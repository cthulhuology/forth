

requires core
requires elf


create elf
\ elf header
0		\ shstrndx none
1		\ one section header for .text
$40		\ size of section header
1		\ one program header
$38		\ program header is $38 bytes long
$40		\ elf header is $40 bytes
0 $80		\ section header offset
0 $40		\ program header offset
0 $400100	\ entry point
elf-header

\ program header
0 $20000 	\ align
0 $110 		\ memsize
0 $110		\ filesize
0 $400000	\ paddr 
0 $400000	\ vaddr 
0 0 		\ offset (start of elf file)
PF_X PF_R or 	\ flags
PT_LOAD		\ type
program-header

0 , 0 , 	\ padding to $80

\ sections
first-section
0 0 		\ entsize
0 0		\ addr align
0 0		\ info link
0 $10		\ size
0 $100		\ offset
0 $400100	\ addr
0 SHF_ALLOC SHF_EXECINSTR or	\ flags
SHT_PROGBITS 0	\ type name
section

\ should be at addr $100,  returns 42 via syscall

$48 c, $c7 c, $c0 c, $3c c, $00 c, $00 c, $00 c, $48 c, 
$c7 c, $c7 c, $2a c, $00 c, $00 c, $00 c, $0f c, $05 c,

0 value fd
elf $110 s" test-elf" W/O create-file .  write-file
bye
