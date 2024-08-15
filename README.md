# Key Master
(open to better names)

Personal Hardware Password Vault / Security Key

## The Problem

Digital authentication is increasingly important today, and changing fast.  We are each required to maintain various credentials, keys, certificates, question/answer pairs, and more, both personal, and for various organizations, to the point where some kind of management tool is absolutely essential.

Password managers are an important piece of the solution, and can be very convenient with plugins and graphical user interfaces, but sharing a password vault across devices can be inconvenient and introduce attack vectors, or use some service where a third party is being trusted with all your passwords.  Furthermore, on public or untrusted hosts without access to install software, one may also need to authenticate or access some passwords as securely as possible.

Even with a password vault, wherever it is stored, it must of course be encrypted, and some kind of password or PIN must be used to unlock it.  However, in many use cases, even on trusted hardware, these credentials are at risk of interception.  Consider a hardware or software keylogger, or a security camera recording you enter your PIN.

There are, of course, many attempts to solve these problems, which I will not bother to enumerate here, but the one which comes closest is the [OnlyKey](https://onlykey.io/), by [CryptoTrust, LLC](https://crp.to/).  This hardware device is the conceptual foundation of the currently proposed device, adding some critical missing features.

## The Device

The proposal in question is an open source hardware device, small and flat, approximately one inches by two inches, as rugged and waterproof as possible.  Internally, the device is relatively simple, including storage devices, encryption chips, a powerful enough processor to run it all, and some robust firmware.  Externally it has the following main features:

- a twelve-key pad of capacitance buttons

Similar to the six-key pad on the OnlyKey, this device would have capacitance buttons used to unlock with a PIN and navigate once unlocked, slightly inset so they can be operated by touch, and more of them, allowing for a much wider variety of codes (which can also be thought of as patterns).  While this does make the unit slightly larger, I think this is a good thing, making it a bit easier to hold and use, and harder to misplace.

- an e-ink display and LED light

Once the user has unlocked the device with their PIN, there are many potential actions you might wish to take.  The buttons can be used to navigate these options, while the display, located on the opposite side of the device from the buttons, is used to indicate which buttons will do what actions.  It can also be used to do some configuration, show user data, display a bar-code, or whatever else.  The LED is used in conjunction with the display to indicate various states in various modes.

- a USB-C port (*female*)

This essential feature is intended to solve the problem of visibility when typing in your PIN.  Rather than a plug (male), which you plug in directly to a computer, the female port is intended to always be connected via a regular USB cable.  This way, you have more flexibility to type your PIN in a more secure arrangement, such as inside your coat, under your shirt, in your pocket, etc.

This also simplifies the use of adapters, allowing this device to connect to whatever devices you have, such as workstations, phones, or even have adapters for smart-card readers or network ports.  In either case, of course even with a plug, extension USB cords are an option, but this clarifies the intention and allows the use of common cords.

## Basic Usage

Since this device contains no battery, it is used by plugging it into some host machine.  This could be a desktop or laptop computer, a mobile phone, or even perhaps a smart card reader via an adapter.  When the device is inserted and powers up, it must be unlocked with a pattern.  It could support several profiles (personal and work, for example), a dummy code, a code to wipe the device if entered, and a feature to wipe the device if too many wrong codes are entered.

Once unlocked, a small storage device could be made available to be mounted by the host system, which contains the password vault to be then accessed directly by your password manager.  This could be configured so that it is only available on trusted hosts, and on untrusted hosts could remain encrypted and hidden.  There could even be an additional storage device which is only accessible on trusted hosts after a passphrase has been entered, intended as storage for a master GPG key or the like.

When on untrusted devices, without the password vault mounted, some configured passwords can still be made available to be typed in directly by the device, which emulates a keyboard and types your passwords, using the auto-type pattern stored in that entry in your password vault.  These credentials can be browsed and selected by using menus on the display of the device, navigated by touch on the buttons on the underside.

Additionally, it can be configured to emulate a smart card reader, and various MFA security keys, to be able to operate as various types of access, authentication, and security cards, allowing further consolidation of credentials into this one device across all the services and hosts one uses.

Of course, when all of one's secure data is on one unit, that data must be backed up.  So this device must include a very easy *backup mode*.  When unlocked, and put into backup mode, it will automatically synchronize when the active unit is available, either plugged into the same host, or even potentially over a network.  This device could even support emulating a network device, and be plugged directly into a POE ethernet port, acting as a network available backup without a host machine.

## Application Software

There is much existing excellent open source software that we can build off, perhaps implementing the configuration of the device and management of the password vault into a program like KeePassXC, rolling out just what we need to, and not re-inventing any wheels.

## Some Examples

You're on the road and sit down to your laptop at a cafe, you open it up and plug in your Key Master with a regular USB cable.  Under your coat or your hat you type in your pattern by touch on the buttons and the device unlocks.  It sees that you are on a trusted device, and shows you appropriate options, including typing in your password to log into the machine, or authenticating as a smart card.  Once logged in, it mounts your password vault and loads your password manager, conveniently entering your passwords into websites with that program's plugins.

When you're back at the hotel, you again plug your Key Master into your laptop and unlock it, perhaps under the covers if you're paranoid of hidden cameras.  You log into Netflix easily via the browser plugin, but your password has expired, and it insists you must change it.  You autogenerate a new password in your password manager and save it to the vault on your key.  Your backup Key Master is at home, plugged into your computer, or perhaps into a network port in your basement (maybe you even have a safe with an ethernet port inside it).  You have your laptop configured to establish an encrypted tunnel to your backup key at home, keeping it in sync with your active key.  Perhaps in addition to your home backup key, you pull your backup travel key out of your hat and plug it in after changing your password, and it automatically syncs with the others.  The LED light on it and e-ink display confirm that it's in sync, and you tuck it back in your hat.

---

Even your phone can be authenticated by the Master Key, which is configured to allow only a limited set of your passwords on this device.  You've configured your phone password manager to cache a subset of these available passwords in memory, so that you don't have to always have your Key Master plugged in, unless you want to access your bank account or some other sensitive service.  So as soon as you've unlocked the phone, you unplug the key from your phone, and use it as normal, until the screen locks at your configured interval, and it needs to be unlocked again.

---

You're at a friends house using their computer.  You plug your Master Key in and unlock it under the table, and since this is not a configured trusted device, it does not mount the storage drive with your password vault.  Instead, you are presented with the passwords you might need, listed on the menu on the device, which you can scroll through and select as needed.  They are then auto-typed according to the pattern stored with that entry in your password vault.

---

You work for a company with extremely high security, with smart-card readers at the entrances.  When you arrive, you plug your company-issued Key Master into the smart-card reader with an adapter cable you carry for the purpose, and enter your PIN on your Key Master in the provided box for your hand, or under your coat.  Guests are given smart-cards, which must be unlocked with a code typed into buttons on the card itself, the slot for which is inside a box to hide your hand while you type your PIN.  These guest cards have only a single key on them, but you use your Master Key for much more.

When you get to your desk, you plug your Key Master into your workstation and unlock it under your desk.  Your workstation is recognized, the smart card protocol is used to authenticate automatically, and you're logged in.  Your password manager has even loaded your SSH keys into the agent, and you're able to SSH without any hassle, without the keys ever being written to your workstation drive.  When you get up to use the restroom, you're expected to unplug the device and take it with you.  As soon as the device is unplugged, your workstation is configured to immediately lock and wipe your passwords from memory.

## Summary

Such a device as described could be a much-needed foundation to an accessible digital security for individuals and organizations alike, simplifying and securing peoples digital lives, a need which no other device available today quite meets.  It's very design would intentionally foster good security practices and habits, and be as convenient as possible.
