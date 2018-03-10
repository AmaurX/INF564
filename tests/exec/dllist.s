	.text
	.globl	main
make:
	pushq %rbp
	movq %rsp, %rbp
	addq $-40, %rsp
	movq %rdi, -16(%rsp)
	movq $24, %rdi
	call sbrk
	movq %rax, %r10
	movq -16(%rsp), %r10
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
	movq %rdi, -8(%rsp)
	movq %r10, %rdi
	call make
	movq %rax, %r10
	movq %r10, %r8
	movq -8(%rsp), %r8
	movq 8(%r8), %r8
	movq %r8, 8(%r10)
	movq %r10, %r8
	movq -8(%rsp), %r9
	movq %r8, 8(%r9)
	movq %r10, %r8
	movq 8(%r10), %r9
	movq %r8, 16(%r9)
	movq -8(%rsp), %r8
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
	movq %rdi, -24(%rsp)
	movq -24(%rsp), %r10
	movq %r10, -32(%rsp)
	movq -32(%rsp), %r10
	movq 0(%r10), %rdi
	call putchar
	movq %rax, %r10
	movq -32(%rsp), %r10
	movq 8(%r10), %r10
	movq %r10, -32(%rsp)
	movq -32(%rsp), %r10
	movq -24(%rsp), %r8
	setne %r8b
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-40, %rsp
	movq $65, %rdi
	call make
	movq %rax, %r10
	movq %r10, -40(%rsp)
	movq -40(%rsp), %rdi
	call afficher
	movq %rax, %r10
	movq -40(%rsp), %rdi
	movq $66, %rsi
	call inserer_apres
	movq %rax, %r10
	movq -40(%rsp), %rdi
	call afficher
	movq %rax, %r10
	movq -40(%rsp), %rdi
	movq $67, %rsi
	call inserer_apres
	movq %rax, %r10
	movq -40(%rsp), %rdi
	call afficher
	movq %rax, %r10
	movq -40(%rsp), %r10
	movq 8(%r10), %rdi
	call supprimer
	movq %rax, %r10
	movq -40(%rsp), %rdi
	call afficher
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
