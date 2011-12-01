;
;       FusoCommon.asm - rotinas em comum entre FusoGrav e FusoCalc
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
%include "stdio.i"
%include "FusoCommon.i"

; Variáveis globais deste módulo
global cidade, buffer, fd, msg_entrada_invalida

section .data
	msg_universidade char	"Universidade Federal da Bahia",0
	len_universidade equ		$-msg_universidade
	msg_final	char "Departamento de Ciências da Computação",LN,\
					 "MATA49 - Programação de Software Básico",LN,LN,\
					 "Fusos horários - ",0

	msg_longitude	char "Longitude (graus, minutos, orientação E/W)     : ",0
	msg_especial	char "Horário de verão ou inverno? (V, I ou <ENTER>) : ",0

	msg_entrada_invalida char "Entrada inválida.",0

section .bss
	cidade 	resb cidade_t_size ; área intermediária do arquivo
	buffer	resb BUFFER_SIZE ; buffer de entrada
	fd 		resint 1 ; descritor do arquivo

section .text
	global imprimir_cabecalho, ler_nome, ler_longitude, ler_info, ler_especial
	global validar_longitude, mklocal
	extern clrscr, print, time, puts, ctime, putchar, forward, getline, strcpy
	extern gettrimln, strchr, trim, atoi, itoa, toupper, strlen, ltrim, strtrunc
	extern memset, gethours, getminutes, getseconds, getdatepart, mktimespan

; arg(0) - string com o nome do programa
imprimir_cabecalho:
	prologue
	call clrscr
	call print, msg_universidade
	mov nbx, 80 - 20 - len_universidade ; calculando a coluna da hora
	call forward, nbx
	call time, NULL
	call mklocal, nax, -3
	call ctime, nax
	call puts, nax
	call print, msg_final
	call puts, arg(0)
	call putchar, LN
	epilogue

; arg(0) - mensagem de prompt
; arg(1) - buffer
ler_info:
	prologue
	call print, arg(0)
	call gettrimln, buffer, BUFFER_SIZE
	epilogue

; arg(0) - mensagem de prompt
; retorna o comprimento do nome lido
ler_nome:
	prologue
	call ler_info, arg(0)
	mov nbx, buffer
	call strtrunc, nbx, LEN_NOME
	call memset, cidade+nome, 0, LEN_NOME
	call strcpy, cidade+nome, buffer
	call strlen, buffer
	epilogue

ler_longitude:
	prologue
.loop_validacao:
	call ler_info, msg_longitude
	cmp nax, 0
	je .erro
	call parse_longitude
	cmp nax, true
	je .fim
.erro:
	call puts, msg_entrada_invalida
	jmp .loop_validacao
.fim:
	epilogue

; acha e separa os valores da longitude no buffer de entrada
parse_longitude:
	prologue
	mov nsi, buffer
	call strlen, nsi
	cmp nax, 0
	je .erro
	call atoi, nsi
	mov [cidade+graus], al
	call strchr, nsi, ' ' ; acha o primeiro espaço
	cmp nax, NULL
	je .erro
	mov nsi, nax
	call ltrim, nsi
	call strlen, nsi
	cmp nax, 0
	je .erro
	call atoi, nsi
	mov [cidade+minutos], al
	call strchr, nsi, ' ' ; acha o segundo
	cmp nax, NULL
	je .erro
	mov nsi, nax
	call ltrim, nsi
	call strlen, nsi
	cmp nax, 0
	je .erro
	zero nax
	mov al, [nsi]
	call toupper, nax
	mov [cidade+orientacao], al
	call validar_longitude, [cidade+graus], [cidade+minutos], [cidade+orientacao]
	jmp .fim
.erro:
	zero nax ; retval false
.fim:
	epilogue

; arg(0) - graus
; arg(1) - minutos
; arg(2) - orientacao
; Verifica se os argumentos constituem uma longitude válida
validar_longitude:
	prologue
	cmp CHAR_SIZE arg(0), 180
	ja .erro
	sete bl
	mov cl, 59
	cmp bl, true
	jne .validar_minutos
	zero cl
.validar_minutos:
	cmp CHAR_SIZE arg(1), cl
	ja .erro
	zero nax
	mov al, arg(2)
	call toupper, nax
	cmp al, 'W'
	je .sucesso
	cmp al, 'E'
	jne .erro
.sucesso:
	retval true
	jmp .fim
.erro:
	zero nax ; retval false
.fim:
	epilogue

; Lê o campo de horário especial da cidade
ler_especial:
	prologue
.loop_validacao:
	call ler_info, msg_especial
	cmp nax, 0
	jne .validar_letra
	mov al, ' '
	jmp .salvar
.validar_letra:
	zero nax
	mov al, [buffer]
	call toupper, nax
	cmp al, 'V'
	je .salvar
	cmp al, 'I'
	jne .erro
.salvar:
	mov [cidade+especial], al
	jmp .fim
.erro:
	call puts, msg_entrada_invalida
	jmp .loop_validacao
.fim:
	epilogue

; arg(0) - referencial de tempo em segundos desde Epoch
; arg(1) - zona horária
mklocal:
	prologue
	mov nsi, arg(1)
	call gethours, arg(0)
	add nsi, nax
	call mktimespan, 0, nsi, 0, 0
	mov nbx, nax ; guarda o timespan local relativo a UTC em nax
	call getminutes, arg(0)
	call mktimespan, 0, 0, nax, 0
	add nbx, nax
	call getseconds, arg(0)
	call mktimespan, 0, 0, 0, nax
	add nbx, nax
	call time, NULL
	call getdatepart, nax
	add nax, nbx ; soma a parte da data UTC com o timespan
	epilogue
