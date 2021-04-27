#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h"

//MY TEST
int
main(int argc, char **argv)
{
    fprintf(2, "main function\n");
    int pid = fork();
    sbrk(5);
    if(pid != 0){
        int status;
        wait(&status);
        fprintf(2, "Child %d finished with status %d\n", pid, status);
        sbrk(7);
    }else{
        sleep(1);
        fprintf(2, "Child running\n");
        sbrk(1);
        sbrk(7);
        exit(5);
    }

    //new test: 
    fprintf(2, "New test starting..\n");

    int cpid[3];
    int i;
    for(i=0; i<3; i++){
        cpid[i] = fork();
    }
    for(i=0; i<3; i++){
        if(cpid[i] != 0){
            int status;
            wait(&status);
            fprintf(2, "Child %d finished with status %d\n", cpid[i], status);
        }
    }
    fprintf(2, "Done\n");
    for(i=0; i<3; i++){
        if(cpid[i] == 0){
            exit(i);
        }
    }

    exit(0);
}
