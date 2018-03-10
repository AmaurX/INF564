	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $10, %r10
	movq %r10, -8(%rsp)
	movq -8(%rsp), %r10
	movq $0, %r8
	setg %r8b
	.data
