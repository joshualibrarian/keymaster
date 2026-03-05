# KeyMaster - Security Requirements and Threat Model (Draft)

**Status:** Concept and partner-scoping
**Audience:** Security reviewers, firmware/hardware engineers, technical evaluators

Security requirements for KeyMaster v1 set mandatory goals and threat boundaries while leaving implementation details open for validated partner proposals.

---

## 1. Security Goals

### Primary goals
1. **Confidentiality:** secrets are inaccessible without authorized unlock
2. **Integrity:** unauthorized data/firmware modification is detectable
3. **Availability:** legitimate users retain practical recovery paths
4. **Isolation:** profile-level separation limits blast radius
5. **Coercion-aware UX:** support reduced-exposure and duress workflows

### Security Boundary
- Defeating nation-state invasive lab attacks in all cases
- Claiming perfect deniability under unlimited forensic pressure
- Preventing users from exporting their own data

---

## 2. Threat Model (v1)

### In scope
- Lost/stolen device attacks
- Malicious or compromised host environments
- Firmware tampering attempts
- Common hardware probing/fault attempts within realistic commercial adversary budgets

### Partially in scope
- Advanced side-channel and fault attacks (mitigate where practical; document residual risk)

### Advanced Adversary Boundary
- Unlimited-resource invasive silicon attacks

---

## 3. Architectural Security Requirements

Partner proposals must demonstrate:
- Separation of security-critical operations from high-complexity host-facing code
- Clear key-handling lifecycle (creation, use, zeroization, rotation/recovery implications)
- Defined trust boundaries across hardware/software domains
- Fail-secure behavior on power loss, reboot loops, and update failures

---

## 4. Cryptography Requirements (Outcome-Level)

Cryptographic choices are not fixed in this draft, but proposals must use modern, reviewed constructions and include rationale for:
- Password/PIN hardening strategy appropriate to target hardware
- Authenticated encryption for vault data
- Key derivation and key wrapping hierarchy
- Nonce/IV management and misuse resistance
- Randomness source and health checks

Any concrete algorithm/parameter selection must be benchmarked and validated on target hardware.

---

## 5. PIN/Unlock and Rate-Limit Requirements

Must provide:
- On-device unlock input path
- Configurable anti-bruteforce policy with durable counters
- User-visible lockout/backoff behavior
- Clear recovery/reset semantics

The exact schedule and enforcement mechanism are implementation decisions, subject to usability and attack-cost analysis.

---

## 6. Profile Isolation and Duress Requirements

Required behavior:
- Each profile uses independent key material; compromise of one profile does not decrypt other profiles.
- Unlock credentials map deterministically to profile scope and policy.
- Duress/reduced-exposure profiles are supported as first-class profiles, not UI-only filters.
- Non-target profile presence is not directly revealed through normal unlock and storage inspection paths.

Security boundary:
- Duress and deniability features are risk-reduction controls, not guarantees against unlimited forensic pressure.

Validation requirements:
- Partner proposals include test cases showing profile key separation and non-cross-decryption.
- Partner proposals include adversarial tests for profile-enumeration leakage through metadata, timing, and error behavior.

---

## 7. Host Trust and Data Exposure Rules

Security model must define what is exposed in each mode:
- Restricted Mode: minimal host surface and no broad vault visibility
- Full Mode: expanded capability on approved hosts with policy gates
- Card Emulation Mode: direct legacy smart-card-reader workflow via adapter with explicit low-power and exposure constraints

Never acceptable:
- Exporting unprotected root key material to host
- Silent privilege expansion across trust modes

---

## 8. Update and Supply-Chain Security

Must include:
- Authenticated firmware/software updates
- Anti-rollback strategy
- Key custody/process for release signing
- Build provenance/reproducibility posture for security-sensitive components

---

## 9. Tamper and Physical Security Requirements

v1 must define and implement:
- Tamper evidence and event handling policy
- Debug interface lockdown strategy for production
- Behavior on unexpected voltage/clock/power anomalies

Hardening depth may vary by SKU, but baseline behavior must be explicit and testable.

---

## 10. Validation Requirements

Security proposal must include:
1. Threat-to-mitigation mapping
2. Cryptographic design review plan
3. Implementation review checklist
4. Fuzzing and negative testing plan for parsers/protocols
5. External review/penetration testing plan before production launch
