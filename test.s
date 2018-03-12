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
	movq %r8, -160(%rbp)
	movq %rcx, -152(%rbp)
	movq %rdx, -144(%rbp)
	movq %rsi, -136(%rbp)
	movq %rdi, -128(%rbp)
	movq -128(%rbp), %r10
	movq $100, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L105
	movq -152(%rbp), %rdi
	movq -152(%rbp), %rsi
	call mul
	movq %rax, %r10
	movq %r10, -168(%rbp)
	movq -160(%rbp), %rdi
	movq -160(%rbp), %rsi
	call mul
	movq %rax, %r10
	movq %r10, -176(%rbp)
	movq -168(%rbp), %rdi
	movq -176(%rbp), %rsi
	call add
	movq %rax, -224(%rbp)
	movq $4, %rdi
	call of_int
	movq %rax, %r10
	cmpq %r10, -224(%rbp)
	setg %r11b
	movzbq %r11b, %r11
	movq %r11, -224(%rbp)
	movq -224(%rbp), %r10
	testq %r10, %r10
	jnz L84
	movq -128(%rbp), %r10
	movq $1, %r8
	addq %r8, %r10
	movq %r10, -208(%rbp)
	movq -136(%rbp), %r15
	movq %r15, -200(%rbp)
	movq -144(%rbp), %r15
	movq %r15, -192(%rbp)
	movq -168(%rbp), %rdi
	movq -176(%rbp), %rsi
	call sub
	movq %rax, %rdi
	movq -136(%rbp), %rsi
	call add
	movq %rax, -184(%rbp)
	movq $2, %rdi
	call of_int
	movq %rax, -216(%rbp)
	movq -152(%rbp), %rdi
	movq -160(%rbp), %rsi
	call mul
	movq %rax, %rsi
	movq -216(%rbp), %rdi
	call mul
	movq %rax, %rdi
	movq -144(%rbp), %rsi
	call add
	movq %rax, %r8
	movq -184(%rbp), %rcx
	movq -192(%rbp), %rdx
	movq -200(%rbp), %rsi
	movq -208(%rbp), %rdi
	call iter
L60:
	movq %rbp, %rsp
	popq %rbp
	ret
L84:
	movq $0, %rax
	jmp L60
L105:
	movq $1, %rax
	jmp L60
inside:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rsi, %r8
	movq %rdi, %r10
	movq $0, -24(%rbp)
	movq %r10, -16(%rbp)
	movq %r8, -8(%rbp)
	movq $0, %rdi
	call of_int
	movq %rax, -232(%rbp)
	movq $0, %rdi
	call of_int
	movq %rax, %r8
	movq -232(%rbp), %rcx
	movq -8(%rbp), %rdx
	movq -16(%rbp), %rsi
	movq -24(%rbp), %rdi
	call iter
	movq %rbp, %rsp
	popq %rbp
	ret
run:
	pushq %rbp
	movq %rsp, %rbp
	addq $-232, %rsp
	movq %rdi, -32(%rbp)
	movq $2, %r10
	movq $0, %rdi
	subq %r10, %rdi
	call of_int
	movq %rax, %r10
	movq %r10, -40(%rbp)
	movq $1, %rdi
	call of_int
	movq %rax, %rdi
	movq %rdi, %r10
	movq -40(%rbp), %rsi
	call sub
	movq %rax, -120(%rbp)
	movq $2, %rdi
	movq -32(%rbp), %r10
	imulq %r10, %rdi
	call of_int
	movq %rax, %rsi
	movq -120(%rbp), %rdi
	call div
	movq %rax, %r10
	movq %r10, -48(%rbp)
	movq $1, %r10
	movq $0, %rdi
	subq %r10, %rdi
	call of_int
	movq %rax, %r10
	movq %r10, -56(%rbp)
	movq $1, %rdi
	call of_int
	movq %rax, %rdi
	movq %rdi, %r10
	movq -56(%rbp), %rsi
	call sub
	movq %rax, -112(%rbp)
	movq -32(%rbp), %rdi
	call of_int
	movq %rax, %rsi
	movq -112(%rbp), %rdi
	call div
	movq %rax, %r10
	movq %r10, -64(%rbp)
	movq $0, %r10
	movq %r10, -72(%rbp)
L131:
	movq -72(%rbp), %r10
	movq -32(%rbp), %r8
	cmpq %r8, %r10
	setl %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L180
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L180:
	movq -56(%rbp), %r15
	movq %r15, -104(%rbp)
	movq -72(%rbp), %rdi
	call of_int
	movq %rax, %rdi
	movq -64(%rbp), %rsi
	call mul
	movq %rax, %rsi
	movq -104(%rbp), %rdi
	call add
	movq %rax, %r10
	movq %r10, -80(%rbp)
	movq $0, %r10
	movq %r10, -88(%rbp)
L147:
	movq -88(%rbp), %r10
	movq $2, %r8
	movq -32(%rbp), %r9
	imulq %r9, %r8
	cmpq %r8, %r10
	setl %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L169
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq -72(%rbp), %r10
	movq $1, %r8
	addq %r8, %r10
	movq %r10, -72(%rbp)
	jmp L131
L169:
	movq -40(%rbp), %r15
	movq %r15, -96(%rbp)
	movq -88(%rbp), %rdi
	call of_int
	movq %rax, %rdi
	movq -48(%rbp), %rsi
	call mul
	movq %rax, %rsi
	movq -96(%rbp), %rdi
	call add
	movq %rax, %rdi
	movq %rdi, %r10
	movq -80(%rbp), %rsi
	call inside
	movq %rax, %r10
	testq %r10, %r10
	jnz L155
	movq $49, %rdi
	call putchar
	movq %rax, %r10
L153:
	movq -88(%rbp), %r10
	movq $1, %r8
	addq %r8, %r10
	movq %r10, -88(%rbp)
	jmp L147
L155:
	movq $48, %rdi
	call putchar
	movq %rax, %r10
	jmp L153
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
