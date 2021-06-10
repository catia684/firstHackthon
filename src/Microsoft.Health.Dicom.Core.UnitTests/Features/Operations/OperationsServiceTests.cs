﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Health.Dicom.Core.Features.Operations;
using Microsoft.Health.Dicom.Core.Messages.Operations;
using Microsoft.Health.Dicom.Core.Models.Operations;
using NSubstitute;
using Xunit;

namespace Microsoft.Health.Dicom.Core.UnitTests.Features.Operations
{
    public class OperationsServiceTests
    {
        [Fact]
        public void Ctor_GivenNullArgument_ThrowsArgumentNullException()
        {
            Assert.Throws<ArgumentNullException>(() => new OperationsService(null));
        }

        [Theory]
        [InlineData(null)]
        [InlineData("")]
        [InlineData("   ")]
        [InlineData("\t  \r\n")]
        public async Task GetStatusAsync_GivenInvalidId_ThrowsArgumentException(string id)
        {
            IDicomOperationsClient client = Substitute.For<IDicomOperationsClient>();
            Type exceptionType = id is null ? typeof(ArgumentNullException) : typeof(ArgumentException);
            await Assert.ThrowsAsync(
                exceptionType,
                () => new OperationsService(client).GetStatusAsync(
                    id,
                    CancellationToken.None));

            await client.DidNotReceiveWithAnyArgs().GetStatusAsync(default, default);
        }

        [Fact]
        public async Task GetStatusAsync_GivenNullResponse_ReturnsNull()
        {
            using var source = new CancellationTokenSource();
            IDicomOperationsClient client = Substitute.For<IDicomOperationsClient>();
            var service = new OperationsService(client);

            string id = Guid.NewGuid().ToString();
            client.GetStatusAsync(Arg.Is(id), Arg.Is(source.Token)).Returns(default(OperationStatusResponse));

            Assert.Null(await service.GetStatusAsync(id, source.Token));

            await client.Received(1).GetStatusAsync(Arg.Is(id), Arg.Is(source.Token));
        }

        [Theory]
        [InlineData(OperationType.Unknown)]
        public async Task GetStatusAsync_GivenNonPublicOperation_ReturnsNull(OperationType type)
        {
            using var source = new CancellationTokenSource();
            IDicomOperationsClient client = Substitute.For<IDicomOperationsClient>();
            var service = new OperationsService(client);

            string id = Guid.NewGuid().ToString();
            client.GetStatusAsync(Arg.Is(id), Arg.Is(source.Token))
                .Returns(new OperationStatusResponse(id, type, DateTime.UtcNow, OperationRuntimeStatus.Completed));

            Assert.Null(await service.GetStatusAsync(id, source.Token));

            await client.Received(1).GetStatusAsync(Arg.Is(id), Arg.Is(source.Token));
        }

        [Theory]
        [InlineData(OperationType.Reindex)]
        public async Task GetStatusAsync_GivenPublicOperation_ReturnsStatus(OperationType type)
        {
            using var source = new CancellationTokenSource();
            IDicomOperationsClient client = Substitute.For<IDicomOperationsClient>();
            var service = new OperationsService(client);

            string id = Guid.NewGuid().ToString();
            var expected = new OperationStatusResponse(id, type, DateTime.UtcNow, OperationRuntimeStatus.Completed);
            client.GetStatusAsync(Arg.Is(id), Arg.Is(source.Token)).Returns(expected);

            Assert.Same(expected, await service.GetStatusAsync(id, source.Token));

            await client.Received(1).GetStatusAsync(Arg.Is(id), Arg.Is(source.Token));
        }
    }
}
