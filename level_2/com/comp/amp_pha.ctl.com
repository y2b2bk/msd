DSET    ^amp_pha
UNDEF   missing
XDEF    1 LINEAR 1. 1.
YDEF    1 LINEAR 1. 1.
ZDEF    1 LEVELS 1000
TDEF    num_t LINEAR jan1979 1dy
VARS    2
amp     0  0 principal component(timeseries of eigenvector)
pha     0  0 principal component(timeseries
enDVARS
