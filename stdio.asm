;
;       stdio.asm - functions for doing basic IO
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

%include "noarch.i"
%include "macros.i"
%include "syscall.i"
%include "linux.i"

%include "stdio.i"

section .text
    global print, puts, getchar, putchar, getline, padzero, prependsign, formati
    global gettrimln
    extern write, read, strlen, isdigit, issign, itoa, strpadl, strpre, trim

; arg(0) - null terminated string to print to stdout
print:
    prologue
    call strlen, arg(0)
    call write, stdout, arg(0), nax
    epilogue

; arg(0) - null terminated string to print to stdout appending a line break
puts:
    prologue
    call print, arg(0)
    mov nbx, nax
    call putchar, LN
    inc nbx
    retval nbx
    epilogue

; returns an character from stdin
getchar:
    prologue 1
    lea nbx, local(0)
    call read, stdin, nbx, 1
    cmp nax, 1
    jl .error
    retval local(0)
    jmp .end
.error:
	retval EOF
.end:
    epilogue 1

; arg(0) - character to print to stdout
putchar:
    prologue
    lea nbx, arg(0)
    call write, stdout, nbx, 1
    cmp nax, 1
    jne .error
    mov nax, arg(0)
.error:
    epilogue

; arg(0) - buffer
; arg(1) - buffer size
getline:
	prologue
	zero ndi
	mov nsi, arg(1)
	cmp nsi, 0
	je .end ; se o tamanho do buffer for 0 não faz nada
	cmp nsi, 1
	je .trailing0 ; se o tamanho for 1 o resultado é cadeia vazia
	dec nsi ; senão o espaço para o \0 deve ser reservado
	mov nbx, arg(0)
.while_not_end:
	call getchar
	cmp nax, EOF ; se achar EOF termina a leitura
	je .trailing0
	cmp nax, LN ; idem para \n
	je .trailing0
	mov CHAR_SIZE [nbx], al
	inc ndi
	inc nbx
	dec nsi
	cmp nsi, 0
	jne .while_not_end
.trailing0:
	mov CHAR_SIZE[nbx], 0
.end:
	retval ndi
    epilogue
   
; arg(0) - buffer to put trimmed line read from stdin
; arg(1) - buffer size
gettrimln:
	prologue
	mov ndi, arg(0)
	call getline, ndi, arg(1)
	call trim, ndi
	call strlen, ndi
	epilogue

; arg(0) - string with integer to pad with zeros
; arg(1) - desired width
padzero:
	prologue
	mov nsi, arg(0)
	mov nbx, arg(1)
	call issign, [nsi]
	cmp nax, true
	jne .pad
	inc nsi ; pula o sinal
	dec nbx
.pad:
	call strpadl, nsi, '0', nbx
	epilogue

; arg(0) - string with integer to prepend sign, if necessary
prependsign:
	prologue
	mov nsi, arg(0)
	call strlen, nsi
	cmp nax, 0
	je .end
	call issign, [nsi]
	cmp nax, true
	je .end
	call strpre, nsi, '+'
.end:
	epilogue

; arg(0) - buffer with integer to format
; arg(1) - flags
; arg(2) - width
; arg(3) - precision
; arg(4) - length
; FIXME: some format tags aren't being checked
; returns the length of the formatted string
formati:
	prologue
	mov bl, arg(1) ; bl contém as flags de formatação
	mov nsi, arg(0) ; nsi contém o ponteiro do buffer
	mov ndi, arg(2) ; ndi contém o comprimento mínimo
	test bl, FMT_PLUS
	jz .check_padding
	call prependsign, nsi
.check_padding:
	cmp ndi, 0
	je .dont_pad
	test bl, FMT_ZERO
	jz .pad_space
	call padzero, nsi, ndi
.pad_space:
	call strpadl, nsi, ' ', ndi
.dont_pad:
	call strlen, nsi
	epilogue
