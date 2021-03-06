#include <stdio.h>
#include <stdlib.h>
#include <fitsio.h>
#include <structure.h>
#include <misc.h>





void fits_averaged_spectrum(char filename[512]){
  /*First I need to declare the variable to extract the data into an multidimensional array */
struct fitsandheader *fitsinfile;
  fitsfile *fptr;
  int hdunum,hdutype;
  int status=0; //Very important to initialize the status code.
  long naxes[3]; //Three dimensional image array size
  int anynul;
  long firstpixel[3],lastpixel[3]; //read the value of the first and last pixel in three  axes
  long inc[3]={1,1,1};

  float nulval=-1.0E-100;
  unsigned long i,j,l; // loop variable
  long k;
  float *spectraarray;
  float *slicearray;
 
  int numberofblank;

  /*--------input-output variable-----------*/
  char outfilename[512];
  FILE *outfile;


/*---- define the fits file -------*/
fitsinfile=malloc(sizeof(struct fitsandheader));


if (fits_open_file(&(fitsinfile->fptr),filename,READONLY,&status))
    printerror(status);

read_type_header(fitsinfile);

  if (fits_movabs_hdu(fitsinfile->fptr,1,&hdutype,&status)) 
    printerror(status);

  /*Now check that your array is a image before continuing*/

  if (hdutype!=IMAGE_HDU){
    printf("The current HDU is not an image, the program cannot continue\n");
    exit(1);
  }
  else{
    /*First we need to obtain the value of the axis */
    if (fits_get_img_size(fitsinfile->fptr,3,&naxes[0],&status))
      printerror(status);
    spectraarray=(float*)malloc(naxes[2]*sizeof(float));
    slicearray=(float*)malloc(naxes[0]*naxes[1]*sizeof(float));
   
    for (i=naxes[1]*naxes[0]-1;i--;){
      slicearray[i]=0.0;  
    }
    for (i=naxes[2]-1;i--;){
      spectraarray[i]=0.0;
    }
      

    /*I need to initialize both arrays*/

 
      status=0;
    /*Now we divide this into several blocks*/
      for (k=0;k<naxes[2];k++){
	/*We grab the slice of the fitscube and then we average sum this value at a given space */
	
	firstpixel[0]=1;
	firstpixel[1]=1;
	firstpixel[2]=k+1;
	lastpixel[0]=naxes[0];
	lastpixel[1]=naxes[1];
	lastpixel[2]=k+1;
	
	  
	if(fits_read_subset(fitsinfile->fptr, TFLOAT,firstpixel,lastpixel,inc, &nulval,slicearray,&anynul,&status))
	    printerror(status);
       
	/*Now we expect the value of the slice to be stored inside an array*/
	numberofblank=0;
	for(l=naxes[1]*naxes[0]-1;l--;){
	
	  if(slicearray[l]!=slicearray[l]) numberofblank++;
	  else  spectraarray[k] +=slicearray[l];
	}
	//printf("spectraarray=%d\n",spectraarray);
	/*Now we obtain the average*/
	spectraarray[k] =spectraarray[k]/(naxes[0]*naxes[1]-numberofblank); 
      }
  }
	   
  

  /*From there we dump the value into a textfile*/
  sprintf(outfilename,"%s_spectra.txt",filename);
  if((outfile=fopen(outfilename,"w+"))==NULL){
    printf("Unable to open file \n");
    exit(1);
  }
  
  for(l=0;l<naxes[2];l++){
float xvalue=fitsinfile->CRVAL3+((float)l-fitsinfile->CRPIX3)*fitsinfile->CDELT3;
    fprintf(outfile,"%.4f %.7f\n",xvalue,spectraarray[l]);
  }
  fclose(outfile);

 if ( fits_close_file(fitsinfile->fptr, &status) )                /* close the file */
         printerror( status );   
  
  
}
  

void read_type_header(struct fitsandheader *fitsinfile){
/* This small function aims to read the various header CTYPE1, CDELT1 CRPIX1, CRVAL1, CTYPE2, CRPIX2, CDELT2 CRVAL2, CTYPE3, CRPIX3, CDELT3, CRVAL3*/
int status=0;
char comment[512];
char CRVAL1[64], CRVAL2[64],CRVAL3[64], CRPIX1[64],CRPIX2[64],CRPIX3[64], CDELT1[64],CDELT2[64],CDELT3[64];
if (fits_read_keyword(fitsinfile->fptr,"CTYPE1",fitsinfile->CTYPE1,comment,&status)) 
  printerror(status);

if (fits_read_keyword(fitsinfile->fptr,"CTYPE2",fitsinfile->CTYPE2,comment,&status))
  printerror(status);

if (fits_read_keyword(fitsinfile->fptr,"CTYPE3",fitsinfile->CTYPE3,comment,&status))
  printerror(status);



if (fits_read_keyword(fitsinfile->fptr,"CRVAL1",CRVAL1,comment,&status))
  printerror(status);

fitsinfile->CRVAL1=atof(CRVAL1);

if (fits_read_keyword(fitsinfile->fptr,"CRVAL2", CRVAL2,comment,&status))
  printerror(status);

fitsinfile->CRVAL2=atof(CRVAL2);

if (fits_read_keyword(fitsinfile->fptr,"CRVAL3", CRVAL3,comment,&status))
  printerror(status);

fitsinfile->CRVAL3=atof(CRVAL3);

if (fits_read_keyword(fitsinfile->fptr,"CRPIX1", CRPIX1,comment,&status))
  printerror(status);


fitsinfile->CRPIX1=atoi(CRPIX1);

if (fits_read_keyword(fitsinfile->fptr,"CRPIX2", CRPIX2,comment,&status))
  printerror(status);


fitsinfile->CRPIX2=atoi(CRPIX2);


if (fits_read_keyword(fitsinfile->fptr,"CRPIX3", CRPIX3,comment,&status))
  printerror(status);

fitsinfile->CRPIX3=atoi(CRPIX3);


if (fits_read_keyword(fitsinfile->fptr,"CDELT1", CDELT1,comment,&status))
  printerror(status);

fitsinfile->CDELT1=atof(CDELT1);


if (fits_read_keyword(fitsinfile->fptr,"CDELT2", CDELT2,comment,&status))
  printerror(status);

fitsinfile->CDELT2=atof(CDELT2);


if (fits_read_keyword(fitsinfile->fptr,"CDELT3", CDELT3,comment,&status))
  printerror(status);

fitsinfile->CDELT3=atof(CDELT3);


}
