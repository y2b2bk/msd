DSET   ^power.asy.gdat
UNDEF  missing
TITLE SPCTIME OUTPUT
XDEF  ctl_x LINEAR   cbg_x 1.0
YDEF   49 LEVELS   0.000  0.010  0.021  0.031  0.042  0.052  0.063  0.073  0.083  0.094  0.104  0.115  0.125  0.135  0.146  0.156  0.167  0.177  0.188  0.198  0.208  0.219  0.229  0.240  0.250  0.260  0.271  0.281  0.292  0.302  0.313  0.323  0.333  0.344  0.354  0.365  0.375  0.385  0.396  0.406  0.417  0.427  0.438  0.448  0.458  0.469  0.479  0.490  0.500
ZDEF  1 LEVELS   1000.        
TDEF  1 LINEAR 1jan1979 1dy   
VARS 1                        
power      0    99   power    
ENDVARS                       
