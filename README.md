# KeyMaster

(open to better names)
Is *KeeMaster* better?
Perhaps *vault*, *KeyVault*, *KeeVault*?
*OpenVault* is pleasantly oxy-moronic?

___Hardware Password Manager and Data Vault___

## Introduction
The management of encryption keys and other authentication data is a primary prerequisite for secure identity, decentralization of communication, the secure storage of all other private data, web of trust, and more.  Most average users sacrifice privacy for convenience and accessibility of their data by trusting it to corporate "clouds", services, networks, proprietary hardware, and closed-source software.

While there are many products, both software and hardware, attempting to facilitate the protection of our data (including password managers, crypto wallets, secure flash drives, and the like), they all fall critically short in some way from providing a solid and universal foundation that can be both really trusted and convenient enough to function in our every day lives.

To achieve this goal of real privacy and security in our digital worlds, some open-source hardware device and robust software infrastructure is needed which is convenient enough to foster an effective security culture that can be incorporated into the daily habits of real users.  Herein I present a broad but coherent vision for such a device and some of it's accompanying software.

## Hardware
The proposed device is small (approximately ***2 inches by 3 inches***), just thick enough to feature three USB-C ports and a MicroSD slot along its edges.  On it's two larger faces, it has an inset 12-key capacitance keypad on one side and an e-paper display on the other, potentially incorporating a fingerprint scanner.

### Connectivity
This device contains no battery, and so is powered only when you connect it to a host via one of its USB ports.  This host could be any desktop, mobile device, or with an adapter, an ethernet port or even smart-card reader.  Once connected to a powered host, it can power other devices connected directly to its other ports, so that flash drives and backup units can be connected directly to it, and mobile devices can be charging while plugged into it.  It's behavior can be configured on a per-host basis, allowing for much flexibility in the balance between security and convenience.

### Unlocking
Once plugged in, the device is unlocked by entering a master code on the integrated 12-key pad of capacitance buttons.  Importantly, these keys are each inset, so that this can be done ***by touch***, with ***one hand***, and can be easily remembered as a ***pattern***, rather than a code.  Because these keys do not depress and require something like an actual finger to be actuated, they are completely silent, and resistant to brute-force attacks.  Since the device contains only ***ports*** (female), it is always connected to its host via a cable, and this simple but important design choice allows the user sufficient flexibility to unlock the device in a secure location, such as under a table, coat, blanket, shirt, in a roomy pocket, or wherever else is out of sight to protect your master code from potential surveillance.

### Integrated Display
On the opposite large side of the device from the keypad is an integrated e-paper display.  Once unlocked, this display is used in conjunction with the keypad opposite it to navigate functions on the device, displaying menus and information on the screen.  By having this onboard display, we can operate the device safely on completely untrusted hosts.  While the device contains no battery, it does contain sufficient capacitors to modify the contents of the display when the device is suddenly unplugged.

## Data Storage
The primary purpose of this device is as a storage vault for encryption keys, certificates, passwords, and other authentication data, so it must possess enough secure flash storage to accomplish this.  Once unlocked, the entries in this vault can be selected with the integrated menus and auto-typed into the host, or they can be made available to specified trusted hosts, to be mounted and accessible directly to a software password manager.

Additionally, this device can also store any other data, even potentially entire portable home directories.  With the low cost of flash storage today, it can easily have terabytes of storage space available, configurable as any number of partitions, available to specific hosts, encrypted by keys stored safely on the device, or available unencrypted on any host, and even bootable.  It can also be used to encrypt data on a host device, flash drive or MicroSD card.

## Software
There are broadly three classes of software involved with this device.  Low level firmware manages a microcontroller to facilitate the unlocking, operation of the integrated display, and menu navigation.  A small application processor in the device runs an embedded Linux which manages network operations, file system volumes, and interaction with trusted hosts, requiring strong integration with software password managers on all targeted platforms.

### Password Manager
This device can operate as a password manager with no accompanying software on the host device, such as with untrusted hosts, via emulation of a keyboard and auto-typing.  However, a far greater degree of convenience is possible on trusted hosts with the incorporation of a software password manager application on the host.

To accomplish this, groups of vault entries is specified for each trusted host, and when connected to that host, a partition is made available containing each of the included entries.  That partition is then mounted by the host and open source password managers and other software (SSH agent, and the like) on the various platforms (Windows, MacOS, Linux, Android, iOS) are adapted to load the vault entries directly from these partitions.

### Data Synchronization
Strong integration with some data synchronization tools on various platforms will allow this device to be painlessly kept up to date with data as it changes on whatever device being used, making it a central source of truth for your keys and any other data.  Since this unit can implement its own network device, it can use a wide variety of protocols to transfer data and share authentication between users.

## Backup Units
Of course when one's important data is safely stored in a single location, backing that data up is especially critical.  To this end, any number of additional identical units may be initialized as backup units to a single active unit.  This is done by plugging a new backup unit directly into the active unit.

Once initialized, all backup units are automatically kept in sync, either when plugged directly into the active unit, plugged into the same host, or even plugged into a different host or a network port over an encrypted network tunnel.

## Conclusion
Such a device could provide a long-needed foundation for strong digital identity, the secure synchronization and sharing of credentials and other data between devices, users, and groups, and even lingering dreams like the web of trust, portable home directories, and more, all while replacing a slew of mismatched devices providing partial solutions.

With sufficient careful hardware design, software development, accessories, marketing, and support, such a device could critically help to build a functional culture of digital security and privacy, not just for geeks, companies with sensitive data, and fringe privacy advocates, but eventually even for average users.  If this vision inspires you, please reach out and help make it a reality.
