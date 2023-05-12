// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using EnsureThat;
using Microsoft.Health.Dicom.Core.Exceptions;
using Microsoft.Health.Dicom.Core.Features.Common;
using Microsoft.Health.Dicom.Core.Features.Model;
using Microsoft.IO;
using Xunit;

namespace Microsoft.Health.Dicom.Tests.Integration.Persistence;

public class FileStoreTests : IClassFixture<DataStoreTestsFixture>
{
    private readonly IFileStore _blobDataStore;
    private readonly Func<int> _getNextWatermark;
    private readonly RecyclableMemoryStreamManager _recyclableMemoryStreamManager;

    public FileStoreTests(DataStoreTestsFixture fixture)
    {
        EnsureArg.IsNotNull(fixture, nameof(fixture));
        _blobDataStore = fixture.FileStore;
        _getNextWatermark = () => fixture.NextWatermark;
        _recyclableMemoryStreamManager = fixture.RecyclableMemoryStreamManager;
    }

    [Fact]
    public async Task GivenAValidFileStream_WhenStored_ThenItCanBeRetrievedAndDeleted()
    {
        var version = _getNextWatermark();

        var fileData = new byte[] { 4, 7, 2 };

        // Store the file.
        InstanceProperties instanceProperties = await AddFileAsync(version, fileData, $"{nameof(GivenAValidFileStream_WhenStored_ThenItCanBeRetrievedAndDeleted)}.fileData");

        Assert.NotNull(instanceProperties);

        // Should be able to retrieve.
        await using (Stream resultStream = await _blobDataStore.GetFileAsync(version))
        {
            Assert.Equal(
                fileData,
                await ConvertStreamToByteArrayAsync(resultStream));
        }

        // Should be able to delete.
        await _blobDataStore.DeleteFileIfExistsAsync(version);

        // The file should no longer exists.
        await Assert.ThrowsAsync<ItemNotFoundException>(() => _blobDataStore.GetFileAsync(version));
    }

    [Fact]
    public async Task GivenFileAlreadyExists_WhenStored_ThenExistingFileWillBeOverwritten()
    {
        var version = _getNextWatermark();

        var fileData1 = new byte[] { 4, 7, 2 };

        InstanceProperties instanceProperties1 = await AddFileAsync(version, fileData1, $"{nameof(GivenFileAlreadyExists_WhenStored_ThenExistingFileWillBeOverwritten)}.fileData1");

        var fileData2 = new byte[] { 1, 3, 5 };

        InstanceProperties instanceProperties2 = await AddFileAsync(version, fileData2, $"{nameof(GivenFileAlreadyExists_WhenStored_ThenExistingFileWillBeOverwritten)}.fileData2");

        Assert.Equal(instanceProperties1, instanceProperties2);

        await using (Stream resultStream = await _blobDataStore.GetFileAsync(version))
        {
            Assert.Equal(
                fileData2,
                await ConvertStreamToByteArrayAsync(resultStream));
        }

        await _blobDataStore.DeleteFileIfExistsAsync(version);
    }

    [Fact]
    public async Task GivenANonExistentFile_WhenRetrieving_ThenItemNotFoundExceptionShouldBeThrown()
    {
        await Assert.ThrowsAsync<ItemNotFoundException>(() => _blobDataStore.GetFileAsync(_getNextWatermark()));
    }

    [Fact]
    public async Task GivenANonExistentFile_WhenDeleting_ThenItShouldNotThrowException()
    {
        await _blobDataStore.DeleteFileIfExistsAsync(_getNextWatermark());
    }

    private async Task<byte[]> ConvertStreamToByteArrayAsync(Stream stream)
    {
        await using (MemoryStream memoryStream = _recyclableMemoryStreamManager.GetStream())
        {
            await stream.CopyToAsync(memoryStream);
            return memoryStream.ToArray();
        }
    }

    private async Task<InstanceProperties> AddFileAsync(long version, byte[] bytes, string tag, CancellationToken cancellationToken = default)
    {
        await using (var stream = _recyclableMemoryStreamManager.GetStream(tag, bytes, 0, bytes.Length))
        {
            return await _blobDataStore.StoreFileAsync(version, stream, cancellationToken);
        }
    }
}
