	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $100, %rdi
	movq $4, %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $102, %rdi
	movq $1, %r10
	subq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $100, %rdi
	movq $2, %r10
	movq $4, %r8
	imulq %r8, %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $216, %rax
	movq $2, %r10
	cqto
	idivq %r10
	movq %rax, %rdi
	call putchar
	movq %rax, %r10
	movq $3, %rdi
	movq $37, %r10
	imulq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $32, %rdi
	call putchar
	movq %rax, %r10
	movq $118, %rdi
	movq $1, %r8
	movq $2, %r10
	subq %r10, %r8
	movq $0, %r10
	subq %r8, %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $100, %rdi
	movq $122, %rax
	movq $11, %r10
	cqto
	idivq %r10
	addq %rax, %rdi
	call putchar
	movq %rax, %r10
	movq $113, %rdi
	movq $1, %r10
	movq $2, %r8
	setl %r8b
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $108, %rdi
	movq $2, %r10
	movq $1, %r8
	setl %r8b
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $99, %rdi
	movq $2, %r10
	movq $1, %r8
	movq $1, %r9
	addq %r9, %r8
	sete %r8b
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	movq $1, %r10
	movq $2, %r8
	sete %r8b
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
