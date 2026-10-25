# Screenshot checklist — Entra + Intune video series

Follow the Labs Hands On "Microsoft Intune + Microsoft Entra ID
Complete Master Course 2026 (Zero to Expert)" in order, and capture
one screenshot per verified step. A screenshot only goes on GitHub
after the step actually worked — never screenshot a video frame and
present it as your own lab work.

**Redact in every screenshot before posting:** tenant domain,
admin and user email addresses, device IDs, certificate thumbprints,
serial numbers, and IP addresses. Keep device name WIN11-Intune,
AzureAdJoined status, and policy/device status visible — those are
the proof.

## Already done (posted as text, screenshots ready locally)

- [x] 01 — Admin center: test user, standard user, no administrator access
- [x] 02 — `whoami`, `hostname`, `dsregcmd /status` (AzureAdJoined: YES)
- [x] 03 — Settings > Accounts > Access work or school: connected to
      MDM and Entra ID

## Phase 2 — Entra ID fundamentals (do these next)

- [ ] 04 — Entra admin center: Users list showing the test user
      (redact emails/domain)
- [ ] 05 — Entra admin center: Groups list showing the test group,
      with the test user as a member
- [ ] 06 — Test user sign-in: MFA registration prompt completed with
      Microsoft Authenticator (do not screenshot QR codes or codes)
- [ ] 07 — Entra admin center: Authentication methods for the test
      user showing Authenticator registered

## Phase 3 — Conditional Access (report-only first, always)

- [ ] 08 — Conditional Access policy creation screen: policy named,
      test user/group assigned, admin account excluded, Enable policy
      set to **Report-only** (screenshot must show Report-only)
- [ ] 09 — Sign-in logs: the same policy showing as Report-only /
      Not applied, proving it was tested before enforcement
- [ ] 10 — Only after step 09 looks clean: the same policy switched
      to On, with a test sign-in succeeding. Never screenshot an
      enforce-first policy as a success.

## Phase 4 — Intune enrollment and device management

- [ ] 11 — Intune admin center: Devices > All devices showing
      WIN11-Intune as managed/enrolled
- [ ] 12 — Intune admin center: device details for WIN11-Intune
      (redact device ID, serial, hardware hashes)
- [ ] 13 — Company Portal on the VM (if used): device shown as
      compliant / managed, signed in as the test user

## Phase 5 — Compliance and configuration

- [ ] 14 — Compliance policy creation: rule set (e.g. OS version,
      BitLocker, Defender) assigned to the test group
- [ ] 15 — Device compliance result: WIN11-Intune showing Compliant
      (or Noncompliant with the failing rule visible — a failed
      check you then fix is also good lab evidence)
- [ ] 16 — Configuration profile creation and assignment
      (e.g. Wi-Fi, VPN, or device restriction profile)
- [ ] 17 — Settings on the VM proving the profile applied
      (the actual setting changed, not just the portal screen)

## Phase 6 — Apps, updates, and endpoint security

- [ ] 18 — Win32 app deployment: app created, assigned to the test
      group, and showing as Installed on WIN11-Intune
- [ ] 19 — App installed on the VM itself (Start menu / app present)
- [ ] 20 — Windows Update for Business: update ring assigned, device
      update status visible
- [ ] 21 — Endpoint security: Defender / BitLocker status on the
      device in Intune (BitLocker recovery key itself must NEVER be
      screenshotted)

## Phase 7 — Troubleshooting (strong portfolio evidence)

- [ ] 22 — A real problem you hit and fixed, with before/after
      screenshots (e.g. enrollment error, policy conflict, sign-in
      log showing the blocking policy, and the fix)
- [ ] 23 — Sign-in logs / What If tool result used to diagnose a
      Conditional Access issue

## Later / do NOT claim yet

- [ ] Autopilot — only when you have a fresh device/VM to run
      through Autopilot end to end; do not claim it from the
      current Entra-joined VM
- [ ] Hybrid identity / Azure AD Connect Cloud Sync — do NOT sync
      the home AD lab (laptop DC01/DC02) to this trial tenant
      without a separate plan; it risks your AD lab
- [ ] Privileged Identity Management (PIM) — not included in
      Business Premium (Entra P1 only); do not claim PIM hands-on
      from this tenant
- [ ] Intune Suite features — only if the trial actually includes
      them; check the license before claiming

## Posting rule

Text (READMEs, checklists) can be pushed from here. PNG screenshots
cannot be pushed through the GitHub connector used here — upload
the redacted PNGs to `entra-intune-lab/screenshots/` on the GitHub
website, then update the README screenshot list to match the files
actually present.
