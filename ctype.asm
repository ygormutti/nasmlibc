;
;       ctype.asm - functions to classify and transform individual characters
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

section .text
    global isgraph, isdigit, issign, isupper, islower, isalpha, toupper, tolower

; arg(0) - char to check if it is graphical
isgraph:
    prologue
    mov nax, 1
    mov nbx, arg(0)
    cmp bl, '!' ; '!' is the first graphical character in ASCII
    jl .nongraph
    cmp bl, 0x7f ; 0x7f is the only non-graphical character after '!'
    je .nongraph
    jmp .end
.nongraph:
    zero nax ; retval false
.end:
    epilogue

; arg(0) - char to check if it is a digit
isdigit:
	prologue
	mov nax, 1
	mov bl, arg(0)
	cmp bl, '0'
	jl .nondigit
	cmp bl, '9'
	jg .nondigit
	jmp .end
.nondigit:
	zero nax ; retval false
.end:
	epilogue

; arg(0) - char to check if is '+' or '-'
issign:
	prologue
	mov nax, 0
	mov bl, arg(0)
	cmp bl, '+'
	je .sign
	cmp bl, '-'
	je .sign
	jmp .end
.sign:
	retval true
.end:
	epilogue

; arg(0) - char to check if is a uppercase letter
isupper:
	prologue
	zero nax
	mov bl, arg(0)
	cmp bl, 'A'
	jl .nonupper
	cmp bl, 'Z'
	jg .nonupper
	retval true
.nonupper:
	epilogue

; arg(0) - char to check if is a lowercase letter
islower:
	prologue
	zero nax
	mov bl, arg(0)
	cmp bl, 'a'
	jl .nonupper
	cmp bl, 'z'
	jg .nonupper
	retval true
.nonupper:
	epilogue

; arg(0) - char to check if is a letter
isalpha:
	prologue
	mov nbx, arg(0)
	call isupper, nbx
	cmp nax, 1
	je .alpha
	call islower, nbx
	cmp nax, 1
	je .alpha
	jmp .end
.alpha:
	retval true
.end:
	epilogue

; arg(0) - char to turn into uppercase letter
toupper:
	prologue
	zero nbx
	mov bl, arg(0)
	call islower, nbx
	cmp nax, 0
	je .end
	sub nbx, 32
.end:
	retval nbx
	epilogue

; arg(0) - char to turn into lowercase letter
tolower:
	prologue
	zero nbx
	mov bl, arg(0)
	call isupper, nbx
	cmp nax, 0
	je .end
	add nbx, 32
.end:
	retval nbx
	epilogue
