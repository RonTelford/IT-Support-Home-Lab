# Active Directory Home Lab

A working Windows domain built from scratch — two domain controllers, joined clients, and the core services a help desk tech touches every day. Built while working through a 26-part "Mastering Active Directory" lab series.

## Environment

| Component | Details |
|---|---|
| Hypervisors | VMware Workstation + VirtualBox (Windows host) |
| Domain controllers | 2× Windows Server 2025 (`WIN-CK2DNMCPL24` · `dc-02`) |
| Domain | `server2025boss.local` (NetBIOS: `LHO`) |
| Clients | Windows 11 (incl. `WIN11BOSS`), plus an Ubuntu 64-bit VM |
| DC IPs (static) | `192.168.243.10` · `192.168.243.11` |

## What I built

- **OU design** — role-based structure: Groups (Domain_Local, Global_Group), Servers (App, DB, Web, ServiceAccounts), Users (Admin, HR, IT, Sales, Workstations)
- **AD Sites & Services** — three sites (HeadOffice, BranchOffice, RemoteOffice) with `192.168.1.0/24`, `192.168.10.0/24`, `192.168.20.0/24` subnets
- **Group Policy** — custom GPO linked to the Workstations OU (link enabled); captured `gpresult` output for IT User01 to review policy results
- **DNS** — AD-integrated forward lookup zone with DC/client A records and `_msdcs`/`_tcp`/`_udp` SRV records
- **Static IP configuration** — DCs on static addresses with the domain DNS suffix, DHCP disabled by design
- **Domain joins** — Windows 11 clients joined to the domain; domain users (e.g. `IT User01`) logging on and authenticating

## Troubleshooting: fixed a replication failure between DCs

`repadmin /replsummary` showed **100% replication failure** (>60 days, error 8524: DNS lookup failure). I worked it step by step:

1. **8524 — DNS lookup failure:** DC-01 couldn't resolve `DC-02.server2025boss.local`. Ping to the DC-02 IP worked, so the machine was alive — a name-resolution problem, not a dead server.
2. Corrected the DC's DNS server list (a public DNS entry was sitting alongside the internal DNS) and confirmed `nslookup` resolved the name afterward — the lookup error cleared, but replication still failed, so the root cause was deeper.
3. **"The target principal name is incorrect"** — a Kerberos error on the forced sync. Ruled out wrong-machine-at-IP (`ping -a` confirmed the hostname) and duplicate SPNs (`setspn -X` clean) and clock skew.
4. Root cause: the DC-02 machine account password was out of sync with AD. Fixed with `netdom resetpwd` on DC-02, restarted the KDC service.
5. `repadmin /syncall` completed with no errors; `replsummary` went to **0 fails** across both DCs.

## Screenshots

![VMware lab overview](screenshots/01-lab-overview-vmware.png)
*VMware Workstation running both Server 2025 DCs and Windows 11 clients*

![AD Sites and Services](screenshots/02-ad-sites-and-services.png)
*AD sites: HeadOffice, BranchOffice, RemoteOffice with their subnets*

![OU structure](screenshots/03-ou-structure-aduc.png)
*Role-based OU design in Active Directory Users and Computers*

![Domain computers](screenshots/04-domain-joined-computers.png)
*Domain-joined machines in the directory*

![ADUC on DC02](screenshots/05-aduc-on-dc02.png)
*Managing the directory from the second domain controller*

![GPO linked to Workstations OU](screenshots/06-gpo-linked-workstations-ou.png)
*Custom GPO linked to the Workstations OU, link enabled*

![gpresult for IT User01](screenshots/07-gpresult-it-user01.png)
*Verifying group memberships and policy results for a domain user*

![DNS Manager](screenshots/08-dns-manager-ad-zone.png)
*AD-integrated zone with DC and client records plus SRV folders*

![ipconfig on the DC](screenshots/09-ipconfig-static-dc.png)
*Static IP configuration on the domain controller (DHCP disabled by design)*

![Healthy replication](screenshots/10-replsummary-healthy.png)
*`repadmin /replsummary` after the fix — 0 failures on both DCs*

![Domain logon on Win11 client](screenshots/11-whoami-win11-domain-client.png)
*`whoami` on the domain-joined Windows 11 client: authenticated as `server2025boss\it user01`*
