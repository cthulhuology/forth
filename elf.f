\ elf.f
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

\ elf header entires

\ table 3
1 constant ELFCLASS32 \ 32-bit objects
2 constant ELFCLASS64 \ 64-bit objects

\ table 4
1 constant ELFDATA2LSB \ Object file data structures are little-endian
2 constant ELFDATA2MSB \ Object file data structures are big-endian

\ table 5
0 constant ELFOSABI_SYSV \ System V ABI
1 constant ELFOSABI_HPUX \ HP-UX operating system
255 constant ELFOSABI_STANDALONE \ Standalone (embedded)  application

\ table 6
0 constant ET_NONE \ No file type
1 constant ET_REL \ Relocatable object file
2 constant ET_EXEC \ Executable file
3 constant ET_DYN \ Shared object file
4 constant ET_CORE \ Core file
$FE00 constant ET_LOOS \ Environment-specific use
$FEFF constant ET_HIOS
$FF00 constant ET_LOPROC \ Processor-specific use
$FFFF constant ET_HIPROC

: e-magic $7f c, [char] E c, [char] L c, [char] F c,  ;
: e-class ELFCLASS64 c, ;	\ table 3
: e-data ELFDATA2LSB c, ;	\ table 4
: e-version 1 c, ;
: e-osabi ELFOSABI_SYSV c, ;	\ table 5
: e-abiver 0 c, ; 

: e-pad 0 c, 0 c, 0 c, 0 c, 0 c, 0 c, 0 c, ;

: e_ident 
	e-magic 
	e-class 	
	e-data 		
	e-version 	
	e-osabi 	
	e-abiver 
	e-pad ; \ [16] unsigned  char  ELF  identification 

: e_type  ET_EXEC h, ;  \ Elf64_Half  Object  file  type  table 6
: e_machine $3e h, ; \ Elf64_Half Machine  type  arch specific
: e_version 1 , ; \ Elf64_Word Object  file  version 
: e_entry ( hi lo -- ) , , ; \ Elf64_Addr  Entry  point  address  system relative $4000e0 in sample prog, e0 was file offset
: e_phoff ( hi lo -- ) , , ; \ Elf64_Off  Program  header  offset  file relative $40 in sample
: e_shoff ( hi lo -- ) , , ; \ Elf64_Off Section  header  offset file relative $210 in sample
: e_flags 0 , ; \ Elf64_Word Processor-specific  flags, 0 in sample
: e_ehsize h, ; \ Elf64_Half  ELF  header  size  $40 in sample
: e_phentsize h, ; \ Elf64_Half Size  of  program  header  entry  $38 in sample 
: e_phnum  h, ; \ Elf64_Half  Number  of  program  header  entries  $2 in sample
: e_shentsize h, ; \  Elf64_Half  Size  of  section  header  entry  $40 in sample
: e_shnum  h, ; \ Elf64_Half Number  of  section  header  entries  $6 in sample
: e_shstrndx h, ; \ Elf64_Half Section  name  string  table  index  $3 in sample

\ elf header

: elf-header ( 
	shstrndx shnum shentsizze 
	phnum phentsize 	
	ehsize 
	shoff_hi shoff_lo 
	phoff_hi phoff_lo 
	entry_hi entry_lo -- )
	e_ident 
	e_type
	e_machine
	e_version
	e_entry
	e_phoff
	e_shoff
	e_flags
	e_ehsize
	e_phentsize
	e_phnum	
	e_shentsize
	e_shnum
	e_shstrndx ;

\ table 7
0 constant SHN_UNDEF \ Used to mark an undefined or meaningless section reference
$FF00 constant SHN_LOPROC \ Processor-specific use
$FF1F constant SHN_HIPROC
$FF20 constant SHN_LOOS \ Environment-specific use
$FF3F constant SHN_HIOS
$FFF1 constant SHN_ABS \ Indicates that the corresponding reference is an absolute value
$FFF2 constant SHN_COMMON \ Indicates a symbol that has been declared as a common block 
			\ (Fortran COMMON or C tentative declaration)

\ table 8
0 constant SHT_NULL \ Marks an unused section header
1 constant SHT_PROGBITS \ Contains information defined by the program
2 constant SHT_SYMTAB \ Contains a linker symbol table
3 constant SHT_STRTAB \ Contains a string table
4 constant SHT_RELA  \ Contains " Rela" type relocation entries
5 constant SHT_HASH \ Contains a symbol hash table
6 constant SHT_DYNAMIC \ Contains dynamic linking tables
7 constant SHT_NOTE \ Contains note information
8 constant SHT_NOBITS \ Contains uninitialized space; does not occupy any space in the file
9 constant SHT_REL \ Contains "Rel" type relocation entries
10 constant SHT_SHLIB \ Reserved
11 constant SHT_DYNSYM \ Contains a dynamic loader symbol table
$60000000 constant SHT_LOOS \ Environment-specific use
$6FFFFFFF constant SHT_HIOS
$70000000 constant SHT_LOPROC \ Processor-specific use
$7FFFFFFF constant SHT_HIPROC

\ table 9
$1 constant SHF_WRITE \ Section contains writable data (W)
$2 constant SHF_ALLOC \ Section is allocated in memory image of program (A) 
$4 constant SHF_EXECINSTR \ Section contains executable instructions (X)
$0F000000 constant SHF_MASKOS \ Environment-specific use
$F0000000 constant SHF_MASKPROC \ Processor-specific use

\ table 10
\ SHT_DYNAMIC	String table used by entries in this section
\ SHT_HASH	Symbol table to which the hash table applies
\ SHT_REL
\ SHT_RELA	Symbol table referenced by relocations
\ SHT_SYMTAB
\ SHT_DYNSYM	String table used by entries in this section
\ Other		SHN_UNDEF

\ table 11
\ SHT_REL
\ SHT_RELA	Section index of section to which the relocations  apply
\ SHT_SYMTAB
\ SHT_DYNSYM	Index of first non-local symbol (i.e., number of local symbols)
\ Other		0

\ table 12
\ .bss		SHT_NOBITS	A,  W		Uninitialized data
\ .data		SHT_PROGBITS	A,  W		Initialized data
\ .interp	SHT_PROGBITS	[A]		Program interpreter path name
\ .rodata	SHT_PROGBITS	A		Read-only data (constants and literals)
\ .text		SHT_PROGBITS	A,  X		Executable code

\ table 13
\ .comment	SHT_PROGBITS	none		Version control information
\ .dynamic	SHT_DYNAMIC	A[,  W]		Dynamic linking tables
\ .dynstr	SHT_STRTAB	A		String table for .dynamic section
\ .dynsym	SHT_DYNSYM	A		Symbol table for dynamic linking
\ .got		SHT_PROGBITS	mach. dep.	Global offset table
\ .hash		SHT_HASH	A		Symbol hash table
\ .note		SHT_NOTE	none		Note section
\ .plt		SHT_PROGBITS	mach. dep.	Procedure linkage table
\ .rel name	SHT_REL		[A]		Relocations for section name
\ .rela name	SHT_RELA	
\ .shstrtab	SHT_STRTAB	none		Section name string table
\ .strtab	SHT_STRTAB	none		String table
\ .symtab	SHT_SYMTAB	[A]		Linker symbol table

: sh_name ( n -- ) , ; \ Elf64_Word  Section  name, offset to section name in strings
: sh_type ( n -- ) , ;  \ Elf64_Word  Section  type  table 8
: sh_flags ( hi lo -- ) , , ; \ Elf64_Xword  Section  attributes  see table 9
: sh_addr ( hi lo -- ) , , ; \ Elf64_Addr  Virtual  address  in  memory, 0 if unallocated 
: sh_offset ( hi lo -- ) , , ; \ Elf64_Off  Offset  in  file  
: sh_size ( hi lo -- ) , , ; \ Elf64_Xword  Size  of  section  
: sh_link ( n -- ) , ; \ Elf64_Word  Link  to  other  section, related section index
: sh_info ( n -- ) , ; \ Elf64_Word  Miscellaneous  information  
: sh_addralign ( hi lo -- ) , , ; \ Elf64_Xword  Address  alignment  boundary  , power of two
: sh_entsize ( hi lo -- ) , , ; \ Elf64_Xword  Size  of  entries,  or zero

: section  ( 
	entsize_hi entsize_lo
	addralign_hi addralign_lo
	info link 
	size_hi size_lo 
	offset_hi offset_lo 
	addr_hi addr_lo
	flags_hi flags_lo
	type name -- )
	sh_name sh_type sh_flags
	sh_addr 	sh_offset
	sh_size		sh_link sh_info
	sh_addralign	sh_entsize ;

: first-section 0 0 0 0 0 0 0 0 0 0 0 0 0 0  section ;

\ table 14
0 constant STB_LOCAL \ Not visible outside the object file 
1 constant STB_GLOBAL \ Global symbol, visible to all object files
2 constant STB_WEAK \ Global scope, but with lower precedence than global symbols
10 constant STB_LOOS \ Environment-specific use
12 constant STB_HIOS
13 constant STB_LOPROC \ Processor-specific use
15 constant STB_HIPROC

\ table 15
0 constant STT_NOTYPE \ No type specified (e.g., an absolute symbol)
1 constant STT_OBJECT \ Data object
2 constant STT_FUNC \ Function entry point
3 constant STT_SECTION \ Symbol is associated with a section
4 constant STT_FILE \ Source file associated with the object file
10 constant STT_LOOS \ Environment-specific use
12 constant STT_HIOS
13 constant STT_LOPROC \ Processor-specific use
15 constant STT_HIPROC

\ symbol table

: st_name ( n -- ) , ; \ Elf64_Word Symbol  name , byte offset to symbol string
: st_info ( n -- ) c, ; \ unsigned  char Type  and  Binding  attributes, table 14, 15
: st_other 0 c, ; \ unsigned  char Reserved
: st_shndx ( n -- ) h, ; \ Elf64_Half Section  table  index table 7
: st_value ( hi lo -- ) , , ; \ Elf64_Addr Symbol  value
: st_size ( hi lo -- ) , , ; \ Elf64_Xword Size  of  object  (e.g.,  common)

: symbol ( hi-size lo-size hi-value lo-value shndx info name -- )
	st_name st_info st_other st_shndx
	st_value
	st_size ;

: first-symbol
	0 0 0 0 0 0 0 symbol ;

\ table 16

0 constant PT_NULL \ Unused entry
1 constant PT_LOAD \ Loadable segment
2 constant PT_DYNAMIC \ Dynamic linking tables
3 constant PT_INTERP \ Program interpreter path name
4 constant PT_NOTE \ Note sections
5 constant PT_SHLIB \ Reserved
6 constant PT_PHDR \ Program header table
$60000000 constant PT_LOOS \ Environment-specific use
$6FFFFFFF constant PT_HIOS
$70000000 constant PT_LOPROC \ Processor-specific use
$7FFFFFFF constant PT_HIPROC

\ table 17
$1 constant PF_X \ Execute permission
$2 constant PF_W \ Write permission
$4 constant PF_R \ Read permission
$00FF0000 constant PF_MASKOS \ These flag bits are reserved for environment-specific use
$FF000000 constant PF_MASKPROC \ These flag bits are reserved for processor-specific use

\ program header

: p_type , ; \ Elf64_Word Type of segment table 16	1 in sample1 PT_LOAD,  $04 in sample2 PT_NOTE
: p_flags , ; \ Elf64_Word Segment attributes table 17	5 in sample1 PF_X PF_R or, $04 in sample2 PF_R
: p_offset ( hi lo -- ) , ,  ; \ Elf64_Off Offset in file	0 in sample1, $b0 in sample2 
: p_vaddr  ( hi lo -- ) , , ; \ Elf64_Addr Virtual address in memory 	$400000 in sample1, $4000b0 in sample2
: p_paddr ( -- ) , ,  ;	\ Elf64_Addr Reserved  $400000 in sample1, $4000b0 in sample2
: p_filesz ( hi lo -- ) , ,  ; \ Elf64_Xword Size  of  segment  in  file $f0 in sample1, $24 in sample 2
: p_memsz ( hi lo -- ) , ,  ; \ Elf64_Xword Size  of  segment  in  memory $f0 in sample1, $24 in sample 2
: p_align ( hi lo -- ) , ,  ; \ Elf64_Xword Alignment  of  segment	$200000 in sample1, $04 in sample 2

: program-header ( 
	mem_align memsize filesize	
	hi_paddr lo_paddr
	hi_vaddr lo_vaddr
	hi_offset lo_offset
	flags type )
	p_type p_flags
	p_offset
	p_vaddr
	p_paddr
	p_filesz
	p_memsz
	p_align ;


\ string table

: string-table
	0 , ;	\ first string is alway null 0
