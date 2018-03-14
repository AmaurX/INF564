	.text
	.globl	main
print_int:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rdi, -8(%rbp)
	movq -8(%rbp), %rax
	movq $10, %r10
	cqto
	idivq %r10
	movq %rax, -16(%rbp)
	movq -8(%rbp), %r10
	movq $9, %r8
	cmpq %r8, %r10
	setg %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L16
L14:
	movq -8(%rbp), %rdi
	movq $10, %r10
	movq -16(%rbp), %r8
	imulq %r8, %r10
	subq %r10, %rdi
	addq $48, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L16:
	movq -16(%rbp), %rdi
	call print_int
	movq %rax, %r10
	jmp L14
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
