	.text
	.globl	main
f:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %rsi, %r10
	movq %rdi, %rax
	addq %r10, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $65, %rdi
	movq $0, %rsi
	call f
	movq %rax, %rdi
	call putchar
	movq %rax, %r10
	movq $65, %rdi
	movq $1, %rsi
	call f
	movq %rax, %rdi
	call putchar
	movq %rax, %r10
	movq $65, %rdi
	movq $2, %rsi
	call f
	movq %rax, %rdi
	call putchar
	movq %rax, %r10
	movq $65, %rdi
	movq $3, %rsi
	call f
	movq %rax, %r10
	movq %r10, -8(%rbp)
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	movq $1, %r8
	addq %r8, %r10
	movq %r10, -8(%rbp)
	movq -8(%rbp), %rdi
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
