include 'livedatareducer.g'

# glish -l ldata.g -plain
## Check that AIPSPATH is defined.
#if (!has_field(environ, 'AIPSPATH')) {
#  print 'AIPSPATH is not defined - abort!'
#  exit
#}

# Directories for RPF, SDFITS, and FITS files
rpf_dir := '../tempoutputdir/'
sdf_dir := './'

# Input RPF files (on command line)

files := shell('cd', rpf_dir, '&& ls temp.rpf')

# Which IF to select

# Parameters for livedatareducer.g
ldred := reducer(config     = 'MOPRA',
                 bandpass   = T,
                 monitor    = F,
                 writer     = T,
                 stats      = F,
                 read_dir   = rpf_dir,
                 write_dir  = sdf_dir)

# Create a GUI so we can see what's going on.
#ldred->showgui()
#t := client("timer -oneshot", 3.0)
#await t->ready

# Configure Multibeam Reader
ldred.reader-> setparm([beamsel     = [T,F,F,F,F,F,F,F,F,F,F,F,F],
#               IFsel       = [T,T,F,F,F,F,F,F,F,F,F,F,F,F,F,F],
               startChan   = 1,
               endChan     = 4096,
               getXpol     = F,
               rateTest    = 'NONE',
               interpolate = T,
               calibrate   = F])

# Configure the bandpass client.
#ldred.bandpass->setparm([smoothing='NONE', 
#                 method='REFERENCED',
#                 xbeam=F,
#                 fit_order=1,
#                 doppler_frame='LSRK',
#                 rescale_axis=T,
#                 continuum=F,
#                 chan_mask = [1,150,0,0,0,0,0,0,3900,4096] ,
#                 estimator='MEAN'])

ldred.bandpass->setparm([smoothing = 'NONE',
                 prescale_mode     = 'NONE', 
                 method            = 'REFERENCED',
                 estimator         = 'MEAN',
                 statratio         = T,
                 xbeam             = F,
                 chan_mask         = [1,400,0,0,0,0,0,0,3700,4096],
                 fit_order         = 1,
                 continuum         = F,                 
                 doppler_frame     = 'LSRK',
                 rescale_axis      = T,
                 check_field       = F,
                 check_time        = F,
                 check_position    = F])


# Process a batch of files through livedata.
for (read_file in files) {
  if (read_file !~ m/\.rpf/) next
  print 'Processing', read_file
  doif := [F,F,F,F,F,F,T,F]
  CollectIF := [F,F,F,F,F,F,F,F]
  for (ifno in 1:8) {
   if( doif[ifno] == T ){
    print 'Working on IF', ifno
    
    rootname := read_file ~ s/(\.rpfix|\.rpf)//
    CollectIF[ifno] := T
    write_file := spaste(rootname,'-IF',ifno)
    ldred.reader->setparm(IFsel=CollectIF)
    ldred->start([read_file=read_file,write_file=write_file])
    await ldred->finished
    CollectIF[ifno] := F
  }
}
}
# Finished with livedata.
print 'Closing down livedata...'
ldred->terminate()
await ldred->done
print 'Finished livedata processing.'

exit
