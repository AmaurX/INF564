	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $10, %rax
	movq %rax, %r10
	incq %rax
	movq %rax, %r10
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
