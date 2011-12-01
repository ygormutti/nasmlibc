;
;       syscall.i - macros for calling system calls using interrupts
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

%ifndef SYSCALL_I
%define SYSCALL_I

%include "noarch.i"

; Register containing syscall number is nax
; Registers used as arguments in syscalls are: nbx, ncx, ndx, nsi, ndi

;
; MACRO
;   syscall
;
; SYNOPSIS
;   syscall handler, number [, arg0[, arg1[, arg2[, arg3[, arg4]]]]]
;
; DESCRIPTION
;   Perform a system call by generating an interrupt to the given handler,
;   passing arguments in registers. The handler will execute the system call
;   assigned to the given number.
;
%macro syscall 2-7
    mov nax, %2
%if %0 > 2
    mov nbx, %3
%endif
%if %0 > 3
    mov ncx, %4
%endif
%if %0 > 4
    mov ndx, %5
%endif
%if %0 > 5
    mov nsi, %6
%endif
%if %0 > 6
    mov ndi, %7
%endif
    int %1
%endmacro

%endif ; SYSCALL_I
