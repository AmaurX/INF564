	.text
	.globl	main
make:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rdx, -48(%rsp)
	movq %rsi, -40(%rsp)
	movq %rdi, -24(%rsp)
	movq $24, %rdi
	call sbrk
	movq %rax, %r10
	movq -24(%rsp), %r10
	movq %rax, %r8
	movq %r10, 0(%r8)
	movq -40(%rsp), %r10
	movq %r10, 8(%rax)
	movq -48(%rsp), %r10
	movq %rax, %r8
	movq %r10, 16(%r8)
	movq %rbp, %rsp
	popq %rbp
	ret
insere:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rdi, -32(%rsp)
	movq %rsi, %r10
	movq -32(%rsp), %r8
	movq 0(%r8), %r8
	sete %r8b
contient:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rdi, %r10
	movq %rsi, %r8
	movq 0(%r10), %r9
	sete %r9b
print_int:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rdi, -56(%rsp)
	movq -56(%rsp), %rax
	movq $10, %r10
	cqto
	idivq %r10
	movq %rax, -64(%rsp)
	movq -56(%rsp), %r10
	movq $9, %r8
	setg %r8b
print:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rdi, -8(%rsp)
	movq $40, %rdi
	call putchar
	movq %rax, %r10
	movq -8(%rsp), %r10
	movq 8(%r10), %r10
	movq $0, %r8
	setne %r8b
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq $1, %rdi
	movq $0, %rsi
	movq $0, %rdx
	call make
	movq %rax, %r10
	movq %r10, -16(%rsp)
	movq -16(%rsp), %rdi
	movq $17, %rsi
	call insere
	movq %rax, %r10
	movq -16(%rsp), %rdi
	movq $5, %rsi
	call insere
	movq %rax, %r10
	movq -16(%rsp), %rdi
	movq $8, %rsi
	call insere
	movq %rax, %r10
	movq -16(%rsp), %rdi
	call print
	movq %rax, %r10
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq -16(%rsp), %rdi
	movq $5, %rsi
	call contient
	movq %rax, %r10
	.data
