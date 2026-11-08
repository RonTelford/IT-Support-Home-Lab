# Active Directory Lab — Rebuilt Nov 7, 2026 + GlobalCompany Practice

What I did: scrapped the old lab VMs and rebuilt Active Directory from
scratch on the desktop, then ran a 100-user multi-country lab on it and
worked 12 practice tickets in order, then a 10-question test.

## Rebuild

- Host: desktop VMware Workstation (the old laptop VMs, desktop Wazuh /
  Ubuntu, desktop Ubuntu, and the old WIN11-Intune VM were all deleted
  Nov 7 — AD study only for now)
- New VMs, one per domain controller:
  - `DC01` — Windows Server 2025, 60 GB single file, 8 GB RAM, 2 CPU, NAT
  - `DC02` — same spec, same ISO
- Domain: `server2025boss.local`, NetBIOS `LHO`
- DC01: `192.168.243.10/24`, gateway `192.168.243.2`, DNS `127.0.0.1`
- DC02: `192.168.243.11/24`, gateway `192.168.243.2`, DNS `192.168.243.10`

### Two things that went wrong on the first DC01 build

1. Pasting the DSRM password line and the `Install-ADDSForest` line together
   created a `-Force$SafePass` parameter error. Fix: run each line **alone**,
   one at a time.
2. The local Administrator password was blank, which blocks promotion.
   Fix: set it first with `net user Administrator "<password>"` — with
   quotes — then promote.

The first DC01 also would not let me log in after promotion, and the
Utilman password reset failed at the EFI Boot Manager screen (Enter did
nothing, mouse does not work there). I deleted that VM and rebuilt it
with VMware Easy Install. That build promoted cleanly.

### Promotion — DC01 (run one line at a time, elevated PowerShell)

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses 127.0.0.1
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
$SafePass = ConvertTo-SecureString "<DSRM-password>" -AsPlainText -Force
Install-ADDSForest -DomainName "server2025boss.local" -DomainNetbiosName "LHO" -InstallDns:$true -SafeModeAdministratorPassword $SafePass -Force
```

The DSRM password is a separate emergency / Restore Mode password. It is
required by `Install-ADDSForest` and is **not** used for normal login.
DNS delegation warnings during promotion are normal.

Result: "Operation completed successfully", logged in as `LHO\Administrator`.

### Promotion — DC02 (additional domain controller)

Set the local Administrator password first, rename to DC02, set the
static IP above, then:

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSDomainController -DomainName "server2025boss.local" -InstallDns:$true -Credential (Get-Credential)
```

The credential popup wants the **DC01 domain admin**: user name
`LHO\Administrator`, password = the DC01 domain admin password.
Not the DC02 local password, not the DSRM password.

Result: promoted as an additional DC. On the DC02 login screen the
domain account showed twice — that is a Windows quirk (last user +
account list), not a problem. Do not change one of them.

### Replication (verified)

```powershell
repadmin /replsummary
```

Result: Source DSA DC01 largest delta 04m:44s **0 / 5 0**;
Destination DSA DC02 largest delta 04m:44s **0 / 5 0**.
Zero failures both ways.

Snapshots: VMware snapshots named **Before-GlobalCompanyLab** on both
DC01 and DC02, taken before the user pack was run. Take them from the
VMware host (VM > Snapshot > Take Snapshot), not inside Windows.

## GlobalCompany 100-user pack

The pack is in `global-company-lab/` in this repo (users.csv,
New-GlobalCompanyLab.ps1, Remove-GlobalCompanyLab.ps1, Build-Guide.md,
Practice-Scenarios.md). It was built Nov 5 and run Nov 7.

- 100 users, 20 each in US-Milwaukee, UK-London, DE-Berlin, CA-Toronto, IN-Delhi
- Departments: IT 20, HR 15, Finance 20, Sales 25, Operations 20
- 27 groups, including GG-AllStaff, GG-IT-Global, and GG-<country>-<dept>
- Temp password for all lab users: must change at next logon
  (the password itself is in the pack files — do not post it in a
  public README; keep it in the lab only)

Run result, Nov 7:

```
Done. Created: 100 users, Skipped (already existed): 0
```

Groups created, including GG-US-HR, GG-UK-IT, GG-DE-Finance, GG-CA-*,
GG-IN-*, and the rest.

First run failed because the folder did not exist on DC01 yet — the
script has to be on the DC, in `C:\Lab\GlobalCompanyLab\`, and run
from there:

```powershell
cd C:\Lab\GlobalCompanyLab
.\New-GlobalCompanyLab.ps1
```

## Practice tickets — all 12 done, in order

Worked in AD Users and Computers first, then verified with PowerShell.
Full ticket text is in `global-company-lab/Practice-Scenarios.md`.

| # | Ticket | What I did | Check |
|---|---|---|---|
| 1 | London lockout — Grace Thomas (`gthomas`, UK-London) | Unlocked the account (Account tab) | `Get-ADUser gthomas -Properties lockoutTime,badPwdCount` — lockoutTime 0 after unlock |
| 2 | Berlin new hire — Lea Fischer (`lfischer`, DE-Berlin IT) | Compared her groups to another DE-Berlin IT user | Already in Domain Users, GG-AllStaff, GG-DE-IT, GG-IT-Global — same as the others, nothing to add |
| 3 | Toronto password reset — Noah Wilson (`nwilson`, CA-Toronto IT) | Reset in ADUC, ticked "must change at next logon" | `Get-ADUser nwilson -Properties pwdLastSet` — **0** |
| 4 | Department move — Mia Becker (`mbecker`, DE-Berlin Finance to HR) | Properties > Organization tab: Department HR, Title HR Manager. Moved the object Finance OU to HR OU. Removed GG-DE-Finance, added GG-DE-HR | Department: HR; DN: `CN=Mia Becker,OU=HR,OU=DE-Berlin,OU=GlobalCompany,DC=server2025boss,DC=local`; MemberOf: GG-DE-HR + GG-AllStaff |
| 5 | Disable account — Vikram Singh (`vsingh`, IN-Delhi) | Disabled, did not delete | `Get-ADUser vsingh -Properties userAccountControl` — **514** (Enabled is 512, Disabled is 514) |
| 6 | Who is the manager? — Amanda Thomas (`athomas`, US-Milwaukee Sales) | Found the manager attribute | Manager: James Carter (`jcarter`), Title: IT Support Technician |
| 7 | Find everyone in IT worldwide | Opened GG-IT-Global instead of searching 5 OUs | `(Get-ADGroupMember GG-IT-Global).Count` — **20** |
| 8 | Last logon — Rahul Verma (`rverma`, IN-Delhi) | Checked lastLogonTimestamp | Not set — the users were just created and have never logged in |
| 9 | Account expires — Sophie Klein (`sklein`, DE-Berlin) | Checked accountExpires | Never expires (0 or 9223372036854775807) |
| 10 | Move a whole team — UK-London Operations, 4 users | Safe plan: check GPOs first, move ONE user, verify, then move the rest | GPOs are checked in Group Policy Management (`gpmc.msc`), not in ADUC. In this lab there were no custom GPOs linked to that OU — only the Default Domain Policy inherited from the domain. That is a real answer: moving the users would not change their GPOs |
| 11 | Replication check — Grace Thomas | Checked on both DCs | `Get-ADUser gthomas -Server DC01` and `Get-ADUser gthomas -Server DC02` — she shows up on **both** |
| 12 | "Who can access Finance?" audit — GG-UK-Finance | Listed the group, spotted the wrong member, removed them | `Get-ADGroupMember GG-UK-Finance \| Get-ADUser -Properties Department \| Select Name,Department` — first run: Grace Thomas, Charlie Roberts, Freya Walker, Leo Wright, all Finance. Practice: added Mia Scott (Sales) to the group, re-ran the check, spotted her, removed her. Back to 4 Finance |

### Attribute Editor — the tab that would not show up

The Attribute Editor tab only appears if View > **Advanced Features**
is turned on **before** you open Properties, in that ADUC window, on
that DC. It is per-window / per-DC — turning it on on DC01 does not
turn it on on DC02. If it still does not show, close Properties,
reopen it, maximise the window, and look at the far-right tab.
When the GUI would not cooperate, PowerShell checks (above) were the
fallback, and they gave the right answers. Do not let the tab block
the ticket.

### Ticket 10 / 12 — two things worth remembering

- `gpupdate /force` is for Group Policy, **not** group membership.
  A user added to a group will not show up in a check until replication
  catches up, or until you check on the same DC you added them on.
  To force replication now: `repadmin /syncall`. A logged-in user's
  token only updates when they log off and back on — gpupdate will not
  refresh it either.
- Group membership is changed in the **Member Of** tab, not in
  Attribute Editor. `memberOf` in Attribute Editor is a read-only
  backlink.

## Final test — score 7/10

10 questions, answered without looking. I got 7 right.

The 3 I missed:

1. `lockoutTime = 0` — I said "how many times a user has been locked
   out". Wrong. That is `badPwdCount`. `lockoutTime = 0` means
   **not locked**. A big number there is the time they got locked out.
2. What never to edit in Attribute Editor — I did not know.
   Answer: `objectSID`, `objectGUID`, `distinguishedName`, `memberOf`,
   `lastLogon` / `lastLogonTimestamp`, and any system attribute you
   do not recognise.
3. How to check hybrid join — I said "check on-prem and cloud".
   The command is `dsregcmd /status` — look for AzureAdJoined +
   DomainJoined.

I declined a retest on those 3. They are written down here so I do
not miss them again.

The 7 I got right: Attribute Editor is View > Advanced Features;
`pwdLastSet = 0` means must change password at next logon;
`userAccountControl = 514` means disabled; `lastLogonTimestamp` is
the replicated one; group membership changes in the Member Of tab;
a password changed on-prem but rejected in Teams usually means sync
to Entra ID has not caught up yet; before disposing a work laptop,
back up, sign out, wipe with Remove Everything + Clean Data, and
check with the lead first.

## Check commands — full list

All of these are also in `snippets/ad-user-checks.ps1` and
`snippets/repadmin-commands.ps1` in the posting package.

```powershell
Get-ADUser gthomas -Properties lockoutTime,badPwdCount
(Get-ADUser lfischer -Properties memberOf).memberOf
Get-ADUser nwilson -Properties pwdLastSet
Get-ADUser mbecker -Properties Department,memberOf
Get-ADUser vsingh -Properties userAccountControl
Get-ADUser athomas -Properties manager,department,title
(Get-ADGroupMember GG-IT-Global).Count
Get-ADUser rverma -Properties lastLogonTimestamp
Get-ADUser sklein -Properties accountExpires
Get-ADUser gthomas -Server DC01
Get-ADUser gthomas -Server DC02
Get-ADGroupMember GG-UK-Finance | Get-ADUser -Properties Department | Select Name,Department
repadmin /replsummary
repadmin /showrepl
repadmin /syncall
```
