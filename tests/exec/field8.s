	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $16, %rdi
	call sbrk
	movq %rax, %r10
	movq %r10, -8(%rbp)
	movq $65, %r10
	movq -8(%rbp), %r8
	movq %r10, 0(%r8)
	movq -8(%rbp), %r10
	movq 0(%r10), %rdi
	call putchar
	movq %rax, %r10
	movq $66, %r8
	movq -8(%rbp), %r10
	movq %r8, 8(%r10)
	movq -8(%rbp), %r10
	movq 8(%r10), %rdi
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
