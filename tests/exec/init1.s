	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq %r10, %r8
	sete %r10b
	movq %r8, %r10
	.data
