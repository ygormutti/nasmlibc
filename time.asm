;
;       time.asm - functions to get and manipulate dates and times
;
;       Copyright 2011 Ygor Mutti <ygormutti@dcc.ufba.br>
;
;		getyear, getmonth and getdate inspired on code by
;		Gilmar Santos Jr (gilmarjr@dcc.ufba.br)
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

%include "time.i"

section .data
; Vector holding the amount of seconds of the months in a common year
	monthsecs  	integer 31 * DAY, ; January
				integer 28 * DAY, ; February
				integer 31 * DAY, ; March
				integer 30 * DAY, ; April
				integer 31 * DAY, ; May
				integer 30 * DAY, ; June
				integer 31 * DAY, ; July
				integer 31 * DAY, ; August
				integer 30 * DAY, ; September
				integer 31 * DAY, ; October
				integer 30 * DAY, ; November
				integer 31 * DAY  ; December

;
; _getter's CACHE
;
; The _get* functions work in a way that one need the remainder seconds
; of the other, so e.g. if you call getyear, getmonth and getdate for
; the same time in sequence it would calculate the year three times.
;
; To avoid this unnecessary overhead, this module mantains* a cache of
; the last calculated remainders. This way, when calling _get* functions
; for the same date they check the cache before calculating everything
; again.
;
; *TODO : This feature isn't yet implemented
;
; The cache will work this way: before starting the calculations the
; functions check if the time they'll calculate upon is the same as
; the value of cache_time. If it isn't they set invalid values to every
; field of the cache, like the ones those variables are initialized here,
; update cache_time with the new value and do their job, saving the
; obtained results into the cache variables.
; If cache_time is the same, they check if the values they need to return
; are in the cache, i.e., if the values in the cache are valid. If they
; are, these are returned, else the functions performs its calculations
; and save the results in the cache.
;
	cache_time 				integer	0
	cache_year				integer 0
	cache_year_rm 			integer	-1
	cache_month				integer 0
	cache_month_rm			integer YEAR + DAY

section .bss
;
; NOTE : the Linux programmer manual says about ctime/asctime:
;
;	The return value points to a statically allocated string which might
;	be overwritten by subsequent calls to any of the date and time
;	functions. The  asctime_r() function  does the same, but stores the
;   string in a user-supplied buffer which should have room for at least
;   26 bytes.
;
; Now you know why ctimebuffer has 26 chars. You're welcome :)
;
	ctimebuffer	reschar 26

section .text
	global isleap, getyear, ctime, cdate, ctimeonly, mktimespan, gettimepart
	global getseconds, getmonth, getday, gethours, getminutes, getdatepart
	extern itoa, formati, strcpy, strcat, strapp

; arg(0) - year to verify if it's leap
isleap:
	prologue
	mov nax, arg(0)
	mov nbx, 400
	zero ndx
	div nbx
	cmp ndx, 0
	je .leap
	mov nax, arg(0)
	mov nbx, 100
	zero ndx
	div nbx
	cmp ndx, 0
	je .nonleap
	mov nax, arg(0)
	mov nbx, 4
	zero ndx
	div nbx
	cmp ndx, 0
	je .leap
.nonleap:
	retval false
	jmp .end
.leap:
	retval true
.end:
	epilogue

; arg(0) - pointer to int to set the seconds since 1 Jan, if not null
; arg(1) - seconds since Epoch
_getyear:
	prologue
	mov nbx, EPOCH_YEAR ; nbx contains the year
	mov esi, INT_SIZE arg(1) 
.while_greater_than_0:
	mov edi, esi ; edi serves as a backup of esi
	sub esi, YEAR
	call isleap, nbx
	cmp nax, true
	jne .not_leap
	sub esi, DAY
.not_leap:
	cmp esi, 0
	jl .negative
	je .end_while
	inc nbx
	jmp .while_greater_than_0
.negative:
	mov esi, edi
.end_while:
	mov ndi, arg(0)
	cmp ndi, NULL ; checks if arg(0) is NULL
	je .end
	mov [ndi], esi ; esi contains the seconds since the beginning of year
.end:
	retval nbx
	epilogue

; arg(0) - seconds since Epoch
getyear:
	prologue
	call _getyear, NULL, arg(0)
	epilogue

; arg(0) - pointer to int to set the seconds since 1st day of month, if not null
; arg(1) - seconds since Epoch
_getmonth:
	prologue 1
	lea nbx, local(0)
	call _getyear, nbx, arg(1)
	mov esi, [nbx]
	mov nbx, EPOCH_MONTH ; nbx contains the month
	mov ndi, monthsecs ; ndi contains the monthsecs cursor
.while_greater_than_0:
	mov local(0), esi ; local(0) serves as a backup of esi
	sub esi, INT_SIZE [ndi]
	cmp INT_SIZE [ndi], 28
	jne .not_february_and_leap
	call isleap, nax ; nax contains the year
	cmp nax, true
	jne .not_february_and_leap
	sub esi, DAY
.not_february_and_leap:
	cmp esi, 0
	jl .negative
	je .end_while
	inc nbx
	add ndi, INT_BYTES
	jmp .while_greater_than_0
.negative:
	mov esi, local(0)
.end_while:
	mov ndi, arg(0)
	cmp ndi, NULL ; checks if arg(0) is NULL
	je .end
	mov [ndi], esi ; esi contains the seconds since the beginning of month
.end:
	retval nbx
	epilogue 1

; arg(0) - seconds since Epoch
getmonth:
	prologue
	call _getmonth, NULL, arg(0)
	epilogue

; arg(0) - seconds since Epoch
getday:
	prologue 1
	lea nbx, local(0)
	call _getmonth, nbx, arg(0)
	mov eax, [nbx]
	mov ebx, DAY
	zero edx
	div ebx
	inc eax; add eax, EPOCH_DAY
	epilogue 1

; arg(0) - seconds since Epoch
gethours:
	prologue
	mov nax, arg(0)
	mov nbx, DAY
	zero ndx
	div nbx ; the remainder is the hours represented as seconds
	mov nax, ndx
	mov nbx, HOUR
	zero ndx
	div nbx
	epilogue

; arg(0) - seconds since Epoch
getminutes:
	prologue
	mov nax, arg(0)
	mov nbx, HOUR
	zero ndx
	div nbx ; the remainder is the minutes represented as seconds
	mov nax, ndx
	mov nbx, MINUTE
	zero ndx
	div nbx
	epilogue

; arg(0) - seconds since Epoch
getseconds:
	prologue
	mov nax, arg(0)
	mov nbx, MINUTE
	zero ndx
	div nbx ; the remainder is the seconds
	retval ndx
	epilogue

; arg(0) - seconds since Epoch
; returns a string containing the date
; FIXME: add support to other formats of date
cdate:
	prologue
	mov nbx, ctimebuffer
	call getday, arg(0)
	call itoa, nax, nbx
	call formati, nbx, FMT_ZERO, 2, NULL, NULL
	add nbx, nax
	mov CHAR_SIZE [nbx], '/'
	inc nbx
	call getmonth, arg(0)
	call itoa, nax, nbx
	call formati, nbx, FMT_ZERO, 2, NULL, NULL
	add nbx, nax
	mov CHAR_SIZE [nbx], '/'
	inc nbx
	call getyear, arg(0)
	call itoa, nax, nbx
	call formati, nbx, FMT_ZERO, 2, NULL, NULL
	mov nax, ctimebuffer
	epilogue

; arg(0) - seconds since Epoch
; arg(1) - if true, include the seconds
; returns a string containing the time
; FIXME: add support to other formats of time
ctimeonly:
	prologue
	mov nbx, ctimebuffer
	call gethours, arg(0)
	call itoa, nax, nbx
	call formati, nbx, FMT_SPACE, 2, NULL, NULL
	add nbx, nax
	mov CHAR_SIZE [nbx], ':'
	inc nbx
	call getminutes, arg(0)
	cmp nax, 10
	call itoa, nax, nbx
	call formati, nbx, FMT_ZERO, 2, NULL, NULL
	cmp SSZ arg(1), true
	jne .end
	add nbx, nax
	mov CHAR_SIZE [nbx], ':'
	inc nbx
	call getseconds, arg(0)
	call itoa, nax, nbx
	call formati, nbx, FMT_ZERO, 2, NULL, NULL
.end:
	mov nax, ctimebuffer
	epilogue

; arg(0) - seconds since Epoch
; returns a string containing the date and the time
; FIXME: add support to other formats of datetime
ctime:
	prologue 3 ; local(0) -> char aux[12]
	mov ndi, ctimebuffer ; ndi é o buffer de saída
	lea nsi, local(0) ; nsi é o buffer auxiliar
	mov nbx, arg(0)
	call ctimeonly, nbx, 1
	call strcpy, nsi, ndi
	call cdate, nbx
	call strapp, ndi, ' '
	call strcat, ndi, nsi
	epilogue 3

; arg(0) - days
; arg(1) - hours
; arg(2) - minutes
; arg(3) - seconds
mktimespan:
	prologue
	mov nbx, arg(3) ; nbx guarda o resultado
	mov nax, arg(2)
	mov ncx, MINUTE
	imul ncx
	add nbx, nax
	mov nax, arg(1)
	mov ncx, HOUR
	imul ncx
	add nbx, nax
	mov nax, arg(0)
	mov ncx, DAY
	imul ncx
	add nbx, nax	
	retval nbx
	epilogue

; arg(0) - seconds since Epoch
; returns seconds since the beginning of the day
gettimepart:
	prologue
	mov nbx, 0
	call gethours, arg(0)
	mov ncx, HOUR
	mul ncx
	add nbx, nax
	call getminutes, arg(0)
	mov ncx, MINUTE
	mul ncx
	add nbx, nax
	call getseconds, arg(0)
	add nbx, nax
	retval nbx
	epilogue

; arg(0) - seconds since Epoch
; returns seconds since Epoch minus the seconds since the beginning of the day
getdatepart:
	prologue
	mov nbx, arg(0)
	call gettimepart, nbx
	sub nbx, nax
	retval nbx	
	epilogue
