	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq $16, %rdi
	call sbrk
	movq %rax, %r10
	movq %r10, -8(%rsp)
	movq -8(%rsp), %r10
	movq %r10, -16(%rsp)
	movq $65, %r10
	movq -16(%rsp), %r8
	movq %r10, 0(%r8)
	movq -8(%rsp), %r10
	movq 0(%r10), %rdi
	call putchar
	movq %rax, %r10
	movq -16(%rsp), %r10
	movq 0(%r10), %rdi
	call putchar
	movq %rax, %r10
	movq $66, %r10
	movq -16(%rsp), %r8
	movq %r10, 8(%r8)
	movq -8(%rsp), %r10
	movq 8(%r10), %rdi
	call putchar
	movq %rax, %r10
	movq -16(%rsp), %r10
	movq 8(%r10), %rdi
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
