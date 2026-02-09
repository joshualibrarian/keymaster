# Key Master
## Open Hardware Password Manager & Data Vault

*Note: "KeyMaster" is a working name; we're open to better suggestions.*

KeyMaster is a small, open hardware USB device designed to be the practical foundation for everyday secure identity: passwords, SSH/GPG keys, OTPs, wallet seeds, and personal data. It's batteryless—powered entirely by the USB port it plugs into—and aims to be both trustworthy and convenient, usable on any host from locked-down corporate desktops to borrowed laptops and phones.

**Status:** Concept and design-in-progress. We're looking for an engineering partner and early collaborators to turn this into hardware and firmware.

---

## Why This Exists

Our digital lives are a mess of passwords, keys, and secrets scattered across devices and services. The current solutions are fundamentally broken:

**Cloud password managers** (1Password, LastPass, Bitwarden, etc.) are convenient but have critical gaps:

- Your vault lives on someone else's servers
- You must trust their cloud, their code, their security practices
- They can be subpoenaed, hacked, or shut down
- They require an internet connection and a trusted host

**Local password managers** (KeePass, KeePassXC, etc.) keep your vault on your own machine, but:

- You must first unlock the host to access your vault—two unlock steps, two attack surfaces
- The host itself may be compromised (keyloggers, malware, shoulder surfers)
- Syncing your vault across devices becomes your problem
- On a borrowed or locked-down machine, you can't use it at all

**Hardware tokens** solve pieces but create new problems:

- YubiKeys do authentication, not password storage
- Crypto wallets handle coins, not your SSH keys or login credentials
- Secure flash drives are just encrypted storage with no smarts
- None of them work well on locked-down or borrowed machines

**The real-world pain points:**

- At a coffee shop, you can't safely log in—keyloggers, shoulder surfers, compromised machines
- At a border crossing, you might be forced to unlock your devices
- At work, USB storage is blocked but you still need your credentials
- Your backup strategy is "hope nothing breaks"

**KeyMaster solves this** by being a single, open, trustworthy device that adapts to any environment while keeping your secrets under your physical control.

---

## The Killer Feature: Invisible Unlock

Every week, you enter your PIN at grocery store terminals with a flimsy plastic guard—while a hundred cameras record your keystrokes. KeyMaster's recessed capacitive keypad changes this: you can unlock it by touch alone, invisibly, under a table or in your pocket.

**Why this matters:**

- No shoulder surfer can see your pattern
- No camera can record your keystrokes
- No one even knows you're unlocking anything
- Silent capacitive touch—no audible feedback to give you away

**Profiles add another layer:**

- Multiple profiles, each with its own unlock pattern
- Each profile reveals different groups of entries
- A **duress profile** can show harmless dummy data
- The encrypted blobs are indistinguishable—there's no way to prove other profiles exist

**Real scenarios:**

- **Border crossing:** Unlock your "travel" profile. Officials see airline and hotel logins. Your banking, crypto, and work credentials don't exist as far as they can tell.
- **Coerced unlock:** Enter your duress pattern. The device unlocks to a decoy vault. Your real data remains hidden.
- **Public spaces:** Unlock under the table at a coffee shop. Nobody sees. Nobody knows.

---

## What We're Building

A compact USB-C device (~2" × 3") that draws power from whatever it's plugged into—no battery needed—and intelligently adapts to its environment:

**Physical Design:**

- 12-key recessed capacitive keypad (silent, pattern-based unlock, usable by touch under a table)
- E-paper display (readable in sunlight, no light leakage, persists when unplugged)
- Two USB-C ports (either can be upstream; one for backups/flash drives)
- MicroSD slot for bulk storage

**Adaptive Security Modes:**

- **Untrusted host:** CCID smart card + HID keyboard only. Auto-type credentials without exposing the vault.
- **Trusted host:** Mount the vault filesystem directly. KeePassXC integration.
- **Smart-card reader:** Low-power mode via adapter for legacy systems.

**Storage Options:**

- Secure vault: 128-512 MB (enough for 10,000+ entries with attachments)
- OS and tools: 8-16 GB eMMC
- User storage: MicroSD up to 1 TB
- Pro model: M.2 NVMe up to 1 TB

---

## Core Capabilities

**Identity & Secrets Management:**

- Passwords, usernames, URLs, notes
- SSH and GPG keys
- TOTP/HOTP seeds
- Crypto wallet seeds and keys
- Certificates and API tokens

**File Storage & Sync:**

- Encrypted partitions unlocked by the device
- Read-only "tools" partition for trusted binaries
- Bootable rescue image
- Automatic sync between active and backup units

**Security Features:**

- Per-profile cryptographic isolation
- Optional secure element for tamper resistance
- Supercapacitor for safe shutdown and tamper response
- All crypto on-device; secrets never touch the host

---

## Technical Architecture

**Dual-Processor Design:**

- **MCU (always on):** Handles keypad, display, USB device functions, crypto. Can run standalone in low-power mode.
- **Application Processor (high-power):** Runs Linux for FUSE filesystem, sync daemon, composite USB gadget.

**Storage Tiers:**

- SPI-NOR: Bootloader and recovery
- SPI-NAND: Encrypted vault store
- eMMC: Operating system and tools
- MicroSD/NVMe: User bulk storage

**USB Composite Device:**

- Ethernet (ECM/NCM/RNDIS)
- CCID smart card
- HID keyboard
- Mass storage (UASP)

See [docs/specs/hardware.md](docs/specs/hardware.md) for the full engineering specification.

---

## Cryptographic Security

**Key Hierarchy:**

```
PIN → Argon2id → Profile Key (PK)
PK + Device Root Secret → KEK
KEK unwraps → Master Vault Key (MVK)
MVK unwraps → Per-entry Data Encryption Keys (DEK)
```

**Key Properties:**

- PIN is never stored
- Master keys exist only in RAM when unlocked
- Each entry can have multiple recipients (for sharing across profiles)
- Optional secure element anchors the Device Root Secret

See [docs/specs/security.md](docs/specs/security.md) for the full cryptographic specification.

---

## Development Roadmap

**Phase 0: Partnership (Current)**

- Finalize specifications
- Find engineering partner for hardware/firmware development
- Build community of early collaborators

**Phase 1: Prototype**

- Custom PCB design
- MCU firmware (keypad, display, USB, crypto)
- Basic vault functionality

**Phase 2: Full Implementation**

- Linux on AP
- FUSE filesystem
- Sync daemon
- KeePassXC integration

**Phase 3: Production**

- Enclosure tooling
- Manufacturing setup
- Certification (FCC, CE)

---

## Why Open Source Matters

**Security through transparency:**

- Auditable hardware designs
- Auditable firmware and software
- No hidden backdoors
- Community review of cryptographic implementation

**User empowerment:**

- Build your own if you want
- Modify to suit your needs
- Fork if the project goes sideways
- Truly own your security infrastructure

**Ecosystem benefits:**

- Interoperability with existing tools (KeePassXC, GPG, SSH)
- Standard protocols (CCID, FIDO, USB mass storage)
- Contributions welcome

---

## Documentation


| Document                                | Description                                 |
| --------------------------------------- | ------------------------------------------- |
| [Vision](docs/vision.md)                | Full philosophy and "why this exists"       |
| [Hardware Spec](docs/specs/hardware.md) | Engineering-quotable hardware specification |
| [Software Spec](docs/specs/software.md) | Firmware and software architecture          |
| [Security Spec](docs/specs/security.md) | Cryptographic design and threat model       |
| [User Guide](docs/user-guide.md)        | Usage scenarios and workflows               |
| [Examples](examples.md)                 | Detailed narrative use cases                |

---

## License

- **Hardware:** CERN Open Hardware License v2 (strongly reciprocal)
- **Firmware/Software:** GPLv3 or Apache 2.0 (TBD with engineering partner)
- **Branding:** "KeyMaster" name and logo trademarked

The commitment to open source is non-negotiable.

---

## Get Involved

**For engineering partnerships:** We're actively seeking a hardware/firmware development partner. If you're an engineering firm with experience in secure embedded systems, we'd love to discuss collaboration.

**For early feedback:** Open an issue on GitHub or reach out with questions, suggestions, or use cases we should consider.

**For contributors:** Hardware design, firmware development, host software, documentation, and testing all need help.

Together, we can build a future where everyone has secure, convenient access to their digital identity without sacrificing privacy or control.
