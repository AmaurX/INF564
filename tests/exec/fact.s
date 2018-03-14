	.text
	.globl	main
fact:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rdi, %r10
	movq $1, %r8
	cmpq %r8, %r10
	setle %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L12
	movq %rdi, -16(%rbp)
	decq %rdi
	call fact
	movq %rax, %r10
	movq -16(%rbp), %r15
	imulq %r10, %r15
	movq %r15, -16(%rbp)
	movq -16(%rbp), %rax
L1:
	movq %rbp, %rsp
	popq %rbp
	ret
L12:
	movq $1, %rax
	jmp L1
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq $0, %r10
	movq %r10, -8(%rbp)
L29:
	movq -8(%rbp), %r10
	movq $4, %r8
	cmpq %r8, %r10
	setle %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L39
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L39:
	movq -8(%rbp), %rdi
	call fact
	movq %rax, %rdi
	addq $65, %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	incq %r10
	movq %r10, -8(%rbp)
	jmp L29
	.data
