// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using EnsureThat;
using FellowOakDicom;
using Microsoft.Health.Dicom.Client;
using Microsoft.Health.Dicom.Tests.Common;
using Microsoft.Health.Dicom.Web.Tests.E2E.Common;
using Microsoft.Health.Operations;
using Xunit;

namespace Microsoft.Health.Dicom.Web.Tests.E2E.Rest;

[Trait("Category", "dicomupdate")]
public class UpdateInstanceTests : IClassFixture<HttpIntegrationTestFixture<Startup>>, IAsyncLifetime
{
    private readonly IDicomWebClient _client;
    private readonly DicomInstancesManager _instancesManager;

    public UpdateInstanceTests(HttpIntegrationTestFixture<Startup> fixture)
    {
        EnsureArg.IsNotNull(fixture, nameof(fixture));
        _client = fixture.GetDicomWebClient();
        _instancesManager = new DicomInstancesManager(_client);
    }

    [Fact]
    public async Task WhenUpdatingDicomMetadataForASingleStudy_ThenItShouldUpdateCorrectly()
    {
        var studyInstanceUid = TestUidGenerator.Generate();

        DicomFile dicomFile1 = Samples.CreateRandomDicomFile(studyInstanceUid);
        DicomFile dicomFile2 = Samples.CreateRandomDicomFile(studyInstanceUid);
        DicomFile dicomFile3 = Samples.CreateRandomDicomFile(studyInstanceUid);

        // Upload files
        Assert.True((await _instancesManager.StoreAsync(new[] { dicomFile1 })).IsSuccessStatusCode);
        Assert.True((await _instancesManager.StoreAsync(new[] { dicomFile2 })).IsSuccessStatusCode);
        Assert.True((await _instancesManager.StoreAsync(new[] { dicomFile3 })).IsSuccessStatusCode);

        // Update study
        var datasetToUpdate = new DicomDataset();
        datasetToUpdate.AddOrUpdate(DicomTag.PatientName, "New^PatientName");
#pragma warning disable CS0618
        Assert.Equal(OperationStatus.Completed, await _instancesManager.UpdateStudyAsync(new List<string> { studyInstanceUid }, datasetToUpdate));
#pragma warning restore CS0618

        // Verify study
        using DicomWebAsyncEnumerableResponse<DicomDataset> response = await _client.RetrieveStudyMetadataAsync(studyInstanceUid);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("application/dicom+json", response.ContentHeaders.ContentType.MediaType);

        DicomDataset[] datasets = await response.ToArrayAsync();

        Assert.Equal(3, datasets.Length);
        foreach (DicomDataset dicomDataset in datasets)
        {
            Assert.Equal("New^PatientName", dicomDataset.GetSingleValue<string>(DicomTag.PatientName));
        }
    }

    [Fact]
    public async Task WhenUpdatingDicomMetadataForMultipleStudy_ThenItShouldUpdateCorrectly()
    {
        var studyInstanceUid1 = TestUidGenerator.Generate();
        var studyInstanceUid2 = TestUidGenerator.Generate();

        DicomFile dicomFile1 = Samples.CreateRandomDicomFileWithPixelData(studyInstanceUid1, rows: 200, columns: 200, frames: 10, dicomTransferSyntax: DicomTransferSyntax.ExplicitVRLittleEndian);
        DicomFile dicomFile2 = Samples.CreateRandomDicomFile(studyInstanceUid1);
        DicomFile dicomFile3 = Samples.CreateRandomDicomFileWithPixelData(studyInstanceUid2);

        // Upload files
        Assert.True((await _instancesManager.StoreAsync(new[] { dicomFile1 })).IsSuccessStatusCode);
        Assert.True((await _instancesManager.StoreAsync(new[] { dicomFile2 })).IsSuccessStatusCode);
        Assert.True((await _instancesManager.StoreAsync(new[] { dicomFile3 })).IsSuccessStatusCode);

        // Update study
        var datasetToUpdate = new DicomDataset();
        datasetToUpdate.AddOrUpdate(DicomTag.PatientName, "New^PatientName");
#pragma warning disable CS0618
        Assert.Equal(OperationStatus.Completed, await _instancesManager.UpdateStudyAsync(new List<string> { studyInstanceUid1 }, datasetToUpdate));
#pragma warning restore CS0618

        // Verify study
        using DicomWebAsyncEnumerableResponse<DicomDataset> response = await _client.RetrieveStudyMetadataAsync(studyInstanceUid1);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("application/dicom+json", response.ContentHeaders.ContentType.MediaType);

        DicomDataset[] datasets = await response.ToArrayAsync();

        Assert.Equal(2, datasets.Length);
        foreach (DicomDataset dicomDataset in datasets)
        {
            Assert.Equal("New^PatientName", dicomDataset.GetSingleValue<string>(DicomTag.PatientName));
        }

        await VerifyRetrieveInstance(studyInstanceUid1, dicomFile1, "New^PatientName");

        // Update again to ensure DICOM file is not corrupted after update
        datasetToUpdate.AddOrUpdate(DicomTag.PatientName, "New^PatientName1");
#pragma warning disable CS0618
        Assert.Equal(OperationStatus.Completed, await _instancesManager.UpdateStudyAsync(new List<string> { studyInstanceUid1 }, datasetToUpdate));
#pragma warning restore CS0618

        await VerifyRetrieveInstance(studyInstanceUid1, dicomFile1, "New^PatientName1");
        await VerifyRetrieveInstanceWithTranscoding(studyInstanceUid1, dicomFile1, "New^PatientName1");

        await VerifyRetrieveFrame(studyInstanceUid1, dicomFile1);
    }

    private async Task VerifyRetrieveInstance(string studyInstanceUid, DicomFile dicomFile, string expectedPatientName)
    {
        using DicomWebResponse<DicomFile> instanceRetrieve = await _client.RetrieveInstanceAsync(
            studyInstanceUid,
            dicomFile.Dataset.GetSingleValue<string>(DicomTag.SeriesInstanceUID),
            dicomFile.Dataset.GetSingleValue<string>(DicomTag.SOPInstanceUID),
            dicomTransferSyntax: "*");

        DicomFile retrievedDicomFile = await instanceRetrieve.GetValueAsync();

        Assert.Equal(expectedPatientName, retrievedDicomFile.Dataset.GetSingleValue<string>(DicomTag.PatientName));
    }

    private async Task VerifyRetrieveFrame(string studyInstanceUid, DicomFile dicomFile)
    {
        using DicomWebResponse<Stream> response = await _client.RetrieveSingleFrameAsync(
            studyInstanceUid,
            dicomFile.Dataset.GetSingleValue<string>(DicomTag.SeriesInstanceUID),
            dicomFile.Dataset.GetSingleValue<string>(DicomTag.SOPInstanceUID),
            1);
        Stream frameStream = await response.GetValueAsync();
        Assert.NotNull(frameStream);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    private async Task VerifyRetrieveInstanceWithTranscoding(string studyInstanceUid, DicomFile dicomFile, string expectedPatientName)
    {
        using DicomWebResponse<DicomFile> instanceRetrieve = await _client.RetrieveInstanceAsync(
            studyInstanceUid,
            dicomFile.Dataset.GetSingleValue<string>(DicomTag.SeriesInstanceUID),
            dicomFile.Dataset.GetSingleValue<string>(DicomTag.SOPInstanceUID),
            dicomTransferSyntax: DicomTransferSyntax.JPEG2000Lossless.UID.UID);

        DicomFile retrievedDicomFile = await instanceRetrieve.GetValueAsync();

        Assert.Equal(expectedPatientName, retrievedDicomFile.Dataset.GetSingleValue<string>(DicomTag.PatientName));
    }

    private async Task VerifyDeleteStudyAsync(string studyInstanceUid, DicomFile dicomFile)
    {
        var seriesInstanceUID = dicomFile.Dataset.GetSingleValue<string>(DicomTag.SeriesInstanceUID);
        var sopInstanceUID = dicomFile.Dataset.GetSingleValue<string>(DicomTag.SOPInstanceUID);

        using (DicomWebResponse response = await _client.DeleteStudyAsync(studyInstanceUid))
        {
            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
        }

        DicomWebException exception1 = await Assert.ThrowsAsync<DicomWebException>(() => _client.RetrieveInstanceAsync(studyInstanceUid, seriesInstanceUID, sopInstanceUID));
        Assert.Equal(HttpStatusCode.NotFound, exception1.StatusCode);

        DicomWebException exception2 = await Assert.ThrowsAsync<DicomWebException>(() => _client.RetrieveInstanceAsync(studyInstanceUid, seriesInstanceUID, sopInstanceUID/*, requestOriginalVersion: requestOriginalVersion*/));
        Assert.Equal(HttpStatusCode.NotFound, exception2.StatusCode);
    }

    public Task InitializeAsync() => Task.CompletedTask;

    public async Task DisposeAsync()
    {
        await _instancesManager.DisposeAsync();
    }
}
