/*
	config.h
	
	edit this to suit your own taste
*/

/* character to terminate ttysnoop client */

#define	TERM_CHAR	31			/* ctrl + '-' */
#define TC_STRING	"Ctrl+'-'"

/* character to suspend/resume ttysnoop client */

#define SUSP_CHAR	28			/* ctrl + '\' */
#define SC_STRING	"Ctrl+'\\'"

/* location of snooptab and named fifos (unix domain sockets) */

#define SNOOPTAB	"/etc/snooptab"	
#define SPOOLDIR	"/var/spool/ttysnoop"

/* which user's password to use for ttysnoop authentication */

#define SNOOPUSER	"root"
