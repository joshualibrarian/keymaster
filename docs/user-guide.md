# KeyMaster – User Guide

This guide describes how KeyMaster works in everyday scenarios. The device is still in design, so specific details may evolve during development.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Daily Use](#daily-use)
3. [Profiles: Separation, Travel, and Duress](#profiles-separation-travel-and-duress)
4. [Backup and Recovery](#backup-and-recovery)
5. [SSH and GPG Keys](#ssh-and-gpg-keys)
6. [Passkeys & Two-Factor](#passkeys--two-factor)
7. [Sharing Credentials](#sharing-credentials)
8. [Host Policies](#host-policies)
9. [Accessories](#accessories)
10. [Troubleshooting](#troubleshooting)

---

## Getting Started

### First-Time Setup

KeyMaster is designed to be used as a pair: one primary device you carry, one backup that stays safe. Set up both together.

**Primary device:**

1. **Plug it in** to any USB-C port. The e-paper display shows "Welcome to KeyMaster."

2. **Create your primary profile.** The device prompts you to set a PIN or pattern. Choose something memorable but not easily guessed. This will be your main unlock code.

3. **The device generates your vault.** Encryption keys are created automatically. This takes a few seconds while the display shows "Initializing vault..."

**Backup device (do this now, not later):**

4. **Plug in your second KeyMaster.** It also shows "Welcome to KeyMaster."

5. **Pair it with your primary.** Plug the two KeyMasters into each other with a USB-C cable and select "Pair backup device" on your primary. They exchange keys directly over that connection, with no camera or app needed. Both devices show a short confirmation code; check that they match and confirm on each keypad. Your backup gets its own PIN, which doesn't have to match.

6. **Store the backup somewhere safe.** A home safe, a trusted friend's house, a safe deposit box. Your backup stays current by syncing whenever it's powered and connected. See [Backup and Recovery](#backup-and-recovery) for the ways to keep it in sync, including leaving it plugged in at home so it updates on its own.

**Why this matters:** Your KeyMaster holds your entire digital identity. If you lose it without a backup, you lose access to everything. The backup isn't an afterthought; it's half of the system.

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
TOTP secret (optional): [paste secret, or scan the site's QR with your phone]
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

**Pattern unlock:** Instead of a numeric PIN, you can swipe a pattern across the 12-key pad, similar to Android pattern unlock but on physical keys. The recessed design means nobody can see your pattern from the side.

**Haptic confirmation:** KeyMaster can give a light tap each time a key press registers, which makes entering your PIN by feel, in a pocket or under a table, far more reliable when you can't watch the display. You can adjust how strong it is or turn it off completely. Because a tap makes a faint sound and vibration, there is also a silent mode you can switch on before unlocking for situations where you want no feedback at all; the device can't tell a duress unlock from a normal one until after you've entered it, so silencing is something you choose, not something it guesses.

### Auto-Typing Credentials

When you need to log into a website on an untrusted computer (like a library kiosk or borrowed laptop):

1. Open the login page in the browser
2. On your KeyMaster, navigate to the entry using the keypad
3. Select "Auto-type" and choose what to send:
   - Username only
   - Password only
   - Username + Tab + Password + Enter
4. The device types the credentials as a keyboard

The computer never sees your password database. It just receives keystrokes. A keylogger would only capture this one credential, not your entire vault.

### Copying TOTP Codes

For sites with two-factor authentication:

1. Find the entry on your KeyMaster
2. Select "Show TOTP"
3. The display shows the current 6-digit code and a countdown
4. Option to auto-type the code

Since the TOTP seed lives on your KeyMaster (not your phone), you have 2FA even when your phone is dead or lost.

**How the device keeps time:** Time-based codes need an accurate clock, and KeyMaster has no battery, so it keeps time with a small energy reserve (a supercapacitor) that holds the clock through everyday gaps between uses, for weeks at a stretch. Whenever it's connected to a computer or the network, it quietly refreshes its clock from the most trustworthy source available. If a KeyMaster has been sitting unused for a very long time and its clock has drifted, it will ask you to confirm the current time once (just read it off your phone or watch), and then it's good again.

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

These entries export cleanly to the KeePass `.kdbx` format, so you can open a copy of your vault in a KeePass-family app if you prefer its interface: KeePassXC on the desktop, or KeePassDX / KeePassium and others on your phone. Changes made through the mounted vault save back to your KeyMaster automatically, encrypted on the device.

To unmount:
```
$ km unmount
```

Or just unplug the device; it unmounts safely.

---

## Profiles: Separation, Travel, and Duress

KeyMaster supports multiple profiles, each with its own unlock pattern and its own view of your vault. This single feature serves many purposes: separating work from personal, reducing exposure while traveling, or providing a decoy under duress.

### How Profiles Work

Each profile has:
- Its own unlock PIN or pattern
- Its own set of visible groups and entries
- Its own encryption keys (cryptographically isolated)

**The key security property:** There is no way to prove that other profiles exist. You can create as many as you like, and the device never records how many there are: every profile's data is stored as the same kind of anonymous encrypted block, mixed together with random filler. Someone examining your device cannot distinguish "no more profiles" from "wrong PIN," and cannot count them.

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

**Travel:** Before a trip, create a travel profile with only the credentials you'll need: airline, hotel, maybe social media. At border crossings, unlock with your travel PIN. Officials see a functional password manager. Your banking, crypto, and work credentials don't exist as far as they can tell.

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

You can have as many KeyMasters as you want, and they keep each other in sync whenever they can reach one another:

- **Two devices** (minimum): One you carry, one in a home safe
- **Three devices**: Add one at a trusted friend's house or safe deposit box
- **More**: As many as you need for your peace of mind

A backup only syncs while it's **powered and connected**, since it has no battery and no wireless radio, so it isn't "always on" in a drawer. There are three easy ways to connect it, and you pick whichever fits:

- **Plug the two devices together.** Connect your primary and backup with a USB-C cable and they sync directly. Simplest, no network involved.
- **Leave the backup plugged into a home computer.** With the small KeyMaster helper app running on that computer, the backup stays reachable on your network and syncs in the background whenever your primary is connected. If you set it up, this can even work over the internet, so a backup across the country stays current.
- **Give the backup its own network connection.** With an inexpensive USB-C–to–Ethernet adapter (and power), a backup can sit on your network by itself, no computer required. This is the setup for a backup that lives in a safe: run power and a network cable in (or a single Power-over-Ethernet cable), and it quietly keeps itself current.

However you connect it, an offline backup simply catches up the moment it's next plugged in. You never have to remember to "make a backup," because it's already made.

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

When two of your KeyMasters can reach each other (plugged together, or both on the network via the helper or an Ethernet adapter):

1. They discover each other and open a mutually authenticated, encrypted connection, and each device proves it's really one of yours.
2. They compare what they hold without revealing it.
3. Missing changes copy in both directions, always as encrypted data.
4. The status LED shows sync activity.

No cloud service sits in the middle, and by default nothing leaves your local network. A backup can even sync while it stays **locked**, and never needs to be unlocked to receive updates, which is what lets one live safely in a sealed safe.

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

## Passkeys & Two-Factor

### Passkeys (FIDO2)

KeyMaster is a full passkey device, the same kind of "sign in without a password" credential that banks, Google, Microsoft, and a growing list of sites now support. To the website, it looks like any other security key.

**What makes passkeys different from passwords:** a passkey isn't a secret you hand over. It's a private key that never leaves your KeyMaster. When you sign in, the website sends a challenge, your KeyMaster signs it on-device (you confirm with a touch), and only the signature goes back. Nothing reusable is ever transmitted, and your KeyMaster refuses to sign for a look-alike phishing site, so passkeys can't be phished or replayed.

**Using a passkey:**

1. On a site's "sign in with a passkey" or "add a security key" prompt, plug in your KeyMaster.
2. The display shows the site name and asks you to confirm.
3. Touch to approve. You're in.

Because this runs on the always-on secure core, it works even on an untrusted, locked-down computer: the machine only ever sees a signature, never your vault.

**The KeyMaster difference: your passkeys are backed up.** On a phone or a typical security key, a passkey is trapped on that one device; lose it and you can be locked out. On KeyMaster, each passkey is stored in your vault like any other entry, so it syncs to your backup and rides along to any of your paired devices. Your passkeys are as recoverable as the rest of your credentials.

### Two-Factor Codes (TOTP)

For sites that use six-digit authenticator codes, KeyMaster stores the TOTP seeds and shows or auto-types the current code; see [Copying TOTP Codes](#copying-totp-codes) under Daily Use. Keeping these on your KeyMaster means you still have your second factor even if your phone is lost or dead.

---

## Sharing Credentials

### How Sharing Works

Sharing on KeyMaster is built on each profile having its own key pair, like a personal padlock and matching key. To share an entry with someone, you lock a copy of it with **their** padlock; only they can open it. You never expose your vault, and there's no shared account or cloud in the middle.

For this to work, you first exchange padlocks, a one-time **pairing** with each person you'll share with. You keep their public "padlock" privately in your own vault as a contact; nothing about who you can share with is ever published anywhere.

**Pairing with someone (one-time):**

- **They have a KeyMaster:** plug the two devices together with a USB-C cable, or connect over your network. Both displays show a short confirmation code; check they match and confirm on each keypad. Done.
- **Reference:** the same private key exchange underpins backup pairing; see [First-Time Setup](#first-time-setup).

### Sharing with Family

Once you've paired:

1. Create a shared group, e.g. "Family Shared."
2. Add entries: Netflix, WiFi password, streaming services.
3. Add your spouse (a paired contact) as a recipient on the group.

Those entries now sync to your spouse's KeyMaster, sealed so only their profile can open them. Each person has their own PIN. Neither can see the other's private entries—only the ones explicitly shared.

### Sending a Credential

To hand a single credential to a paired contact:

1. Find the entry and choose "Share."
2. Pick the contact.
3. Confirm on the keypad.

KeyMaster seals that entry to the recipient's key and delivers it whenever their device is next reachable, over your sync network or, because it's sealed and unreadable in transit, even via an ordinary relay. The two of you don't have to be online at the same moment. No cloud account, no plaintext ever exposed.

For a quick one-time handoff to someone **without** a KeyMaster, the device can display a short-lived QR code that their phone's authenticator or the KeyMaster phone app reads. (KeyMaster shows QR codes but doesn't have a camera to read them, so device-to-device sharing uses the pairing and send flow above rather than scanning.)

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

### Safe by default

A plain USB connection doesn't tell KeyMaster anything trustworthy about the computer it's plugged into, so KeyMaster's default on **any** machine it can't positively recognize is its most cautious mode: smart-card, keyboard auto-type, and passkey only, with no storage exposed. A borrowed laptop or public kiosk gets exactly this, automatically, with no setup.

### Recognizing your own computers

A computer becomes "known" when it runs the small KeyMaster helper app and you've authorized it. The helper identifies the machine to your device, so on your own computers KeyMaster can safely relax to the level you chose:

1. The first time you run the helper on a computer, your device asks you to authorize it and pick a trust level:
   - **Full trust:** All functions, including mounting the vault
   - **Limited:** Credentials and web management, no vault mount
   - **Minimal:** Auto-type and smart-card only
   - **Deny:** Nothing

2. Your device remembers that computer and applies the same policy next time.

### What each level allows

| Host trust | USB functions | Vault access |
|------------|---------------|--------------|
| Full (authorized) | All | Mount filesystem |
| Limited (authorized) | Smart card + keyboard + network | Web management only |
| Minimal (authorized) | Smart card + keyboard + passkey | None |
| Unknown (default) | Smart card + keyboard + passkey | None |

You never have to think about it on the road: an unrecognized machine only ever gets the safe default, and your own machines relax only because you told them to.

---

## Accessories

KeyMaster is designed to be self-contained, but a few accessories can make incorporating it into your daily life significantly easier.

### Smart Card Adapter (roadmap)

A dedicated smart card adapter is planned for future release. This is essentially a standard smart card form factor with a USB-C port. You plug your KeyMaster into the adapter, and the adapter plugs into any smart card reader.

**How it works:**

1. Insert the adapter into a standard smart card reader (ISO 7816)
2. Connect your KeyMaster to the adapter's USB-C port
3. KeyMaster enters low-power mode, drawing power from the smart card reader
4. The device fully emulates a smart card, indistinguishable from a traditional PIV/OpenPGP card

**Why this matters:**

- **Corporate environments:** Many organizations require smart card authentication. The adapter lets KeyMaster work with existing card readers and badge slots without special drivers or IT approval.
- **Legacy systems:** ATMs, government kiosks, and older authentication systems that only support smart cards.
- **Power independence:** The smart card reader provides power, so KeyMaster works even on systems without available USB ports.

The adapter is a simple bridge: it converts between the USB interface and the smart card's contacts and carries no secrets of its own. All cryptographic operations still happen on your KeyMaster, with confirmation on the e-paper display and PIN entry on the recessed keypad.

### Cable Management Accessories (roadmap)

If you're using KeyMaster daily (unlocking your phone, authenticating at coffee shop Wi-Fi, signing into shared computers), you'll want a "quick-draw" solution. Fumbling with a loose cable every time defeats the purpose of having credentials at your fingertips.

**Considerations for everyday carry:**

- **Retractable cables:** A self-winding USB-C cable that clips to your keychain, belt loop, inside your coat or vest. Pull to extend, release to retract. Look for cables rated for data (not charge-only) with a compact housing.
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
2. Check the display: is it showing "LOCKED" or an error?
3. Try a different USB-C cable (some cables are charge-only)

### "Wrong PIN" on a correct PIN

1. Make sure you're entering the right profile's PIN (each profile has its own)
2. Enter it as a deliberate sequence of touches, since rushing can drop or double a key
3. Wait for any rate-limiting delay to expire before trying again
4. If you unlock by pattern rather than digits, trace it the same way you set it

**Careful here:** repeated wrong attempts count toward the device's self-wipe limit. If you're not sure of the PIN, stop and grab your backup rather than burning guesses. See [Forgotten PIN](#forgotten-pin).

### "Vault corrupted" warning

1. Don't panic; this usually means minor index damage
2. Connect to a trusted computer
3. Run `km repair` to rebuild the index
4. If that fails, restore from backup

### Forgotten PIN

KeyMaster is deliberately built to protect your secrets against someone who has the device but not the PIN, so after too many wrong guesses it **wipes itself**, destroying the keys rather than letting anyone keep guessing. There's no backdoor, by design.

That sounds drastic, but it's safe **because your data lives in more than one place.** A wiped or lost device is an inconvenience, not a catastrophe:

1. Take out your backup KeyMaster—it has everything, current as of its last sync.
2. Order a replacement and pair it as your new backup.
3. Carry on.

**If you set up recovery shares** (Shamir social recovery), you can rebuild your vault onto a fresh device even if every KeyMaster is gone, by gathering enough of your shares from the trusted people or places you left them with. See the [Backup and Recovery](#backup-and-recovery) section.

**If you have neither a backup nor recovery shares,** a forgotten PIN means the vault is unrecoverable. This is why KeyMaster ships as a pair and why setting up a backup during first-time setup isn't optional, it's half the system.

### "Tamper detected"

KeyMaster is designed to destroy its secrets if someone tries to physically break into it. If your device reports a tamper event after a hard knock or extreme conditions rather than an actual break-in, treat it like a wiped device: switch to your backup and replace the unit. Your data is safe on the backup; the device that tripped is just being cautious on your behalf.

### Device won't boot

1. Try a different USB port with known-good power
2. Hold the top-left keypad button while plugging in (recovery mode)
3. Display should show "Recovery Mode"
4. Connect to computer and run `km recover`

### Sync not working

1. Confirm the backup is actually powered and connected: plugged into the other device, into a computer running the helper, or onto the network via its Ethernet adapter
2. If syncing over the network, make sure the KeyMaster helper is running on the computer the backup is attached to
3. Check a firewall isn't blocking local discovery (mDNS, port 5353) or the sync port
4. Try connecting the two devices directly with a USB-C cable, the simplest path, no network involved
5. Try a manual sync: `km sync --target=192.168.1.x`

---

## Quick Reference

### Keypad Navigation

During **PIN / pattern entry**, all 12 keys are input symbols, so your unlock code can use any of them, in any length. The roles below apply while **navigating menus**, not while entering your code (so your PIN is never limited to a subset of keys).

| Key | Function (in menus) |
|-----|----------|
| 0-9 | Menu selection / digit entry |
| * | Back / Cancel |
| # | Confirm / Options (submit a completed PIN) |

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

**This is a conceptual guide for a device still in development.** If you're interested in contributing to KeyMaster (hardware design, firmware, host software, or documentation), see the main README for how to get involved.

For questions about the design or feature requests, open an issue on the GitHub repository.
