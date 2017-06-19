#include <syscalls.h>

#undef BUFSIZ
#define BUFSIZ		4096

#define STDIN		0
#define STDOUT		1
#define STDERR		2

/* errors */
#define NO_ERR		0
#define WRITE_ERR	(-1)
#define READ_ERR	(-2)
#define OPEN_ERR	(-3)

.globl cat
cat:	/* int cat(int fd); */
		/* prologue */
	pushl	%ebp
	movl	%esp, %ebp
		/* local vars */
	subl	$(BUFSIZ + 4), %esp	/* int bc; char buf[BUFSIZ]; */
cat_0:
		/* read */
	movl	$SYS_read, %eax
	movl	8(%ebp), %ebx		/* fd */
	movl	%esp, %ecx		/* buf */
	movl	$BUFSIZ, %edx		/* byte count */
	int	$0x80
	movl	%eax, -4(%ebp)		/* -> cnt */
		/* if > 0 -- continue */
	cmpl	$0, -4(%ebp)
	jle	cat_1
		/* write */
	movl	$SYS_write, %eax
	movl	$STDOUT, %ebx		/* fd */
	movl	%esp, %ecx		/* buf */
	movl	-4(%ebp), %edx		/* byte count */
		/* if != cnt -- error */
	cmpl	%eax, -4(%ebp)
	je	cat_0
	movl	$WRITE_ERR, %eax
	jmp	cat_2
cat_1:
	movl	$NO_ERR, %eax
	cmpl	$0, -4(%ebp)
	je	cat_2
	movl	$READ_ERR, %eax
cat_2:
		/* clean up */
	addl	$(BUFSIZ + 4), %esp
	movl	%ebp, %esp
	popl	%ebp
	ret
	
