// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------

using System.CommandLine;

namespace Microsoft.Health.Dicom.SchemaManager;

public static class CommandOptions
{
    public static Option<string> ConnectionStringOption()
    {
        var connectionStringOption = new Option<string>(
            name: OptionAliases.ConnectionString,
            description: Resources.ConnectionStringOptionDescription)
        {
            Arity = ArgumentArity.ExactlyOne,
            IsRequired = true
        };

        connectionStringOption.AddAlias(OptionAliases.ConnectionStringShort);

        return connectionStringOption;
    }

    public static Option<string> ManagedIdentityClientIdOption()
    {
        var managedIdentityClientIdOption = new Option<string>(
            name: OptionAliases.ManagedIdentityClientId,
            description: Resources.ManagedIdentityClientIdDescription)
        {
            Arity = ArgumentArity.ZeroOrOne
        };

        managedIdentityClientIdOption.AddAlias(OptionAliases.ManagedIdentityClientIdShort);

        return managedIdentityClientIdOption;
    }

    public static Option<string> AuthenticationTypeOption()
    {
        var connectionStringOption = new Option<string>(
            name: OptionAliases.AuthenticationType,
            description: Resources.AuthenticationTypeDescription)
        {
            Arity = ArgumentArity.ZeroOrOne
        };

        connectionStringOption.AddAlias(OptionAliases.AuthenticationTypeShort);

        return connectionStringOption;
    }

    public static Option<string> EnableWorkloadIdentityOptions()
    {
        var enableWorkloadIdentityOptions = new Option<string>(
            name: OptionAliases.EnableWorkloadIdentity,
            description: Resources.EnableWorkloadIdentityDescription)
        {
            Arity = ArgumentArity.ZeroOrOne
        };

        enableWorkloadIdentityOptions.AddAlias(OptionAliases.EnableWorkloadIdentityShort);

        return enableWorkloadIdentityOptions;
    }

    public static Option<int> VersionOption()
    {
        var versionOption = new Option<int>(
            name: OptionAliases.Version,
            description: Resources.VersionOptionDescription)
        {
            Arity = ArgumentArity.ExactlyOne
        };

        versionOption.AddAlias(OptionAliases.VersionShort);

        return versionOption;
    }

    public static Option<bool> NextOption()
    {
        var nextOption = new Option<bool>(
            name: OptionAliases.Next,
            description: Resources.NextOptionDescription)
        {
            Arity = ArgumentArity.ZeroOrOne
        };

        nextOption.AddAlias(OptionAliases.NextShort);

        return nextOption;
    }

    public static Option<bool> LatestOption()
    {
        var latestOption = new Option<bool>(
            name: OptionAliases.Latest,
            description: Resources.LatestOptionDescription)
        {
            Arity = ArgumentArity.ZeroOrOne
        };

        latestOption.AddAlias(OptionAliases.LatestShort);

        return latestOption;
    }

    public static Option<bool> ForceOption()
    {
        var forceOption = new Option<bool>(
            name: OptionAliases.Force,
            description: Resources.ForceOptionDescription)
        {
            Arity = ArgumentArity.ZeroOrOne
        };

        forceOption.AddAlias(OptionAliases.ForceShort);

        return forceOption;
    }
}
