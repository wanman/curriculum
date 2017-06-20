#include <syscall.h>

#define STDIN		0
#define STDOUT		1
#define STDERR		2

#define NO_ERR		0
#define READ_ERR	1
#define WRITE_ERR	2
#define OPEN_ERR	3

#undef BUFSIZ
#define BUFSIZ		(1 << 12)

.data

open_err_str:
	.ascii	"open err\n"

.text

.globl cat
/* int cat(int fd); */
cat:
	pushl	%ebp		/* prologue */
	movl	%esp, %ebp

		/* char buf[BUFSIZ]; int bc; */
	subl	$(BUFSIZ + 4), %esp

cat_loop0:	/* while ((bc = read(fd, buf, BUFSIZ)) > 0) */
	movl	$SYS_read, %eax
	movl	8(%ebp), %ebx		/* fd */
	movl	%esp, %ecx		/* buf */
	movl	$BUFSIZ, %edx		/* count */
	int	$0x80
	cmpl	$0, %eax		/* bc > 0 ? */
	jle	cat_end0
	movl	%eax, -4(%ebp)		/* -> bc */

		/*	if (write(STDOUT, buf, bc) != bc) */
	movl	$SYS_write, %eax
	movl	$STDOUT, %ebx		/* fd */
	movl	%esp, %ecx		/* buf */
	movl	-4(%ebp), %edx		/* count */
	int	$0x80
	cmpl	%eax, -4(%ebp)		/* != ? */
	je	cat_loop0

	movl	$WRITE_ERR, %eax	/* != -> write failed */
	addl	$(BUFSIZ + 4), %esp
	popl	%ebp
	ret

cat_end0:	/* check read err */
	cmpl	$0, %eax
	je	cat_end1
	movl	$READ_ERR, %eax
	jmp	cat_end2
cat_end1:
	movl	$NO_ERR, %eax
cat_end2:
	addl	$(BUFSIZ + 4), %esp
	popl	%ebp
	ret


.globl main
main:	/* int main(int argc, char **argv); */
		/* prologue */
	pushl	%ebp
	movl	%esp, %ebp
		/* local vars */
	subl	$4, %esp		/* int fd; */
		/* if (argc == 1) cat(STDIN); */
	cmpl	$1, 8(%ebp)
	jne	main_loop0
	pushl	$STDIN
	call	cat
	addl	$8, %esp		/* + fd */
	jmp	main_end

main_loop0: /* while(--argc) { fd=open(*++argv,O_RDONLY); cat(fd); close(fd); } */
	decl	8(%ebp)
	cmpl	$0, 8(%ebp)
	jle	main_end		/* argc <= 0 */
	
		/* fd = open(*++argv, O_RDONLY) */
	movl	$SYS_open, %eax
	addl	$4, 12(%ebp)
	movl	12(%ebp), %ebx
	movl	(%ebx), %ebx		/* *++argv */
	xorl	%ecx, %ecx		/* O_RDONLY */
	int	$0x80
	cmpl	$0, %eax
	jl	main_open_err
	movl	%eax, -4(%ebp)		/* -> fd */
	/* + error check */

		/* cat(fd) */
	pushl	%eax
	call	cat
	addl	$4, %esp

		/* close(fd) */
	movl	$SYS_close, %eax
	movl	-4(%ebp), %ebx		/* fd */
	int	$0x80
	jmp	main_loop0

main_end:	/* exit(0) */
	movl	$SYS_exit, %eax
	xorl	%ebx, %ebx	/* 0 */
	int	$0x80

main_open_err:	/* write("open err\n") */
	movl	$SYS_write, %eax
	movl	$STDERR, %ebx		/* fd */
	movl	$open_err_str, %ecx	/* buf */
	movl	$9, %edx		/* strlen(buf) */
	int	$0x80
		/* exit(1) */
	movl	$SYS_exit, %eax
	movl	$1, %ebx		/* code */
	int	$0x80
