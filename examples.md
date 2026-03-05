# KeyMaster Usage Examples

These scenarios illustrate intended behavior using the canonical mode model.

---

## 1. Digital Nomad

A user plugs into a borrowed machine at a co-working space.

- Device enters **Restricted Mode**.
- User unlocks a travel profile.
- User auto-types only required credentials.
- Broader vault content is not exposed to the host.

Outcome: useful access on an untrusted machine with reduced exposure.

---

## 2. Corporate Employee

A user works across managed corporate endpoints and personal devices.

- Corporate endpoint policy keeps device in Restricted or constrained Full behavior.
- Work profile is accessible; personal profile remains hidden.
- On approved personal host, Full Mode enables broader management.

Outcome: work/personal separation with consistent device workflow.

---

## 3. Family Sharing

A household shares selected credentials while keeping private data private.

- Shared entries are available to designated profiles.
- Each person unlocks with their own method.
- Private entries remain isolated.

Outcome: selective sharing without flattening all identity boundaries.

---

## 4. Consultant/Developer

A consultant manages credentials for multiple clients.

- Separate profiles or policy scopes by client.
- Only active client data is visible in session.
- SSH/GPG-style operations require explicit device confirmation.

Outcome: lower cross-client leakage risk with practical daily flow.

---

## 5. Frequent Traveler

A traveler expects potential device inspection.

- Uses reduced-exposure profile during travel.
- Keeps higher-risk data outside that profile.
- Returns to normal profile access after travel.

Outcome: coercion-aware workflow that raises uncertainty and limits exposure.

---

## 6. Recovery Scenario

Primary device is lost.

- User restores from backup KeyMaster or encrypted backup file.
- New device provisions with recovered vault.
- User rotates sensitive credentials as needed.

Outcome: no single point of failure for digital identity continuity.

---

## Common Pattern

Across scenarios, KeyMaster is intended to provide:
- Context-aware host exposure
- Profile-based isolation
- On-device confirmation for sensitive actions
- Practical backup and recovery
