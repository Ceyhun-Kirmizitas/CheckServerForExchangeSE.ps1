# Changelog

## Unreleased

- Changed `DNS Client` to `Configured DNS Servers` and now shows DNS server addresses per active network adapter.
- Improved the built-in help and description with a clearer summary of the readiness checks.
- Updated the script date to 27/09/2026.

All notable changes to CheckServerForExchangeSE.ps1 are documented here.

## 1.1 - 26/09/2026

- Renamed the script to CheckServerForExchangeSE.ps1. The version is now kept inside the script and in Git history/releases.
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
