	.text
	.globl	main
f:
	pushq %rbp
	movq %rsp, %rbp
	addq $-32, %rsp
	movq %rcx, -32(%rsp)
	movq %rdx, -24(%rsp)
	movq %rsi, -16(%rsp)
	movq %rdi, -8(%rsp)
	movq -8(%rsp), %r10
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-32, %rsp
	movq $65, %rdi
	movq $66, %rsi
	movq $67, %rdx
	movq $0, %rcx
	call f
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
