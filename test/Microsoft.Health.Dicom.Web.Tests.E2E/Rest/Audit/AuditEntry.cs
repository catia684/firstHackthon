﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using Microsoft.Health.Core.Features.Audit;

namespace Microsoft.Health.Dicom.Web.Tests.E2E.Rest.Audit;

public class AuditEntry
{
    public AuditEntry(
        AuditAction auditAction)
    {
        AuditAction = auditAction;
    }

    public AuditAction AuditAction { get; }
}
