
include 'gridzilla.g'

# Change the outfile name appropriately
#set outfile=BLASTcore

# Check that AIPSPATH is defined.
#if (!has_field(environ, 'AIPSPATH')) {
#  print 'AIPSPATH is not defined - abort!'
#  exit
#}

# Directories for SDFITS and FITS files
sdf_dir  := '../SDFITS'
fits_dir := '../image'

# Output file name (from command line)
rootname := argv[3]

# Velocity/frequency information
#vel1 := -115
#vel2 := 85
#vel1 := -140
#vel2 := +60
#vel1 := -90
#vel2 := 20
vel1 := -100
vel2 := +100

# CO J=1-0 with 8 Ifs
rfreq := [110201.353, 110201.353, 109782.173, 109782.173, 112358.985, 115271.202, 115271.202, 115271.202]
#rfreq := [115271.202]
# Set up the gridder.
lsg := gridzilla(beamsel       = [T,F,F,F,F,F,F,F,F,F,F,F,F],
               rangeSpec     = 'VELOCITY',
               startSpec     = vel1,
               endSpec       = vel2,
               pol_op        = 'A&B',
               daynight      = 'BOTH',
               tsys          = T,
               continuum     = F,
               baseline      = F,
               spectral      = T,
               chkpt         = [F,F],
               projection    = 'SIN',
               pv            = array(0.0, 20),
               refpoint      = F,
               autosize      = F,
               intrefpix     = F,
               centre_lng    = '283.5',
               centre_lat    =  '0.0',
               pixel_width   = 0.25,
               pixel_height  = 0.25,
	       image_width = 262,
               image_height = 262,
               data_range    = [-100.0, 100.0],
               chan_err      =  0.5,
#               statistic     = 'MEANSN',
# NB MEDIAN processes much more quickly than MEANSN!! 
# Also does a much better job with the bad pixels
               statistic     = 'MEDIAN',
               clip_fraction = 0,
               tsys_weight   = T,
               beam_weight   = 0,
               beam_FWHM     = 0.55,
               beam_normal   = F,
               kernel_type   = 'TOP-HAT',
               kernel_FWHM   = 0.5,
               cutoff_radius = 0.25,
               blank_level   = 0.0,
               spectype      = 'VELO-XXX',
               bunit         = 'K',
               bscale        = 1.0,
               remote = T,
               coordSys = 'galactic',
               storage = 50, 
               directories = sdf_dir,
               write_dir = fits_dir,
               short_int = F)

# Loop through the 8 IFs (Change ifno line if necessary)
doif := [T,T,T,T,T,T,T,T,F,F,F,F,F,F,F,F]
for (ifno in 7) {
  print 'Working on IF', ifno
  if (ifno < 5) 
     { 
     dolist := spaste('cd ',sdf_dir,' && ls -d *IF',ifno,'.sdfits')
     tsys := [100.0,  720.0]
     print 'hello'
     doif[1:4] := T
     }
  if (ifno == 5) 
     {
     print 'am I here?'
     dolist := spaste('cd ',sdf_dir,' && ls -d *IF5.sdfits')
     tsys := [100.0,  700.0]
     doif[5] := T
     }
  if (ifno > 5) 
     {
     print 'but am I here?'
     dolist := spaste('cd ',sdf_dir,' && ls -d *IF',ifno,'.sdfits')
     tsys := [300.0,  1000.0]
     doif[7] := T
     }
  endif
  files := shell(dolist)

  write_file := spaste(rootname,'-IF',ifno)
  print 'writefile: ',write_file
  print tsys

  print 'restfreq: ',rfreq[ifno]
  lsg->go([restFreq=rfreq[ifno],IFsel=doif,files=files,
  	selection=ind(files),p_FITSfilename=write_file,
        tsys_range=tsys])
  await lsg->finished
  doif := [F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F]
}

# Finished with gridzilla.
print 'Closing down gridzilla...'
lsg->terminate()
await lsg->done
print 'Finished Gridzilla processing'
exit
