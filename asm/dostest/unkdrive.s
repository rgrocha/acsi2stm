; ACSI2STM Atari hard drive emulator
; Copyright (C) 2019-2023 by Jean-Matthieu Coulon

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

; Tests Gsetdrv on an unknown drive

unkdrive:
	print	.desc

	move.l	drvmask,d0              ; Load drive mask

	moveq	#2,d1                   ; Search for a non-existing drive
.nxtdrv	btst	d1,d0                   ;
	beq.b	.drvok                  ;
	addq	#1,d1                   ;
	cmp.w	#26,d1                  ;
	bhs.b	.ndrv                   ;
	bra.b	.nxtdrv                 ;

.ndrv	print	.nfree                  ; No drive free
	bsr.w	testfailed              ;
	bra.w	.exit                   ;

.drvok	move.w	d1,-(sp)                ; Try to switch to the non-existing
	gemdos	Dsetdrv,2               ; drive

	move.l	drvmask,d1              ; TOS must return drive mask in any case
	cmp.l	d1,d0                   ;
	bne.b	.err                    ;

	bsr.w	testok                  ; Test successful
.exit	move.w	drive,-(sp)             ; Switch back to test drive
	gemdos	Dsetdrv,2               ;

	move.l	drvmask,d1              ; TOS must return drive mask in any case
	cmp.l	d1,d0                   ;
	bne.b	.err                    ;

	rts	                        ; End of test
	
.err	print	.reterr

.desc	dc.b	'Test Dsetdrv on an unknown drive',13,10,0
.nfree	dc.b	7,'No free drive letter found',13,10,0
.reterr	dc.b	'Dsetdrv returned an error. Should return a drive mask',13,10,0

; vim: ff=dos ts=8 sw=8 sts=8 noet colorcolumn=8,41,81 ft=asm tw=80
