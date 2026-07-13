# Licensing

KeyMaster is an open-hardware project. This file records the project's licensing
intent. Where a full license text applies, this file names it and points to the
authoritative source; individual files may additionally carry SPDX identifiers.

## Hardware

**CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S-2.0).**

All hardware design materials — schematics, PCB layouts, enclosure CAD, bills of
materials — are licensed under CERN-OHL-S-2.0. The strongly-reciprocal ("-S")
variant requires that modifications and derived hardware be shared under the same
terms.

- SPDX identifier: `CERN-OHL-S-2.0`
- Full text: https://ohwr.org/cern_ohl_s_v2.txt

## Firmware and Software

Firmware (security-MCU and application-processor) and host software are intended to
be released under a permissive or copyleft open-source license — **GPLv3 or Apache
2.0** — with the final choice to be made together with the engineering partner
(the decision affects patent grants, GPL/Apache compatibility with linked crypto
libraries, and contributor expectations). Until that decision is recorded here, no
firmware/software has been released.

- Candidate SPDX identifiers: `GPL-3.0-or-later` or `Apache-2.0`

## The Secure Element Is the One Closed Component

KeyMaster's commitment to open source is non-negotiable, with one unavoidable
exception: the internals of the secure element are proprietary to its silicon vendor
(certified tamper resistance requires specialized fabrication that open hardware
cannot replicate today). The interface to it is documented and its behavior is
auditable. Everything else — hardware, firmware, vault format, host software — is
open.

## Branding

The "KeyMaster" name and logo are trademarked. The trademark does not restrict use
of the open-source designs or code; it prevents confusingly-branded hardware from
being sold as genuine KeyMaster. ("KeyMaster" is a working name and may change.)
