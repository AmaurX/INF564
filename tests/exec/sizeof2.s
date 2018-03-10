	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $65, %rdi
	movq $8, %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $65, %rdi
	movq $16, %r10
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
