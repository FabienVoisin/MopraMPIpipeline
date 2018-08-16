void fits_get_galacticcoordinates(char fileinput[512], float *galloncenter, float *gallatcenter);
void read_type_header(struct fitsandheader *fitsinfile);
void fits_averaged_spectrum(char filename[512]);
void printerror(int status);
