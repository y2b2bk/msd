input_type='gdat'
          ='asc'
     
&input
input_type='gdat',
input_name='homedir/level_1/variable/data/daily.anom.period.gdat',
i_format    ='(E13.5)',
nx       = num_x,
ny       = num_y,
nt      = num_t,
flt_coef='coef.dat',
missing_value = dmiss
&end

&output
output_type='gdat',
output_name='homedir/level_1/variable/data/daily.filt.20-100.lanz.100.period.gdat',
o_format     ='(E13.5)',
&end
