# KeyMaster – Hardware Specification

This document provides technical hardware requirements for engineering teams to quote development costs. Component choices are recommendations; final selection should optimize for availability, cost, and performance.

---

## 1. Overview

KeyMaster is a USB-powered hardware password manager and data vault with:

- Dual-processor architecture (MCU + Application Processor)
- Two power domains (low-power and high-power)
- On-device PIN entry and display
- Smart-card and keyboard emulation
- Encrypted vault storage with optional bulk storage

**Target:** Prototype-ready design package including schematics, PCB layout, enclosure CAD, and firmware skeleton.

---

## 2. Physical Design

### Form Factor


| Parameter  | Specification                                |
| ---------- | -------------------------------------------- |
| Dimensions | ~2" × 3" × 0.6" (50 × 75 × 15 mm)        |
| Weight     | <100g                                        |
| Material   | Machined aluminum shell, polycarbonate bezel |

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


| Edge   | Components                                   |
| ------ | -------------------------------------------- |
| Top    | USB-C Port A                                 |
| Bottom | USB-C Port B, MicroSD slot                   |
| Sides  | Reserved for vents, indicators               |
| Corner | Keychain attachment point (reinforced metal) |

### Indicators

- 1-2 LEDs visible through bezel edge (power, status)
- E-paper provides detailed status when powered

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
                    │       │        │  │ - NVMe (optional)│  │   │
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

## 4. Low-Power Domain

### MCU Requirements


| Parameter | Specification                                                    |
| --------- | ---------------------------------------------------------------- |
| Core      | ARM Cortex-M33 or Cortex-M4                                      |
| USB       | USB 2.0 Full-Speed device                                        |
| Crypto    | Hardware AES, ECC (P-256, Ed25519), SHA-256                      |
| Security  | TrustZone or equivalent secure world                             |
| GPIO      | Sufficient for 12-key capacitive touch (or I2C touch controller) |
| SPI       | 2+ channels (EPD, flash, SE)                                     |
| I2C       | 1+ channel (SE, sensors)                                         |
| Power     | <15 mA active @ 48 MHz, <10 µA sleep                            |

**Candidate MCUs:**

- STM32L562 / STM32L552 (Cortex-M33, TrustZone, crypto)
- STM32U575 / STM32U585 (ultra-low-power, crypto)
- NXP LPC55S69 (dual Cortex-M33, crypto, USB)
- Nordic nRF52840 (Cortex-M4, crypto, USB, BLE for future)

### Secure Element (Optional)


| Parameter     | Specification                                  |
| ------------- | ---------------------------------------------- |
| Interface     | I2C or SPI (ISO7816 optional for adapter mode) |
| Applets       | OpenPGP, PIV, or FIDO2 capable                 |
| Certification | Common Criteria EAL5+ preferred                |
| Key storage   | Minimum 3 key slots                            |
| Tamper        | Active tamper detection and zeroization        |

**Candidate SEs:**

- STMicroelectronics ST33 series
- NXP JCOP (J3 series)
- Infineon SLE78 / SLC37
- Microchip ATECC608B (simpler, no JavaCard)

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


| Parameter  | Specification                        |
| ---------- | ------------------------------------ |
| Core       | ARM Cortex-A7 or Cortex-A35          |
| RAM        | 256 MB+ DDR3/DDR3L                   |
| USB        | USB 2.0 OTG or USB 3.x host          |
| Interfaces | SPI, I2C, UART for MCU communication |
| Linux      | Mainline kernel support preferred    |
| Power      | Power-gateable from low-power domain |

**Candidate APs:**

- NXP i.MX6UL / i.MX6ULL (mature, good Linux support)
- STM32MP157 (Cortex-A7, OpenSTLinux)
- Allwinner V3s (low cost, limited support)

### OS Storage


| Component | Size    | Purpose                        |
| --------- | ------- | ------------------------------ |
| eMMC      | 8-16 GB | Linux rootfs, tools, RO images |

**Partitioning:**

- A/B system partitions for safe updates
- Read-only tools/rescue partition
- Scratch partition for logs/temp

### Bulk Storage (Optional)


| Component     | Size       | Purpose                         |
| ------------- | ---------- | ------------------------------- |
| MicroSD slot  | Up to 1 TB | User data, encrypted partitions |
| M.2 2230 NVMe | Up to 1 TB | Pro SKU high-speed storage      |

---

## 6. USB Subsystem

### Speed Architecture

The device uses a dual-speed design:

- **USB 2.0 Full Speed (12 Mbps):** MCU provides CCID and HID interfaces. These low-bandwidth functions (smartcard commands, keyboard input) don't need high speed, and embedded MCUs only support USB 2.0 FS.
- **USB 3.2 Gen 2 (10 Gbps):** AP provides mass storage (UASP). Storage access benefits from high bandwidth, especially for the Pro SKU with NVMe. The USB 3.2 hub aggregates both processors' interfaces into a single composite device.

The host sees one composite device. Low-speed interfaces (CCID, HID) run at USB 2.0 speeds; storage runs at USB 3.2 speeds.

### Port Configuration

Both USB-C ports are **Dual-Role Power (DRP)** capable:

- Either port can be upstream (device to host)
- Either port can be downstream (host to peripherals)
- Automatic role detection with manual override

### USB Controllers


| Function             | Controller                                  |
| -------------------- | ------------------------------------------- |
| Type-C PD (per port) | TI TPS65987 / TPS65988 or Cypress CCG3/CCG6 |
| USB 3.2 Gen 2 Hub    | VIA VL830 or Genesys GL3590 (2-4 port)      |
| Upstream selector    | USB 3.x crosspoint switch for failover      |

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
| Sink           | 5V/3A minimum; PD negotiation for higher           |
| Source         | 5V/1.5A to downstream port or connected device     |
| Charge-through | Sink on Port B, source to upstream phone on Port A |

---

## 7. Power Management

### Power Domains


| Domain     | Components                              | Control                          |
| ---------- | --------------------------------------- | -------------------------------- |
| Always-on  | Type-C controllers, power management IC | Enabled when VBUS present        |
| Low-power  | MCU, SE, EPD controller, SPI flash      | Always enabled when powered      |
| High-power | AP, USB hub, eMMC, MicroSD, NVMe        | Load-switched, controlled by MCU |

### Power States


| State      | Active                  | Current    | Trigger                             |
| ---------- | ----------------------- | ---------- | ----------------------------------- |
| Off        | None                    | 0          | No VBUS                             |
| Low-power  | MCU, SE, EPD            | <20 mA     | Default on plug-in, or adapter mode |
| High-power | All                     | 200-500 mA | Adequate power + unlock             |
| Sleep      | MCU (low), EPD persists | <1 mA      | Idle timeout                        |

### Energy Storage


| Component                            | Purpose                        |
| ------------------------------------ | ------------------------------ |
| Supercapacitor (1-2F @ 5.5V)         | E-paper safe refresh on unplug |
| Supercapacitor (optional additional) | Tamper zeroization             |

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
| Feedback  | Optional haptic (LRA) or none (silent)   |

**Implementation Options:**

1. **MCU GPIO sensing**: STM32 touch-sensing controller (TSC)
2. **Dedicated IC**: Microchip MTCH6102, Azoteq IQS525
3. **Hybrid**: Touch IC with MCU interrupt

### Physical Design

- Recessed key areas for tactile navigation
- Silicone overlay or flush capacitive window
- Pattern-based input (not just PIN)

---

## 10. Enclosure

### Materials


| Component   | Material                            | Notes                                |
| ----------- | ----------------------------------- | ------------------------------------ |
| Lower shell | Aluminum (6061-T6)                  | Heatsink, EMI shield, rigidity       |
| Upper bezel | Polycarbonate or glass-filled nylon | EPD window, RF transparent if needed |
| Gaskets     | Silicone or EPDM                    | IP52-IP67 sealing                    |

### Environmental


| Parameter      | Target                  |
| -------------- | ----------------------- |
| IP rating      | IP52 minimum, IP67 goal |
| Operating temp | 0°C to 45°C           |
| Storage temp   | -20°C to 60°C         |
| ESD            | IEC 61000-4-2 Level 4   |

### Tamper Features

- Case-open detection switch to MCU
- Optional active mesh (Pro model)
- Supercapacitor-backed zeroization on tamper

### Assembly

- 4 hidden screws (under rubber feet or labels)
- Tamper-evident seals optional
- Serviceable but not easily opened

---

## 11. SKU Matrix


| Feature        | KeyMaster           | KeyMaster Pro   |
| -------------- | ------------------- | --------------- |
| MCU            | Yes                 | Yes             |
| Secure Element | No (footprint only) | Yes (populated) |
| SPI-NAND       | 128 MB              | 512 MB          |
| eMMC           | 8 GB                | 16 GB           |
| MicroSD        | Yes                 | Yes             |
| NVMe M.2 2230  | No                  | Optional bay    |
| Tamper mesh    | No                  | Optional        |
| Target price   | $80-120             | $150-200        |

Both SKUs use identical PCB; Pro adds SE, larger flash, optional NVMe.

---

## 12. Firmware Requirements

### MCU Firmware


| Component    | Description                                     |
| ------------ | ----------------------------------------------- |
| Bootloader   | Secure boot, signed image verification          |
| Touch driver | Keypad scanning, debounce, pattern detection    |
| EPD driver   | Partial/full refresh, text/graphics rendering   |
| USB stack    | Device mode: CCID, HID, CDC                     |
| Crypto       | Argon2id, AES-GCM, XChaCha20-Poly1305, ECC      |
| SE interface | I2C/SPI commands for key operations             |
| Vault logic  | Entry encryption/decryption, profile management |

### AP Software


| Component    | Description                                       |
| ------------ | ------------------------------------------------- |
| Linux kernel | Mainline or vendor BSP                            |
| USB gadget   | Composite: ECM/NCM/RNDIS, CCID, HID, Mass Storage |
| FUSE daemon  | Vault filesystem presentation                     |
| Sync daemon  | Backup unit discovery and replication             |
| MCU bridge   | UART/SPI communication with MCU                   |

---

## 13. Interfaces Summary


| Interface | Controller | Peripheral           | Notes                      |
| --------- |------------| -------------------- | -------------------------- |
| SPI0      | MCU        | E-paper display      | 10 MHz+                    |
| SPI1      | MCU        | SPI-NOR + SPI-NAND   | Quad-SPI preferred         |
| I2C0      | MCU        | Secure Element       | 400 kHz                    |
| USB       | MCU        | Upstream (FS device) | CCID/HID in low-power mode |
| UART      | MCU ↔ AP   | Internal bridge      | 115200+ baud               |
| USB       | AP         | Hub (host) + Gadget  | USB 3.x preferred          |
| SDIO      | AP         | eMMC                 | 4-bit or 8-bit             |
| SDIO      | AP         | MicroSD              | 4-bit                      |
| PCIe      | AP         | NVMe (optional)      | x1 Gen2                    |

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


| Component                        | Range           |
| -------------------------------- | --------------- |
| Concept refinement + feasibility | $5k - $10k      |
| Schematic + PCB layout           | $10k - $20k     |
| Enclosure design + prototyping   | $5k - $10k      |
| MCU firmware MVP                 | $15k - $30k     |
| **Total Phase 1**                | **$35k - $70k** |

*Estimates vary significantly based on team experience and security depth.*

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

- Final MCU selection (pending crypto benchmark and availability)
- SE selection (pending NDA review and applet availability)
- AP selection (pending Linux BSP evaluation)
- IP rating target (IP52 vs IP67 cost/complexity trade-off)
- NVMe inclusion in base model vs Pro-only
