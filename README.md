# Key Master
## Open Hardware Password Manager & Data Vault

*Note: "KeyMaster" is a working name; we're open to better suggestions.*

KeyMaster is a small, open hardware USB device designed to be the practical foundation for everyday secure identity: passwords, SSH/GPG keys, OTPs, wallet seeds, and personal data. It's batteryless—powered entirely by the USB port it plugs into—and aims to be both trustworthy and convenient, usable on any host from locked-down corporate desktops to borrowed laptops, phones, and even smart-card readers.

It is not just a password store. It is a secure interaction point for credentials, keys, and approvals: one device, under your physical control, where you log in, sign, authenticate, and hold your secrets.

**Status:** Concept and design stage, seeking funding and an engineering partner. We have detailed design specifications and are looking for the capital and the collaborators to turn them into hardware and firmware. If you are an investor or an engineering firm, this repository is written for you: start here, then follow the links below into the depth you need.

---

## Why This Exists

Our passwords, keys, and secrets are scattered across devices and services, and every common way of managing them falls short:

- **Browser and platform managers** (Google, Apple) are what most people use, but your secrets ride on your most-attacked online account, stay locked to one ecosystem, and cover only passwords, never your SSH/GPG keys, wallet seeds, or smart-card logins.
- **Cloud managers** (1Password, Bitwarden) put your vault on someone else's servers, to be trusted, subpoenaed, or breached, and need a network and a trusted host to use.
- **Local managers** (KeePass) keep the vault on your machine, but syncing becomes your problem, the host can be compromised, and a borrowed or locked-down computer locks you out.
- **Hardware tokens** (YubiKey, Ledger, Trezor) each do one slice, authentication or coins or keys, but none holds all of it and none adapts to an untrusted host.

The result is everyday friction: you can't safely log in on a coffee-shop computer, a border agent can compel your whole digital life, work machines block the tools you need, and your backup plan is "hope nothing breaks."

**KeyMaster is a single, open, trustworthy device that keeps every secret under your physical control and adapts to any environment.**

---

## The Opportunity

People have already proven they will pay for hardware that keeps their secrets off the network. Crypto hardware wallets are a \$350–450M market growing toward billions. Privacy phones routinely raise seven figures on crowdfunding (BraX3 raised about \$1.9M, the Librem 5 about \$2.1M). Flipper Zero turned a \$60K goal into \$4.8M and has sold over a million units. The broader privacy-technology market is projected to grow from about \$3.2B in 2024 to roughly \$28B by 2034.

Every one of those products solves a single slice: a wallet holds seed phrases, a security key does FIDO2, a privacy phone hardens the mobile stack. The result is that security-conscious people carry several single-purpose devices and juggle fragmented workflows. What no one has shipped is the integration: one device under the user's physical control that unifies credentials, keys, OTP, wallet seeds, passkeys, and context-aware host behavior.

That gap is what KeyMaster fills. See the [full market analysis](docs/vision.md#why-the-market-is-ready) for the sourced figures and the funding picture below for what building it takes.

---

## Speaks the Language of Existing Smart Card Infrastructure

KeyMaster implements **USB CCID** and the PIV/OpenPGP card protocols, the standards the large installed base of smart-card infrastructure already expects. That infrastructure needs no rework: readers, middleware, and smart-card logon just see a card.

- **Enterprise PKI deployments:** defense contractors, financial institutions, and security-conscious corporations that have standardized on smart-card logon. A self-run PKI can provision KeyMaster **today**: issue it certificates, trust it, done.
- **Federal PIV / DoD CAC:** KeyMaster speaks the same protocols these programs use. Serving as one of those credentials is a matter of the issuer provisioning and authorizing the device, plus formal **device certification** (FIPS 140-3, NIST PIV), a business and regulatory path, not a reader-infrastructure one. The hardware is being designed to make that certification *achievable* (see the hardware spec); it's a roadmap ambition, not a v1 claim.
- **Healthcare smart-card programs:** HIPAA-sensitive logins, electronic prescribing, clinical workflows.

Where your organization already speaks smart card, KeyMaster speaks it too. Where your personal life needs a password manager, **passkey/FIDO2 authenticator**, crypto wallet, TOTP generator, and SSH-key holder, it's also all of those, on the same device.

The vast majority of hardware security tokens do one thing. KeyMaster does the things they each do, plus the things the other categories do, plus the things none of them do — in a single device that's interoperable with the standards each of those markets already speaks.

---

## The Killer Feature: Invisible Unlock

Every week you enter a PIN at a checkout terminal behind a flimsy plastic guard, while cameras record your keystrokes. KeyMaster is built so nobody has to see you unlock it at all. Two design choices make that possible:

- **A recessed capacitive keypad.** You unlock by touch alone, silently, with no visible keystrokes and no audible feedback, under a table or inside a pocket.
- **Female USB-C ports, not a male plug.** Most tokens (the OnlyKey, for example) plug straight into the host, so the device sits at the port in plain view unless you fumble with an extension cable. KeyMaster connects by cable, so it stays in your hand or pocket while you enter your PIN.

Profiles add a second layer: each unlock pattern reveals a different set of entries, a **duress pattern** opens a harmless decoy vault, and because the encrypted blobs are indistinguishable, there is no way to prove other profiles exist. At a border crossing you unlock a travel profile, and your banking, crypto, and work credentials simply don't exist as far as anyone can tell.

---

## What We're Building

A compact USB-C device (~2" × 3") that draws power from whatever it's plugged into—**no battery to charge or replace**—and intelligently adapts to its environment. (A supercapacitor keeps its clock running for weeks unpowered, so TOTP works anywhere.)

**Physical Design:**

- 12-key recessed capacitive keypad (silent by default, pattern-based unlock, usable by touch under a table; optional light haptic confirmation you can silence)
- E-paper display (readable in sunlight, no light leakage, persists when unplugged)
- Durable metal shell, built to take abuse and resist intrusion
- Two fully dual-role USB-C ports (either can be upstream or downstream; power passes through to your phone)
- MicroSD slot for bulk storage

**Adaptive Security Modes:**

- **Untrusted host:** CCID smart card, HID keyboard, and FIDO2 only. Auto-type credentials and log in with passkeys without exposing the vault.
- **Trusted host:** Mount the vault as a filesystem (host-side helper), with KeePass-family (`.kdbx`) compatibility.
- **Smart-card reader:** Low-power mode via adapter for legacy systems.

**Storage Options:**

- Secure vault: 128-512 MB (enough for 10,000+ entries with attachments)
- Onboard flash: 8-16 GB for OS and tools on the base model; the Pro model uses higher-capacity UFS in the same chip footprint, up to ~1 TB
- User storage: MicroSD up to 1 TB, plus external drives via USB-C for more

---

## Sold in Pairs

The single biggest cause of lost credentials is "I meant to back up, but I never got around to it." KeyMaster addresses this at the point of sale: **the default purchase is a pair, not a single device.** Two units together, at a meaningful discount over buying one, so every new user starts with an automatic backup in hand.

The two units sync whenever they can reach each other. A backup can sit powered and networked, plugged into a home machine, or standalone on your network through a USB-C Ethernet adapter (even inside a safe, over a single PoE cable), and stay current on its own; or you can sync two units directly, USB-to-USB, by hand. A backup syncs while still **locked** (it only ever moves encrypted data), and if it's been offline it catches up the moment you next connect it. The primary lives with you; the backup lives in a safe, a safe-deposit box, a trusted relative's house, or wherever makes sense for your threat model.

Single units remain available — to replace a lost device, to add a third backup, or for users who have their own backup strategy — but new buyers are strongly steered toward the pair. Backup isn't a feature you have to remember to set up; it's something you already have because you already bought it.

This pattern also reinforces a healthy mental model: **KeyMasters are fungible paired devices, not single precious objects.** If one gets lost or damaged, you buy a replacement, sync from the surviving twin, and you're whole again.

---

## What It Will Take to Build

KeyMaster is at the design stage. Turning it into a shipping product is a significant, multi-year hardware effort.

A realistic path to a shipping v1 is roughly **\$4–7M over 24–36 months**: a dual-processor secure device carried through prototype, design-for-manufacture, baseline certification (FCC, CE, FIDO2), and a first production run. A lean effort that blends offshore talent and defers heavy certification could reach a pilot for around \$2–3.5M. Pursuing government-grade device certification (FIPS 140-3, Common Criteria) for v1 pushes the ceiling toward \$8–12M and adds one to two years of certification queue, which is why we treat it as a later milestone rather than a v1 gate.

**The near-term ask:** a seed raise toward the **\$4–6M** range funds the path to a self-certified v1 pilot. The fully certified, at-scale product realistically spans a seed round plus a Series A.

We de-risk deliberately:

- **Inherited assurance.** KeyMaster's high-security certifications come from a pre-certified secure element, so the multi-million-dollar chip evaluation is the silicon vendor's cost, not ours.
- **Ship on self-certification.** v1 targets FCC and CE self-declaration (no radio, so no costly RF path) plus FIDO2, with FIPS 140-3 and Common Criteria as funded fast-follows.
- **Honest about the risks.** The dominant ones are certification timelines, the depth of two full firmware stacks, and the economics of a machined-metal device sold as a pair. These are laid out in the [engineering brief](docs/engagement.md) and the [hardware spec](docs/specs/hardware.md).

Hardware budgets tend to run over, so these figures carry contingency, and the specifications behind them are detailed enough for an engineering firm to quote against rather than guess.

**What it might sell for.** Early unit economics are rough but worth stating. A small Linux computer plus a security core, an e-paper display, a keypad, and a machined-metal shell carries a premium bill of materials, roughly **\$100–180 per device** to build at low volume. At the usual direct-to-consumer hardware markup (about 2.5–3× cost), and given the sold-in-pairs model, that points to a launch price around a **\$500–900 pair** (~\$300–500 per device). At real production volume, component pricing, a cheaper enclosure process, and amortized tooling could bring that toward a **\$300–500 pair**. This is a premium price point, closer to a mid-range phone than a \$50 token; the market comps say the willingness-to-pay exists in this range (people fund \$800 privacy phones and buy \$280 hardware wallets), but it has to be earned by the integration story: one device that replaces a wallet, a security key, a password manager, and an authenticator, with a backup already in the box. Validating that willingness-to-pay early is a standing priority.

---

## Core Capabilities

**Identity & Secrets Management:**

- Passwords, usernames, URLs, notes
- **Passkeys / FIDO2:** phishing-resistant, and (uniquely) backed up and portable across your paired devices
- SSH and GPG keys
- TOTP/HOTP seeds
- Crypto wallet seeds and keys
- Certificates and API tokens

**File Storage & Sync:**

- Encrypted partitions unlocked by the device
- **Inline encryption of external drives:** plug a drive into KeyMaster; it encrypts/decrypts in transit at line rate
- Read-only "tools" partition for trusted binaries
- Bootable rescue image
- Automatic sync between active and backup units

**Security Features:**

- Per-profile cryptographic isolation, with deniable hidden profiles
- Un-extractable device secret; tiered secure-element / tamper protection
- **Wipes its secrets under attack:** too many wrong PINs, or a physical intrusion, erases the device; your data is safe because it also lives on your backup
- Supercapacitor for safe shutdown, timekeeping, and tamper response
- The vault and your keys never touch the host; individual credentials cross only when you deliberately use them (auto-type, signing)

---

## Technical Architecture

**Dual-Processor Design:**

- **Security MCU (always on):** Handles keypad, display, the device secret, PIN entry, and core vault crypto. It runs **standalone**, even from a smart-card reader's power, with the application processor off. Small, auditable, and physically separate from the Linux brain.
- **Application Processor (high-power, USB3-class, Linux):** FUSE vault presentation, sync daemon, composite USB gadget, and line-rate inline encryption of external media via its hardware crypto engine. Powers up only when needed.

**Storage Tiers:**

- SPI-NOR: Bootloader and recovery
- SPI-NAND: Encrypted vault store
- UFS (preferred) or eMMC: Operating system, tools, and Pro extra capacity
- MicroSD and external USB-C drives: User bulk storage

**USB Composite Device:**

- Ethernet (ECM/NCM/RNDIS), link-local only, never a default route (won't hijack host traffic)
- CCID smart card
- HID keyboard
- FIDO2 / passkey authenticator
- Encrypted mass storage

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

- PIN is never stored; master keys exist only in RAM when unlocked
- Sharing seals an entry to each recipient's per-profile public key, so it works across profiles and across devices
- Hidden profiles are stored so their count can't be recovered from the device (deniable "object-soup" format)
- The device secret is un-extractable (secure element, or a split-secret anchored in the MCU)

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
- KeePass-family (`.kdbx`) compatibility

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

- Interoperability with existing tools (the KeePass family, GPG, SSH); by speaking `.kdbx` we piggyback on their mature browser extensions and mobile apps instead of rebuilding them
- Standard protocols (CCID, FIDO2, USB mass storage)
- Contributions welcome

---

## Documentation


| Document                                | Description                                 |
| --------------------------------------- | ------------------------------------------- |
| [Vision](docs/vision.md)                | Product thesis, market context, and philosophy |
| [Engineering Partners](docs/engagement.md) | Scope of work, deliverables, and acceptance criteria for a build partner |
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
