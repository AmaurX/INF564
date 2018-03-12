	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq $65, %r10
	movq %r10, -16(%rbp)
	movq -16(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq $0, %r10
	testq %r10, %r10
	jnz L13
	movq $67, %rdi
	movq %rdi, %r10
	movq $68, %r10
	movq %r10, -8(%rbp)
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
L8:
	movq -16(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L13:
	movq $66, %rdi
	movq %rdi, %r10
	call putchar
	movq %rax, %r10
	jmp L8
	.data
