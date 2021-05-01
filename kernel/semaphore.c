#include "defs.h"
#include "param.h"

struct bsem
{
    //struct spinlock b_lock;
    int state;      //state 0 == UNUSED, state 1 == USED
    int bid;
    int unlocked;        //unlocked 0 == LOCKED, unlocked 1 == UNLOCkED
    int sleeping_threads;
};

struct bsem bsems[MAX_BSEM];
  
struct spinlock bsem_lock; 

void bsem_init(){           //called from proc.c at init
    int i = 0;

    initlock(&bsem_lock, "bsem");

    for(i = 0; i < MAX_BSEM; i++){
        struct bsem *b = &bsems[i];
        //initlock(&b->b_lock, "b_lock");
        b->bid = i;
        b->unlocked = 0;
        b->state = 0;
        b->sleeping_threads = 0;
    }
}


int bsem_alloc(){
    struct bsem *b;
    acquire(&bsem_lock);
    for(b = bsems; b < &bsems[MAX_BSEM]; b++){
        if(!b->state){
            b->state = 1; //used
            b->unlocked = 1; //unlocked
            release(&bsem_lock); 
            return b->bid;
        }
    }
    release(&bsem_lock);
    return -1;
}

void bsem_free(int bid){
    struct bsem *b = &bsems[bid];
    b->unlocked = 0;
    b->sleeping_threads = 0;
    b->state = 0;        //unused
}

void bsem_down(int bid){
    struct bsem *b;
    b = &bsems[bid];
    acquire(&bsem_lock);
    if(!b->unlocked){
        b->sleeping_threads++;
        sleep(b, &bsem_lock);
        b->sleeping_threads--;
    }
    else b->unlocked--;
    release(&bsem_lock);
}

void bsem_up(int bid){
    struct bsem *b;
    b = &bsems[bid];
    acquire(&bsem_lock);
    if(b->sleeping_threads){
        wakeup_one(b);
    }
    else b->unlocked++;
    release(&bsem_lock);
}
