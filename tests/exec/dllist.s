	.text
	.globl	main
make:
	pushq %rbp
	movq %rsp, %rbp
	addq $-40, %rsp
	movq %rdi, -16(%rbp)
	movq $24, %rdi
	call sbrk
	movq %rax, %r10
	movq -16(%rbp), %r10
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
	addq $-40, %rsp
	movq %rsi, %r10
	movq %rdi, -8(%rbp)
	movq %r10, %rdi
	call make
	movq %rax, %r10
	movq %r10, %r8
	movq -8(%rbp), %r8
	movq 8(%r8), %r8
	movq %r8, 8(%r10)
	movq %r10, %r8
	movq -8(%rbp), %r9
	movq %r8, 8(%r9)
	movq %r10, %r8
	movq 8(%r10), %r9
	movq %r8, 16(%r9)
	movq -8(%rbp), %r8
	movq %r8, 16(%r10)
	movq %r8, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
supprimer:
	pushq %rbp
	movq %rsp, %rbp
	addq $-40, %rsp
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
	addq $-40, %rsp
	movq %rdi, -24(%rbp)
	movq -24(%rbp), %r10
	movq %r10, -32(%rbp)
	movq -32(%rbp), %r10
	movq 0(%r10), %rdi
	call putchar
	movq %rax, %r10
	movq -32(%rbp), %r10
	movq 8(%r10), %r10
	movq %r10, -32(%rbp)
L72:
	movq -32(%rbp), %r10
	movq -24(%rbp), %r8
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
	movq -32(%rbp), %r10
	movq 0(%r10), %rdi
	call putchar
	movq %rax, %r10
	movq -32(%rbp), %r10
	movq 8(%r10), %r10
	movq %r10, -32(%rbp)
	jmp L72
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-40, %rsp
	movq $65, %rdi
	call make
	movq %rax, %r10
	movq %r10, -40(%rbp)
	movq -40(%rbp), %rdi
	call afficher
	movq %rax, %r10
	movq -40(%rbp), %rdi
	movq $66, %rsi
	call inserer_apres
	movq %rax, %r10
	movq -40(%rbp), %rdi
	call afficher
	movq %rax, %r10
	movq -40(%rbp), %rdi
	movq $67, %rsi
	call inserer_apres
	movq %rax, %r10
	movq -40(%rbp), %rdi
	call afficher
	movq %rax, %r10
	movq -40(%rbp), %r10
	movq 8(%r10), %rdi
	call supprimer
	movq %rax, %r10
	movq -40(%rbp), %rdi
	call afficher
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
