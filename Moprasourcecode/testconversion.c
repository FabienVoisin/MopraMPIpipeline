#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "wcs.h"



int main(int argc, char **argv){

  double RApos, DECpos;
  double *gallon, *gallat;
  RApos=atof(argv[1]);
  DECpos=atof(argv[2]);

  gallon=&RApos;
  gallat=&DECpos;
  fk52gal(gallon,gallat);

  printf("l= %.3f b= %.3f \n",*gallon,*gallat);




  return 0;
}


