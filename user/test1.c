#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

struct sigaction {
    void (*sa_handler) (int);
    uint sigmask;
};

void test(){
    int pid = fork();
    if (pid == 0){
        for(int i=0; i<1000 ; i++){
           // printf("printing\n");
            printf(".");
        }
        for(int i=0; i<1000 ; i++){
           // printf("printing again\n");
            printf("_");
        }
        printf("child finish\n");
        exit(0);
    }
    else{
        sleep(1);
        kill(pid, 17); //SIGSTOP
        printf("sent stop\n");
        sleep(100);
        kill(pid, 19); //SIGCONT
        printf("sent continue\n");
        printf("parent finish\n");
        exit(0);
    }
    
}

void test4(){
    int pid = fork();
    if (pid == 0){
        struct sigaction s1; 
        s1.sa_handler= (void *)19;
        s1.sigmask= (1<<5);
        int ret = sigaction(4, &s1, 0);
        printf("ret = %d \n", ret);
        for(int i=0; i<1000 ; i++){
           // printf("printing\n");
            printf(".");
        }
        for(int i=0; i<1000 ; i++){
           // printf("printing again\n");
            printf("_");
        }
        printf("child finish\n");
        exit(0);
    }
    else{
        sleep(3);
        kill(pid, 17); //SIGSTOP
        printf("sent stop\n");
        sleep(100);
        kill(pid, 4); //SIGCONT
        printf("sent continue\n");
        printf("parent finish\n");
        exit(0);
    }
    
}

void test2(){
    printf("---------START TEST 2---------\n");
    int pid = fork();
    if (pid == 0){
        for(int i=0; i<1000 ; i++){
           // printf("printing\n");
            printf(".");
        }
        for(int i=0; i<1000 ; i++){
           // printf("printing again\n");
            printf("_");
        }
        printf("child finish\n");
        exit(0);
    }
    else{
        sleep(3);
        kill(pid, 9); //SIGSTOP
        printf("sent kill\n");
        sleep(100);
        printf("parent finish\n");
        exit(0);
    }
    
}

void sig(){
    printf("good!\n");
}

void sig2(){
    printf("good!\n");
}

void test3(){
    int pid = fork();
    if (pid == 0){
        struct sigaction s1; 
        s1.sa_handler= &sig2;
        s1.sigmask= (1<<5);
        int ret = sigaction(4, &s1, 0);
        printf("ret = %d \n", ret);
        for(int i=0; i<1000 ; i++){
           // printf("printing\n");
            printf(".");
        }
        for(int i=0; i<1000 ; i++){
           // printf("printing again\n");
            printf("_");
        }
        printf("child finish\n");
        exit(0);
    }
    else{
        sleep(3);
        kill(pid, 4); 
        printf("sent signal\n");
        sleep(20);
        printf("parent finish\n");
        exit(0);
    }
    
}

void test5(){
    int pid = fork();
    if (pid == 0){
        struct sigaction s1; 
        s1.sa_handler= &sig2;
        s1.sigmask= (1<<5);
         struct sigaction s2; 
        s2.sa_handler= &sig2;
        s2.sigmask= (1<<5);
        struct sigaction s3; 
        s3.sa_handler= &sig2;
        s3.sigmask= (1<<5);
        int ret = sigaction(4, &s1, 0);
        int ret2 = sigaction(5, &s2, 0);
        int ret3 = sigaction(7, &s3, 0);
        printf("ret = %d ret2 = %d ret3= %d\n", ret, ret2, ret3);
        for(int i=0; i<1000 ; i++){
           // printf("printing\n");
            printf(".");
        }
        for(int i=0; i<3000 ; i++){
           // printf("printing again\n");
            printf("_");
        }
        printf("child finish\n");
    
        exit(0);
    }
    else{
        sleep(3);
        kill(pid, 4); 
        kill(pid, 5);
        kill(pid, 7);
        printf("sent signal\n");
        sleep(6);
         
        printf("parent finish\n");
        exit(0);
    }
    
}

int
main(int argc, char **argv)
{
    printf("test %d\n", &test);
    printf("test2 %d\n", &test2);
    printf("test3 %d\n", &test3);
    printf("test4 %d\n", &test4);
    printf("sig %d\n", &sig);
    printf("sig2 %d\n", &sig2);
    //test();
    //test2();
    //test3();
    test4();
    //test5();
    //test();
    exit(0);
}

