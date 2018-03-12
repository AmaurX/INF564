	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $0, %r10
	movq %r10, %r8
	movq $0, %rax
	movq %rax, %r8
L19:
	movq %rax, %r8
	movq $10, %r9
	cmpq %r9, %r8
	setl %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	jnz L45
	movq $100, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L8
L6:
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L8:
	movq $33, %rdi
	call putchar
	movq %rax, %r10
	jmp L6
L45:
	movq $10, %r8
	movq %r8, %r9
L30:
	movq %r8, %r9
	movq $0, %rcx
	cmpq %rcx, %r9
	setg %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jnz L42
	movq %rax, %r8
	movq $1, %r9
	addq %r9, %r8
	movq %r8, %rax
	jmp L19
L42:
	movq $1, %r9
	addq %r9, %r10
	movq %r10, %r9
	movq $1, %r9
	subq %r9, %r8
	movq %r8, %r9
	jmp L30
	.data
