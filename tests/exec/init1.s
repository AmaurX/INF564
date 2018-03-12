	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq %r10, %r8
	cmpq %r10, %r8
	sete %r11b
	movzbq %r11b, %r8
	movq %r8, %r10
	testq %r10, %r10
	jnz L8
L6:
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L8:
	movq $97, %rdi
	call putchar
	movq %rax, %r10
	jmp L6
	.data
