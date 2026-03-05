# KeyMaster - Hardware Specification

**Status:** Concept and partner-scoping
**Audience:** Engineering firms, hardware/firmware leads, technical evaluators

---

## 1. Product Intent

KeyMaster is a pocketable, USB-powered identity device with:
- On-device unlock input (no host keyboard dependency)
- On-device status/confirmation display
- Safe operation on trusted and untrusted hosts
- Practical phone/laptop usage, including single-port phone charging scenarios

---

## 2. Physical Requirements

### 2.1 Form Factor
- Target size class: approximately `50 x 75 x 15 mm`.
- Operates as a pocket-carryable, cable-safe device for daily insertion/removal.

### 2.2 Input Surface
- Provides a recessed multi-key input area for blind/tactile entry.
- Target layout: `12-key (3x4)`.
- Supports both numeric PIN and pattern-style entry.

### 2.3 Display
- Provides always-visible lock/status information when powered.
- Low-power reflective display class (e-paper or equivalent) is preferred.
- Display updates are not required for every keypress in low-power operation.

### 2.4 Ports
- Provides `2x USB-C` ports.
- One-port designs are out of scope for v1 because inline power + device use is a core workflow.

---

## 3. Power and USB Requirements

### 3.1 Batteryless Operation
- Operates without an internal rechargeable battery.
- External USB power is the primary source.

### 3.2 Pass-Through Power (Critical)
The device supports inline use where a phone has a single USB-C port and needs both charging and KeyMaster access.

Required behavior:
- Supports simultaneous:
  - Upstream host/device connection (phone/computer)
  - External power input from charger/power source
- Passes power through while KeyMaster remains operational.
- Maintains stable USB data and avoids repeated disconnect/re-enumeration under normal cable movement.

Power targets:
- Minimum supported pass-through to downstream host: `5V @ 1.5A` continuous.
- Preferred target: `5V @ 3A` continuous when thermal/electrical limits allow.

### 3.3 Power States
Hardware defines and supports:
- **Off:** no external power
- **Restricted Mode:** low-power secure baseline behavior
- **Full Mode:** expanded functionality when policy/power permit
- **Reader Mode:** very low-power compatibility mode for smart-card-style adapter path

### 3.4 Brown-Out / Disconnect Safety
- Fails safe on cable pull, brown-out, and role swap.
- Protects vault integrity on abrupt power loss.
- Includes a short hold-up energy buffer (supercapacitor or equivalent) to complete critical shutdown actions on unplug:
  - clear/reset sensitive on-screen state
  - zeroize active in-memory key material

---

## 4. Low-Power and Reader Mode Requirements

Reader Mode exists specifically to support a future smart-card adapter and other constrained-power environments.

### 4.1 Reader Mode Budget (Electrical)
- Reader Mode average power draw stays within adapter-provided power limits.
- Required budget target at 5V input:
  - **Average:** `<= 20 mA`
  - **Peak:** `<= 40 mA` (excluding brief startup transients)

### 4.2 Reader Mode Behavior
In Reader Mode, hardware supports at minimum:
- Secure unlock input
- Basic confirmation/status output
- Restricted host functionality needed for smart-card-centric workflows

In Reader Mode, hardware defers or disables non-essential high-draw functions:
- High-refresh display updates
- Secondary storage/peripheral power
- High-complexity processing domain

### 4.3 Verification
Partner proposals include an actual power budget table and measurement plan showing compliance for Reader Mode.

---

## 5. Architecture Requirements

### 5.1 Security vs Feature Separation
Design separates:
- **Security/control domain:** unlock, policy enforcement, key operations, restricted baseline
- **Feature domain:** richer host workflows and higher-complexity services

Implementation may be dual-processor or equivalent isolation, but trust boundaries must be explicit.

### 5.2 Baseline Availability
Without high-power boot, the device still provides restricted secure operation and policy gating.

---

## 6. Storage Requirements

Hardware supports three roles:
- Boot/recovery path storage
- Encrypted vault storage
- System/update storage

Capacity targets:
- Vault class: `128 MB - 512 MB`
- System software class: `>= 8 GB`
- Optional user bulk storage path (base or higher SKU)

Storage design includes:
- Wear strategy
- Sudden power-loss integrity behavior
- Recovery and reprovisioning workflow

---

## 7. Security-Relevant Hardware Controls

Includes:
- Secure boot support
- Production debug lockdown strategy
- Hardware-backed entropy source suitable for cryptographic key generation
- Tamper event signaling path and response policy

Also includes, in the base or higher SKU path:
- Hardened key anchor (secure element or equivalent)
- Enhanced tamper detection/response

---

## 8. Host Compatibility Requirements

Mode model:
- **Restricted Mode:** minimal exposed host surface on unknown/untrusted hosts
- **Full Mode:** expanded workflows on approved hosts
- **Reader Mode:** constrained-power smart-card-centric path

Partner proposals provide concrete compatibility expectations for:
- Windows
- macOS
- Linux
- Android
- iOS

---

## 9. Environmental and Mechanical Targets

Partner proposals provide targets and validation plans for:
- ESD robustness at user-accessible ports/surfaces
- Connector insertion life
- Drop/handling durability
- Operating/storage temperature ranges
- Moisture/dust tolerance appropriate for daily carry

---

## 10. SKU Direction

### Base SKU
- Full core workflow support
- Batteryless operation
- 2x USB-C with pass-through power behavior

### Hardened/Pro SKU (roadmap)
- Additional tamper resistance
- Hardened key anchor
- Expanded performance/storage envelope

PCB/mechanical commonality across SKUs is preferred.

---

## 11. Deliverables Required From Engineering Firms

1. Architecture proposal with trust boundaries
2. Electrical power-path design proposal, including pass-through strategy
3. Reader Mode power budget and measurement plan
4. Feasibility/risk register and milestone plan
5. Preliminary BOM/cost range with supply risk notes
6. Validation plan (electrical, USB interoperability, mechanical, environmental)

---

## 12. Acceptance Criteria (v1 Hardware)

A proposal is acceptable when it demonstrates:
- Recessed on-device unlock input and low-power status display
- Two-port USB-C design with verified pass-through power behavior
- Stable inline phone + charger + KeyMaster workflow
- Reader Mode power budget compatible with constrained-power adapter design
- Explicit trust-boundary architecture and secure boot/debug posture
