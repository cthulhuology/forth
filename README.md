forth
=====

This is yet another 64 bit forth implemented in forth written initially 
for x86_64 (amd64 and intel64) instruction set. 

The goal isn't to be strictly an ANSI forth, but to be close enough that
you can get around it.  Since we're going to be 64 bit from the get go,
a lot of the ANSI standard is actually a pain to support.  And as this
forth  is going to support the x86_64 ABIs for each platform, this means
that a library support will be different from most existing ones.


design
------

In order to get bootstrapped quickly, I'm taking the approach of using a
copy assembler.  The copy assembler uses a table to translate a virutal 
instruction set into machine native instructions.  Each of the virutual
instructions consist of just enough assembler to build up the core forth
words.  From there the forth words will be defined in terms of these
instructions.  This allows us to swap out instruction tables to port the
forth to new processors with a little effort.

  +----+------------+
  | ## | bytes (12) |
  +----+------------+

Each instruction just copies the bytes for the instruction inline to
the exec region of memory.  A set of patch function are used to back
patch different instructions to embed literals, or swap out instructions.

For example, 0 ins copies a 64 bit value to the top of the stack, the
default value is 0. To copy another value, the assembler using patch8 to
backpatch the desired literal into it.  1 ins uses patch4 to backpatch
a 32bit literal.

Another component of the design is that it uses 3 separate memory regions:
data, exec, and lexicon.  The data region is a place for r/w data that 
can be read by the program.  It is also a place to store constants and
other things.  It is the first area of memory so that all data references
are back references.  The exec region is the next region of memory for 
storing r/x code. The compiler writes instructions to this memory region, 
and it can be write protected for turnkey solutions.  

Finally, a separate lexicon region is used to store the dictionary. The
lexicon consists of a length, a string, and an address:   

  +--------+--------------------------------+--------+
  |length  | string                         | addr   |
  +--------+--------------------------------+--------+

The dictionary is search backwards so that you can redefine thing.  There's
no smudge, and recursive definitions are allowed. Since the compiler will 
support proper tail call recursion and definition fall through, it is possible
to use the dictionary to support jump tables and other structures.  Typically
definitions don't point to the data segment, but they may.


license
-------

 Copyright (C) 2016 David J Goehrig <dave@dloh.org>
 
  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

