#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <misc.h>
int main(int argc, char **argv){
  char filename[512];
  
  sprintf(filename,"%s",argv[1]);
  fits_averaged_spectrum(filename);

  return 0;
}
