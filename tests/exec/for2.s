	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $10, %r10
	movq %r10, -8(%rbp)
L11:
	movq -8(%rbp), %r10
	movq $0, %r8
	cmpq %r8, %r10
	setg %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L21
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L21:
	movq -8(%rbp), %rdi
	decq %rdi
	movq %rdi, -8(%rbp)
	addq $65, %rdi
	incq %rdi
	call putchar
	movq %rax, %r10
	jmp L11
	.data
