#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h"
#include "kernel/param.h"
#include "Csemaphore.h" 


void test_thread(){
    printf("first Thread is now running\n");
    kthread_exit(1);
}

void test_thread2(){
    printf("second Thread is now running\n");
    kthread_exit(2);
}

//MY TEST
int
mytest()
{
    fprintf(2, "main function\n");
    int tid;
    int did;
    int status;
    void* stack = malloc(STACK_SIZE);
    did = kthread_id();
    printf("before create: thread num: %d creating new thread\n", did);
    tid = kthread_create(test_thread, stack);
    printf("after create before join, new tid : %d \n", tid);
    kthread_join(tid,&status);

    free(stack);
    printf("Finished testing threads, main thread id: %d, %d\n", did,status);

    exit(0);
}

void
thread_test()
{
    fprintf(2, "main function\n");
    int tid[2];
    int status1;
    int status2;
    void* stack1 = malloc(STACK_SIZE);
    void* stack2 = malloc(STACK_SIZE);
    tid[0] = kthread_create(test_thread, stack1);
    tid[1] = kthread_create(test_thread2, stack2);
    printf("after create before join, new tid : %d \n", tid[0]);
    printf("after create before join, new tid : %d \n", tid[1]);
    kthread_join(tid[0],&status1);
    kthread_join(tid[1],&status2);

    free(stack1);
    free(stack2);
    printf("Finished testing threads, thread id: %d, status: %d\n", tid[0],status1);
    printf("Finished testing threads, thread id: %d, status: %d\n", tid[1],status2);
    kthread_exit(3);
}

void bsem_test_tamir(){
    int zero_bsem  = bsem_alloc();
    int one_bsem   = bsem_alloc();

    printf("zero %d one %d\n",zero_bsem,one_bsem);
    bsem_down(one_bsem); //Let's print 0 first
    int pid        = fork();
    if(pid){
        for(int i=0;i<10;i++){
        bsem_down(zero_bsem);
        printf("0");
        bsem_up(one_bsem);
      }
      bsem_up(one_bsem);
      exit(0);
    }
    else{
      for(int i=0;i<10;i++){
        bsem_down(one_bsem);
        printf("1");
        bsem_up(zero_bsem);
      }
    }
    printf("\n");
    bsem_free(one_bsem);
    bsem_free(zero_bsem);
    exit(0);
}

void bsem_test(){
    int pid;
    int bid = bsem_alloc();
    bsem_down(bid);
    printf("1. Parent downing semaphore\n");
    if((pid = fork()) == 0){
        printf("2. Child downing semaphore\n");
        bsem_down(bid);
        printf("4. Child woke up\n");
        exit(0);
    }
    sleep(5);
    printf("3. Let the child wait on the semaphore...\n");
    sleep(10);
    bsem_up(bid);

    bsem_free(bid);
    wait(&pid);

    printf("Finished bsem test, make sure that the order of the prints is alright. Meaning (1...2...3...4)\n");
}

void bsem_test_me(){
    int pid1;
    int pid2;
    int bid = bsem_alloc();
    bsem_down(bid);
    printf("-. Parent downing semaphore long parent message 111 111\n");
    bsem_up(bid);
    if((pid1 = fork()) == 0){
        bsem_down(bid);
        printf("-. Child1 downing semaphore long child message 111 111\n");
        bsem_up(bid);
        bsem_down(bid);
        printf("-. Child1 woke up long child message 111 111\n");
        bsem_up(bid);
        exit(0);
    }
    else{
        if((pid2 = fork())==0){
            bsem_down(bid);
            printf("-. Child2 downing semaphore long child message 222 222\n");
            bsem_up(bid);
            bsem_down(bid);
            printf("-. Child2 woke up long child message 222 222\n");
            bsem_up(bid);
            exit(0);
        }
    }
    //sleep(5);
    bsem_down(bid);
    printf("-. Let the child wait on the semaphore...\n");
    //sleep(10);
    bsem_up(bid);


    wait(&pid1);
    wait(&pid2);
    bsem_free(bid);
    

    printf("Finished bsem test, make sure that the order of the prints is alright. \n");
}

void Csem_test(){
	struct counting_semaphore csem;
    int retval;
    int pid;
    
    
    retval = csem_alloc(&csem,1);
    if(retval==-1)
    {
		printf("failed csem alloc");
		exit(-1);
	}

    csem_down(&csem);
    printf("1. Parent downing semaphore\n");
    if((pid = fork()) == 0){
        printf("2. Child downing semaphore\n");
        csem_down(&csem);
        printf("4. Child woke up\n");
        exit(0);
    }
    sleep(5);
    printf("3. Let the child wait on the semaphore...\n");
    sleep(10);
    csem_up(&csem);

    csem_free(&csem);
    wait(&pid);

    printf("Finished bsem test, make sure that the order of the prints is alright. Meaning (1...2...3...4)\n");
}

int
main(int argc, char **argv)
{   
    //bsem_test();
    //bsem_test();
    //bsem_test_me();
    //bsem_test_tamir();
    //Csem_test();
    //mytest();
    thread_test();
    printf("got here : bad");
    exit(0);
}