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

Backoff Schedule (defaults, user-configurable):
  Attempts 1-3:   No delay
  Attempts 4-6:   30 second delay
  Attempts 7-9:   5 minute delay
  Attempts 10-12: 1 hour delay
  Attempts 13+:   24 hour delay

Lockout (default: 20 attempts, user-configurable):
  After N failed attempts: Permanent lockout
  Recovery: Factory reset or social recovery (see Key Recovery section)

Counter Reset:
  Successful unlock resets counter to 0
  Counter stored in tamper-resistant memory
```

The lockout threshold, backoff schedule, and reset policy are user-configurable during setup and adjustable later (via elevated unlock).  Users with high recall confidence and high-value vaults may set a tighter lockout (10 attempts or fewer); users who routinely mistype and accept marginally higher brute-force risk may set a looser one (30 or more).  The defaults reflect a general-purpose choice.

### On Brute-Force Resistance

Traditional brute-force analysis assumes an attacker can issue guesses rapidly, so PIN entropy must be large enough to resist billions or trillions of attempts. KeyMaster's design breaks both assumptions.

**Input is physical, not programmable.** The capacitive keypad has no mechanical switches and no exposed contacts. Automating key entry would require a robotic apparatus that correctly triggers capacitive sensing across 12 keys — a significantly harder engineering problem than driving a USB interface or soldering to a debug pin. For practical purposes, a human attacker enters guesses by hand, at human speeds.

**Attempts are hard-capped.** The rate-limiting schedule permanently locks the device after a user-configured number of failed attempts (default: 20). Recovery then requires factory reset or social recovery (see the Key Recovery section). An attacker gets at most N tries total — not N per second indefinitely.

**The math inverts.** A 6-digit PIN has 10⁶ = 1,000,000 possible values. At the default 20-attempt cap, random guesses against a uniformly-chosen 6-digit PIN succeed with probability 20 / 10⁶ = 0.002% — roughly 1 in 50,000. An 8-digit PIN drops that to 1 in 5 million. Users who want tighter protection can lower the cap; users who routinely mistype can raise it, accepting marginally higher brute-force exposure. Either way, the protection is stronger than most online services provide against password guessing, and it's achieved with PINs short enough to remember easily.

**PIN length primarily serves other goals.** Because brute force is not the limiting factor, users can choose PIN length based on other considerations:

- **Coercion-resistance**: longer sequences are harder to compel quickly under duress; the act of entering a 16-digit sequence is visibly slower and more cognitively demanding than a 4-digit one
- **Shoulder-surfing resistance**: longer patterns are harder for a bystander to memorize in the brief window of observation
- **Personal memorability**: a meaningful 12-digit sequence (a historical date, a phone number) may be easier to recall than an arbitrary 4-digit one

The device supports PINs of arbitrary length within hardware limits; users pick what fits their threat model.

**Implication for positioning:** KeyMaster's security does not come from forcing users to memorize high-entropy secrets. It comes from making attempts expensive and finite, so modest entropy suffices. This is a structurally different security story than software password managers (which must defend against offline attacks on exported vaults at billions of guesses per second) and is a direct consequence of keeping the vault in tamper-resistant hardware with physical-only input.

### PIN Entry Security

```
Keypad Properties:
  - Recessed design: not visible from side angles
  - Silent capacitive touch: no audible feedback
  - No key labels visible when in use
  - Purely physical input: no remote/programmatic entry path

PIN Memorization Styles:
  Users can frame their PIN mentally in whichever way works for them:
  - As a traced pattern (shape on the keypad, like a swipe unlock)
  - As a numeric code (digits, like a phone or debit-card PIN)
  - As a meaningful sequence (dates, phone numbers, personal mnemonics)

  The device stores and verifies the input as an ordered sequence of key
  touches.  Pattern vs. digit is a user preference, not a device mode.
  Patterns often suit quick under-the-table entry (muscle memory of shape);
  digits often suit recall across contexts and devices.

PIN in Memory:
  - Stored in TrustZone secure RAM (if available)
  - Zeroized immediately after PK derivation
  - Never written to flash or non-secure memory
```

### Tiered Unlock for Elevated Operations

A profile unlock gives the user access to their day-to-day credentials: passwords, TOTP seeds, routine signing keys. For a small number of high-sensitivity items, the user may want an additional authentication step beyond the profile PIN. KeyMaster supports **tiered unlock** — operations or entries flagged as elevated require a second PIN, distinct from the profile PIN, entered after the profile is already unlocked.

**Motivation:**

The classic PGP hierarchy distinguished a master key (used only for certifying other keys, kept extra carefully) from subkeys (used for day-to-day operations). The same asymmetry applies to any user who holds a few very-rarely-used, catastrophic-if-compromised secrets alongside many frequently-used routine ones. Requiring the same PIN for both forces a trade-off: either excessive friction on routine operations or insufficient protection on critical ones. Tiered unlock resolves the trade-off by scaling protection to sensitivity.

**Mechanism:**

```
Profile Unlock (Tier 1):
  PIN_1 → PK_1 → KEK_1 → MVK_1
  Unlocks routine entries in the profile.

Elevated Unlock (Tier 2):
  PIN_2 → PK_2 → KEK_2 → EVK  (Elevated Vault Key)
  Required to access elevated entries or perform elevated operations.
  Valid only while the profile itself is already unlocked (session-gated).

Elevated Entries:
  Wrapped with EVK rather than MVK.
  Visible as metadata (title, group) after profile unlock, but content accessible
  only after elevated unlock within the same session.
```

**Typical elevated operations:**

- Revealing wallet seeds or seed phrases
- Exporting the private key of a long-term signing identity
- Authorizing a new paired device or sync partner
- Rotating the profile's master key
- Accessing a "cold" entry group (backup authentication codes, inheritance instructions, etc.)

**Duress interaction:**

Because elevated unlock requires both PINs, an attacker who has extracted the profile PIN — via coercion, shoulder-surfing, or keystroke observation — still cannot access elevated content without the second PIN. The two PINs should be chosen to differ in length and style (a pattern for the profile, a numeric sequence for elevation, or vice versa) to make them cognitively distinct and reduce the risk of both being surrendered in the same duress event.

**Policy configurability:**

The set of entries and operations requiring elevation is policy-controlled. Default: wallet seeds, signing identities, device-pairing operations, and any entry the user explicitly flags. Users can adjust the policy during setup or later — with elevation itself required to change the policy, preventing an attacker with only the profile PIN from lowering the protection of elevated entries.

**Limits:**

Tiered unlock is defense in depth, not a new root of trust. An attacker with full device compromise at the hardware level is not meaningfully hindered by the second PIN. The mechanism protects against attackers who have obtained the profile PIN but lack the elevation PIN, physical access during an elevated session, or the ability to observe two independent authentications.

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

## Key Recovery

### The Recovery Problem

KeyMaster is built around hardware custody of secrets: a forgotten PIN, a lost device without backup, or a damaged device without backup means the vault is gone. This is the correct trade-off for a device designed to resist compromise — anything that lets the legitimate user recover also creates a path for an attacker — but it means recovery paths need to be deliberate and explicit, not accidental.

KeyMaster supports three recovery tiers with different trust and threat-model properties. Users can mix and match.

### Tier 1: Paired-Device Sync (Default)

KeyMaster is sold in pairs. The two devices sync continuously via direct USB connection, local network, or downstream connection through a host. Every change on one replicates to the other; the backup is never more than a sync cycle stale.

**Handles:**
- Primary device lost, stolen, or damaged: the backup becomes the new primary; buy a replacement to pair as the new backup.
- PIN still known but device compromised: factory-reset the compromised unit, re-pair from the backup.

**Does not handle:**
- PIN forgotten on both devices (PINs are typically the same on paired devices).
- Both devices lost simultaneously (e.g., house fire, coordinated theft).

### Tier 2: Additional Hardware Backup

Users may purchase additional single units as extra backups — held in a safe-deposit box, at a trusted relative's house, at an office safe. These units sync when they can reach each other and hold the last-synced state otherwise.

**Handles:**
- Tier-1 cases plus geographic dispersion.
- Loss of multiple units if at least one survives.

**Does not handle:**
- PIN forgotten across all devices.
- Coordinated access to all backup locations.

### Tier 3: Social Recovery via Shamir's Secret Sharing

For catastrophic scenarios — all hardware lost, PIN forgotten on all devices, or a user who prefers recovery through trusted peers over personal hardware — KeyMaster supports **threshold secret sharing** of a recovery key, using Adi Shamir's 1979 construction (Shamir, 1979, *Communications of the ACM* 22(11), 612-613).

**Mechanism:**

1. During setup, the user generates a recovery key and splits it into N shares using Shamir's scheme (polynomial interpolation over a finite field).
2. Each share is distributed to a trusted peer — a family member, a friend, a lawyer — or stored in a geographically-separated secure location.
3. Any M of the N shares can reconstruct the recovery key. Fewer than M shares reveal nothing about the key (information-theoretic guarantee, not merely computational).
4. The user maintains a **recovery blob** containing the vault's Master Vault Keys wrapped with a recovery-derived KEK. The blob can be stored openly — on cloud storage, on a factory-reset KeyMaster, on a USB drive — because it is ciphertext that only the recovery key can decrypt.
5. To recover: reconstruct the recovery key from M shares, combine it with a factory-reset KeyMaster and the recovery blob, and the vault is restored. The user sets a new PIN and resumes operation.

**Shares as paper or as devices:**

Each share can be stored in two ways:

1. **Paper shares.** The share is printed or written as a short, human-readable recovery phrase and given to the trusted peer, who stores it in whatever way suits them: a safe, a safe-deposit box, a sealed envelope with a lawyer, or simply a labeled piece of paper in a drawer. Recovery requires the user to physically collect enough shares and transcribe them into a factory-reset KeyMaster.

2. **Device-held shares.** If a trusted peer has their own KeyMaster, their share can be stored directly in their device, protected by their own PIN and by the same tamper resistance protecting the rest of their vault. When the user needs to recover, the two KeyMasters coordinate over a direct connection (USB-to-USB, local network, or through a shared relay), reconstructing the key without any paper handling. The peer's KeyMaster can enforce release policies of its own: explicit confirmation from the peer, a cooling-off period, notification to the other share-holders, or any combination the peer configures.

The two modes can also mix. A user might give paper shares to an elderly relative and a safe-deposit box, while holding device-based shares with a spouse, a best friend, and a business partner. Whatever fits the user's network of trusted peers and their technical comfort.

**Typical configurations:**

| N | M | Example |
|---|---|---------|
| 3 | 2 | Small family; any two of three can recover |
| 5 | 3 | Extended family or friends; majority required |
| 5 | 3 | Mixed: user, spouse, lawyer, safe-deposit box, trusted friend |
| 7 | 4 | Conservative; tolerates loss of three shares |

**Properties:**

- **No single point of failure.** Fewer than M shares reveal nothing, even if combined with the ciphertext recovery blob.
- **No online service needed.** Recovery is cryptographic, not custodial. There is no company to subpoena or compromise.
- **Social, not technical.** Share-holders need only keep their share safe. They don't run software, maintain infrastructure, or understand the cryptography.
- **Survives the user.** If the user becomes incapacitated or dies, the threshold of trusted parties can recover the vault — consistent with the bequeathing model (see below).

**Threat model limitations:**

- Shares need to be stored *safely*. A share on a sticky note defeats the protection.
- Share-holders can collude. Choose them with that in mind; geographic, social, and professional diversity make collusion harder.
- Social recovery is, by design, a bypass of normal PIN protection. Anyone with M shares plus the recovery blob can restore the vault without the original PIN. This is a feature (the user can recover from PIN loss) and a trade-off (a coordinated adversary with enough shares can recover without the PIN) that the user accepts when opting in.

**Recommended default for users who want social recovery as a safety net:**

N=5, M=3, with shares held by:

1. The user, in a personal safe at home
2. A trusted family member or close friend
3. A second trusted family member or close friend
4. A geographically-separated secure location (safe-deposit box, office safe)
5. A professional (lawyer, accountant) under a clear written arrangement

This tolerates the loss of any two shares, requires three to recover, and distributes across personal, social, and professional axes so no single category of compromise suffices.

### Tier 4: Factory Reset (Last Resort)

If all recovery mechanisms fail or were never configured, factory reset wipes the device entirely. The vault is lost; the device becomes newly usable.

This is the KeyMaster equivalent of "I lost my keys and have to rekey the locks." Whether this is acceptable or catastrophic depends on what's in the vault. For users treating KeyMaster as a convenience layer over regularly-changed passwords, a reset loses a few weeks of updates. For users storing crypto wallet seeds or critical long-term keys, it is terminal. Recovery-tier choice should reflect that assessment.

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
