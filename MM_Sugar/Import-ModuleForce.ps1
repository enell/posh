Function Import-ModuleForce {
<#
.SYNOPSIS
    Import-Module [-Name] <string[]> [-Global] [-Prefix <string>] [-Function <string[]>] [-Cmdlet <string[]>] [-Variable <string[]>] [-Alias <string[]>] [-Force] [-PassThru] [-AsCustomObject] [-MinimumVersion <version>] [-MaximumVersion <string>] [-RequiredVersion <version>] [-ArgumentList <Object[]>] [-DisableNameChecking] [-NoClobber] [-Scope <string>] [<CommonParameters>]

    Import-Module [-Name] <string[]> -PSSession <PSSession> [-Global] [-Prefix <string>] [-Function <string[]>] [-Cmdlet <string[]>] [-Variable <string[]>] [-Alias <string[]>] [-Force] [-PassThru] [-AsCustomObject] [-MinimumVersion <version>] [-MaximumVersion <string>] [-RequiredVersion <version>] [-ArgumentList <Object[]>] [-DisableNameChecking] [-NoClobber] [-Scope <string>] [<CommonParameters>]

    Import-Module [-Name] <string[]> -CimSession <CimSession> [-Global] [-Prefix <string>] [-Function <string[]>] [-Cmdlet <string[]>] [-Variable <string[]>] [-Alias <string[]>] [-Force] [-PassThru] [-AsCustomObject] [-MinimumVersion <version>] [-MaximumVersion <string>] [-RequiredVersion <version>] [-ArgumentList <Object[]>] [-DisableNameChecking] [-NoClobber] [-Scope <string>] [-CimResourceUri <uri>] [-CimNamespace <string>] [<CommonParameters>]

    Import-Module [-FullyQualifiedName] <ModuleSpecification[]> [-Global] [-Prefix <string>] [-Function <string[]>] [-Cmdlet <string[]>] [-Variable <string[]>] [-Alias <string[]>] [-Force] [-PassThru] [-AsCustomObject] [-ArgumentList <Object[]>] [-DisableNameChecking] [-NoClobber] [-Scope <string>] [<CommonParameters>]

    Import-Module [-FullyQualifiedName] <ModuleSpecification[]> -PSSession <PSSession> [-Global] [-Prefix <string>] [-Function <string[]>] [-Cmdlet <string[]>] [-Variable <string[]>] [-Alias <string[]>] [-Force] [-PassThru] [-AsCustomObject] [-ArgumentList <Object[]>] [-DisableNameChecking] [-NoClobber] [-Scope <string>] [<CommonParameters>]

    Import-Module [-Assembly] <Assembly[]> [-Global] [-Prefix <string>] [-Function <string[]>] [-Cmdlet <string[]>] [-Variable <string[]>] [-Alias <string[]>] [-Force] [-PassThru] [-AsCustomObject] [-ArgumentList <Object[]>] [-DisableNameChecking] [-NoClobber] [-Scope <string>] [<CommonParameters>]

    Import-Module [-ModuleInfo] <psmoduleinfo[]> [-Global] [-Prefix <string>] [-Function <string[]>] [-Cmdlet <string[]>] [-Variable <string[]>] [-Alias <string[]>] [-Force] [-PassThru] [-AsCustomObject] [-ArgumentList <Object[]>] [-DisableNameChecking] [-NoClobber] [-Scope <string>] [<CommonParameters>]

#>

<#
You are responsible for implementing the logic for added parameters.  These
parameters are bound to $PSBoundParameters so if you pass them on the the
command you are proxying, it will almost certainly cause an error.  This logic
should be added to your BEGIN statement to remove any specified parameters
from $PSBoundParameters.

In general, the way you are going to implement additional parameters is by
modifying the way you generate the $scriptCmd variable.  Here is an example
of how you would add a -SORTBY parameter to a cmdlet:

        if ($SortBy)
        {
            [Void]$PSBoundParameters.Remove("SortBy")
            $scriptCmd = {& $wrappedCmd @PSBoundParameters |Sort-Object -Property $SortBy}
        }else
        {
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        }

################################################################################
New ATTRIBUTES:
        if ($Force)
        {
            [Void]$PSBoundParameters.Remove(Force)
        }
################################################################################
#>

    [CmdletBinding(DefaultParameterSetName='Name')]
    param(
        [switch]
        ${Global},

        [ValidateNotNull()]
        [string]
        ${Prefix},

        [Parameter(ParameterSetName='PSSession', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='Name', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='CimSession', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]]
        ${Name},

        [Parameter(ParameterSetName='FullyQualifiedName', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='FullyQualifiedNameAndPSSession', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]
        ${FullyQualifiedName},

        [Parameter(ParameterSetName='Assembly', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [System.Reflection.Assembly[]]
        ${Assembly},

        [ValidateNotNull()]
        [string[]]
        ${Function},

        [ValidateNotNull()]
        [string[]]
        ${Cmdlet},

        [ValidateNotNull()]
        [string[]]
        ${Variable},

        [ValidateNotNull()]
        [string[]]
        ${Alias},

        [switch]
        ${Force},

        [switch]
        ${PassThru},

        [switch]
        ${AsCustomObject},

        [Parameter(ParameterSetName='PSSession')]
        [Parameter(ParameterSetName='CimSession')]
        [Parameter(ParameterSetName='Name')]
        [Alias('Version')]
        [version]
        ${MinimumVersion},

        [Parameter(ParameterSetName='PSSession')]
        [Parameter(ParameterSetName='Name')]
        [Parameter(ParameterSetName='CimSession')]
        [string]
        ${MaximumVersion},

        [Parameter(ParameterSetName='CimSession')]
        [Parameter(ParameterSetName='Name')]
        [Parameter(ParameterSetName='PSSession')]
        [version]
        ${RequiredVersion},

        [Parameter(ParameterSetName='ModuleInfo', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [psmoduleinfo[]]
        ${ModuleInfo},

        [Alias('Args')]
        [System.Object[]]
        ${ArgumentList},

        [switch]
        ${DisableNameChecking},

        [Alias('NoOverwrite')]
        [switch]
        ${NoClobber},

        [ValidateSet('Local','Global')]
        [string]
        ${Scope},

        [Parameter(ParameterSetName='PSSession', Mandatory=$true)]
        [Parameter(ParameterSetName='FullyQualifiedNameAndPSSession', Mandatory=$true)]
        [ValidateNotNull()]
        [System.Management.Automation.Runspaces.PSSession]
        ${PSSession},

        [Parameter(ParameterSetName='CimSession', Mandatory=$true)]
        [ValidateNotNull()]
        [Microsoft.Management.Infrastructure.CimSession]
        ${CimSession},

        [Parameter(ParameterSetName='CimSession')]
        [ValidateNotNull()]
        [uri]
        ${CimResourceUri},

        [Parameter(ParameterSetName='CimSession')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CimNamespace})

    begin
    {
        $PSBoundParameters.Force = $true

        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Core\Import-Module', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }

}

sal importf Import-ModuleForce
