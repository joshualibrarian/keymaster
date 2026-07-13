# KeyMaster – Vision & Philosophy

This document explains the "why" behind KeyMaster: the problem we're solving, the principles guiding our design, and the future we're working toward.

---

## The Product Thesis

KeyMaster is a portable, open hardware identity device that keeps sensitive operations under the user's physical control while staying practical in everyday workflows.

It is not just a password store. It is a secure interaction point for credentials, keys, and approvals: the place where you log in, sign, authenticate, and hold your secrets, on a device you own rather than on infrastructure you rent or a host you can't trust.

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

No drivers needed on any modern OS. Works on Windows, Mac, Linux, Android, and iPhone/iPad (all USB-C as of recent models). Works on locked-down corporate machines where only smart cards are allowed.

**6. Backup Is the Default, Not an Afterthought**

KeyMaster is sold in pairs at a discount over single units. Every new user starts with two devices — a primary and a synced backup — because the failure mode we see over and over with other security tools is "I meant to back up, but I never got around to it." By making backup part of the purchase rather than a later chore, we remove the most common way for users to lose their secrets.

The two units sync continuously when they can reach each other. If one is lost or damaged, the other is already current. If you want a third or fourth backup (safe deposit box, trusted friend's house, office safe), you can buy additional single units — but nobody starts the journey with just one.

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

Groups are directories; entries are canonical in `.entries/`. The device handles all encryption—plaintext never touches the host disk, and the on-device store is opaque (see the security spec's "object-soup" format). Where a user wants to work in an existing password manager, KeyMaster can export to the standard KeePass `.kdbx` format — compatible with the whole KeePass family (KeePassXC on the desktop, KeePassDX / KeePassium and others on mobile). Which managers to integrate with is an open, not-yet-decided question; `.kdbx` is simply a widely-supported interchange target.

### Backup & Sync

Clone units stay in sync whenever they can reach each other:
- Connect two KeyMasters directly, USB-to-USB, for a manual sync
- Or leave a backup powered and on your network, plugged into a machine running the helper, or standalone through a USB-C Ethernet adapter (even inside a safe, over a single PoE cable)
- The backup replicates while still **locked**, moving only encrypted data, so it never needs a PIN entered in the safe
- Content-addressed, deduplicated, encrypted replication
- An offline backup simply catches up the moment it's next connected

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

## Why the Market Is Ready

Consumer awareness of digital privacy and personal security has shifted dramatically. What was once a niche concern for security professionals is now a mainstream buying motivation, and the market is responding with real products and real revenue.

**The privacy hardware wave is already here, and the numbers show it:**

- **Privacy phones** are a proven category. Brax Technologies' BraX3 privacy phone raised about $1.9M from 4,855 backers (770% of its goal), and Brax reports 5,500+ units shipped; its follow-up Open Slate tablet raised over $900K from 1,100+ backers. Purism's Librem 5 raised about $2.1M against a $1.5M goal. The Mudita Kompakt, a privacy-focused minimalist phone, more than doubled its Kickstarter goal with €353K from 1,078 backers across 34 countries.
- **Crypto hardware wallets** are an established market, estimated at roughly $350–450M in 2024 and forecast to reach several billion dollars by the early 2030s. Trezor reported a 600% weekly sales spike as Bitcoin approached $100K in late 2024; Ledger reported 2025 as its first year reaching triple-digit-million revenue; Foundation Devices raised a $7M seed (led by Polychain) for its air-gapped Passport wallet. Consumers have proven they will pay a premium for a physical device that keeps secrets off the network.
- **Hardware security keys** (Nitrokey, OnlyKey, YubiKey) have moved from developer curiosity to enterprise procurement. Nitrokey has grown to tens of thousands of users across 120+ countries while remaining independent of venture investors.
- **Security tools** have become mainstream retail products. Flipper Zero raised $4.8M on Kickstarter (on a $60K goal) and has since sold over a million units. Hak5 has been selling penetration-testing hardware since the late 2000s. These are retail businesses, not fringe projects.
- **Privacy routers and home automation** are now retail categories. Products like Home Assistant Yellow (privacy-respecting home automation) sell through platforms like Crowd Supply, which reports a campaign success rate roughly twice that of Kickstarter for open-source hardware.

**The broader privacy technology market confirms the trend.** The global Privacy Enhancing Technologies market is estimated at about $3.2B in 2024 and projected to reach roughly $28B by 2034, a mid-20s-percent CAGR (Market.us, corroborated by Grand View Research). Regulatory pressure (GDPR, CCPA), rising consumer awareness, and IoT proliferation are all accelerating demand. Cybersecurity startup investment surged in 2025 to its strongest year since 2021 (roughly $18B, up 26% year over year, per Crunchbase), and venture firms including Andreessen Horowitz are backing privacy-first companies: Cape, a privacy-focused mobile carrier, has raised $191M, including a $100M round in 2026 at a $900M valuation.

*(Figures are as of early 2026 and drawn from company announcements, crowdfunding pages, and market-research sources; the strongest single data point, the PET market size, is independently corroborated across firms.)*

**What all these products have in common:** each solves one slice of the personal security problem. A hardware wallet protects seed phrases. A security key handles FIDO2. A privacy phone hardens the mobile stack. Users who care about security end up carrying multiple single-purpose devices and managing multiple fragmented workflows.

**What's missing is integration.** No current product unifies credentials, keys, OTP, wallet seeds, and context-aware host behavior in a single device under the user's physical control. KeyMaster is designed for exactly that gap: not by competing with any one of these products, but by consolidating the fragmented workflows they collectively address.

The market has already educated the buyer. The infrastructure of trust (open hardware, transparent security claims, community review) is now expected, not novel. The demand signal is clear and quantified. What remains is execution.

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

## Scope and Honesty

KeyMaster aims to materially improve security and usability, not to claim impossible guarantees. We would rather state our limits plainly than oversell, because a security product that overpromises loses the trust it depends on.

What KeyMaster is designed to do:

- Raise an attacker's cost and uncertainty, so that compromising your secrets is expensive, targeted, and physical rather than cheap and remote.
- Reduce the blast radius during a compromise or coercion, through profile isolation, reduced-exposure profiles, and a device that reveals nothing on an untrusted host.
- Provide backup and recovery paths a normal person can understand and actually use.

What it does not claim:

- It is not proof against a nation-state lab that can attack the silicon directly (see the security spec's threat model). No commercially feasible device is.
- It does not make a weak, reused PIN strong; it makes guessing expensive and finite.
- Its "dead man's switch" and location-secrecy features are safety nets with stated limits, not cryptographic guarantees.

Every claim in these documents is meant to survive scrutiny by a security professional. Where a feature has a limit, the specifications state it.

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

**The scenario:** You're a journalist pursuing a dangerous story. You hide a backup KeyMaster somewhere it can stay powered and reach the network—a friend's house, an office, a closet with an outlet and an ethernet drop (a USB-C Ethernet adapter, or a single PoE cable, makes it a self-contained network node). You configure it: "If I don't unlock my primary device for 7 days, release my story notes to these email addresses. Release my Facebook password to my sister."

**How it could work:** Because the application processor is a full little Linux computer, a powered-and-networked backup runs on its own, keeping its own network time and monitoring check-ins from your primary device via the normal sync protocol. If the deadline passes with no check-in, it releases the designated data—perhaps by emailing encryption keys, posting to a dead drop, or simply unlocking for a designated recipient.

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
