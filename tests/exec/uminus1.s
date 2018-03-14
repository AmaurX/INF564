	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $1, %r10
	movq $0, %rdi
	subq %r10, %rdi
	addq $66, %rdi
	call putchar
	movq %rax, %r10
	movq $1, %r8
	movq $0, %r10
	subq %r8, %r10
	movq $0, %rdi
	subq %r10, %rdi
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
