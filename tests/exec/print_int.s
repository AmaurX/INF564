	.text
	.globl	main
print_int:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rdi, -8(%rsp)
	movq -8(%rsp), %rax
	movq $10, %r10
	cqto
	idivq %r10
	movq %rax, -16(%rsp)
	movq -8(%rsp), %r10
	movq $9, %r8
	setg %r8b
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq $42, %rdi
	call print_int
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
