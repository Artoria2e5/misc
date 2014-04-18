/*
	ttysnoops.c
	
	ttysnoops sets up a pseudo-tty for the specified program and
	redirects its stdin/stdout/stderr to/from the current ctty 
	and a specified snoop device (usually another tty or a socket)
	
	v0.00	4-1-94 Carl Declerck	- first version
	v0.01	6-1-94	     ""		- added /etc/snooptab file
	v0.02	9-1-94	     ""		- added socket support
	v0.10	8-8-94	     ""		- various bug fixes
	v0.11	9-8-94       ""		- password authentication added
	v0.11a 23-8-94 Ulrich Callmeier - shadow support hacked in
	v0.12	6-9-94 Carl Declerck	- added suspend/resume key
	v0.12a	6-8-95 Josh Bailey		- fixed lingering utmp-entry bug
	v0.12b	6-3-96 Carl Declerck	- minor cleanups
	v0.12c 21-3-96 Carl Declerck	- fiexed bug to exit when telnetd exits
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/syslog.h>
#include <linux/time.h>
#include <linux/un.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <termios.h>
#include <grp.h>
#include <pwd.h>
#include <utmp.h>
#include <errno.h>
#ifdef SHADOW_PWD
#include <shadow.h>
#endif
#include "config.h"
#include "common.h"


#define BUFF_SIZE	256

char buff[BUFF_SIZE];

int snoopfd = -1, authfd = -1;
int pgmpid = -1, authpid = -1, servpid = -1;
int use_socket = 0, fdmax = 0, proctype = DEAD_PROCESS;
char snoopdev[32], ptynam[32], childproc[128], sockname[128];


/* read a single line from a stream, ignoring all irrelevant stuff */

int  read_line (char *buff, FILE *f)
{
    int b, i;

    *buff = 0;
    do
    {
        while ((b = fgetc(f)) != EOF && isspace(b));
        if (b == EOF) return (0);
        for (i = 0; b != EOF && b != '\n' && b != '\r'; i++)
        {
            buff[i] = (b == '\t') ? ' ': b;
            b = fgetc(f);
        }
        buff[i] = 0;
    }
    while (*buff == '#');

    return (1);
}

/* extract the first word from a string */

char *parse_arg (char *arg, char *buff)
{
	int i = 0, j = 0, quote = 0;

	*arg = 0;
	if (buff == NULL)
		return (NULL);
		
	while (buff[i] && buff[i] == ' ') i++;
	while (buff[i] && (buff[i] != ' ' || quote))
	{
		switch (buff[i])
		{
			case '\\' :	arg[j++] = buff[++i]; break;
			case '"'  :	quote = !quote; break;
			default   :	arg[j++] = buff[i];
		}
		i++;
   	}	
	while (buff[i] && buff[i] == ' ') i++;
	arg[j] = 0;

	return (j ? buff + i : NULL);
}

/* process the snooptab file */

int process_snooptab (void)
{
	FILE *f;
	char line[1024], arg[128], tty[16], *tail;
	
	if ((f = fopen(SNOOPTAB, "r")) == NULL)
		errorf ("can't open %s\n", SNOOPTAB);
	
	strcpy (tty, leafname(ttyname(STDIN_FILENO)));
	
	while (read_line(line, f))
	{
		tail = parse_arg(arg, line);
		
		if ((strcmp(arg, tty) == 0) || (*arg == '*'))
		{
			tail = parse_arg(snoopdev, tail);
			tail = parse_arg(arg, tail);
			tail = parse_arg(childproc, tail);
			
			if (strcmp(arg, "init") == 0)
				proctype = INIT_PROCESS;
			else if (strcmp(arg, "login") == 0)
				proctype = LOGIN_PROCESS;
			else if (strcmp(arg, "user") == 0)
				proctype = USER_PROCESS;
				
			if (strcmp(snoopdev, "socket") == 0)
				use_socket = 1;
				
			fclose (f);
			return (1);
		}
	}
			
	fclose (f);
	errorf ("no entry for %s in %s\n", tty, SNOOPTAB);
}

/* find & open a pty to be used by the pty-master */

int find_ptyxx (char *ptyname)
{
	int fd, i, j;
	static char *s1 = "pqrs", *s2 = "0123456789abcdef";
	
	strcpy (ptyname, "/dev/ptyxx");
	
	for (i = 0; s1[i]; i++)
	{
		ptyname[8] = s1[i];
		
		for (j = 0; s2[j]; j++)
		{
			ptyname[9] = s2[j];
			
			if ((fd = open(ptyname, O_RDWR)) >= 0)
			{
				ptyname[5] = 't';
				return (fd);
			}
			
			if (errno == ENOENT)
				return (-1);
		}
	}
	
	return (-1);
}

/* find & open a pty (tty) to be used by pty-client */

int find_ttyxx (char *ttyname, int ptyfd)
{
	struct group *grp;
	int gid, fd;
	
	if ((grp = getgrnam("tty")) != NULL)
		gid = grp->gr_gid;
	else
		gid = -1;
	
	chown (ttyname, getuid(), gid);
	chmod (ttyname, S_IRUSR | S_IWUSR | S_IWGRP);
	
	if ((fd = open(ttyname, O_RDWR)) >= 0)
		return (fd);
	
	close (ptyfd);
	return (-1);
}

/* fork off the pty-client and redirect its stdin/out/err to the pty */

int fork_pty (int *ptyfd, char *ttynam)
{
	struct termios term;
	struct winsize twin;
	int ttyfd, pid;
	char name[32];
	
	tcgetattr (STDIN_FILENO, &term);
	ioctl (STDIN_FILENO, TIOCGWINSZ, (char *) &twin);

	if ((*ptyfd = find_ptyxx(name)) < 0)
		errorf ("can't open pty\n");
	
	strcpy (ttynam, leafname(name));
	
	if ((pid = fork()) < 0)
		errorf ("can't fork\n");
	
	if (pid == 0)       /* child */
	{
		if (setsid() < 0)
			errorf ("setsid failed\n");
		
		if ((ttyfd = find_ttyxx(name, *ptyfd)) < 0)
			errorf ("can't open tty\n");
			
		close (*ptyfd);

		if (tcsetattr(ttyfd, TCSANOW, &term) < 0)
			errorf ("can't set termios\n");
		
		if (ioctl(ttyfd, TIOCSWINSZ, &twin) < 0)
			errorf ("can't set winsize\n");
		
		if (dup2(ttyfd, STDIN_FILENO) != STDIN_FILENO)
			errorf ("can't dup2 into stdin\n");
		
		if (dup2(ttyfd, STDOUT_FILENO) != STDOUT_FILENO)
			errorf ("can't dup2 into stdout\n");
		
		if (dup2(ttyfd, STDERR_FILENO) != STDERR_FILENO)
			errorf ("can't dup2 into stderr\n");
		
		if (ttyfd > STDERR_FILENO)
			close (ttyfd);
	}

	return (pid);
}		

void beep (void)
{
	fputc (7, stdout);
	fflush (stdout);
}

void sigalrm (int sig)
{
	sig = sig;

	printf ("\r\nPassword timeout\r\n");
	exit (0);
}

int inputs (char *buff, int max, FILE *f)
{
	int b, l;

	*buff = 0; max--;
	signal (SIGALRM, sigalrm);

	while (1)
	{
		alarm (10);
		if ((b = fgetc(f)) != EOF)
			switch (b)
			{
				case '\r' :
					alarm (0);
					return (0);

				case 8 :
				case 127 :
					if (*buff == 0)
						beep ();
					else
						buff[strlen(buff) - 1] = 0;
					break;

				case 0 :
					break;

				default :
					if (b >= 32 && b < 127)
						if ((l = strlen(buff)) < max)
						{
							buff[l] = b;
							buff[l + 1] = 0;
						}
						else
							beep ();
			}
	}

	return (0);
}
					
void authenticate (int fd)
{
	struct passwd *pw;

#ifdef SHADOW_PWD
	struct spwd *spw;
#endif

	int ret = 0;
	char buff[16], *pwbuff;

	if ((authpid = fork()) == 0)	/* authentication child */
	{
		dup2 (fd, STDIN_FILENO);
		dup2 (fd, STDOUT_FILENO);
		dup2 (fd, STDERR_FILENO);
		if (fd > STDERR_FILENO)
			close (fd);

		if ((pw = getpwnam(SNOOPUSER)) == NULL)
			exit (1);

#ifdef SHADOW_PWD
		if ((spw = getspnam(SNOOPUSER)) == NULL)
		    exit(1);
#endif

		printf ("Connected to %s snoop server...\r\n", ptynam);
		printf ("%s (ASCII %d) to suspend, %s (ASCII %d) to terminate.\r\n",
			SC_STRING, SUSP_CHAR, TC_STRING, TERM_CHAR);
		printf ("Snoop password:"); fflush (stdout);
		if (inputs(buff, 16, stdin) == 0)
		{
#ifndef SHADOW_PWD
			if (strcmp(pw->pw_passwd, crypt(buff, pw->pw_passwd)) == 0)
#else
                        if (strcmp(spw->sp_pwdp, crypt(buff, spw->sp_pwdp)) == 0)
#endif
			{
				printf ("\r\nVerified OK... Snoop started.\r\n");
				ret = 1;
			}
			else
				printf ("\r\nPassword incorrect.\r\n");
		}

		fflush (stdout);
		exit (ret);
	}
}

/* This function added by Josh Bailey, josh@tutor.co.nz, 6 Aug 1995.
   Previous versions of ttysnoop did not remove the pseudo-terminal
   entry from utmp after log out... Meaning people showed up as still
   logged in when they weren't. */

void cleanup_utmp (char ptynam[])
{
	struct utmp utmp;
	
	setutent ();
	strcpy (utmp.ut_line, ptynam);
	utmp = *(getutline(&utmp));
	*utmp.ut_user = 0;
	pututline (&utmp);
	endutent ();
}

/* do a graceful closedown */

void closedown (void)
{
	if (servpid == getpid())	/* only server must clear utmp entry */
		cleanup_utmp (ptynam);
	stty_orig ();
}

/* signal handlers */

void sighup (int sig)
{
	sig = sig;
	closedown ();
}

void sigpipe (int sig)
{
	sig = sig;
	snoopfd = -1;
	
	signal (SIGPIPE, sigpipe);
}

void sigchld (int sig)
{
	int status, pid;
	sig = sig;

	if ((pid = wait(&status)) == authpid)
	{
		if (((status >> 8) & 0xff) == 1)
		{
			snoopfd = authfd;
			fdmax = max(fdmax, snoopfd);
			syslog (LOG_INFO, "snoop on %s (%s)", ttyname(STDIN_FILENO),
						leafname(sockname));
		}
		else
			close (authfd);

		authpid = authfd = -1;
	}
	else if (pid == pgmpid)
		raise (SIGHUP);

	signal (SIGCHLD, sigchld);
}

/* main program */

int main (int argc, char *argv[])
{
	struct sockaddr_un serv_addr, cli_addr;
	fd_set readset;
	struct utmp utmp;
	int ptyfd, servfd, len, n, sel, susp = 0;

	if (!isatty(STDIN_FILENO))
		errorf ("stdin is not a tty\n");

	/* do init stuff */

	servpid = getpid();
	*sockname = 0;
	signal (SIGPIPE, sigpipe);
	signal (SIGCHLD, sigchld);
	signal (SIGHUP, sighup);
	stty_initstore ();
	process_snooptab ();
	openlog ("ttysnoops", LOG_PID, LOG_AUTH);
	atexit (closedown);
	
	/* fork off the client and load the new image */
	
	if ((pgmpid = fork_pty(&ptyfd, ptynam)) == 0)    /* child */
	{
		/* should we update utmp to reflect the change to ttypX ? */

		if (proctype == LOGIN_PROCESS)
		{
			strncopy (utmp.ut_line, ptynam);
			strncopy (utmp.ut_id, ptynam + 3);
			*utmp.ut_host = 0;
			utmp.ut_addr = 0;
			strncopy (utmp.ut_user, "LOGIN");
			utmp.ut_pid = getpid();
			utmp.ut_type = proctype;
			utmp.ut_time = time(NULL);
			pututline (&utmp);
		}
		
		/* exec the real pty-client program */
		
		argv[0] = childproc;
		execv (childproc, &argv[0]);
		
		errorf ("can't exec %s\n", childproc);
	}
	
	/* put stdin into raw mode */
	
	stty_raw (STDIN_FILENO);
	
	/* calc (initial) max file descriptor to use in select() */
		
	fdmax = max(STDIN_FILENO, ptyfd);

	/* is the snoop-device a socket or tty ? */
	
	if (use_socket)
	{
		/* create the main server socket */
		
		if ((servfd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0)
			errorf ("can't create server socket\n");
		
		sprintf (sockname, "%s/%s", SPOOLDIR, ptynam);
		unlink (sockname);
		serv_addr.sun_family = AF_UNIX;
		strncopy (serv_addr.sun_path, sockname);
		if (bind(servfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0)
			errorf ("can't bind server socket (%s)\n", sockname);
			
		if (listen(servfd, 5) < 0)
			errorf ("can't set up listen buffers for server socket\n");
		
		/* update fdmax */
		
		fdmax = max(fdmax, servfd);
	}
	else	/* snoop-dev is a tty */
	{
		/* open snoop-device and put it into raw mode */
		
		if ((snoopfd = open(snoopdev, O_RDWR)) < 0)
			errorf ("can't open snoop device %s\n", snoopdev);
		
		if (isatty(snoopfd))
			stty_raw (snoopfd);
		
		/* update fdmax */
		
		fdmax = max(fdmax, snoopfd);
	}
	
	/* do the main server loop */
	
	while (1)
	{
		do
		{
			FD_ZERO (&readset);
			FD_SET (STDIN_FILENO, &readset);
			FD_SET (ptyfd, &readset);
			if (snoopfd >= 0)
				FD_SET (snoopfd, &readset);
			else if (use_socket && authfd == -1)
				FD_SET (servfd, &readset);

			sel = select(fdmax + 1, &readset, NULL, NULL, NULL);
		}
		while (sel == -1 && errno == EINTR);
		if (sel == -1 && errno != EINTR)
			errorf ("select failed. errno = %d\n", errno);
		
		if (FD_ISSET(STDIN_FILENO, &readset))
		{
			if ((n = read(STDIN_FILENO, buff, BUFF_SIZE)) < 1)
				exit (0);

			write (ptyfd, buff, n);
		}
		
		if ((snoopfd >= 0) && FD_ISSET(snoopfd, &readset))
		{
			n = read(snoopfd, buff, BUFF_SIZE);
			if (!n || ((*buff == TERM_CHAR) && (n == 1) && use_socket))
			{
				close (snoopfd);
				snoopfd = -1;
			}
			else if ((*buff == SUSP_CHAR) && (n == 1) && use_socket)
			{
				if (susp = !susp)
					fdprintf (snoopfd, "\r\nSnoop suspended. %s (ASCII %d) to resume.\r\n",
						SC_STRING, SUSP_CHAR);
				else
					fdprintf (snoopfd, "Snoop resumes...\r\n");
			}
			else
				write (ptyfd, buff, n);
		}
		
		if (FD_ISSET(ptyfd, &readset))
		{
			if ((n = read(ptyfd, buff, BUFF_SIZE)) < 1)
				exit (0);
				
			write (STDOUT_FILENO, buff, n);
			if (!susp && (snoopfd >= 0))
				write (snoopfd, buff, n);
		}

		if (use_socket && (snoopfd < 0) && (authfd < 0) && FD_ISSET(servfd, &readset))
		{
			/* a ttysnoop client wants to connect, create socket */
			
			if ((authfd = accept(servfd, (struct sockaddr *) &cli_addr, &len)) < 0)
				errorf ("can't accept on server socket\n");
			else
			{
				susp = 0;
				authenticate (authfd);
			}

			/* update fdmax */
			
			/* fdmax = max(fdmax, snoopfd); */
		}			
	}
}
