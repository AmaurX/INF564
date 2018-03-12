	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq $65, %r10
	movq %r10, -8(%rbp)
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	movq $1, %r8
	addq %r8, %r10
	movq %r10, -8(%rbp)
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	movq $1, %r8
	addq %r8, %r10
	movq %r10, -16(%rbp)
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -16(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
