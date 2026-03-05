# KeyMaster - User Guide (Conceptual)

KeyMaster v1 user experience centers on on-device unlock, profile-based access, and context-aware host exposure.

---

## 1. Getting Started

### First setup
1. Connect KeyMaster to a host using USB-C.
2. Create a primary unlock method (PIN or pattern).
3. Initialize the vault.
4. Pair at least one backup device or create an encrypted backup file.

### Why setup includes backup immediately
KeyMaster is a critical identity device. Backup is part of the primary workflow, not an optional afterthought.

---

## 2. Daily Use

### Unlock
1. Connect the device.
2. Enter unlock method on-device.
3. Device enters the appropriate host mode based on policy and host trust.

### Retrieve or auto-type credentials
- Select an entry on-device or via approved host workflow.
- Auto-type or copy specific fields as allowed by policy.

### OTP usage
- View or emit current OTP code from on-device-managed secret material.

---

## 3. Host Modes

### Restricted Mode
- Default for unknown/untrusted hosts
- Minimal exposed functionality
- No broad vault browsing

### Full Mode
- For approved hosts
- Expanded credential management and integration workflows

### Reader Mode (roadmap)
- Compatibility path for smart-card-centric/legacy environments

---

## 4. Profiles and Separation

Each profile can have:
- Its own unlock method
- Its own visible data scope
- Its own policy constraints

Common profile patterns:
- Primary
- Travel/reduced exposure
- Duress/decoy
- Work/personal separation

Important: duress and deniability features should be understood as risk-reduction tools, not absolute guarantees.

---

## 5. Backup and Recovery

Supported strategies:
- Additional KeyMaster units (preferred)
- Encrypted backup files for archival/recovery

Recovery expectations:
- Users can restore data to replacement hardware
- Recovery steps and failure states are explicit and testable

---

## 6. SSH/GPG and Advanced Credentials

KeyMaster is intended to support hardware-backed credential operations, including SSH/GPG-style workflows, with explicit on-device confirmation for sensitive actions.

Exact integration mechanism is implementation-dependent and will be documented in shipped tooling.

---

## 7. Password Manager Workflow

Preferred long-term workflow:
- Native integration/backend paths with existing open-source password managers, where KeyMaster retains cryptographic authority

Fallback workflow:
- Import/export compatibility (`.kdbx` and related interchange paths where appropriate)

---

## 8. Troubleshooting Principles

If something fails:
1. Verify cable/port and device power state
2. Verify device lock state and active profile
3. Verify host trust policy and expected mode
4. Use explicit recovery tooling if vault index or sync state is unhealthy

Detailed command-level troubleshooting will be finalized with implementation.

---

## 9. Implementation Note

UI flow and command syntax may evolve during implementation. The user outcomes in this guide remain the product target.
