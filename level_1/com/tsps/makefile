#FFLAGS= -O4
#FC = ifort
FC = gfortran
#FFLAGS=-assume byterecl

#FOBJ =  power.o libfftpack.a
FOBJ =  power.f90 libfftpack.a

power : $(FOBJ)
	  $(FC) $(FFLAGS) $(FOBJ) -o $@ 
#power.o : power.f90
#	  $(FC) $(FFLAGS) -c $<

clean:
	rm -f sswm sswm*.o core *.o fort.* GNFB08 gmeta
	ls -al
