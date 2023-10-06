#FC   = f90
#FC   = ifort -assume byterecl -traceback -g
FC = gfortran

FOBJ =  stps.o libfftpack.a

stps:  $(FOBJ)
	$(FC) $(FFLAGS) $(FOBJ) -o $@
stps.o : stps.f90
	$(FC) $(FFLAGS) -c $<

#
#       "make clean" invokes this part:
#
clean:
	rm -f sswm sswm*.o core *.o fort.* GNFB08 gmeta
	ls -al
