﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using EnsureThat;
using Microsoft.Data.SqlClient;
using Microsoft.Health.Dicom.SqlServer.Features.CustomTag;

namespace Microsoft.Health.Dicom.Tests.Integration.Persistence.Models
{
    public class CustomTagDataRow
    {
        public int TagKey { get; private set; }

        public object TagValue { get; private set; }

        public long StudyKey { get; private set; }

        public long? SeriesKey { get; private set; }

        public long? InstancKey { get; private set; }

        public long Watermark { get; private set; }

        private void ReadOthers(SqlDataReader sqlDataReader)
        {
            EnsureArg.IsNotNull(sqlDataReader, nameof(sqlDataReader));

            TagKey = sqlDataReader.GetInt32(0);
            StudyKey = sqlDataReader.GetInt64(2);
            SeriesKey = ReadNullableLong(sqlDataReader, 3);
            InstancKey = ReadNullableLong(sqlDataReader, 4);
            Watermark = sqlDataReader.GetInt64(5);
        }

        internal void Read(SqlDataReader sqlDataReader, CustomTagDataType dataType)
        {
            switch (dataType)
            {
                case CustomTagDataType.StringData:
                    TagValue = sqlDataReader.GetString(1);
                    break;
                case CustomTagDataType.LongData:
                    TagValue = sqlDataReader.GetInt64(1);
                    break;
                case CustomTagDataType.DoubleData:
                    TagValue = sqlDataReader.GetDouble(1);
                    break;
                case CustomTagDataType.DateTimeData:
                    TagValue = sqlDataReader.GetDateTime(1);
                    break;
                case CustomTagDataType.PersonNameData:
                    TagValue = sqlDataReader.GetString(1);
                    break;
                default:
                    break;
            }

            ReadOthers(sqlDataReader);
        }

        private static long? ReadNullableLong(SqlDataReader sqlDataReader, int column)
        {
            return sqlDataReader.IsDBNull(column) ? null : sqlDataReader.GetInt64(column);
        }
    }
}
