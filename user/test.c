#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"
//#include "kernel/proc.h"         // NEW INCLUDE FOR ASS 2, has all the signal definitions and sigaction definition.  Alternatively, copy the relevant things into user.h and include only it, and then no need to include spinlock.h .
struct sigaction {

  void (*sa_handler) (int); 
  uint sigmask; 
};

int
run(void f(char *), char *s) {
  int pid;
  int xstatu;

  printf("test %s: \n", s);
  if((pid = fork()) < 0) {
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    f(s);
    exit(0);
  } else {
    wait(&xstatu);
    if(xstatu != 0) 
      printf("FAILED\n");
    else
      printf("OK\n");
    return xstatu == 0;
  }
}


#define SIGKILL 9
#define BUFSZ  ((MAXOPBLOCKS+2)*BSIZE)

char buf[BUFSZ];


int wait_sig = 0;

int dummy(int i){
  i = i + 1;
  return i++;
}

void test_handler(int signum){
    wait_sig = 1;
    printf("Received sigtest\n");
}



void signal_test(char *s){
    int pid;
    int testsig;
    testsig=15;

    struct sigaction act = {test_handler, (uint)(1 << 29)};
    struct sigaction old;
    //fprintf(2, "blahhh %p\n", act.sa_handler);
    sigprocmask(0);
    sigaction(testsig, &act, &old);

    if((pid = fork()) == 0){
        while(!wait_sig)
            fprintf(2,"waiting\n");
        exit(0);
    }
    kill(pid, testsig);
    printf("before wait\n");
    wait(&pid);
    printf("Finished testing signals\n");
}






 int main(int argc, char** argv){
    
    int i = dummy(0);
    fprintf(2, "dummy first: %d%d\n", i, dummy);
    
    fprintf(2,"%d\n", test_handler);
    struct test {
        void (*f)(char *);
        char *s;
    }
   
    tests[] = {
        //ASS 2 Compilation tests:
            {signal_test,"signal_test"},
            { 0, 0},
    };


    printf("usertests starting\n");

    for (struct test *t = tests; t->s != 0; t++) {
        run(t->f, t->s);
        
    }


    exit(0);
    return 0;

}