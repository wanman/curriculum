#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

#define STDIN		0	/* standart streams */
#define STDOUT		1
#define STDERR		2

#define NO_ERR		0	/* error constants */
#define READ_ERR	(-1)
#define WRITE_ERR	(-2)
#define OPEN_ERR	(-3)

#undef BUFSIZ
#define BUFSIZ		(1 << 12)	/* better to be divident of block */

int cat(int fd)
{
	char buf[BUFSIZ];
	int bc;

	while ((bc = read(fd, buf, BUFSIZ)) > 0)
		if (write(STDOUT, buf, bc) != bc)
			return WRITE_ERR;
	return bc ? READ_ERR : NO_ERR;
}

int main(int argc, char *argv[])
{
	int fd, res;

	if (argc == 1) {
		cat(STDIN);
			/* check err here */
	} else {
		while (--argc) {
			fd = open(*++argv, O_RDONLY);
			if (fd == -1) {
				write(STDERR, "open err\n", 9);
				exit(1);
			}
			cat(fd);
				/* check err here */
			close(fd);
		}
	}

	exit(0);
}
		
