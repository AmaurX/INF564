	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $1, %rax
	movq $0, %r10
	cqto
	idivq %r10
	movq %rax, %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rsp), %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
