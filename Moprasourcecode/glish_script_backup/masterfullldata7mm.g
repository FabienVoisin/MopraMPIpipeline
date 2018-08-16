include 'livedatareducer.g'

# Check that AIPSPATH is defined.
#if (!has_field(environ, 'AIPSPATH')) {
#  print 'AIPSPATH is not defined - abort!'
#/  exit
#}

# Directories for RPF, SDFITS, and FITS files
rpf_dir := '../tempoutputdir/'
sdf_dir := './'

# Input RPF files (on command line)

files := shell('cd', rpf_dir, '&& ls temp.rpf')



# Which IF to select

# Parameters for livedatareducer.g
ldred := reducer(bandpass   = T,
                 monitor    = F,
                 writer     = T,
                 stats      = F,
                 read_dir   = rpf_dir,
                 write_dir  = sdf_dir)

# Create a GUI so we can see whats going on.
#ldred->showgui()
#t := client("timer -oneshot", 3.0)
#await t->ready

# Configure the bandpass client.
ldred.bandpass->setparm([smoothing='NONE', 
                 method='REFERENCED',
                 xbeam=F,
                 fit_order=1,
                 doppler_frame='LSRK',
                 rescale_axis=T,
                 continuum=F,
                 chan_mask = [1,1330,0,0,0,0,0,0,2330,4096] ,
                 estimator='MEAN'])


# Process a batch of files through livedata.
for (read_file in files) {
  if (read_file !~ m/\.rpf/) next
  print 'Processing', read_file
  doif := [T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T]
  CollectIF := [F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F]
  for (ifno in 1:16) {  # for (ifno in 1:16) {
          if ( doif[ifno] == T ){
              print 'Working on IF', ifno
              
              rootname := shell('echo ',read_file," | sed 's/.rpf//'") 
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
