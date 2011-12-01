;
;       linux.asm - procedures for calling Linux system calls
;
;       Copyright 2011 Ygor Mutti <ygormutti@dcc.ufba.br>
;       Most info pasted from kernel.org
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

%include "syscall.i"
%include "macros.i"

%include "linux.i"

section .text
    global exit, read, write, open, close, time

;
; NAME
;   exit - terminate the calling process
;
; SYNOPSIS
;   void exit(int status)
;
; DESCRIPTION
;   The function exit() terminates the calling process "immediately".  Any open
;   file descriptors belonging to the process are closed; any children of the
;   process are inherited by process 1, init, and the process's parent is sent a
;   SIGCHLD signal.
;
;   The value status is returned to the parent process as the process's exit
;   status, and can be collected using one of the wait family of calls.
;
_defsyscall __NR_exit, exit, 1

;
; NAME
;   read - read from a file descriptor
;
; SYNOPSIS
;   ssize_t read(int fd, void *buf, size_t count);
;
; DESCRIPTION
;   read attempts to read up to count bytes from file descriptor fd into the
;   buffer starting at buf.
;
; RETURN VALUE
;   On success, the number of bytes read is returned (zero indicates EOF),
;   and the file position is advanced by this number.
;
_defsyscall __NR_read, read, 3

;
; NAME
;   write - write to a file descriptor
;
; SYNOPSIS
;   ssize_t write(int fd, const void *buf, size_t count);
;
; DESCRIPTION
;   write writes up to count bytes from the buffer pointed buf to the file
;   referred to by the file descriptor fd.
;
; RETURN VALUE
;   On success, the number of bytes written is returned (zero indicates nothing
;   was written).  On error, -1 is returned, and errno is set appropriately.
;
_defsyscall __NR_write, write, 3

;
; NAME
;   open - open and possibly create a file or device
;
; SYNOPSIS
;   int open(const char *pathname, int flags, mode_t mode);
;
; DESCRIPTION
;   Given a pathname for a file, open() returns a file descriptor, a small,
;   nonnegative integer  for  use  in  subsequent  system  calls  (read(2),
;   write(2), lseek(2), fcntl(2), etc.).  The file descriptor returned by a
;   successful call will be the lowest-numbered file  descriptor  not  cur‐
;   rently open for the process.
;
;   mode is an octal number like those we use with chmod. For flags use the
;   O_* constants defined above, by adding the flags you wish to combine.
;
; RETURN VALUE
;   open() return the new file descriptor, or -1 if an error occurred.
;
_defsyscall __NR_open, open, 3

;
; NAME
;   close - close a file descriptor
;
; SYNOPSIS
;   int close(int fd);
;
; DESCRIPTION
;   close()  closes  a  file descriptor, so that it no longer refers to any
;   file and may be reused.  Any record locks (see fcntl(2))  held  on  the
;   file  it  was  associated  with,  and owned by the process, are removed
;   (regardless of the file descriptor that was used to obtain the lock).
;
;   If fd is the last file descriptor referring to the underlying open file
;   description  (see open(2)), the resources associated with the open file
;   description are freed; if the descriptor was the last  reference  to  a
;   file which has been removed using unlink(2) the file is deleted.
;
; RETURN VALUE
;   close()  returns  zero on success.  On error, -1 is returned.
;
_defsyscall __NR_close, close, 1

;
; NAME
;   time - get time in seconds
;
; SYNOPSIS
;   time_t time(time_t *t);
;
; DESCRIPTION
;   time()  returns  the  time  as  the  number of seconds since the Epoch,
;   1970-01-01 00:00:00 +0000 (UTC).
;
;   If t is non-NULL, the return value is also stored in the memory pointed
;   to by t.
;
; RETURN VALUE
;   On  success,  the value of time in seconds since the Epoch is returned.
;   On error, ((time_t) -1) is returned, and errno is set appropriately.
;
_defsyscall __NR_time, time, 1


