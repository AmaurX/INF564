	.text
	.globl	main
add:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rsi, %r10
	movq %rdi, %rax
	addq %r10, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
sub:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rsi, %r10
	movq %rdi, %rax
	subq %r10, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
mul:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rsi, %r8
	movq %rdi, %r10
	imulq %r8, %r10
	movq %r10, %r8
	movq $8192, %rax
	movq $2, %r10
	cqto
	idivq %r10
	addq %rax, %r8
	movq %r8, %rax
	movq $8192, %r10
	cqto
	idivq %r10
	movq %rbp, %rsp
	popq %rbp
	ret
div:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rsi, %r8
	movq %rdi, %r10
	movq $8192, %r9
	imulq %r9, %r10
	movq %r10, %r9
	movq %r8, %rax
	movq $2, %r10
	cqto
	idivq %r10
	addq %rax, %r9
	movq %r9, %rax
	cqto
	idivq %r8
	movq %rbp, %rsp
	popq %rbp
	ret
of_int:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rdi, %rax
	movq $8192, %r10
	imulq %r10, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
iter:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %r8, -160(%rsp)
	movq %rcx, -152(%rsp)
	movq %rdx, -144(%rsp)
	movq %rsi, -136(%rsp)
	movq %rdi, -128(%rsp)
	movq -128(%rsp), %r10
	movq $100, %r8
	sete %r8b
inside:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rsi, %r8
	movq %rdi, %r10
	movq $0, -24(%rsp)
	movq %r10, -16(%rsp)
	movq %r8, -8(%rsp)
	movq $0, %rdi
	call of_int
	movq %rax, -232(%rsp)
	movq $0, %rdi
	call of_int
	movq %rax, %r8
	movq -232(%rsp), %rcx
	movq -8(%rsp), %rdx
	movq -16(%rsp), %rsi
	movq -24(%rsp), %rdi
	call iter
	movq %rbp, %rsp
	popq %rbp
	ret
run:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rdi, -32(%rsp)
	movq $2, %r10
	movq $0, %rdi
	subq %r10, %rdi
	call of_int
	movq %rax, %r10
	movq %r10, -40(%rsp)
	movq $1, %rdi
	call of_int
	movq %rax, %rdi
	movq %rdi, %r10
	movq -40(%rsp), %rsi
	call sub
	movq %rax, -120(%rsp)
	movq $2, %rdi
	movq -32(%rsp), %r10
	imulq %r10, %rdi
	call of_int
	movq %rax, %rsi
	movq -120(%rsp), %rdi
	call div
	movq %rax, %r10
	movq %r10, -48(%rsp)
	movq $1, %r10
	movq $0, %rdi
	subq %r10, %rdi
	call of_int
	movq %rax, %r10
	movq %r10, -56(%rsp)
	movq $1, %rdi
	call of_int
	movq %rax, %rdi
	movq %rdi, %r10
	movq -56(%rsp), %rsi
	call sub
	movq %rax, -112(%rsp)
	movq -32(%rsp), %rdi
	call of_int
	movq %rax, %rsi
	movq -112(%rsp), %rdi
	call div
	movq %rax, %r10
	movq %r10, -64(%rsp)
	movq $0, %r10
	movq %r10, -72(%rsp)
	movq -72(%rsp), %r10
	movq -32(%rsp), %r8
	setl %r8b
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq $30, %rdi
	call run
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
