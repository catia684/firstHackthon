
/*************************************************************************************************
    Auto-Generated from Sql build task. Do not manually edit it. 
**************************************************************************************************/
SET XACT_ABORT ON
BEGIN TRAN
IF EXISTS (SELECT *
           FROM   sys.tables
           WHERE  name = 'Instance')
    BEGIN
        ROLLBACK;
        RETURN;
    END

CREATE SEQUENCE dbo.WatermarkSequence
    AS BIGINT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO CYCLE
    CACHE 1000000;

CREATE SEQUENCE dbo.StudyKeySequence
    AS BIGINT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO CYCLE
    CACHE 1000000;

CREATE SEQUENCE dbo.SeriesKeySequence
    AS BIGINT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO CYCLE
    CACHE 1000000;

CREATE SEQUENCE dbo.InstanceKeySequence
    AS BIGINT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO CYCLE
    CACHE 1000000;

CREATE SEQUENCE dbo.TagKeySequence
    AS INT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO CYCLE
    CACHE 10000;

CREATE SEQUENCE dbo.PartitionKeySequence
    AS INT
    START WITH 2
    INCREMENT BY 1
    MINVALUE 1
    NO CYCLE
    CACHE 10000;

CREATE SEQUENCE dbo.WorkitemKeySequence
    AS INT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO CYCLE
    CACHE 10000;

CREATE TABLE dbo.ChangeFeed (
    Sequence          BIGINT             IDENTITY (1, 1) NOT NULL,
    Timestamp         DATETIMEOFFSET (7) NOT NULL,
    Action            TINYINT            NOT NULL,
    StudyInstanceUid  VARCHAR (64)       NOT NULL,
    SeriesInstanceUid VARCHAR (64)       NOT NULL,
    SopInstanceUid    VARCHAR (64)       NOT NULL,
    OriginalWatermark BIGINT             NOT NULL,
    CurrentWatermark  BIGINT             NULL,
    PartitionKey      INT                DEFAULT 1 NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_ChangeFeed
    ON dbo.ChangeFeed(Sequence);

CREATE NONCLUSTERED INDEX IX_ChangeFeed_PartitionKey_StudyInstanceUid_SeriesInstanceUid_SopInstanceUid
    ON dbo.ChangeFeed(PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.DeletedInstance (
    StudyInstanceUid  VARCHAR (64)       NOT NULL,
    SeriesInstanceUid VARCHAR (64)       NOT NULL,
    SopInstanceUid    VARCHAR (64)       NOT NULL,
    Watermark         BIGINT             NOT NULL,
    DeletedDateTime   DATETIMEOFFSET (0) NOT NULL,
    RetryCount        INT                NOT NULL,
    CleanupAfter      DATETIMEOFFSET (0) NOT NULL,
    PartitionKey      INT                DEFAULT 1 NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_DeletedInstance
    ON dbo.DeletedInstance(PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, Watermark);

CREATE NONCLUSTERED INDEX IX_DeletedInstance_RetryCount_CleanupAfter
    ON dbo.DeletedInstance(RetryCount, CleanupAfter)
    INCLUDE(PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, Watermark) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.ExtendedQueryTag (
    TagKey            INT           NOT NULL,
    TagPath           VARCHAR (64)  NOT NULL,
    TagVR             VARCHAR (2)   NOT NULL,
    TagPrivateCreator NVARCHAR (64) NULL,
    TagLevel          TINYINT       NOT NULL,
    TagStatus         TINYINT       NOT NULL,
    QueryStatus       TINYINT       DEFAULT 1 NOT NULL,
    ErrorCount        INT           DEFAULT 0 NOT NULL
);

CREATE UNIQUE CLUSTERED INDEX IXC_ExtendedQueryTag
    ON dbo.ExtendedQueryTag(TagKey);

CREATE UNIQUE NONCLUSTERED INDEX IX_ExtendedQueryTag_TagPath
    ON dbo.ExtendedQueryTag(TagPath);

CREATE TABLE dbo.ExtendedQueryTagDateTime (
    TagKey          INT           NOT NULL,
    TagValue        DATETIME2 (7) NOT NULL,
    SopInstanceKey1 BIGINT        NOT NULL,
    SopInstanceKey2 BIGINT        NULL,
    SopInstanceKey3 BIGINT        NULL,
    Watermark       BIGINT        NOT NULL,
    TagValueUtc     DATETIME2 (7) NULL,
    PartitionKey    INT           DEFAULT 1 NOT NULL,
    ResourceType    TINYINT       DEFAULT 0 NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_ExtendedQueryTagDateTime
    ON dbo.ExtendedQueryTagDateTime(ResourceType, TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagDateTime_TagKey_PartitionKey_ResourceType_SopInstanceKey1_SopInstanceKey2_SopInstanceKey3
    ON dbo.ExtendedQueryTagDateTime(ResourceType, TagKey, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3)
    INCLUDE(Watermark) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagDateTime_PartitionKey_ResourceType_SopInstanceKey1_SopInstanceKey2_SopInstanceKey3
    ON dbo.ExtendedQueryTagDateTime(ResourceType, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.ExtendedQueryTagDouble (
    TagKey          INT        NOT NULL,
    TagValue        FLOAT (53) NOT NULL,
    SopInstanceKey1 BIGINT     NOT NULL,
    SopInstanceKey2 BIGINT     NULL,
    SopInstanceKey3 BIGINT     NULL,
    Watermark       BIGINT     NOT NULL,
    PartitionKey    INT        DEFAULT 1 NOT NULL,
    ResourceType    TINYINT    DEFAULT 0 NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_ExtendedQueryTagDouble
    ON dbo.ExtendedQueryTagDouble(ResourceType, TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagDouble_TagKey_PartitionKey_ResourceType_SopInstanceKey1_SopInstanceKey2_SopInstanceKey3
    ON dbo.ExtendedQueryTagDouble(ResourceType, TagKey, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3)
    INCLUDE(Watermark) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagDouble_PartitionKey_ResourceType_SopInstanceKey1_SopInstanceKey2_SopInstanceKey3
    ON dbo.ExtendedQueryTagDouble(ResourceType, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.ExtendedQueryTagError (
    TagKey      INT           NOT NULL,
    ErrorCode   SMALLINT      NOT NULL,
    Watermark   BIGINT        NOT NULL,
    CreatedTime DATETIME2 (7) NOT NULL
);

CREATE UNIQUE CLUSTERED INDEX IXC_ExtendedQueryTagError
    ON dbo.ExtendedQueryTagError(TagKey, Watermark);

CREATE UNIQUE NONCLUSTERED INDEX IX_ExtendedQueryTagError_CreatedTime_Watermark_TagKey
    ON dbo.ExtendedQueryTagError(CreatedTime, Watermark, TagKey)
    INCLUDE(ErrorCode);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagError_Watermark
    ON dbo.ExtendedQueryTagError(Watermark);

CREATE TABLE dbo.ExtendedQueryTagLong (
    TagKey          INT     NOT NULL,
    TagValue        BIGINT  NOT NULL,
    SopInstanceKey1 BIGINT  NOT NULL,
    SopInstanceKey2 BIGINT  NULL,
    SopInstanceKey3 BIGINT  NULL,
    Watermark       BIGINT  NOT NULL,
    PartitionKey    INT     DEFAULT 1 NOT NULL,
    ResourceType    TINYINT DEFAULT 0 NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_ExtendedQueryTagLong
    ON dbo.ExtendedQueryTagLong(ResourceType, TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagLong_TagKey_PartitionKey_ResourceType_SopInstanceKey1_SopInstanceKey2_SopInstanceKey3
    ON dbo.ExtendedQueryTagLong(ResourceType, TagKey, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3)
    INCLUDE(Watermark) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagLong_PartitionKey_ResourceType_SopInstanceKey1_SopInstanceKey2_SopInstanceKey3
    ON dbo.ExtendedQueryTagLong(ResourceType, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.ExtendedQueryTagOperation (
    TagKey      INT              NOT NULL,
    OperationId UNIQUEIDENTIFIER NOT NULL
);

CREATE UNIQUE CLUSTERED INDEX IXC_ExtendedQueryTagOperation
    ON dbo.ExtendedQueryTagOperation(TagKey);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagOperation_OperationId
    ON dbo.ExtendedQueryTagOperation(OperationId)
    INCLUDE(TagKey);

CREATE TABLE dbo.ExtendedQueryTagPersonName (
    TagKey             INT            NOT NULL,
    TagValue           NVARCHAR (200) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    SopInstanceKey1    BIGINT         NOT NULL,
    SopInstanceKey2    BIGINT         NULL,
    SopInstanceKey3    BIGINT         NULL,
    Watermark          BIGINT         NOT NULL,
    WatermarkAndTagKey AS             CONCAT(TagKey, '.', Watermark),
    TagValueWords      AS             REPLACE(REPLACE(TagValue, '^', ' '), '=', ' ') PERSISTED,
    PartitionKey       INT            DEFAULT 1 NOT NULL,
    ResourceType       TINYINT        DEFAULT 0 NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_ExtendedQueryTagPersonName
    ON dbo.ExtendedQueryTagPersonName(ResourceType, TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagPersonName_TagKey_PartitionKey_ResourceType_SopInstanceKey1_SopInstanceKey2_SopInstanceKey3
    ON dbo.ExtendedQueryTagPersonName(ResourceType, TagKey, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3)
    INCLUDE(Watermark) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagPersonName_PartitionKey_ResourceType_SopInstanceKey1_SopInstanceKey2_SopInstanceKey3
    ON dbo.ExtendedQueryTagPersonName(ResourceType, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3) WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE NONCLUSTERED INDEX IXC_ExtendedQueryTagPersonName_WatermarkAndTagKey
    ON dbo.ExtendedQueryTagPersonName(WatermarkAndTagKey) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.ExtendedQueryTagString (
    TagKey          INT           NOT NULL,
    TagValue        NVARCHAR (64) NOT NULL,
    SopInstanceKey1 BIGINT        NOT NULL,
    SopInstanceKey2 BIGINT        NULL,
    SopInstanceKey3 BIGINT        NULL,
    Watermark       BIGINT        NOT NULL,
    PartitionKey    INT           DEFAULT 1 NOT NULL,
    ResourceType    TINYINT       DEFAULT 0 NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_ExtendedQueryTagString
    ON dbo.ExtendedQueryTagString(ResourceType, TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagString_TagKey_PartitionKey_ResourceType_SopInstanceKey1_SopInstanceKey2_SopInstanceKey3
    ON dbo.ExtendedQueryTagString(ResourceType, TagKey, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3)
    INCLUDE(Watermark) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_ExtendedQueryTagString_PartitionKey_ResourceType_SopInstanceKey1_SopInstanceKey2_SopInstanceKey3
    ON dbo.ExtendedQueryTagString(ResourceType, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.Instance (
    InstanceKey           BIGINT        NOT NULL,
    SeriesKey             BIGINT        NOT NULL,
    StudyKey              BIGINT        NOT NULL,
    StudyInstanceUid      VARCHAR (64)  NOT NULL,
    SeriesInstanceUid     VARCHAR (64)  NOT NULL,
    SopInstanceUid        VARCHAR (64)  NOT NULL,
    Watermark             BIGINT        NOT NULL,
    Status                TINYINT       NOT NULL,
    LastStatusUpdatedDate DATETIME2 (7) NOT NULL,
    CreatedDate           DATETIME2 (7) NOT NULL,
    PartitionKey          INT           DEFAULT 1 NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_Instance
    ON dbo.Instance(SeriesKey, InstanceKey);

CREATE UNIQUE NONCLUSTERED INDEX IX_Instance_StudyInstanceUid_SeriesInstanceUid_SopInstanceUid_PartitionKey
    ON dbo.Instance(StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, PartitionKey)
    INCLUDE(Status, Watermark) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Instance_StudyInstanceUid_Status_PartitionKey
    ON dbo.Instance(StudyInstanceUid, Status, PartitionKey)
    INCLUDE(Watermark) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Instance_StudyInstanceUid_SeriesInstanceUid_Status_PartitionKey
    ON dbo.Instance(StudyInstanceUid, SeriesInstanceUid, Status, PartitionKey)
    INCLUDE(Watermark) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Instance_SopInstanceUid_Status_PartitionKey
    ON dbo.Instance(SopInstanceUid, Status, PartitionKey)
    INCLUDE(StudyInstanceUid, SeriesInstanceUid, Watermark) WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE NONCLUSTERED INDEX IX_Instance_Watermark_Status
    ON dbo.Instance(Watermark, Status)
    INCLUDE(PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Instance_SeriesKey_Status_Watermark
    ON dbo.Instance(SeriesKey, Status, Watermark)
    INCLUDE(StudyInstanceUid, SeriesInstanceUid, SopInstanceUid) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Instance_StudyKey_Status_Watermark
    ON dbo.Instance(StudyKey, Status, Watermark)
    INCLUDE(StudyInstanceUid, SeriesInstanceUid, SopInstanceUid) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.Partition (
    PartitionKey  INT           NOT NULL,
    PartitionName VARCHAR (64)  NOT NULL,
    CreatedDate   DATETIME2 (7) NOT NULL
);

CREATE UNIQUE CLUSTERED INDEX IXC_Partition
    ON dbo.Partition(PartitionKey);

CREATE UNIQUE NONCLUSTERED INDEX IX_Partition_PartitionName
    ON dbo.Partition(PartitionName)
    INCLUDE(PartitionKey);

INSERT  INTO dbo.Partition (PartitionKey, PartitionName, CreatedDate)
VALUES                    (1, 'Microsoft.Default', SYSUTCDATETIME());

CREATE TABLE dbo.Series (
    SeriesKey                       BIGINT        NOT NULL,
    StudyKey                        BIGINT        NOT NULL,
    SeriesInstanceUid               VARCHAR (64)  NOT NULL,
    Modality                        NVARCHAR (16) NULL,
    PerformedProcedureStepStartDate DATE          NULL,
    ManufacturerModelName           NVARCHAR (64) NULL,
    PartitionKey                    INT           DEFAULT 1 NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_Series
    ON dbo.Series(PartitionKey, StudyKey, SeriesKey);

CREATE UNIQUE NONCLUSTERED INDEX IX_Series_SeriesKey
    ON dbo.Series(SeriesKey) WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE NONCLUSTERED INDEX IX_Series_SeriesInstanceUid_PartitionKey
    ON dbo.Series(SeriesInstanceUid, PartitionKey)
    INCLUDE(StudyKey) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Series_Modality_PartitionKey
    ON dbo.Series(Modality, PartitionKey)
    INCLUDE(StudyKey, SeriesKey) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Series_PerformedProcedureStepStartDate_PartitionKey
    ON dbo.Series(PerformedProcedureStepStartDate, PartitionKey)
    INCLUDE(StudyKey, SeriesKey) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Series_ManufacturerModelName_PartitionKey
    ON dbo.Series(ManufacturerModelName, PartitionKey)
    INCLUDE(StudyKey, SeriesKey) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.Study (
    StudyKey                    BIGINT         NOT NULL,
    StudyInstanceUid            VARCHAR (64)   NOT NULL,
    PatientId                   NVARCHAR (64)  NOT NULL,
    PatientName                 NVARCHAR (200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    ReferringPhysicianName      NVARCHAR (200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    StudyDate                   DATE           NULL,
    StudyDescription            NVARCHAR (64)  NULL,
    AccessionNumber             NVARCHAR (16)  NULL,
    PatientNameWords            AS             REPLACE(REPLACE(PatientName, '^', ' '), '=', ' ') PERSISTED,
    ReferringPhysicianNameWords AS             REPLACE(REPLACE(ReferringPhysicianName, '^', ' '), '=', ' ') PERSISTED,
    PatientBirthDate            DATE           NULL,
    PartitionKey                INT            DEFAULT 1 NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_Study
    ON dbo.Study(PartitionKey, StudyKey);

CREATE UNIQUE NONCLUSTERED INDEX IX_Study_StudyKey
    ON dbo.Study(StudyKey) WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE NONCLUSTERED INDEX IX_Study_StudyInstanceUid_PartitionKey
    ON dbo.Study(StudyInstanceUid, PartitionKey)
    INCLUDE(StudyKey) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Study_PatientId_PartitionKey
    ON dbo.Study(PatientId, PartitionKey)
    INCLUDE(StudyKey) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Study_PatientName_PartitionKey
    ON dbo.Study(PatientName, PartitionKey)
    INCLUDE(StudyKey) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Study_ReferringPhysicianName_PartitionKey
    ON dbo.Study(ReferringPhysicianName, PartitionKey)
    INCLUDE(StudyKey) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Study_StudyDate_PartitionKey
    ON dbo.Study(StudyDate, PartitionKey)
    INCLUDE(StudyKey) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Study_StudyDescription_PartitionKey
    ON dbo.Study(StudyDescription, PartitionKey)
    INCLUDE(StudyKey) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Study_AccessionNumber_PartitionKey
    ON dbo.Study(AccessionNumber, PartitionKey)
    INCLUDE(StudyKey) WITH (DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_Study_PatientBirthDate_PartitionKey
    ON dbo.Study(PatientBirthDate, PartitionKey)
    INCLUDE(StudyKey) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.Workitem (
    WorkitemKey           BIGINT        NOT NULL,
    PartitionKey          INT           DEFAULT 1 NOT NULL,
    WorkitemUid           VARCHAR (64)  NOT NULL,
    TransactionUid        VARCHAR (64)  NULL,
    Status                TINYINT       NOT NULL,
    CreatedDate           DATETIME2 (7) NOT NULL,
    LastStatusUpdatedDate DATETIME2 (7) NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_Workitem
    ON dbo.Workitem(PartitionKey, WorkitemKey);

CREATE UNIQUE NONCLUSTERED INDEX IX_Workitem_WorkitemUid_PartitionKey
    ON dbo.Workitem(WorkitemUid, PartitionKey)
    INCLUDE(WorkitemKey, Status, TransactionUid) WITH (DATA_COMPRESSION = PAGE);

CREATE TABLE dbo.WorkitemQueryTag (
    TagKey  INT          NOT NULL,
    TagPath VARCHAR (64) NOT NULL,
    TagVR   VARCHAR (2)  NOT NULL
)
WITH (DATA_COMPRESSION = PAGE);

CREATE UNIQUE CLUSTERED INDEX IXC_WorkitemQueryTag
    ON dbo.WorkitemQueryTag(TagKey);

CREATE UNIQUE NONCLUSTERED INDEX IXC_WorkitemQueryTag_TagPath
    ON dbo.WorkitemQueryTag(TagPath) WITH (DATA_COMPRESSION = PAGE);

CREATE TYPE dbo.AddExtendedQueryTagsInputTableType_1 AS TABLE (
    TagPath           VARCHAR (64) ,
    TagVR             VARCHAR (2)  ,
    TagPrivateCreator NVARCHAR (64),
    TagLevel          TINYINT      );

CREATE TYPE dbo.InsertStringExtendedQueryTagTableType_1 AS TABLE (
    TagKey   INT          ,
    TagValue NVARCHAR (64),
    TagLevel TINYINT      );

CREATE TYPE dbo.InsertDoubleExtendedQueryTagTableType_1 AS TABLE (
    TagKey   INT       ,
    TagValue FLOAT (53),
    TagLevel TINYINT   );

CREATE TYPE dbo.InsertLongExtendedQueryTagTableType_1 AS TABLE (
    TagKey   INT    ,
    TagValue BIGINT ,
    TagLevel TINYINT);

CREATE TYPE dbo.InsertDateTimeExtendedQueryTagTableType_1 AS TABLE (
    TagKey   INT          ,
    TagValue DATETIME2 (7),
    TagLevel TINYINT      );

CREATE TYPE dbo.InsertDateTimeExtendedQueryTagTableType_2 AS TABLE (
    TagKey      INT          ,
    TagValue    DATETIME2 (7),
    TagValueUtc DATETIME2 (7) NULL,
    TagLevel    TINYINT      );

CREATE TYPE dbo.InsertPersonNameExtendedQueryTagTableType_1 AS TABLE (
    TagKey   INT           ,
    TagValue NVARCHAR (200) COLLATE SQL_Latin1_General_CP1_CI_AI,
    TagLevel TINYINT       );

CREATE TYPE dbo.ExtendedQueryTagKeyTableType_1 AS TABLE (
    TagKey INT);

INSERT  INTO dbo.WorkitemQueryTag (TagKey, TagPath, TagVR)
VALUES                           ( NEXT VALUE FOR TagKeySequence, '00100010', 'PN');

INSERT  INTO dbo.WorkitemQueryTag (TagKey, TagPath, TagVR)
VALUES                           ( NEXT VALUE FOR TagKeySequence, '00100020', 'LO');

INSERT  INTO dbo.WorkitemQueryTag (TagKey, TagPath, TagVR)
VALUES                           ( NEXT VALUE FOR TagKeySequence, '0040A370.00080050', 'SQ');

INSERT  INTO dbo.WorkitemQueryTag (TagKey, TagPath, TagVR)
VALUES                           ( NEXT VALUE FOR TagKeySequence, '0040A370.00401001', 'SQ');

INSERT  INTO dbo.WorkitemQueryTag (TagKey, TagPath, TagVR)
VALUES                           ( NEXT VALUE FOR TagKeySequence, '00404005', 'DT');

INSERT  INTO dbo.WorkitemQueryTag (TagKey, TagPath, TagVR)
VALUES                           ( NEXT VALUE FOR TagKeySequence, '00404025.00080100', 'SQ');

INSERT  INTO dbo.WorkitemQueryTag (TagKey, TagPath, TagVR)
VALUES                           ( NEXT VALUE FOR TagKeySequence, '00404026.00080100', 'SQ');

INSERT  INTO dbo.WorkitemQueryTag (TagKey, TagPath, TagVR)
VALUES                           ( NEXT VALUE FOR TagKeySequence, '00741000', 'CS');

INSERT  INTO dbo.WorkitemQueryTag (TagKey, TagPath, TagVR)
VALUES                           ( NEXT VALUE FOR TagKeySequence, '00404027.00080100', 'SQ');

COMMIT
GO
IF ((SELECT is_read_committed_snapshot_on
     FROM   sys.databases
     WHERE  database_id = DB_ID()) = 0)
    BEGIN
        ALTER DATABASE CURRENT
            SET READ_COMMITTED_SNAPSHOT ON;
    END

IF ((SELECT is_auto_update_stats_async_on
     FROM   sys.databases
     WHERE  database_id = DB_ID()) = 0)
    BEGIN
        ALTER DATABASE CURRENT
            SET AUTO_UPDATE_STATISTICS_ASYNC ON;
    END

IF ((SELECT is_ansi_nulls_on
     FROM   sys.databases
     WHERE  database_id = DB_ID()) = 0)
    BEGIN
        ALTER DATABASE CURRENT
            SET ANSI_NULLS ON;
    END

GO
IF NOT EXISTS (SELECT *
               FROM   sys.fulltext_catalogs
               WHERE  name = 'Dicom_Catalog')
    BEGIN
        CREATE FULLTEXT CATALOG Dicom_Catalog
            WITH ACCENT_SENSITIVITY = OFF
            AS DEFAULT;
    END


GO
IF NOT EXISTS (SELECT *
               FROM   sys.fulltext_indexes
               WHERE  object_id = object_id('dbo.Study'))
    BEGIN
        CREATE FULLTEXT INDEX ON Study
            (PatientNameWords, ReferringPhysicianNameWords LANGUAGE 1033)
            KEY INDEX IX_Study_StudyKey
            WITH STOPLIST OFF;
    END


GO
IF NOT EXISTS (SELECT *
               FROM   sys.fulltext_indexes
               WHERE  object_id = object_id('dbo.ExtendedQueryTagPersonName'))
    BEGIN
        CREATE FULLTEXT INDEX ON ExtendedQueryTagPersonName
            (TagValueWords LANGUAGE 1033)
            KEY INDEX IXC_ExtendedQueryTagPersonName_WatermarkAndTagKey
            WITH STOPLIST OFF;
    END

GO
CREATE OR ALTER PROCEDURE dbo.AddExtendedQueryTagError
@tagKey INT, @errorCode SMALLINT, @watermark BIGINT
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
DECLARE @currentDate AS DATETIME2 (7) = SYSUTCDATETIME();
IF NOT EXISTS (SELECT *
               FROM   dbo.Instance WITH (UPDLOCK)
               WHERE  Watermark = @watermark
                      AND Status = 1)
    THROW 50404, 'Instance does not exist or has not been created.', 1;
IF NOT EXISTS (SELECT *
               FROM   dbo.ExtendedQueryTag WITH (HOLDLOCK)
               WHERE  TagKey = @tagKey
                      AND TagStatus = 0)
    THROW 50404, 'Tag does not exist or is not being added.', 1;
DECLARE @addedCount AS SMALLINT;
SET @addedCount = 1;
MERGE INTO dbo.ExtendedQueryTagError WITH (HOLDLOCK)
 AS XQTE
USING (SELECT @tagKey AS TagKey,
              @errorCode AS ErrorCode,
              @watermark AS Watermark) AS src ON src.TagKey = XQTE.TagKey
                                                 AND src.WaterMark = XQTE.Watermark
WHEN MATCHED THEN UPDATE 
SET CreatedTime = @currentDate,
    ErrorCode   = @errorCode,
    @addedCount = 0
WHEN NOT MATCHED THEN INSERT (TagKey, ErrorCode, Watermark, CreatedTime) VALUES (@tagKey, @errorCode, @watermark, @currentDate) OUTPUT INSERTED.TagKey;
UPDATE dbo.ExtendedQueryTag
SET    QueryStatus = 0,
       ErrorCount  = ErrorCount + @addedCount
WHERE  TagKey = @tagKey;
COMMIT TRANSACTION;

GO
CREATE OR ALTER PROCEDURE dbo.AddExtendedQueryTags
@extendedQueryTags dbo.AddExtendedQueryTagsInputTableType_1 READONLY, @maxAllowedCount INT=128, @ready BIT=0
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
    BEGIN TRANSACTION;
    IF (SELECT COUNT(*)
        FROM   dbo.ExtendedQueryTag AS XQT WITH (HOLDLOCK)
               FULL OUTER JOIN
               @extendedQueryTags AS input
               ON XQT.TagPath = input.TagPath) > @maxAllowedCount
        THROW 50409, 'extended query tags exceed max allowed count', 1;
    DECLARE @existingTags TABLE (
        TagKey      INT             ,
        TagStatus   TINYINT         ,
        OperationId UNIQUEIDENTIFIER NULL);
    INSERT INTO @existingTags (TagKey, TagStatus, OperationId)
    SELECT XQT.TagKey,
           TagStatus,
           OperationId
    FROM   dbo.ExtendedQueryTag AS XQT
           INNER JOIN
           @extendedQueryTags AS input
           ON input.TagPath = XQT.TagPath
           LEFT OUTER JOIN
           dbo.ExtendedQueryTagOperation AS XQTO
           ON XQT.TagKey = XQTO.TagKey;
    IF EXISTS (SELECT 1
               FROM   @existingTags
               WHERE  TagStatus <> 0
                      OR (TagStatus = 0
                          AND OperationId IS NOT NULL))
        THROW 50409, 'extended query tag(s) already exist', 2;
    DELETE XQT
    FROM   dbo.ExtendedQueryTag AS XQT
           INNER JOIN
           @existingTags AS et
           ON XQT.TagKey = et.TagKey;
    INSERT INTO dbo.ExtendedQueryTag (TagKey, TagPath, TagPrivateCreator, TagVR, TagLevel, TagStatus, QueryStatus, ErrorCount)
    OUTPUT INSERTED.TagKey, INSERTED.TagPath, INSERTED.TagVR, INSERTED.TagPrivateCreator, INSERTED.TagLevel, INSERTED.TagStatus, INSERTED.QueryStatus, INSERTED.ErrorCount
    SELECT  NEXT VALUE FOR TagKeySequence,
           TagPath,
           TagPrivateCreator,
           TagVR,
           TagLevel,
           @ready,
           1,
           0
    FROM   @extendedQueryTags;
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.AddInstanceV6
@partitionKey INT, @studyInstanceUid VARCHAR (64), @seriesInstanceUid VARCHAR (64), @sopInstanceUid VARCHAR (64), @patientId NVARCHAR (64), @patientName NVARCHAR (325)=NULL, @referringPhysicianName NVARCHAR (325)=NULL, @studyDate DATE=NULL, @studyDescription NVARCHAR (64)=NULL, @accessionNumber NVARCHAR (64)=NULL, @modality NVARCHAR (16)=NULL, @performedProcedureStepStartDate DATE=NULL, @patientBirthDate DATE=NULL, @manufacturerModelName NVARCHAR (64)=NULL, @stringExtendedQueryTags dbo.InsertStringExtendedQueryTagTableType_1 READONLY, @longExtendedQueryTags dbo.InsertLongExtendedQueryTagTableType_1 READONLY, @doubleExtendedQueryTags dbo.InsertDoubleExtendedQueryTagTableType_1 READONLY, @dateTimeExtendedQueryTags dbo.InsertDateTimeExtendedQueryTagTableType_2 READONLY, @personNameExtendedQueryTags dbo.InsertPersonNameExtendedQueryTagTableType_1 READONLY, @initialStatus TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DECLARE @currentDate AS DATETIME2 (7) = SYSUTCDATETIME();
    DECLARE @existingStatus AS TINYINT;
    DECLARE @newWatermark AS BIGINT;
    DECLARE @studyKey AS BIGINT;
    DECLARE @seriesKey AS BIGINT;
    DECLARE @instanceKey AS BIGINT;
    SELECT @existingStatus = Status
    FROM   dbo.Instance
    WHERE  PartitionKey = @partitionKey
           AND StudyInstanceUid = @studyInstanceUid
           AND SeriesInstanceUid = @seriesInstanceUid
           AND SopInstanceUid = @sopInstanceUid;
    IF @@ROWCOUNT <> 0
        THROW 50409, 'Instance already exists', @existingStatus;
    SET @newWatermark =  NEXT VALUE FOR dbo.WatermarkSequence;
    SET @instanceKey =  NEXT VALUE FOR dbo.InstanceKeySequence;
    SELECT @studyKey = StudyKey
    FROM   dbo.Study WITH (UPDLOCK)
    WHERE  PartitionKey = @partitionKey
           AND StudyInstanceUid = @studyInstanceUid;
    IF @@ROWCOUNT = 0
        BEGIN
            SET @studyKey =  NEXT VALUE FOR dbo.StudyKeySequence;
            INSERT  INTO dbo.Study (PartitionKey, StudyKey, StudyInstanceUid, PatientId, PatientName, PatientBirthDate, ReferringPhysicianName, StudyDate, StudyDescription, AccessionNumber)
            VALUES                (@partitionKey, @studyKey, @studyInstanceUid, @patientId, @patientName, @patientBirthDate, @referringPhysicianName, @studyDate, @studyDescription, @accessionNumber);
        END
    ELSE
        BEGIN
            UPDATE dbo.Study
            SET    PatientId              = @patientId,
                   PatientName            = @patientName,
                   PatientBirthDate       = @patientBirthDate,
                   ReferringPhysicianName = @referringPhysicianName,
                   StudyDate              = @studyDate,
                   StudyDescription       = @studyDescription,
                   AccessionNumber        = @accessionNumber
            WHERE  StudyKey = @studyKey;
        END
    SELECT @seriesKey = SeriesKey
    FROM   dbo.Series WITH (UPDLOCK)
    WHERE  StudyKey = @studyKey
           AND SeriesInstanceUid = @seriesInstanceUid
           AND PartitionKey = @partitionKey;
    IF @@ROWCOUNT = 0
        BEGIN
            SET @seriesKey =  NEXT VALUE FOR dbo.SeriesKeySequence;
            INSERT  INTO dbo.Series (PartitionKey, StudyKey, SeriesKey, SeriesInstanceUid, Modality, PerformedProcedureStepStartDate, ManufacturerModelName)
            VALUES                 (@partitionKey, @studyKey, @seriesKey, @seriesInstanceUid, @modality, @performedProcedureStepStartDate, @manufacturerModelName);
        END
    ELSE
        BEGIN
            UPDATE dbo.Series
            SET    Modality                        = @modality,
                   PerformedProcedureStepStartDate = @performedProcedureStepStartDate,
                   ManufacturerModelName           = @manufacturerModelName
            WHERE  SeriesKey = @seriesKey
                   AND StudyKey = @studyKey
                   AND PartitionKey = @partitionKey;
        END
    INSERT  INTO dbo.Instance (PartitionKey, StudyKey, SeriesKey, InstanceKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, Watermark, Status, LastStatusUpdatedDate, CreatedDate)
    VALUES                   (@partitionKey, @studyKey, @seriesKey, @instanceKey, @studyInstanceUid, @seriesInstanceUid, @sopInstanceUid, @newWatermark, @initialStatus, @currentDate, @currentDate);
    BEGIN TRY
        EXECUTE dbo.IIndexInstanceCoreV9 @partitionKey, @studyKey, @seriesKey, @instanceKey, @newWatermark, @stringExtendedQueryTags, @longExtendedQueryTags, @doubleExtendedQueryTags, @dateTimeExtendedQueryTags, @personNameExtendedQueryTags;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
    SELECT @newWatermark;
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.AddPartition
@partitionName VARCHAR (64)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DECLARE @createdDate AS DATETIME2 (7) = SYSUTCDATETIME();
    DECLARE @partitionKey AS INT;
    SET @partitionKey =  NEXT VALUE FOR dbo.PartitionKeySequence;
    INSERT  INTO dbo.Partition (PartitionKey, PartitionName, CreatedDate)
    VALUES                    (@partitionKey, @partitionName, @createdDate);
    SELECT @partitionKey,
           @partitionName,
           @createdDate;
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.AddWorkitem
@partitionKey INT, @workitemUid VARCHAR (64), @stringExtendedQueryTags dbo.InsertStringExtendedQueryTagTableType_1 READONLY, @dateTimeExtendedQueryTags dbo.InsertDateTimeExtendedQueryTagTableType_2 READONLY, @personNameExtendedQueryTags dbo.InsertPersonNameExtendedQueryTagTableType_1 READONLY, @initialStatus TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DECLARE @currentDate AS DATETIME2 (7) = SYSUTCDATETIME();
    DECLARE @workitemKey AS BIGINT;
    SELECT @workitemKey = WorkitemKey
    FROM   dbo.Workitem
    WHERE  PartitionKey = @partitionKey
           AND WorkitemUid = @workitemUid;
    IF @@ROWCOUNT <> 0
        THROW 50409, 'Workitem already exists', 1;
    SET @workitemKey =  NEXT VALUE FOR dbo.WorkitemKeySequence;
    INSERT  INTO dbo.Workitem (WorkitemKey, PartitionKey, WorkitemUid, Status, CreatedDate, LastStatusUpdatedDate)
    VALUES                   (@workitemKey, @partitionKey, @workitemUid, @initialStatus, @currentDate, @currentDate);
    BEGIN TRY
        EXECUTE dbo.IIndexWorkitemInstanceCore @partitionKey, @workitemKey, @stringExtendedQueryTags, @dateTimeExtendedQueryTags, @personNameExtendedQueryTags;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
    SELECT @workitemKey;
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.AssignReindexingOperation
@extendedQueryTagKeys dbo.ExtendedQueryTagKeyTableType_1 READONLY, @operationId UNIQUEIDENTIFIER, @returnIfCompleted BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    MERGE INTO dbo.ExtendedQueryTagOperation WITH (HOLDLOCK)
     AS XQTO
    USING (SELECT input.TagKey
           FROM   @extendedQueryTagKeys AS input
                  INNER JOIN
                  dbo.ExtendedQueryTag AS XQT WITH (HOLDLOCK)
                  ON input.TagKey = XQT.TagKey
           WHERE  TagStatus = 0) AS tags ON XQTO.TagKey = tags.TagKey
    WHEN NOT MATCHED THEN INSERT (TagKey, OperationId) VALUES (tags.TagKey, @operationId);
    SELECT XQT.TagKey,
           TagPath,
           TagVR,
           TagPrivateCreator,
           TagLevel,
           TagStatus,
           QueryStatus,
           ErrorCount
    FROM   @extendedQueryTagKeys AS input
           INNER JOIN
           dbo.ExtendedQueryTag AS XQT WITH (HOLDLOCK)
           ON input.TagKey = XQT.TagKey
           LEFT OUTER JOIN
           dbo.ExtendedQueryTagOperation AS XQTO WITH (HOLDLOCK)
           ON XQT.TagKey = XQTO.TagKey
    WHERE  (@returnIfCompleted = 1
            AND TagStatus = 1)
           OR (OperationId = @operationId
               AND TagStatus = 0);
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.CompleteReindexing
@extendedQueryTagKeys dbo.ExtendedQueryTagKeyTableType_1 READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    UPDATE XQT
    SET    TagStatus = 1
    FROM   dbo.ExtendedQueryTag AS XQT
           INNER JOIN
           @extendedQueryTagKeys AS input
           ON XQT.TagKey = input.TagKey
    WHERE  TagStatus = 0;
    DELETE XQTO
    OUTPUT DELETED.TagKey
    FROM   dbo.ExtendedQueryTagOperation AS XQTO
           INNER JOIN
           dbo.ExtendedQueryTag AS XQT
           ON XQTO.TagKey = XQT.TagKey
           INNER JOIN
           @extendedQueryTagKeys AS input
           ON XQT.TagKey = input.TagKey
    WHERE  TagStatus = 1;
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.DeleteDeletedInstance
@studyInstanceUid VARCHAR (64), @seriesInstanceUid VARCHAR (64), @sopInstanceUid VARCHAR (64), @watermark BIGINT
AS
SET NOCOUNT ON;
DELETE dbo.DeletedInstance
WHERE  StudyInstanceUid = @studyInstanceUid
       AND SeriesInstanceUid = @seriesInstanceUid
       AND SopInstanceUid = @sopInstanceUid
       AND Watermark = @watermark;

GO
CREATE OR ALTER PROCEDURE dbo.DeleteDeletedInstanceV6
@partitionKey INT, @studyInstanceUid VARCHAR (64), @seriesInstanceUid VARCHAR (64), @sopInstanceUid VARCHAR (64), @watermark BIGINT
AS
SET NOCOUNT ON;
DELETE dbo.DeletedInstance
WHERE  PartitionKey = @partitionKey
       AND StudyInstanceUid = @studyInstanceUid
       AND SeriesInstanceUid = @seriesInstanceUid
       AND SopInstanceUid = @sopInstanceUid
       AND Watermark = @watermark;

GO
CREATE OR ALTER PROCEDURE dbo.DeleteExtendedQueryTag
@tagPath VARCHAR (64), @dataType TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DECLARE @tagStatus AS TINYINT;
    DECLARE @tagKey AS INT;
    SELECT @tagKey = TagKey,
           @tagStatus = TagStatus
    FROM   dbo.ExtendedQueryTag WITH (XLOCK)
    WHERE  dbo.ExtendedQueryTag.TagPath = @tagPath;
    IF @@ROWCOUNT = 0
        THROW 50404, 'extended query tag not found', 1;
    IF @tagStatus = 2
        THROW 50412, 'extended query tag is not in Ready or Adding status', 1;
    UPDATE dbo.ExtendedQueryTag
    SET    TagStatus = 2
    WHERE  dbo.ExtendedQueryTag.TagKey = @tagKey;
    COMMIT TRANSACTION;
    BEGIN TRANSACTION;
    IF @dataType = 0
        DELETE dbo.ExtendedQueryTagString
        WHERE  TagKey = @tagKey;
    ELSE
        IF @dataType = 1
            DELETE dbo.ExtendedQueryTagLong
            WHERE  TagKey = @tagKey;
        ELSE
            IF @dataType = 2
                DELETE dbo.ExtendedQueryTagDouble
                WHERE  TagKey = @tagKey;
            ELSE
                IF @dataType = 3
                    DELETE dbo.ExtendedQueryTagDateTime
                    WHERE  TagKey = @tagKey;
                ELSE
                    DELETE dbo.ExtendedQueryTagPersonName
                    WHERE  TagKey = @tagKey;
    DELETE dbo.ExtendedQueryTag
    WHERE  TagKey = @tagKey;
    DELETE dbo.ExtendedQueryTagError
    WHERE  TagKey = @tagKey;
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.DeleteExtendedQueryTagV8
@tagPath VARCHAR (64), @dataType TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DECLARE @tagKey AS INT;
    SELECT @tagKey = TagKey
    FROM   dbo.ExtendedQueryTag WITH (XLOCK)
    WHERE  dbo.ExtendedQueryTag.TagPath = @tagPath;
    IF @@ROWCOUNT = 0
        THROW 50404, 'extended query tag not found', 1;
    UPDATE dbo.ExtendedQueryTag
    SET    TagStatus = 2
    WHERE  dbo.ExtendedQueryTag.TagKey = @tagKey;
    COMMIT TRANSACTION;
    BEGIN TRANSACTION;
    IF @dataType = 0
        DELETE dbo.ExtendedQueryTagString
        WHERE  TagKey = @tagKey;
    ELSE
        IF @dataType = 1
            DELETE dbo.ExtendedQueryTagLong
            WHERE  TagKey = @tagKey;
        ELSE
            IF @dataType = 2
                DELETE dbo.ExtendedQueryTagDouble
                WHERE  TagKey = @tagKey;
            ELSE
                IF @dataType = 3
                    DELETE dbo.ExtendedQueryTagDateTime
                    WHERE  TagKey = @tagKey;
                ELSE
                    DELETE dbo.ExtendedQueryTagPersonName
                    WHERE  TagKey = @tagKey;
    DELETE dbo.ExtendedQueryTagError
    WHERE  TagKey = @tagKey;
    DELETE dbo.ExtendedQueryTag
    WHERE  TagKey = @tagKey;
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.DeleteInstanceV6
@cleanupAfter DATETIMEOFFSET (0), @createdStatus TINYINT, @partitionKey INT, @studyInstanceUid VARCHAR (64), @seriesInstanceUid VARCHAR (64)=NULL, @sopInstanceUid VARCHAR (64)=NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
DECLARE @deletedInstances AS TABLE (
    PartitionKey      INT         ,
    StudyInstanceUid  VARCHAR (64),
    SeriesInstanceUid VARCHAR (64),
    SopInstanceUid    VARCHAR (64),
    Status            TINYINT     ,
    Watermark         BIGINT      );
DECLARE @studyKey AS BIGINT;
DECLARE @seriesKey AS BIGINT;
DECLARE @instanceKey AS BIGINT;
DECLARE @deletedDate AS DATETIME2 = SYSUTCDATETIME();
SELECT @studyKey = StudyKey,
       @seriesKey = CASE @seriesInstanceUid WHEN NULL THEN NULL ELSE SeriesKey END,
       @instanceKey = CASE @sopInstanceUid WHEN NULL THEN NULL ELSE InstanceKey END
FROM   dbo.Instance
WHERE  PartitionKey = @partitionKey
       AND StudyInstanceUid = @studyInstanceUid
       AND SeriesInstanceUid = ISNULL(@seriesInstanceUid, SeriesInstanceUid)
       AND SopInstanceUid = ISNULL(@sopInstanceUid, SopInstanceUid);
DELETE dbo.Instance
OUTPUT deleted.PartitionKey, deleted.StudyInstanceUid, deleted.SeriesInstanceUid, deleted.SopInstanceUid, deleted.Status, deleted.Watermark INTO @deletedInstances
WHERE  PartitionKey = @partitionKey
       AND StudyInstanceUid = @studyInstanceUid
       AND SeriesInstanceUid = ISNULL(@seriesInstanceUid, SeriesInstanceUid)
       AND SopInstanceUid = ISNULL(@sopInstanceUid, SopInstanceUid);
IF @@ROWCOUNT = 0
    THROW 50404, 'Instance not found', 1;
DECLARE @deletedTags AS TABLE (
    TagKey BIGINT);
DELETE XQTE
OUTPUT deleted.TagKey INTO @deletedTags
FROM   dbo.ExtendedQueryTagError AS XQTE
       INNER JOIN
       @deletedInstances AS DI
       ON XQTE.Watermark = DI.Watermark;
IF EXISTS (SELECT *
           FROM   @deletedTags)
    BEGIN
        DECLARE @deletedTagCounts AS TABLE (
            TagKey     BIGINT,
            ErrorCount INT   );
        INSERT INTO @deletedTagCounts (TagKey, ErrorCount)
        SELECT   TagKey,
                 COUNT(1)
        FROM     @deletedTags
        GROUP BY TagKey;
        UPDATE XQT
        SET    XQT.ErrorCount = XQT.ErrorCount - DTC.ErrorCount
        FROM   dbo.ExtendedQueryTag AS XQT
               INNER JOIN
               @deletedTagCounts AS DTC
               ON XQT.TagKey = DTC.TagKey;
    END
DELETE dbo.ExtendedQueryTagString
WHERE  SopInstanceKey1 = @studyKey
       AND SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
       AND SopInstanceKey3 = ISNULL(@instanceKey, SopInstanceKey3)
       AND PartitionKey = @partitionKey;
DELETE dbo.ExtendedQueryTagLong
WHERE  SopInstanceKey1 = @studyKey
       AND SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
       AND SopInstanceKey3 = ISNULL(@instanceKey, SopInstanceKey3)
       AND PartitionKey = @partitionKey;
DELETE dbo.ExtendedQueryTagDouble
WHERE  SopInstanceKey1 = @studyKey
       AND SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
       AND SopInstanceKey3 = ISNULL(@instanceKey, SopInstanceKey3)
       AND PartitionKey = @partitionKey;
DELETE dbo.ExtendedQueryTagDateTime
WHERE  SopInstanceKey1 = @studyKey
       AND SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
       AND SopInstanceKey3 = ISNULL(@instanceKey, SopInstanceKey3)
       AND PartitionKey = @partitionKey;
DELETE dbo.ExtendedQueryTagPersonName
WHERE  SopInstanceKey1 = @studyKey
       AND SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
       AND SopInstanceKey3 = ISNULL(@instanceKey, SopInstanceKey3)
       AND PartitionKey = @partitionKey;
INSERT INTO dbo.DeletedInstance (PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, Watermark, DeletedDateTime, RetryCount, CleanupAfter)
SELECT PartitionKey,
       StudyInstanceUid,
       SeriesInstanceUid,
       SopInstanceUid,
       Watermark,
       @deletedDate,
       0,
       @cleanupAfter
FROM   @deletedInstances;
INSERT INTO dbo.ChangeFeed (TimeStamp, Action, PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, OriginalWatermark)
SELECT @deletedDate,
       1,
       PartitionKey,
       StudyInstanceUid,
       SeriesInstanceUid,
       SopInstanceUid,
       Watermark
FROM   @deletedInstances
WHERE  Status = @createdStatus;
UPDATE CF
SET    CF.CurrentWatermark = NULL
FROM   dbo.ChangeFeed AS CF WITH (FORCESEEK)
       INNER JOIN
       @deletedInstances AS DI
       ON CF.PartitionKey = DI.PartitionKey
          AND CF.StudyInstanceUid = DI.StudyInstanceUid
          AND CF.SeriesInstanceUid = DI.SeriesInstanceUid
          AND CF.SopInstanceUid = DI.SopInstanceUid;
IF NOT EXISTS (SELECT *
               FROM   dbo.Instance WITH (HOLDLOCK, UPDLOCK)
               WHERE  StudyKey = @studyKey
                      AND SeriesInstanceUid = ISNULL(@seriesInstanceUid, SeriesInstanceUid))
    BEGIN
        DELETE dbo.Series
        WHERE  StudyKey = @studyKey
               AND SeriesInstanceUid = ISNULL(@seriesInstanceUid, SeriesInstanceUid)
               AND PartitionKey = @partitionKey;
        DELETE dbo.ExtendedQueryTagString
        WHERE  SopInstanceKey1 = @studyKey
               AND SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
               AND PartitionKey = @partitionKey;
        DELETE dbo.ExtendedQueryTagLong
        WHERE  SopInstanceKey1 = @studyKey
               AND SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
               AND PartitionKey = @partitionKey;
        DELETE dbo.ExtendedQueryTagDouble
        WHERE  SopInstanceKey1 = @studyKey
               AND SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
               AND PartitionKey = @partitionKey;
        DELETE dbo.ExtendedQueryTagDateTime
        WHERE  SopInstanceKey1 = @studyKey
               AND SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
               AND PartitionKey = @partitionKey;
        DELETE dbo.ExtendedQueryTagPersonName
        WHERE  SopInstanceKey1 = @studyKey
               AND SopInstanceKey2 = ISNULL(@seriesKey, SopInstanceKey2)
               AND PartitionKey = @partitionKey;
    END
IF NOT EXISTS (SELECT *
               FROM   dbo.Series WITH (HOLDLOCK, UPDLOCK)
               WHERE  Studykey = @studyKey
                      AND PartitionKey = @partitionKey)
    BEGIN
        DELETE dbo.Study
        WHERE  StudyKey = @studyKey
               AND PartitionKey = @partitionKey;
        DELETE dbo.ExtendedQueryTagString
        WHERE  SopInstanceKey1 = @studyKey
               AND PartitionKey = @partitionKey;
        DELETE dbo.ExtendedQueryTagLong
        WHERE  SopInstanceKey1 = @studyKey
               AND PartitionKey = @partitionKey;
        DELETE dbo.ExtendedQueryTagDouble
        WHERE  SopInstanceKey1 = @studyKey
               AND PartitionKey = @partitionKey;
        DELETE dbo.ExtendedQueryTagDateTime
        WHERE  SopInstanceKey1 = @studyKey
               AND PartitionKey = @partitionKey;
        DELETE dbo.ExtendedQueryTagPersonName
        WHERE  SopInstanceKey1 = @studyKey
               AND PartitionKey = @partitionKey;
    END
COMMIT TRANSACTION;

GO
CREATE OR ALTER PROCEDURE dbo.DeleteWorkitem
@partitionKey INT, @workitemUid VARCHAR (64)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DECLARE @workitemResourceType AS TINYINT = 1;
    DECLARE @workitemKey AS BIGINT;
    SELECT @workitemKey = WorkitemKey
    FROM   dbo.Workitem
    WHERE  PartitionKey = @partitionKey
           AND WorkitemUid = @workitemUid;
    IF @@ROWCOUNT = 0
        THROW 50413, 'Workitem does not exists', 1;
    DELETE dbo.ExtendedQueryTagString
    WHERE  SopInstanceKey1 = @workitemKey
           AND PartitionKey = @partitionKey
           AND ResourceType = @workitemResourceType;
    DELETE dbo.ExtendedQueryTagLong
    WHERE  SopInstanceKey1 = @workitemKey
           AND PartitionKey = @partitionKey
           AND ResourceType = @workitemResourceType;
    DELETE dbo.ExtendedQueryTagDouble
    WHERE  SopInstanceKey1 = @workitemKey
           AND PartitionKey = @partitionKey
           AND ResourceType = @workitemResourceType;
    DELETE dbo.ExtendedQueryTagDateTime
    WHERE  SopInstanceKey1 = @workitemKey
           AND PartitionKey = @partitionKey
           AND ResourceType = @workitemResourceType;
    DELETE dbo.ExtendedQueryTagPersonName
    WHERE  SopInstanceKey1 = @workitemKey
           AND PartitionKey = @partitionKey
           AND ResourceType = @workitemResourceType;
    DELETE dbo.Workitem
    WHERE  WorkItemKey = @workitemKey
           AND PartitionKey = @partitionKey;
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetChangeFeed
@limit INT, @offset BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT   Sequence,
             Timestamp,
             Action,
             StudyInstanceUid,
             SeriesInstanceUid,
             SopInstanceUid,
             OriginalWatermark,
             CurrentWatermark
    FROM     dbo.ChangeFeed
    WHERE    Sequence BETWEEN @offset + 1 AND @offset + @limit
    ORDER BY Sequence;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetChangeFeedLatest
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT   TOP (1) Sequence,
                     Timestamp,
                     Action,
                     StudyInstanceUid,
                     SeriesInstanceUid,
                     SopInstanceUid,
                     OriginalWatermark,
                     CurrentWatermark
    FROM     dbo.ChangeFeed
    ORDER BY Sequence DESC;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetChangeFeedLatestV6
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT   TOP (1) Sequence,
                     Timestamp,
                     Action,
                     PartitionName,
                     StudyInstanceUid,
                     SeriesInstanceUid,
                     SopInstanceUid,
                     OriginalWatermark,
                     CurrentWatermark
    FROM     dbo.ChangeFeed AS c
             INNER JOIN
             dbo.Partition AS p
             ON p.PartitionKey = c.PartitionKey
    ORDER BY Sequence DESC;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetChangeFeedV6
@limit INT, @offset BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT   Sequence,
             Timestamp,
             Action,
             PartitionName,
             StudyInstanceUid,
             SeriesInstanceUid,
             SopInstanceUid,
             OriginalWatermark,
             CurrentWatermark
    FROM     dbo.ChangeFeed AS c
             INNER JOIN
             dbo.Partition AS p
             ON p.PartitionKey = c.PartitionKey
    WHERE    Sequence BETWEEN @offset + 1 AND @offset + @limit
    ORDER BY Sequence;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetExtendedQueryTag
@tagPath VARCHAR (64)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT XQT.TagKey,
           TagPath,
           TagVR,
           TagPrivateCreator,
           TagLevel,
           TagStatus,
           QueryStatus,
           ErrorCount,
           OperationId
    FROM   dbo.ExtendedQueryTag AS XQT
           LEFT OUTER JOIN
           dbo.ExtendedQueryTagOperation AS XQTO
           ON XQT.TagKey = XQTO.TagKey
    WHERE  TagPath = ISNULL(@tagPath, TagPath);
END

GO
CREATE OR ALTER PROCEDURE dbo.GetExtendedQueryTagErrors
@tagPath VARCHAR (64), @limit INT, @offset INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @tagKey AS INT;
    SELECT @tagKey = TagKey
    FROM   dbo.ExtendedQueryTag WITH (HOLDLOCK)
    WHERE  dbo.ExtendedQueryTag.TagPath = @tagPath;
    IF (@@ROWCOUNT = 0)
        THROW 50404, 'extended query tag not found', 1;
    SELECT   TagKey,
             ErrorCode,
             CreatedTime,
             StudyInstanceUid,
             SeriesInstanceUid,
             SopInstanceUid
    FROM     dbo.ExtendedQueryTagError AS XQTE
             INNER JOIN
             dbo.Instance AS I
             ON XQTE.Watermark = I.Watermark
    WHERE    XQTE.TagKey = @tagKey
    ORDER BY CreatedTime ASC, XQTE.Watermark ASC, TagKey ASC
    OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetExtendedQueryTagErrorsV6
@tagPath VARCHAR (64), @limit INT, @offset INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @tagKey AS INT;
    SELECT @tagKey = TagKey
    FROM   dbo.ExtendedQueryTag WITH (HOLDLOCK)
    WHERE  dbo.ExtendedQueryTag.TagPath = @tagPath;
    IF (@@ROWCOUNT = 0)
        THROW 50404, 'extended query tag not found', 1;
    SELECT   TagKey,
             ErrorCode,
             CreatedTime,
             PartitionName,
             StudyInstanceUid,
             SeriesInstanceUid,
             SopInstanceUid
    FROM     dbo.ExtendedQueryTagError AS XQTE
             INNER JOIN
             dbo.Instance AS I
             ON XQTE.Watermark = I.Watermark
             INNER JOIN
             dbo.Partition AS P
             ON P.PartitionKey = I.PartitionKey
    WHERE    XQTE.TagKey = @tagKey
    ORDER BY CreatedTime ASC, XQTE.Watermark ASC, TagKey ASC
    OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetExtendedQueryTags
@limit INT, @offset INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT   XQT.TagKey,
             TagPath,
             TagVR,
             TagPrivateCreator,
             TagLevel,
             TagStatus,
             QueryStatus,
             ErrorCount,
             OperationId
    FROM     dbo.ExtendedQueryTag AS XQT
             LEFT OUTER JOIN
             dbo.ExtendedQueryTagOperation AS XQTO
             ON XQT.TagKey = XQTO.TagKey
    ORDER BY XQT.TagKey ASC
    OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetExtendedQueryTagsByKey
@extendedQueryTagKeys dbo.ExtendedQueryTagKeyTableType_1 READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT XQT.TagKey,
           TagPath,
           TagVR,
           TagPrivateCreator,
           TagLevel,
           TagStatus,
           QueryStatus,
           ErrorCount,
           OperationId
    FROM   @extendedQueryTagKeys AS input
           INNER JOIN
           dbo.ExtendedQueryTag AS XQT
           ON input.TagKey = XQT.TagKey
           LEFT OUTER JOIN
           dbo.ExtendedQueryTagOperation AS XQTO
           ON XQT.TagKey = XQTO.TagKey;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetExtendedQueryTagsByOperation
@operationId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT XQT.TagKey,
           TagPath,
           TagVR,
           TagPrivateCreator,
           TagLevel,
           TagStatus,
           QueryStatus,
           ErrorCount
    FROM   dbo.ExtendedQueryTag AS XQT
           INNER JOIN
           dbo.ExtendedQueryTagOperation AS XQTO
           ON XQT.TagKey = XQTO.TagKey
    WHERE  OperationId = @operationId;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetInstance
@validStatus TINYINT, @studyInstanceUid VARCHAR (64), @seriesInstanceUid VARCHAR (64)=NULL, @sopInstanceUid VARCHAR (64)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT StudyInstanceUid,
           SeriesInstanceUid,
           SopInstanceUid,
           Watermark
    FROM   dbo.Instance
    WHERE  StudyInstanceUid = @studyInstanceUid
           AND SeriesInstanceUid = ISNULL(@seriesInstanceUid, SeriesInstanceUid)
           AND SopInstanceUid = ISNULL(@sopInstanceUid, SopInstanceUid)
           AND Status = @validStatus;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetInstanceBatches
@batchSize INT, @batchCount INT, @status TINYINT, @maxWatermark BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT   MIN(Watermark) AS MinWatermark,
             MAX(Watermark) AS MaxWatermark
    FROM     (SELECT TOP (@batchSize * @batchCount) Watermark,
                                                    (ROW_NUMBER() OVER (ORDER BY Watermark DESC) - 1) / @batchSize AS Batch
              FROM   dbo.Instance
              WHERE  Watermark <= ISNULL(@maxWatermark, Watermark)
                     AND Status = @status) AS I
    GROUP BY Batch
    ORDER BY Batch ASC;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetInstancesByWatermarkRange
@startWatermark BIGINT, @endWatermark BIGINT, @status TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT StudyInstanceUid,
           SeriesInstanceUid,
           SopInstanceUid,
           Watermark
    FROM   dbo.Instance
    WHERE  Watermark BETWEEN @startWatermark AND @endWatermark
           AND Status = @status;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetInstancesByWatermarkRangeV6
@startWatermark BIGINT, @endWatermark BIGINT, @status TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT StudyInstanceUid,
           SeriesInstanceUid,
           SopInstanceUid,
           Watermark
    FROM   dbo.Instance
    WHERE  Watermark BETWEEN @startWatermark AND @endWatermark
           AND Status = @status;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetInstanceV6
@validStatus TINYINT, @partitionKey INT, @studyInstanceUid VARCHAR (64), @seriesInstanceUid VARCHAR (64)=NULL, @sopInstanceUid VARCHAR (64)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT StudyInstanceUid,
           SeriesInstanceUid,
           SopInstanceUid,
           Watermark
    FROM   dbo.Instance
    WHERE  PartitionKey = @partitionKey
           AND StudyInstanceUid = @studyInstanceUid
           AND SeriesInstanceUid = ISNULL(@seriesInstanceUid, SeriesInstanceUid)
           AND SopInstanceUid = ISNULL(@sopInstanceUid, SopInstanceUid)
           AND Status = @validStatus;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetPartition
@partitionName VARCHAR (64)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT PartitionKey,
           PartitionName,
           CreatedDate
    FROM   dbo.Partition
    WHERE  PartitionName = @partitionName;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetPartitions
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT PartitionKey,
           PartitionName,
           CreatedDate
    FROM   dbo.Partition;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetWorkitemMetadata
@partitionKey INT, @workitemUid VARCHAR (64), @procedureStepStateTagPath VARCHAR (64)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT wi.WorkitemUid,
           wi.WorkitemKey,
           wi.PartitionKey,
           wi.[Status],
           wi.TransactionUid,
           eqt.TagValue AS ProcedureStepState
    FROM   dbo.WorkitemQueryTag AS wqt
           INNER JOIN
           dbo.ExtendedQueryTagString AS eqt
           ON eqt.ResourceType = 1
              AND eqt.TagKey = wqt.TagKey
              AND wqt.TagPath = @procedureStepStateTagPath
           INNER JOIN
           dbo.Workitem AS wi
           ON wi.WorkitemKey = eqt.SopInstanceKey1
              AND wi.PartitionKey = eqt.PartitionKey
    WHERE  wi.PartitionKey = @partitionKey
           AND wi.WorkitemUid = @workitemUid;
END

GO
CREATE OR ALTER PROCEDURE dbo.GetWorkitemQueryTags
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SELECT TagKey,
           TagPath,
           TagVR
    FROM   dbo.WorkItemQueryTag;
END

GO
CREATE OR ALTER PROCEDURE dbo.IIndexInstanceCoreV9
@partitionKey INT=1, @studyKey BIGINT, @seriesKey BIGINT, @instanceKey BIGINT, @watermark BIGINT, @stringExtendedQueryTags dbo.InsertStringExtendedQueryTagTableType_1 READONLY, @longExtendedQueryTags dbo.InsertLongExtendedQueryTagTableType_1 READONLY, @doubleExtendedQueryTags dbo.InsertDoubleExtendedQueryTagTableType_1 READONLY, @dateTimeExtendedQueryTags dbo.InsertDateTimeExtendedQueryTagTableType_2 READONLY, @personNameExtendedQueryTags dbo.InsertPersonNameExtendedQueryTagTableType_1 READONLY
AS
BEGIN
    DECLARE @resourceType AS TINYINT = 0;
    IF EXISTS (SELECT 1
               FROM   @stringExtendedQueryTags)
        BEGIN
            MERGE INTO dbo.ExtendedQueryTagString WITH (HOLDLOCK)
             AS T
            USING (SELECT input.TagKey,
                          input.TagValue,
                          input.TagLevel
                   FROM   @stringExtendedQueryTags AS input
                          INNER JOIN
                          dbo.ExtendedQueryTag WITH (REPEATABLEREAD)
                          ON dbo.ExtendedQueryTag.TagKey = input.TagKey
                             AND dbo.ExtendedQueryTag.TagStatus <> 2) AS S ON T.ResourceType = @resourceType
                                                                              AND T.TagKey = S.TagKey
                                                                              AND T.PartitionKey = @partitionKey
                                                                              AND T.SopInstanceKey1 = @studyKey
                                                                              AND ISNULL(T.SopInstanceKey2, @seriesKey) = @seriesKey
                                                                              AND ISNULL(T.SopInstanceKey3, @instanceKey) = @instanceKey
            WHEN MATCHED AND @watermark > T.Watermark THEN UPDATE 
            SET T.Watermark = @watermark,
                T.TagValue  = S.TagValue
            WHEN NOT MATCHED THEN INSERT (TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3, Watermark, ResourceType) VALUES (S.TagKey, S.TagValue, @partitionKey, @studyKey, (CASE WHEN S.TagLevel <> 2 THEN @seriesKey ELSE NULL END), (CASE WHEN S.TagLevel = 0 THEN @instanceKey ELSE NULL END), @watermark, @resourceType);
        END
    IF EXISTS (SELECT 1
               FROM   @longExtendedQueryTags)
        BEGIN
            MERGE INTO dbo.ExtendedQueryTagLong WITH (HOLDLOCK)
             AS T
            USING (SELECT input.TagKey,
                          input.TagValue,
                          input.TagLevel
                   FROM   @longExtendedQueryTags AS input
                          INNER JOIN
                          dbo.ExtendedQueryTag WITH (REPEATABLEREAD)
                          ON dbo.ExtendedQueryTag.TagKey = input.TagKey
                             AND dbo.ExtendedQueryTag.TagStatus <> 2) AS S ON T.ResourceType = @resourceType
                                                                              AND T.TagKey = S.TagKey
                                                                              AND T.PartitionKey = @partitionKey
                                                                              AND T.SopInstanceKey1 = @studyKey
                                                                              AND ISNULL(T.SopInstanceKey2, @seriesKey) = @seriesKey
                                                                              AND ISNULL(T.SopInstanceKey3, @instanceKey) = @instanceKey
            WHEN MATCHED AND @watermark > T.Watermark THEN UPDATE 
            SET T.Watermark = @watermark,
                T.TagValue  = S.TagValue
            WHEN NOT MATCHED THEN INSERT (TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3, Watermark, ResourceType) VALUES (S.TagKey, S.TagValue, @partitionKey, @studyKey, (CASE WHEN S.TagLevel <> 2 THEN @seriesKey ELSE NULL END), (CASE WHEN S.TagLevel = 0 THEN @instanceKey ELSE NULL END), @watermark, @resourceType);
        END
    IF EXISTS (SELECT 1
               FROM   @doubleExtendedQueryTags)
        BEGIN
            MERGE INTO dbo.ExtendedQueryTagDouble WITH (HOLDLOCK)
             AS T
            USING (SELECT input.TagKey,
                          input.TagValue,
                          input.TagLevel
                   FROM   @doubleExtendedQueryTags AS input
                          INNER JOIN
                          dbo.ExtendedQueryTag WITH (REPEATABLEREAD)
                          ON dbo.ExtendedQueryTag.TagKey = input.TagKey
                             AND dbo.ExtendedQueryTag.TagStatus <> 2) AS S ON T.ResourceType = @resourceType
                                                                              AND T.TagKey = S.TagKey
                                                                              AND T.PartitionKey = @partitionKey
                                                                              AND T.SopInstanceKey1 = @studyKey
                                                                              AND ISNULL(T.SopInstanceKey2, @seriesKey) = @seriesKey
                                                                              AND ISNULL(T.SopInstanceKey3, @instanceKey) = @instanceKey
            WHEN MATCHED AND @watermark > T.Watermark THEN UPDATE 
            SET T.Watermark = @watermark,
                T.TagValue  = S.TagValue
            WHEN NOT MATCHED THEN INSERT (TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3, Watermark, ResourceType) VALUES (S.TagKey, S.TagValue, @partitionKey, @studyKey, (CASE WHEN S.TagLevel <> 2 THEN @seriesKey ELSE NULL END), (CASE WHEN S.TagLevel = 0 THEN @instanceKey ELSE NULL END), @watermark, @resourceType);
        END
    IF EXISTS (SELECT 1
               FROM   @dateTimeExtendedQueryTags)
        BEGIN
            MERGE INTO dbo.ExtendedQueryTagDateTime WITH (HOLDLOCK)
             AS T
            USING (SELECT input.TagKey,
                          input.TagValue,
                          input.TagValueUtc,
                          input.TagLevel
                   FROM   @dateTimeExtendedQueryTags AS input
                          INNER JOIN
                          dbo.ExtendedQueryTag WITH (REPEATABLEREAD)
                          ON dbo.ExtendedQueryTag.TagKey = input.TagKey
                             AND dbo.ExtendedQueryTag.TagStatus <> 2) AS S ON T.ResourceType = @resourceType
                                                                              AND T.TagKey = S.TagKey
                                                                              AND T.PartitionKey = @partitionKey
                                                                              AND T.SopInstanceKey1 = @studyKey
                                                                              AND ISNULL(T.SopInstanceKey2, @seriesKey) = @seriesKey
                                                                              AND ISNULL(T.SopInstanceKey3, @instanceKey) = @instanceKey
            WHEN MATCHED AND @watermark > T.Watermark THEN UPDATE 
            SET T.Watermark = @watermark,
                T.TagValue  = S.TagValue
            WHEN NOT MATCHED THEN INSERT (TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3, Watermark, TagValueUtc, ResourceType) VALUES (S.TagKey, S.TagValue, @partitionKey, @studyKey, (CASE WHEN S.TagLevel <> 2 THEN @seriesKey ELSE NULL END), (CASE WHEN S.TagLevel = 0 THEN @instanceKey ELSE NULL END), @watermark, S.TagValueUtc, @resourceType);
        END
    IF EXISTS (SELECT 1
               FROM   @personNameExtendedQueryTags)
        BEGIN
            MERGE INTO dbo.ExtendedQueryTagPersonName WITH (HOLDLOCK)
             AS T
            USING (SELECT input.TagKey,
                          input.TagValue,
                          input.TagLevel
                   FROM   @personNameExtendedQueryTags AS input
                          INNER JOIN
                          dbo.ExtendedQueryTag WITH (REPEATABLEREAD)
                          ON dbo.ExtendedQueryTag.TagKey = input.TagKey
                             AND dbo.ExtendedQueryTag.TagStatus <> 2) AS S ON T.ResourceType = @resourceType
                                                                              AND T.TagKey = S.TagKey
                                                                              AND T.PartitionKey = @partitionKey
                                                                              AND T.SopInstanceKey1 = @studyKey
                                                                              AND ISNULL(T.SopInstanceKey2, @seriesKey) = @seriesKey
                                                                              AND ISNULL(T.SopInstanceKey3, @instanceKey) = @instanceKey
            WHEN MATCHED AND @watermark > T.Watermark THEN UPDATE 
            SET T.Watermark = @watermark,
                T.TagValue  = S.TagValue
            WHEN NOT MATCHED THEN INSERT (TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3, Watermark, ResourceType) VALUES (S.TagKey, S.TagValue, @partitionKey, @studyKey, (CASE WHEN S.TagLevel <> 2 THEN @seriesKey ELSE NULL END), (CASE WHEN S.TagLevel = 0 THEN @instanceKey ELSE NULL END), @watermark, @resourceType);
        END
END

GO
CREATE OR ALTER PROCEDURE dbo.IIndexWorkitemInstanceCore
@partitionKey INT=1, @workitemKey BIGINT, @stringExtendedQueryTags dbo.InsertStringExtendedQueryTagTableType_1 READONLY, @dateTimeExtendedQueryTags dbo.InsertDateTimeExtendedQueryTagTableType_2 READONLY, @personNameExtendedQueryTags dbo.InsertPersonNameExtendedQueryTagTableType_1 READONLY
AS
BEGIN
    DECLARE @workitemResourceType AS TINYINT = 1;
    DECLARE @newWatermark AS BIGINT;
    SET @newWatermark =  NEXT VALUE FOR dbo.WatermarkSequence;
    IF EXISTS (SELECT 1
               FROM   @stringExtendedQueryTags)
        BEGIN
            INSERT dbo.ExtendedQueryTagString (TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3, Watermark, ResourceType)
            SELECT input.TagKey,
                   input.TagValue,
                   @partitionKey,
                   @workitemKey,
                   NULL,
                   NULL,
                   @newWatermark,
                   @workitemResourceType
            FROM   @stringExtendedQueryTags AS input
                   INNER JOIN
                   dbo.WorkitemQueryTag
                   ON dbo.WorkitemQueryTag.TagKey = input.TagKey;
        END
    IF EXISTS (SELECT 1
               FROM   @dateTimeExtendedQueryTags)
        BEGIN
            INSERT dbo.ExtendedQueryTagDateTime (TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3, Watermark, ResourceType)
            SELECT input.TagKey,
                   input.TagValue,
                   @partitionKey,
                   @workitemKey,
                   NULL,
                   NULL,
                   @newWatermark,
                   @workitemResourceType
            FROM   @dateTimeExtendedQueryTags AS input
                   INNER JOIN
                   dbo.WorkitemQueryTag
                   ON dbo.WorkitemQueryTag.TagKey = input.TagKey;
        END
    IF EXISTS (SELECT 1
               FROM   @personNameExtendedQueryTags)
        BEGIN
            INSERT dbo.ExtendedQueryTagPersonName (TagKey, TagValue, PartitionKey, SopInstanceKey1, SopInstanceKey2, SopInstanceKey3, Watermark, ResourceType)
            SELECT input.TagKey,
                   input.TagValue,
                   @partitionKey,
                   @workitemKey,
                   NULL,
                   NULL,
                   @newWatermark,
                   @workitemResourceType
            FROM   @personNameExtendedQueryTags AS input
                   INNER JOIN
                   dbo.WorkitemQueryTag
                   ON dbo.WorkitemQueryTag.TagKey = input.TagKey;
        END
END

GO
CREATE OR ALTER PROCEDURE dbo.IncrementDeletedInstanceRetry
@studyInstanceUid VARCHAR (64), @seriesInstanceUid VARCHAR (64), @sopInstanceUid VARCHAR (64), @watermark BIGINT, @cleanupAfter DATETIMEOFFSET (0)
AS
SET NOCOUNT ON;
DECLARE @retryCount AS INT;
UPDATE dbo.DeletedInstance
SET    @retryCount = RetryCount = RetryCount + 1,
       CleanupAfter             = @cleanupAfter
WHERE  StudyInstanceUid = @studyInstanceUid
       AND SeriesInstanceUid = @seriesInstanceUid
       AND SopInstanceUid = @sopInstanceUid
       AND Watermark = @watermark;
SELECT @retryCount;

GO
CREATE OR ALTER PROCEDURE dbo.IncrementDeletedInstanceRetryV6
@partitionKey INT, @studyInstanceUid VARCHAR (64), @seriesInstanceUid VARCHAR (64), @sopInstanceUid VARCHAR (64), @watermark BIGINT, @cleanupAfter DATETIMEOFFSET (0)
AS
SET NOCOUNT ON;
DECLARE @retryCount AS INT;
UPDATE dbo.DeletedInstance
SET    @retryCount = RetryCount = RetryCount + 1,
       CleanupAfter             = @cleanupAfter
WHERE  PartitionKey = @partitionKey
       AND StudyInstanceUid = @studyInstanceUid
       AND SeriesInstanceUid = @seriesInstanceUid
       AND SopInstanceUid = @sopInstanceUid
       AND Watermark = @watermark;
SELECT @retryCount;

GO
CREATE OR ALTER PROCEDURE dbo.IndexInstanceV6
@watermark BIGINT, @stringExtendedQueryTags dbo.InsertStringExtendedQueryTagTableType_1 READONLY, @longExtendedQueryTags dbo.InsertLongExtendedQueryTagTableType_1 READONLY, @doubleExtendedQueryTags dbo.InsertDoubleExtendedQueryTagTableType_1 READONLY, @dateTimeExtendedQueryTags dbo.InsertDateTimeExtendedQueryTagTableType_2 READONLY, @personNameExtendedQueryTags dbo.InsertPersonNameExtendedQueryTagTableType_1 READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DECLARE @partitionKey AS BIGINT;
    DECLARE @studyKey AS BIGINT;
    DECLARE @seriesKey AS BIGINT;
    DECLARE @instanceKey AS BIGINT;
    DECLARE @status AS TINYINT;
    SELECT @partitionKey = PartitionKey,
           @studyKey = StudyKey,
           @seriesKey = SeriesKey,
           @instanceKey = InstanceKey,
           @status = Status
    FROM   dbo.Instance WITH (HOLDLOCK)
    WHERE  Watermark = @watermark;
    IF @@ROWCOUNT = 0
        THROW 50404, 'Instance does not exists', 1;
    IF @status <> 1
        THROW 50409, 'Instance has not yet been stored succssfully', 1;
    BEGIN TRY
        EXECUTE dbo.IIndexInstanceCoreV9 @partitionKey, @studyKey, @seriesKey, @instanceKey, @watermark, @stringExtendedQueryTags, @longExtendedQueryTags, @doubleExtendedQueryTags, @dateTimeExtendedQueryTags, @personNameExtendedQueryTags;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.RetrieveDeletedInstance
@count INT, @maxRetries INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@count) StudyInstanceUid,
                        SeriesInstanceUid,
                        SopInstanceUid,
                        Watermark
    FROM   dbo.DeletedInstance WITH (UPDLOCK, READPAST)
    WHERE  RetryCount <= @maxRetries
           AND CleanupAfter < SYSUTCDATETIME();
END

GO
CREATE OR ALTER PROCEDURE dbo.RetrieveDeletedInstanceV6
@count INT, @maxRetries INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@count) PartitionKey,
                        StudyInstanceUid,
                        SeriesInstanceUid,
                        SopInstanceUid,
                        Watermark
    FROM   dbo.DeletedInstance WITH (UPDLOCK, READPAST)
    WHERE  RetryCount <= @maxRetries
           AND CleanupAfter < SYSUTCDATETIME();
END

GO
CREATE OR ALTER PROCEDURE dbo.UpdateExtendedQueryTagQueryStatus
@tagPath VARCHAR (64), @queryStatus TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE XQT
    SET    QueryStatus = @queryStatus
    OUTPUT INSERTED.TagKey, INSERTED.TagPath, INSERTED.TagVR, INSERTED.TagPrivateCreator, INSERTED.TagLevel, INSERTED.TagStatus, INSERTED.QueryStatus, INSERTED.ErrorCount, XQTO.OperationId
    FROM   dbo.ExtendedQueryTag AS XQT
           LEFT OUTER JOIN
           dbo.ExtendedQueryTagOperation AS XQTO
           ON XQT.TagKey = XQTO.TagKey
    WHERE  TagPath = @tagPath;
END

GO
CREATE OR ALTER PROCEDURE dbo.UpdateInstanceStatus
@studyInstanceUid VARCHAR (64), @seriesInstanceUid VARCHAR (64), @sopInstanceUid VARCHAR (64), @watermark BIGINT, @status TINYINT
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
DECLARE @currentDate AS DATETIME2 (7) = SYSUTCDATETIME();
UPDATE dbo.Instance
SET    Status                = @status,
       LastStatusUpdatedDate = @currentDate
WHERE  StudyInstanceUid = @studyInstanceUid
       AND SeriesInstanceUid = @seriesInstanceUid
       AND SopInstanceUid = @sopInstanceUid
       AND Watermark = @watermark;
IF @@ROWCOUNT = 0
    BEGIN
        THROW 50404, 'Instance does not exist', 1;
    END
INSERT  INTO dbo.ChangeFeed (Timestamp, Action, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, OriginalWatermark)
VALUES                     (@currentDate, 0, @studyInstanceUid, @seriesInstanceUid, @sopInstanceUid, @watermark);
UPDATE dbo.ChangeFeed
SET    CurrentWatermark = @watermark
WHERE  StudyInstanceUid = @studyInstanceUid
       AND SeriesInstanceUid = @seriesInstanceUid
       AND SopInstanceUid = @sopInstanceUid;
COMMIT TRANSACTION;

GO
CREATE OR ALTER PROCEDURE dbo.UpdateInstanceStatusV6
@partitionKey INT, @studyInstanceUid VARCHAR (64), @seriesInstanceUid VARCHAR (64), @sopInstanceUid VARCHAR (64), @watermark BIGINT, @status TINYINT, @maxTagKey INT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    IF @maxTagKey < (SELECT ISNULL(MAX(TagKey), 0)
                     FROM   dbo.ExtendedQueryTag WITH (HOLDLOCK))
        THROW 50409, 'Max extended query tag key does not match', 10;
    DECLARE @currentDate AS DATETIME2 (7) = SYSUTCDATETIME();
    UPDATE dbo.Instance
    SET    Status                = @status,
           LastStatusUpdatedDate = @currentDate
    WHERE  PartitionKey = @partitionKey
           AND StudyInstanceUid = @studyInstanceUid
           AND SeriesInstanceUid = @seriesInstanceUid
           AND SopInstanceUid = @sopInstanceUid
           AND Watermark = @watermark;
    IF @@ROWCOUNT = 0
        THROW 50404, 'Instance does not exist', 1;
    INSERT  INTO dbo.ChangeFeed (Timestamp, Action, PartitionKey, StudyInstanceUid, SeriesInstanceUid, SopInstanceUid, OriginalWatermark)
    VALUES                     (@currentDate, 0, @partitionKey, @studyInstanceUid, @seriesInstanceUid, @sopInstanceUid, @watermark);
    UPDATE dbo.ChangeFeed
    SET    CurrentWatermark = @watermark
    WHERE  PartitionKey = @partitionKey
           AND StudyInstanceUid = @studyInstanceUid
           AND SeriesInstanceUid = @seriesInstanceUid
           AND SopInstanceUid = @sopInstanceUid;
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.UpdateWorkitem
@partitionKey INT, @workitemUid VARCHAR (64), @stringExtendedQueryTags dbo.InsertStringExtendedQueryTagTableType_1 READONLY, @dateTimeExtendedQueryTags dbo.InsertDateTimeExtendedQueryTagTableType_2 READONLY, @personNameExtendedQueryTags dbo.InsertPersonNameExtendedQueryTagTableType_1 READONLY, @status TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DECLARE @workitemKey AS BIGINT;
    DECLARE @newWatermark AS BIGINT;
    DECLARE @currentDate AS DATETIME2 (7) = SYSUTCDATETIME();
    SELECT @workitemKey = WorkitemKey
    FROM   dbo.Workitem
    WHERE  PartitionKey = @partitionKey
           AND WorkitemUid = @workitemUid;
    IF @@ROWCOUNT = 0
        THROW 50413, 'Workitem does not exist', 1;
    SET @newWatermark =  NEXT VALUE FOR dbo.WatermarkSequence;
    IF EXISTS (SELECT 1
               FROM   @stringExtendedQueryTags)
        BEGIN
            WITH InputCTE
            AS   (SELECT wqt.TagKey,
                         wqt.TagPath,
                         eqts.TagValue AS OldTagValue,
                         input.TagValue AS NewTagValue,
                         eqts.ResourceType,
                         wi.PartitionKey,
                         wi.WorkitemKey,
                         wi.WorkitemUid,
                         wi.TransactionUid,
                         eqts.Watermark
                  FROM   dbo.WorkitemQueryTag AS wqt
                         INNER JOIN
                         @stringExtendedQueryTags AS input
                         ON input.TagKey = wqt.TagKey
                         INNER JOIN
                         dbo.ExtendedQueryTagString AS eqts
                         ON eqts.TagKey = wqt.TagKey
                            AND eqts.ResourceType = 1
                         INNER JOIN
                         dbo.Workitem AS wi
                         ON wi.PartitionKey = eqts.PartitionKey
                            AND wi.WorkitemKey = eqts.SopInstanceKey1
                  WHERE  wi.PartitionKey = @partitionKey
                         AND wi.WorkitemKey = @workitemKey)
            UPDATE targetTbl
            SET    targetTbl.TagValue  = cte.NewTagValue,
                   targetTbl.Watermark = @newWatermark
            FROM   dbo.ExtendedQueryTagString AS targetTbl
                   INNER JOIN
                   InputCTE AS cte
                   ON targetTbl.ResourceType = cte.ResourceType
                      AND cte.PartitionKey = targetTbl.PartitionKey
                      AND cte.WorkitemKey = targetTbl.SopInstanceKey1
                      AND cte.TagKey = targetTbl.TagKey
                      AND cte.OldTagValue = targetTbl.TagValue
                      AND cte.Watermark = targetTbl.Watermark;
        END
    IF EXISTS (SELECT 1
               FROM   @dateTimeExtendedQueryTags)
        BEGIN
            WITH InputCTE
            AS   (SELECT wqt.TagKey,
                         wqt.TagPath,
                         eqts.TagValue AS OldTagValue,
                         input.TagValue AS NewTagValue,
                         eqts.ResourceType,
                         wi.PartitionKey,
                         wi.WorkitemKey,
                         wi.WorkitemUid,
                         wi.TransactionUid,
                         eqts.Watermark
                  FROM   dbo.WorkitemQueryTag AS wqt
                         INNER JOIN
                         @dateTimeExtendedQueryTags AS input
                         ON input.TagKey = wqt.TagKey
                         INNER JOIN
                         dbo.ExtendedQueryTagDateTime AS eqts
                         ON eqts.TagKey = wqt.TagKey
                            AND eqts.ResourceType = 1
                         INNER JOIN
                         dbo.Workitem AS wi
                         ON wi.PartitionKey = eqts.PartitionKey
                            AND wi.WorkitemKey = eqts.SopInstanceKey1
                  WHERE  wi.PartitionKey = @partitionKey
                         AND wi.WorkitemKey = @workitemKey)
            UPDATE targetTbl
            SET    targetTbl.TagValue  = cte.NewTagValue,
                   targetTbl.Watermark = @newWatermark
            FROM   dbo.ExtendedQueryTagDateTime AS targetTbl
                   INNER JOIN
                   InputCTE AS cte
                   ON targetTbl.ResourceType = cte.ResourceType
                      AND cte.PartitionKey = targetTbl.PartitionKey
                      AND cte.WorkitemKey = targetTbl.SopInstanceKey1
                      AND cte.TagKey = targetTbl.TagKey
                      AND cte.OldTagValue = targetTbl.TagValue
                      AND cte.Watermark = targetTbl.Watermark;
        END
    IF EXISTS (SELECT 1
               FROM   @personNameExtendedQueryTags)
        BEGIN
            WITH InputCTE
            AS   (SELECT wqt.TagKey,
                         wqt.TagPath,
                         eqts.TagValue AS OldTagValue,
                         input.TagValue AS NewTagValue,
                         eqts.ResourceType,
                         wi.PartitionKey,
                         wi.WorkitemKey,
                         wi.WorkitemUid,
                         wi.TransactionUid,
                         eqts.Watermark
                  FROM   dbo.WorkitemQueryTag AS wqt
                         INNER JOIN
                         @personNameExtendedQueryTags AS input
                         ON input.TagKey = wqt.TagKey
                         INNER JOIN
                         dbo.ExtendedQueryTagPersonName AS eqts
                         ON eqts.TagKey = wqt.TagKey
                            AND eqts.ResourceType = 1
                         INNER JOIN
                         dbo.Workitem AS wi
                         ON wi.PartitionKey = eqts.PartitionKey
                            AND wi.WorkitemKey = eqts.SopInstanceKey1
                  WHERE  wi.PartitionKey = @partitionKey
                         AND wi.WorkitemKey = @workitemKey)
            UPDATE targetTbl
            SET    targetTbl.TagValue  = cte.NewTagValue,
                   targetTbl.Watermark = @newWatermark
            FROM   dbo.ExtendedQueryTagPersonName AS targetTbl
                   INNER JOIN
                   InputCTE AS cte
                   ON targetTbl.ResourceType = cte.ResourceType
                      AND cte.PartitionKey = targetTbl.PartitionKey
                      AND cte.WorkitemKey = targetTbl.SopInstanceKey1
                      AND cte.TagKey = targetTbl.TagKey
                      AND cte.OldTagValue = targetTbl.TagValue
                      AND cte.Watermark = targetTbl.Watermark;
        END
    EXECUTE dbo.UpdateWorkitemStatus @partitionKey, @workitemKey, @status;
    COMMIT TRANSACTION;
    SELECT @workitemKey;
END

GO
CREATE OR ALTER PROCEDURE dbo.UpdateWorkitemProcedureStepState
@partitionKey INT, @workitemUid VARCHAR (64), @procedureStepStateTagPath VARCHAR (64), @procedureStepState VARCHAR (64), @status TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DECLARE @workitemKey AS BIGINT;
    DECLARE @newWatermark AS BIGINT;
    DECLARE @currentProcedureStepStateTagValue AS VARCHAR (64);
    DECLARE @currentDate AS DATETIME2 (7) = SYSUTCDATETIME();
    SELECT @workitemKey = WorkitemKey
    FROM   dbo.Workitem
    WHERE  PartitionKey = @partitionKey
           AND WorkitemUid = @workitemUid;
    IF @@ROWCOUNT = 0
        THROW 50409, 'Workitem does not exist', 1;
    SET @newWatermark =  NEXT VALUE FOR dbo.WatermarkSequence;
    BEGIN TRY
        WITH TagKeyCTE
        AS   (SELECT wqt.TagKey,
                     wqt.TagPath,
                     eqts.TagValue AS OldTagValue,
                     eqts.ResourceType,
                     wi.PartitionKey,
                     wi.WorkitemKey,
                     wi.WorkitemUid,
                     wi.TransactionUid,
                     eqts.Watermark
              FROM   dbo.WorkitemQueryTag AS wqt
                     INNER JOIN
                     dbo.ExtendedQueryTagString AS eqts
                     ON eqts.TagKey = wqt.TagKey
                        AND eqts.ResourceType = 1
                     INNER JOIN
                     dbo.Workitem AS wi
                     ON wi.PartitionKey = eqts.PartitionKey
                        AND wi.WorkitemKey = eqts.SopInstanceKey1
              WHERE  wi.PartitionKey = @partitionKey
                     AND wi.WorkitemKey = @workitemKey)
        UPDATE targetTbl
        SET    targetTbl.TagValue  = @procedureStepState,
               targetTbl.Watermark = @newWatermark
        FROM   dbo.ExtendedQueryTagString AS targetTbl
               INNER JOIN
               TagKeyCTE AS cte
               ON targetTbl.ResourceType = cte.ResourceType
                  AND cte.PartitionKey = targetTbl.PartitionKey
                  AND cte.WorkitemKey = targetTbl.SopInstanceKey1
                  AND cte.TagKey = targetTbl.TagKey
                  AND cte.OldTagValue = targetTbl.TagValue
                  AND cte.Watermark = targetTbl.Watermark
        WHERE  cte.TagPath = @procedureStepStateTagPath;
        EXECUTE dbo.UpdateWorkitemStatus @partitionKey, @workitemKey, @status;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
    SELECT @workitemKey;
    COMMIT TRANSACTION;
END

GO
CREATE OR ALTER PROCEDURE dbo.UpdateWorkitemStatus
@partitionKey INT, @workitemKey BIGINT, @status TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    DECLARE @currentDate AS DATETIME2 (7) = SYSUTCDATETIME();
    UPDATE dbo.Workitem
    SET    Status                = @status,
           LastStatusUpdatedDate = @currentDate
    WHERE  PartitionKey = @partitionKey
           AND WorkitemKey = @workitemKey;
    IF @@ROWCOUNT = 0
        THROW 50404, 'Workitem instance does not exist', 1;
    COMMIT TRANSACTION;
END

GO
