﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using EnsureThat;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Health.Extensions.DependencyInjection;

namespace Microsoft.Health.Dicom.Api.Modules
{
    public class MvcModule : IStartupModule
    {
        public void Load(IServiceCollection services)
        {
            EnsureArg.IsNotNull(services, nameof(services));

            services.AddHttpContextAccessor();

            // These are needed for IUrlResolver used by search.
            // If we update the search implementation to not use these, we should remove
            // the registration since enabling these accessors has performance implications.
            // https://github.com/aspnet/Hosting/issues/793
            services.TryAddSingleton<IActionContextAccessor, ActionContextAccessor>();
        }
    }
}
