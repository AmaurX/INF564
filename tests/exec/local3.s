	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $65, %r10
	movq %r10, -8(%rbp)
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %rdi
	incq %rdi
	movq %rdi, -8(%rbp)
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %rdi
	incq %rdi
	movq %rdi, %r10
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
