#include "Csemaphore.h"
#include "user.h"


int csem_alloc(struct counting_semaphore *sem, int initial_value){
    int s1 = bsem_alloc();
    int s2 = bsem_alloc();
    if(initial_value == 0) bsem_down(s2);
    if( s1 < 0 || s2 < 0) return -1;
    sem->s1 = s1;
    sem->s2 = s2;
    sem->value = initial_value;
    return 0;
}

void csem_free(struct counting_semaphore *sem){
    sem->value = 0;
    bsem_free(sem->s1);
    bsem_free(sem->s2);
}

void csem_down(struct counting_semaphore *sem){
    bsem_down(sem->s2);
    bsem_down(sem->s1);
    sem->value--;
    if(sem->value > 0) bsem_up(sem->s2);
    bsem_up(sem->s1);
}

void csem_up(struct counting_semaphore *sem){
    bsem_down(sem->s1);
    sem->value++;
    if(sem->value == 1) bsem_up(sem->s2);
    bsem_up(sem->s1);
}