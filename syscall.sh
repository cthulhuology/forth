#!/bin/bash
cat /usr/include/asm/unistd_64.h | grep "__NR_" | sed 's%.* __NR_%_%g' | grep -v '#define' | grep -v SYSCALL | grep -v ifndef | grep -v endif | grep -v '\*' | awk '{ print $2, "constant", _$1 }' > syscall.f
