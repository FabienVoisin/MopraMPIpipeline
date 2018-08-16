include 'gridzilla.g'

# Check that AIPSPATH is defined.
#if (!has_field(environ, 'AIPSPATH')) {
#  print 'AIPSPATH is not defined - abort!'
#  exit
#}

# Project number
#proj := 'CTB37A'
proj := 'J1809'
#proj := 'TestFit'
#proj := 'w28'

# Directories for SDFITS and FITS files
#sdf_dir := '../../SdFits/'
sdf_dir := '../g003_part1sdfits/'
fits_dir := './'

# Velocity/frequency information
vel1 := lowervelocity
vel2 := uppervelocity

# Control which lines to analyse (T/F)
doloop := [T, # IF 1 (window 0) 
           T, # IF 2 (window 1)
           T, # IF 3 (window 2)
           T, # IF 4 (window  3)
           T, # IF 5 Empty
           T, # IF 6 (window 5)
           T, # IF 7 Empty
           T, # IF 8 (window 7)
           T, # IF 9 (window 8)
           T, # IF 10 (window 9)
           T, # IF 11 (window 10)
           T, # IF 12 (window 11)
           T, # IF 13 (window 12)
           T, # IF 14 (window 13)
           T, # IF 15 (window 14)
           T] # IF 16 (window 15)

# Define which IF corresponds to freqs & molecule names below
ifname := [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
rfreq := [42373.365,  # IF 1 (window 0)
          42820.582,   # IF 2 42519.373 (window 1)
          43122.079,   # IF 3 42820.582 (window 2)
          43122.079,   # IF 4 (window 3)
          43000.000,   # IF 5 Empty
          43423.864,   # IF 6 (window 5)
          43423.864,   # IF 7 Empty
          44069.476,   # IF 8 (window 7)
          45119.064,   # IF 9 (window 8)
          45264.750,   # IF 10 (window 9)
          45453.720,   # IF 11 45490.340 (window 10)
          46247.580,   # IF 12 46247.580 (window 11)
          47927.580,   # IF 13 (window 12)
          48206.946,   # IF 14 (window 13)
          48651.604,   # IF 15 (window 14)
          48990.957]   # IF 16 (window 15)

oname := ['30SiO1-0_v0', # IF 1 (window 0)
          'SiO1-0v2',    # IF 2 (window 1)
          'SiO1-0v1',    # IF 3 (window 2)
          'SiO1-0v1',    # IF 4 (window 3)
          'Dummy',         # IF 5 Dummy
          'SIO1-0v0',    # IF 6 (window 5)
          'Dummy',         # IF 7 Dummy
          'CH3OHI', # IF 8 (window 7)
          'HC7N40-39',    # IF 9 (window 8)
          'HC5N17-16',    # IF 10 (window 9)
          'H52alpha',# IF 11 (window 10)
          '13CS1-0',      # IF 12 (window 11)
          'HC5N16-15',    # IF 13 (window 12)
          'C34S1-0',      # IF 14 (window 13)
          'OCS4-3',       # IF 15 (window 14)
          'CS1-0']        # IF 16 (window 15)


# Set up the gridder.
lsg := gridzilla(remote = T,
                 autosize = T,  
                 pixel_width = 0.25,
                 pixel_height = 0.25,
                 rangeSpec = 'velocity',
                 startSpec = vel1,
                 endSpec = vel2,
                 pol_op = 'A&B',
                 spectral = T,
                 continuum = F,
                 baseline = F,
                 projection = 'SIN',
                 coordSys ='galactic', # 'equatorial',
                 statistic = 'MEAN',
                 tsys = T,
                 tsys_range = [0,200],
                 clip_fraction = 0.0,
                 tsys_weight = T,
                 beam_weight = 1,
                 beam_FWHM = 1.25,
                 beam_normal = F,
                 kernel_type = 'GAUSSIAN',
                 kernel_FWHM = 0.1,
                 cutoff_radius = 2.5, # 2.5,
                 blank_level = 3.0,
                 storage = 25,
                 directories = sdf_dir,
                 write_dir = fits_dir,
                 spectype = 'VELO-XXX',
                 short_int = F)

# Loop through the IFs

# Start off with all IFs turned off
#doif :=   [F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F]
doif :=   [T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T]

for (iloop in 1:16) {
  if (doloop[iloop] == T) {
      ifno := ifname[iloop]
      doif[ifno] := T
      print 'Working on IF', ifno
      dolist := spaste('cd ',sdf_dir,' && ls -d *IF',ifno,'.sdfits')
      files := shell(dolist)
      write_file := spaste(proj,'_IF',ifno,'_clean2',oname[iloop])
      print 'writefile: ',write_file
      print 'restfreq: ',rfreq[iloop]
      lsg->go([restFreq=rfreq[iloop],IFsel=doif,files=files,
               selection=ind(files),p_FITSfilename=write_file])
      await lsg->finished
      doif[ifno] := F
  }
}       
        
  
# Finished with gridzilla.
print 'Closing down gridzilla...'
lsg->terminate()
await lsg->done

exit

