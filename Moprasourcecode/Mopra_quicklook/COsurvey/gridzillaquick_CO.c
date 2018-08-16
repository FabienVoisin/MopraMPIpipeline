#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <mpi.h>
#include <misc.h>
int main(int argc, char **argv){

  /*Loop command*/

  int i,j,k ;

  /*------------System command variables*--------------*/
  int number_of_files;
  int number_of_outputfiles;
  char **list_of_files;
  char **list_of_outputfiles;
  char folderinputname[512];
  char foldertotalinputname[512];
  char folderoutputname[512];
  char command[512];

  float velmin, velmax, velocityrange_per_task;
  float current_lower_velocity, current_upper_velocity; //The current lower upper bound in the while loop (see below)
  FILE *tmpfile;
  char procedure_filename[512];
  char currentfile[512];
  float galloncenter, gallatcenter; //To obtain the coordinates from the sdfits file
  float shiftgalloncenter;
  float gallatcenterbis;
  /*-----------------MPI variable ----------------------*/

  int ierr;
  int proc_id, num_proc;

  int task_number;//for the loop
  int max_task;
  
  int task_per_file;
  int procedure_id;

  ierr=MPI_Init(&argc, &argv); //Initialize the MPI
  ierr=MPI_Comm_rank(MPI_COMM_WORLD,&proc_id); //Determine the ID of a given proc
  ierr=MPI_Comm_size(MPI_COMM_WORLD,&num_proc);

  /*-------------------Code-----------------------*/

  sprintf(folderinputname,"%s",argv[1]);
  sprintf(foldertotalinputname, "%s/%s/",getenv("RAWDATA"),folderinputname);
 
  sprintf(folderoutputname,"%s/%s/",getenv("RAWDATA"),argv[2]);
  chdir(folderoutputname);

  velmin=atof(argv[3]);
  velmax=atof(argv[4]);
  velocityrange_per_task=atof(argv[5]);


 if(proc_id==0){
   sprintf(command,"cp %smasterquickgzillaCO.g %sgzilla.g",getenv("MOPRAGLISHSCRIPT"),folderoutputname);
    system(command);
    /*Only the processor 0 will grab the information and then send it to the other processors*/

    sprintf(command,"ls  %s*IF7.sdfits | wc -l >tmp.txt",foldertotalinputname); /*  count the number of .rpf files*/
    system(command);
  
    sprintf(command,"(cd %s; ls *IF7.sdfits) >>tmp.txt",foldertotalinputname); /*add the list of files into this tmp dump */
    system(command);
      

      if ((tmpfile=fopen("tmp.txt","r"))==NULL){
	printf("Unable to open file tmp.txt\n");
	exit(1);
      }
  
      fscanf(tmpfile,"%d",&number_of_files); //fetch the first row (int)
   
      sprintf(command, "sed 's/tempoutputdir/%s/' gzilla.g>tmpgzilla.g ; mv tmpgzilla.g gzilla.g",folderinputname); //Change the output directory in the ldata
      
      system(command);
  }
      
  ierr=MPI_Bcast(&number_of_files,1, MPI_INT,0,MPI_COMM_WORLD); //Broadcast the number of files to all other processes


  /* Now that we know the number of files inside the system */
  
  list_of_files=(char**)malloc(number_of_files*sizeof(char*));

  for (i=0;i<number_of_files;i++){
    list_of_files[i]=(char*)malloc(512*sizeof(char)); /*Each string has been allocated 512 characters */
  }

  if(proc_id==0){
    for (i=0;i<number_of_files;i++){
      fscanf(tmpfile,"%s",list_of_files[i]);
       printf("%s\n",list_of_files[i]);
    }
  }
  
  for(i=0;i<number_of_files;i++){
    ierr=MPI_Bcast(list_of_files[i],512,MPI_CHAR,0,MPI_COMM_WORLD); //send the string to the rest
  }
  




  if (proc_id==0){
    task_number=0;
    sprintf(command, "sed 's/tempinputdir/%s/' gzilla.g>tmpgzilla.g ; mv tmpgzilla.g gzilla.g",folderinputname);
    system(command);
    task_number=0;
    for(i=0;i<number_of_files;i++){

      sprintf(command,"sed 's/projectname/%s/' gzilla.g>tmpgzilla.g ; mv tmpgzilla.g gzilla.g ",list_of_files[i]);
      system(command);
      sprintf(command,"sed 's/temporaryfilename/%s/' gzilla.g>dummygzilla.g ",list_of_files[i]);
      system(command);

      sprintf(currentfile,"%s/%s",foldertotalinputname,list_of_files[i]);
      /*Now grab the galactic coordinates*/
      fits_get_galacticcoordinates(currentfile,&galloncenter,&gallatcenter);
      shiftgalloncenter=galloncenter+0.5;
      gallatcenterbis=gallatcenter;
      printf("gallon=%.1f gallat=%.1f\n",shiftgalloncenter,gallatcenterbis);
      sprintf(command,"sed 's/longitudetemp/%.1f/' dummygzilla.g>tmpgzilla.g ; mv tmpgzilla.g dummygzilla.g", galloncenter);
      system(command);

      sprintf(command,"sed 's/latitudetemp/%.1f/' dummygzilla.g>tmpgzilla.g ; mv tmpgzilla.g dummygzilla.g", gallatcenter);
      system(command);

      
      
      current_lower_velocity=velmin;
      current_upper_velocity=velmin+velocityrange_per_task;
    
    while  (current_lower_velocity<velmax){
      
      sprintf(command, "sed 's/lowervelocity/%.1f/' dummygzilla.g > tmpgzilla.g", current_lower_velocity);
      system(command);
      sprintf(command, "sed 's/uppervelocity/%.1f/' tmpgzilla.g > gzillatemplate_%d.g ", current_upper_velocity,task_number);
      system(command);
      task_number++;
      /*Increment the velocity range */
      current_lower_velocity +=velocityrange_per_task;
     
      if (current_upper_velocity + velocityrange_per_task <= velmax) current_upper_velocity +=velocityrange_per_task;
      else if(current_upper_velocity + velocityrange_per_task > velmax) current_upper_velocity =velmax;
      
    }
    max_task=task_number;   
    }
  }
  ierr=MPI_Bcast(&max_task,1,MPI_INT,0,MPI_COMM_WORLD);

  /* Now that all the procedures has been set properly, it is time to set glish*/

  procedure_id=proc_id; //proc_id will have a different value for each processors
  
  while (procedure_id<max_task){

    sprintf(procedure_filename, "gzillatemplate_%d.g", procedure_id);

    /*Now run the Glish command */
  
     sprintf(command, "glish -l %s",procedure_filename);
       system(command);

    procedure_id +=num_proc;
    }

 	

  
  ierr=MPI_Finalize();  


  return 0;
}
