	.text
	.globl	main
make:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rdx, -48(%rbp)
	movq %rsi, -40(%rbp)
	movq %rdi, -24(%rbp)
	movq $24, %rdi
	call sbrk
	movq %rax, %r10
	movq -24(%rbp), %r10
	movq %rax, %r8
	movq %r10, 0(%r8)
	movq -40(%rbp), %r10
	movq %r10, 8(%rax)
	movq -48(%rbp), %r10
	movq %rax, %r8
	movq %r10, 16(%r8)
	movq %rbp, %rsp
	popq %rbp
	ret
insere:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rdi, -32(%rbp)
	movq %rsi, %r10
	movq -32(%rbp), %r8
	movq 0(%r8), %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L66
	movq %rsi, %r10
	movq -32(%rbp), %r8
	movq 0(%r8), %r8
	cmpq %r8, %r10
	setl %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L41
	movq -32(%rbp), %r10
	movq 16(%r10), %r10
	movq $0, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L48
	movq -32(%rbp), %r10
	movq 16(%r10), %rdi
	call insere
	movq %rax, %r10
L24:
	movq $0, %rax
L21:
	movq %rbp, %rsp
	popq %rbp
	ret
L48:
	movq %rsi, %rdi
	movq $0, %rsi
	movq $0, %rdx
	call make
	movq %rax, %r10
	movq -32(%rbp), %r8
	movq %r10, 16(%r8)
	jmp L24
L41:
	movq -32(%rbp), %r10
	movq 8(%r10), %r10
	movq $0, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L31
	movq -32(%rbp), %r10
	movq 8(%r10), %rdi
	call insere
	movq %rax, %r10
	jmp L24
L31:
	movq %rsi, %rdi
	movq $0, %rsi
	movq $0, %rdx
	call make
	movq %rax, %r10
	movq -32(%rbp), %r8
	movq %r10, 8(%r8)
	jmp L24
L66:
	movq $0, %rax
	jmp L21
contient:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rdi, %r10
	movq %rsi, %r8
	movq 0(%r10), %r9
	cmpq %r9, %r8
	sete %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	jnz L112
	movq %rsi, %r8
	movq 0(%r10), %r9
	cmpq %r9, %r8
	setl %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	jnz L103
	movq $0, %r8
L96:
	testq %r8, %r8
	jnz L94
	movq 16(%r10), %r8
	movq $0, %r9
	cmpq %r9, %r8
	setne %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	jnz L82
	movq $0, %rax
L74:
	movq %rbp, %rsp
	popq %rbp
	ret
L82:
	movq 16(%r10), %rdi
	call contient
	jmp L74
L94:
	movq 8(%r10), %rdi
	call contient
	jmp L74
L103:
	movq 8(%r10), %r8
	movq $0, %r9
	cmpq %r9, %r8
	setne %r11b
	movzbq %r11b, %r8
	cmpq $0, %r8
	setne %r8b
	jmp L96
L112:
	movq $1, %rax
	jmp L74
print_int:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rdi, -56(%rbp)
	movq -56(%rbp), %rax
	movq $10, %r10
	cqto
	idivq %r10
	movq %rax, -64(%rbp)
	movq -56(%rbp), %r10
	movq $9, %r8
	cmpq %r8, %r10
	setg %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L135
L133:
	movq -56(%rbp), %rdi
	movq $10, %r8
	movq -64(%rbp), %r10
	imulq %r10, %r8
	movq %r8, %r10
	subq %r10, %rdi
	addq $48, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L135:
	movq -64(%rbp), %rdi
	call print_int
	movq %rax, %r10
	jmp L133
print:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rdi, -8(%rbp)
	movq $40, %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rbp), %r10
	movq 8(%r10), %r10
	movq $0, %r8
	cmpq %r8, %r10
	setne %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L168
L165:
	movq -8(%rbp), %r10
	movq 0(%r10), %rdi
	call print_int
	movq %rax, %r10
	movq -8(%rbp), %r10
	movq 16(%r10), %r10
	movq $0, %r8
	cmpq %r8, %r10
	setne %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L155
L152:
	movq $41, %rdi
	call putchar
	movq %rbp, %rsp
	popq %rbp
	ret
L155:
	movq -8(%rbp), %r10
	movq 16(%r10), %rdi
	call print
	movq %rax, %r10
	jmp L152
L168:
	movq -8(%rbp), %r10
	movq 8(%r10), %rdi
	call print
	movq %rax, %r10
	jmp L165
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq $1, %rdi
	movq $0, %rsi
	movq $0, %rdx
	call make
	movq %rax, %r10
	movq %r10, -16(%rbp)
	movq -16(%rbp), %rdi
	movq $17, %rsi
	call insere
	movq %rax, %r10
	movq -16(%rbp), %rdi
	movq $5, %rsi
	call insere
	movq %rax, %r10
	movq -16(%rbp), %rdi
	movq $8, %rsi
	call insere
	movq %rax, %r10
	movq -16(%rbp), %rdi
	call print
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq -16(%rbp), %rdi
	movq $5, %rsi
	call contient
	movq %rax, %r10
	testq %r10, %r10
	jnz L223
	movq $0, %r10
L217:
	testq %r10, %r10
	jnz L215
	movq $0, %r10
L210:
	testq %r10, %r10
	jnz L208
	movq $0, %r10
L202:
	testq %r10, %r10
	jnz L200
L194:
	movq -16(%rbp), %rdi
	movq $42, %rsi
	call insere
	movq %rax, %r10
	movq -16(%rbp), %rdi
	movq $1000, %rsi
	call insere
	movq %rax, %r10
	movq -16(%rbp), %rdi
	movq $0, %rsi
	call insere
	movq %rax, %r10
	movq -16(%rbp), %rdi
	call print
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L200:
	movq $111, %rdi
	call putchar
	movq %rax, %r10
	movq $107, %rdi
	call putchar
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	jmp L194
L208:
	movq -16(%rbp), %rdi
	movq $3, %rsi
	call contient
	movq %rax, %r10
	cmpq $0, %r10
	sete %r10b
	cmpq $0, %r10
	setne %r10b
	jmp L202
L215:
	movq -16(%rbp), %rdi
	movq $17, %rsi
	call contient
	movq %rax, %r10
	cmpq $0, %r10
	setne %r10b
	jmp L210
L223:
	movq -16(%rbp), %rdi
	movq $0, %rsi
	call contient
	movq %rax, %r10
	cmpq $0, %r10
	sete %r10b
	cmpq $0, %r10
	setne %r10b
	jmp L217
	.data
