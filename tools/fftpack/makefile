LIB=fftpack
FFLAGS=-O
OBJ=\
cfftb.o\
cfftb1.o\
cfftf.o\
cfftf1.o\
cffti.o\
cffti1.o\
cosqb.o\
cosqb1.o\
cosqf.o\
cosqf1.o\
cosqi.o\
cost.o\
costi.o\
ezfft1.o\
ezfftb.o\
ezfftf.o\
ezffti.o\
passb.o\
passb2.o\
passb3.o\
passb4.o\
passb5.o\
passf.o\
passf2.o\
passf3.o\
passf4.o\
passf5.o\
radb2.o\
radb3.o\
radb4.o\
radb5.o\
radbg.o\
radf2.o\
radf3.o\
radf4.o\
radf5.o\
radfg.o\
rfftb.o\
rfftb1.o\
rfftf.o\
rfftf1.o\
rffti.o\
rffti1.o\
sinqb.o\
sinqf.o\
sinqi.o\
sint.o\
sint1.o\
sinti.o

FC=gfortran
FFLAGS=

#lib$(LIB).a:	$(OBJ)
#	update lib$(LIB).a $?
lib$(LIB).a: $(OBJ)
	ar -rcs lib$(LIB).a $(OBJ)

install:	lib$(LIB).a
	mv lib$(LIB).a /usr/local/lib
	rm *.o

.f90.o:
	${FC} ${FFLAGS} -c $<

clean:
	rm -f *.o *.a
