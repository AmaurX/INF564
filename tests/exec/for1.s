	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $0, %r10
	movq %r10, %r8
	movq $0, %rax
	movq %rax, %r8
	movq %rax, %r8
	movq $10, %r9
	setl %r9b
	.data
