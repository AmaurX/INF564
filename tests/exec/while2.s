	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $10, %r10
	movq %r10, -8(%rsp)
	movq -8(%rsp), %r10
	movq $1, %r8
	subq %r8, %r10
	movq %r10, -8(%rsp)
	.data
