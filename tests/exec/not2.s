	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $0, %rdi
	movq %rdi, %r10
	cmpq $0, %rdi
	sete %dil
	addq $65, %rdi
	call putchar
	movq %rax, %r10
	movq $1, %rdi
	movq %rdi, %r10
	cmpq $0, %rdi
	sete %dil
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
