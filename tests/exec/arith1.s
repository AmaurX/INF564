	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $104, %rdi
	call putchar
	movq %rax, %r10
	movq $101, %rdi
	call putchar
	movq %rax, %r10
	movq $8, %rdi
	addq $100, %rdi
	call putchar
	movq %rax, %r10
	movq $108, %rdi
	call putchar
	movq %rax, %r10
	movq $111, %rdi
	call putchar
	movq %rax, %r10
	movq $32, %rdi
	call putchar
	movq %rax, %r10
	movq $-1, %r10
	movq $0, %rdi
	subq %r10, %rdi
	addq $118, %rdi
	call putchar
	movq %rax, %r10
	movq $11, %rdi
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
	movq $2, %r10
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
