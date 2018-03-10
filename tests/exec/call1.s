	.text
	.globl	main
f:
	pushq %rbp
	movq %rsp, %rbp
	movq %rsi, %r10
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $65, %rdi
	movq $66, %rsi
	call f
	movq %rax, %r10
	movq $66, %rdi
	movq $65, %rsi
	call f
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
