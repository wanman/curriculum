#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>

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
	int fd;

	if (argc == 1)
		cat(STDIN);
	else {
		while (--argc) {
			fd = open(*++argv, O_RDONLY);
			cat(fd);
			close(fd);
		}
	}

	exit(0);
}
