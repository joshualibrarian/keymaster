# KeyMaster – Hardware Specification

This document provides technical hardware requirements for engineering teams to quote development costs. Component choices are recommendations; final selection should optimize for availability, cost, and performance.

---

## 1. Overview

KeyMaster is a USB-powered hardware password manager and data vault with:

- **Dual-processor architecture:** a small always-on **security MCU** plus a higher-power **application processor (AP)**. §3 explains why the two are kept separate.
- Two power domains (low-power and high-power)
- On-device PIN entry and e-paper display
- Smart-card, FIDO2/passkey, and keyboard emulation
- Encrypted vault storage, with a hardware crypto path capable of line-rate encryption of external media
- Physical-only PIN entry, an un-extractable device secret, and tamper response that erases key material on intrusion

**Target:** Prototype-ready design package including schematics, PCB layout, enclosure CAD, and firmware skeleton.

> **A note on component choices in this document.** Every specific part named below is an *existence-proof example* of a class that meets a requirement, not a mandated selection. Final silicon, passives, and mechanicals are the design partner's call, optimized for availability, cost, and their own experience. This spec defines the *envelope* and demonstrates the path is buildable with parts that exist today.

---

## 2. Physical Design

### Form Factor


| Parameter  | Specification                                |
| ---------- | -------------------------------------------- |
| Dimensions | ~2" × 3" × ~0.7" (50 × 75 × ~18 mm); final thickness is a mechanical-design decision, not a hard target |
| Weight     | Modest heft; the metal shell's mass is part of the physical-security story |
| Material   | Durable metal shell, polycarbonate bezel (see §10) |

### Face A: Keypad

- 12-key recessed capacitive touch pad
- Arranged in 3×4 grid (phone-style or custom layout)
- Each key inset for tactile navigation by touch alone
- Silent operation (no mechanical switches)
- Capacitive sensing via MCU GPIOs or dedicated touch controller

### Face B: Display

- E-paper (EPD), 2.7" to 3.5" diagonal
- Resolution: 264×176 or higher
- Partial refresh support for responsive UI
- Persists image when power removed
- Controller: SPI interface to MCU

### Edges

Only three items need edge access: two USB-C ports and the MicroSD slot. Everything else (PD controllers, USB hub, crosspoint switch, and so on) is internal. There is ample edge space.

| Edge            | Components                                   |
| --------------- | -------------------------------------------- |
| Bottom (short)  | USB-C Port A                                 |
| Side (long)     | USB-C Port B, MicroSD slot                   |
| Top (short)     | Keychain attachment point (reinforced metal) |
| Other side      | Reserved for indicators/vents                |

### Indicators

- 1-2 LEDs visible through bezel edge (power, status)
- E-paper provides detailed status when powered

### Mechanical Integration

The internal cavity holds a keypad electrode layer, the e-paper panel, and a logic board carrying two processor domains, the USB subsystem, storage, and the supercapacitors. This is a dense build: a small Linux computer plus a security core in a keychain-sized body. Expect modern packaging (HDI/micro-via PCB, package-on-package or a compact system-on-module for the application processor) and a deliberate component-height plan so the tall parts (supercapacitors, USB-C connectors) clear the display and keypad planes. The XY footprint is comfortable; the ~18 mm thickness gives the internal stack room, and final thickness is set in mechanical design.

---

## 3. Electronics Architecture

### Block Diagram

```
                    ┌─────────────────────────────────────────────┐
                    │              KeyMaster                      │
                    │                                             │
   USB-C Port A ────┤►┌─────────┐    ┌────────────────────────┐   │
   (upstream/       │ │  Type-C │    │   High-Power Domain    │   │
    downstream)     │ │   MUX   │◄──►│                        │   │
                    │ │  + PD   │    │  ┌──────────────────┐  │   │
   USB-C Port B ────┤►└─────────┘    │  │ Application      │  │   │
   (upstream/       │       │        │  │ Processor (AP)   │  │   │
    downstream)     │       │        │  │ - Linux          │  │   │
                    │       ▼        │  │ - FUSE FS        │  │   │
                    │  ┌─────────┐   │  │ - Sync daemon    │  │   │
                    │  │ USB 3.2 │   │  │ - USB gadget     │  │   │
                    │  │   Hub   │◄─►│  └────────┬─────────┘  │   │
                    │  └─────────┘   │           │            │   │
                    │       │        │  ┌────────▼─────────┐  │   │
                    │       │        │  │ Storage          │  │   │
   MicroSD ─────────┤───────┼───────►│  │ - eMMC (OS)      │  │   │
                    │       │        │  │ - MicroSD        │  │   │
                    │       │        │  │ - UFS or eMMC    │  │   │
                    │       │        │  └──────────────────┘  │   │
                    │       │        └────────────────────────┘   │
                    │       │                                     │
                    │       │        ┌────────────────────────┐   │
                    │       │        │   Low-Power Domain     │   │
                    │       │        │                        │   │
                    │       └───────►│  ┌──────────────────┐  │   │
                    │                │  │ MCU              │  │   │
                    │                │  │ - Keypad scan    │  │   │
                    │                │  │ - EPD driver     │  │   │
                    │                │  │ - USB 2.0 FS     │  │   │
                    │                │  │ - Crypto accel   │  │   │
                    │                │  │ - CCID/HID       │  │   │
                    │                │  └────────┬─────────┘  │   │
                    │                │           │            │   │
                    │                │  ┌────────▼─────────┐  │   │
                    │                │  │ Secure Element   │  │   │
                    │                │  │ (optional)       │  │   │
                    │                │  └──────────────────┘  │   │
                    │                │                        │   │
                    │                │  ┌──────────────────┐  │   │
                    │                │  │ Vault Storage    │  │   │
                    │                │  │ - SPI-NOR (boot) │  │   │
                    │                │  │ - SPI-NAND (data)│  │   │
                    │                │  └──────────────────┘  │   │
                    │                └────────────────────────┘   │
                    │                                             │
                    │  ┌──────────────────────────────────────┐   │
                    │  │ Power Management                     │   │
                    │  │ - Per-port PD controllers            │   │
                    │  │ - Domain load switches               │   │
                    │  │ - Supercapacitor (e-paper/tamper)    │   │
                    │  └──────────────────────────────────────┘   │
                    └─────────────────────────────────────────────┘
```

---

## 4. Low-Power Domain (Security Core)

The low-power domain is the **security core** and is **architecturally non-negotiable**: it handles PIN entry, unlock, and the vault's core cryptography, and it must run **standalone**, with the application processor completely powered off, on as little as a smart-card reader can supply (see §7). This is what lets KeyMaster act as a pure smart card / FIDO authenticator on a legacy reader or a power-starved host, and it keeps the small, auditable security domain **physically separate** from the large, complex, network-facing Linux brain. Do not collapse this domain into the AP.

### MCU Requirements


| Parameter | Specification                                                    |
| --------- | ---------------------------------------------------------------- |
| Core      | ARM Cortex-M33 or Cortex-M4                                      |
| USB       | USB 2.0 Full-Speed device                                        |
| Crypto    | Hardware AES, ECC (P-256, Ed25519), SHA-256                      |
| Security  | TrustZone or equivalent secure world                             |
| GPIO      | Sufficient for 12-key capacitive touch (or I2C touch controller) |
| SPI       | 2+ channels (EPD, flash, SE)                                     |
| I2C       | 2+ channels (SE, RTC, sensors)                                   |
| USB HID   | Must support keyboard + FIDO2/CTAP2 HID interfaces (see software spec) |
| Power     | <15 mA active @ 48 MHz, <10 µA sleep                            |
| Secret    | A **true hardware-secret key** (not merely a public unique ID) to anchor the Device Root Secret (see note below) |

**MCU class:** Cortex-M33 (or M4) with hardware crypto, a secure world (TrustZone or equivalent), and enough on-chip RAM to run the PIN-stretch KDF (see security spec; parameters are tuned to the chosen part, not fixed here). **Example parts that meet this today:** STM32L562/L552, STM32U575/U585, NXP LPC55S69, Nordic nRF52840 (M4, adds BLE for a future radio option).

> **Device-secret note.** The Device Root Secret (DRS) must be anchored in something an attacker cannot read out. The chip's public "unique device ID" is **not** a secret and must not be used for this. Acceptable anchors: a dedicated secure element (best), or an MCU with a true hardware-secret key facility (e.g. parts with a device-unique hardware key usable by the crypto engine but never exposed to software). Treat this as a hard selection criterion for the MCU/SE.

### Real-Time Clock + Timekeeping Supercapacitor

KeyMaster must keep wall-clock time across power removal so that **TOTP works on any host** and time-based features (sync, dead-man's-switch) are reliable. Because the device is batteryless, timekeeping is held by a **dedicated supercapacitor** backing an ultra-low-power RTC.

| Parameter        | Specification                                                        |
| ---------------- | ------------------------------------------------------------------- |
| RTC              | Ultra-low-power (≈ tens–hundreds of nA timekeeping); e.g. RV-3028-class |
| Backup element   | Dedicated supercapacitor sized for **weeks** of retention (the limit is supercap self-leakage, not RTC draw; validate against a real leakage budget, and a low-leakage part is preferred) |
| Interface        | I2C to security MCU                                                  |
| Re-sync sources  | Firmware refreshes time opportunistically (network NTP, host helper, host-clock scavenge); manual keypad entry as last resort (see security/software specs) |

This preserves the "no battery to charge or replace" property while giving the device a trustworthy-enough local clock.

### Secure Element (base: good / Pro: best)

The device secret and attempt-counter live in tamper-resistant storage. Two tiers (see §11):

- **Base — "good":** the device secret is **split across physically separate stores**: a true MCU hardware-secret key (read-out disabled) plus random shares in locked flash and EEPROM, so no single memory read-out reveals it, plus MCU-level tamper inputs. (Key-splitting is used in shipping MCU-only tokens; see security spec.)
- **Pro — "best":** a dedicated secure element that stores the secret and performs the unlock operation *internally* (the secret never leaves it), plus a tamper mesh.

| Parameter     | Specification                                  |
| ------------- | ---------------------------------------------- |
| Interface     | I2C or SPI (ISO7816 optional for adapter mode) |
| Applets       | OpenPGP, PIV, or FIDO2 capable                 |
| Certification | Common Criteria EAL5+ / FIPS-capable preferred (supports the certifiability goal, §14a) |
| Key storage   | Device secret + minimum 3 additional key slots |
| Tamper        | Active tamper detection and zeroization        |

**Example SEs:** STMicroelectronics ST33 series, NXP JCOP (J3), Infineon SLE78 / SLC37, Microchip ATECC608B (simpler, no JavaCard). *(An exotic alternative worth evaluating with the design partner: a PUF (physically-unclonable-function) secret derived from chip manufacturing randomness, so there is nothing stored to extract. It needs error-correction/helper-data plumbing; named as an option, not a requirement.)*

### Vault Storage


| Component | Size       | Purpose                            |
| --------- | ---------- | ---------------------------------- |
| SPI-NOR   | 16-32 MB   | MCU firmware, bootloader, recovery |
| SPI-NAND  | 128-512 MB | Encrypted vault store              |

**Notes:**

- SPI-NOR: Winbond W25Q128 or similar, quad-SPI preferred
- SPI-NAND: Winbond W25N01GV or similar, with wear leveling in firmware

---

## 5. High-Power Domain

### Application Processor Requirements

The AP runs Linux for the composite USB gadget, the vault-presentation daemon, sync, and **line-rate bulk encryption**. KeyMaster can act as an inline encrypting bridge for external media (plug a drive into the downstream port; KeyMaster encrypts/decrypts every byte in transit), and that data path runs on the AP's hardware crypto engine. That capability, not the small vault, is what sets the AP's performance floor.

**AP class (not a specific part; see the note in §1):**

| Parameter   | Requirement                                                                 |
| ----------- | --------------------------------------------------------------------------- |
| Core        | Quad Cortex-A53 / A55-class (or better), Linux-capable                       |
| RAM         | 512 MB+ (256 MB minimum)                                                     |
| USB         | **USB3-class**, ideally **two** dual-role controllers (one host → external drive, one device → upstream host) for the encrypting-bridge path |
| Crypto      | Hardware AES engine with a **software-invisible key path** (keys usable by the engine but never exposed to the OS) |
| Secure boot | Verified/secure boot with a documented, mainline-supported chain            |
| Linux       | Mainline kernel support; long-term (industrial) availability                 |
| Interfaces  | SPI, I2C, UART for MCU communication                                          |
| Power       | Power-gateable from the security domain (off entirely in low-power mode)      |

**Example parts that meet this class today** (the design partner chooses; verify USB3-controller count, the invisible-key crypto facility, mainline status, and availability horizon per part):

- **NXP i.MX 8M Plus:** quad A53, two USB 3.0 dual-role, CAAM crypto (supports "black keys" usable-but-invisible-to-software), HAB secure boot, strong mainline, long industrial availability. Proven, security-oriented.
- **NXP i.MX 95:** newer; A55, USB3/PCIe, on-die EdgeLock secure enclave. Strongest security pedigree.
- **Rockchip RK3568:** quad A55, dual USB3, PCIe/SATA, crypto block. Best cost/capability; consumer-grade secure-boot ecosystem and shorter availability guarantees.
- **STMicro STM32MP25:** A35 + integrated M33, USB3, ST security IP. Mirrors the two-processor model on one die (a consolidation option; note the physical-isolation trade-off in §3).

> **Why not a cheap USB-2 AP?** Presenting fast *encrypted external storage* to a host requires a USB3 device controller in the AP; you cannot add speed with a downstream bridge without moving that data outside the AP's encryption path. USB3 is therefore required *for the encrypting-bridge capability*. The everyday vault itself is small and runs fine at USB 2.0.

### OS Storage


| Component   | Size    | Purpose                        |
| ----------- | ------- | ------------------------------ |
| UFS or eMMC | 8-16 GB+ | Linux rootfs, tools, RO images, and onboard user capacity |

> **Storage direction: lean toward UFS.** We would prefer UFS for modern, SSD-class onboard speed (full-duplex, command-queued, roughly 2,000+ MB/s vs. eMMC's ~400) in the same solder-down footprint. eMMC is an acceptable fallback where the chosen application processor lacks a UFS controller, or where cost and availability favor it. Treat this as an engineering decision that leans UFS, not a hard requirement.

**Partitioning:**

- A/B system partitions for safe updates
- Read-only tools/rescue partition
- Scratch partition for logs/temp

### Bulk Storage

| Component     | Size       | Purpose                                          |
| ------------- | ---------- | ------------------------------------------------ |
| MicroSD slot  | Up to 1 TB | User data, encrypted partitions                  |

> Onboard capacity is set by the UFS (preferred) or eMMC part, higher-capacity on the Pro model in the same footprint. For larger or higher-speed storage, users add a MicroSD card or an external drive on the USB-C port through the encrypting-bridge path (see §5, High-Power Domain).

---

## 6. USB Subsystem

### Interface Topology

Two processors present interfaces to the host through an internal USB hub. **The hub does not merge the two processors into one logical device;** the host enumerates the hub with the devices behind it. The security MCU's low-bandwidth interfaces (CCID, HID keyboard, FIDO2) speak USB 2.0; the AP presents the composite functions (Ethernet, mass storage / vault presentation) at USB3-class speed and **passes CCID/HID through from the MCU** when it is powered, so the host sees a single coherent KeyMaster.

- **Security MCU (USB 2.0 Full/High Speed):** CCID, HID keyboard, and FIDO2/CTAP2. Low-bandwidth by nature; runs even when the AP is off (this is the always-available smart-card / passkey path).
- **AP (USB3-class):** Ethernet-over-USB, vault presentation, and, for the encrypting-bridge use case, line-rate encrypted mass storage. Speed here follows the chosen AP (see §5).

### Port Configuration: two fully dual-role USB-C ports

Both USB-C ports are **fully dual-role in data and power**, and several use cases below depend on that flexibility. Data-role and power-role negotiate independently under USB-C, so all of this works regardless of USB2-vs-USB3 data speed:

- Either port can be **upstream** (device to host) or **downstream** (host driving a peripheral).
- **Phone + power passthrough:** plug into a phone (KeyMaster is a *data device* to the phone) while a wall charger on the other port powers KeyMaster **and** charges the phone through it. (Phones have one port; this is the "use it with power on your phone" case.)
- **Standalone on a network:** KeyMaster acts as USB *host* on one port to drive a USB-C Ethernet adapter, while sinking wall power on the other, giving a self-contained networked backup with no computer involved (see software spec, sync).
- **Direct KeyMaster-to-KeyMaster:** two units connect USB-to-USB for pairing and sync.

### USB Controllers


| Function             | Example part(s)                             |
| -------------------- | ------------------------------------------- |
| Type-C PD (per port) | TI TPS65987 / TPS65988 or Cypress CCG3/CCG6 |
| USB hub              | USB3-class hub, e.g. VIA VL8xx or Genesys GL35xx |
| Upstream selector    | USB crosspoint switch for role/failover     |

### USB Device Functions (Composite Gadget)

When acting as USB device to host:


| Class                   | Purpose                           |
| ----------------------- | --------------------------------- |
| CDC-ECM / NCM / RNDIS   | USB Ethernet (auto-select per OS) |
| CCID                    | Smart card (OpenPGP/PIV)          |
| HID Keyboard            | Auto-type credentials             |
| Mass Storage (UASP/BOT) | Vault and storage access          |

### Power Delivery


| Capability     | Specification                                      |
| -------------- | -------------------------------------------------- |
| Sink           | 5V/3A minimum; PD negotiation for higher (a **≥30 W** input is recommended when charge-through to a phone is expected) |
| Source         | 5V/1.5A to a downstream peripheral; higher to a phone when input headroom allows |
| Charge-through | Sink wall power on one port; source to the connected phone on the other. The phone receives input power *minus* KeyMaster's own draw; state the budget in the PD design |

> With only phone power (no wall supply), KeyMaster runs in the low-power security domain only (CCID / HID / FIDO2, i.e. auto-type and smart-card/passkey to the phone). Full composite mode (storage, sync) needs an adequate powered source.

---

## 7. Power Management

### Power Domains


| Domain      | Components                                   | Control                          |
| ----------- | -------------------------------------------- | -------------------------------- |
| Always-on   | Type-C controllers, PMIC, RTC + its supercap | Enabled when VBUS present; RTC held by supercap when unpowered |
| Low-power   | Security MCU, SE, EPD controller, SPI flash  | Always enabled when powered      |
| High-power  | AP, USB hub, eMMC/UFS, MicroSD               | Load-switched, controlled by the security MCU |

### Power States


| State      | Active                  | Current (target) | Trigger                             |
| ---------- | ----------------------- | ---------------- | ----------------------------------- |
| Off        | RTC on supercap only    | ~0 (nA RTC)      | No VBUS                             |
| Low-power  | MCU, SE, EPD            | ≤ ~60 mA         | Default on plug-in; adapter / smart-card-reader mode |
| High-power | All                     | 200-500 mA+      | Adequate power + unlock (AP inline crypto can push higher) |
| Sleep      | MCU (low), EPD persists | <1 mA            | Idle timeout                        |

> The low-power budget target is set by the weakest supported source: an ISO 7816 smart-card reader supplies on the order of 60 mA, so the security domain must operate within that envelope. (This figure is the single source of truth; the software spec's mode table refers back to it.)

### Energy Storage


| Component                                   | Purpose                                             |
| ------------------------------------------- | --------------------------------------------------- |
| Supercapacitor (1-2 F)                      | E-paper safe refresh on unplug; power for tamper/timeout **key-zeroization** on power loss |
| Supercapacitor (dedicated, low-leakage) | **Timekeeping (RTC) retention for weeks** while unpowered (see §4) |
| Tamper power                                | Sufficient stored energy to complete **secret wipe** on a tamper event even with USB power removed |

---

## 8. Display

### E-Paper Specifications


| Parameter  | Specification                    |
| ---------- | -------------------------------- |
| Size       | 2.7" - 3.5" diagonal             |
| Resolution | 264×176 minimum                 |
| Colors     | Black/white (grayscale optional) |
| Interface  | SPI                              |
| Refresh    | Full: <1s, Partial: <300ms       |
| Controller | SSD1680 or similar               |

**Candidate Displays:**

- Good Display GDEH029A1 (2.9", 296×128)
- Waveshare 2.7" (264×176)
- Good Display GDEW027W3 (2.7", 264×176)

---

## 9. Keypad

### Capacitive Touch


| Parameter | Specification                            |
| --------- | ---------------------------------------- |
| Keys      | 12 (3×4 grid)                           |
| Sensing   | Capacitive, self-capacitance preferred   |
| Actuation | Finger touch only (no mechanical switch) |
| Feedback  | Optional haptic confirmation, user-configurable including fully off (see below) |

**Implementation Options:**

1. **MCU GPIO sensing**: STM32 touch-sensing controller (TSC)
2. **Dedicated IC**: Microchip MTCH6102, Azoteq IQS525
3. **Hybrid**: Touch IC with MCU interrupt

### Haptic Feedback (optional)

A capacitive keypad gives no tactile confirmation on its own, which makes dropped or doubled key entries easy, especially during eyes-free unlock (in a pocket or under a table, where the user is not watching the display). A light haptic confirmation on each *registered* touch addresses this and directly supports the invisible-unlock use case.

| Parameter | Specification |
| --------- | ------------- |
| Actuator  | Single LRA (linear resonant actuator) under the keypad; one actuator serves all keys |
| Driver    | Dedicated haptic driver IC (e.g. TI DRV2605L class), MCU-controlled |
| Domain    | Low-power domain; a click is a few-millisecond burst, so average power impact is negligible |
| Waveform  | A single **uniform** click, identical for every key, so the feedback reveals no information about *which* key was touched |
| Control   | User-configurable intensity, including fully off; plus a user-invokable silent mode that disables it before unlock for maximum-stealth situations (the exact control is an implementation/UX detail) |

**Security note.** Haptic feedback is opt-in and introduces a small acoustic and vibration signature. With a uniform waveform it does not leak key *values*, but it does make keypress *count and timing* observable to someone who can hear or feel the device (most relevant when it rests on a hard surface; in-hand, the palm largely damps it). This is why it must be silenceable. See the security spec's side-channel notes.

### Physical Design

- Recessed key areas for tactile navigation
- Silicone overlay or flush capacitive window
- Pattern-based input (not just PIN)

---

## 10. Enclosure

### Materials

The enclosure is a serious physical-security component, not just a case. KeyMaster is designed to take real-world abuse and to strongly resist intrusion.

| Component   | Material                            | Notes                                |
| ----------- | ----------------------------------- | ------------------------------------ |
| Shell       | **Durable metal**                   | Hard to cut/drill/pry, corrosion-resistant, with meaningful mass. Stainless steel, hard-anodized aluminum, or similar; the specific alloy is an engineering decision (see thermal note). |
| Upper bezel | Polycarbonate or glass-filled nylon | EPD window, RF-transparent for a future radio |
| Gaskets     | Silicone or EPDM                    | IP52-IP67 sealing                    |

> **Material choice interacts with thermal design.** The USB3-class AP doing line-rate crypto dissipates real power, and the shell material affects how that heat is handled. A hard, poor-conductor metal (stainless steel) resists intrusion best but is a poor heatsink (~15× lower thermal conductivity than aluminum), so it needs an internal thermal path, a heat spreader or conductive pad carrying AP heat to a deliberate surface. A good conductor (aluminum) helps dissipate but is softer. Either way, plan for an internal thermal path and treat the hardness/thermal/cost trade-off as part of enclosure design.

### Environmental


| Parameter      | Target                  |
| -------------- | ----------------------- |
| IP rating      | IP52 minimum, IP67 goal |
| Operating temp | 0°C to 45°C           |
| Storage temp   | -20°C to 60°C         |
| ESD            | IEC 61000-4-2 Level 4   |

### Tamper Features

- Case-open detection to the security MCU
- Active tamper mesh (Pro model) enveloping the secret store
- Supercapacitor-backed **zeroization / secret wipe** on tamper, functional even without USB power

> **False-positive discipline (design requirement).** Tamper response destroys key material, so thresholds must be tuned to tolerate real-world abuse (drop, cold, power dropouts, tolerances) without false-triggering; shipped products have destroyed customer data this way. Aggressive tamper response is acceptable here **only because a KeyMaster's data always lives on at least one paired backup and/or recovery shares** (see security spec, Recovery). If a unit wipes, whether from a real attack or a false trigger, the owner restores from the paired backup and replaces the hardware.

### Assembly

- 4 hidden screws (under rubber feet or labels)
- Tamper-evident seals optional
- Serviceable but not easily opened

---

## 11. SKU Matrix

The two SKUs differ mainly in the **tier of physical secret protection**: a "good" tier and a "best" tier of the same security model (see security spec).

| Feature              | KeyMaster ("good")                              | KeyMaster Pro ("best")                    |
| -------------------- | ----------------------------------------------- | ----------------------------------------- |
| Security MCU         | Yes                                             | Yes                                       |
| Device-secret anchor | MCU OTP fuses, read-out disabled + MCU tamper   | **Secret internal to a secure element**   |
| Tamper mesh          | Case-open detect                                | Active mesh + case-open                   |
| RTC + timekeeping supercap | Yes                                       | Yes                                       |
| SPI-NAND (vault)     | 128 MB                                           | 512 MB                                    |
| Onboard storage      | 8-16 GB (UFS preferred, eMMC fallback)          | Higher-capacity UFS/eMMC (up to 256 GB+, same footprint) |
| MicroSD              | Yes                                             | Yes                                       |
| Target price         | \$80-120 *(indicative; see §14)*                 | \$150-200 *(indicative; see §14)*          |

Both SKUs share a PCB; Pro populates the secure element, adds the tamper mesh, and fits higher-capacity flash. Both are sold, and strongly recommended, **as pairs** (backup is fundamental to the design; see README and security spec).

---

## 12. Firmware Requirements

### MCU Firmware


| Component    | Description                                     |
| ------------ | ----------------------------------------------- |
| Bootloader   | Secure boot, signed image verification          |
| Touch driver | Keypad scanning, debounce, pattern detection    |
| EPD driver   | Partial/full refresh, text/graphics rendering   |
| USB stack    | Device mode: CCID, HID keyboard, **FIDO2/CTAP2 HID**, CDC |
| Crypto       | PIN-stretch KDF, AES-GCM, ChaCha20-Poly1305, ECC (Ed25519 / X25519) |
| SE interface | I2C/SPI commands for key operations             |
| RTC / time   | Read/maintain the RTC; opportunistic time re-sync; manual set |
| Tamper/wipe  | Tamper + timeout **key zeroization**; attempt-counter management |
| Vault logic  | Entry encryption/decryption, profile management (object-store model) |

### AP Software


| Component      | Description                                                   |
| -------------- | ------------------------------------------------------------ |
| Linux kernel   | Mainline preferred; verified boot                            |
| USB gadget     | Composite: ECM/NCM/RNDIS, Ethernet, mass storage; CCID/HID/FIDO passthrough from MCU |
| Vault daemon   | Presents the vault to trusted hosts (host-side FUSE over the device API; see software spec, **not** raw USB mass storage) |
| Bulk-crypto    | Line-rate inline encryption of external media via the AP crypto engine |
| Sync daemon    | Backup discovery + replication; **headless (locked) sync** mode |
| MCU bridge     | UART/SPI communication with the security MCU                  |

---

## 13. Interfaces Summary


| Interface | Controller | Peripheral            | Notes                                   |
| --------- |------------| --------------------- | --------------------------------------- |
| SPI0      | MCU        | E-paper display       | 10 MHz+                                 |
| SPI1      | MCU        | SPI-NOR + SPI-NAND    | Quad-SPI preferred                      |
| I2C0      | MCU        | Secure Element        | 400 kHz                                 |
| I2C1      | MCU        | RTC (+ tamper sensors)| Timekeeping across power loss           |
| GPIO/AIN  | MCU        | Tamper mesh / switch  | Triggers zeroization                    |
| USB       | MCU        | Upstream (FS/HS device) | CCID / HID keyboard / FIDO2 in low-power mode |
| UART      | MCU ↔ AP   | Internal bridge       | 115200+ baud                            |
| USB       | AP         | Hub + gadget + host   | USB3-class; host role drives external drive / Ethernet adapter |
| SDIO      | AP         | eMMC                  | 4-bit or 8-bit                          |
| SDIO      | AP         | MicroSD               | 4-bit                                   |
| SDIO/eMMC | AP         | eMMC / UFS (onboard)  | Higher capacity on Pro; same footprint  |

---

## 14. Development Deliverables

### Phase 1 Deliverables

1. **Schematic** (KiCad or Altium)
2. **PCB layout** (Gerbers, drill files, assembly drawings)
3. **Bill of Materials** with alternates and sourcing
4. **Enclosure CAD** (STEP files for CNC/3D print)
5. **Firmware skeleton** (bootloader, drivers, basic vault operations)
6. **Test procedures** (power-on, USB enumeration, flash verification)

### Budget Estimate

> **These figures are rough, order-of-magnitude planning placeholders — not quotes.** A secure, dual-processor device with on-device crypto, secure boot, CCID + FIDO2 + OpenPGP card emulation, an e-paper UI, capacitive touch, tamper response, and a Linux AP is a substantial firmware effort; realistic all-in prototype figures for work of this kind commonly run well into six figures. The ranges below are intended to frame *relative* effort and to be replaced by a real partner quote. Treat the firmware line especially as a floor, not a ceiling.

| Component                        | Indicative range |
| -------------------------------- | ---------------- |
| Concept refinement + feasibility | \$5k - \$15k       |
| Schematic + PCB layout           | \$15k - \$40k      |
| Enclosure design + prototyping (machined metal, thermal path) | \$10k - \$25k |
| Firmware MVP (security MCU + AP)  | \$60k - \$200k+    |
| **Total Phase 1 (indicative)**   | **highly team-dependent; obtain a quote** |

*Estimates vary significantly with team experience, certification scope, and security depth.*

### 14a. Certifiability as a Design Goal

KeyMaster v1 is not expected to carry formal certification, but the hardware should be **designed so that certification (FIPS 140-3, NIST PIV, Common Criteria) would be achievable in a later revision.** This keeps the door open to government/enterprise programs (see README, smart-card interoperability) without reworking the platform. Cheap to plan for now:

- Use a certifiable/certified secure element for the device secret.
- Keep a clean **crypto-module boundary** (well-defined interfaces around the security domain).
- Use only standards-approved algorithms with validated implementations.
- Provide a hardware RNG with health testing per NIST SP 800-90B.
- Map tamper response to the physical-security levels certification expects.

**Inherit assurance from the secure element.** A pre-certified secure element (for example an NXP EdgeLock SE05x, which is Common Criteria EAL6+-based and FIPS 140-2/3 validated, with a public datasheet and no NDA) carries its own multi-million-dollar evaluation. Anchoring the device secret in such a part means the hardest, most expensive assurance is the silicon vendor's cost, not ours. Prefer turnkey, public-datasheet, no-NDA secure elements to avoid the NDA-gated datasheets and unpublished minimum-order quantities that gate the highest-security programmable smart-card ICs.

This is a **design goal, not a v1 deliverable.** Device-level FIPS 140-3 / Common Criteria is best treated as a funded fast-follow after v1: the CMVP validation queue alone has recently run 1.5–2 years, so committing to it for v1 risks stranding inventory behind a certification backlog.

---

## 15. References

### Similar Products

- [OnlyKey](https://onlykey.io/) – MCU-based, no display, only auto type
- [USB Armory Mk II](https://inversepath.com/usbarmory) – Full Linux, no display/keypad
- [Nitrokey](https://www.nitrokey.com/) – Open source, smart card focus
- [Trezor](https://trezor.io/) – Crypto wallet, display + buttons

### Standards

- USB 3.2 Specification
- USB Type-C Specification
- USB Power Delivery Specification
- ISO/IEC 7816 (Smart Cards)
- CCID Specification
- FIDO2/WebAuthn

---

## 16. Open Questions

- Final security-MCU selection (crypto benchmark, true hardware-secret facility, availability)
- SE selection (NDA review, applet availability, certification path)
- AP selection (USB3-controller count, invisible-key crypto engine, mainline BSP, availability horizon)
- RTC + timekeeping-supercap sizing vs. target unpowered-retention window
- Tamper-threshold tuning to avoid false positives across the environmental envelope
- IP rating target (IP52 vs IP67 cost/complexity trade-off)
- Enclosure metal choice vs. thermal path for the AP (hardness/thermal/cost trade-off)
- Final thickness within the mechanical envelope (~18 mm target)
- Onboard storage: confirm UFS (preferred) vs. eMMC fallback against the chosen AP's controller support and cost
