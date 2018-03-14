	.text
	.globl	main
get:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, %r9
	movq %rsi, %r10
	movq $0, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L13
	movq 8(%r9), %rdi
	movq $1, %r10
	subq %r10, %rsi
	call get
L1:
	movq %rbp, %rsp
	popq %rbp
	ret
L13:
	movq %r9, %r10
	movq 0(%r10), %rax
	jmp L1
set:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, %r10
	movq %rsi, %r8
	movq $0, %r9
	cmpq %r9, %r8
	sete %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	jnz L35
	movq 8(%r10), %rdi
	movq $1, %r10
	subq %r10, %rsi
	call set
L20:
	movq %rbp, %rsp
	popq %rbp
	ret
L35:
	movq %rdx, %rax
	movq %rax, 0(%r10)
	jmp L20
create:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, -56(%rbp)
	movq -56(%rbp), %r10
	movq $0, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L63
	movq $16, %rdi
	call sbrk
	movq %rax, %r10
	movq %r10, -64(%rbp)
	movq $0, %r10
	movq -64(%rbp), %r8
	movq %r10, 0(%r8)
	movq -56(%rbp), %rdi
	movq $1, %r10
	subq %r10, %rdi
	call create
	movq %rax, %r10
	movq -64(%rbp), %r8
	movq %r10, 8(%r8)
	movq -64(%rbp), %rax
L42:
	movq %rbp, %rsp
	popq %rbp
	ret
L63:
	movq $0, %rax
	jmp L42
print_row:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rsi, -80(%rbp)
	movq %rdi, -72(%rbp)
	movq $0, %r10
	movq %r10, -88(%rbp)
L80:
	movq -88(%rbp), %r10
	movq -80(%rbp), %r8
	cmpq %r8, %r10
	setle %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L96
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L96:
	movq -72(%rbp), %rdi
	movq -88(%rbp), %rsi
	call get
	movq %rax, %r10
	movq $0, %r8
	cmpq %r8, %r10
	setne %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L87
	movq $46, %rdi
	call putchar
	movq %rax, %r10
L85:
	movq -88(%rbp), %r10
	incq %r10
	movq %r10, -88(%rbp)
	jmp L80
L87:
	movq $42, %rdi
	call putchar
	movq %rax, %r10
	jmp L85
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
	movq %rdi, -96(%rbp)
	movq %r10, -104(%rbp)
L125:
	movq -104(%rbp), %r10
	movq $0, %r8
	cmpq %r8, %r10
	setg %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L146
	movq -96(%rbp), %rdi
	movq $0, %rsi
	movq $1, %rdx
	call set
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L146:
	movq -96(%rbp), %r15
	movq %r15, -16(%rbp)
	movq -104(%rbp), %r15
	movq %r15, -8(%rbp)
	movq -96(%rbp), %rdi
	movq -104(%rbp), %rsi
	call get
	movq %rax, -24(%rbp)
	movq -96(%rbp), %rdi
	movq -104(%rbp), %rsi
	movq $1, %r10
	subq %r10, %rsi
	call get
	movq %rax, %r10
	addq %r10, -24(%rbp)
	movq -24(%rbp), %rdi
	call mod7
	movq %rax, %rdx
	movq -8(%rbp), %rsi
	movq -16(%rbp), %rdi
	call set
	movq %rax, %r10
	movq -104(%rbp), %r8
	movq $1, %r10
	subq %r10, %r8
	movq %r8, %r10
	movq %r10, -104(%rbp)
	jmp L125
pascal:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, -32(%rbp)
	movq -32(%rbp), %rdi
	incq %rdi
	call create
	movq %rax, %r10
	movq %r10, -48(%rbp)
	movq $0, %r10
	movq %r10, -40(%rbp)
L158:
	movq -40(%rbp), %r10
	movq -32(%rbp), %r8
	cmpq %r8, %r10
	setl %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L173
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L173:
	movq -48(%rbp), %rdi
	movq -40(%rbp), %rsi
	movq $0, %rdx
	call set
	movq %rax, %r10
	movq -48(%rbp), %rdi
	movq -40(%rbp), %rsi
	call compute_row
	movq %rax, %r10
	movq -48(%rbp), %rdi
	movq -40(%rbp), %rsi
	call print_row
	movq %rax, %r10
	movq -40(%rbp), %r10
	incq %r10
	movq %r10, -40(%rbp)
	jmp L158
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
