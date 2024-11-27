# KeyMaster

(open to better names)
Is *KeeMaster* better?
Perhaps *vault*, *KeyVault*, *KeeVault*?
*OpenVault* is pleasantly oxy-moronic?

Personal Data Vault

## Brief Overview

This proposed hardware device has elements from several which exist on the market, notably the [OnlyKey](https://onlykey.io/), and the [Armory](https://www.crowdsupply.com/f-secure/usb-armory-mk-ii), but has several important design features which are about making the device flexible and easy to incorporate into people's actual lives and digital processes.  It can be used with any host and once unlocked gives you secure access to all your keys and passwords, and even all your personal data.  It has a robust backup system and can even be configured to bequeath your data to specified persons after your death.

## Introduction

There is a tremendous need for digital security today and solutions are fragmented.  I present herein this vision for an open source hardware data vault, which can be used to store ALL of one's private keys, passwords, and anything else, as securely and ***conveniently*** as possible.  Coupled with good software integration, this device could form the foundation of an open source security culture, secure authentication, communication, and even the old lingering dream of a functional [web of trust](https://www.weboftrust.info/).

## The Problem

The average modern person must keep track of some dozens and growing authentication data such as passwords, encryption keys, TOTP keys, cryptocurrency, passwords, question / answer pairs, certificates, and more.  Some management tool for this is clearly required.   

Common good advice is to use a *password manager*, a program running on your workstation or mobile device which can secure your passwords in an encrypted vault file to be accessed for website forms or SSH sessions, crypto transactions, or whatever else.  The open source [KeePass](https://keepassxc.org/) family of software has made this fairly robust, with many users synchronizing their vaults over the internet to multiple devices.

While this solution is fairly convenient, and is almost sufficient, there are several important reasons why it does not account for every use case, and critically fails to support good security culture:

### Host Login

If your password vault is stored on your computer, then you need to get into your computer in order to access it.  This, then necessitates remembering yet another password for each host, in addition to the master password for your password vault.  Quickly the notion of remembering only a single strong code falls apart.

### Master Password Vulnerability

When it comes time to unlock your software password vault, you usually do so on a keyboard.  When you're at home on your desktop, you may trust your workstation, that's pretty safe.  But on other, less trusted hosts, or in less trusted locations, you may still need access to some of your passwords, which may be hard if they are at home on your device.  Even then, when you enter your master password to unlock your vault, you may be vulnerable to keyloggers, malware, or even cameras which may record your password as you type it, just like when you type your credit card PIN at the gas pump or the grocery store.

### Synchronization Between Devices

If you must access your password vault on multiple devices, you must synchronize between them somehow.  That usually means over a network, which entails any number of opportunities to open attack vectors to compromise your (albeit encrypted) vault.  This may be acceptable in most cases, but it would be nice to have a convenient mechanism for synchronizing our key vaults locally.

## Attempts at a Solution

There are, of course, many attempts to solve these problems, aside from the aforementioned software password managers, and this leads us to hardware storage vaults of various kinds, of which there are many.

Some call themselves *hardware password managers* such as the [OnlyKey](https://onlykey.io/), the [Armory](https://www.crowdsupply.com/f-secure/usb-armory-mk-ii), and the [Signet](https://www.crowdsupply.com/nth-dimension/signet-high-capacity).  They usually enter passwords by emulating keyboards and typing them in.  This is secure and usually effective, but can be a bit clunky, and somewhat less convenient than using plugins that query your password database and autofill forms, such as with a good software password manager.

Others call themselves *cold crypto wallets*, such as the [Trezor](https://trezor.io/), the [Keystone](https://keyst.one/), and a slew of others.  They may do a fine job of storing specific crypto private keys and help you back up those keys, but that's usually all they do.  Their accompanying software is focused on connecting you to cryptocurrency exchanges and related services, but rarely do they help you manage your passwords, your SSH keys, your PGP keys, and the rest.

## The Proposed Device

The solution presented here is a hardware device, much like those referenced.  By leveraging features of each, and integrating well with existing password managers, we can create a device and usage pattern that is both secure and can fit reasonably into one's real life.

This proposed device is open source, small and flat, measuring approximately ***two inches by three inches***, and thick enough to have USB-C ports along the edge.  It is tamper-resistant, and has a metal case, being as durable and waterproof as possible.  It contains the following broad exterior features.

### USB-C Ports

While many similar small devices have a USB plug (male), this device has two USB-C ports (female) along it's edge.  Each of these function identically, being able to supply power to the device from a host machine.  When both are used simultaneously, the device acts as a USB hub and the other devices function normally.  In the case of a mobile host, this allows you to charge your phone while using this device, a likely common scenario.

This feature is also essential to the goal of security, as with only receptacles on the device, it's usually on the end of a cord, and so easier to operate in locations which are safer for entering your code.  Having two ports also means that if one is damaged, the other may still be used.

To keep this device as simple and secure as possible, no wireless communication options are included, so it's usable only with hard connections.  This is intentional, since many devices this will be plugged into already include such capabilities (such as mobile devices, which often support Bluetooth and NFC).

### MicroSD Card Slot

This device may also have a MicroSD card slot, allowing easy and safe importing of data directly without trusting any host, or of encrypting data to be transferred directly somewhere.

### Keypad

Similar to the six-key pad on the [OnlyKey](https://onlykey.io/), this device has a keypad of capacitance keys which are used to unlock the device with a PIN code.  However, this keypad has ***twelve keys***, arranged like an older phone in a ***four by three grid***.

Also, similarly to the [OnlyKey](https://onlykey.io/), the keys on this keypad are ***recessed***.  This an important features, because it allows the user to enter their code ***by touch*** with ***one hand***, perhaps thinking of it as a pattern, rather than a code.  This makes much easier the important security practice of entering your password ***out of sight***.  With this small device on the end of a cord, you can enter your pattern under a table, inside your vest, under your coat, behind your hat, or even inside a pocket (if it's roomy enough).

### Display

In order to operate safely on less trusted hosts, this device must have a display.  It consists of an e-ink screen occupying the side opposite the keypad.  Once the user has unlocked the device, they look down on it in their hand and can navigate the menu using the keys on the underside.

While this device contains no battery, it does contain a capacitor sufficient to alter the message displayed when the device is unplugged, such as "If found, return to...", a QR code, a logo, or whatever else you might want.

### RGB LED

The device has a single configurable LED light, whose color can indicate the status or mode of the unit, which profiles are logged in, or whatever else is handy.

### Fingerprint Scanner?

Though it adds significant complications to the design, one additional feature that ***could*** be added (perhaps in a subsequent version) is a fingerprint scanner.  It could occupy the surface of the display, acting as an additional factor to the PIN entry, though it's use for authentication is questionable, and I think perhaps it's better without it.

### Internal Components

Broadly, the hardware required for this device is a combination of the [Armory](https://www.crowdsupply.com/f-secure/usb-armory-mk-ii) and the [OnlyKey](https://onlykey.io/), but with a bigger keypad and a display.  It will require at least the following components:

- cryptographic processors
- true random number generator
- microcontroller with protected memory
  - manages keypad, unlocking, etc.
- secure non-volatile storage (a few MB should do)
  - profile keys decrypted by unlocking device
  - group keys decrypted by profile keys
  - group keys used to decrypt entries
- small application processor running embedded linux
- internal flash storage
  - entries stored as encrypted volumes
  - decrypted by group keys in secure flash
  - optionally additional flash for other data
- USB controller
  - able to emulate keyboard, network device, mass storage, smart card, ...

## Basic Usage

The device is used by plugging into some host, which could be a desktop or laptop computer, a mobile device, a network port, or any other (powered) host for which there is an adapter.  Once plugged in, it must be unlocked by entering a code on the keypad corresponding to one of the profiles.  That decrypts the profile key, which is used to decrypt all the group keys which encrypt the actual entries.  Most of this decryption is done lazily.  It supports several profiles, a code which wipes the device, and a feature that wipes it after too many failed attempts.

### Sharing Entries

Various protocols can be used to share entries between users of this device (and others), both directly between them and over networks.  While transmission over networks may introduce some attack vectors, for many people its convenience, especially in limited use, vastly outweighs the risks.  Between TLS, VPNs, PGP, and whatever protocols we want to implement, we have many options for (mostly) safely sharing and synchronizing such private data over the untrusted internet.

### Backup Units

Of course, when all of your private data is on one device, that data must be backed up.  While a user need have only one active unit (with as many profiles as they have room for), they should have at least one, if not several, backup vaults.  These backup units are identical to the active units, except they are set into backup mode.

This is done by plugging the backup unit directly into the unlocked active unit, and then entering that same unlock code on the new backup unit, which registers the backup unit with the active one.  When changes are then made to the contents of the active unit, it will attempt to synchronize all registered backup units.

### Death Protocol

Having these active backup units, if they are accessible remotely, gives us the ability to implement the ***death protocol***, wherein users can bequeath their data to others upon their death.

How does it know the user has died?  Well, of course, it doesn't really know, but the user sets a ***length of time***, a set of entries, and recipients.  Each time the active device is used, an attempt is made to contact all the registered backup units.  If an active backup unit does not receive this contact within the given amount of time, then the unit presumes the user has died and the designated entries are released and distributed to the designated recipients, encrypted using their public keys.

In general use, one could set this to six months, or a year.  Longer if you're going on a backwoods trek or the like.  If someone feared for their life, they could set certain items to be distributed, in a week or a day, if the contact is not made, which could execute on the backup unit from almost anywhere.

### Auto-Type

The device may be configured to reveal nothing to unknown hosts.  In this case, you can still have the unit auto-type your credentials by navigating the menu on the device screen with the keys and selecting an entry to type, which will execute the auto-type sequence which is contained in that entry.

### Mounted Entries

In whatever format we store the (encrypted) entries on the flash drive, such as the KeePass `KDBX` format, or a native one is designed, we can configure the device to make them available to the host, perhaps mounted in `~/vault`.  This allows them to be accessed directly by a well-integrated password manager and used as conveniently as possible, through web plugins, key agents, or the like.

### Extended Storage

While this device is designed primarily to store your authentication and encryption keys and data, there is no reason why it cannot have a secondary, much larger flash storage (on the order of terabytes), potentially storing a wide range of things, even all of a user's private data.

There is perhaps an argument to be made that it would be better to store one's encrypted data on a different device from the keys which decrypt it, which may have merit.  If one leans that way, they can use a model without such extended storage, and have their data on a separate device, which need only be a flash drive, which their vault is required to unlock.

#### Mounted Home

If your device does have extended storage, it could even eventually help realize the dream of the portable home directory, such as with [`systemd-homed`](https://systemd.io/HOME_DIRECTORY/).  Your home directory could be stored as an encrypted volume on the bulk storage (or on another device, encrypted by keys on this one) and made accessible only to designated hosts after the vault has been unlocked.  Even if all the pieces are not yet in place for this to work completely, software can be used to synchronize your home directory or parts of it directly to this device when it's used.

#### Public Partitions

On an untrusted or unknown host, you may want access to some software, or even a trusted operating system.  This device may be configured with completely public, unencrypted partitions, which will be accessible to any host, even without unlocking the device.

On these partitions you could store data that is not private and you want to have easily available.  This could include a `VCARD` file with your contact info, your public keys, your portfolio, some favorite music, or whatever else.

Additionally, this public drive could store your commonly needed binaries, so even if running on an untrusted host, you could at least have trusted software.  This device can even have a bootable partition, containing one or several operating systems for various platforms, which you could customize and configure, having somewhat more trust in.

## Application Software

The degree to which the use of this device could become widespread largely depends on the associated software integration on popular platforms.  While the device ***can*** be used with no supporting software on the host whatsoever, the functionality will be broader, and the user experience much better, with good accompanying software.

There already exists a good foundation of open source software which can be built upon to make this daunting task feasible.  There are very mature password managers with good integration that can be fairly easily extended to read the native format of this device straight off the mounted vault entries and operate as normal.

This device has a full application processor, which runs an embedded linux and can carry on complex long-running tasks and network communication, such as for the backup process, and the death protocol.  Clearly there is a lot of code that needs to be written to make all that happen smoothly, but it doesn't have to happen immediately, rather built up over time, after the hardware is rolled out and the firmware is stable.  

## Summary

When talking about security or privacy with most people today, I hear a lot of "don't care" attitude, an apathy towards privacy and security.  This seems due, in part, to the seeming futility of accomplishing some semblance of real security today, and I think if an actual, functional, usable system was available, with the right marketing campaign, many regular folks would take it up, in addition to the many geeks that already use such products as are available today.

The dream of this device is not a tool for development or hardware hacking, it is a an everyday thing that average, non-technical people can actually learn to use, and (perhaps with some guidance), incorporate into their lives, eventually supporting a new era of data stability, privacy, and secure communications.
