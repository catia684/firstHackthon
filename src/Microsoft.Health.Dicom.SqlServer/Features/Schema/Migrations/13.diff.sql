/****************************************************************************************
Guidelines to create migration scripts - https://github.com/microsoft/healthcare-shared-components/tree/master/src/Microsoft.Health.SqlServer/SqlSchemaScriptsGuidelines.md
This diff is broken up into several sections:
 - The first transaction contains changes to tables and stored procedures.
 - The second transaction contains updates to indexes.
 - IMPORTANT: Avoid rebuiling indexes inside the transaction, it locks the table during the transaction.
******************************************************************************************/

SET XACT_ABORT ON

BEGIN TRANSACTION

GO

/***************************************************************************************/
-- STORED PROCEDURE
--     DeleteInstanceV6
--
-- FIRST SCHEMA VERSION
--     6
--
-- DESCRIPTION
--     Removes the specified instance(s) and places them in the DeletedInstance table for later removal
--
-- PARAMETERS
--     @partitionKey
--         * The Partition key
--     @cleanupAfter
--         * The date time offset that the instance can be cleaned up.
--     @createdStatus
--         * Status value representing the created state.
--     @studyInstanceUid
--         * The study instance UID.
--     @seriesInstanceUid
--         * The series instance UID.
--     @sopInstanceUid
--         * The SOP instance UID.
/***************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.DeleteInstanceV6
    @cleanupAfter       DATETIMEOFFSET(0),
    @createdStatus      TINYINT,
    @partitionKey       INT,
    @studyInstanceUid   VARCHAR(64),
    @seriesInstanceUid  VARCHAR(64) = null,
    @sopInstanceUid     VARCHAR(64) = null
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRANSACTION

    DECLARE @deletedInstances AS TABLE
           (PartitionKey INT,
            StudyInstanceUid VARCHAR(64),
            SeriesInstanceUid VARCHAR(64),
            SopInstanceUid VARCHAR(64),
            Status TINYINT,
            Watermark BIGINT)

    DECLARE @studyKey BIGINT
    DECLARE @seriesKey BIGINT
    DECLARE @instanceKey BIGINT
    DECLARE @deletedDate DATETIME2 = SYSUTCDATETIME()
    DECLARE @imageResourceType AS TINYINT = 0

    -- Get the study, series and instance PK
    SELECT  @studyKey = StudyKey,
    @seriesKey = CASE @seriesInstanceUid WHEN NULL THEN NULL ELSE SeriesKey END,
    @instanceKey = CASE @sopInstanceUid WHEN NULL THEN NULL ELSE InstanceKey END
    FROM    dbo.Instance
    WHERE   PartitionKey = @partitionKey
        AND     StudyInstanceUid = @studyInstanceUid
        AND     SeriesInstanceUid = ISNULL(@seriesInstanceUid, SeriesInstanceUid)
        AND     SopInstanceUid = ISNULL(@sopInstanceUid, SopInstanceUid)

    -- Delete the instance and insert the details into DeletedInstance and ChangeFeed
    DELETE  dbo.Instance
        OUTPUT deleted.PartitionKey, deleted.StudyInstanceUid, deleted.SeriesInstanceUid, deleted.SopInstanceUid, deleted.Status, deleted.Watermark
        INTO @deletedInstances
    WHERE   PartitionKey = @partitionKey
        AND     StudyInstanceUid = @studyInstanceUid
        AND     SeriesInstanceUid = ISNULL(@seriesInstanceUid, SeriesInstanceUid)
        AND     SopInstanceUid = ISNULL(@sopInstanceUid, SopInstanceUid)

    IF @@ROWCOUNT = 0
        THROW 50404, 'Instance not found', 1

    -- Deleting tag errors
    DECLARE @deletedTags AS TABLE
    (
        TagKey BIGINT
    )
    DELETE XQTE
        OUTPUT deleted.TagKey
        INTO @deletedTags
    FROM dbo.ExtendedQueryTagError as XQTE
    INNER JOIN @deletedInstances AS DI
    ON XQTE.Watermark = DI.Watermark

    -- Update error count
    IF EXISTS (SELECT * FROM @deletedTags)
    BEGIN
        DECLARE @deletedTagCounts AS TABLE
        (
            TagKey BIGINT,
            ErrorCount INT
        )

        -- Calculate error count
        INSERT INTO @deletedTagCounts
            (TagKey, ErrorCount)
        SELECT TagKey, COUNT(1)
        FROM @deletedTags
        GROUP BY TagKey

        UPDATE XQT
        SET XQT.ErrorCount = XQT.ErrorCount - DTC.ErrorCount
        FROM dbo.ExtendedQueryTag AS XQT
        INNER JOIN @deletedTagCounts AS DTC
        ON XQT.TagKey = DTC.TagKey
    END

    -- Deleting indexed instance tags
    DELETE
    FROM    dbo.ExtendedQueryTagString
    WHERE   SopInstanceKey1 = @studyKey
    AND     SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
    AND     SopInstanceKey3 = ISNULL(@instanceKey, SopInstanceKey3)
    AND     PartitionKey = @partitionKey
    AND     ResourceType = @imageResourceType

    DELETE
    FROM    dbo.ExtendedQueryTagLong
    WHERE   SopInstanceKey1 = @studyKey
    AND     SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
    AND     SopInstanceKey3 = ISNULL(@instanceKey, SopInstanceKey3)
    AND     PartitionKey = @partitionKey
    AND     ResourceType = @imageResourceType

    DELETE
    FROM    dbo.ExtendedQueryTagDouble
    WHERE   SopInstanceKey1 = @studyKey
    AND     SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
    AND     SopInstanceKey3 = ISNULL(@instanceKey, SopInstanceKey3)
    AND     PartitionKey = @partitionKey
    AND     ResourceType = @imageResourceType

    DELETE
    FROM    dbo.ExtendedQueryTagDateTime
    WHERE   SopInstanceKey1 = @studyKey
    AND     SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
    AND     SopInstanceKey3 = ISNULL(@instanceKey, SopInstanceKey3)
    AND     PartitionKey = @partitionKey
    AND     ResourceType = @imageResourceType

    DELETE
    FROM    dbo.ExtendedQueryTagPersonName
    WHERE   SopInstanceKey1 = @studyKey
    AND     SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
    AND     SopInstanceKey3 = ISNULL(@instanceKey, SopInstanceKey3)
    AND     PartitionKey = @partitionKey
    AND     ResourceType = @imageResourceType

    INSERT INTO dbo.DeletedInstance
    (PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, Watermark, DeletedDateTime, RetryCount, CleanupAfter)
    SELECT PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, Watermark, @deletedDate, 0 , @cleanupAfter
    FROM @deletedInstances

    INSERT INTO dbo.ChangeFeed
    (TimeStamp, Action, PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, OriginalWatermark)
    SELECT @deletedDate, 1, PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, Watermark
    FROM @deletedInstances
    WHERE Status = @createdStatus

    UPDATE CF
    SET CF.CurrentWatermark = NULL
    FROM dbo.ChangeFeed AS CF WITH(FORCESEEK)
    JOIN @deletedInstances AS DI
    ON CF.PartitionKey = DI.PartitionKey
        AND CF.StudyInstanceUid = DI.StudyInstanceUid
        AND CF.SeriesInstanceUid = DI.SeriesInstanceUid
        AND CF.SopInstanceUid = DI.SopInstanceUid

    -- If this is the last instance for a series, remove the series
    IF NOT EXISTS ( SELECT  *
                    FROM    dbo.Instance WITH(HOLDLOCK, UPDLOCK)
                    WHERE   StudyKey = @studyKey
                    AND     SeriesInstanceUid = ISNULL(@seriesInstanceUid, SeriesInstanceUid))
    BEGIN
        DELETE
        FROM    dbo.Series
        WHERE   StudyKey = @studyKey
        AND     SeriesInstanceUid = ISNULL(@seriesInstanceUid, SeriesInstanceUid)
        AND     PartitionKey = @partitionKey

        -- Deleting indexed series tags
        DELETE
        FROM    dbo.ExtendedQueryTagString
        WHERE   SopInstanceKey1 = @studyKey
        AND     SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
        AND     PartitionKey = @partitionKey
        AND     ResourceType = @imageResourceType

        DELETE
        FROM    dbo.ExtendedQueryTagLong
        WHERE   SopInstanceKey1 = @studyKey
        AND     SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
        AND     PartitionKey = @partitionKey
        AND     ResourceType = @imageResourceType

        DELETE
        FROM    dbo.ExtendedQueryTagDouble
        WHERE   SopInstanceKey1 = @studyKey
        AND     SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
        AND     PartitionKey = @partitionKey
        AND     ResourceType = @imageResourceType

        DELETE
        FROM    dbo.ExtendedQueryTagDateTime
        WHERE   SopInstanceKey1 = @studyKey
        AND     SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
        AND     PartitionKey = @partitionKey
        AND     ResourceType = @imageResourceType

        DELETE
        FROM    dbo.ExtendedQueryTagPersonName
        WHERE   SopInstanceKey1 = @studyKey
        AND     SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
        AND     PartitionKey = @partitionKey
        AND     ResourceType = @imageResourceType
    END

    -- If we've removing the series, see if it's the last for a study and if so, remove the study
    IF NOT EXISTS ( SELECT  *
                    FROM    dbo.Series WITH(HOLDLOCK, UPDLOCK)
                    WHERE   Studykey = @studyKey
                    AND     PartitionKey = @partitionKey)
    BEGIN
        DELETE
        FROM    dbo.Study
        WHERE   StudyKey = @studyKey
        AND     PartitionKey = @partitionKey

        -- Deleting indexed study tags
        DELETE
        FROM    dbo.ExtendedQueryTagString
        WHERE   SopInstanceKey1 = @studyKey
        AND     PartitionKey = @partitionKey
        AND     ResourceType = @imageResourceType

        DELETE
        FROM    dbo.ExtendedQueryTagLong
        WHERE   SopInstanceKey1 = @studyKey
        AND     PartitionKey = @partitionKey
        AND     ResourceType = @imageResourceType

        DELETE
        FROM    dbo.ExtendedQueryTagDouble
        WHERE   SopInstanceKey1 = @studyKey
        AND     PartitionKey = @partitionKey
        AND     ResourceType = @imageResourceType

        DELETE
        FROM    dbo.ExtendedQueryTagDateTime
        WHERE   SopInstanceKey1 = @studyKey
        AND     PartitionKey = @partitionKey
        AND     ResourceType = @imageResourceType

        DELETE
        FROM    dbo.ExtendedQueryTagPersonName
        WHERE   SopInstanceKey1 = @studyKey
        AND     PartitionKey = @partitionKey
        AND     ResourceType = @imageResourceType
    END

    COMMIT TRANSACTION
END
GO

/***************************************************************************************/
-- STORED PROCEDURE
--    DeleteExtendedQueryTagV8
--
-- DESCRIPTION
--    Delete specific extended query tag
--
-- PARAMETERS
--     @tagPath
--         * The extended query tag path
--     @dataType
--         * the data type of extended query tag. 0 -- String, 1 -- Long, 2 -- Double, 3 -- DateTime, 4 -- PersonName
/***************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.DeleteExtendedQueryTagV8
    @tagPath VARCHAR(64),
    @dataType TINYINT
AS
BEGIN
    SET NOCOUNT     ON
    SET XACT_ABORT  ON

    BEGIN TRANSACTION

        DECLARE @tagKey INT
        DECLARE @imageResourceType AS TINYINT = 0

        SELECT @tagKey = TagKey
        FROM dbo.ExtendedQueryTag WITH(XLOCK)
        WHERE dbo.ExtendedQueryTag.TagPath = @tagPath

        -- Check existence
        IF @@ROWCOUNT = 0
            THROW 50404, 'extended query tag not found', 1

        -- Update status to Deleting
        UPDATE dbo.ExtendedQueryTag
        SET TagStatus = 2
        WHERE dbo.ExtendedQueryTag.TagKey = @tagKey

    COMMIT TRANSACTION

    BEGIN TRANSACTION

        -- Delete index data
        IF @dataType = 0
            DELETE FROM dbo.ExtendedQueryTagString WHERE TagKey = @tagKey AND ResourceType = @imageResourceType
        ELSE IF @dataType = 1
            DELETE FROM dbo.ExtendedQueryTagLong WHERE TagKey = @tagKey AND ResourceType = @imageResourceType
        ELSE IF @dataType = 2
            DELETE FROM dbo.ExtendedQueryTagDouble WHERE TagKey = @tagKey AND ResourceType = @imageResourceType
        ELSE IF @dataType = 3
            DELETE FROM dbo.ExtendedQueryTagDateTime WHERE TagKey = @tagKey AND ResourceType = @imageResourceType
        ELSE
            DELETE FROM dbo.ExtendedQueryTagPersonName WHERE TagKey = @tagKey AND ResourceType = @imageResourceType

        -- Delete errors
        DELETE FROM dbo.ExtendedQueryTagError
        WHERE TagKey = @tagKey

        -- Delete tag
        DELETE FROM dbo.ExtendedQueryTag
        WHERE TagKey = @tagKey

    COMMIT TRANSACTION
END
GO

COMMIT TRANSACTION
