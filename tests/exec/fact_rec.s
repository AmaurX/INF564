	.text
	.globl	main
fact_rec:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %rdi, %r10
	movq $1, %r8
	cmpq %r8, %r10
	setle %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L13
	movq %rdi, -8(%rbp)
	movq $1, %r10
	subq %r10, %rdi
	call fact_rec
	movq %rax, %r10
	movq -8(%rbp), %r15
	imulq %r10, %r15
	movq %r15, -8(%rbp)
	movq -8(%rbp), %rax
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
	addq $-8, %rsp
	movq $0, %rdi
	call fact_rec
	movq %rax, %r10
	movq $1, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L45
L43:
	movq $1, %rdi
	call fact_rec
	movq %rax, %r10
	movq $1, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L36
L34:
	movq $5, %rdi
	call fact_rec
	movq %rax, %r10
	movq $120, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L27
L25:
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L27:
	movq $51, %rdi
	call putchar
	movq %rax, %r10
	jmp L25
L36:
	movq $50, %rdi
	call putchar
	movq %rax, %r10
	jmp L34
L45:
	movq $49, %rdi
	call putchar
	movq %rax, %r10
	jmp L43
	.data
