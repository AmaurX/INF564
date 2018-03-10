	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $65, %r10
	movq %r10, -8(%rsp)
	movq -8(%rsp), %rdi
	call putchar
	movq %rax, %r10
	movq $1, %r10
	.data
