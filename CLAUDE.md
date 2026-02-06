# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KeyMaster is an open hardware password manager and data vault—a batteryless USB-C device with physical PIN entry. This repository contains design specifications, documentation, and conceptual diagrams. **No firmware or software code exists yet**; the project is in the concept/design phase seeking an engineering partner.

## Repository Structure

```
keymaster/
├── README.md                    # Elevator pitch and project overview
├── CLAUDE.md                    # This file - guidance for Claude Code
├── examples.md                  # Detailed narrative use cases (12 scenarios)
├── docs/
│   ├── vision.md                # Philosophy and "why this exists"
│   ├── user-guide.md            # User workflows and scenarios
│   ├── specs/
│   │   ├── hardware.md          # Engineering-quotable hardware specification
│   │   ├── software.md          # Firmware and software architecture
│   │   └── security.md          # Cryptographic design and threat model
│   └── diagrams/
│       ├── overview.md          # Guide to diagrams and rendering
│       ├── crypto-flow.dot      # Key derivation flow (Graphviz)
│       └── threat-model.dot     # Threat model structure (Graphviz)
└── archive/
    ├── DECISIONS-LOG.md         # Summary of design decisions
    └── keymaster-conversations.md  # Historical ChatGPT exports
```

## Key Technical Concepts

**Dual-Processor Architecture:**
- MCU (security domain): handles CCID, HID, crypto operations, PIN entry
- Application Processor (Linux): runs when Composite Mode enabled for full vault access

**Operating Modes:**
- Minimal Mode: MCU only, CCID + HID exposed, no storage visible
- Composite Mode: AP enabled, USB composite gadget, FUSE vault filesystem, web/CLI access

**Cryptographic Design** (see `docs/diagrams/crypto-flow.dot`):
- PIN → Argon2id → ProfileKey
- ProfileKey + DRS (device root secret) → HKDF → KEK
- KEK unwraps MVK (Master Vault Key) per profile
- Per-entry DEKs wrapped with recipient MVKs for sharing

**Hidden Unlock / Duress Feature:**
- Different PINs unlock different profiles
- No indication that additional profiles exist

## Working with Diagrams

Graphviz `.dot` files in `docs/diagrams/` can be rendered with:
```bash
dot -Tpng docs/diagrams/crypto-flow.dot -o docs/diagrams/crypto-flow.png
dot -Tpng docs/diagrams/threat-model.dot -o docs/diagrams/threat-model.png
```

## Project Status

Currently at **Phase 0: Partnership**—seeking hardware/firmware development partner. Documentation serves as a design specification for engineering quotes and early collaborator alignment.
