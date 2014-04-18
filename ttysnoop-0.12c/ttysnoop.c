/*
	ttysnoop.c
	
	ttysnoop is the client to ttysnoops. it can only be used on ptys
	that are snooped via a socket 'device' in /etc/snooptab.
	
	v0.00	9-1-94	Carl Declerck	- first version
	v0.10	8-8-94	     ""		- bug fixes
	v0.11	9-8-94       ""		- pwd authentication
	v0.12	6-9-94	     ""		- see ttysnoops.c
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <linux/time.h>
#include <linux/un.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <grp.h>
#include <utmp.h>
#include <errno.h>

#include "config.h"
#include "common.h"

#define BUFF_SIZE	256

char buff[BUFF_SIZE];

int main (int argc, char *argv[])
{
	fd_set readset;
	struct sockaddr_un sock_addr;
	int sockfd, fdmax, quit = 0, n;
	char sockname[128];
	
	if (argc < 2)
		errorf ("Usage: ttysnoop <pty>\n");
	
	/* create the client socket */
	
	if ((sockfd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0)
		errorf ("can't create client socket\n");
	
	sprintf (sockname, "%s/%s", SPOOLDIR, argv[1]);
	sock_addr.sun_family = AF_UNIX;
	strncopy (sock_addr.sun_path, sockname);
	if (connect(sockfd, (struct sockaddr *) &sock_addr, sizeof(sock_addr)) < 0)
		errorf ("can't connect to server\n");
	
	/* put stdin into raw mode */
	
	stty_initstore ();
	atexit (stty_orig);
	if (isatty(STDIN_FILENO))
		stty_raw (STDIN_FILENO);

	/* calc max file descriptor for select() */
	
	fdmax = max(STDIN_FILENO, sockfd);
	
	/* do our thing */
	
	while (!quit)
	{
		FD_ZERO (&readset);
		FD_SET (STDIN_FILENO, &readset);
		FD_SET (sockfd, &readset);
		
		select (fdmax + 1, &readset, NULL, NULL, NULL);
		
		if (FD_ISSET(STDIN_FILENO, &readset))
		{
			n = read(STDIN_FILENO, buff, BUFF_SIZE);

			if (write(sockfd, buff, n) < 0)
				quit = 1;
		}
		
		if (FD_ISSET(sockfd, &readset))
		{
			if ((n = read(sockfd, buff, BUFF_SIZE)) < 1)
				quit = 1;

			if (n > 0)
				write (STDOUT_FILENO, buff, n);
		}
	}
	
	printf ("\r\nBack at local tty.\r\n");
}
