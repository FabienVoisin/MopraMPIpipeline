#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fitsio.h>
#include <wcs.h>

void printerror(int status);

void  fits_get_galacticcoordinates(char filename[512], float *galloncenter, float *gallatcenter){
  
fitsfile *fptr;
 int hdunum=2;
 int hdutype;
 int status;
int i;

 long rnows;
 int ncols;

 int colnum; //column number of the fits file
 int typecode;
 long repeat; 
 long width;

 long firstrow;
 long firstelement;
 long nelements; //fetch a given number of element in a fits file
 long nrows;

 float nulval;
 int anynul;
 int testval;

 float radecvalue[2];
 double galacticvalue[2];

 status=0;
 printf("%s\n",filename);
 // char filename[] = "2013-09-02_1344-M648-IF16.sdfits";
//if ( fits_flush_file(fptr, &status) )
//printerror (status);
//printf("fitsname=%s \nfitsname=%s\n",filename,filename2);
if ( fits_open_file(&fptr,filename, READONLY, &status) )
 printerror ( status );
 //testval=fits_open_file(&fptr,&filename[0], READWRITE, &status);


/*Now we move to the second hdu*/
 if ( fits_movabs_hdu(fptr, hdunum, &hdutype, &status) )
   printerror (status);


 /*We should now look at the first row column 6 and 7 */

 
 firstelement=1;
 nulval=1E-20;
//printf("Hello test3\n");
 for (i=7;i<=8;++i){

   if (fits_get_coltype(fptr, i, &typecode, &repeat, &width, &status) )
     printerror (status);

   if(fits_get_num_rows(fptr, &nrows, &status)) 
     printerror (status);

//   printf("typecode=%d repeat=%ld width=%ld \n", typecode, repeat, width);
   firstrow=nrows/2; //get to half the table 
   if ( fits_read_col(fptr, TFLOAT, i,firstrow, firstelement, 1, &nulval, &radecvalue[i-7], &anynul, &status))
     printerror(status);
 }

 /*print the results */


 


 /*close the fits file */
 if ( fits_close_file(fptr, &status) ) 
         printerror( status );
  
 galacticvalue[0]=radecvalue[0];
 galacticvalue[1]=radecvalue[1];
 fk52gal(&galacticvalue[0],&galacticvalue[1]);
 *galloncenter= galacticvalue[0];
 *gallatcenter= galacticvalue[1];
 





}


void printerror( int status)
{
    /*****************************************************/
    /* Print out cfitsio error messages and exit program */
    /*****************************************************/


    if (status)
    {
       fits_report_error(stderr, status); /* print error report */

         exit( status );    /* terminate the program, returning error status */
    }
    return;
}
