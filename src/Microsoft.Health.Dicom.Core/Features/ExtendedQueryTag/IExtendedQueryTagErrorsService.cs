﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Health.Dicom.Core.Messages.ExtendedQueryTag;

namespace Microsoft.Health.Dicom.Core.Features.ExtendedQueryTag
{
    public interface IExtendedQueryTagErrorsService
    {
        /// <summary>
        /// Asynchronously adds an error for a specified Extended Query Tag.
        /// </summary>
        /// <param name="tagKey">TagKey of the extended query tag to which an error will be added.</param>
        /// <param name="createdTime">Time at which the error was created.</param>
        /// <param name="errorCode">Error code.</param>
        /// <param name="watermark">Watermark.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>The tag key.</returns>
        public Task<int> AddExtendedQueryTagErrorAsync(
            int tagKey,
            int errorCode,
            long watermark,
            DateTime createdTime,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Asynchronously gets errors for a specified Extended Query Tag.
        /// </summary>
        /// <param name="tagPath">Path to the extended query tag that is requested.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>The response.</returns>
        public Task<GetExtendedQueryTagErrorsResponse> GetExtendedQueryTagErrorsAsync(string tagPath, CancellationToken cancellationToken = default);
    }
}
