;
;       time.i - constants and macros for date and time manipulation
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

%ifndef TIME_I
%define TIME_I

%define MINUTE	60
%define HOUR	60 * MINUTE
%define DAY		24 * HOUR
%define YEAR	365 * DAY

%define EPOCH_YEAR	1970
%define EPOCH_MONTH 1
%define EPOCH_DAY	1

%endif ; TIME_I
