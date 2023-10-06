function main(args)

clevint=subwrd(args,1)
clevnum=subwrd(args,2)
startlv=subwrd(args,3)

if (clevnum='');clevnum=9;endif;
if (startlv='')
   lv0=-clevint*clevnum
   lv1=-lv0
else
   lv0=startlv
   lv1=lv0+(clevnum-1)*clevint
endif

listlevs=''

lvn=lv0
while (lvn<=lv1)
listlevs=listlevs%lvn%' '
lvn=lvn+clevint
endwhile

'set clevs 'listlevs

return
