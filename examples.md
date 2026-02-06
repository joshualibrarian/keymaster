# KeyMaster Usage Examples

These narrative examples illustrate how KeyMaster adapts to different environments and use cases. The device behavior described represents the intended user experience.

## 1. The Digital Nomad

**Sarah** works remotely and travels frequently, using various computers and networks.

**At a co-working space in Bangkok:**
Sarah plugs her KeyMaster into a shared computer. The device detects an unknown host and automatically enters Minimal Mode. The e-paper display shows "Unknown Host - Minimal Mode" and prompts for her PIN.

She enters her travel PIN, which unlocks only her "travel" profile containing essential work passwords and a few personal accounts. When she visits her banking website, she presses the button on KeyMaster to auto-type her credentials. The device types her username, tabs to the password field, enters her password, and presses enter—all without the host computer ever seeing her actual credentials.

**At her Airbnb with her laptop:**
On her trusted laptop, KeyMaster switches to Composite Mode. She can access her full vault through the web interface at http://192.168.42.1, manage all her profiles, and sync her latest password changes to her backup MicroSD card.

**Security benefit:** Even if the co-working computer is compromised, it never sees her actual passwords or knows about her other profiles.

## 2. The Corporate Employee

**Marcus** works at a large company with strict IT policies and locked-down workstations.

**At his work desktop:**
The corporate IT department has pre-configured KeyMaster policies for work machines. When Marcus plugs in his device, it recognizes the corporate environment and presents only his "work" profile. His personal passwords remain completely hidden.

The device appears as a smart card to the Windows system, allowing him to use it for:

**At home on his personal laptop:**
KeyMaster switches to full Composite Mode, giving Marcus access to all his profiles. He can manage personal passwords, sync family shared accounts, and backup his vault to an encrypted USB drive.

**Security benefit:** Work and personal identities remain completely separate, satisfying corporate security policies while maintaining personal privacy.

## 3. The Security-Conscious Family

**The Chen family** shares some accounts while keeping others private.

**Dad setting up shared Netflix account:**
David creates a new entry in his "family" profile and adds his wife Lisa and teenage daughter Emma as recipients. Each family member can decrypt this entry with their own PIN, but none of them can see each other's private passwords.

**Mom accessing shared account:**
Lisa plugs in her KeyMaster and unlocks her profile. She can see the Netflix password that David shared, but not his personal banking or work accounts. When she updates the password after a security breach, the change syncs to David and Emma's devices during their next backup.

**Teenager with restricted access:**
Emma's KeyMaster has a policy that prevents access to financial sites and limits auto-type to approved domains. Her parents can review her password usage through the family management interface without seeing her actual passwords.

**Security benefit:** Selective sharing without compromising individual privacy or security.

## 4. The Developer

**Alex** manages dozens of SSH keys, API tokens, and development credentials across multiple clients.

**At Client A's office:**
KeyMaster recognizes the client's network and presents only the "ClientA" profile. Alex can SSH to their servers using keys stored on the device, sign commits with the client-specific GPG key, and access development databases—all without exposing credentials for other clients.

**Working from home on personal projects:**
In Composite Mode, Alex accesses all profiles and can:

**During a security audit:**
Alex uses the device's built-in key rotation feature to generate new SSH keys for all clients, exports the public keys via the web interface, and securely deletes the old keys after confirming deployment.

**Security benefit:** Client credentials remain isolated while maintaining convenient access to all development tools.

## 5. The Frequent Traveler

**Maria** crosses international borders regularly and needs to protect sensitive data from inspection.

**At airport security:**
Maria enables "Travel Mode" before her trip. This locks KeyMaster into Minimal Mode and hides her most sensitive profiles. If authorities inspect her device, they only see basic travel-related passwords and no indication that other data exists.

**At her hotel:**
Using her travel PIN, Maria can access essential accounts like email and work systems. Her banking and personal accounts remain hidden in other profiles that can't be unlocked with the travel PIN.

**Back home:**
Maria disables Travel Mode with her master PIN, restoring access to all profiles and enabling Composite Mode for full vault management.

**Security benefit:** Plausible deniability and protection against coercive inspection while maintaining access to essential accounts.

## 6. The Small Business Owner

**Tom** runs a marketing agency and needs to manage both business and client credentials securely.

**Managing client social media accounts:**
Tom creates separate profiles for each client. When working on Client X's campaign, he unlocks only that client's profile, preventing accidental cross-posting or credential leakage between clients.

**Sharing access with employees:**
Tom creates shared entries for business tools (Slack, project management, etc.) and adds his employees as recipients. Each employee can access shared business accounts with their own PIN while keeping personal passwords private.

**During client handoffs:**
When a client relationship ends, Tom can export only that client's credentials to a secure archive and then delete the profile, ensuring clean separation without affecting other clients.

**Security benefit:** Professional credential management with clear client boundaries and employee access control.

## 7. The Privacy Advocate

**Jordan** prioritizes maximum security and minimal trust in external services.

**Using public computers:**
At the library, Jordan's KeyMaster operates in Minimal Mode only. Even if the computer has keyloggers or malware, it can't capture Jordan's passwords since they're auto-typed directly from the hardware device.

**Managing encrypted communications:**
Jordan stores GPG keys on the device and uses them to sign and decrypt emails without the keys ever touching the host computer. TOTP seeds for secure messaging apps are also stored on-device.

**Creating secure backups:**
Jordan regularly backs up the encrypted vault to multiple MicroSD cards, storing them in different physical locations. The backup encryption keys are derived from the device's hardware, making the backups useless without the physical KeyMaster.

**Security benefit:** Maximum security with minimal trust in host computers or cloud services.

## 8. The Emergency Responder

**Dr. Kim** works in emergency medicine and needs reliable access to critical systems under any conditions.

**During a hospital emergency:**
Dr. Kim plugs KeyMaster into any available computer in the hospital. The device recognizes the hospital network and presents her medical credentials, allowing instant access to patient records and medical systems without waiting for IT support.

**At a disaster site:**
Using a ruggedized tablet with limited connectivity, Dr. Kim's KeyMaster provides offline access to emergency protocols and contact information stored in the encrypted vault. The device's batteryless design ensures it works even when other devices have failed.

**Sharing access with relief teams:**
Dr. Kim can quickly add temporary team members as recipients for shared emergency credentials, allowing coordinated response without compromising long-term security.

**Security benefit:** Reliable access to critical systems regardless of infrastructure conditions or device availability.

## 9. The Cryptocurrency Enthusiast

**Alex** manages multiple crypto wallets and DeFi protocols while maintaining operational security.

**At a crypto conference:**
Using a borrowed laptop to check portfolio values, Alex's KeyMaster remains in Minimal Mode. The device can sign transactions using stored private keys without exposing them to the potentially compromised conference network.

**Managing multiple wallets:**
Alex organizes wallet seeds by risk level—hot wallet seeds in the "daily" profile for easy access, cold storage seeds in the "vault" profile requiring additional confirmations. Hardware wallet backup phrases are stored encrypted with additional recipient keys for inheritance planning.

**DeFi protocol interactions:**
When interacting with new protocols, Alex uses KeyMaster's signing capabilities to review and approve transactions on the device's display before broadcasting, protecting against malicious contract interactions.

**Security benefit:** Private key isolation with convenient transaction signing across multiple protocols and risk levels.

## 10. The Academic Researcher

**Dr. Patel** collaborates with international research teams and needs to manage access to various institutional resources.

**At a partner university:**
KeyMaster recognizes the partner institution's network and presents Dr. Patel's "collaboration" profile, containing shared research credentials and project-specific access tokens while hiding her home institution's sensitive data.

**Managing research data:**
Encrypted research notes and preliminary findings are stored in KeyMaster's vault, accessible only through her personal profile. When ready for publication, she can selectively share specific entries with co-authors.

**Conference presentations:**
At international conferences, Dr. Patel uses Travel Mode to limit exposure while maintaining access to presentation materials and essential communications.

**Security benefit:** Institutional credential isolation with secure research data management across international collaborations.

## 11. The Freelance Journalist

**Sam** investigates sensitive stories and needs to protect sources while maintaining professional access.

**Protecting source communications:**
Sam stores encrypted messaging app credentials and GPG keys for secure source communication in a separate "sources" profile, isolated from professional journalism accounts.

**Working in hostile environments:**
When reporting from areas with government surveillance, Sam uses a duress PIN that unlocks only a "cover" profile containing innocuous credentials, hiding the existence of sensitive source protection tools.

**Secure file storage:**
Interview recordings and sensitive documents are encrypted and stored in KeyMaster's vault, accessible only through biometric confirmation on trusted devices.

**Security benefit:** Source protection through credential isolation and plausible deniability features.

## 12. The Elderly Technology User

**Robert**, 72, wants to stay connected with family online but struggles with password complexity and security.

**Simplified daily use:**
Robert's KeyMaster is configured with large, clear labels on the e-paper display. His daughter set up auto-type templates for his most-used sites—email, news, and video calls with grandchildren. He simply plugs in the device, enters his PIN, and presses the button when prompted.

**Family assistance:**
Robert's daughter has recipient access to his "family" profile, allowing her to help update passwords and add new accounts without seeing his private information. She can remotely guide him through the web interface during video calls.

**Emergency access:**
Robert's KeyMaster includes emergency contact information and medical details in a special profile that can be accessed by first responders using a clearly marked emergency PIN.

**Security benefit:** Strong security with simplified operation and family support without compromising privacy.

---

## Common Patterns Across Examples

**Adaptive Security:** KeyMaster automatically adjusts its security posture based on the environment, providing maximum protection on untrusted hosts while enabling full functionality on trusted devices.

**Profile Isolation:** Different aspects of users' digital lives remain completely separate, preventing credential leakage between contexts (work/personal, client A/client B, etc.).

**Selective Sharing:** Users can share specific credentials with family, colleagues, or collaborators without exposing their entire password vault.

**Physical Confirmation:** Sensitive operations require physical interaction with the device, preventing remote attacks even if the host computer is compromised.

**No Single Point of Failure:** The combination of on-device storage, encrypted backups, and recovery mechanisms ensures users never lose access to their digital lives.

These examples demonstrate how KeyMaster's design philosophy—security without sacrificing usability—applies across diverse user needs and threat models.
