	.text
	.globl	main
fact_imp:
	pushq %rbp
	movq %rsp, %rbp
	movq %rdi, %r9
	movq $1, %rax
	movq %rax, %r10
	movq %r9, %r10
	movq $1, %r8
	setg %r8b
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $0, %rdi
	call fact_imp
	movq %rax, %r10
	movq $1, %r8
	sete %r8b
	.data
