;
;       string.asm - functions to manipulate null-terminated strings
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

%include "string.i"

section .text
	global strrev, strlen, strchr, ltrim, rtrim, trim, formati, strapp
	global strpre, strpadl, strpadr, strcpy, strcat, strtrunc, memset, memcpy
	extern isgraph

; arg(0) - null terminated string to count characters
strlen:
    prologue
    zero nax
    mov nbx, arg(0) ; copia o ponteiro da string para ebx
.while_not_end:
    cmp CHAR_SIZE [nbx], 0 ; compara o caractere com \0
    je .end_of_string ; se for \0 encerra o loop
    inc nax ; incrementa a contagem de caracteres
    inc nbx ; avanca o ponteiro da string
    jmp .while_not_end
.end_of_string:
    epilogue

; arg(0) - string to revert
strrev:
	prologue
	mov nsi, arg(0) ; nsi -> cursor à direita
	call strlen, nsi
	mov ndi, nax
	dec ndi
	add ndi, nsi ; ndi -> cursor à esquerda
.revert_loop:
	mov al, CHAR_SIZE [nsi] ; al, bl -> auxiliares
	mov bl, CHAR_SIZE [ndi]
	xchg al, bl
	mov CHAR_SIZE [nsi], al
	mov CHAR_SIZE [ndi], bl
	inc nsi
	dec ndi
	cmp nsi, ndi
	jb .revert_loop
	epilogue

; arg(0) - string to eliminate whitespace at the beginning
ltrim:
	prologue
	mov nsi, arg(0)
	mov ndi, nsi
	zero nbx
.while_not_isgraph:
	cmp CHAR_SIZE [nsi], 0 ; verifica se o caractere é \0
	je .end ; se for a cadeia só contém whitespace
	call isgraph, CHAR_SIZE [nsi]
	cmp nax, true
	je .trim_loop_setup
	inc nbx
	inc nsi
	jmp .while_not_isgraph
.trim_loop_setup:
	call strlen, ndi
	sub nax, nbx
	mov ncx, nax
.trim_loop:
	mov al, [nsi]
	mov [ndi], al
	inc nsi
	inc ndi
	loop .trim_loop
.end:
	mov CHAR_SIZE [ndi], 0
	epilogue

; arg(0) - string to eliminate whitespace at the end
rtrim:
	prologue
	mov nsi, arg(0)
	call strlen, nsi
	cmp nax, 0
	je .end
	dec nax
	add nsi, nax
.trim_loop:
	mov nax, arg(0)
	dec nax
	cmp nsi, nax
	je .end ; alcançou o começo da cadeia -1
	call isgraph, CHAR_SIZE [nsi]
	cmp nax, true
	je .end
	mov CHAR_SIZE [nsi], 0
	dec nsi
	jmp .trim_loop
.end:
	epilogue

; arg(0) - string to eliminate whitespace at the end and beginning
trim:
	prologue
	call ltrim, arg(0)
	call rtrim, arg(0)
	epilogue

; arg(0) - string used to search for char in arg(1)
; returns a pointer to the first occurence of the char, null otherwise
strchr:
	prologue
	mov nsi, arg(0)
	mov bl, arg(1)
.search_loop:
	cmp CHAR_SIZE [nsi], 0
	je .not_found
	cmp [nsi], bl
	je .end
	inc nsi
	jmp .search_loop
.not_found:
	zero nsi ; retval NULL
.end:
	retval nsi
	epilogue

; arg(0) - string to append char
; arg(1) - char to append
strapp:
	prologue
	mov ndi, arg(0)
	call strlen, ndi
	add ndi, nax
	mov al, arg(1)
	mov [ndi], al
	inc ndi
	mov CHAR_SIZE [ndi], 0
	epilogue

; arg(0) - string to prepend char
; arg(1) - char to prepend
strpre:
	prologue
	mov ndi, arg(0)
	call strlen, ndi
	add ndi, nax
	mov nsi, ndi
	dec nsi
	inc ndi
	mov CHAR_SIZE [ndi], 0
	dec ndi
	cmp nax, 0
	je .prepend
	mov ncx, nax
.shift_loop:
	mov bl, [nsi]
	mov [ndi], bl
	dec nsi
	dec ndi
	loop .shift_loop
.prepend:
	mov al, arg(1)
	mov [ndi], al
	epilogue

; arg(0) - string to pad at the left side
; arg(1) - char used to pad
; arg(2) - desired width
; arg(3) - side to pad; 0 -> left, right otherwise
strpad:
	prologue
	mov nbx, arg(3)
	mov nsi, arg(0) ; nsi é o ponteiro da string
	mov ndi, arg(2)
	call strlen, nsi
	sub ndi, nax ; ndi indica quanto falta para encher
.pad_loop:
	cmp ndi, 0
	jle .end
	cmp nbx, 0
	je .pad_left
	call strapp, nsi, arg(1)
	jmp .pad_right
.pad_left:
	call strpre, nsi, arg(1)
.pad_right:
	dec ndi
	jmp .pad_loop
.end:
	epilogue

; arg(0) - string to pad at the left side
; arg(1) - char used to pad
; arg(2) - desired width
strpadl:
	prologue
	call strpad, arg(0), arg(1), arg(2), 0
	epilogue

; arg(0) - string to pad at the right side
; arg(1) - char used to pad
; arg(2) - desired width
strpadr:
	prologue
	call strpad, arg(0), arg(1), arg(2), 1
	epilogue

; arg(0) - destination string; it should be large enough to contain both strings
; arg(1) - source string to concatenate
strcat:
	prologue
	mov ndi, arg(0)
	call strlen, ndi
	add ndi, nax
	mov nsi, arg(1)
.concatenate:
	mov bl, [nsi]
	mov [ndi], bl
	cmp bl, 0
	je .end
	inc nsi
	inc ndi
	jmp .concatenate
.end:
	retval arg(0)
	epilogue

; arg(0) - destination string; should be at least as large as the source
; arg(1) - source string, to be copied to destination
strcpy:
	prologue
	zero nax
	mov ndi, arg(0)
	mov nsi, arg(1)
.copy:
	mov bl, [nsi]
	mov [ndi], bl
	cmp bl, 0
	je .end
	inc nsi
	inc ndi
	jmp .copy
.end:
	retval arg(0)
	epilogue

; arg(0) - string to truncate
; arg(1) - target string length
strtrunc:
	prologue
	mov nsi, arg(0)
	mov nbx, arg(1)
	call strlen, nsi
	cmp nax, nbx
	jbe .end
	add nsi, nbx
	mov CHAR_SIZE [nsi], 0
.end:
	epilogue

; arg(0) - buffer to set first arg(2) bytes with the char in arg(1)
memset:
	prologue
	mov ndi, arg(0)
	mov al, arg(1)
	mov ncx, arg(2)
.set_loop:
	mov [ndi], al
	loop .set_loop
	epilogue

; arg(0) - destination
; arg(1) - source
; arg(2) - bytes to copy from source to destination
memcpy:
	prologue
	mov nsi, arg(1)
	mov ndi, arg(0)
	mov ncx, arg(2)
	cmp ncx, 0
	je .end
.cpy_loop:
	mov al, [nsi]
	mov [ndi], al
	inc nsi
	inc ndi
	loop .cpy_loop
.end:
	epilogue
