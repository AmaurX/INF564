	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $10, %r10
	movq %r10, -8(%rbp)
L8:
	movq -8(%rbp), %r10
	testq %r10, %r10
	jnz L17
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L17:
	movq -8(%rbp), %r10
	decq %r10
	movq %r10, -8(%rbp)
	movq -8(%rbp), %rdi
	addq $65, %rdi
	call putchar
	movq %rax, %r10
	jmp L8
	.data
