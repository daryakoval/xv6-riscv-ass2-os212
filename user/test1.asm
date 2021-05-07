
user/_test1:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sig>:
        exit(0);
    }
    
}

void sig(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("good!\n");
   8:	00001517          	auipc	a0,0x1
   c:	d2850513          	addi	a0,a0,-728 # d30 <malloc+0xe8>
  10:	00001097          	auipc	ra,0x1
  14:	b7a080e7          	jalr	-1158(ra) # b8a <printf>
}
  18:	60a2                	ld	ra,8(sp)
  1a:	6402                	ld	s0,0(sp)
  1c:	0141                	addi	sp,sp,16
  1e:	8082                	ret

0000000000000020 <sig2>:

void sig2(){
  20:	1141                	addi	sp,sp,-16
  22:	e406                	sd	ra,8(sp)
  24:	e022                	sd	s0,0(sp)
  26:	0800                	addi	s0,sp,16
    printf("good!\n");
  28:	00001517          	auipc	a0,0x1
  2c:	d0850513          	addi	a0,a0,-760 # d30 <malloc+0xe8>
  30:	00001097          	auipc	ra,0x1
  34:	b5a080e7          	jalr	-1190(ra) # b8a <printf>
}
  38:	60a2                	ld	ra,8(sp)
  3a:	6402                	ld	s0,0(sp)
  3c:	0141                	addi	sp,sp,16
  3e:	8082                	ret

0000000000000040 <test>:
void test(){
  40:	1101                	addi	sp,sp,-32
  42:	ec06                	sd	ra,24(sp)
  44:	e822                	sd	s0,16(sp)
  46:	e426                	sd	s1,8(sp)
  48:	e04a                	sd	s2,0(sp)
  4a:	1000                	addi	s0,sp,32
    int pid = fork();
  4c:	00000097          	auipc	ra,0x0
  50:	7a6080e7          	jalr	1958(ra) # 7f2 <fork>
    if (pid == 0){
  54:	e921                	bnez	a0,a4 <test+0x64>
  56:	3e800493          	li	s1,1000
            printf(".");
  5a:	00001917          	auipc	s2,0x1
  5e:	cde90913          	addi	s2,s2,-802 # d38 <malloc+0xf0>
  62:	854a                	mv	a0,s2
  64:	00001097          	auipc	ra,0x1
  68:	b26080e7          	jalr	-1242(ra) # b8a <printf>
        for(int i=0; i<1000 ; i++){
  6c:	34fd                	addiw	s1,s1,-1
  6e:	f8f5                	bnez	s1,62 <test+0x22>
  70:	3e800493          	li	s1,1000
            printf("_");
  74:	00001917          	auipc	s2,0x1
  78:	ccc90913          	addi	s2,s2,-820 # d40 <malloc+0xf8>
  7c:	854a                	mv	a0,s2
  7e:	00001097          	auipc	ra,0x1
  82:	b0c080e7          	jalr	-1268(ra) # b8a <printf>
        for(int i=0; i<1000 ; i++){
  86:	34fd                	addiw	s1,s1,-1
  88:	f8f5                	bnez	s1,7c <test+0x3c>
        printf("child finish\n");
  8a:	00001517          	auipc	a0,0x1
  8e:	cbe50513          	addi	a0,a0,-834 # d48 <malloc+0x100>
  92:	00001097          	auipc	ra,0x1
  96:	af8080e7          	jalr	-1288(ra) # b8a <printf>
        exit(0);
  9a:	4501                	li	a0,0
  9c:	00000097          	auipc	ra,0x0
  a0:	75e080e7          	jalr	1886(ra) # 7fa <exit>
  a4:	84aa                	mv	s1,a0
        sleep(1);
  a6:	4505                	li	a0,1
  a8:	00000097          	auipc	ra,0x0
  ac:	7e2080e7          	jalr	2018(ra) # 88a <sleep>
        kill(pid, 17); //SIGSTOP
  b0:	45c5                	li	a1,17
  b2:	8526                	mv	a0,s1
  b4:	00000097          	auipc	ra,0x0
  b8:	776080e7          	jalr	1910(ra) # 82a <kill>
        printf("sent stop\n");
  bc:	00001517          	auipc	a0,0x1
  c0:	c9c50513          	addi	a0,a0,-868 # d58 <malloc+0x110>
  c4:	00001097          	auipc	ra,0x1
  c8:	ac6080e7          	jalr	-1338(ra) # b8a <printf>
        sleep(100);
  cc:	06400513          	li	a0,100
  d0:	00000097          	auipc	ra,0x0
  d4:	7ba080e7          	jalr	1978(ra) # 88a <sleep>
        kill(pid, 19); //SIGCONT
  d8:	45cd                	li	a1,19
  da:	8526                	mv	a0,s1
  dc:	00000097          	auipc	ra,0x0
  e0:	74e080e7          	jalr	1870(ra) # 82a <kill>
        printf("sent continue\n");
  e4:	00001517          	auipc	a0,0x1
  e8:	c8450513          	addi	a0,a0,-892 # d68 <malloc+0x120>
  ec:	00001097          	auipc	ra,0x1
  f0:	a9e080e7          	jalr	-1378(ra) # b8a <printf>
        printf("parent finish\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	c8450513          	addi	a0,a0,-892 # d78 <malloc+0x130>
  fc:	00001097          	auipc	ra,0x1
 100:	a8e080e7          	jalr	-1394(ra) # b8a <printf>
        exit(0);
 104:	4501                	li	a0,0
 106:	00000097          	auipc	ra,0x0
 10a:	6f4080e7          	jalr	1780(ra) # 7fa <exit>

000000000000010e <test2>:
void test2(){
 10e:	1101                	addi	sp,sp,-32
 110:	ec06                	sd	ra,24(sp)
 112:	e822                	sd	s0,16(sp)
 114:	e426                	sd	s1,8(sp)
 116:	e04a                	sd	s2,0(sp)
 118:	1000                	addi	s0,sp,32
    printf("---------START TEST 2---------\n");
 11a:	00001517          	auipc	a0,0x1
 11e:	c6e50513          	addi	a0,a0,-914 # d88 <malloc+0x140>
 122:	00001097          	auipc	ra,0x1
 126:	a68080e7          	jalr	-1432(ra) # b8a <printf>
    int pid = fork();
 12a:	00000097          	auipc	ra,0x0
 12e:	6c8080e7          	jalr	1736(ra) # 7f2 <fork>
    if (pid == 0){
 132:	e921                	bnez	a0,182 <test2+0x74>
 134:	3e800493          	li	s1,1000
            printf(".");
 138:	00001917          	auipc	s2,0x1
 13c:	c0090913          	addi	s2,s2,-1024 # d38 <malloc+0xf0>
 140:	854a                	mv	a0,s2
 142:	00001097          	auipc	ra,0x1
 146:	a48080e7          	jalr	-1464(ra) # b8a <printf>
        for(int i=0; i<1000 ; i++){
 14a:	34fd                	addiw	s1,s1,-1
 14c:	f8f5                	bnez	s1,140 <test2+0x32>
 14e:	3e800493          	li	s1,1000
            printf("_");
 152:	00001917          	auipc	s2,0x1
 156:	bee90913          	addi	s2,s2,-1042 # d40 <malloc+0xf8>
 15a:	854a                	mv	a0,s2
 15c:	00001097          	auipc	ra,0x1
 160:	a2e080e7          	jalr	-1490(ra) # b8a <printf>
        for(int i=0; i<1000 ; i++){
 164:	34fd                	addiw	s1,s1,-1
 166:	f8f5                	bnez	s1,15a <test2+0x4c>
        printf("child finish\n");
 168:	00001517          	auipc	a0,0x1
 16c:	be050513          	addi	a0,a0,-1056 # d48 <malloc+0x100>
 170:	00001097          	auipc	ra,0x1
 174:	a1a080e7          	jalr	-1510(ra) # b8a <printf>
        exit(0);
 178:	4501                	li	a0,0
 17a:	00000097          	auipc	ra,0x0
 17e:	680080e7          	jalr	1664(ra) # 7fa <exit>
 182:	84aa                	mv	s1,a0
        sleep(3);
 184:	450d                	li	a0,3
 186:	00000097          	auipc	ra,0x0
 18a:	704080e7          	jalr	1796(ra) # 88a <sleep>
        kill(pid, 9); //SIGSTOP
 18e:	45a5                	li	a1,9
 190:	8526                	mv	a0,s1
 192:	00000097          	auipc	ra,0x0
 196:	698080e7          	jalr	1688(ra) # 82a <kill>
        printf("sent kill\n");
 19a:	00001517          	auipc	a0,0x1
 19e:	c0e50513          	addi	a0,a0,-1010 # da8 <malloc+0x160>
 1a2:	00001097          	auipc	ra,0x1
 1a6:	9e8080e7          	jalr	-1560(ra) # b8a <printf>
        sleep(100);
 1aa:	06400513          	li	a0,100
 1ae:	00000097          	auipc	ra,0x0
 1b2:	6dc080e7          	jalr	1756(ra) # 88a <sleep>
        printf("parent finish\n");
 1b6:	00001517          	auipc	a0,0x1
 1ba:	bc250513          	addi	a0,a0,-1086 # d78 <malloc+0x130>
 1be:	00001097          	auipc	ra,0x1
 1c2:	9cc080e7          	jalr	-1588(ra) # b8a <printf>
        exit(0);
 1c6:	4501                	li	a0,0
 1c8:	00000097          	auipc	ra,0x0
 1cc:	632080e7          	jalr	1586(ra) # 7fa <exit>

00000000000001d0 <test4>:
void test4(){
 1d0:	7179                	addi	sp,sp,-48
 1d2:	f406                	sd	ra,40(sp)
 1d4:	f022                	sd	s0,32(sp)
 1d6:	ec26                	sd	s1,24(sp)
 1d8:	e84a                	sd	s2,16(sp)
 1da:	1800                	addi	s0,sp,48
    int pid = fork();
 1dc:	00000097          	auipc	ra,0x0
 1e0:	616080e7          	jalr	1558(ra) # 7f2 <fork>
    if (pid == 0){
 1e4:	e141                	bnez	a0,264 <test4+0x94>
        s1.sa_handler= (void *)19;
 1e6:	47cd                	li	a5,19
 1e8:	fcf43823          	sd	a5,-48(s0)
        s1.sigmask= (1<<5);
 1ec:	02000793          	li	a5,32
 1f0:	fcf42c23          	sw	a5,-40(s0)
        int ret = sigaction(4, &s1, 0);
 1f4:	4601                	li	a2,0
 1f6:	fd040593          	addi	a1,s0,-48
 1fa:	4511                	li	a0,4
 1fc:	00000097          	auipc	ra,0x0
 200:	6a6080e7          	jalr	1702(ra) # 8a2 <sigaction>
 204:	85aa                	mv	a1,a0
        printf("ret = %d \n", ret);
 206:	00001517          	auipc	a0,0x1
 20a:	bb250513          	addi	a0,a0,-1102 # db8 <malloc+0x170>
 20e:	00001097          	auipc	ra,0x1
 212:	97c080e7          	jalr	-1668(ra) # b8a <printf>
 216:	3e800493          	li	s1,1000
            printf(".");
 21a:	00001917          	auipc	s2,0x1
 21e:	b1e90913          	addi	s2,s2,-1250 # d38 <malloc+0xf0>
 222:	854a                	mv	a0,s2
 224:	00001097          	auipc	ra,0x1
 228:	966080e7          	jalr	-1690(ra) # b8a <printf>
        for(int i=0; i<1000 ; i++){
 22c:	34fd                	addiw	s1,s1,-1
 22e:	f8f5                	bnez	s1,222 <test4+0x52>
 230:	3e800493          	li	s1,1000
            printf("_");
 234:	00001917          	auipc	s2,0x1
 238:	b0c90913          	addi	s2,s2,-1268 # d40 <malloc+0xf8>
 23c:	854a                	mv	a0,s2
 23e:	00001097          	auipc	ra,0x1
 242:	94c080e7          	jalr	-1716(ra) # b8a <printf>
        for(int i=0; i<1000 ; i++){
 246:	34fd                	addiw	s1,s1,-1
 248:	f8f5                	bnez	s1,23c <test4+0x6c>
        printf("child finish\n");
 24a:	00001517          	auipc	a0,0x1
 24e:	afe50513          	addi	a0,a0,-1282 # d48 <malloc+0x100>
 252:	00001097          	auipc	ra,0x1
 256:	938080e7          	jalr	-1736(ra) # b8a <printf>
        exit(0);
 25a:	4501                	li	a0,0
 25c:	00000097          	auipc	ra,0x0
 260:	59e080e7          	jalr	1438(ra) # 7fa <exit>
 264:	84aa                	mv	s1,a0
        sleep(3);
 266:	450d                	li	a0,3
 268:	00000097          	auipc	ra,0x0
 26c:	622080e7          	jalr	1570(ra) # 88a <sleep>
        kill(pid, 17); //SIGSTOP
 270:	45c5                	li	a1,17
 272:	8526                	mv	a0,s1
 274:	00000097          	auipc	ra,0x0
 278:	5b6080e7          	jalr	1462(ra) # 82a <kill>
        printf("sent stop\n");
 27c:	00001517          	auipc	a0,0x1
 280:	adc50513          	addi	a0,a0,-1316 # d58 <malloc+0x110>
 284:	00001097          	auipc	ra,0x1
 288:	906080e7          	jalr	-1786(ra) # b8a <printf>
        sleep(100);
 28c:	06400513          	li	a0,100
 290:	00000097          	auipc	ra,0x0
 294:	5fa080e7          	jalr	1530(ra) # 88a <sleep>
        kill(pid, 4); //SIGCONT
 298:	4591                	li	a1,4
 29a:	8526                	mv	a0,s1
 29c:	00000097          	auipc	ra,0x0
 2a0:	58e080e7          	jalr	1422(ra) # 82a <kill>
        printf("sent continue\n");
 2a4:	00001517          	auipc	a0,0x1
 2a8:	ac450513          	addi	a0,a0,-1340 # d68 <malloc+0x120>
 2ac:	00001097          	auipc	ra,0x1
 2b0:	8de080e7          	jalr	-1826(ra) # b8a <printf>
        printf("parent finish\n");
 2b4:	00001517          	auipc	a0,0x1
 2b8:	ac450513          	addi	a0,a0,-1340 # d78 <malloc+0x130>
 2bc:	00001097          	auipc	ra,0x1
 2c0:	8ce080e7          	jalr	-1842(ra) # b8a <printf>
        exit(0);
 2c4:	4501                	li	a0,0
 2c6:	00000097          	auipc	ra,0x0
 2ca:	534080e7          	jalr	1332(ra) # 7fa <exit>

00000000000002ce <test3>:

void test3(){
 2ce:	7179                	addi	sp,sp,-48
 2d0:	f406                	sd	ra,40(sp)
 2d2:	f022                	sd	s0,32(sp)
 2d4:	ec26                	sd	s1,24(sp)
 2d6:	e84a                	sd	s2,16(sp)
 2d8:	1800                	addi	s0,sp,48
    int pid = fork();
 2da:	00000097          	auipc	ra,0x0
 2de:	518080e7          	jalr	1304(ra) # 7f2 <fork>
    if (pid == 0){
 2e2:	e159                	bnez	a0,368 <test3+0x9a>
        struct sigaction s1; 
        s1.sa_handler= &sig2;
 2e4:	00000797          	auipc	a5,0x0
 2e8:	d3c78793          	addi	a5,a5,-708 # 20 <sig2>
 2ec:	fcf43823          	sd	a5,-48(s0)
        s1.sigmask= (1<<5);
 2f0:	02000793          	li	a5,32
 2f4:	fcf42c23          	sw	a5,-40(s0)
        int ret = sigaction(4, &s1, 0);
 2f8:	4601                	li	a2,0
 2fa:	fd040593          	addi	a1,s0,-48
 2fe:	4511                	li	a0,4
 300:	00000097          	auipc	ra,0x0
 304:	5a2080e7          	jalr	1442(ra) # 8a2 <sigaction>
 308:	85aa                	mv	a1,a0
        printf("ret = %d \n", ret);
 30a:	00001517          	auipc	a0,0x1
 30e:	aae50513          	addi	a0,a0,-1362 # db8 <malloc+0x170>
 312:	00001097          	auipc	ra,0x1
 316:	878080e7          	jalr	-1928(ra) # b8a <printf>
 31a:	3e800493          	li	s1,1000
        for(int i=0; i<1000 ; i++){
           // printf("printing\n");
            printf(".");
 31e:	00001917          	auipc	s2,0x1
 322:	a1a90913          	addi	s2,s2,-1510 # d38 <malloc+0xf0>
 326:	854a                	mv	a0,s2
 328:	00001097          	auipc	ra,0x1
 32c:	862080e7          	jalr	-1950(ra) # b8a <printf>
        for(int i=0; i<1000 ; i++){
 330:	34fd                	addiw	s1,s1,-1
 332:	f8f5                	bnez	s1,326 <test3+0x58>
 334:	3e800493          	li	s1,1000
        }
        for(int i=0; i<1000 ; i++){
           // printf("printing again\n");
            printf("_");
 338:	00001917          	auipc	s2,0x1
 33c:	a0890913          	addi	s2,s2,-1528 # d40 <malloc+0xf8>
 340:	854a                	mv	a0,s2
 342:	00001097          	auipc	ra,0x1
 346:	848080e7          	jalr	-1976(ra) # b8a <printf>
        for(int i=0; i<1000 ; i++){
 34a:	34fd                	addiw	s1,s1,-1
 34c:	f8f5                	bnez	s1,340 <test3+0x72>
        }
        printf("child finish\n");
 34e:	00001517          	auipc	a0,0x1
 352:	9fa50513          	addi	a0,a0,-1542 # d48 <malloc+0x100>
 356:	00001097          	auipc	ra,0x1
 35a:	834080e7          	jalr	-1996(ra) # b8a <printf>
        exit(0);
 35e:	4501                	li	a0,0
 360:	00000097          	auipc	ra,0x0
 364:	49a080e7          	jalr	1178(ra) # 7fa <exit>
 368:	84aa                	mv	s1,a0
    }
    else{
        sleep(3);
 36a:	450d                	li	a0,3
 36c:	00000097          	auipc	ra,0x0
 370:	51e080e7          	jalr	1310(ra) # 88a <sleep>
        kill(pid, 4); 
 374:	4591                	li	a1,4
 376:	8526                	mv	a0,s1
 378:	00000097          	auipc	ra,0x0
 37c:	4b2080e7          	jalr	1202(ra) # 82a <kill>
        printf("sent signal\n");
 380:	00001517          	auipc	a0,0x1
 384:	a4850513          	addi	a0,a0,-1464 # dc8 <malloc+0x180>
 388:	00001097          	auipc	ra,0x1
 38c:	802080e7          	jalr	-2046(ra) # b8a <printf>
        sleep(20);
 390:	4551                	li	a0,20
 392:	00000097          	auipc	ra,0x0
 396:	4f8080e7          	jalr	1272(ra) # 88a <sleep>
        printf("parent finish\n");
 39a:	00001517          	auipc	a0,0x1
 39e:	9de50513          	addi	a0,a0,-1570 # d78 <malloc+0x130>
 3a2:	00000097          	auipc	ra,0x0
 3a6:	7e8080e7          	jalr	2024(ra) # b8a <printf>
        exit(0);
 3aa:	4501                	li	a0,0
 3ac:	00000097          	auipc	ra,0x0
 3b0:	44e080e7          	jalr	1102(ra) # 7fa <exit>

00000000000003b4 <test5>:
    }
    
}

void test5(){
 3b4:	715d                	addi	sp,sp,-80
 3b6:	e486                	sd	ra,72(sp)
 3b8:	e0a2                	sd	s0,64(sp)
 3ba:	fc26                	sd	s1,56(sp)
 3bc:	f84a                	sd	s2,48(sp)
 3be:	0880                	addi	s0,sp,80
    int pid = fork();
 3c0:	00000097          	auipc	ra,0x0
 3c4:	432080e7          	jalr	1074(ra) # 7f2 <fork>
    if (pid == 0){
 3c8:	e161                	bnez	a0,488 <test5+0xd4>
        struct sigaction s1; 
        s1.sa_handler= &sig2;
 3ca:	00000717          	auipc	a4,0x0
 3ce:	c5670713          	addi	a4,a4,-938 # 20 <sig2>
 3d2:	fae43823          	sd	a4,-80(s0)
        s1.sigmask= (1<<5);
 3d6:	02000793          	li	a5,32
 3da:	faf42c23          	sw	a5,-72(s0)
         struct sigaction s2; 
        s2.sa_handler= &sig2;
 3de:	fce43023          	sd	a4,-64(s0)
        s2.sigmask= (1<<5);
 3e2:	fcf42423          	sw	a5,-56(s0)
        struct sigaction s3; 
        s3.sa_handler= &sig2;
 3e6:	fce43823          	sd	a4,-48(s0)
        s3.sigmask= (1<<5);
 3ea:	fcf42c23          	sw	a5,-40(s0)
        int ret = sigaction(4, &s1, 0);
 3ee:	4601                	li	a2,0
 3f0:	fb040593          	addi	a1,s0,-80
 3f4:	4511                	li	a0,4
 3f6:	00000097          	auipc	ra,0x0
 3fa:	4ac080e7          	jalr	1196(ra) # 8a2 <sigaction>
 3fe:	84aa                	mv	s1,a0
        int ret2 = sigaction(5, &s2, 0);
 400:	4601                	li	a2,0
 402:	fc040593          	addi	a1,s0,-64
 406:	4515                	li	a0,5
 408:	00000097          	auipc	ra,0x0
 40c:	49a080e7          	jalr	1178(ra) # 8a2 <sigaction>
 410:	892a                	mv	s2,a0
        int ret3 = sigaction(7, &s3, 0);
 412:	4601                	li	a2,0
 414:	fd040593          	addi	a1,s0,-48
 418:	451d                	li	a0,7
 41a:	00000097          	auipc	ra,0x0
 41e:	488080e7          	jalr	1160(ra) # 8a2 <sigaction>
 422:	86aa                	mv	a3,a0
        printf("ret = %d ret2 = %d ret3= %d\n", ret, ret2, ret3);
 424:	864a                	mv	a2,s2
 426:	85a6                	mv	a1,s1
 428:	00001517          	auipc	a0,0x1
 42c:	9b050513          	addi	a0,a0,-1616 # dd8 <malloc+0x190>
 430:	00000097          	auipc	ra,0x0
 434:	75a080e7          	jalr	1882(ra) # b8a <printf>
 438:	3e800493          	li	s1,1000
        for(int i=0; i<1000 ; i++){
           // printf("printing\n");
            printf(".");
 43c:	00001917          	auipc	s2,0x1
 440:	8fc90913          	addi	s2,s2,-1796 # d38 <malloc+0xf0>
 444:	854a                	mv	a0,s2
 446:	00000097          	auipc	ra,0x0
 44a:	744080e7          	jalr	1860(ra) # b8a <printf>
        for(int i=0; i<1000 ; i++){
 44e:	34fd                	addiw	s1,s1,-1
 450:	f8f5                	bnez	s1,444 <test5+0x90>
 452:	6485                	lui	s1,0x1
 454:	bb848493          	addi	s1,s1,-1096 # bb8 <printf+0x2e>
        }
        for(int i=0; i<3000 ; i++){
           // printf("printing again\n");
            printf("_");
 458:	00001917          	auipc	s2,0x1
 45c:	8e890913          	addi	s2,s2,-1816 # d40 <malloc+0xf8>
 460:	854a                	mv	a0,s2
 462:	00000097          	auipc	ra,0x0
 466:	728080e7          	jalr	1832(ra) # b8a <printf>
        for(int i=0; i<3000 ; i++){
 46a:	34fd                	addiw	s1,s1,-1
 46c:	f8f5                	bnez	s1,460 <test5+0xac>
        }
        printf("child finish\n");
 46e:	00001517          	auipc	a0,0x1
 472:	8da50513          	addi	a0,a0,-1830 # d48 <malloc+0x100>
 476:	00000097          	auipc	ra,0x0
 47a:	714080e7          	jalr	1812(ra) # b8a <printf>
    
        exit(0);
 47e:	4501                	li	a0,0
 480:	00000097          	auipc	ra,0x0
 484:	37a080e7          	jalr	890(ra) # 7fa <exit>
 488:	84aa                	mv	s1,a0
    }
    else{
        sleep(3);
 48a:	450d                	li	a0,3
 48c:	00000097          	auipc	ra,0x0
 490:	3fe080e7          	jalr	1022(ra) # 88a <sleep>
        kill(pid, 4); 
 494:	4591                	li	a1,4
 496:	8526                	mv	a0,s1
 498:	00000097          	auipc	ra,0x0
 49c:	392080e7          	jalr	914(ra) # 82a <kill>
        kill(pid, 5);
 4a0:	4595                	li	a1,5
 4a2:	8526                	mv	a0,s1
 4a4:	00000097          	auipc	ra,0x0
 4a8:	386080e7          	jalr	902(ra) # 82a <kill>
        kill(pid, 7);
 4ac:	459d                	li	a1,7
 4ae:	8526                	mv	a0,s1
 4b0:	00000097          	auipc	ra,0x0
 4b4:	37a080e7          	jalr	890(ra) # 82a <kill>
        printf("sent signal\n");
 4b8:	00001517          	auipc	a0,0x1
 4bc:	91050513          	addi	a0,a0,-1776 # dc8 <malloc+0x180>
 4c0:	00000097          	auipc	ra,0x0
 4c4:	6ca080e7          	jalr	1738(ra) # b8a <printf>
        sleep(6);
 4c8:	4519                	li	a0,6
 4ca:	00000097          	auipc	ra,0x0
 4ce:	3c0080e7          	jalr	960(ra) # 88a <sleep>
         
        printf("parent finish\n");
 4d2:	00001517          	auipc	a0,0x1
 4d6:	8a650513          	addi	a0,a0,-1882 # d78 <malloc+0x130>
 4da:	00000097          	auipc	ra,0x0
 4de:	6b0080e7          	jalr	1712(ra) # b8a <printf>
        exit(0);
 4e2:	4501                	li	a0,0
 4e4:	00000097          	auipc	ra,0x0
 4e8:	316080e7          	jalr	790(ra) # 7fa <exit>

00000000000004ec <main>:
    
}

int
main(int argc, char **argv)
{
 4ec:	1141                	addi	sp,sp,-16
 4ee:	e406                	sd	ra,8(sp)
 4f0:	e022                	sd	s0,0(sp)
 4f2:	0800                	addi	s0,sp,16
    printf("test %d\n", &test);
 4f4:	00000597          	auipc	a1,0x0
 4f8:	b4c58593          	addi	a1,a1,-1204 # 40 <test>
 4fc:	00001517          	auipc	a0,0x1
 500:	8fc50513          	addi	a0,a0,-1796 # df8 <malloc+0x1b0>
 504:	00000097          	auipc	ra,0x0
 508:	686080e7          	jalr	1670(ra) # b8a <printf>
    printf("test2 %d\n", &test2);
 50c:	00000597          	auipc	a1,0x0
 510:	c0258593          	addi	a1,a1,-1022 # 10e <test2>
 514:	00001517          	auipc	a0,0x1
 518:	8f450513          	addi	a0,a0,-1804 # e08 <malloc+0x1c0>
 51c:	00000097          	auipc	ra,0x0
 520:	66e080e7          	jalr	1646(ra) # b8a <printf>
    printf("test3 %d\n", &test3);
 524:	00000597          	auipc	a1,0x0
 528:	daa58593          	addi	a1,a1,-598 # 2ce <test3>
 52c:	00001517          	auipc	a0,0x1
 530:	8ec50513          	addi	a0,a0,-1812 # e18 <malloc+0x1d0>
 534:	00000097          	auipc	ra,0x0
 538:	656080e7          	jalr	1622(ra) # b8a <printf>
    printf("test4 %d\n", &test4);
 53c:	00000597          	auipc	a1,0x0
 540:	c9458593          	addi	a1,a1,-876 # 1d0 <test4>
 544:	00001517          	auipc	a0,0x1
 548:	8e450513          	addi	a0,a0,-1820 # e28 <malloc+0x1e0>
 54c:	00000097          	auipc	ra,0x0
 550:	63e080e7          	jalr	1598(ra) # b8a <printf>
    printf("sig %d\n", &sig);
 554:	00000597          	auipc	a1,0x0
 558:	aac58593          	addi	a1,a1,-1364 # 0 <sig>
 55c:	00001517          	auipc	a0,0x1
 560:	8dc50513          	addi	a0,a0,-1828 # e38 <malloc+0x1f0>
 564:	00000097          	auipc	ra,0x0
 568:	626080e7          	jalr	1574(ra) # b8a <printf>
    printf("sig2 %d\n", &sig2);
 56c:	00000597          	auipc	a1,0x0
 570:	ab458593          	addi	a1,a1,-1356 # 20 <sig2>
 574:	00001517          	auipc	a0,0x1
 578:	8cc50513          	addi	a0,a0,-1844 # e40 <malloc+0x1f8>
 57c:	00000097          	auipc	ra,0x0
 580:	60e080e7          	jalr	1550(ra) # b8a <printf>
    //test();
    //test2();
    //test3();
    test4();
 584:	00000097          	auipc	ra,0x0
 588:	c4c080e7          	jalr	-948(ra) # 1d0 <test4>

000000000000058c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 58c:	1141                	addi	sp,sp,-16
 58e:	e422                	sd	s0,8(sp)
 590:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 592:	87aa                	mv	a5,a0
 594:	0585                	addi	a1,a1,1
 596:	0785                	addi	a5,a5,1
 598:	fff5c703          	lbu	a4,-1(a1)
 59c:	fee78fa3          	sb	a4,-1(a5)
 5a0:	fb75                	bnez	a4,594 <strcpy+0x8>
    ;
  return os;
}
 5a2:	6422                	ld	s0,8(sp)
 5a4:	0141                	addi	sp,sp,16
 5a6:	8082                	ret

00000000000005a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 5a8:	1141                	addi	sp,sp,-16
 5aa:	e422                	sd	s0,8(sp)
 5ac:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 5ae:	00054783          	lbu	a5,0(a0)
 5b2:	cb91                	beqz	a5,5c6 <strcmp+0x1e>
 5b4:	0005c703          	lbu	a4,0(a1)
 5b8:	00f71763          	bne	a4,a5,5c6 <strcmp+0x1e>
    p++, q++;
 5bc:	0505                	addi	a0,a0,1
 5be:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 5c0:	00054783          	lbu	a5,0(a0)
 5c4:	fbe5                	bnez	a5,5b4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 5c6:	0005c503          	lbu	a0,0(a1)
}
 5ca:	40a7853b          	subw	a0,a5,a0
 5ce:	6422                	ld	s0,8(sp)
 5d0:	0141                	addi	sp,sp,16
 5d2:	8082                	ret

00000000000005d4 <strlen>:

uint
strlen(const char *s)
{
 5d4:	1141                	addi	sp,sp,-16
 5d6:	e422                	sd	s0,8(sp)
 5d8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 5da:	00054783          	lbu	a5,0(a0)
 5de:	cf91                	beqz	a5,5fa <strlen+0x26>
 5e0:	0505                	addi	a0,a0,1
 5e2:	87aa                	mv	a5,a0
 5e4:	4685                	li	a3,1
 5e6:	9e89                	subw	a3,a3,a0
 5e8:	00f6853b          	addw	a0,a3,a5
 5ec:	0785                	addi	a5,a5,1
 5ee:	fff7c703          	lbu	a4,-1(a5)
 5f2:	fb7d                	bnez	a4,5e8 <strlen+0x14>
    ;
  return n;
}
 5f4:	6422                	ld	s0,8(sp)
 5f6:	0141                	addi	sp,sp,16
 5f8:	8082                	ret
  for(n = 0; s[n]; n++)
 5fa:	4501                	li	a0,0
 5fc:	bfe5                	j	5f4 <strlen+0x20>

00000000000005fe <memset>:

void*
memset(void *dst, int c, uint n)
{
 5fe:	1141                	addi	sp,sp,-16
 600:	e422                	sd	s0,8(sp)
 602:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 604:	ca19                	beqz	a2,61a <memset+0x1c>
 606:	87aa                	mv	a5,a0
 608:	1602                	slli	a2,a2,0x20
 60a:	9201                	srli	a2,a2,0x20
 60c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 610:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 614:	0785                	addi	a5,a5,1
 616:	fee79de3          	bne	a5,a4,610 <memset+0x12>
  }
  return dst;
}
 61a:	6422                	ld	s0,8(sp)
 61c:	0141                	addi	sp,sp,16
 61e:	8082                	ret

0000000000000620 <strchr>:

char*
strchr(const char *s, char c)
{
 620:	1141                	addi	sp,sp,-16
 622:	e422                	sd	s0,8(sp)
 624:	0800                	addi	s0,sp,16
  for(; *s; s++)
 626:	00054783          	lbu	a5,0(a0)
 62a:	cb99                	beqz	a5,640 <strchr+0x20>
    if(*s == c)
 62c:	00f58763          	beq	a1,a5,63a <strchr+0x1a>
  for(; *s; s++)
 630:	0505                	addi	a0,a0,1
 632:	00054783          	lbu	a5,0(a0)
 636:	fbfd                	bnez	a5,62c <strchr+0xc>
      return (char*)s;
  return 0;
 638:	4501                	li	a0,0
}
 63a:	6422                	ld	s0,8(sp)
 63c:	0141                	addi	sp,sp,16
 63e:	8082                	ret
  return 0;
 640:	4501                	li	a0,0
 642:	bfe5                	j	63a <strchr+0x1a>

0000000000000644 <gets>:

char*
gets(char *buf, int max)
{
 644:	711d                	addi	sp,sp,-96
 646:	ec86                	sd	ra,88(sp)
 648:	e8a2                	sd	s0,80(sp)
 64a:	e4a6                	sd	s1,72(sp)
 64c:	e0ca                	sd	s2,64(sp)
 64e:	fc4e                	sd	s3,56(sp)
 650:	f852                	sd	s4,48(sp)
 652:	f456                	sd	s5,40(sp)
 654:	f05a                	sd	s6,32(sp)
 656:	ec5e                	sd	s7,24(sp)
 658:	1080                	addi	s0,sp,96
 65a:	8baa                	mv	s7,a0
 65c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 65e:	892a                	mv	s2,a0
 660:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 662:	4aa9                	li	s5,10
 664:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 666:	89a6                	mv	s3,s1
 668:	2485                	addiw	s1,s1,1
 66a:	0344d863          	bge	s1,s4,69a <gets+0x56>
    cc = read(0, &c, 1);
 66e:	4605                	li	a2,1
 670:	faf40593          	addi	a1,s0,-81
 674:	4501                	li	a0,0
 676:	00000097          	auipc	ra,0x0
 67a:	19c080e7          	jalr	412(ra) # 812 <read>
    if(cc < 1)
 67e:	00a05e63          	blez	a0,69a <gets+0x56>
    buf[i++] = c;
 682:	faf44783          	lbu	a5,-81(s0)
 686:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 68a:	01578763          	beq	a5,s5,698 <gets+0x54>
 68e:	0905                	addi	s2,s2,1
 690:	fd679be3          	bne	a5,s6,666 <gets+0x22>
  for(i=0; i+1 < max; ){
 694:	89a6                	mv	s3,s1
 696:	a011                	j	69a <gets+0x56>
 698:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 69a:	99de                	add	s3,s3,s7
 69c:	00098023          	sb	zero,0(s3)
  return buf;
}
 6a0:	855e                	mv	a0,s7
 6a2:	60e6                	ld	ra,88(sp)
 6a4:	6446                	ld	s0,80(sp)
 6a6:	64a6                	ld	s1,72(sp)
 6a8:	6906                	ld	s2,64(sp)
 6aa:	79e2                	ld	s3,56(sp)
 6ac:	7a42                	ld	s4,48(sp)
 6ae:	7aa2                	ld	s5,40(sp)
 6b0:	7b02                	ld	s6,32(sp)
 6b2:	6be2                	ld	s7,24(sp)
 6b4:	6125                	addi	sp,sp,96
 6b6:	8082                	ret

00000000000006b8 <stat>:

int
stat(const char *n, struct stat *st)
{
 6b8:	1101                	addi	sp,sp,-32
 6ba:	ec06                	sd	ra,24(sp)
 6bc:	e822                	sd	s0,16(sp)
 6be:	e426                	sd	s1,8(sp)
 6c0:	e04a                	sd	s2,0(sp)
 6c2:	1000                	addi	s0,sp,32
 6c4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6c6:	4581                	li	a1,0
 6c8:	00000097          	auipc	ra,0x0
 6cc:	172080e7          	jalr	370(ra) # 83a <open>
  if(fd < 0)
 6d0:	02054563          	bltz	a0,6fa <stat+0x42>
 6d4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 6d6:	85ca                	mv	a1,s2
 6d8:	00000097          	auipc	ra,0x0
 6dc:	17a080e7          	jalr	378(ra) # 852 <fstat>
 6e0:	892a                	mv	s2,a0
  close(fd);
 6e2:	8526                	mv	a0,s1
 6e4:	00000097          	auipc	ra,0x0
 6e8:	13e080e7          	jalr	318(ra) # 822 <close>
  return r;
}
 6ec:	854a                	mv	a0,s2
 6ee:	60e2                	ld	ra,24(sp)
 6f0:	6442                	ld	s0,16(sp)
 6f2:	64a2                	ld	s1,8(sp)
 6f4:	6902                	ld	s2,0(sp)
 6f6:	6105                	addi	sp,sp,32
 6f8:	8082                	ret
    return -1;
 6fa:	597d                	li	s2,-1
 6fc:	bfc5                	j	6ec <stat+0x34>

00000000000006fe <atoi>:

int
atoi(const char *s)
{
 6fe:	1141                	addi	sp,sp,-16
 700:	e422                	sd	s0,8(sp)
 702:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 704:	00054603          	lbu	a2,0(a0)
 708:	fd06079b          	addiw	a5,a2,-48
 70c:	0ff7f793          	andi	a5,a5,255
 710:	4725                	li	a4,9
 712:	02f76963          	bltu	a4,a5,744 <atoi+0x46>
 716:	86aa                	mv	a3,a0
  n = 0;
 718:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 71a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 71c:	0685                	addi	a3,a3,1
 71e:	0025179b          	slliw	a5,a0,0x2
 722:	9fa9                	addw	a5,a5,a0
 724:	0017979b          	slliw	a5,a5,0x1
 728:	9fb1                	addw	a5,a5,a2
 72a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 72e:	0006c603          	lbu	a2,0(a3)
 732:	fd06071b          	addiw	a4,a2,-48
 736:	0ff77713          	andi	a4,a4,255
 73a:	fee5f1e3          	bgeu	a1,a4,71c <atoi+0x1e>
  return n;
}
 73e:	6422                	ld	s0,8(sp)
 740:	0141                	addi	sp,sp,16
 742:	8082                	ret
  n = 0;
 744:	4501                	li	a0,0
 746:	bfe5                	j	73e <atoi+0x40>

0000000000000748 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 748:	1141                	addi	sp,sp,-16
 74a:	e422                	sd	s0,8(sp)
 74c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 74e:	02b57463          	bgeu	a0,a1,776 <memmove+0x2e>
    while(n-- > 0)
 752:	00c05f63          	blez	a2,770 <memmove+0x28>
 756:	1602                	slli	a2,a2,0x20
 758:	9201                	srli	a2,a2,0x20
 75a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 75e:	872a                	mv	a4,a0
      *dst++ = *src++;
 760:	0585                	addi	a1,a1,1
 762:	0705                	addi	a4,a4,1
 764:	fff5c683          	lbu	a3,-1(a1)
 768:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 76c:	fee79ae3          	bne	a5,a4,760 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 770:	6422                	ld	s0,8(sp)
 772:	0141                	addi	sp,sp,16
 774:	8082                	ret
    dst += n;
 776:	00c50733          	add	a4,a0,a2
    src += n;
 77a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 77c:	fec05ae3          	blez	a2,770 <memmove+0x28>
 780:	fff6079b          	addiw	a5,a2,-1
 784:	1782                	slli	a5,a5,0x20
 786:	9381                	srli	a5,a5,0x20
 788:	fff7c793          	not	a5,a5
 78c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 78e:	15fd                	addi	a1,a1,-1
 790:	177d                	addi	a4,a4,-1
 792:	0005c683          	lbu	a3,0(a1)
 796:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 79a:	fee79ae3          	bne	a5,a4,78e <memmove+0x46>
 79e:	bfc9                	j	770 <memmove+0x28>

00000000000007a0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 7a0:	1141                	addi	sp,sp,-16
 7a2:	e422                	sd	s0,8(sp)
 7a4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 7a6:	ca05                	beqz	a2,7d6 <memcmp+0x36>
 7a8:	fff6069b          	addiw	a3,a2,-1
 7ac:	1682                	slli	a3,a3,0x20
 7ae:	9281                	srli	a3,a3,0x20
 7b0:	0685                	addi	a3,a3,1
 7b2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 7b4:	00054783          	lbu	a5,0(a0)
 7b8:	0005c703          	lbu	a4,0(a1)
 7bc:	00e79863          	bne	a5,a4,7cc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 7c0:	0505                	addi	a0,a0,1
    p2++;
 7c2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 7c4:	fed518e3          	bne	a0,a3,7b4 <memcmp+0x14>
  }
  return 0;
 7c8:	4501                	li	a0,0
 7ca:	a019                	j	7d0 <memcmp+0x30>
      return *p1 - *p2;
 7cc:	40e7853b          	subw	a0,a5,a4
}
 7d0:	6422                	ld	s0,8(sp)
 7d2:	0141                	addi	sp,sp,16
 7d4:	8082                	ret
  return 0;
 7d6:	4501                	li	a0,0
 7d8:	bfe5                	j	7d0 <memcmp+0x30>

00000000000007da <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 7da:	1141                	addi	sp,sp,-16
 7dc:	e406                	sd	ra,8(sp)
 7de:	e022                	sd	s0,0(sp)
 7e0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 7e2:	00000097          	auipc	ra,0x0
 7e6:	f66080e7          	jalr	-154(ra) # 748 <memmove>
}
 7ea:	60a2                	ld	ra,8(sp)
 7ec:	6402                	ld	s0,0(sp)
 7ee:	0141                	addi	sp,sp,16
 7f0:	8082                	ret

00000000000007f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 7f2:	4885                	li	a7,1
 ecall
 7f4:	00000073          	ecall
 ret
 7f8:	8082                	ret

00000000000007fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 7fa:	4889                	li	a7,2
 ecall
 7fc:	00000073          	ecall
 ret
 800:	8082                	ret

0000000000000802 <wait>:
.global wait
wait:
 li a7, SYS_wait
 802:	488d                	li	a7,3
 ecall
 804:	00000073          	ecall
 ret
 808:	8082                	ret

000000000000080a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 80a:	4891                	li	a7,4
 ecall
 80c:	00000073          	ecall
 ret
 810:	8082                	ret

0000000000000812 <read>:
.global read
read:
 li a7, SYS_read
 812:	4895                	li	a7,5
 ecall
 814:	00000073          	ecall
 ret
 818:	8082                	ret

000000000000081a <write>:
.global write
write:
 li a7, SYS_write
 81a:	48c1                	li	a7,16
 ecall
 81c:	00000073          	ecall
 ret
 820:	8082                	ret

0000000000000822 <close>:
.global close
close:
 li a7, SYS_close
 822:	48d5                	li	a7,21
 ecall
 824:	00000073          	ecall
 ret
 828:	8082                	ret

000000000000082a <kill>:
.global kill
kill:
 li a7, SYS_kill
 82a:	4899                	li	a7,6
 ecall
 82c:	00000073          	ecall
 ret
 830:	8082                	ret

0000000000000832 <exec>:
.global exec
exec:
 li a7, SYS_exec
 832:	489d                	li	a7,7
 ecall
 834:	00000073          	ecall
 ret
 838:	8082                	ret

000000000000083a <open>:
.global open
open:
 li a7, SYS_open
 83a:	48bd                	li	a7,15
 ecall
 83c:	00000073          	ecall
 ret
 840:	8082                	ret

0000000000000842 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 842:	48c5                	li	a7,17
 ecall
 844:	00000073          	ecall
 ret
 848:	8082                	ret

000000000000084a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 84a:	48c9                	li	a7,18
 ecall
 84c:	00000073          	ecall
 ret
 850:	8082                	ret

0000000000000852 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 852:	48a1                	li	a7,8
 ecall
 854:	00000073          	ecall
 ret
 858:	8082                	ret

000000000000085a <link>:
.global link
link:
 li a7, SYS_link
 85a:	48cd                	li	a7,19
 ecall
 85c:	00000073          	ecall
 ret
 860:	8082                	ret

0000000000000862 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 862:	48d1                	li	a7,20
 ecall
 864:	00000073          	ecall
 ret
 868:	8082                	ret

000000000000086a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 86a:	48a5                	li	a7,9
 ecall
 86c:	00000073          	ecall
 ret
 870:	8082                	ret

0000000000000872 <dup>:
.global dup
dup:
 li a7, SYS_dup
 872:	48a9                	li	a7,10
 ecall
 874:	00000073          	ecall
 ret
 878:	8082                	ret

000000000000087a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 87a:	48ad                	li	a7,11
 ecall
 87c:	00000073          	ecall
 ret
 880:	8082                	ret

0000000000000882 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 882:	48b1                	li	a7,12
 ecall
 884:	00000073          	ecall
 ret
 888:	8082                	ret

000000000000088a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 88a:	48b5                	li	a7,13
 ecall
 88c:	00000073          	ecall
 ret
 890:	8082                	ret

0000000000000892 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 892:	48b9                	li	a7,14
 ecall
 894:	00000073          	ecall
 ret
 898:	8082                	ret

000000000000089a <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 89a:	48d9                	li	a7,22
 ecall
 89c:	00000073          	ecall
 ret
 8a0:	8082                	ret

00000000000008a2 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 8a2:	48dd                	li	a7,23
 ecall
 8a4:	00000073          	ecall
 ret
 8a8:	8082                	ret

00000000000008aa <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 8aa:	48e1                	li	a7,24
 ecall
 8ac:	00000073          	ecall
 ret
 8b0:	8082                	ret

00000000000008b2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 8b2:	1101                	addi	sp,sp,-32
 8b4:	ec06                	sd	ra,24(sp)
 8b6:	e822                	sd	s0,16(sp)
 8b8:	1000                	addi	s0,sp,32
 8ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 8be:	4605                	li	a2,1
 8c0:	fef40593          	addi	a1,s0,-17
 8c4:	00000097          	auipc	ra,0x0
 8c8:	f56080e7          	jalr	-170(ra) # 81a <write>
}
 8cc:	60e2                	ld	ra,24(sp)
 8ce:	6442                	ld	s0,16(sp)
 8d0:	6105                	addi	sp,sp,32
 8d2:	8082                	ret

00000000000008d4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 8d4:	7139                	addi	sp,sp,-64
 8d6:	fc06                	sd	ra,56(sp)
 8d8:	f822                	sd	s0,48(sp)
 8da:	f426                	sd	s1,40(sp)
 8dc:	f04a                	sd	s2,32(sp)
 8de:	ec4e                	sd	s3,24(sp)
 8e0:	0080                	addi	s0,sp,64
 8e2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 8e4:	c299                	beqz	a3,8ea <printint+0x16>
 8e6:	0805c863          	bltz	a1,976 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 8ea:	2581                	sext.w	a1,a1
  neg = 0;
 8ec:	4881                	li	a7,0
 8ee:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 8f2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 8f4:	2601                	sext.w	a2,a2
 8f6:	00000517          	auipc	a0,0x0
 8fa:	56250513          	addi	a0,a0,1378 # e58 <digits>
 8fe:	883a                	mv	a6,a4
 900:	2705                	addiw	a4,a4,1
 902:	02c5f7bb          	remuw	a5,a1,a2
 906:	1782                	slli	a5,a5,0x20
 908:	9381                	srli	a5,a5,0x20
 90a:	97aa                	add	a5,a5,a0
 90c:	0007c783          	lbu	a5,0(a5)
 910:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 914:	0005879b          	sext.w	a5,a1
 918:	02c5d5bb          	divuw	a1,a1,a2
 91c:	0685                	addi	a3,a3,1
 91e:	fec7f0e3          	bgeu	a5,a2,8fe <printint+0x2a>
  if(neg)
 922:	00088b63          	beqz	a7,938 <printint+0x64>
    buf[i++] = '-';
 926:	fd040793          	addi	a5,s0,-48
 92a:	973e                	add	a4,a4,a5
 92c:	02d00793          	li	a5,45
 930:	fef70823          	sb	a5,-16(a4)
 934:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 938:	02e05863          	blez	a4,968 <printint+0x94>
 93c:	fc040793          	addi	a5,s0,-64
 940:	00e78933          	add	s2,a5,a4
 944:	fff78993          	addi	s3,a5,-1
 948:	99ba                	add	s3,s3,a4
 94a:	377d                	addiw	a4,a4,-1
 94c:	1702                	slli	a4,a4,0x20
 94e:	9301                	srli	a4,a4,0x20
 950:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 954:	fff94583          	lbu	a1,-1(s2)
 958:	8526                	mv	a0,s1
 95a:	00000097          	auipc	ra,0x0
 95e:	f58080e7          	jalr	-168(ra) # 8b2 <putc>
  while(--i >= 0)
 962:	197d                	addi	s2,s2,-1
 964:	ff3918e3          	bne	s2,s3,954 <printint+0x80>
}
 968:	70e2                	ld	ra,56(sp)
 96a:	7442                	ld	s0,48(sp)
 96c:	74a2                	ld	s1,40(sp)
 96e:	7902                	ld	s2,32(sp)
 970:	69e2                	ld	s3,24(sp)
 972:	6121                	addi	sp,sp,64
 974:	8082                	ret
    x = -xx;
 976:	40b005bb          	negw	a1,a1
    neg = 1;
 97a:	4885                	li	a7,1
    x = -xx;
 97c:	bf8d                	j	8ee <printint+0x1a>

000000000000097e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 97e:	7119                	addi	sp,sp,-128
 980:	fc86                	sd	ra,120(sp)
 982:	f8a2                	sd	s0,112(sp)
 984:	f4a6                	sd	s1,104(sp)
 986:	f0ca                	sd	s2,96(sp)
 988:	ecce                	sd	s3,88(sp)
 98a:	e8d2                	sd	s4,80(sp)
 98c:	e4d6                	sd	s5,72(sp)
 98e:	e0da                	sd	s6,64(sp)
 990:	fc5e                	sd	s7,56(sp)
 992:	f862                	sd	s8,48(sp)
 994:	f466                	sd	s9,40(sp)
 996:	f06a                	sd	s10,32(sp)
 998:	ec6e                	sd	s11,24(sp)
 99a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 99c:	0005c903          	lbu	s2,0(a1)
 9a0:	18090f63          	beqz	s2,b3e <vprintf+0x1c0>
 9a4:	8aaa                	mv	s5,a0
 9a6:	8b32                	mv	s6,a2
 9a8:	00158493          	addi	s1,a1,1
  state = 0;
 9ac:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 9ae:	02500a13          	li	s4,37
      if(c == 'd'){
 9b2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 9b6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 9ba:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 9be:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9c2:	00000b97          	auipc	s7,0x0
 9c6:	496b8b93          	addi	s7,s7,1174 # e58 <digits>
 9ca:	a839                	j	9e8 <vprintf+0x6a>
        putc(fd, c);
 9cc:	85ca                	mv	a1,s2
 9ce:	8556                	mv	a0,s5
 9d0:	00000097          	auipc	ra,0x0
 9d4:	ee2080e7          	jalr	-286(ra) # 8b2 <putc>
 9d8:	a019                	j	9de <vprintf+0x60>
    } else if(state == '%'){
 9da:	01498f63          	beq	s3,s4,9f8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 9de:	0485                	addi	s1,s1,1
 9e0:	fff4c903          	lbu	s2,-1(s1)
 9e4:	14090d63          	beqz	s2,b3e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 9e8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 9ec:	fe0997e3          	bnez	s3,9da <vprintf+0x5c>
      if(c == '%'){
 9f0:	fd479ee3          	bne	a5,s4,9cc <vprintf+0x4e>
        state = '%';
 9f4:	89be                	mv	s3,a5
 9f6:	b7e5                	j	9de <vprintf+0x60>
      if(c == 'd'){
 9f8:	05878063          	beq	a5,s8,a38 <vprintf+0xba>
      } else if(c == 'l') {
 9fc:	05978c63          	beq	a5,s9,a54 <vprintf+0xd6>
      } else if(c == 'x') {
 a00:	07a78863          	beq	a5,s10,a70 <vprintf+0xf2>
      } else if(c == 'p') {
 a04:	09b78463          	beq	a5,s11,a8c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 a08:	07300713          	li	a4,115
 a0c:	0ce78663          	beq	a5,a4,ad8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a10:	06300713          	li	a4,99
 a14:	0ee78e63          	beq	a5,a4,b10 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 a18:	11478863          	beq	a5,s4,b28 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a1c:	85d2                	mv	a1,s4
 a1e:	8556                	mv	a0,s5
 a20:	00000097          	auipc	ra,0x0
 a24:	e92080e7          	jalr	-366(ra) # 8b2 <putc>
        putc(fd, c);
 a28:	85ca                	mv	a1,s2
 a2a:	8556                	mv	a0,s5
 a2c:	00000097          	auipc	ra,0x0
 a30:	e86080e7          	jalr	-378(ra) # 8b2 <putc>
      }
      state = 0;
 a34:	4981                	li	s3,0
 a36:	b765                	j	9de <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 a38:	008b0913          	addi	s2,s6,8
 a3c:	4685                	li	a3,1
 a3e:	4629                	li	a2,10
 a40:	000b2583          	lw	a1,0(s6)
 a44:	8556                	mv	a0,s5
 a46:	00000097          	auipc	ra,0x0
 a4a:	e8e080e7          	jalr	-370(ra) # 8d4 <printint>
 a4e:	8b4a                	mv	s6,s2
      state = 0;
 a50:	4981                	li	s3,0
 a52:	b771                	j	9de <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a54:	008b0913          	addi	s2,s6,8
 a58:	4681                	li	a3,0
 a5a:	4629                	li	a2,10
 a5c:	000b2583          	lw	a1,0(s6)
 a60:	8556                	mv	a0,s5
 a62:	00000097          	auipc	ra,0x0
 a66:	e72080e7          	jalr	-398(ra) # 8d4 <printint>
 a6a:	8b4a                	mv	s6,s2
      state = 0;
 a6c:	4981                	li	s3,0
 a6e:	bf85                	j	9de <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 a70:	008b0913          	addi	s2,s6,8
 a74:	4681                	li	a3,0
 a76:	4641                	li	a2,16
 a78:	000b2583          	lw	a1,0(s6)
 a7c:	8556                	mv	a0,s5
 a7e:	00000097          	auipc	ra,0x0
 a82:	e56080e7          	jalr	-426(ra) # 8d4 <printint>
 a86:	8b4a                	mv	s6,s2
      state = 0;
 a88:	4981                	li	s3,0
 a8a:	bf91                	j	9de <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 a8c:	008b0793          	addi	a5,s6,8
 a90:	f8f43423          	sd	a5,-120(s0)
 a94:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 a98:	03000593          	li	a1,48
 a9c:	8556                	mv	a0,s5
 a9e:	00000097          	auipc	ra,0x0
 aa2:	e14080e7          	jalr	-492(ra) # 8b2 <putc>
  putc(fd, 'x');
 aa6:	85ea                	mv	a1,s10
 aa8:	8556                	mv	a0,s5
 aaa:	00000097          	auipc	ra,0x0
 aae:	e08080e7          	jalr	-504(ra) # 8b2 <putc>
 ab2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ab4:	03c9d793          	srli	a5,s3,0x3c
 ab8:	97de                	add	a5,a5,s7
 aba:	0007c583          	lbu	a1,0(a5)
 abe:	8556                	mv	a0,s5
 ac0:	00000097          	auipc	ra,0x0
 ac4:	df2080e7          	jalr	-526(ra) # 8b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 ac8:	0992                	slli	s3,s3,0x4
 aca:	397d                	addiw	s2,s2,-1
 acc:	fe0914e3          	bnez	s2,ab4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 ad0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 ad4:	4981                	li	s3,0
 ad6:	b721                	j	9de <vprintf+0x60>
        s = va_arg(ap, char*);
 ad8:	008b0993          	addi	s3,s6,8
 adc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 ae0:	02090163          	beqz	s2,b02 <vprintf+0x184>
        while(*s != 0){
 ae4:	00094583          	lbu	a1,0(s2)
 ae8:	c9a1                	beqz	a1,b38 <vprintf+0x1ba>
          putc(fd, *s);
 aea:	8556                	mv	a0,s5
 aec:	00000097          	auipc	ra,0x0
 af0:	dc6080e7          	jalr	-570(ra) # 8b2 <putc>
          s++;
 af4:	0905                	addi	s2,s2,1
        while(*s != 0){
 af6:	00094583          	lbu	a1,0(s2)
 afa:	f9e5                	bnez	a1,aea <vprintf+0x16c>
        s = va_arg(ap, char*);
 afc:	8b4e                	mv	s6,s3
      state = 0;
 afe:	4981                	li	s3,0
 b00:	bdf9                	j	9de <vprintf+0x60>
          s = "(null)";
 b02:	00000917          	auipc	s2,0x0
 b06:	34e90913          	addi	s2,s2,846 # e50 <malloc+0x208>
        while(*s != 0){
 b0a:	02800593          	li	a1,40
 b0e:	bff1                	j	aea <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 b10:	008b0913          	addi	s2,s6,8
 b14:	000b4583          	lbu	a1,0(s6)
 b18:	8556                	mv	a0,s5
 b1a:	00000097          	auipc	ra,0x0
 b1e:	d98080e7          	jalr	-616(ra) # 8b2 <putc>
 b22:	8b4a                	mv	s6,s2
      state = 0;
 b24:	4981                	li	s3,0
 b26:	bd65                	j	9de <vprintf+0x60>
        putc(fd, c);
 b28:	85d2                	mv	a1,s4
 b2a:	8556                	mv	a0,s5
 b2c:	00000097          	auipc	ra,0x0
 b30:	d86080e7          	jalr	-634(ra) # 8b2 <putc>
      state = 0;
 b34:	4981                	li	s3,0
 b36:	b565                	j	9de <vprintf+0x60>
        s = va_arg(ap, char*);
 b38:	8b4e                	mv	s6,s3
      state = 0;
 b3a:	4981                	li	s3,0
 b3c:	b54d                	j	9de <vprintf+0x60>
    }
  }
}
 b3e:	70e6                	ld	ra,120(sp)
 b40:	7446                	ld	s0,112(sp)
 b42:	74a6                	ld	s1,104(sp)
 b44:	7906                	ld	s2,96(sp)
 b46:	69e6                	ld	s3,88(sp)
 b48:	6a46                	ld	s4,80(sp)
 b4a:	6aa6                	ld	s5,72(sp)
 b4c:	6b06                	ld	s6,64(sp)
 b4e:	7be2                	ld	s7,56(sp)
 b50:	7c42                	ld	s8,48(sp)
 b52:	7ca2                	ld	s9,40(sp)
 b54:	7d02                	ld	s10,32(sp)
 b56:	6de2                	ld	s11,24(sp)
 b58:	6109                	addi	sp,sp,128
 b5a:	8082                	ret

0000000000000b5c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b5c:	715d                	addi	sp,sp,-80
 b5e:	ec06                	sd	ra,24(sp)
 b60:	e822                	sd	s0,16(sp)
 b62:	1000                	addi	s0,sp,32
 b64:	e010                	sd	a2,0(s0)
 b66:	e414                	sd	a3,8(s0)
 b68:	e818                	sd	a4,16(s0)
 b6a:	ec1c                	sd	a5,24(s0)
 b6c:	03043023          	sd	a6,32(s0)
 b70:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b74:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b78:	8622                	mv	a2,s0
 b7a:	00000097          	auipc	ra,0x0
 b7e:	e04080e7          	jalr	-508(ra) # 97e <vprintf>
}
 b82:	60e2                	ld	ra,24(sp)
 b84:	6442                	ld	s0,16(sp)
 b86:	6161                	addi	sp,sp,80
 b88:	8082                	ret

0000000000000b8a <printf>:

void
printf(const char *fmt, ...)
{
 b8a:	711d                	addi	sp,sp,-96
 b8c:	ec06                	sd	ra,24(sp)
 b8e:	e822                	sd	s0,16(sp)
 b90:	1000                	addi	s0,sp,32
 b92:	e40c                	sd	a1,8(s0)
 b94:	e810                	sd	a2,16(s0)
 b96:	ec14                	sd	a3,24(s0)
 b98:	f018                	sd	a4,32(s0)
 b9a:	f41c                	sd	a5,40(s0)
 b9c:	03043823          	sd	a6,48(s0)
 ba0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 ba4:	00840613          	addi	a2,s0,8
 ba8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 bac:	85aa                	mv	a1,a0
 bae:	4505                	li	a0,1
 bb0:	00000097          	auipc	ra,0x0
 bb4:	dce080e7          	jalr	-562(ra) # 97e <vprintf>
}
 bb8:	60e2                	ld	ra,24(sp)
 bba:	6442                	ld	s0,16(sp)
 bbc:	6125                	addi	sp,sp,96
 bbe:	8082                	ret

0000000000000bc0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bc0:	1141                	addi	sp,sp,-16
 bc2:	e422                	sd	s0,8(sp)
 bc4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bc6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bca:	00000797          	auipc	a5,0x0
 bce:	2a67b783          	ld	a5,678(a5) # e70 <freep>
 bd2:	a805                	j	c02 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 bd4:	4618                	lw	a4,8(a2)
 bd6:	9db9                	addw	a1,a1,a4
 bd8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 bdc:	6398                	ld	a4,0(a5)
 bde:	6318                	ld	a4,0(a4)
 be0:	fee53823          	sd	a4,-16(a0)
 be4:	a091                	j	c28 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 be6:	ff852703          	lw	a4,-8(a0)
 bea:	9e39                	addw	a2,a2,a4
 bec:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 bee:	ff053703          	ld	a4,-16(a0)
 bf2:	e398                	sd	a4,0(a5)
 bf4:	a099                	j	c3a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bf6:	6398                	ld	a4,0(a5)
 bf8:	00e7e463          	bltu	a5,a4,c00 <free+0x40>
 bfc:	00e6ea63          	bltu	a3,a4,c10 <free+0x50>
{
 c00:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c02:	fed7fae3          	bgeu	a5,a3,bf6 <free+0x36>
 c06:	6398                	ld	a4,0(a5)
 c08:	00e6e463          	bltu	a3,a4,c10 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c0c:	fee7eae3          	bltu	a5,a4,c00 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 c10:	ff852583          	lw	a1,-8(a0)
 c14:	6390                	ld	a2,0(a5)
 c16:	02059813          	slli	a6,a1,0x20
 c1a:	01c85713          	srli	a4,a6,0x1c
 c1e:	9736                	add	a4,a4,a3
 c20:	fae60ae3          	beq	a2,a4,bd4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 c24:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 c28:	4790                	lw	a2,8(a5)
 c2a:	02061593          	slli	a1,a2,0x20
 c2e:	01c5d713          	srli	a4,a1,0x1c
 c32:	973e                	add	a4,a4,a5
 c34:	fae689e3          	beq	a3,a4,be6 <free+0x26>
  } else
    p->s.ptr = bp;
 c38:	e394                	sd	a3,0(a5)
  freep = p;
 c3a:	00000717          	auipc	a4,0x0
 c3e:	22f73b23          	sd	a5,566(a4) # e70 <freep>
}
 c42:	6422                	ld	s0,8(sp)
 c44:	0141                	addi	sp,sp,16
 c46:	8082                	ret

0000000000000c48 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 c48:	7139                	addi	sp,sp,-64
 c4a:	fc06                	sd	ra,56(sp)
 c4c:	f822                	sd	s0,48(sp)
 c4e:	f426                	sd	s1,40(sp)
 c50:	f04a                	sd	s2,32(sp)
 c52:	ec4e                	sd	s3,24(sp)
 c54:	e852                	sd	s4,16(sp)
 c56:	e456                	sd	s5,8(sp)
 c58:	e05a                	sd	s6,0(sp)
 c5a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c5c:	02051493          	slli	s1,a0,0x20
 c60:	9081                	srli	s1,s1,0x20
 c62:	04bd                	addi	s1,s1,15
 c64:	8091                	srli	s1,s1,0x4
 c66:	0014899b          	addiw	s3,s1,1
 c6a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 c6c:	00000517          	auipc	a0,0x0
 c70:	20453503          	ld	a0,516(a0) # e70 <freep>
 c74:	c515                	beqz	a0,ca0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c76:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c78:	4798                	lw	a4,8(a5)
 c7a:	02977f63          	bgeu	a4,s1,cb8 <malloc+0x70>
 c7e:	8a4e                	mv	s4,s3
 c80:	0009871b          	sext.w	a4,s3
 c84:	6685                	lui	a3,0x1
 c86:	00d77363          	bgeu	a4,a3,c8c <malloc+0x44>
 c8a:	6a05                	lui	s4,0x1
 c8c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c90:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c94:	00000917          	auipc	s2,0x0
 c98:	1dc90913          	addi	s2,s2,476 # e70 <freep>
  if(p == (char*)-1)
 c9c:	5afd                	li	s5,-1
 c9e:	a895                	j	d12 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 ca0:	00000797          	auipc	a5,0x0
 ca4:	1d878793          	addi	a5,a5,472 # e78 <base>
 ca8:	00000717          	auipc	a4,0x0
 cac:	1cf73423          	sd	a5,456(a4) # e70 <freep>
 cb0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 cb2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 cb6:	b7e1                	j	c7e <malloc+0x36>
      if(p->s.size == nunits)
 cb8:	02e48c63          	beq	s1,a4,cf0 <malloc+0xa8>
        p->s.size -= nunits;
 cbc:	4137073b          	subw	a4,a4,s3
 cc0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 cc2:	02071693          	slli	a3,a4,0x20
 cc6:	01c6d713          	srli	a4,a3,0x1c
 cca:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ccc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 cd0:	00000717          	auipc	a4,0x0
 cd4:	1aa73023          	sd	a0,416(a4) # e70 <freep>
      return (void*)(p + 1);
 cd8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 cdc:	70e2                	ld	ra,56(sp)
 cde:	7442                	ld	s0,48(sp)
 ce0:	74a2                	ld	s1,40(sp)
 ce2:	7902                	ld	s2,32(sp)
 ce4:	69e2                	ld	s3,24(sp)
 ce6:	6a42                	ld	s4,16(sp)
 ce8:	6aa2                	ld	s5,8(sp)
 cea:	6b02                	ld	s6,0(sp)
 cec:	6121                	addi	sp,sp,64
 cee:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 cf0:	6398                	ld	a4,0(a5)
 cf2:	e118                	sd	a4,0(a0)
 cf4:	bff1                	j	cd0 <malloc+0x88>
  hp->s.size = nu;
 cf6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 cfa:	0541                	addi	a0,a0,16
 cfc:	00000097          	auipc	ra,0x0
 d00:	ec4080e7          	jalr	-316(ra) # bc0 <free>
  return freep;
 d04:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 d08:	d971                	beqz	a0,cdc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d0c:	4798                	lw	a4,8(a5)
 d0e:	fa9775e3          	bgeu	a4,s1,cb8 <malloc+0x70>
    if(p == freep)
 d12:	00093703          	ld	a4,0(s2)
 d16:	853e                	mv	a0,a5
 d18:	fef719e3          	bne	a4,a5,d0a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 d1c:	8552                	mv	a0,s4
 d1e:	00000097          	auipc	ra,0x0
 d22:	b64080e7          	jalr	-1180(ra) # 882 <sbrk>
  if(p == (char*)-1)
 d26:	fd5518e3          	bne	a0,s5,cf6 <malloc+0xae>
        return 0;
 d2a:	4501                	li	a0,0
 d2c:	bf45                	j	cdc <malloc+0x94>
