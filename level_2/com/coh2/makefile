#FFLAGS= -O4
#FC = ifort -assume byterecl
FC = gfortran

FOBJ =  spctime.o libfftpack.a

spctime:  $(FOBJ)
	  $(FC) $(FFLAGS) $(FOBJ) -o $@
spctime.o : spctime.f90
	  $(FC) $(FFLAGS) -c $<

clean:
	rm -f sswm sswm*.o core *.o fort.* GNFB08 gmeta
	ls -al
