	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $10, %r10
	movq %r10, -8(%rbp)
L15:
	movq -8(%rbp), %r8
	movq $1, %r10
	subq %r10, %r8
	movq %r8, %r10
	movq %r10, -8(%rbp)
	incq %r10
	testq %r10, %r10
	jnz L19
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L19:
	movq -8(%rbp), %rdi
	addq $65, %rdi
	call putchar
	movq %rax, %r10
	jmp L15
	.data
