# KeyMaster – Vision & Philosophy

This document explains the "why" behind KeyMaster: the problem we're solving, the principles guiding our design, and the future we're working toward.

---

## The Problem

### Your Digital Identity Is Fragmented

You have dozens—maybe hundreds—of accounts. Each has a password, and the important ones have 2FA. You have SSH keys for servers, GPG keys for signing, API tokens for services, crypto wallet seeds worth real money. All of this is scattered:

- Some passwords in your browser
- Some in a cloud password manager
- SSH keys on your laptop
- Wallet seeds on a hardware device (or worse, a sticky note)
- Work credentials in a different system than personal ones

None of these systems talk to each other. None of them travel well. None of them work when you're on a borrowed computer or a locked-down corporate machine.

### Current Solutions Are Broken

**Cloud password managers** (1Password, LastPass, Bitwarden, etc.):
- Convenient, but your vault lives on someone else's servers
- You must trust their security, their employees, their jurisdiction
- They can be subpoenaed, hacked, acquired, or shut down
- They require network access and a trusted host to use

**Local password managers** (KeePass, etc.):
- You control the file, but now you have a sync problem
- How do you get it to your phone? Your work laptop? A borrowed computer?
- The file is only as secure as the device it's on

**Hardware tokens** (YubiKey, Ledger, Trezor, OnlyKey):
- YubiKey: Authentication only, not password storage
- Ledger/Trezor: Crypto wallets only
- OnlyKey: Closest to what we want, but no display, limited storage, no network
- USB Armory: Powerful but complex, no integrated UI

**Secure flash drives**:
- Just encrypted storage with no intelligence
- Can't auto-type, can't integrate with password managers
- Can't adapt to untrusted hosts

### Real-World Pain Points

**The coffee shop problem:** You need to log into your bank on a public computer. Keyloggers could capture your password. Shoulder surfers could see your screen. Malware could intercept your session. With current tools, you either take the risk or don't log in.

**The border crossing problem:** Customs officials in many countries can compel you to unlock your devices. Your entire digital life is exposed. Refusing can mean detention, device seizure, or denied entry.

**The work/personal problem:** Your employer controls your work laptop. You need access to personal accounts, but you don't want IT seeing your personal passwords. Current solutions force you to choose between convenience and privacy.

**The backup problem:** Your password vault is critical. If you lose it, you lose access to everything. But backups are manual, error-prone, and often forgotten.

---

## The Solution

### One Device, All Your Secrets

KeyMaster is a single, physical device that holds:
- All your passwords and login credentials
- All your SSH and GPG keys
- All your TOTP/HOTP seeds
- All your crypto wallet seeds
- Any other sensitive files you need

It's small enough to carry everywhere. It works on any host. It adapts to the security context. And it's built on open-source principles so you can actually trust it.

### Design Principles

**1. Physical Control**

Your secrets are stored on a device you physically possess. Not on a server. Not in the cloud. Not on your laptop where it could be stolen or searched. On a dedicated, hardened device that stays with you.

**2. Adaptive Security**

Different situations require different security postures:
- On a trusted home computer, mount the full vault for convenience
- On a borrowed laptop, expose only CCID/HID—no storage, no secrets visible
- At a border crossing, unlock a travel profile with minimal data
- Under duress, unlock a decoy profile with harmless information

The device detects and adapts. You choose the trade-offs.

**3. Cryptographic Isolation**

Profiles aren't just views—they're cryptographically independent. Each profile has its own master key, derived from its own PIN. Entries shared between profiles use multi-recipient encryption. There's no way to prove other profiles exist.

**4. Open Source Everything**

Security through obscurity doesn't work. KeyMaster's hardware designs, firmware, filesystem format, and host software are all open source. The only closed components are the secure element internals (unavoidable with current silicon) and any third-party crypto libraries.

This means:
- You can audit the code
- You can build it yourself
- You can modify it for your needs
- You can fork it if the project goes sideways

**5. Works Everywhere**

KeyMaster uses standard protocols:
- USB CCID for smart-card operations
- USB HID for keyboard emulation
- USB Mass Storage for file access
- USB Ethernet for network features

No drivers needed on any modern OS. Works on Windows, Mac, Linux, Android, iOS (with adapter). Works on locked-down corporate machines where only smart cards are allowed.

---

## How It Works

### Hardware

A compact device (~2" × 3" × 0.6") with:
- **12-key capacitive keypad**: Recessed for tactile navigation, silent, works by touch alone. You can unlock it under a table, invisible to observers.
- **E-paper display**: Readable in any light, no glow to attract attention, persists when unplugged.
- **Two USB-C ports**: Either can connect to a host; the other for flash drives or backup units.
- **MicroSD slot**: For bulk user storage.
- **No battery**: Powered by USB, with a supercapacitor for safe shutdown.

### Dual-Processor Architecture

- **MCU (always on)**: Handles the keypad, display, USB device functions, and cryptographic operations. Can operate in low-power mode from a smart-card reader.
- **Application Processor**: Runs Linux for advanced features—FUSE filesystem, sync daemon, composite USB gadget. Only powers up when needed.

### Vault Filesystem

When unlocked on a trusted host, KeyMaster presents a FUSE filesystem:

```
~/.vault/
  Banking/
    Chase -> ../.entries/4f8c2.../
    CreditUnion -> ../.entries/a12b9.../
  Dev/
    GitHub -> ../.entries/7c0d1.../
  .entries/
    4f8c2.../
      .entry.xml
      ssh_key
  .profiles/
    personal/.profile.xml
  .hosts/
    desktop-123/.host.xml
```

Groups are directories. Entries are canonical in `.entries/`. Everything is XML for KeePassXC compatibility. The device handles all encryption—plaintext never touches the host disk.

### Backup & Sync

Clone units stay in sync automatically:
- Connect your active KeyMaster to your desktop
- Your backup KeyMaster, plugged into the same network (via USB-Ethernet or LAN), syncs in the background
- Content-addressed, deduplicated, encrypted replication
- Works even when the active device isn't plugged in—backup just waits

---

## Use Cases

### The Digital Nomad

You work from coffee shops, airports, and co-working spaces around the world. You plug KeyMaster into a shared computer, enter your travel profile PIN under the desk, and auto-type your credentials. The computer never sees your password database. Your high-value accounts remain hidden.

### The Security Professional

You manage SSH keys for dozens of clients, each isolated in their own group. Your KeyMaster presents as a smart card for SSH authentication. Keys never leave the device. Client A's credentials are invisible when working on Client B's systems.

### The Privacy Advocate

At a border crossing, you unlock your duress profile. The guard sees a few hotel bookings and social media logins. Your crypto wallets, secure communications, and real identity remain encrypted and invisible. There's no way to prove they exist.

### The Family

Shared Netflix password? Create a family group. Each family member has their own KeyMaster with access to shared entries. Mom can't see Dad's work passwords; Dad can't see Mom's personal accounts. But they can both access the streaming logins they share.

### The Paranoid

Your backup KeyMaster lives in a safe deposit box. Your tertiary backup is at a trusted friend's house. All three stay in sync whenever they connect to the network. If your primary is lost or stolen, your secrets are safe (encrypted) and recoverable (from backup).

---

## Why Open Source Matters Here

Security devices are different from other products. You're trusting them with your most sensitive data. That trust requires transparency.

**Closed-source security is a contradiction.** You can't verify what a black box does. You can't know if there's a backdoor. You can't know if the crypto is implemented correctly. You're trusting the vendor's reputation, not the actual security.

**Open source enables real auditing.** The code is public. Security researchers can review it. Bugs get found and fixed. Backdoors would be discovered. The community keeps the project honest.

**Open source enables user agency.** Don't like a design decision? Fork it. Vendor goes out of business? The code survives. Worried about supply chain attacks? Build it yourself from source.

For KeyMaster, this means:
- Hardware schematics and PCB layouts: Open
- MCU and AP firmware: Open
- Vault filesystem format: Open
- Host software and integrations: Open
- Secure element internals: Closed (silicon vendor limitation)

We use secure elements from vendors like STMicro and NXP. Their silicon is closed, but the interface is documented and the behavior is auditable. This is a pragmatic trade-off: certified tamper resistance requires specialized fabrication that open-source hardware can't replicate.

---

## The Future

KeyMaster v1 is a foundation. Future versions could add:

- **Smart-card adapter**: Plug into legacy contact readers via USB-C
- **Fingerprint sensor**: Biometric as a second factor
- **WiFi/BLE**: Wireless sync and authentication
- **Web of trust**: Device-to-device key signing
- **Portable home directories**: Carry your entire desktop environment
- **Dead man's switch (bequeathing)**: Automatic release of designated data if you don't check in

### A Note on Bequeathing

One feature we're exploring: a "dead man's switch" that releases specific secrets if you fail to check in within a configured window.

**The scenario:** You're a journalist pursuing a dangerous story. You hide a backup KeyMaster somewhere with network access—a computer lab, a friend's house, a random ethernet port. You configure it: "If I don't unlock my primary device for 7 days, release my story notes to these email addresses. Release my Facebook password to my sister."

**How it could work:** The hidden backup monitors check-ins from your primary device (via the normal sync protocol). If the deadline passes with no check-in, it releases the designated data—perhaps by emailing encryption keys, posting to a dead drop, or simply unlocking for a designated recipient.

**The honest limitations:** This is security through secrecy of location, not cryptographic strength. If an adversary finds the hidden device, they can isolate it from the network (preventing release) or wait and intercept the data. It's also possible to coerce someone into checking in. But for the threat model where the adversary doesn't know about your backup—and that's often the realistic scenario—it provides a meaningful safety net.

**Possible enhancements:**
- Duress-aware check-in: Normal unlock resets the timer. Duress PIN *accelerates* it.
- Distributed release: The device holds keys to already-published encrypted data, not the data itself.
- Multi-signal heartbeat: Require check-in from multiple independent sources.

This isn't a perfect system—it's a "probably works if they don't find the device" system. But that may be exactly right for journalists, activists, or anyone who wants their secrets to outlive them if something goes wrong.

But first, we need to build v1. We need engineering partners, early adopters, and contributors. We need to prove that open, trustworthy, convenient security is possible.

---

## Get Involved

If this vision resonates with you, we want to hear from you:

- **Engineers**: Help design and build it
- **Security researchers**: Review our crypto and threat model
- **Users**: Tell us your use cases and pain points
- **Advocates**: Spread the word

Together, we can build a future where everyone has secure, convenient access to their digital identity without sacrificing privacy or control.
