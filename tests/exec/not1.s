	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $65, %rdi
	movq $0, %r10
	cmpq $0, %r10
	sete %r10b
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $65, %rdi
	movq $1, %r10
	cmpq $0, %r10
	sete %r10b
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
