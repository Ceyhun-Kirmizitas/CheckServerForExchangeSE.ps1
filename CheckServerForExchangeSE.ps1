<#
.SYNOPSIS
Checks if a Windows Server is ready for an Exchange Server Subscription Edition (SE) Mailbox role installation.

.DESCRIPTION
CheckServerForExchangeSE.ps1 is a read-only readiness script.
It checks the current Windows Server configuration and reports PASS, BLOCKER, REVIEW, and INFO results.
It does not change Windows or Exchange settings.

The script checks the main items needed before Exchange SE installation, including:
- Windows Server and Windows PowerShell
- Domain, Active Directory, DNS, and forest functional level
- Primary DNS suffix and server FQDN
- Network adapters, IPv4/IPv6, RSS, DNS registration, NIC power saving, NIC Teaming, and packet discards
- Windows Time, pending reboot, CPU, memory, page file, and storage
- NTFS/ReFS and 64 KB allocation unit size on non-system fixed volumes
- .NET Framework, Windows Features, Remote Registry, Visual C++ packages, UCMA 4.0, and IIS URL Rewrite
- TLS/SCHANNEL settings
- Microsoft Defender status and exclusions
- Previous Exchange Setup log detection
- Credential Guard, power plan, regional settings, time zone, and IE ESC

When two or more servers are checked, results are grouped by check by default. The script also compares regional settings and time zone values between servers.

Page file guidance is based on installed RAM. The expected Exchange baseline is a fixed page file with minimum and maximum values set to 25% of installed memory.

For IPv6, the script keeps IPv6 enabled and uses the Microsoft-recommended preference for IPv4 over IPv6 instead of disabling IPv6.
Preferred baseline:
  Registry path : HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters
  Name          : DisabledComponents
  Type          : REG_DWORD
  Decimal       : 32
  Hexadecimal   : 0x20
A restart is required after changing this value. This script does not make the change.

.PARAMETER Server
One or more server names to check. If not specified, the local server is checked.
Remote checks use Windows PowerShell Remoting / WinRM with the current credentials.
If one remote server fails, the script reports the failure and continues with the other servers.

.PARAMETER OutputFile
Optional TXT report path.
For multiple servers, all results are written to one report.
Using this parameter disables console paging.

.PARAMETER GroupBy
Shows results grouped by check.
This is already the default when two or more servers are checked.

.PARAMETER Detailed
Shows results server by server instead of grouping them by check.

.PARAMETER NoPaging
Disables console paging and prints the results continuously.

.PARAMETER Help
Shows the short usage guide and exits.

.EXAMPLE
.\CheckServerForExchangeSE.ps1
Checks the local server.

.EXAMPLE
.\CheckServerForExchangeSE.ps1 -NoPaging
Checks the local server without console paging.

.EXAMPLE
.\CheckServerForExchangeSE.ps1 -OutputFile C:\Temp\ExchangeSE-Readiness.txt
Checks the local server and saves the results to a TXT file.

.EXAMPLE
.\CheckServerForExchangeSE.ps1 -Server EXSE01
Checks one remote server.

.EXAMPLE
.\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02,EXSE03
Checks multiple remote servers. Results are grouped by check by default.

.EXAMPLE
.\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02 -GroupBy
Checks multiple servers and shows grouped results.

.EXAMPLE
.\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02 -Detailed
Checks multiple servers and shows each server separately.

.EXAMPLE
.\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02 -Detailed -NoPaging
Checks multiple servers in detailed view without console paging.

.EXAMPLE
.\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02 -OutputFile C:\Temp\ExchangeSE-Readiness.txt
Checks multiple servers and saves one combined TXT report.

.EXAMPLE
.\CheckServerForExchangeSE.ps1 -Help
Shows the built-in usage guide.

.NOTES
Author  : Ceyhun Kirmizitas

Check my GitHub page for updates and other useful tools:
https://github.com/Ceyhun-Kirmizitas

Version : 1.1
Date    : 26/09/2026
Scope   : Exchange Server Subscription Edition Mailbox server readiness check
Shell   : Windows PowerShell 5.1
Mode    : Read-only

License
-------
MIT License
Copyright (c) 2026 Ceyhun Kirmizitas

Caution
-------
Use this script at your own risk.
Review and test it in your environment before production use.
The author is not responsible for any issues, outages, or data loss resulting from its use.

Design notes
------------
The script is based on practical Exchange 2016 to Exchange SE side-by-side migration work.
It reports environment-specific network and security settings but does not change them.
Regional and time zone differences are also shown when multiple servers are checked.

Microsoft references used by this script:
- Exchange Server 2019 and SE prerequisites:
  https://learn.microsoft.com/en-us/exchange/plan-and-deploy/prerequisites
- Exchange Server 2019 and SE system requirements:
  https://learn.microsoft.com/en-us/exchange/plan-and-deploy/system-requirements
- Exchange Server supportability matrix:
  https://learn.microsoft.com/en-us/exchange/plan-and-deploy/supportability-matrix
- Exchange Server storage configuration options:
  https://learn.microsoft.com/en-us/exchange/plan-and-deploy/deployment-ref/storage-configuration
- Exchange Setup primary DNS suffix readiness:
  https://learn.microsoft.com/en-us/exchange/plan-and-deploy/deployment-ref/ms-exch-setupreadiness-fqdnmissing
- Windows IPv6 configuration guidance:
  https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-ipv6-in-windows
- Windows IE Enhanced Security Configuration:
  https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-ie-esc
- Exchange Server TLS configuration:
  https://learn.microsoft.com/en-us/exchange/plan-and-deploy/post-installation-tasks/security-best-practices/exchange-tls-configuration
- Microsoft CSS-Exchange SetupLogReviewer:
  https://microsoft.github.io/CSS-Exchange/Setup/SetupLogReviewer/
- Running Windows antivirus software on Exchange servers:
  https://learn.microsoft.com/en-us/exchange/antispam-and-antimalware/windows-antivirus-software

Change log
----------
1.1 - 26/09/2026
- Renamed the script to CheckServerForExchangeSE.ps1. The version is now kept inside the script and in Git history/releases.
- Improved error handling. If one check fails, it is reported and the remaining checks continue. A critical server data collection failure stops only that server.
- Removed the final rethrow so unexpected top-level errors are shown as a clear diagnostic message.
- Added active NIC checks for RSS, link speed, MTU, DNS registration, power saving, and Packets Received Discarded.
- Added vmxnet3 awareness when packet discards are detected.
- Added INFO as a result type for information-only checks.
- Added detection of an existing Exchange Setup log and a reference to Microsoft's SetupLogReviewer.
- Added LBFO NIC Teaming information, including mode, load-balancing algorithm, status, and members.
- Added Active Directory DNS checks for DC Locator, Kerberos, Global Catalog, server FQDN, writable DC, and GC.
- Added storage information for physical disk media type, bus type, GPT/MBR, and mapped drive-letter volumes.
- Added TLS/SCHANNEL checks with TLS 1.2 validation and information for TLS 1.0, 1.1, and 1.3.
- Added Microsoft Defender status and exclusion information, plus a reminder to review Exchange exclusions for antivirus, EDR, and application-control products.
- Added Microsoft Visual C++ 2015-2022 x64 as an information-only check.
- Improved remote connection errors. Invoke-Command is used first, and Test-WSMan is used only after a failure for extra diagnostics.
- Improved performance for collection counts, Windows Feature lookup, and installed application lookup.
- Added console paging based on the current window size. Press ENTER to continue or Q to stop paging. Use -NoPaging to disable it.
- Added grouped results for multi-server checks and a -Detailed option for server-by-server output.
- Added a startup banner with author, version, read-only mode, and ENTER confirmation.
- Fixed Country or region detection by using Get-WinHomeLocation.HomeLocation, with GeoId 244 as a fallback for United States.
- Set IE ESC - Administrators to PASS for visibility and kept IE ESC - Users as REVIEW.
- Updated regional check names to match Windows UI wording and added the United States / English (United States) baseline.
- Fixed forest and domain functional level detection by using LDAP RootDSE numeric values.
- Added file system and allocation unit size checks for non-system fixed volumes. NTFS/ReFS are accepted and 64 KB is used as the deployment baseline.
- Updated IPv6 preference checking. 0x20 is the preferred baseline and the Windows default 0x00 is reported as REVIEW.
- Improved multi-server regional and time zone comparison for PowerShell Remoting.
- Fixed installed prerequisite detection when optional registry properties are missing.
- Fixed Windows PowerShell 5.1 variable name conflicts such as PSEdition.
- Improved Windows PowerShell 5.1 compatibility for generic List collections.
- Improved Count handling under StrictMode.
- Added script line and function details for unexpected errors.
- Added more help examples for local, remote, grouped, detailed, paging, and report use.
- Added the GitHub profile URL to the script notes.
- Added MIT license information and a caution note for production use.

1.0 - 23/09/2026
- Created the first version of the Exchange server readiness script.
- Added primary DNS suffix and FQDN checks.
- Added Active Directory forest functional level checks.
- Added Windows Time service and time source information.
- Added CPU socket information based on Exchange hardware guidance.
- Improved prerequisite package detection and version reporting.
- Updated IPv6 checking so the normal Windows default is not reported as a problem.
- Added cross-server regional and time zone comparison.
- Removed hard-coded version labels from reports and console output.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, DontShow = $true)]
    [bool]$InternalLocal = $false,

    [Parameter(Mandatory = $false)]
    [string[]]$Server,

    [Parameter(Mandatory = $false)]
    [string]$OutputFile,

    [Parameter(Mandatory = $false)]
    [switch]$GroupBy,

    [Parameter(Mandatory = $false)]
    [switch]$Detailed,

    [Parameter(Mandatory = $false)]
    [switch]$NoPaging,

    [Parameter(Mandatory = $false)]
    [switch]$Help
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$script:ScriptBaseName = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)

$script:ScriptVersion = '1.1'

if ($Help) {
    @"
CheckServerForExchangeSE.ps1
Exchange Server SE readiness check

COMMON USAGE
  Check the local server:
    .\CheckServerForExchangeSE.ps1

  Check the local server without paging:
    .\CheckServerForExchangeSE.ps1 -NoPaging

  Check the local server and save a TXT report:
    .\CheckServerForExchangeSE.ps1 -OutputFile C:\Temp\ExchangeSE-Readiness.txt

  Check one remote server:
    .\CheckServerForExchangeSE.ps1 -Server EXSE01

  Check multiple servers (grouped by default):
    .\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02

  Show grouped results:
    .\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02 -GroupBy

  Show each server separately:
    .\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02 -Detailed

  Show detailed results without paging:
    .\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02 -Detailed -NoPaging

  Save one combined TXT report:
    .\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02 -OutputFile C:\Temp\ExchangeSE-Readiness.txt

  Show this help:
    .\CheckServerForExchangeSE.ps1 -Help

RESULTS
  PASS     Ready / expected
  BLOCKER  Must be fixed before Exchange installation
  REVIEW   Needs review for this environment
  INFO     Information only

NOTES
  - The script is read-only and does not change Windows or Exchange settings.
  - Remote checks use PowerShell Remoting / WinRM.
  - Two or more servers are grouped by check by default. Use -Detailed for server-by-server output.
  - Console output pauses about once per screen. Press ENTER to continue or Q to stop paging.
  - Use -NoPaging to print continuously. Paging is also disabled when -OutputFile is used.
  - Full help:
      Get-Help .\CheckServerForExchangeSE.ps1 -Full
"@ | Write-Host
    return
}

# Exchange SE Mailbox role Windows Features from current Microsoft prerequisites.
$script:DesktopExperienceFeatures = @(
    'Server-Media-Foundation',
    'NET-Framework-45-Core',
    'NET-Framework-45-ASPNET',
    'NET-WCF-HTTP-Activation45',
    'NET-WCF-Pipe-Activation45',
    'NET-WCF-TCP-Activation45',
    'NET-WCF-TCP-PortSharing45',
    'RPC-over-HTTP-proxy',
    'RSAT-Clustering',
    'RSAT-Clustering-CmdInterface',
    'RSAT-Clustering-Mgmt',
    'RSAT-Clustering-PowerShell',
    'WAS-Process-Model',
    'Web-Asp-Net45',
    'Web-Basic-Auth',
    'Web-Client-Auth',
    'Web-Digest-Auth',
    'Web-Dir-Browsing',
    'Web-Dyn-Compression',
    'Web-Http-Errors',
    'Web-Http-Logging',
    'Web-Http-Redirect',
    'Web-Http-Tracing',
    'Web-ISAPI-Ext',
    'Web-ISAPI-Filter',
    'Web-Metabase',
    'Web-Mgmt-Console',
    'Web-Mgmt-Service',
    'Web-Net-Ext45',
    'Web-Request-Monitor',
    'Web-Server',
    'Web-Stat-Compression',
    'Web-Static-Content',
    'Web-Windows-Auth',
    'Web-WMI',
    'Windows-Identity-Foundation',
    'RSAT-ADDS'
)

$script:ServerCoreFeatures = @(
    'Server-Media-Foundation',
    'NET-Framework-45-Core',
    'NET-Framework-45-ASPNET',
    'NET-WCF-HTTP-Activation45',
    'NET-WCF-Pipe-Activation45',
    'NET-WCF-TCP-Activation45',
    'NET-WCF-TCP-PortSharing45',
    'RPC-over-HTTP-proxy',
    'RSAT-Clustering',
    'RSAT-Clustering-CmdInterface',
    'RSAT-Clustering-PowerShell',
    'WAS-Process-Model',
    'Web-Asp-Net45',
    'Web-Basic-Auth',
    'Web-Client-Auth',
    'Web-Digest-Auth',
    'Web-Dir-Browsing',
    'Web-Dyn-Compression',
    'Web-Http-Errors',
    'Web-Http-Logging',
    'Web-Http-Redirect',
    'Web-Http-Tracing',
    'Web-ISAPI-Ext',
    'Web-ISAPI-Filter',
    'Web-Metabase',
    'Web-Mgmt-Service',
    'Web-Net-Ext45',
    'Web-Request-Monitor',
    'Web-Server',
    'Web-Stat-Compression',
    'Web-Static-Content',
    'Web-Windows-Auth',
    'Web-WMI',
    'RSAT-ADDS'
)

# ---------------------------------------------------------------------------
# Generic helpers
# ---------------------------------------------------------------------------
function Test-IsAdministrator {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch { return $false }
}

function ConvertTo-DisplayText {
    param($Value)

    if ($null -eq $Value) { return '<Not Set>' }
    if ($Value -is [System.Array]) {
        if ((Get-SafeCount $Value) -eq 0) { return '<None>' }
        return (@($Value | ForEach-Object { [string]$_ }) -join ', ')
    }
    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) { return '<Empty>' }
    return $text
}

function Get-SafeCount {
    param($Value)

    if ($null -eq $Value) { return 0 }
    if ($Value -is [string]) { return 1 }
    if ($Value -is [System.Collections.ICollection]) { return [int]$Value.Count }

    # Most scalar PowerShell objects are a single item. Avoid Measure-Object here
    # because this helper is called repeatedly throughout the readiness checks.
    return 1
}

function New-CheckResult {
    param(
        [Parameter(Mandatory = $true)][string]$Category,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][ValidateSet('PASS','BLOCKER','REVIEW','INFO')][string]$Status,
        $Current,
        $Expected,
        [string]$Message = ''
    )

    [PSCustomObject]@{
        Category = $Category
        Name     = $Name
        Status   = $Status
        Current  = ConvertTo-DisplayText $Current
        Expected = ConvertTo-DisplayText $Expected
        Message  = $Message
    }
}

function Resolve-OutputFilePath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $expanded = [Environment]::ExpandEnvironmentVariables($Path)
    if (-not [System.IO.Path]::IsPathRooted($expanded)) {
        $expanded = Join-Path (Get-Location).Path $expanded
    }

    $directory = Split-Path -Parent $expanded
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    return [System.IO.Path]::GetFullPath($expanded)
}

function Get-InstalledApplications {
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    $items = New-Object System.Collections.Generic.List[object]

    foreach ($path in $paths) {
        $registryItems = @()
        try {
            $registryItems = @(Get-ItemProperty -Path $path -ErrorAction Stop)
        }
        catch {
            continue
        }

        foreach ($item in $registryItems) {
            # Under StrictMode, many uninstall keys do not expose every optional
            # property (for example DisplayVersion or Publisher). Read optional
            # properties through PSObject.Properties so one incomplete registry
            # key cannot abort enumeration of the whole uninstall branch.
            $displayNameProperty = $item.PSObject.Properties['DisplayName']
            if ($null -eq $displayNameProperty) { continue }

            $displayName = [string]$displayNameProperty.Value
            if ([string]::IsNullOrWhiteSpace($displayName)) { continue }

            $displayVersionProperty = $item.PSObject.Properties['DisplayVersion']
            $publisherProperty = $item.PSObject.Properties['Publisher']
            $uninstallKeyProperty = $item.PSObject.Properties['PSChildName']

            [void]$items.Add([PSCustomObject]@{
                DisplayName    = $displayName
                DisplayVersion = if ($null -ne $displayVersionProperty) { [string]$displayVersionProperty.Value } else { '' }
                Publisher      = if ($null -ne $publisherProperty) { [string]$publisherProperty.Value } else { '' }
                UninstallKey   = if ($null -ne $uninstallKeyProperty) { [string]$uninstallKeyProperty.Value } else { '' }
            })
        }
    }

    return $items.ToArray()
}

function Get-InstalledApplicationText {
    param(
        [AllowNull()][AllowEmptyCollection()]$Applications,
        [Parameter(Mandatory = $true)][string]$Pattern
    )

    $appMatches = @(
        $Applications |
            Where-Object { $_.DisplayName -match $Pattern } |
            Sort-Object DisplayName,DisplayVersion -Unique
    )

    if ((Get-SafeCount $appMatches) -eq 0) { return $null }

    return (($appMatches | ForEach-Object {
        if ([string]::IsNullOrWhiteSpace([string]$_.DisplayVersion)) {
            [string]$_.DisplayName
        }
        else {
            "{0} [{1}]" -f $_.DisplayName,$_.DisplayVersion
        }
    }) -join '; ')
}

function Get-InstalledApplicationCache {
    param([AllowNull()][AllowEmptyCollection()]$Applications)

    # Build the prerequisite/application view once so evaluation does not rescan
    # the uninstall registry list for every individual check.
    [PSCustomObject]@{
        VC2012       = Get-InstalledApplicationText -Applications $Applications -Pattern 'Microsoft Visual C\+\+ 2012.*x64'
        VC2013       = Get-InstalledApplicationText -Applications $Applications -Pattern 'Microsoft Visual C\+\+ 2013.*x64'
        VC2015To2022 = Get-InstalledApplicationText -Applications $Applications -Pattern 'Microsoft Visual C\+\+ (2015-2022|2015|2017|2019|2022).*x64'
        UCMA40       = Get-InstalledApplicationText -Applications $Applications -Pattern 'Unified Communications Managed API 4\.0|UCMA 4\.0'
        URLRewrite   = Get-InstalledApplicationText -Applications $Applications -Pattern 'IIS URL Rewrite Module|URL Rewrite Module'
    }
}

function ConvertTo-ADFunctionalLevelName {
    param(
        [Parameter(Mandatory = $true)][int]$Level,
        [Parameter(Mandatory = $true)][ValidateSet('Forest','Domain')][string]$Scope
    )

    $baseName = switch ($Level) {
        0 { 'Windows2000' }
        1 { 'Windows2003Interim' }
        2 { 'Windows2003' }
        3 { 'Windows2008' }
        4 { 'Windows2008R2' }
        5 { 'Windows2012' }
        6 { 'Windows2012R2' }
        7 { 'Windows2016' }
        default { "UnknownLevel$Level" }
    }

    return "{0}{1}" -f $baseName,$Scope
}

function Get-ADFunctionalLevelInfo {
    $forestMode = $null
    $domainMode = $null
    $forestLevel = $null
    $domainLevel = $null
    $forestDnsName = $null
    $errorText = $null

    try {
        # Query RootDSE directly instead of relying on the legacy .NET ForestMode/DomainMode enums.
        # RootDSE exposes the numeric AD functional levels and works without the ActiveDirectory PowerShell module.
        $rootDse = [ADSI]'LDAP://RootDSE'

        $forestProperty = $rootDse.Properties['forestFunctionality']
        $domainProperty = $rootDse.Properties['domainFunctionality']
        $rootDomainNamingContextProperty = $rootDse.Properties['rootDomainNamingContext']

        if ($null -ne $forestProperty -and (Get-SafeCount $forestProperty) -gt 0) {
            $forestLevel = [int]$forestProperty[0]
            $forestMode = ConvertTo-ADFunctionalLevelName -Level $forestLevel -Scope Forest
        }

        if ($null -ne $domainProperty -and (Get-SafeCount $domainProperty) -gt 0) {
            $domainLevel = [int]$domainProperty[0]
            $domainMode = ConvertTo-ADFunctionalLevelName -Level $domainLevel -Scope Domain
        }

        if ($null -ne $rootDomainNamingContextProperty -and (Get-SafeCount $rootDomainNamingContextProperty) -gt 0) {
            $rootDomainNamingContext = [string]$rootDomainNamingContextProperty[0]
            $forestDnsParts = @($rootDomainNamingContext -split ',' | Where-Object { $_ -match '(?i)^DC=' } | ForEach-Object { $_ -replace '(?i)^DC=','' })
            if ((Get-SafeCount $forestDnsParts) -gt 0) { $forestDnsName = ($forestDnsParts -join '.') }
        }

        if ($null -eq $forestLevel) {
            $errorText = 'RootDSE did not return forestFunctionality.'
        }
    }
    catch {
        $errorText = $_.Exception.Message
    }

    [PSCustomObject]@{
        ForestMode  = $forestMode
        ForestLevel = $forestLevel
        DomainMode  = $domainMode
        DomainLevel = $domainLevel
        ForestDnsName = $forestDnsName
        Error       = $errorText
        Source      = 'LDAP RootDSE'
    }
}

function Get-TimeSyncInfo {
    $serviceState = 'Unknown'
    $source = $null
    $errorText = $null

    try {
        $service = Get-CimInstance Win32_Service -Filter "Name='W32Time'" -ErrorAction Stop
        $serviceState = "{0} / {1}" -f $service.StartMode,$service.State
    }
    catch {
        $errorText = $_.Exception.Message
    }

    try {
        $sourceOutput = @(& w32tm.exe /query /source 2>&1)
        if ($LASTEXITCODE -eq 0 -and (Get-SafeCount $sourceOutput) -gt 0) {
            $source = (($sourceOutput | ForEach-Object { [string]$_ }) -join ' ').Trim()
        }
        elseif ([string]::IsNullOrWhiteSpace($errorText)) {
            $errorText = (($sourceOutput | ForEach-Object { [string]$_ }) -join ' ').Trim()
        }
    }
    catch {
        if ([string]::IsNullOrWhiteSpace($errorText)) {
            $errorText = $_.Exception.Message
        }
    }

    [PSCustomObject]@{
        ServiceState = $serviceState
        Source       = $source
        Error        = $errorText
    }
}

function Get-DotNetFrameworkInfo {
    $release = $null
    try {
        $release = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release -ErrorAction Stop).Release
    }
    catch { }

    $version = 'Not detected'
    if ($null -ne $release) {
        if ([int64]$release -ge 533320) { $version = '4.8.1' }
        elseif ([int64]$release -ge 528040) { $version = '4.8' }
        else { $version = "Pre-4.8 (Release $release)" }
    }

    [PSCustomObject]@{
        Release = $release
        Version = $version
    }
}

function Get-PendingRebootInfo {
    $reasons = New-Object System.Collections.Generic.List[string]

    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') {
        [void]$reasons.Add('Component Based Servicing')
    }
    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') {
        [void]$reasons.Add('Windows Update')
    }
    try {
        $sessionManager = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction Stop
        if ($null -ne $sessionManager.PendingFileRenameOperations) { [void]$reasons.Add('Pending File Rename Operations') }
    }
    catch { }
    try {
        $computerName = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' -ErrorAction Stop
        $activeName = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' -ErrorAction Stop
        if ([string]$computerName.ComputerName -ne [string]$activeName.ComputerName) { [void]$reasons.Add('Computer rename') }
    }
    catch { }

    [PSCustomObject]@{
        Pending = ((Get-SafeCount $reasons) -gt 0)
        Reasons = $reasons.ToArray()
    }
}

function Get-PowerPlanInfo {
    try {
        $text = (& powercfg.exe /GetActiveScheme 2>$null | Out-String).Trim()
        $guid = $null
        $name = $text
        if ($text -match '([0-9a-fA-F-]{36})') { $guid = $matches[1].ToLowerInvariant() }
        if ($text -match '\(([^)]+)\)') { $name = $matches[1] }
        return [PSCustomObject]@{ Name = $name; Guid = $guid; Raw = $text }
    }
    catch {
        return [PSCustomObject]@{ Name = 'Unknown'; Guid = $null; Raw = $_.Exception.Message }
    }
}

function Get-ActiveDirectorySiteInfo {
    $site = $null
    $dc = $null
    $gc = $null
    $siteError = $null
    $dcError = $null

    try {
        $siteOutput = @(& nltest.exe /dsgetsite 2>&1)
        if ($LASTEXITCODE -eq 0 -and (Get-SafeCount $siteOutput) -gt 0) {
            $site = ([string]$siteOutput[0]).Trim()
        }
        else { $siteError = ($siteOutput -join ' ').Trim() }
    }
    catch { $siteError = $_.Exception.Message }

    try {
        $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        if ($cs.PartOfDomain -and -not [string]::IsNullOrWhiteSpace([string]$cs.Domain)) {
            $dcOutput = @(& nltest.exe "/dsgetdc:$($cs.Domain)" /WRITABLE 2>&1)
            if ($LASTEXITCODE -eq 0) {
                $dcLine = @($dcOutput | Where-Object { [string]$_ -match '(?i)DC:' } | Select-Object -First 1)
                if ((Get-SafeCount $dcLine) -gt 0) { $dc = ([string]$dcLine[0] -replace '^\s*DC:\s*','').Trim('\ ') }
            }
            else { $dcError = ($dcOutput -join ' ').Trim() }

            $gcOutput = @(& nltest.exe "/dsgetdc:$($cs.Domain)" /GC /WRITABLE 2>&1)
            if ($LASTEXITCODE -eq 0) {
                $gcLine = @($gcOutput | Where-Object { [string]$_ -match '(?i)DC:' } | Select-Object -First 1)
                if ((Get-SafeCount $gcLine) -gt 0) { $gc = ([string]$gcLine[0] -replace '^\s*DC:\s*','').Trim('\ ') }
            }
        }
    }
    catch { $dcError = $_.Exception.Message }

    [PSCustomObject]@{
        Site      = $site
        DC        = $dc
        GC        = $gc
        SiteError = $siteError
        DCError   = $dcError
    }
}

function Invoke-DnsReadinessLookup {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][ValidateSet('Host','SRV')][string]$LookupType
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        return [PSCustomObject]@{ Name = $Name; Type = $LookupType; Success = $false; Values = @(); Error = 'DNS name is empty.' }
    }

    try {
        if ($LookupType -eq 'SRV') {
            $records = @(Resolve-DnsName -Name $Name -Type SRV -DnsOnly -ErrorAction Stop)
            $values = @($records | Where-Object { $_.PSObject.Properties['NameTarget'] -and $_.NameTarget } | ForEach-Object { ([string]$_.NameTarget).TrimEnd('.') } | Select-Object -Unique)
        }
        else {
            $records = @(Resolve-DnsName -Name $Name -DnsOnly -ErrorAction Stop)
            $values = @($records | Where-Object { $_.PSObject.Properties['IPAddress'] -and $_.IPAddress } | ForEach-Object { [string]$_.IPAddress } | Select-Object -Unique)
        }

        return [PSCustomObject]@{
            Name    = $Name
            Type    = $LookupType
            Success = ((Get-SafeCount $values) -gt 0)
            Values  = $values
            Error   = if ((Get-SafeCount $values) -gt 0) { '' } else { 'DNS query returned no usable records.' }
        }
    }
    catch {
        return [PSCustomObject]@{ Name = $Name; Type = $LookupType; Success = $false; Values = @(); Error = $_.Exception.Message }
    }
}

function Get-DnsReadinessInfo {
    param(
        [string]$ComputerName,
        [string]$PrimaryDnsSuffix,
        [string]$DomainName,
        [string]$ForestDnsName,
        [string]$WritableDC,
        [string]$GlobalCatalog
    )

    $serverFqdn = if (-not [string]::IsNullOrWhiteSpace($PrimaryDnsSuffix)) { "{0}.{1}" -f $ComputerName,$PrimaryDnsSuffix } else { $null }
    $dcSrvName = if (-not [string]::IsNullOrWhiteSpace($DomainName)) { "_ldap._tcp.dc._msdcs.{0}" -f $DomainName } else { $null }
    $kerberosSrvName = if (-not [string]::IsNullOrWhiteSpace($DomainName)) { "_kerberos._tcp.{0}" -f $DomainName } else { $null }
    $gcDnsName = if (-not [string]::IsNullOrWhiteSpace($ForestDnsName)) { $ForestDnsName } else { $DomainName }
    $gcSrvName = if (-not [string]::IsNullOrWhiteSpace($gcDnsName)) { "_ldap._tcp.gc._msdcs.{0}" -f $gcDnsName } else { $null }

    [PSCustomObject]@{
        ServerFqdn = if ($serverFqdn) { Invoke-DnsReadinessLookup -Name $serverFqdn -LookupType Host } else { [PSCustomObject]@{ Name=''; Type='Host'; Success=$false; Values=@(); Error='Primary DNS suffix is missing.' } }
        DcSrv      = if ($dcSrvName) { Invoke-DnsReadinessLookup -Name $dcSrvName -LookupType SRV } else { [PSCustomObject]@{ Name=''; Type='SRV'; Success=$false; Values=@(); Error='Domain name is unavailable.' } }
        KerberosSrv = if ($kerberosSrvName) { Invoke-DnsReadinessLookup -Name $kerberosSrvName -LookupType SRV } else { [PSCustomObject]@{ Name=''; Type='SRV'; Success=$false; Values=@(); Error='Domain name is unavailable.' } }
        GcSrv      = if ($gcSrvName) { Invoke-DnsReadinessLookup -Name $gcSrvName -LookupType SRV } else { [PSCustomObject]@{ Name=''; Type='SRV'; Success=$false; Values=@(); Error='Forest DNS name is unavailable.' } }
        WritableDC = if (-not [string]::IsNullOrWhiteSpace($WritableDC)) { Invoke-DnsReadinessLookup -Name $WritableDC -LookupType Host } else { [PSCustomObject]@{ Name=''; Type='Host'; Success=$false; Values=@(); Error='Writable DC was not discovered.' } }
        GlobalCatalog = if (-not [string]::IsNullOrWhiteSpace($GlobalCatalog)) { Invoke-DnsReadinessLookup -Name $GlobalCatalog -LookupType Host } else { [PSCustomObject]@{ Name=''; Type='Host'; Success=$false; Values=@(); Error='Global Catalog was not discovered.' } }
    }
}

function Get-NicTeamingInfo {
    $available = $false
    $errorText = $null
    $teams = New-Object System.Collections.Generic.List[object]

    try {
        $available = ($null -ne (Get-Command Get-NetLbfoTeam -ErrorAction SilentlyContinue))
        if ($available) {
            foreach ($team in @(Get-NetLbfoTeam -ErrorAction Stop)) {
                $members = @()
                try {
                    if ($null -ne (Get-Command Get-NetLbfoTeamMember -ErrorAction SilentlyContinue)) {
                        $members = @(Get-NetLbfoTeamMember -Team $team -ErrorAction Stop | ForEach-Object { [string]$_.Name })
                    }
                }
                catch { }

                [void]$teams.Add([PSCustomObject]@{
                    Name                   = [string]$team.Name
                    Status                 = [string]$team.Status
                    TeamingMode            = [string]$team.TeamingMode
                    LoadBalancingAlgorithm = [string]$team.LoadBalancingAlgorithm
                    Members                = $members
                })
            }
        }
    }
    catch {
        $errorText = $_.Exception.Message
    }

    [PSCustomObject]@{
        CmdletAvailable = $available
        Teams           = $teams.ToArray()
        Error           = $errorText
    }
}

function Get-SchannelProtocolRoleInfo {
    param(
        [Parameter(Mandatory = $true)][string]$Protocol,
        [Parameter(Mandatory = $true)][ValidateSet('Client','Server')][string]$Role
    )

    $path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{0}\{1}" -f $Protocol,$Role
    $enabled = $null
    $disabledByDefault = $null
    $configured = Test-Path -LiteralPath $path

    if ($configured) {
        try {
            $item = Get-ItemProperty -LiteralPath $path -ErrorAction Stop
            $enabledProperty = $item.PSObject.Properties['Enabled']
            $disabledProperty = $item.PSObject.Properties['DisabledByDefault']
            if ($null -ne $enabledProperty) { $enabled = [int]$enabledProperty.Value }
            if ($null -ne $disabledProperty) { $disabledByDefault = [int]$disabledProperty.Value }
        }
        catch { }
    }

    $state = 'OS default / not explicitly configured'
    if ($enabled -eq 0 -or $disabledByDefault -eq 1) {
        $state = 'Disabled'
    }
    elseif ($enabled -eq 1) {
        $state = 'Enabled'
    }
    elseif ($disabledByDefault -eq 0) {
        $state = 'Not disabled by default'
    }

    [PSCustomObject]@{
        Protocol          = $Protocol
        Role              = $Role
        RegistryPath      = $path
        Configured        = [bool]$configured
        Enabled           = $enabled
        DisabledByDefault = $disabledByDefault
        State             = $state
    }
}

function Get-TlsBaselineInfo {
    $items = New-Object System.Collections.Generic.List[object]
    foreach ($protocol in @('TLS 1.0','TLS 1.1','TLS 1.2','TLS 1.3')) {
        foreach ($role in @('Client','Server')) {
            [void]$items.Add((Get-SchannelProtocolRoleInfo -Protocol $protocol -Role $role))
        }
    }
    return $items.ToArray()
}

function Get-AntimalwareInfo {
    $statusAvailable = ($null -ne (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue))
    $preferenceAvailable = ($null -ne (Get-Command Get-MpPreference -ErrorAction SilentlyContinue))
    $statusError = $null
    $preferenceError = $null
    $status = $null
    $preference = $null

    if ($statusAvailable) {
        try { $status = Get-MpComputerStatus -ErrorAction Stop } catch { $statusError = $_.Exception.Message }
    }
    if ($preferenceAvailable) {
        try { $preference = Get-MpPreference -ErrorAction Stop } catch { $preferenceError = $_.Exception.Message }
    }

    $paths = @()
    $processes = @()
    $extensions = @()
    if ($null -ne $preference) {
        if ($preference.PSObject.Properties['ExclusionPath'] -and $null -ne $preference.ExclusionPath) { $paths = @($preference.ExclusionPath) }
        if ($preference.PSObject.Properties['ExclusionProcess'] -and $null -ne $preference.ExclusionProcess) { $processes = @($preference.ExclusionProcess) }
        if ($preference.PSObject.Properties['ExclusionExtension'] -and $null -ne $preference.ExclusionExtension) { $extensions = @($preference.ExclusionExtension) }
    }

    [PSCustomObject]@{
        StatusCmdletAvailable     = $statusAvailable
        PreferenceCmdletAvailable = $preferenceAvailable
        AMServiceEnabled          = if ($null -ne $status -and $status.PSObject.Properties['AMServiceEnabled']) { [bool]$status.AMServiceEnabled } else { $null }
        AntivirusEnabled          = if ($null -ne $status -and $status.PSObject.Properties['AntivirusEnabled']) { [bool]$status.AntivirusEnabled } else { $null }
        RealTimeProtectionEnabled = if ($null -ne $status -and $status.PSObject.Properties['RealTimeProtectionEnabled']) { [bool]$status.RealTimeProtectionEnabled } else { $null }
        ExclusionPaths            = $paths
        ExclusionProcesses        = $processes
        ExclusionExtensions       = $extensions
        StatusError               = $statusError
        PreferenceError           = $preferenceError
    }
}

function Get-ExchangeSetupHistoryInfo {
    $path = Join-Path $env:SystemDrive 'ExchangeSetupLogs\ExchangeSetup.log'
    try {
        if (Test-Path -LiteralPath $path) {
            $item = Get-Item -LiteralPath $path -ErrorAction Stop
            return [PSCustomObject]@{
                Exists        = $true
                Path          = $path
                LastWriteTime = $item.LastWriteTime
                LengthBytes   = [int64]$item.Length
                Error         = ''
            }
        }
        return [PSCustomObject]@{ Exists = $false; Path = $path; LastWriteTime = $null; LengthBytes = 0; Error = '' }
    }
    catch {
        return [PSCustomObject]@{ Exists = $false; Path = $path; LastWriteTime = $null; LengthBytes = 0; Error = $_.Exception.Message }
    }
}

function Get-PhysicalDiskInventory {
    $items = New-Object System.Collections.Generic.List[object]
    $errorText = $null

    try {
        if ($null -ne (Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue)) {
            foreach ($disk in @(Get-PhysicalDisk -ErrorAction Stop)) {
                $mediaTypeProperty = $disk.PSObject.Properties['MediaType']
                $busTypeProperty = $disk.PSObject.Properties['BusType']
                $friendlyNameProperty = $disk.PSObject.Properties['FriendlyName']
                $healthProperty = $disk.PSObject.Properties['HealthStatus']
                $sizeProperty = $disk.PSObject.Properties['Size']
                [void]$items.Add([PSCustomObject]@{
                    FriendlyName = if ($null -ne $friendlyNameProperty) { [string]$friendlyNameProperty.Value } else { '<Unknown>' }
                    MediaType    = if ($null -ne $mediaTypeProperty) { [string]$mediaTypeProperty.Value } else { 'Unspecified' }
                    BusType      = if ($null -ne $busTypeProperty) { [string]$busTypeProperty.Value } else { 'Unspecified' }
                    HealthStatus = if ($null -ne $healthProperty) { [string]$healthProperty.Value } else { '<Unknown>' }
                    SizeGB       = if ($null -ne $sizeProperty -and $sizeProperty.Value) { [math]::Round([int64]$sizeProperty.Value / 1GB, 1) } else { 0 }
                })
            }
        }
    }
    catch { $errorText = $_.Exception.Message }

    [PSCustomObject]@{
        Disks = $items.ToArray()
        Error = $errorText
    }
}

function Get-NicPowerManagementInfo {
    param(
        [Parameter(Mandatory = $true)]
        $Adapter
    )

    $adapterName = if ($Adapter.PSObject.Properties['Name']) { [string]$Adapter.Name } else { '' }
    $driverFileName = if ($Adapter.PSObject.Properties['DriverFileName']) { [string]$Adapter.DriverFileName } else { '' }

    # LBFO multiplexor adapters do not expose a meaningful per-device PnP power setting.
    if ($driverFileName -eq 'NdIsImPlatform.sys') {
        return [PSCustomObject]@{
            State          = 'Unsupported'
            Source         = 'LBFO multiplexor adapter'
            PnPCapabilities = $null
            Error          = ''
        }
    }

    try {
        if ($null -ne (Get-Command Get-NetAdapterPowerManagement -ErrorAction SilentlyContinue)) {
            $power = $Adapter | Get-NetAdapterPowerManagement -ErrorAction Stop
            if ($null -ne $power -and $power.PSObject.Properties['AllowComputerToTurnOffDevice']) {
                $value = [string]$power.AllowComputerToTurnOffDevice
                if (-not [string]::IsNullOrWhiteSpace($value)) {
                    return [PSCustomObject]@{
                        State          = $value
                        Source         = 'Get-NetAdapterPowerManagement'
                        PnPCapabilities = $null
                        Error          = ''
                    }
                }
            }
        }
    }
    catch {
        # Fall back to the same PnPCapabilities approach used by Microsoft CSS-Exchange HealthChecker.
    }

    $deviceId = if ($Adapter.PSObject.Properties['DeviceID']) { [string]$Adapter.DeviceID } else { '' }
    if ([string]::IsNullOrWhiteSpace($deviceId)) {
        return [PSCustomObject]@{
            State          = 'Unknown'
            Source         = 'PnPCapabilities fallback'
            PnPCapabilities = $null
            Error          = 'Adapter DeviceID is not available.'
        }
    }

    $basePath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}'
    try {
        foreach ($key in @(Get-ChildItem -LiteralPath $basePath -ErrorAction Stop | Where-Object { $_.PSChildName -match '^\d{4}$' })) {
            $properties = Get-ItemProperty -LiteralPath $key.PSPath -ErrorAction SilentlyContinue
            if ($null -eq $properties) { continue }

            $netCfgProperty = $properties.PSObject.Properties['NetCfgInstanceId']
            if ($null -eq $netCfgProperty -or [string]$netCfgProperty.Value -ne $deviceId) { continue }

            $pnpProperty = $properties.PSObject.Properties['PnPCapabilities']
            if ($null -eq $pnpProperty -or $null -eq $pnpProperty.Value) {
                return [PSCustomObject]@{
                    State          = 'Unsupported'
                    Source         = 'PnPCapabilities'
                    PnPCapabilities = $null
                    Error          = ''
                }
            }

            $pnpValue = [int]$pnpProperty.Value
            return [PSCustomObject]@{
                State          = if ($pnpValue -eq 24 -or $pnpValue -eq 280) { 'Disabled' } else { 'Enabled' }
                Source         = 'PnPCapabilities'
                PnPCapabilities = $pnpValue
                Error          = ''
            }
        }

        return [PSCustomObject]@{
            State          = 'Unknown'
            Source         = 'PnPCapabilities fallback'
            PnPCapabilities = $null
            Error          = 'Matching NIC registry entry was not found.'
        }
    }
    catch {
        return [PSCustomObject]@{
            State          = 'Unknown'
            Source         = 'PnPCapabilities fallback'
            PnPCapabilities = $null
            Error          = $_.Exception.Message
        }
    }
}

function Get-NetworkSummary {
    $items = New-Object System.Collections.Generic.List[object]

    $discardCounters = @()
    try {
        # CIM performance data avoids localized performance-counter names.
        $discardCounters = @(Get-CimInstance Win32_PerfFormattedData_Tcpip_NetworkInterface -ErrorAction Stop)
    }
    catch { }

    try {
        # Include active team/vNIC interfaces too. -Physical can hide the interface that actually owns the server IP configuration.
        $adapters = @(Get-NetAdapter -ErrorAction Stop | Where-Object { $_.Status -eq 'Up' })
        foreach ($adapter in $adapters) {
            $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.ifIndex -ErrorAction SilentlyContinue
            $ipv4Binding = Get-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip -ErrorAction SilentlyContinue
            $ipv6Binding = Get-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
            $ipv4If = Get-NetIPInterface -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            $dnsClient = Get-DnsClient -InterfaceIndex $adapter.ifIndex -ErrorAction SilentlyContinue

            $ipv4 = @()
            $ipv6 = @()
            $gateway = @()
            $dnsServers = @()
            $dnsSuffix = $null
            if ($ipConfig) {
                $ipv4 = @($ipConfig.IPv4Address | ForEach-Object { $_.IPAddress })
                $ipv6 = @($ipConfig.IPv6Address | Where-Object { $_.IPAddress -notlike 'fe80:*' } | ForEach-Object { $_.IPAddress })
                $gateway = @($ipConfig.IPv4DefaultGateway | ForEach-Object { $_.NextHop })
                if ($ipConfig.DNSServer) { $dnsServers = @($ipConfig.DNSServer.ServerAddresses) }
                if ($dnsClient) { $dnsSuffix = [string]$dnsClient.ConnectionSpecificSuffix }
            }

            $description = if ($adapter.PSObject.Properties['InterfaceDescription']) { [string]$adapter.InterfaceDescription } else { [string]$adapter.Name }
            $linkSpeed = if ($adapter.PSObject.Properties['LinkSpeed']) { [string]$adapter.LinkSpeed } else { '<Unknown>' }
            $mtu = if ($null -ne $ipv4If -and $ipv4If.PSObject.Properties['NlMtuBytes']) { [int]$ipv4If.NlMtuBytes } else { $null }
            $registeredInDns = if ($null -ne $dnsClient -and $dnsClient.PSObject.Properties['RegisterThisConnectionsAddress']) { [bool]$dnsClient.RegisterThisConnectionsAddress } else { $null }

            $rssSupported = $false
            $rssEnabled = $null
            $rssMaxProcessors = $null
            $rssMaxProcessorNumber = $null
            $rssQueues = $null
            $rssError = ''
            try {
                if ($null -ne (Get-Command Get-NetAdapterRss -ErrorAction SilentlyContinue)) {
                    $rss = $adapter | Get-NetAdapterRss -ErrorAction Stop
                    if ($null -ne $rss) {
                        $rssSupported = $true
                        if ($rss.PSObject.Properties['Enabled']) { $rssEnabled = [bool]$rss.Enabled }
                        if ($rss.PSObject.Properties['MaxProcessors']) { $rssMaxProcessors = $rss.MaxProcessors }
                        if ($rss.PSObject.Properties['MaxProcessorNumber']) { $rssMaxProcessorNumber = $rss.MaxProcessorNumber }
                        if ($rss.PSObject.Properties['NumberOfReceiveQueues']) { $rssQueues = $rss.NumberOfReceiveQueues }
                    }
                }
                else {
                    $rssError = 'Get-NetAdapterRss cmdlet not available.'
                }
            }
            catch {
                $rssError = $_.Exception.Message
            }

            $powerManagement = Get-NicPowerManagementInfo -Adapter $adapter

            $packetsReceivedDiscarded = $null
            $discardCounterFound = $false
            foreach ($counter in $discardCounters) {
                $counterName = if ($counter.PSObject.Properties['Name']) { [string]$counter.Name } else { '' }
                $possibleDescription = $description.Replace('#','_')
                if ($counterName -eq $description -or $counterName -eq $possibleDescription -or $counterName -eq [string]$adapter.Name) {
                    if ($counter.PSObject.Properties['PacketsReceivedDiscarded']) {
                        $packetsReceivedDiscarded = [int64]$counter.PacketsReceivedDiscarded
                        $discardCounterFound = $true
                    }
                    break
                }
            }

            [void]$items.Add([PSCustomObject]@{
                Name                     = [string]$adapter.Name
                Description              = $description
                InterfaceIndex           = $adapter.ifIndex
                MacAddress               = $adapter.MacAddress
                LinkSpeed                = $linkSpeed
                MTU                      = $mtu
                IPv4                     = $ipv4
                IPv6                     = $ipv6
                Gateway                  = $gateway
                DnsServers               = $dnsServers
                IPv4Enabled              = [bool]($ipv4Binding -and $ipv4Binding.Enabled)
                IPv6Enabled              = [bool]($ipv6Binding -and $ipv6Binding.Enabled)
                Dhcp                     = if ($ipv4If) { [string]$ipv4If.Dhcp } else { 'Unknown' }
                DnsSuffix                = $dnsSuffix
                RegisteredInDns          = $registeredInDns
                RssSupported             = $rssSupported
                RssEnabled               = $rssEnabled
                RssMaxProcessors         = $rssMaxProcessors
                RssMaxProcessorNumber    = $rssMaxProcessorNumber
                RssNumberOfReceiveQueues = $rssQueues
                RssError                 = $rssError
                PowerManagementState     = [string]$powerManagement.State
                PowerManagementSource    = [string]$powerManagement.Source
                PowerManagementError     = [string]$powerManagement.Error
                PnPCapabilities          = $powerManagement.PnPCapabilities
                PacketsReceivedDiscarded = $packetsReceivedDiscarded
                DiscardCounterFound      = $discardCounterFound
                IsVmxnet3                = ($description -match '(?i)vmxnet3')
            })
        }
    }
    catch { }
    return $items.ToArray()
}

function Get-IPv6PolicyInfo {
    $path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'
    $exists = $false
    $value = 0
    try {
        $property = Get-ItemProperty -Path $path -Name DisabledComponents -ErrorAction Stop
        $exists = $true
        $value = [uint32]$property.DisabledComponents
    }
    catch { }

    $meaning = switch ($value) {
        0   { 'Default IPv6 behavior' }
        32  { 'Prefer IPv4 over IPv6 (0x20)' }
        255 { 'IPv6 disabled by policy (0xFF)' }
        default { ('Custom IPv6 policy (0x{0:X2})' -f $value) }
    }

    [PSCustomObject]@{
        RegistryValueExists = $exists
        DisabledComponents  = $value
        HexValue            = ('0x{0:X2}' -f $value)
        Meaning             = $meaning
    }
}

function Get-CredentialGuardInfo {
    $lsaCfgFlags = $null
    try {
        $lsaCfgFlags = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name LsaCfgFlags -ErrorAction Stop).LsaCfgFlags
    }
    catch { }

    $running = @()
    try {
        $deviceGuard = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard -ErrorAction Stop
        $running = @($deviceGuard.SecurityServicesRunning)
    }
    catch { }

    $enabled = (($null -ne $lsaCfgFlags -and [int]$lsaCfgFlags -ne 0) -or ($running -contains 1))
    [PSCustomObject]@{
        Enabled                 = $enabled
        LsaCfgFlags             = $lsaCfgFlags
        SecurityServicesRunning = $running
    }
}

function Get-IEEscInfo {
    param([string]$InstallationType)

    if ($InstallationType -match '(?i)core') {
        return [PSCustomObject]@{
            Applicable = $false
            AdministratorState = 'N/A (Server Core)'
            UserState          = 'N/A (Server Core)'
            AdministratorValue = $null
            UserValue          = $null
        }
    }

    $adminPath = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
    $userPath  = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'

    $adminValue = $null
    $userValue = $null
    try { $adminValue = (Get-ItemProperty -LiteralPath $adminPath -Name IsInstalled -ErrorAction Stop).IsInstalled } catch { }
    try { $userValue = (Get-ItemProperty -LiteralPath $userPath -Name IsInstalled -ErrorAction Stop).IsInstalled } catch { }

    $adminState = if ($null -eq $adminValue) { 'Unknown' } elseif ([int]$adminValue -eq 1) { 'On' } elseif ([int]$adminValue -eq 0) { 'Off' } else { "Unknown ($adminValue)" }
    $userState  = if ($null -eq $userValue)  { 'Unknown' } elseif ([int]$userValue -eq 1)  { 'On' } elseif ([int]$userValue -eq 0)  { 'Off' } else { "Unknown ($userValue)" }

    [PSCustomObject]@{
        Applicable = $true
        AdministratorState = $adminState
        UserState          = $userState
        AdministratorValue = $adminValue
        UserValue          = $userValue
    }
}

function Get-ServerState {
    $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    $registryOs = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop
    $pending = Get-PendingRebootInfo
    $network = @(Get-NetworkSummary)
    $ipv6Policy = Get-IPv6PolicyInfo
    $dotNet = Get-DotNetFrameworkInfo
    $apps = @(Get-InstalledApplications)
    $appCache = Get-InstalledApplicationCache -Applications $apps
    $ad = Get-ActiveDirectorySiteInfo
    $power = Get-PowerPlanInfo
    $credentialGuard = Get-CredentialGuardInfo
    $ieEsc = Get-IEEscInfo -InstallationType ([string]$registryOs.InstallationType)
    $adFunctionalLevel = Get-ADFunctionalLevelInfo
    $timeSync = Get-TimeSyncInfo
    $nicTeaming = Get-NicTeamingInfo
    $tlsBaseline = @(Get-TlsBaselineInfo)
    $antimalware = Get-AntimalwareInfo
    $setupHistory = Get-ExchangeSetupHistoryInfo
    $physicalDiskInventory = Get-PhysicalDiskInventory

    $primaryDnsSuffix = $null
    try {
        $primaryDnsSuffix = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName
    }
    catch { }

    $dnsReadiness = Get-DnsReadinessInfo -ComputerName ([string]$env:COMPUTERNAME) -PrimaryDnsSuffix $primaryDnsSuffix -DomainName ([string]$cs.Domain) -ForestDnsName ([string]$adFunctionalLevel.ForestDnsName) -WritableDC ([string]$ad.DC) -GlobalCatalog ([string]$ad.GC)

    $features = @()
    try {
        Import-Module ServerManager -ErrorAction Stop
        $features = @(Get-WindowsFeature -ErrorAction Stop)
    }
    catch { }

    $remoteRegistry = $null
    try { $remoteRegistry = Get-CimInstance Win32_Service -Filter "Name='RemoteRegistry'" -ErrorAction Stop } catch { }

    $pageFileSettings = @()
    $pageFileUsage = @()
    try { $pageFileSettings = @(Get-CimInstance Win32_PageFileSetting -ErrorAction Stop) } catch { }
    try { $pageFileUsage = @(Get-CimInstance Win32_PageFileUsage -ErrorAction Stop) } catch { }

    $fixedDisks = @()
    try {
        # Get-Volume exposes the allocation unit size directly. Only fixed volumes with a drive letter
        # are evaluated here so hidden/system-reserved volumes are not treated as Exchange data volumes.
        $fixedDisks = @(Get-Volume -ErrorAction Stop | Where-Object {
            $_.DriveType -eq 'Fixed' -and $null -ne $_.DriveLetter
        } | ForEach-Object {
            $driveId = "{0}:" -f [string]$_.DriveLetter
            $diskNumber = $null
            $partitionStyle = $null
            $diskFriendlyName = $null
            $diskBusType = $null

            try {
                $partition = Get-Partition -DriveLetter ([string]$_.DriveLetter) -ErrorAction Stop | Select-Object -First 1
                if ($null -ne $partition) {
                    $diskNumber = [int]$partition.DiskNumber
                    $diskObject = Get-Disk -Number $diskNumber -ErrorAction Stop
                    if ($diskObject.PSObject.Properties['PartitionStyle']) { $partitionStyle = [string]$diskObject.PartitionStyle }
                    if ($diskObject.PSObject.Properties['FriendlyName']) { $diskFriendlyName = [string]$diskObject.FriendlyName }
                    if ($diskObject.PSObject.Properties['BusType']) { $diskBusType = [string]$diskObject.BusType }
                }
            }
            catch { }

            [PSCustomObject]@{
                DeviceID           = $driveId
                DriveLetter        = [string]$_.DriveLetter
                Label              = [string]$_.FileSystemLabel
                FileSystem         = [string]$_.FileSystem
                AllocationUnitSize = if ($null -ne $_.AllocationUnitSize) { [int64]$_.AllocationUnitSize } else { $null }
                SizeGB             = if ($_.Size) { [math]::Round($_.Size / 1GB, 1) } else { 0 }
                FreeGB             = if ($_.SizeRemaining) { [math]::Round($_.SizeRemaining / 1GB, 1) } else { 0 }
                DiskNumber         = $diskNumber
                PartitionStyle     = $partitionStyle
                DiskFriendlyName   = $diskFriendlyName
                BusType            = $diskBusType
            }
        })
    }
    catch {
        # Fallback keeps the original disk visibility if the Storage module is unavailable.
        try {
            $fixedDisks = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop | ForEach-Object {
                [PSCustomObject]@{
                    DeviceID           = [string]$_.DeviceID
                    DriveLetter        = ([string]$_.DeviceID).TrimEnd(':')
                    Label              = [string]$_.VolumeName
                    FileSystem         = [string]$_.FileSystem
                    AllocationUnitSize = $null
                    SizeGB             = if ($_.Size) { [math]::Round($_.Size / 1GB, 1) } else { 0 }
                    FreeGB             = if ($_.FreeSpace) { [math]::Round($_.FreeSpace / 1GB, 1) } else { 0 }
                    DiskNumber         = $null
                    PartitionStyle     = $null
                    DiskFriendlyName   = $null
                    BusType            = $null
                }
            })
        }
        catch { }
    }

    $systemLocale = $null
    $culture = $null
    $uiCulture = $null
    $timeZone = $null
    $homeLocation = $null
    $homeLocationDescription = $null
    $ansiCodePage = $null
    $utf8BetaEnabled = $null
    try { $systemLocale = Get-WinSystemLocale -ErrorAction Stop } catch { }
    try { $culture = Get-Culture -ErrorAction Stop } catch { }
    try { $uiCulture = Get-UICulture -ErrorAction Stop } catch { }
    try { $timeZone = Get-TimeZone -ErrorAction Stop } catch { }
    try {
        $homeLocation = Get-WinHomeLocation -ErrorAction Stop
        if ($homeLocation -and $homeLocation.PSObject.Properties['HomeLocation'] -and -not [string]::IsNullOrWhiteSpace([string]$homeLocation.HomeLocation)) {
            $homeLocationDescription = [string]$homeLocation.HomeLocation
        }
        elseif ($homeLocation -and $homeLocation.PSObject.Properties['GeoId'] -and [int]$homeLocation.GeoId -eq 244) {
            $homeLocationDescription = 'United States'
        }
    }
    catch { }
    try {
        $codePage = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage' -Name ACP -ErrorAction Stop
        $ansiCodePage = [string]$codePage.ACP
        $utf8BetaEnabled = ($ansiCodePage -eq '65001')
    }
    catch { }
    [PSCustomObject]@{
        Timestamp              = Get-Date
        ComputerName           = [string]$env:COMPUTERNAME
        ComputerSystem         = $cs
        OperatingSystem        = $os
        RegistryOS             = $registryOs
        InstalledApps          = $apps
        InstalledAppCache      = $appCache
        WindowsFeatures        = $features
        RemoteRegistry         = $remoteRegistry
        PendingReboot          = $pending
        Network                = $network
        NicTeaming             = $nicTeaming
        DnsReadiness           = $dnsReadiness
        IPv6Policy             = $ipv6Policy
        DotNet                 = $dotNet
        AD                     = $ad
        PowerPlan              = $power
        CredentialGuard       = $credentialGuard
        IEEsc                  = $ieEsc
        ADFunctionalLevel      = $adFunctionalLevel
        TimeSync               = $timeSync
        PrimaryDnsSuffix       = $primaryDnsSuffix
        PageFileSettings       = $pageFileSettings
        PageFileUsage          = $pageFileUsage
        FixedDisks             = $fixedDisks
        PhysicalDiskInventory  = $physicalDiskInventory
        TlsBaseline            = $tlsBaseline
        Antimalware            = $antimalware
        ExchangeSetupHistory   = $setupHistory
        SystemLocale           = $systemLocale
        Culture                = $culture
        UICulture              = $uiCulture
        TimeZone               = $timeZone
        HomeLocation           = $homeLocation
        CountryOrRegion        = $homeLocationDescription
        SystemLocaleName       = if ($systemLocale) { [string]$systemLocale.Name } else { $null }
        SystemLocaleDisplayName = if ($systemLocale) { [string]$systemLocale.EnglishName } else { $null }
        CultureName            = if ($culture) { [string]$culture.Name } else { $null }
        CultureDisplayName     = if ($culture) { [string]$culture.EnglishName } else { $null }
        ShortDatePattern       = if ($culture) { [string]$culture.DateTimeFormat.ShortDatePattern } else { $null }
        NumberDecimalSeparator = if ($culture) { [string]$culture.NumberFormat.NumberDecimalSeparator } else { $null }
        UICultureName          = if ($uiCulture) { [string]$uiCulture.Name } else { $null }
        UICultureDisplayName   = if ($uiCulture) { [string]$uiCulture.EnglishName } else { $null }
        TimeZoneId             = if ($timeZone) { [string]$timeZone.Id } else { $null }
        AnsiCodePage           = $ansiCodePage
        Utf8BetaEnabled        = $utf8BetaEnabled
        IsAdministrator        = Test-IsAdministrator
        AutomaticManagedPagefile = [bool]$cs.AutomaticManagedPagefile
    }
}

# ---------------------------------------------------------------------------
# Check evaluation
# ---------------------------------------------------------------------------
function Get-OsYear {
    param($State)
    $caption = [string]$State.OperatingSystem.Caption
    foreach ($year in @('2025','2022','2019')) {
        if ($caption -match $year) { return $year }
    }
    return 'Unknown'
}

function Get-RequiredWindowsFeatures {
    param($State)
    $installationType = [string]$State.RegistryOS.InstallationType
    if ($installationType -match '(?i)core') { return @($script:ServerCoreFeatures) }
    return @($script:DesktopExperienceFeatures)
}

function Get-ExchangePreparationChecks {
    param([Parameter(Mandatory = $true)]$State)

    $results = New-Object System.Collections.Generic.List[object]
    $checkFailureNumber = 0

    # Keep one failed readiness check from terminating the remaining checks.
    # Because $ErrorActionPreference is Stop, unexpected errors are surfaced as
    # REVIEW and execution resumes with the next statement in this function.
    trap {
        $checkFailureNumber++
        $errorMessage = if ($_.Exception -and -not [string]::IsNullOrWhiteSpace([string]$_.Exception.Message)) {
            [string]$_.Exception.Message
        }
        else {
            [string]$_
        }
        $lineNumber = if ($_.InvocationInfo -and $_.InvocationInfo.ScriptLineNumber) {
            [int]$_.InvocationInfo.ScriptLineNumber
        }
        else {
            0
        }
        $current = if ($lineNumber -gt 0) {
            "Check failed at script line {0}: {1}" -f $lineNumber,$errorMessage
        }
        else {
            "Check failed: {0}" -f $errorMessage
        }

        [void]$results.Add((New-CheckResult -Category 'Check Execution' -Name ("Readiness check failure #{0}" -f $checkFailureNumber) -Status REVIEW -Current $current -Expected 'Check completes successfully' -Message 'This check could not be evaluated. The script continued with the remaining readiness checks.'))
        continue
    }

    $osYear = Get-OsYear -State $State
    $caption = [string]$State.OperatingSystem.Caption
    $edition = [string]$State.RegistryOS.EditionID
    $installType = [string]$State.RegistryOS.InstallationType
    $architecture = [string]$State.OperatingSystem.OSArchitecture

    if ($State.IsAdministrator) {
        [void]$results.Add((New-CheckResult -Category 'Host' -Name 'Administrator' -Status PASS -Current 'Elevated' -Expected 'Run from an elevated Windows PowerShell session'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Host' -Name 'Administrator' -Status BLOCKER -Current 'Not elevated' -Expected 'Run as Administrator' -Message 'Some prerequisite and registry checks may be incomplete without elevation.'))
    }

    $psVersion = [string]$PSVersionTable.PSVersion
    $shellEdition = if ($PSVersionTable.ContainsKey('PSEdition')) { [string]$PSVersionTable.PSEdition } else { 'Desktop' }
    if ($PSVersionTable.PSVersion.Major -eq 5 -and $shellEdition -eq 'Desktop') {
        [void]$results.Add((New-CheckResult -Category 'Host' -Name 'Windows PowerShell' -Status PASS -Current "$psVersion / $shellEdition" -Expected 'Windows PowerShell 5.1 (Windows-included version)'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Host' -Name 'Windows PowerShell' -Status BLOCKER -Current "$psVersion / $shellEdition" -Expected 'Windows PowerShell 5.1 (Windows-included version)' -Message 'Run the check from Windows PowerShell 5.1. Exchange Server uses the Windows-included Windows PowerShell version.'))
    }

    $supportedOs = ($osYear -in @('2019','2022','2025')) -and ($edition -match '(?i)standard|datacenter') -and ($architecture -match '64')
    if ($supportedOs) {
        [void]$results.Add((New-CheckResult -Category 'Operating System' -Name 'Windows Server' -Status PASS -Current "$caption / $edition / $installType / $architecture" -Expected 'Windows Server 2019, 2022, or 2025 Standard/Datacenter x64'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Operating System' -Name 'Windows Server' -Status BLOCKER -Current "$caption / $edition / $installType / $architecture" -Expected 'Windows Server 2019, 2022, or 2025 Standard/Datacenter x64' -Message 'Exchange Server SE OS supportability check failed.'))
    }

    if ($State.ComputerSystem.PartOfDomain) {
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Domain Membership' -Status PASS -Current $State.ComputerSystem.Domain -Expected 'Domain member'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Domain Membership' -Status BLOCKER -Current 'Workgroup' -Expected 'Domain member' -Message 'Join the server to the target Active Directory domain before Exchange installation.'))
    }

    $primaryDnsSuffix = [string]$State.PrimaryDnsSuffix
    if (-not [string]::IsNullOrWhiteSpace($primaryDnsSuffix)) {
        $fqdn = "{0}.{1}" -f $State.ComputerName,$primaryDnsSuffix
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Primary DNS Suffix / FQDN' -Status PASS -Current $fqdn -Expected 'Primary DNS suffix configured before Exchange installation'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Primary DNS Suffix / FQDN' -Status BLOCKER -Current '<Missing>' -Expected 'Primary DNS suffix configured before Exchange installation' -Message 'Exchange Setup requires a valid server FQDN. Do not rename the server or change its primary DNS suffix after Exchange is installed.'))
    }

    $forestMode = [string]$State.ADFunctionalLevel.ForestMode
    $forestLevel = $State.ADFunctionalLevel.ForestLevel
    if ($null -ne $forestLevel -and [int]$forestLevel -in @(6,7)) {
        $forestCurrent = "{0} (level {1})" -f $forestMode,$forestLevel
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Forest Functional Level' -Status PASS -Current $forestCurrent -Expected 'Windows Server 2012 R2 or Windows Server 2016 forest functional level'))
    }
    elseif ($null -ne $forestLevel) {
        $forestCurrent = "{0} (level {1})" -f $forestMode,$forestLevel
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Forest Functional Level' -Status BLOCKER -Current $forestCurrent -Expected 'Windows Server 2012 R2 or Windows Server 2016 forest functional level' -Message 'Exchange Server SE supports only the forest functional levels listed in the current Exchange supportability matrix.'))
    }
    else {
        $forestError = if (-not [string]::IsNullOrWhiteSpace([string]$State.ADFunctionalLevel.Error)) { [string]$State.ADFunctionalLevel.Error } else { 'Could not query forestFunctionality from LDAP RootDSE.' }
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Forest Functional Level' -Status REVIEW -Current $forestError -Expected 'Windows Server 2012 R2 or Windows Server 2016 forest functional level' -Message 'The forest functional level could not be determined. This is a detection issue, not an Exchange readiness blocker.'))
    }

    if ([int]$State.ComputerSystem.DomainRole -ge 4) {
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Server Role' -Status BLOCKER -Current 'Domain Controller' -Expected 'Member Server' -Message 'Use a member server for Exchange.'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Server Role' -Status PASS -Current 'Member Server' -Expected 'Member Server'))
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$State.AD.Site)) {
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'AD Site' -Status PASS -Current $State.AD.Site -Expected 'Resolved AD site'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'AD Site' -Status BLOCKER -Current $State.AD.SiteError -Expected 'Resolved AD site' -Message 'Verify AD subnet/site mapping and domain connectivity.'))
    }

    if ($State.AD.DC -and $State.AD.GC) {
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Writable DC / GC' -Status PASS -Current ("DC={0}; GC={1}" -f $State.AD.DC,$State.AD.GC) -Expected 'Writable DC and GC reachable'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Active Directory' -Name 'Writable DC / GC' -Status BLOCKER -Current ("DC={0}; GC={1}; {2}" -f $State.AD.DC,$State.AD.GC,$State.AD.DCError) -Expected 'Writable DC and GC reachable'))
    }

    if ($State.ComputerSystem.PartOfDomain) {
        $dnsChecks = @(
            [PSCustomObject]@{ Name='Server FQDN Resolution'; Data=$State.DnsReadiness.ServerFqdn; Expected='Exchange server FQDN resolves in DNS' },
            [PSCustomObject]@{ Name='DC Locator SRV Records'; Data=$State.DnsReadiness.DcSrv; Expected='_ldap._tcp.dc._msdcs.<domain> SRV records resolve' },
            [PSCustomObject]@{ Name='Kerberos SRV Records'; Data=$State.DnsReadiness.KerberosSrv; Expected='_kerberos._tcp.<domain> SRV records resolve' },
            [PSCustomObject]@{ Name='Global Catalog SRV Records'; Data=$State.DnsReadiness.GcSrv; Expected='_ldap._tcp.gc._msdcs.<forest> SRV records resolve' },
            [PSCustomObject]@{ Name='Writable DC DNS Resolution'; Data=$State.DnsReadiness.WritableDC; Expected='Discovered writable DC resolves in DNS' },
            [PSCustomObject]@{ Name='Global Catalog DNS Resolution'; Data=$State.DnsReadiness.GlobalCatalog; Expected='Discovered Global Catalog resolves in DNS' }
        )

        foreach ($dnsCheck in $dnsChecks) {
            $dnsData = $dnsCheck.Data
            $dnsCurrent = if ($dnsData.Success) {
                "{0} -> {1}" -f $dnsData.Name,(@($dnsData.Values) -join ', ')
            }
            else {
                "{0}: {1}" -f $(if ([string]::IsNullOrWhiteSpace([string]$dnsData.Name)) { '<Not available>' } else { [string]$dnsData.Name }),$dnsData.Error
            }
            [void]$results.Add((New-CheckResult -Category 'DNS and Active Directory' -Name $dnsCheck.Name -Status $(if ($dnsData.Success) { 'PASS' } else { 'BLOCKER' }) -Current $dnsCurrent -Expected $dnsCheck.Expected -Message $(if ($dnsData.Success) { '' } else { 'Verify DNS registration, AD-integrated DNS zones, SRV records, and client DNS configuration before Exchange installation.' })))
        }
    }

    $dnsServers = @($State.Network | ForEach-Object { $_.DnsServers } | Where-Object { $_ } | Select-Object -Unique)
    $dnsAdapterDetails = @(
        $State.Network |
            Where-Object { (Get-SafeCount @($_.DnsServers)) -gt 0 } |
            ForEach-Object {
                $adapterName = if (-not [string]::IsNullOrWhiteSpace([string]$_.Name)) {
                    [string]$_.Name
                }
                elseif (-not [string]::IsNullOrWhiteSpace([string]$_.Description)) {
                    [string]$_.Description
                }
                else {
                    'Adapter'
                }

                "{0}: {1}" -f $adapterName,(@($_.DnsServers) -join ', ')
            }
    )

    $dhcpAdapters = @($State.Network | Where-Object { $_.Dhcp -eq 'Enabled' } | ForEach-Object { $_.Name })
    if ((Get-SafeCount $dnsServers) -gt 0) {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'Configured DNS Servers' -Status PASS -Current ($dnsAdapterDetails -join ' | ') -Expected 'Internal AD-capable DNS servers' -Message 'Verify the addresses against the customer AD/DNS design.'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'Configured DNS Servers' -Status BLOCKER -Current '<None configured on active adapters>' -Expected 'At least one internal AD DNS server'))
    }

    $lbfoTeams = @($State.NicTeaming.Teams)
    if ((Get-SafeCount $lbfoTeams) -gt 0) {
        $teamText = @($lbfoTeams | ForEach-Object {
            "{0}: Status={1}; Mode={2}; Algorithm={3}; Members={4}" -f $_.Name,$_.Status,$_.TeamingMode,$_.LoadBalancingAlgorithm,(@($_.Members) -join ',')
        }) -join ' | '
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'NIC Teaming (LBFO)' -Status REVIEW -Current $teamText -Expected 'Validate that LBFO teaming is intentional for this server design' -Message 'Windows LBFO NIC Teaming was detected. Review the team mode, load-balancing algorithm, switch/network design, and member adapters.'))
    }
    elseif (-not [string]::IsNullOrWhiteSpace([string]$State.NicTeaming.Error)) {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'NIC Teaming (LBFO)' -Status INFO -Current $State.NicTeaming.Error -Expected 'Visibility only' -Message 'LBFO state could not be queried.'))
    }
    elseif ($State.NicTeaming.CmdletAvailable) {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'NIC Teaming (LBFO)' -Status PASS -Current 'Not configured' -Expected 'No LBFO team, or validate intentional configuration'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'NIC Teaming (LBFO)' -Status INFO -Current 'Get-NetLbfoTeam cmdlet not available' -Expected 'Visibility only'))
    }

    foreach ($adapter in @($State.Network)) {
        $adapterLabel = if (-not [string]::IsNullOrWhiteSpace([string]$adapter.Name)) { [string]$adapter.Name } else { [string]$adapter.Description }
        $adapterDescription = if (-not [string]::IsNullOrWhiteSpace([string]$adapter.Description)) { [string]$adapter.Description } else { $adapterLabel }
        $mtuText = if ($null -ne $adapter.MTU) { [string]$adapter.MTU } else { '<Unknown>' }
        [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("Adapter Details - {0}" -f $adapterLabel) -Status INFO -Current ("Description={0}; LinkSpeed={1}; MTU={2}" -f $adapterDescription,$adapter.LinkSpeed,$mtuText) -Expected 'Visibility only'))

        if ($adapter.RssSupported) {
            $rssCurrent = "Enabled={0}; MaxProcessors={1}; MaxProcessorNumber={2}; ReceiveQueues={3}" -f $adapter.RssEnabled,$adapter.RssMaxProcessors,$adapter.RssMaxProcessorNumber,$adapter.RssNumberOfReceiveQueues
            if ($adapter.RssEnabled) {
                [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("RSS - {0}" -f $adapterLabel) -Status PASS -Current $rssCurrent -Expected 'RSS enabled'))
            }
            else {
                [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("RSS - {0}" -f $adapterLabel) -Status REVIEW -Current $rssCurrent -Expected 'RSS enabled' -Message 'Enabling Receive Side Scaling (RSS) is recommended for Exchange server network adapters.'))
            }
        }
        else {
            $rssCurrent = if (-not [string]::IsNullOrWhiteSpace([string]$adapter.RssError)) { $adapter.RssError } else { 'No RSS feature detected' }
            [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("RSS - {0}" -f $adapterLabel) -Status INFO -Current $rssCurrent -Expected 'Visibility only'))
        }

        $powerState = [string]$adapter.PowerManagementState
        if ($powerState -eq 'Disabled') {
            [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("NIC Power Saving - {0}" -f $adapterLabel) -Status PASS -Current 'Allow the computer to turn off this device to save power = Disabled' -Expected 'Disabled'))
        }
        elseif ($powerState -eq 'Enabled') {
            [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("NIC Power Saving - {0}" -f $adapterLabel) -Status REVIEW -Current 'Allow the computer to turn off this device to save power = Enabled' -Expected 'Disabled' -Message 'Disable NIC power saving before Exchange installation.'))
        }
        else {
            $powerCurrent = $powerState
            if (-not [string]::IsNullOrWhiteSpace([string]$adapter.PowerManagementError)) { $powerCurrent += ": $($adapter.PowerManagementError)" }
            [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("NIC Power Saving - {0}" -f $adapterLabel) -Status INFO -Current $powerCurrent -Expected 'Visibility only'))
        }

        if ($adapter.DiscardCounterFound) {
            $discardValue = [int64]$adapter.PacketsReceivedDiscarded
            $discardMessage = 'Packets Received Discarded should normally remain at 0.'
            if ($adapter.IsVmxnet3 -and $discardValue -gt 0) {
                $discardMessage += ' vmxnet3 detected; if discards persist, review the VMware vmxnet3 guest packet-loss known issue referenced by Microsoft CSS-Exchange HealthChecker: https://aka.ms/HC-VMwareLostPackets'
            }

            if ($discardValue -eq 0) {
                [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("Packets Received Discarded - {0}" -f $adapterLabel) -Status PASS -Current '0' -Expected '0'))
            }
            elseif ($discardValue -lt 1000) {
                [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("Packets Received Discarded - {0}" -f $adapterLabel) -Status REVIEW -Current ([string]$discardValue) -Expected '0' -Message $discardMessage))
            }
            else {
                [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("Packets Received Discarded - {0}" -f $adapterLabel) -Status BLOCKER -Current ([string]$discardValue) -Expected '0' -Message ($discardMessage + ' This value is high enough to indicate a potentially significant network performance issue.'))) 
            }
        }
        else {
            [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name ("Packets Received Discarded - {0}" -f $adapterLabel) -Status INFO -Current 'Counter not available' -Expected 'Visibility only'))
        }
    }

    $registeredAdapters = @($State.Network | Where-Object { $_.RegisteredInDns -eq $true } | ForEach-Object { $_.Name })
    if ((Get-SafeCount $registeredAdapters) -gt 0) {
        [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name 'NIC DNS Registration' -Status PASS -Current ("Registered: {0}" -f ($registeredAdapters -join ', ')) -Expected 'At least one active server NIC registers its address in DNS'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Network Adapter' -Name 'NIC DNS Registration' -Status BLOCKER -Current 'No active NIC is configured to register its address in DNS' -Expected 'At least one active server NIC registers its address in DNS' -Message 'Exchange depends on correct server DNS registration. Validate Register this connection''s addresses in DNS before installation.'))
    }

    if ((Get-SafeCount $dhcpAdapters) -gt 0) {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'IPv4 Addressing' -Status REVIEW -Current ("DHCP: {0}" -f ($dhcpAdapters -join ', ')) -Expected 'Stable server addressing' -Message 'Confirm whether DHCP/reservation is intentional for this Exchange server.'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'IPv4 Addressing' -Status PASS -Current 'No active adapter reports DHCP' -Expected 'Stable server addressing'))
    }

    $ipv4Enabled = (Get-SafeCount @($State.Network | Where-Object { $_.IPv4Enabled })) -gt 0
    [void]$results.Add((New-CheckResult -Category 'Network' -Name 'IPv4 Binding' -Status $(if ($ipv4Enabled) { 'PASS' } else { 'BLOCKER' }) -Current $(if ($ipv4Enabled) { 'Enabled' } else { 'Not detected/enabled' }) -Expected 'Enabled'))

    $ipv6DisabledAdapters = @($State.Network | Where-Object { -not $_.IPv6Enabled } | ForEach-Object { $_.Name })
    if ((Get-SafeCount $ipv6DisabledAdapters) -eq 0) {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'IPv6 Adapter Binding' -Status PASS -Current 'Enabled on active adapters' -Expected 'Keep IPv6 bound/enabled'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'IPv6 Adapter Binding' -Status REVIEW -Current ("Disabled: {0}" -f ($ipv6DisabledAdapters -join ', ')) -Expected 'Keep IPv6 bound/enabled' -Message 'Microsoft does not recommend unbinding IPv6.'))
    }

    $dcValue = [uint32]$State.IPv6Policy.DisabledComponents
    $registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'
    $registryDetails = "Registry path: $registryPath`nName: DisabledComponents`nType: REG_DWORD`nDecimal: 32`nHexadecimal: 0x20"
    $currentPolicy = if ($State.IPv6Policy.RegistryValueExists) {
        "$($State.IPv6Policy.HexValue) - $($State.IPv6Policy.Meaning)"
    }
    else {
        'Not configured - Windows default behavior applies (IPv6 preferred over IPv4)'
    }

    if ($dcValue -eq 32 -and $State.IPv6Policy.RegistryValueExists) {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'IP Protocol Preference' -Status PASS -Current $currentPolicy -Expected 'Prefer IPv4 over IPv6' -Message $registryDetails))
    }
    elseif ($dcValue -eq 0) {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'IP Protocol Preference' -Status REVIEW -Current $currentPolicy -Expected 'Prefer IPv4 over IPv6' -Message ("Microsoft recommends preferring IPv4 over IPv6 instead of disabling IPv6.`n" + $registryDetails)))
    }
    elseif ($dcValue -eq 255) {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'IP Protocol Preference' -Status REVIEW -Current $currentPolicy -Expected 'Prefer IPv4 over IPv6 without disabling IPv6' -Message ("Microsoft does not recommend disabling IPv6. Use the IPv4 preference setting instead.`n" + $registryDetails)))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Network' -Name 'IP Protocol Preference' -Status REVIEW -Current $currentPolicy -Expected 'Prefer IPv4 over IPv6' -Message ("A custom DisabledComponents value is configured. Review it against Microsoft IPv6 guidance.`n" + $registryDetails)))
    }

    $timeSource = [string]$State.TimeSync.Source
    $timeState = [string]$State.TimeSync.ServiceState
    if (-not [string]::IsNullOrWhiteSpace($timeSource) -and $timeSource -notmatch '(?i)Local CMOS Clock|Free-running System Clock') {
        [void]$results.Add((New-CheckResult -Category 'Operating System' -Name 'Windows Time' -Status PASS -Current ("{0}; Source={1}" -f $timeState,$timeSource) -Expected 'Running with a valid domain/environment time source'))
    }
    else {
        $timeCurrent = if ([string]::IsNullOrWhiteSpace($timeSource)) { "{0}; {1}" -f $timeState,$State.TimeSync.Error } else { "{0}; Source={1}" -f $timeState,$timeSource }
        [void]$results.Add((New-CheckResult -Category 'Operating System' -Name 'Windows Time' -Status REVIEW -Current $timeCurrent -Expected 'Running with a valid domain/environment time source' -Message 'Verify time synchronization before Exchange installation. Kerberos and Exchange authentication are time-sensitive.'))
    }

    if ($State.PendingReboot.Pending) {
        [void]$results.Add((New-CheckResult -Category 'Operating System' -Name 'Pending reboot' -Status BLOCKER -Current ($State.PendingReboot.Reasons -join ', ') -Expected 'No pending reboot' -Message 'Restart the server and rerun the check before Exchange Setup.'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Operating System' -Name 'Pending reboot' -Status PASS -Current 'No' -Expected 'No pending reboot'))
    }

    $ramGB = [math]::Round($State.ComputerSystem.TotalPhysicalMemory / 1GB, 1)
    if ($ramGB -ge 128) {
        [void]$results.Add((New-CheckResult -Category 'Hardware' -Name 'Memory' -Status PASS -Current "$ramGB GB" -Expected '128 GB minimum recommended for Mailbox role'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Hardware' -Name 'Memory' -Status REVIEW -Current "$ramGB GB" -Expected '128 GB minimum recommended for Mailbox role' -Message 'Validate sizing for the intended workload.'))
    }

    $cpuSockets = [int]$State.ComputerSystem.NumberOfProcessors
    $logicalProcessors = [int]$State.ComputerSystem.NumberOfLogicalProcessors
    if ($cpuSockets -le 2) {
        [void]$results.Add((New-CheckResult -Category 'Hardware' -Name 'CPU Sockets' -Status PASS -Current ("Sockets={0}; LogicalProcessors={1}" -f $cpuSockets,$logicalProcessors) -Expected 'Up to 2 processor sockets recommended'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Hardware' -Name 'CPU Sockets' -Status REVIEW -Current ("Sockets={0}; LogicalProcessors={1}" -f $cpuSockets,$logicalProcessors) -Expected 'Up to 2 processor sockets recommended' -Message 'Review the physical/virtual CPU topology and Exchange sizing design.'))
    }

    $systemDrive = [string]$env:SystemDrive
    $systemDisk = @($State.FixedDisks | Where-Object { $_.DeviceID -ieq $systemDrive } | Select-Object -First 1)
    if ((Get-SafeCount $systemDisk) -gt 0) {
        $diskText = "$($systemDisk[0].FreeGB) GB free / $($systemDisk[0].FileSystem)"
        if ($systemDisk[0].FreeGB -lt 0.2) {
            [void]$results.Add((New-CheckResult -Category 'Storage' -Name 'System Drive Free Space' -Status BLOCKER -Current $diskText -Expected 'At least 200 MB free on system drive'))
        }
        elseif ($systemDisk[0].FreeGB -lt 30) {
            [void]$results.Add((New-CheckResult -Category 'Storage' -Name 'System Drive Free Space' -Status REVIEW -Current $diskText -Expected '30 GB free if Exchange binaries will be installed on this drive'))
        }
        else {
            [void]$results.Add((New-CheckResult -Category 'Storage' -Name 'System Drive Free Space' -Status PASS -Current $diskText -Expected 'At least 30 GB when used as Exchange installation drive'))
        }
        [void]$results.Add((New-CheckResult -Category 'Storage' -Name 'System Drive File System' -Status $(if ($systemDisk[0].FileSystem -ieq 'NTFS') { 'PASS' } else { 'BLOCKER' }) -Current $systemDisk[0].FileSystem -Expected 'NTFS'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Storage' -Name 'System Drive' -Status BLOCKER -Current 'Not detected' -Expected 'System drive information available'))
    }

    $physicalDisks = @($State.PhysicalDiskInventory.Disks)
    if ((Get-SafeCount $physicalDisks) -gt 0) {
        $physicalDiskText = @($physicalDisks | ForEach-Object {
            "{0}: Media={1}; Bus={2}; Size={3} GB; Health={4}" -f $_.FriendlyName,$_.MediaType,$_.BusType,$_.SizeGB,$_.HealthStatus
        }) -join ' | '
        [void]$results.Add((New-CheckResult -Category 'Storage' -Name 'Physical Disk Media' -Status INFO -Current $physicalDiskText -Expected 'Visibility only' -Message 'MediaType/BusType can be Unspecified or abstracted on virtual machines, SAN LUNs, and some storage stacks.'))
    }
    else {
        $physicalDiskCurrent = if (-not [string]::IsNullOrWhiteSpace([string]$State.PhysicalDiskInventory.Error)) { $State.PhysicalDiskInventory.Error } else { 'No physical disk media information returned' }
        [void]$results.Add((New-CheckResult -Category 'Storage' -Name 'Physical Disk Media' -Status INFO -Current $physicalDiskCurrent -Expected 'Visibility only' -Message 'This is informational. Virtualized or SAN-backed storage may not expose physical media type to the guest OS.'))
    }

    # Exchange data-volume baseline. Microsoft supports NTFS and ReFS for Exchange data volumes and
    # recommends 64 KB allocation units for database (.edb) and transaction log volumes. This readiness
    # script deliberately enforces 64 KB on every non-system fixed drive-letter volume used for the build.
    $dataVolumes = @($State.FixedDisks | Where-Object { $_.DeviceID -and $_.DeviceID -ine $systemDrive })
    if ((Get-SafeCount $dataVolumes) -eq 0) {
        [void]$results.Add((New-CheckResult -Category 'Storage' -Name 'Non-System Fixed Volumes' -Status REVIEW -Current 'None detected' -Expected 'Exchange data volumes, if present, should use NTFS/ReFS with 64 KB allocation unit size' -Message 'No non-system fixed drive-letter volumes were detected.'))
    }
    else {
        foreach ($volume in $dataVolumes) {
            $volumeId = [string]$volume.DeviceID
            $volumeLabel = if ([string]::IsNullOrWhiteSpace([string]$volume.Label)) { '' } else { " ($($volume.Label))" }
            $fileSystem = [string]$volume.FileSystem
            $fileSystemStatus = if ($fileSystem -in @('NTFS','ReFS')) { 'PASS' } else { 'BLOCKER' }
            [void]$results.Add((New-CheckResult -Category 'Storage' -Name ("{0}{1} File System" -f $volumeId,$volumeLabel) -Status $fileSystemStatus -Current $fileSystem -Expected 'NTFS or ReFS' -Message $(if ($fileSystemStatus -eq 'BLOCKER') { 'Use an Exchange-supported file system for the intended data volume.' } else { '' })))

            $partitionStyle = [string]$volume.PartitionStyle
            if (-not [string]::IsNullOrWhiteSpace($partitionStyle)) {
                $partitionStatus = if ($partitionStyle -ieq 'GPT') { 'PASS' } else { 'REVIEW' }
                [void]$results.Add((New-CheckResult -Category 'Storage' -Name ("{0}{1} Partition Style" -f $volumeId,$volumeLabel) -Status $partitionStatus -Current $partitionStyle -Expected 'GPT recommended' -Message $(if ($partitionStatus -eq 'REVIEW') { 'Review the disk layout against the Exchange storage design.' } else { '' })))
            }
            else {
                [void]$results.Add((New-CheckResult -Category 'Storage' -Name ("{0}{1} Partition Style" -f $volumeId,$volumeLabel) -Status INFO -Current 'Could not determine' -Expected 'Visibility only'))
            }

            $busCurrent = if (-not [string]::IsNullOrWhiteSpace([string]$volume.BusType)) { [string]$volume.BusType } else { '<Unknown / abstracted>' }
            $diskNameCurrent = if (-not [string]::IsNullOrWhiteSpace([string]$volume.DiskFriendlyName)) { [string]$volume.DiskFriendlyName } else { '<Unknown>' }
            [void]$results.Add((New-CheckResult -Category 'Storage' -Name ("{0}{1} Disk / Bus" -f $volumeId,$volumeLabel) -Status INFO -Current ("Disk={0}; Bus={1}" -f $diskNameCurrent,$busCurrent) -Expected 'Visibility only'))

            if ($null -eq $volume.AllocationUnitSize) {
                [void]$results.Add((New-CheckResult -Category 'Storage' -Name ("{0}{1} Allocation Unit Size" -f $volumeId,$volumeLabel) -Status BLOCKER -Current 'Could not determine' -Expected '64 KB (65536 bytes)' -Message 'Allocation unit size could not be verified. This readiness baseline requires a confirmed 64 KB allocation unit size on every non-system fixed volume.'))
            }
            else {
                $allocationBytes = [int64]$volume.AllocationUnitSize
                $allocationText = if (($allocationBytes % 1KB) -eq 0) { "{0} KB ({1} bytes)" -f [int]($allocationBytes / 1KB),$allocationBytes } else { "$allocationBytes bytes" }
                $allocationStatus = if ($allocationBytes -eq 65536) { 'PASS' } else { 'BLOCKER' }
                $allocationMessage = if ($allocationStatus -eq 'BLOCKER') {
                    'This readiness baseline requires 64 KB allocation units on non-system Exchange data volumes. Microsoft supports other allocation unit sizes, but 64 KB is the documented best practice for .edb and transaction log volumes.'
                }
                else { '' }
                [void]$results.Add((New-CheckResult -Category 'Storage' -Name ("{0}{1} Allocation Unit Size" -f $volumeId,$volumeLabel) -Status $allocationStatus -Current $allocationText -Expected '64 KB (65536 bytes)' -Message $allocationMessage))
            }
        }
    }

    $desiredPageFileMB = [int][math]::Round(($State.ComputerSystem.TotalPhysicalMemory / 1MB) * 0.25, 0)
    $desiredPageFileGB = [math]::Round($desiredPageFileMB / 1024, 1)
    $pageSetting = @($State.PageFileSettings)
    $pageCurrent = if ((Get-SafeCount $pageSetting) -eq 0) {
        "Automatic=$($State.AutomaticManagedPagefile); no Win32_PageFileSetting object detected"
    }
    else {
        "Automatic=$($State.AutomaticManagedPagefile); " + (($pageSetting | ForEach-Object { "{0}: Initial={1} MB Maximum={2} MB" -f $_.Name,$_.InitialSize,$_.MaximumSize }) -join '; ')
    }
    $pageMatches = (-not $State.AutomaticManagedPagefile -and (Get-SafeCount $pageSetting) -eq 1 -and [int]$pageSetting[0].InitialSize -eq $desiredPageFileMB -and [int]$pageSetting[0].MaximumSize -eq $desiredPageFileMB)
    [void]$results.Add((New-CheckResult -Category 'Operating System' -Name 'Recommended Page File' -Status $(if ($pageMatches) { 'PASS' } else { 'REVIEW' }) -Current $pageCurrent -Expected ("Initial=Maximum={0} MB ({1} GB), 25% of installed RAM" -f $desiredPageFileMB,$desiredPageFileGB) -Message 'Microsoft Exchange guidance: Initial and Maximum should be the same value: 25% of installed RAM. This script only reports the recommendation.'))

    $dotNetSupported = $false
    $dotNetRecommended = $false
    if ($osYear -eq '2019') {
        $dotNetSupported = ($State.DotNet.Release -and [int64]$State.DotNet.Release -ge 528040 -and [int64]$State.DotNet.Release -lt 533320)
        $dotNetRecommended = $dotNetSupported
    }
    elseif ($osYear -in @('2022','2025')) {
        $dotNetSupported = ($State.DotNet.Release -and [int64]$State.DotNet.Release -ge 528040)
        $dotNetRecommended = ($State.DotNet.Release -and [int64]$State.DotNet.Release -ge 533320)
    }

    if ($dotNetSupported) {
        $message = if ($dotNetRecommended) { '' } else { '.NET Framework 4.8 is supported; 4.8.1 is recommended on Windows Server 2022/2025.' }
        [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name '.NET Framework' -Status PASS -Current $State.DotNet.Version -Expected $(if ($osYear -eq '2019') { '4.8' } else { '4.8 or 4.8.1 (4.8.1 recommended)' }) -Message $message))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name '.NET Framework' -Status BLOCKER -Current $State.DotNet.Version -Expected $(if ($osYear -eq '2019') { '4.8' } else { '4.8 or 4.8.1 (4.8.1 recommended)' }) -Message 'Install a supported .NET Framework version before Exchange Setup.'))
    }

    $requiredFeatures = @(Get-RequiredWindowsFeatures -State $State)
    if ((Get-SafeCount $State.WindowsFeatures) -eq 0) {
        [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name 'Windows Features' -Status BLOCKER -Current 'Unable to query Get-WindowsFeature' -Expected 'Required Exchange SE Mailbox Windows Features'))
    }
    else {
        $missingFeatures = @()
        $featureTable = @{}
        foreach ($installedFeature in @($State.WindowsFeatures)) {
            if ($null -ne $installedFeature -and -not [string]::IsNullOrWhiteSpace([string]$installedFeature.Name)) {
                $featureTable[[string]$installedFeature.Name] = $installedFeature
            }
        }

        foreach ($featureName in $requiredFeatures) {
            if (-not $featureTable.ContainsKey($featureName) -or -not [bool]$featureTable[$featureName].Installed) {
                $missingFeatures += $featureName
            }
        }
        if ((Get-SafeCount $missingFeatures) -eq 0) {
            [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name 'Windows Features' -Status PASS -Current 'All required Exchange SE Mailbox features installed' -Expected 'Complete'))
        }
        else {
            [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name 'Windows Features' -Status BLOCKER -Current ("Missing: {0}" -f ($missingFeatures -join ', ')) -Expected 'All required Exchange SE Mailbox Windows Features installed' -Message 'Exchange Setup can install supported Windows components by using the prerequisite option or /InstallWindowsComponents.'))
        }
    }

    if ($State.RemoteRegistry -and $State.RemoteRegistry.StartMode -eq 'Auto') {
        [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name 'Remote Registry' -Status PASS -Current "$($State.RemoteRegistry.StartMode) / $($State.RemoteRegistry.State)" -Expected 'Startup type Automatic (not Disabled)'))
    }
    else {
        $rrCurrent = if ($State.RemoteRegistry) { "$($State.RemoteRegistry.StartMode) / $($State.RemoteRegistry.State)" } else { 'Service not found' }
        [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name 'Remote Registry' -Status BLOCKER -Current $rrCurrent -Expected 'Startup type Automatic (not Disabled)' -Message 'Microsoft Exchange prerequisites require the Remote Registry service startup type to be Automatic.'))
    }

    $vc2012Text = [string]$State.InstalledAppCache.VC2012
    $vc2012Installed = -not [string]::IsNullOrWhiteSpace($vc2012Text)
    [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name 'Visual C++ 2012 x64' -Status $(if ($vc2012Installed) { 'PASS' } else { 'BLOCKER' }) -Current $(if ($vc2012Installed) { $vc2012Text } else { 'Not detected' }) -Expected 'Installed' -Message $(if ($vc2012Installed) { '' } else { 'Install the Microsoft Visual C++ 2012 x64 Redistributable before Exchange Setup.' })))

    $vc2013Text = [string]$State.InstalledAppCache.VC2013
    $vc2013Installed = -not [string]::IsNullOrWhiteSpace($vc2013Text)
    [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name 'Visual C++ 2013 x64' -Status $(if ($vc2013Installed) { 'PASS' } else { 'BLOCKER' }) -Current $(if ($vc2013Installed) { $vc2013Text } else { 'Not detected' }) -Expected 'Installed' -Message $(if ($vc2013Installed) { '' } else { 'Install the Microsoft Visual C++ 2013 x64 Redistributable before Exchange Setup.' })))

    $vc2015To2022Text = [string]$State.InstalledAppCache.VC2015To2022
    [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name 'Visual C++ 2015-2022 x64' -Status INFO -Current $(if ([string]::IsNullOrWhiteSpace($vc2015To2022Text)) { 'Not detected' } else { $vc2015To2022Text }) -Expected 'Visibility only' -Message 'Reported for inventory visibility. This check is not used as an Exchange SE readiness blocker.'))

    $ucmaText = [string]$State.InstalledAppCache.UCMA40
    $ucmaInstalled = -not [string]::IsNullOrWhiteSpace($ucmaText)
    [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name 'Unified Communications Managed API 4.0' -Status $(if ($ucmaInstalled) { 'PASS' } else { 'BLOCKER' }) -Current $(if ($ucmaInstalled) { $ucmaText } else { 'Not detected' }) -Expected 'Installed' -Message $(if ($ucmaInstalled) { '' } else { 'Install UCMA 4.0 before Exchange Setup. The installer is also available in the UCMARedist folder on Exchange media.' })))

    $urlRewriteText = [string]$State.InstalledAppCache.URLRewrite
    $urlRewriteInstalled = -not [string]::IsNullOrWhiteSpace($urlRewriteText)
    [void]$results.Add((New-CheckResult -Category 'Prerequisites' -Name 'IIS URL Rewrite Module 2' -Status $(if ($urlRewriteInstalled) { 'PASS' } else { 'BLOCKER' }) -Current $(if ($urlRewriteInstalled) { $urlRewriteText } else { 'Not detected' }) -Expected 'Installed' -Message $(if ($urlRewriteInstalled) { '' } else { 'Install IIS URL Rewrite Module before Exchange Setup.' })))

    if ($State.ExchangeSetupHistory.Exists) {
        $setupLogSizeMB = [math]::Round(([int64]$State.ExchangeSetupHistory.LengthBytes / 1MB), 2)
        $setupLogCurrent = "{0}; LastWrite={1}; Size={2} MB" -f $State.ExchangeSetupHistory.Path,$State.ExchangeSetupHistory.LastWriteTime,$setupLogSizeMB
        [void]$results.Add((New-CheckResult -Category 'Exchange Setup History' -Name 'Exchange Setup Log' -Status INFO -Current $setupLogCurrent -Expected 'Review only if Exchange Setup was previously attempted' -Message 'Previous Exchange Setup activity was detected. If a prior setup failed, review ExchangeSetup.log with Microsoft CSS-Exchange SetupLogReviewer.'))
    }
    elseif (-not [string]::IsNullOrWhiteSpace([string]$State.ExchangeSetupHistory.Error)) {
        [void]$results.Add((New-CheckResult -Category 'Exchange Setup History' -Name 'Exchange Setup Log' -Status INFO -Current $State.ExchangeSetupHistory.Error -Expected 'Visibility only' -Message 'The setup log path could not be checked.'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Exchange Setup History' -Name 'Exchange Setup Log' -Status INFO -Current ("Not found: {0}" -f $State.ExchangeSetupHistory.Path) -Expected 'Visibility only'))
    }

    $tls12 = @($State.TlsBaseline | Where-Object { $_.Protocol -eq 'TLS 1.2' })
    $tls12Disabled = @($tls12 | Where-Object { $_.State -eq 'Disabled' })
    $tls12Current = @($tls12 | ForEach-Object { "{0}={1}" -f $_.Role,$_.State }) -join '; '
    if ((Get-SafeCount $tls12Disabled) -gt 0) {
        [void]$results.Add((New-CheckResult -Category 'TLS' -Name 'TLS 1.2' -Status BLOCKER -Current $tls12Current -Expected 'TLS 1.2 not explicitly disabled for SCHANNEL Client/Server' -Message 'TLS 1.2 is required for the Exchange security baseline. Review SCHANNEL protocol policy before installation.'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'TLS' -Name 'TLS 1.2' -Status PASS -Current $tls12Current -Expected 'TLS 1.2 available for SCHANNEL Client/Server'))
    }

    foreach ($legacyProtocol in @('TLS 1.0','TLS 1.1','TLS 1.3')) {
        $protocolRows = @($State.TlsBaseline | Where-Object { $_.Protocol -eq $legacyProtocol })
        $protocolCurrent = @($protocolRows | ForEach-Object { "{0}={1}" -f $_.Role,$_.State }) -join '; '
        [void]$results.Add((New-CheckResult -Category 'TLS' -Name $legacyProtocol -Status INFO -Current $protocolCurrent -Expected 'Review against the current Exchange/Windows TLS security design' -Message 'Informational SCHANNEL visibility only; this result is not used as an installation blocker.'))
    }

    $defender = $State.Antimalware
    if ($defender.StatusCmdletAvailable) {
        $defenderCurrent = "AMService={0}; Antivirus={1}; RealTimeProtection={2}" -f $defender.AMServiceEnabled,$defender.AntivirusEnabled,$defender.RealTimeProtectionEnabled
        if (-not [string]::IsNullOrWhiteSpace([string]$defender.StatusError)) { $defenderCurrent = "Status query failed: {0}" -f $defender.StatusError }
        [void]$results.Add((New-CheckResult -Category 'Security / Antimalware' -Name 'Microsoft Defender Antivirus' -Status INFO -Current $defenderCurrent -Expected 'Visibility only'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Security / Antimalware' -Name 'Microsoft Defender Antivirus' -Status INFO -Current 'Defender PowerShell cmdlets not available' -Expected 'Visibility only'))
    }

    if ($defender.PreferenceCmdletAvailable -and [string]::IsNullOrWhiteSpace([string]$defender.PreferenceError)) {
        $pathCount = Get-SafeCount $defender.ExclusionPaths
        $processCount = Get-SafeCount $defender.ExclusionProcesses
        $extensionCount = Get-SafeCount $defender.ExclusionExtensions
        $exclusionCurrent = "Paths={0}; Processes={1}; Extensions={2}" -f $pathCount,$processCount,$extensionCount
        $exclusionDetails = @()
        if ($pathCount -gt 0) { $exclusionDetails += "Paths: $(@($defender.ExclusionPaths) -join ', ')" }
        if ($processCount -gt 0) { $exclusionDetails += "Processes: $(@($defender.ExclusionProcesses) -join ', ')" }
        if ($extensionCount -gt 0) { $exclusionDetails += "Extensions: $(@($defender.ExclusionExtensions) -join ', ')" }
        $defenderNote = 'Validate the required Exchange Server antivirus exclusions before installation.'
        if ((Get-SafeCount $exclusionDetails) -gt 0) { $defenderNote += " Current exclusions: $($exclusionDetails -join ' | ')" }
        [void]$results.Add((New-CheckResult -Category 'Security / Antimalware' -Name 'Microsoft Defender Exclusions' -Status INFO -Current $exclusionCurrent -Expected 'Exchange Server exclusions reviewed before installation' -Message $defenderNote))
    }
    else {
        $prefCurrent = if (-not [string]::IsNullOrWhiteSpace([string]$defender.PreferenceError)) { $defender.PreferenceError } else { 'Get-MpPreference not available' }
        [void]$results.Add((New-CheckResult -Category 'Security / Antimalware' -Name 'Microsoft Defender Exclusions' -Status INFO -Current $prefCurrent -Expected 'Exchange Server exclusions reviewed before installation'))
    }

    [void]$results.Add((New-CheckResult -Category 'Security / Antimalware' -Name 'Antivirus / EDR Exclusions' -Status INFO -Current 'Manual validation required for non-Microsoft security products' -Expected 'Validate Exchange Server exclusions before installation' -Message 'If third-party antivirus, EDR, application control, or other security software is installed, review and configure the required Exchange Server exclusions before installation.'))

    if ($State.CredentialGuard.Enabled) {
        [void]$results.Add((New-CheckResult -Category 'Security' -Name 'Credential Guard' -Status BLOCKER -Current ("Enabled (LsaCfgFlags={0}; Running={1})" -f $State.CredentialGuard.LsaCfgFlags,($State.CredentialGuard.SecurityServicesRunning -join ',')) -Expected 'Disabled for Exchange Server' -Message 'Review the organization security/GPO configuration before Exchange installation.'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Security' -Name 'Credential Guard' -Status PASS -Current 'Not detected as enabled' -Expected 'Disabled for Exchange Server'))
    }

    $powerGuid = [string]$State.PowerPlan.Guid
    if ($powerGuid -eq '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c') {
        [void]$results.Add((New-CheckResult -Category 'Performance' -Name 'Power Plan' -Status PASS -Current $State.PowerPlan.Name -Expected 'High performance'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Performance' -Name 'Power Plan' -Status REVIEW -Current $State.PowerPlan.Name -Expected 'Review for Exchange workload / CPU throttling'))
    }

    $countryOrRegion = if ($State.CountryOrRegion) { [string]$State.CountryOrRegion } else { '<Unknown>' }
    $formatName = if ($State.CultureDisplayName) { [string]$State.CultureDisplayName } else { '<Unknown>' }
    $systemLocaleDisplayName = if ($State.SystemLocaleDisplayName) { [string]$State.SystemLocaleDisplayName } else { '<Unknown>' }
    $displayLanguage = if ($State.UICultureDisplayName) { [string]$State.UICultureDisplayName } else { '<Unknown>' }
    $timeZoneName = if ($State.TimeZoneId) { [string]$State.TimeZoneId } else { '<Unknown>' }

    $countryStatus = if ($countryOrRegion -eq 'United States') { 'PASS' } elseif ($countryOrRegion -eq '<Unknown>') { 'REVIEW' } else { 'BLOCKER' }
    [void]$results.Add((New-CheckResult -Category 'Region' -Name 'Country or region' -Status $countryStatus -Current $countryOrRegion -Expected 'United States' -Message $(if ($countryStatus -eq 'REVIEW') { 'The Windows home location could not be read.' } else { '' })))

    $formatStatus = if ([string]$State.CultureName -eq 'en-US') { 'PASS' } elseif ($formatName -eq '<Unknown>') { 'REVIEW' } else { 'BLOCKER' }
    [void]$results.Add((New-CheckResult -Category 'Region' -Name 'Format' -Status $formatStatus -Current $formatName -Expected 'English (United States)' -Message $(if ($formatStatus -eq 'REVIEW') { 'The current user regional format could not be read.' } else { '' })))

    $systemLocaleStatus = if ([string]$State.SystemLocaleName -eq 'en-US') { 'PASS' } elseif ($systemLocaleDisplayName -eq '<Unknown>') { 'REVIEW' } else { 'BLOCKER' }
    [void]$results.Add((New-CheckResult -Category 'Region' -Name 'Current system locale' -Status $systemLocaleStatus -Current $systemLocaleDisplayName -Expected 'English (United States)' -Message $(if ($systemLocaleStatus -eq 'REVIEW') { 'The Windows system locale could not be read.' } else { '' })))

    $displayLanguageStatus = if ([string]$State.UICultureName -eq 'en-US') { 'PASS' } elseif ($displayLanguage -eq '<Unknown>') { 'REVIEW' } else { 'BLOCKER' }
    [void]$results.Add((New-CheckResult -Category 'Region' -Name 'Display language' -Status $displayLanguageStatus -Current $displayLanguage -Expected 'English (United States)' -Message $(if ($displayLanguageStatus -eq 'REVIEW') { 'The current user display language could not be read.' } else { '' })))

    if ($null -eq $State.Utf8BetaEnabled) {
        [void]$results.Add((New-CheckResult -Category 'Region' -Name 'Beta: Use Unicode UTF-8 for worldwide language support' -Status REVIEW -Current '<Unknown>' -Expected 'Off (unchecked)' -Message 'The system ANSI code page could not be read.'))
    }
    elseif ([bool]$State.Utf8BetaEnabled) {
        [void]$results.Add((New-CheckResult -Category 'Region' -Name 'Beta: Use Unicode UTF-8 for worldwide language support' -Status BLOCKER -Current 'On (checked)' -Expected 'Off (unchecked)' -Message 'Clear this option for the Exchange server regional baseline.'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Region' -Name 'Beta: Use Unicode UTF-8 for worldwide language support' -Status PASS -Current 'Off (unchecked)' -Expected 'Off (unchecked)'))
    }

    [void]$results.Add((New-CheckResult -Category 'Date & time' -Name 'Time zone' -Status REVIEW -Current $timeZoneName -Expected 'Must be consistent with the deployment design'))

    if ($State.IEEsc.Applicable) {
        [void]$results.Add((New-CheckResult -Category 'Security' -Name 'IE ESC - Administrators' -Status PASS -Current $State.IEEsc.AdministratorState -Expected 'Reported for visibility' -Message 'Current administrator state is reported for visibility.'))
        [void]$results.Add((New-CheckResult -Category 'Security' -Name 'IE ESC - Users' -Status REVIEW -Current $State.IEEsc.UserState -Expected 'Review the intended server baseline' -Message 'Current user state is reported for review.'))
    }
    else {
        [void]$results.Add((New-CheckResult -Category 'Security' -Name 'IE ESC - Administrators' -Status PASS -Current $State.IEEsc.AdministratorState -Expected 'Not applicable to Server Core'))
        [void]$results.Add((New-CheckResult -Category 'Security' -Name 'IE ESC - Users' -Status REVIEW -Current $State.IEEsc.UserState -Expected 'Not applicable to Server Core'))
    }

    return $results.ToArray()
}

function Get-CrossServerConsistencyChecks {
    param([Parameter(Mandatory = $true)][object[]]$Results)

    $connected = @($Results | Where-Object { $_.ConnectionStatus -eq 'Connected' -and $null -ne $_.State })
    if ((Get-SafeCount $connected) -lt 2) { return @() }

    $checks = New-Object System.Collections.Generic.List[object]

    $comparisons = @(
        [PSCustomObject]@{
            Name = 'Country or region'
            Values = @($connected | ForEach-Object {
                $value = if ($_.State.CountryOrRegion) { [string]$_.State.CountryOrRegion } else { '<Unknown>' }
                "{0}={1}" -f $_.Server,$value
            })
            Unique = @($connected | ForEach-Object {
                if ($_.State.CountryOrRegion) { [string]$_.State.CountryOrRegion } else { '<Unknown>' }
            } | Select-Object -Unique)
        },
        [PSCustomObject]@{
            Name = 'Format'
            Values = @($connected | ForEach-Object {
                $format = if ($_.State.CultureDisplayName) { [string]$_.State.CultureDisplayName } else { '<Unknown>' }
                $shortDate = if ($_.State.ShortDatePattern) { [string]$_.State.ShortDatePattern } else { '<Unknown>' }
                $decimal = if ($_.State.NumberDecimalSeparator) { [string]$_.State.NumberDecimalSeparator } else { '<Unknown>' }
                "{0}={1}; Short date={2}; Decimal symbol={3}" -f $_.Server,$format,$shortDate,$decimal
            })
            Unique = @($connected | ForEach-Object {
                $format = if ($_.State.CultureName) { [string]$_.State.CultureName } else { '<Unknown>' }
                $shortDate = if ($_.State.ShortDatePattern) { [string]$_.State.ShortDatePattern } else { '<Unknown>' }
                $decimal = if ($_.State.NumberDecimalSeparator) { [string]$_.State.NumberDecimalSeparator } else { '<Unknown>' }
                "{0}|{1}|{2}" -f $format,$shortDate,$decimal
            } | Select-Object -Unique)
        },
        [PSCustomObject]@{
            Name = 'Current system locale'
            Values = @($connected | ForEach-Object {
                $value = if ($_.State.SystemLocaleDisplayName) { [string]$_.State.SystemLocaleDisplayName } else { '<Unknown>' }
                "{0}={1}" -f $_.Server,$value
            })
            Unique = @($connected | ForEach-Object {
                if ($_.State.SystemLocaleName) { [string]$_.State.SystemLocaleName } else { '<Unknown>' }
            } | Select-Object -Unique)
        },
        [PSCustomObject]@{
            Name = 'Display language'
            Values = @($connected | ForEach-Object {
                $value = if ($_.State.UICultureDisplayName) { [string]$_.State.UICultureDisplayName } else { '<Unknown>' }
                "{0}={1}" -f $_.Server,$value
            })
            Unique = @($connected | ForEach-Object {
                if ($_.State.UICultureName) { [string]$_.State.UICultureName } else { '<Unknown>' }
            } | Select-Object -Unique)
        },
        [PSCustomObject]@{
            Name = 'Time zone'
            Values = @($connected | ForEach-Object {
                $value = if ($_.State.TimeZoneId) { [string]$_.State.TimeZoneId } else { '<Unknown>' }
                "{0}={1}" -f $_.Server,$value
            })
            Unique = @($connected | ForEach-Object {
                if ($_.State.TimeZoneId) { [string]$_.State.TimeZoneId } else { '<Unknown>' }
            } | Select-Object -Unique)
        }
    )
    foreach ($comparison in $comparisons) {
        $status = if ((Get-SafeCount $comparison.Unique) -eq 1) { 'PASS' } else { 'REVIEW' }
        $message = if ($status -eq 'PASS') {
            'Values are consistent across the checked servers.'
        }
        else {
            'Peer-server values differ. Confirm whether the difference is intentional before Exchange installation or production traffic.'
        }

        [void]$checks.Add((New-CheckResult -Category 'Cross-Server Consistency' -Name $comparison.Name -Status $status -Current ($comparison.Values -join ' | ') -Expected 'Consistent across peer Exchange servers' -Message $message))
    }

    return $checks.ToArray()
}

# ---------------------------------------------------------------------------
# Display / report helpers
# ---------------------------------------------------------------------------
$script:PagingEnabled = $false
$script:PagingLineCount = 0
$script:PagingPageHeight = 0
$script:PagingWindowWidth = 120

function Initialize-ResultPaging {
    $script:PagingEnabled = $false
    $script:PagingLineCount = 0
    $script:PagingPageHeight = 0
    $script:PagingWindowWidth = 120

    if ($InternalLocal -or $NoPaging -or -not [string]::IsNullOrWhiteSpace($OutputFile)) {
        return
    }

    try {
        $windowSize = $Host.UI.RawUI.WindowSize
        $height = [int]$windowSize.Height
        $width = [int]$windowSize.Width

        if ($height -ge 10 -and $width -ge 20) {
            # Reserve a few lines for the paging prompt and the next section header.
            $script:PagingPageHeight = [Math]::Max(5, ($height - 3))
            $script:PagingWindowWidth = [Math]::Max(20, $width)
            $script:PagingEnabled = $true
        }
    }
    catch {
        # Hosts without RawUI support simply print continuously.
        $script:PagingEnabled = $false
    }
}

function Reset-ResultPaging {
    $script:PagingLineCount = 0
}

function Get-ResultDisplayLineCount {
    param([AllowNull()][string]$Text)

    if ($null -eq $Text) { return 1 }

    $width = [Math]::Max(20, [int]$script:PagingWindowWidth)
    $count = 0
    foreach ($line in @($Text -split "`r`n|`n|`r")) {
        $length = [string]$line
        $count += [Math]::Max(1, [int][Math]::Ceiling(($length.Length + 1) / [double]$width))
    }
    return $count
}

function Invoke-ResultPagingPause {
    if (-not $script:PagingEnabled) { return }

    Write-Host ''
    $response = Read-Host 'Press ENTER to continue, or Q to stop paging'
    if ([string]$response -match '(?i)^q$') {
        $script:PagingEnabled = $false
    }
    $script:PagingLineCount = 0
}

function Write-ResultHost {
    param(
        [AllowNull()][string]$Text = '',
        [System.ConsoleColor]$ForegroundColor,
        [switch]$NoNewline
    )

    $lineCount = Get-ResultDisplayLineCount -Text $Text
    if ($script:PagingEnabled -and $script:PagingLineCount -gt 0 -and (($script:PagingLineCount + $lineCount) -gt $script:PagingPageHeight)) {
        Invoke-ResultPagingPause
    }

    if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
        Write-Host $Text -ForegroundColor $ForegroundColor -NoNewline:$NoNewline
    }
    else {
        Write-Host $Text -NoNewline:$NoNewline
    }

    if (-not $NoNewline) {
        $script:PagingLineCount += $lineCount
    }
}

function Get-StatusColor {
    param([string]$Status)
    switch ($Status) {
        'PASS'    { 'Green' }
        'BLOCKER' { 'Red' }
        'REVIEW'  { 'Cyan' }
        'INFO'    { 'DarkCyan' }
        default   { 'Gray' }
    }
}

function Show-CheckResults {
    param([Parameter(Mandatory = $true)][object[]]$Checks)

    $categories = @($Checks.Category | Select-Object -Unique)
    foreach ($category in $categories) {
        Write-ResultHost ''
        Write-ResultHost "[$category]" -ForegroundColor White
        foreach ($check in @($Checks | Where-Object { $_.Category -eq $category })) {
            $color = Get-StatusColor -Status $check.Status
            Write-ResultHost ("{0,-9} {1}" -f $check.Status,$check.Name) -ForegroundColor $color
            Write-ResultHost ("  Current : {0}" -f $check.Current) -ForegroundColor DarkGray
            if ($check.Expected -ne '<Not Set>') { Write-ResultHost ("  Expected: {0}" -f $check.Expected) -ForegroundColor DarkGray }
            if (-not [string]::IsNullOrWhiteSpace($check.Message)) { Write-ResultHost ("  Note    : {0}" -f $check.Message) -ForegroundColor DarkGray }
        }
    }

    $pass = (Get-SafeCount @($Checks | Where-Object { $_.Status -eq 'PASS' }))
    $blocker = (Get-SafeCount @($Checks | Where-Object { $_.Status -eq 'BLOCKER' }))
    $review = (Get-SafeCount @($Checks | Where-Object { $_.Status -eq 'REVIEW' }))
    $info = (Get-SafeCount @($Checks | Where-Object { $_.Status -eq 'INFO' }))
    Write-ResultHost ''
    Write-ResultHost ("Summary: PASS={0}  BLOCKER={1}  REVIEW={2}  INFO={3}" -f $pass,$blocker,$review,$info) -ForegroundColor White
}

function Get-CheckReportLines {
    param(
        [Parameter(Mandatory = $true)]$State,
        [Parameter(Mandatory = $true)][object[]]$Checks
    )

    $lines = New-Object System.Collections.Generic.List[string]
    [void]$lines.Add(("{0}.ps1  Version {1}" -f $script:ScriptBaseName,$script:ScriptVersion))
    [void]$lines.Add(('Report Time    : {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
    [void]$lines.Add(('Computer       : {0}' -f $State.ComputerName))
    [void]$lines.Add(('OS             : {0}' -f $State.OperatingSystem.Caption))
    [void]$lines.Add(('OS Build       : {0}' -f $State.OperatingSystem.BuildNumber))
    [void]$lines.Add(('Installation   : {0}' -f $State.RegistryOS.InstallationType))
    [void]$lines.Add(('Domain         : {0}' -f $State.ComputerSystem.Domain))
    [void]$lines.Add(('Primary DNS    : {0}' -f $State.PrimaryDnsSuffix))
    [void]$lines.Add(('AD Site        : {0}' -f $State.AD.Site))
    [void]$lines.Add(('Forest Level   : {0}' -f $State.ADFunctionalLevel.ForestMode))
    [void]$lines.Add('Mode           : Read-only server configuration check')
    [void]$lines.Add('')

    foreach ($category in @($Checks.Category | Select-Object -Unique)) {
        [void]$lines.Add("[$category]")
        foreach ($check in @($Checks | Where-Object { $_.Category -eq $category })) {
            [void]$lines.Add(("{0,-9} {1}" -f $check.Status,$check.Name))
            [void]$lines.Add(("  Current : {0}" -f $check.Current))
            [void]$lines.Add(("  Expected: {0}" -f $check.Expected))
            if (-not [string]::IsNullOrWhiteSpace($check.Message)) { [void]$lines.Add(("  Note    : {0}" -f $check.Message)) }
        }
        [void]$lines.Add('')
    }

    $pass = (Get-SafeCount @($Checks | Where-Object { $_.Status -eq 'PASS' }))
    $blocker = (Get-SafeCount @($Checks | Where-Object { $_.Status -eq 'BLOCKER' }))
    $review = (Get-SafeCount @($Checks | Where-Object { $_.Status -eq 'REVIEW' }))
    $info = (Get-SafeCount @($Checks | Where-Object { $_.Status -eq 'INFO' }))
    [void]$lines.Add(("Summary: PASS={0}  BLOCKER={1}  REVIEW={2}  INFO={3}" -f $pass,$blocker,$review,$info))
    return $lines.ToArray()
}

function Export-CheckReport {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$State,
        [Parameter(Mandatory = $true)][object[]]$Checks
    )

    $resolvedPath = Resolve-OutputFilePath -Path $Path
    $lines = @(Get-CheckReportLines -State $State -Checks $Checks)
    Set-Content -LiteralPath $resolvedPath -Value $lines -Encoding UTF8 -ErrorAction Stop
    return $resolvedPath
}

# ---------------------------------------------------------------------------
# Multi-server orchestration helpers
# ---------------------------------------------------------------------------
function Test-IsLocalTarget {
    param([Parameter(Mandatory = $true)][string]$ComputerName)

    $name = $ComputerName.Trim()
    if ([string]::IsNullOrWhiteSpace($name)) { return $true }
    if ($name -in @('.','localhost','127.0.0.1','::1')) { return $true }
    if ($name -ieq $env:COMPUTERNAME) { return $true }

    try {
        $localFqdn = [System.Net.Dns]::GetHostEntry($env:COMPUTERNAME).HostName
        if (-not [string]::IsNullOrWhiteSpace($localFqdn) -and $name -ieq $localFqdn) { return $true }
    }
    catch { }

    return $false
}

function New-ServerCheckFailureResult {
    param(
        [Parameter(Mandatory = $true)][string]$ComputerName,
        [Parameter(Mandatory = $true)][string]$Stage,
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )

    $check = [PSCustomObject]@{
        Category = 'Server Check'
        Name     = $Stage
        Status   = 'BLOCKER'
        Current  = "Check failed: {0}" -f $ErrorMessage
        Expected = 'Required base server information can be collected'
        Message  = 'Only this server was skipped. Other requested servers will continue.'
    }

    return [PSCustomObject]@{
        Server           = $ComputerName
        ConnectionStatus = 'CheckFailed'
        FailureStage     = $Stage
        Error            = $ErrorMessage
        State            = $null
        Checks           = @($check)
    }
}

function Invoke-LocalServerCheck {
    $serverName = [string]$env:COMPUTERNAME

    try {
        # Base state is required by many dependent checks. If it cannot be
        # collected reliably, skip only this server rather than emitting
        # misleading PASS/BLOCKER results from incomplete data.
        $state = Get-ServerState
    }
    catch {
        return New-ServerCheckFailureResult -ComputerName $serverName -Stage 'Server data collection' -ErrorMessage $_.Exception.Message
    }

    try {
        $checks = @(Get-ExchangePreparationChecks -State $state)
    }
    catch {
        # Individual readiness errors are normally handled by the trap inside
        # Get-ExchangePreparationChecks. This is the final server-level guard.
        return New-ServerCheckFailureResult -ComputerName $serverName -Stage 'Readiness check evaluation' -ErrorMessage $_.Exception.Message
    }

    return [PSCustomObject]@{
        Server           = [string]$state.ComputerName
        ConnectionStatus = 'Connected'
        FailureStage     = ''
        Error            = ''
        State            = $state
        Checks           = $checks
    }
}

function Get-RemoteConnectionFailureInfo {
    param(
        [Parameter(Mandatory = $true)][string]$ComputerName,
        [Parameter(Mandatory = $true)]$ErrorRecord
    )

    $message = [string]$ErrorRecord.Exception.Message
    $type = 'WinRM / PowerShell Remoting'

    if ($message -match '(?i)no such host|could not be resolved|name resolution|cannot find the computer|host is unknown') {
        $type = 'DNS resolution'
    }
    elseif ($message -match '(?i)access is denied|0x80070005') {
        $type = 'Access denied'
    }
    elseif ($message -match '(?i)authentication|credentials|kerberos|logon failure|0x8009030e|0x80090322') {
        $type = 'Authentication'
    }
    elseif ($message -match '(?i)winrm|wsman|cannot connect|connection.*failed|firewall|5985|5986') {
        $type = 'WinRM connectivity'
    }

    $probe = 'Test-WSMan was not available.'
    try {
        if ($null -ne (Get-Command Test-WSMan -ErrorAction SilentlyContinue)) {
            [void](Test-WSMan -ComputerName $ComputerName -ErrorAction Stop)
            $probe = 'Test-WSMan succeeded; the WSMan endpoint is reachable. Review authentication, authorization, or the PowerShell session configuration.'
        }
    }
    catch {
        $probe = "Test-WSMan also failed: {0}" -f $_.Exception.Message
    }

    [PSCustomObject]@{
        Type       = $type
        Message    = $message
        Diagnostic = $probe
    }
}

function New-ConnectionFailureResult {
    param(
        [Parameter(Mandatory = $true)][string]$ComputerName,
        [Parameter(Mandatory = $true)][string]$ErrorMessage,
        [string]$FailureType = 'WinRM / PowerShell Remoting',
        [string]$Diagnostic = ''
    )

    $current = "{0}: {1}" -f $FailureType,$ErrorMessage
    $note = 'The server was skipped. Other requested servers will continue.'
    if (-not [string]::IsNullOrWhiteSpace($Diagnostic)) { $note = "{0} {1}" -f $Diagnostic,$note }

    $check = [PSCustomObject]@{
        Category = 'Connection'
        Name     = 'Remote connectivity'
        Status   = 'BLOCKER'
        Current  = $current
        Expected = 'PowerShell Remoting / WinRM reachable with the current credentials'
        Message  = $note
    }

    return [PSCustomObject]@{
        Server           = $ComputerName
        ConnectionStatus = 'Failed'
        FailureStage     = 'Remote connectivity'
        Error            = $current
        State            = $null
        Checks           = @($check)
    }
}

function Invoke-ServerCheck {
    param([Parameter(Mandatory = $true)][string]$ComputerName)

    if (Test-IsLocalTarget -ComputerName $ComputerName) {
        return Invoke-LocalServerCheck
    }

    try {
        $target = $ComputerName
        $remoteResult = Invoke-Command -ComputerName $target -FilePath $PSCommandPath -ArgumentList @($true) -ErrorAction Stop
        $firstResult = @($remoteResult | Select-Object -First 1)
        if ((Get-SafeCount $firstResult) -eq 0) {
            return New-ConnectionFailureResult -ComputerName $ComputerName -ErrorMessage 'Remote command completed without returning a check result.'
        }
        return $firstResult[0]
    }
    catch {
        $failure = Get-RemoteConnectionFailureInfo -ComputerName $ComputerName -ErrorRecord $_
        return New-ConnectionFailureResult -ComputerName $ComputerName -ErrorMessage $failure.Message -FailureType $failure.Type -Diagnostic $failure.Diagnostic
    }
}

function Show-ServerCheckResult {
    param([Parameter(Mandatory = $true)]$Result)

    Write-ResultHost ''
    Write-ResultHost '==================================================' -ForegroundColor DarkGray
    Write-ResultHost ("Server: {0}" -f $Result.Server) -ForegroundColor Yellow
    Write-ResultHost '==================================================' -ForegroundColor DarkGray

    Show-CheckResults -Checks @($Result.Checks)
}

function Show-GroupedServerCheckResults {
    param([Parameter(Mandatory = $true)][object[]]$Results)

    $connected = @($Results | Where-Object { $_.ConnectionStatus -eq 'Connected' -and $null -ne $_.State })
    $failed = @($Results | Where-Object { $_.ConnectionStatus -ne 'Connected' -or $null -eq $_.State })

    Write-ResultHost ''
    Write-ResultHost '==================================================' -ForegroundColor DarkGray
    Write-ResultHost 'Grouped Results' -ForegroundColor Yellow
    Write-ResultHost '==================================================' -ForegroundColor DarkGray

    if ((Get-SafeCount $failed) -gt 0) {
        Write-ResultHost ''
        Write-ResultHost '[Server Check / Connection]' -ForegroundColor White
        foreach ($result in $failed) {
            $stage = if ($result.PSObject.Properties['FailureStage'] -and -not [string]::IsNullOrWhiteSpace([string]$result.FailureStage)) { [string]$result.FailureStage } else { 'Server check' }
            Write-ResultHost ("{0,-18} {1,-9} {2}: {3}" -f $result.Server,'BLOCKER',$stage,$result.Error) -ForegroundColor Red
        }
    }

    if ((Get-SafeCount $connected) -eq 0) {
        return
    }

    $orderedChecks = New-Object System.Collections.Generic.List[object]
    $seen = @{}
    foreach ($result in $connected) {
        foreach ($check in @($result.Checks)) {
            $key = "{0}`0{1}" -f [string]$check.Category,[string]$check.Name
            if (-not $seen.ContainsKey($key)) {
                $seen[$key] = $true
                [void]$orderedChecks.Add([PSCustomObject]@{
                    Category = [string]$check.Category
                    Name     = [string]$check.Name
                })
            }
        }
    }

    $categories = @($orderedChecks.ToArray() | ForEach-Object { $_.Category } | Select-Object -Unique)
    foreach ($category in $categories) {
        Write-ResultHost ''
        Write-ResultHost "[$category]" -ForegroundColor White

        foreach ($definition in @($orderedChecks.ToArray() | Where-Object { $_.Category -eq $category })) {
            Write-ResultHost $definition.Name -ForegroundColor Yellow

            $matchingChecks = New-Object System.Collections.Generic.List[object]
            foreach ($result in $connected) {
                $match = @($result.Checks | Where-Object {
                    $_.Category -eq $definition.Category -and $_.Name -eq $definition.Name
                } | Select-Object -First 1)

                if ((Get-SafeCount $match) -gt 0) {
                    $item = $match[0]
                    [void]$matchingChecks.Add($item)
                    $color = Get-StatusColor -Status $item.Status
                    Write-ResultHost ("  {0,-18} {1,-9} {2}" -f $result.Server,$item.Status,$item.Current) -ForegroundColor $color
                }
                else {
                    Write-ResultHost ("  {0,-18} {1,-9} {2}" -f $result.Server,'REVIEW','<Not returned>') -ForegroundColor Cyan
                }
            }

            $expected = @($matchingChecks.ToArray() | ForEach-Object { [string]$_.Expected } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_ -ne '<Not Set>' } | Select-Object -Unique)
            if ((Get-SafeCount $expected) -eq 1) {
                Write-ResultHost ("  Expected           : {0}" -f $expected[0]) -ForegroundColor DarkGray
            }

            $notes = @($matchingChecks.ToArray() | ForEach-Object { [string]$_.Message } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
            if ((Get-SafeCount $notes) -eq 1) {
                Write-ResultHost ("  Note               : {0}" -f $notes[0]) -ForegroundColor DarkGray
            }
        }
    }

    Write-ResultHost ''
    Write-ResultHost '[Summary]' -ForegroundColor White
    foreach ($result in $Results) {
        if ($result.ConnectionStatus -eq 'Connected' -and $null -ne $result.State) {
            $checks = @($result.Checks)
            $pass = @($checks | Where-Object { $_.Status -eq 'PASS' })
            $blocker = @($checks | Where-Object { $_.Status -eq 'BLOCKER' })
            $review = @($checks | Where-Object { $_.Status -eq 'REVIEW' })
            $info = @($checks | Where-Object { $_.Status -eq 'INFO' })
            Write-ResultHost ("{0,-18} PASS={1}  BLOCKER={2}  REVIEW={3}  INFO={4}" -f $result.Server,(Get-SafeCount $pass),(Get-SafeCount $blocker),(Get-SafeCount $review),(Get-SafeCount $info)) -ForegroundColor White
        }
        else {
            $failureSummary = if ($result.ConnectionStatus -eq 'Failed') { 'connection failed' } else { 'server check failed' }
            Write-ResultHost ("{0,-18} PASS=0  BLOCKER=1  REVIEW=0  INFO=0  ({1})" -f $result.Server,$failureSummary) -ForegroundColor Red
        }
    }
}

function Get-GroupedMultiServerReportLines {
    param(
        [Parameter(Mandatory = $true)][object[]]$Results,
        [object[]]$ComparisonChecks = @()
    )

    $lines = New-Object System.Collections.Generic.List[string]
    [void]$lines.Add(("{0}.ps1  Version {1}" -f $script:ScriptBaseName,$script:ScriptVersion))
    [void]$lines.Add(('Report Time : {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
    [void]$lines.Add('Mode        : Read-only server configuration check')
    [void]$lines.Add('Display     : Grouped by check')
    [void]$lines.Add(('Servers     : {0}' -f (@($Results | ForEach-Object { $_.Server }) -join ', ')))
    [void]$lines.Add('')

    $connected = @($Results | Where-Object { $_.ConnectionStatus -eq 'Connected' -and $null -ne $_.State })
    $failed = @($Results | Where-Object { $_.ConnectionStatus -ne 'Connected' -or $null -eq $_.State })

    if ((Get-SafeCount $failed) -gt 0) {
        [void]$lines.Add('[Server Check / Connection]')
        foreach ($result in $failed) {
            $stage = if ($result.PSObject.Properties['FailureStage'] -and -not [string]::IsNullOrWhiteSpace([string]$result.FailureStage)) { [string]$result.FailureStage } else { 'Server check' }
            [void]$lines.Add(("{0,-18} {1,-9} {2}: {3}" -f $result.Server,'BLOCKER',$stage,$result.Error))
        }
        [void]$lines.Add('')
    }

    if ((Get-SafeCount $connected) -gt 0) {
        $orderedChecks = New-Object System.Collections.Generic.List[object]
        $seen = @{}
        foreach ($result in $connected) {
            foreach ($check in @($result.Checks)) {
                $key = "{0}`0{1}" -f [string]$check.Category,[string]$check.Name
                if (-not $seen.ContainsKey($key)) {
                    $seen[$key] = $true
                    [void]$orderedChecks.Add([PSCustomObject]@{
                        Category = [string]$check.Category
                        Name     = [string]$check.Name
                    })
                }
            }
        }

        foreach ($category in @($orderedChecks.ToArray() | ForEach-Object { $_.Category } | Select-Object -Unique)) {
            [void]$lines.Add("[$category]")
            foreach ($definition in @($orderedChecks.ToArray() | Where-Object { $_.Category -eq $category })) {
                [void]$lines.Add($definition.Name)
                $matchingChecks = New-Object System.Collections.Generic.List[object]
                foreach ($result in $connected) {
                    $match = @($result.Checks | Where-Object {
                        $_.Category -eq $definition.Category -and $_.Name -eq $definition.Name
                    } | Select-Object -First 1)
                    if ((Get-SafeCount $match) -gt 0) {
                        $item = $match[0]
                        [void]$matchingChecks.Add($item)
                        [void]$lines.Add(("  {0,-18} {1,-9} {2}" -f $result.Server,$item.Status,$item.Current))
                    }
                    else {
                        [void]$lines.Add(("  {0,-18} {1,-9} {2}" -f $result.Server,'REVIEW','<Not returned>'))
                    }
                }

                $expected = @($matchingChecks.ToArray() | ForEach-Object { [string]$_.Expected } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_ -ne '<Not Set>' } | Select-Object -Unique)
                if ((Get-SafeCount $expected) -eq 1) { [void]$lines.Add(("  Expected           : {0}" -f $expected[0])) }
                $notes = @($matchingChecks.ToArray() | ForEach-Object { [string]$_.Message } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
                if ((Get-SafeCount $notes) -eq 1) { [void]$lines.Add(("  Note               : {0}" -f $notes[0])) }
            }
            [void]$lines.Add('')
        }
    }

    [void]$lines.Add('[Summary]')
    foreach ($result in $Results) {
        if ($result.ConnectionStatus -eq 'Connected' -and $null -ne $result.State) {
            $checks = @($result.Checks)
            [void]$lines.Add(("{0,-18} PASS={1}  BLOCKER={2}  REVIEW={3}  INFO={4}" -f $result.Server,
                (Get-SafeCount @($checks | Where-Object { $_.Status -eq 'PASS' })),
                (Get-SafeCount @($checks | Where-Object { $_.Status -eq 'BLOCKER' })),
                (Get-SafeCount @($checks | Where-Object { $_.Status -eq 'REVIEW' })),
                (Get-SafeCount @($checks | Where-Object { $_.Status -eq 'INFO' }))))
        }
        else {
            $failureSummary = if ($result.ConnectionStatus -eq 'Failed') { 'connection failed' } else { 'server check failed' }
            [void]$lines.Add(("{0,-18} PASS=0  BLOCKER=1  REVIEW=0  INFO=0  ({1})" -f $result.Server,$failureSummary))
        }
    }
    [void]$lines.Add('')

    if ((Get-SafeCount $ComparisonChecks) -gt 0) {
        [void]$lines.Add('==================================================')
        [void]$lines.Add('Cross-Server Consistency')
        [void]$lines.Add('==================================================')
        foreach ($check in $ComparisonChecks) {
            [void]$lines.Add(("{0,-9} {1}" -f $check.Status,$check.Name))
            [void]$lines.Add(("  Current : {0}" -f $check.Current))
            [void]$lines.Add(("  Expected: {0}" -f $check.Expected))
            if (-not [string]::IsNullOrWhiteSpace($check.Message)) { [void]$lines.Add(("  Note    : {0}" -f $check.Message)) }
        }
        [void]$lines.Add('')
    }

    return $lines.ToArray()
}

function Get-MultiServerReportLines {
    param(
        [Parameter(Mandatory = $true)][object[]]$Results,
        [object[]]$ComparisonChecks = @()
    )

    $lines = New-Object System.Collections.Generic.List[string]
    [void]$lines.Add(("{0}.ps1  Version {1}" -f $script:ScriptBaseName,$script:ScriptVersion))
    [void]$lines.Add(('Report Time : {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
    [void]$lines.Add('Mode        : Read-only server configuration check')
    [void]$lines.Add(('Servers     : {0}' -f (@($Results | ForEach-Object { $_.Server }) -join ', ')))
    [void]$lines.Add('')

    foreach ($result in $Results) {
        [void]$lines.Add('==================================================')
        [void]$lines.Add(("Server: {0}" -f $result.Server))
        [void]$lines.Add('==================================================')

        if ($result.ConnectionStatus -eq 'Connected' -and $null -ne $result.State) {
            foreach ($line in @(Get-CheckReportLines -State $result.State -Checks @($result.Checks))) {
                [void]$lines.Add($line)
            }
        }
        else {
            $stage = if ($result.PSObject.Properties['FailureStage'] -and -not [string]::IsNullOrWhiteSpace([string]$result.FailureStage)) { [string]$result.FailureStage } else { 'Server check' }
            [void]$lines.Add('[Server Check / Connection]')
            [void]$lines.Add(("BLOCKER   {0}" -f $stage))
            [void]$lines.Add(('  Current : {0}' -f $result.Error))
            [void]$lines.Add('  Expected: The server check can collect the required data and complete')
            [void]$lines.Add('  Note    : The server was skipped. Other requested servers continued.')
            [void]$lines.Add('')
            [void]$lines.Add('Summary: PASS=0  BLOCKER=1  REVIEW=0  INFO=0')
        }
        [void]$lines.Add('')
    }

    if ((Get-SafeCount $ComparisonChecks) -gt 0) {
        [void]$lines.Add('==================================================')
        [void]$lines.Add('Cross-Server Consistency')
        [void]$lines.Add('==================================================')
        foreach ($check in $ComparisonChecks) {
            [void]$lines.Add(("{0,-9} {1}" -f $check.Status,$check.Name))
            [void]$lines.Add(("  Current : {0}" -f $check.Current))
            [void]$lines.Add(("  Expected: {0}" -f $check.Expected))
            if (-not [string]::IsNullOrWhiteSpace($check.Message)) {
                [void]$lines.Add(("  Note    : {0}" -f $check.Message))
            }
        }
        [void]$lines.Add('')
    }

    return $lines.ToArray()
}

function Export-MultiServerReport {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object[]]$Results,
        [object[]]$ComparisonChecks = @(),
        [switch]$Grouped
    )

    $resolvedPath = Resolve-OutputFilePath -Path $Path
    if ($Grouped) {
        $lines = @(Get-GroupedMultiServerReportLines -Results $Results -ComparisonChecks $ComparisonChecks)
    }
    else {
        $lines = @(Get-MultiServerReportLines -Results $Results -ComparisonChecks $ComparisonChecks)
    }
    Set-Content -LiteralPath $resolvedPath -Value $lines -Encoding UTF8 -ErrorAction Stop
    return $resolvedPath
}

# Internal remoting entry point. It returns structured data and writes no report/configuration changes.
if ($InternalLocal) {
    Invoke-LocalServerCheck
    return
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
try {
    Write-Host ''
    Write-Host ("{0}.ps1" -f $script:ScriptBaseName) -ForegroundColor Yellow
    Write-Host 'Exchange Server SE Mailbox server readiness check' -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host 'Author  : Ceyhun Kirmizitas' -ForegroundColor Cyan
    Write-Host ("Version : {0}" -f $script:ScriptVersion) -ForegroundColor Cyan
    Write-Host 'Mode    : Read-only' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'This script does not make any changes to Windows or Exchange configuration.' -ForegroundColor Cyan
    Write-Host ''
    [void](Read-Host 'Press ENTER to start the checks')
    Write-Host ''
    Initialize-ResultPaging

    $targets = @()
    if ((Get-SafeCount $Server) -eq 0) {
        $targets = @($env:COMPUTERNAME)
    }
    else {
        $targets = @($Server | ForEach-Object { if ($null -ne $_) { $_.Trim() } } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
    }

    if ((Get-SafeCount $targets) -eq 0) {
        $targets = @($env:COMPUTERNAME)
    }

    if ($GroupBy -and $Detailed) { throw 'Use either -GroupBy or -Detailed, not both.' }
    $useGroupedDisplay = ($GroupBy -or ((Get-SafeCount $targets) -gt 1 -and -not $Detailed))

    $results = New-Object System.Collections.Generic.List[object]
    foreach ($target in $targets) {
        if ($useGroupedDisplay) {
            Write-Host ("Checking {0}..." -f $target) -NoNewline -ForegroundColor Cyan
        }

        $result = Invoke-ServerCheck -ComputerName $target
        [void]$results.Add($result)

        if ($useGroupedDisplay) {
            if ($result.ConnectionStatus -eq 'Connected') {
                Write-Host ' Completed' -ForegroundColor Green
            }
            else {
                Write-Host ' Failed' -ForegroundColor Red
            }
        }
        else {
            Show-ServerCheckResult -Result $result
        }
    }

    $comparisonChecks = @(Get-CrossServerConsistencyChecks -Results ($results.ToArray()))

    if ($useGroupedDisplay) {
        Write-Host ''
        Write-Host 'Generating grouped results...' -ForegroundColor DarkGray
        Reset-ResultPaging
        Show-GroupedServerCheckResults -Results ($results.ToArray())
    }

    if ((Get-SafeCount $comparisonChecks) -gt 0) {
        Write-ResultHost ''
        Write-ResultHost '==================================================' -ForegroundColor DarkGray
        Write-ResultHost 'Cross-Server Consistency' -ForegroundColor Yellow
        Write-ResultHost '==================================================' -ForegroundColor DarkGray
        Show-CheckResults -Checks $comparisonChecks
    }

    if (-not [string]::IsNullOrWhiteSpace($OutputFile)) {
        $outputPath = Export-MultiServerReport -Path $OutputFile -Results ($results.ToArray()) -ComparisonChecks $comparisonChecks -Grouped:$useGroupedDisplay
        Write-Host ''
        Write-Host ("Report exported: {0}" -f $outputPath) -ForegroundColor Green
    }

    Write-Host ''
    Write-Host 'Check complete. No server configuration changes were made.' -ForegroundColor Cyan
}
catch {
    Write-Host ''
    Write-Host 'Unexpected script error' -ForegroundColor Red
    Write-Host ("Message : {0}" -f $_.Exception.Message) -ForegroundColor Red
    if ($_.InvocationInfo.ScriptLineNumber) {
        Write-Host ("Line    : {0}" -f $_.InvocationInfo.ScriptLineNumber) -ForegroundColor Red
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$_.InvocationInfo.Line)) {
        Write-Host ("Code    : {0}" -f $_.InvocationInfo.Line.Trim()) -ForegroundColor Red
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$_.ScriptStackTrace)) {
        Write-Host ("Stack   : {0}" -f $_.ScriptStackTrace) -ForegroundColor DarkRed
    }
    Write-Host 'The script stopped because of an unexpected top-level error. No server configuration changes were made.' -ForegroundColor Red
}
