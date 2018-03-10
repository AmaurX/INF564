	.text
	.globl	main
many:
	pushq %rbp
	movq %rsp, %rbp
	addq $-120, %rsp
	movq 40(%rsp), %r15
	movq %r15, -16(%rsp)
	movq 32(%rsp), %r15
	movq %r15, -8(%rsp)
	movq 24(%rsp), %r15
	movq %r15, -112(%rsp)
	movq 16(%rsp), %r15
	movq %r15, -104(%rsp)
	movq %r9, -80(%rsp)
	movq %r8, -72(%rsp)
	movq %rcx, -64(%rsp)
	movq %rdx, -56(%rsp)
	movq %rsi, -48(%rsp)
	movq %rdi, -40(%rsp)
	movq $64, %rdi
	movq -40(%rsp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -48(%rsp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -56(%rsp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -64(%rsp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -72(%rsp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -80(%rsp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -104(%rsp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -112(%rsp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -8(%rsp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -16(%rsp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq -40(%rsp), %r10
	movq $10, %r8
	setl %r8b
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-120, %rsp
	movq $1, %rdi
	movq $2, %rsi
	movq $3, %rdx
	movq $4, %rcx
	movq $5, %r8
	movq $6, %r9
	movq $7, -96(%rsp)
	movq $8, -88(%rsp)
	movq $9, %rax
	movq $10, %r10
	pushq %r10
	pushq %rax
	pushq -88(%rsp)
	pushq -96(%rsp)
	call many
	movq %rax, %r10
	addq $32, %rsp
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
