# KeyMaster – For Prospective Engineering Partners

This document is for hardware and firmware firms evaluating a partnership to build KeyMaster. It describes what we need, what a proposal should contain, and how we will judge whether v1 is on track. It is deliberately outcome-oriented: it states goals and acceptance criteria and leaves implementation choices to your expertise.

For full technical detail, see the design specifications:

- [Hardware Specification](specs/hardware.md) – requirements, candidate parts, deliverables, budget framing
- [Software Specification](specs/software.md) – firmware and software architecture
- [Security Specification](specs/security.md) – cryptographic design and threat model
- [Vision](vision.md) – the product thesis, market context, and philosophy

**Project status:** concept and design stage. There is no code or hardware yet. The specifications are the design of record; this brief turns them into a scope of work.

---

## What We Are Looking For

A partner (or a small set of partners) to take KeyMaster from specification to a validated prototype and a credible production path. The immediate objective is a working v1 that proves the core device, not a finished retail product on day one.

We are looking for demonstrated experience in secure embedded systems: on-device cryptography, secure boot, USB device/gadget stacks, and ideally smart-card (CCID/PIV/OpenPGP) or FIDO2 authenticator work. Familiarity with dual-domain designs (a small security MCU alongside a Linux application processor) is valuable.

---

## Two Principles That Shape Every Requirement

These govern how the specs are written, and how proposals should read back to us.

**1. We specify a class, not a part.** Every specific component named in the specs is an existence-proof example that the requirement is buildable with parts available today, not a mandated selection. Final silicon, passives, and mechanicals are your call, chosen for availability, cost, and your experience. Where a proposal deviates from an example part, justify it against the requirement.

**2. Capability envelope versus sequencing.** The design specs describe everything the hardware should make possible. Which firmware ships first is a sequencing question for the roadmap, not the hardware design. Design the board so the full capability set is possible; we can agree what v1 firmware delivers separately.

---

## v1 Scope in Brief

A batteryless USB-C device with on-device PIN entry and an e-paper display, built around two power/security domains:

- **Security MCU (always on):** PIN entry, the device secret, vault cryptography, and the USB smart-card (CCID), HID keyboard, and FIDO2 interfaces. Must run standalone on smart-card-reader power, with the application processor off.
- **Application processor (higher power, Linux):** vault presentation to trusted hosts, backup/sync, the composite USB gadget, and line-rate inline encryption of external media.

Physical: stainless enclosure, 12-key recessed capacitive keypad, e-paper display, two fully dual-role USB-C ports with power pass-through, tamper detection with key zeroization, a supercapacitor-backed real-time clock, and tiered secret storage (fuse/split-secret on the base model, a secure element on the Pro model). Sold as a pair.

See the hardware spec for the full requirement set.

---

## Deliverables Required in a Proposal

A proposal should include:

1. **Architecture proposal** with clearly defined trust boundaries between the security domain, the application processor, and the host.
2. **Electrical power-path design**, including the two-port dual-role and pass-through-power strategy (wall power in, device powered, phone charged through).
3. **Card-emulation (low-power) mode power budget** and a measurement plan against a constrained-power smart-card reader (order of ~60 mA).
4. **Feasibility and risk register** with a milestone plan: what is routine, what is hard, what is uncertain, and how you propose to retire each risk.
5. **Preliminary BOM and cost range** with supply-risk notes, alternates, and lead-time exposure (secure element, application processor, e-paper, USB-C PD controllers).
6. **Validation plan** covering electrical bring-up, USB interoperability across host operating systems, mechanical, and environmental testing.

---

## Acceptance Criteria (v1 Hardware)

A design is on track when it demonstrates:

- Recessed, physical-only on-device unlock input and a low-power status display.
- A two-port USB-C design with verified pass-through power behavior.
- A stable inline "phone + charger + KeyMaster" workflow (device powered by the charger, phone charged through it, data to the phone).
- A card-emulation-mode power budget compatible with constrained-power adapter operation.
- An explicit trust-boundary architecture with a defined secure-boot and debug-lockout posture.
- A stainless enclosure with an internal thermal path adequate for the application processor under load.
- Tamper detection that zeroizes the device secret, with thresholds tuned to tolerate real-world abuse (drop, cold, power dropouts) without false-triggering.

---

## Functional Outcomes (v1 Firmware/Software)

v1 software must deliver:

1. On-device unlock (PIN or pattern) that is independent of host trust.
2. Profile-aware access control, including reduced-exposure (travel/duress) profiles, with the deniability properties described in the security spec.
3. Credential and key operations (auto-type, smart-card, FIDO2/passkey, SSH/GPG signing) without exposing root secrets to the host.
4. Usable host workflows for everyday credential operations.
5. A backup and sync path that users can understand and recover from, consistent with the "sold in pairs, backup is fundamental" model.

---

## Security and Validation Requirements

Proposals must demonstrate:

- **Separation** of security-critical operations from high-complexity, host-facing code.
- A clear **key-handling lifecycle**: creation, use, zeroization, and the rotation/recovery implications of each key.
- **Defined trust boundaries** across the hardware and software domains, matching the zones in the security spec.
- **Fail-secure behavior** on power loss, reboot loops, and update failures.

A security validation plan must include:

1. A threat-to-mitigation mapping against the documented threat model (T1–T3 in scope; nation-state lab attacks are explicitly out of scope).
2. A cryptographic design review plan.
3. An implementation review checklist (constant-time crypto, key zeroization, no plaintext keys in logs, debug disabled in production).
4. A fuzzing and negative-testing plan for all parsers and protocols.
5. An external review or penetration test before any production launch.

---

## What Is Deliberately Left Open

These decisions are yours to make and justify against the product goals:

- Specific silicon selection (security MCU, application processor, secure element), within the required classes.
- Programming language choices for firmware and host software.
- The specific sync protocol stack.
- The exact USB gadget composition.
- The Linux distribution or board support package.
- Enclosure manufacturing method and finishing details, provided the physical-security and thermal requirements are met.

---

## Engagement Shape and Budget

We anticipate a phased engagement: feasibility and architecture, then prototype (schematic, PCB, enclosure, firmware MVP), then design-for-manufacture and validation. The hardware spec's development-deliverables section carries indicative, order-of-magnitude budget ranges for the prototype phase; these are planning placeholders to be replaced by your quote. A realistic secure, dual-processor device of this kind is a substantial firmware effort, and we would rather see an honest number than an optimistic one.

The broader capital picture (prototype through certification and a first production run) is summarized in the investor-facing materials in the README and vision documents.

---

## How to Engage

KeyMaster is at Phase 0: finding an engineering partner and early collaborators. If your firm has experience in secure embedded systems and this scope fits your capabilities, we would like to talk. Open an issue on the repository or reach out with questions, a preliminary read on feasibility, or areas where you would push back on the design.

We expect pushback. The specifications reflect careful design, but you build these devices for a living; where we have something wrong or expensive-for-no-reason, we want to hear it.
