# New-Hire Onboarding Practice — Active Directory, Entra ID & Intune (Home Lab)

**Date:** November 14, 2026
**Environment:** Windows Server 2025 domain controllers (DC01, DC02), Windows 11 VM managed by Intune. Practice lab only — not a production procedure.

## What I did

Finished a 9-ticket new-hire onboarding practice pack in the home lab: created two new hires in Active Directory, proved they replicated to the second domain controller, and walked the full day-one sign-in check from AD through to device compliance and Conditional Access.

### The two hires

- **Taylor Brooks (tbrooks)** — US-Milwaukee, IT, IT Support Technician, manager James Carter. Groups: GG-AllStaff, GG-US-IT, GG-IT-Global.
- **Sofia Reyes (sreyes)** — CA-Toronto, HR, HR Assistant, manager Ava Lee. Groups: GG-AllStaff and GG-CA-HR only — no IT groups.

Both accounts were created with a temporary password set to change at next logon.

### Replication

Proved both accounts on the second domain controller:

```powershell
Get-ADUser tbrooks -Server DC02 -Properties Enabled,Department,Title,Manager
Get-ADUser sreyes -Server DC02 -Properties Enabled,Department,Title,Manager
```

Both returned Enabled True with the right department, title, and manager. An account that only exists on one domain controller is not onboarded yet — if that DC is down on the new hire's first morning, they cannot sign in anywhere.

This pack also closed out an earlier replication fix: replication had failed with error 8524 (DNS lookup failure) because DC02 listed the IPv6 loopback address first as its DNS server. Fixing the DNS order on both DCs and raising each DC from 2 GB to 4 GB RAM brought `repadmin /replsummary` to 0 failures both ways.

### Device check (Intune)

The Windows 11 VM showed in Intune as Compliant, last check-in November 14 at 6:19 PM. The compliance policy checks Secure Boot and TPM 2.0. Settings on the VM confirmed it connected to the organization's MDM and Entra ID. Windows Terminal was assigned to all users as a required app, and Outlook on the web signed in cleanly with no MFA prompt — the lab Conditional Access policy is Report-only, so it watches without enforcing.

### Day-one sign-in order

The order that works, from the account outward:

1. **Active Directory** — locked out or disabled? Check `lockoutTime`, `badPwdCount`, `Enabled`. A `pwdLastSet` of 0 means the temp-password change never happened.
2. **Sync** — did the account reach Entra? Check sync status and last sync, then the sign-in logs.
3. **Device join** — `dsregcmd /status`. A hybrid-joined device shows AzureAdJoined YES and DomainJoined YES.
4. **Compliance** — the device, not the account. Company Portal: Secure Boot + TPM 2.0.
5. **Conditional Access** — prove it in the sign-in logs, CA tab. Check the admin account is excluded before touching any CA policy.

### Lab vs hybrid

The lab has no sync between on-prem AD and the cloud tenant, so lab AD users never appear in Entra — expected in this lab, not broken. In a hybrid environment sync does run, so a missing cloud sign-in there is a sync or licence problem to chase.

## Key learning

Group membership decides what a new hire can actually reach. Sofia not being able to open the IT shared drive (and Taylor not the HR one) is correct, not a problem. And a newly added group only takes effect after log off and back on — `gpupdate /force` does not refresh group membership or the user's token.

## Screenshots

- `tbrooks-on-dc02.png` — Taylor Brooks verified on DC02
- `taylor-account-must-change-password.png` — Account tab, must change password at next logon
- `sreyes-on-dc02.png` — Sofia Reyes verified on DC02
- `intune-device-compliant-cropped.png` — Windows 11 VM Compliant in Intune
- `work-or-school-mdm-entra-redacted.png` — VM connected to MDM and Entra ID
- `testuser-accounts-redacted.png` — test user account on the VM
- `credential-manager-no-windows-credentials.png` — Credential Manager, no stale saved credentials (stale credentials cause repeated lockouts)
