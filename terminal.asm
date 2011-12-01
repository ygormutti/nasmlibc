;
;       terminal.asm - functions for manipulating the terminal
;
;       Copyright 2011 Ygor Mutti <ygormutti@dcc.ufba.br>
;
;       This program is free software; you can redistribute it and/or modify
;       it under the terms of the GNU General Public License as published by
;       the Free Software Foundation; either version 2 of the License, or
;       (at your option) any later version.
;
;       This program is distributed in the hope that it will be useful,
;       but WITHOUT ANY WARRANTY; without even the implied warranty of
;       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;       GNU General Public License for more details.
;
;       You should have received a copy of the GNU General Public License
;       along with this program; if not, write to the Free Software
;       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
;       MA 02110-1301, USA.
;

%include "macros.i"

section .data
	ansi_esc_begin			char	1bh,'[',0
	ansi_esc_erase_display	char	1bh,'[2J',0

section .text
	global clrscr, gotoxy, forward
	extern itoa, print, putchar

; arg(0) - line to move cursor
; arg(1) - column to move cursor
gotoxy:
	prologue 1 ; local(0) -> char buffer[n], n >= 4
	lea ndi, local(0)
	call print, ansi_esc_begin
	call itoa, arg(0), ndi
	call print, ndi
	call putchar, ';'
	call itoa, arg(1), ndi
	call print, ndi
	call putchar, 'H'
	epilogue 1

;arg(0) - number of columns to move the cursor forward
forward:
	prologue 1 ; local(0) -> char buffer[n], n >= 4
	lea ndi, local(0)
	call print, ansi_esc_begin
	call itoa, arg(0), ndi
	call print, ndi
	call putchar, 'C'
	epilogue 1

; clears the screen
clrscr:
	prologue
	call gotoxy, 0, 0
	call print, ansi_esc_erase_display
	epilogue


