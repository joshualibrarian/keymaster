# KeyMaster - Vision

KeyMaster combines secure identity operations with practical daily usability.

---

## The Problem

Digital identity is fragmented across cloud services, local files, browsers, phones, and hardware tokens. Existing tools are often good at one job, but weak across real-world contexts.

Common failures:
- Security degrades on untrusted hosts
- Work/personal boundaries are awkward
- Backup and recovery are inconsistent
- High-stress contexts (travel/coercion) are poorly handled

---

## The Product Thesis

KeyMaster is a portable, open hardware identity device that keeps sensitive operations under user control while remaining practical in everyday workflows.

It is not just a password store. It is intended to be a secure interaction point for credentials, keys, and approvals.

---

## Design Principles

### 1. Physical user control
Secrets should be anchored to a device the user possesses, not only to remote infrastructure.

### 2. Context-aware exposure
The device should expose less on unknown hosts and more on approved hosts.

### 3. Profile separation
Users should be able to separate identities and use reduced-exposure profiles when needed.

### 4. Open and auditable
Hardware and software should be inspectable and forkable; trust should come from transparency.

### 5. Practical interoperability
The device should work with existing operating systems and credential ecosystems without requiring fragile one-off hacks.

---

## Operating Model (Canonical Terms)

- **Restricted Mode:** minimal host-facing surface for unknown/untrusted environments
- **Full Mode:** richer workflows on approved hosts
- **Card Emulation Mode:** direct legacy smart-card-reader workflow via adapter under constrained-power operation (roadmap)

---

## Scope and Honesty

KeyMaster aims to materially improve security and usability, not claim impossible guarantees.

Specifically:
- It should raise attacker cost and uncertainty
- It should reduce blast radius during compromise/coercion scenarios
- It should provide understandable recovery paths

Claims stay bounded: KeyMaster raises attacker cost and uncertainty, and it includes explicit limitations.

---

## Password Manager Ecosystem Direction

Preferred direction:
- Native integration path with existing open-source password managers (KeePassXC is one possible target), where cryptographic authority remains on KeyMaster

Fallback direction:
- Import/export compatibility (including `.kdbx` where appropriate), when native integration is unavailable

---

## Why This Is Built As Open Hardware/Software

For a security device, openness is part of the value proposition:
- External review improves trustworthiness
- Users retain long-term control
- Vendor failure does not destroy the ecosystem

---

## Why the Market Is Ready

Consumer awareness of digital privacy and personal security has shifted dramatically. What was once a niche concern for security professionals is now a mainstream buying motivation — and the market is responding with real products and real revenue.

**The privacy hardware wave is already here — and the numbers prove it:**

- **Privacy phones** are a proven category. Brax Technologies' BraX3 became the most-crowdfunded smartphone on Indiegogo, raising over $1.8M and shipping 5,500+ units. Their follow-up Open Slate tablet launched on Indiegogo with strong early demand. Purism's Librem 5 privacy phone raised over $1.5M in crowdfunding. The Mudita Kompakt, a privacy-focused minimalist phone, doubled its Kickstarter goal with €353K from backers across 34 countries.
- **Crypto hardware wallets** are a $348M market (2024), projected to reach $2.9B by 2032. Ledger generated $181M in revenue; Trezor hit $47M with a 600% sales spike when Bitcoin approached $100K. Foundation Devices raised $7M in seed funding for its air-gapped Passport wallet. Consumers have proven they will pay a premium for a physical device that keeps secrets off the network.
- **Hardware security keys** (NitroKey, OnlyKey, YubiKey) have moved from developer curiosity to enterprise procurement lists. Nitrokey has grown to tens of thousands of users across 120+ countries while remaining entirely self-funded — no outside investors needed.
- **Security tools** have become mainstream products. Flipper Zero raised $4.8M on Kickstarter (on a $60K goal), sold 500,000+ units, and was on track for $80M in revenue by 2023. Hak5 has been profitably selling security hardware since 2005. These are no longer fringe products — they are retail businesses.
- **Privacy routers and home automation** are now retail categories. Products like Home Assistant Amber (privacy-respecting home automation) sell through platforms like Crowd Supply, which boasts twice the success rate of Kickstarter for open-source hardware.

**The broader privacy technology market confirms the trend.** The global Privacy Enhancing Technologies market is projected to grow from $3.2B (2024) to $28.4B by 2034 — a 24.5% CAGR. Regulatory pressure (GDPR, CCPA), rising consumer awareness, and IoT proliferation are all accelerating demand. Cybersecurity startup investment surged in 2025, and venture firms like Andreessen Horowitz are backing privacy-first companies (Cape, a privacy phone service, raised $61M).

**What all these products have in common:** each solves one slice of the personal security problem. A hardware wallet protects seed phrases. A security key handles FIDO2. A privacy phone hardens the mobile stack. Users who care about security end up carrying multiple single-purpose devices and managing multiple fragmented workflows.

**What's missing is integration.** No current product unifies credentials, keys, OTP, wallet seeds, and context-aware host behavior in a single device under the user's physical control. KeyMaster is designed for exactly that gap — not by competing with any one of these products, but by consolidating the fragmented workflows they collectively address.

The market has already educated the buyer. The infrastructure of trust (open hardware, transparent security claims, community review) is now expected, not novel. The demand signal is clear and quantified. What remains is execution.

---

## Near-Term Goal

The immediate goal is to partner with experienced engineering teams to turn this vision into a validated prototype and a credible production path.
