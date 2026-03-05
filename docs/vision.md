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

## Near-Term Goal

The immediate goal is to partner with experienced engineering teams to turn this vision into a validated prototype and a credible production path.
