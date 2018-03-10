	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	movq $104, %rdi
	call putchar
	movq %rax, %r10
	movq $101, %rdi
	call putchar
	movq %rax, %r10
	movq $108, %rdi
	call putchar
	movq %rax, %r10
	movq $108, %rdi
	call putchar
	movq %rax, %r10
	movq $111, %rdi
	call putchar
	movq %rax, %r10
	movq $32, %rdi
	call putchar
	movq %rax, %r10
	movq $119, %rdi
	call putchar
	movq %rax, %r10
	movq $111, %rdi
	call putchar
	movq %rax, %r10
	movq $114, %rdi
	call putchar
	movq %rax, %r10
	movq $108, %rdi
	call putchar
	movq %rax, %r10
	movq $100, %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
