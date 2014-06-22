	#
# Makefile for the ttysnoop programs
#

CC	= gcc

# Without shadow support

#CCOPTS	= -O2
#LIBS	= 

# For shadow support

CCOPTS	= -O2 -DSHADOW_PWD
LIBS	= -lshadow

SERVEROBJS	= ttysnoops.o common.o
CLIENTOBJS	= ttysnoop.o common.o
SERVERSRCS	= ttysnoops.c
CLIENTSRCS	= ttysnoop.c
INCLUDES	= config.h common.h

all:		ttysnoops ttysnoop

ttysnoops:	$(SERVEROBJS)
		$(CC) $(SERVEROBJS) -o ttysnoops $(LIBS)

ttysnoop:	$(CLIENTOBJS)
		$(CC) $(CLIENTOBJS) -o ttysnoop $(LIBS)

ttysnoops.o:	$(SERVERSRCS) $(INCLUDES)
		$(CC) $(CCOPTS) -c -o ttysnoops.o $(SERVERSRCS)

ttysnoop.o:	$(CLIENTSRCS) $(INCLUDES)
		$(CC) $(CCOPTS) -c -o ttysnoop.o $(CLIENTSRCS)

common.o:	common.c common.h
		$(CC) $(CCOPTS) -c -o common.o common.c

clean:
		rm -f *~ *.o core ttysnoop ttysnoops

install:
		install -s ttysnoop ${DESTDIR}/${PREFIX}/sbin
		install -s ttysnoops ${DESTDIR}/${PREFIX}/sbin
		install -m 644 ttysnoop.8 ${DESTDIR}/usr/man/man8/
		cp snooptab.dist ${DESTDIR}/${PREFIX}/etc/snooptab
		@echo ... copy snooptab.dist to /etc/snooptab and edit it ...
 
