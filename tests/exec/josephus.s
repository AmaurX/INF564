	.text
	.globl	main
make:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rdi, -32(%rsp)
	movq $24, %rdi
	call sbrk
	movq %rax, %r10
	movq -32(%rsp), %r10
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
	movq %rdi, -24(%rsp)
	movq %r10, %rdi
	call make
	movq %rax, %r10
	movq %r10, %r8
	movq -24(%rsp), %r8
	movq 8(%r8), %r8
	movq %r8, 8(%r10)
	movq %r10, %r8
	movq -24(%rsp), %r9
	movq %r8, 8(%r9)
	movq %r10, %r8
	movq 8(%r10), %r9
	movq %r8, 16(%r9)
	movq -24(%rsp), %r8
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
	movq %rdi, -40(%rsp)
	movq -40(%rsp), %r10
	movq %r10, -48(%rsp)
	movq -48(%rsp), %r10
	movq 0(%r10), %rdi
	call putchar
	movq %rax, %r10
	movq -48(%rsp), %r10
	movq 8(%r10), %r10
	movq %r10, -48(%rsp)
	movq -48(%rsp), %r10
	movq -40(%rsp), %r8
	setne %r8b
cercle:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rdi, -56(%rsp)
	movq $1, %rdi
	call make
	movq %rax, %r10
	movq %r10, -64(%rsp)
	movq -56(%rsp), %r10
	movq %r10, -72(%rsp)
	movq -72(%rsp), %r10
	movq $2, %r8
	setge %r8b
josephus:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rsi, -80(%rsp)
	call cercle
	movq %rax, %r10
	movq %r10, -88(%rsp)
	movq -88(%rsp), %r10
	movq -88(%rsp), %r8
	movq 8(%r8), %r8
	setne %r8b
print_int:
	pushq %rbp
	movq %rsp, %rbp
	addq $-88, %rsp
	movq %rdi, -8(%rsp)
	movq -8(%rsp), %rax
	movq $10, %r10
	cqto
	idivq %r10
	movq %rax, -16(%rsp)
	movq -8(%rsp), %r10
	movq $9, %r8
	setg %r8b
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
