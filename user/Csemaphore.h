
struct counting_semaphore {
    int value;
    int s1;
    int s2;
};


int csem_alloc(struct counting_semaphore*, int);
void csem_free(struct counting_semaphore*);
void csem_down(struct counting_semaphore*);
void csem_up(struct counting_semaphore*);