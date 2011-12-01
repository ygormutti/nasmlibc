;
;       macros.i - general utilities macros
;
;       Copyright 2011 Ygor Mutti <ygormutti@gdcc.ufba.br>
;       multipop and multipush macros were copied from NASM documentation.
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

%ifndef MACROS_I
%define MACROS_I

%include "noarch.i"

; NULL pointer
%define NULL 0

; Define boolean constants
%idefine true  1
%idefine false 0

;
; MACRO
;   multipush
;
; SYNOPSIS
;   multipush ...
;
; DESCRIPTION
;   Pushes various registers in sequence.
;
%macro  multipush 1-*
%%multipush:
    %rep %0
        push %1
        %rotate 1
    %endrep
%%endmultipush:
%endmacro

;
; MACRO
;   multipop
;
; SYNOPSIS
;   multipop ...
;
; DESCRIPTION
;   Pops various registers in reverse sequence.
;
%macro  multipop 1-*
%%multipop:
    %rep %0
        %rotate -1
        pop %1
    %endrep
%%endmultipop:
%endmacro

; Zero the value of the given register
%macro zero 1
    xor %1, %1 ; this takes lass cycles than mov %1, 0
%endmacro

; A more flexible version of loop
%macro loop 2
	dec %1
	cmp %1, 0
	je %%loop_end
	jmp %2
%%loop_end:
%endmacro

;-------------------------------------------------------------------------------
; The following macros implement the prologue, epilogue and call of functions
; according to the document named "SYSTEM V APPLICATION BINARY INTERFACE,
; Intel386TM Architecture Processor Supplement, Fourth Edition".
;

;
; MACRO
;   prologue
;
; SYNOPSIS
;   prologue [n]
;
; DESCRIPTION
;   Initializes stack frame. If the optional argument nlocals is given,
;   allocates space for n local variables. It also pushes the register
;   values that must be preserved to the caller.
;
%macro prologue 0-1 0
%%prologue:
    push nbp
    mov nbp, nsp
%if %1 > 0
    sub nsp, %1 * PTR_BYTES
%endif
	multipush nbx, nsi, ndi
%%endprologue:
%endmacro

;
; MACRO
;   epilogue
;
; SYNOPSIS
;   epilogue
;
; DESCRIPTION
;   Restores the previous stack frame and local register variables values.
;
%macro epilogue 0-1 0
%%epilogue:
    multipop nbx, nsi, ndi
%if %1 > 0
    add nsp, %1 * PTR_BYTES
%endif
    mov nsp, nbp
    pop nbp
    ret
%%endepilogue:
%endmacro

; The size of the variables in the processor's stack
%define SSZ PTR_SIZE

;
; MACRO
;   call
;
; SYNOPSIS
;   call procedure [, args]
;
; DESCRIPTION
;   Calls the procedure with the given args. The procedure must be declared
;   using the prologue and epilogue macros.
;
%macro call 1-*
%%procedure: equ %1
%if %0 > 1
	%rep %0 - 1
		%rotate -1
		push SSZ %1
	%endrep
%endif
	call %%procedure
%if %0 > 1
	add		nsp, (%0 - 1) * PTR_BYTES
%endif
%endmacro

; Sets the return value of the function
%macro retval 1
%%retval:
	mov nax, %1
%endmacro

;-------------------------------------------------------------------------------
; Utility macros for acessing variables in the processor's stack
; OBS: they only work when using 'prologue' and 'epilogue' macros at the begin
; and at the end of procedures, respectively.
;

%define SAVE_AREA_REGISTERS 3

; The offset of the nth argument relative to the frame pointer
%define arg_offset(n) ((n * PTR_BYTES) + (2 * PTR_BYTES))

; The address (pointer) of the nth argument
%define argp(n) (nbp + arg_offset(n))

; The value of the nth argument
%define arg(n) [argp(n)]

; The offset of the nth local variable relative to the frame pointer
%define local_offset(n) (-1 * (PTR_BYTES * (n + 1 + SAVE_AREA_REGISTERS)))

; The address (pointer) of the nth local variable
%define localp(n) (nbp + local_offset(n))

; The value of the nth local variable
%define local(n) [localp(n)]

;-------------------------------------------------------------------------------

%endif ; MACROS_I
