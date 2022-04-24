﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using Microsoft.Health.Dicom.Core.Models;
using Microsoft.Health.Dicom.Core.Models.Export;

namespace Microsoft.Health.Dicom.Core.Features.Export;

public interface IExportSource : IAsyncEnumerable<SourceElement>, IAsyncDisposable
{
    event EventHandler<ReadFailureEventArgs> ReadFailure;

    TypedConfiguration<ExportSourceType> Configuration { get; }

    TypedConfiguration<ExportSourceType> DequeueBatch(int size);
}
