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
	jnz L12
	movq %rdi, -8(%rbp)
	decq %rdi
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
L12:
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
	jnz L44
L42:
	movq $1, %rdi
	call fact_rec
	movq %rax, %r10
	movq $1, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L35
L33:
	movq $5, %rdi
	call fact_rec
	movq %rax, %r10
	movq $120, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L26
L24:
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L26:
	movq $51, %rdi
	call putchar
	movq %rax, %r10
	jmp L24
L35:
	movq $50, %rdi
	call putchar
	movq %rax, %r10
	jmp L33
L44:
	movq $49, %rdi
	call putchar
	movq %rax, %r10
	jmp L42
	.data
