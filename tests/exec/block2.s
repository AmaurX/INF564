	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq $65, %r10
	movq %r10, -16(%rsp)
	movq -16(%rsp), %rdi
	call putchar
	movq %rax, %r10
	movq $0, %r10
	.data
