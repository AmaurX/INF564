	.text
	.globl	main
get:
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
	jnz L12
	movq 8(%r10), %rdi
	decq %rsi
	call get
L1:
	movq %rbp, %rsp
	popq %rbp
	ret
L12:
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
	jnz L33
	movq 8(%r10), %rdi
	decq %rsi
	call set
L19:
	movq %rbp, %rsp
	popq %rbp
	ret
L33:
	movq %rdx, %rax
	movq %rax, 0(%r10)
	jmp L19
create:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, -48(%rbp)
	movq -48(%rbp), %r10
	movq $0, %r8
	cmpq %r8, %r10
	sete %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L60
	movq $16, %rdi
	call sbrk
	movq %rax, %r10
	movq %r10, -56(%rbp)
	movq $0, %r10
	movq -56(%rbp), %r8
	movq %r10, 0(%r8)
	movq -48(%rbp), %rdi
	decq %rdi
	call create
	movq %rax, %r10
	movq -56(%rbp), %r8
	movq %r10, 8(%r8)
	movq -56(%rbp), %rax
L40:
	movq %rbp, %rsp
	popq %rbp
	ret
L60:
	movq $0, %rax
	jmp L40
print_row:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rsi, -72(%rbp)
	movq %rdi, -64(%rbp)
	movq $0, %r10
	movq %r10, -80(%rbp)
L77:
	movq -80(%rbp), %r10
	movq -72(%rbp), %r8
	cmpq %r8, %r10
	setle %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L93
	movq $10, %rdi
	call putchar
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L93:
	movq -64(%rbp), %rdi
	movq -80(%rbp), %rsi
	call get
	movq %rax, %r10
	movq $0, %r8
	cmpq %r8, %r10
	setne %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L84
	movq $46, %rdi
	call putchar
	movq %rax, %r10
L82:
	movq -80(%rbp), %r10
	incq %r10
	movq %r10, -80(%rbp)
	jmp L77
L84:
	movq $42, %rdi
	call putchar
	movq %rax, %r10
	jmp L82
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
	movq %rdi, -88(%rbp)
	movq %r10, -96(%rbp)
L122:
	movq -96(%rbp), %r10
	movq $0, %r8
	cmpq %r8, %r10
	setg %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L141
	movq -88(%rbp), %rdi
	movq $0, %rsi
	movq $1, %rdx
	call set
	movq %rax, %r10
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L141:
	movq -88(%rbp), %r15
	movq %r15, -8(%rbp)
	movq -96(%rbp), %r15
	movq %r15, -104(%rbp)
	movq -88(%rbp), %rdi
	movq -96(%rbp), %rsi
	call get
	movq %rax, -16(%rbp)
	movq -88(%rbp), %rdi
	movq -96(%rbp), %rsi
	decq %rsi
	call get
	movq %rax, %r10
	addq %r10, -16(%rbp)
	movq -16(%rbp), %rdi
	call mod7
	movq %rax, %rdx
	movq -104(%rbp), %rsi
	movq -8(%rbp), %rdi
	call set
	movq %rax, %r10
	movq -96(%rbp), %r10
	decq %r10
	movq %r10, -96(%rbp)
	jmp L122
pascal:
	pushq %rbp
	movq %rsp, %rbp
	addq $-104, %rsp
	movq %rdi, -24(%rbp)
	movq -24(%rbp), %rdi
	incq %rdi
	call create
	movq %rax, %r10
	movq %r10, -40(%rbp)
	movq $0, %r10
	movq %r10, -32(%rbp)
L153:
	movq -32(%rbp), %r10
	movq -24(%rbp), %r8
	cmpq %r8, %r10
	setl %r11b
	movzbq %r11b, %r10
	testq %r10, %r10
	jnz L168
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
L168:
	movq -40(%rbp), %rdi
	movq -32(%rbp), %rsi
	movq $0, %rdx
	call set
	movq %rax, %r10
	movq -40(%rbp), %rdi
	movq -32(%rbp), %rsi
	call compute_row
	movq %rax, %r10
	movq -40(%rbp), %rdi
	movq -32(%rbp), %rsi
	call print_row
	movq %rax, %r10
	movq -32(%rbp), %r10
	incq %r10
	movq %r10, -32(%rbp)
	jmp L153
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
