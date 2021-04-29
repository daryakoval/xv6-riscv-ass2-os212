#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h"
#include "kernel/param.h"


void test_thread(){
    printf("Thread is now running\n");
    kthread_exit(0);
}

//MY TEST
int
main(int argc, char **argv)
{
    fprintf(2, "main function\n");
    int tid;
    int status;
    void* stack = malloc(STACK_SIZE);
    tid = kthread_id();
    printf("before create: tid: %d creating thread\n", tid);
    tid = kthread_create(test_thread, stack);
    printf("after create before join new tid : %d \n", tid);
    kthread_join(tid,&status);
    printf("after join\n");

    tid = kthread_id();
    free(stack);
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);

    exit(0);
}
