	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $0, %r10
	movq %r10, -8(%rsp)
	movq $1, %r10
	movq %r10, %r8
	movq $1, %r8
	sete %r8b
	.data
