struct counting_semaphore;


int csem_alloc(struct counting_semaphore*, int);
void csem_free(struct counting_semaphore*);
void csem_down(struct counting_semaphore*);
void csem_up(struct counting_semaphore*);