# repadmin-commands.ps1
# Replication commands for a two-DC lab (DC01 and DC02).
# Run in an elevated PowerShell on a domain controller.
# No passwords or secrets in this file.

# Summary: how many failures, and how long since the last replication.
# 0 failures both ways is what you want.
repadmin /replsummary

# Detail: who each DC replicates from and to, last success, and any errors.
# Look for "Last attempt was successful" for the other DC.
repadmin /showrepl

# Force a sync now instead of waiting for the normal schedule.
# Use it after you move a user, add someone to a group, or move an object
# to another OU, and the other DC does not show the change yet.
# It forces replication — it does not make the change itself.
repadmin /syncall

# Force a sync on one specific DC.
repadmin /syncall DC01
repadmin /syncall DC02

# Replicate one single object only, instead of a full sync.
# Format: repadmin /replsingleobj <destination DC> <source DC> "<distinguished name>"
# Example (replace the DN with the real one for your user):
# repadmin /replsingleobj DC02 DC01 "CN=Grace Thomas,OU=Finance,OU=UK-London,OU=GlobalCompany,DC=server2025boss,DC=local"

# PowerShell versions of the same checks:
Get-ADReplicationPartnerMetadata -Target DC01
Get-ADReplicationPartnerMetadata -Target DC02
Get-ADReplicationFailure -Target DC01
Get-ADReplicationFailure -Target DC02
