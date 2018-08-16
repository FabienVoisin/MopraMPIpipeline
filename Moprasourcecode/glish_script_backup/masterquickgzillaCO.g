include 'gridzilla.g'

# Check that AIPSPATH is defined.
#if (!has_field(environ, 'AIPSPATH')) {
#  print 'AIPSPATH is not defined - abort!'
#  exit
#}

# Project number
#proj := 'CTB37A'
proj := 'projectname'
#proj := 'TestFit'
#proj := 'w28'
rootname := proj ~ s/.sdfits// 

# Directories for SDFITS and FITS files
#sdf_dir := '../../SdFits/'
sdf_dir := '../tempinputdir/'
fits_dir := './'

# Velocity/frequency information
vel1 := lowervelocity
vel2 := uppervelocity

# Control which lines to analyse (T/F)
doloop := [F, # IF 1 (window 0) 
           F, # IF 2 (window 1)
           F, # IF 3 (window 2)
           F, # IF 4 (window  3)
           F, # IF 5 Empty
           F, # IF 6 (window 5)
           T, # IF 7 Empty
           F] # IF 8 (window 7)           

# Define which IF corresponds to freqs & molecule names below
ifname := [1,2,3,4,5,6,7,8]
rfreq := [110201.353,  # IF 1 (window 0)
          110201.353,   # IF 2 42519.373 (window 1)
          109792.173,   # IF 3 42820.582 (window 2)
          109782.173,   # IF 4 (window 3)
          112358.985,   # IF 5 Empty
          115271.202,   # IF 6 (window 5)
          115271.202,   # IF 7 Empty
          115271.202]   # IF 8 (window 7)
          

oname := ['13CO1-0', # IF 1 (window 0)
          '13CO1-0',    # IF 2 (window 1)
          'C18O1-0',    # IF 3 (window 2)
          'C18O1-0',    # IF 4 (window 3)
          'C17O1-0',         # IF 5 Dummy
          'CO1-0',    # IF 6 (window 5)
          'CO1-0',         # IF 7 Dummy
          'CO1-0'] # IF 8 (window 7)
                  


# Set up the gridder.
        lsg := gridzilla(beamsel = [T,F,F,F,F,F,F,F,F,F,F,F,F],
                 remote = T,
                 autosize = F,  
                 pixel_width = 0.25,
                 pixel_height = 0.25,
                 rangeSpec = 'velocity',
                 startSpec = vel1,
                 endSpec = vel2,
                 pol_op = 'A&B',
                 spectral = T,
                 continuum = F,
                 baseline = F,
                 chkpt = [F,F],
                 projection = 'SIN',
                 coordSys ='galactic', # 'equatorial',
                 statistic = 'MEDIAN',
                 tsys = T,
                 tsys_range = [0,200],
                 clip_fraction = 0.0,
                 tsys_weight = T,
                 beam_weight = 0,
                 beam_FWHM = 0.55,
                 beam_normal = F,
                 kernel_type = 'TOP-HAT',
                 kernel_FWHM = 0.5,
                 cutoff_radius = 0.25, # 2.5,
                 blank_level = 0.0,
                 storage = 50,
                 directories = sdf_dir,
                 write_dir = fits_dir,
                 spectype = 'VELO-XXX',
                 short_int = F, 
                 chan_err=0.5,
                 centre_lng  ='longitudetemp',
                 centre_lat  ='latitudetemp',
                 image_width = 300, 
                 image_height = 300,
                 bunit =  'K',
                 bscale = 1.0 )
# Loop through the IFs

# Start off with all IFs turned off
#doif :=   [F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F]
doif :=   [F,F,F,F,F,F,F,F]

for (iloop in 1:8) {
  if (doloop[iloop] == T) {
      rootfilename := 'temporaryfilename' ~ s/IF[1-8].sdfits//

      ifno := ifname[iloop]
      iloop2 := iloop - 1
      iloop3 := iloop + 1
        if (iloop < 5) 
     { 
     tsys := [100.0,  720.0]
     doif[1:4] := T
        dolist := spaste('cd ',sdf_dir,' && ls -d ',rootfilename,'IF',iloop,'.sdfits',' && ls -d ',rootfilename,'IF',iloop2,'.sdfits')

     }
  if (iloop == 5) 
     {
     tsys := [100.0,  700.0]
     dolist := spaste('cd ',sdf_dir,' && ls -d ',rootfilename,'IF',iloop,'.sdfits')
     doif[iloop] := T
     }
  if (iloop > 5) 
     {
     tsys := [300.0,  1000.0]
     dolist := spaste('cd ',sdf_dir,' && ls -d ',rootfilename,'IF',iloop2,'.sdfits',' && ls -d ',rootfilename,'IF',iloop,'.sdfits', ' && ls -d ',rootfilename,'IF',iloop3,'.sdfits')
     doif[6:8] := T
     }
  endif

      #doif[iloop] := T
      print 'Working on IF', iloop
     # dolist := spaste('cd ', sdf_dir,' && ls ', proj)
      #dolist := spaste('cd ',sdf_dir,' && ls -d *IF',ifno,'.sdfits')
      files := shell(dolist)
      write_file := spaste(rootname,'_raw_',oname[iloop],'_',vel1,'_',vel2,'_IF',iloop)
      print 'writefile: ',write_file
      print 'restfreq: ',rfreq[iloop]
      lsg->go([restFreq=rfreq[iloop],IFsel=doif,files=files,
               selection=ind(files),p_FITSfilename=write_file, 
               tsys_range=tsys])
      await lsg->finished
      doif[ifno] := F
  }
}       
        
  
# Finished with gridzilla.
print 'Closing down gridzilla...'
lsg->terminate()
await lsg->done

exit

