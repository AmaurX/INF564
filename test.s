	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $30, %r10
	movq %r10, %r8
	movq $20, %r8
	movq %r8, %r9
	cmpq %r8, %r10
	setl %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L14
	movq $100, %r10
	movq %r10, %r8
L11:
	movq $1, %rdi
	movq $2, %r10
	cmpq %r10, %rdi
	sete %r11b
	movzbq %r11b, %rdi
	addq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L14:
	movq $10, %r10
	jmp L11
	.data
