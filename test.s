	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $10, %rdi
	movq %rdi, %r10
	movq $5, %r10
	movq %r10, -8(%rsp)
	movq %rdi, %rax
	movq -8(%rsp), %r10
	cqto
	idivq %r10
	movq %rax, %rdi
	movq $65, %r10
	addq %r10, %rdi
	movq $5, %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $5, %rax
	movq -8(%rsp), %r10
	addq %r10, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
