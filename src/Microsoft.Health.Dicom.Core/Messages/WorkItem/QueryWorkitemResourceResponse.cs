﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using System.Collections.Generic;
using EnsureThat;
using FellowOakDicom;

namespace Microsoft.Health.Dicom.Core.Messages.Workitem
{
    public sealed class QueryWorkitemResourceResponse
    {
        public QueryWorkitemResourceResponse(IEnumerable<DicomDataset> responseDataset, IReadOnlyCollection<string> erroneousTags)
        {
            ResponseDatasets = EnsureArg.IsNotNull(responseDataset, nameof(responseDataset));
            ErroneousTags = EnsureArg.IsNotNull(erroneousTags, nameof(erroneousTags));
        }

        public IEnumerable<DicomDataset> ResponseDatasets { get; }

        public IReadOnlyCollection<string> ErroneousTags { get; }
    }
}
