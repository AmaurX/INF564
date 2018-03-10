	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $1, %r10
	movq %r10, %r8
	movq $65, %rdi
	addq %r10, %rdi
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
