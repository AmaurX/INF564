	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $102, %rdi
	decq %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
