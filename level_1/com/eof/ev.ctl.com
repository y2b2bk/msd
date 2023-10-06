DSET ^eof.ev
UNDEF   missing
XDEF   sel_x LINEAR beg_lon del_lon
YDEF   sel_y LINEAR beg_lat del_lat
ZDEF    1 LEVELS 1000
TDEF    1  LINEAR  jan00 1mon
VARS    10
ev1      0  0 ev1
ev2      0  0 ev2
ev3      0  0 ev3
ev4      0  0 ev4
ev5      0  0 ev5
ev6      0  0 ev6
ev7      0  0 ev7
ev8      0  0 ev8
ev9      0  0 ev9
ev10     0  0 ev10
ENDVARS

