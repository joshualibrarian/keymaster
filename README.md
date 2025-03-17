# KeyMaster

(open to better names)
Is *KeeMaster* better?
Perhaps *vault*, *KeyVault*, *KeeVault*?
*OpenVault* is pleasantly oxy-moronic?

___Hardware Password Manager and Data Vault___

## Introduction
The management of encryption keys and other authentication data is a primary prerequisite for secure identity, decentralization of communication, the secure storage of all other private data, and even the old lingering dream of a functional [web of trust](https://www.weboftrust.info/).  Most average users sacrifice privacy for convenience and accessibility of their data by trusting it to corporate "clouds", networks, proprietary hardware, and closed-source software.

While there are many products, both software and hardware, attempting to facilitate the protection of our data (including password managers, crypto wallets, secure flash drives, and the like), they all fall critically short in some way from providing a solid and universal foundation that can be both really trusted and convenient enough to function in our every day lives.

To achieve this goal of real privacy and security in our digital worlds, some open-source hardware device and software ecosystem is needed which is convenient enough to foster an effective security culture that can be incorporated into the daily habits of real users.  Herein I present a coherent vision for such a device, and it's accompanying software.

## Hardware
The proposed device is small (approximately ***2 x 3 inches***), and just thick enough to feature three USB-C ports and a MicroSD card slot along its edges, with an inset 12-key capacitance keypad on one side and an e-paper display on the other, potentially incorporating a fingerprint scanner.

### Connectivity
This device contains no battery, and so is powered only when you connect it to a host via one of its USB-C ports.  This host could be any desktop, mobile device, or with an adapter, an ethernet port or even smart-card reader.  Once connected to a host, it can power other devices connected directly to its other ports, so that flash drives and backup units can be connected directly to it.  It's behavior can be configured on a per-host basis, allowing for much flexibility in the balance between security and convenience.

### Unlocking
The device is unlocked by entering a master code on the integrated 12-key pad of capacitance buttons.  Importantly, these keys are inset, so that this can be done ***by touch***, with ***one hand***, and can be more easily remembered as a ***pattern***, rather than a code.  Because these keys do not depress and require something like an actual finger to be actuated, they are completely silent, and are resistant to brute-force attacks.  Since the device contains only ***ports*** (female), it is always connected to its host via a cable, and this simple but important design choice allows the user to sufficient flexibility to unlock the device in a secure location, such as under a table, coat, blanket, shirt, or wherever else is out of sight to protect your code from potential surveillance.

### Integrated Display
On the opposite flat side of the device from the keypad is an integrated e-paper display.  Once unlocked, this display is used in conjunction with the keypad opposite it to navigate functions on the device, displaying menus and information on the screen.  By having this onboard display, we can operate the device safely on completely untrusted hosts.  While the device contains no battery, it does contain sufficient capacitors to modify the contents of the display when the device is suddenly unplugged.

### Data Storage
The primary purpose of this device is as a storage vault for encryption keys, certificates, passwords, and other authentication data, so it must possess enough secure flash storage to accomplish this.  Once unlocked, the entries in this vault can be selected with the integrated menus and auto-typed into the host, or they can be made available as small partitions and mounted by specific trusted hosts, accessible directly to a software password manager.

Additionally, this device can also store any other data, and with the low cost of flash storage today, can easily have terabytes of storage space available, configurable as any number of partitions, available to specific hosts, encrypted by keys stored safely on the device, or available unencrypted on any host and even bootable.  It can also be used to encrypt data on a host device, flash drive or MicroSD card.

## Software
There are three layers of software involved in this device.  Low level firmware manages a microcontroller to facilitate the unlocking, operation of the integrated display, and menu navigation.  A small application processor in the device runs an embedded Linux which manages network operations, file system volumes, and integration with trusted hosts, requiring strong integration with software password managers on all targeted platforms.

### Password Manager
This device can operate as a password manager with no accompanying software on the host device, such as with untrusted hosts, via auto-typing.  However, a far greater degree of convenience is possible on trusted hosts with the incorporation of a software password manager application on the host.

To accomplish this, a group of vault entries is specified for each trusted host, and when connected to that host, a partition is made available containing each of the included entries.  That partition is then mounted by the host and password managers on the various platforms (Windows, MacOS, Linux, Android, iOS) are adapted to load the vault entries directly from these partitions.

### Backup Units
Of course when one's critical data is safely stored in a single location, backing that data up is especially critical.  To this end, any number of additional identical units may be initialized as backup units to a single active unit.  This is done by plugging a new backup unit directly into the active unit.  Once initialized, it is automatically kept in sync, either when plugged directly into the active unit, plugged into the same host, or even plugged into a different host or a network port over an encrypted network tunnel.
