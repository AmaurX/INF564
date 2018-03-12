	.text
	.globl	main
fact:
	pushq %rbp
	movq %rsp, %rbp
	addq $-24, %rsp
	movq %rdi, %r10
	movq $1, %r8
	cmpq %r8, %r10
	setle %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L13
	movq %rdi, -24(%rbp)
	movq $1, %r10
	subq %r10, %rdi
	call fact
	movq %rax, %r10
	movq -24(%rbp), %r15
	imulq %r10, %r15
	movq %r15, -24(%rbp)
	movq -24(%rbp), %rax
L1:
	movq %rbp, %rsp
	popq %rbp
	ret
L13:
	movq $1, %rax
	jmp L1
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-24, %rsp
	movq $0, %r10
	movq %r10, -8(%rbp)
L30:
	movq -8(%rbp), %r10
	movq $4, %r8
	cmpq %r8, %r10
	setle %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L42
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L42:
	movq $65, -16(%rbp)
	movq -8(%rbp), %rdi
	call fact
	movq %rax, %r10
	addq %r10, -16(%rbp)
	movq -16(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	movq $1, %r8
	addq %r8, %r10
	movq %r10, -8(%rbp)
	jmp L30
	.data
