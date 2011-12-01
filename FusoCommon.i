;
;       FusoCommon.i - coisas em comum entre FusoGrav e FusoCalc
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

%ifndef FUSOCOMMON_I
%define FUSOCOMMON_I

; Comprimento do nome de uma cidade
%define LEN_NOME 20

; Tamanho do buffer de entrada
%define BUFFER_SIZE 256

; Estrutura que será guardada no arquivo
struc cidade_t
	nome		resb LEN_NOME ; nome da cidade
	graus		resb 1	; graus de longitude (0-180)
	minutos		resb 1	; minutos de longitude (0-59)
	orientacao	resb 1	; orientação da longitude ('W'|'E')
	especial	resb 1	; horário especial ('V'|'I'|' ')
endstruc

%endif ; FUSOCOMMON_I
