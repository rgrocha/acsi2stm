GemDrive: high level filesystem driver
======================================

GemDrive enables reading SD cards from the Atari ST, without the hassle of the
ancient TOS/BIOS filesystem implementation. It works more or less like the
GEMDOS drive functionality provided by the Hatari emulator: hook high level
filesystem calls and implement them directly in the STM32, using modern SD
card libraries.


Benefits
--------

* Handles all standard PC-formatted SD cards (FAT16/FAT32/ExFAT).
* No SD card size limit.
* Avoids most TOS filesystem bugs.
* Consumes much less RAM on the ST than a normal driver.
* Can be combined with a normal hard drive or a floppy drive.
* Fully supports medium swap.
* Everything that runs on Hatari GEMDOS drives should run on GemDrive.


Limitations
-----------

* Truncates long file names, as TOS doesn't support them.
* Only supports ASCII characters in file names, no intl support.
* Only one partition per SD card.
* Works around some TOS limitations by using (relatively safe) heuristics,
  but there may be issues in some very extreme corner cases.
* Hooks the whole system unconditionally: may decrease performance in some
  cases. Also, the STM32 can stall the whole TOS in case of error.
* TOS versions below 1.04 (Rainbow TOS) lack necessary APIs to implement Pexec
  properly, meaning that running a program will leak a small amount of RAM.
  This is also the case in Hatari.
* Not compatible with EmuTOS, MiNT, or any other TOS replacement.


How to use
----------

When the ST boots (cold boot or reset), ACSI2STM scans all SD cards, then
decide whether each SD card slot is in ACSI mode, GemDrive mode or disabled,
in that order:

* If the slot doesn't exist, it is completely disabled.
* If strict mode is enabled (via dumper or "strict" firmware variant), ACSI
  mode is enabled.
* If the SD card contains an ACSI disk image, ACSI mode is enabled.
* If the SD card is Atari bootable, ACSI mode is enabled.
* If the SD card can be mounted by the STM32, GemDrive mode is enabled.
* If no SD card is detected in the slot, GemDrive mode is enabled.
* If no other condition is satisfied, the SD card has an unknown format: ACSI
  mode is enabled.

If at least one SD slot is in GemDrive mode, then the driver will load by
providing a boot sector through the first GemDrive slot only (to avoid loading
the driver multiple times). All further GemDrive communication will go through
the ACSI id matching this slot.

If no SD card is present, GemDrive mode is enabled, because it supports hot
inserting and hot swapping cards.

If GemDrive detects a bootable SD card, it will shift its drive letters to L:
in order to avoid conflicts with poorly written ACSI drivers that steal
existing drive letters for themselves.

At boot, GemDrive designates the first SD card it finds as boot drive (even if
it is not C:). If no SD card is detected, it leaves boot drive untouched
(usually the floppy drive is designated as boot).

**Note**: in order to avoid drive letter confusion, only the first partition of
the SD card is used by GemDrive. This should not be a problem in most cases as
the need for multiple partitions arised from disk size limitations, and
GemDrive doesn't have any of them.


Mixing GemDrive and ACSI
------------------------

### Mixing GemDrive and ICD PRO

To mix GemDrive with ICD PRO, you must proceed like this:

* You must have only one bootable ICD PRO SD card.
* Insert the ICD PRO SD cards after the GemDrive cards.

The GemDrive driver will boot before the ICD PRO driver. GemDrive will use L:
and above as drive letters.

### Mixing GemDrive and other ACSI drivers

A few considerations should be made when mixing both kinds of drives:

* ACSI drivers that require ACSI id 0 and break the boot chain won't allow
  GemDrive loading itself.
* GemDrive doesn't respond to any ACSI command, except reading the boot sector.
  Most drivers will ignore such a strange behavior and should skip the drive
  successfully.
* In general putting GemDrive first and the ACSI drives last is your best bet.

If your driver has problems with GemDrive, then only solution is to enable
strict mode to force ACSI everywhere.


How it works
------------

GemDrive injects itself in the system by providing a boot sector. This boot
sector takes over the whole operating system and the STM32 can access freely
the whole ST RAM and operating system.

When booted, the STM32 injects the driver in RAM, then installs a hook for all
GEMDOS calls. The driver is just a small stub taking less than 500 bytes of
memory.

Each GEMDOS trap sends a single byte command to the STM32, then waits for
remote commands from the STM32 program. The command set is extremely reduced,
so the whole algorithm is actually implemented in the STM32.

The STM32 decodes the trap call, then can decide to either implement it, or to
forward the call to the TOS.


Future improvements
-------------------

Things that could be done more or less easily:

* Install the driver in top RAM.
* Floppy drive emulator, by hooking BIOS and XBIOS calls.
* Hook Pexec on ST files to boot a floppy image by double-clicking it in GEM.
* Support international character sets for filename translation, based on the
  language of the machine.
