# KeyMaster - Software/Firmware Requirements (Draft)

**Status:** Concept and partner-scoping
**Audience:** Firmware teams, systems engineers, integration partners

Software requirements for KeyMaster v1 define security and UX outcomes while leaving implementation choices open for partner proposals.

---

## 1. Purpose

KeyMaster software spans:
- Device control firmware
- Security-sensitive key/vault logic
- Host integration surface
- Optional management/sync services

Goal: specify what must be true from a user and security perspective so engineering partners can design practical implementations.

---

## 2. Functional Outcomes

v1 software must deliver:
1. On-device unlock workflow (PIN/pattern) independent of host trust
2. Profile-aware access control (including reduced-exposure profiles)
3. Credential and key operations without exposing root secrets to host
4. Usable host workflows for daily credential operations
5. Backup/sync path that is understandable and recoverable by users

---

## 3. Mode Model (Canonical Terminology)

All docs should use this naming:

- **Restricted Mode**
  - For unknown/untrusted hosts
  - Minimal exposed functionality
  - No broad vault browsing from host

- **Full Mode**
  - For approved hosts and richer workflows
  - Enables broader management/integration capabilities

- **Reader Mode**
  - Optional in v1, but roadmap-defined
  - Compatibility path for smart-card-centric or legacy environments

---

## 4. Software Architecture Requirements

Implementation may vary, but proposals must show:
- Clear isolation boundary between security-critical code and high-complexity services
- Explicit inter-domain communication contract
- Deterministic lock/unlock state transitions
- Defined behavior on power interruption, host disconnect, and update rollback

Partner proposals should include a threat-informed rationale for chosen architecture.

---

## 5. Vault and Data Model Requirements

### Core properties
- Encrypted-at-rest vault storage on device
- Profile-scoped visibility and permissions
- Attachment support for entry-associated artifacts
- Metadata and data integrity checks

### Format and compatibility
- Internal storage format is project-defined and may evolve
- External interoperability (import/export) must be supported for mainstream password workflows
- Migration/versioning strategy must be explicit

---

## 6. Password Manager Integration

KeyMaster integrates directly with an existing password manager as the primary path.

Why this path:
- Existing password managers already have polished UX and mature daily workflows.
- They already integrate with browsers and desktop autofill flows.
- Reusing that ecosystem reduces implementation risk and shortens time-to-usable product.

What this means:
- We choose a real open source password manager target (KeePass family for instance).
- If needed, we modify that password manager to read/write KeyMaster's native vault format.
- Cryptographic authority stays on KeyMaster during normal operation.

---

## 7. Host Integration Requirements

v1 host integration should include:
- A stable CLI for core operations (status, unlock assistance, list/get/add/update, backup/restore, sync trigger)
- Predictable behavior on Windows/macOS/Linux
- Browser/desktop integration strategy either in v1 or explicitly deferred with rationale

Any optional local management UI must be gated by active unlock state and least-privilege principles.

---

## 8. Update and Recovery Requirements

Software stack must support:
- Authenticated update packages
- Rollback-safe update flow
- Recovery path for failed updates
- Clear user-visible status for update and recovery states

Production signing and key-handling processes must be documented before shipment.

---

## 9. Backup and Sync Outcomes

Required behavior:
- Users can maintain multiple backup KeyMaster units; one backup is minimum, not the target.
- Backup units automatically sync from the active unit when connectivity is available.
- Sync state is visible and verifiable (not a silent black box).
- Conflict handling is deterministic and understandable to users.
- Recovery to replacement hardware from synced backups is straightforward and documented.

Roadmap direction:
- Sharing selected groups with other active units (not just passive backups).
- Explicit permission and policy controls for cross-device shared groups.

Implementation details (transport/discovery/object model) remain open to partner proposal.

---

## 10. Engineering Deliverables Expected

From a software partner proposal:
1. Architecture diagram + trust boundaries
2. Interface contract between security domain and feature domain
3. Data model/versioning proposal
4. Test strategy (unit, integration, fuzz/security, fault-injection where relevant)
5. Update/signing/recovery design
6. Milestone plan with prototype gates

---

## 11. Implementation Flexibility

This draft leaves these decisions open:
- Specific programming language choices
- Specific sync protocol stack
- Specific USB gadget composition details
- Specific Linux distribution/BSP

Those should be justified in partner proposals against product goals.
