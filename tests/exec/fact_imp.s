	.text
	.globl	main
fact_imp:
	pushq %rbp
	movq %rsp, %rbp
	movq %rdi, %r9
	movq $1, %rax
	movq %rax, %r10
L9:
	movq %r9, %r10
	movq $1, %r8
	cmpq %r8, %r10
	setg %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L23
	movq %rbp, %rsp
	popq %rbp
	ret
L23:
	movq %r9, %r10
	movq $1, %r8
	subq %r8, %r10
	movq %r10, %r9
	movq $1, %r8
	addq %r8, %r10
	imulq %r10, %rax
	movq %rax, %r10
	jmp L9
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $0, %rdi
	call fact_imp
	movq %rax, %r10
	movq $1, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L52
L50:
	movq $1, %rdi
	call fact_imp
	movq %rax, %r10
	movq $1, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L43
L41:
	movq $5, %rdi
	call fact_imp
	movq %rax, %r10
	movq $120, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L34
L32:
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L34:
	movq $51, %rdi
	call putchar
	movq %rax, %r10
	jmp L32
L43:
	movq $50, %rdi
	call putchar
	movq %rax, %r10
	jmp L41
L52:
	movq $49, %rdi
	call putchar
	movq %rax, %r10
	jmp L50
	.data
