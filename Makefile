#
# Makefile to compile the Fortran server / C client demo.
# Very basic. Just type make.
#

all:
	gfortran -c str2int_mod.f90
	gfortran -o server server.f90 str2int_mod.o -fno-underscoring
	gcc -o client client.c
