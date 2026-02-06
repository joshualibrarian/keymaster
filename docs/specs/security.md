# KeyMaster – Security Specification

**Version:** 0.1 (Draft)
**Status:** Design-in-progress

This document specifies the cryptographic design and threat model for KeyMaster. It is intended for security review and as a reference for implementation.

---

## Table of Contents

1. [Security Goals](#security-goals)
2. [Threat Model](#threat-model)
3. [Key Hierarchy](#key-hierarchy)
4. [Cryptographic Primitives](#cryptographic-primitives)
5. [Profile System](#profile-system)
6. [Entry Encryption](#entry-encryption)
7. [PIN Protection](#pin-protection)
8. [Secure Element](#secure-element)
9. [Device Authentication](#device-authentication)
10. [Tamper Protection](#tamper-protection)
11. [Attack Mitigations](#attack-mitigations)
12. [Security Boundaries](#security-boundaries)

---

## Security Goals

### Primary Goals

1. **Confidentiality:** Secrets are only accessible to authorized users with the correct PIN
2. **Integrity:** Tampering with vault data is detectable
3. **Availability:** Users can always access their secrets when they have physical possession
4. **Deniability:** Hidden profiles cannot be proven to exist
5. **Isolation:** Compromise of one profile does not reveal others

### Non-Goals

1. **Protection against nation-state lab attacks:** Invasive chip-level extraction is out of scope
2. **Remote attestation:** Device does not prove state to remote parties
3. **DRM or anti-copying:** Users can export and backup their data freely

---

## Threat Model

### Adversary Capabilities

| Threat Level | Adversary | Capabilities | In Scope? |
|--------------|-----------|--------------|-----------|
| **T1** | Casual thief | Physical possession, no technical skills | Yes |
| **T2** | Skilled attacker | Physical possession, software tools, public exploits | Yes |
| **T3** | Resourced attacker | Custom hardware, JTAG, logic analyzers, glitching | Partially |
| **T4** | Nation-state lab | Chip decapping, FIB, unlimited resources | No |

### Attack Scenarios

#### Physical Attacks (T1-T2)

| Attack | Description | Mitigation |
|--------|-------------|------------|
| Stolen device | Attacker has physical device | PIN required, rate limiting, lockout |
| Lost device | Device falls into unknown hands | Encrypted at rest, no default unlock |
| Shoulder surfing | Attacker observes PIN entry | Recessed keypad, pattern-based entry |
| Forced unlock | User coerced to reveal PIN | Duress profile with decoy data |

#### Software Attacks (T2)

| Attack | Description | Mitigation |
|--------|-------------|------------|
| Malicious host | Compromised computer | Crypto on-device, host never sees keys |
| USB attacks | BadUSB, malicious drivers | Minimal USB surface, signed firmware |
| Firmware tampering | Modified firmware image | Secure boot, signature verification |
| Memory dump | Extract keys from RAM | TrustZone isolation, zeroization |

#### Hardware Attacks (T3)

| Attack | Description | Mitigation |
|--------|-------------|------------|
| JTAG/SWD | Debug interface access | Debug disabled, fuses blown |
| Side-channel | Power analysis, EM emanations | Constant-time crypto, randomized ops |
| Glitching | Voltage/clock manipulation | Glitch detection, redundant checks |
| Cold boot | Freeze and extract RAM | Supercap-backed zeroization |

### Out-of-Scope Attacks

- Chip decapping and microprobing
- Focused ion beam (FIB) circuit modification
- Attacks requiring >$100k equipment or cleanroom access
- Social engineering (beyond duress scenarios)
- Rubber-hose cryptanalysis (torture)

---

## Key Hierarchy

### Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Key Hierarchy                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  User Input                Hardware Secret                           │
│      │                          │                                    │
│      ▼                          ▼                                    │
│  ┌───────┐                ┌───────────┐                              │
│  │  PIN  │                │    DRS    │  Device Root Secret          │
│  └───┬───┘                │  (in SE)  │  (256-bit, hardware-bound)   │
│      │                    └─────┬─────┘                              │
│      ▼                          │                                    │
│  ┌────────────────────┐         │                                    │
│  │ Argon2id(PIN,salt) │         │                                    │
│  │  m=64MB, t=3, p=4  │         │                                    │
│  └─────────┬──────────┘         │                                    │
│            │                    │                                    │
│            ▼                    ▼                                    │
│         ┌──────┐           ┌────────────────────────────┐            │
│         │  PK  │──────────▶│ HKDF(PK || DRS, "KEK", 32) │            │
│         └──────┘           └──────────────┬─────────────┘            │
│         PIN Key                           │                          │
│                                           ▼                          │
│                                      ┌─────────┐                     │
│                                      │   KEK   │                     │
│                                      └────┬────┘                     │
│                                 Key Encryption Key                   │
│                                           │                          │
│                                           ▼                          │
│                              ┌────────────────────────┐              │
│                              │ AES-KW(KEK, MVK_wrap)  │              │
│                              └───────────┬────────────┘              │
│                                          │                           │
│                                          ▼                           │
│                                     ┌─────────┐                      │
│                                     │   MVK   │                      │
│                                     └────┬────┘                      │
│                              Master Vault Key (per-profile)          │
│                                          │                           │
│                         ┌────────────────┼────────────────┐          │
│                         ▼                ▼                ▼          │
│                    ┌─────────┐      ┌─────────┐      ┌─────────┐     │
│                    │  DEK₁  │      │  DEK₂  │      │  DEK₃  │     │
│                    └─────────┘      └─────────┘      └─────────┘     │
│                    Entry Keys (per-entry, multi-recipient)           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Definitions

| Key | Size | Derivation | Storage | Lifetime |
|-----|------|------------|---------|----------|
| **PIN** | Variable | User input | Never stored | Transient (in RAM during unlock) |
| **Salt** | 256 bits | Random | Per-profile in flash | Permanent (regenerate to rotate PIN) |
| **DRS** | 256 bits | SE RNG or MCU HUK | SE or OTP fuses | Device lifetime |
| **PK** | 256 bits | Argon2id(PIN, salt) | Never stored | Transient |
| **KEK** | 256 bits | HKDF(PK \|\| DRS, "KEK") | Never stored | Session (while unlocked) |
| **MVK** | 256 bits | Random | Wrapped in flash | Profile lifetime |
| **DEK** | 256 bits | Random | Wrapped per-entry | Entry lifetime |

### Key Properties

**Device Root Secret (DRS):**
- Generated once during device initialization
- Stored in secure element (preferred) or derived from MCU hardware unique key
- Never leaves the device
- Binds all encryption to this specific hardware

**PIN Key (PK):**
- Derived from user PIN using Argon2id
- High memory cost (64 MB) to resist GPU/ASIC attacks
- Unique salt per profile prevents rainbow tables

**Key Encryption Key (KEK):**
- Combines PK (user knowledge) with DRS (device possession)
- Two-factor: device + PIN required to decrypt vault
- Exists only in RAM while profile is unlocked

**Master Vault Key (MVK):**
- One per profile (enables cryptographic isolation)
- Wrapped with KEK and stored in flash
- Used to wrap/unwrap per-entry DEKs

**Data Encryption Key (DEK):**
- One per entry
- Enables sharing: entry can have multiple recipient blobs
- Each recipient blob contains DEK wrapped by that profile's MVK

---

## Cryptographic Primitives

### Algorithm Selection

| Purpose | Algorithm | Parameters |
|---------|-----------|------------|
| PIN stretching | Argon2id | m=65536 KB, t=3, p=4 |
| Key derivation | HKDF-SHA256 | Per RFC 5869 |
| Key wrapping | AES-256-KW | Per RFC 3394 |
| Data encryption | AES-256-GCM | 96-bit nonce, 128-bit tag |
| Alternative AEAD | ChaCha20-Poly1305 | 96-bit nonce |
| Hashing | SHA-256, SHA-512 | Per FIPS 180-4 |
| Signing | Ed25519 | Per RFC 8032 |
| Key agreement | X25519 | Per RFC 7748 |

### Why These Choices

**Argon2id** (PIN stretching):
- Winner of Password Hashing Competition
- Memory-hard: resists GPU/ASIC attacks
- Argon2id variant resists both side-channel and GPU attacks
- Parameters chosen for ~1 second unlock on embedded ARM

**AES-256-GCM** (encryption):
- NIST-approved, widely analyzed
- Hardware acceleration available on target MCUs
- Authenticated encryption prevents tampering
- 96-bit nonce with random generation (collision probability acceptable)

**ChaCha20-Poly1305** (alternative):
- Software-friendly (no AES hardware needed)
- Constant-time implementation easier
- Used when AES acceleration unavailable

**Ed25519** (signatures):
- Fast, small signatures
- Deterministic (no RNG needed for signing)
- Used for firmware verification and device attestation

### Nonce Management

```
Nonce Strategy:
- 96-bit random nonces for AES-GCM
- Never reuse nonce with same key
- Entry version number included in AAD (prevents rollback)

Nonce Generation:
- Primary: SE hardware RNG
- Fallback: MCU TRNG + DRBG
- Health checks before each use

Collision Analysis:
- 96-bit nonce, random selection
- 2^32 encryptions before 50% collision probability
- Acceptable for vault use case (<<2^32 operations)
```

---

## Profile System

### Profile Isolation

Each profile is cryptographically independent:

```
Profile A                    Profile B                    Profile C
─────────                    ─────────                    ─────────
PIN_A                        PIN_B                        PIN_C
  │                            │                            │
  ▼                            ▼                            ▼
Salt_A                       Salt_B                       Salt_C
  │                            │                            │
  ▼                            ▼                            ▼
PK_A ──┐                     PK_B ──┐                     PK_C ──┐
       │                            │                            │
       ▼                            ▼                            ▼
    ┌──────┐                     ┌──────┐                     ┌──────┐
DRS─│ HKDF │                 DRS─│ HKDF │                 DRS─│ HKDF │
    └──┬───┘                     └──┬───┘                     └──┬───┘
       │                            │                            │
       ▼                            ▼                            ▼
    KEK_A                        KEK_B                        KEK_C
       │                            │                            │
       ▼                            ▼                            ▼
    MVK_A                        MVK_B                        MVK_C
```

**Key properties:**
- No shared keys between profiles
- Cannot derive one profile's keys from another
- Duress profile indistinguishable from regular profile

### Profile Types

| Type | Purpose | Visibility |
|------|---------|------------|
| **Primary** | Main user profile | All groups the user permits |
| **Travel** | Reduced exposure while traveling | Subset of groups (low-risk only) |
| **Duress** | Coerced unlock scenario | Decoy groups with harmless data |
| **Work** | Employer-accessible data | Work-related groups only |

### Deniable Encryption

**How it works:**
- All profile metadata has identical structure
- Wrapped MVK blobs are same size (256 bits + 64-bit tag)
- No profile count stored; device tries all known salts
- Failed decryption indistinguishable from "no more profiles"

**Limitations:**
- Attacker with physical access can observe number of unlock attempts
- Statistical analysis of flash wear could reveal profile count (mitigated by wear leveling)
- Duress profile should be used occasionally to maintain plausibility

---

## Entry Encryption

### Entry Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Encrypted Entry                              │
├─────────────────────────────────────────────────────────────────────┤
│  Header (plaintext):                                                 │
│    entry_uuid: 128 bits                                              │
│    version: 32 bits                                                  │
│    modified: 64 bits (timestamp)                                     │
│    recipient_count: 8 bits                                           │
│                                                                      │
│  Recipient Blobs (per-profile):                                      │
│    ┌──────────────────────────────────────────┐                      │
│    │  profile_id: 128 bits (UUID)             │                      │
│    │  wrapped_dek: 256 + 64 bits (AES-KW)     │ × N recipients       │
│    └──────────────────────────────────────────┘                      │
│                                                                      │
│  Encrypted Payload:                                                  │
│    nonce: 96 bits                                                    │
│    ciphertext: variable                                              │
│    tag: 128 bits                                                     │
│                                                                      │
│  AAD (additional authenticated data):                                │
│    entry_uuid || version || modified                                 │
└─────────────────────────────────────────────────────────────────────┘
```

### Multi-Recipient Encryption

Entries can be accessible from multiple profiles:

```
Entry: "GitHub Credentials"
  │
  ├── Recipient: Profile "personal"
  │     wrapped_dek = AES-KW(MVK_personal, DEK)
  │
  └── Recipient: Profile "work"
        wrapped_dek = AES-KW(MVK_work, DEK)
```

**Process to decrypt:**
1. User unlocks profile (e.g., "personal")
2. KEK derived, MVK unwrapped
3. For target entry, find recipient blob matching profile UUID
4. Unwrap DEK using MVK
5. Decrypt payload using DEK + nonce

**Process to share entry with new profile:**
1. Decrypt DEK using source profile's MVK
2. Wrap DEK with destination profile's MVK
3. Add new recipient blob to entry
4. Re-encrypt and save

### Field-Level Encryption

Sensitive fields have additional protection:

```xml
<entry>
  <title>GitHub</title>                    <!-- Cleartext in encrypted payload -->
  <username>user@email.com</username>      <!-- Cleartext in encrypted payload -->
  <password protected="true">
    <blob>base64(AES-GCM(DEK, password))</blob>
  </password>
  <notes>...</notes>
</entry>
```

The entire entry is encrypted, but password fields are double-encrypted. This enables:
- Showing entry titles without exposing passwords
- Additional confirmation required for password reveal
- Audit logging of password access

---

## PIN Protection

### Argon2id Parameters

```
Parameters:
  m (memory): 65536 KB (64 MB)
  t (iterations): 3
  p (parallelism): 4
  hashlen: 32 bytes (256 bits)
  saltlen: 32 bytes (256 bits)

Rationale:
  - 64 MB memory resists GPU attacks (GPUs have limited fast memory)
  - 3 iterations provide good security margin
  - 4 threads utilize quad-core AP
  - Runs in ~1 second on target ARM Cortex-A7
```

### Rate Limiting

```
Attempt Tracking (in SE or MCU flash):
  ┌──────────────────────────────────┐
  │  failed_attempts: uint8          │
  │  last_attempt: timestamp         │
  │  lockout_until: timestamp        │
  └──────────────────────────────────┘

Backoff Schedule:
  Attempts 1-3:   No delay
  Attempts 4-6:   30 second delay
  Attempts 7-9:   5 minute delay
  Attempts 10-12: 1 hour delay
  Attempts 13+:   24 hour delay

Lockout:
  After 20 failed attempts: Permanent lockout
  Recovery: Factory reset only (vault data lost)

Counter Reset:
  Successful unlock resets counter to 0
  Counter stored in tamper-resistant memory
```

### PIN Entry Security

```
Keypad Properties:
  - Recessed design: not visible from side angles
  - Silent capacitive touch: no audible feedback
  - Pattern-based entry: reduces shoulder surfing
  - No key labels visible when in use

Pattern vs. Digit PIN:
  - Device supports both modes
  - Pattern: 4-9 key sequence (swipe-like)
  - Digit: 4-12 digit numeric PIN
  - Pattern preferred for public spaces

PIN in Memory:
  - Stored in TrustZone secure RAM (if available)
  - Zeroized immediately after PK derivation
  - Never written to flash or non-secure memory
```

---

## Secure Element

### SE Functions

The secure element (optional, Pro model) provides:

| Function | Description |
|----------|-------------|
| **DRS Storage** | Device Root Secret stored in tamper-resistant memory |
| **Rate Limiting** | Hardware-enforced PIN attempt counter |
| **RNG** | True random number generator |
| **Attestation** | Sign device identity with hardware-bound key |
| **Crypto Offload** | AES, ECC operations (optional) |

### SE Communication

```
Interface: ISO7816-3 T=1 or SPI
Protocol: APDU commands

Key Commands:
  SELECT            - Select applet
  VERIFY PIN        - Check PIN (handled by SE)
  UNWRAP KEY        - Decrypt using SE-stored key
  SIGN              - Create signature with attestation key
  GET RANDOM        - Obtain random bytes

Security:
  - All commands authenticated with session key
  - Replay protection via command counter
  - Communication encrypted after authentication
```

### Non-SE Fallback

When no SE is present (base model):

```
DRS Derivation:
  1. Read MCU Hardware Unique Key (HUK) from OTP fuses
  2. DRS = HKDF(HUK, "KeyMaster DRS v1", device_serial)

Rate Limiting:
  - Counter in MCU flash (less tamper-resistant)
  - Glitch detection to protect counter updates

RNG:
  - MCU TRNG as entropy source
  - DRBG (HMAC-DRBG) for expansion
  - Health checks per SP 800-90B
```

---

## Device Authentication

### Device Identity

Each KeyMaster has a unique identity:

```
Device Certificate:
  Subject: CN=<device_uuid>
  Issuer: CN=KeyMaster Factory CA (or self-signed)
  Public Key: Ed25519
  Extensions:
    - Device serial number
    - Hardware revision
    - SE present flag

Private Key Storage:
  - In SE (Pro model): Attestation applet
  - Without SE: Derived from DRS + "device_key"
```

### Sync Authentication

Devices authenticate to each other during sync:

```
Mutual TLS 1.3:
  1. Device A connects to Device B
  2. Both present device certificates
  3. Owner verification:
     - Devices must share owner signature
     - Owner signs device certs during pairing
  4. Session established with forward secrecy

Owner Key:
  - Ed25519 keypair generated on first device
  - Used to sign new device certificates
  - Backed up (encrypted) for recovery
```

### Host Identification

Hosts are identified by fingerprint:

```
Host Fingerprint:
  - SHA-256 of host-specific data
  - Sources: machine ID, hostname, USB topology
  - Not cryptographically secure (advisory only)

Host Registration:
  1. Unknown host detected
  2. Display shows: "New host: [name]. Trust level?"
  3. User selects: Full / Limited / Deny
  4. Host policy stored with fingerprint
```

---

## Tamper Protection

### Physical Tamper Detection

```
Tamper Switch:
  - Mechanical switch triggered by case opening
  - Connected to MCU tamper input
  - Supercap-backed: works without USB power

Response:
  1. Interrupt wakes MCU (or keeps it awake)
  2. MCU zeroizes all keys in RAM
  3. MCU increments tamper counter
  4. SE (if present) increments its counter
  5. Device enters locked state
  6. User sees "Tamper detected" on next use

Tamper Counter:
  - Stored in SE or protected flash
  - Visible to user on status screen
  - Cannot be reset (permanent record)
```

### Voltage and Clock Monitoring

```
Glitch Detection:
  - Brown-out detector (BOD) enabled
  - Clock security system (CSS) monitors oscillator
  - Watchdog timer for software hangs

Response to Anomaly:
  - Immediate reset
  - Keys zeroized before reset
  - Counter incremented
```

### Cold Boot Protection

```
Supercapacitor Function:
  1. USB power lost (disconnect or glitch)
  2. Supercap provides ~100ms power
  3. MCU detects power loss
  4. MCU zeroizes all keys
  5. MCU triggers safe e-paper refresh
  6. System powers down cleanly

Supercap Sizing:
  - Capacity: 1-2F
  - Voltage: 3.3V
  - Hold-up time: >100ms at 50mA load
```

---

## Attack Mitigations

### Side-Channel Mitigations

| Attack | Mitigation |
|--------|------------|
| **Timing** | Constant-time comparison, fixed iteration counts |
| **Power analysis** | Randomized operation order, dummy operations |
| **EM emanation** | Shielded enclosure, randomized execution |
| **Cache timing** | No data-dependent memory access patterns |

### Software Mitigations

| Attack | Mitigation |
|--------|------------|
| **Buffer overflow** | Rust/safe C, stack canaries, ASLR |
| **ROP/JOP** | ARM PAC (if available), CFI |
| **Firmware downgrade** | Version counter in OTP, anti-rollback |
| **Debug access** | JTAG disabled, RDP level 2 |

### Protocol Mitigations

| Attack | Mitigation |
|--------|------------|
| **Replay** | Nonces in all encrypted messages, timestamps |
| **MITM (sync)** | Mutual TLS, certificate pinning |
| **Rollback** | Version numbers in AAD, monotonic counters |
| **Malformed input** | Strict parsing, length limits, fuzzing |

---

## Dead Man's Switch (Bequeathing)

### Overview

A backup KeyMaster can be configured to release designated data if the owner fails to "check in" within a specified time window. This enables scenarios like journalists protecting sources or users ensuring next-of-kin access.

### Mechanism

```
Check-in Protocol:
  1. Backup device monitors sync heartbeats from primary
  2. Each successful unlock of primary (or backup itself) resets timer
  3. Timer expiration triggers release sequence

Release Options:
  - Email encryption keys to designated recipients
  - Publish keys to pre-configured dead drop (Tor hidden service, etc.)
  - Unlock specific entries for physical retrieval
  - Broadcast decryption key for already-published encrypted data
```

### Threat Model

| Scenario | Protection Level | Notes |
|----------|------------------|-------|
| Adversary doesn't know backup exists | Strong | Device releases as configured |
| Adversary finds and isolates device | None | Network isolation prevents release |
| Adversary coerces owner to check in | Partial | Duress check-in can accelerate release |
| Adversary intercepts release | Partial | Distributed release mitigates |
| Clock manipulation | Weak | Requires authenticated NTP from multiple sources |

**Security property:** Protection comes from *secrecy of backup location*, not cryptographic properties. This is fundamentally different from other KeyMaster security guarantees.

### Enhancements

**Duress-aware check-in:**
```
Normal unlock → Reset timer
Duress PIN unlock → Accelerate timer (or trigger immediate release)
```

**Distributed release:**
- Don't store plaintext on backup device
- Store keys to data already published in encrypted form elsewhere
- Interception at release time doesn't help adversary

**Multi-signal heartbeat:**
- Require check-in from primary device AND external signal
- External: email to specific address, social media post, etc.
- Increases difficulty of faking check-in

### Explicit Limitations

This feature should be documented with clear warnings:

1. **Not cryptographically enforced:** Physical possession of backup defeats the mechanism
2. **Network-dependent:** Isolated devices cannot release or verify check-ins
3. **Time-dependent:** Clock attacks possible without authenticated time sources
4. **Coercion-vulnerable:** Owner can be forced to check in (mitigated by duress mode)

Appropriate for: Journalists, activists, estate planning, scenarios where adversary likely doesn't know backup exists.

Not appropriate for: Protection against adversaries who will search exhaustively for backup devices.

---

## Security Boundaries

### Trust Zones

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Trust Boundaries                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                    MOST TRUSTED (Zone 0)                       │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │  Secure Element (if present)                             │  │  │
│  │  │  - DRS storage                                           │  │  │
│  │  │  - Rate limiting                                         │  │  │
│  │  │  - Attestation key                                       │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  │                                                                │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │  MCU TrustZone Secure World                              │  │  │
│  │  │  - Active keys (KEK, MVK, DEK)                           │  │  │
│  │  │  - PIN buffer                                            │  │  │
│  │  │  - Crypto operations                                     │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                    TRUSTED (Zone 1)                            │  │
│  │  MCU Normal World                                              │  │
│  │  - Keypad driver                                               │  │
│  │  - Display driver                                              │  │
│  │  - USB stack                                                   │  │
│  │  - State machine                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                    LESS TRUSTED (Zone 2)                       │  │
│  │  Application Processor (Linux)                                 │  │
│  │  - FUSE filesystem                                             │  │
│  │  - Sync daemon                                                 │  │
│  │  - Web UI                                                      │  │
│  │  - Storage drivers                                             │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                    UNTRUSTED (Zone 3)                          │  │
│  │  Host Computer                                                 │  │
│  │  - USB interface only                                          │  │
│  │  - Never sees plaintext keys                                   │  │
│  │  - All sensitive ops require on-device confirmation            │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Flow Rules

| From | To | Allowed Data |
|------|----|--------------|
| Zone 0 | Zone 1 | Encrypted data, status codes |
| Zone 1 | Zone 0 | PIN (for verification), commands |
| Zone 1 | Zone 2 | Encrypted entries, wrapped keys |
| Zone 2 | Zone 1 | Encrypted data, sync messages |
| Zone 2 | Zone 3 | Encrypted vault (via USB mass storage) |
| Zone 3 | Zone 2 | User commands, host identification |

**Never allowed:**
- Plaintext keys crossing any boundary
- PIN leaving Zone 0/1
- MVK/KEK leaving Zone 0
- Debug access from Zone 3

---

## Appendix A: Cryptographic Test Vectors

### Argon2id Test Vector

```
Input:
  password: "correct horse battery staple"
  salt: 0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20
  m: 65536, t: 3, p: 4

Output (PK):
  0x... (to be computed with reference implementation)
```

### AES-256-GCM Test Vector

```
Input:
  key: 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
  nonce: 0x000102030405060708090a0b
  plaintext: "test entry data"
  aad: entry_uuid || version

Output:
  ciphertext: 0x... (to be computed)
  tag: 0x... (to be computed)
```

---

## Appendix B: Security Checklist

### Implementation Checklist

- [ ] All crypto operations use constant-time implementations
- [ ] Keys zeroized immediately after use
- [ ] No plaintext keys in logs or debug output
- [ ] PIN attempt counter protected against rollback
- [ ] Firmware signature verified before execution
- [ ] Debug interfaces disabled in production
- [ ] Random numbers from hardware RNG with health checks
- [ ] TLS 1.3 with certificate pinning for sync
- [ ] All user input validated and length-limited

### Review Checklist

- [ ] Key hierarchy reviewed by cryptographer
- [ ] Argon2id parameters validated for target hardware
- [ ] Side-channel resistance tested
- [ ] Fuzzing performed on all parsers
- [ ] Penetration test by external party
- [ ] Secure element evaluation (if used)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | 2025-09 | - | Initial draft |
