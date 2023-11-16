﻿/*************************************************************
    Stored procedures for updating an instance status.
**************************************************************/
--
-- STORED PROCEDURE
--     EndUpdateInstanceV50
--
-- DESCRIPTION
--     Bulk update all instances in a study, creates new entry in changefeed and fileProperty for each new file added.
--
-- PARAMETERS
--     @partitionKey
--         * The partition key.
--     @studyInstanceUid
--         * The study instance UID.
--     @patientId
--         * The Id of the patient.
--     @patientName
--         * The name of the patient.
--     @patientBirthDate
--         * The patient's birth date.
--     @insertFileProperties
--         * A table type containing the file properties to insert.
--
-- RETURN VALUE
--     None
--
CREATE OR ALTER PROCEDURE dbo.EndUpdateInstanceV50
    @partitionKey                       INT,
    @studyInstanceUid                   VARCHAR(64),
    @patientId                          NVARCHAR(64) = NULL,
    @patientName                        NVARCHAR(325) = NULL,
    @patientBirthDate                   DATE = NULL,
    @insertFileProperties               dbo.FilePropertyTableType READONLY,
    @stringExtendedQueryTags dbo.InsertStringExtendedQueryTagTableType_1         READONLY,
    @longExtendedQueryTags dbo.InsertLongExtendedQueryTagTableType_1             READONLY,
    @doubleExtendedQueryTags dbo.InsertDoubleExtendedQueryTagTableType_1         READONLY,
    @dateTimeExtendedQueryTags dbo.InsertDateTimeExtendedQueryTagTableType_2     READONLY,
    @personNameExtendedQueryTags dbo.InsertPersonNameExtendedQueryTagTableType_1 READONLY
AS
BEGIN
    SET NOCOUNT ON

    SET XACT_ABORT ON
    BEGIN TRANSACTION

        DECLARE @currentDate DATETIME2(7) = SYSUTCDATETIME()
        DECLARE @resourceType TINYINT = 0
        DECLARE @studyKey BIGINT

        CREATE TABLE #UpdatedInstances
               (PartitionKey INT,
                StudyInstanceUid VARCHAR(64),
                SeriesInstanceUid VARCHAR(64),
                SopInstanceUid VARCHAR(64),
                Watermark BIGINT,
                OriginalWatermark BIGINT,
                InstanceKey BIGINT)

        DELETE FROM #UpdatedInstances

        UPDATE dbo.Instance
        SET LastStatusUpdatedDate = @currentDate,
            OriginalWatermark = ISNULL(OriginalWatermark, Watermark),
            Watermark = NewWatermark,
            NewWatermark = NULL
        OUTPUT deleted.PartitionKey, @studyInstanceUid, deleted.SeriesInstanceUid, deleted.SopInstanceUid, inserted.Watermark, inserted.OriginalWatermark, deleted.InstanceKey INTO #UpdatedInstances
        WHERE PartitionKey = @partitionKey
          AND StudyInstanceUid = @studyInstanceUid
          AND Status = 1
          AND NewWatermark IS NOT NULL

        -- Create index on temp table so we can join on watermark when we need to update change feed with file path.
        IF NOT EXISTS (SELECT *
                       FROM   tempdb.sys.indexes
                       WHERE  name = 'IXC_UpdatedInstances')
            CREATE UNIQUE INDEX IXC_UpdatedInstances ON #UpdatedInstances (Watermark)

        -- Create index on temp table so we can join on instance key and watermark when we need to insert file
        -- properties when instance key alone is does not specify a unique row on the table
        IF NOT EXISTS (SELECT *
                       FROM   tempdb.sys.indexes
                       WHERE  name = 'IXC_UpdatedInstanceKeyWatermark')
        CREATE UNIQUE CLUSTERED INDEX IXC_UpdatedInstanceKeyWatermark ON #UpdatedInstances (InstanceKey, OriginalWatermark)

        -- Only updating patient information in a study
        UPDATE dbo.Study
        SET PatientId = ISNULL(@patientId, PatientId),
            PatientName = ISNULL(@patientName, PatientName),
            PatientBirthDate = ISNULL(@patientBirthDate, PatientBirthDate),
            @studyKey = StudyKey
        WHERE PartitionKey = @partitionKey
            AND StudyInstanceUid = @studyInstanceUid

        -- The study does not exist. May be deleted
        IF @@ROWCOUNT = 0
            THROW 50404, 'Study does not exist', 1

        -- Delete from file properties any rows with "stale" watermarks if we will be inserting new ones
        IF EXISTS (SELECT 1 FROM @insertFileProperties)
        DELETE FP
        FROM dbo.FileProperty as FP
        INNER JOIN #UpdatedInstances U
        ON U.InstanceKey = FP.InstanceKey
        WHERE U.OriginalWatermark != FP.Watermark

        -- Insert new file properties from added blobs, @insertFileProperties will be empty when external store not
        -- enabled
        INSERT INTO dbo.FileProperty
        (InstanceKey, Watermark, FilePath, ETag)
        SELECT U.InstanceKey, I.Watermark, I.FilePath, I.ETag
        FROM @insertFileProperties I
        INNER JOIN #UpdatedInstances U
        ON U.Watermark = I.Watermark

        -- Update extended query tags value if any
        -- String Key tags
        IF EXISTS (SELECT 1 FROM @stringExtendedQueryTags)
        BEGIN
            UPDATE EQT
            SET EQT.TagValue = S.TagValue
            FROM dbo.ExtendedQueryTagString EQT
            INNER JOIN @stringExtendedQueryTags S
            ON EQT.ResourceType = @resourceType
                AND EQT.TagKey = S.TagKey
                AND EQT.PartitionKey = @partitionKey
                AND EQT.SopInstanceKey1 = @studyKey
        END

        -- Long Key tags
        IF EXISTS (SELECT 1 FROM @longExtendedQueryTags)
        BEGIN
            UPDATE EQT
            SET EQT.TagValue = S.TagValue
            FROM dbo.ExtendedQueryTagLong EQT
            INNER JOIN @longExtendedQueryTags S
            ON EQT.ResourceType = @resourceType
                AND EQT.TagKey = S.TagKey
                AND EQT.PartitionKey = @partitionKey
                AND EQT.SopInstanceKey1 = @studyKey
        END

        -- Double Key tags
        IF EXISTS (SELECT 1 FROM @doubleExtendedQueryTags)
        BEGIN
            UPDATE EQT
            SET EQT.TagValue = S.TagValue
            FROM dbo.ExtendedQueryTagDouble EQT
            INNER JOIN @doubleExtendedQueryTags S
            ON EQT.ResourceType = @resourceType
                AND EQT.TagKey = S.TagKey
                AND EQT.PartitionKey = @partitionKey
                AND EQT.SopInstanceKey1 = @studyKey
        END

        -- Double Key tags
        IF EXISTS (SELECT 1 FROM @dateTimeExtendedQueryTags)
        BEGIN
            UPDATE EQT
            SET EQT.TagValue = S.TagValueUtc
            FROM dbo.ExtendedQueryTagDateTime EQT
            INNER JOIN @dateTimeExtendedQueryTags S
            ON EQT.ResourceType = @resourceType
                AND EQT.TagKey = S.TagKey
                AND EQT.PartitionKey = @partitionKey
                AND EQT.SopInstanceKey1 = @studyKey
        END

        -- Person Key tags
        IF EXISTS (SELECT 1 FROM @personNameExtendedQueryTags)
        BEGIN
            UPDATE EQT
            SET EQT.TagValue = S.TagValue
            FROM dbo.ExtendedQueryTagPersonName EQT
            INNER JOIN @personNameExtendedQueryTags S
            ON EQT.ResourceType = @resourceType
                AND EQT.TagKey = S.TagKey
                AND EQT.PartitionKey = @partitionKey
                AND EQT.SopInstanceKey1 = @studyKey
        END

        -- Insert into change feed table for update action type
        INSERT INTO dbo.ChangeFeed
        (Action, PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, OriginalWatermark)
        SELECT 2, PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, Watermark
        FROM #UpdatedInstances

        -- Update existing instance currentWatermark to latest and update file path
        UPDATE C
        SET CurrentWatermark = U.Watermark, FilePath = I.FilePath
        FROM dbo.ChangeFeed C
        JOIN #UpdatedInstances U
        ON C.PartitionKey = U.PartitionKey
            AND C.StudyInstanceUid = U.StudyInstanceUid
            AND C.SeriesInstanceUid = U.SeriesInstanceUid
            AND C.SopInstanceUid = U.SopInstanceUid
        LEFT OUTER JOIN @insertFileProperties I
        ON I.Watermark = U.Watermark

    COMMIT TRANSACTION
END
