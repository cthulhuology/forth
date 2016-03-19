requires elf

\ $ rm dyn

\ this is a small program that returns 42 via exit syscall
here
$48 c, $c7 c, $c0 c, $3c c, $00 c, $00 c, $00 c, $48 c, 
$c7 c, $c7 c, $2a c, $00 c, $00 c, $00 c, $0f c, $05 c,

\ this compiles the minimal elf file with the above program
$10 s" dyn" dynelf 
\ $ chmod u+x dyn

bye
