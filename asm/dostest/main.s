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

main:
	print	drvltrq                 ; Welcome screen. Ask for a drive letter
.ltrq	gemdos	Cconis,2                ; Flush keyboard buffer
	tst.w	d0                      ;
	bne.b	.ltrq                   ;
	gemdos	Cnecin,2                ; Read drive letter

	cmp.b	#$1b,d0                 ; Exit if pressed Esc
	bne.b	.nesc                   ;
	rts	                        ;

.nesc	cmp.b	#'a',d0                 ; Change to upper case
	bmi.b	.upper                  ;
	add.b	#'A'-'a',d0             ;

.upper	sub.b	#'A',d0                 ; Transform to id
	and.w	#$00ff,d0               ;

	cmp.w	#26,d0                  ; Check if it is a valid letter
	bhs.b	.ltrq                   ; Not a letter: try again

	move.w	d0,drvlttr              ; Store wanted drive letter
	moveq	#1,d1                   ;
	lsl.l	d1,d0                   ;
	move.l	d1,drvmask              ; Store drive mask
	add.b	#'A',d0                 ;
	move.w	d0,drvlttr              ; Store drive letter

	gemdos	Dgetdrv,2               ; Get current drive
	move.w	d0,prvdrv               ;

	move.w	d0,-(sp)                ; Switch to wanted drive
	gemdos	Dsetdrv,4               ;

	move.l	drvmask,d1              ; Check if the drive actually exists
	and.l	d0,d1                   ;
	bne.b	.drvok                  ;

	move.w	prvdrv,-(sp)            ; Roll back
	gemdos	Dsetdrv,4               ;
	bra.w	.ltrq                   ; Select another drive letter

.drvok	print	usedrv                  ; Print selected drive letter
	move.w	drvlttr,-(sp)           ;
	gemdos	Cconout,4               ;
	print	usedrv2                 ;

	; Do the actual tests
	bsr.w	unkdrive

	rts

drvltrq	dc.b	'GEMDOS file functions tester v'
	incbin	..\..\VERSION
	dc.b	13,10,'by Jean-Matthieu Coulon',13,10
	dc.b	'https://github.com/retro16/acsi2stm',13,10
	dc.b	'License: GPLv3',13,10
	dc.b	13,10
	dc.b	'Tests file system functions on a drive.',13,10
	dc.b	'The drive must be empty (no files).',13,10
	dc.b	13,10
	dc.b	'Please input the drive letter to test:',13,10
	dc.b	0

usedrv	dc.b	13,10,'Testing on drive ',0
usedrv2	dc.b	':',13,10,0

	even

; vim: ff=dos ts=8 sw=8 sts=8 noet colorcolumn=8,41,81 ft=asm tw=80
