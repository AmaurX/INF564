	.text
	.globl	main
fact_imp:
	pushq %rbp
	movq %rsp, %rbp
	movq %rdi, %r8
	movq $1, %rax
	movq %rax, %r10
L9:
	movq %r8, %r10
	movq $1, %r9
	cmpq %r9, %r10
	setg %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L21
	movq %rbp, %rsp
	popq %rbp
	ret
L21:
	movq %r8, %r10
	decq %r10
	movq %r10, %r8
	incq %r10
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
	jnz L50
L48:
	movq $1, %rdi
	call fact_imp
	movq %rax, %r10
	movq $1, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L41
L39:
	movq $5, %rdi
	call fact_imp
	movq %rax, %r10
	movq $120, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L32
L30:
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L32:
	movq $51, %rdi
	call putchar
	movq %rax, %r10
	jmp L30
L41:
	movq $50, %rdi
	call putchar
	movq %rax, %r10
	jmp L39
L50:
	movq $49, %rdi
	call putchar
	movq %rax, %r10
	jmp L48
	.data
