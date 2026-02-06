# KeyMaster – User Guide

This guide describes how KeyMaster works in everyday scenarios. The device is still in design, so specific details may evolve during development.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Daily Use](#daily-use)
3. [Profiles: Separation, Travel, and Duress](#profiles-separation-travel-and-duress)
4. [Backup and Recovery](#backup-and-recovery)
5. [SSH and GPG Keys](#ssh-and-gpg-keys)
6. [Sharing Credentials](#sharing-credentials)
7. [Host Policies](#host-policies)
8. [Accessories](#accessories)
9. [Troubleshooting](#troubleshooting)

---

## Getting Started

### First-Time Setup

KeyMaster is designed to be used as a pair: one primary device you carry, one backup that stays safe. Set up both together.

**Primary device:**

1. **Plug it in** to any USB-C port. The e-paper display shows "Welcome to KeyMaster."

2. **Create your primary profile.** The device prompts you to set a PIN or pattern. Choose something memorable but not easily guessed—this will be your main unlock code.

3. **The device generates your vault.** Encryption keys are created automatically. This takes a few seconds while the display shows "Initializing vault..."

**Backup device (do this now, not later):**

4. **Plug in your second KeyMaster.** It also shows "Welcome to KeyMaster."

5. **Pair it with your primary.** On your primary device, select "Pair backup device." Both devices exchange keys and establish a sync relationship. Your backup gets its own PIN—it doesn't have to match.

6. **Store the backup somewhere safe.** A home safe, a trusted friend's house, a safe deposit box. Whenever both devices are on the same network, they sync automatically. Your backup stays current without you thinking about it.

**Why this matters:** Your KeyMaster holds your entire digital identity. If you lose it without a backup, you lose access to everything. The backup isn't an afterthought—it's half of the system.

**You're ready to use it.** The primary device shows "LOCKED" with a key icon. Enter your PIN to unlock.

### Adding Your First Credentials

With your KeyMaster unlocked and connected to a trusted computer:

**Option A: Import from a password manager**
```
$ km import ~/Downloads/bitwarden_export.json
Importing 147 entries... done.
Created groups: Banking, Social, Shopping, Dev, Personal
```

**Option B: Add entries manually**
```
$ km add
Title: GitHub
URL: https://github.com/login
Username: myusername
Password: [enter or generate]
TOTP secret (optional): [scan QR or enter]
Group: Dev
Entry saved.
```

**Option C: Save as you browse**

With the browser extension installed, visit a login page and click "Save to KeyMaster" when you sign in. The device display will show "Save new entry?" with the site name. Confirm on the device keypad.

---

## Daily Use

### Unlocking Your KeyMaster

1. Plug the device into any USB port
2. The display shows "LOCKED"
3. Enter your PIN on the recessed keypad
4. If correct, the display shows your profile name and "Unlocked"

**Pattern unlock:** Instead of a numeric PIN, you can swipe a pattern across the 12-key pad—similar to Android pattern unlock but on physical keys. The recessed design means nobody can see your pattern from the side.

### Auto-Typing Credentials

When you need to log into a website on an untrusted computer (like a library kiosk or borrowed laptop):

1. Open the login page in the browser
2. On your KeyMaster, navigate to the entry using the keypad
3. Select "Auto-type" and choose what to send:
   - Username only
   - Password only
   - Username + Tab + Password + Enter
4. The device types the credentials as a keyboard

The computer never sees your password database—it just receives keystrokes. A keylogger would only capture this one credential, not your entire vault.

### Copying TOTP Codes

For sites with two-factor authentication:

1. Find the entry on your KeyMaster
2. Select "Show TOTP"
3. The display shows the current 6-digit code and a countdown
4. Option to auto-type the code

Since the TOTP seed lives on your KeyMaster (not your phone), you have 2FA even when your phone is dead or lost.

### Mounting the Vault (Trusted Computers)

On computers you trust, you can mount the vault as a virtual drive:

```
$ km mount ~/vault
Vault mounted at /home/user/vault
```

Now you can browse your credentials like files:
```
~/vault/
  Banking/
    Chase.xml
    CreditUnion.xml
  Dev/
    GitHub.xml
    AWS.xml
  Personal/
    Netflix.xml
```

KeePassXC can open these files directly. Changes save back to your KeyMaster automatically.

To unmount:
```
$ km unmount
```

Or just unplug the device—it unmounts safely.

---

## Profiles: Separation, Travel, and Duress

KeyMaster supports multiple profiles, each with its own unlock pattern and its own view of your vault. This single feature serves many purposes: separating work from personal, reducing exposure while traveling, or providing a decoy under duress.

### How Profiles Work

Each profile has:
- Its own unlock PIN or pattern
- Its own set of visible groups and entries
- Its own encryption keys (cryptographically isolated)

**The key security property:** There is no way to prove that other profiles exist. The encrypted blobs are identical in structure. The device doesn't store a profile count. Someone examining your device cannot distinguish "no more profiles" from "wrong PIN."

### Setting Up Additional Profiles

1. Unlock with your primary profile
2. Settings → Profiles → Add Profile
3. Set a distinct PIN/pattern for the new profile
4. Choose what groups this profile can see:
   - A subset of your real entries (e.g., low-risk accounts only)
   - Decoy entries you create specifically for this profile
   - Or nothing at all
5. Give it a name that makes sense to you (only visible when unlocked)

### When to Use Different Profiles

**Travel:** Before a trip, create a travel profile with only the credentials you'll need—airline, hotel, maybe social media. At border crossings, unlock with your travel PIN. Officials see a functional password manager. Your banking, crypto, and work credentials don't exist as far as they can tell.

**Duress:** If someone coerces you to unlock your device, enter your duress PIN. They see a working vault with plausible content. Your real data remains encrypted and hidden. They cannot prove anything else exists.

**Work/Personal:** Keep work credentials in one profile, personal in another. Your employer never sees your personal accounts. You never accidentally auto-type your personal password into a work system.

**Shared devices:** Family members can each have their own profile on a shared KeyMaster, with access to shared entries (Netflix, WiFi) but not each other's private accounts.

### Tips for Effective Use

- **Use all your profiles occasionally.** A profile with year-old timestamps looks suspicious. Log into a travel account now and then.
- **Make duress profiles plausible.** A few shopping sites, social media, maybe a streaming service. Empty vaults look suspicious.
- **Keep your duress PIN simple.** You may need to enter it under stress.
- **Remember which PIN is which.** Entering your primary PIN when you meant to enter your duress PIN defeats the purpose.

---

## Backup and Recovery

### Why Backups Matter

Your KeyMaster holds your entire digital identity. Without a backup, losing the device means losing access to everything.

### Backup Options

**Option 1: Additional KeyMaster devices (recommended)**

You can have as many KeyMasters as you want, and they all stay in sync automatically:

- **Two devices** (minimum): One you carry, one in a home safe
- **Three devices**: Add one at a trusted friend's house or safe deposit box
- **More**: As many as you need for your peace of mind

Whenever any two devices are on the same network, they sync. By default this works over local networks (USB-Ethernet, WiFi, LAN). If you configure it, devices can sync over the internet too—useful if your backup lives across the country.

**Option 2: Encrypted file backup**

Export an encrypted backup to a USB drive or cloud storage:

```
$ km backup ~/backups/keymaster-2025-09-15.vault
Enter backup password:
Backup complete. Store safely.
```

To restore to a new or wiped KeyMaster:
```
$ km restore ~/backups/keymaster-2025-09-15.vault
Enter backup password:
Restore complete. 147 entries recovered.
```

This is a snapshot, not a live sync. Good for archival, but a backup KeyMaster is better for day-to-day protection.

### How Sync Works

When multiple KeyMasters are on the same network:

1. Connect your primary to a computer
2. Your backup (on the same network) detects it via mDNS
3. They compare vault hashes
4. Missing entries sync in both directions
5. Status LED shows sync activity

No cloud required. No internet required. Just two KeyMasters on the same local network.

### What Syncs

- All entries and attachments
- Groups and organization
- Profiles and their configurations
- Host policies

What doesn't sync:
- Device-specific settings (display brightness, etc.)
- PIN/pattern codes (each device has its own)

---

## SSH and GPG Keys

### Storing SSH Keys

You can store SSH private keys on your KeyMaster:

```
$ km ssh-import ~/.ssh/id_ed25519
Enter key passphrase:
Key imported: SHA256:abc123...
```

The key is now encrypted in your vault. Your `~/.ssh/id_ed25519` can be deleted from the host.

### Using SSH with KeyMaster

**Method 1: SSH Agent**

```
$ km ssh-agent start
SSH agent listening on /run/user/1000/keymaster.sock
$ export SSH_AUTH_SOCK=/run/user/1000/keymaster.sock
$ ssh user@server
```

The KeyMaster acts as an SSH agent. When SSH requests a signature, the device display shows "SSH sign: user@server?" and you confirm on the keypad.

**Method 2: PKCS#11**

```
$ ssh -I /usr/lib/keymaster-pkcs11.so user@server
```

The SSH client talks to your KeyMaster via the PKCS#11 interface.

### GPG Keys

Similarly for GPG:

```
$ km gpg-import ~/private-key.asc
$ km gpg-agent start
$ export GNUPGHOME=/run/user/1000/keymaster-gpg
$ gpg --sign document.txt
```

Your KeyMaster confirms signing operations on the display.

### Smart Card Emulation

Your KeyMaster emulates an OpenPGP smart card via USB CCID:

- No special drivers needed
- Works with standard `gpg-agent` and `ssh-agent`
- Works on locked-down corporate machines that only allow smart cards

---

## Sharing Credentials

### Sharing with Family

Create a shared group that family members can access:

1. Primary device: Create group "Family Shared"
2. Add entries: Netflix, WiFi password, streaming services
3. Set group permissions: Allow profiles "personal" and "spouse"

On your spouse's KeyMaster:
1. Pair devices (one-time setup)
2. Sync
3. Spouse's profile now sees the "Family Shared" group

Each person has their own PIN. Neither can see the other's private entries.

### Temporary Sharing

Need to share a password once?

1. Find the entry
2. Select "Generate share link"
3. Display shows QR code valid for 10 minutes
4. Other person scans with KeyMaster app
5. They receive the credential (one-time)

No cloud. No email. Direct device-to-device via QR.

### Team Workspaces

For small teams, you can set up a shared vault:

1. Create a "Work" profile on all team devices
2. Sync via office network
3. Shared credentials accessible to all
4. Personal profiles remain private

---

## Host Policies

### What Are Host Policies?

Your KeyMaster remembers computers you've used it with and can apply different rules to each:

- **Home desktop:** Full access, mount vault, sync enabled
- **Work laptop:** Limited groups, no mounting, auto-type only
- **Unknown/untrusted:** CCID and HID only, no storage access

### Configuring Host Policies

When you plug into a new computer:

1. Display shows: "New host detected: [hostname]"
2. You choose trust level:
   - **Full trust:** All functions
   - **Limited:** No vault mounting
   - **Minimal:** Auto-type only
   - **Deny:** No access

The device remembers this host by its fingerprint.

### Automatic Mode Selection

Based on host trust level, your KeyMaster automatically:

| Host Trust | USB Functions | Vault Access |
|------------|---------------|--------------|
| Full | All | Mount filesystem |
| Limited | CCID + HID + Ethernet | Web UI only |
| Minimal | CCID + HID only | None |
| Unknown | CCID + HID only | None (prompt to register) |

You never have to think about it—plug in and the device adapts.

---

## Accessories

KeyMaster is designed to be self-contained, but a few accessories can make incorporating it into your daily life significantly easier.

### Smart Card Adapter (roadmap)

A dedicated smart card adapter is planned for future release. This is essentially a standard smart card form factor with a USB-C port—you plug your KeyMaster into the adapter, and the adapter plugs into any smart card reader.

**How it works:**

1. Insert the adapter into a standard smart card reader (ISO 7816)
2. Connect your KeyMaster to the adapter's USB-C port
3. KeyMaster enters low-power mode, drawing power from the smart card reader
4. The device fully emulates a smart card—indistinguishable from a traditional PIV/OpenPGP card

**Why this matters:**

- **Corporate environments:** Many organizations require smart card authentication. The adapter lets KeyMaster work with existing card readers and badge slots without special drivers or IT approval.
- **Legacy systems:** ATMs, government kiosks, and older authentication systems that only support smart cards.
- **Power independence:** The smart card reader provides power, so KeyMaster works even on systems without available USB ports.

The adapter is passive—it simply bridges the USB interface to smart card contacts. All cryptographic operations still happen on your KeyMaster, with confirmation on the e-paper display and PIN entry on the recessed keypad.

### Cable Management Accessories (roadmap)

If you're using KeyMaster daily—unlocking your phone, authenticating at coffee shop Wi-Fi, signing into shared computers—you'll want a "quick-draw" solution. Fumbling with a loose cable every time defeats the purpose of having credentials at your fingertips.

**Considerations for everyday carry:**

- **Retractable cables:** A self-winding USB-C cable that clips to your keychain, belt loop, inside your coat or vest.  Pull to extend, release to retract. Look for cables rated for data (not charge-only) with a compact housing.
- **Lanyard mounts:** A short (6-8 inch) cable permanently attached to a lanyard or badge reel. KeyMaster stays in your pocket; pull it out, plug in, authenticate, let it retract.
- **Jacket/bag integration:** A cable routed through an inner pocket with the connector accessible at the cuff or an external port. Your KeyMaster lives in the pocket; the cable is always ready.

**What to look for:**

- USB-C cables that support data transfer (many retractable cables are charge-only)
- Durable strain relief at both ends
- Compact, low-snag housings
- Quick-release clips if you need to detach

We don't manufacture cables, but we're evaluating partnerships with accessory makers to offer tested, recommended options. In the meantime, any quality retractable USB-C data cable will work.

**The goal:** KeyMaster should be as accessible as your house keys. The best cable setup is the one you'll actually use every day without thinking about it.

---

## Troubleshooting

### "Device not recognized"

1. Try a different USB port (directly on computer, not through a hub)
2. Check the display—is it showing "LOCKED" or an error?
3. Try a different USB-C cable (some cables are charge-only)

### "Wrong PIN" on a correct PIN

1. Make sure you're entering the right profile's PIN
2. Check if Caps Lock affected a previous entry
3. Wait for any rate-limiting delay to expire
4. Try pattern mode if you set one up

### "Vault corrupted" warning

1. Don't panic—this usually means minor index damage
2. Connect to a trusted computer
3. Run `km repair` to rebuild the index
4. If that fails, restore from backup

### Forgotten PIN

If you've forgotten your PIN and have no backup:
1. After too many wrong attempts, the device locks permanently
2. A factory reset erases the vault (this is by design)
3. This is why backups are critical

If you have a backup KeyMaster or recovery kit:
1. Factory reset the locked device
2. Restore from backup
3. Set a new PIN

### Device won't boot

1. Try a different USB port with known-good power
2. Hold the top-left keypad button while plugging in (recovery mode)
3. Display should show "Recovery Mode"
4. Connect to computer and run `km recover`

### Sync not working

1. Check both devices are on the same network
2. Verify both are unlocked with profiles that can see the shared content
3. Check firewall isn't blocking mDNS (port 5353) or sync port (TBD)
4. Try manual sync: `km sync --target=192.168.1.x`

---

## Quick Reference

### Keypad Navigation

| Key | Function |
|-----|----------|
| 1-9 | PIN entry / menu selection |
| * | Back / Cancel |
| 0 | Confirm / Enter |
| # | Options / Menu |

### Display Icons

| Icon | Meaning |
|------|---------|
| 🔒 | Locked |
| 🔓 | Unlocked |
| ⟳ | Syncing |
| ⚠ | Warning/error |
| ✓ | Success |
| ⌨ | Auto-typing |

### LED Indicators

| Color | Meaning |
|-------|---------|
| Off | Powered down |
| Blue pulse | Standby / locked |
| Green solid | Unlocked |
| Green blink | Activity (typing, syncing) |
| Red blink | Error / tamper |

---

## Getting Help

**This is a conceptual guide for a device still in development.** If you're interested in contributing to KeyMaster—hardware design, firmware, host software, or documentation—see the main README for how to get involved.

For questions about the design or feature requests, open an issue on the GitHub repository.
