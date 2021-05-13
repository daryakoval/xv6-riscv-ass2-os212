#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h"
#include "kernel/param.h"
#include "Csemaphore.h" 

struct sigaction {
    void (*sa_handler) (int);
    uint sigmask;
};


int wait_sig1 = 0;
int wait_sig2 = 0;
int wait_sig3 = 0;

void test_handler_0(int signum){
    wait_sig1 = 1;
    printf("Received sigtest 0\n");
}
void test_handler_1(int signum){
    wait_sig1 = 1;
    printf("Received sigtest 1\n");
}
void test_handler_2(int signum){
    wait_sig2 = 1;
    printf("Received sigtest 2\n");
}
void test_handler_3(int signum){
    wait_sig3 = 1;
    printf("Received sigtest 3\n");
}




void signal_test(){
    int pid;
    int testsig;
    testsig=15;
    printf("addr of test 0 is : %d\n",test_handler_0);
    struct sigaction act1 = {test_handler_1, (uint)(1 << 29)};
    struct sigaction old1;
    sigprocmask(0);
    sigaction(testsig, &act1, &old1);
    struct sigaction act2 = {test_handler_2, (uint)(1 << 28)};
    struct sigaction old2;
    sigprocmask(0);
    sigaction(testsig+1, &act2, &old2);
    struct sigaction act3 = {test_handler_3, (uint)(1 << 27)};
    struct sigaction old3;
    sigprocmask(0);

    sigaction(20, &act3, &old3);
    if((pid = fork()) == 0){
        while(!wait_sig1 && !wait_sig2 && !wait_sig3)
            sleep(1);
        exit(0);
    }
    kill(pid, testsig);
    kill(pid, testsig+1);
    kill(pid,20);
    wait(&pid);
    printf("Finished testing signals\n");
}

void signal_test_fromoldact(){
    int pid;
    int testsig;
    testsig=15;
    struct sigaction act1 = {test_handler_1, (uint)(1 << 29)};
    struct sigaction old1;
    sigprocmask(0);
    sigaction(testsig, &act1, &old1);
    if((pid = fork()) == 0){
    while(!wait_sig1 && !wait_sig2 && !wait_sig3)
        sleep(1);
    exit(0);
    }
    kill(pid, testsig);
    wait(&pid);
    struct sigaction act2 = {test_handler_2, (uint)(1 << 29)};
    struct sigaction old2;
    sigprocmask(0);
    sigaction(testsig, &act2, &old2);
        if((pid = fork()) == 0){
    while(!wait_sig1 && !wait_sig2 && !wait_sig3)
        sleep(1);
    exit(0);
    }
    kill(pid, testsig);
    wait(&pid);
    struct sigaction act3 = {act1.sa_handler, (uint)(1 << 29)};
    struct sigaction old3;
    sigprocmask(0);
    sigaction(testsig, &act3, &old3);
            if((pid = fork()) == 0){
    while(!wait_sig1)
        sleep(1);
    exit(0);
    }
    kill(pid, testsig);
    wait(&pid);
    printf("Finished testing signals\n");
}



void signal_test_sigstop(){
    int pid;
    int testsig;
    testsig=20;
    struct sigaction act1 = {test_handler_1, (uint)(1 << 29)};
    struct sigaction old1;
    sigprocmask(0);
    sigaction(testsig, &act1, &old1);
    if((pid = fork()) == 0){
    while(!wait_sig1)
        sleep(1);
    exit(0);
    }
    kill(pid,SIGSTOP);
    kill(pid,testsig);
    kill(pid,SIGCONT);
    wait(&pid);
      printf("Finished testing signals\n");



}

int
main(int argc, char **argv)
{   
    signal_test();
    printf("_________________");
    signal_test_fromoldact();
        printf("_________________");
    signal_test_sigstop();
    exit(0);
}