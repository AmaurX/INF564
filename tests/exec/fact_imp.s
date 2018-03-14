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
	jnz L22
	movq %rbp, %rsp
	popq %rbp
	ret
L22:
	movq %r8, %r10
	movq $1, %r8
	subq %r8, %r10
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
	jnz L51
L49:
	movq $1, %rdi
	call fact_imp
	movq %rax, %r10
	movq $1, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L42
L40:
	movq $5, %rdi
	call fact_imp
	movq %rax, %r10
	movq $120, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L33
L31:
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L33:
	movq $51, %rdi
	call putchar
	movq %rax, %r10
	jmp L31
L42:
	movq $50, %rdi
	call putchar
	movq %rax, %r10
	jmp L40
L51:
	movq $49, %rdi
	call putchar
	movq %rax, %r10
	jmp L49
	.data
