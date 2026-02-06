# KeyMaster Diagrams

This directory contains technical diagrams for the KeyMaster project.

## Available Diagrams

### crypto-flow.dot
Graphviz diagram showing the cryptographic key derivation flow:
- PIN → Argon2id → Profile Key
- DRS + Profile Key → HKDF → KEK
- KEK → unwrap → MVK
- MVK → unwrap → DEK (per-entry)
- Multi-recipient key wrapping

**To render:**
```bash
dot -Tpng crypto-flow.dot -o crypto-flow.png
dot -Tsvg crypto-flow.dot -o crypto-flow.svg
```

### threat-model.dot
Graphviz diagram showing the threat model structure:
- Assets (keys, PINs, logs, device integrity)
- Adversaries (casual thief, insider, remote attacker, advanced lab)
- Attack surfaces (physical, side-channel, fault injection, logical)
- Relationships between adversaries and attack vectors

**To render:**
```bash
dot -Tpng threat-model.dot -o threat-model.png
dot -Tsvg threat-model.dot -o threat-model.svg
```

## Rendering All Diagrams

```bash
cd docs/diagrams
for f in *.dot; do
  dot -Tpng "$f" -o "${f%.dot}.png"
  dot -Tsvg "$f" -o "${f%.dot}.svg"
done
```

## Planned Diagrams

The following diagrams would be useful additions:

- **hardware-block.dot** - PCB block diagram showing MCU, AP, storage, USB
- **usb-composite.dot** - USB device tree and interface configuration
- **state-machine.dot** - Device states (LOCKED, UNLOCKED, COMPOSITE, TAMPER)
- **sync-protocol.dot** - Device-to-device sync message flow
- **vault-layout.dot** - Filesystem structure and entry relationships
