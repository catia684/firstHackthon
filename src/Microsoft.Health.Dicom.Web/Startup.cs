﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Microsoft.Health.Dicom.Web
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public virtual void ConfigureServices(IServiceCollection services)
        {
            services.Configure<KestrelServerOptions>(options =>
            {
                options.AllowSynchronousIO = true;
            });

            Core.Registration.IDicomServerBuilder dicomServerBuilder = services.AddDicomServer(Configuration)
                .AddBlobStorageDataStore(Configuration)
                .AddMetadataStorageDataStore(Configuration);

            string dataStore = Configuration["DataStore"];

            if (string.Equals(dataStore, KnownDataStores.CosmosDb, StringComparison.InvariantCultureIgnoreCase))
            {
                dicomServerBuilder.AddCosmosDbIndexingPersistence(Configuration);
            }
            else if (string.Equals(dataStore, KnownDataStores.SqlServer, StringComparison.InvariantCultureIgnoreCase))
            {
                dicomServerBuilder.AddExperimentalSqlServer();
            }

            AddApplicationInsightsTelemetry(services);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public virtual void Configure(IApplicationBuilder app)
        {
            app.UseDicomServer();
        }

        /// <summary>
        /// Adds ApplicationInsights for telemetry and logging.
        /// </summary>
        private void AddApplicationInsightsTelemetry(IServiceCollection services)
        {
            string instrumentationKey = Configuration["ApplicationInsights:InstrumentationKey"];

            if (!string.IsNullOrWhiteSpace(instrumentationKey))
            {
                services.AddApplicationInsightsTelemetry(instrumentationKey);
                services.AddLogging(loggingBuilder => loggingBuilder.AddApplicationInsights(instrumentationKey));
            }
        }
    }
}
