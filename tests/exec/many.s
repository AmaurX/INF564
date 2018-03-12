	.text
	.globl	main
many:
	pushq %rbp
	movq %rsp, %rbp
	addq $-120, %rsp
	movq 40(%rbp), %r15
	movq %r15, -16(%rbp)
	movq 32(%rbp), %r15
	movq %r15, -8(%rbp)
	movq 24(%rbp), %r15
	movq %r15, -112(%rbp)
	movq 16(%rbp), %r15
	movq %r15, -104(%rbp)
	movq %r9, -80(%rbp)
	movq %r8, -72(%rbp)
	movq %rcx, -64(%rbp)
	movq %rdx, -56(%rbp)
	movq %rsi, -48(%rbp)
	movq %rdi, -40(%rbp)
	movq $64, %rdi
	movq -40(%rbp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -48(%rbp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -56(%rbp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -64(%rbp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -72(%rbp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -80(%rbp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -104(%rbp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -112(%rbp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -8(%rbp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $64, %rdi
	movq -16(%rbp), %r10
	addq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq -40(%rbp), %r10
	movq $10, %r8
	cmpq %r8, %r10
	setl %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L15
L4:
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L15:
	movq -48(%rbp), %rdi
	movq -56(%rbp), %rsi
	movq -64(%rbp), %rdx
	movq -72(%rbp), %rcx
	movq -80(%rbp), %r8
	movq -104(%rbp), %r9
	movq -112(%rbp), %r15
	movq %r15, -32(%rbp)
	movq -8(%rbp), %r15
	movq %r15, -24(%rbp)
	movq -16(%rbp), %rax
	movq -40(%rbp), %r10
	pushq %r10
	pushq %rax
	pushq -24(%rbp)
	pushq -32(%rbp)
	call many
	movq %rax, %r10
	addq $32, %rsp
	jmp L4
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
	movq $7, -96(%rbp)
	movq $8, -88(%rbp)
	movq $9, %rax
	movq $10, %r10
	pushq %r10
	pushq %rax
	pushq -88(%rbp)
	pushq -96(%rbp)
	call many
	movq %rax, %r10
	addq $32, %rsp
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
