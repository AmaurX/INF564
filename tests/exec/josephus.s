	.text
	.globl	main
make:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rdi, -32(%rbp)
	movq $24, %rdi
	call sbrk
	movq %rax, %r10
	movq -32(%rbp), %r10
	movq %rax, %r8
	movq %r10, 0(%r8)
	movq %rax, %r10
	movq %r10, 16(%rax)
	movq %rax, %r8
	movq %r10, 8(%r8)
	movq %rbp, %rsp
	popq %rbp
	ret
inserer_apres:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rsi, %r10
	movq %rdi, -24(%rbp)
	movq %r10, %rdi
	call make
	movq %rax, %r10
	movq %r10, %r8
	movq -24(%rbp), %r8
	movq 8(%r8), %r8
	movq %r8, 8(%r10)
	movq %r10, %r8
	movq -24(%rbp), %r9
	movq %r8, 8(%r9)
	movq %r10, %r8
	movq 8(%r10), %r9
	movq %r8, 16(%r9)
	movq -24(%rbp), %r8
	movq %r8, 16(%r10)
	movq %r8, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
supprimer:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rdi, %r10
	movq 8(%r10), %r8
	movq 16(%r10), %r9
	movq %r8, 8(%r9)
	movq 16(%r10), %r8
	movq 8(%r10), %r10
	movq %r8, 16(%r10)
	movq %r8, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
afficher:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rdi, -40(%rbp)
	movq -40(%rbp), %r10
	movq %r10, -48(%rbp)
	movq -48(%rbp), %r10
	movq 0(%r10), %rdi
	call putchar
	movq %rax, %r10
	movq -48(%rbp), %r10
	movq 8(%r10), %r10
	movq %r10, -48(%rbp)
L72:
	movq -48(%rbp), %r10
	movq -40(%rbp), %r8
	cmpq %r8, %r10
	setne %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L79
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L79:
	movq -48(%rbp), %r10
	movq 0(%r10), %rdi
	call putchar
	movq %rax, %r10
	movq -48(%rbp), %r10
	movq 8(%r10), %r10
	movq %r10, -48(%rbp)
	jmp L72
cercle:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rdi, -56(%rbp)
	movq $1, %rdi
	call make
	movq %rax, %r10
	movq %r10, -64(%rbp)
	movq -56(%rbp), %r10
	movq %r10, -72(%rbp)
L98:
	movq -72(%rbp), %r10
	movq $2, %r8
	cmpq %r8, %r10
	setge %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L106
	movq -64(%rbp), %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L106:
	movq -64(%rbp), %rdi
	movq -72(%rbp), %rsi
	call inserer_apres
	movq %rax, %r10
	movq -72(%rbp), %r10
	decq %r10
	movq %r10, -72(%rbp)
	jmp L98
josephus:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rsi, -80(%rbp)
	call cercle
	movq %rax, %r10
	movq %r10, -88(%rbp)
L124:
	movq -88(%rbp), %r10
	movq -88(%rbp), %r8
	movq 8(%r8), %r8
	cmpq %r8, %r10
	setne %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L147
	movq -88(%rbp), %r10
	movq 0(%r10), %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L147:
	movq $1, %r10
	movq %r10, %r8
L135:
	movq %r10, %r8
	movq -80(%rbp), %r9
	cmpq %r9, %r8
	setl %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	jnz L144
	movq -88(%rbp), %rdi
	call supprimer
	movq %rax, %r10
	movq -88(%rbp), %r10
	movq 8(%r10), %r10
	movq %r10, -88(%rbp)
	jmp L124
L144:
	movq -88(%rbp), %r8
	movq 8(%r8), %r8
	movq %r8, -88(%rbp)
	incq %r10
	movq %r10, %r8
	jmp L135
print_int:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rdi, -8(%rbp)
	movq -8(%rbp), %rax
	movq $10, %r10
	cqto
	idivq %r10
	movq %rax, -16(%rbp)
	movq -8(%rbp), %r10
	movq $9, %r8
	cmpq %r8, %r10
	setg %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L167
L165:
	movq -8(%rbp), %rdi
	movq $10, %r10
	movq -16(%rbp), %r8
	imulq %r8, %r10
	subq %r10, %rdi
	addq $48, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L167:
	movq -16(%rbp), %rdi
	call print_int
	movq %rax, %r10
	jmp L165
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq $7, %rdi
	movq $5, %rsi
	call josephus
	movq %rax, %rdi
	call print_int
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $5, %rdi
	movq $5, %rsi
	call josephus
	movq %rax, %rdi
	call print_int
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $5, %rdi
	movq $17, %rsi
	call josephus
	movq %rax, %rdi
	call print_int
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $13, %rdi
	movq $2, %rsi
	call josephus
	movq %rax, %rdi
	call print_int
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
