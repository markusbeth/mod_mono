#!/bin/sh 

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

ORIGDIR=`pwd`
cd $srcdir
PROJECT=mod_mono
TEST_TYPE=-f
FILE=src/mod_mono.c

DIE=0

(autoconf --version) < /dev/null > /dev/null 2>&1 || {
	echo
	echo "You must have autoconf installed to compile $PROJECT."
	echo "Download the appropriate package for your distribution,"
	echo "or get the source tarball at ftp://ftp.gnu.org/pub/gnu/"
	DIE=1
}

if [ -z "$LIBTOOL" ]; then
  LIBTOOL=`which glibtool 2>/dev/null` 
  if [ ! -x "$LIBTOOL" ]; then
    LIBTOOL=`which libtool`
  fi
fi

(grep "^AM_PROG_LIBTOOL" $srcdir/configure.in >/dev/null) && {
  ($LIBTOOL --version) < /dev/null > /dev/null 2>&1 || {
    echo
    echo "**Error**: You must have \`libtool' installed to compile mod_mono."
    echo "Get ftp://ftp.gnu.org/pub/gnu/libtool-1.2d.tar.gz"
    echo "(or a newer version if it is available)"
    DIE=1
  }
}

(automake --version) < /dev/null > /dev/null 2>&1 || {
	echo
	echo "You must have automake installed to compile $PROJECT."
	echo "Get ftp://sourceware.cygnus.com/pub/automake/automake-1.4.tar.gz"
	echo "(or a newer version if it is available)"
	DIE=1
}

if test "$DIE" -eq 1; then
	exit 1
fi

test $TEST_TYPE $FILE || {
	echo "You must run this script in the top-level $PROJECT directory"
	exit 1
}

if test -z "$*"; then
	echo "I am going to run ./configure with no arguments - if you wish "
        echo "to pass any to it, please specify them on the $0 command line."
fi

case $CC in
*xlc | *xlc\ * | *lcc | *lcc\ *) am_opt=--include-deps;;
esac
aclocal

(autoheader --version)  < /dev/null > /dev/null 2>&1 && autoheader || exit 1

if grep "^AM_PROG_LIBTOOL" configure.in >/dev/null; then
  if test -z "$NO_LIBTOOLIZE" ; then 
    ${LIBTOOL}ize --force --copy
  fi
fi

automake -a $am_opt
autoconf
cd $ORIGDIR

$srcdir/configure "$@"

if [ $? -eq 0 ] ; then
	echo "Now type 'make' to compile $PROJECT."
fi

