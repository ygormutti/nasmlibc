;       x86_64.i - x86 64 bits compatibility header
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

%ifndef x86_??
%define x86_??

; LP64 convention -> Long and Pointer are 64 bits long

; Macros for defining variables of types used in LP64 convention
%define ptr     int64
%define long    int64

; Amount of bytes of the types
%define PTR_BYTES   8
%define LONG_BYTES  8

; Size of types
%define PTR_SIZE    qword
%define LONG_SIZE   qword

; "noarch" N?? register names. These should be used when there is no need
; for registers to have a specific size.
%idefine nax rax
%idefine nbx rbx
%idefine ncx rcx
%idefine ndx rdx
%idefine nsi rsi
%idefine ndi rdi
%idefine nbp rbp
%idefine nsp rsp
%idefine nip rip

; Amount of bytes of the N?? registers
%define NBYTES 8

; Size of the N?? registers
%define NSIZE qword

%endif ; x86_??
