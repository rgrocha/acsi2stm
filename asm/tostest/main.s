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

	; Include all tests
	include	tdsetdrv.s
	include	tdsetpth.s
	include	tdcreate.s
	include	tfcropen.s

	include	tui.s

main:
	move.l	sp,mainsp               ; Used for abort

	gemdos	Dgetdrv,2               ; Query drive mask
	move.l	d0,-(sp)                ;
	gemdos	Dsetdrv,6               ;
	move.l	d0,drvmask              ;
	
	print	.drvlrq                 ; Welcome screen. Ask for a drive letter
	bsr	.ltrq                   ;
	move.w	d0,tstdrv               ; Store wanted drive letter

	print	.reflrq                 ; Ask for a reference drive letter
	bsr	.ltrq                   ;
	move.w	d0,refdrv               ; Store wanted drive letter

	; Do the actual tests
	move.w	tstdrv,drive
	bsr	tdsetdrv
	bsr	tdsetpth
	bsr	tdcreate
	bsr	tfcropen

	; End of tests
	print	.reslt1

	move.w	success,d0              ; Print successful tests count
	ext.l	d0                      ;
	moveq	#1,d1                   ;
	bsr	tui.puint               ;

	print	.reslt2

	move.w	failed,d0               ; Print failed tests count
	ext.l	d0                      ;
	moveq	#1,d1                   ;
	bsr	tui.puint               ;
	print	.reslt3                 ;

	gemdos	Cnecin,2                ; Wait for a key

	rts

.ltrq	gemdos	Cnecin,2                ; Read drive letter

	cmp.b	#$1b,d0                 ; Exit if pressed Esc
	beq	abort                   ;

.nesc	cmp.b	#'a',d0                 ; Change to upper case
	bmi.b	.upper                  ;
	add.b	#'A'-'a',d0             ;

.upper	sub.b	#'A',d0                 ; Transform to id
	and.w	#$00ff,d0               ;

	cmp.w	#26,d0                  ; Check if it is a valid letter
	bhs	.ltrq                   ; Not a letter: try again

	move.l	drvmask,d1              ; Check if the drive actually exists
	btst	d0,d1                   ;
	beq	.ltrq                   ;

	move.w	d0,-(sp)                ; Temp storage
	add.b	#'A',d0                 ; Print selected drive letter
	move.w	d0,-(sp)                ;
	print	.usedr1                 ;
	gemdos	Cconout,4               ;
	print	.usedr2                 ;
	move.w	(sp)+,d0                ; Restore d0

	rts	                        ; Success

.drvlrq	dc.b	$1b,'E','GEMDOS file functions tester v'
	incbin	..\..\VERSION
	dc.b	$0d,$0a,'by Jean-Matthieu Coulon',$0d,$0a
	dc.b	'https://github.com/retro16/acsi2stm',$0d,$0a
	dc.b	'License: GPLv3',$0d,$0a
	dc.b	$0d,$0a
	dc.b	'Tests file system functions on a drive.',$0d,$0a
	dc.b	'The drive must be empty (no files).',$0d,$0a
	dc.b	$0d,$0a
	dc.b	'Please input the drive letter to test:',$0d,$0a
	dc.b	$1b,'e'
	dc.b	0

.reflrq	dc.b	'Please input a reference drive letter:',$0d,$0a
	dc.b	0

.usedr1	dc.b	$1b,'f','Using drive ',0
.usedr2	dc.b	':',$0d,$0a,$0a
	dc.b	0

.reslt1	dc.b	'________________________________________',$0d,$0a,$0a
	dc.b	'Test results:',$0d,$0a,$0a
	dc.b	'  ',0
.reslt2	dc.b	' successful tests',$0d,$0a
	dc.b	'  ',0
.reslt3	dc.b	' failed tests',$0d,$0a
	dc.b	0

	even

testok:
	move.l	mainsp,sp               ; Adjust stack for the test return addr
	subq	#4,sp                   ;

	add.w	#1,success              ; Success counter
	print	.succss                 ; Print result

	rts

.succss	dc.b	' -> successful',$0d,$0a
	dc.b	$0a
	dc.b	0

	even

testfailed:
	move.l	mainsp,sp               ; Adjust stack for the test return addr
	subq	#4,sp                   ;

	add.w	#1,failed               ; Increment failure counter
	print	(a5)                    ; Print error message
	print	.fail                   ;

	rts

.fail	dc.b	' -> failed',$0d,$0a
	dc.b	$0a
	dc.b	0

	even

abort:
	move.l	mainsp,sp               ; Restore main stack pointer
	print	(a5)                    ; Print error message
	print	.abort                  ;
	gemdos	Cnecin,2                ; Wait for a key
	rts	                        ; Exit from main

.abort	dc.b	$0d,$0a,7,'Program aborted',$0d,$0a
	dc.b	0

	even

; vim: ff=dos ts=8 sw=8 sts=8 noet colorcolumn=8,41,81 ft=asm tw=80
