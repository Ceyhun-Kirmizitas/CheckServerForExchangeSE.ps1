# CheckServerForExchangeSE.ps1

Read-only PowerShell readiness check for Exchange Server Subscription Edition (SE) Mailbox role installation.

The script checks Windows Server readiness before Exchange SE installation and reports **PASS**, **BLOCKER**, **REVIEW**, and **INFO** results. It does not change Windows or Exchange configuration.

## Download

- [GitHub source](CheckServerForExchangeSE.ps1)
- [GitHub raw download](https://raw.githubusercontent.com/Ceyhun-Kirmizitas/CheckServerForExchangeSE.ps1/main/CheckServerForExchangeSE.ps1)

## What it checks

- Windows Server version, edition, architecture, and Windows PowerShell
- Domain membership, primary DNS suffix, server FQDN, Active Directory site, and functional levels
- Writable domain controller and Global Catalog availability
- DNS SRV records and server/DC/GC name resolution
- Active network adapters, DNS servers, DHCP, IPv4/IPv6 bindings, and IPv6 preference
- RSS, link speed, MTU, DNS registration, NIC power management, NIC Teaming, and packet discards
- Windows Time, pending reboot, CPU, memory, page file, and power plan
- File system, allocation unit size, disk partition style, media type, and bus type
- Required Windows Features and Exchange prerequisite packages
- TLS/SCHANNEL configuration
- Microsoft Defender status and exclusions
- Previous Exchange Setup log activity
- Credential Guard, IE Enhanced Security Configuration, regional settings, and time zone
- Regional and time zone consistency across multiple servers

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
