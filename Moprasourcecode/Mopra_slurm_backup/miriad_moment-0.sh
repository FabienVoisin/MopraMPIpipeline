# Miriad shell-script

# Makes -0 moment maps (integrated intensity maps within a velocity ranges) from .fits files



rm -Rf miriad.out miriad2.out 
rm -Rf integrated.out
rm -rf *.def
declare -f val
fname=`basename $1 .fits`

echo Input file: $1
file1=$1 # First argument -> input fits file
vel1=$2 # Second argument -> lower velocity range
vel2=$3 # Third argument -> Higher velocity range

fits in=$1 op=xyin out=miriad.out
imsub in=miriad.out region="kms,images(${vel1} , ${vel2})" out=miriad2.out
#imsub in=miriad.out region="images(${vel1} , ${vel2})" out=miriad2.out
moment in=miriad2.out region="images(0)" out=integrated.out mom=0 axis=3
fits in=integrated.out op=xyout out=${fname}-0moment_${vel1}_${vel2}.fits
#imstat in=miriad.out log=blabla.txt
#val=0.42 
#maths exp=integrated.out/${val} out=sigmaCS
#fits in=sigmaCS op=xyout out=${fname}-0moment_${vel1}_${vel2}_test.fits
rm -rf *.def integrated.out miriad.out miriad2.out sigmaCS

echo Output file: ${fname}-0moment_${vel1}_${vel2}.fits
