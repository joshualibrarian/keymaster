# KeyMaster - Hardware Requirements (Draft)

**Status:** Concept and partner-scoping
**Audience:** Engineering firms, hardware/firmware leads, technical evaluators

---

## 1. Product Definition

KeyMaster v1 is a pocketable, USB-powered hardware identity device with:
- On-device unlock input
- On-device status/approval display
- Profile-aware security behavior across trusted and untrusted hosts
- Built-in path to backup/recovery workflows

The hardware target is a practical daily-carry product, not a lab-only security module.

---

## 2. Reference Hardware Shape

### 2.1 Form Factor
- Target envelope: approximately `50 x 75 x 15 mm` (same class as a compact external drive)
- Carryable in pocket or key pouch
- Robust enough for frequent connect/disconnect cycles

### 2.2 User-Facing Surfaces
- **Input:** recessed multi-key touch surface, target `12-key (3x4)` layout, supports PIN and pattern-style entry
- **Display:** low-power reflective display (e-paper class preferred), target `2.7"-3.5"`
- **Indicators:** at least one auxiliary status indicator (LED or equivalent)

### 2.3 Ports and Expansion
- Minimum `1x USB-C` for host connection
- Preferred `2x USB-C` for flexible workflows (host + accessory/backup/peripheral)
- Optional removable storage interface if it does not weaken security posture

---

## 3. Hardware Architecture Requirements

### 3.1 Domains
Hardware must separate responsibilities into:
- **Security/control domain:** unlock UI, policy enforcement, key operations, low-power baseline behavior
- **Feature domain:** richer host workflows and optional high-complexity services

Partners may implement this as dual-processor or equivalent isolation architecture. Proposals must show trust boundaries and failure behavior.

### 3.2 Always-Available Capability
Without requiring a high-power boot path, the device must support:
- Lock/unlock interaction
- Basic host-facing restricted behavior
- Key material handling under security policy

### 3.3 High-Function Capability
When power/policy allow, the device must support:
- Richer host integration workflows
- Backup/sync support paths
- Larger data handling and advanced management operations

---

## 4. Power and Electrical Behavior

### 4.1 Power Source
- USB-powered operation; no user battery dependency for core features
- Clean handling of cable disconnect and brown-out conditions

### 4.2 Power States
Hardware design must define and validate at least:
- **Disconnected/off**
- **Restricted baseline state** (low-power functionality available)
- **Full-function state** (expanded capabilities active)

### 4.3 Power-Loss Safety
Power interruption must not corrupt vault metadata or leave key material in unsafe states.

---

## 5. Storage Architecture Requirements

### 5.1 Storage Classes
Hardware must support distinct storage roles:
- Boot and recovery path
- Encrypted vault data
- System software and update partitions

### 5.2 Capacity Envelope (Target)
- Vault storage: `128 MB - 512 MB` class
- System/software storage: `>= 8 GB` class
- Optional user bulk storage: removable and/or higher-capacity SKU

### 5.3 Data Integrity and Endurance
Proposal must cover:
- Wear strategy
- Sudden power-loss integrity behavior
- Update rollback behavior
- Manufacturing provisioning and recovery path

---

## 6. USB Behavior and Host Compatibility

### 6.1 Mode Expectations
KeyMaster host behavior maps to three product modes:
- **Restricted Mode:** minimal exposed host surface for untrusted environments
- **Full Mode:** expanded functionality on approved hosts
- **Reader Mode:** compatibility path for smart-card-centric environments (roadmap commitment)

### 6.2 Interoperability Targets
v1 proposals must provide concrete compatibility behavior for:
- Windows
- macOS
- Linux
- Mobile hosts via adapters where practical

### 6.3 Interface Strategy
Exact USB class composition is partner-proposed. The proposal must include:
- Enumeration strategy by mode
- Power negotiation assumptions
- Failure behavior on hostile or noncompliant hosts

---

## 7. Security-Relevant Hardware Controls

Required hardware-enforced controls:
- Secure boot chain support
- Production debug lockdown strategy
- Hardware-backed entropy source suitable for cryptographic operations
- Tamper event signaling path with defined response policy

Recommended for hardened SKU:
- Secure element or equivalent hardened key anchor
- Enhanced tamper detection/response
- Additional physical hardening features

---

## 8. Mechanical and Environmental Targets

Proposal must include target values and validation plan for:
- Operating/storage temperature ranges
- ESD robustness for user-accessible surfaces and ports
- Connector insertion life
- Drop/handling durability
- Moisture/dust tolerance appropriate for daily carry

---

## 9. SKU Strategy

### 9.1 Base SKU (v1)
- Core security/control + full user workflows
- USB-powered portability
- On-device input/display
- Encrypted vault with recovery path

### 9.2 Hardened/Pro SKU (optional in v1, planned path)
- Additional tamper resistance
- Optional hardened key storage
- Expanded performance/storage envelope

Both SKUs should share maximal board/mechanical commonality where practical.

---

## 10. Deliverables Expected From Engineering Partners

For initial engagement:
1. Architecture proposal with trust boundaries
2. Feasibility assessment and critical risk register
3. Prototype plan and milestone schedule
4. Preliminary BOM/cost ranges with component risk notes
5. Validation plan (electrical, mechanical, environmental, interoperability)

---

## 11. Acceptance Checklist (v1 Hardware)

A proposal is acceptable when it demonstrates:
- Clear implementation of recessed on-device unlock input and low-power display
- USB-powered operation with safe behavior under disconnect/brown-out
- Trust-boundary architecture for security/control vs feature workloads
- Mode-based host behavior (Restricted/Full) with roadmap for Reader Mode
- Viable manufacturing and recovery/provisioning path

---
