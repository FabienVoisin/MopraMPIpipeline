#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <mpi.h>
#include <string.h>
int main(int argc, char **argv){
  
  /*Loop commmand*/
  int  i,j,k;



  /*-----------------System command variable-------------------*/
  char folderinputname[512];
  char foldertotalinputname[512];
  char folderoutputname[512];
  char command[512];
  
  int filenumber;
  FILE *tmpfile;
  int number_of_files;
  char **list_of_files; // an array of string (of 512 characters)
  char procedure_filename[512];

  /*----------------------MPI Variable-------------------------*/


  int ierr;
  int proc_id,num_proc;
  MPI_Comm comm;
  int proc_per_id; // number of proc per ID
  int procedure_number;
  int procedure_id; //The ID of a procedure 
  int task_per_file;//number of tasks per livedata
  ierr=MPI_Init(&argc,&argv); //Initialise the MPI
  ierr=MPI_Comm_rank(MPI_COMM_WORLD,&proc_id); //Determinig the ID of a given proc
  ierr=MPI_Comm_size(MPI_COMM_WORLD,&num_proc); // Query the number of processor used

  /*----------------------------Define the string variable----------------*/
  task_per_file=atoi(argv[3]);
  sprintf(folderoutputname,"%s/%s/",getenv("RAWDATA"),argv[2]);
  printf("%s\n",folderoutputname);
  sprintf(folderinputname,"%s",argv[1]);
  printf("%s\n",folderinputname);
  sprintf(foldertotalinputname,"%s/%s/",getenv("RAWDATA"),folderinputname);
  chdir(folderoutputname);


  if(proc_id==0){
    /*Only the processor 0 will grab the information and then send it to the other processors*/
    sprintf(command,"cp %smasterfullldataCMZ.g %sldata.g",getenv("MOPRAGLISHSCRIPT"),folderoutputname);
    system(command);
    sprintf(command,"ls  %s*.sdfits | wc -l >tmp.txt",foldertotalinputname); /*  count the number of .rpf files*/
    system(command);
  
    sprintf(command,"(cd %s; ls *.sdfits) >>tmp.txt",foldertotalinputname); /*add the list of files into this tmp dump */
    system(command);
      

      if ((tmpfile=fopen("tmp.txt","r"))==NULL){
	printf("Unable to open file tmp.txt\n");
	exit(1);
      }
  
      fscanf(tmpfile,"%d",&number_of_files); //fetch the first row (int)
   
      sprintf(command, "sed 's/tempoutputdir/%s/' ldata.g>tmpldata.g ; mv tmpldata.g ldata.g",folderinputname); //Change the output directory in the ldata
      
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
    }
  }
  
  for(i=0;i<number_of_files;i++){
    ierr=MPI_Bcast(list_of_files[i],512,MPI_CHAR,0,MPI_COMM_WORLD); //send the string to the rest
  }
  
  
  if(proc_id==0){
  for (i=0; i<number_of_files;i++){
    for (j=0;j<task_per_file;j++){
      procedure_number=task_per_file*i+j;
      sprintf(procedure_filename, "templateldata_%d.g", procedure_number);
      sprintf(command, "sed 's/temp.rpf/%s/' ldata.g > %s", list_of_files[i], procedure_filename);
      system(command);
      /* Now I have to implement a sed to change the ifno for loop for each procedure number according to the task per file*/
      sprintf(command, "sed 's/ifno in 1:8/ifno in %d:%d/g' %s>tmpldata.g; mv tmpldata.g %s ",1+8/task_per_file*j,8/task_per_file*(j+1), procedure_filename, procedure_filename);

      system(command);
    }
  }
  }

  procedure_id=proc_id;//proc_id will have a different value for each processors
  /*  Now we have to execute glish */
  /*The procedure_ID should only go between 0 and number_of_files*task_per_files-1*/
  //MPI_Barrier(MPI_COMM_WORLD);
  while (procedure_id<number_of_files*task_per_file){
    
    sprintf(procedure_filename, "templateldata_%d.g", procedure_id);
    
    
    /*-----Now run the command glish */
    
    sprintf(command, "glish -l %s", procedure_filename);
    system(command);
    
    
    /*The glish will take some time to run */
    /*Now increment the procedure_filename by num_proc */
    procedure_id +=num_proc;
    //      MPI_Barrier(MPI_COMM_WORLD);

  }

  /*Now all the raw files has been changed to Sdfits file*/

  ierr=MPI_Finalize(); //Closing the MPI 
  return 0;
}
