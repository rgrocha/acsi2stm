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

; Test suite for ACSI2STM >= 4.0

	incdir	..\inc\
	include	tos.i

	opt	O+

	text
start
	lea	stacktop,sp             ; Initialize stack

	move.l	sp,d0                   ; Shrink memory
	lea	start-$100,a0           ;
	sub.l	a0,d0                   ;
	move.l	d0,-(sp)                ;
	pea	start-$100              ;
	clr.w	-(sp)                   ;
	gemdos	Mshrink,12              ;

	include	main.s
	even
	include	unkdrive.s
	even

	data

	include	data.s

	bss

	include	bss.s

stack:
	ds.b	4096
stacktop:

; vim: ff=dos ts=8 sw=8 sts=8 noet colorcolumn=8,41,81 ft=asm tw=80
