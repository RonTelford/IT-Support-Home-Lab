# ad-user-checks.ps1
# AD user and group checks used in the GlobalCompany practice tickets.
# Domain: server2025boss.local. Users below are from the 100-user lab pack.
# Run in PowerShell on a DC (AD module loaded). No passwords in this file.
#
# Attribute Editor reminder: View > Advanced Features must be turned on
# BEFORE you open Properties, in that ADUC window, on that DC.
# If the tab will not show, use these commands instead — they give the
# same answers.

# Ticket 1 — Locked out? lockoutTime = 0 means NOT locked.
# badPwdCount is the count of wrong passwords. Do not mix them up.
Get-ADUser gthomas -Properties lockoutTime,badPwdCount

# Ticket 2 — What groups is a user in?
(Get-ADUser lfischer -Properties memberOf).memberOf

# Ticket 3 — Password reset check. pwdLastSet = 0 means the user
# must change their password at next logon. Any other number is a
# timestamp of when the password was last set.
Get-ADUser nwilson -Properties pwdLastSet

# Ticket 4 — Department and group membership after a move.
Get-ADUser mbecker -Properties Department,memberOf

# Ticket 5 — Enabled or disabled? userAccountControl 512 = enabled,
# 514 = disabled. Disable, do not delete, a leaver's account.
Get-ADUser vsingh -Properties userAccountControl

# Ticket 6 — Who is the manager, and what is their title?
Get-ADUser athomas -Properties manager,department,title

# Ticket 7 — Everyone in IT, worldwide. One group, 20 members,
# instead of searching 5 OUs.
(Get-ADGroupMember GG-IT-Global).Count

# Ticket 8 — Last logon. lastLogonTimestamp is replicated and
# approximate. lastLogon is per-DC only — do not use it to judge
# the whole domain. Blank / 0 means the user has never logged in.
Get-ADUser rverma -Properties lastLogonTimestamp

# Ticket 9 — Does the account expire? 0 or 9223372036854775807
# means never expires.
Get-ADUser sklein -Properties accountExpires

# Ticket 11 — Replication check. Same user, both DCs.
# If it is missing on the second DC, wait a minute and try again,
# then run repadmin /showrepl.
Get-ADUser gthomas -Server DC01
Get-ADUser gthomas -Server DC02

# Ticket 12 — "Who can access Finance?" audit.
# All 4 members should say Finance. Anyone else is out of place.
Get-ADGroupMember GG-UK-Finance | Get-ADUser -Properties Department | Select Name,Department

# Never edit in Attribute Editor:
#   objectSID, objectGUID, distinguishedName, memberOf,
#   lastLogon / lastLogonTimestamp, and any system attribute
#   you do not recognise. Change group membership in the
#   Member Of tab — memberOf is a read-only backlink in
#   Attribute Editor.
