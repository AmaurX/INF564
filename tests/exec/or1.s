	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $65, %rdi
	movq $1, %r10
	testq %r10, %r10
	jz L42
	movq $1, %r10
L39:
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $65, %rdi
	movq $0, %r10
	testq %r10, %r10
	jz L32
	movq $1, %r10
L29:
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $65, %rdi
	movq $1, %r10
	testq %r10, %r10
	jz L22
	movq $1, %r10
L19:
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $65, %rdi
	movq $0, %r10
	testq %r10, %r10
	jz L12
	movq $1, %r10
L9:
	addq %r10, %rdi
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
	movq $0, %r10
	cmpq $0, %r10
	setne %r10b
	jmp L9
L22:
	movq $0, %r10
	cmpq $0, %r10
	setne %r10b
	jmp L19
L32:
	movq $2, %r10
	cmpq $0, %r10
	setne %r10b
	jmp L29
L42:
	movq $1, %r10
	cmpq $0, %r10
	setne %r10b
	jmp L39
	.data
