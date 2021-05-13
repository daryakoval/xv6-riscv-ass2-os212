#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
//task 2.2
int
main(int argc, char **argv)
{
  int i;

  if(argc <= 2){
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    if( i%2==0 )
      
      kill(atoi(argv[i-1]),atoi(argv[i]));
    
  exit(0);
}
//todo: check for numbers of args
//       support multiple sinal sending 
