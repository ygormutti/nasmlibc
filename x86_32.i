;
;       x86_32.i - x86 32 bits compatibility header
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

; LP32 convention -> (L)ong and (P)ointer are (32) bits long

; Macros for defining variables of types used in LP32 convention
%define ptr     int32
%define long    int32

; Amount of bytes of the types
%define PTR_BYTES   4
%define LONG_BYTES  4

; Size of types
%define PTR_SIZE    dword
%define LONG_SIZE   dword

; "noarch" N?? register names. These should be used when there is no need
; for registers to have a specific size.
%idefine nax eax
%idefine nbx ebx
%idefine ncx ecx
%idefine ndx edx
%idefine nsi esi
%idefine ndi edi
%idefine nbp ebp
%idefine nsp esp
%idefine nip eip

; Amount of bytes of the N?? registers
%define NBYTES 4

; Size of the N?? registers
%define NSIZE dword

%endif ; x86_??
