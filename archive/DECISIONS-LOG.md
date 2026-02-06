# KeyMaster Decisions Log

This document summarizes the final design decisions from the archived ChatGPT conversations (Aug-Sep 2025). When earlier ideas were superseded by later ones, only the **final position** is recorded.

---

## Hardware Form Factor

| Decision | Final Position |
|----------|----------------|
| **Dimensions** | ~2" x 3" x 0.6" |
| **Power** | Batteryless; USB-powered; supercap for e-paper safe refresh on disconnect |
| **Face A** | 12-key recessed capacitive keypad (pattern-based unlock, silent, one-hand operation) |
| **Face B** | E-paper display (2.7-3.5") |
| **Ports** | 2 x USB-C (simplified from original 3), 1 x MicroSD slot |
| **Enclosure** | Aluminum shell (heatsink, EMI shielding), polycarbonate bezel, tamper switch, IP52-67 target |

---

## Electronics Architecture

### Two Power Domains
| Domain | Components | When Active |
|--------|------------|-------------|
| **Low-Power** | MCU + SE + keypad + display/LED | Always when powered; sufficient for smart-card adapter mode |
| **High-Power** | AP + USB hub + storage controllers | Normal operation; requires adequate power (>80mA) |

### Component Selection
| Component | Specification | Examples |
|-----------|---------------|----------|
| **MCU** | Cortex-M33/M4, USB 2.0 FS, crypto accelerators (AES/ECC/SHA), TrustZone | STM32L562, STM32U575, NXP LPC55S69, nRF52840 |
| **SE (optional)** | ISO7816-compliant, tamper-resistant, OpenPGP/PIV applets | ST33, NXP JCOP, Infineon SLE |
| **AP** | Linux-capable ARM SoC | NXP i.MX6UL, STM32MP1 |

### Storage Tiers
| Storage | Size | Purpose |
|---------|------|---------|
| **SPI-NOR** | 16-32 MB | Bootloader, recovery |
| **SPI-NAND** | 128-512 MB | Vault store (plenty for 10,000+ entries) |
| **eMMC** | 8-16 GB | OS, tools, RO boot images |
| **MicroSD** | User-swappable, up to 1 TB | Bulk user data |
| **NVMe M.2 2230** | Optional (Pro SKU), up to 1 TB | High-speed bulk storage |

---

## USB Architecture

### Simplified from 3 ports to 2 ports
| Decision | Rationale |
|----------|-----------|
| **2 USB-C ports, both DRP** | Either can be upstream (device to host) or downstream (host to peripherals) |
| **No DP Alt Mode** | Deferred; not a dock; user can use external hub for video |
| **Charge-through** | Charger on one port can power phone on the other port |

### Composite USB Device (upstream to host)
- **USB Ethernet** (ECM/NCM/RNDIS auto-select)
- **CCID** (smart card)
- **HID** (keyboard for auto-type)
- **Mass Storage** (UASP/BOT)

### Downstream Host Functions
- Flash drives, backup KeyMasters, USB-Ethernet adapters
- Re-export attached storage as virtual disk (encrypted, policy-controlled)

---

## Operating Modes

| Mode | Trigger | Active Components | Functions |
|------|---------|-------------------|-----------|
| **Low-Power** | Smart-card adapter signature OR <80mA contract | MCU + SE + keypad + LED/glyph | CCID/HID only |
| **High-Power** | Normal USB connection | All | Full composite device, storage, sync |
| **Backup Mode** | Device is both upstream device and downstream host | All | Sync with backup unit while connected to host |

---

## Cryptographic Architecture

### Key Hierarchy (per-profile)
```
PIN → Argon2id(PIN, salt) → PK (PIN Key)
                               ↓
PK + DRS (Device Root Secret) → HKDF → KEK (Key Encryption Key)
                                          ↓
                                    Unwrap MVK (Master Vault Key)
                                          ↓
                               For each entry: Unwrap DEK
                                          ↓
                                    AEAD decrypt/encrypt entry fields
```

### Key Storage
| Key | Where Stored |
|-----|--------------|
| **DRS** | In SE (if present) or derived from MCU HUK |
| **PIN** | Never stored |
| **KEK** | Derived at unlock, held in RAM only |
| **MVK** | Stored wrapped as Wrap(KEK, MVK) on disk |
| **DEK** | Stored per-entry as recipient blobs: {profile_id, Wrap(MVK_p, DEK)} |

### Profile Isolation
- Each profile has independent PIN, KEK, MVK
- Entries can have multiple recipients (shared across profiles)
- Duress/decoy profiles supported (indistinguishable blobs)
- Groups/Hosts are **policy only**, not crypto boundaries

---

## Vault Filesystem (FUSE)

### Layout at `~/.vault/`
```
~/.vault/
  Banking/                 # Group (directory)
    .group.xml
    Chase -> ../.entries/4f8c2.../
  Dev/
    .group.xml
    GitHub -> ../.entries/7c0d1.../
  .entries/
    4f8c2.../
      .entry.xml
      ssh_key
    7c0d1.../
      .entry.xml
  .profiles/
    personal/.profile.xml
    duress/.profile.xml
  .hosts/
    desktop-123/.host.xml
  .index/
    entries_by_slug/
    entries_by_tag/
```

### Key Decisions
| Decision | Rationale |
|----------|-----------|
| **Groups at top level** | No `/groups/` subdirectory; what you see is what your profile+host allows |
| **XML everywhere** | `.group.xml`, `.entry.xml`, `.profile.xml`, `.host.xml` for KeePassXC compatibility |
| **UUIDs for entries** | Stable IDs; human slugs in .entry.xml; symlinks use slugs for display |
| **Visibility = Profile ∩ Host** | Intersection of allowed groups from both |
| **.index/ optional** | Read-only symlink trees for fast lookups (by slug, tag, date) |

---

## SKU Strategy

| Model | MCU | SE | Storage | Notes |
|-------|-----|----|---------|-------|
| **KeyMaster** | Yes | No | eMMC + MicroSD | Fully open, MCU-only crypto |
| **KeyMaster Pro** | Yes | Yes | eMMC + MicroSD + NVMe option | Tamper-resistant, SE anchors keys |

Both use same PCB (SE footprint unpopulated on base model).

---

## Deferred to v2

| Feature | Reason |
|---------|--------|
| **Fingerprint scanner** | Complicates v1 |
| **Smart-card contact adapter** | SBU lines reserved; adapter can be developed later |
| **WiFi/BLE** | RF transparency issues; keep v1 wired-only |
| **DP Alt Mode / dock features** | Not core function; user can use external hub |
| **USB4 retimers** | USB 3.2 Gen 1 sufficient for storage; keeps layout simple |

---

## Licensing

| Component | License |
|-----------|---------|
| **Hardware** | CERN OHL v2 or TAPR OHL |
| **Firmware** | GPLv3 (copyleft) or Apache 2.0 (permissive) |
| **SE internals** | Closed (unavoidable) |
| **Branding** | "KeyMaster" name/logo trademarked |

---

## Threat Model Summary

| Protects Against | Out of Scope |
|------------------|--------------|
| Casual theft | Nation-state lab with invasive chip-level extraction |
| Moderate insider tampering | |
| Remote attacks (when network-connected) | |
| Coffee spills, rain (IP67 target) | |

### Mitigations
- SE for key storage + rate limiting
- Supercap for tamper zeroize
- EMI shielded enclosure
- Signed firmware, disabled debug
- Volatile buffers for PIN

---

## Document Structure (agreed)

1. **README.md** - Elevator pitch, quick overview
2. **docs/vision.md** - Full "why this exists" narrative
3. **docs/specs/hardware.md** - Engineering-quotable hardware spec
4. **docs/specs/software.md** - Firmware/software architecture
5. **docs/specs/security.md** - Crypto design, threat model
6. **docs/user-guide.md** - Polished usage narratives

---

## Unresolved / Open Questions

- Final name decision ("KeyMaster" is working title)
- Exact enclosure IP rating (IP52 vs IP67)
- Whether to require all profile PINs for "admin mode" or just policy
- Specific SE chip selection pending supplier evaluation
