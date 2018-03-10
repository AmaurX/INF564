	.text
	.globl	main
get:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, %r9
	movq %rsi, %r10
	movq $0, %r8
	sete %r8b
set:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, %r10
	movq %rsi, %r8
	movq $0, %r9
	sete %r9b
create:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, -56(%rsp)
	movq -56(%rsp), %r10
	movq $0, %r8
	sete %r8b
print_row:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rsi, -80(%rsp)
	movq %rdi, -72(%rsp)
	movq $0, %r10
	movq %r10, -88(%rsp)
	movq -88(%rsp), %r10
	movq -80(%rsp), %r8
	setle %r8b
mod7:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, %rax
	movq %rax, %r10
	movq $7, %r8
	movq $7, %r9
	cqto
	idivq %r9
	imulq %rax, %r8
	subq %r8, %r10
	movq %r10, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
compute_row:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rsi, %r10
	movq %rdi, -96(%rsp)
	movq %r10, -104(%rsp)
	movq -104(%rsp), %r10
	movq $0, %r8
	setg %r8b
pascal:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, -32(%rsp)
	movq -32(%rsp), %rdi
	movq $1, %r10
	addq %r10, %rdi
	call create
	movq %rax, %r10
	movq %r10, -48(%rsp)
	movq $0, %r10
	movq %r10, -40(%rsp)
	movq -40(%rsp), %r10
	movq -32(%rsp), %r8
	setl %r8b
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq $42, %rdi
	call pascal
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
