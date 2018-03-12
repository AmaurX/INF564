	.text
	.globl	main
f:
	pushq %rbp
	movq %rsp, %rbp
	addq $-32, %rsp
	movq %rcx, -32(%rbp)
	movq %rdx, -24(%rbp)
	movq %rsi, -16(%rbp)
	movq %rdi, -8(%rbp)
	movq -8(%rbp), %r10
	cmpq $0, %r10
	sete %r10b
	testq %r10, %r10
	jnz L12
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -16(%rbp), %rdi
	movq -24(%rbp), %rsi
	movq -32(%rbp), %rdx
	movq -8(%rbp), %rcx
	call f
L1:
	movq %rbp, %rsp
	popq %rbp
	ret
L12:
	movq $10, %rax
	jmp L1
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-32, %rsp
	movq $65, %rdi
	movq $66, %rsi
	movq $67, %rdx
	movq $0, %rcx
	call f
	movq %rax, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
