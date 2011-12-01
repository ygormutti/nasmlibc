;
;       stdlib.asm - General utilities library
;
;       Copyright 2011 Ygor Mutti <ygormutti@dcc.ufba.br>
;
;		itoa and atoi based on code from the book The C Programming
;		Language by KERNIGHAN, Brian W. and RITCHE, Dennis M.
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
    global atoi, itoa, ctoi, itoc, isodd
    extern isgraph, isdigit, strrev, strlen

; arg(0) - string to convert to signed integer
atoi:
    prologue
    mov nbx, arg(0) ; nbx é o cursor da string
    mov nsi, 1 ; nsi é um inteiro indicando o sinal do número
    zero ndi ; ndi é o número lido
.while_whitespace:
    call isgraph, CHAR_SIZE [nbx]
    cmp nax, true
    je .end_while
    inc nbx
    jmp .while_whitespace ; loop while
.end_while:
	cmp CHAR_SIZE [nbx], '-'
	jne .not_minus
	neg nsi
	inc nbx
	jmp .while_digit
.not_minus:
	cmp CHAR_SIZE [nbx], '+'
	jne .while_digit
	inc nbx
.while_digit:
	call isdigit, CHAR_SIZE [nbx]
	cmp nax, true
	jne .end
	zero nax
	mov al, CHAR_SIZE [nbx]
	call ctoi, nax
	imul ndi, 10
	add ndi, nax
	inc nbx
	jmp .while_digit
.end:
	mov nax, nsi
	imul ndi
    epilogue

; arg(0) - number to convert to string
; arg(1) - buffer to place converted number
; returns the length of the converted number
; FIXME : receive the buffer's size as parameter
itoa:
	prologue
	mov eax, arg(0) ; eax será usado como dividendo
	mov ndi, arg(1) ; ndi é o cursor do buffer
	mov INT_SIZE local(0), 10 ; local(0) será usado como divisor
	mov esi, eax  ; esi indica se o número é negativo
	cmp eax, 0
	jge .non_negative
	neg eax
.non_negative:
	cmp eax, 0 ; verificação para evitar divisões por zero
	jne .while_not_zero
	mov CHAR_SIZE [ndi], '0'
	inc ndi
	jmp .end
.while_not_zero:
	mov edx, 0
	mov ecx, 10
	div ecx
    zero nbx
	mov ebx, eax ; salva o valor de eax
	call itoc, ndx
	mov [ndi], al
	mov eax, ebx ; recupera o valor de eax
	inc ndi
	cmp eax, 0
	jne .while_not_zero
.append_sign:
	cmp esi, 0
	jge .end
	mov CHAR_SIZE [ndi], '-'
	inc ndi
.end:
	mov CHAR_SIZE [ndi], 0
	mov ndi, arg(1)
	call strrev, ndi
	call strlen, ndi
	epilogue

; arg(0) - char to convert to digit (integer)
ctoi:
    prologue
    call isdigit, arg(0)
    cmp nax, false
    je .nondigit
    mov nax, arg(0)
    sub nax, 0x30
    jmp .end
.nondigit:
    retval 0
.end:
    epilogue

; arg(0) - digit (integer) to convert to char
itoc:
    prologue
    mov nax, arg(0)
    cmp nax, 0
    jl .non_digit
    cmp nax, 9
    jg .non_digit
    add nax, '0'
    jmp .end
.non_digit:
    retval '0'
.end:
    epilogue

; arg(0) - number to check if it is odd
isodd:
	prologue
	mov nax, arg(0)
	mov nbx, 2
	zero ndx
	idiv nbx
	mov nax, ndx
	cmp nax, 0
	setne al
	movzx nax, al
	epilogue
