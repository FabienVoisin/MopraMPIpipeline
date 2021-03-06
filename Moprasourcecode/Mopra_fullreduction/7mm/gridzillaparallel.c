#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <mpi.h>
int main(int argc, char **argv){

  /*Loop command*/

  int i,j,k ;

  /*------------System command variables*--------------*/
  
  char folderinputname[512];
  char foldertotalinputname[512];
  char folderoutputname[512];
  char command[512];

  float velmin, velmax, velocityrange_per_task;
  float current_lower_velocity, current_upper_velocity; //The current lower upper bound in the while loop (see below)

  char procedure_filename[512];
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

  if (proc_id==0){
    if (OnlyCO==0) sprintf(command,"cp %smasterfullgzilla7mm.g %sgzilla.g",getenv("MOPRAGLISHSCRIPT"),folderoutputname);
    else if (OnlyCO==1) sprintf(command,"cp %smasterquickgzilla7mm.g %sgzilla.g",getenv("MOPRAGLISHSCRIPT"),folderoutputname);
    system(command);    
   
    sprintf(command, "sed 's/tempinputdir/%s/' gzilla.g>tmpgzilla.g ; mv tmpgzilla.g gzilla.g",folderinputname);
    system(command);
    current_lower_velocity=velmin;
    current_upper_velocity=velmin+velocityrange_per_task;
    task_number=0;
    while  (current_lower_velocity<velmax){
      
       sprintf(command, "sed 's/lowervelocity/%f/' gzilla.g > tmpgzilla.g", current_lower_velocity);
      system(command);
      sprintf(command, "sed 's/uppervelocity/%f/' tmpgzilla.g > dummygzilla.g; mv dummygzilla.g tmpgzilla.g", current_upper_velocity);
      system(command);
           for(j=0; j<task_per_file; j++){
 
	     sprintf(command, "sed 's/1:16/%d:%d/' tmpgzilla.g > gzillatemplate_%d.g", 1+16/task_per_file*j,16/task_per_file*(j+1),task_number);
	
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

    sprintf(procedure_filename, "gzillatemplate_%d.g", procedure_id);

    /*Now run the Glish command */

    sprintf(command, "glish -l %s",procedure_filename);
    system(command);

    procedure_id +=num_proc;

  }

	

      
      


	  

  
  ierr=MPI_Finalize();  


  return 0;
}
