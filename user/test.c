#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h"

//MY TEST
int
main(int argc, char **argv)
{
    fprintf(2, "main function\n");
    //int pid = fork();
    /*if(pid != 0){
        int status;
        wait(&status);
        fprintf(2, "Child %d finished with status %d\n", pid, status);
    }else{
        sleep(1);
        fprintf(2, "Child running\n");
        exit(3);
    }*/
    int id = kthread_id();
    fprintf(2, "id of thread %d\n", id);
   /* int pid = fork();
    if(pid != 0){
        sleep(3);
        int status1;
        kthread_join(4, &status1);
        fprintf(2, "Child %d finished with status %d\n", id, status1);
    }else{
        id = kthread_id();
        fprintf(2, "child thread id %d\n", id);
        kthread_exit(6);
    }*/
    kthread_exit(6);
    fprintf(2, "should not get here\n");

    /*//new test: 
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
    }*/

    //exit(0);
    return 0;
}
