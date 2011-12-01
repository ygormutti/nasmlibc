;
;       noarch.i - Architecture (almost) independent compatibility header
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

%ifndef NOARCH_I
%define NOARCH_I

; Macros for defining variables of portable types
%define int8    	db
%define int16   	dw
%define int32   	dd
%define int64   	dq
%define real32  	dd
%define real64  	dq
%define resint8  	resb
%define resint16   	resw
%define resint32   	resd
%define resint64   	resq
%define resreal32  	resd
%define resreal64  	resq

; Macros for defining variables of types used in both LP64 and LP32 conventions
%define char        	int8
%define short       	int16
%define integer     	int32
%define longlong   	 	int64
%define float       	real32
%define double      	real64
%define reschar        	resint8
%define resshort       	resint16
%define resint	     	resint32
%define reslonglong    	resint64
%define resfloat       	resreal32
%define resdouble      	resreal64

; Amount of bytes of the types
%define CHAR_BYTES      1
%define SHORT_BYTES     2
%define INT_BYTES       4
%define LONGLONG_BYTES  8
%define FLOAT_BYTES     4
%define DOUBLE_BYTES    8

; Size of types
%define CHAR_SIZE       byte
%define SHORT_SIZE      word
%define INT_SIZE        dword
%define LONGLONG_SIZE   qword
%define FLOAT_SIZE      dword
%define DOUBLE_SIZE     qword

; arch.i defines which architecture will be used when assembling
%include "arch.i"

; If arch.i defines x86_64 then use the 64 bits header, else use 32 bits header.
; These headers defines the characteristics that varies bewteen 32 and 64
; bits architectures.
%ifdef x86_64
    %include "x86_64.i"
%else
    %include "x86_32.i"
%endif

%endif ; NOARCH_I
