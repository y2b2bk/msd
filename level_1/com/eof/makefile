#FFLAGS= -O4
#FC = ifort -assume byterecl
FC = gfortran
FOBJ =  libfftpack.a

#power.o: power.f90
#	${FC} ${FFLAGS} -c $<

power:  power.f90 $(FOBJ)
	  $(FC) $(FFLAGS) $? -o $@

clean:
	rm -f sswm sswm*.o core *.o fort.* GNFB08 gmeta
	ls -al
