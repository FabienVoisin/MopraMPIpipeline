#include <fitsio.h>
struct fitsandheader{
fitsfile *fptr;
char CTYPE1[256];
char CTYPE2[256];
char CTYPE3[256];
float CDELT1;
float CDELT2;
float CDELT3;
long CRPIX1;
long CRPIX2;
long CRPIX3;
float CRVAL1;
float CRVAL2;
float CRVAL3;
};
