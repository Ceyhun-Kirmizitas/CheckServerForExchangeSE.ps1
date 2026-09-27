# ExchangeServerReadinessCheck.ps1

Read-only, role-aware PowerShell readiness checks for **Exchange Server Subscription Edition (SE)**.

The script validates one local server, one remote server, or multiple remote servers before Exchange Setup. It supports the **Mailbox**, **ManagementTools**, and **EdgeTransport** roles and reports findings as **PASS**, **BLOCKER**, **REVIEW**, or **INFO**.

It does not change Windows or Exchange configuration.

## Download

- [ExchangeServerReadinessCheck.ps1](ExchangeServerReadinessCheck.ps1)
- [Raw download](https://raw.githubusercontent.com/Ceyhun-Kirmizitas/ExchangeServerReadinessCheck.ps1/main/ExchangeServerReadinessCheck.ps1)
- [Usage article and screenshots](https://ceyhunkirmizitas.net/exchange-server-se-readiness-check/)

## Roles

### Mailbox

Performs the full Exchange server readiness evaluation and automatically selects the matching Windows Feature baseline for **Server Core** or **Server with Desktop Experience**.

### ManagementTools

Validates the supported **Exchange Server SE Management Tools** prerequisite scope on both supported Windows Server and Windows client systems.

Supported client systems include **Windows 11** and **Windows 10 64-bit**. On Windows clients, the script validates `IIS-ManagementConsole` and `IIS-Metabase`. On Windows Server, it validates `Web-Mgmt-Console` and `Web-Metabase` and requires **Server with Desktop Experience**.

### EdgeTransport

Uses the Edge Transport prerequisite and readiness scope without Mailbox-only checks.

## What it checks

### Host and operating system

- Elevated Windows PowerShell session
- Windows PowerShell 5.1
- Supported Windows Server version, edition, x64 architecture, and installation type
- Windows Time service and time source
- Pending reboot
- Page file guidance

### Active Directory, DNS, and permissions

- Domain membership where applicable
- Primary DNS suffix and server FQDN
- Forest functional level
- Active Directory site
- Writable domain controller and Global Catalog
- Server FQDN and Exchange-related DNS/SRV resolution
- Current user effective access-token visibility for Exchange Organization Management, Domain Admins, Enterprise Admins, and Schema Admins
- FSMO role holders and Schema Master site visibility

### Network

- Configured DNS servers per active adapter
- DHCP / stable IPv4 addressing
- IPv4 and IPv6 bindings
- IPv6 `DisabledComponents` policy
- Link speed and MTU
- Receive Side Scaling (RSS)
- NIC power-saving configuration
- DNS registration
- LBFO NIC Teaming

### Hardware, performance, and storage

- Installed memory
- CPU sockets and logical processors
- Windows power plan
- System drive information
- Physical disk media and bus information where available
- Non-system fixed-volume file system and partition style
- Allocation unit size visibility

The script does **not** assume every non-system volume is an Exchange data volume. A 64 KB allocation unit is treated as the recommended baseline when the volume will host Exchange database or transaction log files.

### Role-aware Exchange prerequisites

Depending on the selected role, checks include:

- .NET Framework
- Required Windows Features
- Remote Registry
- Microsoft Visual C++ 2012 x64
- Microsoft Visual C++ 2013 x64
- Microsoft Visual C++ 2015-2022 x64 visibility
- Unified Communications Managed API 4.0
- IIS URL Rewrite Module 2
- Active Directory Lightweight Directory Services (AD LDS)

### TLS and security

- TLS 1.2 readiness
- .NET Framework 4.x TLS settings
- TLS 1.0, TLS 1.1, and TLS 1.3 SCHANNEL visibility
- Microsoft Defender Antivirus status and exclusions
- Third-party antivirus / EDR exclusion reminder
- Credential Guard
- IE Enhanced Security Configuration visibility

### Exchange Setup history

- Existing `C:\ExchangeSetupLogs\ExchangeSetup.log`
- Previous Exchange Setup activity
- Microsoft CSS-Exchange SetupLogReviewer reference

### Regional settings and multi-server consistency

- Country or region
- Current user format
- Current system locale
- Current user display language
- Beta UTF-8 setting
- Time zone

When two or more servers are checked, the script compares selected regional and time zone values across the servers.

## Parameters

| Parameter | Description | Notes |
|---|---|---|
| `-Role` | Selects the Exchange SE role to validate. | `Mailbox`, `ManagementTools`, or `EdgeTransport`. Mailbox is the default for parameterized/unattended runs. |
| `-Server` | Checks one or more remote servers. | Uses Windows PowerShell Remoting / WinRM with the current credentials. |
| `-OutputFile` | Saves results to a TXT report. | Multiple servers are written to one combined report. Also disables console paging. |
| `-GroupBy` | Groups multi-server results by check. | Already the default when two or more servers are checked. |
| `-Detailed` | Displays results server by server. | Use when grouped output is not wanted. |
| `-NoPaging` | Prints console output continuously. | Also disables paging for `-Help`. |
| `-NonInteractive` | Runs without interactive prompts. | Intended for scheduled tasks, pipelines, and unattended execution. |
| `-Help` | Displays the built-in usage guide. | Use with `-NoPaging` for continuous output. |

## Examples

Interactive local check:

```powershell
.\ExchangeServerReadinessCheck.ps1
```

Mailbox role:

```powershell
.\ExchangeServerReadinessCheck.ps1 -Role Mailbox
```

Management Tools:

```powershell
.\ExchangeServerReadinessCheck.ps1 -Role ManagementTools
```

Edge Transport:

```powershell
.\ExchangeServerReadinessCheck.ps1 -Role EdgeTransport
```

One remote server:

```powershell
.\ExchangeServerReadinessCheck.ps1 -Server EXSE01
```

Multiple servers, grouped by check by default:

```powershell
.\ExchangeServerReadinessCheck.ps1 -Server EXSE01,EXSE02,EXSE03
```

Server-by-server output:

```powershell
.\ExchangeServerReadinessCheck.ps1 -Server EXSE01,EXSE02 -Detailed
```

Unattended execution:

```powershell
.\ExchangeServerReadinessCheck.ps1 -NonInteractive
```

Save one combined TXT report:

```powershell
.\ExchangeServerReadinessCheck.ps1 -Server EXSE01,EXSE02 -OutputFile C:\Temp\ExchangeSE-Readiness.txt
```

Built-in help:

```powershell
.\ExchangeServerReadinessCheck.ps1 -Help
```

Full PowerShell help:

```powershell
Get-Help .\ExchangeServerReadinessCheck.ps1 -Full
```

## Result types

- **PASS** - The expected readiness condition is met.
- **BLOCKER** - Exchange Setup is expected to fail, or the configuration is explicitly unsupported.
- **REVIEW** - The item needs review because it is a recommendation, preferred deployment baseline, or environment-specific decision.
- **INFO** - Information only and does not affect readiness counts.

## Behavior

- The script is read-only.
- Fully interactive execution displays a role selector. Pressing ENTER selects Mailbox.
- Operational parameters bypass the startup confirmation.
- If one remote server fails, the script reports the failure and continues with the remaining servers.
- Two or more servers are grouped by check by default.
- Use `-Detailed` for server-by-server output.
- Console output uses paging unless it is disabled with `-NoPaging`, `-NonInteractive`, or `-OutputFile`.

## Notes

The script is intended as a pre-installation readiness aid and does not replace Microsoft CSS-Exchange HealthChecker.

Always review the findings against the current Microsoft Exchange Server prerequisites, system requirements, supportability matrix, and your deployment design.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Feedback and issues

For bugs, feedback, or feature requests, use [GitHub Issues](https://github.com/Ceyhun-Kirmizitas/ExchangeServerReadinessCheck.ps1/issues).

## License

MIT. See [LICENSE](LICENSE).
