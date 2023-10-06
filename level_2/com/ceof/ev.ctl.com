DSET ^ceof.ev
UNDEF  missing
XDEF  num_x LINEAR beg_lon del_lon
YDEF    1 LINEAR 0 2.5
ZDEF    3 LEVELS 1000 850 200
TDEF    1  LINEAR  jan00 1mon
VARS    10
ev1      3  0 ave for filtering anomaly of 20N-20S
ev2      3  0 ave for filtering anomaly of 20N-20S
ev3      3  0 ave for filtering anomaly of 20N-20S
ev4      3  0 ave for filtering anomaly of 20N-20S
ev5      3  0 ave for filtering anomaly of 20N-20S
ev6      3  0 ave for filtering anomaly of 20N-20S
ev7      3  0 ave for filtering anomaly of 20N-20S
ev8      3  0 ave for filtering anomaly of 20N-20S
ev9      3  0 ave for filtering anomaly of 20N-20S
ev10     3  0 ave for filtering anomaly of 20N-20S
ENDVARS

