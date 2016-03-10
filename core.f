\ core.f
\
\ x86_64 virtual machine instructions
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

requires dict

\ Register allocation
\
\ rax - tos, arg0 (syscall)
\ rcx - counter, arg4
\ rdx - port, scratch, arg3
\ rbx - scratch, reserved
\ rsp - return stack, reserved
\ rbp - data stack, reserved
\ rsi - source addr, arg2
\ rdi - dest addr, arg1
\ r8  - arg5
\ r9  - arg6
\ r10 - scratch
\ r11 - scratch
\ r12 - scratch, reserved
\ r13 - scratch, reserved
\ r14 - scratch, reserved
\ r15 - scratch, reserved

\ defines an opcode for the opcodes table
: opc	parse-word number dup ,			\ store opcode byte count
	dup >r					\ squirrel away count for later
	0 do parse-word number c, loop 		\ assemble opcode table
	12 r> - 0 do 0 c, loop 			\ pad out to 16 bytes
	; immediate

\ C calls use  rdi, rsi, rdx, rcx, r8, r9, then return stack in rev order

create opcodes

\ length	data						op	comment

	\ literal
opc	10	$48 $b8 $00 $00 $00 $00 $00 $00 $00 $00 \	lit	mov rax,imm64
opc	7	$48 $c7 $c0 $00 $00 $00 $00		\	lit32	mov rax,imm32

	\ call / return
opc	5	$e8 $00 $00 $00 $00			\	word	call imm32
opc	6	$0f $84 $00 $00 $00 $00			\	0=?	jz imm32
opc	6	$0f $88 $00 $00 $00 $00			\	0<?	js imm32
opc	2	$ff $e0					\	jump	jmp rax
opc	2	$ff $d0					\ 	call	call rax		
opc	1	$c3					\	;	ret
opc	1	$90					\	nop	nop

	\ offset math
opc	3	$48 $ff $c0				\	+1	inc rax
opc	4	$48 $8d $40 $02				\	+2	lea rax,[rax+2]
opc	4	$48 $8d $40 $03				\	+3	lea rax,[rax+3]
opc	4	$48 $8d $40 $04				\	+4	lea rax,[rax+4]
opc	4	$48 $8d $40 $08				\	+8	lea rax,[rax+8]
opc	3	$48 $ff $c8				\	-1	dec rax
opc	4	$48 $8d $40 $fe 			\	-2	lea rax,[rax-2]
opc	4	$48 $8d $40 $fd 			\	-3	lea rax,[rax-3]
opc	4	$48 $8d $40 $fc 			\	-4	lea rax,[rax-4]
opc	4	$48 $8d $40 $f8 			\	-8	lea rax,[rax-8]

	\ return stack juggling
opc	1	$58					\	r>	pop rax
opc	1	$50					\	>r	push rax
opc	3	$48 $89 $e0				\	rp>	mov rax,rsp
opc	3	$48 $89 $c4				\	>rp	mov rsp,rax

	\ auto increment fetch /store
opc	1	$fd					\	std	std		
opc	1	$fc					\	cld	cld		
opc	3	$48 $89 $f0				\	s>	mov rax,rsi
opc	3	$48 $89 $c6				\	>s	mov rsi,rax
opc	3	$48 $89 $f8				\	d>	mov rax,rdi
opc	3	$48 $89 $c7				\	>d	mov rdi,rax
opc	1	$ac					\	c@+	lodsb
opc	2	$66 $ad					\	w@+	lodsw
opc	1	$ad					\	d@+	lodsd
opc	2	$48 $ad					\	@+	lodsq
opc	1	$aa					\	c!+	stosb
opc	2	$66 $ab					\	w!+	stosw
opc	1	$ab					\	d!+	stosd
opc	1	$48 $ab					\	!+	stosd

	\ memory access
opc	2	$8a $02					\	c@	mov al,[rdx]
opc	4	$66 $0f $b6 $02				\	u@	movzx ax,[rdx]
opc	4	$66 $0f $be $02				\	h@	movsx ax,[rdx]	
opc	3	$48 $8b $00				\	@	mov rax,[rax]
opc	2	$88 $02					\	c!	mov [rdx],cl
opc	3	$66 $89 $02				\	h!	mov [rdx],ax
opc	2	$89 $02					\	d!	mov [rdx],eax
opc	3	$48 $89 $02				\	!	mov [rdx],rax
opc	3	$48 $89 $10				\	~!	mov [rax],rdx

	\ stack juggling
opc	4	$48 $8b $45 $00 			\	>a	mov rax,[rbp]
opc	4	$48 $89 $45 $00				\	a>	mov [rbp],rax
opc	4	$48 $8b $55 $00				\	>x	mov rdx,[rbp]
opc	4	$48 $89 $55 $00				\	x>	mov [rbp],rdx
opc	3	$48 $89 $c5				\	>sp	mov rbp,rax
opc	3	$48 $89 $e8				\	sp>	mov rax,rbp
opc	4	$48 $8d $6d $08				\	+sp	lea rbp,[rbp+8]
opc	3	$48 $8d $6d $f8				\	-sp	lea rbp,[rbp-8]
opc	4	$48 $87 $45 $00				\	swap	xchg rax,[rbp]

	\ math
opc	3	$48 $31 $c0				\	0a	xor rax,rax
opc	3	$48 $31 $d2				\	0x	xor rdx,rdx
opc	4	$48 $03 $45 $00				\	+	add rax,[rbp]
opc	4	$48 $f7 $6d $00				\	*	imul [rbp]
opc	4	$48 $f7 $65 $00				\	u*	mul [rbp]
opc	3	$48 $f7 $d8				\	negate	neg rax
opc	4	$48 $f7 $7d $00 			\	~/mod	idiv [rbp]

	\ logic
opc	3	$48 $f7 $d0				\	not	not rax
opc	4	$48 $23 $45 $00				\	and	and rax,[rbp]
opc	4	$48 $0b $45 $00				\	or	or rax,[rbp]
opc	4	$48 $33 $45 $00				\	xor	xor rax,[rbp]

	\ bit shift
opc	3	$48 $d1 $e0				\	2*	shl rax,1
opc	3	$48 $c1 $e0 $02 			\	4*	shl rax,2
opc	3	$48 $c1 $e0 $03 			\	8*	shl rax,3
opc	3	$48 $c1 $e0 $08 			\	<<	shl rax,8
opc	3	$48 $d1 $e8				\	2/	shr rax,1
opc	3	$48 $c1 $e8 $02				\	4/	shr rax,2
opc	3	$48 $c1 $e8 $03				\	8/	shr rax,3
opc	3	$48 $c1 $e8 $08				\	>>	shr rax,3
opc	3	$48 $89 $c1 				\	>c	mov rcx,rax
opc	3	$48 $89 $c8				\	c>	mov rax,rcx
opc	3	$48 $d3 $e0				\	lshift	shl rax,cl
opc	3	$48 $d3 $e8				\	rshift	shr rax,cl
opc	3	$48 $d3 $f8				\	rshifta	sar rax,cl

	\ ports
opc	1	$ee					\	outb	out dx,al
opc	2	$66 $ef					\	outw	out dx,ax
opc	1	$ef					\	outd	out dx,eax
opc	1	$ec					\	inb	in al,dx
opc	2	$66 $ed					\	inw	in ax,dx
opc	1	$ed					\	ind	in eax,dx

	\ comparison & test
opc	3	$48 $85 $c0				\	?	test rax,rax
opc	4	$48 $3b $45 $00				\	<=>	cmp rax,[rbp]

	\ arguments
opc	2	$0f $05					\	syscall	syscall
opc	4 	$48 $8b $7d $00				\	arg1	mov rdi,[rbp] 
opc	4	$48 $8b $75 $f8				\	arg2	mov rsi,[rbp-8]
opc	4	$48 $8b $55 $f0				\	arg3	mov rdx,[rbp-16]
opc	4	$4c $8b $55 $e8				\	arg4	mov r10,[rbp-24]
opc	4	$4c $8b $45 $e0				\	arg5	mov r8,[rbp-32]
opc	4	$4c $8b $4d $d8				\	arg6	mov r9,[rbp-40]

create end-opcodes 0 ,

\ fetch a bye from addr, and leave addr+1 and byte on stack
ICODE c@+ ( addr -- a+1 n )
	PUSH(EBX)                      \ save addr on stack
	0 [EBX] AL MOV                 \ read value from addr to tos
	EAX EBX MOV
	1 # 0 [EBP] ADD                \ increment address
	RET   END-CODE

\ assembles an instruction given an opcode table index
: ins ( n -- )
	16 * opcodes + dup 4+ swap @	\ addr len
	0 do c@+ c,exec loop ;

\ patches the last byte
: patch1 ( c -- )
	exec-here 1 - ! ;

\ patches an address into the last 4 bytes
: patch4 ( addr -- )
	exec-here 4 - ! ;

\ ptaches a 64 bit value
: patch8 ( high low -- )
	exec-here 8 - ~!+ ~!+ ;

