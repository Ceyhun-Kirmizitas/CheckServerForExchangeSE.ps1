# Changelog

All notable changes to ExchangeServerReadinessCheck.ps1 are documented here.

## 1.4 - 27/09/2026

- Added Exchange Server SE Management Tools readiness support for Windows 10/11 64-bit client operating systems.
- Added the Windows client Management Tools feature baseline: `IIS-ManagementConsole` and `IIS-Metabase`.
- Windows Server Management Tools checks continue to use `Web-Mgmt-Console` and `Web-Metabase` and require Desktop Experience.
- Updated Management Tools OS evaluation so supported Windows clients are not incorrectly blocked by Windows Server checks.
- Updated Management Tools .NET and prerequisite reporting for Windows client systems.
- Improved Windows client feature collection so `IIS-ManagementConsole` and `IIS-Metabase` are queried independently and per-feature query failures are reported without hiding successfully collected feature states.
- Changed console paging Q behavior so it stops further paged console output while requested checks, report generation, and exit-code calculation continue.
- Prevented unreadable SCHANNEL, Credential Guard, and network data from producing false PASS results.
- Added same-site writable Global Catalog validation for the Exchange server AD site.
- Added documented process exit codes: 0=no blocker, 1=blocker, 2=incomplete due to connection/collection/evaluation error.
- Preserved per-server Expected and Note values in grouped console and TXT output when they differ.
- Changed disabled NIC dynamic DNS registration from Mailbox BLOCKER to REVIEW and added manual-DNS guidance.
- Updated server FQDN DNS validation to compare returned A/AAAA addresses with active local IPv4/IPv6 addresses.
- Updated cross-server consistency so unknown peer values cannot be reported as PASS.
- Fixed ManagementTools exit-code evaluation when no cross-server comparison checks are generated.

## 1.3 - 27/09/2026

- Renamed the script to `ExchangeServerReadinessCheck.ps1` to match the broader role-aware readiness scope.
- Added `-Role` with `Mailbox`, `ManagementTools`, and `EdgeTransport` values.
- Added interactive role selection; pressing ENTER selects Mailbox.
- Added role-aware prerequisite evaluation for Mailbox, Management Tools, and Edge Transport.
- Added Server Core vs Server with Desktop Experience detection and automatic Mailbox prerequisite baseline selection.
- Added Windows Server Management Tools prerequisite validation.
- Added Edge Transport prerequisite validation, including AD LDS.
- Added current-user effective access-token visibility for Exchange Organization Management, Domain Admins, Enterprise Admins, and Schema Admins.
- Added FSMO role holder and Schema Master site visibility.
- Added `-NonInteractive` for unattended execution.
- Operational parameters now bypass the startup confirmation and use Mailbox when `-Role` is omitted.
- Added paging to built-in `-Help`; use `-Help -NoPaging` for continuous output.
- Fixed console paging so Q stops the remaining console output immediately.
- Refined BLOCKER semantics so hard blockers are reserved for unsupported or clearly setup-breaking conditions.
- Changed regional settings to environment-specific REVIEW results instead of enforcing an en-US baseline.
- Updated regional check names to distinguish current-user settings from system-wide settings.
- Refined storage reporting so non-system volumes are not automatically treated as Exchange database/log volumes.
- Removed Packets Received Discarded readiness evaluation.
- Updated IPv6 logic so Windows default behavior and `DisabledComponents=0x20` are accepted; disabling or unbinding IPv6 is flagged for review.
- Added .NET Framework 4.x TLS checks for `SystemDefaultTlsVersions` and `SchUseStrongCrypto`.
- Improved permission wording to clarify that membership results come from the effective Windows access token.
- Improved Windows Server release detection using build number, ProductName, InstallationType, and EditionID.
- Improved Server Core-aware UCMA guidance.
- Updated role propagation for local, remote, console, and TXT report output.

## 1.2 - 27/09/2026

- Changed `DNS Client` to `Configured DNS Servers` and now shows DNS server addresses per active network adapter.
- Improved the built-in help and description with a clearer summary of the readiness checks.
- Updated the script date to 27/09/2026.

## 1.1 - 26/09/2026

- Renamed the script to `CheckServerForExchangeSE.ps1`. The version is kept inside the script and in Git history/releases.
- Improved error handling so one failed check does not stop the remaining checks.
- Added active NIC checks for RSS, link speed, MTU, DNS registration, power saving, and packet discards.
- Added vmxnet3 awareness when packet discards are detected.
- Added INFO as a result type for information-only checks.
- Added Exchange Setup log detection and a reference to Microsoft's SetupLogReviewer.
- Added LBFO NIC Teaming information.
- Added Active Directory DNS checks for DC Locator, Kerberos, Global Catalog, server FQDN, writable DC, and GC.
- Added storage information for media type, bus type, GPT/MBR, and mapped volumes.
- Added TLS/SCHANNEL checks.
- Added Microsoft Defender status and exclusion information.
- Added Microsoft Visual C++ 2015-2022 x64 as an information-only check.
- Improved remote connection error handling.
- Improved Windows PowerShell 5.1 compatibility.
- Added console paging and grouped multi-server output.
- Added regional and time zone consistency checks.
- Added file system and 64 KB allocation unit checks for non-system fixed volumes.
- Added more help examples and GitHub information.
- Added MIT license and production-use caution information.

## 1.0 - 23/09/2026

- Created the first version of the Exchange server readiness script.
- Added primary DNS suffix and FQDN checks.
- Added Active Directory forest functional level checks.
- Added Windows Time service and time source information.
- Added CPU socket information based on Exchange hardware guidance.
- Added prerequisite package detection and version reporting.
- Added IPv6 preference checking.
- Added cross-server regional and time zone comparison.
