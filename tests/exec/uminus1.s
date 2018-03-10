	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $66, %rdi
	movq $1, %r8
	movq $0, %r10
	subq %r8, %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $65, %rdi
	movq $1, %r10
	movq $0, %r8
	subq %r10, %r8
	movq $0, %r10
	subq %r8, %r10
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
