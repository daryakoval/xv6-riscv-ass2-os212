#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table at boot time.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->kstack = KSTACK((int) (p - proc));
      //task 1.2
      //lock ?
      for(int i=0;i<32;i++){
        p->signal_handlers[i]=(void*)SIG_DFL;
        p->signal_handlers_mask[i]=0;
      }
      p->frozen=0;
      p->signal_handling_flag=0;
      //task 1.2
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid() {
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }
  if((p->user_trap_frame_backup = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;
  //task 1.2
  for(int i=0; i<32;i++){
    p->signal_handlers[i]=(void*)SIG_DFL;
    p->signal_handlers_mask[i]=0;
  }

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  if(p->user_trap_frame_backup)
    kfree((void*)p->user_trap_frame_backup);
  p->trapframe = 0;
  p->user_trap_frame_backup=0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
}

// Create a user page table for a given process,
// with no user memory, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
  p->frozen=0;
  p->signal_mask=0;
  

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
  

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);
  
  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  //task 1.2
  np->signal_mask=p->signal_mask; 

  for(int i=0;i<32;i++){
    np->signal_handlers[i]=(void*) p->signal_handlers[i]; 
    np->signal_handlers_mask[i]=p->signal_handlers_mask[i];
  }
  //task 1.2
  //2.3
  //init frozem to 0
  np->frozen=0;
  np->signal_handling_flag=0;

  //2.3


  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
          // Found one.
          pid = np->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;
        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  
  c->proc = 0;
  for(;;){
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();

    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if(p->state == RUNNABLE) {
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
      }
      release(&p->lock);
    }
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      //printf("this acc 17?\n");
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
//task 2.1
int
kill(int pid, int signum)
{
  if(signum<0 || signum>31)
    return -1;
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){// maybe check if ignore?
    //task 2.3
      p->pendding_signals |= ((uint)1 << signum);// or bitwise to turn on new signal in pedding signals

      //task 2.3
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}

//task 1.3
uint
sigprocmask(uint sigmask){
  struct proc *p=myproc();

  acquire(&p->lock);
  uint prev=p->signal_mask;
  p->signal_mask=sigmask;

  release(&p->lock);
  return prev;

}

//task 1.3



//task 1.5
  void
  sigret(void){

  struct proc* p = myproc();

  acquire(&p->lock);
  //memmove(p->trapframe, p->user_trap_frame_backup, sizeof(struct trapframe)); // trapframe restore

  *(p->trapframe)=*(p->user_trap_frame_backup);

  //p->trapframe->sp += sizeof(p->trapframe);// add size
  p->signal_mask = p->signal_mask_backup; //restoring sigmask in case of change
  p->signal_handling_flag=0;

  release(&p->lock);
  }
//task 1.5

//task 2.3
void
sigKillHandler(){
  struct proc *p=myproc();

  p->killed = 1;
  if(p->state == SLEEPING){
  //Wake process from sleep().
    p->state = RUNNABLE;
  return;
  }
}
void
sigStopHandler(){
  struct proc *p=myproc();

  acquire(&p->lock);
  p->frozen=1;
  release(&p->lock);
  return;
}
void
sigContHandler(){
  struct proc *p=myproc();

  acquire(&p->lock);
  p->frozen=0;
  release(&p->lock);
  return;
}



//task 1.4
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  struct proc *p=myproc();

  acquire(&p->lock);
  struct sigaction Kact;

  if( signum<0 || signum >31|| signum==SIGKILL || signum==SIGSTOP){
    release(&p->lock);
    return -1;
  }


  if(oldact){
    Kact.sa_handler= p->signal_handlers[signum];
    Kact.sigmask=p->signal_handlers_mask[signum];
    copyout(p->pagetable,(uint64)oldact,(char*)&Kact,sizeof(struct sigaction));
  }
  if(act){

    copyin(p->pagetable,(char*)&Kact,(uint64)act,sizeof(struct sigaction));
    if(Kact.sigmask<0) {// sigmask invalid
      release(&p->lock);
      return -1;
    }
    p->signal_handlers[signum]=Kact.sa_handler;
    p->signal_handlers_mask[signum]=Kact.sigmask;

  }
  release(&p->lock);
  return 0;

}
//task 1.4



void
userhandler(int i){ // process and curent i to check
  
  struct proc *p=myproc();

  acquire(&p->lock);


  //step 2 -backup proc sigmask
  p->signal_mask_backup=p->signal_mask;
  p->signal_mask=p->signal_handlers_mask[i];
  
  //step 3 - turn on flag
  p->signal_handling_flag=1;

  //step 4- reduce sp and buackup
  p->trapframe->sp -=sizeof(struct trapframe);

   
   // step 5 

  copyout(p->pagetable,(uint64)p->user_trap_frame_backup->sp,(char*)p->trapframe,sizeof(struct trapframe));
  //step 6
  p->trapframe->epc=(uint64)p->signal_handlers[i];
  
  // step 7
  int sigret_size= endFunc-startCalcSize; // cacl func size
  
  
  p->trapframe->sp-=sigret_size;
  
  //step 8
  copyout(p->pagetable,(uint64)p->trapframe->sp,(char*)startCalcSize,sigret_size);

  //step 9
  p->trapframe->a0=i; // put signum in a0
  p->trapframe->ra=p->trapframe->sp;

  p->pendding_signals &= ~((uint)1<<i); // turn off the signal
  release(&p->lock);

}

int
handle_pendding_sinals(){
 struct proc *p=myproc();
  acquire(&p->lock);
  *(p->user_trap_frame_backup)=*(p->trapframe);

  while (p->frozen==1){// while the process is still frozen
     if(p->frozen==1 && ((p->pendding_signals & (uint)1<<SIGCONT)==0)){// check if proc is frozen and cont bit is off
      release(&p->lock);
      yield();
      
      acquire(&p->lock);
     }
    else if(p->frozen==1 && ((p->pendding_signals & (uint)1<<SIGCONT)!=0)){ // if frozen and cont bit is on handle it
      release(&p->lock);
      sigContHandler();
      acquire(&p->lock);
      p->pendding_signals &= ~((uint)1<<SIGCONT);// discard sigcont

    }
  }  
  for(int i=0;i<32;i++){
    uint signal_bit_to_check= 1<<i;
    void *currentHandler=p->signal_handlers[i];
    if((p->pendding_signals & signal_bit_to_check)!=0 && p->signal_handling_flag==0){
      

      if(i== SIGKILL){
        
         sigKillHandler();
         
         p->pendding_signals &= ~(signal_bit_to_check);
         release(&p->lock);
         return -1;
      }
       
      else if(i== SIGSTOP){
        release(&p->lock);
        sigStopHandler();
        acquire(&p->lock);
        p->pendding_signals &= ~(signal_bit_to_check);
        release(&p->lock);
        return -1;
      }
        
      //check if signal is blocked in the process 
      else if((p->signal_mask & signal_bit_to_check) ==0 ){
        //signal is not blocked 

        //check if signal handler is IGN if true discard the signal
        if(currentHandler==(void*) SIG_IGN){
          p->pendding_signals &= ~(signal_bit_to_check);
          release(&p->lock);
          return -1;
        }
          
        else if(currentHandler== (void*)  SIGSTOP){
          release(&p->lock);
          sigStopHandler();
          acquire(&p->lock);
          p->pendding_signals &= ~(signal_bit_to_check);
          release(&p->lock);
          return -1;
        }
          
        else if(currentHandler==(void*) SIGCONT){
          release(&p->lock);
          sigContHandler();
          acquire(&p->lock);
          p->pendding_signals &= ~(signal_bit_to_check);
          release(&p->lock);
          return -1;
        }
        else if( currentHandler==(void*) SIGKILL || currentHandler==(void*) SIG_DFL){
          sigKillHandler();
         p->pendding_signals &= ~(signal_bit_to_check);
         release(&p->lock);
          return -1;
        }
          
        else{// its a user space handler 
          release(&p->lock);
          return i; // return the signal number so in trap.c we call userhandle function 
        }
      }




    }
  }

  release(&p->lock);
  return -1;
  
}