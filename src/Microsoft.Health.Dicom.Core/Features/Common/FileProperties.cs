﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

namespace Microsoft.Health.Dicom.Core.Features.Common;

public class FileProperties
{
    public long ContentLength { get; init; }

    public long StreamLength { get; init; }

    public string FilePath { get; init; }

    public string ETag { get; init; }
}
