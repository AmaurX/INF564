	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $4, %rdi
	addq $100, %rdi
	call putchar
	movq %rax, %r10
	movq $102, %rdi
	movq $1, %r10
	subq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $2, %rdi
	movq $4, %r10
	imulq %r10, %rdi
	addq $100, %rdi
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
	movq $1, %r10
	movq $2, %r8
	subq %r8, %r10
	movq $0, %rdi
	subq %r10, %rdi
	addq $118, %rdi
	call putchar
	movq %rax, %r10
	movq $122, %rax
	movq $11, %r10
	cqto
	idivq %r10
	movq %rax, %rdi
	addq $100, %rdi
	call putchar
	movq %rax, %r10
	movq $1, %rdi
	movq $2, %r10
	cmpq %r10, %rdi
	setl %r11b
	movzbq %r11b, %rdi
	addq $113, %rdi
	call putchar
	movq %rax, %r10
	movq $2, %rdi
	movq $1, %r10
	cmpq %r10, %rdi
	setl %r11b
	movzbq %r11b, %rdi
	addq $108, %rdi
	call putchar
	movq %rax, %r10
	movq $2, %rdi
	movq $1, %r10
	incq %r10
	cmpq %r10, %rdi
	sete %r11b
	movzbq %r11b, %rdi
	addq $99, %rdi
	call putchar
	movq %rax, %r10
	movq $1, %rdi
	movq $2, %r10
	cmpq %r10, %rdi
	sete %r11b
	movzbq %r11b, %rdi
	addq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
