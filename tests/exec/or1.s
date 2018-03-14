	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $1, %r10
	testq %r10, %r10
	jz L39
	movq $1, %rdi
L36:
	addq $65, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %r10
	testq %r10, %r10
	jz L30
	movq $1, %rdi
L27:
	addq $65, %rdi
	call putchar
	movq %rax, %r10
	movq $1, %r10
	testq %r10, %r10
	jz L21
	movq $1, %rdi
L18:
	addq $65, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %r10
	testq %r10, %r10
	jz L12
	movq $1, %rdi
L9:
	addq $65, %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L12:
	movq $0, %rdi
	cmpq $0, %rdi
	setne %dil
	jmp L9
L21:
	movq $0, %rdi
	cmpq $0, %rdi
	setne %dil
	jmp L18
L30:
	movq $2, %rdi
	cmpq $0, %rdi
	setne %dil
	jmp L27
L39:
	movq $1, %rdi
	cmpq $0, %rdi
	setne %dil
	jmp L36
	.data
