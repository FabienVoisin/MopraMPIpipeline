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
  FILE *tempinfile;
  char folderinputname[512];
  char foldertotalinputname[512];
  char folderoutputname[512];
  char projectname[512];
  char command[512];

  float velmin, velmax, velocityrange_per_task;
  float current_lower_velocity, current_upper_velocity; //The current lower upper bound in the while loop (see below)

  char procedure_filename[512];
  char currentfile[512];
  float galloncenter, gallatcenter; //To obtain the coordinates from the sdfits file
  float shiftgalloncenter;
  float gallatcenterbis;
  int OnlyCO;
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
  task_per_file=atoi(argv[6]);
  OnlyCO=atoi(argv[7]);
  sprintf(projectname,"%s",argv[8]); 
 galloncenter=atof(argv[9]);
  gallatcenter=atof(argv[10]);
  if (proc_id==0){

    sprintf(command,"cp %smasterfullgzillaCO.g %sgzillafull.g",getenv("MOPRAGLISHSCRIPT"),folderoutputname);
    system(command);    
   
     sprintf(command, "sed 's/tempinputdir/%s/' gzillafull.g>tmpgzillafull.g ; mv tmpgzillafull.g gzillafull.g",folderinputname);
    system(command);
       sprintf(command, "sed 's/tempprojectID/%s/' gzillafull.g>tmpgzillafull.g ; mv tmpgzillafull.g gzillafull.g",projectname); 
    system(command);
    /*
    sprintf(command, "ls %s*.sdfits | head -n 1 >filetemp.txt",foldertotalinputname);
    system(command);
    if((tempinfile=fopen("filetemp.txt","r"))==NULL) {
      printf("Unable to read temp file \n");
      exit(1);
    }
    fscanf(tempinfile,"%s",currentfile);
    fits_get_galacticcoordinates(currentfile,&galloncenter,&gallatcenter);
    shiftgalloncenter=(int)galloncenter+0.5;
    gallatcenterbis=(int)gallatcenter;*/
      printf("gallon=%.1f gallat=%.1f\n",galloncenter,gallatcenter);
      sprintf(command,"sed 's/longitudetemp/%.1f/' gzillafull.g>tmpgzillafull.g ; mv tmpgzillafull.g gzillafull.g", galloncenter);
      system(command);

      sprintf(command,"sed 's/latitudetemp/%.1f/' gzillafull.g>tmpgzillafull.g ; mv tmpgzillafull.g gzillafull.g", gallatcenter);
      system(command);

  
    current_lower_velocity=velmin;
    current_upper_velocity=velmin+velocityrange_per_task;
    task_number=0;
    while  (current_lower_velocity<velmax){
      
      sprintf(command, "sed 's/lowervelocity/%f/' gzillafull.g > tmpgzillafull.g", current_lower_velocity);
      system(command);
      sprintf(command, "sed 's/uppervelocity/%f/' tmpgzillafull.g > dummygzillafull.g", current_upper_velocity);
      system(command);
      if(OnlyCO==0){
           for(j=0; j<task_per_file; j++){
 
	     sprintf(command, "sed 's/1:8/%d:%d/' dummygzillafull.g > gzillatemplatefull_%d.g", 1+8/task_per_file*j,8/task_per_file*(j+1),task_number);
	
	     system(command);
	     task_number++;
	   }
      }

      else  if (OnlyCO==1) {
	sprintf(command, "sed 's/iloop in 1:8/iloop in 6:8/' dummygzillafull.g>gzillatemplatefull_%d.g",task_number); 
	system(command);
	task_number++;
      }

      /*Increment the velocity range */
      current_lower_velocity +=velocityrange_per_task;
     
      if (current_upper_velocity + velocityrange_per_task <= velmax) current_upper_velocity +=velocityrange_per_task;
      else if(current_upper_velocity + velocityrange_per_task > velmax) current_upper_velocity =velmax;
      
    }
    max_task=task_number;   
  }

  ierr=MPI_Bcast(&max_task,1,MPI_INT,0,MPI_COMM_WORLD);

  /* Now that all the procedures has been set properly, it is time to set glish*/

  procedure_id=proc_id; //proc_id will have a different value for each processors
  
  while (procedure_id<max_task){

    sprintf(procedure_filename, "gzillatemplatefull_%d.g", procedure_id);

    /*Now run the Glish command */

    sprintf(command, "glish -l %s",procedure_filename);
    system(command);

    procedure_id +=num_proc;

  }

	

      
      


	  

  
  ierr=MPI_Finalize();  


  return 0;
}
