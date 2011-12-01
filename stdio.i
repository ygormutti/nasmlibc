;
;       stdio.i - functions for doing basic IO (header file)
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

%ifndef STDIO_I
%define STDIO_I

; Line break character
%define LN 10

; End of file value
%define EOF -1

%define FMT_MINUS	00000001b
%define FMT_PLUS	00000010b
%define FMT_HASH	00000100b
%define FMT_SPACE   00001000b
%define FMT_ZERO	00010000b

%endif ; STDIO_I
