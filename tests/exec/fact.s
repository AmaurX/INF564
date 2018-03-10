	.text
	.globl	main
fact:
	pushq %rbp
	movq %rsp, %rbp
	addq $-24, %rsp
	movq %rdi, %r10
	movq $1, %r8
	setle %r8b
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-24, %rsp
	movq $0, %r10
	movq %r10, -8(%rsp)
	movq -8(%rsp), %r10
	movq $4, %r8
	setle %r8b
	.data
