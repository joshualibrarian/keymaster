# KeyMaster – Software Specification

**Version:** 0.1 (Draft)
**Status:** Design-in-progress

This document specifies the firmware and software architecture for KeyMaster. It is intended to be quotable by engineering firms for development estimates.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [MCU Firmware](#mcu-firmware)
3. [Application Processor Software](#application-processor-software)
4. [USB Composite Device](#usb-composite-device)
5. [Vault Filesystem](#vault-filesystem)
6. [Sync Protocol](#sync-protocol)
7. [Host Software](#host-software)
8. [Boot and Update](#boot-and-update)
9. [Development Priorities](#development-priorities)

---

## Architecture Overview

### Dual-Processor Model

KeyMaster uses two processors with distinct responsibilities:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        KeyMaster Software Stack                     │
├─────────────────────────────────┬───────────────────────────────────┤
│         MCU Domain              │         AP Domain                 │
│      (Always Available)         │      (High-Power Mode)            │
├─────────────────────────────────┼───────────────────────────────────┤
│  ┌─────────────────────────┐    │    ┌─────────────────────────┐    │
│  │     Keypad Driver       │    │    │      Linux Kernel       │    │
│  ├─────────────────────────┤    │    ├─────────────────────────┤    │
│  │    Display Driver       │    │    │    USB Gadget Driver    │    │
│  │    (E-Paper/LED)        │    │    │  (Composite Device)     │    │
│  ├─────────────────────────┤    │    ├─────────────────────────┤    │
│  │   USB Device Stack      │    │    │    FUSE Filesystem      │    │
│  │   (CCID, HID, CDC)      │    │    │    (Vault Mount)        │    │
│  ├─────────────────────────┤    │    ├─────────────────────────┤    │
│  │   Crypto Engine         │    │    │    Sync Daemon          │    │
│  │   (AES, ECC, SHA)       │    │    │    (kmsyncd)            │    │
│  ├─────────────────────────┤    │    ├─────────────────────────┤    │
│  │   Secure Element I/F    │    │    │   Web UI (Optional)     │    │
│  │   (ISO7816, SPI)        │    │    │   (Local management)    │    │
│  ├─────────────────────────┤    │    ├─────────────────────────┤    │
│  │   State Machine         │    │    │   Storage Drivers       │    │
│  │   (Profiles, Policies)  │    │    │   (eMMC, SD, NVMe)      │    │
│  └─────────────────────────┘    │    └─────────────────────────┘    │
├─────────────────────────────────┴───────────────────────────────────┤
│                        Inter-Processor Communication                │
│                    (SPI + GPIO handshake + shared SRAM)             │
└─────────────────────────────────────────────────────────────────────┘
```

### Operating Modes


| Mode           | Power | MCU    | AP     | USB Functions  | Trigger                             |
| -------------- | ----- | ------ | ------ | -------------- | ----------------------------------- |
| **Low-Power**  | <80mA | Active | Off    | CCID, HID only | Smart-card adapter or low-power USB |
| **High-Power** | Full  | Active | Active | Full composite | Normal USB connection               |
| **Backup**     | Full  | Active | Active | Device + Host  | Backup unit connected downstream    |

---

## MCU Firmware

### Target Platform

- **Processor:** ARM Cortex-M33 or M4 with TrustZone
- **Examples:** STM32L562, STM32U575, NXP LPC55S69
- **Clock:** 80-160 MHz
- **RAM:** 256 KB minimum (512 KB preferred)
- **Flash:** 512 KB minimum for firmware

### Firmware Components

#### 1. Keypad Driver

```
Responsibilities:
- Capacitive touch scanning (12 keys)
- Pattern recognition (unlock sequences)
- Debouncing and noise rejection
- Interrupt-driven with low-power sleep

Interface:
- keypad_init()
- keypad_get_event() → {key, press/release, timestamp}
- keypad_get_pattern() → pattern_buffer
- keypad_set_backlight(level)

Power Budget:
- Active scanning: <5mA
- Sleep (interrupt wake): <100µA
```

#### 2. Display Driver

```
Responsibilities:
- E-paper display updates (partial and full refresh)
- Glyph rendering (icons, status indicators)
- Text rendering (entries, menus)
- Safe refresh on power loss (supercap-backed)

Interface:
- display_init()
- display_clear()
- display_text(x, y, string, font)
- display_glyph(x, y, glyph_id)
- display_refresh(partial: bool)
- display_sleep()

Refresh Times:
- Full refresh: <1s
- Partial refresh: <300ms
```

#### 3. USB Device Stack

The MCU implements a USB 2.0 Full Speed device with multiple interfaces:

**CCID (Chip Card Interface Device)**

```
- ISO7816 T=0 and T=1 protocols
- OpenPGP card emulation (signing, decryption, authentication)
- PIV card emulation (optional)
- Up to 3 virtual card slots

Commands:
- PC_to_RDR_IccPowerOn
- PC_to_RDR_XfrBlock (APDU exchange)
- PC_to_RDR_IccPowerOff
```

**HID Keyboard**

```
- Standard USB HID keyboard
- Auto-type credential injection
- Configurable typing speed (evade detection)
- Support for special characters via Alt codes

Interface:
- hid_type_string(string, speed_ms)
- hid_type_credential(entry_id, field)
- hid_send_key(keycode, modifiers)
```

**CDC ACM (Serial)**

```
- Debug console (disabled in production)
- Host communication channel (when AP unavailable)
```

#### 4. Cryptographic Engine

All cryptographic operations run on the MCU, using hardware accelerators when available:

```
Algorithms:
- AES-256-GCM (vault encryption)
- ChaCha20-Poly1305 (alternative AEAD)
- X25519 (key agreement)
- Ed25519 (signatures)
- SHA-256, SHA-512 (hashing)
- Argon2id (PIN stretching)
- HKDF (key derivation)

Interface:
- crypto_aead_encrypt(key, nonce, plaintext, aad) → ciphertext
- crypto_aead_decrypt(key, nonce, ciphertext, aad) → plaintext
- crypto_kdf(ikm, salt, info, length) → derived_key
- crypto_argon2(password, salt, params) → hash
- crypto_sign(key, message) → signature
- crypto_verify(key, message, signature) → bool

Memory:
- Keys held in secure RAM (TrustZone if available)
- Zeroization on unlock timeout or tamper
```

#### 5. Secure Element Interface

```
Communication:
- ISO7816-3 contact interface (primary)
- SPI interface (alternative)

Functions:
- Store Device Root Secret (DRS)
- Rate-limit PIN attempts
- Provide hardware RNG
- Sign with device attestation key

Commands (via APDU):
- SELECT applet
- VERIFY PIN
- GET CHALLENGE
- INTERNAL AUTHENTICATE
- COMPUTE DIGITAL SIGNATURE
```

#### 6. State Machine

The MCU maintains device state across all modes:

```
States:
- LOCKED: No profile active, only unlock UI
- UNLOCKED: Profile active, services available
- COMPOSITE: AP running, full functions
- TAMPER: Threat detected, keys zeroized

Transitions:
- LOCKED → UNLOCKED: Valid PIN entry
- UNLOCKED → COMPOSITE: AP boot complete
- UNLOCKED → LOCKED: Timeout or user lock
- ANY → TAMPER: Tamper switch or anomaly

Persistent State (in NOR flash):
- Profile metadata (salt, wrapped keys)
- Host policies
- Device configuration
- Attempt counters
```

### MCU Memory Map

```
Flash (512 KB):
  0x00000000 - 0x00010000  Bootloader (64 KB)
  0x00010000 - 0x00070000  Firmware A (384 KB)
  0x00070000 - 0x00080000  Config + State (64 KB)

RAM (256 KB):
  0x20000000 - 0x20010000  Stack + Heap (64 KB)
  0x20010000 - 0x20030000  Crypto buffers (128 KB)
  0x20030000 - 0x20040000  USB buffers (64 KB)

Secure RAM (TrustZone, 32 KB):
  0x30000000 - 0x30008000  Active keys, PIN buffer
```

---

## Application Processor Software

### Target Platform

- **Processor:** ARM Cortex-A7 or A53 (Linux-capable)
- **Examples:** NXP i.MX6UL, STM32MP157, Allwinner V3s
- **RAM:** 256 MB minimum (512 MB preferred)
- **Storage:** 8-16 GB eMMC for OS and tools

### Operating System

```
Base: Linux (mainline kernel preferred)
  - Kernel: 5.15 LTS or newer
  - Init: systemd or BusyBox init
  - Root filesystem: Read-only SquashFS + overlayfs

Size Budget:
  - Kernel + DTB: ~8 MB
  - Root filesystem: ~200 MB
  - Tools partition: ~2 GB
  - Remaining: User data
```

### Core Services

#### 1. USB Gadget Driver (ConfigFS)

```
Composite Device Configuration:
  /sys/kernel/config/usb_gadget/keymaster/
    ├── idVendor          (0x1D50 OpenMoko)
    ├── idProduct         (TBD)
    ├── strings/0x409/
    │   ├── manufacturer  "KeyMaster Project"
    │   ├── product       "KeyMaster"
    │   └── serialnumber  (device UUID)
    ├── configs/c.1/
    │   ├── ecm.usb0     → Ethernet (ECM/NCM/RNDIS)
    │   ├── ccid.usb0    → Smart card (passthrough to MCU)
    │   ├── hid.usb0     → Keyboard (passthrough to MCU)
    │   └── mass_storage.usb0 → Storage (UASP/BOT)
    └── functions/
        ├── ecm.usb0/
        ├── ncm.usb0/
        ├── rndis.usb0/
        ├── mass_storage.usb0/
        └── ffs.ccid/     (FunctionFS for CCID)
```

#### 2. FUSE Vault Filesystem (kmvaultfs)

The vault is presented to hosts as a FUSE filesystem:

```
Mount Point: /mnt/vault (internal), exported via USB mass storage

Virtual Layout:
  /vault/
    ├── Banking/              # Group directory
    │   ├── .group.xml        # Group metadata
    │   ├── Chase → ../.entries/4f8c2.../
    │   └── CreditUnion → ../.entries/a12b9.../
    ├── Dev/
    │   └── GitHub → ../.entries/7c0d1.../
    ├── .entries/             # Canonical entry storage
    │   ├── 4f8c2.../
    │   │   ├── .entry.xml    # Entry metadata
    │   │   └── ssh_key       # Attachment
    │   └── 7c0d1.../
    ├── .profiles/
    │   ├── personal/.profile.xml
    │   └── duress/.profile.xml
    ├── .hosts/
    │   └── desktop-123/.host.xml
    └── .index/               # Read-only indexes
        ├── by-slug/
        ├── by-tag/
        └── by-date/

Visibility Rules:
  Visible Groups = Profile.allowed_groups ∩ Host.allowed_groups
  Visible Entries = Entries in visible groups with recipient blob for active profile
```

**FUSE Operations:**

```c
struct fuse_operations kmvault_ops = {
    .getattr  = kmvault_getattr,   // Stat files/dirs
    .readdir  = kmvault_readdir,   // List directory
    .open     = kmvault_open,      // Open file (decrypt on demand)
    .read     = kmvault_read,      // Read decrypted content
    .write    = kmvault_write,     // Write + encrypt
    .create   = kmvault_create,    // New entry
    .unlink   = kmvault_unlink,    // Delete entry
    .mkdir    = kmvault_mkdir,     // New group
    .rmdir    = kmvault_rmdir,     // Delete group
    .rename   = kmvault_rename,    // Move entry/group
    .truncate = kmvault_truncate,  // Resize
    .fsync    = kmvault_fsync,     // Commit to storage
};
```

#### 3. Sync Daemon (kmsyncd)

Handles synchronization between KeyMaster units:

```
Discovery:
  - mDNS/DNS-SD: _keymaster._tcp
  - USB-Ethernet link-local
  - Manual IP configuration

Protocol:
  - TLS 1.3 mutual authentication
  - Device certificates signed by owner key
  - Content-addressed object store
  - Merkle tree for efficient diff

Sync Algorithm:
  1. Exchange root hashes
  2. Identify differing subtrees
  3. Request missing objects
  4. Verify and store
  5. Update local index
  6. Commit transaction

Conflict Resolution:
  - Last-writer-wins with vector clocks
  - Deleted entries tombstoned (sync deletion)
  - Conflicts flagged for user resolution
```

#### 4. Web UI (Optional)

Local management interface served over USB-Ethernet:

```
Stack:
  - Lightweight HTTP server (e.g., mongoose, lighttpd)
  - Static HTML/CSS/JS (no framework dependencies)
  - REST API for operations

Endpoints:
  GET  /api/status          Device status
  GET  /api/entries         List entries (filtered by profile)
  GET  /api/entries/:id     Get entry details
  POST /api/entries         Create entry
  PUT  /api/entries/:id     Update entry
  DELETE /api/entries/:id   Delete entry
  POST /api/sync/start      Initiate sync
  GET  /api/sync/status     Sync progress
  POST /api/backup          Start backup
  GET  /api/hosts           List known hosts
  POST /api/hosts           Register host

Security:
  - HTTPS only (self-signed cert, pinned in host software)
  - Requires active unlock
  - All sensitive ops require on-device confirmation
```

---

## USB Composite Device

### Device Descriptors

```
Device Descriptor:
  bcdUSB: 0x0210 (USB 2.1 for BOS)
  bDeviceClass: 0xEF (Miscellaneous)
  bDeviceSubClass: 0x02 (Common Class)
  bDeviceProtocol: 0x01 (Interface Association)
  idVendor: 0x1D50 (OpenMoko - open hardware)
  idProduct: TBD
  bcdDevice: 0x0100
  iManufacturer: "KeyMaster Project"
  iProduct: "KeyMaster"
  iSerialNumber: (device UUID)

Configuration Descriptor:
  bNumInterfaces: 6-8 (depending on mode)
  bMaxPower: 500mA (high-power) or 100mA (low-power)
```

### Interface Configuration


| Interface | Class     | SubClass | Protocol | Description                 |
| --------- | --------- | -------- | -------- | --------------------------- |
| 0         | 0x0B      | 0x00     | 0x00     | CCID (Smart Card)           |
| 1         | 0x03      | 0x01     | 0x01     | HID Keyboard                |
| 2-3       | 0x02/0x0A | -        | -        | CDC ECM (Ethernet)          |
| 4         | 0x08      | 0x06     | 0x50     | Mass Storage (UASP)         |
| 5         | 0x08      | 0x06     | 0x62     | Mass Storage (BOT fallback) |

### Mode-Specific Configurations

**Low-Power Mode (Smart Card Adapter):**

```
Interfaces: CCID + HID only
Power: 100mA max
Functions: PIN entry, credential auto-type, CCID operations
```

**High-Power Mode (Full Composite):**

```
Interfaces: All
Power: 500mA
Functions: Storage mount, sync, full management
```

---

## Vault Filesystem

### On-Disk Format

The vault is stored in SPI-NAND flash as an encrypted object store:

```
Physical Layout (SPI-NAND, 256 MB example):
  Block 0-15:     Superblock + metadata (redundant)
  Block 16-31:    Object index
  Block 32+:      Object data (content-addressed)

Superblock:
  magic: "KMVAULT1"
  version: 1
  created: timestamp
  device_id: UUID
  root_hash: SHA-256 of index root

Object Format:
  object_id: SHA-256(content)
  type: blob | tree | entry | profile | host
  size: uint32
  content: encrypted bytes
  recipients: [{profile_id, wrapped_dek}]
```

### Entry Format (XML)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<entry uuid="4f8c2a1b-..." version="3" modified="2025-09-15T14:30:00Z">
  <title>Chase Bank</title>
  <username>john.doe@email.com</username>
  <password protected="true"><!-- encrypted in blob --></password>
  <url>https://chase.com/login</url>
  <notes>Main checking account</notes>
  <tags>
    <tag>banking</tag>
    <tag>financial</tag>
  </tags>
  <totp>
    <secret protected="true"><!-- encrypted --></secret>
    <digits>6</digits>
    <period>30</period>
    <algorithm>SHA1</algorithm>
  </totp>
  <attachments>
    <attachment name="recovery_codes.txt" size="1024" hash="sha256:..."/>
  </attachments>
  <history>
    <previous version="2" modified="2025-08-01T10:00:00Z" hash="sha256:..."/>
  </history>
</entry>
```

### Group Format (XML)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<group uuid="7d3f1..." name="Banking" icon="bank">
  <description>Financial accounts</description>
  <created>2025-01-15T00:00:00Z</created>
  <settings>
    <auto-lock-timeout>300</auto-lock-timeout>
    <require-confirmation>true</require-confirmation>
  </settings>
</group>
```

### Profile Format (XML)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<profile uuid="a1b2c3..." name="personal" type="primary">
  <created>2025-01-15T00:00:00Z</created>
  <allowed-groups>
    <group uuid="7d3f1..."/>  <!-- Banking -->
    <group uuid="8e4g2..."/>  <!-- Dev -->
    <group uuid="9f5h3..."/>  <!-- Personal -->
  </allowed-groups>
  <settings>
    <unlock-timeout>3600</unlock-timeout>
    <require-presence>true</require-presence>
  </settings>
  <!-- Wrapped MVK stored separately in keystore -->
</profile>
```

### Host Policy Format (XML)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<host uuid="desktop-123" fingerprint="sha256:...">
  <name>Home Desktop</name>
  <first-seen>2025-01-20T00:00:00Z</first-seen>
  <last-seen>2025-09-15T14:00:00Z</last-seen>
  <trust-level>full</trust-level>
  <allowed-groups>
    <group uuid="7d3f1..."/>
    <group uuid="8e4g2..."/>
    <group uuid="9f5h3..."/>
  </allowed-groups>
  <allowed-functions>
    <function>mount-vault</function>
    <function>sync</function>
    <function>backup</function>
  </allowed-functions>
</host>
```

---

## Sync Protocol

### Object Exchange Protocol

```
Message Format (TLS 1.3 encrypted):
  {
    "type": "request" | "response" | "push",
    "id": "uuid",
    "timestamp": "iso8601",
    "payload": { ... }
  }

Request Types:
  - HELLO: Exchange device info and root hashes
  - DIFF: Request objects missing from local store
  - FETCH: Request specific objects by hash
  - PUSH: Send objects to peer
  - COMMIT: Finalize transaction
  - ABORT: Cancel transaction

Example Flow:
  A → B: HELLO {root_hash: "abc123...", vector_clock: {...}}
  B → A: HELLO {root_hash: "def456...", vector_clock: {...}}
  A → B: DIFF {have: [...], want: [...]}
  B → A: PUSH {objects: [...]}
  A → B: COMMIT {new_root: "ghi789..."}
  B → A: ACK
```

### Conflict Handling

```
Vector Clock per Entry:
  {
    "device_a": 5,
    "device_b": 3
  }

Merge Rules:
  1. If clocks are comparable (one dominates), take dominant
  2. If concurrent (neither dominates), flag conflict
  3. User resolves via UI (keep A, keep B, merge)
  4. Resolution increments clock and syncs

Tombstones:
  - Deleted entries replaced with tombstone object
  - Tombstones sync to all peers
  - Tombstones expire after 90 days
```

---

## Host Software

### CLI Tool (km)

```bash
# Installation
$ cargo install keymaster-cli  # or apt install keymaster-cli

# Basic usage
$ km status                    # Show device status
$ km unlock                    # Interactive unlock
$ km list                      # List entries
$ km get github.com            # Get entry by URL/title
$ km add                       # Interactive add entry
$ km generate                  # Generate password
$ km totp github               # Show TOTP code
$ km ssh-add                   # Add SSH keys to agent
$ km sync                      # Manual sync trigger

# Advanced
$ km mount ~/vault             # Mount vault filesystem
$ km backup /path/to/backup    # Create encrypted backup
$ km export --format=kdbx      # Export to KeePass format
$ km import file.kdbx          # Import from KeePass
```

### Browser Extension

```
Features:
  - Auto-fill credentials on matching URLs
  - Generate passwords inline
  - Save new credentials
  - TOTP auto-copy

Communication:
  - Native messaging to CLI tool
  - CLI communicates with device via USB

Supported Browsers:
  - Firefox
  - Chrome/Chromium
  - Safari (macOS)
```

### SSH Agent Integration

```
Mode 1: Agent Proxy
  - km acts as SSH agent
  - Forwards requests to device CCID
  - SSH_AUTH_SOCK=/run/user/$UID/keymaster.sock

Mode 2: PKCS#11 Provider
  - Device provides PKCS#11 .so
  - ssh -I /usr/lib/keymaster-pkcs11.so user@host
```

### KeePassXC Integration

```
Database Location:
  - ~/.vault/ (FUSE mount from device)
  - KeePassXC opens XML files directly
  - Changes saved back through FUSE → encrypted on device

Configuration:
  - KeePassXC browser integration works unchanged
  - Secret Service API via device
```

---

## Boot and Update

### MCU Boot Sequence

```
1. Hardware init (clocks, GPIO, power rails)
2. Verify bootloader signature
3. Check firmware A/B slots, select valid
4. Verify firmware signature
5. Initialize crypto engine
6. Initialize SE (if present)
7. Initialize keypad, display
8. Show "LOCKED" on display
9. Initialize USB device stack
10. Enter main loop (wait for unlock)
```

### AP Boot Sequence

```
1. MCU asserts AP power enable
2. AP ROM loads SPL from SPI-NOR
3. SPL loads U-Boot from eMMC
4. U-Boot verifies kernel signature
5. Linux kernel boots
6. systemd starts core services:
   - kmsyncd (sync daemon)
   - kmvaultfs (FUSE mount)
   - usb-gadget (composite device)
7. Signal MCU: AP ready
8. MCU enables full USB composite
```

### Firmware Update

```
MCU Update:
  1. Host sends signed update via USB CDC
  2. MCU verifies signature (Ed25519)
  3. MCU writes to inactive slot
  4. MCU verifies written image
  5. MCU updates boot flags
  6. MCU reboots to new firmware
  7. If boot fails, automatic rollback

AP Update:
  1. Download update package to /tmp
  2. Verify package signature
  3. Mount update partition
  4. Extract new rootfs
  5. Update boot config
  6. Reboot
  7. Rollback if health check fails

Update Signing:
  - Ed25519 keys
  - Public key embedded in bootloader
  - Threshold signatures for production (2-of-3)
```

---

## Development Priorities

### Phase 1: Core Functionality


| Priority | Component          | Description                |
| -------- | ------------------ | -------------------------- |
| P0       | MCU keypad driver  | Unlock flow                |
| P0       | MCU display driver | Status and menus           |
| P0       | MCU crypto engine  | Vault encryption           |
| P0       | MCU USB CCID       | Smart card emulation       |
| P0       | MCU USB HID        | Keyboard auto-type         |
| P1       | MCU SE interface   | Secure element integration |
| P1       | AP FUSE filesystem | Vault mount                |
| P1       | AP USB gadget      | Composite device           |

### Phase 2: Full Features


| Priority | Component             | Description           |
| -------- | --------------------- | --------------------- |
| P0       | Sync daemon           | Device-to-device sync |
| P0       | Host CLI tool         | User interface        |
| P1       | Web UI                | Local management      |
| P1       | Browser extension     | Auto-fill             |
| P2       | KeePassXC integration | Compatibility         |
| P2       | SSH agent             | Key management        |

### Phase 3: Polish


| Priority | Component       | Description        |
| -------- | --------------- | ------------------ |
| P0       | Firmware update | Secure OTA         |
| P1       | Backup/restore  | Data safety        |
| P2       | Import/export   | KeePass, 1Password |
| P2       | Mobile apps     | iOS, Android       |

---

## Appendix: Technology Choices

### Languages


| Component         | Language   | Rationale                                  |
| ----------------- | ---------- | ------------------------------------------ |
| MCU firmware      | Rust or C  | Safety, performance, embedded support      |
| AP services       | Rust       | Memory safety, async, good USB/FUSE crates |
| Host CLI          | Rust       | Cross-platform, single binary              |
| Web UI            | TypeScript | Standard, minimal dependencies             |
| Browser extension | TypeScript | Browser requirement                        |

### Libraries (Tentative)


| Purpose    | Library                 | License          |
| ---------- | ----------------------- | ---------------- |
| MCU crypto | libsodium or RustCrypto | ISC / Apache-2.0 |
| FUSE       | fuse3 / fuser           | LGPL / MIT       |
| USB gadget | configfs + functionfs   | GPL (kernel)     |
| Sync TLS   | rustls                  | Apache-2.0       |
| CLI        | clap                    | Apache-2.0       |
| Web UI     | vanilla JS or Preact    | MIT              |

---

## Document History


| Version | Date    | Author | Changes       |
| ------- | ------- | ------ | ------------- |
| 0.1     | 2025-09 | -      | Initial draft |
