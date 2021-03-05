//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------
namespace Microsoft.Health.Dicom.SqlServer.Features.Schema.Model
{
    using Microsoft.Health.SqlServer.Features.Client;
    using Microsoft.Health.SqlServer.Features.Schema.Model;

    internal class AddCustomTagsInputTableTypeV1TableValuedParameterDefinition : TableValuedParameterDefinition<AddCustomTagsInputTableTypeV1Row>
    {
        internal AddCustomTagsInputTableTypeV1TableValuedParameterDefinition(System.String parameterName) : base(parameterName, "dbo.AddCustomTagsInputTableType_1")
        {
        }

        internal readonly VarCharColumn TagPath = new VarCharColumn("TagPath", 64);
        internal readonly VarCharColumn TagVR = new VarCharColumn("TagVR", 2);
        internal readonly TinyIntColumn TagLevel = new TinyIntColumn("TagLevel");

        protected override global::System.Collections.Generic.IEnumerable<Column> Columns => new Column[] { TagPath, TagVR, TagLevel };

        protected override void FillSqlDataRecord(global::Microsoft.Data.SqlClient.Server.SqlDataRecord record, AddCustomTagsInputTableTypeV1Row rowData)
        {
            TagPath.Set(record, 0, rowData.TagPath);
            TagVR.Set(record, 1, rowData.TagVR);
            TagLevel.Set(record, 2, rowData.TagLevel);
        }
    }

    internal struct AddCustomTagsInputTableTypeV1Row
    {
        internal AddCustomTagsInputTableTypeV1Row(System.String TagPath, System.String TagVR, System.Byte TagLevel)
        {
            this.TagPath = TagPath;
            this.TagVR = TagVR;
            this.TagLevel = TagLevel;
        }

        internal System.String TagPath { get; }
        internal System.String TagVR { get; }
        internal System.Byte TagLevel { get; }
    }

    internal class InsertBigIntCustomTagTableTypeV1TableValuedParameterDefinition : TableValuedParameterDefinition<InsertBigIntCustomTagTableTypeV1Row>
    {
        internal InsertBigIntCustomTagTableTypeV1TableValuedParameterDefinition(System.String parameterName) : base(parameterName, "dbo.InsertBigIntCustomTagTableType_1")
        {
        }

        internal readonly BigIntColumn TagKey = new BigIntColumn("TagKey");
        internal readonly BigIntColumn TagValue = new BigIntColumn("TagValue");
        internal readonly TinyIntColumn TagLevel = new TinyIntColumn("TagLevel");

        protected override global::System.Collections.Generic.IEnumerable<Column> Columns => new Column[] { TagKey, TagValue, TagLevel };

        protected override void FillSqlDataRecord(global::Microsoft.Data.SqlClient.Server.SqlDataRecord record, InsertBigIntCustomTagTableTypeV1Row rowData)
        {
            TagKey.Set(record, 0, rowData.TagKey);
            TagValue.Set(record, 1, rowData.TagValue);
            TagLevel.Set(record, 2, rowData.TagLevel);
        }
    }

    internal struct InsertBigIntCustomTagTableTypeV1Row
    {
        internal InsertBigIntCustomTagTableTypeV1Row(System.Int64 TagKey, System.Int64 TagValue, System.Byte TagLevel)
        {
            this.TagKey = TagKey;
            this.TagValue = TagValue;
            this.TagLevel = TagLevel;
        }

        internal System.Int64 TagKey { get; }
        internal System.Int64 TagValue { get; }
        internal System.Byte TagLevel { get; }
    }

    internal class InsertDateTimeCustomTagTableTypeV1TableValuedParameterDefinition : TableValuedParameterDefinition<InsertDateTimeCustomTagTableTypeV1Row>
    {
        internal InsertDateTimeCustomTagTableTypeV1TableValuedParameterDefinition(System.String parameterName) : base(parameterName, "dbo.InsertDateTimeCustomTagTableType_1")
        {
        }

        internal readonly BigIntColumn TagKey = new BigIntColumn("TagKey");
        internal readonly DateTime2Column TagValue = new DateTime2Column("TagValue", 7);
        internal readonly TinyIntColumn TagLevel = new TinyIntColumn("TagLevel");

        protected override global::System.Collections.Generic.IEnumerable<Column> Columns => new Column[] { TagKey, TagValue, TagLevel };

        protected override void FillSqlDataRecord(global::Microsoft.Data.SqlClient.Server.SqlDataRecord record, InsertDateTimeCustomTagTableTypeV1Row rowData)
        {
            TagKey.Set(record, 0, rowData.TagKey);
            TagValue.Set(record, 1, rowData.TagValue);
            TagLevel.Set(record, 2, rowData.TagLevel);
        }
    }

    internal struct InsertDateTimeCustomTagTableTypeV1Row
    {
        internal InsertDateTimeCustomTagTableTypeV1Row(System.Int64 TagKey, System.DateTime TagValue, System.Byte TagLevel)
        {
            this.TagKey = TagKey;
            this.TagValue = TagValue;
            this.TagLevel = TagLevel;
        }

        internal System.Int64 TagKey { get; }
        internal System.DateTime TagValue { get; }
        internal System.Byte TagLevel { get; }
    }

    internal class InsertPersonNameCustomTagTableTypeV1TableValuedParameterDefinition : TableValuedParameterDefinition<InsertPersonNameCustomTagTableTypeV1Row>
    {
        internal InsertPersonNameCustomTagTableTypeV1TableValuedParameterDefinition(System.String parameterName) : base(parameterName, "dbo.InsertPersonNameCustomTagTableType_1")
        {
        }

        internal readonly BigIntColumn TagKey = new BigIntColumn("TagKey");
        internal readonly NVarCharColumn TagValue = new NVarCharColumn("TagValue", 200, "SQL_Latin1_General_CP1_CI_AI");
        internal readonly TinyIntColumn TagLevel = new TinyIntColumn("TagLevel");

        protected override global::System.Collections.Generic.IEnumerable<Column> Columns => new Column[] { TagKey, TagValue, TagLevel };

        protected override void FillSqlDataRecord(global::Microsoft.Data.SqlClient.Server.SqlDataRecord record, InsertPersonNameCustomTagTableTypeV1Row rowData)
        {
            TagKey.Set(record, 0, rowData.TagKey);
            TagValue.Set(record, 1, rowData.TagValue);
            TagLevel.Set(record, 2, rowData.TagLevel);
        }
    }

    internal struct InsertPersonNameCustomTagTableTypeV1Row
    {
        internal InsertPersonNameCustomTagTableTypeV1Row(System.Int64 TagKey, System.String TagValue, System.Byte TagLevel)
        {
            this.TagKey = TagKey;
            this.TagValue = TagValue;
            this.TagLevel = TagLevel;
        }

        internal System.Int64 TagKey { get; }
        internal System.String TagValue { get; }
        internal System.Byte TagLevel { get; }
    }

    internal class InsertStringCustomTagTableTypeV1TableValuedParameterDefinition : TableValuedParameterDefinition<InsertStringCustomTagTableTypeV1Row>
    {
        internal InsertStringCustomTagTableTypeV1TableValuedParameterDefinition(System.String parameterName) : base(parameterName, "dbo.InsertStringCustomTagTableType_1")
        {
        }

        internal readonly BigIntColumn TagKey = new BigIntColumn("TagKey");
        internal readonly NVarCharColumn TagValue = new NVarCharColumn("TagValue", 64);
        internal readonly TinyIntColumn TagLevel = new TinyIntColumn("TagLevel");

        protected override global::System.Collections.Generic.IEnumerable<Column> Columns => new Column[] { TagKey, TagValue, TagLevel };

        protected override void FillSqlDataRecord(global::Microsoft.Data.SqlClient.Server.SqlDataRecord record, InsertStringCustomTagTableTypeV1Row rowData)
        {
            TagKey.Set(record, 0, rowData.TagKey);
            TagValue.Set(record, 1, rowData.TagValue);
            TagLevel.Set(record, 2, rowData.TagLevel);
        }
    }

    internal struct InsertStringCustomTagTableTypeV1Row
    {
        internal InsertStringCustomTagTableTypeV1Row(System.Int64 TagKey, System.String TagValue, System.Byte TagLevel)
        {
            this.TagKey = TagKey;
            this.TagValue = TagValue;
            this.TagLevel = TagLevel;
        }

        internal System.Int64 TagKey { get; }
        internal System.String TagValue { get; }
        internal System.Byte TagLevel { get; }
    }
}