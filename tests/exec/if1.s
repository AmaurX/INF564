	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $65, %r10
	movq %r10, -8(%rbp)
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	testq %r10, %r10
	jnz L63
L60:
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	testq %r10, %r10
	jnz L55
	movq $0, %r10
L52:
	testq %r10, %r10
	jnz L50
L47:
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	testq %r10, %r10
	jnz L42
	movq $0, %r10
L39:
	testq %r10, %r10
	jnz L37
L34:
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	testq %r10, %r10
	jz L29
	movq $1, %r10
L26:
	testq %r10, %r10
	jnz L24
L21:
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	testq %r10, %r10
	jz L16
	movq $1, %r10
L13:
	testq %r10, %r10
	jnz L11
L8:
	movq -8(%rbp), %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L11:
	movq $70, %r10
	movq %r10, -8(%rbp)
	jmp L8
L16:
	movq $1, %r10
	cmpq $0, %r10
	setne %r10b
	jmp L13
L24:
	movq $69, %r10
	movq %r10, -8(%rbp)
	jmp L21
L29:
	movq $0, %r10
	cmpq $0, %r10
	setne %r10b
	jmp L26
L37:
	movq $68, %r10
	movq %r10, -8(%rbp)
	jmp L34
L42:
	movq $1, %r10
	cmpq $0, %r10
	setne %r10b
	jmp L39
L50:
	movq $67, %r10
	movq %r10, -8(%rbp)
	jmp L47
L55:
	movq $0, %r10
	cmpq $0, %r10
	setne %r10b
	jmp L52
L63:
	movq $66, %r10
	movq %r10, -8(%rbp)
	jmp L60
	.data
