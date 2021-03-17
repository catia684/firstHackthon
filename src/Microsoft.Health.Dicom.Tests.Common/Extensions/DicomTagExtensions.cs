﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using Dicom;
using Microsoft.Health.Dicom.Core.Extensions;
using Microsoft.Health.Dicom.Core.Features.CustomTag;

namespace Microsoft.Health.Dicom.Tests.Common.Extensions
{
    public static class DicomTagExtensions
    {
        public static CustomTagEntry BuildCustomTagEntry(this DicomTag tag, string vr = null, string privateCreator = null, CustomTagLevel level = CustomTagLevel.Series, CustomTagStatus status = CustomTagStatus.Added)
        {
            return new CustomTagEntry() { Path = tag.GetPath(), VR = vr ?? tag.GetDefaultVR()?.Code, PrivateCreator = privateCreator, Level = level, Status = status };
        }

        public static CustomTagStoreEntry BuildCustomTagStoreEntry(this DicomTag tag, int key = 1, string vr = null, string privateCreator = null, CustomTagLevel level = CustomTagLevel.Series, CustomTagStatus status = CustomTagStatus.Reindexing)
        {
            return new CustomTagStoreEntry(key: key, path: tag.GetPath(), vr: vr ?? tag.GetDefaultVR().Code, privateCreator: privateCreator, level: level, status: status);
        }
    }
}
