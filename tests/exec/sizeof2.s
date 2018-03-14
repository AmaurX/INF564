	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $8, %rdi
	addq $65, %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $16, %rdi
	addq $65, %rdi
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
