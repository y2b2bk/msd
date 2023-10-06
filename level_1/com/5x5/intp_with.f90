!***********************************************************************
!                                                                      
! bilini: bilinear interpolation from an irregular grid to an irregular 
!         grid.  allows different types of interpolation in each        
!         direction, i.e., linear or linear in log of the coordinate.  
!         if the extrapolation flag is false and any part of the        
!         receiving grid is outside the original grid, then an undefined
!         value is assigned - no extrapolation is done.                 
!                                                                       
! arguments:                                                            
!                                                                       
!   qfrom  - values of quantity on the 'from' grid (grid being          
!            interpolated from)                                         
!   xfrom  - abscissa values of the 'from' grid lines in the x direction
!   yfrom  - ordinate values of the 'from' grid lines in the y direction
!   nxfrom - number of 'from' grid lines in the x direction             
!   nyfrom - number of 'from' grid lines in the y direction             
!   qto    - values of quantity on the 'to' grid (grid being            
!            interpolated to)                                           
!   xto    - abscissa values of the 'to' grid lines in the x direction  
!   yto    - ordinate values of the 'to' grid lines in the y direction  
!   nxto   - number of 'to' grid lines in the x direction               
!   nyto   - number of 'to' grid lines in the y direction               
!   xintp  - type of interpolation to do in the x direction             
!            'linear': linear in the abscissa values                    
!            'linlog': linear in the log of the abscissa values         
!   yintp  - type of interpolation to do in the y direction             
!            'linear': linear in the ordinate values                    
!            'linlog': linear in the log of the ordinate values         
!   extrap - extrapolation flag                                         
!            t: extrapolation will be done to 'to' grid                 
!            f: no extrapolation will be done, values on 'to' grid      
!               outside the 'from' grid will be set to 'undef'          
!   undef  - undefined value specified by the user.  if any of the      
!            'from' grid points surrounding a 'to' grid point have this 
!            value, then no interpolation is done and the 'to' grid     
!            point is assigned this same value.  if there are no        
!            undefined values on the 'from' grid, then set undef to a   
!            value that does not appear on the 'from' grid.  undef is   
!            also assigned to any 'to' grid points that are outside of  
!            the 'from' grid if extrap is false.                        
!   nundef - number of grid points that were assigned the undefined     
!            value because missing values on the 'from' grid precluded  
!            any interpolation or because they were outside the 'from'  
!            grid.  also will be set to -1 if either xintp or yintp are 
!            invalid.                                                   
!                                                                       
! schematic of interpolation method                                     
!                                                                       
!                            .           |        .                     
!                            .           |        .                     
!         yfrom(jfroma) ................................                
!                            .           |        .                     
!                            .           |        .                     
!              yto(jto) _____.___________|________._____                
!                            .           |        .                     
!         yfrom(jfromb) ................................                
!                            .           |        .                     
!                            .           |        .                     
!                          xfrom        xto     xfrom                   
!                        (ifromb)      (ito)  (ifroma)                  
!                                                                       
!     ..... 'from' grid: interpolation done from this grid.  values     
!           given by qfrom(ifrom,jfrom)                                 
!                                                                       
!     _____ 'to' grid: interpolation done to this grid.  values stored  
!           in qto(ito,jto)                                             
!                                                                       
!***********************************************************************
                                                                        
  subroutine bilini(qfrom,xfrom,yfrom,nxfrom,nyfrom,qto,xto,yto, &   
      nxto,nyto,xintp,yintp,extrap,undef,nundef)      
  implicit none

  integer :: nxfrom, nyfrom, nxto, nyto
  real, dimension(nxfrom, nyfrom) :: qfrom
  real, dimension(nxfrom) :: xfrom
  real, dimension(nyfrom) :: yfrom
  real, dimension(nxto, nyto) :: qto 
  real, dimension(nxto) :: xto
  real, dimension(nxto) :: yto
  integer :: nundef, ifroma, jfroma, ito, jto, ifromb, jfromb
  real :: xwght, ywght, undef, qfia, qfib

  character(len=8) :: xintp, yintp                                          
  logical extrap                                        

  nundef=0                                            
  jfroma=2                                           

! loop over all ordinate values on 'to' grid            
! ------------------------------------------           
                                                      
  do 500 jto=1,nyto                              
                                                    
! determine indexes on 'from' grid that bracket the current ordinate on 
! the 'to' grid                                                         
! --------------------------------------------------------------------- 
                                                                        
   60    if (jfroma.eq.nyfrom) goto 70                                  
         if (yfrom(jfroma).ge.yto(jto)) goto 70                         
         jfroma=jfroma+1                                                
         goto 60                                                        
   70    jfromb=jfroma-1                                                
                                                                        
! determine interpolation weighting in y direction                      
! ------------------------------------------------                      
                                                                        
         if (yintp.eq.'linear') then                                    
            ywght=(yto(jto)-yfrom(jfromb))/&                             
                 (yfrom(jfroma)-yfrom(jfromb))                         
         else if (yintp.eq.'linlog') then                               
            ywght=alog(yto(jto)/yfrom(jfromb))/&                         
                 alog(yfrom(jfroma)/yfrom(jfromb))                     
         else                                                           
            goto 901                                                    
         end if                                                         
                                                                        
! reset pointer to 'from' grid line that is after the 'to' grid line    
! in the x direction                                                    
! ------------------------------------------------------------------    
                                                                        
         ifroma=2                                                       
                                                                        
! loop over all abscissa values on 'to' grid                            
! ------------------------------------------                            
                                                                        
         do 400 ito=1,nxto                                              
                                                                        
! check that the 'to' grid point is inside the 'from' grid, unless      
! extrap is .true., in which case allow extrapolation                   
! ----------------------------------------------------------------      
                                                                        
     if ((xto(ito).ge.xfrom(1).and.xto(ito).le.xfrom(nxfrom).and.&
        yto(jto).ge.yfrom(1).and.yto(jto).le.yfrom(nyfrom))&    
        .or. extrap ) then                                      
                                                                        
! determine indexes on 'from' grid that bracket the current abscissa    
! on the 'to' grid                                                      
! ------------------------------------------------------------------    
                                                                        
  140          if (ifroma.eq.nxfrom) goto 150                           
               if (xfrom(ifroma).ge.xto(ito)) goto 150                  
               ifroma=ifroma+1                                          
               goto 140                                                 
  150          ifromb=ifroma-1                                          
                                                                        
! determine interpolation weighting in x direction                      
! ------------------------------------------------                      
                                                                        
               if (xintp.eq.'linear') then                              
                  xwght=(xto(ito)-xfrom(ifromb))/&                       
                       (xfrom(ifroma)-xfrom(ifromb))                   
               else if (xintp.eq.'linlog') then                         
                  xwght=alog(xto(ito)/xfrom(ifromb))/&                   
                       alog(xfrom(ifroma)/xfrom(ifromb))               
               else                                                     
                  goto 901                                              
               end if                                                   
                                                                        
! preform interpolation only if all surrounding values on the 'from'    
! grid are defined                                                      
! ------------------------------------------------------------------    
                                                                        
               if (qfrom(ifromb,jfromb).ne.undef.and.&                   
                  qfrom(ifroma,jfromb).ne.undef.and.&                   
                  qfrom(ifromb,jfroma).ne.undef.and.&                   
                  qfrom(ifroma,jfroma).ne.undef) then                  
                                                                        
! interpolation in y direction                                          
! ----------------------------                                          
                                                                        
                  qfib=qfrom(ifromb,jfroma)*ywght+&                      
                      qfrom(ifromb,jfromb)*(1.-ywght)                  
                  qfia=qfrom(ifroma,jfroma)*ywght+&                      
                      qfrom(ifroma,jfromb)*(1.-ywght)                  
                                                                        
! interpolation in x direction                                          
! ----------------------------                                          
                                                                        
                  qto(ito,jto)=qfia*xwght+qfib*(1.-xwght)               
                                                                        
! else at least one surrounding point on the 'from' grid is not         
! defined.  however, if the 'to' grid point coencides with one of the   
! 'from' grid lines, and the values on that 'from' grid line are        
! defined, then an interpolation can be done.                           
! -------------------------------------------------------------------   
                                                                        
               else if (xto(ito).eq.xfrom(ifromb).and.&                  
                       qfrom(ifromb,jfromb).ne.undef.and.&              
                       qfrom(ifromb,jfroma).ne.undef) then             
                                                                        
                  qto(ito,jto)=qfrom(ifromb,jfroma)*ywght+&              
                              qfrom(ifromb,jfromb)*(1.-ywght)          
                                                                        
               else if (xto(ito).eq.xfrom(ifroma).and.&                  
                       qfrom(ifroma,jfromb).ne.undef.and.&              
                       qfrom(ifroma,jfroma).ne.undef) then             
                                                                        
                  qto(ito,jto)=qfrom(ifroma,jfroma)*ywght+&              
                              qfrom(ifroma,jfromb)*(1.-ywght)          
                                                                        
               else if (yto(jto).eq.yfrom(jfromb).and.&                  
                       qfrom(ifromb,jfromb).ne.undef.and.&              
                       qfrom(ifroma,jfromb).ne.undef) then             
                                                                        
                  qto(ito,jto)=qfrom(ifroma,jfromb)*xwght+&              
                              qfrom(ifromb,jfromb)*(1.-xwght)          
                                                                        
               else if (yto(jto).eq.yfrom(jfroma).and.&                  
                       qfrom(ifromb,jfroma).ne.undef.and.&              
                       qfrom(ifroma,jfroma).ne.undef) then             
                                                                        
                  qto(ito,jto)=qfrom(ifroma,jfroma)*xwght+&              
                              qfrom(ifromb,jfroma)*(1.-xwght)          
                                                                        
! else set 'to' grid point to undefined value                           
! -------------------------------------------                           
                                                                        
               else                                                     
                                                                        
                  qto(ito,jto)=undef                                    
                  nundef=nundef+1                                       
                                                                        
               end if                                                   
                                                                        
! else outside 'from' grid and no extrapolation - set to undefined value
! ----------------------------------------------------------------------
                                                                        
            else                                                        
                                                                        
               qto(ito,jto)=undef                                       
               nundef=nundef+1                                          
                                                                        
            end if                                                      
                                                                        
! next 'to' grid point                                                  
! --------------------                                                  
                                                                       
  400    continue                                                       
                                                                        
  500 continue                                                          
                                                                        
      goto 1000                                                         
                                                                        
! error handling                                                        
! --------------                                                        
                                                                      
  901 nundef=-1                                                       
      do 620 jto=1,nyto                                               
         do 610 ito=1,nxto                                            
            qto(ito,jto)=undef                                        
  610    continue                                                     
  620 continue                                                        
                                                                      
 1000 return                                                          
  end subroutine                                                            
