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
	gemdos	Dgetdrv,2               ; Query drive mask
	move.l	d0,-(sp)                ;
	gemdos	Dsetdrv,6               ;
	move.l	d0,drvmask              ;
	
	print	drvltrq                 ; Welcome screen. Ask for a drive letter
	bsr.b	.ltrq                   ;

	move.w	d0,drive                ; Store wanted drive letter
	add.b	#'A',d0                 ;
	move.w	d0,drvlttr              ; Store drive letter

	print	usedrv                  ; Print selected drive letter
	move.w	drvlttr,-(sp)           ;
	gemdos	Cconout,4               ;
	print	usedrv2                 ;

	print	refltrq                 ; Ask for a reference drive letter
	bsr.b	.ltrq                   ;

	move.w	d0,refdrv               ; Store wanted drive letter
	add.b	#'A',d0                 ;
	move.w	d0,reflttr              ; Store drive letter

	print	usedrv                  ; Print selected drive letter
	move.w	reflttr,-(sp)           ;
	gemdos	Cconout,4               ;
	print	usedrv2                 ;

	; Do the actual tests
	bsr.w	unkdrive

	rts

.ltrq	gemdos	Cconis,2                ; Flush keyboard buffer
	tst.w	d0                      ;
	bne.b	.ltrq                   ;
	gemdos	Cnecin,2                ; Read drive letter

	move.w	d0,d3
	cmp.b	#$1b,d3                 ; Exit if pressed Esc
	bne.b	.nesc                   ;
	rts	                        ;

.nesc	cmp.b	#'a',d3                 ; Change to upper case
	bmi.b	.upper                  ;
	add.b	#'A'-'a',d3             ;

.upper	sub.b	#'A',d3                 ; Transform to id
	and.w	#$00ff,d3               ;

	cmp.w	#26,d3                  ; Check if it is a valid letter
	bhs.b	.ltrq                   ; Not a letter: try again

	move.l	drvmask,d1              ; Check if the drive actually exists
	btst	d3,d1                   ;
	beq.b	.ltrq                   ;

	moveq	#0,d0                   ; Return drive letter
	move.b	d3,d0                   ;

	rts	                        ; Success


testok:
	move.w	success,d0
	addq	#1,d0
	move.w	d0,success
	print	succss
	rts

testfailed:
	move.w	failed,d0
	addq	#1,d0
	move.w	d0,failed
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

succss	dc.b	' -> successful',13,10,0
	even

; vim: ff=dos ts=8 sw=8 sts=8 noet colorcolumn=8,41,81 ft=asm tw=80
