﻿
/*************************************************************
    Extended Query Tag Data Table for VR Types mapping to Double
    Note: Watermark is primarily used while re-indexing to determine which TagValue is latest.
            For example, with multiple instances in a series, while indexing a series level tag,
            the Watermark is used to ensure that if there are different values between instances,
            the value on the instance with the highest watermark wins.
**************************************************************/
CREATE TABLE dbo.ExtendedQueryTagDouble (
    TagKey                  INT                  NOT NULL,              --PK
    TagValue                FLOAT(53)            NOT NULL,
    StudyKey                BIGINT               NOT NULL,              --FK
    SeriesKey               BIGINT               NULL,                  --FK
    InstanceKey             BIGINT               NULL,                  --FK
    Watermark               BIGINT               NOT NULL,
    PartitionKey            INT                  NOT NULL DEFAULT 1     --FK
) WITH (DATA_COMPRESSION = PAGE)

CREATE UNIQUE CLUSTERED INDEX IXC_ExtendedQueryTagDouble ON dbo.ExtendedQueryTagDouble
(
    TagKey,
    TagValue,
    StudyKey,
    SeriesKey,
    InstanceKey,
    PartitionKey
)

CREATE UNIQUE NONCLUSTERED INDEX IX_ExtendedQueryTagDouble_TagKey_StudyKey_SeriesKey_InstanceKey_PartitionKey on dbo.ExtendedQueryTagDouble
(
    TagKey,
    StudyKey,
    SeriesKey,
    InstanceKey,
    PartitionKey
)
INCLUDE
(
    Watermark
)
WITH (DATA_COMPRESSION = PAGE)
