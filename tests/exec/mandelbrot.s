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
	movq %r8, -152(%rbp)
	movq %rcx, -144(%rbp)
	movq %rdx, -136(%rbp)
	movq %rsi, -128(%rbp)
	movq %rdi, -120(%rbp)
	movq -120(%rbp), %r10
	movq $100, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L104
	movq -144(%rbp), %rdi
	movq -144(%rbp), %rsi
	call mul
	movq %rax, %r10
	movq %r10, -160(%rbp)
	movq -152(%rbp), %rdi
	movq -152(%rbp), %rsi
	call mul
	movq %rax, %r10
	movq %r10, -168(%rbp)
	movq -160(%rbp), %rdi
	movq -168(%rbp), %rsi
	call add
	movq %rax, -216(%rbp)
	movq $4, %rdi
	call of_int
	movq %rax, %r10
	cmpq %r10, -216(%rbp)
	setg %r11b
	movzbq %r11b, %r11
	movq %r11, -216(%rbp)
	movq -216(%rbp), %r10
	testq %r10, %r10
	jnz L83
	movq -120(%rbp), %r10
	incq %r10
	movq %r10, -200(%rbp)
	movq -128(%rbp), %r15
	movq %r15, -192(%rbp)
	movq -136(%rbp), %r15
	movq %r15, -184(%rbp)
	movq -160(%rbp), %rdi
	movq -168(%rbp), %rsi
	call sub
	movq %rax, %rdi
	movq -128(%rbp), %rsi
	call add
	movq %rax, -176(%rbp)
	movq $2, %rdi
	call of_int
	movq %rax, -208(%rbp)
	movq -144(%rbp), %rdi
	movq -152(%rbp), %rsi
	call mul
	movq %rax, %rsi
	movq -208(%rbp), %rdi
	call mul
	movq %rax, %rdi
	movq -136(%rbp), %rsi
	call add
	movq %rax, %r8
	movq -176(%rbp), %rcx
	movq -184(%rbp), %rdx
	movq -192(%rbp), %rsi
	movq -200(%rbp), %rdi
	call iter
L60:
	movq %rbp, %rsp
	popq %rbp
	ret
L83:
	movq $0, %rax
	jmp L60
L104:
	movq $1, %rax
	jmp L60
inside:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rsi, %r8
	movq %rdi, %r10
	movq $0, -16(%rbp)
	movq %r10, -8(%rbp)
	movq %r8, -232(%rbp)
	movq $0, %rdi
	call of_int
	movq %rax, -224(%rbp)
	movq $0, %rdi
	call of_int
	movq %rax, %r8
	movq -224(%rbp), %rcx
	movq -232(%rbp), %rdx
	movq -8(%rbp), %rsi
	movq -16(%rbp), %rdi
	call iter
	movq %rbp, %rsp
	popq %rbp
	ret
run:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rdi, -24(%rbp)
	movq $2, %r10
	movq $0, %rdi
	subq %r10, %rdi
	call of_int
	movq %rax, %r10
	movq %r10, -32(%rbp)
	movq $1, %rdi
	call of_int
	movq %rax, %rdi
	movq %rdi, %r10
	movq -32(%rbp), %rsi
	call sub
	movq %rax, -112(%rbp)
	movq $2, %rdi
	movq -24(%rbp), %r10
	imulq %r10, %rdi
	call of_int
	movq %rax, %rsi
	movq -112(%rbp), %rdi
	call div
	movq %rax, %r10
	movq %r10, -40(%rbp)
	movq $1, %r10
	movq $0, %rdi
	subq %r10, %rdi
	call of_int
	movq %rax, %r10
	movq %r10, -48(%rbp)
	movq $1, %rdi
	call of_int
	movq %rax, %rdi
	movq %rdi, %r10
	movq -48(%rbp), %rsi
	call sub
	movq %rax, -104(%rbp)
	movq -24(%rbp), %rdi
	call of_int
	movq %rax, %rsi
	movq -104(%rbp), %rdi
	call div
	movq %rax, %r10
	movq %r10, -56(%rbp)
	movq $0, %r10
	movq %r10, -64(%rbp)
L130:
	movq -64(%rbp), %r10
	movq -24(%rbp), %r8
	cmpq %r8, %r10
	setl %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L177
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L177:
	movq -48(%rbp), %r15
	movq %r15, -96(%rbp)
	movq -64(%rbp), %rdi
	call of_int
	movq %rax, %rdi
	movq -56(%rbp), %rsi
	call mul
	movq %rax, %rsi
	movq -96(%rbp), %rdi
	call add
	movq %rax, %r10
	movq %r10, -72(%rbp)
	movq $0, %r10
	movq %r10, -80(%rbp)
L145:
	movq -80(%rbp), %r10
	movq $2, %r8
	movq -24(%rbp), %r9
	imulq %r9, %r8
	cmpq %r8, %r10
	setl %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L166
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq -64(%rbp), %r10
	incq %r10
	movq %r10, -64(%rbp)
	jmp L130
L166:
	movq -32(%rbp), %r15
	movq %r15, -88(%rbp)
	movq -80(%rbp), %rdi
	call of_int
	movq %rax, %rdi
	movq -40(%rbp), %rsi
	call mul
	movq %rax, %rsi
	movq -88(%rbp), %rdi
	call add
	movq %rax, %rdi
	movq %rdi, %r10
	movq -72(%rbp), %rsi
	call inside
	movq %rax, %r10
	testq %r10, %r10
	jnz L152
	movq $49, %rdi
	call putchar
	movq %rax, %r10
L150:
	movq -80(%rbp), %r10
	incq %r10
	movq %r10, -80(%rbp)
	jmp L145
L152:
	movq $48, %rdi
	call putchar
	movq %rax, %r10
	jmp L150
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
