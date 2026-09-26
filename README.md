# CheckServerForExchangeSE.ps1

Read-only PowerShell readiness check for Exchange Server Subscription Edition (SE) Mailbox role installation.  
It checks one or more Windows Servers for operating system, Active Directory, DNS, network, storage, prerequisites, security, and other Exchange SE readiness requirements.

The script reports **PASS**, **BLOCKER**, **REVIEW**, and **INFO** results. It does not change Windows or Exchange configuration.

## Download

- [GitHub source](CheckServerForExchangeSE.ps1)
- [GitHub raw download](https://raw.githubusercontent.com/Ceyhun-Kirmizitas/CheckServerForExchangeSE.ps1/main/CheckServerForExchangeSE.ps1)

## What it checks

### Host and operating system

- Administrator/elevated PowerShell session
- Windows PowerShell 5.1
- Supported Windows Server version, edition, installation type, and x64 architecture
- Member server role instead of Domain Controller
- Windows Time service and current time source
- Pending reboot state

### Active Directory and DNS

- Domain membership
- Primary DNS suffix and server FQDN
- Active Directory forest functional level
- Active Directory site detection
- Writable domain controller and Global Catalog discovery
- Server FQDN DNS resolution
- DC Locator SRV records
- Kerberos SRV records
- Global Catalog SRV records
- Writable domain controller DNS resolution
- Global Catalog DNS resolution

### Network configuration

- DNS client configuration
- DHCP / stable IPv4 addressing
- IPv4 binding
- IPv6 adapter binding
- IPv4-over-IPv6 preference through `DisabledComponents`
- Windows LBFO NIC Teaming configuration and members

### Network adapter health

For each active network adapter where supported:

- Adapter description, link speed, and MTU
- Receive Side Scaling (RSS)
- RSS processor and receive queue information
- NIC power-saving configuration
- DNS registration
- Packets Received Discarded
- vmxnet3 awareness when packet discards are detected

### Hardware and performance

- Installed memory
- CPU sockets and logical processors
- Exchange page file baseline
- Windows power plan

### Storage

- System drive free space and file system
- Physical disk media information where available
- Non-system fixed-volume file system
- GPT/MBR partition style
- Disk and bus information
- 64 KB allocation unit size on non-system fixed volumes

### Exchange prerequisites

- .NET Framework
- Required Windows Features
- Remote Registry service
- Microsoft Visual C++ 2012 x64
- Microsoft Visual C++ 2013 x64
- Microsoft Visual C++ 2015-2022 x64 visibility
- Unified Communications Managed API 4.0
- IIS URL Rewrite Module 2

### TLS and security

- TLS 1.2 readiness
- TLS 1.0, TLS 1.1, and TLS 1.3 visibility
- Microsoft Defender Antivirus status
- Microsoft Defender exclusions
- Antivirus / EDR exclusion review reminder
- Credential Guard
- IE Enhanced Security Configuration for Administrators and Users

### Exchange Setup history

- Existing `C:\ExchangeSetupLogs\ExchangeSetup.log`
- Previous Exchange Setup activity
- Reference to Microsoft CSS-Exchange SetupLogReviewer for deeper analysis

### Regional settings and time zone

- Country or region
- Regional format
- Current system locale
- Display language
- Beta: Use Unicode UTF-8 for worldwide language support
- Time zone

### Multi-server consistency

When two or more servers are checked, the script also compares:

- Country or region
- Regional format
- Current system locale
- Display language
- Time zone

## Result types

- **PASS** - Expected readiness condition is met.
- **BLOCKER** - Must be fixed before Exchange installation, or does not meet the required deployment baseline.
- **REVIEW** - Needs review for the environment or does not match the preferred baseline.
- **INFO** - Information only and does not affect readiness counts.

## Requirements and behavior

- Windows PowerShell 5.1
- Administrator permissions
- PowerShell Remoting / WinRM for remote server checks
- The script is read-only and does not change Windows or Exchange configuration.
- When two or more servers are checked, results are grouped by check by default.
- Use `-Detailed` for server-by-server output.
- Use `-NoPaging` to disable console paging.
- Using `-OutputFile` creates a TXT report and disables console paging.

## Examples

Check the local server:

```powershell
.\CheckServerForExchangeSE.ps1
```

Check one remote server:

```powershell
.\CheckServerForExchangeSE.ps1 -Server EXSE01
```

Check multiple servers:

```powershell
.\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02,EXSE03
```

Show each server separately:

```powershell
.\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02 -Detailed
```

Run without console paging:

```powershell
.\CheckServerForExchangeSE.ps1 -NoPaging
```

Save a TXT report:

```powershell
.\CheckServerForExchangeSE.ps1 -Server EXSE01,EXSE02 -OutputFile C:\Temp\ExchangeSE-Readiness.txt
```

Show the built-in usage guide:

```powershell
.\CheckServerForExchangeSE.ps1 -Help
```

For full PowerShell help:

```powershell
Get-Help .\CheckServerForExchangeSE.ps1 -Full
```

## Notes

Some checks are based on the deployment baseline used by this script and may be stricter than a Microsoft product support requirement. Review **REVIEW** and **INFO** results in the context of your environment.

The script includes selected readiness checks inspired by practical Exchange Server deployment work and Microsoft guidance. It is not intended to replace Microsoft CSS-Exchange HealthChecker.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Feedback and issues

For feedback, bugs, and feature requests, please use this repository's [GitHub Issues](https://github.com/Ceyhun-Kirmizitas/CheckServerForExchangeSE.ps1/issues).

## License

MIT. See [LICENSE](LICENSE).
