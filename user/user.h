struct stat;
struct rtcdate;
//task 1.4
struct sigaction;
//task 1.4
struct counting_semaphore;

// system calls
int fork(void);
int exit(int) __attribute__((noreturn));
int wait(int*);
int pipe(int*);
int write(int, const void*, int);
int read(int, void*, int);
int close(int);
int kill(int, int);
int exec(char*, char**);
int open(const char*, int);
int mknod(const char*, short, short);
int unlink(const char*);
int fstat(int fd, struct stat*);
int link(const char*, const char*);
int mkdir(const char*);
int chdir(const char*);
int dup(int);
int getpid(void);
char* sbrk(int);
int sleep(int);
int uptime(void);
//task 1.3
uint sigprocmask(uint sigmask);
//task 1.3
//task 1.4
int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact);
//task 1.4

//task 1.5
void sigret(void);
//task 1.5
int kthread_create(void(*start_func)(), void *stack); //task3
int kthread_id(); //task3
void kthread_exit(int);//task3
int kthread_join(int, int*);  //task3
int bsem_alloc();
void bsem_free(int);
void bsem_down(int);
void bsem_up(int);

// ulib.c
int stat(const char*, struct stat*);
char* strcpy(char*, const char*);
void *memmove(void*, const void*, int);
char* strchr(const char*, char c);
int strcmp(const char*, const char*);
void fprintf(int, const char*, ...);
void printf(const char*, ...);
char* gets(char*, int max);
uint strlen(const char*);
void* memset(void*, int, uint);
void* malloc(uint);
void free(void*);
int atoi(const char*);
int memcmp(const void *, const void *, uint);
void *memcpy(void *, const void *, uint);
