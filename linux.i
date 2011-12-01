;
;       linux.i - macros and constants for calling system calls
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

%ifndef LINUX_I
%define LINUX_I

%include "macros.i"

; POSIX syscall numbers
%define __NR_restart_syscall      0
%define __NR_exit		  1
%define __NR_fork		  2
%define __NR_read		  3
%define __NR_write		  4
%define __NR_open		  5
%define __NR_close		  6
%define __NR_waitpid	  7
%define __NR_creat		  8
%define __NR_link		  9
%define __NR_unlink		 10
%define __NR_execve		 11
%define __NR_chdir		 12
%define __NR_time		 13

; Standard POSIX file descriptors
%idefine stdin	0
%idefine stdout	1
%idefine stderr	2

; Index into IDT which contains the memory address of the Linux system call
; interrupt handler
%define GATE 0x80

; Macro used for defining Linux syscalls as procedures
; Usage: _defsyscall call_number, call_name, nargs
%macro _defsyscall 3
%2:
    prologue
%if %3 = 0
    syscall GATE, %1
%elif %3 = 1
    syscall GATE, %1, arg(0)
%elif %3 = 2
    syscall GATE, %1, arg(0), arg(1)
%elif %3 = 3
    syscall GATE, %1, arg(0), arg(1), arg(2)
%elif %3 = 4
    syscall GATE, %1, arg(0), arg(1), arg(2), arg(3)
%elif %3 = 5
    syscall GATE, %1, arg(0), arg(1), arg(2), arg(3), arg(4)
%endif
    epilogue
%endmacro

; Flags to be passed as parameters to open system call
%define O_RDONLY	00000000o
%define O_WRONLY	00000001o
%define O_RDWR		00000002o
%define O_CREAT		00000100o
%define O_TRUNC		00001000o
%define O_APPEND	00002000o

%endif ; LINUX_I
