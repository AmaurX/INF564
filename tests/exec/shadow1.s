	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $0, %r10
	movq %r10, -8(%rbp)
	movq $1, %r10
	movq %r10, %r8
	movq $1, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L16
L14:
	movq -8(%rbp), %r8
	movq $0, %r10
	cmpq %r10, %r8
	sete %r11b
	movzbq %r11b, %r8
	movq %r8, %r10
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
	movq $98, %rdi
	call putchar
	movq %rax, %r10
	jmp L6
L16:
	movq $97, %rdi
	call putchar
	movq %rax, %r10
	jmp L14
	.data
