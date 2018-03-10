	.text
	.globl	main
fact_rec:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %rdi, %r10
	movq $1, %r8
	setle %r8b
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $0, %rdi
	call fact_rec
	movq %rax, %r10
	movq $1, %r8
	sete %r8b
	.data
