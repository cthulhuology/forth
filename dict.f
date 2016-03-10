\ dict.f
\
\ dictionary routines
\
\ Copyright (C) 2016 David J Goehrig <dave@dloh.org>
\ 
\  This software is provided 'as-is', without any express or implied
\  warranty.  In no event will the authors be held liable for any damages
\  arising from the use of this software.
\
\  Permission is granted to anyone to use this software for any purpose,
\  including commercial applications, and to alter it and redistribute it
\  freely, subject to the following restrictions:
\
\  1. The origin of this software must not be misrepresented; you must not
\     claim that you wrote the original software. If you use this software
\     in a product, an acknowledgment in the product documentation would be
\     appreciated but is not required.
\  2. Altered source versions must be plainly marked as such, and must not be
\     misrepresented as being the original software.
\  3. This notice may not be removed or altered from any source distribution.
\

empty

1024 1024 * constant data-size
1024 1024 * constant exec-size

256 constant max-words
48 constant row-size
max-words row-size * constant lex-size

\ data region
create data
	data-size allot
create end-data
data data-size erase

data value data-here	\ free data pointer

: data-allot ( n -- )
	data-here + to data-here ;

: ,data ( n -- )
	data-here ! 4 data-allot ;

: c,data ( n -- )
	data-here c! 1 data-allot ;

\ exec region
create exec
	exec-size allot
create end-exec
exec exec-size erase	

exec value exec-here	\ free code pointer

: exec-allot ( n -- )
	exec-here + to exec-here ;

: ,exec ( n -- )
	exec-here ! 4 exec-allot ;

: c,exec ( c -- )
	exec-here c! 1 exec-allot ;

\ lexicon region
\ 
\ +--------+--------------------------------+--------+
\ |length  | string                         | addr   |
\ +--------+--------------------------------+--------+
\
create lexicon 
	lex-size allot
create lexicon-end
lexicon lex-size erase

lexicon value lex-here	\ free dictionary pointer

ICODE c!+ ( c addr -- addr+1)
	0 [EBP] EAX MOV		\ load c into eax
	AL 0 [EBX] MOV		\ read value from addr to tos
	1 # EBX ADD
	4 # EBP ADD		\ nip
	RET   END-CODE

: lex-length! ( len -- )
	lex-here 0 over 4+ ! ! ;	\ write 64 bits

: lex-string! ( addr len -- )
	lex-here 8 + swap move ;

: lex-addr!
	lex-here 40 + 0 over 4+ ! ! ;	\ write 64 bits

: lex-next lex-here row-size + to lex-here ;

: def 
	parse-word 		\ addr len
	dup lex-length!
	lex-string! 
	exec-here lex-addr!
	lex-next ; immediate 

: let
	parse-word 		\ addr len
	dup lex-length!
	lex-string! 
	data-here lex-addr!
	lex-next ;
