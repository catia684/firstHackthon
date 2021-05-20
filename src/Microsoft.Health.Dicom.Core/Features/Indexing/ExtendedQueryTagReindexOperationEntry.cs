﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using Microsoft.Health.Dicom.Core.Features.ExtendedQueryTag;

namespace Microsoft.Health.Dicom.Core.Features.Indexing
{
    public class ExtendedQueryTagReindexOperationEntry
    {
        public long ExtendedQueryTagKey { get; set; }

        public string OperationId { get; set; }

        public long EndWatermark { get; set; }

        public ExtendedQueryTagOperationStatus Status { get; set; }

        public ExtendedQueryTagStoreEntry ExtendedQueryTagStoreEntry { get; set; }
    }
}
