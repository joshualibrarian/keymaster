# KeyMaster
## Open Hardware Identity Device

KeyMaster is a batteryless USB device for secure daily identity operations: credentials, SSH/GPG keys, OTP secrets, wallet seeds, and other sensitive data.

**Status:** Concept and partner-scoping. Audience:
- Investors evaluating product direction and market fit
- Engineering firms evaluating feasibility, scope, and execution risk

---

## Why This Exists

Most people currently split digital identity across:
- Cloud password managers
- Local vault files on laptops/phones
- Hardware tokens that solve only one slice of the problem

That creates practical failures in real environments:
- Untrusted or borrowed computers
- Locked-down enterprise systems
- Travel and coercion-sensitive situations
- Fragile backup/recovery workflows

KeyMaster aims to combine usability and strong security controls in one portable device under the user's physical control.

---

## Product Direction

### Core experience
- On-device unlock and confirmation
- Adaptive behavior based on host trust
- Profile-based separation (including reduced-exposure and duress workflows)
- Reliable backup/recovery paths

### Canonical host modes
- **Restricted Mode:** minimal host exposure for unknown/untrusted environments
- **Full Mode:** broader workflows on approved hosts
- **Reader Mode:** compatibility path for smart-card-centric/legacy environments (roadmap)

### Design principles
- User control over secrets
- Security posture appropriate to context
- Open designs and auditable implementation
- Practical interoperability with existing ecosystems

---

## Password Manager Integration

KeyMaster prefers **native integration** with existing open-source password managers (KeePassXC is one possible target), instead of brittle file-format tricks.

Fallback compatibility will include import/export workflows (including `.kdbx` where appropriate) when native integration is not available.

---

## Architecture

The v1 architecture is expected to include:
- A security/control domain for unlock, policy, and key operations
- A feature domain for richer host-facing workflows

Silicon and software stack choices remain open in this phase so engineering partners can propose the best implementation.

---

## Security Model

KeyMaster:
- Keep root secrets within device trust boundaries
- Isolate profiles cryptographically
- Reduce data exposure on untrusted hosts
- Provide durable anti-bruteforce and update integrity controls

Threat model limits and residual risks are called out explicitly in implementation proposals.

---

## Roadmap

### Phase 0 (Current)
- Finalize product requirements and threat model boundaries
- Select engineering partner(s)
- Build early contributor and reviewer community

### Phase 1
- Hardware and firmware prototypes
- Core unlock/profile/vault flows
- Baseline host integration

### Phase 2
- Usability hardening and integration expansion
- Backup/sync maturity
- External security review cycles

### Phase 3
- Manufacturing, certification, and launch readiness

---

## Documentation

| Document | Purpose |
| --- | --- |
| [Vision](docs/vision.md) | Problem framing, product philosophy, positioning |
| [Hardware Requirements](docs/specs/hardware.md) | Outcome-level hardware requirements |
| [Software Requirements](docs/specs/software.md) | Outcome-level firmware/software requirements |
| [Security Requirements](docs/specs/security.md) | Threat model and security requirements baseline |
| [User Guide](docs/user-guide.md) | Intended user workflows |
| [Examples](examples.md) | Narrative scenarios aligned to current scope |

---

## Open Source Commitment

- Hardware design artifacts: open
- Firmware/software: open
- Formats/protocols: documented and reviewable

The project is designed for auditability and long-term user control.

---

## Get Involved

- **Engineering firms:** propose architecture, risk, and milestone plans
- **Security reviewers:** challenge threat model and assumptions
- **Contributors/users:** provide use cases, implementation ideas, and feedback
