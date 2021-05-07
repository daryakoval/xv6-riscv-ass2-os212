
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_handler>:
char buf[BUFSZ];


int wait_sig = 0;

void test_handler(int signum){
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
    wait_sig = 1;
       8:	4785                	li	a5,1
       a:	00008717          	auipc	a4,0x8
       e:	2af72b23          	sw	a5,694(a4) # 82c0 <wait_sig>
    printf("Received sigtest\n");
      12:	00006517          	auipc	a0,0x6
      16:	f2650513          	addi	a0,a0,-218 # 5f38 <malloc+0x300>
      1a:	00006097          	auipc	ra,0x6
      1e:	b60080e7          	jalr	-1184(ra) # 5b7a <printf>
}
      22:	60a2                	ld	ra,8(sp)
      24:	6402                	ld	s0,0(sp)
      26:	0141                	addi	sp,sp,16
      28:	8082                	ret

000000000000002a <test_handler2>:
void test_handler2(int signum){
      2a:	1141                	addi	sp,sp,-16
      2c:	e406                	sd	ra,8(sp)
      2e:	e022                	sd	s0,0(sp)
      30:	0800                	addi	s0,sp,16
    wait_sig = 1;
      32:	4785                	li	a5,1
      34:	00008717          	auipc	a4,0x8
      38:	28f72623          	sw	a5,652(a4) # 82c0 <wait_sig>
    printf("Received sigtest\n");
      3c:	00006517          	auipc	a0,0x6
      40:	efc50513          	addi	a0,a0,-260 # 5f38 <malloc+0x300>
      44:	00006097          	auipc	ra,0x6
      48:	b36080e7          	jalr	-1226(ra) # 5b7a <printf>
}
      4c:	60a2                	ld	ra,8(sp)
      4e:	6402                	ld	s0,0(sp)
      50:	0141                	addi	sp,sp,16
      52:	8082                	ret

0000000000000054 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      54:	00009797          	auipc	a5,0x9
      58:	38478793          	addi	a5,a5,900 # 93d8 <uninit>
      5c:	0000c697          	auipc	a3,0xc
      60:	a8c68693          	addi	a3,a3,-1396 # bae8 <buf>
    if(uninit[i] != '\0'){
      64:	0007c703          	lbu	a4,0(a5)
      68:	e709                	bnez	a4,72 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6a:	0785                	addi	a5,a5,1
      6c:	fed79ce3          	bne	a5,a3,64 <bsstest+0x10>
      70:	8082                	ret
{
      72:	1141                	addi	sp,sp,-16
      74:	e406                	sd	ra,8(sp)
      76:	e022                	sd	s0,0(sp)
      78:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7a:	85aa                	mv	a1,a0
      7c:	00006517          	auipc	a0,0x6
      80:	ed450513          	addi	a0,a0,-300 # 5f50 <malloc+0x318>
      84:	00006097          	auipc	ra,0x6
      88:	af6080e7          	jalr	-1290(ra) # 5b7a <printf>
      exit(1);
      8c:	4505                	li	a0,1
      8e:	00005097          	auipc	ra,0x5
      92:	75c080e7          	jalr	1884(ra) # 57ea <exit>

0000000000000096 <signal_test>:
void signal_test(char *s){
      96:	715d                	addi	sp,sp,-80
      98:	e486                	sd	ra,72(sp)
      9a:	e0a2                	sd	s0,64(sp)
      9c:	fc26                	sd	s1,56(sp)
      9e:	0880                	addi	s0,sp,80
    int pid=0;
      a0:	fc042e23          	sw	zero,-36(s0)
        printf("pointer is: %p\n",test_handler);
      a4:	00000597          	auipc	a1,0x0
      a8:	f5c58593          	addi	a1,a1,-164 # 0 <test_handler>
      ac:	00006517          	auipc	a0,0x6
      b0:	ebc50513          	addi	a0,a0,-324 # 5f68 <malloc+0x330>
      b4:	00006097          	auipc	ra,0x6
      b8:	ac6080e7          	jalr	-1338(ra) # 5b7a <printf>
    printf("pointer is: %p\n",test_handler2);
      bc:	00000597          	auipc	a1,0x0
      c0:	f6e58593          	addi	a1,a1,-146 # 2a <test_handler2>
      c4:	00006517          	auipc	a0,0x6
      c8:	ea450513          	addi	a0,a0,-348 # 5f68 <malloc+0x330>
      cc:	00006097          	auipc	ra,0x6
      d0:	aae080e7          	jalr	-1362(ra) # 5b7a <printf>
    struct sigaction act = {test_handler2, (uint)(1 << 29)};
      d4:	00000797          	auipc	a5,0x0
      d8:	f5678793          	addi	a5,a5,-170 # 2a <test_handler2>
      dc:	fcf43423          	sd	a5,-56(s0)
      e0:	200007b7          	lui	a5,0x20000
      e4:	fcf42823          	sw	a5,-48(s0)
    sigprocmask(0);
      e8:	4501                	li	a0,0
      ea:	00005097          	auipc	ra,0x5
      ee:	7a0080e7          	jalr	1952(ra) # 588a <sigprocmask>
    sigaction(testsig, &act, &old);
      f2:	fb840613          	addi	a2,s0,-72
      f6:	fc840593          	addi	a1,s0,-56
      fa:	453d                	li	a0,15
      fc:	00005097          	auipc	ra,0x5
     100:	796080e7          	jalr	1942(ra) # 5892 <sigaction>
     if((pid = fork()) == 0){
     104:	00005097          	auipc	ra,0x5
     108:	6de080e7          	jalr	1758(ra) # 57e2 <fork>
     10c:	fca42e23          	sw	a0,-36(s0)
     110:	c521                	beqz	a0,158 <signal_test+0xc2>
     112:	85aa                	mv	a1,a0
    printf("pid is: %d\n",pid);
     114:	00006517          	auipc	a0,0x6
     118:	e6450513          	addi	a0,a0,-412 # 5f78 <malloc+0x340>
     11c:	00006097          	auipc	ra,0x6
     120:	a5e080e7          	jalr	-1442(ra) # 5b7a <printf>
    kill(pid, testsig);
     124:	45bd                	li	a1,15
     126:	fdc42503          	lw	a0,-36(s0)
     12a:	00005097          	auipc	ra,0x5
     12e:	6f0080e7          	jalr	1776(ra) # 581a <kill>
    wait(&pid);
     132:	fdc40513          	addi	a0,s0,-36
     136:	00005097          	auipc	ra,0x5
     13a:	6bc080e7          	jalr	1724(ra) # 57f2 <wait>
    printf("Finished testing signals\n");
     13e:	00006517          	auipc	a0,0x6
     142:	e4a50513          	addi	a0,a0,-438 # 5f88 <malloc+0x350>
     146:	00006097          	auipc	ra,0x6
     14a:	a34080e7          	jalr	-1484(ra) # 5b7a <printf>
}
     14e:	60a6                	ld	ra,72(sp)
     150:	6406                	ld	s0,64(sp)
     152:	74e2                	ld	s1,56(sp)
     154:	6161                	addi	sp,sp,80
     156:	8082                	ret
        while(!wait_sig)
     158:	00008797          	auipc	a5,0x8
     15c:	1687a783          	lw	a5,360(a5) # 82c0 <wait_sig>
     160:	ef81                	bnez	a5,178 <signal_test+0xe2>
     162:	00008497          	auipc	s1,0x8
     166:	15e48493          	addi	s1,s1,350 # 82c0 <wait_sig>
            sleep(1);
     16a:	4505                	li	a0,1
     16c:	00005097          	auipc	ra,0x5
     170:	70e080e7          	jalr	1806(ra) # 587a <sleep>
        while(!wait_sig)
     174:	409c                	lw	a5,0(s1)
     176:	dbf5                	beqz	a5,16a <signal_test+0xd4>
        exit(0);
     178:	4501                	li	a0,0
     17a:	00005097          	auipc	ra,0x5
     17e:	670080e7          	jalr	1648(ra) # 57ea <exit>

0000000000000182 <exitwait>:
{
     182:	7139                	addi	sp,sp,-64
     184:	fc06                	sd	ra,56(sp)
     186:	f822                	sd	s0,48(sp)
     188:	f426                	sd	s1,40(sp)
     18a:	f04a                	sd	s2,32(sp)
     18c:	ec4e                	sd	s3,24(sp)
     18e:	e852                	sd	s4,16(sp)
     190:	0080                	addi	s0,sp,64
     192:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
     194:	4901                	li	s2,0
     196:	06400993          	li	s3,100
    pid = fork();
     19a:	00005097          	auipc	ra,0x5
     19e:	648080e7          	jalr	1608(ra) # 57e2 <fork>
     1a2:	84aa                	mv	s1,a0
    if(pid < 0){
     1a4:	02054a63          	bltz	a0,1d8 <exitwait+0x56>
    if(pid){
     1a8:	c151                	beqz	a0,22c <exitwait+0xaa>
      if(wait(&xstate) != pid){
     1aa:	fcc40513          	addi	a0,s0,-52
     1ae:	00005097          	auipc	ra,0x5
     1b2:	644080e7          	jalr	1604(ra) # 57f2 <wait>
     1b6:	02951f63          	bne	a0,s1,1f4 <exitwait+0x72>
      if(i != xstate) {
     1ba:	fcc42783          	lw	a5,-52(s0)
     1be:	05279963          	bne	a5,s2,210 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
     1c2:	2905                	addiw	s2,s2,1
     1c4:	fd391be3          	bne	s2,s3,19a <exitwait+0x18>
}
     1c8:	70e2                	ld	ra,56(sp)
     1ca:	7442                	ld	s0,48(sp)
     1cc:	74a2                	ld	s1,40(sp)
     1ce:	7902                	ld	s2,32(sp)
     1d0:	69e2                	ld	s3,24(sp)
     1d2:	6a42                	ld	s4,16(sp)
     1d4:	6121                	addi	sp,sp,64
     1d6:	8082                	ret
      printf("%s: fork failed\n", s);
     1d8:	85d2                	mv	a1,s4
     1da:	00006517          	auipc	a0,0x6
     1de:	dce50513          	addi	a0,a0,-562 # 5fa8 <malloc+0x370>
     1e2:	00006097          	auipc	ra,0x6
     1e6:	998080e7          	jalr	-1640(ra) # 5b7a <printf>
      exit(1);
     1ea:	4505                	li	a0,1
     1ec:	00005097          	auipc	ra,0x5
     1f0:	5fe080e7          	jalr	1534(ra) # 57ea <exit>
        printf("%s: wait wrong pid\n", s);
     1f4:	85d2                	mv	a1,s4
     1f6:	00006517          	auipc	a0,0x6
     1fa:	dca50513          	addi	a0,a0,-566 # 5fc0 <malloc+0x388>
     1fe:	00006097          	auipc	ra,0x6
     202:	97c080e7          	jalr	-1668(ra) # 5b7a <printf>
        exit(1);
     206:	4505                	li	a0,1
     208:	00005097          	auipc	ra,0x5
     20c:	5e2080e7          	jalr	1506(ra) # 57ea <exit>
        printf("%s: wait wrong exit status\n", s);
     210:	85d2                	mv	a1,s4
     212:	00006517          	auipc	a0,0x6
     216:	dc650513          	addi	a0,a0,-570 # 5fd8 <malloc+0x3a0>
     21a:	00006097          	auipc	ra,0x6
     21e:	960080e7          	jalr	-1696(ra) # 5b7a <printf>
        exit(1);
     222:	4505                	li	a0,1
     224:	00005097          	auipc	ra,0x5
     228:	5c6080e7          	jalr	1478(ra) # 57ea <exit>
      exit(i);
     22c:	854a                	mv	a0,s2
     22e:	00005097          	auipc	ra,0x5
     232:	5bc080e7          	jalr	1468(ra) # 57ea <exit>

0000000000000236 <twochildren>:
{
     236:	1101                	addi	sp,sp,-32
     238:	ec06                	sd	ra,24(sp)
     23a:	e822                	sd	s0,16(sp)
     23c:	e426                	sd	s1,8(sp)
     23e:	e04a                	sd	s2,0(sp)
     240:	1000                	addi	s0,sp,32
     242:	892a                	mv	s2,a0
     244:	3e800493          	li	s1,1000
    int pid1 = fork();
     248:	00005097          	auipc	ra,0x5
     24c:	59a080e7          	jalr	1434(ra) # 57e2 <fork>
    if(pid1 < 0){
     250:	02054c63          	bltz	a0,288 <twochildren+0x52>
    if(pid1 == 0){
     254:	c921                	beqz	a0,2a4 <twochildren+0x6e>
      int pid2 = fork();
     256:	00005097          	auipc	ra,0x5
     25a:	58c080e7          	jalr	1420(ra) # 57e2 <fork>
      if(pid2 < 0){
     25e:	04054763          	bltz	a0,2ac <twochildren+0x76>
      if(pid2 == 0){
     262:	c13d                	beqz	a0,2c8 <twochildren+0x92>
        wait(0);
     264:	4501                	li	a0,0
     266:	00005097          	auipc	ra,0x5
     26a:	58c080e7          	jalr	1420(ra) # 57f2 <wait>
        wait(0);
     26e:	4501                	li	a0,0
     270:	00005097          	auipc	ra,0x5
     274:	582080e7          	jalr	1410(ra) # 57f2 <wait>
  for(int i = 0; i < 1000; i++){
     278:	34fd                	addiw	s1,s1,-1
     27a:	f4f9                	bnez	s1,248 <twochildren+0x12>
}
     27c:	60e2                	ld	ra,24(sp)
     27e:	6442                	ld	s0,16(sp)
     280:	64a2                	ld	s1,8(sp)
     282:	6902                	ld	s2,0(sp)
     284:	6105                	addi	sp,sp,32
     286:	8082                	ret
      printf("%s: fork failed\n", s);
     288:	85ca                	mv	a1,s2
     28a:	00006517          	auipc	a0,0x6
     28e:	d1e50513          	addi	a0,a0,-738 # 5fa8 <malloc+0x370>
     292:	00006097          	auipc	ra,0x6
     296:	8e8080e7          	jalr	-1816(ra) # 5b7a <printf>
      exit(1);
     29a:	4505                	li	a0,1
     29c:	00005097          	auipc	ra,0x5
     2a0:	54e080e7          	jalr	1358(ra) # 57ea <exit>
      exit(0);
     2a4:	00005097          	auipc	ra,0x5
     2a8:	546080e7          	jalr	1350(ra) # 57ea <exit>
        printf("%s: fork failed\n", s);
     2ac:	85ca                	mv	a1,s2
     2ae:	00006517          	auipc	a0,0x6
     2b2:	cfa50513          	addi	a0,a0,-774 # 5fa8 <malloc+0x370>
     2b6:	00006097          	auipc	ra,0x6
     2ba:	8c4080e7          	jalr	-1852(ra) # 5b7a <printf>
        exit(1);
     2be:	4505                	li	a0,1
     2c0:	00005097          	auipc	ra,0x5
     2c4:	52a080e7          	jalr	1322(ra) # 57ea <exit>
        exit(0);
     2c8:	00005097          	auipc	ra,0x5
     2cc:	522080e7          	jalr	1314(ra) # 57ea <exit>

00000000000002d0 <forkfork>:
{
     2d0:	7179                	addi	sp,sp,-48
     2d2:	f406                	sd	ra,40(sp)
     2d4:	f022                	sd	s0,32(sp)
     2d6:	ec26                	sd	s1,24(sp)
     2d8:	1800                	addi	s0,sp,48
     2da:	84aa                	mv	s1,a0
    int pid = fork();
     2dc:	00005097          	auipc	ra,0x5
     2e0:	506080e7          	jalr	1286(ra) # 57e2 <fork>
    if(pid < 0){
     2e4:	04054163          	bltz	a0,326 <forkfork+0x56>
    if(pid == 0){
     2e8:	cd29                	beqz	a0,342 <forkfork+0x72>
    int pid = fork();
     2ea:	00005097          	auipc	ra,0x5
     2ee:	4f8080e7          	jalr	1272(ra) # 57e2 <fork>
    if(pid < 0){
     2f2:	02054a63          	bltz	a0,326 <forkfork+0x56>
    if(pid == 0){
     2f6:	c531                	beqz	a0,342 <forkfork+0x72>
    wait(&xstatus);
     2f8:	fdc40513          	addi	a0,s0,-36
     2fc:	00005097          	auipc	ra,0x5
     300:	4f6080e7          	jalr	1270(ra) # 57f2 <wait>
    if(xstatus != 0) {
     304:	fdc42783          	lw	a5,-36(s0)
     308:	ebbd                	bnez	a5,37e <forkfork+0xae>
    wait(&xstatus);
     30a:	fdc40513          	addi	a0,s0,-36
     30e:	00005097          	auipc	ra,0x5
     312:	4e4080e7          	jalr	1252(ra) # 57f2 <wait>
    if(xstatus != 0) {
     316:	fdc42783          	lw	a5,-36(s0)
     31a:	e3b5                	bnez	a5,37e <forkfork+0xae>
}
     31c:	70a2                	ld	ra,40(sp)
     31e:	7402                	ld	s0,32(sp)
     320:	64e2                	ld	s1,24(sp)
     322:	6145                	addi	sp,sp,48
     324:	8082                	ret
      printf("%s: fork failed", s);
     326:	85a6                	mv	a1,s1
     328:	00006517          	auipc	a0,0x6
     32c:	cd050513          	addi	a0,a0,-816 # 5ff8 <malloc+0x3c0>
     330:	00006097          	auipc	ra,0x6
     334:	84a080e7          	jalr	-1974(ra) # 5b7a <printf>
      exit(1);
     338:	4505                	li	a0,1
     33a:	00005097          	auipc	ra,0x5
     33e:	4b0080e7          	jalr	1200(ra) # 57ea <exit>
{
     342:	0c800493          	li	s1,200
        int pid1 = fork();
     346:	00005097          	auipc	ra,0x5
     34a:	49c080e7          	jalr	1180(ra) # 57e2 <fork>
        if(pid1 < 0){
     34e:	00054f63          	bltz	a0,36c <forkfork+0x9c>
        if(pid1 == 0){
     352:	c115                	beqz	a0,376 <forkfork+0xa6>
        wait(0);
     354:	4501                	li	a0,0
     356:	00005097          	auipc	ra,0x5
     35a:	49c080e7          	jalr	1180(ra) # 57f2 <wait>
      for(int j = 0; j < 200; j++){
     35e:	34fd                	addiw	s1,s1,-1
     360:	f0fd                	bnez	s1,346 <forkfork+0x76>
      exit(0);
     362:	4501                	li	a0,0
     364:	00005097          	auipc	ra,0x5
     368:	486080e7          	jalr	1158(ra) # 57ea <exit>
          exit(1);
     36c:	4505                	li	a0,1
     36e:	00005097          	auipc	ra,0x5
     372:	47c080e7          	jalr	1148(ra) # 57ea <exit>
          exit(0);
     376:	00005097          	auipc	ra,0x5
     37a:	474080e7          	jalr	1140(ra) # 57ea <exit>
      printf("%s: fork in child failed", s);
     37e:	85a6                	mv	a1,s1
     380:	00006517          	auipc	a0,0x6
     384:	c8850513          	addi	a0,a0,-888 # 6008 <malloc+0x3d0>
     388:	00005097          	auipc	ra,0x5
     38c:	7f2080e7          	jalr	2034(ra) # 5b7a <printf>
      exit(1);
     390:	4505                	li	a0,1
     392:	00005097          	auipc	ra,0x5
     396:	458080e7          	jalr	1112(ra) # 57ea <exit>

000000000000039a <forktest>:
{
     39a:	7179                	addi	sp,sp,-48
     39c:	f406                	sd	ra,40(sp)
     39e:	f022                	sd	s0,32(sp)
     3a0:	ec26                	sd	s1,24(sp)
     3a2:	e84a                	sd	s2,16(sp)
     3a4:	e44e                	sd	s3,8(sp)
     3a6:	1800                	addi	s0,sp,48
     3a8:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
     3aa:	4481                	li	s1,0
     3ac:	3e800913          	li	s2,1000
    pid = fork();
     3b0:	00005097          	auipc	ra,0x5
     3b4:	432080e7          	jalr	1074(ra) # 57e2 <fork>
    if(pid < 0)
     3b8:	02054863          	bltz	a0,3e8 <forktest+0x4e>
    if(pid == 0)
     3bc:	c115                	beqz	a0,3e0 <forktest+0x46>
  for(n=0; n<N; n++){
     3be:	2485                	addiw	s1,s1,1
     3c0:	ff2498e3          	bne	s1,s2,3b0 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
     3c4:	85ce                	mv	a1,s3
     3c6:	00006517          	auipc	a0,0x6
     3ca:	c7a50513          	addi	a0,a0,-902 # 6040 <malloc+0x408>
     3ce:	00005097          	auipc	ra,0x5
     3d2:	7ac080e7          	jalr	1964(ra) # 5b7a <printf>
    exit(1);
     3d6:	4505                	li	a0,1
     3d8:	00005097          	auipc	ra,0x5
     3dc:	412080e7          	jalr	1042(ra) # 57ea <exit>
      exit(0);
     3e0:	00005097          	auipc	ra,0x5
     3e4:	40a080e7          	jalr	1034(ra) # 57ea <exit>
  if (n == 0) {
     3e8:	cc9d                	beqz	s1,426 <forktest+0x8c>
  if(n == N){
     3ea:	3e800793          	li	a5,1000
     3ee:	fcf48be3          	beq	s1,a5,3c4 <forktest+0x2a>
  for(; n > 0; n--){
     3f2:	00905b63          	blez	s1,408 <forktest+0x6e>
    if(wait(0) < 0){
     3f6:	4501                	li	a0,0
     3f8:	00005097          	auipc	ra,0x5
     3fc:	3fa080e7          	jalr	1018(ra) # 57f2 <wait>
     400:	04054163          	bltz	a0,442 <forktest+0xa8>
  for(; n > 0; n--){
     404:	34fd                	addiw	s1,s1,-1
     406:	f8e5                	bnez	s1,3f6 <forktest+0x5c>
  if(wait(0) != -1){
     408:	4501                	li	a0,0
     40a:	00005097          	auipc	ra,0x5
     40e:	3e8080e7          	jalr	1000(ra) # 57f2 <wait>
     412:	57fd                	li	a5,-1
     414:	04f51563          	bne	a0,a5,45e <forktest+0xc4>
}
     418:	70a2                	ld	ra,40(sp)
     41a:	7402                	ld	s0,32(sp)
     41c:	64e2                	ld	s1,24(sp)
     41e:	6942                	ld	s2,16(sp)
     420:	69a2                	ld	s3,8(sp)
     422:	6145                	addi	sp,sp,48
     424:	8082                	ret
    printf("%s: no fork at all!\n", s);
     426:	85ce                	mv	a1,s3
     428:	00006517          	auipc	a0,0x6
     42c:	c0050513          	addi	a0,a0,-1024 # 6028 <malloc+0x3f0>
     430:	00005097          	auipc	ra,0x5
     434:	74a080e7          	jalr	1866(ra) # 5b7a <printf>
    exit(1);
     438:	4505                	li	a0,1
     43a:	00005097          	auipc	ra,0x5
     43e:	3b0080e7          	jalr	944(ra) # 57ea <exit>
      printf("%s: wait stopped early\n", s);
     442:	85ce                	mv	a1,s3
     444:	00006517          	auipc	a0,0x6
     448:	c2450513          	addi	a0,a0,-988 # 6068 <malloc+0x430>
     44c:	00005097          	auipc	ra,0x5
     450:	72e080e7          	jalr	1838(ra) # 5b7a <printf>
      exit(1);
     454:	4505                	li	a0,1
     456:	00005097          	auipc	ra,0x5
     45a:	394080e7          	jalr	916(ra) # 57ea <exit>
    printf("%s: wait got too many\n", s);
     45e:	85ce                	mv	a1,s3
     460:	00006517          	auipc	a0,0x6
     464:	c2050513          	addi	a0,a0,-992 # 6080 <malloc+0x448>
     468:	00005097          	auipc	ra,0x5
     46c:	712080e7          	jalr	1810(ra) # 5b7a <printf>
    exit(1);
     470:	4505                	li	a0,1
     472:	00005097          	auipc	ra,0x5
     476:	378080e7          	jalr	888(ra) # 57ea <exit>

000000000000047a <copyinstr1>:
{
     47a:	1141                	addi	sp,sp,-16
     47c:	e406                	sd	ra,8(sp)
     47e:	e022                	sd	s0,0(sp)
     480:	0800                	addi	s0,sp,16
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
     482:	20100593          	li	a1,513
     486:	4505                	li	a0,1
     488:	057e                	slli	a0,a0,0x1f
     48a:	00005097          	auipc	ra,0x5
     48e:	3a0080e7          	jalr	928(ra) # 582a <open>
    if(fd >= 0){
     492:	02055063          	bgez	a0,4b2 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
     496:	20100593          	li	a1,513
     49a:	557d                	li	a0,-1
     49c:	00005097          	auipc	ra,0x5
     4a0:	38e080e7          	jalr	910(ra) # 582a <open>
    uint64 addr = addrs[ai];
     4a4:	55fd                	li	a1,-1
    if(fd >= 0){
     4a6:	00055863          	bgez	a0,4b6 <copyinstr1+0x3c>
}
     4aa:	60a2                	ld	ra,8(sp)
     4ac:	6402                	ld	s0,0(sp)
     4ae:	0141                	addi	sp,sp,16
     4b0:	8082                	ret
    uint64 addr = addrs[ai];
     4b2:	4585                	li	a1,1
     4b4:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
     4b6:	862a                	mv	a2,a0
     4b8:	00006517          	auipc	a0,0x6
     4bc:	be050513          	addi	a0,a0,-1056 # 6098 <malloc+0x460>
     4c0:	00005097          	auipc	ra,0x5
     4c4:	6ba080e7          	jalr	1722(ra) # 5b7a <printf>
      exit(1);
     4c8:	4505                	li	a0,1
     4ca:	00005097          	auipc	ra,0x5
     4ce:	320080e7          	jalr	800(ra) # 57ea <exit>

00000000000004d2 <opentest>:
{
     4d2:	1101                	addi	sp,sp,-32
     4d4:	ec06                	sd	ra,24(sp)
     4d6:	e822                	sd	s0,16(sp)
     4d8:	e426                	sd	s1,8(sp)
     4da:	1000                	addi	s0,sp,32
     4dc:	84aa                	mv	s1,a0
  fd = open("echo", 0);
     4de:	4581                	li	a1,0
     4e0:	00006517          	auipc	a0,0x6
     4e4:	bd850513          	addi	a0,a0,-1064 # 60b8 <malloc+0x480>
     4e8:	00005097          	auipc	ra,0x5
     4ec:	342080e7          	jalr	834(ra) # 582a <open>
  if(fd < 0){
     4f0:	02054663          	bltz	a0,51c <opentest+0x4a>
  close(fd);
     4f4:	00005097          	auipc	ra,0x5
     4f8:	31e080e7          	jalr	798(ra) # 5812 <close>
  fd = open("doesnotexist", 0);
     4fc:	4581                	li	a1,0
     4fe:	00006517          	auipc	a0,0x6
     502:	bda50513          	addi	a0,a0,-1062 # 60d8 <malloc+0x4a0>
     506:	00005097          	auipc	ra,0x5
     50a:	324080e7          	jalr	804(ra) # 582a <open>
  if(fd >= 0){
     50e:	02055563          	bgez	a0,538 <opentest+0x66>
}
     512:	60e2                	ld	ra,24(sp)
     514:	6442                	ld	s0,16(sp)
     516:	64a2                	ld	s1,8(sp)
     518:	6105                	addi	sp,sp,32
     51a:	8082                	ret
    printf("%s: open echo failed!\n", s);
     51c:	85a6                	mv	a1,s1
     51e:	00006517          	auipc	a0,0x6
     522:	ba250513          	addi	a0,a0,-1118 # 60c0 <malloc+0x488>
     526:	00005097          	auipc	ra,0x5
     52a:	654080e7          	jalr	1620(ra) # 5b7a <printf>
    exit(1);
     52e:	4505                	li	a0,1
     530:	00005097          	auipc	ra,0x5
     534:	2ba080e7          	jalr	698(ra) # 57ea <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     538:	85a6                	mv	a1,s1
     53a:	00006517          	auipc	a0,0x6
     53e:	bae50513          	addi	a0,a0,-1106 # 60e8 <malloc+0x4b0>
     542:	00005097          	auipc	ra,0x5
     546:	638080e7          	jalr	1592(ra) # 5b7a <printf>
    exit(1);
     54a:	4505                	li	a0,1
     54c:	00005097          	auipc	ra,0x5
     550:	29e080e7          	jalr	670(ra) # 57ea <exit>

0000000000000554 <truncate2>:
{
     554:	7179                	addi	sp,sp,-48
     556:	f406                	sd	ra,40(sp)
     558:	f022                	sd	s0,32(sp)
     55a:	ec26                	sd	s1,24(sp)
     55c:	e84a                	sd	s2,16(sp)
     55e:	e44e                	sd	s3,8(sp)
     560:	1800                	addi	s0,sp,48
     562:	89aa                	mv	s3,a0
  unlink("truncfile");
     564:	00006517          	auipc	a0,0x6
     568:	bac50513          	addi	a0,a0,-1108 # 6110 <malloc+0x4d8>
     56c:	00005097          	auipc	ra,0x5
     570:	2ce080e7          	jalr	718(ra) # 583a <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     574:	60100593          	li	a1,1537
     578:	00006517          	auipc	a0,0x6
     57c:	b9850513          	addi	a0,a0,-1128 # 6110 <malloc+0x4d8>
     580:	00005097          	auipc	ra,0x5
     584:	2aa080e7          	jalr	682(ra) # 582a <open>
     588:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     58a:	4611                	li	a2,4
     58c:	00006597          	auipc	a1,0x6
     590:	b9458593          	addi	a1,a1,-1132 # 6120 <malloc+0x4e8>
     594:	00005097          	auipc	ra,0x5
     598:	276080e7          	jalr	630(ra) # 580a <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     59c:	40100593          	li	a1,1025
     5a0:	00006517          	auipc	a0,0x6
     5a4:	b7050513          	addi	a0,a0,-1168 # 6110 <malloc+0x4d8>
     5a8:	00005097          	auipc	ra,0x5
     5ac:	282080e7          	jalr	642(ra) # 582a <open>
     5b0:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     5b2:	4605                	li	a2,1
     5b4:	00006597          	auipc	a1,0x6
     5b8:	b7458593          	addi	a1,a1,-1164 # 6128 <malloc+0x4f0>
     5bc:	8526                	mv	a0,s1
     5be:	00005097          	auipc	ra,0x5
     5c2:	24c080e7          	jalr	588(ra) # 580a <write>
  if(n != -1){
     5c6:	57fd                	li	a5,-1
     5c8:	02f51b63          	bne	a0,a5,5fe <truncate2+0xaa>
  unlink("truncfile");
     5cc:	00006517          	auipc	a0,0x6
     5d0:	b4450513          	addi	a0,a0,-1212 # 6110 <malloc+0x4d8>
     5d4:	00005097          	auipc	ra,0x5
     5d8:	266080e7          	jalr	614(ra) # 583a <unlink>
  close(fd1);
     5dc:	8526                	mv	a0,s1
     5de:	00005097          	auipc	ra,0x5
     5e2:	234080e7          	jalr	564(ra) # 5812 <close>
  close(fd2);
     5e6:	854a                	mv	a0,s2
     5e8:	00005097          	auipc	ra,0x5
     5ec:	22a080e7          	jalr	554(ra) # 5812 <close>
}
     5f0:	70a2                	ld	ra,40(sp)
     5f2:	7402                	ld	s0,32(sp)
     5f4:	64e2                	ld	s1,24(sp)
     5f6:	6942                	ld	s2,16(sp)
     5f8:	69a2                	ld	s3,8(sp)
     5fa:	6145                	addi	sp,sp,48
     5fc:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     5fe:	862a                	mv	a2,a0
     600:	85ce                	mv	a1,s3
     602:	00006517          	auipc	a0,0x6
     606:	b2e50513          	addi	a0,a0,-1234 # 6130 <malloc+0x4f8>
     60a:	00005097          	auipc	ra,0x5
     60e:	570080e7          	jalr	1392(ra) # 5b7a <printf>
    exit(1);
     612:	4505                	li	a0,1
     614:	00005097          	auipc	ra,0x5
     618:	1d6080e7          	jalr	470(ra) # 57ea <exit>

000000000000061c <forkforkfork>:
{
     61c:	1101                	addi	sp,sp,-32
     61e:	ec06                	sd	ra,24(sp)
     620:	e822                	sd	s0,16(sp)
     622:	e426                	sd	s1,8(sp)
     624:	1000                	addi	s0,sp,32
     626:	84aa                	mv	s1,a0
  unlink("stopforking");
     628:	00006517          	auipc	a0,0x6
     62c:	b3050513          	addi	a0,a0,-1232 # 6158 <malloc+0x520>
     630:	00005097          	auipc	ra,0x5
     634:	20a080e7          	jalr	522(ra) # 583a <unlink>
  int pid = fork();
     638:	00005097          	auipc	ra,0x5
     63c:	1aa080e7          	jalr	426(ra) # 57e2 <fork>
  if(pid < 0){
     640:	04054563          	bltz	a0,68a <forkforkfork+0x6e>
  if(pid == 0){
     644:	c12d                	beqz	a0,6a6 <forkforkfork+0x8a>
  sleep(20); // two seconds
     646:	4551                	li	a0,20
     648:	00005097          	auipc	ra,0x5
     64c:	232080e7          	jalr	562(ra) # 587a <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
     650:	20200593          	li	a1,514
     654:	00006517          	auipc	a0,0x6
     658:	b0450513          	addi	a0,a0,-1276 # 6158 <malloc+0x520>
     65c:	00005097          	auipc	ra,0x5
     660:	1ce080e7          	jalr	462(ra) # 582a <open>
     664:	00005097          	auipc	ra,0x5
     668:	1ae080e7          	jalr	430(ra) # 5812 <close>
  wait(0);
     66c:	4501                	li	a0,0
     66e:	00005097          	auipc	ra,0x5
     672:	184080e7          	jalr	388(ra) # 57f2 <wait>
  sleep(10); // one second
     676:	4529                	li	a0,10
     678:	00005097          	auipc	ra,0x5
     67c:	202080e7          	jalr	514(ra) # 587a <sleep>
}
     680:	60e2                	ld	ra,24(sp)
     682:	6442                	ld	s0,16(sp)
     684:	64a2                	ld	s1,8(sp)
     686:	6105                	addi	sp,sp,32
     688:	8082                	ret
    printf("%s: fork failed", s);
     68a:	85a6                	mv	a1,s1
     68c:	00006517          	auipc	a0,0x6
     690:	96c50513          	addi	a0,a0,-1684 # 5ff8 <malloc+0x3c0>
     694:	00005097          	auipc	ra,0x5
     698:	4e6080e7          	jalr	1254(ra) # 5b7a <printf>
    exit(1);
     69c:	4505                	li	a0,1
     69e:	00005097          	auipc	ra,0x5
     6a2:	14c080e7          	jalr	332(ra) # 57ea <exit>
      int fd = open("stopforking", 0);
     6a6:	00006497          	auipc	s1,0x6
     6aa:	ab248493          	addi	s1,s1,-1358 # 6158 <malloc+0x520>
     6ae:	4581                	li	a1,0
     6b0:	8526                	mv	a0,s1
     6b2:	00005097          	auipc	ra,0x5
     6b6:	178080e7          	jalr	376(ra) # 582a <open>
      if(fd >= 0){
     6ba:	02055463          	bgez	a0,6e2 <forkforkfork+0xc6>
      if(fork() < 0){
     6be:	00005097          	auipc	ra,0x5
     6c2:	124080e7          	jalr	292(ra) # 57e2 <fork>
     6c6:	fe0554e3          	bgez	a0,6ae <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
     6ca:	20200593          	li	a1,514
     6ce:	8526                	mv	a0,s1
     6d0:	00005097          	auipc	ra,0x5
     6d4:	15a080e7          	jalr	346(ra) # 582a <open>
     6d8:	00005097          	auipc	ra,0x5
     6dc:	13a080e7          	jalr	314(ra) # 5812 <close>
     6e0:	b7f9                	j	6ae <forkforkfork+0x92>
        exit(0);
     6e2:	4501                	li	a0,0
     6e4:	00005097          	auipc	ra,0x5
     6e8:	106080e7          	jalr	262(ra) # 57ea <exit>

00000000000006ec <bigwrite>:
{
     6ec:	715d                	addi	sp,sp,-80
     6ee:	e486                	sd	ra,72(sp)
     6f0:	e0a2                	sd	s0,64(sp)
     6f2:	fc26                	sd	s1,56(sp)
     6f4:	f84a                	sd	s2,48(sp)
     6f6:	f44e                	sd	s3,40(sp)
     6f8:	f052                	sd	s4,32(sp)
     6fa:	ec56                	sd	s5,24(sp)
     6fc:	e85a                	sd	s6,16(sp)
     6fe:	e45e                	sd	s7,8(sp)
     700:	0880                	addi	s0,sp,80
     702:	8baa                	mv	s7,a0
  unlink("bigwrite");
     704:	00005517          	auipc	a0,0x5
     708:	77450513          	addi	a0,a0,1908 # 5e78 <malloc+0x240>
     70c:	00005097          	auipc	ra,0x5
     710:	12e080e7          	jalr	302(ra) # 583a <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     714:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     718:	00005a97          	auipc	s5,0x5
     71c:	760a8a93          	addi	s5,s5,1888 # 5e78 <malloc+0x240>
      int cc = write(fd, buf, sz);
     720:	0000ba17          	auipc	s4,0xb
     724:	3c8a0a13          	addi	s4,s4,968 # bae8 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     728:	6b0d                	lui	s6,0x3
     72a:	1c9b0b13          	addi	s6,s6,457 # 31c9 <bigfile+0x5d>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     72e:	20200593          	li	a1,514
     732:	8556                	mv	a0,s5
     734:	00005097          	auipc	ra,0x5
     738:	0f6080e7          	jalr	246(ra) # 582a <open>
     73c:	892a                	mv	s2,a0
    if(fd < 0){
     73e:	04054d63          	bltz	a0,798 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     742:	8626                	mv	a2,s1
     744:	85d2                	mv	a1,s4
     746:	00005097          	auipc	ra,0x5
     74a:	0c4080e7          	jalr	196(ra) # 580a <write>
     74e:	89aa                	mv	s3,a0
      if(cc != sz){
     750:	06a49463          	bne	s1,a0,7b8 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     754:	8626                	mv	a2,s1
     756:	85d2                	mv	a1,s4
     758:	854a                	mv	a0,s2
     75a:	00005097          	auipc	ra,0x5
     75e:	0b0080e7          	jalr	176(ra) # 580a <write>
      if(cc != sz){
     762:	04951963          	bne	a0,s1,7b4 <bigwrite+0xc8>
    close(fd);
     766:	854a                	mv	a0,s2
     768:	00005097          	auipc	ra,0x5
     76c:	0aa080e7          	jalr	170(ra) # 5812 <close>
    unlink("bigwrite");
     770:	8556                	mv	a0,s5
     772:	00005097          	auipc	ra,0x5
     776:	0c8080e7          	jalr	200(ra) # 583a <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     77a:	1d74849b          	addiw	s1,s1,471
     77e:	fb6498e3          	bne	s1,s6,72e <bigwrite+0x42>
}
     782:	60a6                	ld	ra,72(sp)
     784:	6406                	ld	s0,64(sp)
     786:	74e2                	ld	s1,56(sp)
     788:	7942                	ld	s2,48(sp)
     78a:	79a2                	ld	s3,40(sp)
     78c:	7a02                	ld	s4,32(sp)
     78e:	6ae2                	ld	s5,24(sp)
     790:	6b42                	ld	s6,16(sp)
     792:	6ba2                	ld	s7,8(sp)
     794:	6161                	addi	sp,sp,80
     796:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     798:	85de                	mv	a1,s7
     79a:	00006517          	auipc	a0,0x6
     79e:	9ce50513          	addi	a0,a0,-1586 # 6168 <malloc+0x530>
     7a2:	00005097          	auipc	ra,0x5
     7a6:	3d8080e7          	jalr	984(ra) # 5b7a <printf>
      exit(1);
     7aa:	4505                	li	a0,1
     7ac:	00005097          	auipc	ra,0x5
     7b0:	03e080e7          	jalr	62(ra) # 57ea <exit>
     7b4:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     7b6:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     7b8:	86ce                	mv	a3,s3
     7ba:	8626                	mv	a2,s1
     7bc:	85de                	mv	a1,s7
     7be:	00006517          	auipc	a0,0x6
     7c2:	9ca50513          	addi	a0,a0,-1590 # 6188 <malloc+0x550>
     7c6:	00005097          	auipc	ra,0x5
     7ca:	3b4080e7          	jalr	948(ra) # 5b7a <printf>
        exit(1);
     7ce:	4505                	li	a0,1
     7d0:	00005097          	auipc	ra,0x5
     7d4:	01a080e7          	jalr	26(ra) # 57ea <exit>

00000000000007d8 <copyin>:
{
     7d8:	715d                	addi	sp,sp,-80
     7da:	e486                	sd	ra,72(sp)
     7dc:	e0a2                	sd	s0,64(sp)
     7de:	fc26                	sd	s1,56(sp)
     7e0:	f84a                	sd	s2,48(sp)
     7e2:	f44e                	sd	s3,40(sp)
     7e4:	f052                	sd	s4,32(sp)
     7e6:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     7e8:	4785                	li	a5,1
     7ea:	07fe                	slli	a5,a5,0x1f
     7ec:	fcf43023          	sd	a5,-64(s0)
     7f0:	57fd                	li	a5,-1
     7f2:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     7f6:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     7fa:	00006a17          	auipc	s4,0x6
     7fe:	9a6a0a13          	addi	s4,s4,-1626 # 61a0 <malloc+0x568>
    uint64 addr = addrs[ai];
     802:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     806:	20100593          	li	a1,513
     80a:	8552                	mv	a0,s4
     80c:	00005097          	auipc	ra,0x5
     810:	01e080e7          	jalr	30(ra) # 582a <open>
     814:	84aa                	mv	s1,a0
    if(fd < 0){
     816:	08054863          	bltz	a0,8a6 <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     81a:	6609                	lui	a2,0x2
     81c:	85ce                	mv	a1,s3
     81e:	00005097          	auipc	ra,0x5
     822:	fec080e7          	jalr	-20(ra) # 580a <write>
    if(n >= 0){
     826:	08055d63          	bgez	a0,8c0 <copyin+0xe8>
    close(fd);
     82a:	8526                	mv	a0,s1
     82c:	00005097          	auipc	ra,0x5
     830:	fe6080e7          	jalr	-26(ra) # 5812 <close>
    unlink("copyin1");
     834:	8552                	mv	a0,s4
     836:	00005097          	auipc	ra,0x5
     83a:	004080e7          	jalr	4(ra) # 583a <unlink>
    n = write(1, (char*)addr, 8192);
     83e:	6609                	lui	a2,0x2
     840:	85ce                	mv	a1,s3
     842:	4505                	li	a0,1
     844:	00005097          	auipc	ra,0x5
     848:	fc6080e7          	jalr	-58(ra) # 580a <write>
    if(n > 0){
     84c:	08a04963          	bgtz	a0,8de <copyin+0x106>
    if(pipe(fds) < 0){
     850:	fb840513          	addi	a0,s0,-72
     854:	00005097          	auipc	ra,0x5
     858:	fa6080e7          	jalr	-90(ra) # 57fa <pipe>
     85c:	0a054063          	bltz	a0,8fc <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     860:	6609                	lui	a2,0x2
     862:	85ce                	mv	a1,s3
     864:	fbc42503          	lw	a0,-68(s0)
     868:	00005097          	auipc	ra,0x5
     86c:	fa2080e7          	jalr	-94(ra) # 580a <write>
    if(n > 0){
     870:	0aa04363          	bgtz	a0,916 <copyin+0x13e>
    close(fds[0]);
     874:	fb842503          	lw	a0,-72(s0)
     878:	00005097          	auipc	ra,0x5
     87c:	f9a080e7          	jalr	-102(ra) # 5812 <close>
    close(fds[1]);
     880:	fbc42503          	lw	a0,-68(s0)
     884:	00005097          	auipc	ra,0x5
     888:	f8e080e7          	jalr	-114(ra) # 5812 <close>
  for(int ai = 0; ai < 2; ai++){
     88c:	0921                	addi	s2,s2,8
     88e:	fd040793          	addi	a5,s0,-48
     892:	f6f918e3          	bne	s2,a5,802 <copyin+0x2a>
}
     896:	60a6                	ld	ra,72(sp)
     898:	6406                	ld	s0,64(sp)
     89a:	74e2                	ld	s1,56(sp)
     89c:	7942                	ld	s2,48(sp)
     89e:	79a2                	ld	s3,40(sp)
     8a0:	7a02                	ld	s4,32(sp)
     8a2:	6161                	addi	sp,sp,80
     8a4:	8082                	ret
      printf("open(copyin1) failed\n");
     8a6:	00006517          	auipc	a0,0x6
     8aa:	90250513          	addi	a0,a0,-1790 # 61a8 <malloc+0x570>
     8ae:	00005097          	auipc	ra,0x5
     8b2:	2cc080e7          	jalr	716(ra) # 5b7a <printf>
      exit(1);
     8b6:	4505                	li	a0,1
     8b8:	00005097          	auipc	ra,0x5
     8bc:	f32080e7          	jalr	-206(ra) # 57ea <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     8c0:	862a                	mv	a2,a0
     8c2:	85ce                	mv	a1,s3
     8c4:	00006517          	auipc	a0,0x6
     8c8:	8fc50513          	addi	a0,a0,-1796 # 61c0 <malloc+0x588>
     8cc:	00005097          	auipc	ra,0x5
     8d0:	2ae080e7          	jalr	686(ra) # 5b7a <printf>
      exit(1);
     8d4:	4505                	li	a0,1
     8d6:	00005097          	auipc	ra,0x5
     8da:	f14080e7          	jalr	-236(ra) # 57ea <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     8de:	862a                	mv	a2,a0
     8e0:	85ce                	mv	a1,s3
     8e2:	00006517          	auipc	a0,0x6
     8e6:	90e50513          	addi	a0,a0,-1778 # 61f0 <malloc+0x5b8>
     8ea:	00005097          	auipc	ra,0x5
     8ee:	290080e7          	jalr	656(ra) # 5b7a <printf>
      exit(1);
     8f2:	4505                	li	a0,1
     8f4:	00005097          	auipc	ra,0x5
     8f8:	ef6080e7          	jalr	-266(ra) # 57ea <exit>
      printf("pipe() failed\n");
     8fc:	00006517          	auipc	a0,0x6
     900:	92450513          	addi	a0,a0,-1756 # 6220 <malloc+0x5e8>
     904:	00005097          	auipc	ra,0x5
     908:	276080e7          	jalr	630(ra) # 5b7a <printf>
      exit(1);
     90c:	4505                	li	a0,1
     90e:	00005097          	auipc	ra,0x5
     912:	edc080e7          	jalr	-292(ra) # 57ea <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     916:	862a                	mv	a2,a0
     918:	85ce                	mv	a1,s3
     91a:	00006517          	auipc	a0,0x6
     91e:	91650513          	addi	a0,a0,-1770 # 6230 <malloc+0x5f8>
     922:	00005097          	auipc	ra,0x5
     926:	258080e7          	jalr	600(ra) # 5b7a <printf>
      exit(1);
     92a:	4505                	li	a0,1
     92c:	00005097          	auipc	ra,0x5
     930:	ebe080e7          	jalr	-322(ra) # 57ea <exit>

0000000000000934 <copyout>:
{
     934:	711d                	addi	sp,sp,-96
     936:	ec86                	sd	ra,88(sp)
     938:	e8a2                	sd	s0,80(sp)
     93a:	e4a6                	sd	s1,72(sp)
     93c:	e0ca                	sd	s2,64(sp)
     93e:	fc4e                	sd	s3,56(sp)
     940:	f852                	sd	s4,48(sp)
     942:	f456                	sd	s5,40(sp)
     944:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     946:	4785                	li	a5,1
     948:	07fe                	slli	a5,a5,0x1f
     94a:	faf43823          	sd	a5,-80(s0)
     94e:	57fd                	li	a5,-1
     950:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     954:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     958:	00006a17          	auipc	s4,0x6
     95c:	908a0a13          	addi	s4,s4,-1784 # 6260 <malloc+0x628>
    n = write(fds[1], "x", 1);
     960:	00005a97          	auipc	s5,0x5
     964:	7c8a8a93          	addi	s5,s5,1992 # 6128 <malloc+0x4f0>
    uint64 addr = addrs[ai];
     968:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     96c:	4581                	li	a1,0
     96e:	8552                	mv	a0,s4
     970:	00005097          	auipc	ra,0x5
     974:	eba080e7          	jalr	-326(ra) # 582a <open>
     978:	84aa                	mv	s1,a0
    if(fd < 0){
     97a:	08054663          	bltz	a0,a06 <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     97e:	6609                	lui	a2,0x2
     980:	85ce                	mv	a1,s3
     982:	00005097          	auipc	ra,0x5
     986:	e80080e7          	jalr	-384(ra) # 5802 <read>
    if(n > 0){
     98a:	08a04b63          	bgtz	a0,a20 <copyout+0xec>
    close(fd);
     98e:	8526                	mv	a0,s1
     990:	00005097          	auipc	ra,0x5
     994:	e82080e7          	jalr	-382(ra) # 5812 <close>
    if(pipe(fds) < 0){
     998:	fa840513          	addi	a0,s0,-88
     99c:	00005097          	auipc	ra,0x5
     9a0:	e5e080e7          	jalr	-418(ra) # 57fa <pipe>
     9a4:	08054d63          	bltz	a0,a3e <copyout+0x10a>
    n = write(fds[1], "x", 1);
     9a8:	4605                	li	a2,1
     9aa:	85d6                	mv	a1,s5
     9ac:	fac42503          	lw	a0,-84(s0)
     9b0:	00005097          	auipc	ra,0x5
     9b4:	e5a080e7          	jalr	-422(ra) # 580a <write>
    if(n != 1){
     9b8:	4785                	li	a5,1
     9ba:	08f51f63          	bne	a0,a5,a58 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     9be:	6609                	lui	a2,0x2
     9c0:	85ce                	mv	a1,s3
     9c2:	fa842503          	lw	a0,-88(s0)
     9c6:	00005097          	auipc	ra,0x5
     9ca:	e3c080e7          	jalr	-452(ra) # 5802 <read>
    if(n > 0){
     9ce:	0aa04263          	bgtz	a0,a72 <copyout+0x13e>
    close(fds[0]);
     9d2:	fa842503          	lw	a0,-88(s0)
     9d6:	00005097          	auipc	ra,0x5
     9da:	e3c080e7          	jalr	-452(ra) # 5812 <close>
    close(fds[1]);
     9de:	fac42503          	lw	a0,-84(s0)
     9e2:	00005097          	auipc	ra,0x5
     9e6:	e30080e7          	jalr	-464(ra) # 5812 <close>
  for(int ai = 0; ai < 2; ai++){
     9ea:	0921                	addi	s2,s2,8
     9ec:	fc040793          	addi	a5,s0,-64
     9f0:	f6f91ce3          	bne	s2,a5,968 <copyout+0x34>
}
     9f4:	60e6                	ld	ra,88(sp)
     9f6:	6446                	ld	s0,80(sp)
     9f8:	64a6                	ld	s1,72(sp)
     9fa:	6906                	ld	s2,64(sp)
     9fc:	79e2                	ld	s3,56(sp)
     9fe:	7a42                	ld	s4,48(sp)
     a00:	7aa2                	ld	s5,40(sp)
     a02:	6125                	addi	sp,sp,96
     a04:	8082                	ret
      printf("open(README) failed\n");
     a06:	00006517          	auipc	a0,0x6
     a0a:	86250513          	addi	a0,a0,-1950 # 6268 <malloc+0x630>
     a0e:	00005097          	auipc	ra,0x5
     a12:	16c080e7          	jalr	364(ra) # 5b7a <printf>
      exit(1);
     a16:	4505                	li	a0,1
     a18:	00005097          	auipc	ra,0x5
     a1c:	dd2080e7          	jalr	-558(ra) # 57ea <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     a20:	862a                	mv	a2,a0
     a22:	85ce                	mv	a1,s3
     a24:	00006517          	auipc	a0,0x6
     a28:	85c50513          	addi	a0,a0,-1956 # 6280 <malloc+0x648>
     a2c:	00005097          	auipc	ra,0x5
     a30:	14e080e7          	jalr	334(ra) # 5b7a <printf>
      exit(1);
     a34:	4505                	li	a0,1
     a36:	00005097          	auipc	ra,0x5
     a3a:	db4080e7          	jalr	-588(ra) # 57ea <exit>
      printf("pipe() failed\n");
     a3e:	00005517          	auipc	a0,0x5
     a42:	7e250513          	addi	a0,a0,2018 # 6220 <malloc+0x5e8>
     a46:	00005097          	auipc	ra,0x5
     a4a:	134080e7          	jalr	308(ra) # 5b7a <printf>
      exit(1);
     a4e:	4505                	li	a0,1
     a50:	00005097          	auipc	ra,0x5
     a54:	d9a080e7          	jalr	-614(ra) # 57ea <exit>
      printf("pipe write failed\n");
     a58:	00006517          	auipc	a0,0x6
     a5c:	85850513          	addi	a0,a0,-1960 # 62b0 <malloc+0x678>
     a60:	00005097          	auipc	ra,0x5
     a64:	11a080e7          	jalr	282(ra) # 5b7a <printf>
      exit(1);
     a68:	4505                	li	a0,1
     a6a:	00005097          	auipc	ra,0x5
     a6e:	d80080e7          	jalr	-640(ra) # 57ea <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     a72:	862a                	mv	a2,a0
     a74:	85ce                	mv	a1,s3
     a76:	00006517          	auipc	a0,0x6
     a7a:	85250513          	addi	a0,a0,-1966 # 62c8 <malloc+0x690>
     a7e:	00005097          	auipc	ra,0x5
     a82:	0fc080e7          	jalr	252(ra) # 5b7a <printf>
      exit(1);
     a86:	4505                	li	a0,1
     a88:	00005097          	auipc	ra,0x5
     a8c:	d62080e7          	jalr	-670(ra) # 57ea <exit>

0000000000000a90 <truncate1>:
{
     a90:	711d                	addi	sp,sp,-96
     a92:	ec86                	sd	ra,88(sp)
     a94:	e8a2                	sd	s0,80(sp)
     a96:	e4a6                	sd	s1,72(sp)
     a98:	e0ca                	sd	s2,64(sp)
     a9a:	fc4e                	sd	s3,56(sp)
     a9c:	f852                	sd	s4,48(sp)
     a9e:	f456                	sd	s5,40(sp)
     aa0:	1080                	addi	s0,sp,96
     aa2:	8aaa                	mv	s5,a0
  unlink("truncfile");
     aa4:	00005517          	auipc	a0,0x5
     aa8:	66c50513          	addi	a0,a0,1644 # 6110 <malloc+0x4d8>
     aac:	00005097          	auipc	ra,0x5
     ab0:	d8e080e7          	jalr	-626(ra) # 583a <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     ab4:	60100593          	li	a1,1537
     ab8:	00005517          	auipc	a0,0x5
     abc:	65850513          	addi	a0,a0,1624 # 6110 <malloc+0x4d8>
     ac0:	00005097          	auipc	ra,0x5
     ac4:	d6a080e7          	jalr	-662(ra) # 582a <open>
     ac8:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     aca:	4611                	li	a2,4
     acc:	00005597          	auipc	a1,0x5
     ad0:	65458593          	addi	a1,a1,1620 # 6120 <malloc+0x4e8>
     ad4:	00005097          	auipc	ra,0x5
     ad8:	d36080e7          	jalr	-714(ra) # 580a <write>
  close(fd1);
     adc:	8526                	mv	a0,s1
     ade:	00005097          	auipc	ra,0x5
     ae2:	d34080e7          	jalr	-716(ra) # 5812 <close>
  int fd2 = open("truncfile", O_RDONLY);
     ae6:	4581                	li	a1,0
     ae8:	00005517          	auipc	a0,0x5
     aec:	62850513          	addi	a0,a0,1576 # 6110 <malloc+0x4d8>
     af0:	00005097          	auipc	ra,0x5
     af4:	d3a080e7          	jalr	-710(ra) # 582a <open>
     af8:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     afa:	02000613          	li	a2,32
     afe:	fa040593          	addi	a1,s0,-96
     b02:	00005097          	auipc	ra,0x5
     b06:	d00080e7          	jalr	-768(ra) # 5802 <read>
  if(n != 4){
     b0a:	4791                	li	a5,4
     b0c:	0cf51e63          	bne	a0,a5,be8 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     b10:	40100593          	li	a1,1025
     b14:	00005517          	auipc	a0,0x5
     b18:	5fc50513          	addi	a0,a0,1532 # 6110 <malloc+0x4d8>
     b1c:	00005097          	auipc	ra,0x5
     b20:	d0e080e7          	jalr	-754(ra) # 582a <open>
     b24:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     b26:	4581                	li	a1,0
     b28:	00005517          	auipc	a0,0x5
     b2c:	5e850513          	addi	a0,a0,1512 # 6110 <malloc+0x4d8>
     b30:	00005097          	auipc	ra,0x5
     b34:	cfa080e7          	jalr	-774(ra) # 582a <open>
     b38:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     b3a:	02000613          	li	a2,32
     b3e:	fa040593          	addi	a1,s0,-96
     b42:	00005097          	auipc	ra,0x5
     b46:	cc0080e7          	jalr	-832(ra) # 5802 <read>
     b4a:	8a2a                	mv	s4,a0
  if(n != 0){
     b4c:	ed4d                	bnez	a0,c06 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     b4e:	02000613          	li	a2,32
     b52:	fa040593          	addi	a1,s0,-96
     b56:	8526                	mv	a0,s1
     b58:	00005097          	auipc	ra,0x5
     b5c:	caa080e7          	jalr	-854(ra) # 5802 <read>
     b60:	8a2a                	mv	s4,a0
  if(n != 0){
     b62:	e971                	bnez	a0,c36 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     b64:	4619                	li	a2,6
     b66:	00005597          	auipc	a1,0x5
     b6a:	7f258593          	addi	a1,a1,2034 # 6358 <malloc+0x720>
     b6e:	854e                	mv	a0,s3
     b70:	00005097          	auipc	ra,0x5
     b74:	c9a080e7          	jalr	-870(ra) # 580a <write>
  n = read(fd3, buf, sizeof(buf));
     b78:	02000613          	li	a2,32
     b7c:	fa040593          	addi	a1,s0,-96
     b80:	854a                	mv	a0,s2
     b82:	00005097          	auipc	ra,0x5
     b86:	c80080e7          	jalr	-896(ra) # 5802 <read>
  if(n != 6){
     b8a:	4799                	li	a5,6
     b8c:	0cf51d63          	bne	a0,a5,c66 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     b90:	02000613          	li	a2,32
     b94:	fa040593          	addi	a1,s0,-96
     b98:	8526                	mv	a0,s1
     b9a:	00005097          	auipc	ra,0x5
     b9e:	c68080e7          	jalr	-920(ra) # 5802 <read>
  if(n != 2){
     ba2:	4789                	li	a5,2
     ba4:	0ef51063          	bne	a0,a5,c84 <truncate1+0x1f4>
  unlink("truncfile");
     ba8:	00005517          	auipc	a0,0x5
     bac:	56850513          	addi	a0,a0,1384 # 6110 <malloc+0x4d8>
     bb0:	00005097          	auipc	ra,0x5
     bb4:	c8a080e7          	jalr	-886(ra) # 583a <unlink>
  close(fd1);
     bb8:	854e                	mv	a0,s3
     bba:	00005097          	auipc	ra,0x5
     bbe:	c58080e7          	jalr	-936(ra) # 5812 <close>
  close(fd2);
     bc2:	8526                	mv	a0,s1
     bc4:	00005097          	auipc	ra,0x5
     bc8:	c4e080e7          	jalr	-946(ra) # 5812 <close>
  close(fd3);
     bcc:	854a                	mv	a0,s2
     bce:	00005097          	auipc	ra,0x5
     bd2:	c44080e7          	jalr	-956(ra) # 5812 <close>
}
     bd6:	60e6                	ld	ra,88(sp)
     bd8:	6446                	ld	s0,80(sp)
     bda:	64a6                	ld	s1,72(sp)
     bdc:	6906                	ld	s2,64(sp)
     bde:	79e2                	ld	s3,56(sp)
     be0:	7a42                	ld	s4,48(sp)
     be2:	7aa2                	ld	s5,40(sp)
     be4:	6125                	addi	sp,sp,96
     be6:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     be8:	862a                	mv	a2,a0
     bea:	85d6                	mv	a1,s5
     bec:	00005517          	auipc	a0,0x5
     bf0:	70c50513          	addi	a0,a0,1804 # 62f8 <malloc+0x6c0>
     bf4:	00005097          	auipc	ra,0x5
     bf8:	f86080e7          	jalr	-122(ra) # 5b7a <printf>
    exit(1);
     bfc:	4505                	li	a0,1
     bfe:	00005097          	auipc	ra,0x5
     c02:	bec080e7          	jalr	-1044(ra) # 57ea <exit>
    printf("aaa fd3=%d\n", fd3);
     c06:	85ca                	mv	a1,s2
     c08:	00005517          	auipc	a0,0x5
     c0c:	71050513          	addi	a0,a0,1808 # 6318 <malloc+0x6e0>
     c10:	00005097          	auipc	ra,0x5
     c14:	f6a080e7          	jalr	-150(ra) # 5b7a <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     c18:	8652                	mv	a2,s4
     c1a:	85d6                	mv	a1,s5
     c1c:	00005517          	auipc	a0,0x5
     c20:	70c50513          	addi	a0,a0,1804 # 6328 <malloc+0x6f0>
     c24:	00005097          	auipc	ra,0x5
     c28:	f56080e7          	jalr	-170(ra) # 5b7a <printf>
    exit(1);
     c2c:	4505                	li	a0,1
     c2e:	00005097          	auipc	ra,0x5
     c32:	bbc080e7          	jalr	-1092(ra) # 57ea <exit>
    printf("bbb fd2=%d\n", fd2);
     c36:	85a6                	mv	a1,s1
     c38:	00005517          	auipc	a0,0x5
     c3c:	71050513          	addi	a0,a0,1808 # 6348 <malloc+0x710>
     c40:	00005097          	auipc	ra,0x5
     c44:	f3a080e7          	jalr	-198(ra) # 5b7a <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     c48:	8652                	mv	a2,s4
     c4a:	85d6                	mv	a1,s5
     c4c:	00005517          	auipc	a0,0x5
     c50:	6dc50513          	addi	a0,a0,1756 # 6328 <malloc+0x6f0>
     c54:	00005097          	auipc	ra,0x5
     c58:	f26080e7          	jalr	-218(ra) # 5b7a <printf>
    exit(1);
     c5c:	4505                	li	a0,1
     c5e:	00005097          	auipc	ra,0x5
     c62:	b8c080e7          	jalr	-1140(ra) # 57ea <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     c66:	862a                	mv	a2,a0
     c68:	85d6                	mv	a1,s5
     c6a:	00005517          	auipc	a0,0x5
     c6e:	6f650513          	addi	a0,a0,1782 # 6360 <malloc+0x728>
     c72:	00005097          	auipc	ra,0x5
     c76:	f08080e7          	jalr	-248(ra) # 5b7a <printf>
    exit(1);
     c7a:	4505                	li	a0,1
     c7c:	00005097          	auipc	ra,0x5
     c80:	b6e080e7          	jalr	-1170(ra) # 57ea <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     c84:	862a                	mv	a2,a0
     c86:	85d6                	mv	a1,s5
     c88:	00005517          	auipc	a0,0x5
     c8c:	6f850513          	addi	a0,a0,1784 # 6380 <malloc+0x748>
     c90:	00005097          	auipc	ra,0x5
     c94:	eea080e7          	jalr	-278(ra) # 5b7a <printf>
    exit(1);
     c98:	4505                	li	a0,1
     c9a:	00005097          	auipc	ra,0x5
     c9e:	b50080e7          	jalr	-1200(ra) # 57ea <exit>

0000000000000ca2 <pipe1>:
{
     ca2:	711d                	addi	sp,sp,-96
     ca4:	ec86                	sd	ra,88(sp)
     ca6:	e8a2                	sd	s0,80(sp)
     ca8:	e4a6                	sd	s1,72(sp)
     caa:	e0ca                	sd	s2,64(sp)
     cac:	fc4e                	sd	s3,56(sp)
     cae:	f852                	sd	s4,48(sp)
     cb0:	f456                	sd	s5,40(sp)
     cb2:	f05a                	sd	s6,32(sp)
     cb4:	ec5e                	sd	s7,24(sp)
     cb6:	1080                	addi	s0,sp,96
     cb8:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
     cba:	fa840513          	addi	a0,s0,-88
     cbe:	00005097          	auipc	ra,0x5
     cc2:	b3c080e7          	jalr	-1220(ra) # 57fa <pipe>
     cc6:	ed25                	bnez	a0,d3e <pipe1+0x9c>
     cc8:	84aa                	mv	s1,a0
  pid = fork();
     cca:	00005097          	auipc	ra,0x5
     cce:	b18080e7          	jalr	-1256(ra) # 57e2 <fork>
     cd2:	8a2a                	mv	s4,a0
  if(pid == 0){
     cd4:	c159                	beqz	a0,d5a <pipe1+0xb8>
  } else if(pid > 0){
     cd6:	16a05e63          	blez	a0,e52 <pipe1+0x1b0>
    close(fds[1]);
     cda:	fac42503          	lw	a0,-84(s0)
     cde:	00005097          	auipc	ra,0x5
     ce2:	b34080e7          	jalr	-1228(ra) # 5812 <close>
    total = 0;
     ce6:	8a26                	mv	s4,s1
    cc = 1;
     ce8:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
     cea:	0000ba97          	auipc	s5,0xb
     cee:	dfea8a93          	addi	s5,s5,-514 # bae8 <buf>
      if(cc > sizeof(buf))
     cf2:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
     cf4:	864e                	mv	a2,s3
     cf6:	85d6                	mv	a1,s5
     cf8:	fa842503          	lw	a0,-88(s0)
     cfc:	00005097          	auipc	ra,0x5
     d00:	b06080e7          	jalr	-1274(ra) # 5802 <read>
     d04:	10a05263          	blez	a0,e08 <pipe1+0x166>
      for(i = 0; i < n; i++){
     d08:	0000b717          	auipc	a4,0xb
     d0c:	de070713          	addi	a4,a4,-544 # bae8 <buf>
     d10:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     d14:	00074683          	lbu	a3,0(a4)
     d18:	0ff4f793          	andi	a5,s1,255
     d1c:	2485                	addiw	s1,s1,1
     d1e:	0cf69163          	bne	a3,a5,de0 <pipe1+0x13e>
      for(i = 0; i < n; i++){
     d22:	0705                	addi	a4,a4,1
     d24:	fec498e3          	bne	s1,a2,d14 <pipe1+0x72>
      total += n;
     d28:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
     d2c:	0019979b          	slliw	a5,s3,0x1
     d30:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
     d34:	013b7363          	bgeu	s6,s3,d3a <pipe1+0x98>
        cc = sizeof(buf);
     d38:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     d3a:	84b2                	mv	s1,a2
     d3c:	bf65                	j	cf4 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
     d3e:	85ca                	mv	a1,s2
     d40:	00005517          	auipc	a0,0x5
     d44:	66050513          	addi	a0,a0,1632 # 63a0 <malloc+0x768>
     d48:	00005097          	auipc	ra,0x5
     d4c:	e32080e7          	jalr	-462(ra) # 5b7a <printf>
    exit(1);
     d50:	4505                	li	a0,1
     d52:	00005097          	auipc	ra,0x5
     d56:	a98080e7          	jalr	-1384(ra) # 57ea <exit>
    close(fds[0]);
     d5a:	fa842503          	lw	a0,-88(s0)
     d5e:	00005097          	auipc	ra,0x5
     d62:	ab4080e7          	jalr	-1356(ra) # 5812 <close>
    for(n = 0; n < N; n++){
     d66:	0000bb17          	auipc	s6,0xb
     d6a:	d82b0b13          	addi	s6,s6,-638 # bae8 <buf>
     d6e:	416004bb          	negw	s1,s6
     d72:	0ff4f493          	andi	s1,s1,255
     d76:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
     d7a:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
     d7c:	6a85                	lui	s5,0x1
     d7e:	42da8a93          	addi	s5,s5,1069 # 142d <validatetest+0x13>
{
     d82:	87da                	mv	a5,s6
        buf[i] = seq++;
     d84:	0097873b          	addw	a4,a5,s1
     d88:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
     d8c:	0785                	addi	a5,a5,1
     d8e:	fef99be3          	bne	s3,a5,d84 <pipe1+0xe2>
        buf[i] = seq++;
     d92:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
     d96:	40900613          	li	a2,1033
     d9a:	85de                	mv	a1,s7
     d9c:	fac42503          	lw	a0,-84(s0)
     da0:	00005097          	auipc	ra,0x5
     da4:	a6a080e7          	jalr	-1430(ra) # 580a <write>
     da8:	40900793          	li	a5,1033
     dac:	00f51c63          	bne	a0,a5,dc4 <pipe1+0x122>
    for(n = 0; n < N; n++){
     db0:	24a5                	addiw	s1,s1,9
     db2:	0ff4f493          	andi	s1,s1,255
     db6:	fd5a16e3          	bne	s4,s5,d82 <pipe1+0xe0>
    exit(0);
     dba:	4501                	li	a0,0
     dbc:	00005097          	auipc	ra,0x5
     dc0:	a2e080e7          	jalr	-1490(ra) # 57ea <exit>
        printf("%s: pipe1 oops 1\n", s);
     dc4:	85ca                	mv	a1,s2
     dc6:	00005517          	auipc	a0,0x5
     dca:	5f250513          	addi	a0,a0,1522 # 63b8 <malloc+0x780>
     dce:	00005097          	auipc	ra,0x5
     dd2:	dac080e7          	jalr	-596(ra) # 5b7a <printf>
        exit(1);
     dd6:	4505                	li	a0,1
     dd8:	00005097          	auipc	ra,0x5
     ddc:	a12080e7          	jalr	-1518(ra) # 57ea <exit>
          printf("%s: pipe1 oops 2\n", s);
     de0:	85ca                	mv	a1,s2
     de2:	00005517          	auipc	a0,0x5
     de6:	5ee50513          	addi	a0,a0,1518 # 63d0 <malloc+0x798>
     dea:	00005097          	auipc	ra,0x5
     dee:	d90080e7          	jalr	-624(ra) # 5b7a <printf>
}
     df2:	60e6                	ld	ra,88(sp)
     df4:	6446                	ld	s0,80(sp)
     df6:	64a6                	ld	s1,72(sp)
     df8:	6906                	ld	s2,64(sp)
     dfa:	79e2                	ld	s3,56(sp)
     dfc:	7a42                	ld	s4,48(sp)
     dfe:	7aa2                	ld	s5,40(sp)
     e00:	7b02                	ld	s6,32(sp)
     e02:	6be2                	ld	s7,24(sp)
     e04:	6125                	addi	sp,sp,96
     e06:	8082                	ret
    if(total != N * SZ){
     e08:	6785                	lui	a5,0x1
     e0a:	42d78793          	addi	a5,a5,1069 # 142d <validatetest+0x13>
     e0e:	02fa0063          	beq	s4,a5,e2e <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
     e12:	85d2                	mv	a1,s4
     e14:	00005517          	auipc	a0,0x5
     e18:	5d450513          	addi	a0,a0,1492 # 63e8 <malloc+0x7b0>
     e1c:	00005097          	auipc	ra,0x5
     e20:	d5e080e7          	jalr	-674(ra) # 5b7a <printf>
      exit(1);
     e24:	4505                	li	a0,1
     e26:	00005097          	auipc	ra,0x5
     e2a:	9c4080e7          	jalr	-1596(ra) # 57ea <exit>
    close(fds[0]);
     e2e:	fa842503          	lw	a0,-88(s0)
     e32:	00005097          	auipc	ra,0x5
     e36:	9e0080e7          	jalr	-1568(ra) # 5812 <close>
    wait(&xstatus);
     e3a:	fa440513          	addi	a0,s0,-92
     e3e:	00005097          	auipc	ra,0x5
     e42:	9b4080e7          	jalr	-1612(ra) # 57f2 <wait>
    exit(xstatus);
     e46:	fa442503          	lw	a0,-92(s0)
     e4a:	00005097          	auipc	ra,0x5
     e4e:	9a0080e7          	jalr	-1632(ra) # 57ea <exit>
    printf("%s: fork() failed\n", s);
     e52:	85ca                	mv	a1,s2
     e54:	00005517          	auipc	a0,0x5
     e58:	5b450513          	addi	a0,a0,1460 # 6408 <malloc+0x7d0>
     e5c:	00005097          	auipc	ra,0x5
     e60:	d1e080e7          	jalr	-738(ra) # 5b7a <printf>
    exit(1);
     e64:	4505                	li	a0,1
     e66:	00005097          	auipc	ra,0x5
     e6a:	984080e7          	jalr	-1660(ra) # 57ea <exit>

0000000000000e6e <preempt>:
{
     e6e:	7139                	addi	sp,sp,-64
     e70:	fc06                	sd	ra,56(sp)
     e72:	f822                	sd	s0,48(sp)
     e74:	f426                	sd	s1,40(sp)
     e76:	f04a                	sd	s2,32(sp)
     e78:	ec4e                	sd	s3,24(sp)
     e7a:	e852                	sd	s4,16(sp)
     e7c:	0080                	addi	s0,sp,64
     e7e:	892a                	mv	s2,a0
  pid1 = fork();
     e80:	00005097          	auipc	ra,0x5
     e84:	962080e7          	jalr	-1694(ra) # 57e2 <fork>
  if(pid1 < 0) {
     e88:	00054563          	bltz	a0,e92 <preempt+0x24>
     e8c:	84aa                	mv	s1,a0
  if(pid1 == 0)
     e8e:	e105                	bnez	a0,eae <preempt+0x40>
    for(;;)
     e90:	a001                	j	e90 <preempt+0x22>
    printf("%s: fork failed", s);
     e92:	85ca                	mv	a1,s2
     e94:	00005517          	auipc	a0,0x5
     e98:	16450513          	addi	a0,a0,356 # 5ff8 <malloc+0x3c0>
     e9c:	00005097          	auipc	ra,0x5
     ea0:	cde080e7          	jalr	-802(ra) # 5b7a <printf>
    exit(1);
     ea4:	4505                	li	a0,1
     ea6:	00005097          	auipc	ra,0x5
     eaa:	944080e7          	jalr	-1724(ra) # 57ea <exit>
  pid2 = fork();
     eae:	00005097          	auipc	ra,0x5
     eb2:	934080e7          	jalr	-1740(ra) # 57e2 <fork>
     eb6:	89aa                	mv	s3,a0
  if(pid2 < 0) {
     eb8:	00054463          	bltz	a0,ec0 <preempt+0x52>
  if(pid2 == 0)
     ebc:	e105                	bnez	a0,edc <preempt+0x6e>
    for(;;)
     ebe:	a001                	j	ebe <preempt+0x50>
    printf("%s: fork failed\n", s);
     ec0:	85ca                	mv	a1,s2
     ec2:	00005517          	auipc	a0,0x5
     ec6:	0e650513          	addi	a0,a0,230 # 5fa8 <malloc+0x370>
     eca:	00005097          	auipc	ra,0x5
     ece:	cb0080e7          	jalr	-848(ra) # 5b7a <printf>
    exit(1);
     ed2:	4505                	li	a0,1
     ed4:	00005097          	auipc	ra,0x5
     ed8:	916080e7          	jalr	-1770(ra) # 57ea <exit>
  pipe(pfds);
     edc:	fc840513          	addi	a0,s0,-56
     ee0:	00005097          	auipc	ra,0x5
     ee4:	91a080e7          	jalr	-1766(ra) # 57fa <pipe>
  pid3 = fork();
     ee8:	00005097          	auipc	ra,0x5
     eec:	8fa080e7          	jalr	-1798(ra) # 57e2 <fork>
     ef0:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
     ef2:	02054e63          	bltz	a0,f2e <preempt+0xc0>
  if(pid3 == 0){
     ef6:	e525                	bnez	a0,f5e <preempt+0xf0>
    close(pfds[0]);
     ef8:	fc842503          	lw	a0,-56(s0)
     efc:	00005097          	auipc	ra,0x5
     f00:	916080e7          	jalr	-1770(ra) # 5812 <close>
    if(write(pfds[1], "x", 1) != 1)
     f04:	4605                	li	a2,1
     f06:	00005597          	auipc	a1,0x5
     f0a:	22258593          	addi	a1,a1,546 # 6128 <malloc+0x4f0>
     f0e:	fcc42503          	lw	a0,-52(s0)
     f12:	00005097          	auipc	ra,0x5
     f16:	8f8080e7          	jalr	-1800(ra) # 580a <write>
     f1a:	4785                	li	a5,1
     f1c:	02f51763          	bne	a0,a5,f4a <preempt+0xdc>
    close(pfds[1]);
     f20:	fcc42503          	lw	a0,-52(s0)
     f24:	00005097          	auipc	ra,0x5
     f28:	8ee080e7          	jalr	-1810(ra) # 5812 <close>
    for(;;)
     f2c:	a001                	j	f2c <preempt+0xbe>
     printf("%s: fork failed\n", s);
     f2e:	85ca                	mv	a1,s2
     f30:	00005517          	auipc	a0,0x5
     f34:	07850513          	addi	a0,a0,120 # 5fa8 <malloc+0x370>
     f38:	00005097          	auipc	ra,0x5
     f3c:	c42080e7          	jalr	-958(ra) # 5b7a <printf>
     exit(1);
     f40:	4505                	li	a0,1
     f42:	00005097          	auipc	ra,0x5
     f46:	8a8080e7          	jalr	-1880(ra) # 57ea <exit>
      printf("%s: preempt write error", s);
     f4a:	85ca                	mv	a1,s2
     f4c:	00005517          	auipc	a0,0x5
     f50:	4d450513          	addi	a0,a0,1236 # 6420 <malloc+0x7e8>
     f54:	00005097          	auipc	ra,0x5
     f58:	c26080e7          	jalr	-986(ra) # 5b7a <printf>
     f5c:	b7d1                	j	f20 <preempt+0xb2>
  close(pfds[1]);
     f5e:	fcc42503          	lw	a0,-52(s0)
     f62:	00005097          	auipc	ra,0x5
     f66:	8b0080e7          	jalr	-1872(ra) # 5812 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     f6a:	660d                	lui	a2,0x3
     f6c:	0000b597          	auipc	a1,0xb
     f70:	b7c58593          	addi	a1,a1,-1156 # bae8 <buf>
     f74:	fc842503          	lw	a0,-56(s0)
     f78:	00005097          	auipc	ra,0x5
     f7c:	88a080e7          	jalr	-1910(ra) # 5802 <read>
     f80:	4785                	li	a5,1
     f82:	02f50363          	beq	a0,a5,fa8 <preempt+0x13a>
    printf("%s: preempt read error", s);
     f86:	85ca                	mv	a1,s2
     f88:	00005517          	auipc	a0,0x5
     f8c:	4b050513          	addi	a0,a0,1200 # 6438 <malloc+0x800>
     f90:	00005097          	auipc	ra,0x5
     f94:	bea080e7          	jalr	-1046(ra) # 5b7a <printf>
}
     f98:	70e2                	ld	ra,56(sp)
     f9a:	7442                	ld	s0,48(sp)
     f9c:	74a2                	ld	s1,40(sp)
     f9e:	7902                	ld	s2,32(sp)
     fa0:	69e2                	ld	s3,24(sp)
     fa2:	6a42                	ld	s4,16(sp)
     fa4:	6121                	addi	sp,sp,64
     fa6:	8082                	ret
  close(pfds[0]);
     fa8:	fc842503          	lw	a0,-56(s0)
     fac:	00005097          	auipc	ra,0x5
     fb0:	866080e7          	jalr	-1946(ra) # 5812 <close>
  printf("kill... ");
     fb4:	00005517          	auipc	a0,0x5
     fb8:	49c50513          	addi	a0,a0,1180 # 6450 <malloc+0x818>
     fbc:	00005097          	auipc	ra,0x5
     fc0:	bbe080e7          	jalr	-1090(ra) # 5b7a <printf>
  kill(pid1, SIGKILL);
     fc4:	45a5                	li	a1,9
     fc6:	8526                	mv	a0,s1
     fc8:	00005097          	auipc	ra,0x5
     fcc:	852080e7          	jalr	-1966(ra) # 581a <kill>
  kill(pid2, SIGKILL);
     fd0:	45a5                	li	a1,9
     fd2:	854e                	mv	a0,s3
     fd4:	00005097          	auipc	ra,0x5
     fd8:	846080e7          	jalr	-1978(ra) # 581a <kill>
  kill(pid3, SIGKILL);
     fdc:	45a5                	li	a1,9
     fde:	8552                	mv	a0,s4
     fe0:	00005097          	auipc	ra,0x5
     fe4:	83a080e7          	jalr	-1990(ra) # 581a <kill>
  printf("wait... ");
     fe8:	00005517          	auipc	a0,0x5
     fec:	47850513          	addi	a0,a0,1144 # 6460 <malloc+0x828>
     ff0:	00005097          	auipc	ra,0x5
     ff4:	b8a080e7          	jalr	-1142(ra) # 5b7a <printf>
  wait(0);
     ff8:	4501                	li	a0,0
     ffa:	00004097          	auipc	ra,0x4
     ffe:	7f8080e7          	jalr	2040(ra) # 57f2 <wait>
  wait(0);
    1002:	4501                	li	a0,0
    1004:	00004097          	auipc	ra,0x4
    1008:	7ee080e7          	jalr	2030(ra) # 57f2 <wait>
  wait(0);
    100c:	4501                	li	a0,0
    100e:	00004097          	auipc	ra,0x4
    1012:	7e4080e7          	jalr	2020(ra) # 57f2 <wait>
    1016:	b749                	j	f98 <preempt+0x12a>

0000000000001018 <unlinkread>:
{
    1018:	7179                	addi	sp,sp,-48
    101a:	f406                	sd	ra,40(sp)
    101c:	f022                	sd	s0,32(sp)
    101e:	ec26                	sd	s1,24(sp)
    1020:	e84a                	sd	s2,16(sp)
    1022:	e44e                	sd	s3,8(sp)
    1024:	1800                	addi	s0,sp,48
    1026:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
    1028:	20200593          	li	a1,514
    102c:	00005517          	auipc	a0,0x5
    1030:	dfc50513          	addi	a0,a0,-516 # 5e28 <malloc+0x1f0>
    1034:	00004097          	auipc	ra,0x4
    1038:	7f6080e7          	jalr	2038(ra) # 582a <open>
  if(fd < 0){
    103c:	0e054563          	bltz	a0,1126 <unlinkread+0x10e>
    1040:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
    1042:	4615                	li	a2,5
    1044:	00005597          	auipc	a1,0x5
    1048:	44c58593          	addi	a1,a1,1100 # 6490 <malloc+0x858>
    104c:	00004097          	auipc	ra,0x4
    1050:	7be080e7          	jalr	1982(ra) # 580a <write>
  close(fd);
    1054:	8526                	mv	a0,s1
    1056:	00004097          	auipc	ra,0x4
    105a:	7bc080e7          	jalr	1980(ra) # 5812 <close>
  fd = open("unlinkread", O_RDWR);
    105e:	4589                	li	a1,2
    1060:	00005517          	auipc	a0,0x5
    1064:	dc850513          	addi	a0,a0,-568 # 5e28 <malloc+0x1f0>
    1068:	00004097          	auipc	ra,0x4
    106c:	7c2080e7          	jalr	1986(ra) # 582a <open>
    1070:	84aa                	mv	s1,a0
  if(fd < 0){
    1072:	0c054863          	bltz	a0,1142 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
    1076:	00005517          	auipc	a0,0x5
    107a:	db250513          	addi	a0,a0,-590 # 5e28 <malloc+0x1f0>
    107e:	00004097          	auipc	ra,0x4
    1082:	7bc080e7          	jalr	1980(ra) # 583a <unlink>
    1086:	ed61                	bnez	a0,115e <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    1088:	20200593          	li	a1,514
    108c:	00005517          	auipc	a0,0x5
    1090:	d9c50513          	addi	a0,a0,-612 # 5e28 <malloc+0x1f0>
    1094:	00004097          	auipc	ra,0x4
    1098:	796080e7          	jalr	1942(ra) # 582a <open>
    109c:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
    109e:	460d                	li	a2,3
    10a0:	00005597          	auipc	a1,0x5
    10a4:	43858593          	addi	a1,a1,1080 # 64d8 <malloc+0x8a0>
    10a8:	00004097          	auipc	ra,0x4
    10ac:	762080e7          	jalr	1890(ra) # 580a <write>
  close(fd1);
    10b0:	854a                	mv	a0,s2
    10b2:	00004097          	auipc	ra,0x4
    10b6:	760080e7          	jalr	1888(ra) # 5812 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
    10ba:	660d                	lui	a2,0x3
    10bc:	0000b597          	auipc	a1,0xb
    10c0:	a2c58593          	addi	a1,a1,-1492 # bae8 <buf>
    10c4:	8526                	mv	a0,s1
    10c6:	00004097          	auipc	ra,0x4
    10ca:	73c080e7          	jalr	1852(ra) # 5802 <read>
    10ce:	4795                	li	a5,5
    10d0:	0af51563          	bne	a0,a5,117a <unlinkread+0x162>
  if(buf[0] != 'h'){
    10d4:	0000b717          	auipc	a4,0xb
    10d8:	a1474703          	lbu	a4,-1516(a4) # bae8 <buf>
    10dc:	06800793          	li	a5,104
    10e0:	0af71b63          	bne	a4,a5,1196 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
    10e4:	4629                	li	a2,10
    10e6:	0000b597          	auipc	a1,0xb
    10ea:	a0258593          	addi	a1,a1,-1534 # bae8 <buf>
    10ee:	8526                	mv	a0,s1
    10f0:	00004097          	auipc	ra,0x4
    10f4:	71a080e7          	jalr	1818(ra) # 580a <write>
    10f8:	47a9                	li	a5,10
    10fa:	0af51c63          	bne	a0,a5,11b2 <unlinkread+0x19a>
  close(fd);
    10fe:	8526                	mv	a0,s1
    1100:	00004097          	auipc	ra,0x4
    1104:	712080e7          	jalr	1810(ra) # 5812 <close>
  unlink("unlinkread");
    1108:	00005517          	auipc	a0,0x5
    110c:	d2050513          	addi	a0,a0,-736 # 5e28 <malloc+0x1f0>
    1110:	00004097          	auipc	ra,0x4
    1114:	72a080e7          	jalr	1834(ra) # 583a <unlink>
}
    1118:	70a2                	ld	ra,40(sp)
    111a:	7402                	ld	s0,32(sp)
    111c:	64e2                	ld	s1,24(sp)
    111e:	6942                	ld	s2,16(sp)
    1120:	69a2                	ld	s3,8(sp)
    1122:	6145                	addi	sp,sp,48
    1124:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
    1126:	85ce                	mv	a1,s3
    1128:	00005517          	auipc	a0,0x5
    112c:	34850513          	addi	a0,a0,840 # 6470 <malloc+0x838>
    1130:	00005097          	auipc	ra,0x5
    1134:	a4a080e7          	jalr	-1462(ra) # 5b7a <printf>
    exit(1);
    1138:	4505                	li	a0,1
    113a:	00004097          	auipc	ra,0x4
    113e:	6b0080e7          	jalr	1712(ra) # 57ea <exit>
    printf("%s: open unlinkread failed\n", s);
    1142:	85ce                	mv	a1,s3
    1144:	00005517          	auipc	a0,0x5
    1148:	35450513          	addi	a0,a0,852 # 6498 <malloc+0x860>
    114c:	00005097          	auipc	ra,0x5
    1150:	a2e080e7          	jalr	-1490(ra) # 5b7a <printf>
    exit(1);
    1154:	4505                	li	a0,1
    1156:	00004097          	auipc	ra,0x4
    115a:	694080e7          	jalr	1684(ra) # 57ea <exit>
    printf("%s: unlink unlinkread failed\n", s);
    115e:	85ce                	mv	a1,s3
    1160:	00005517          	auipc	a0,0x5
    1164:	35850513          	addi	a0,a0,856 # 64b8 <malloc+0x880>
    1168:	00005097          	auipc	ra,0x5
    116c:	a12080e7          	jalr	-1518(ra) # 5b7a <printf>
    exit(1);
    1170:	4505                	li	a0,1
    1172:	00004097          	auipc	ra,0x4
    1176:	678080e7          	jalr	1656(ra) # 57ea <exit>
    printf("%s: unlinkread read failed", s);
    117a:	85ce                	mv	a1,s3
    117c:	00005517          	auipc	a0,0x5
    1180:	36450513          	addi	a0,a0,868 # 64e0 <malloc+0x8a8>
    1184:	00005097          	auipc	ra,0x5
    1188:	9f6080e7          	jalr	-1546(ra) # 5b7a <printf>
    exit(1);
    118c:	4505                	li	a0,1
    118e:	00004097          	auipc	ra,0x4
    1192:	65c080e7          	jalr	1628(ra) # 57ea <exit>
    printf("%s: unlinkread wrong data\n", s);
    1196:	85ce                	mv	a1,s3
    1198:	00005517          	auipc	a0,0x5
    119c:	36850513          	addi	a0,a0,872 # 6500 <malloc+0x8c8>
    11a0:	00005097          	auipc	ra,0x5
    11a4:	9da080e7          	jalr	-1574(ra) # 5b7a <printf>
    exit(1);
    11a8:	4505                	li	a0,1
    11aa:	00004097          	auipc	ra,0x4
    11ae:	640080e7          	jalr	1600(ra) # 57ea <exit>
    printf("%s: unlinkread write failed\n", s);
    11b2:	85ce                	mv	a1,s3
    11b4:	00005517          	auipc	a0,0x5
    11b8:	36c50513          	addi	a0,a0,876 # 6520 <malloc+0x8e8>
    11bc:	00005097          	auipc	ra,0x5
    11c0:	9be080e7          	jalr	-1602(ra) # 5b7a <printf>
    exit(1);
    11c4:	4505                	li	a0,1
    11c6:	00004097          	auipc	ra,0x4
    11ca:	624080e7          	jalr	1572(ra) # 57ea <exit>

00000000000011ce <linktest>:
{
    11ce:	1101                	addi	sp,sp,-32
    11d0:	ec06                	sd	ra,24(sp)
    11d2:	e822                	sd	s0,16(sp)
    11d4:	e426                	sd	s1,8(sp)
    11d6:	e04a                	sd	s2,0(sp)
    11d8:	1000                	addi	s0,sp,32
    11da:	892a                	mv	s2,a0
  unlink("lf1");
    11dc:	00005517          	auipc	a0,0x5
    11e0:	36450513          	addi	a0,a0,868 # 6540 <malloc+0x908>
    11e4:	00004097          	auipc	ra,0x4
    11e8:	656080e7          	jalr	1622(ra) # 583a <unlink>
  unlink("lf2");
    11ec:	00005517          	auipc	a0,0x5
    11f0:	35c50513          	addi	a0,a0,860 # 6548 <malloc+0x910>
    11f4:	00004097          	auipc	ra,0x4
    11f8:	646080e7          	jalr	1606(ra) # 583a <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
    11fc:	20200593          	li	a1,514
    1200:	00005517          	auipc	a0,0x5
    1204:	34050513          	addi	a0,a0,832 # 6540 <malloc+0x908>
    1208:	00004097          	auipc	ra,0x4
    120c:	622080e7          	jalr	1570(ra) # 582a <open>
  if(fd < 0){
    1210:	10054763          	bltz	a0,131e <linktest+0x150>
    1214:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
    1216:	4615                	li	a2,5
    1218:	00005597          	auipc	a1,0x5
    121c:	27858593          	addi	a1,a1,632 # 6490 <malloc+0x858>
    1220:	00004097          	auipc	ra,0x4
    1224:	5ea080e7          	jalr	1514(ra) # 580a <write>
    1228:	4795                	li	a5,5
    122a:	10f51863          	bne	a0,a5,133a <linktest+0x16c>
  close(fd);
    122e:	8526                	mv	a0,s1
    1230:	00004097          	auipc	ra,0x4
    1234:	5e2080e7          	jalr	1506(ra) # 5812 <close>
  if(link("lf1", "lf2") < 0){
    1238:	00005597          	auipc	a1,0x5
    123c:	31058593          	addi	a1,a1,784 # 6548 <malloc+0x910>
    1240:	00005517          	auipc	a0,0x5
    1244:	30050513          	addi	a0,a0,768 # 6540 <malloc+0x908>
    1248:	00004097          	auipc	ra,0x4
    124c:	602080e7          	jalr	1538(ra) # 584a <link>
    1250:	10054363          	bltz	a0,1356 <linktest+0x188>
  unlink("lf1");
    1254:	00005517          	auipc	a0,0x5
    1258:	2ec50513          	addi	a0,a0,748 # 6540 <malloc+0x908>
    125c:	00004097          	auipc	ra,0x4
    1260:	5de080e7          	jalr	1502(ra) # 583a <unlink>
  if(open("lf1", 0) >= 0){
    1264:	4581                	li	a1,0
    1266:	00005517          	auipc	a0,0x5
    126a:	2da50513          	addi	a0,a0,730 # 6540 <malloc+0x908>
    126e:	00004097          	auipc	ra,0x4
    1272:	5bc080e7          	jalr	1468(ra) # 582a <open>
    1276:	0e055e63          	bgez	a0,1372 <linktest+0x1a4>
  fd = open("lf2", 0);
    127a:	4581                	li	a1,0
    127c:	00005517          	auipc	a0,0x5
    1280:	2cc50513          	addi	a0,a0,716 # 6548 <malloc+0x910>
    1284:	00004097          	auipc	ra,0x4
    1288:	5a6080e7          	jalr	1446(ra) # 582a <open>
    128c:	84aa                	mv	s1,a0
  if(fd < 0){
    128e:	10054063          	bltz	a0,138e <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    1292:	660d                	lui	a2,0x3
    1294:	0000b597          	auipc	a1,0xb
    1298:	85458593          	addi	a1,a1,-1964 # bae8 <buf>
    129c:	00004097          	auipc	ra,0x4
    12a0:	566080e7          	jalr	1382(ra) # 5802 <read>
    12a4:	4795                	li	a5,5
    12a6:	10f51263          	bne	a0,a5,13aa <linktest+0x1dc>
  close(fd);
    12aa:	8526                	mv	a0,s1
    12ac:	00004097          	auipc	ra,0x4
    12b0:	566080e7          	jalr	1382(ra) # 5812 <close>
  if(link("lf2", "lf2") >= 0){
    12b4:	00005597          	auipc	a1,0x5
    12b8:	29458593          	addi	a1,a1,660 # 6548 <malloc+0x910>
    12bc:	852e                	mv	a0,a1
    12be:	00004097          	auipc	ra,0x4
    12c2:	58c080e7          	jalr	1420(ra) # 584a <link>
    12c6:	10055063          	bgez	a0,13c6 <linktest+0x1f8>
  unlink("lf2");
    12ca:	00005517          	auipc	a0,0x5
    12ce:	27e50513          	addi	a0,a0,638 # 6548 <malloc+0x910>
    12d2:	00004097          	auipc	ra,0x4
    12d6:	568080e7          	jalr	1384(ra) # 583a <unlink>
  if(link("lf2", "lf1") >= 0){
    12da:	00005597          	auipc	a1,0x5
    12de:	26658593          	addi	a1,a1,614 # 6540 <malloc+0x908>
    12e2:	00005517          	auipc	a0,0x5
    12e6:	26650513          	addi	a0,a0,614 # 6548 <malloc+0x910>
    12ea:	00004097          	auipc	ra,0x4
    12ee:	560080e7          	jalr	1376(ra) # 584a <link>
    12f2:	0e055863          	bgez	a0,13e2 <linktest+0x214>
  if(link(".", "lf1") >= 0){
    12f6:	00005597          	auipc	a1,0x5
    12fa:	24a58593          	addi	a1,a1,586 # 6540 <malloc+0x908>
    12fe:	00005517          	auipc	a0,0x5
    1302:	35250513          	addi	a0,a0,850 # 6650 <malloc+0xa18>
    1306:	00004097          	auipc	ra,0x4
    130a:	544080e7          	jalr	1348(ra) # 584a <link>
    130e:	0e055863          	bgez	a0,13fe <linktest+0x230>
}
    1312:	60e2                	ld	ra,24(sp)
    1314:	6442                	ld	s0,16(sp)
    1316:	64a2                	ld	s1,8(sp)
    1318:	6902                	ld	s2,0(sp)
    131a:	6105                	addi	sp,sp,32
    131c:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    131e:	85ca                	mv	a1,s2
    1320:	00005517          	auipc	a0,0x5
    1324:	23050513          	addi	a0,a0,560 # 6550 <malloc+0x918>
    1328:	00005097          	auipc	ra,0x5
    132c:	852080e7          	jalr	-1966(ra) # 5b7a <printf>
    exit(1);
    1330:	4505                	li	a0,1
    1332:	00004097          	auipc	ra,0x4
    1336:	4b8080e7          	jalr	1208(ra) # 57ea <exit>
    printf("%s: write lf1 failed\n", s);
    133a:	85ca                	mv	a1,s2
    133c:	00005517          	auipc	a0,0x5
    1340:	22c50513          	addi	a0,a0,556 # 6568 <malloc+0x930>
    1344:	00005097          	auipc	ra,0x5
    1348:	836080e7          	jalr	-1994(ra) # 5b7a <printf>
    exit(1);
    134c:	4505                	li	a0,1
    134e:	00004097          	auipc	ra,0x4
    1352:	49c080e7          	jalr	1180(ra) # 57ea <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    1356:	85ca                	mv	a1,s2
    1358:	00005517          	auipc	a0,0x5
    135c:	22850513          	addi	a0,a0,552 # 6580 <malloc+0x948>
    1360:	00005097          	auipc	ra,0x5
    1364:	81a080e7          	jalr	-2022(ra) # 5b7a <printf>
    exit(1);
    1368:	4505                	li	a0,1
    136a:	00004097          	auipc	ra,0x4
    136e:	480080e7          	jalr	1152(ra) # 57ea <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    1372:	85ca                	mv	a1,s2
    1374:	00005517          	auipc	a0,0x5
    1378:	22c50513          	addi	a0,a0,556 # 65a0 <malloc+0x968>
    137c:	00004097          	auipc	ra,0x4
    1380:	7fe080e7          	jalr	2046(ra) # 5b7a <printf>
    exit(1);
    1384:	4505                	li	a0,1
    1386:	00004097          	auipc	ra,0x4
    138a:	464080e7          	jalr	1124(ra) # 57ea <exit>
    printf("%s: open lf2 failed\n", s);
    138e:	85ca                	mv	a1,s2
    1390:	00005517          	auipc	a0,0x5
    1394:	24050513          	addi	a0,a0,576 # 65d0 <malloc+0x998>
    1398:	00004097          	auipc	ra,0x4
    139c:	7e2080e7          	jalr	2018(ra) # 5b7a <printf>
    exit(1);
    13a0:	4505                	li	a0,1
    13a2:	00004097          	auipc	ra,0x4
    13a6:	448080e7          	jalr	1096(ra) # 57ea <exit>
    printf("%s: read lf2 failed\n", s);
    13aa:	85ca                	mv	a1,s2
    13ac:	00005517          	auipc	a0,0x5
    13b0:	23c50513          	addi	a0,a0,572 # 65e8 <malloc+0x9b0>
    13b4:	00004097          	auipc	ra,0x4
    13b8:	7c6080e7          	jalr	1990(ra) # 5b7a <printf>
    exit(1);
    13bc:	4505                	li	a0,1
    13be:	00004097          	auipc	ra,0x4
    13c2:	42c080e7          	jalr	1068(ra) # 57ea <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    13c6:	85ca                	mv	a1,s2
    13c8:	00005517          	auipc	a0,0x5
    13cc:	23850513          	addi	a0,a0,568 # 6600 <malloc+0x9c8>
    13d0:	00004097          	auipc	ra,0x4
    13d4:	7aa080e7          	jalr	1962(ra) # 5b7a <printf>
    exit(1);
    13d8:	4505                	li	a0,1
    13da:	00004097          	auipc	ra,0x4
    13de:	410080e7          	jalr	1040(ra) # 57ea <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
    13e2:	85ca                	mv	a1,s2
    13e4:	00005517          	auipc	a0,0x5
    13e8:	24450513          	addi	a0,a0,580 # 6628 <malloc+0x9f0>
    13ec:	00004097          	auipc	ra,0x4
    13f0:	78e080e7          	jalr	1934(ra) # 5b7a <printf>
    exit(1);
    13f4:	4505                	li	a0,1
    13f6:	00004097          	auipc	ra,0x4
    13fa:	3f4080e7          	jalr	1012(ra) # 57ea <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    13fe:	85ca                	mv	a1,s2
    1400:	00005517          	auipc	a0,0x5
    1404:	25850513          	addi	a0,a0,600 # 6658 <malloc+0xa20>
    1408:	00004097          	auipc	ra,0x4
    140c:	772080e7          	jalr	1906(ra) # 5b7a <printf>
    exit(1);
    1410:	4505                	li	a0,1
    1412:	00004097          	auipc	ra,0x4
    1416:	3d8080e7          	jalr	984(ra) # 57ea <exit>

000000000000141a <validatetest>:
{
    141a:	7139                	addi	sp,sp,-64
    141c:	fc06                	sd	ra,56(sp)
    141e:	f822                	sd	s0,48(sp)
    1420:	f426                	sd	s1,40(sp)
    1422:	f04a                	sd	s2,32(sp)
    1424:	ec4e                	sd	s3,24(sp)
    1426:	e852                	sd	s4,16(sp)
    1428:	e456                	sd	s5,8(sp)
    142a:	e05a                	sd	s6,0(sp)
    142c:	0080                	addi	s0,sp,64
    142e:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1430:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    1432:	00005997          	auipc	s3,0x5
    1436:	24698993          	addi	s3,s3,582 # 6678 <malloc+0xa40>
    143a:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    143c:	6a85                	lui	s5,0x1
    143e:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1442:	85a6                	mv	a1,s1
    1444:	854e                	mv	a0,s3
    1446:	00004097          	auipc	ra,0x4
    144a:	404080e7          	jalr	1028(ra) # 584a <link>
    144e:	01251f63          	bne	a0,s2,146c <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1452:	94d6                	add	s1,s1,s5
    1454:	ff4497e3          	bne	s1,s4,1442 <validatetest+0x28>
}
    1458:	70e2                	ld	ra,56(sp)
    145a:	7442                	ld	s0,48(sp)
    145c:	74a2                	ld	s1,40(sp)
    145e:	7902                	ld	s2,32(sp)
    1460:	69e2                	ld	s3,24(sp)
    1462:	6a42                	ld	s4,16(sp)
    1464:	6aa2                	ld	s5,8(sp)
    1466:	6b02                	ld	s6,0(sp)
    1468:	6121                	addi	sp,sp,64
    146a:	8082                	ret
      printf("%s: link should not succeed\n", s);
    146c:	85da                	mv	a1,s6
    146e:	00005517          	auipc	a0,0x5
    1472:	21a50513          	addi	a0,a0,538 # 6688 <malloc+0xa50>
    1476:	00004097          	auipc	ra,0x4
    147a:	704080e7          	jalr	1796(ra) # 5b7a <printf>
      exit(1);
    147e:	4505                	li	a0,1
    1480:	00004097          	auipc	ra,0x4
    1484:	36a080e7          	jalr	874(ra) # 57ea <exit>

0000000000001488 <copyinstr2>:
{
    1488:	7155                	addi	sp,sp,-208
    148a:	e586                	sd	ra,200(sp)
    148c:	e1a2                	sd	s0,192(sp)
    148e:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    1490:	f6840793          	addi	a5,s0,-152
    1494:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    1498:	07800713          	li	a4,120
    149c:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    14a0:	0785                	addi	a5,a5,1
    14a2:	fed79de3          	bne	a5,a3,149c <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    14a6:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    14aa:	f6840513          	addi	a0,s0,-152
    14ae:	00004097          	auipc	ra,0x4
    14b2:	38c080e7          	jalr	908(ra) # 583a <unlink>
  if(ret != -1){
    14b6:	57fd                	li	a5,-1
    14b8:	0ef51063          	bne	a0,a5,1598 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    14bc:	20100593          	li	a1,513
    14c0:	f6840513          	addi	a0,s0,-152
    14c4:	00004097          	auipc	ra,0x4
    14c8:	366080e7          	jalr	870(ra) # 582a <open>
  if(fd != -1){
    14cc:	57fd                	li	a5,-1
    14ce:	0ef51563          	bne	a0,a5,15b8 <copyinstr2+0x130>
  ret = link(b, b);
    14d2:	f6840593          	addi	a1,s0,-152
    14d6:	852e                	mv	a0,a1
    14d8:	00004097          	auipc	ra,0x4
    14dc:	372080e7          	jalr	882(ra) # 584a <link>
  if(ret != -1){
    14e0:	57fd                	li	a5,-1
    14e2:	0ef51b63          	bne	a0,a5,15d8 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    14e6:	00006797          	auipc	a5,0x6
    14ea:	f7a78793          	addi	a5,a5,-134 # 7460 <malloc+0x1828>
    14ee:	f4f43c23          	sd	a5,-168(s0)
    14f2:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    14f6:	f5840593          	addi	a1,s0,-168
    14fa:	f6840513          	addi	a0,s0,-152
    14fe:	00004097          	auipc	ra,0x4
    1502:	324080e7          	jalr	804(ra) # 5822 <exec>
  if(ret != -1){
    1506:	57fd                	li	a5,-1
    1508:	0ef51963          	bne	a0,a5,15fa <copyinstr2+0x172>
  int pid = fork();
    150c:	00004097          	auipc	ra,0x4
    1510:	2d6080e7          	jalr	726(ra) # 57e2 <fork>
  if(pid < 0){
    1514:	10054363          	bltz	a0,161a <copyinstr2+0x192>
  if(pid == 0){
    1518:	12051463          	bnez	a0,1640 <copyinstr2+0x1b8>
    151c:	00007797          	auipc	a5,0x7
    1520:	eb478793          	addi	a5,a5,-332 # 83d0 <big.0>
    1524:	00008697          	auipc	a3,0x8
    1528:	eac68693          	addi	a3,a3,-340 # 93d0 <__global_pointer$+0x920>
      big[i] = 'x';
    152c:	07800713          	li	a4,120
    1530:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1534:	0785                	addi	a5,a5,1
    1536:	fed79de3          	bne	a5,a3,1530 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    153a:	00008797          	auipc	a5,0x8
    153e:	e8078b23          	sb	zero,-362(a5) # 93d0 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    1542:	00007797          	auipc	a5,0x7
    1546:	aae78793          	addi	a5,a5,-1362 # 7ff0 <malloc+0x23b8>
    154a:	6390                	ld	a2,0(a5)
    154c:	6794                	ld	a3,8(a5)
    154e:	6b98                	ld	a4,16(a5)
    1550:	6f9c                	ld	a5,24(a5)
    1552:	f2c43823          	sd	a2,-208(s0)
    1556:	f2d43c23          	sd	a3,-200(s0)
    155a:	f4e43023          	sd	a4,-192(s0)
    155e:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1562:	f3040593          	addi	a1,s0,-208
    1566:	00005517          	auipc	a0,0x5
    156a:	b5250513          	addi	a0,a0,-1198 # 60b8 <malloc+0x480>
    156e:	00004097          	auipc	ra,0x4
    1572:	2b4080e7          	jalr	692(ra) # 5822 <exec>
    if(ret != -1){
    1576:	57fd                	li	a5,-1
    1578:	0af50e63          	beq	a0,a5,1634 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    157c:	55fd                	li	a1,-1
    157e:	00005517          	auipc	a0,0x5
    1582:	1b250513          	addi	a0,a0,434 # 6730 <malloc+0xaf8>
    1586:	00004097          	auipc	ra,0x4
    158a:	5f4080e7          	jalr	1524(ra) # 5b7a <printf>
      exit(1);
    158e:	4505                	li	a0,1
    1590:	00004097          	auipc	ra,0x4
    1594:	25a080e7          	jalr	602(ra) # 57ea <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1598:	862a                	mv	a2,a0
    159a:	f6840593          	addi	a1,s0,-152
    159e:	00005517          	auipc	a0,0x5
    15a2:	10a50513          	addi	a0,a0,266 # 66a8 <malloc+0xa70>
    15a6:	00004097          	auipc	ra,0x4
    15aa:	5d4080e7          	jalr	1492(ra) # 5b7a <printf>
    exit(1);
    15ae:	4505                	li	a0,1
    15b0:	00004097          	auipc	ra,0x4
    15b4:	23a080e7          	jalr	570(ra) # 57ea <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    15b8:	862a                	mv	a2,a0
    15ba:	f6840593          	addi	a1,s0,-152
    15be:	00005517          	auipc	a0,0x5
    15c2:	10a50513          	addi	a0,a0,266 # 66c8 <malloc+0xa90>
    15c6:	00004097          	auipc	ra,0x4
    15ca:	5b4080e7          	jalr	1460(ra) # 5b7a <printf>
    exit(1);
    15ce:	4505                	li	a0,1
    15d0:	00004097          	auipc	ra,0x4
    15d4:	21a080e7          	jalr	538(ra) # 57ea <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    15d8:	86aa                	mv	a3,a0
    15da:	f6840613          	addi	a2,s0,-152
    15de:	85b2                	mv	a1,a2
    15e0:	00005517          	auipc	a0,0x5
    15e4:	10850513          	addi	a0,a0,264 # 66e8 <malloc+0xab0>
    15e8:	00004097          	auipc	ra,0x4
    15ec:	592080e7          	jalr	1426(ra) # 5b7a <printf>
    exit(1);
    15f0:	4505                	li	a0,1
    15f2:	00004097          	auipc	ra,0x4
    15f6:	1f8080e7          	jalr	504(ra) # 57ea <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    15fa:	567d                	li	a2,-1
    15fc:	f6840593          	addi	a1,s0,-152
    1600:	00005517          	auipc	a0,0x5
    1604:	11050513          	addi	a0,a0,272 # 6710 <malloc+0xad8>
    1608:	00004097          	auipc	ra,0x4
    160c:	572080e7          	jalr	1394(ra) # 5b7a <printf>
    exit(1);
    1610:	4505                	li	a0,1
    1612:	00004097          	auipc	ra,0x4
    1616:	1d8080e7          	jalr	472(ra) # 57ea <exit>
    printf("fork failed\n");
    161a:	00005517          	auipc	a0,0x5
    161e:	31e50513          	addi	a0,a0,798 # 6938 <malloc+0xd00>
    1622:	00004097          	auipc	ra,0x4
    1626:	558080e7          	jalr	1368(ra) # 5b7a <printf>
    exit(1);
    162a:	4505                	li	a0,1
    162c:	00004097          	auipc	ra,0x4
    1630:	1be080e7          	jalr	446(ra) # 57ea <exit>
    exit(747); // OK
    1634:	2eb00513          	li	a0,747
    1638:	00004097          	auipc	ra,0x4
    163c:	1b2080e7          	jalr	434(ra) # 57ea <exit>
  int st = 0;
    1640:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1644:	f5440513          	addi	a0,s0,-172
    1648:	00004097          	auipc	ra,0x4
    164c:	1aa080e7          	jalr	426(ra) # 57f2 <wait>
  if(st != 747){
    1650:	f5442703          	lw	a4,-172(s0)
    1654:	2eb00793          	li	a5,747
    1658:	00f71663          	bne	a4,a5,1664 <copyinstr2+0x1dc>
}
    165c:	60ae                	ld	ra,200(sp)
    165e:	640e                	ld	s0,192(sp)
    1660:	6169                	addi	sp,sp,208
    1662:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    1664:	00005517          	auipc	a0,0x5
    1668:	0f450513          	addi	a0,a0,244 # 6758 <malloc+0xb20>
    166c:	00004097          	auipc	ra,0x4
    1670:	50e080e7          	jalr	1294(ra) # 5b7a <printf>
    exit(1);
    1674:	4505                	li	a0,1
    1676:	00004097          	auipc	ra,0x4
    167a:	174080e7          	jalr	372(ra) # 57ea <exit>

000000000000167e <exectest>:
{
    167e:	715d                	addi	sp,sp,-80
    1680:	e486                	sd	ra,72(sp)
    1682:	e0a2                	sd	s0,64(sp)
    1684:	fc26                	sd	s1,56(sp)
    1686:	f84a                	sd	s2,48(sp)
    1688:	0880                	addi	s0,sp,80
    168a:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    168c:	00005797          	auipc	a5,0x5
    1690:	a2c78793          	addi	a5,a5,-1492 # 60b8 <malloc+0x480>
    1694:	fcf43023          	sd	a5,-64(s0)
    1698:	00005797          	auipc	a5,0x5
    169c:	0f078793          	addi	a5,a5,240 # 6788 <malloc+0xb50>
    16a0:	fcf43423          	sd	a5,-56(s0)
    16a4:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    16a8:	00005517          	auipc	a0,0x5
    16ac:	0e850513          	addi	a0,a0,232 # 6790 <malloc+0xb58>
    16b0:	00004097          	auipc	ra,0x4
    16b4:	18a080e7          	jalr	394(ra) # 583a <unlink>
  pid = fork();
    16b8:	00004097          	auipc	ra,0x4
    16bc:	12a080e7          	jalr	298(ra) # 57e2 <fork>
  if(pid < 0) {
    16c0:	04054663          	bltz	a0,170c <exectest+0x8e>
    16c4:	84aa                	mv	s1,a0
  if(pid == 0) {
    16c6:	e959                	bnez	a0,175c <exectest+0xde>
    close(1);
    16c8:	4505                	li	a0,1
    16ca:	00004097          	auipc	ra,0x4
    16ce:	148080e7          	jalr	328(ra) # 5812 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    16d2:	20100593          	li	a1,513
    16d6:	00005517          	auipc	a0,0x5
    16da:	0ba50513          	addi	a0,a0,186 # 6790 <malloc+0xb58>
    16de:	00004097          	auipc	ra,0x4
    16e2:	14c080e7          	jalr	332(ra) # 582a <open>
    if(fd < 0) {
    16e6:	04054163          	bltz	a0,1728 <exectest+0xaa>
    if(fd != 1) {
    16ea:	4785                	li	a5,1
    16ec:	04f50c63          	beq	a0,a5,1744 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    16f0:	85ca                	mv	a1,s2
    16f2:	00005517          	auipc	a0,0x5
    16f6:	0be50513          	addi	a0,a0,190 # 67b0 <malloc+0xb78>
    16fa:	00004097          	auipc	ra,0x4
    16fe:	480080e7          	jalr	1152(ra) # 5b7a <printf>
      exit(1);
    1702:	4505                	li	a0,1
    1704:	00004097          	auipc	ra,0x4
    1708:	0e6080e7          	jalr	230(ra) # 57ea <exit>
     printf("%s: fork failed\n", s);
    170c:	85ca                	mv	a1,s2
    170e:	00005517          	auipc	a0,0x5
    1712:	89a50513          	addi	a0,a0,-1894 # 5fa8 <malloc+0x370>
    1716:	00004097          	auipc	ra,0x4
    171a:	464080e7          	jalr	1124(ra) # 5b7a <printf>
     exit(1);
    171e:	4505                	li	a0,1
    1720:	00004097          	auipc	ra,0x4
    1724:	0ca080e7          	jalr	202(ra) # 57ea <exit>
      printf("%s: create failed\n", s);
    1728:	85ca                	mv	a1,s2
    172a:	00005517          	auipc	a0,0x5
    172e:	06e50513          	addi	a0,a0,110 # 6798 <malloc+0xb60>
    1732:	00004097          	auipc	ra,0x4
    1736:	448080e7          	jalr	1096(ra) # 5b7a <printf>
      exit(1);
    173a:	4505                	li	a0,1
    173c:	00004097          	auipc	ra,0x4
    1740:	0ae080e7          	jalr	174(ra) # 57ea <exit>
    if(exec("echo", echoargv) < 0){
    1744:	fc040593          	addi	a1,s0,-64
    1748:	00005517          	auipc	a0,0x5
    174c:	97050513          	addi	a0,a0,-1680 # 60b8 <malloc+0x480>
    1750:	00004097          	auipc	ra,0x4
    1754:	0d2080e7          	jalr	210(ra) # 5822 <exec>
    1758:	02054163          	bltz	a0,177a <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    175c:	fdc40513          	addi	a0,s0,-36
    1760:	00004097          	auipc	ra,0x4
    1764:	092080e7          	jalr	146(ra) # 57f2 <wait>
    1768:	02951763          	bne	a0,s1,1796 <exectest+0x118>
  if(xstatus != 0)
    176c:	fdc42503          	lw	a0,-36(s0)
    1770:	cd0d                	beqz	a0,17aa <exectest+0x12c>
    exit(xstatus);
    1772:	00004097          	auipc	ra,0x4
    1776:	078080e7          	jalr	120(ra) # 57ea <exit>
      printf("%s: exec echo failed\n", s);
    177a:	85ca                	mv	a1,s2
    177c:	00005517          	auipc	a0,0x5
    1780:	04450513          	addi	a0,a0,68 # 67c0 <malloc+0xb88>
    1784:	00004097          	auipc	ra,0x4
    1788:	3f6080e7          	jalr	1014(ra) # 5b7a <printf>
      exit(1);
    178c:	4505                	li	a0,1
    178e:	00004097          	auipc	ra,0x4
    1792:	05c080e7          	jalr	92(ra) # 57ea <exit>
    printf("%s: wait failed!\n", s);
    1796:	85ca                	mv	a1,s2
    1798:	00005517          	auipc	a0,0x5
    179c:	04050513          	addi	a0,a0,64 # 67d8 <malloc+0xba0>
    17a0:	00004097          	auipc	ra,0x4
    17a4:	3da080e7          	jalr	986(ra) # 5b7a <printf>
    17a8:	b7d1                	j	176c <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    17aa:	4581                	li	a1,0
    17ac:	00005517          	auipc	a0,0x5
    17b0:	fe450513          	addi	a0,a0,-28 # 6790 <malloc+0xb58>
    17b4:	00004097          	auipc	ra,0x4
    17b8:	076080e7          	jalr	118(ra) # 582a <open>
  if(fd < 0) {
    17bc:	02054a63          	bltz	a0,17f0 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    17c0:	4609                	li	a2,2
    17c2:	fb840593          	addi	a1,s0,-72
    17c6:	00004097          	auipc	ra,0x4
    17ca:	03c080e7          	jalr	60(ra) # 5802 <read>
    17ce:	4789                	li	a5,2
    17d0:	02f50e63          	beq	a0,a5,180c <exectest+0x18e>
    printf("%s: read failed\n", s);
    17d4:	85ca                	mv	a1,s2
    17d6:	00005517          	auipc	a0,0x5
    17da:	03250513          	addi	a0,a0,50 # 6808 <malloc+0xbd0>
    17de:	00004097          	auipc	ra,0x4
    17e2:	39c080e7          	jalr	924(ra) # 5b7a <printf>
    exit(1);
    17e6:	4505                	li	a0,1
    17e8:	00004097          	auipc	ra,0x4
    17ec:	002080e7          	jalr	2(ra) # 57ea <exit>
    printf("%s: open failed\n", s);
    17f0:	85ca                	mv	a1,s2
    17f2:	00005517          	auipc	a0,0x5
    17f6:	ffe50513          	addi	a0,a0,-2 # 67f0 <malloc+0xbb8>
    17fa:	00004097          	auipc	ra,0x4
    17fe:	380080e7          	jalr	896(ra) # 5b7a <printf>
    exit(1);
    1802:	4505                	li	a0,1
    1804:	00004097          	auipc	ra,0x4
    1808:	fe6080e7          	jalr	-26(ra) # 57ea <exit>
  unlink("echo-ok");
    180c:	00005517          	auipc	a0,0x5
    1810:	f8450513          	addi	a0,a0,-124 # 6790 <malloc+0xb58>
    1814:	00004097          	auipc	ra,0x4
    1818:	026080e7          	jalr	38(ra) # 583a <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    181c:	fb844703          	lbu	a4,-72(s0)
    1820:	04f00793          	li	a5,79
    1824:	00f71863          	bne	a4,a5,1834 <exectest+0x1b6>
    1828:	fb944703          	lbu	a4,-71(s0)
    182c:	04b00793          	li	a5,75
    1830:	02f70063          	beq	a4,a5,1850 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1834:	85ca                	mv	a1,s2
    1836:	00005517          	auipc	a0,0x5
    183a:	fea50513          	addi	a0,a0,-22 # 6820 <malloc+0xbe8>
    183e:	00004097          	auipc	ra,0x4
    1842:	33c080e7          	jalr	828(ra) # 5b7a <printf>
    exit(1);
    1846:	4505                	li	a0,1
    1848:	00004097          	auipc	ra,0x4
    184c:	fa2080e7          	jalr	-94(ra) # 57ea <exit>
    exit(0);
    1850:	4501                	li	a0,0
    1852:	00004097          	auipc	ra,0x4
    1856:	f98080e7          	jalr	-104(ra) # 57ea <exit>

000000000000185a <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(char *s)
{
    185a:	7179                	addi	sp,sp,-48
    185c:	f406                	sd	ra,40(sp)
    185e:	f022                	sd	s0,32(sp)
    1860:	ec26                	sd	s1,24(sp)
    1862:	1800                	addi	s0,sp,48
    1864:	84aa                	mv	s1,a0
  int pid, fd, xstatus;

  unlink("bigarg-ok");
    1866:	00005517          	auipc	a0,0x5
    186a:	fd250513          	addi	a0,a0,-46 # 6838 <malloc+0xc00>
    186e:	00004097          	auipc	ra,0x4
    1872:	fcc080e7          	jalr	-52(ra) # 583a <unlink>
  pid = fork();
    1876:	00004097          	auipc	ra,0x4
    187a:	f6c080e7          	jalr	-148(ra) # 57e2 <fork>
  if(pid == 0){
    187e:	c121                	beqz	a0,18be <bigargtest+0x64>
    args[MAXARG-1] = 0;
    exec("echo", args);
    fd = open("bigarg-ok", O_CREATE);
    close(fd);
    exit(0);
  } else if(pid < 0){
    1880:	0a054063          	bltz	a0,1920 <bigargtest+0xc6>
    printf("%s: bigargtest: fork failed\n", s);
    exit(1);
  }
  
  wait(&xstatus);
    1884:	fdc40513          	addi	a0,s0,-36
    1888:	00004097          	auipc	ra,0x4
    188c:	f6a080e7          	jalr	-150(ra) # 57f2 <wait>
  if(xstatus != 0)
    1890:	fdc42503          	lw	a0,-36(s0)
    1894:	e545                	bnez	a0,193c <bigargtest+0xe2>
    exit(xstatus);
  fd = open("bigarg-ok", 0);
    1896:	4581                	li	a1,0
    1898:	00005517          	auipc	a0,0x5
    189c:	fa050513          	addi	a0,a0,-96 # 6838 <malloc+0xc00>
    18a0:	00004097          	auipc	ra,0x4
    18a4:	f8a080e7          	jalr	-118(ra) # 582a <open>
  if(fd < 0){
    18a8:	08054e63          	bltz	a0,1944 <bigargtest+0xea>
    printf("%s: bigarg test failed!\n", s);
    exit(1);
  }
  close(fd);
    18ac:	00004097          	auipc	ra,0x4
    18b0:	f66080e7          	jalr	-154(ra) # 5812 <close>
}
    18b4:	70a2                	ld	ra,40(sp)
    18b6:	7402                	ld	s0,32(sp)
    18b8:	64e2                	ld	s1,24(sp)
    18ba:	6145                	addi	sp,sp,48
    18bc:	8082                	ret
    18be:	00007797          	auipc	a5,0x7
    18c2:	a1278793          	addi	a5,a5,-1518 # 82d0 <args.1>
    18c6:	00007697          	auipc	a3,0x7
    18ca:	b0268693          	addi	a3,a3,-1278 # 83c8 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    18ce:	00005717          	auipc	a4,0x5
    18d2:	f7a70713          	addi	a4,a4,-134 # 6848 <malloc+0xc10>
    18d6:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    18d8:	07a1                	addi	a5,a5,8
    18da:	fed79ee3          	bne	a5,a3,18d6 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    18de:	00007597          	auipc	a1,0x7
    18e2:	9f258593          	addi	a1,a1,-1550 # 82d0 <args.1>
    18e6:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    18ea:	00004517          	auipc	a0,0x4
    18ee:	7ce50513          	addi	a0,a0,1998 # 60b8 <malloc+0x480>
    18f2:	00004097          	auipc	ra,0x4
    18f6:	f30080e7          	jalr	-208(ra) # 5822 <exec>
    fd = open("bigarg-ok", O_CREATE);
    18fa:	20000593          	li	a1,512
    18fe:	00005517          	auipc	a0,0x5
    1902:	f3a50513          	addi	a0,a0,-198 # 6838 <malloc+0xc00>
    1906:	00004097          	auipc	ra,0x4
    190a:	f24080e7          	jalr	-220(ra) # 582a <open>
    close(fd);
    190e:	00004097          	auipc	ra,0x4
    1912:	f04080e7          	jalr	-252(ra) # 5812 <close>
    exit(0);
    1916:	4501                	li	a0,0
    1918:	00004097          	auipc	ra,0x4
    191c:	ed2080e7          	jalr	-302(ra) # 57ea <exit>
    printf("%s: bigargtest: fork failed\n", s);
    1920:	85a6                	mv	a1,s1
    1922:	00005517          	auipc	a0,0x5
    1926:	00650513          	addi	a0,a0,6 # 6928 <malloc+0xcf0>
    192a:	00004097          	auipc	ra,0x4
    192e:	250080e7          	jalr	592(ra) # 5b7a <printf>
    exit(1);
    1932:	4505                	li	a0,1
    1934:	00004097          	auipc	ra,0x4
    1938:	eb6080e7          	jalr	-330(ra) # 57ea <exit>
    exit(xstatus);
    193c:	00004097          	auipc	ra,0x4
    1940:	eae080e7          	jalr	-338(ra) # 57ea <exit>
    printf("%s: bigarg test failed!\n", s);
    1944:	85a6                	mv	a1,s1
    1946:	00005517          	auipc	a0,0x5
    194a:	00250513          	addi	a0,a0,2 # 6948 <malloc+0xd10>
    194e:	00004097          	auipc	ra,0x4
    1952:	22c080e7          	jalr	556(ra) # 5b7a <printf>
    exit(1);
    1956:	4505                	li	a0,1
    1958:	00004097          	auipc	ra,0x4
    195c:	e92080e7          	jalr	-366(ra) # 57ea <exit>

0000000000001960 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1960:	7179                	addi	sp,sp,-48
    1962:	f406                	sd	ra,40(sp)
    1964:	f022                	sd	s0,32(sp)
    1966:	ec26                	sd	s1,24(sp)
    1968:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    196a:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    196e:	00007497          	auipc	s1,0x7
    1972:	9424b483          	ld	s1,-1726(s1) # 82b0 <__SDATA_BEGIN__>
    1976:	fd840593          	addi	a1,s0,-40
    197a:	8526                	mv	a0,s1
    197c:	00004097          	auipc	ra,0x4
    1980:	ea6080e7          	jalr	-346(ra) # 5822 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    1984:	8526                	mv	a0,s1
    1986:	00004097          	auipc	ra,0x4
    198a:	e74080e7          	jalr	-396(ra) # 57fa <pipe>

  exit(0);
    198e:	4501                	li	a0,0
    1990:	00004097          	auipc	ra,0x4
    1994:	e5a080e7          	jalr	-422(ra) # 57ea <exit>

0000000000001998 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1998:	7139                	addi	sp,sp,-64
    199a:	fc06                	sd	ra,56(sp)
    199c:	f822                	sd	s0,48(sp)
    199e:	f426                	sd	s1,40(sp)
    19a0:	f04a                	sd	s2,32(sp)
    19a2:	ec4e                	sd	s3,24(sp)
    19a4:	0080                	addi	s0,sp,64
    19a6:	64b1                	lui	s1,0xc
    19a8:	35048493          	addi	s1,s1,848 # c350 <buf+0x868>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    19ac:	597d                	li	s2,-1
    19ae:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    19b2:	00004997          	auipc	s3,0x4
    19b6:	70698993          	addi	s3,s3,1798 # 60b8 <malloc+0x480>
    argv[0] = (char*)0xffffffff;
    19ba:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    19be:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    19c2:	fc040593          	addi	a1,s0,-64
    19c6:	854e                	mv	a0,s3
    19c8:	00004097          	auipc	ra,0x4
    19cc:	e5a080e7          	jalr	-422(ra) # 5822 <exec>
  for(int i = 0; i < 50000; i++){
    19d0:	34fd                	addiw	s1,s1,-1
    19d2:	f4e5                	bnez	s1,19ba <badarg+0x22>
  }
  
  exit(0);
    19d4:	4501                	li	a0,0
    19d6:	00004097          	auipc	ra,0x4
    19da:	e14080e7          	jalr	-492(ra) # 57ea <exit>

00000000000019de <copyinstr3>:
{
    19de:	7179                	addi	sp,sp,-48
    19e0:	f406                	sd	ra,40(sp)
    19e2:	f022                	sd	s0,32(sp)
    19e4:	ec26                	sd	s1,24(sp)
    19e6:	1800                	addi	s0,sp,48
  sbrk(8192);
    19e8:	6509                	lui	a0,0x2
    19ea:	00004097          	auipc	ra,0x4
    19ee:	e88080e7          	jalr	-376(ra) # 5872 <sbrk>
  uint64 top = (uint64) sbrk(0);
    19f2:	4501                	li	a0,0
    19f4:	00004097          	auipc	ra,0x4
    19f8:	e7e080e7          	jalr	-386(ra) # 5872 <sbrk>
  if((top % PGSIZE) != 0){
    19fc:	03451793          	slli	a5,a0,0x34
    1a00:	e3c9                	bnez	a5,1a82 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    1a02:	4501                	li	a0,0
    1a04:	00004097          	auipc	ra,0x4
    1a08:	e6e080e7          	jalr	-402(ra) # 5872 <sbrk>
  if(top % PGSIZE){
    1a0c:	03451793          	slli	a5,a0,0x34
    1a10:	e3d9                	bnez	a5,1a96 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    1a12:	fff50493          	addi	s1,a0,-1 # 1fff <fourteen+0x13f>
  *b = 'x';
    1a16:	07800793          	li	a5,120
    1a1a:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    1a1e:	8526                	mv	a0,s1
    1a20:	00004097          	auipc	ra,0x4
    1a24:	e1a080e7          	jalr	-486(ra) # 583a <unlink>
  if(ret != -1){
    1a28:	57fd                	li	a5,-1
    1a2a:	08f51363          	bne	a0,a5,1ab0 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    1a2e:	20100593          	li	a1,513
    1a32:	8526                	mv	a0,s1
    1a34:	00004097          	auipc	ra,0x4
    1a38:	df6080e7          	jalr	-522(ra) # 582a <open>
  if(fd != -1){
    1a3c:	57fd                	li	a5,-1
    1a3e:	08f51863          	bne	a0,a5,1ace <copyinstr3+0xf0>
  ret = link(b, b);
    1a42:	85a6                	mv	a1,s1
    1a44:	8526                	mv	a0,s1
    1a46:	00004097          	auipc	ra,0x4
    1a4a:	e04080e7          	jalr	-508(ra) # 584a <link>
  if(ret != -1){
    1a4e:	57fd                	li	a5,-1
    1a50:	08f51e63          	bne	a0,a5,1aec <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    1a54:	00006797          	auipc	a5,0x6
    1a58:	a0c78793          	addi	a5,a5,-1524 # 7460 <malloc+0x1828>
    1a5c:	fcf43823          	sd	a5,-48(s0)
    1a60:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1a64:	fd040593          	addi	a1,s0,-48
    1a68:	8526                	mv	a0,s1
    1a6a:	00004097          	auipc	ra,0x4
    1a6e:	db8080e7          	jalr	-584(ra) # 5822 <exec>
  if(ret != -1){
    1a72:	57fd                	li	a5,-1
    1a74:	08f51c63          	bne	a0,a5,1b0c <copyinstr3+0x12e>
}
    1a78:	70a2                	ld	ra,40(sp)
    1a7a:	7402                	ld	s0,32(sp)
    1a7c:	64e2                	ld	s1,24(sp)
    1a7e:	6145                	addi	sp,sp,48
    1a80:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1a82:	0347d513          	srli	a0,a5,0x34
    1a86:	6785                	lui	a5,0x1
    1a88:	40a7853b          	subw	a0,a5,a0
    1a8c:	00004097          	auipc	ra,0x4
    1a90:	de6080e7          	jalr	-538(ra) # 5872 <sbrk>
    1a94:	b7bd                	j	1a02 <copyinstr3+0x24>
    printf("oops\n");
    1a96:	00005517          	auipc	a0,0x5
    1a9a:	ed250513          	addi	a0,a0,-302 # 6968 <malloc+0xd30>
    1a9e:	00004097          	auipc	ra,0x4
    1aa2:	0dc080e7          	jalr	220(ra) # 5b7a <printf>
    exit(1);
    1aa6:	4505                	li	a0,1
    1aa8:	00004097          	auipc	ra,0x4
    1aac:	d42080e7          	jalr	-702(ra) # 57ea <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1ab0:	862a                	mv	a2,a0
    1ab2:	85a6                	mv	a1,s1
    1ab4:	00005517          	auipc	a0,0x5
    1ab8:	bf450513          	addi	a0,a0,-1036 # 66a8 <malloc+0xa70>
    1abc:	00004097          	auipc	ra,0x4
    1ac0:	0be080e7          	jalr	190(ra) # 5b7a <printf>
    exit(1);
    1ac4:	4505                	li	a0,1
    1ac6:	00004097          	auipc	ra,0x4
    1aca:	d24080e7          	jalr	-732(ra) # 57ea <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1ace:	862a                	mv	a2,a0
    1ad0:	85a6                	mv	a1,s1
    1ad2:	00005517          	auipc	a0,0x5
    1ad6:	bf650513          	addi	a0,a0,-1034 # 66c8 <malloc+0xa90>
    1ada:	00004097          	auipc	ra,0x4
    1ade:	0a0080e7          	jalr	160(ra) # 5b7a <printf>
    exit(1);
    1ae2:	4505                	li	a0,1
    1ae4:	00004097          	auipc	ra,0x4
    1ae8:	d06080e7          	jalr	-762(ra) # 57ea <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1aec:	86aa                	mv	a3,a0
    1aee:	8626                	mv	a2,s1
    1af0:	85a6                	mv	a1,s1
    1af2:	00005517          	auipc	a0,0x5
    1af6:	bf650513          	addi	a0,a0,-1034 # 66e8 <malloc+0xab0>
    1afa:	00004097          	auipc	ra,0x4
    1afe:	080080e7          	jalr	128(ra) # 5b7a <printf>
    exit(1);
    1b02:	4505                	li	a0,1
    1b04:	00004097          	auipc	ra,0x4
    1b08:	ce6080e7          	jalr	-794(ra) # 57ea <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1b0c:	567d                	li	a2,-1
    1b0e:	85a6                	mv	a1,s1
    1b10:	00005517          	auipc	a0,0x5
    1b14:	c0050513          	addi	a0,a0,-1024 # 6710 <malloc+0xad8>
    1b18:	00004097          	auipc	ra,0x4
    1b1c:	062080e7          	jalr	98(ra) # 5b7a <printf>
    exit(1);
    1b20:	4505                	li	a0,1
    1b22:	00004097          	auipc	ra,0x4
    1b26:	cc8080e7          	jalr	-824(ra) # 57ea <exit>

0000000000001b2a <rwsbrk>:
{
    1b2a:	1101                	addi	sp,sp,-32
    1b2c:	ec06                	sd	ra,24(sp)
    1b2e:	e822                	sd	s0,16(sp)
    1b30:	e426                	sd	s1,8(sp)
    1b32:	e04a                	sd	s2,0(sp)
    1b34:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    1b36:	6509                	lui	a0,0x2
    1b38:	00004097          	auipc	ra,0x4
    1b3c:	d3a080e7          	jalr	-710(ra) # 5872 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    1b40:	57fd                	li	a5,-1
    1b42:	06f50363          	beq	a0,a5,1ba8 <rwsbrk+0x7e>
    1b46:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    1b48:	7579                	lui	a0,0xffffe
    1b4a:	00004097          	auipc	ra,0x4
    1b4e:	d28080e7          	jalr	-728(ra) # 5872 <sbrk>
    1b52:	57fd                	li	a5,-1
    1b54:	06f50763          	beq	a0,a5,1bc2 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    1b58:	20100593          	li	a1,513
    1b5c:	00004517          	auipc	a0,0x4
    1b60:	23450513          	addi	a0,a0,564 # 5d90 <malloc+0x158>
    1b64:	00004097          	auipc	ra,0x4
    1b68:	cc6080e7          	jalr	-826(ra) # 582a <open>
    1b6c:	892a                	mv	s2,a0
  if(fd < 0){
    1b6e:	06054763          	bltz	a0,1bdc <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    1b72:	6505                	lui	a0,0x1
    1b74:	94aa                	add	s1,s1,a0
    1b76:	40000613          	li	a2,1024
    1b7a:	85a6                	mv	a1,s1
    1b7c:	854a                	mv	a0,s2
    1b7e:	00004097          	auipc	ra,0x4
    1b82:	c8c080e7          	jalr	-884(ra) # 580a <write>
    1b86:	862a                	mv	a2,a0
  if(n >= 0){
    1b88:	06054763          	bltz	a0,1bf6 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    1b8c:	85a6                	mv	a1,s1
    1b8e:	00005517          	auipc	a0,0x5
    1b92:	e3250513          	addi	a0,a0,-462 # 69c0 <malloc+0xd88>
    1b96:	00004097          	auipc	ra,0x4
    1b9a:	fe4080e7          	jalr	-28(ra) # 5b7a <printf>
    exit(1);
    1b9e:	4505                	li	a0,1
    1ba0:	00004097          	auipc	ra,0x4
    1ba4:	c4a080e7          	jalr	-950(ra) # 57ea <exit>
    printf("sbrk(rwsbrk) failed\n");
    1ba8:	00005517          	auipc	a0,0x5
    1bac:	dc850513          	addi	a0,a0,-568 # 6970 <malloc+0xd38>
    1bb0:	00004097          	auipc	ra,0x4
    1bb4:	fca080e7          	jalr	-54(ra) # 5b7a <printf>
    exit(1);
    1bb8:	4505                	li	a0,1
    1bba:	00004097          	auipc	ra,0x4
    1bbe:	c30080e7          	jalr	-976(ra) # 57ea <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    1bc2:	00005517          	auipc	a0,0x5
    1bc6:	dc650513          	addi	a0,a0,-570 # 6988 <malloc+0xd50>
    1bca:	00004097          	auipc	ra,0x4
    1bce:	fb0080e7          	jalr	-80(ra) # 5b7a <printf>
    exit(1);
    1bd2:	4505                	li	a0,1
    1bd4:	00004097          	auipc	ra,0x4
    1bd8:	c16080e7          	jalr	-1002(ra) # 57ea <exit>
    printf("open(rwsbrk) failed\n");
    1bdc:	00005517          	auipc	a0,0x5
    1be0:	dcc50513          	addi	a0,a0,-564 # 69a8 <malloc+0xd70>
    1be4:	00004097          	auipc	ra,0x4
    1be8:	f96080e7          	jalr	-106(ra) # 5b7a <printf>
    exit(1);
    1bec:	4505                	li	a0,1
    1bee:	00004097          	auipc	ra,0x4
    1bf2:	bfc080e7          	jalr	-1028(ra) # 57ea <exit>
  close(fd);
    1bf6:	854a                	mv	a0,s2
    1bf8:	00004097          	auipc	ra,0x4
    1bfc:	c1a080e7          	jalr	-998(ra) # 5812 <close>
  unlink("rwsbrk");
    1c00:	00004517          	auipc	a0,0x4
    1c04:	19050513          	addi	a0,a0,400 # 5d90 <malloc+0x158>
    1c08:	00004097          	auipc	ra,0x4
    1c0c:	c32080e7          	jalr	-974(ra) # 583a <unlink>
  fd = open("README", O_RDONLY);
    1c10:	4581                	li	a1,0
    1c12:	00004517          	auipc	a0,0x4
    1c16:	64e50513          	addi	a0,a0,1614 # 6260 <malloc+0x628>
    1c1a:	00004097          	auipc	ra,0x4
    1c1e:	c10080e7          	jalr	-1008(ra) # 582a <open>
    1c22:	892a                	mv	s2,a0
  if(fd < 0){
    1c24:	02054963          	bltz	a0,1c56 <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    1c28:	4629                	li	a2,10
    1c2a:	85a6                	mv	a1,s1
    1c2c:	00004097          	auipc	ra,0x4
    1c30:	bd6080e7          	jalr	-1066(ra) # 5802 <read>
    1c34:	862a                	mv	a2,a0
  if(n >= 0){
    1c36:	02054d63          	bltz	a0,1c70 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    1c3a:	85a6                	mv	a1,s1
    1c3c:	00005517          	auipc	a0,0x5
    1c40:	db450513          	addi	a0,a0,-588 # 69f0 <malloc+0xdb8>
    1c44:	00004097          	auipc	ra,0x4
    1c48:	f36080e7          	jalr	-202(ra) # 5b7a <printf>
    exit(1);
    1c4c:	4505                	li	a0,1
    1c4e:	00004097          	auipc	ra,0x4
    1c52:	b9c080e7          	jalr	-1124(ra) # 57ea <exit>
    printf("open(rwsbrk) failed\n");
    1c56:	00005517          	auipc	a0,0x5
    1c5a:	d5250513          	addi	a0,a0,-686 # 69a8 <malloc+0xd70>
    1c5e:	00004097          	auipc	ra,0x4
    1c62:	f1c080e7          	jalr	-228(ra) # 5b7a <printf>
    exit(1);
    1c66:	4505                	li	a0,1
    1c68:	00004097          	auipc	ra,0x4
    1c6c:	b82080e7          	jalr	-1150(ra) # 57ea <exit>
  close(fd);
    1c70:	854a                	mv	a0,s2
    1c72:	00004097          	auipc	ra,0x4
    1c76:	ba0080e7          	jalr	-1120(ra) # 5812 <close>
  exit(0);
    1c7a:	4501                	li	a0,0
    1c7c:	00004097          	auipc	ra,0x4
    1c80:	b6e080e7          	jalr	-1170(ra) # 57ea <exit>

0000000000001c84 <sbrkarg>:
{
    1c84:	7179                	addi	sp,sp,-48
    1c86:	f406                	sd	ra,40(sp)
    1c88:	f022                	sd	s0,32(sp)
    1c8a:	ec26                	sd	s1,24(sp)
    1c8c:	e84a                	sd	s2,16(sp)
    1c8e:	e44e                	sd	s3,8(sp)
    1c90:	1800                	addi	s0,sp,48
    1c92:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    1c94:	6505                	lui	a0,0x1
    1c96:	00004097          	auipc	ra,0x4
    1c9a:	bdc080e7          	jalr	-1060(ra) # 5872 <sbrk>
    1c9e:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    1ca0:	20100593          	li	a1,513
    1ca4:	00005517          	auipc	a0,0x5
    1ca8:	d7450513          	addi	a0,a0,-652 # 6a18 <malloc+0xde0>
    1cac:	00004097          	auipc	ra,0x4
    1cb0:	b7e080e7          	jalr	-1154(ra) # 582a <open>
    1cb4:	84aa                	mv	s1,a0
  unlink("sbrk");
    1cb6:	00005517          	auipc	a0,0x5
    1cba:	d6250513          	addi	a0,a0,-670 # 6a18 <malloc+0xde0>
    1cbe:	00004097          	auipc	ra,0x4
    1cc2:	b7c080e7          	jalr	-1156(ra) # 583a <unlink>
  if(fd < 0)  {
    1cc6:	0404c163          	bltz	s1,1d08 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    1cca:	6605                	lui	a2,0x1
    1ccc:	85ca                	mv	a1,s2
    1cce:	8526                	mv	a0,s1
    1cd0:	00004097          	auipc	ra,0x4
    1cd4:	b3a080e7          	jalr	-1222(ra) # 580a <write>
    1cd8:	04054663          	bltz	a0,1d24 <sbrkarg+0xa0>
  close(fd);
    1cdc:	8526                	mv	a0,s1
    1cde:	00004097          	auipc	ra,0x4
    1ce2:	b34080e7          	jalr	-1228(ra) # 5812 <close>
  a = sbrk(PGSIZE);
    1ce6:	6505                	lui	a0,0x1
    1ce8:	00004097          	auipc	ra,0x4
    1cec:	b8a080e7          	jalr	-1142(ra) # 5872 <sbrk>
  if(pipe((int *) a) != 0){
    1cf0:	00004097          	auipc	ra,0x4
    1cf4:	b0a080e7          	jalr	-1270(ra) # 57fa <pipe>
    1cf8:	e521                	bnez	a0,1d40 <sbrkarg+0xbc>
}
    1cfa:	70a2                	ld	ra,40(sp)
    1cfc:	7402                	ld	s0,32(sp)
    1cfe:	64e2                	ld	s1,24(sp)
    1d00:	6942                	ld	s2,16(sp)
    1d02:	69a2                	ld	s3,8(sp)
    1d04:	6145                	addi	sp,sp,48
    1d06:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    1d08:	85ce                	mv	a1,s3
    1d0a:	00005517          	auipc	a0,0x5
    1d0e:	d1650513          	addi	a0,a0,-746 # 6a20 <malloc+0xde8>
    1d12:	00004097          	auipc	ra,0x4
    1d16:	e68080e7          	jalr	-408(ra) # 5b7a <printf>
    exit(1);
    1d1a:	4505                	li	a0,1
    1d1c:	00004097          	auipc	ra,0x4
    1d20:	ace080e7          	jalr	-1330(ra) # 57ea <exit>
    printf("%s: write sbrk failed\n", s);
    1d24:	85ce                	mv	a1,s3
    1d26:	00005517          	auipc	a0,0x5
    1d2a:	d1250513          	addi	a0,a0,-750 # 6a38 <malloc+0xe00>
    1d2e:	00004097          	auipc	ra,0x4
    1d32:	e4c080e7          	jalr	-436(ra) # 5b7a <printf>
    exit(1);
    1d36:	4505                	li	a0,1
    1d38:	00004097          	auipc	ra,0x4
    1d3c:	ab2080e7          	jalr	-1358(ra) # 57ea <exit>
    printf("%s: pipe() failed\n", s);
    1d40:	85ce                	mv	a1,s3
    1d42:	00004517          	auipc	a0,0x4
    1d46:	65e50513          	addi	a0,a0,1630 # 63a0 <malloc+0x768>
    1d4a:	00004097          	auipc	ra,0x4
    1d4e:	e30080e7          	jalr	-464(ra) # 5b7a <printf>
    exit(1);
    1d52:	4505                	li	a0,1
    1d54:	00004097          	auipc	ra,0x4
    1d58:	a96080e7          	jalr	-1386(ra) # 57ea <exit>

0000000000001d5c <argptest>:
{
    1d5c:	1101                	addi	sp,sp,-32
    1d5e:	ec06                	sd	ra,24(sp)
    1d60:	e822                	sd	s0,16(sp)
    1d62:	e426                	sd	s1,8(sp)
    1d64:	e04a                	sd	s2,0(sp)
    1d66:	1000                	addi	s0,sp,32
    1d68:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    1d6a:	4581                	li	a1,0
    1d6c:	00005517          	auipc	a0,0x5
    1d70:	ce450513          	addi	a0,a0,-796 # 6a50 <malloc+0xe18>
    1d74:	00004097          	auipc	ra,0x4
    1d78:	ab6080e7          	jalr	-1354(ra) # 582a <open>
  if (fd < 0) {
    1d7c:	02054b63          	bltz	a0,1db2 <argptest+0x56>
    1d80:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    1d82:	4501                	li	a0,0
    1d84:	00004097          	auipc	ra,0x4
    1d88:	aee080e7          	jalr	-1298(ra) # 5872 <sbrk>
    1d8c:	567d                	li	a2,-1
    1d8e:	fff50593          	addi	a1,a0,-1
    1d92:	8526                	mv	a0,s1
    1d94:	00004097          	auipc	ra,0x4
    1d98:	a6e080e7          	jalr	-1426(ra) # 5802 <read>
  close(fd);
    1d9c:	8526                	mv	a0,s1
    1d9e:	00004097          	auipc	ra,0x4
    1da2:	a74080e7          	jalr	-1420(ra) # 5812 <close>
}
    1da6:	60e2                	ld	ra,24(sp)
    1da8:	6442                	ld	s0,16(sp)
    1daa:	64a2                	ld	s1,8(sp)
    1dac:	6902                	ld	s2,0(sp)
    1dae:	6105                	addi	sp,sp,32
    1db0:	8082                	ret
    printf("%s: open failed\n", s);
    1db2:	85ca                	mv	a1,s2
    1db4:	00005517          	auipc	a0,0x5
    1db8:	a3c50513          	addi	a0,a0,-1476 # 67f0 <malloc+0xbb8>
    1dbc:	00004097          	auipc	ra,0x4
    1dc0:	dbe080e7          	jalr	-578(ra) # 5b7a <printf>
    exit(1);
    1dc4:	4505                	li	a0,1
    1dc6:	00004097          	auipc	ra,0x4
    1dca:	a24080e7          	jalr	-1500(ra) # 57ea <exit>

0000000000001dce <openiputtest>:
{
    1dce:	7179                	addi	sp,sp,-48
    1dd0:	f406                	sd	ra,40(sp)
    1dd2:	f022                	sd	s0,32(sp)
    1dd4:	ec26                	sd	s1,24(sp)
    1dd6:	1800                	addi	s0,sp,48
    1dd8:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    1dda:	00005517          	auipc	a0,0x5
    1dde:	c7e50513          	addi	a0,a0,-898 # 6a58 <malloc+0xe20>
    1de2:	00004097          	auipc	ra,0x4
    1de6:	a70080e7          	jalr	-1424(ra) # 5852 <mkdir>
    1dea:	04054263          	bltz	a0,1e2e <openiputtest+0x60>
  pid = fork();
    1dee:	00004097          	auipc	ra,0x4
    1df2:	9f4080e7          	jalr	-1548(ra) # 57e2 <fork>
  if(pid < 0){
    1df6:	04054a63          	bltz	a0,1e4a <openiputtest+0x7c>
  if(pid == 0){
    1dfa:	e93d                	bnez	a0,1e70 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    1dfc:	4589                	li	a1,2
    1dfe:	00005517          	auipc	a0,0x5
    1e02:	c5a50513          	addi	a0,a0,-934 # 6a58 <malloc+0xe20>
    1e06:	00004097          	auipc	ra,0x4
    1e0a:	a24080e7          	jalr	-1500(ra) # 582a <open>
    if(fd >= 0){
    1e0e:	04054c63          	bltz	a0,1e66 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    1e12:	85a6                	mv	a1,s1
    1e14:	00005517          	auipc	a0,0x5
    1e18:	c6450513          	addi	a0,a0,-924 # 6a78 <malloc+0xe40>
    1e1c:	00004097          	auipc	ra,0x4
    1e20:	d5e080e7          	jalr	-674(ra) # 5b7a <printf>
      exit(1);
    1e24:	4505                	li	a0,1
    1e26:	00004097          	auipc	ra,0x4
    1e2a:	9c4080e7          	jalr	-1596(ra) # 57ea <exit>
    printf("%s: mkdir oidir failed\n", s);
    1e2e:	85a6                	mv	a1,s1
    1e30:	00005517          	auipc	a0,0x5
    1e34:	c3050513          	addi	a0,a0,-976 # 6a60 <malloc+0xe28>
    1e38:	00004097          	auipc	ra,0x4
    1e3c:	d42080e7          	jalr	-702(ra) # 5b7a <printf>
    exit(1);
    1e40:	4505                	li	a0,1
    1e42:	00004097          	auipc	ra,0x4
    1e46:	9a8080e7          	jalr	-1624(ra) # 57ea <exit>
    printf("%s: fork failed\n", s);
    1e4a:	85a6                	mv	a1,s1
    1e4c:	00004517          	auipc	a0,0x4
    1e50:	15c50513          	addi	a0,a0,348 # 5fa8 <malloc+0x370>
    1e54:	00004097          	auipc	ra,0x4
    1e58:	d26080e7          	jalr	-730(ra) # 5b7a <printf>
    exit(1);
    1e5c:	4505                	li	a0,1
    1e5e:	00004097          	auipc	ra,0x4
    1e62:	98c080e7          	jalr	-1652(ra) # 57ea <exit>
    exit(0);
    1e66:	4501                	li	a0,0
    1e68:	00004097          	auipc	ra,0x4
    1e6c:	982080e7          	jalr	-1662(ra) # 57ea <exit>
  sleep(1);
    1e70:	4505                	li	a0,1
    1e72:	00004097          	auipc	ra,0x4
    1e76:	a08080e7          	jalr	-1528(ra) # 587a <sleep>
  if(unlink("oidir") != 0){
    1e7a:	00005517          	auipc	a0,0x5
    1e7e:	bde50513          	addi	a0,a0,-1058 # 6a58 <malloc+0xe20>
    1e82:	00004097          	auipc	ra,0x4
    1e86:	9b8080e7          	jalr	-1608(ra) # 583a <unlink>
    1e8a:	cd19                	beqz	a0,1ea8 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    1e8c:	85a6                	mv	a1,s1
    1e8e:	00005517          	auipc	a0,0x5
    1e92:	c1250513          	addi	a0,a0,-1006 # 6aa0 <malloc+0xe68>
    1e96:	00004097          	auipc	ra,0x4
    1e9a:	ce4080e7          	jalr	-796(ra) # 5b7a <printf>
    exit(1);
    1e9e:	4505                	li	a0,1
    1ea0:	00004097          	auipc	ra,0x4
    1ea4:	94a080e7          	jalr	-1718(ra) # 57ea <exit>
  wait(&xstatus);
    1ea8:	fdc40513          	addi	a0,s0,-36
    1eac:	00004097          	auipc	ra,0x4
    1eb0:	946080e7          	jalr	-1722(ra) # 57f2 <wait>
  exit(xstatus);
    1eb4:	fdc42503          	lw	a0,-36(s0)
    1eb8:	00004097          	auipc	ra,0x4
    1ebc:	932080e7          	jalr	-1742(ra) # 57ea <exit>

0000000000001ec0 <fourteen>:
{
    1ec0:	1101                	addi	sp,sp,-32
    1ec2:	ec06                	sd	ra,24(sp)
    1ec4:	e822                	sd	s0,16(sp)
    1ec6:	e426                	sd	s1,8(sp)
    1ec8:	1000                	addi	s0,sp,32
    1eca:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    1ecc:	00005517          	auipc	a0,0x5
    1ed0:	dbc50513          	addi	a0,a0,-580 # 6c88 <malloc+0x1050>
    1ed4:	00004097          	auipc	ra,0x4
    1ed8:	97e080e7          	jalr	-1666(ra) # 5852 <mkdir>
    1edc:	e165                	bnez	a0,1fbc <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    1ede:	00005517          	auipc	a0,0x5
    1ee2:	c0250513          	addi	a0,a0,-1022 # 6ae0 <malloc+0xea8>
    1ee6:	00004097          	auipc	ra,0x4
    1eea:	96c080e7          	jalr	-1684(ra) # 5852 <mkdir>
    1eee:	e56d                	bnez	a0,1fd8 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    1ef0:	20000593          	li	a1,512
    1ef4:	00005517          	auipc	a0,0x5
    1ef8:	c4450513          	addi	a0,a0,-956 # 6b38 <malloc+0xf00>
    1efc:	00004097          	auipc	ra,0x4
    1f00:	92e080e7          	jalr	-1746(ra) # 582a <open>
  if(fd < 0){
    1f04:	0e054863          	bltz	a0,1ff4 <fourteen+0x134>
  close(fd);
    1f08:	00004097          	auipc	ra,0x4
    1f0c:	90a080e7          	jalr	-1782(ra) # 5812 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    1f10:	4581                	li	a1,0
    1f12:	00005517          	auipc	a0,0x5
    1f16:	c9e50513          	addi	a0,a0,-866 # 6bb0 <malloc+0xf78>
    1f1a:	00004097          	auipc	ra,0x4
    1f1e:	910080e7          	jalr	-1776(ra) # 582a <open>
  if(fd < 0){
    1f22:	0e054763          	bltz	a0,2010 <fourteen+0x150>
  close(fd);
    1f26:	00004097          	auipc	ra,0x4
    1f2a:	8ec080e7          	jalr	-1812(ra) # 5812 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    1f2e:	00005517          	auipc	a0,0x5
    1f32:	cf250513          	addi	a0,a0,-782 # 6c20 <malloc+0xfe8>
    1f36:	00004097          	auipc	ra,0x4
    1f3a:	91c080e7          	jalr	-1764(ra) # 5852 <mkdir>
    1f3e:	c57d                	beqz	a0,202c <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    1f40:	00005517          	auipc	a0,0x5
    1f44:	d3850513          	addi	a0,a0,-712 # 6c78 <malloc+0x1040>
    1f48:	00004097          	auipc	ra,0x4
    1f4c:	90a080e7          	jalr	-1782(ra) # 5852 <mkdir>
    1f50:	cd65                	beqz	a0,2048 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    1f52:	00005517          	auipc	a0,0x5
    1f56:	d2650513          	addi	a0,a0,-730 # 6c78 <malloc+0x1040>
    1f5a:	00004097          	auipc	ra,0x4
    1f5e:	8e0080e7          	jalr	-1824(ra) # 583a <unlink>
  unlink("12345678901234/12345678901234");
    1f62:	00005517          	auipc	a0,0x5
    1f66:	cbe50513          	addi	a0,a0,-834 # 6c20 <malloc+0xfe8>
    1f6a:	00004097          	auipc	ra,0x4
    1f6e:	8d0080e7          	jalr	-1840(ra) # 583a <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    1f72:	00005517          	auipc	a0,0x5
    1f76:	c3e50513          	addi	a0,a0,-962 # 6bb0 <malloc+0xf78>
    1f7a:	00004097          	auipc	ra,0x4
    1f7e:	8c0080e7          	jalr	-1856(ra) # 583a <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    1f82:	00005517          	auipc	a0,0x5
    1f86:	bb650513          	addi	a0,a0,-1098 # 6b38 <malloc+0xf00>
    1f8a:	00004097          	auipc	ra,0x4
    1f8e:	8b0080e7          	jalr	-1872(ra) # 583a <unlink>
  unlink("12345678901234/123456789012345");
    1f92:	00005517          	auipc	a0,0x5
    1f96:	b4e50513          	addi	a0,a0,-1202 # 6ae0 <malloc+0xea8>
    1f9a:	00004097          	auipc	ra,0x4
    1f9e:	8a0080e7          	jalr	-1888(ra) # 583a <unlink>
  unlink("12345678901234");
    1fa2:	00005517          	auipc	a0,0x5
    1fa6:	ce650513          	addi	a0,a0,-794 # 6c88 <malloc+0x1050>
    1faa:	00004097          	auipc	ra,0x4
    1fae:	890080e7          	jalr	-1904(ra) # 583a <unlink>
}
    1fb2:	60e2                	ld	ra,24(sp)
    1fb4:	6442                	ld	s0,16(sp)
    1fb6:	64a2                	ld	s1,8(sp)
    1fb8:	6105                	addi	sp,sp,32
    1fba:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    1fbc:	85a6                	mv	a1,s1
    1fbe:	00005517          	auipc	a0,0x5
    1fc2:	afa50513          	addi	a0,a0,-1286 # 6ab8 <malloc+0xe80>
    1fc6:	00004097          	auipc	ra,0x4
    1fca:	bb4080e7          	jalr	-1100(ra) # 5b7a <printf>
    exit(1);
    1fce:	4505                	li	a0,1
    1fd0:	00004097          	auipc	ra,0x4
    1fd4:	81a080e7          	jalr	-2022(ra) # 57ea <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    1fd8:	85a6                	mv	a1,s1
    1fda:	00005517          	auipc	a0,0x5
    1fde:	b2650513          	addi	a0,a0,-1242 # 6b00 <malloc+0xec8>
    1fe2:	00004097          	auipc	ra,0x4
    1fe6:	b98080e7          	jalr	-1128(ra) # 5b7a <printf>
    exit(1);
    1fea:	4505                	li	a0,1
    1fec:	00003097          	auipc	ra,0x3
    1ff0:	7fe080e7          	jalr	2046(ra) # 57ea <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    1ff4:	85a6                	mv	a1,s1
    1ff6:	00005517          	auipc	a0,0x5
    1ffa:	b7250513          	addi	a0,a0,-1166 # 6b68 <malloc+0xf30>
    1ffe:	00004097          	auipc	ra,0x4
    2002:	b7c080e7          	jalr	-1156(ra) # 5b7a <printf>
    exit(1);
    2006:	4505                	li	a0,1
    2008:	00003097          	auipc	ra,0x3
    200c:	7e2080e7          	jalr	2018(ra) # 57ea <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2010:	85a6                	mv	a1,s1
    2012:	00005517          	auipc	a0,0x5
    2016:	bce50513          	addi	a0,a0,-1074 # 6be0 <malloc+0xfa8>
    201a:	00004097          	auipc	ra,0x4
    201e:	b60080e7          	jalr	-1184(ra) # 5b7a <printf>
    exit(1);
    2022:	4505                	li	a0,1
    2024:	00003097          	auipc	ra,0x3
    2028:	7c6080e7          	jalr	1990(ra) # 57ea <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    202c:	85a6                	mv	a1,s1
    202e:	00005517          	auipc	a0,0x5
    2032:	c1250513          	addi	a0,a0,-1006 # 6c40 <malloc+0x1008>
    2036:	00004097          	auipc	ra,0x4
    203a:	b44080e7          	jalr	-1212(ra) # 5b7a <printf>
    exit(1);
    203e:	4505                	li	a0,1
    2040:	00003097          	auipc	ra,0x3
    2044:	7aa080e7          	jalr	1962(ra) # 57ea <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2048:	85a6                	mv	a1,s1
    204a:	00005517          	auipc	a0,0x5
    204e:	c4e50513          	addi	a0,a0,-946 # 6c98 <malloc+0x1060>
    2052:	00004097          	auipc	ra,0x4
    2056:	b28080e7          	jalr	-1240(ra) # 5b7a <printf>
    exit(1);
    205a:	4505                	li	a0,1
    205c:	00003097          	auipc	ra,0x3
    2060:	78e080e7          	jalr	1934(ra) # 57ea <exit>

0000000000002064 <iputtest>:
{
    2064:	1101                	addi	sp,sp,-32
    2066:	ec06                	sd	ra,24(sp)
    2068:	e822                	sd	s0,16(sp)
    206a:	e426                	sd	s1,8(sp)
    206c:	1000                	addi	s0,sp,32
    206e:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2070:	00005517          	auipc	a0,0x5
    2074:	c6050513          	addi	a0,a0,-928 # 6cd0 <malloc+0x1098>
    2078:	00003097          	auipc	ra,0x3
    207c:	7da080e7          	jalr	2010(ra) # 5852 <mkdir>
    2080:	04054563          	bltz	a0,20ca <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2084:	00005517          	auipc	a0,0x5
    2088:	c4c50513          	addi	a0,a0,-948 # 6cd0 <malloc+0x1098>
    208c:	00003097          	auipc	ra,0x3
    2090:	7ce080e7          	jalr	1998(ra) # 585a <chdir>
    2094:	04054963          	bltz	a0,20e6 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2098:	00005517          	auipc	a0,0x5
    209c:	c7850513          	addi	a0,a0,-904 # 6d10 <malloc+0x10d8>
    20a0:	00003097          	auipc	ra,0x3
    20a4:	79a080e7          	jalr	1946(ra) # 583a <unlink>
    20a8:	04054d63          	bltz	a0,2102 <iputtest+0x9e>
  if(chdir("/") < 0){
    20ac:	00005517          	auipc	a0,0x5
    20b0:	c9450513          	addi	a0,a0,-876 # 6d40 <malloc+0x1108>
    20b4:	00003097          	auipc	ra,0x3
    20b8:	7a6080e7          	jalr	1958(ra) # 585a <chdir>
    20bc:	06054163          	bltz	a0,211e <iputtest+0xba>
}
    20c0:	60e2                	ld	ra,24(sp)
    20c2:	6442                	ld	s0,16(sp)
    20c4:	64a2                	ld	s1,8(sp)
    20c6:	6105                	addi	sp,sp,32
    20c8:	8082                	ret
    printf("%s: mkdir failed\n", s);
    20ca:	85a6                	mv	a1,s1
    20cc:	00005517          	auipc	a0,0x5
    20d0:	c0c50513          	addi	a0,a0,-1012 # 6cd8 <malloc+0x10a0>
    20d4:	00004097          	auipc	ra,0x4
    20d8:	aa6080e7          	jalr	-1370(ra) # 5b7a <printf>
    exit(1);
    20dc:	4505                	li	a0,1
    20de:	00003097          	auipc	ra,0x3
    20e2:	70c080e7          	jalr	1804(ra) # 57ea <exit>
    printf("%s: chdir iputdir failed\n", s);
    20e6:	85a6                	mv	a1,s1
    20e8:	00005517          	auipc	a0,0x5
    20ec:	c0850513          	addi	a0,a0,-1016 # 6cf0 <malloc+0x10b8>
    20f0:	00004097          	auipc	ra,0x4
    20f4:	a8a080e7          	jalr	-1398(ra) # 5b7a <printf>
    exit(1);
    20f8:	4505                	li	a0,1
    20fa:	00003097          	auipc	ra,0x3
    20fe:	6f0080e7          	jalr	1776(ra) # 57ea <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2102:	85a6                	mv	a1,s1
    2104:	00005517          	auipc	a0,0x5
    2108:	c1c50513          	addi	a0,a0,-996 # 6d20 <malloc+0x10e8>
    210c:	00004097          	auipc	ra,0x4
    2110:	a6e080e7          	jalr	-1426(ra) # 5b7a <printf>
    exit(1);
    2114:	4505                	li	a0,1
    2116:	00003097          	auipc	ra,0x3
    211a:	6d4080e7          	jalr	1748(ra) # 57ea <exit>
    printf("%s: chdir / failed\n", s);
    211e:	85a6                	mv	a1,s1
    2120:	00005517          	auipc	a0,0x5
    2124:	c2850513          	addi	a0,a0,-984 # 6d48 <malloc+0x1110>
    2128:	00004097          	auipc	ra,0x4
    212c:	a52080e7          	jalr	-1454(ra) # 5b7a <printf>
    exit(1);
    2130:	4505                	li	a0,1
    2132:	00003097          	auipc	ra,0x3
    2136:	6b8080e7          	jalr	1720(ra) # 57ea <exit>

000000000000213a <exitiputtest>:
{
    213a:	7179                	addi	sp,sp,-48
    213c:	f406                	sd	ra,40(sp)
    213e:	f022                	sd	s0,32(sp)
    2140:	ec26                	sd	s1,24(sp)
    2142:	1800                	addi	s0,sp,48
    2144:	84aa                	mv	s1,a0
  pid = fork();
    2146:	00003097          	auipc	ra,0x3
    214a:	69c080e7          	jalr	1692(ra) # 57e2 <fork>
  if(pid < 0){
    214e:	04054663          	bltz	a0,219a <exitiputtest+0x60>
  if(pid == 0){
    2152:	ed45                	bnez	a0,220a <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2154:	00005517          	auipc	a0,0x5
    2158:	b7c50513          	addi	a0,a0,-1156 # 6cd0 <malloc+0x1098>
    215c:	00003097          	auipc	ra,0x3
    2160:	6f6080e7          	jalr	1782(ra) # 5852 <mkdir>
    2164:	04054963          	bltz	a0,21b6 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2168:	00005517          	auipc	a0,0x5
    216c:	b6850513          	addi	a0,a0,-1176 # 6cd0 <malloc+0x1098>
    2170:	00003097          	auipc	ra,0x3
    2174:	6ea080e7          	jalr	1770(ra) # 585a <chdir>
    2178:	04054d63          	bltz	a0,21d2 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    217c:	00005517          	auipc	a0,0x5
    2180:	b9450513          	addi	a0,a0,-1132 # 6d10 <malloc+0x10d8>
    2184:	00003097          	auipc	ra,0x3
    2188:	6b6080e7          	jalr	1718(ra) # 583a <unlink>
    218c:	06054163          	bltz	a0,21ee <exitiputtest+0xb4>
    exit(0);
    2190:	4501                	li	a0,0
    2192:	00003097          	auipc	ra,0x3
    2196:	658080e7          	jalr	1624(ra) # 57ea <exit>
    printf("%s: fork failed\n", s);
    219a:	85a6                	mv	a1,s1
    219c:	00004517          	auipc	a0,0x4
    21a0:	e0c50513          	addi	a0,a0,-500 # 5fa8 <malloc+0x370>
    21a4:	00004097          	auipc	ra,0x4
    21a8:	9d6080e7          	jalr	-1578(ra) # 5b7a <printf>
    exit(1);
    21ac:	4505                	li	a0,1
    21ae:	00003097          	auipc	ra,0x3
    21b2:	63c080e7          	jalr	1596(ra) # 57ea <exit>
      printf("%s: mkdir failed\n", s);
    21b6:	85a6                	mv	a1,s1
    21b8:	00005517          	auipc	a0,0x5
    21bc:	b2050513          	addi	a0,a0,-1248 # 6cd8 <malloc+0x10a0>
    21c0:	00004097          	auipc	ra,0x4
    21c4:	9ba080e7          	jalr	-1606(ra) # 5b7a <printf>
      exit(1);
    21c8:	4505                	li	a0,1
    21ca:	00003097          	auipc	ra,0x3
    21ce:	620080e7          	jalr	1568(ra) # 57ea <exit>
      printf("%s: child chdir failed\n", s);
    21d2:	85a6                	mv	a1,s1
    21d4:	00005517          	auipc	a0,0x5
    21d8:	b8c50513          	addi	a0,a0,-1140 # 6d60 <malloc+0x1128>
    21dc:	00004097          	auipc	ra,0x4
    21e0:	99e080e7          	jalr	-1634(ra) # 5b7a <printf>
      exit(1);
    21e4:	4505                	li	a0,1
    21e6:	00003097          	auipc	ra,0x3
    21ea:	604080e7          	jalr	1540(ra) # 57ea <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    21ee:	85a6                	mv	a1,s1
    21f0:	00005517          	auipc	a0,0x5
    21f4:	b3050513          	addi	a0,a0,-1232 # 6d20 <malloc+0x10e8>
    21f8:	00004097          	auipc	ra,0x4
    21fc:	982080e7          	jalr	-1662(ra) # 5b7a <printf>
      exit(1);
    2200:	4505                	li	a0,1
    2202:	00003097          	auipc	ra,0x3
    2206:	5e8080e7          	jalr	1512(ra) # 57ea <exit>
  wait(&xstatus);
    220a:	fdc40513          	addi	a0,s0,-36
    220e:	00003097          	auipc	ra,0x3
    2212:	5e4080e7          	jalr	1508(ra) # 57f2 <wait>
  exit(xstatus);
    2216:	fdc42503          	lw	a0,-36(s0)
    221a:	00003097          	auipc	ra,0x3
    221e:	5d0080e7          	jalr	1488(ra) # 57ea <exit>

0000000000002222 <dirtest>:
{
    2222:	1101                	addi	sp,sp,-32
    2224:	ec06                	sd	ra,24(sp)
    2226:	e822                	sd	s0,16(sp)
    2228:	e426                	sd	s1,8(sp)
    222a:	1000                	addi	s0,sp,32
    222c:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    222e:	00005517          	auipc	a0,0x5
    2232:	b4a50513          	addi	a0,a0,-1206 # 6d78 <malloc+0x1140>
    2236:	00003097          	auipc	ra,0x3
    223a:	61c080e7          	jalr	1564(ra) # 5852 <mkdir>
    223e:	04054563          	bltz	a0,2288 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2242:	00005517          	auipc	a0,0x5
    2246:	b3650513          	addi	a0,a0,-1226 # 6d78 <malloc+0x1140>
    224a:	00003097          	auipc	ra,0x3
    224e:	610080e7          	jalr	1552(ra) # 585a <chdir>
    2252:	04054963          	bltz	a0,22a4 <dirtest+0x82>
  if(chdir("..") < 0){
    2256:	00005517          	auipc	a0,0x5
    225a:	b4250513          	addi	a0,a0,-1214 # 6d98 <malloc+0x1160>
    225e:	00003097          	auipc	ra,0x3
    2262:	5fc080e7          	jalr	1532(ra) # 585a <chdir>
    2266:	04054d63          	bltz	a0,22c0 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    226a:	00005517          	auipc	a0,0x5
    226e:	b0e50513          	addi	a0,a0,-1266 # 6d78 <malloc+0x1140>
    2272:	00003097          	auipc	ra,0x3
    2276:	5c8080e7          	jalr	1480(ra) # 583a <unlink>
    227a:	06054163          	bltz	a0,22dc <dirtest+0xba>
}
    227e:	60e2                	ld	ra,24(sp)
    2280:	6442                	ld	s0,16(sp)
    2282:	64a2                	ld	s1,8(sp)
    2284:	6105                	addi	sp,sp,32
    2286:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2288:	85a6                	mv	a1,s1
    228a:	00005517          	auipc	a0,0x5
    228e:	a4e50513          	addi	a0,a0,-1458 # 6cd8 <malloc+0x10a0>
    2292:	00004097          	auipc	ra,0x4
    2296:	8e8080e7          	jalr	-1816(ra) # 5b7a <printf>
    exit(1);
    229a:	4505                	li	a0,1
    229c:	00003097          	auipc	ra,0x3
    22a0:	54e080e7          	jalr	1358(ra) # 57ea <exit>
    printf("%s: chdir dir0 failed\n", s);
    22a4:	85a6                	mv	a1,s1
    22a6:	00005517          	auipc	a0,0x5
    22aa:	ada50513          	addi	a0,a0,-1318 # 6d80 <malloc+0x1148>
    22ae:	00004097          	auipc	ra,0x4
    22b2:	8cc080e7          	jalr	-1844(ra) # 5b7a <printf>
    exit(1);
    22b6:	4505                	li	a0,1
    22b8:	00003097          	auipc	ra,0x3
    22bc:	532080e7          	jalr	1330(ra) # 57ea <exit>
    printf("%s: chdir .. failed\n", s);
    22c0:	85a6                	mv	a1,s1
    22c2:	00005517          	auipc	a0,0x5
    22c6:	ade50513          	addi	a0,a0,-1314 # 6da0 <malloc+0x1168>
    22ca:	00004097          	auipc	ra,0x4
    22ce:	8b0080e7          	jalr	-1872(ra) # 5b7a <printf>
    exit(1);
    22d2:	4505                	li	a0,1
    22d4:	00003097          	auipc	ra,0x3
    22d8:	516080e7          	jalr	1302(ra) # 57ea <exit>
    printf("%s: unlink dir0 failed\n", s);
    22dc:	85a6                	mv	a1,s1
    22de:	00005517          	auipc	a0,0x5
    22e2:	ada50513          	addi	a0,a0,-1318 # 6db8 <malloc+0x1180>
    22e6:	00004097          	auipc	ra,0x4
    22ea:	894080e7          	jalr	-1900(ra) # 5b7a <printf>
    exit(1);
    22ee:	4505                	li	a0,1
    22f0:	00003097          	auipc	ra,0x3
    22f4:	4fa080e7          	jalr	1274(ra) # 57ea <exit>

00000000000022f8 <subdir>:
{
    22f8:	1101                	addi	sp,sp,-32
    22fa:	ec06                	sd	ra,24(sp)
    22fc:	e822                	sd	s0,16(sp)
    22fe:	e426                	sd	s1,8(sp)
    2300:	e04a                	sd	s2,0(sp)
    2302:	1000                	addi	s0,sp,32
    2304:	892a                	mv	s2,a0
  unlink("ff");
    2306:	00005517          	auipc	a0,0x5
    230a:	bfa50513          	addi	a0,a0,-1030 # 6f00 <malloc+0x12c8>
    230e:	00003097          	auipc	ra,0x3
    2312:	52c080e7          	jalr	1324(ra) # 583a <unlink>
  if(mkdir("dd") != 0){
    2316:	00005517          	auipc	a0,0x5
    231a:	aba50513          	addi	a0,a0,-1350 # 6dd0 <malloc+0x1198>
    231e:	00003097          	auipc	ra,0x3
    2322:	534080e7          	jalr	1332(ra) # 5852 <mkdir>
    2326:	38051663          	bnez	a0,26b2 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    232a:	20200593          	li	a1,514
    232e:	00005517          	auipc	a0,0x5
    2332:	ac250513          	addi	a0,a0,-1342 # 6df0 <malloc+0x11b8>
    2336:	00003097          	auipc	ra,0x3
    233a:	4f4080e7          	jalr	1268(ra) # 582a <open>
    233e:	84aa                	mv	s1,a0
  if(fd < 0){
    2340:	38054763          	bltz	a0,26ce <subdir+0x3d6>
  write(fd, "ff", 2);
    2344:	4609                	li	a2,2
    2346:	00005597          	auipc	a1,0x5
    234a:	bba58593          	addi	a1,a1,-1094 # 6f00 <malloc+0x12c8>
    234e:	00003097          	auipc	ra,0x3
    2352:	4bc080e7          	jalr	1212(ra) # 580a <write>
  close(fd);
    2356:	8526                	mv	a0,s1
    2358:	00003097          	auipc	ra,0x3
    235c:	4ba080e7          	jalr	1210(ra) # 5812 <close>
  if(unlink("dd") >= 0){
    2360:	00005517          	auipc	a0,0x5
    2364:	a7050513          	addi	a0,a0,-1424 # 6dd0 <malloc+0x1198>
    2368:	00003097          	auipc	ra,0x3
    236c:	4d2080e7          	jalr	1234(ra) # 583a <unlink>
    2370:	36055d63          	bgez	a0,26ea <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2374:	00005517          	auipc	a0,0x5
    2378:	ad450513          	addi	a0,a0,-1324 # 6e48 <malloc+0x1210>
    237c:	00003097          	auipc	ra,0x3
    2380:	4d6080e7          	jalr	1238(ra) # 5852 <mkdir>
    2384:	38051163          	bnez	a0,2706 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2388:	20200593          	li	a1,514
    238c:	00005517          	auipc	a0,0x5
    2390:	ae450513          	addi	a0,a0,-1308 # 6e70 <malloc+0x1238>
    2394:	00003097          	auipc	ra,0x3
    2398:	496080e7          	jalr	1174(ra) # 582a <open>
    239c:	84aa                	mv	s1,a0
  if(fd < 0){
    239e:	38054263          	bltz	a0,2722 <subdir+0x42a>
  write(fd, "FF", 2);
    23a2:	4609                	li	a2,2
    23a4:	00005597          	auipc	a1,0x5
    23a8:	afc58593          	addi	a1,a1,-1284 # 6ea0 <malloc+0x1268>
    23ac:	00003097          	auipc	ra,0x3
    23b0:	45e080e7          	jalr	1118(ra) # 580a <write>
  close(fd);
    23b4:	8526                	mv	a0,s1
    23b6:	00003097          	auipc	ra,0x3
    23ba:	45c080e7          	jalr	1116(ra) # 5812 <close>
  fd = open("dd/dd/../ff", 0);
    23be:	4581                	li	a1,0
    23c0:	00005517          	auipc	a0,0x5
    23c4:	ae850513          	addi	a0,a0,-1304 # 6ea8 <malloc+0x1270>
    23c8:	00003097          	auipc	ra,0x3
    23cc:	462080e7          	jalr	1122(ra) # 582a <open>
    23d0:	84aa                	mv	s1,a0
  if(fd < 0){
    23d2:	36054663          	bltz	a0,273e <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    23d6:	660d                	lui	a2,0x3
    23d8:	00009597          	auipc	a1,0x9
    23dc:	71058593          	addi	a1,a1,1808 # bae8 <buf>
    23e0:	00003097          	auipc	ra,0x3
    23e4:	422080e7          	jalr	1058(ra) # 5802 <read>
  if(cc != 2 || buf[0] != 'f'){
    23e8:	4789                	li	a5,2
    23ea:	36f51863          	bne	a0,a5,275a <subdir+0x462>
    23ee:	00009717          	auipc	a4,0x9
    23f2:	6fa74703          	lbu	a4,1786(a4) # bae8 <buf>
    23f6:	06600793          	li	a5,102
    23fa:	36f71063          	bne	a4,a5,275a <subdir+0x462>
  close(fd);
    23fe:	8526                	mv	a0,s1
    2400:	00003097          	auipc	ra,0x3
    2404:	412080e7          	jalr	1042(ra) # 5812 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2408:	00005597          	auipc	a1,0x5
    240c:	af058593          	addi	a1,a1,-1296 # 6ef8 <malloc+0x12c0>
    2410:	00005517          	auipc	a0,0x5
    2414:	a6050513          	addi	a0,a0,-1440 # 6e70 <malloc+0x1238>
    2418:	00003097          	auipc	ra,0x3
    241c:	432080e7          	jalr	1074(ra) # 584a <link>
    2420:	34051b63          	bnez	a0,2776 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    2424:	00005517          	auipc	a0,0x5
    2428:	a4c50513          	addi	a0,a0,-1460 # 6e70 <malloc+0x1238>
    242c:	00003097          	auipc	ra,0x3
    2430:	40e080e7          	jalr	1038(ra) # 583a <unlink>
    2434:	34051f63          	bnez	a0,2792 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2438:	4581                	li	a1,0
    243a:	00005517          	auipc	a0,0x5
    243e:	a3650513          	addi	a0,a0,-1482 # 6e70 <malloc+0x1238>
    2442:	00003097          	auipc	ra,0x3
    2446:	3e8080e7          	jalr	1000(ra) # 582a <open>
    244a:	36055263          	bgez	a0,27ae <subdir+0x4b6>
  if(chdir("dd") != 0){
    244e:	00005517          	auipc	a0,0x5
    2452:	98250513          	addi	a0,a0,-1662 # 6dd0 <malloc+0x1198>
    2456:	00003097          	auipc	ra,0x3
    245a:	404080e7          	jalr	1028(ra) # 585a <chdir>
    245e:	36051663          	bnez	a0,27ca <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    2462:	00005517          	auipc	a0,0x5
    2466:	b2e50513          	addi	a0,a0,-1234 # 6f90 <malloc+0x1358>
    246a:	00003097          	auipc	ra,0x3
    246e:	3f0080e7          	jalr	1008(ra) # 585a <chdir>
    2472:	36051a63          	bnez	a0,27e6 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    2476:	00005517          	auipc	a0,0x5
    247a:	b4a50513          	addi	a0,a0,-1206 # 6fc0 <malloc+0x1388>
    247e:	00003097          	auipc	ra,0x3
    2482:	3dc080e7          	jalr	988(ra) # 585a <chdir>
    2486:	36051e63          	bnez	a0,2802 <subdir+0x50a>
  if(chdir("./..") != 0){
    248a:	00005517          	auipc	a0,0x5
    248e:	b6650513          	addi	a0,a0,-1178 # 6ff0 <malloc+0x13b8>
    2492:	00003097          	auipc	ra,0x3
    2496:	3c8080e7          	jalr	968(ra) # 585a <chdir>
    249a:	38051263          	bnez	a0,281e <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    249e:	4581                	li	a1,0
    24a0:	00005517          	auipc	a0,0x5
    24a4:	a5850513          	addi	a0,a0,-1448 # 6ef8 <malloc+0x12c0>
    24a8:	00003097          	auipc	ra,0x3
    24ac:	382080e7          	jalr	898(ra) # 582a <open>
    24b0:	84aa                	mv	s1,a0
  if(fd < 0){
    24b2:	38054463          	bltz	a0,283a <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    24b6:	660d                	lui	a2,0x3
    24b8:	00009597          	auipc	a1,0x9
    24bc:	63058593          	addi	a1,a1,1584 # bae8 <buf>
    24c0:	00003097          	auipc	ra,0x3
    24c4:	342080e7          	jalr	834(ra) # 5802 <read>
    24c8:	4789                	li	a5,2
    24ca:	38f51663          	bne	a0,a5,2856 <subdir+0x55e>
  close(fd);
    24ce:	8526                	mv	a0,s1
    24d0:	00003097          	auipc	ra,0x3
    24d4:	342080e7          	jalr	834(ra) # 5812 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    24d8:	4581                	li	a1,0
    24da:	00005517          	auipc	a0,0x5
    24de:	99650513          	addi	a0,a0,-1642 # 6e70 <malloc+0x1238>
    24e2:	00003097          	auipc	ra,0x3
    24e6:	348080e7          	jalr	840(ra) # 582a <open>
    24ea:	38055463          	bgez	a0,2872 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    24ee:	20200593          	li	a1,514
    24f2:	00005517          	auipc	a0,0x5
    24f6:	b8e50513          	addi	a0,a0,-1138 # 7080 <malloc+0x1448>
    24fa:	00003097          	auipc	ra,0x3
    24fe:	330080e7          	jalr	816(ra) # 582a <open>
    2502:	38055663          	bgez	a0,288e <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2506:	20200593          	li	a1,514
    250a:	00005517          	auipc	a0,0x5
    250e:	ba650513          	addi	a0,a0,-1114 # 70b0 <malloc+0x1478>
    2512:	00003097          	auipc	ra,0x3
    2516:	318080e7          	jalr	792(ra) # 582a <open>
    251a:	38055863          	bgez	a0,28aa <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    251e:	20000593          	li	a1,512
    2522:	00005517          	auipc	a0,0x5
    2526:	8ae50513          	addi	a0,a0,-1874 # 6dd0 <malloc+0x1198>
    252a:	00003097          	auipc	ra,0x3
    252e:	300080e7          	jalr	768(ra) # 582a <open>
    2532:	38055a63          	bgez	a0,28c6 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    2536:	4589                	li	a1,2
    2538:	00005517          	auipc	a0,0x5
    253c:	89850513          	addi	a0,a0,-1896 # 6dd0 <malloc+0x1198>
    2540:	00003097          	auipc	ra,0x3
    2544:	2ea080e7          	jalr	746(ra) # 582a <open>
    2548:	38055d63          	bgez	a0,28e2 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    254c:	4585                	li	a1,1
    254e:	00005517          	auipc	a0,0x5
    2552:	88250513          	addi	a0,a0,-1918 # 6dd0 <malloc+0x1198>
    2556:	00003097          	auipc	ra,0x3
    255a:	2d4080e7          	jalr	724(ra) # 582a <open>
    255e:	3a055063          	bgez	a0,28fe <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2562:	00005597          	auipc	a1,0x5
    2566:	bde58593          	addi	a1,a1,-1058 # 7140 <malloc+0x1508>
    256a:	00005517          	auipc	a0,0x5
    256e:	b1650513          	addi	a0,a0,-1258 # 7080 <malloc+0x1448>
    2572:	00003097          	auipc	ra,0x3
    2576:	2d8080e7          	jalr	728(ra) # 584a <link>
    257a:	3a050063          	beqz	a0,291a <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    257e:	00005597          	auipc	a1,0x5
    2582:	bc258593          	addi	a1,a1,-1086 # 7140 <malloc+0x1508>
    2586:	00005517          	auipc	a0,0x5
    258a:	b2a50513          	addi	a0,a0,-1238 # 70b0 <malloc+0x1478>
    258e:	00003097          	auipc	ra,0x3
    2592:	2bc080e7          	jalr	700(ra) # 584a <link>
    2596:	3a050063          	beqz	a0,2936 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    259a:	00005597          	auipc	a1,0x5
    259e:	95e58593          	addi	a1,a1,-1698 # 6ef8 <malloc+0x12c0>
    25a2:	00005517          	auipc	a0,0x5
    25a6:	84e50513          	addi	a0,a0,-1970 # 6df0 <malloc+0x11b8>
    25aa:	00003097          	auipc	ra,0x3
    25ae:	2a0080e7          	jalr	672(ra) # 584a <link>
    25b2:	3a050063          	beqz	a0,2952 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    25b6:	00005517          	auipc	a0,0x5
    25ba:	aca50513          	addi	a0,a0,-1334 # 7080 <malloc+0x1448>
    25be:	00003097          	auipc	ra,0x3
    25c2:	294080e7          	jalr	660(ra) # 5852 <mkdir>
    25c6:	3a050463          	beqz	a0,296e <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    25ca:	00005517          	auipc	a0,0x5
    25ce:	ae650513          	addi	a0,a0,-1306 # 70b0 <malloc+0x1478>
    25d2:	00003097          	auipc	ra,0x3
    25d6:	280080e7          	jalr	640(ra) # 5852 <mkdir>
    25da:	3a050863          	beqz	a0,298a <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    25de:	00005517          	auipc	a0,0x5
    25e2:	91a50513          	addi	a0,a0,-1766 # 6ef8 <malloc+0x12c0>
    25e6:	00003097          	auipc	ra,0x3
    25ea:	26c080e7          	jalr	620(ra) # 5852 <mkdir>
    25ee:	3a050c63          	beqz	a0,29a6 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    25f2:	00005517          	auipc	a0,0x5
    25f6:	abe50513          	addi	a0,a0,-1346 # 70b0 <malloc+0x1478>
    25fa:	00003097          	auipc	ra,0x3
    25fe:	240080e7          	jalr	576(ra) # 583a <unlink>
    2602:	3c050063          	beqz	a0,29c2 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    2606:	00005517          	auipc	a0,0x5
    260a:	a7a50513          	addi	a0,a0,-1414 # 7080 <malloc+0x1448>
    260e:	00003097          	auipc	ra,0x3
    2612:	22c080e7          	jalr	556(ra) # 583a <unlink>
    2616:	3c050463          	beqz	a0,29de <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    261a:	00004517          	auipc	a0,0x4
    261e:	7d650513          	addi	a0,a0,2006 # 6df0 <malloc+0x11b8>
    2622:	00003097          	auipc	ra,0x3
    2626:	238080e7          	jalr	568(ra) # 585a <chdir>
    262a:	3c050863          	beqz	a0,29fa <subdir+0x702>
  if(chdir("dd/xx") == 0){
    262e:	00005517          	auipc	a0,0x5
    2632:	c6250513          	addi	a0,a0,-926 # 7290 <malloc+0x1658>
    2636:	00003097          	auipc	ra,0x3
    263a:	224080e7          	jalr	548(ra) # 585a <chdir>
    263e:	3c050c63          	beqz	a0,2a16 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    2642:	00005517          	auipc	a0,0x5
    2646:	8b650513          	addi	a0,a0,-1866 # 6ef8 <malloc+0x12c0>
    264a:	00003097          	auipc	ra,0x3
    264e:	1f0080e7          	jalr	496(ra) # 583a <unlink>
    2652:	3e051063          	bnez	a0,2a32 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    2656:	00004517          	auipc	a0,0x4
    265a:	79a50513          	addi	a0,a0,1946 # 6df0 <malloc+0x11b8>
    265e:	00003097          	auipc	ra,0x3
    2662:	1dc080e7          	jalr	476(ra) # 583a <unlink>
    2666:	3e051463          	bnez	a0,2a4e <subdir+0x756>
  if(unlink("dd") == 0){
    266a:	00004517          	auipc	a0,0x4
    266e:	76650513          	addi	a0,a0,1894 # 6dd0 <malloc+0x1198>
    2672:	00003097          	auipc	ra,0x3
    2676:	1c8080e7          	jalr	456(ra) # 583a <unlink>
    267a:	3e050863          	beqz	a0,2a6a <subdir+0x772>
  if(unlink("dd/dd") < 0){
    267e:	00005517          	auipc	a0,0x5
    2682:	c8250513          	addi	a0,a0,-894 # 7300 <malloc+0x16c8>
    2686:	00003097          	auipc	ra,0x3
    268a:	1b4080e7          	jalr	436(ra) # 583a <unlink>
    268e:	3e054c63          	bltz	a0,2a86 <subdir+0x78e>
  if(unlink("dd") < 0){
    2692:	00004517          	auipc	a0,0x4
    2696:	73e50513          	addi	a0,a0,1854 # 6dd0 <malloc+0x1198>
    269a:	00003097          	auipc	ra,0x3
    269e:	1a0080e7          	jalr	416(ra) # 583a <unlink>
    26a2:	40054063          	bltz	a0,2aa2 <subdir+0x7aa>
}
    26a6:	60e2                	ld	ra,24(sp)
    26a8:	6442                	ld	s0,16(sp)
    26aa:	64a2                	ld	s1,8(sp)
    26ac:	6902                	ld	s2,0(sp)
    26ae:	6105                	addi	sp,sp,32
    26b0:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    26b2:	85ca                	mv	a1,s2
    26b4:	00004517          	auipc	a0,0x4
    26b8:	72450513          	addi	a0,a0,1828 # 6dd8 <malloc+0x11a0>
    26bc:	00003097          	auipc	ra,0x3
    26c0:	4be080e7          	jalr	1214(ra) # 5b7a <printf>
    exit(1);
    26c4:	4505                	li	a0,1
    26c6:	00003097          	auipc	ra,0x3
    26ca:	124080e7          	jalr	292(ra) # 57ea <exit>
    printf("%s: create dd/ff failed\n", s);
    26ce:	85ca                	mv	a1,s2
    26d0:	00004517          	auipc	a0,0x4
    26d4:	72850513          	addi	a0,a0,1832 # 6df8 <malloc+0x11c0>
    26d8:	00003097          	auipc	ra,0x3
    26dc:	4a2080e7          	jalr	1186(ra) # 5b7a <printf>
    exit(1);
    26e0:	4505                	li	a0,1
    26e2:	00003097          	auipc	ra,0x3
    26e6:	108080e7          	jalr	264(ra) # 57ea <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    26ea:	85ca                	mv	a1,s2
    26ec:	00004517          	auipc	a0,0x4
    26f0:	72c50513          	addi	a0,a0,1836 # 6e18 <malloc+0x11e0>
    26f4:	00003097          	auipc	ra,0x3
    26f8:	486080e7          	jalr	1158(ra) # 5b7a <printf>
    exit(1);
    26fc:	4505                	li	a0,1
    26fe:	00003097          	auipc	ra,0x3
    2702:	0ec080e7          	jalr	236(ra) # 57ea <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    2706:	85ca                	mv	a1,s2
    2708:	00004517          	auipc	a0,0x4
    270c:	74850513          	addi	a0,a0,1864 # 6e50 <malloc+0x1218>
    2710:	00003097          	auipc	ra,0x3
    2714:	46a080e7          	jalr	1130(ra) # 5b7a <printf>
    exit(1);
    2718:	4505                	li	a0,1
    271a:	00003097          	auipc	ra,0x3
    271e:	0d0080e7          	jalr	208(ra) # 57ea <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    2722:	85ca                	mv	a1,s2
    2724:	00004517          	auipc	a0,0x4
    2728:	75c50513          	addi	a0,a0,1884 # 6e80 <malloc+0x1248>
    272c:	00003097          	auipc	ra,0x3
    2730:	44e080e7          	jalr	1102(ra) # 5b7a <printf>
    exit(1);
    2734:	4505                	li	a0,1
    2736:	00003097          	auipc	ra,0x3
    273a:	0b4080e7          	jalr	180(ra) # 57ea <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    273e:	85ca                	mv	a1,s2
    2740:	00004517          	auipc	a0,0x4
    2744:	77850513          	addi	a0,a0,1912 # 6eb8 <malloc+0x1280>
    2748:	00003097          	auipc	ra,0x3
    274c:	432080e7          	jalr	1074(ra) # 5b7a <printf>
    exit(1);
    2750:	4505                	li	a0,1
    2752:	00003097          	auipc	ra,0x3
    2756:	098080e7          	jalr	152(ra) # 57ea <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    275a:	85ca                	mv	a1,s2
    275c:	00004517          	auipc	a0,0x4
    2760:	77c50513          	addi	a0,a0,1916 # 6ed8 <malloc+0x12a0>
    2764:	00003097          	auipc	ra,0x3
    2768:	416080e7          	jalr	1046(ra) # 5b7a <printf>
    exit(1);
    276c:	4505                	li	a0,1
    276e:	00003097          	auipc	ra,0x3
    2772:	07c080e7          	jalr	124(ra) # 57ea <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    2776:	85ca                	mv	a1,s2
    2778:	00004517          	auipc	a0,0x4
    277c:	79050513          	addi	a0,a0,1936 # 6f08 <malloc+0x12d0>
    2780:	00003097          	auipc	ra,0x3
    2784:	3fa080e7          	jalr	1018(ra) # 5b7a <printf>
    exit(1);
    2788:	4505                	li	a0,1
    278a:	00003097          	auipc	ra,0x3
    278e:	060080e7          	jalr	96(ra) # 57ea <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2792:	85ca                	mv	a1,s2
    2794:	00004517          	auipc	a0,0x4
    2798:	79c50513          	addi	a0,a0,1948 # 6f30 <malloc+0x12f8>
    279c:	00003097          	auipc	ra,0x3
    27a0:	3de080e7          	jalr	990(ra) # 5b7a <printf>
    exit(1);
    27a4:	4505                	li	a0,1
    27a6:	00003097          	auipc	ra,0x3
    27aa:	044080e7          	jalr	68(ra) # 57ea <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    27ae:	85ca                	mv	a1,s2
    27b0:	00004517          	auipc	a0,0x4
    27b4:	7a050513          	addi	a0,a0,1952 # 6f50 <malloc+0x1318>
    27b8:	00003097          	auipc	ra,0x3
    27bc:	3c2080e7          	jalr	962(ra) # 5b7a <printf>
    exit(1);
    27c0:	4505                	li	a0,1
    27c2:	00003097          	auipc	ra,0x3
    27c6:	028080e7          	jalr	40(ra) # 57ea <exit>
    printf("%s: chdir dd failed\n", s);
    27ca:	85ca                	mv	a1,s2
    27cc:	00004517          	auipc	a0,0x4
    27d0:	7ac50513          	addi	a0,a0,1964 # 6f78 <malloc+0x1340>
    27d4:	00003097          	auipc	ra,0x3
    27d8:	3a6080e7          	jalr	934(ra) # 5b7a <printf>
    exit(1);
    27dc:	4505                	li	a0,1
    27de:	00003097          	auipc	ra,0x3
    27e2:	00c080e7          	jalr	12(ra) # 57ea <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    27e6:	85ca                	mv	a1,s2
    27e8:	00004517          	auipc	a0,0x4
    27ec:	7b850513          	addi	a0,a0,1976 # 6fa0 <malloc+0x1368>
    27f0:	00003097          	auipc	ra,0x3
    27f4:	38a080e7          	jalr	906(ra) # 5b7a <printf>
    exit(1);
    27f8:	4505                	li	a0,1
    27fa:	00003097          	auipc	ra,0x3
    27fe:	ff0080e7          	jalr	-16(ra) # 57ea <exit>
    printf("chdir dd/../../dd failed\n", s);
    2802:	85ca                	mv	a1,s2
    2804:	00004517          	auipc	a0,0x4
    2808:	7cc50513          	addi	a0,a0,1996 # 6fd0 <malloc+0x1398>
    280c:	00003097          	auipc	ra,0x3
    2810:	36e080e7          	jalr	878(ra) # 5b7a <printf>
    exit(1);
    2814:	4505                	li	a0,1
    2816:	00003097          	auipc	ra,0x3
    281a:	fd4080e7          	jalr	-44(ra) # 57ea <exit>
    printf("%s: chdir ./.. failed\n", s);
    281e:	85ca                	mv	a1,s2
    2820:	00004517          	auipc	a0,0x4
    2824:	7d850513          	addi	a0,a0,2008 # 6ff8 <malloc+0x13c0>
    2828:	00003097          	auipc	ra,0x3
    282c:	352080e7          	jalr	850(ra) # 5b7a <printf>
    exit(1);
    2830:	4505                	li	a0,1
    2832:	00003097          	auipc	ra,0x3
    2836:	fb8080e7          	jalr	-72(ra) # 57ea <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    283a:	85ca                	mv	a1,s2
    283c:	00004517          	auipc	a0,0x4
    2840:	7d450513          	addi	a0,a0,2004 # 7010 <malloc+0x13d8>
    2844:	00003097          	auipc	ra,0x3
    2848:	336080e7          	jalr	822(ra) # 5b7a <printf>
    exit(1);
    284c:	4505                	li	a0,1
    284e:	00003097          	auipc	ra,0x3
    2852:	f9c080e7          	jalr	-100(ra) # 57ea <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    2856:	85ca                	mv	a1,s2
    2858:	00004517          	auipc	a0,0x4
    285c:	7d850513          	addi	a0,a0,2008 # 7030 <malloc+0x13f8>
    2860:	00003097          	auipc	ra,0x3
    2864:	31a080e7          	jalr	794(ra) # 5b7a <printf>
    exit(1);
    2868:	4505                	li	a0,1
    286a:	00003097          	auipc	ra,0x3
    286e:	f80080e7          	jalr	-128(ra) # 57ea <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    2872:	85ca                	mv	a1,s2
    2874:	00004517          	auipc	a0,0x4
    2878:	7dc50513          	addi	a0,a0,2012 # 7050 <malloc+0x1418>
    287c:	00003097          	auipc	ra,0x3
    2880:	2fe080e7          	jalr	766(ra) # 5b7a <printf>
    exit(1);
    2884:	4505                	li	a0,1
    2886:	00003097          	auipc	ra,0x3
    288a:	f64080e7          	jalr	-156(ra) # 57ea <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    288e:	85ca                	mv	a1,s2
    2890:	00005517          	auipc	a0,0x5
    2894:	80050513          	addi	a0,a0,-2048 # 7090 <malloc+0x1458>
    2898:	00003097          	auipc	ra,0x3
    289c:	2e2080e7          	jalr	738(ra) # 5b7a <printf>
    exit(1);
    28a0:	4505                	li	a0,1
    28a2:	00003097          	auipc	ra,0x3
    28a6:	f48080e7          	jalr	-184(ra) # 57ea <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    28aa:	85ca                	mv	a1,s2
    28ac:	00005517          	auipc	a0,0x5
    28b0:	81450513          	addi	a0,a0,-2028 # 70c0 <malloc+0x1488>
    28b4:	00003097          	auipc	ra,0x3
    28b8:	2c6080e7          	jalr	710(ra) # 5b7a <printf>
    exit(1);
    28bc:	4505                	li	a0,1
    28be:	00003097          	auipc	ra,0x3
    28c2:	f2c080e7          	jalr	-212(ra) # 57ea <exit>
    printf("%s: create dd succeeded!\n", s);
    28c6:	85ca                	mv	a1,s2
    28c8:	00005517          	auipc	a0,0x5
    28cc:	81850513          	addi	a0,a0,-2024 # 70e0 <malloc+0x14a8>
    28d0:	00003097          	auipc	ra,0x3
    28d4:	2aa080e7          	jalr	682(ra) # 5b7a <printf>
    exit(1);
    28d8:	4505                	li	a0,1
    28da:	00003097          	auipc	ra,0x3
    28de:	f10080e7          	jalr	-240(ra) # 57ea <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    28e2:	85ca                	mv	a1,s2
    28e4:	00005517          	auipc	a0,0x5
    28e8:	81c50513          	addi	a0,a0,-2020 # 7100 <malloc+0x14c8>
    28ec:	00003097          	auipc	ra,0x3
    28f0:	28e080e7          	jalr	654(ra) # 5b7a <printf>
    exit(1);
    28f4:	4505                	li	a0,1
    28f6:	00003097          	auipc	ra,0x3
    28fa:	ef4080e7          	jalr	-268(ra) # 57ea <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    28fe:	85ca                	mv	a1,s2
    2900:	00005517          	auipc	a0,0x5
    2904:	82050513          	addi	a0,a0,-2016 # 7120 <malloc+0x14e8>
    2908:	00003097          	auipc	ra,0x3
    290c:	272080e7          	jalr	626(ra) # 5b7a <printf>
    exit(1);
    2910:	4505                	li	a0,1
    2912:	00003097          	auipc	ra,0x3
    2916:	ed8080e7          	jalr	-296(ra) # 57ea <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    291a:	85ca                	mv	a1,s2
    291c:	00005517          	auipc	a0,0x5
    2920:	83450513          	addi	a0,a0,-1996 # 7150 <malloc+0x1518>
    2924:	00003097          	auipc	ra,0x3
    2928:	256080e7          	jalr	598(ra) # 5b7a <printf>
    exit(1);
    292c:	4505                	li	a0,1
    292e:	00003097          	auipc	ra,0x3
    2932:	ebc080e7          	jalr	-324(ra) # 57ea <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    2936:	85ca                	mv	a1,s2
    2938:	00005517          	auipc	a0,0x5
    293c:	84050513          	addi	a0,a0,-1984 # 7178 <malloc+0x1540>
    2940:	00003097          	auipc	ra,0x3
    2944:	23a080e7          	jalr	570(ra) # 5b7a <printf>
    exit(1);
    2948:	4505                	li	a0,1
    294a:	00003097          	auipc	ra,0x3
    294e:	ea0080e7          	jalr	-352(ra) # 57ea <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    2952:	85ca                	mv	a1,s2
    2954:	00005517          	auipc	a0,0x5
    2958:	84c50513          	addi	a0,a0,-1972 # 71a0 <malloc+0x1568>
    295c:	00003097          	auipc	ra,0x3
    2960:	21e080e7          	jalr	542(ra) # 5b7a <printf>
    exit(1);
    2964:	4505                	li	a0,1
    2966:	00003097          	auipc	ra,0x3
    296a:	e84080e7          	jalr	-380(ra) # 57ea <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    296e:	85ca                	mv	a1,s2
    2970:	00005517          	auipc	a0,0x5
    2974:	85850513          	addi	a0,a0,-1960 # 71c8 <malloc+0x1590>
    2978:	00003097          	auipc	ra,0x3
    297c:	202080e7          	jalr	514(ra) # 5b7a <printf>
    exit(1);
    2980:	4505                	li	a0,1
    2982:	00003097          	auipc	ra,0x3
    2986:	e68080e7          	jalr	-408(ra) # 57ea <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    298a:	85ca                	mv	a1,s2
    298c:	00005517          	auipc	a0,0x5
    2990:	85c50513          	addi	a0,a0,-1956 # 71e8 <malloc+0x15b0>
    2994:	00003097          	auipc	ra,0x3
    2998:	1e6080e7          	jalr	486(ra) # 5b7a <printf>
    exit(1);
    299c:	4505                	li	a0,1
    299e:	00003097          	auipc	ra,0x3
    29a2:	e4c080e7          	jalr	-436(ra) # 57ea <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    29a6:	85ca                	mv	a1,s2
    29a8:	00005517          	auipc	a0,0x5
    29ac:	86050513          	addi	a0,a0,-1952 # 7208 <malloc+0x15d0>
    29b0:	00003097          	auipc	ra,0x3
    29b4:	1ca080e7          	jalr	458(ra) # 5b7a <printf>
    exit(1);
    29b8:	4505                	li	a0,1
    29ba:	00003097          	auipc	ra,0x3
    29be:	e30080e7          	jalr	-464(ra) # 57ea <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    29c2:	85ca                	mv	a1,s2
    29c4:	00005517          	auipc	a0,0x5
    29c8:	86c50513          	addi	a0,a0,-1940 # 7230 <malloc+0x15f8>
    29cc:	00003097          	auipc	ra,0x3
    29d0:	1ae080e7          	jalr	430(ra) # 5b7a <printf>
    exit(1);
    29d4:	4505                	li	a0,1
    29d6:	00003097          	auipc	ra,0x3
    29da:	e14080e7          	jalr	-492(ra) # 57ea <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    29de:	85ca                	mv	a1,s2
    29e0:	00005517          	auipc	a0,0x5
    29e4:	87050513          	addi	a0,a0,-1936 # 7250 <malloc+0x1618>
    29e8:	00003097          	auipc	ra,0x3
    29ec:	192080e7          	jalr	402(ra) # 5b7a <printf>
    exit(1);
    29f0:	4505                	li	a0,1
    29f2:	00003097          	auipc	ra,0x3
    29f6:	df8080e7          	jalr	-520(ra) # 57ea <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    29fa:	85ca                	mv	a1,s2
    29fc:	00005517          	auipc	a0,0x5
    2a00:	87450513          	addi	a0,a0,-1932 # 7270 <malloc+0x1638>
    2a04:	00003097          	auipc	ra,0x3
    2a08:	176080e7          	jalr	374(ra) # 5b7a <printf>
    exit(1);
    2a0c:	4505                	li	a0,1
    2a0e:	00003097          	auipc	ra,0x3
    2a12:	ddc080e7          	jalr	-548(ra) # 57ea <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    2a16:	85ca                	mv	a1,s2
    2a18:	00005517          	auipc	a0,0x5
    2a1c:	88050513          	addi	a0,a0,-1920 # 7298 <malloc+0x1660>
    2a20:	00003097          	auipc	ra,0x3
    2a24:	15a080e7          	jalr	346(ra) # 5b7a <printf>
    exit(1);
    2a28:	4505                	li	a0,1
    2a2a:	00003097          	auipc	ra,0x3
    2a2e:	dc0080e7          	jalr	-576(ra) # 57ea <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2a32:	85ca                	mv	a1,s2
    2a34:	00004517          	auipc	a0,0x4
    2a38:	4fc50513          	addi	a0,a0,1276 # 6f30 <malloc+0x12f8>
    2a3c:	00003097          	auipc	ra,0x3
    2a40:	13e080e7          	jalr	318(ra) # 5b7a <printf>
    exit(1);
    2a44:	4505                	li	a0,1
    2a46:	00003097          	auipc	ra,0x3
    2a4a:	da4080e7          	jalr	-604(ra) # 57ea <exit>
    printf("%s: unlink dd/ff failed\n", s);
    2a4e:	85ca                	mv	a1,s2
    2a50:	00005517          	auipc	a0,0x5
    2a54:	86850513          	addi	a0,a0,-1944 # 72b8 <malloc+0x1680>
    2a58:	00003097          	auipc	ra,0x3
    2a5c:	122080e7          	jalr	290(ra) # 5b7a <printf>
    exit(1);
    2a60:	4505                	li	a0,1
    2a62:	00003097          	auipc	ra,0x3
    2a66:	d88080e7          	jalr	-632(ra) # 57ea <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    2a6a:	85ca                	mv	a1,s2
    2a6c:	00005517          	auipc	a0,0x5
    2a70:	86c50513          	addi	a0,a0,-1940 # 72d8 <malloc+0x16a0>
    2a74:	00003097          	auipc	ra,0x3
    2a78:	106080e7          	jalr	262(ra) # 5b7a <printf>
    exit(1);
    2a7c:	4505                	li	a0,1
    2a7e:	00003097          	auipc	ra,0x3
    2a82:	d6c080e7          	jalr	-660(ra) # 57ea <exit>
    printf("%s: unlink dd/dd failed\n", s);
    2a86:	85ca                	mv	a1,s2
    2a88:	00005517          	auipc	a0,0x5
    2a8c:	88050513          	addi	a0,a0,-1920 # 7308 <malloc+0x16d0>
    2a90:	00003097          	auipc	ra,0x3
    2a94:	0ea080e7          	jalr	234(ra) # 5b7a <printf>
    exit(1);
    2a98:	4505                	li	a0,1
    2a9a:	00003097          	auipc	ra,0x3
    2a9e:	d50080e7          	jalr	-688(ra) # 57ea <exit>
    printf("%s: unlink dd failed\n", s);
    2aa2:	85ca                	mv	a1,s2
    2aa4:	00005517          	auipc	a0,0x5
    2aa8:	88450513          	addi	a0,a0,-1916 # 7328 <malloc+0x16f0>
    2aac:	00003097          	auipc	ra,0x3
    2ab0:	0ce080e7          	jalr	206(ra) # 5b7a <printf>
    exit(1);
    2ab4:	4505                	li	a0,1
    2ab6:	00003097          	auipc	ra,0x3
    2aba:	d34080e7          	jalr	-716(ra) # 57ea <exit>

0000000000002abe <rmdot>:
{
    2abe:	1101                	addi	sp,sp,-32
    2ac0:	ec06                	sd	ra,24(sp)
    2ac2:	e822                	sd	s0,16(sp)
    2ac4:	e426                	sd	s1,8(sp)
    2ac6:	1000                	addi	s0,sp,32
    2ac8:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    2aca:	00005517          	auipc	a0,0x5
    2ace:	87650513          	addi	a0,a0,-1930 # 7340 <malloc+0x1708>
    2ad2:	00003097          	auipc	ra,0x3
    2ad6:	d80080e7          	jalr	-640(ra) # 5852 <mkdir>
    2ada:	e549                	bnez	a0,2b64 <rmdot+0xa6>
  if(chdir("dots") != 0){
    2adc:	00005517          	auipc	a0,0x5
    2ae0:	86450513          	addi	a0,a0,-1948 # 7340 <malloc+0x1708>
    2ae4:	00003097          	auipc	ra,0x3
    2ae8:	d76080e7          	jalr	-650(ra) # 585a <chdir>
    2aec:	e951                	bnez	a0,2b80 <rmdot+0xc2>
  if(unlink(".") == 0){
    2aee:	00004517          	auipc	a0,0x4
    2af2:	b6250513          	addi	a0,a0,-1182 # 6650 <malloc+0xa18>
    2af6:	00003097          	auipc	ra,0x3
    2afa:	d44080e7          	jalr	-700(ra) # 583a <unlink>
    2afe:	cd59                	beqz	a0,2b9c <rmdot+0xde>
  if(unlink("..") == 0){
    2b00:	00004517          	auipc	a0,0x4
    2b04:	29850513          	addi	a0,a0,664 # 6d98 <malloc+0x1160>
    2b08:	00003097          	auipc	ra,0x3
    2b0c:	d32080e7          	jalr	-718(ra) # 583a <unlink>
    2b10:	c545                	beqz	a0,2bb8 <rmdot+0xfa>
  if(chdir("/") != 0){
    2b12:	00004517          	auipc	a0,0x4
    2b16:	22e50513          	addi	a0,a0,558 # 6d40 <malloc+0x1108>
    2b1a:	00003097          	auipc	ra,0x3
    2b1e:	d40080e7          	jalr	-704(ra) # 585a <chdir>
    2b22:	e94d                	bnez	a0,2bd4 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    2b24:	00005517          	auipc	a0,0x5
    2b28:	88450513          	addi	a0,a0,-1916 # 73a8 <malloc+0x1770>
    2b2c:	00003097          	auipc	ra,0x3
    2b30:	d0e080e7          	jalr	-754(ra) # 583a <unlink>
    2b34:	cd55                	beqz	a0,2bf0 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    2b36:	00005517          	auipc	a0,0x5
    2b3a:	89a50513          	addi	a0,a0,-1894 # 73d0 <malloc+0x1798>
    2b3e:	00003097          	auipc	ra,0x3
    2b42:	cfc080e7          	jalr	-772(ra) # 583a <unlink>
    2b46:	c179                	beqz	a0,2c0c <rmdot+0x14e>
  if(unlink("dots") != 0){
    2b48:	00004517          	auipc	a0,0x4
    2b4c:	7f850513          	addi	a0,a0,2040 # 7340 <malloc+0x1708>
    2b50:	00003097          	auipc	ra,0x3
    2b54:	cea080e7          	jalr	-790(ra) # 583a <unlink>
    2b58:	e961                	bnez	a0,2c28 <rmdot+0x16a>
}
    2b5a:	60e2                	ld	ra,24(sp)
    2b5c:	6442                	ld	s0,16(sp)
    2b5e:	64a2                	ld	s1,8(sp)
    2b60:	6105                	addi	sp,sp,32
    2b62:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    2b64:	85a6                	mv	a1,s1
    2b66:	00004517          	auipc	a0,0x4
    2b6a:	7e250513          	addi	a0,a0,2018 # 7348 <malloc+0x1710>
    2b6e:	00003097          	auipc	ra,0x3
    2b72:	00c080e7          	jalr	12(ra) # 5b7a <printf>
    exit(1);
    2b76:	4505                	li	a0,1
    2b78:	00003097          	auipc	ra,0x3
    2b7c:	c72080e7          	jalr	-910(ra) # 57ea <exit>
    printf("%s: chdir dots failed\n", s);
    2b80:	85a6                	mv	a1,s1
    2b82:	00004517          	auipc	a0,0x4
    2b86:	7de50513          	addi	a0,a0,2014 # 7360 <malloc+0x1728>
    2b8a:	00003097          	auipc	ra,0x3
    2b8e:	ff0080e7          	jalr	-16(ra) # 5b7a <printf>
    exit(1);
    2b92:	4505                	li	a0,1
    2b94:	00003097          	auipc	ra,0x3
    2b98:	c56080e7          	jalr	-938(ra) # 57ea <exit>
    printf("%s: rm . worked!\n", s);
    2b9c:	85a6                	mv	a1,s1
    2b9e:	00004517          	auipc	a0,0x4
    2ba2:	7da50513          	addi	a0,a0,2010 # 7378 <malloc+0x1740>
    2ba6:	00003097          	auipc	ra,0x3
    2baa:	fd4080e7          	jalr	-44(ra) # 5b7a <printf>
    exit(1);
    2bae:	4505                	li	a0,1
    2bb0:	00003097          	auipc	ra,0x3
    2bb4:	c3a080e7          	jalr	-966(ra) # 57ea <exit>
    printf("%s: rm .. worked!\n", s);
    2bb8:	85a6                	mv	a1,s1
    2bba:	00004517          	auipc	a0,0x4
    2bbe:	7d650513          	addi	a0,a0,2006 # 7390 <malloc+0x1758>
    2bc2:	00003097          	auipc	ra,0x3
    2bc6:	fb8080e7          	jalr	-72(ra) # 5b7a <printf>
    exit(1);
    2bca:	4505                	li	a0,1
    2bcc:	00003097          	auipc	ra,0x3
    2bd0:	c1e080e7          	jalr	-994(ra) # 57ea <exit>
    printf("%s: chdir / failed\n", s);
    2bd4:	85a6                	mv	a1,s1
    2bd6:	00004517          	auipc	a0,0x4
    2bda:	17250513          	addi	a0,a0,370 # 6d48 <malloc+0x1110>
    2bde:	00003097          	auipc	ra,0x3
    2be2:	f9c080e7          	jalr	-100(ra) # 5b7a <printf>
    exit(1);
    2be6:	4505                	li	a0,1
    2be8:	00003097          	auipc	ra,0x3
    2bec:	c02080e7          	jalr	-1022(ra) # 57ea <exit>
    printf("%s: unlink dots/. worked!\n", s);
    2bf0:	85a6                	mv	a1,s1
    2bf2:	00004517          	auipc	a0,0x4
    2bf6:	7be50513          	addi	a0,a0,1982 # 73b0 <malloc+0x1778>
    2bfa:	00003097          	auipc	ra,0x3
    2bfe:	f80080e7          	jalr	-128(ra) # 5b7a <printf>
    exit(1);
    2c02:	4505                	li	a0,1
    2c04:	00003097          	auipc	ra,0x3
    2c08:	be6080e7          	jalr	-1050(ra) # 57ea <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    2c0c:	85a6                	mv	a1,s1
    2c0e:	00004517          	auipc	a0,0x4
    2c12:	7ca50513          	addi	a0,a0,1994 # 73d8 <malloc+0x17a0>
    2c16:	00003097          	auipc	ra,0x3
    2c1a:	f64080e7          	jalr	-156(ra) # 5b7a <printf>
    exit(1);
    2c1e:	4505                	li	a0,1
    2c20:	00003097          	auipc	ra,0x3
    2c24:	bca080e7          	jalr	-1078(ra) # 57ea <exit>
    printf("%s: unlink dots failed!\n", s);
    2c28:	85a6                	mv	a1,s1
    2c2a:	00004517          	auipc	a0,0x4
    2c2e:	7ce50513          	addi	a0,a0,1998 # 73f8 <malloc+0x17c0>
    2c32:	00003097          	auipc	ra,0x3
    2c36:	f48080e7          	jalr	-184(ra) # 5b7a <printf>
    exit(1);
    2c3a:	4505                	li	a0,1
    2c3c:	00003097          	auipc	ra,0x3
    2c40:	bae080e7          	jalr	-1106(ra) # 57ea <exit>

0000000000002c44 <dirfile>:
{
    2c44:	1101                	addi	sp,sp,-32
    2c46:	ec06                	sd	ra,24(sp)
    2c48:	e822                	sd	s0,16(sp)
    2c4a:	e426                	sd	s1,8(sp)
    2c4c:	e04a                	sd	s2,0(sp)
    2c4e:	1000                	addi	s0,sp,32
    2c50:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    2c52:	20000593          	li	a1,512
    2c56:	00003517          	auipc	a0,0x3
    2c5a:	2ca50513          	addi	a0,a0,714 # 5f20 <malloc+0x2e8>
    2c5e:	00003097          	auipc	ra,0x3
    2c62:	bcc080e7          	jalr	-1076(ra) # 582a <open>
  if(fd < 0){
    2c66:	0e054d63          	bltz	a0,2d60 <dirfile+0x11c>
  close(fd);
    2c6a:	00003097          	auipc	ra,0x3
    2c6e:	ba8080e7          	jalr	-1112(ra) # 5812 <close>
  if(chdir("dirfile") == 0){
    2c72:	00003517          	auipc	a0,0x3
    2c76:	2ae50513          	addi	a0,a0,686 # 5f20 <malloc+0x2e8>
    2c7a:	00003097          	auipc	ra,0x3
    2c7e:	be0080e7          	jalr	-1056(ra) # 585a <chdir>
    2c82:	cd6d                	beqz	a0,2d7c <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    2c84:	4581                	li	a1,0
    2c86:	00004517          	auipc	a0,0x4
    2c8a:	7d250513          	addi	a0,a0,2002 # 7458 <malloc+0x1820>
    2c8e:	00003097          	auipc	ra,0x3
    2c92:	b9c080e7          	jalr	-1124(ra) # 582a <open>
  if(fd >= 0){
    2c96:	10055163          	bgez	a0,2d98 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    2c9a:	20000593          	li	a1,512
    2c9e:	00004517          	auipc	a0,0x4
    2ca2:	7ba50513          	addi	a0,a0,1978 # 7458 <malloc+0x1820>
    2ca6:	00003097          	auipc	ra,0x3
    2caa:	b84080e7          	jalr	-1148(ra) # 582a <open>
  if(fd >= 0){
    2cae:	10055363          	bgez	a0,2db4 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    2cb2:	00004517          	auipc	a0,0x4
    2cb6:	7a650513          	addi	a0,a0,1958 # 7458 <malloc+0x1820>
    2cba:	00003097          	auipc	ra,0x3
    2cbe:	b98080e7          	jalr	-1128(ra) # 5852 <mkdir>
    2cc2:	10050763          	beqz	a0,2dd0 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    2cc6:	00004517          	auipc	a0,0x4
    2cca:	79250513          	addi	a0,a0,1938 # 7458 <malloc+0x1820>
    2cce:	00003097          	auipc	ra,0x3
    2cd2:	b6c080e7          	jalr	-1172(ra) # 583a <unlink>
    2cd6:	10050b63          	beqz	a0,2dec <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    2cda:	00004597          	auipc	a1,0x4
    2cde:	77e58593          	addi	a1,a1,1918 # 7458 <malloc+0x1820>
    2ce2:	00003517          	auipc	a0,0x3
    2ce6:	57e50513          	addi	a0,a0,1406 # 6260 <malloc+0x628>
    2cea:	00003097          	auipc	ra,0x3
    2cee:	b60080e7          	jalr	-1184(ra) # 584a <link>
    2cf2:	10050b63          	beqz	a0,2e08 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    2cf6:	00003517          	auipc	a0,0x3
    2cfa:	22a50513          	addi	a0,a0,554 # 5f20 <malloc+0x2e8>
    2cfe:	00003097          	auipc	ra,0x3
    2d02:	b3c080e7          	jalr	-1220(ra) # 583a <unlink>
    2d06:	10051f63          	bnez	a0,2e24 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    2d0a:	4589                	li	a1,2
    2d0c:	00004517          	auipc	a0,0x4
    2d10:	94450513          	addi	a0,a0,-1724 # 6650 <malloc+0xa18>
    2d14:	00003097          	auipc	ra,0x3
    2d18:	b16080e7          	jalr	-1258(ra) # 582a <open>
  if(fd >= 0){
    2d1c:	12055263          	bgez	a0,2e40 <dirfile+0x1fc>
  fd = open(".", 0);
    2d20:	4581                	li	a1,0
    2d22:	00004517          	auipc	a0,0x4
    2d26:	92e50513          	addi	a0,a0,-1746 # 6650 <malloc+0xa18>
    2d2a:	00003097          	auipc	ra,0x3
    2d2e:	b00080e7          	jalr	-1280(ra) # 582a <open>
    2d32:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    2d34:	4605                	li	a2,1
    2d36:	00003597          	auipc	a1,0x3
    2d3a:	3f258593          	addi	a1,a1,1010 # 6128 <malloc+0x4f0>
    2d3e:	00003097          	auipc	ra,0x3
    2d42:	acc080e7          	jalr	-1332(ra) # 580a <write>
    2d46:	10a04b63          	bgtz	a0,2e5c <dirfile+0x218>
  close(fd);
    2d4a:	8526                	mv	a0,s1
    2d4c:	00003097          	auipc	ra,0x3
    2d50:	ac6080e7          	jalr	-1338(ra) # 5812 <close>
}
    2d54:	60e2                	ld	ra,24(sp)
    2d56:	6442                	ld	s0,16(sp)
    2d58:	64a2                	ld	s1,8(sp)
    2d5a:	6902                	ld	s2,0(sp)
    2d5c:	6105                	addi	sp,sp,32
    2d5e:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    2d60:	85ca                	mv	a1,s2
    2d62:	00004517          	auipc	a0,0x4
    2d66:	6b650513          	addi	a0,a0,1718 # 7418 <malloc+0x17e0>
    2d6a:	00003097          	auipc	ra,0x3
    2d6e:	e10080e7          	jalr	-496(ra) # 5b7a <printf>
    exit(1);
    2d72:	4505                	li	a0,1
    2d74:	00003097          	auipc	ra,0x3
    2d78:	a76080e7          	jalr	-1418(ra) # 57ea <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    2d7c:	85ca                	mv	a1,s2
    2d7e:	00004517          	auipc	a0,0x4
    2d82:	6ba50513          	addi	a0,a0,1722 # 7438 <malloc+0x1800>
    2d86:	00003097          	auipc	ra,0x3
    2d8a:	df4080e7          	jalr	-524(ra) # 5b7a <printf>
    exit(1);
    2d8e:	4505                	li	a0,1
    2d90:	00003097          	auipc	ra,0x3
    2d94:	a5a080e7          	jalr	-1446(ra) # 57ea <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    2d98:	85ca                	mv	a1,s2
    2d9a:	00004517          	auipc	a0,0x4
    2d9e:	6ce50513          	addi	a0,a0,1742 # 7468 <malloc+0x1830>
    2da2:	00003097          	auipc	ra,0x3
    2da6:	dd8080e7          	jalr	-552(ra) # 5b7a <printf>
    exit(1);
    2daa:	4505                	li	a0,1
    2dac:	00003097          	auipc	ra,0x3
    2db0:	a3e080e7          	jalr	-1474(ra) # 57ea <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    2db4:	85ca                	mv	a1,s2
    2db6:	00004517          	auipc	a0,0x4
    2dba:	6b250513          	addi	a0,a0,1714 # 7468 <malloc+0x1830>
    2dbe:	00003097          	auipc	ra,0x3
    2dc2:	dbc080e7          	jalr	-580(ra) # 5b7a <printf>
    exit(1);
    2dc6:	4505                	li	a0,1
    2dc8:	00003097          	auipc	ra,0x3
    2dcc:	a22080e7          	jalr	-1502(ra) # 57ea <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    2dd0:	85ca                	mv	a1,s2
    2dd2:	00004517          	auipc	a0,0x4
    2dd6:	6be50513          	addi	a0,a0,1726 # 7490 <malloc+0x1858>
    2dda:	00003097          	auipc	ra,0x3
    2dde:	da0080e7          	jalr	-608(ra) # 5b7a <printf>
    exit(1);
    2de2:	4505                	li	a0,1
    2de4:	00003097          	auipc	ra,0x3
    2de8:	a06080e7          	jalr	-1530(ra) # 57ea <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    2dec:	85ca                	mv	a1,s2
    2dee:	00004517          	auipc	a0,0x4
    2df2:	6ca50513          	addi	a0,a0,1738 # 74b8 <malloc+0x1880>
    2df6:	00003097          	auipc	ra,0x3
    2dfa:	d84080e7          	jalr	-636(ra) # 5b7a <printf>
    exit(1);
    2dfe:	4505                	li	a0,1
    2e00:	00003097          	auipc	ra,0x3
    2e04:	9ea080e7          	jalr	-1558(ra) # 57ea <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    2e08:	85ca                	mv	a1,s2
    2e0a:	00004517          	auipc	a0,0x4
    2e0e:	6d650513          	addi	a0,a0,1750 # 74e0 <malloc+0x18a8>
    2e12:	00003097          	auipc	ra,0x3
    2e16:	d68080e7          	jalr	-664(ra) # 5b7a <printf>
    exit(1);
    2e1a:	4505                	li	a0,1
    2e1c:	00003097          	auipc	ra,0x3
    2e20:	9ce080e7          	jalr	-1586(ra) # 57ea <exit>
    printf("%s: unlink dirfile failed!\n", s);
    2e24:	85ca                	mv	a1,s2
    2e26:	00004517          	auipc	a0,0x4
    2e2a:	6e250513          	addi	a0,a0,1762 # 7508 <malloc+0x18d0>
    2e2e:	00003097          	auipc	ra,0x3
    2e32:	d4c080e7          	jalr	-692(ra) # 5b7a <printf>
    exit(1);
    2e36:	4505                	li	a0,1
    2e38:	00003097          	auipc	ra,0x3
    2e3c:	9b2080e7          	jalr	-1614(ra) # 57ea <exit>
    printf("%s: open . for writing succeeded!\n", s);
    2e40:	85ca                	mv	a1,s2
    2e42:	00004517          	auipc	a0,0x4
    2e46:	6e650513          	addi	a0,a0,1766 # 7528 <malloc+0x18f0>
    2e4a:	00003097          	auipc	ra,0x3
    2e4e:	d30080e7          	jalr	-720(ra) # 5b7a <printf>
    exit(1);
    2e52:	4505                	li	a0,1
    2e54:	00003097          	auipc	ra,0x3
    2e58:	996080e7          	jalr	-1642(ra) # 57ea <exit>
    printf("%s: write . succeeded!\n", s);
    2e5c:	85ca                	mv	a1,s2
    2e5e:	00004517          	auipc	a0,0x4
    2e62:	6f250513          	addi	a0,a0,1778 # 7550 <malloc+0x1918>
    2e66:	00003097          	auipc	ra,0x3
    2e6a:	d14080e7          	jalr	-748(ra) # 5b7a <printf>
    exit(1);
    2e6e:	4505                	li	a0,1
    2e70:	00003097          	auipc	ra,0x3
    2e74:	97a080e7          	jalr	-1670(ra) # 57ea <exit>

0000000000002e78 <reparent>:
{
    2e78:	7179                	addi	sp,sp,-48
    2e7a:	f406                	sd	ra,40(sp)
    2e7c:	f022                	sd	s0,32(sp)
    2e7e:	ec26                	sd	s1,24(sp)
    2e80:	e84a                	sd	s2,16(sp)
    2e82:	e44e                	sd	s3,8(sp)
    2e84:	e052                	sd	s4,0(sp)
    2e86:	1800                	addi	s0,sp,48
    2e88:	89aa                	mv	s3,a0
  int master_pid = getpid();
    2e8a:	00003097          	auipc	ra,0x3
    2e8e:	9e0080e7          	jalr	-1568(ra) # 586a <getpid>
    2e92:	8a2a                	mv	s4,a0
    2e94:	0c800913          	li	s2,200
    int pid = fork();
    2e98:	00003097          	auipc	ra,0x3
    2e9c:	94a080e7          	jalr	-1718(ra) # 57e2 <fork>
    2ea0:	84aa                	mv	s1,a0
    if(pid < 0){
    2ea2:	02054263          	bltz	a0,2ec6 <reparent+0x4e>
    if(pid){
    2ea6:	cd21                	beqz	a0,2efe <reparent+0x86>
      if(wait(0) != pid){
    2ea8:	4501                	li	a0,0
    2eaa:	00003097          	auipc	ra,0x3
    2eae:	948080e7          	jalr	-1720(ra) # 57f2 <wait>
    2eb2:	02951863          	bne	a0,s1,2ee2 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    2eb6:	397d                	addiw	s2,s2,-1
    2eb8:	fe0910e3          	bnez	s2,2e98 <reparent+0x20>
  exit(0);
    2ebc:	4501                	li	a0,0
    2ebe:	00003097          	auipc	ra,0x3
    2ec2:	92c080e7          	jalr	-1748(ra) # 57ea <exit>
      printf("%s: fork failed\n", s);
    2ec6:	85ce                	mv	a1,s3
    2ec8:	00003517          	auipc	a0,0x3
    2ecc:	0e050513          	addi	a0,a0,224 # 5fa8 <malloc+0x370>
    2ed0:	00003097          	auipc	ra,0x3
    2ed4:	caa080e7          	jalr	-854(ra) # 5b7a <printf>
      exit(1);
    2ed8:	4505                	li	a0,1
    2eda:	00003097          	auipc	ra,0x3
    2ede:	910080e7          	jalr	-1776(ra) # 57ea <exit>
        printf("%s: wait wrong pid\n", s);
    2ee2:	85ce                	mv	a1,s3
    2ee4:	00003517          	auipc	a0,0x3
    2ee8:	0dc50513          	addi	a0,a0,220 # 5fc0 <malloc+0x388>
    2eec:	00003097          	auipc	ra,0x3
    2ef0:	c8e080e7          	jalr	-882(ra) # 5b7a <printf>
        exit(1);
    2ef4:	4505                	li	a0,1
    2ef6:	00003097          	auipc	ra,0x3
    2efa:	8f4080e7          	jalr	-1804(ra) # 57ea <exit>
      int pid2 = fork();
    2efe:	00003097          	auipc	ra,0x3
    2f02:	8e4080e7          	jalr	-1820(ra) # 57e2 <fork>
      if(pid2 < 0){
    2f06:	00054763          	bltz	a0,2f14 <reparent+0x9c>
      exit(0);
    2f0a:	4501                	li	a0,0
    2f0c:	00003097          	auipc	ra,0x3
    2f10:	8de080e7          	jalr	-1826(ra) # 57ea <exit>
        kill(master_pid, SIGKILL);
    2f14:	45a5                	li	a1,9
    2f16:	8552                	mv	a0,s4
    2f18:	00003097          	auipc	ra,0x3
    2f1c:	902080e7          	jalr	-1790(ra) # 581a <kill>
        exit(1);
    2f20:	4505                	li	a0,1
    2f22:	00003097          	auipc	ra,0x3
    2f26:	8c8080e7          	jalr	-1848(ra) # 57ea <exit>

0000000000002f2a <fourfiles>:
{
    2f2a:	7171                	addi	sp,sp,-176
    2f2c:	f506                	sd	ra,168(sp)
    2f2e:	f122                	sd	s0,160(sp)
    2f30:	ed26                	sd	s1,152(sp)
    2f32:	e94a                	sd	s2,144(sp)
    2f34:	e54e                	sd	s3,136(sp)
    2f36:	e152                	sd	s4,128(sp)
    2f38:	fcd6                	sd	s5,120(sp)
    2f3a:	f8da                	sd	s6,112(sp)
    2f3c:	f4de                	sd	s7,104(sp)
    2f3e:	f0e2                	sd	s8,96(sp)
    2f40:	ece6                	sd	s9,88(sp)
    2f42:	e8ea                	sd	s10,80(sp)
    2f44:	e4ee                	sd	s11,72(sp)
    2f46:	1900                	addi	s0,sp,176
    2f48:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    2f4c:	00003797          	auipc	a5,0x3
    2f50:	dd478793          	addi	a5,a5,-556 # 5d20 <malloc+0xe8>
    2f54:	f6f43823          	sd	a5,-144(s0)
    2f58:	00003797          	auipc	a5,0x3
    2f5c:	dd078793          	addi	a5,a5,-560 # 5d28 <malloc+0xf0>
    2f60:	f6f43c23          	sd	a5,-136(s0)
    2f64:	00003797          	auipc	a5,0x3
    2f68:	dcc78793          	addi	a5,a5,-564 # 5d30 <malloc+0xf8>
    2f6c:	f8f43023          	sd	a5,-128(s0)
    2f70:	00003797          	auipc	a5,0x3
    2f74:	dc878793          	addi	a5,a5,-568 # 5d38 <malloc+0x100>
    2f78:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    2f7c:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    2f80:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    2f82:	4481                	li	s1,0
    2f84:	4a11                	li	s4,4
    fname = names[pi];
    2f86:	00093983          	ld	s3,0(s2)
    unlink(fname);
    2f8a:	854e                	mv	a0,s3
    2f8c:	00003097          	auipc	ra,0x3
    2f90:	8ae080e7          	jalr	-1874(ra) # 583a <unlink>
    pid = fork();
    2f94:	00003097          	auipc	ra,0x3
    2f98:	84e080e7          	jalr	-1970(ra) # 57e2 <fork>
    if(pid < 0){
    2f9c:	04054463          	bltz	a0,2fe4 <fourfiles+0xba>
    if(pid == 0){
    2fa0:	c12d                	beqz	a0,3002 <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    2fa2:	2485                	addiw	s1,s1,1
    2fa4:	0921                	addi	s2,s2,8
    2fa6:	ff4490e3          	bne	s1,s4,2f86 <fourfiles+0x5c>
    2faa:	4491                	li	s1,4
    wait(&xstatus);
    2fac:	f6c40513          	addi	a0,s0,-148
    2fb0:	00003097          	auipc	ra,0x3
    2fb4:	842080e7          	jalr	-1982(ra) # 57f2 <wait>
    if(xstatus != 0)
    2fb8:	f6c42b03          	lw	s6,-148(s0)
    2fbc:	0c0b1e63          	bnez	s6,3098 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    2fc0:	34fd                	addiw	s1,s1,-1
    2fc2:	f4ed                	bnez	s1,2fac <fourfiles+0x82>
    2fc4:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2fc8:	00009a17          	auipc	s4,0x9
    2fcc:	b20a0a13          	addi	s4,s4,-1248 # bae8 <buf>
    2fd0:	00009a97          	auipc	s5,0x9
    2fd4:	b19a8a93          	addi	s5,s5,-1255 # bae9 <buf+0x1>
    if(total != N*SZ){
    2fd8:	6d85                	lui	s11,0x1
    2fda:	770d8d93          	addi	s11,s11,1904 # 1770 <exectest+0xf2>
  for(i = 0; i < NCHILD; i++){
    2fde:	03400d13          	li	s10,52
    2fe2:	aa1d                	j	3118 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    2fe4:	f5843583          	ld	a1,-168(s0)
    2fe8:	00004517          	auipc	a0,0x4
    2fec:	95050513          	addi	a0,a0,-1712 # 6938 <malloc+0xd00>
    2ff0:	00003097          	auipc	ra,0x3
    2ff4:	b8a080e7          	jalr	-1142(ra) # 5b7a <printf>
      exit(1);
    2ff8:	4505                	li	a0,1
    2ffa:	00002097          	auipc	ra,0x2
    2ffe:	7f0080e7          	jalr	2032(ra) # 57ea <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    3002:	20200593          	li	a1,514
    3006:	854e                	mv	a0,s3
    3008:	00003097          	auipc	ra,0x3
    300c:	822080e7          	jalr	-2014(ra) # 582a <open>
    3010:	892a                	mv	s2,a0
      if(fd < 0){
    3012:	04054763          	bltz	a0,3060 <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    3016:	1f400613          	li	a2,500
    301a:	0304859b          	addiw	a1,s1,48
    301e:	00009517          	auipc	a0,0x9
    3022:	aca50513          	addi	a0,a0,-1334 # bae8 <buf>
    3026:	00002097          	auipc	ra,0x2
    302a:	5c8080e7          	jalr	1480(ra) # 55ee <memset>
    302e:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    3030:	00009997          	auipc	s3,0x9
    3034:	ab898993          	addi	s3,s3,-1352 # bae8 <buf>
    3038:	1f400613          	li	a2,500
    303c:	85ce                	mv	a1,s3
    303e:	854a                	mv	a0,s2
    3040:	00002097          	auipc	ra,0x2
    3044:	7ca080e7          	jalr	1994(ra) # 580a <write>
    3048:	85aa                	mv	a1,a0
    304a:	1f400793          	li	a5,500
    304e:	02f51863          	bne	a0,a5,307e <fourfiles+0x154>
      for(i = 0; i < N; i++){
    3052:	34fd                	addiw	s1,s1,-1
    3054:	f0f5                	bnez	s1,3038 <fourfiles+0x10e>
      exit(0);
    3056:	4501                	li	a0,0
    3058:	00002097          	auipc	ra,0x2
    305c:	792080e7          	jalr	1938(ra) # 57ea <exit>
        printf("create failed\n", s);
    3060:	f5843583          	ld	a1,-168(s0)
    3064:	00004517          	auipc	a0,0x4
    3068:	50450513          	addi	a0,a0,1284 # 7568 <malloc+0x1930>
    306c:	00003097          	auipc	ra,0x3
    3070:	b0e080e7          	jalr	-1266(ra) # 5b7a <printf>
        exit(1);
    3074:	4505                	li	a0,1
    3076:	00002097          	auipc	ra,0x2
    307a:	774080e7          	jalr	1908(ra) # 57ea <exit>
          printf("write failed %d\n", n);
    307e:	00004517          	auipc	a0,0x4
    3082:	4fa50513          	addi	a0,a0,1274 # 7578 <malloc+0x1940>
    3086:	00003097          	auipc	ra,0x3
    308a:	af4080e7          	jalr	-1292(ra) # 5b7a <printf>
          exit(1);
    308e:	4505                	li	a0,1
    3090:	00002097          	auipc	ra,0x2
    3094:	75a080e7          	jalr	1882(ra) # 57ea <exit>
      exit(xstatus);
    3098:	855a                	mv	a0,s6
    309a:	00002097          	auipc	ra,0x2
    309e:	750080e7          	jalr	1872(ra) # 57ea <exit>
          printf("wrong char\n", s);
    30a2:	f5843583          	ld	a1,-168(s0)
    30a6:	00004517          	auipc	a0,0x4
    30aa:	4ea50513          	addi	a0,a0,1258 # 7590 <malloc+0x1958>
    30ae:	00003097          	auipc	ra,0x3
    30b2:	acc080e7          	jalr	-1332(ra) # 5b7a <printf>
          exit(1);
    30b6:	4505                	li	a0,1
    30b8:	00002097          	auipc	ra,0x2
    30bc:	732080e7          	jalr	1842(ra) # 57ea <exit>
      total += n;
    30c0:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    30c4:	660d                	lui	a2,0x3
    30c6:	85d2                	mv	a1,s4
    30c8:	854e                	mv	a0,s3
    30ca:	00002097          	auipc	ra,0x2
    30ce:	738080e7          	jalr	1848(ra) # 5802 <read>
    30d2:	02a05363          	blez	a0,30f8 <fourfiles+0x1ce>
    30d6:	00009797          	auipc	a5,0x9
    30da:	a1278793          	addi	a5,a5,-1518 # bae8 <buf>
    30de:	fff5069b          	addiw	a3,a0,-1
    30e2:	1682                	slli	a3,a3,0x20
    30e4:	9281                	srli	a3,a3,0x20
    30e6:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    30e8:	0007c703          	lbu	a4,0(a5)
    30ec:	fa971be3          	bne	a4,s1,30a2 <fourfiles+0x178>
      for(j = 0; j < n; j++){
    30f0:	0785                	addi	a5,a5,1
    30f2:	fed79be3          	bne	a5,a3,30e8 <fourfiles+0x1be>
    30f6:	b7e9                	j	30c0 <fourfiles+0x196>
    close(fd);
    30f8:	854e                	mv	a0,s3
    30fa:	00002097          	auipc	ra,0x2
    30fe:	718080e7          	jalr	1816(ra) # 5812 <close>
    if(total != N*SZ){
    3102:	03b91863          	bne	s2,s11,3132 <fourfiles+0x208>
    unlink(fname);
    3106:	8566                	mv	a0,s9
    3108:	00002097          	auipc	ra,0x2
    310c:	732080e7          	jalr	1842(ra) # 583a <unlink>
  for(i = 0; i < NCHILD; i++){
    3110:	0c21                	addi	s8,s8,8
    3112:	2b85                	addiw	s7,s7,1
    3114:	03ab8d63          	beq	s7,s10,314e <fourfiles+0x224>
    fname = names[i];
    3118:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    311c:	4581                	li	a1,0
    311e:	8566                	mv	a0,s9
    3120:	00002097          	auipc	ra,0x2
    3124:	70a080e7          	jalr	1802(ra) # 582a <open>
    3128:	89aa                	mv	s3,a0
    total = 0;
    312a:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    312c:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3130:	bf51                	j	30c4 <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    3132:	85ca                	mv	a1,s2
    3134:	00004517          	auipc	a0,0x4
    3138:	46c50513          	addi	a0,a0,1132 # 75a0 <malloc+0x1968>
    313c:	00003097          	auipc	ra,0x3
    3140:	a3e080e7          	jalr	-1474(ra) # 5b7a <printf>
      exit(1);
    3144:	4505                	li	a0,1
    3146:	00002097          	auipc	ra,0x2
    314a:	6a4080e7          	jalr	1700(ra) # 57ea <exit>
}
    314e:	70aa                	ld	ra,168(sp)
    3150:	740a                	ld	s0,160(sp)
    3152:	64ea                	ld	s1,152(sp)
    3154:	694a                	ld	s2,144(sp)
    3156:	69aa                	ld	s3,136(sp)
    3158:	6a0a                	ld	s4,128(sp)
    315a:	7ae6                	ld	s5,120(sp)
    315c:	7b46                	ld	s6,112(sp)
    315e:	7ba6                	ld	s7,104(sp)
    3160:	7c06                	ld	s8,96(sp)
    3162:	6ce6                	ld	s9,88(sp)
    3164:	6d46                	ld	s10,80(sp)
    3166:	6da6                	ld	s11,72(sp)
    3168:	614d                	addi	sp,sp,176
    316a:	8082                	ret

000000000000316c <bigfile>:
{
    316c:	7139                	addi	sp,sp,-64
    316e:	fc06                	sd	ra,56(sp)
    3170:	f822                	sd	s0,48(sp)
    3172:	f426                	sd	s1,40(sp)
    3174:	f04a                	sd	s2,32(sp)
    3176:	ec4e                	sd	s3,24(sp)
    3178:	e852                	sd	s4,16(sp)
    317a:	e456                	sd	s5,8(sp)
    317c:	0080                	addi	s0,sp,64
    317e:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    3180:	00004517          	auipc	a0,0x4
    3184:	43850513          	addi	a0,a0,1080 # 75b8 <malloc+0x1980>
    3188:	00002097          	auipc	ra,0x2
    318c:	6b2080e7          	jalr	1714(ra) # 583a <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    3190:	20200593          	li	a1,514
    3194:	00004517          	auipc	a0,0x4
    3198:	42450513          	addi	a0,a0,1060 # 75b8 <malloc+0x1980>
    319c:	00002097          	auipc	ra,0x2
    31a0:	68e080e7          	jalr	1678(ra) # 582a <open>
    31a4:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    31a6:	4481                	li	s1,0
    memset(buf, i, SZ);
    31a8:	00009917          	auipc	s2,0x9
    31ac:	94090913          	addi	s2,s2,-1728 # bae8 <buf>
  for(i = 0; i < N; i++){
    31b0:	4a51                	li	s4,20
  if(fd < 0){
    31b2:	0a054063          	bltz	a0,3252 <bigfile+0xe6>
    memset(buf, i, SZ);
    31b6:	25800613          	li	a2,600
    31ba:	85a6                	mv	a1,s1
    31bc:	854a                	mv	a0,s2
    31be:	00002097          	auipc	ra,0x2
    31c2:	430080e7          	jalr	1072(ra) # 55ee <memset>
    if(write(fd, buf, SZ) != SZ){
    31c6:	25800613          	li	a2,600
    31ca:	85ca                	mv	a1,s2
    31cc:	854e                	mv	a0,s3
    31ce:	00002097          	auipc	ra,0x2
    31d2:	63c080e7          	jalr	1596(ra) # 580a <write>
    31d6:	25800793          	li	a5,600
    31da:	08f51a63          	bne	a0,a5,326e <bigfile+0x102>
  for(i = 0; i < N; i++){
    31de:	2485                	addiw	s1,s1,1
    31e0:	fd449be3          	bne	s1,s4,31b6 <bigfile+0x4a>
  close(fd);
    31e4:	854e                	mv	a0,s3
    31e6:	00002097          	auipc	ra,0x2
    31ea:	62c080e7          	jalr	1580(ra) # 5812 <close>
  fd = open("bigfile.dat", 0);
    31ee:	4581                	li	a1,0
    31f0:	00004517          	auipc	a0,0x4
    31f4:	3c850513          	addi	a0,a0,968 # 75b8 <malloc+0x1980>
    31f8:	00002097          	auipc	ra,0x2
    31fc:	632080e7          	jalr	1586(ra) # 582a <open>
    3200:	8a2a                	mv	s4,a0
  total = 0;
    3202:	4981                	li	s3,0
  for(i = 0; ; i++){
    3204:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    3206:	00009917          	auipc	s2,0x9
    320a:	8e290913          	addi	s2,s2,-1822 # bae8 <buf>
  if(fd < 0){
    320e:	06054e63          	bltz	a0,328a <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    3212:	12c00613          	li	a2,300
    3216:	85ca                	mv	a1,s2
    3218:	8552                	mv	a0,s4
    321a:	00002097          	auipc	ra,0x2
    321e:	5e8080e7          	jalr	1512(ra) # 5802 <read>
    if(cc < 0){
    3222:	08054263          	bltz	a0,32a6 <bigfile+0x13a>
    if(cc == 0)
    3226:	c971                	beqz	a0,32fa <bigfile+0x18e>
    if(cc != SZ/2){
    3228:	12c00793          	li	a5,300
    322c:	08f51b63          	bne	a0,a5,32c2 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    3230:	01f4d79b          	srliw	a5,s1,0x1f
    3234:	9fa5                	addw	a5,a5,s1
    3236:	4017d79b          	sraiw	a5,a5,0x1
    323a:	00094703          	lbu	a4,0(s2)
    323e:	0af71063          	bne	a4,a5,32de <bigfile+0x172>
    3242:	12b94703          	lbu	a4,299(s2)
    3246:	08f71c63          	bne	a4,a5,32de <bigfile+0x172>
    total += cc;
    324a:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    324e:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    3250:	b7c9                	j	3212 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    3252:	85d6                	mv	a1,s5
    3254:	00004517          	auipc	a0,0x4
    3258:	37450513          	addi	a0,a0,884 # 75c8 <malloc+0x1990>
    325c:	00003097          	auipc	ra,0x3
    3260:	91e080e7          	jalr	-1762(ra) # 5b7a <printf>
    exit(1);
    3264:	4505                	li	a0,1
    3266:	00002097          	auipc	ra,0x2
    326a:	584080e7          	jalr	1412(ra) # 57ea <exit>
      printf("%s: write bigfile failed\n", s);
    326e:	85d6                	mv	a1,s5
    3270:	00004517          	auipc	a0,0x4
    3274:	37850513          	addi	a0,a0,888 # 75e8 <malloc+0x19b0>
    3278:	00003097          	auipc	ra,0x3
    327c:	902080e7          	jalr	-1790(ra) # 5b7a <printf>
      exit(1);
    3280:	4505                	li	a0,1
    3282:	00002097          	auipc	ra,0x2
    3286:	568080e7          	jalr	1384(ra) # 57ea <exit>
    printf("%s: cannot open bigfile\n", s);
    328a:	85d6                	mv	a1,s5
    328c:	00004517          	auipc	a0,0x4
    3290:	37c50513          	addi	a0,a0,892 # 7608 <malloc+0x19d0>
    3294:	00003097          	auipc	ra,0x3
    3298:	8e6080e7          	jalr	-1818(ra) # 5b7a <printf>
    exit(1);
    329c:	4505                	li	a0,1
    329e:	00002097          	auipc	ra,0x2
    32a2:	54c080e7          	jalr	1356(ra) # 57ea <exit>
      printf("%s: read bigfile failed\n", s);
    32a6:	85d6                	mv	a1,s5
    32a8:	00004517          	auipc	a0,0x4
    32ac:	38050513          	addi	a0,a0,896 # 7628 <malloc+0x19f0>
    32b0:	00003097          	auipc	ra,0x3
    32b4:	8ca080e7          	jalr	-1846(ra) # 5b7a <printf>
      exit(1);
    32b8:	4505                	li	a0,1
    32ba:	00002097          	auipc	ra,0x2
    32be:	530080e7          	jalr	1328(ra) # 57ea <exit>
      printf("%s: short read bigfile\n", s);
    32c2:	85d6                	mv	a1,s5
    32c4:	00004517          	auipc	a0,0x4
    32c8:	38450513          	addi	a0,a0,900 # 7648 <malloc+0x1a10>
    32cc:	00003097          	auipc	ra,0x3
    32d0:	8ae080e7          	jalr	-1874(ra) # 5b7a <printf>
      exit(1);
    32d4:	4505                	li	a0,1
    32d6:	00002097          	auipc	ra,0x2
    32da:	514080e7          	jalr	1300(ra) # 57ea <exit>
      printf("%s: read bigfile wrong data\n", s);
    32de:	85d6                	mv	a1,s5
    32e0:	00004517          	auipc	a0,0x4
    32e4:	38050513          	addi	a0,a0,896 # 7660 <malloc+0x1a28>
    32e8:	00003097          	auipc	ra,0x3
    32ec:	892080e7          	jalr	-1902(ra) # 5b7a <printf>
      exit(1);
    32f0:	4505                	li	a0,1
    32f2:	00002097          	auipc	ra,0x2
    32f6:	4f8080e7          	jalr	1272(ra) # 57ea <exit>
  close(fd);
    32fa:	8552                	mv	a0,s4
    32fc:	00002097          	auipc	ra,0x2
    3300:	516080e7          	jalr	1302(ra) # 5812 <close>
  if(total != N*SZ){
    3304:	678d                	lui	a5,0x3
    3306:	ee078793          	addi	a5,a5,-288 # 2ee0 <reparent+0x68>
    330a:	02f99363          	bne	s3,a5,3330 <bigfile+0x1c4>
  unlink("bigfile.dat");
    330e:	00004517          	auipc	a0,0x4
    3312:	2aa50513          	addi	a0,a0,682 # 75b8 <malloc+0x1980>
    3316:	00002097          	auipc	ra,0x2
    331a:	524080e7          	jalr	1316(ra) # 583a <unlink>
}
    331e:	70e2                	ld	ra,56(sp)
    3320:	7442                	ld	s0,48(sp)
    3322:	74a2                	ld	s1,40(sp)
    3324:	7902                	ld	s2,32(sp)
    3326:	69e2                	ld	s3,24(sp)
    3328:	6a42                	ld	s4,16(sp)
    332a:	6aa2                	ld	s5,8(sp)
    332c:	6121                	addi	sp,sp,64
    332e:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    3330:	85d6                	mv	a1,s5
    3332:	00004517          	auipc	a0,0x4
    3336:	34e50513          	addi	a0,a0,846 # 7680 <malloc+0x1a48>
    333a:	00003097          	auipc	ra,0x3
    333e:	840080e7          	jalr	-1984(ra) # 5b7a <printf>
    exit(1);
    3342:	4505                	li	a0,1
    3344:	00002097          	auipc	ra,0x2
    3348:	4a6080e7          	jalr	1190(ra) # 57ea <exit>

000000000000334c <truncate3>:
{
    334c:	7159                	addi	sp,sp,-112
    334e:	f486                	sd	ra,104(sp)
    3350:	f0a2                	sd	s0,96(sp)
    3352:	eca6                	sd	s1,88(sp)
    3354:	e8ca                	sd	s2,80(sp)
    3356:	e4ce                	sd	s3,72(sp)
    3358:	e0d2                	sd	s4,64(sp)
    335a:	fc56                	sd	s5,56(sp)
    335c:	1880                	addi	s0,sp,112
    335e:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    3360:	60100593          	li	a1,1537
    3364:	00003517          	auipc	a0,0x3
    3368:	dac50513          	addi	a0,a0,-596 # 6110 <malloc+0x4d8>
    336c:	00002097          	auipc	ra,0x2
    3370:	4be080e7          	jalr	1214(ra) # 582a <open>
    3374:	00002097          	auipc	ra,0x2
    3378:	49e080e7          	jalr	1182(ra) # 5812 <close>
  pid = fork();
    337c:	00002097          	auipc	ra,0x2
    3380:	466080e7          	jalr	1126(ra) # 57e2 <fork>
  if(pid < 0){
    3384:	08054063          	bltz	a0,3404 <truncate3+0xb8>
  if(pid == 0){
    3388:	e969                	bnez	a0,345a <truncate3+0x10e>
    338a:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    338e:	00003a17          	auipc	s4,0x3
    3392:	d82a0a13          	addi	s4,s4,-638 # 6110 <malloc+0x4d8>
      int n = write(fd, "1234567890", 10);
    3396:	00004a97          	auipc	s5,0x4
    339a:	30aa8a93          	addi	s5,s5,778 # 76a0 <malloc+0x1a68>
      int fd = open("truncfile", O_WRONLY);
    339e:	4585                	li	a1,1
    33a0:	8552                	mv	a0,s4
    33a2:	00002097          	auipc	ra,0x2
    33a6:	488080e7          	jalr	1160(ra) # 582a <open>
    33aa:	84aa                	mv	s1,a0
      if(fd < 0){
    33ac:	06054a63          	bltz	a0,3420 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    33b0:	4629                	li	a2,10
    33b2:	85d6                	mv	a1,s5
    33b4:	00002097          	auipc	ra,0x2
    33b8:	456080e7          	jalr	1110(ra) # 580a <write>
      if(n != 10){
    33bc:	47a9                	li	a5,10
    33be:	06f51f63          	bne	a0,a5,343c <truncate3+0xf0>
      close(fd);
    33c2:	8526                	mv	a0,s1
    33c4:	00002097          	auipc	ra,0x2
    33c8:	44e080e7          	jalr	1102(ra) # 5812 <close>
      fd = open("truncfile", O_RDONLY);
    33cc:	4581                	li	a1,0
    33ce:	8552                	mv	a0,s4
    33d0:	00002097          	auipc	ra,0x2
    33d4:	45a080e7          	jalr	1114(ra) # 582a <open>
    33d8:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    33da:	02000613          	li	a2,32
    33de:	f9840593          	addi	a1,s0,-104
    33e2:	00002097          	auipc	ra,0x2
    33e6:	420080e7          	jalr	1056(ra) # 5802 <read>
      close(fd);
    33ea:	8526                	mv	a0,s1
    33ec:	00002097          	auipc	ra,0x2
    33f0:	426080e7          	jalr	1062(ra) # 5812 <close>
    for(int i = 0; i < 100; i++){
    33f4:	39fd                	addiw	s3,s3,-1
    33f6:	fa0994e3          	bnez	s3,339e <truncate3+0x52>
    exit(0);
    33fa:	4501                	li	a0,0
    33fc:	00002097          	auipc	ra,0x2
    3400:	3ee080e7          	jalr	1006(ra) # 57ea <exit>
    printf("%s: fork failed\n", s);
    3404:	85ca                	mv	a1,s2
    3406:	00003517          	auipc	a0,0x3
    340a:	ba250513          	addi	a0,a0,-1118 # 5fa8 <malloc+0x370>
    340e:	00002097          	auipc	ra,0x2
    3412:	76c080e7          	jalr	1900(ra) # 5b7a <printf>
    exit(1);
    3416:	4505                	li	a0,1
    3418:	00002097          	auipc	ra,0x2
    341c:	3d2080e7          	jalr	978(ra) # 57ea <exit>
        printf("%s: open failed\n", s);
    3420:	85ca                	mv	a1,s2
    3422:	00003517          	auipc	a0,0x3
    3426:	3ce50513          	addi	a0,a0,974 # 67f0 <malloc+0xbb8>
    342a:	00002097          	auipc	ra,0x2
    342e:	750080e7          	jalr	1872(ra) # 5b7a <printf>
        exit(1);
    3432:	4505                	li	a0,1
    3434:	00002097          	auipc	ra,0x2
    3438:	3b6080e7          	jalr	950(ra) # 57ea <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    343c:	862a                	mv	a2,a0
    343e:	85ca                	mv	a1,s2
    3440:	00004517          	auipc	a0,0x4
    3444:	27050513          	addi	a0,a0,624 # 76b0 <malloc+0x1a78>
    3448:	00002097          	auipc	ra,0x2
    344c:	732080e7          	jalr	1842(ra) # 5b7a <printf>
        exit(1);
    3450:	4505                	li	a0,1
    3452:	00002097          	auipc	ra,0x2
    3456:	398080e7          	jalr	920(ra) # 57ea <exit>
    345a:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    345e:	00003a17          	auipc	s4,0x3
    3462:	cb2a0a13          	addi	s4,s4,-846 # 6110 <malloc+0x4d8>
    int n = write(fd, "xxx", 3);
    3466:	00004a97          	auipc	s5,0x4
    346a:	26aa8a93          	addi	s5,s5,618 # 76d0 <malloc+0x1a98>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    346e:	60100593          	li	a1,1537
    3472:	8552                	mv	a0,s4
    3474:	00002097          	auipc	ra,0x2
    3478:	3b6080e7          	jalr	950(ra) # 582a <open>
    347c:	84aa                	mv	s1,a0
    if(fd < 0){
    347e:	04054763          	bltz	a0,34cc <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    3482:	460d                	li	a2,3
    3484:	85d6                	mv	a1,s5
    3486:	00002097          	auipc	ra,0x2
    348a:	384080e7          	jalr	900(ra) # 580a <write>
    if(n != 3){
    348e:	478d                	li	a5,3
    3490:	04f51c63          	bne	a0,a5,34e8 <truncate3+0x19c>
    close(fd);
    3494:	8526                	mv	a0,s1
    3496:	00002097          	auipc	ra,0x2
    349a:	37c080e7          	jalr	892(ra) # 5812 <close>
  for(int i = 0; i < 150; i++){
    349e:	39fd                	addiw	s3,s3,-1
    34a0:	fc0997e3          	bnez	s3,346e <truncate3+0x122>
  wait(&xstatus);
    34a4:	fbc40513          	addi	a0,s0,-68
    34a8:	00002097          	auipc	ra,0x2
    34ac:	34a080e7          	jalr	842(ra) # 57f2 <wait>
  unlink("truncfile");
    34b0:	00003517          	auipc	a0,0x3
    34b4:	c6050513          	addi	a0,a0,-928 # 6110 <malloc+0x4d8>
    34b8:	00002097          	auipc	ra,0x2
    34bc:	382080e7          	jalr	898(ra) # 583a <unlink>
  exit(xstatus);
    34c0:	fbc42503          	lw	a0,-68(s0)
    34c4:	00002097          	auipc	ra,0x2
    34c8:	326080e7          	jalr	806(ra) # 57ea <exit>
      printf("%s: open failed\n", s);
    34cc:	85ca                	mv	a1,s2
    34ce:	00003517          	auipc	a0,0x3
    34d2:	32250513          	addi	a0,a0,802 # 67f0 <malloc+0xbb8>
    34d6:	00002097          	auipc	ra,0x2
    34da:	6a4080e7          	jalr	1700(ra) # 5b7a <printf>
      exit(1);
    34de:	4505                	li	a0,1
    34e0:	00002097          	auipc	ra,0x2
    34e4:	30a080e7          	jalr	778(ra) # 57ea <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    34e8:	862a                	mv	a2,a0
    34ea:	85ca                	mv	a1,s2
    34ec:	00004517          	auipc	a0,0x4
    34f0:	1ec50513          	addi	a0,a0,492 # 76d8 <malloc+0x1aa0>
    34f4:	00002097          	auipc	ra,0x2
    34f8:	686080e7          	jalr	1670(ra) # 5b7a <printf>
      exit(1);
    34fc:	4505                	li	a0,1
    34fe:	00002097          	auipc	ra,0x2
    3502:	2ec080e7          	jalr	748(ra) # 57ea <exit>

0000000000003506 <writetest>:
{
    3506:	7139                	addi	sp,sp,-64
    3508:	fc06                	sd	ra,56(sp)
    350a:	f822                	sd	s0,48(sp)
    350c:	f426                	sd	s1,40(sp)
    350e:	f04a                	sd	s2,32(sp)
    3510:	ec4e                	sd	s3,24(sp)
    3512:	e852                	sd	s4,16(sp)
    3514:	e456                	sd	s5,8(sp)
    3516:	e05a                	sd	s6,0(sp)
    3518:	0080                	addi	s0,sp,64
    351a:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
    351c:	20200593          	li	a1,514
    3520:	00004517          	auipc	a0,0x4
    3524:	1d850513          	addi	a0,a0,472 # 76f8 <malloc+0x1ac0>
    3528:	00002097          	auipc	ra,0x2
    352c:	302080e7          	jalr	770(ra) # 582a <open>
  if(fd < 0){
    3530:	0a054d63          	bltz	a0,35ea <writetest+0xe4>
    3534:	892a                	mv	s2,a0
    3536:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
    3538:	00004997          	auipc	s3,0x4
    353c:	1e898993          	addi	s3,s3,488 # 7720 <malloc+0x1ae8>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
    3540:	00004a97          	auipc	s5,0x4
    3544:	218a8a93          	addi	s5,s5,536 # 7758 <malloc+0x1b20>
  for(i = 0; i < N; i++){
    3548:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
    354c:	4629                	li	a2,10
    354e:	85ce                	mv	a1,s3
    3550:	854a                	mv	a0,s2
    3552:	00002097          	auipc	ra,0x2
    3556:	2b8080e7          	jalr	696(ra) # 580a <write>
    355a:	47a9                	li	a5,10
    355c:	0af51563          	bne	a0,a5,3606 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
    3560:	4629                	li	a2,10
    3562:	85d6                	mv	a1,s5
    3564:	854a                	mv	a0,s2
    3566:	00002097          	auipc	ra,0x2
    356a:	2a4080e7          	jalr	676(ra) # 580a <write>
    356e:	47a9                	li	a5,10
    3570:	0af51a63          	bne	a0,a5,3624 <writetest+0x11e>
  for(i = 0; i < N; i++){
    3574:	2485                	addiw	s1,s1,1
    3576:	fd449be3          	bne	s1,s4,354c <writetest+0x46>
  close(fd);
    357a:	854a                	mv	a0,s2
    357c:	00002097          	auipc	ra,0x2
    3580:	296080e7          	jalr	662(ra) # 5812 <close>
  fd = open("small", O_RDONLY);
    3584:	4581                	li	a1,0
    3586:	00004517          	auipc	a0,0x4
    358a:	17250513          	addi	a0,a0,370 # 76f8 <malloc+0x1ac0>
    358e:	00002097          	auipc	ra,0x2
    3592:	29c080e7          	jalr	668(ra) # 582a <open>
    3596:	84aa                	mv	s1,a0
  if(fd < 0){
    3598:	0a054563          	bltz	a0,3642 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
    359c:	7d000613          	li	a2,2000
    35a0:	00008597          	auipc	a1,0x8
    35a4:	54858593          	addi	a1,a1,1352 # bae8 <buf>
    35a8:	00002097          	auipc	ra,0x2
    35ac:	25a080e7          	jalr	602(ra) # 5802 <read>
  if(i != N*SZ*2){
    35b0:	7d000793          	li	a5,2000
    35b4:	0af51563          	bne	a0,a5,365e <writetest+0x158>
  close(fd);
    35b8:	8526                	mv	a0,s1
    35ba:	00002097          	auipc	ra,0x2
    35be:	258080e7          	jalr	600(ra) # 5812 <close>
  if(unlink("small") < 0){
    35c2:	00004517          	auipc	a0,0x4
    35c6:	13650513          	addi	a0,a0,310 # 76f8 <malloc+0x1ac0>
    35ca:	00002097          	auipc	ra,0x2
    35ce:	270080e7          	jalr	624(ra) # 583a <unlink>
    35d2:	0a054463          	bltz	a0,367a <writetest+0x174>
}
    35d6:	70e2                	ld	ra,56(sp)
    35d8:	7442                	ld	s0,48(sp)
    35da:	74a2                	ld	s1,40(sp)
    35dc:	7902                	ld	s2,32(sp)
    35de:	69e2                	ld	s3,24(sp)
    35e0:	6a42                	ld	s4,16(sp)
    35e2:	6aa2                	ld	s5,8(sp)
    35e4:	6b02                	ld	s6,0(sp)
    35e6:	6121                	addi	sp,sp,64
    35e8:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
    35ea:	85da                	mv	a1,s6
    35ec:	00004517          	auipc	a0,0x4
    35f0:	11450513          	addi	a0,a0,276 # 7700 <malloc+0x1ac8>
    35f4:	00002097          	auipc	ra,0x2
    35f8:	586080e7          	jalr	1414(ra) # 5b7a <printf>
    exit(1);
    35fc:	4505                	li	a0,1
    35fe:	00002097          	auipc	ra,0x2
    3602:	1ec080e7          	jalr	492(ra) # 57ea <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
    3606:	8626                	mv	a2,s1
    3608:	85da                	mv	a1,s6
    360a:	00004517          	auipc	a0,0x4
    360e:	12650513          	addi	a0,a0,294 # 7730 <malloc+0x1af8>
    3612:	00002097          	auipc	ra,0x2
    3616:	568080e7          	jalr	1384(ra) # 5b7a <printf>
      exit(1);
    361a:	4505                	li	a0,1
    361c:	00002097          	auipc	ra,0x2
    3620:	1ce080e7          	jalr	462(ra) # 57ea <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
    3624:	8626                	mv	a2,s1
    3626:	85da                	mv	a1,s6
    3628:	00004517          	auipc	a0,0x4
    362c:	14050513          	addi	a0,a0,320 # 7768 <malloc+0x1b30>
    3630:	00002097          	auipc	ra,0x2
    3634:	54a080e7          	jalr	1354(ra) # 5b7a <printf>
      exit(1);
    3638:	4505                	li	a0,1
    363a:	00002097          	auipc	ra,0x2
    363e:	1b0080e7          	jalr	432(ra) # 57ea <exit>
    printf("%s: error: open small failed!\n", s);
    3642:	85da                	mv	a1,s6
    3644:	00004517          	auipc	a0,0x4
    3648:	14c50513          	addi	a0,a0,332 # 7790 <malloc+0x1b58>
    364c:	00002097          	auipc	ra,0x2
    3650:	52e080e7          	jalr	1326(ra) # 5b7a <printf>
    exit(1);
    3654:	4505                	li	a0,1
    3656:	00002097          	auipc	ra,0x2
    365a:	194080e7          	jalr	404(ra) # 57ea <exit>
    printf("%s: read failed\n", s);
    365e:	85da                	mv	a1,s6
    3660:	00003517          	auipc	a0,0x3
    3664:	1a850513          	addi	a0,a0,424 # 6808 <malloc+0xbd0>
    3668:	00002097          	auipc	ra,0x2
    366c:	512080e7          	jalr	1298(ra) # 5b7a <printf>
    exit(1);
    3670:	4505                	li	a0,1
    3672:	00002097          	auipc	ra,0x2
    3676:	178080e7          	jalr	376(ra) # 57ea <exit>
    printf("%s: unlink small failed\n", s);
    367a:	85da                	mv	a1,s6
    367c:	00004517          	auipc	a0,0x4
    3680:	13450513          	addi	a0,a0,308 # 77b0 <malloc+0x1b78>
    3684:	00002097          	auipc	ra,0x2
    3688:	4f6080e7          	jalr	1270(ra) # 5b7a <printf>
    exit(1);
    368c:	4505                	li	a0,1
    368e:	00002097          	auipc	ra,0x2
    3692:	15c080e7          	jalr	348(ra) # 57ea <exit>

0000000000003696 <writebig>:
{
    3696:	7139                	addi	sp,sp,-64
    3698:	fc06                	sd	ra,56(sp)
    369a:	f822                	sd	s0,48(sp)
    369c:	f426                	sd	s1,40(sp)
    369e:	f04a                	sd	s2,32(sp)
    36a0:	ec4e                	sd	s3,24(sp)
    36a2:	e852                	sd	s4,16(sp)
    36a4:	e456                	sd	s5,8(sp)
    36a6:	0080                	addi	s0,sp,64
    36a8:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
    36aa:	20200593          	li	a1,514
    36ae:	00004517          	auipc	a0,0x4
    36b2:	12250513          	addi	a0,a0,290 # 77d0 <malloc+0x1b98>
    36b6:	00002097          	auipc	ra,0x2
    36ba:	174080e7          	jalr	372(ra) # 582a <open>
    36be:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
    36c0:	4481                	li	s1,0
    ((int*)buf)[0] = i;
    36c2:	00008917          	auipc	s2,0x8
    36c6:	42690913          	addi	s2,s2,1062 # bae8 <buf>
  for(i = 0; i < MAXFILE; i++){
    36ca:	10c00a13          	li	s4,268
  if(fd < 0){
    36ce:	06054c63          	bltz	a0,3746 <writebig+0xb0>
    ((int*)buf)[0] = i;
    36d2:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
    36d6:	40000613          	li	a2,1024
    36da:	85ca                	mv	a1,s2
    36dc:	854e                	mv	a0,s3
    36de:	00002097          	auipc	ra,0x2
    36e2:	12c080e7          	jalr	300(ra) # 580a <write>
    36e6:	40000793          	li	a5,1024
    36ea:	06f51c63          	bne	a0,a5,3762 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
    36ee:	2485                	addiw	s1,s1,1
    36f0:	ff4491e3          	bne	s1,s4,36d2 <writebig+0x3c>
  close(fd);
    36f4:	854e                	mv	a0,s3
    36f6:	00002097          	auipc	ra,0x2
    36fa:	11c080e7          	jalr	284(ra) # 5812 <close>
  fd = open("big", O_RDONLY);
    36fe:	4581                	li	a1,0
    3700:	00004517          	auipc	a0,0x4
    3704:	0d050513          	addi	a0,a0,208 # 77d0 <malloc+0x1b98>
    3708:	00002097          	auipc	ra,0x2
    370c:	122080e7          	jalr	290(ra) # 582a <open>
    3710:	89aa                	mv	s3,a0
  n = 0;
    3712:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
    3714:	00008917          	auipc	s2,0x8
    3718:	3d490913          	addi	s2,s2,980 # bae8 <buf>
  if(fd < 0){
    371c:	06054263          	bltz	a0,3780 <writebig+0xea>
    i = read(fd, buf, BSIZE);
    3720:	40000613          	li	a2,1024
    3724:	85ca                	mv	a1,s2
    3726:	854e                	mv	a0,s3
    3728:	00002097          	auipc	ra,0x2
    372c:	0da080e7          	jalr	218(ra) # 5802 <read>
    if(i == 0){
    3730:	c535                	beqz	a0,379c <writebig+0x106>
    } else if(i != BSIZE){
    3732:	40000793          	li	a5,1024
    3736:	0af51f63          	bne	a0,a5,37f4 <writebig+0x15e>
    if(((int*)buf)[0] != n){
    373a:	00092683          	lw	a3,0(s2)
    373e:	0c969a63          	bne	a3,s1,3812 <writebig+0x17c>
    n++;
    3742:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
    3744:	bff1                	j	3720 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
    3746:	85d6                	mv	a1,s5
    3748:	00004517          	auipc	a0,0x4
    374c:	09050513          	addi	a0,a0,144 # 77d8 <malloc+0x1ba0>
    3750:	00002097          	auipc	ra,0x2
    3754:	42a080e7          	jalr	1066(ra) # 5b7a <printf>
    exit(1);
    3758:	4505                	li	a0,1
    375a:	00002097          	auipc	ra,0x2
    375e:	090080e7          	jalr	144(ra) # 57ea <exit>
      printf("%s: error: write big file failed\n", s, i);
    3762:	8626                	mv	a2,s1
    3764:	85d6                	mv	a1,s5
    3766:	00004517          	auipc	a0,0x4
    376a:	09250513          	addi	a0,a0,146 # 77f8 <malloc+0x1bc0>
    376e:	00002097          	auipc	ra,0x2
    3772:	40c080e7          	jalr	1036(ra) # 5b7a <printf>
      exit(1);
    3776:	4505                	li	a0,1
    3778:	00002097          	auipc	ra,0x2
    377c:	072080e7          	jalr	114(ra) # 57ea <exit>
    printf("%s: error: open big failed!\n", s);
    3780:	85d6                	mv	a1,s5
    3782:	00004517          	auipc	a0,0x4
    3786:	09e50513          	addi	a0,a0,158 # 7820 <malloc+0x1be8>
    378a:	00002097          	auipc	ra,0x2
    378e:	3f0080e7          	jalr	1008(ra) # 5b7a <printf>
    exit(1);
    3792:	4505                	li	a0,1
    3794:	00002097          	auipc	ra,0x2
    3798:	056080e7          	jalr	86(ra) # 57ea <exit>
      if(n == MAXFILE - 1){
    379c:	10b00793          	li	a5,267
    37a0:	02f48a63          	beq	s1,a5,37d4 <writebig+0x13e>
  close(fd);
    37a4:	854e                	mv	a0,s3
    37a6:	00002097          	auipc	ra,0x2
    37aa:	06c080e7          	jalr	108(ra) # 5812 <close>
  if(unlink("big") < 0){
    37ae:	00004517          	auipc	a0,0x4
    37b2:	02250513          	addi	a0,a0,34 # 77d0 <malloc+0x1b98>
    37b6:	00002097          	auipc	ra,0x2
    37ba:	084080e7          	jalr	132(ra) # 583a <unlink>
    37be:	06054963          	bltz	a0,3830 <writebig+0x19a>
}
    37c2:	70e2                	ld	ra,56(sp)
    37c4:	7442                	ld	s0,48(sp)
    37c6:	74a2                	ld	s1,40(sp)
    37c8:	7902                	ld	s2,32(sp)
    37ca:	69e2                	ld	s3,24(sp)
    37cc:	6a42                	ld	s4,16(sp)
    37ce:	6aa2                	ld	s5,8(sp)
    37d0:	6121                	addi	sp,sp,64
    37d2:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
    37d4:	10b00613          	li	a2,267
    37d8:	85d6                	mv	a1,s5
    37da:	00004517          	auipc	a0,0x4
    37de:	06650513          	addi	a0,a0,102 # 7840 <malloc+0x1c08>
    37e2:	00002097          	auipc	ra,0x2
    37e6:	398080e7          	jalr	920(ra) # 5b7a <printf>
        exit(1);
    37ea:	4505                	li	a0,1
    37ec:	00002097          	auipc	ra,0x2
    37f0:	ffe080e7          	jalr	-2(ra) # 57ea <exit>
      printf("%s: read failed %d\n", s, i);
    37f4:	862a                	mv	a2,a0
    37f6:	85d6                	mv	a1,s5
    37f8:	00004517          	auipc	a0,0x4
    37fc:	07050513          	addi	a0,a0,112 # 7868 <malloc+0x1c30>
    3800:	00002097          	auipc	ra,0x2
    3804:	37a080e7          	jalr	890(ra) # 5b7a <printf>
      exit(1);
    3808:	4505                	li	a0,1
    380a:	00002097          	auipc	ra,0x2
    380e:	fe0080e7          	jalr	-32(ra) # 57ea <exit>
      printf("%s: read content of block %d is %d\n", s,
    3812:	8626                	mv	a2,s1
    3814:	85d6                	mv	a1,s5
    3816:	00004517          	auipc	a0,0x4
    381a:	06a50513          	addi	a0,a0,106 # 7880 <malloc+0x1c48>
    381e:	00002097          	auipc	ra,0x2
    3822:	35c080e7          	jalr	860(ra) # 5b7a <printf>
      exit(1);
    3826:	4505                	li	a0,1
    3828:	00002097          	auipc	ra,0x2
    382c:	fc2080e7          	jalr	-62(ra) # 57ea <exit>
    printf("%s: unlink big failed\n", s);
    3830:	85d6                	mv	a1,s5
    3832:	00004517          	auipc	a0,0x4
    3836:	07650513          	addi	a0,a0,118 # 78a8 <malloc+0x1c70>
    383a:	00002097          	auipc	ra,0x2
    383e:	340080e7          	jalr	832(ra) # 5b7a <printf>
    exit(1);
    3842:	4505                	li	a0,1
    3844:	00002097          	auipc	ra,0x2
    3848:	fa6080e7          	jalr	-90(ra) # 57ea <exit>

000000000000384c <createtest>:
{
    384c:	7179                	addi	sp,sp,-48
    384e:	f406                	sd	ra,40(sp)
    3850:	f022                	sd	s0,32(sp)
    3852:	ec26                	sd	s1,24(sp)
    3854:	e84a                	sd	s2,16(sp)
    3856:	1800                	addi	s0,sp,48
  name[0] = 'a';
    3858:	06100793          	li	a5,97
    385c:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
    3860:	fc040d23          	sb	zero,-38(s0)
    3864:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
    3868:	06400913          	li	s2,100
    name[1] = '0' + i;
    386c:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
    3870:	20200593          	li	a1,514
    3874:	fd840513          	addi	a0,s0,-40
    3878:	00002097          	auipc	ra,0x2
    387c:	fb2080e7          	jalr	-78(ra) # 582a <open>
    close(fd);
    3880:	00002097          	auipc	ra,0x2
    3884:	f92080e7          	jalr	-110(ra) # 5812 <close>
  for(i = 0; i < N; i++){
    3888:	2485                	addiw	s1,s1,1
    388a:	0ff4f493          	andi	s1,s1,255
    388e:	fd249fe3          	bne	s1,s2,386c <createtest+0x20>
  name[0] = 'a';
    3892:	06100793          	li	a5,97
    3896:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
    389a:	fc040d23          	sb	zero,-38(s0)
    389e:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
    38a2:	06400913          	li	s2,100
    name[1] = '0' + i;
    38a6:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
    38aa:	fd840513          	addi	a0,s0,-40
    38ae:	00002097          	auipc	ra,0x2
    38b2:	f8c080e7          	jalr	-116(ra) # 583a <unlink>
  for(i = 0; i < N; i++){
    38b6:	2485                	addiw	s1,s1,1
    38b8:	0ff4f493          	andi	s1,s1,255
    38bc:	ff2495e3          	bne	s1,s2,38a6 <createtest+0x5a>
}
    38c0:	70a2                	ld	ra,40(sp)
    38c2:	7402                	ld	s0,32(sp)
    38c4:	64e2                	ld	s1,24(sp)
    38c6:	6942                	ld	s2,16(sp)
    38c8:	6145                	addi	sp,sp,48
    38ca:	8082                	ret

00000000000038cc <killstatus>:
{
    38cc:	7139                	addi	sp,sp,-64
    38ce:	fc06                	sd	ra,56(sp)
    38d0:	f822                	sd	s0,48(sp)
    38d2:	f426                	sd	s1,40(sp)
    38d4:	f04a                	sd	s2,32(sp)
    38d6:	ec4e                	sd	s3,24(sp)
    38d8:	e852                	sd	s4,16(sp)
    38da:	0080                	addi	s0,sp,64
    38dc:	8a2a                	mv	s4,a0
    38de:	06400913          	li	s2,100
    if(xst != -1) {
    38e2:	59fd                	li	s3,-1
    int pid1 = fork();
    38e4:	00002097          	auipc	ra,0x2
    38e8:	efe080e7          	jalr	-258(ra) # 57e2 <fork>
    38ec:	84aa                	mv	s1,a0
    if(pid1 < 0){
    38ee:	04054063          	bltz	a0,392e <killstatus+0x62>
    if(pid1 == 0){
    38f2:	cd21                	beqz	a0,394a <killstatus+0x7e>
    sleep(1);
    38f4:	4505                	li	a0,1
    38f6:	00002097          	auipc	ra,0x2
    38fa:	f84080e7          	jalr	-124(ra) # 587a <sleep>
    kill(pid1, SIGKILL);
    38fe:	45a5                	li	a1,9
    3900:	8526                	mv	a0,s1
    3902:	00002097          	auipc	ra,0x2
    3906:	f18080e7          	jalr	-232(ra) # 581a <kill>
    wait(&xst);
    390a:	fcc40513          	addi	a0,s0,-52
    390e:	00002097          	auipc	ra,0x2
    3912:	ee4080e7          	jalr	-284(ra) # 57f2 <wait>
    if(xst != -1) {
    3916:	fcc42783          	lw	a5,-52(s0)
    391a:	03379d63          	bne	a5,s3,3954 <killstatus+0x88>
  for(int i = 0; i < 100; i++){
    391e:	397d                	addiw	s2,s2,-1
    3920:	fc0912e3          	bnez	s2,38e4 <killstatus+0x18>
  exit(0);
    3924:	4501                	li	a0,0
    3926:	00002097          	auipc	ra,0x2
    392a:	ec4080e7          	jalr	-316(ra) # 57ea <exit>
      printf("%s: fork failed\n", s);
    392e:	85d2                	mv	a1,s4
    3930:	00002517          	auipc	a0,0x2
    3934:	67850513          	addi	a0,a0,1656 # 5fa8 <malloc+0x370>
    3938:	00002097          	auipc	ra,0x2
    393c:	242080e7          	jalr	578(ra) # 5b7a <printf>
      exit(1);
    3940:	4505                	li	a0,1
    3942:	00002097          	auipc	ra,0x2
    3946:	ea8080e7          	jalr	-344(ra) # 57ea <exit>
        getpid();
    394a:	00002097          	auipc	ra,0x2
    394e:	f20080e7          	jalr	-224(ra) # 586a <getpid>
      while(1) {
    3952:	bfe5                	j	394a <killstatus+0x7e>
       printf("%s: status should be -1\n", s);
    3954:	85d2                	mv	a1,s4
    3956:	00004517          	auipc	a0,0x4
    395a:	f6a50513          	addi	a0,a0,-150 # 78c0 <malloc+0x1c88>
    395e:	00002097          	auipc	ra,0x2
    3962:	21c080e7          	jalr	540(ra) # 5b7a <printf>
       exit(1);
    3966:	4505                	li	a0,1
    3968:	00002097          	auipc	ra,0x2
    396c:	e82080e7          	jalr	-382(ra) # 57ea <exit>

0000000000003970 <reparent2>:
{
    3970:	1101                	addi	sp,sp,-32
    3972:	ec06                	sd	ra,24(sp)
    3974:	e822                	sd	s0,16(sp)
    3976:	e426                	sd	s1,8(sp)
    3978:	1000                	addi	s0,sp,32
    397a:	32000493          	li	s1,800
    int pid1 = fork();
    397e:	00002097          	auipc	ra,0x2
    3982:	e64080e7          	jalr	-412(ra) # 57e2 <fork>
    if(pid1 < 0){
    3986:	00054f63          	bltz	a0,39a4 <reparent2+0x34>
    if(pid1 == 0){
    398a:	c915                	beqz	a0,39be <reparent2+0x4e>
    wait(0);
    398c:	4501                	li	a0,0
    398e:	00002097          	auipc	ra,0x2
    3992:	e64080e7          	jalr	-412(ra) # 57f2 <wait>
  for(int i = 0; i < 800; i++){
    3996:	34fd                	addiw	s1,s1,-1
    3998:	f0fd                	bnez	s1,397e <reparent2+0xe>
  exit(0);
    399a:	4501                	li	a0,0
    399c:	00002097          	auipc	ra,0x2
    39a0:	e4e080e7          	jalr	-434(ra) # 57ea <exit>
      printf("fork failed\n");
    39a4:	00003517          	auipc	a0,0x3
    39a8:	f9450513          	addi	a0,a0,-108 # 6938 <malloc+0xd00>
    39ac:	00002097          	auipc	ra,0x2
    39b0:	1ce080e7          	jalr	462(ra) # 5b7a <printf>
      exit(1);
    39b4:	4505                	li	a0,1
    39b6:	00002097          	auipc	ra,0x2
    39ba:	e34080e7          	jalr	-460(ra) # 57ea <exit>
      fork();
    39be:	00002097          	auipc	ra,0x2
    39c2:	e24080e7          	jalr	-476(ra) # 57e2 <fork>
      fork();
    39c6:	00002097          	auipc	ra,0x2
    39ca:	e1c080e7          	jalr	-484(ra) # 57e2 <fork>
      exit(0);
    39ce:	4501                	li	a0,0
    39d0:	00002097          	auipc	ra,0x2
    39d4:	e1a080e7          	jalr	-486(ra) # 57ea <exit>

00000000000039d8 <mem>:
{
    39d8:	7139                	addi	sp,sp,-64
    39da:	fc06                	sd	ra,56(sp)
    39dc:	f822                	sd	s0,48(sp)
    39de:	f426                	sd	s1,40(sp)
    39e0:	f04a                	sd	s2,32(sp)
    39e2:	ec4e                	sd	s3,24(sp)
    39e4:	0080                	addi	s0,sp,64
    39e6:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    39e8:	00002097          	auipc	ra,0x2
    39ec:	dfa080e7          	jalr	-518(ra) # 57e2 <fork>
    m1 = 0;
    39f0:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    39f2:	6909                	lui	s2,0x2
    39f4:	71190913          	addi	s2,s2,1809 # 2711 <subdir+0x419>
  if((pid = fork()) == 0){
    39f8:	c115                	beqz	a0,3a1c <mem+0x44>
    wait(&xstatus);
    39fa:	fcc40513          	addi	a0,s0,-52
    39fe:	00002097          	auipc	ra,0x2
    3a02:	df4080e7          	jalr	-524(ra) # 57f2 <wait>
    if(xstatus == -1){
    3a06:	fcc42503          	lw	a0,-52(s0)
    3a0a:	57fd                	li	a5,-1
    3a0c:	06f50363          	beq	a0,a5,3a72 <mem+0x9a>
    exit(xstatus);
    3a10:	00002097          	auipc	ra,0x2
    3a14:	dda080e7          	jalr	-550(ra) # 57ea <exit>
      *(char**)m2 = m1;
    3a18:	e104                	sd	s1,0(a0)
      m1 = m2;
    3a1a:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    3a1c:	854a                	mv	a0,s2
    3a1e:	00002097          	auipc	ra,0x2
    3a22:	21a080e7          	jalr	538(ra) # 5c38 <malloc>
    3a26:	f96d                	bnez	a0,3a18 <mem+0x40>
    while(m1){
    3a28:	c881                	beqz	s1,3a38 <mem+0x60>
      m2 = *(char**)m1;
    3a2a:	8526                	mv	a0,s1
    3a2c:	6084                	ld	s1,0(s1)
      free(m1);
    3a2e:	00002097          	auipc	ra,0x2
    3a32:	182080e7          	jalr	386(ra) # 5bb0 <free>
    while(m1){
    3a36:	f8f5                	bnez	s1,3a2a <mem+0x52>
    m1 = malloc(1024*20);
    3a38:	6515                	lui	a0,0x5
    3a3a:	00002097          	auipc	ra,0x2
    3a3e:	1fe080e7          	jalr	510(ra) # 5c38 <malloc>
    if(m1 == 0){
    3a42:	c911                	beqz	a0,3a56 <mem+0x7e>
    free(m1);
    3a44:	00002097          	auipc	ra,0x2
    3a48:	16c080e7          	jalr	364(ra) # 5bb0 <free>
    exit(0);
    3a4c:	4501                	li	a0,0
    3a4e:	00002097          	auipc	ra,0x2
    3a52:	d9c080e7          	jalr	-612(ra) # 57ea <exit>
      printf("couldn't allocate mem?!!\n", s);
    3a56:	85ce                	mv	a1,s3
    3a58:	00004517          	auipc	a0,0x4
    3a5c:	e8850513          	addi	a0,a0,-376 # 78e0 <malloc+0x1ca8>
    3a60:	00002097          	auipc	ra,0x2
    3a64:	11a080e7          	jalr	282(ra) # 5b7a <printf>
      exit(1);
    3a68:	4505                	li	a0,1
    3a6a:	00002097          	auipc	ra,0x2
    3a6e:	d80080e7          	jalr	-640(ra) # 57ea <exit>
      exit(0);
    3a72:	4501                	li	a0,0
    3a74:	00002097          	auipc	ra,0x2
    3a78:	d76080e7          	jalr	-650(ra) # 57ea <exit>

0000000000003a7c <sharedfd>:
{
    3a7c:	7159                	addi	sp,sp,-112
    3a7e:	f486                	sd	ra,104(sp)
    3a80:	f0a2                	sd	s0,96(sp)
    3a82:	eca6                	sd	s1,88(sp)
    3a84:	e8ca                	sd	s2,80(sp)
    3a86:	e4ce                	sd	s3,72(sp)
    3a88:	e0d2                	sd	s4,64(sp)
    3a8a:	fc56                	sd	s5,56(sp)
    3a8c:	f85a                	sd	s6,48(sp)
    3a8e:	f45e                	sd	s7,40(sp)
    3a90:	1880                	addi	s0,sp,112
    3a92:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    3a94:	00004517          	auipc	a0,0x4
    3a98:	e6c50513          	addi	a0,a0,-404 # 7900 <malloc+0x1cc8>
    3a9c:	00002097          	auipc	ra,0x2
    3aa0:	d9e080e7          	jalr	-610(ra) # 583a <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    3aa4:	20200593          	li	a1,514
    3aa8:	00004517          	auipc	a0,0x4
    3aac:	e5850513          	addi	a0,a0,-424 # 7900 <malloc+0x1cc8>
    3ab0:	00002097          	auipc	ra,0x2
    3ab4:	d7a080e7          	jalr	-646(ra) # 582a <open>
  if(fd < 0){
    3ab8:	04054a63          	bltz	a0,3b0c <sharedfd+0x90>
    3abc:	892a                	mv	s2,a0
  pid = fork();
    3abe:	00002097          	auipc	ra,0x2
    3ac2:	d24080e7          	jalr	-732(ra) # 57e2 <fork>
    3ac6:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    3ac8:	06300593          	li	a1,99
    3acc:	c119                	beqz	a0,3ad2 <sharedfd+0x56>
    3ace:	07000593          	li	a1,112
    3ad2:	4629                	li	a2,10
    3ad4:	fa040513          	addi	a0,s0,-96
    3ad8:	00002097          	auipc	ra,0x2
    3adc:	b16080e7          	jalr	-1258(ra) # 55ee <memset>
    3ae0:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    3ae4:	4629                	li	a2,10
    3ae6:	fa040593          	addi	a1,s0,-96
    3aea:	854a                	mv	a0,s2
    3aec:	00002097          	auipc	ra,0x2
    3af0:	d1e080e7          	jalr	-738(ra) # 580a <write>
    3af4:	47a9                	li	a5,10
    3af6:	02f51963          	bne	a0,a5,3b28 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    3afa:	34fd                	addiw	s1,s1,-1
    3afc:	f4e5                	bnez	s1,3ae4 <sharedfd+0x68>
  if(pid == 0) {
    3afe:	04099363          	bnez	s3,3b44 <sharedfd+0xc8>
    exit(0);
    3b02:	4501                	li	a0,0
    3b04:	00002097          	auipc	ra,0x2
    3b08:	ce6080e7          	jalr	-794(ra) # 57ea <exit>
    printf("%s: cannot open sharedfd for writing", s);
    3b0c:	85d2                	mv	a1,s4
    3b0e:	00004517          	auipc	a0,0x4
    3b12:	e0250513          	addi	a0,a0,-510 # 7910 <malloc+0x1cd8>
    3b16:	00002097          	auipc	ra,0x2
    3b1a:	064080e7          	jalr	100(ra) # 5b7a <printf>
    exit(1);
    3b1e:	4505                	li	a0,1
    3b20:	00002097          	auipc	ra,0x2
    3b24:	cca080e7          	jalr	-822(ra) # 57ea <exit>
      printf("%s: write sharedfd failed\n", s);
    3b28:	85d2                	mv	a1,s4
    3b2a:	00004517          	auipc	a0,0x4
    3b2e:	e0e50513          	addi	a0,a0,-498 # 7938 <malloc+0x1d00>
    3b32:	00002097          	auipc	ra,0x2
    3b36:	048080e7          	jalr	72(ra) # 5b7a <printf>
      exit(1);
    3b3a:	4505                	li	a0,1
    3b3c:	00002097          	auipc	ra,0x2
    3b40:	cae080e7          	jalr	-850(ra) # 57ea <exit>
    wait(&xstatus);
    3b44:	f9c40513          	addi	a0,s0,-100
    3b48:	00002097          	auipc	ra,0x2
    3b4c:	caa080e7          	jalr	-854(ra) # 57f2 <wait>
    if(xstatus != 0)
    3b50:	f9c42983          	lw	s3,-100(s0)
    3b54:	00098763          	beqz	s3,3b62 <sharedfd+0xe6>
      exit(xstatus);
    3b58:	854e                	mv	a0,s3
    3b5a:	00002097          	auipc	ra,0x2
    3b5e:	c90080e7          	jalr	-880(ra) # 57ea <exit>
  close(fd);
    3b62:	854a                	mv	a0,s2
    3b64:	00002097          	auipc	ra,0x2
    3b68:	cae080e7          	jalr	-850(ra) # 5812 <close>
  fd = open("sharedfd", 0);
    3b6c:	4581                	li	a1,0
    3b6e:	00004517          	auipc	a0,0x4
    3b72:	d9250513          	addi	a0,a0,-622 # 7900 <malloc+0x1cc8>
    3b76:	00002097          	auipc	ra,0x2
    3b7a:	cb4080e7          	jalr	-844(ra) # 582a <open>
    3b7e:	8baa                	mv	s7,a0
  nc = np = 0;
    3b80:	8ace                	mv	s5,s3
  if(fd < 0){
    3b82:	02054563          	bltz	a0,3bac <sharedfd+0x130>
    3b86:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    3b8a:	06300493          	li	s1,99
      if(buf[i] == 'p')
    3b8e:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    3b92:	4629                	li	a2,10
    3b94:	fa040593          	addi	a1,s0,-96
    3b98:	855e                	mv	a0,s7
    3b9a:	00002097          	auipc	ra,0x2
    3b9e:	c68080e7          	jalr	-920(ra) # 5802 <read>
    3ba2:	02a05f63          	blez	a0,3be0 <sharedfd+0x164>
    3ba6:	fa040793          	addi	a5,s0,-96
    3baa:	a01d                	j	3bd0 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    3bac:	85d2                	mv	a1,s4
    3bae:	00004517          	auipc	a0,0x4
    3bb2:	daa50513          	addi	a0,a0,-598 # 7958 <malloc+0x1d20>
    3bb6:	00002097          	auipc	ra,0x2
    3bba:	fc4080e7          	jalr	-60(ra) # 5b7a <printf>
    exit(1);
    3bbe:	4505                	li	a0,1
    3bc0:	00002097          	auipc	ra,0x2
    3bc4:	c2a080e7          	jalr	-982(ra) # 57ea <exit>
        nc++;
    3bc8:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    3bca:	0785                	addi	a5,a5,1
    3bcc:	fd2783e3          	beq	a5,s2,3b92 <sharedfd+0x116>
      if(buf[i] == 'c')
    3bd0:	0007c703          	lbu	a4,0(a5)
    3bd4:	fe970ae3          	beq	a4,s1,3bc8 <sharedfd+0x14c>
      if(buf[i] == 'p')
    3bd8:	ff6719e3          	bne	a4,s6,3bca <sharedfd+0x14e>
        np++;
    3bdc:	2a85                	addiw	s5,s5,1
    3bde:	b7f5                	j	3bca <sharedfd+0x14e>
  close(fd);
    3be0:	855e                	mv	a0,s7
    3be2:	00002097          	auipc	ra,0x2
    3be6:	c30080e7          	jalr	-976(ra) # 5812 <close>
  unlink("sharedfd");
    3bea:	00004517          	auipc	a0,0x4
    3bee:	d1650513          	addi	a0,a0,-746 # 7900 <malloc+0x1cc8>
    3bf2:	00002097          	auipc	ra,0x2
    3bf6:	c48080e7          	jalr	-952(ra) # 583a <unlink>
  if(nc == N*SZ && np == N*SZ){
    3bfa:	6789                	lui	a5,0x2
    3bfc:	71078793          	addi	a5,a5,1808 # 2710 <subdir+0x418>
    3c00:	00f99763          	bne	s3,a5,3c0e <sharedfd+0x192>
    3c04:	6789                	lui	a5,0x2
    3c06:	71078793          	addi	a5,a5,1808 # 2710 <subdir+0x418>
    3c0a:	02fa8063          	beq	s5,a5,3c2a <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    3c0e:	85d2                	mv	a1,s4
    3c10:	00004517          	auipc	a0,0x4
    3c14:	d7050513          	addi	a0,a0,-656 # 7980 <malloc+0x1d48>
    3c18:	00002097          	auipc	ra,0x2
    3c1c:	f62080e7          	jalr	-158(ra) # 5b7a <printf>
    exit(1);
    3c20:	4505                	li	a0,1
    3c22:	00002097          	auipc	ra,0x2
    3c26:	bc8080e7          	jalr	-1080(ra) # 57ea <exit>
    exit(0);
    3c2a:	4501                	li	a0,0
    3c2c:	00002097          	auipc	ra,0x2
    3c30:	bbe080e7          	jalr	-1090(ra) # 57ea <exit>

0000000000003c34 <createdelete>:
{
    3c34:	7175                	addi	sp,sp,-144
    3c36:	e506                	sd	ra,136(sp)
    3c38:	e122                	sd	s0,128(sp)
    3c3a:	fca6                	sd	s1,120(sp)
    3c3c:	f8ca                	sd	s2,112(sp)
    3c3e:	f4ce                	sd	s3,104(sp)
    3c40:	f0d2                	sd	s4,96(sp)
    3c42:	ecd6                	sd	s5,88(sp)
    3c44:	e8da                	sd	s6,80(sp)
    3c46:	e4de                	sd	s7,72(sp)
    3c48:	e0e2                	sd	s8,64(sp)
    3c4a:	fc66                	sd	s9,56(sp)
    3c4c:	0900                	addi	s0,sp,144
    3c4e:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    3c50:	4901                	li	s2,0
    3c52:	4991                	li	s3,4
    pid = fork();
    3c54:	00002097          	auipc	ra,0x2
    3c58:	b8e080e7          	jalr	-1138(ra) # 57e2 <fork>
    3c5c:	84aa                	mv	s1,a0
    if(pid < 0){
    3c5e:	02054f63          	bltz	a0,3c9c <createdelete+0x68>
    if(pid == 0){
    3c62:	c939                	beqz	a0,3cb8 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    3c64:	2905                	addiw	s2,s2,1
    3c66:	ff3917e3          	bne	s2,s3,3c54 <createdelete+0x20>
    3c6a:	4491                	li	s1,4
    wait(&xstatus);
    3c6c:	f7c40513          	addi	a0,s0,-132
    3c70:	00002097          	auipc	ra,0x2
    3c74:	b82080e7          	jalr	-1150(ra) # 57f2 <wait>
    if(xstatus != 0)
    3c78:	f7c42903          	lw	s2,-132(s0)
    3c7c:	0e091263          	bnez	s2,3d60 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    3c80:	34fd                	addiw	s1,s1,-1
    3c82:	f4ed                	bnez	s1,3c6c <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    3c84:	f8040123          	sb	zero,-126(s0)
    3c88:	03000993          	li	s3,48
    3c8c:	5a7d                	li	s4,-1
    3c8e:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3c92:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    3c94:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    3c96:	07400a93          	li	s5,116
    3c9a:	a29d                	j	3e00 <createdelete+0x1cc>
      printf("fork failed\n", s);
    3c9c:	85e6                	mv	a1,s9
    3c9e:	00003517          	auipc	a0,0x3
    3ca2:	c9a50513          	addi	a0,a0,-870 # 6938 <malloc+0xd00>
    3ca6:	00002097          	auipc	ra,0x2
    3caa:	ed4080e7          	jalr	-300(ra) # 5b7a <printf>
      exit(1);
    3cae:	4505                	li	a0,1
    3cb0:	00002097          	auipc	ra,0x2
    3cb4:	b3a080e7          	jalr	-1222(ra) # 57ea <exit>
      name[0] = 'p' + pi;
    3cb8:	0709091b          	addiw	s2,s2,112
    3cbc:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    3cc0:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    3cc4:	4951                	li	s2,20
    3cc6:	a015                	j	3cea <createdelete+0xb6>
          printf("%s: create failed\n", s);
    3cc8:	85e6                	mv	a1,s9
    3cca:	00003517          	auipc	a0,0x3
    3cce:	ace50513          	addi	a0,a0,-1330 # 6798 <malloc+0xb60>
    3cd2:	00002097          	auipc	ra,0x2
    3cd6:	ea8080e7          	jalr	-344(ra) # 5b7a <printf>
          exit(1);
    3cda:	4505                	li	a0,1
    3cdc:	00002097          	auipc	ra,0x2
    3ce0:	b0e080e7          	jalr	-1266(ra) # 57ea <exit>
      for(i = 0; i < N; i++){
    3ce4:	2485                	addiw	s1,s1,1
    3ce6:	07248863          	beq	s1,s2,3d56 <createdelete+0x122>
        name[1] = '0' + i;
    3cea:	0304879b          	addiw	a5,s1,48
    3cee:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    3cf2:	20200593          	li	a1,514
    3cf6:	f8040513          	addi	a0,s0,-128
    3cfa:	00002097          	auipc	ra,0x2
    3cfe:	b30080e7          	jalr	-1232(ra) # 582a <open>
        if(fd < 0){
    3d02:	fc0543e3          	bltz	a0,3cc8 <createdelete+0x94>
        close(fd);
    3d06:	00002097          	auipc	ra,0x2
    3d0a:	b0c080e7          	jalr	-1268(ra) # 5812 <close>
        if(i > 0 && (i % 2 ) == 0){
    3d0e:	fc905be3          	blez	s1,3ce4 <createdelete+0xb0>
    3d12:	0014f793          	andi	a5,s1,1
    3d16:	f7f9                	bnez	a5,3ce4 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    3d18:	01f4d79b          	srliw	a5,s1,0x1f
    3d1c:	9fa5                	addw	a5,a5,s1
    3d1e:	4017d79b          	sraiw	a5,a5,0x1
    3d22:	0307879b          	addiw	a5,a5,48
    3d26:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    3d2a:	f8040513          	addi	a0,s0,-128
    3d2e:	00002097          	auipc	ra,0x2
    3d32:	b0c080e7          	jalr	-1268(ra) # 583a <unlink>
    3d36:	fa0557e3          	bgez	a0,3ce4 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    3d3a:	85e6                	mv	a1,s9
    3d3c:	00003517          	auipc	a0,0x3
    3d40:	d6450513          	addi	a0,a0,-668 # 6aa0 <malloc+0xe68>
    3d44:	00002097          	auipc	ra,0x2
    3d48:	e36080e7          	jalr	-458(ra) # 5b7a <printf>
            exit(1);
    3d4c:	4505                	li	a0,1
    3d4e:	00002097          	auipc	ra,0x2
    3d52:	a9c080e7          	jalr	-1380(ra) # 57ea <exit>
      exit(0);
    3d56:	4501                	li	a0,0
    3d58:	00002097          	auipc	ra,0x2
    3d5c:	a92080e7          	jalr	-1390(ra) # 57ea <exit>
      exit(1);
    3d60:	4505                	li	a0,1
    3d62:	00002097          	auipc	ra,0x2
    3d66:	a88080e7          	jalr	-1400(ra) # 57ea <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    3d6a:	f8040613          	addi	a2,s0,-128
    3d6e:	85e6                	mv	a1,s9
    3d70:	00004517          	auipc	a0,0x4
    3d74:	c2850513          	addi	a0,a0,-984 # 7998 <malloc+0x1d60>
    3d78:	00002097          	auipc	ra,0x2
    3d7c:	e02080e7          	jalr	-510(ra) # 5b7a <printf>
        exit(1);
    3d80:	4505                	li	a0,1
    3d82:	00002097          	auipc	ra,0x2
    3d86:	a68080e7          	jalr	-1432(ra) # 57ea <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3d8a:	054b7163          	bgeu	s6,s4,3dcc <createdelete+0x198>
      if(fd >= 0)
    3d8e:	02055a63          	bgez	a0,3dc2 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    3d92:	2485                	addiw	s1,s1,1
    3d94:	0ff4f493          	andi	s1,s1,255
    3d98:	05548c63          	beq	s1,s5,3df0 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    3d9c:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    3da0:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    3da4:	4581                	li	a1,0
    3da6:	f8040513          	addi	a0,s0,-128
    3daa:	00002097          	auipc	ra,0x2
    3dae:	a80080e7          	jalr	-1408(ra) # 582a <open>
      if((i == 0 || i >= N/2) && fd < 0){
    3db2:	00090463          	beqz	s2,3dba <createdelete+0x186>
    3db6:	fd2bdae3          	bge	s7,s2,3d8a <createdelete+0x156>
    3dba:	fa0548e3          	bltz	a0,3d6a <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3dbe:	014b7963          	bgeu	s6,s4,3dd0 <createdelete+0x19c>
        close(fd);
    3dc2:	00002097          	auipc	ra,0x2
    3dc6:	a50080e7          	jalr	-1456(ra) # 5812 <close>
    3dca:	b7e1                	j	3d92 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3dcc:	fc0543e3          	bltz	a0,3d92 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    3dd0:	f8040613          	addi	a2,s0,-128
    3dd4:	85e6                	mv	a1,s9
    3dd6:	00004517          	auipc	a0,0x4
    3dda:	bea50513          	addi	a0,a0,-1046 # 79c0 <malloc+0x1d88>
    3dde:	00002097          	auipc	ra,0x2
    3de2:	d9c080e7          	jalr	-612(ra) # 5b7a <printf>
        exit(1);
    3de6:	4505                	li	a0,1
    3de8:	00002097          	auipc	ra,0x2
    3dec:	a02080e7          	jalr	-1534(ra) # 57ea <exit>
  for(i = 0; i < N; i++){
    3df0:	2905                	addiw	s2,s2,1
    3df2:	2a05                	addiw	s4,s4,1
    3df4:	2985                	addiw	s3,s3,1
    3df6:	0ff9f993          	andi	s3,s3,255
    3dfa:	47d1                	li	a5,20
    3dfc:	02f90a63          	beq	s2,a5,3e30 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    3e00:	84e2                	mv	s1,s8
    3e02:	bf69                	j	3d9c <createdelete+0x168>
  for(i = 0; i < N; i++){
    3e04:	2905                	addiw	s2,s2,1
    3e06:	0ff97913          	andi	s2,s2,255
    3e0a:	2985                	addiw	s3,s3,1
    3e0c:	0ff9f993          	andi	s3,s3,255
    3e10:	03490863          	beq	s2,s4,3e40 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    3e14:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    3e16:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    3e1a:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    3e1e:	f8040513          	addi	a0,s0,-128
    3e22:	00002097          	auipc	ra,0x2
    3e26:	a18080e7          	jalr	-1512(ra) # 583a <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    3e2a:	34fd                	addiw	s1,s1,-1
    3e2c:	f4ed                	bnez	s1,3e16 <createdelete+0x1e2>
    3e2e:	bfd9                	j	3e04 <createdelete+0x1d0>
    3e30:	03000993          	li	s3,48
    3e34:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    3e38:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    3e3a:	08400a13          	li	s4,132
    3e3e:	bfd9                	j	3e14 <createdelete+0x1e0>
}
    3e40:	60aa                	ld	ra,136(sp)
    3e42:	640a                	ld	s0,128(sp)
    3e44:	74e6                	ld	s1,120(sp)
    3e46:	7946                	ld	s2,112(sp)
    3e48:	79a6                	ld	s3,104(sp)
    3e4a:	7a06                	ld	s4,96(sp)
    3e4c:	6ae6                	ld	s5,88(sp)
    3e4e:	6b46                	ld	s6,80(sp)
    3e50:	6ba6                	ld	s7,72(sp)
    3e52:	6c06                	ld	s8,64(sp)
    3e54:	7ce2                	ld	s9,56(sp)
    3e56:	6149                	addi	sp,sp,144
    3e58:	8082                	ret

0000000000003e5a <concreate>:
{
    3e5a:	7135                	addi	sp,sp,-160
    3e5c:	ed06                	sd	ra,152(sp)
    3e5e:	e922                	sd	s0,144(sp)
    3e60:	e526                	sd	s1,136(sp)
    3e62:	e14a                	sd	s2,128(sp)
    3e64:	fcce                	sd	s3,120(sp)
    3e66:	f8d2                	sd	s4,112(sp)
    3e68:	f4d6                	sd	s5,104(sp)
    3e6a:	f0da                	sd	s6,96(sp)
    3e6c:	ecde                	sd	s7,88(sp)
    3e6e:	1100                	addi	s0,sp,160
    3e70:	89aa                	mv	s3,a0
  file[0] = 'C';
    3e72:	04300793          	li	a5,67
    3e76:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    3e7a:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    3e7e:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    3e80:	4b0d                	li	s6,3
    3e82:	4a85                	li	s5,1
      link("C0", file);
    3e84:	00004b97          	auipc	s7,0x4
    3e88:	b64b8b93          	addi	s7,s7,-1180 # 79e8 <malloc+0x1db0>
  for(i = 0; i < N; i++){
    3e8c:	02800a13          	li	s4,40
    3e90:	acc1                	j	4160 <concreate+0x306>
      link("C0", file);
    3e92:	fa840593          	addi	a1,s0,-88
    3e96:	855e                	mv	a0,s7
    3e98:	00002097          	auipc	ra,0x2
    3e9c:	9b2080e7          	jalr	-1614(ra) # 584a <link>
    if(pid == 0) {
    3ea0:	a45d                	j	4146 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    3ea2:	4795                	li	a5,5
    3ea4:	02f9693b          	remw	s2,s2,a5
    3ea8:	4785                	li	a5,1
    3eaa:	02f90b63          	beq	s2,a5,3ee0 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    3eae:	20200593          	li	a1,514
    3eb2:	fa840513          	addi	a0,s0,-88
    3eb6:	00002097          	auipc	ra,0x2
    3eba:	974080e7          	jalr	-1676(ra) # 582a <open>
      if(fd < 0){
    3ebe:	26055b63          	bgez	a0,4134 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    3ec2:	fa840593          	addi	a1,s0,-88
    3ec6:	00004517          	auipc	a0,0x4
    3eca:	b2a50513          	addi	a0,a0,-1238 # 79f0 <malloc+0x1db8>
    3ece:	00002097          	auipc	ra,0x2
    3ed2:	cac080e7          	jalr	-852(ra) # 5b7a <printf>
        exit(1);
    3ed6:	4505                	li	a0,1
    3ed8:	00002097          	auipc	ra,0x2
    3edc:	912080e7          	jalr	-1774(ra) # 57ea <exit>
      link("C0", file);
    3ee0:	fa840593          	addi	a1,s0,-88
    3ee4:	00004517          	auipc	a0,0x4
    3ee8:	b0450513          	addi	a0,a0,-1276 # 79e8 <malloc+0x1db0>
    3eec:	00002097          	auipc	ra,0x2
    3ef0:	95e080e7          	jalr	-1698(ra) # 584a <link>
      exit(0);
    3ef4:	4501                	li	a0,0
    3ef6:	00002097          	auipc	ra,0x2
    3efa:	8f4080e7          	jalr	-1804(ra) # 57ea <exit>
        exit(1);
    3efe:	4505                	li	a0,1
    3f00:	00002097          	auipc	ra,0x2
    3f04:	8ea080e7          	jalr	-1814(ra) # 57ea <exit>
  memset(fa, 0, sizeof(fa));
    3f08:	02800613          	li	a2,40
    3f0c:	4581                	li	a1,0
    3f0e:	f8040513          	addi	a0,s0,-128
    3f12:	00001097          	auipc	ra,0x1
    3f16:	6dc080e7          	jalr	1756(ra) # 55ee <memset>
  fd = open(".", 0);
    3f1a:	4581                	li	a1,0
    3f1c:	00002517          	auipc	a0,0x2
    3f20:	73450513          	addi	a0,a0,1844 # 6650 <malloc+0xa18>
    3f24:	00002097          	auipc	ra,0x2
    3f28:	906080e7          	jalr	-1786(ra) # 582a <open>
    3f2c:	892a                	mv	s2,a0
  n = 0;
    3f2e:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3f30:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    3f34:	02700b13          	li	s6,39
      fa[i] = 1;
    3f38:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    3f3a:	4641                	li	a2,16
    3f3c:	f7040593          	addi	a1,s0,-144
    3f40:	854a                	mv	a0,s2
    3f42:	00002097          	auipc	ra,0x2
    3f46:	8c0080e7          	jalr	-1856(ra) # 5802 <read>
    3f4a:	08a05163          	blez	a0,3fcc <concreate+0x172>
    if(de.inum == 0)
    3f4e:	f7045783          	lhu	a5,-144(s0)
    3f52:	d7e5                	beqz	a5,3f3a <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3f54:	f7244783          	lbu	a5,-142(s0)
    3f58:	ff4791e3          	bne	a5,s4,3f3a <concreate+0xe0>
    3f5c:	f7444783          	lbu	a5,-140(s0)
    3f60:	ffe9                	bnez	a5,3f3a <concreate+0xe0>
      i = de.name[1] - '0';
    3f62:	f7344783          	lbu	a5,-141(s0)
    3f66:	fd07879b          	addiw	a5,a5,-48
    3f6a:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    3f6e:	00eb6f63          	bltu	s6,a4,3f8c <concreate+0x132>
      if(fa[i]){
    3f72:	fb040793          	addi	a5,s0,-80
    3f76:	97ba                	add	a5,a5,a4
    3f78:	fd07c783          	lbu	a5,-48(a5)
    3f7c:	eb85                	bnez	a5,3fac <concreate+0x152>
      fa[i] = 1;
    3f7e:	fb040793          	addi	a5,s0,-80
    3f82:	973e                	add	a4,a4,a5
    3f84:	fd770823          	sb	s7,-48(a4)
      n++;
    3f88:	2a85                	addiw	s5,s5,1
    3f8a:	bf45                	j	3f3a <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    3f8c:	f7240613          	addi	a2,s0,-142
    3f90:	85ce                	mv	a1,s3
    3f92:	00004517          	auipc	a0,0x4
    3f96:	a7e50513          	addi	a0,a0,-1410 # 7a10 <malloc+0x1dd8>
    3f9a:	00002097          	auipc	ra,0x2
    3f9e:	be0080e7          	jalr	-1056(ra) # 5b7a <printf>
        exit(1);
    3fa2:	4505                	li	a0,1
    3fa4:	00002097          	auipc	ra,0x2
    3fa8:	846080e7          	jalr	-1978(ra) # 57ea <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    3fac:	f7240613          	addi	a2,s0,-142
    3fb0:	85ce                	mv	a1,s3
    3fb2:	00004517          	auipc	a0,0x4
    3fb6:	a7e50513          	addi	a0,a0,-1410 # 7a30 <malloc+0x1df8>
    3fba:	00002097          	auipc	ra,0x2
    3fbe:	bc0080e7          	jalr	-1088(ra) # 5b7a <printf>
        exit(1);
    3fc2:	4505                	li	a0,1
    3fc4:	00002097          	auipc	ra,0x2
    3fc8:	826080e7          	jalr	-2010(ra) # 57ea <exit>
  close(fd);
    3fcc:	854a                	mv	a0,s2
    3fce:	00002097          	auipc	ra,0x2
    3fd2:	844080e7          	jalr	-1980(ra) # 5812 <close>
  if(n != N){
    3fd6:	02800793          	li	a5,40
    3fda:	00fa9763          	bne	s5,a5,3fe8 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    3fde:	4a8d                	li	s5,3
    3fe0:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    3fe2:	02800a13          	li	s4,40
    3fe6:	a8c9                	j	40b8 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    3fe8:	85ce                	mv	a1,s3
    3fea:	00004517          	auipc	a0,0x4
    3fee:	a6e50513          	addi	a0,a0,-1426 # 7a58 <malloc+0x1e20>
    3ff2:	00002097          	auipc	ra,0x2
    3ff6:	b88080e7          	jalr	-1144(ra) # 5b7a <printf>
    exit(1);
    3ffa:	4505                	li	a0,1
    3ffc:	00001097          	auipc	ra,0x1
    4000:	7ee080e7          	jalr	2030(ra) # 57ea <exit>
      printf("%s: fork failed\n", s);
    4004:	85ce                	mv	a1,s3
    4006:	00002517          	auipc	a0,0x2
    400a:	fa250513          	addi	a0,a0,-94 # 5fa8 <malloc+0x370>
    400e:	00002097          	auipc	ra,0x2
    4012:	b6c080e7          	jalr	-1172(ra) # 5b7a <printf>
      exit(1);
    4016:	4505                	li	a0,1
    4018:	00001097          	auipc	ra,0x1
    401c:	7d2080e7          	jalr	2002(ra) # 57ea <exit>
      close(open(file, 0));
    4020:	4581                	li	a1,0
    4022:	fa840513          	addi	a0,s0,-88
    4026:	00002097          	auipc	ra,0x2
    402a:	804080e7          	jalr	-2044(ra) # 582a <open>
    402e:	00001097          	auipc	ra,0x1
    4032:	7e4080e7          	jalr	2020(ra) # 5812 <close>
      close(open(file, 0));
    4036:	4581                	li	a1,0
    4038:	fa840513          	addi	a0,s0,-88
    403c:	00001097          	auipc	ra,0x1
    4040:	7ee080e7          	jalr	2030(ra) # 582a <open>
    4044:	00001097          	auipc	ra,0x1
    4048:	7ce080e7          	jalr	1998(ra) # 5812 <close>
      close(open(file, 0));
    404c:	4581                	li	a1,0
    404e:	fa840513          	addi	a0,s0,-88
    4052:	00001097          	auipc	ra,0x1
    4056:	7d8080e7          	jalr	2008(ra) # 582a <open>
    405a:	00001097          	auipc	ra,0x1
    405e:	7b8080e7          	jalr	1976(ra) # 5812 <close>
      close(open(file, 0));
    4062:	4581                	li	a1,0
    4064:	fa840513          	addi	a0,s0,-88
    4068:	00001097          	auipc	ra,0x1
    406c:	7c2080e7          	jalr	1986(ra) # 582a <open>
    4070:	00001097          	auipc	ra,0x1
    4074:	7a2080e7          	jalr	1954(ra) # 5812 <close>
      close(open(file, 0));
    4078:	4581                	li	a1,0
    407a:	fa840513          	addi	a0,s0,-88
    407e:	00001097          	auipc	ra,0x1
    4082:	7ac080e7          	jalr	1964(ra) # 582a <open>
    4086:	00001097          	auipc	ra,0x1
    408a:	78c080e7          	jalr	1932(ra) # 5812 <close>
      close(open(file, 0));
    408e:	4581                	li	a1,0
    4090:	fa840513          	addi	a0,s0,-88
    4094:	00001097          	auipc	ra,0x1
    4098:	796080e7          	jalr	1942(ra) # 582a <open>
    409c:	00001097          	auipc	ra,0x1
    40a0:	776080e7          	jalr	1910(ra) # 5812 <close>
    if(pid == 0)
    40a4:	08090363          	beqz	s2,412a <concreate+0x2d0>
      wait(0);
    40a8:	4501                	li	a0,0
    40aa:	00001097          	auipc	ra,0x1
    40ae:	748080e7          	jalr	1864(ra) # 57f2 <wait>
  for(i = 0; i < N; i++){
    40b2:	2485                	addiw	s1,s1,1
    40b4:	0f448563          	beq	s1,s4,419e <concreate+0x344>
    file[1] = '0' + i;
    40b8:	0304879b          	addiw	a5,s1,48
    40bc:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    40c0:	00001097          	auipc	ra,0x1
    40c4:	722080e7          	jalr	1826(ra) # 57e2 <fork>
    40c8:	892a                	mv	s2,a0
    if(pid < 0){
    40ca:	f2054de3          	bltz	a0,4004 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    40ce:	0354e73b          	remw	a4,s1,s5
    40d2:	00a767b3          	or	a5,a4,a0
    40d6:	2781                	sext.w	a5,a5
    40d8:	d7a1                	beqz	a5,4020 <concreate+0x1c6>
    40da:	01671363          	bne	a4,s6,40e0 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    40de:	f129                	bnez	a0,4020 <concreate+0x1c6>
      unlink(file);
    40e0:	fa840513          	addi	a0,s0,-88
    40e4:	00001097          	auipc	ra,0x1
    40e8:	756080e7          	jalr	1878(ra) # 583a <unlink>
      unlink(file);
    40ec:	fa840513          	addi	a0,s0,-88
    40f0:	00001097          	auipc	ra,0x1
    40f4:	74a080e7          	jalr	1866(ra) # 583a <unlink>
      unlink(file);
    40f8:	fa840513          	addi	a0,s0,-88
    40fc:	00001097          	auipc	ra,0x1
    4100:	73e080e7          	jalr	1854(ra) # 583a <unlink>
      unlink(file);
    4104:	fa840513          	addi	a0,s0,-88
    4108:	00001097          	auipc	ra,0x1
    410c:	732080e7          	jalr	1842(ra) # 583a <unlink>
      unlink(file);
    4110:	fa840513          	addi	a0,s0,-88
    4114:	00001097          	auipc	ra,0x1
    4118:	726080e7          	jalr	1830(ra) # 583a <unlink>
      unlink(file);
    411c:	fa840513          	addi	a0,s0,-88
    4120:	00001097          	auipc	ra,0x1
    4124:	71a080e7          	jalr	1818(ra) # 583a <unlink>
    4128:	bfb5                	j	40a4 <concreate+0x24a>
      exit(0);
    412a:	4501                	li	a0,0
    412c:	00001097          	auipc	ra,0x1
    4130:	6be080e7          	jalr	1726(ra) # 57ea <exit>
      close(fd);
    4134:	00001097          	auipc	ra,0x1
    4138:	6de080e7          	jalr	1758(ra) # 5812 <close>
    if(pid == 0) {
    413c:	bb65                	j	3ef4 <concreate+0x9a>
      close(fd);
    413e:	00001097          	auipc	ra,0x1
    4142:	6d4080e7          	jalr	1748(ra) # 5812 <close>
      wait(&xstatus);
    4146:	f6c40513          	addi	a0,s0,-148
    414a:	00001097          	auipc	ra,0x1
    414e:	6a8080e7          	jalr	1704(ra) # 57f2 <wait>
      if(xstatus != 0)
    4152:	f6c42483          	lw	s1,-148(s0)
    4156:	da0494e3          	bnez	s1,3efe <concreate+0xa4>
  for(i = 0; i < N; i++){
    415a:	2905                	addiw	s2,s2,1
    415c:	db4906e3          	beq	s2,s4,3f08 <concreate+0xae>
    file[1] = '0' + i;
    4160:	0309079b          	addiw	a5,s2,48
    4164:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4168:	fa840513          	addi	a0,s0,-88
    416c:	00001097          	auipc	ra,0x1
    4170:	6ce080e7          	jalr	1742(ra) # 583a <unlink>
    pid = fork();
    4174:	00001097          	auipc	ra,0x1
    4178:	66e080e7          	jalr	1646(ra) # 57e2 <fork>
    if(pid && (i % 3) == 1){
    417c:	d20503e3          	beqz	a0,3ea2 <concreate+0x48>
    4180:	036967bb          	remw	a5,s2,s6
    4184:	d15787e3          	beq	a5,s5,3e92 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4188:	20200593          	li	a1,514
    418c:	fa840513          	addi	a0,s0,-88
    4190:	00001097          	auipc	ra,0x1
    4194:	69a080e7          	jalr	1690(ra) # 582a <open>
      if(fd < 0){
    4198:	fa0553e3          	bgez	a0,413e <concreate+0x2e4>
    419c:	b31d                	j	3ec2 <concreate+0x68>
}
    419e:	60ea                	ld	ra,152(sp)
    41a0:	644a                	ld	s0,144(sp)
    41a2:	64aa                	ld	s1,136(sp)
    41a4:	690a                	ld	s2,128(sp)
    41a6:	79e6                	ld	s3,120(sp)
    41a8:	7a46                	ld	s4,112(sp)
    41aa:	7aa6                	ld	s5,104(sp)
    41ac:	7b06                	ld	s6,96(sp)
    41ae:	6be6                	ld	s7,88(sp)
    41b0:	610d                	addi	sp,sp,160
    41b2:	8082                	ret

00000000000041b4 <linkunlink>:
{
    41b4:	711d                	addi	sp,sp,-96
    41b6:	ec86                	sd	ra,88(sp)
    41b8:	e8a2                	sd	s0,80(sp)
    41ba:	e4a6                	sd	s1,72(sp)
    41bc:	e0ca                	sd	s2,64(sp)
    41be:	fc4e                	sd	s3,56(sp)
    41c0:	f852                	sd	s4,48(sp)
    41c2:	f456                	sd	s5,40(sp)
    41c4:	f05a                	sd	s6,32(sp)
    41c6:	ec5e                	sd	s7,24(sp)
    41c8:	e862                	sd	s8,16(sp)
    41ca:	e466                	sd	s9,8(sp)
    41cc:	1080                	addi	s0,sp,96
    41ce:	84aa                	mv	s1,a0
  unlink("x");
    41d0:	00002517          	auipc	a0,0x2
    41d4:	f5850513          	addi	a0,a0,-168 # 6128 <malloc+0x4f0>
    41d8:	00001097          	auipc	ra,0x1
    41dc:	662080e7          	jalr	1634(ra) # 583a <unlink>
  pid = fork();
    41e0:	00001097          	auipc	ra,0x1
    41e4:	602080e7          	jalr	1538(ra) # 57e2 <fork>
  if(pid < 0){
    41e8:	02054b63          	bltz	a0,421e <linkunlink+0x6a>
    41ec:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    41ee:	4c85                	li	s9,1
    41f0:	e119                	bnez	a0,41f6 <linkunlink+0x42>
    41f2:	06100c93          	li	s9,97
    41f6:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    41fa:	41c659b7          	lui	s3,0x41c65
    41fe:	e6d9899b          	addiw	s3,s3,-403
    4202:	690d                	lui	s2,0x3
    4204:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    4208:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    420a:	4b05                	li	s6,1
      unlink("x");
    420c:	00002a97          	auipc	s5,0x2
    4210:	f1ca8a93          	addi	s5,s5,-228 # 6128 <malloc+0x4f0>
      link("cat", "x");
    4214:	00004b97          	auipc	s7,0x4
    4218:	87cb8b93          	addi	s7,s7,-1924 # 7a90 <malloc+0x1e58>
    421c:	a825                	j	4254 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    421e:	85a6                	mv	a1,s1
    4220:	00002517          	auipc	a0,0x2
    4224:	d8850513          	addi	a0,a0,-632 # 5fa8 <malloc+0x370>
    4228:	00002097          	auipc	ra,0x2
    422c:	952080e7          	jalr	-1710(ra) # 5b7a <printf>
    exit(1);
    4230:	4505                	li	a0,1
    4232:	00001097          	auipc	ra,0x1
    4236:	5b8080e7          	jalr	1464(ra) # 57ea <exit>
      close(open("x", O_RDWR | O_CREATE));
    423a:	20200593          	li	a1,514
    423e:	8556                	mv	a0,s5
    4240:	00001097          	auipc	ra,0x1
    4244:	5ea080e7          	jalr	1514(ra) # 582a <open>
    4248:	00001097          	auipc	ra,0x1
    424c:	5ca080e7          	jalr	1482(ra) # 5812 <close>
  for(i = 0; i < 100; i++){
    4250:	34fd                	addiw	s1,s1,-1
    4252:	c88d                	beqz	s1,4284 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    4254:	033c87bb          	mulw	a5,s9,s3
    4258:	012787bb          	addw	a5,a5,s2
    425c:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    4260:	0347f7bb          	remuw	a5,a5,s4
    4264:	dbf9                	beqz	a5,423a <linkunlink+0x86>
    } else if((x % 3) == 1){
    4266:	01678863          	beq	a5,s6,4276 <linkunlink+0xc2>
      unlink("x");
    426a:	8556                	mv	a0,s5
    426c:	00001097          	auipc	ra,0x1
    4270:	5ce080e7          	jalr	1486(ra) # 583a <unlink>
    4274:	bff1                	j	4250 <linkunlink+0x9c>
      link("cat", "x");
    4276:	85d6                	mv	a1,s5
    4278:	855e                	mv	a0,s7
    427a:	00001097          	auipc	ra,0x1
    427e:	5d0080e7          	jalr	1488(ra) # 584a <link>
    4282:	b7f9                	j	4250 <linkunlink+0x9c>
  if(pid)
    4284:	020c0463          	beqz	s8,42ac <linkunlink+0xf8>
    wait(0);
    4288:	4501                	li	a0,0
    428a:	00001097          	auipc	ra,0x1
    428e:	568080e7          	jalr	1384(ra) # 57f2 <wait>
}
    4292:	60e6                	ld	ra,88(sp)
    4294:	6446                	ld	s0,80(sp)
    4296:	64a6                	ld	s1,72(sp)
    4298:	6906                	ld	s2,64(sp)
    429a:	79e2                	ld	s3,56(sp)
    429c:	7a42                	ld	s4,48(sp)
    429e:	7aa2                	ld	s5,40(sp)
    42a0:	7b02                	ld	s6,32(sp)
    42a2:	6be2                	ld	s7,24(sp)
    42a4:	6c42                	ld	s8,16(sp)
    42a6:	6ca2                	ld	s9,8(sp)
    42a8:	6125                	addi	sp,sp,96
    42aa:	8082                	ret
    exit(0);
    42ac:	4501                	li	a0,0
    42ae:	00001097          	auipc	ra,0x1
    42b2:	53c080e7          	jalr	1340(ra) # 57ea <exit>

00000000000042b6 <bigdir>:
{
    42b6:	715d                	addi	sp,sp,-80
    42b8:	e486                	sd	ra,72(sp)
    42ba:	e0a2                	sd	s0,64(sp)
    42bc:	fc26                	sd	s1,56(sp)
    42be:	f84a                	sd	s2,48(sp)
    42c0:	f44e                	sd	s3,40(sp)
    42c2:	f052                	sd	s4,32(sp)
    42c4:	ec56                	sd	s5,24(sp)
    42c6:	e85a                	sd	s6,16(sp)
    42c8:	0880                	addi	s0,sp,80
    42ca:	89aa                	mv	s3,a0
  unlink("bd");
    42cc:	00003517          	auipc	a0,0x3
    42d0:	7cc50513          	addi	a0,a0,1996 # 7a98 <malloc+0x1e60>
    42d4:	00001097          	auipc	ra,0x1
    42d8:	566080e7          	jalr	1382(ra) # 583a <unlink>
  fd = open("bd", O_CREATE);
    42dc:	20000593          	li	a1,512
    42e0:	00003517          	auipc	a0,0x3
    42e4:	7b850513          	addi	a0,a0,1976 # 7a98 <malloc+0x1e60>
    42e8:	00001097          	auipc	ra,0x1
    42ec:	542080e7          	jalr	1346(ra) # 582a <open>
  if(fd < 0){
    42f0:	0c054963          	bltz	a0,43c2 <bigdir+0x10c>
  close(fd);
    42f4:	00001097          	auipc	ra,0x1
    42f8:	51e080e7          	jalr	1310(ra) # 5812 <close>
  for(i = 0; i < N; i++){
    42fc:	4901                	li	s2,0
    name[0] = 'x';
    42fe:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    4302:	00003a17          	auipc	s4,0x3
    4306:	796a0a13          	addi	s4,s4,1942 # 7a98 <malloc+0x1e60>
  for(i = 0; i < N; i++){
    430a:	1f400b13          	li	s6,500
    name[0] = 'x';
    430e:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    4312:	41f9579b          	sraiw	a5,s2,0x1f
    4316:	01a7d71b          	srliw	a4,a5,0x1a
    431a:	012707bb          	addw	a5,a4,s2
    431e:	4067d69b          	sraiw	a3,a5,0x6
    4322:	0306869b          	addiw	a3,a3,48
    4326:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    432a:	03f7f793          	andi	a5,a5,63
    432e:	9f99                	subw	a5,a5,a4
    4330:	0307879b          	addiw	a5,a5,48
    4334:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    4338:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    433c:	fb040593          	addi	a1,s0,-80
    4340:	8552                	mv	a0,s4
    4342:	00001097          	auipc	ra,0x1
    4346:	508080e7          	jalr	1288(ra) # 584a <link>
    434a:	84aa                	mv	s1,a0
    434c:	e949                	bnez	a0,43de <bigdir+0x128>
  for(i = 0; i < N; i++){
    434e:	2905                	addiw	s2,s2,1
    4350:	fb691fe3          	bne	s2,s6,430e <bigdir+0x58>
  unlink("bd");
    4354:	00003517          	auipc	a0,0x3
    4358:	74450513          	addi	a0,a0,1860 # 7a98 <malloc+0x1e60>
    435c:	00001097          	auipc	ra,0x1
    4360:	4de080e7          	jalr	1246(ra) # 583a <unlink>
    name[0] = 'x';
    4364:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    4368:	1f400a13          	li	s4,500
    name[0] = 'x';
    436c:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    4370:	41f4d79b          	sraiw	a5,s1,0x1f
    4374:	01a7d71b          	srliw	a4,a5,0x1a
    4378:	009707bb          	addw	a5,a4,s1
    437c:	4067d69b          	sraiw	a3,a5,0x6
    4380:	0306869b          	addiw	a3,a3,48
    4384:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    4388:	03f7f793          	andi	a5,a5,63
    438c:	9f99                	subw	a5,a5,a4
    438e:	0307879b          	addiw	a5,a5,48
    4392:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    4396:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    439a:	fb040513          	addi	a0,s0,-80
    439e:	00001097          	auipc	ra,0x1
    43a2:	49c080e7          	jalr	1180(ra) # 583a <unlink>
    43a6:	ed21                	bnez	a0,43fe <bigdir+0x148>
  for(i = 0; i < N; i++){
    43a8:	2485                	addiw	s1,s1,1
    43aa:	fd4491e3          	bne	s1,s4,436c <bigdir+0xb6>
}
    43ae:	60a6                	ld	ra,72(sp)
    43b0:	6406                	ld	s0,64(sp)
    43b2:	74e2                	ld	s1,56(sp)
    43b4:	7942                	ld	s2,48(sp)
    43b6:	79a2                	ld	s3,40(sp)
    43b8:	7a02                	ld	s4,32(sp)
    43ba:	6ae2                	ld	s5,24(sp)
    43bc:	6b42                	ld	s6,16(sp)
    43be:	6161                	addi	sp,sp,80
    43c0:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    43c2:	85ce                	mv	a1,s3
    43c4:	00003517          	auipc	a0,0x3
    43c8:	6dc50513          	addi	a0,a0,1756 # 7aa0 <malloc+0x1e68>
    43cc:	00001097          	auipc	ra,0x1
    43d0:	7ae080e7          	jalr	1966(ra) # 5b7a <printf>
    exit(1);
    43d4:	4505                	li	a0,1
    43d6:	00001097          	auipc	ra,0x1
    43da:	414080e7          	jalr	1044(ra) # 57ea <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    43de:	fb040613          	addi	a2,s0,-80
    43e2:	85ce                	mv	a1,s3
    43e4:	00003517          	auipc	a0,0x3
    43e8:	6dc50513          	addi	a0,a0,1756 # 7ac0 <malloc+0x1e88>
    43ec:	00001097          	auipc	ra,0x1
    43f0:	78e080e7          	jalr	1934(ra) # 5b7a <printf>
      exit(1);
    43f4:	4505                	li	a0,1
    43f6:	00001097          	auipc	ra,0x1
    43fa:	3f4080e7          	jalr	1012(ra) # 57ea <exit>
      printf("%s: bigdir unlink failed", s);
    43fe:	85ce                	mv	a1,s3
    4400:	00003517          	auipc	a0,0x3
    4404:	6e050513          	addi	a0,a0,1760 # 7ae0 <malloc+0x1ea8>
    4408:	00001097          	auipc	ra,0x1
    440c:	772080e7          	jalr	1906(ra) # 5b7a <printf>
      exit(1);
    4410:	4505                	li	a0,1
    4412:	00001097          	auipc	ra,0x1
    4416:	3d8080e7          	jalr	984(ra) # 57ea <exit>

000000000000441a <manywrites>:
{
    441a:	711d                	addi	sp,sp,-96
    441c:	ec86                	sd	ra,88(sp)
    441e:	e8a2                	sd	s0,80(sp)
    4420:	e4a6                	sd	s1,72(sp)
    4422:	e0ca                	sd	s2,64(sp)
    4424:	fc4e                	sd	s3,56(sp)
    4426:	f852                	sd	s4,48(sp)
    4428:	f456                	sd	s5,40(sp)
    442a:	f05a                	sd	s6,32(sp)
    442c:	ec5e                	sd	s7,24(sp)
    442e:	1080                	addi	s0,sp,96
    4430:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    4432:	4981                	li	s3,0
    4434:	4911                	li	s2,4
    int pid = fork();
    4436:	00001097          	auipc	ra,0x1
    443a:	3ac080e7          	jalr	940(ra) # 57e2 <fork>
    443e:	84aa                	mv	s1,a0
    if(pid < 0){
    4440:	02054963          	bltz	a0,4472 <manywrites+0x58>
    if(pid == 0){
    4444:	c521                	beqz	a0,448c <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    4446:	2985                	addiw	s3,s3,1
    4448:	ff2997e3          	bne	s3,s2,4436 <manywrites+0x1c>
    444c:	4491                	li	s1,4
    int st = 0;
    444e:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    4452:	fa840513          	addi	a0,s0,-88
    4456:	00001097          	auipc	ra,0x1
    445a:	39c080e7          	jalr	924(ra) # 57f2 <wait>
    if(st != 0)
    445e:	fa842503          	lw	a0,-88(s0)
    4462:	ed6d                	bnez	a0,455c <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    4464:	34fd                	addiw	s1,s1,-1
    4466:	f4e5                	bnez	s1,444e <manywrites+0x34>
  exit(0);
    4468:	4501                	li	a0,0
    446a:	00001097          	auipc	ra,0x1
    446e:	380080e7          	jalr	896(ra) # 57ea <exit>
      printf("fork failed\n");
    4472:	00002517          	auipc	a0,0x2
    4476:	4c650513          	addi	a0,a0,1222 # 6938 <malloc+0xd00>
    447a:	00001097          	auipc	ra,0x1
    447e:	700080e7          	jalr	1792(ra) # 5b7a <printf>
      exit(1);
    4482:	4505                	li	a0,1
    4484:	00001097          	auipc	ra,0x1
    4488:	366080e7          	jalr	870(ra) # 57ea <exit>
      name[0] = 'b';
    448c:	06200793          	li	a5,98
    4490:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    4494:	0619879b          	addiw	a5,s3,97
    4498:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    449c:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    44a0:	fa840513          	addi	a0,s0,-88
    44a4:	00001097          	auipc	ra,0x1
    44a8:	396080e7          	jalr	918(ra) # 583a <unlink>
    44ac:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    44ae:	00007b17          	auipc	s6,0x7
    44b2:	63ab0b13          	addi	s6,s6,1594 # bae8 <buf>
        for(int i = 0; i < ci+1; i++){
    44b6:	8a26                	mv	s4,s1
    44b8:	0209ce63          	bltz	s3,44f4 <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    44bc:	20200593          	li	a1,514
    44c0:	fa840513          	addi	a0,s0,-88
    44c4:	00001097          	auipc	ra,0x1
    44c8:	366080e7          	jalr	870(ra) # 582a <open>
    44cc:	892a                	mv	s2,a0
          if(fd < 0){
    44ce:	04054763          	bltz	a0,451c <manywrites+0x102>
          int cc = write(fd, buf, sz);
    44d2:	660d                	lui	a2,0x3
    44d4:	85da                	mv	a1,s6
    44d6:	00001097          	auipc	ra,0x1
    44da:	334080e7          	jalr	820(ra) # 580a <write>
          if(cc != sz){
    44de:	678d                	lui	a5,0x3
    44e0:	04f51e63          	bne	a0,a5,453c <manywrites+0x122>
          close(fd);
    44e4:	854a                	mv	a0,s2
    44e6:	00001097          	auipc	ra,0x1
    44ea:	32c080e7          	jalr	812(ra) # 5812 <close>
        for(int i = 0; i < ci+1; i++){
    44ee:	2a05                	addiw	s4,s4,1
    44f0:	fd49d6e3          	bge	s3,s4,44bc <manywrites+0xa2>
        unlink(name);
    44f4:	fa840513          	addi	a0,s0,-88
    44f8:	00001097          	auipc	ra,0x1
    44fc:	342080e7          	jalr	834(ra) # 583a <unlink>
      for(int iters = 0; iters < howmany; iters++){
    4500:	3bfd                	addiw	s7,s7,-1
    4502:	fa0b9ae3          	bnez	s7,44b6 <manywrites+0x9c>
      unlink(name);
    4506:	fa840513          	addi	a0,s0,-88
    450a:	00001097          	auipc	ra,0x1
    450e:	330080e7          	jalr	816(ra) # 583a <unlink>
      exit(0);
    4512:	4501                	li	a0,0
    4514:	00001097          	auipc	ra,0x1
    4518:	2d6080e7          	jalr	726(ra) # 57ea <exit>
            printf("%s: cannot create %s\n", s, name);
    451c:	fa840613          	addi	a2,s0,-88
    4520:	85d6                	mv	a1,s5
    4522:	00003517          	auipc	a0,0x3
    4526:	5de50513          	addi	a0,a0,1502 # 7b00 <malloc+0x1ec8>
    452a:	00001097          	auipc	ra,0x1
    452e:	650080e7          	jalr	1616(ra) # 5b7a <printf>
            exit(1);
    4532:	4505                	li	a0,1
    4534:	00001097          	auipc	ra,0x1
    4538:	2b6080e7          	jalr	694(ra) # 57ea <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    453c:	86aa                	mv	a3,a0
    453e:	660d                	lui	a2,0x3
    4540:	85d6                	mv	a1,s5
    4542:	00002517          	auipc	a0,0x2
    4546:	c4650513          	addi	a0,a0,-954 # 6188 <malloc+0x550>
    454a:	00001097          	auipc	ra,0x1
    454e:	630080e7          	jalr	1584(ra) # 5b7a <printf>
            exit(1);
    4552:	4505                	li	a0,1
    4554:	00001097          	auipc	ra,0x1
    4558:	296080e7          	jalr	662(ra) # 57ea <exit>
      exit(st);
    455c:	00001097          	auipc	ra,0x1
    4560:	28e080e7          	jalr	654(ra) # 57ea <exit>

0000000000004564 <iref>:
{
    4564:	7139                	addi	sp,sp,-64
    4566:	fc06                	sd	ra,56(sp)
    4568:	f822                	sd	s0,48(sp)
    456a:	f426                	sd	s1,40(sp)
    456c:	f04a                	sd	s2,32(sp)
    456e:	ec4e                	sd	s3,24(sp)
    4570:	e852                	sd	s4,16(sp)
    4572:	e456                	sd	s5,8(sp)
    4574:	e05a                	sd	s6,0(sp)
    4576:	0080                	addi	s0,sp,64
    4578:	8b2a                	mv	s6,a0
    457a:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    457e:	00003a17          	auipc	s4,0x3
    4582:	59aa0a13          	addi	s4,s4,1434 # 7b18 <malloc+0x1ee0>
    mkdir("");
    4586:	00003497          	auipc	s1,0x3
    458a:	af248493          	addi	s1,s1,-1294 # 7078 <malloc+0x1440>
    link("README", "");
    458e:	00002a97          	auipc	s5,0x2
    4592:	cd2a8a93          	addi	s5,s5,-814 # 6260 <malloc+0x628>
    fd = open("xx", O_CREATE);
    4596:	00003997          	auipc	s3,0x3
    459a:	eca98993          	addi	s3,s3,-310 # 7460 <malloc+0x1828>
    459e:	a891                	j	45f2 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    45a0:	85da                	mv	a1,s6
    45a2:	00003517          	auipc	a0,0x3
    45a6:	57e50513          	addi	a0,a0,1406 # 7b20 <malloc+0x1ee8>
    45aa:	00001097          	auipc	ra,0x1
    45ae:	5d0080e7          	jalr	1488(ra) # 5b7a <printf>
      exit(1);
    45b2:	4505                	li	a0,1
    45b4:	00001097          	auipc	ra,0x1
    45b8:	236080e7          	jalr	566(ra) # 57ea <exit>
      printf("%s: chdir irefd failed\n", s);
    45bc:	85da                	mv	a1,s6
    45be:	00003517          	auipc	a0,0x3
    45c2:	57a50513          	addi	a0,a0,1402 # 7b38 <malloc+0x1f00>
    45c6:	00001097          	auipc	ra,0x1
    45ca:	5b4080e7          	jalr	1460(ra) # 5b7a <printf>
      exit(1);
    45ce:	4505                	li	a0,1
    45d0:	00001097          	auipc	ra,0x1
    45d4:	21a080e7          	jalr	538(ra) # 57ea <exit>
      close(fd);
    45d8:	00001097          	auipc	ra,0x1
    45dc:	23a080e7          	jalr	570(ra) # 5812 <close>
    45e0:	a889                	j	4632 <iref+0xce>
    unlink("xx");
    45e2:	854e                	mv	a0,s3
    45e4:	00001097          	auipc	ra,0x1
    45e8:	256080e7          	jalr	598(ra) # 583a <unlink>
  for(i = 0; i < NINODE + 1; i++){
    45ec:	397d                	addiw	s2,s2,-1
    45ee:	06090063          	beqz	s2,464e <iref+0xea>
    if(mkdir("irefd") != 0){
    45f2:	8552                	mv	a0,s4
    45f4:	00001097          	auipc	ra,0x1
    45f8:	25e080e7          	jalr	606(ra) # 5852 <mkdir>
    45fc:	f155                	bnez	a0,45a0 <iref+0x3c>
    if(chdir("irefd") != 0){
    45fe:	8552                	mv	a0,s4
    4600:	00001097          	auipc	ra,0x1
    4604:	25a080e7          	jalr	602(ra) # 585a <chdir>
    4608:	f955                	bnez	a0,45bc <iref+0x58>
    mkdir("");
    460a:	8526                	mv	a0,s1
    460c:	00001097          	auipc	ra,0x1
    4610:	246080e7          	jalr	582(ra) # 5852 <mkdir>
    link("README", "");
    4614:	85a6                	mv	a1,s1
    4616:	8556                	mv	a0,s5
    4618:	00001097          	auipc	ra,0x1
    461c:	232080e7          	jalr	562(ra) # 584a <link>
    fd = open("", O_CREATE);
    4620:	20000593          	li	a1,512
    4624:	8526                	mv	a0,s1
    4626:	00001097          	auipc	ra,0x1
    462a:	204080e7          	jalr	516(ra) # 582a <open>
    if(fd >= 0)
    462e:	fa0555e3          	bgez	a0,45d8 <iref+0x74>
    fd = open("xx", O_CREATE);
    4632:	20000593          	li	a1,512
    4636:	854e                	mv	a0,s3
    4638:	00001097          	auipc	ra,0x1
    463c:	1f2080e7          	jalr	498(ra) # 582a <open>
    if(fd >= 0)
    4640:	fa0541e3          	bltz	a0,45e2 <iref+0x7e>
      close(fd);
    4644:	00001097          	auipc	ra,0x1
    4648:	1ce080e7          	jalr	462(ra) # 5812 <close>
    464c:	bf59                	j	45e2 <iref+0x7e>
    464e:	03300493          	li	s1,51
    chdir("..");
    4652:	00002997          	auipc	s3,0x2
    4656:	74698993          	addi	s3,s3,1862 # 6d98 <malloc+0x1160>
    unlink("irefd");
    465a:	00003917          	auipc	s2,0x3
    465e:	4be90913          	addi	s2,s2,1214 # 7b18 <malloc+0x1ee0>
    chdir("..");
    4662:	854e                	mv	a0,s3
    4664:	00001097          	auipc	ra,0x1
    4668:	1f6080e7          	jalr	502(ra) # 585a <chdir>
    unlink("irefd");
    466c:	854a                	mv	a0,s2
    466e:	00001097          	auipc	ra,0x1
    4672:	1cc080e7          	jalr	460(ra) # 583a <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4676:	34fd                	addiw	s1,s1,-1
    4678:	f4ed                	bnez	s1,4662 <iref+0xfe>
  chdir("/");
    467a:	00002517          	auipc	a0,0x2
    467e:	6c650513          	addi	a0,a0,1734 # 6d40 <malloc+0x1108>
    4682:	00001097          	auipc	ra,0x1
    4686:	1d8080e7          	jalr	472(ra) # 585a <chdir>
}
    468a:	70e2                	ld	ra,56(sp)
    468c:	7442                	ld	s0,48(sp)
    468e:	74a2                	ld	s1,40(sp)
    4690:	7902                	ld	s2,32(sp)
    4692:	69e2                	ld	s3,24(sp)
    4694:	6a42                	ld	s4,16(sp)
    4696:	6aa2                	ld	s5,8(sp)
    4698:	6b02                	ld	s6,0(sp)
    469a:	6121                	addi	sp,sp,64
    469c:	8082                	ret

000000000000469e <sbrkbasic>:
{
    469e:	7139                	addi	sp,sp,-64
    46a0:	fc06                	sd	ra,56(sp)
    46a2:	f822                	sd	s0,48(sp)
    46a4:	f426                	sd	s1,40(sp)
    46a6:	f04a                	sd	s2,32(sp)
    46a8:	ec4e                	sd	s3,24(sp)
    46aa:	e852                	sd	s4,16(sp)
    46ac:	0080                	addi	s0,sp,64
    46ae:	8a2a                	mv	s4,a0
  pid = fork();
    46b0:	00001097          	auipc	ra,0x1
    46b4:	132080e7          	jalr	306(ra) # 57e2 <fork>
  if(pid < 0){
    46b8:	02054c63          	bltz	a0,46f0 <sbrkbasic+0x52>
  if(pid == 0){
    46bc:	ed21                	bnez	a0,4714 <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    46be:	40000537          	lui	a0,0x40000
    46c2:	00001097          	auipc	ra,0x1
    46c6:	1b0080e7          	jalr	432(ra) # 5872 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    46ca:	57fd                	li	a5,-1
    46cc:	02f50f63          	beq	a0,a5,470a <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    46d0:	400007b7          	lui	a5,0x40000
    46d4:	97aa                	add	a5,a5,a0
      *b = 99;
    46d6:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    46da:	6705                	lui	a4,0x1
      *b = 99;
    46dc:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff1508>
    for(b = a; b < a+TOOMUCH; b += 4096){
    46e0:	953a                	add	a0,a0,a4
    46e2:	fef51de3          	bne	a0,a5,46dc <sbrkbasic+0x3e>
    exit(1);
    46e6:	4505                	li	a0,1
    46e8:	00001097          	auipc	ra,0x1
    46ec:	102080e7          	jalr	258(ra) # 57ea <exit>
    printf("fork failed in sbrkbasic\n");
    46f0:	00003517          	auipc	a0,0x3
    46f4:	46050513          	addi	a0,a0,1120 # 7b50 <malloc+0x1f18>
    46f8:	00001097          	auipc	ra,0x1
    46fc:	482080e7          	jalr	1154(ra) # 5b7a <printf>
    exit(1);
    4700:	4505                	li	a0,1
    4702:	00001097          	auipc	ra,0x1
    4706:	0e8080e7          	jalr	232(ra) # 57ea <exit>
      exit(0);
    470a:	4501                	li	a0,0
    470c:	00001097          	auipc	ra,0x1
    4710:	0de080e7          	jalr	222(ra) # 57ea <exit>
  wait(&xstatus);
    4714:	fcc40513          	addi	a0,s0,-52
    4718:	00001097          	auipc	ra,0x1
    471c:	0da080e7          	jalr	218(ra) # 57f2 <wait>
  if(xstatus == 1){
    4720:	fcc42703          	lw	a4,-52(s0)
    4724:	4785                	li	a5,1
    4726:	00f70d63          	beq	a4,a5,4740 <sbrkbasic+0xa2>
  a = sbrk(0);
    472a:	4501                	li	a0,0
    472c:	00001097          	auipc	ra,0x1
    4730:	146080e7          	jalr	326(ra) # 5872 <sbrk>
    4734:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    4736:	4901                	li	s2,0
    4738:	6985                	lui	s3,0x1
    473a:	38898993          	addi	s3,s3,904 # 1388 <linktest+0x1ba>
    473e:	a005                	j	475e <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    4740:	85d2                	mv	a1,s4
    4742:	00003517          	auipc	a0,0x3
    4746:	42e50513          	addi	a0,a0,1070 # 7b70 <malloc+0x1f38>
    474a:	00001097          	auipc	ra,0x1
    474e:	430080e7          	jalr	1072(ra) # 5b7a <printf>
    exit(1);
    4752:	4505                	li	a0,1
    4754:	00001097          	auipc	ra,0x1
    4758:	096080e7          	jalr	150(ra) # 57ea <exit>
    a = b + 1;
    475c:	84be                	mv	s1,a5
    b = sbrk(1);
    475e:	4505                	li	a0,1
    4760:	00001097          	auipc	ra,0x1
    4764:	112080e7          	jalr	274(ra) # 5872 <sbrk>
    if(b != a){
    4768:	04951c63          	bne	a0,s1,47c0 <sbrkbasic+0x122>
    *b = 1;
    476c:	4785                	li	a5,1
    476e:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    4772:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    4776:	2905                	addiw	s2,s2,1
    4778:	ff3912e3          	bne	s2,s3,475c <sbrkbasic+0xbe>
  pid = fork();
    477c:	00001097          	auipc	ra,0x1
    4780:	066080e7          	jalr	102(ra) # 57e2 <fork>
    4784:	892a                	mv	s2,a0
  if(pid < 0){
    4786:	04054d63          	bltz	a0,47e0 <sbrkbasic+0x142>
  c = sbrk(1);
    478a:	4505                	li	a0,1
    478c:	00001097          	auipc	ra,0x1
    4790:	0e6080e7          	jalr	230(ra) # 5872 <sbrk>
  c = sbrk(1);
    4794:	4505                	li	a0,1
    4796:	00001097          	auipc	ra,0x1
    479a:	0dc080e7          	jalr	220(ra) # 5872 <sbrk>
  if(c != a + 1){
    479e:	0489                	addi	s1,s1,2
    47a0:	04a48e63          	beq	s1,a0,47fc <sbrkbasic+0x15e>
    printf("%s: sbrk test failed post-fork\n", s);
    47a4:	85d2                	mv	a1,s4
    47a6:	00003517          	auipc	a0,0x3
    47aa:	42a50513          	addi	a0,a0,1066 # 7bd0 <malloc+0x1f98>
    47ae:	00001097          	auipc	ra,0x1
    47b2:	3cc080e7          	jalr	972(ra) # 5b7a <printf>
    exit(1);
    47b6:	4505                	li	a0,1
    47b8:	00001097          	auipc	ra,0x1
    47bc:	032080e7          	jalr	50(ra) # 57ea <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    47c0:	86aa                	mv	a3,a0
    47c2:	8626                	mv	a2,s1
    47c4:	85ca                	mv	a1,s2
    47c6:	00003517          	auipc	a0,0x3
    47ca:	3ca50513          	addi	a0,a0,970 # 7b90 <malloc+0x1f58>
    47ce:	00001097          	auipc	ra,0x1
    47d2:	3ac080e7          	jalr	940(ra) # 5b7a <printf>
      exit(1);
    47d6:	4505                	li	a0,1
    47d8:	00001097          	auipc	ra,0x1
    47dc:	012080e7          	jalr	18(ra) # 57ea <exit>
    printf("%s: sbrk test fork failed\n", s);
    47e0:	85d2                	mv	a1,s4
    47e2:	00003517          	auipc	a0,0x3
    47e6:	3ce50513          	addi	a0,a0,974 # 7bb0 <malloc+0x1f78>
    47ea:	00001097          	auipc	ra,0x1
    47ee:	390080e7          	jalr	912(ra) # 5b7a <printf>
    exit(1);
    47f2:	4505                	li	a0,1
    47f4:	00001097          	auipc	ra,0x1
    47f8:	ff6080e7          	jalr	-10(ra) # 57ea <exit>
  if(pid == 0)
    47fc:	00091763          	bnez	s2,480a <sbrkbasic+0x16c>
    exit(0);
    4800:	4501                	li	a0,0
    4802:	00001097          	auipc	ra,0x1
    4806:	fe8080e7          	jalr	-24(ra) # 57ea <exit>
  wait(&xstatus);
    480a:	fcc40513          	addi	a0,s0,-52
    480e:	00001097          	auipc	ra,0x1
    4812:	fe4080e7          	jalr	-28(ra) # 57f2 <wait>
  exit(xstatus);
    4816:	fcc42503          	lw	a0,-52(s0)
    481a:	00001097          	auipc	ra,0x1
    481e:	fd0080e7          	jalr	-48(ra) # 57ea <exit>

0000000000004822 <sbrkmuch>:
{
    4822:	7179                	addi	sp,sp,-48
    4824:	f406                	sd	ra,40(sp)
    4826:	f022                	sd	s0,32(sp)
    4828:	ec26                	sd	s1,24(sp)
    482a:	e84a                	sd	s2,16(sp)
    482c:	e44e                	sd	s3,8(sp)
    482e:	e052                	sd	s4,0(sp)
    4830:	1800                	addi	s0,sp,48
    4832:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    4834:	4501                	li	a0,0
    4836:	00001097          	auipc	ra,0x1
    483a:	03c080e7          	jalr	60(ra) # 5872 <sbrk>
    483e:	892a                	mv	s2,a0
  a = sbrk(0);
    4840:	4501                	li	a0,0
    4842:	00001097          	auipc	ra,0x1
    4846:	030080e7          	jalr	48(ra) # 5872 <sbrk>
    484a:	84aa                	mv	s1,a0
  p = sbrk(amt);
    484c:	06400537          	lui	a0,0x6400
    4850:	9d05                	subw	a0,a0,s1
    4852:	00001097          	auipc	ra,0x1
    4856:	020080e7          	jalr	32(ra) # 5872 <sbrk>
  if (p != a) {
    485a:	0ca49863          	bne	s1,a0,492a <sbrkmuch+0x108>
  char *eee = sbrk(0);
    485e:	4501                	li	a0,0
    4860:	00001097          	auipc	ra,0x1
    4864:	012080e7          	jalr	18(ra) # 5872 <sbrk>
    4868:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    486a:	00a4f963          	bgeu	s1,a0,487c <sbrkmuch+0x5a>
    *pp = 1;
    486e:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    4870:	6705                	lui	a4,0x1
    *pp = 1;
    4872:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    4876:	94ba                	add	s1,s1,a4
    4878:	fef4ede3          	bltu	s1,a5,4872 <sbrkmuch+0x50>
  *lastaddr = 99;
    487c:	064007b7          	lui	a5,0x6400
    4880:	06300713          	li	a4,99
    4884:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f1507>
  a = sbrk(0);
    4888:	4501                	li	a0,0
    488a:	00001097          	auipc	ra,0x1
    488e:	fe8080e7          	jalr	-24(ra) # 5872 <sbrk>
    4892:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    4894:	757d                	lui	a0,0xfffff
    4896:	00001097          	auipc	ra,0x1
    489a:	fdc080e7          	jalr	-36(ra) # 5872 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    489e:	57fd                	li	a5,-1
    48a0:	0af50363          	beq	a0,a5,4946 <sbrkmuch+0x124>
  c = sbrk(0);
    48a4:	4501                	li	a0,0
    48a6:	00001097          	auipc	ra,0x1
    48aa:	fcc080e7          	jalr	-52(ra) # 5872 <sbrk>
  if(c != a - PGSIZE){
    48ae:	77fd                	lui	a5,0xfffff
    48b0:	97a6                	add	a5,a5,s1
    48b2:	0af51863          	bne	a0,a5,4962 <sbrkmuch+0x140>
  a = sbrk(0);
    48b6:	4501                	li	a0,0
    48b8:	00001097          	auipc	ra,0x1
    48bc:	fba080e7          	jalr	-70(ra) # 5872 <sbrk>
    48c0:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    48c2:	6505                	lui	a0,0x1
    48c4:	00001097          	auipc	ra,0x1
    48c8:	fae080e7          	jalr	-82(ra) # 5872 <sbrk>
    48cc:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    48ce:	0aa49a63          	bne	s1,a0,4982 <sbrkmuch+0x160>
    48d2:	4501                	li	a0,0
    48d4:	00001097          	auipc	ra,0x1
    48d8:	f9e080e7          	jalr	-98(ra) # 5872 <sbrk>
    48dc:	6785                	lui	a5,0x1
    48de:	97a6                	add	a5,a5,s1
    48e0:	0af51163          	bne	a0,a5,4982 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    48e4:	064007b7          	lui	a5,0x6400
    48e8:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f1507>
    48ec:	06300793          	li	a5,99
    48f0:	0af70963          	beq	a4,a5,49a2 <sbrkmuch+0x180>
  a = sbrk(0);
    48f4:	4501                	li	a0,0
    48f6:	00001097          	auipc	ra,0x1
    48fa:	f7c080e7          	jalr	-132(ra) # 5872 <sbrk>
    48fe:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    4900:	4501                	li	a0,0
    4902:	00001097          	auipc	ra,0x1
    4906:	f70080e7          	jalr	-144(ra) # 5872 <sbrk>
    490a:	40a9053b          	subw	a0,s2,a0
    490e:	00001097          	auipc	ra,0x1
    4912:	f64080e7          	jalr	-156(ra) # 5872 <sbrk>
  if(c != a){
    4916:	0aa49463          	bne	s1,a0,49be <sbrkmuch+0x19c>
}
    491a:	70a2                	ld	ra,40(sp)
    491c:	7402                	ld	s0,32(sp)
    491e:	64e2                	ld	s1,24(sp)
    4920:	6942                	ld	s2,16(sp)
    4922:	69a2                	ld	s3,8(sp)
    4924:	6a02                	ld	s4,0(sp)
    4926:	6145                	addi	sp,sp,48
    4928:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    492a:	85ce                	mv	a1,s3
    492c:	00003517          	auipc	a0,0x3
    4930:	2c450513          	addi	a0,a0,708 # 7bf0 <malloc+0x1fb8>
    4934:	00001097          	auipc	ra,0x1
    4938:	246080e7          	jalr	582(ra) # 5b7a <printf>
    exit(1);
    493c:	4505                	li	a0,1
    493e:	00001097          	auipc	ra,0x1
    4942:	eac080e7          	jalr	-340(ra) # 57ea <exit>
    printf("%s: sbrk could not deallocate\n", s);
    4946:	85ce                	mv	a1,s3
    4948:	00003517          	auipc	a0,0x3
    494c:	2f050513          	addi	a0,a0,752 # 7c38 <malloc+0x2000>
    4950:	00001097          	auipc	ra,0x1
    4954:	22a080e7          	jalr	554(ra) # 5b7a <printf>
    exit(1);
    4958:	4505                	li	a0,1
    495a:	00001097          	auipc	ra,0x1
    495e:	e90080e7          	jalr	-368(ra) # 57ea <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    4962:	86aa                	mv	a3,a0
    4964:	8626                	mv	a2,s1
    4966:	85ce                	mv	a1,s3
    4968:	00003517          	auipc	a0,0x3
    496c:	2f050513          	addi	a0,a0,752 # 7c58 <malloc+0x2020>
    4970:	00001097          	auipc	ra,0x1
    4974:	20a080e7          	jalr	522(ra) # 5b7a <printf>
    exit(1);
    4978:	4505                	li	a0,1
    497a:	00001097          	auipc	ra,0x1
    497e:	e70080e7          	jalr	-400(ra) # 57ea <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    4982:	86d2                	mv	a3,s4
    4984:	8626                	mv	a2,s1
    4986:	85ce                	mv	a1,s3
    4988:	00003517          	auipc	a0,0x3
    498c:	31050513          	addi	a0,a0,784 # 7c98 <malloc+0x2060>
    4990:	00001097          	auipc	ra,0x1
    4994:	1ea080e7          	jalr	490(ra) # 5b7a <printf>
    exit(1);
    4998:	4505                	li	a0,1
    499a:	00001097          	auipc	ra,0x1
    499e:	e50080e7          	jalr	-432(ra) # 57ea <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    49a2:	85ce                	mv	a1,s3
    49a4:	00003517          	auipc	a0,0x3
    49a8:	32450513          	addi	a0,a0,804 # 7cc8 <malloc+0x2090>
    49ac:	00001097          	auipc	ra,0x1
    49b0:	1ce080e7          	jalr	462(ra) # 5b7a <printf>
    exit(1);
    49b4:	4505                	li	a0,1
    49b6:	00001097          	auipc	ra,0x1
    49ba:	e34080e7          	jalr	-460(ra) # 57ea <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    49be:	86aa                	mv	a3,a0
    49c0:	8626                	mv	a2,s1
    49c2:	85ce                	mv	a1,s3
    49c4:	00003517          	auipc	a0,0x3
    49c8:	33c50513          	addi	a0,a0,828 # 7d00 <malloc+0x20c8>
    49cc:	00001097          	auipc	ra,0x1
    49d0:	1ae080e7          	jalr	430(ra) # 5b7a <printf>
    exit(1);
    49d4:	4505                	li	a0,1
    49d6:	00001097          	auipc	ra,0x1
    49da:	e14080e7          	jalr	-492(ra) # 57ea <exit>

00000000000049de <kernmem>:
{
    49de:	715d                	addi	sp,sp,-80
    49e0:	e486                	sd	ra,72(sp)
    49e2:	e0a2                	sd	s0,64(sp)
    49e4:	fc26                	sd	s1,56(sp)
    49e6:	f84a                	sd	s2,48(sp)
    49e8:	f44e                	sd	s3,40(sp)
    49ea:	f052                	sd	s4,32(sp)
    49ec:	ec56                	sd	s5,24(sp)
    49ee:	0880                	addi	s0,sp,80
    49f0:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    49f2:	4485                	li	s1,1
    49f4:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    49f6:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    49f8:	69b1                	lui	s3,0xc
    49fa:	35098993          	addi	s3,s3,848 # c350 <buf+0x868>
    49fe:	1003d937          	lui	s2,0x1003d
    4a02:	090e                	slli	s2,s2,0x3
    4a04:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e988>
    pid = fork();
    4a08:	00001097          	auipc	ra,0x1
    4a0c:	dda080e7          	jalr	-550(ra) # 57e2 <fork>
    if(pid < 0){
    4a10:	02054963          	bltz	a0,4a42 <kernmem+0x64>
    if(pid == 0){
    4a14:	c529                	beqz	a0,4a5e <kernmem+0x80>
    wait(&xstatus);
    4a16:	fbc40513          	addi	a0,s0,-68
    4a1a:	00001097          	auipc	ra,0x1
    4a1e:	dd8080e7          	jalr	-552(ra) # 57f2 <wait>
    if(xstatus != -1)  // did kernel kill child?
    4a22:	fbc42783          	lw	a5,-68(s0)
    4a26:	05579d63          	bne	a5,s5,4a80 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    4a2a:	94ce                	add	s1,s1,s3
    4a2c:	fd249ee3          	bne	s1,s2,4a08 <kernmem+0x2a>
}
    4a30:	60a6                	ld	ra,72(sp)
    4a32:	6406                	ld	s0,64(sp)
    4a34:	74e2                	ld	s1,56(sp)
    4a36:	7942                	ld	s2,48(sp)
    4a38:	79a2                	ld	s3,40(sp)
    4a3a:	7a02                	ld	s4,32(sp)
    4a3c:	6ae2                	ld	s5,24(sp)
    4a3e:	6161                	addi	sp,sp,80
    4a40:	8082                	ret
      printf("%s: fork failed\n", s);
    4a42:	85d2                	mv	a1,s4
    4a44:	00001517          	auipc	a0,0x1
    4a48:	56450513          	addi	a0,a0,1380 # 5fa8 <malloc+0x370>
    4a4c:	00001097          	auipc	ra,0x1
    4a50:	12e080e7          	jalr	302(ra) # 5b7a <printf>
      exit(1);
    4a54:	4505                	li	a0,1
    4a56:	00001097          	auipc	ra,0x1
    4a5a:	d94080e7          	jalr	-620(ra) # 57ea <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    4a5e:	0004c683          	lbu	a3,0(s1)
    4a62:	8626                	mv	a2,s1
    4a64:	85d2                	mv	a1,s4
    4a66:	00003517          	auipc	a0,0x3
    4a6a:	2c250513          	addi	a0,a0,706 # 7d28 <malloc+0x20f0>
    4a6e:	00001097          	auipc	ra,0x1
    4a72:	10c080e7          	jalr	268(ra) # 5b7a <printf>
      exit(1);
    4a76:	4505                	li	a0,1
    4a78:	00001097          	auipc	ra,0x1
    4a7c:	d72080e7          	jalr	-654(ra) # 57ea <exit>
      exit(1);
    4a80:	4505                	li	a0,1
    4a82:	00001097          	auipc	ra,0x1
    4a86:	d68080e7          	jalr	-664(ra) # 57ea <exit>

0000000000004a8a <sbrkfail>:
{
    4a8a:	7119                	addi	sp,sp,-128
    4a8c:	fc86                	sd	ra,120(sp)
    4a8e:	f8a2                	sd	s0,112(sp)
    4a90:	f4a6                	sd	s1,104(sp)
    4a92:	f0ca                	sd	s2,96(sp)
    4a94:	ecce                	sd	s3,88(sp)
    4a96:	e8d2                	sd	s4,80(sp)
    4a98:	e4d6                	sd	s5,72(sp)
    4a9a:	0100                	addi	s0,sp,128
    4a9c:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    4a9e:	fb040513          	addi	a0,s0,-80
    4aa2:	00001097          	auipc	ra,0x1
    4aa6:	d58080e7          	jalr	-680(ra) # 57fa <pipe>
    4aaa:	e901                	bnez	a0,4aba <sbrkfail+0x30>
    4aac:	f8040493          	addi	s1,s0,-128
    4ab0:	fa840993          	addi	s3,s0,-88
    4ab4:	8926                	mv	s2,s1
    if(pids[i] != -1)
    4ab6:	5a7d                	li	s4,-1
    4ab8:	a085                	j	4b18 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    4aba:	85d6                	mv	a1,s5
    4abc:	00002517          	auipc	a0,0x2
    4ac0:	8e450513          	addi	a0,a0,-1820 # 63a0 <malloc+0x768>
    4ac4:	00001097          	auipc	ra,0x1
    4ac8:	0b6080e7          	jalr	182(ra) # 5b7a <printf>
    exit(1);
    4acc:	4505                	li	a0,1
    4ace:	00001097          	auipc	ra,0x1
    4ad2:	d1c080e7          	jalr	-740(ra) # 57ea <exit>
      sbrk(BIG - (uint64)sbrk(0));
    4ad6:	00001097          	auipc	ra,0x1
    4ada:	d9c080e7          	jalr	-612(ra) # 5872 <sbrk>
    4ade:	064007b7          	lui	a5,0x6400
    4ae2:	40a7853b          	subw	a0,a5,a0
    4ae6:	00001097          	auipc	ra,0x1
    4aea:	d8c080e7          	jalr	-628(ra) # 5872 <sbrk>
      write(fds[1], "x", 1);
    4aee:	4605                	li	a2,1
    4af0:	00001597          	auipc	a1,0x1
    4af4:	63858593          	addi	a1,a1,1592 # 6128 <malloc+0x4f0>
    4af8:	fb442503          	lw	a0,-76(s0)
    4afc:	00001097          	auipc	ra,0x1
    4b00:	d0e080e7          	jalr	-754(ra) # 580a <write>
      for(;;) sleep(1000);
    4b04:	3e800513          	li	a0,1000
    4b08:	00001097          	auipc	ra,0x1
    4b0c:	d72080e7          	jalr	-654(ra) # 587a <sleep>
    4b10:	bfd5                	j	4b04 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4b12:	0911                	addi	s2,s2,4
    4b14:	03390563          	beq	s2,s3,4b3e <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    4b18:	00001097          	auipc	ra,0x1
    4b1c:	cca080e7          	jalr	-822(ra) # 57e2 <fork>
    4b20:	00a92023          	sw	a0,0(s2)
    4b24:	d94d                	beqz	a0,4ad6 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4b26:	ff4506e3          	beq	a0,s4,4b12 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4b2a:	4605                	li	a2,1
    4b2c:	faf40593          	addi	a1,s0,-81
    4b30:	fb042503          	lw	a0,-80(s0)
    4b34:	00001097          	auipc	ra,0x1
    4b38:	cce080e7          	jalr	-818(ra) # 5802 <read>
    4b3c:	bfd9                	j	4b12 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    4b3e:	6505                	lui	a0,0x1
    4b40:	00001097          	auipc	ra,0x1
    4b44:	d32080e7          	jalr	-718(ra) # 5872 <sbrk>
    4b48:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    4b4a:	597d                	li	s2,-1
    4b4c:	a021                	j	4b54 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4b4e:	0491                	addi	s1,s1,4
    4b50:	03348063          	beq	s1,s3,4b70 <sbrkfail+0xe6>
    if(pids[i] == -1)
    4b54:	4088                	lw	a0,0(s1)
    4b56:	ff250ce3          	beq	a0,s2,4b4e <sbrkfail+0xc4>
    kill(pids[i], SIGKILL);
    4b5a:	45a5                	li	a1,9
    4b5c:	00001097          	auipc	ra,0x1
    4b60:	cbe080e7          	jalr	-834(ra) # 581a <kill>
    wait(0);
    4b64:	4501                	li	a0,0
    4b66:	00001097          	auipc	ra,0x1
    4b6a:	c8c080e7          	jalr	-884(ra) # 57f2 <wait>
    4b6e:	b7c5                	j	4b4e <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4b70:	57fd                	li	a5,-1
    4b72:	04fa0163          	beq	s4,a5,4bb4 <sbrkfail+0x12a>
  pid = fork();
    4b76:	00001097          	auipc	ra,0x1
    4b7a:	c6c080e7          	jalr	-916(ra) # 57e2 <fork>
    4b7e:	84aa                	mv	s1,a0
  if(pid < 0){
    4b80:	04054863          	bltz	a0,4bd0 <sbrkfail+0x146>
  if(pid == 0){
    4b84:	c525                	beqz	a0,4bec <sbrkfail+0x162>
  wait(&xstatus);
    4b86:	fbc40513          	addi	a0,s0,-68
    4b8a:	00001097          	auipc	ra,0x1
    4b8e:	c68080e7          	jalr	-920(ra) # 57f2 <wait>
  if(xstatus != -1 && xstatus != 2)
    4b92:	fbc42783          	lw	a5,-68(s0)
    4b96:	577d                	li	a4,-1
    4b98:	00e78563          	beq	a5,a4,4ba2 <sbrkfail+0x118>
    4b9c:	4709                	li	a4,2
    4b9e:	08e79d63          	bne	a5,a4,4c38 <sbrkfail+0x1ae>
}
    4ba2:	70e6                	ld	ra,120(sp)
    4ba4:	7446                	ld	s0,112(sp)
    4ba6:	74a6                	ld	s1,104(sp)
    4ba8:	7906                	ld	s2,96(sp)
    4baa:	69e6                	ld	s3,88(sp)
    4bac:	6a46                	ld	s4,80(sp)
    4bae:	6aa6                	ld	s5,72(sp)
    4bb0:	6109                	addi	sp,sp,128
    4bb2:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4bb4:	85d6                	mv	a1,s5
    4bb6:	00003517          	auipc	a0,0x3
    4bba:	19250513          	addi	a0,a0,402 # 7d48 <malloc+0x2110>
    4bbe:	00001097          	auipc	ra,0x1
    4bc2:	fbc080e7          	jalr	-68(ra) # 5b7a <printf>
    exit(1);
    4bc6:	4505                	li	a0,1
    4bc8:	00001097          	auipc	ra,0x1
    4bcc:	c22080e7          	jalr	-990(ra) # 57ea <exit>
    printf("%s: fork failed\n", s);
    4bd0:	85d6                	mv	a1,s5
    4bd2:	00001517          	auipc	a0,0x1
    4bd6:	3d650513          	addi	a0,a0,982 # 5fa8 <malloc+0x370>
    4bda:	00001097          	auipc	ra,0x1
    4bde:	fa0080e7          	jalr	-96(ra) # 5b7a <printf>
    exit(1);
    4be2:	4505                	li	a0,1
    4be4:	00001097          	auipc	ra,0x1
    4be8:	c06080e7          	jalr	-1018(ra) # 57ea <exit>
    a = sbrk(0);
    4bec:	4501                	li	a0,0
    4bee:	00001097          	auipc	ra,0x1
    4bf2:	c84080e7          	jalr	-892(ra) # 5872 <sbrk>
    4bf6:	892a                	mv	s2,a0
    sbrk(10*BIG);
    4bf8:	3e800537          	lui	a0,0x3e800
    4bfc:	00001097          	auipc	ra,0x1
    4c00:	c76080e7          	jalr	-906(ra) # 5872 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4c04:	87ca                	mv	a5,s2
    4c06:	3e800737          	lui	a4,0x3e800
    4c0a:	993a                	add	s2,s2,a4
    4c0c:	6705                	lui	a4,0x1
      n += *(a+i);
    4c0e:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f1508>
    4c12:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4c14:	97ba                	add	a5,a5,a4
    4c16:	ff279ce3          	bne	a5,s2,4c0e <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4c1a:	8626                	mv	a2,s1
    4c1c:	85d6                	mv	a1,s5
    4c1e:	00003517          	auipc	a0,0x3
    4c22:	14a50513          	addi	a0,a0,330 # 7d68 <malloc+0x2130>
    4c26:	00001097          	auipc	ra,0x1
    4c2a:	f54080e7          	jalr	-172(ra) # 5b7a <printf>
    exit(1);
    4c2e:	4505                	li	a0,1
    4c30:	00001097          	auipc	ra,0x1
    4c34:	bba080e7          	jalr	-1094(ra) # 57ea <exit>
    exit(1);
    4c38:	4505                	li	a0,1
    4c3a:	00001097          	auipc	ra,0x1
    4c3e:	bb0080e7          	jalr	-1104(ra) # 57ea <exit>

0000000000004c42 <fsfull>:
{
    4c42:	7171                	addi	sp,sp,-176
    4c44:	f506                	sd	ra,168(sp)
    4c46:	f122                	sd	s0,160(sp)
    4c48:	ed26                	sd	s1,152(sp)
    4c4a:	e94a                	sd	s2,144(sp)
    4c4c:	e54e                	sd	s3,136(sp)
    4c4e:	e152                	sd	s4,128(sp)
    4c50:	fcd6                	sd	s5,120(sp)
    4c52:	f8da                	sd	s6,112(sp)
    4c54:	f4de                	sd	s7,104(sp)
    4c56:	f0e2                	sd	s8,96(sp)
    4c58:	ece6                	sd	s9,88(sp)
    4c5a:	e8ea                	sd	s10,80(sp)
    4c5c:	e4ee                	sd	s11,72(sp)
    4c5e:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4c60:	00003517          	auipc	a0,0x3
    4c64:	13850513          	addi	a0,a0,312 # 7d98 <malloc+0x2160>
    4c68:	00001097          	auipc	ra,0x1
    4c6c:	f12080e7          	jalr	-238(ra) # 5b7a <printf>
  for(nfiles = 0; ; nfiles++){
    4c70:	4481                	li	s1,0
    name[0] = 'f';
    4c72:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4c76:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4c7a:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4c7e:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4c80:	00003c97          	auipc	s9,0x3
    4c84:	128c8c93          	addi	s9,s9,296 # 7da8 <malloc+0x2170>
    int total = 0;
    4c88:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4c8a:	00007a17          	auipc	s4,0x7
    4c8e:	e5ea0a13          	addi	s4,s4,-418 # bae8 <buf>
    name[0] = 'f';
    4c92:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4c96:	0384c7bb          	divw	a5,s1,s8
    4c9a:	0307879b          	addiw	a5,a5,48
    4c9e:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4ca2:	0384e7bb          	remw	a5,s1,s8
    4ca6:	0377c7bb          	divw	a5,a5,s7
    4caa:	0307879b          	addiw	a5,a5,48
    4cae:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4cb2:	0374e7bb          	remw	a5,s1,s7
    4cb6:	0367c7bb          	divw	a5,a5,s6
    4cba:	0307879b          	addiw	a5,a5,48
    4cbe:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4cc2:	0364e7bb          	remw	a5,s1,s6
    4cc6:	0307879b          	addiw	a5,a5,48
    4cca:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4cce:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4cd2:	f5040593          	addi	a1,s0,-176
    4cd6:	8566                	mv	a0,s9
    4cd8:	00001097          	auipc	ra,0x1
    4cdc:	ea2080e7          	jalr	-350(ra) # 5b7a <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4ce0:	20200593          	li	a1,514
    4ce4:	f5040513          	addi	a0,s0,-176
    4ce8:	00001097          	auipc	ra,0x1
    4cec:	b42080e7          	jalr	-1214(ra) # 582a <open>
    4cf0:	892a                	mv	s2,a0
    if(fd < 0){
    4cf2:	0a055663          	bgez	a0,4d9e <fsfull+0x15c>
      printf("open %s failed\n", name);
    4cf6:	f5040593          	addi	a1,s0,-176
    4cfa:	00003517          	auipc	a0,0x3
    4cfe:	0be50513          	addi	a0,a0,190 # 7db8 <malloc+0x2180>
    4d02:	00001097          	auipc	ra,0x1
    4d06:	e78080e7          	jalr	-392(ra) # 5b7a <printf>
  while(nfiles >= 0){
    4d0a:	0604c363          	bltz	s1,4d70 <fsfull+0x12e>
    name[0] = 'f';
    4d0e:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4d12:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4d16:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4d1a:	4929                	li	s2,10
  while(nfiles >= 0){
    4d1c:	5afd                	li	s5,-1
    name[0] = 'f';
    4d1e:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4d22:	0344c7bb          	divw	a5,s1,s4
    4d26:	0307879b          	addiw	a5,a5,48
    4d2a:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4d2e:	0344e7bb          	remw	a5,s1,s4
    4d32:	0337c7bb          	divw	a5,a5,s3
    4d36:	0307879b          	addiw	a5,a5,48
    4d3a:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4d3e:	0334e7bb          	remw	a5,s1,s3
    4d42:	0327c7bb          	divw	a5,a5,s2
    4d46:	0307879b          	addiw	a5,a5,48
    4d4a:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4d4e:	0324e7bb          	remw	a5,s1,s2
    4d52:	0307879b          	addiw	a5,a5,48
    4d56:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4d5a:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4d5e:	f5040513          	addi	a0,s0,-176
    4d62:	00001097          	auipc	ra,0x1
    4d66:	ad8080e7          	jalr	-1320(ra) # 583a <unlink>
    nfiles--;
    4d6a:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4d6c:	fb5499e3          	bne	s1,s5,4d1e <fsfull+0xdc>
  printf("fsfull test finished\n");
    4d70:	00003517          	auipc	a0,0x3
    4d74:	06850513          	addi	a0,a0,104 # 7dd8 <malloc+0x21a0>
    4d78:	00001097          	auipc	ra,0x1
    4d7c:	e02080e7          	jalr	-510(ra) # 5b7a <printf>
}
    4d80:	70aa                	ld	ra,168(sp)
    4d82:	740a                	ld	s0,160(sp)
    4d84:	64ea                	ld	s1,152(sp)
    4d86:	694a                	ld	s2,144(sp)
    4d88:	69aa                	ld	s3,136(sp)
    4d8a:	6a0a                	ld	s4,128(sp)
    4d8c:	7ae6                	ld	s5,120(sp)
    4d8e:	7b46                	ld	s6,112(sp)
    4d90:	7ba6                	ld	s7,104(sp)
    4d92:	7c06                	ld	s8,96(sp)
    4d94:	6ce6                	ld	s9,88(sp)
    4d96:	6d46                	ld	s10,80(sp)
    4d98:	6da6                	ld	s11,72(sp)
    4d9a:	614d                	addi	sp,sp,176
    4d9c:	8082                	ret
    int total = 0;
    4d9e:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4da0:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4da4:	40000613          	li	a2,1024
    4da8:	85d2                	mv	a1,s4
    4daa:	854a                	mv	a0,s2
    4dac:	00001097          	auipc	ra,0x1
    4db0:	a5e080e7          	jalr	-1442(ra) # 580a <write>
      if(cc < BSIZE)
    4db4:	00aad563          	bge	s5,a0,4dbe <fsfull+0x17c>
      total += cc;
    4db8:	00a989bb          	addw	s3,s3,a0
    while(1){
    4dbc:	b7e5                	j	4da4 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4dbe:	85ce                	mv	a1,s3
    4dc0:	00003517          	auipc	a0,0x3
    4dc4:	00850513          	addi	a0,a0,8 # 7dc8 <malloc+0x2190>
    4dc8:	00001097          	auipc	ra,0x1
    4dcc:	db2080e7          	jalr	-590(ra) # 5b7a <printf>
    close(fd);
    4dd0:	854a                	mv	a0,s2
    4dd2:	00001097          	auipc	ra,0x1
    4dd6:	a40080e7          	jalr	-1472(ra) # 5812 <close>
    if(total == 0)
    4dda:	f20988e3          	beqz	s3,4d0a <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4dde:	2485                	addiw	s1,s1,1
    4de0:	bd4d                	j	4c92 <fsfull+0x50>

0000000000004de2 <rand>:
{
    4de2:	1141                	addi	sp,sp,-16
    4de4:	e422                	sd	s0,8(sp)
    4de6:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4de8:	00003717          	auipc	a4,0x3
    4dec:	4d070713          	addi	a4,a4,1232 # 82b8 <randstate>
    4df0:	6308                	ld	a0,0(a4)
    4df2:	001967b7          	lui	a5,0x196
    4df6:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187b15>
    4dfa:	02f50533          	mul	a0,a0,a5
    4dfe:	3c6ef7b7          	lui	a5,0x3c6ef
    4e02:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e0867>
    4e06:	953e                	add	a0,a0,a5
    4e08:	e308                	sd	a0,0(a4)
}
    4e0a:	2501                	sext.w	a0,a0
    4e0c:	6422                	ld	s0,8(sp)
    4e0e:	0141                	addi	sp,sp,16
    4e10:	8082                	ret

0000000000004e12 <stacktest>:
{
    4e12:	7179                	addi	sp,sp,-48
    4e14:	f406                	sd	ra,40(sp)
    4e16:	f022                	sd	s0,32(sp)
    4e18:	ec26                	sd	s1,24(sp)
    4e1a:	1800                	addi	s0,sp,48
    4e1c:	84aa                	mv	s1,a0
  pid = fork();
    4e1e:	00001097          	auipc	ra,0x1
    4e22:	9c4080e7          	jalr	-1596(ra) # 57e2 <fork>
  if(pid == 0) {
    4e26:	c115                	beqz	a0,4e4a <stacktest+0x38>
  } else if(pid < 0){
    4e28:	04054463          	bltz	a0,4e70 <stacktest+0x5e>
  wait(&xstatus);
    4e2c:	fdc40513          	addi	a0,s0,-36
    4e30:	00001097          	auipc	ra,0x1
    4e34:	9c2080e7          	jalr	-1598(ra) # 57f2 <wait>
  if(xstatus == -1)  // kernel killed child?
    4e38:	fdc42503          	lw	a0,-36(s0)
    4e3c:	57fd                	li	a5,-1
    4e3e:	04f50763          	beq	a0,a5,4e8c <stacktest+0x7a>
    exit(xstatus);
    4e42:	00001097          	auipc	ra,0x1
    4e46:	9a8080e7          	jalr	-1624(ra) # 57ea <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    4e4a:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    4e4c:	77fd                	lui	a5,0xfffff
    4e4e:	97ba                	add	a5,a5,a4
    4e50:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff0508>
    4e54:	85a6                	mv	a1,s1
    4e56:	00003517          	auipc	a0,0x3
    4e5a:	f9a50513          	addi	a0,a0,-102 # 7df0 <malloc+0x21b8>
    4e5e:	00001097          	auipc	ra,0x1
    4e62:	d1c080e7          	jalr	-740(ra) # 5b7a <printf>
    exit(1);
    4e66:	4505                	li	a0,1
    4e68:	00001097          	auipc	ra,0x1
    4e6c:	982080e7          	jalr	-1662(ra) # 57ea <exit>
    printf("%s: fork failed\n", s);
    4e70:	85a6                	mv	a1,s1
    4e72:	00001517          	auipc	a0,0x1
    4e76:	13650513          	addi	a0,a0,310 # 5fa8 <malloc+0x370>
    4e7a:	00001097          	auipc	ra,0x1
    4e7e:	d00080e7          	jalr	-768(ra) # 5b7a <printf>
    exit(1);
    4e82:	4505                	li	a0,1
    4e84:	00001097          	auipc	ra,0x1
    4e88:	966080e7          	jalr	-1690(ra) # 57ea <exit>
    exit(0);
    4e8c:	4501                	li	a0,0
    4e8e:	00001097          	auipc	ra,0x1
    4e92:	95c080e7          	jalr	-1700(ra) # 57ea <exit>

0000000000004e96 <sbrkbugs>:
{
    4e96:	1141                	addi	sp,sp,-16
    4e98:	e406                	sd	ra,8(sp)
    4e9a:	e022                	sd	s0,0(sp)
    4e9c:	0800                	addi	s0,sp,16
  int pid = fork();
    4e9e:	00001097          	auipc	ra,0x1
    4ea2:	944080e7          	jalr	-1724(ra) # 57e2 <fork>
  if(pid < 0){
    4ea6:	02054263          	bltz	a0,4eca <sbrkbugs+0x34>
  if(pid == 0){
    4eaa:	ed0d                	bnez	a0,4ee4 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    4eac:	00001097          	auipc	ra,0x1
    4eb0:	9c6080e7          	jalr	-1594(ra) # 5872 <sbrk>
    sbrk(-sz);
    4eb4:	40a0053b          	negw	a0,a0
    4eb8:	00001097          	auipc	ra,0x1
    4ebc:	9ba080e7          	jalr	-1606(ra) # 5872 <sbrk>
    exit(0);
    4ec0:	4501                	li	a0,0
    4ec2:	00001097          	auipc	ra,0x1
    4ec6:	928080e7          	jalr	-1752(ra) # 57ea <exit>
    printf("fork failed\n");
    4eca:	00002517          	auipc	a0,0x2
    4ece:	a6e50513          	addi	a0,a0,-1426 # 6938 <malloc+0xd00>
    4ed2:	00001097          	auipc	ra,0x1
    4ed6:	ca8080e7          	jalr	-856(ra) # 5b7a <printf>
    exit(1);
    4eda:	4505                	li	a0,1
    4edc:	00001097          	auipc	ra,0x1
    4ee0:	90e080e7          	jalr	-1778(ra) # 57ea <exit>
  wait(0);
    4ee4:	4501                	li	a0,0
    4ee6:	00001097          	auipc	ra,0x1
    4eea:	90c080e7          	jalr	-1780(ra) # 57f2 <wait>
  pid = fork();
    4eee:	00001097          	auipc	ra,0x1
    4ef2:	8f4080e7          	jalr	-1804(ra) # 57e2 <fork>
  if(pid < 0){
    4ef6:	02054563          	bltz	a0,4f20 <sbrkbugs+0x8a>
  if(pid == 0){
    4efa:	e121                	bnez	a0,4f3a <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    4efc:	00001097          	auipc	ra,0x1
    4f00:	976080e7          	jalr	-1674(ra) # 5872 <sbrk>
    sbrk(-(sz - 3500));
    4f04:	6785                	lui	a5,0x1
    4f06:	dac7879b          	addiw	a5,a5,-596
    4f0a:	40a7853b          	subw	a0,a5,a0
    4f0e:	00001097          	auipc	ra,0x1
    4f12:	964080e7          	jalr	-1692(ra) # 5872 <sbrk>
    exit(0);
    4f16:	4501                	li	a0,0
    4f18:	00001097          	auipc	ra,0x1
    4f1c:	8d2080e7          	jalr	-1838(ra) # 57ea <exit>
    printf("fork failed\n");
    4f20:	00002517          	auipc	a0,0x2
    4f24:	a1850513          	addi	a0,a0,-1512 # 6938 <malloc+0xd00>
    4f28:	00001097          	auipc	ra,0x1
    4f2c:	c52080e7          	jalr	-942(ra) # 5b7a <printf>
    exit(1);
    4f30:	4505                	li	a0,1
    4f32:	00001097          	auipc	ra,0x1
    4f36:	8b8080e7          	jalr	-1864(ra) # 57ea <exit>
  wait(0);
    4f3a:	4501                	li	a0,0
    4f3c:	00001097          	auipc	ra,0x1
    4f40:	8b6080e7          	jalr	-1866(ra) # 57f2 <wait>
  pid = fork();
    4f44:	00001097          	auipc	ra,0x1
    4f48:	89e080e7          	jalr	-1890(ra) # 57e2 <fork>
  if(pid < 0){
    4f4c:	02054a63          	bltz	a0,4f80 <sbrkbugs+0xea>
  if(pid == 0){
    4f50:	e529                	bnez	a0,4f9a <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    4f52:	00001097          	auipc	ra,0x1
    4f56:	920080e7          	jalr	-1760(ra) # 5872 <sbrk>
    4f5a:	67ad                	lui	a5,0xb
    4f5c:	8007879b          	addiw	a5,a5,-2048
    4f60:	40a7853b          	subw	a0,a5,a0
    4f64:	00001097          	auipc	ra,0x1
    4f68:	90e080e7          	jalr	-1778(ra) # 5872 <sbrk>
    sbrk(-10);
    4f6c:	5559                	li	a0,-10
    4f6e:	00001097          	auipc	ra,0x1
    4f72:	904080e7          	jalr	-1788(ra) # 5872 <sbrk>
    exit(0);
    4f76:	4501                	li	a0,0
    4f78:	00001097          	auipc	ra,0x1
    4f7c:	872080e7          	jalr	-1934(ra) # 57ea <exit>
    printf("fork failed\n");
    4f80:	00002517          	auipc	a0,0x2
    4f84:	9b850513          	addi	a0,a0,-1608 # 6938 <malloc+0xd00>
    4f88:	00001097          	auipc	ra,0x1
    4f8c:	bf2080e7          	jalr	-1038(ra) # 5b7a <printf>
    exit(1);
    4f90:	4505                	li	a0,1
    4f92:	00001097          	auipc	ra,0x1
    4f96:	858080e7          	jalr	-1960(ra) # 57ea <exit>
  wait(0);
    4f9a:	4501                	li	a0,0
    4f9c:	00001097          	auipc	ra,0x1
    4fa0:	856080e7          	jalr	-1962(ra) # 57f2 <wait>
  exit(0);
    4fa4:	4501                	li	a0,0
    4fa6:	00001097          	auipc	ra,0x1
    4faa:	844080e7          	jalr	-1980(ra) # 57ea <exit>

0000000000004fae <badwrite>:
{
    4fae:	7179                	addi	sp,sp,-48
    4fb0:	f406                	sd	ra,40(sp)
    4fb2:	f022                	sd	s0,32(sp)
    4fb4:	ec26                	sd	s1,24(sp)
    4fb6:	e84a                	sd	s2,16(sp)
    4fb8:	e44e                	sd	s3,8(sp)
    4fba:	e052                	sd	s4,0(sp)
    4fbc:	1800                	addi	s0,sp,48
  unlink("junk");
    4fbe:	00003517          	auipc	a0,0x3
    4fc2:	e5a50513          	addi	a0,a0,-422 # 7e18 <malloc+0x21e0>
    4fc6:	00001097          	auipc	ra,0x1
    4fca:	874080e7          	jalr	-1932(ra) # 583a <unlink>
    4fce:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4fd2:	00003997          	auipc	s3,0x3
    4fd6:	e4698993          	addi	s3,s3,-442 # 7e18 <malloc+0x21e0>
    write(fd, (char*)0xffffffffffL, 1);
    4fda:	5a7d                	li	s4,-1
    4fdc:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4fe0:	20100593          	li	a1,513
    4fe4:	854e                	mv	a0,s3
    4fe6:	00001097          	auipc	ra,0x1
    4fea:	844080e7          	jalr	-1980(ra) # 582a <open>
    4fee:	84aa                	mv	s1,a0
    if(fd < 0){
    4ff0:	06054b63          	bltz	a0,5066 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4ff4:	4605                	li	a2,1
    4ff6:	85d2                	mv	a1,s4
    4ff8:	00001097          	auipc	ra,0x1
    4ffc:	812080e7          	jalr	-2030(ra) # 580a <write>
    close(fd);
    5000:	8526                	mv	a0,s1
    5002:	00001097          	auipc	ra,0x1
    5006:	810080e7          	jalr	-2032(ra) # 5812 <close>
    unlink("junk");
    500a:	854e                	mv	a0,s3
    500c:	00001097          	auipc	ra,0x1
    5010:	82e080e7          	jalr	-2002(ra) # 583a <unlink>
  for(int i = 0; i < assumed_free; i++){
    5014:	397d                	addiw	s2,s2,-1
    5016:	fc0915e3          	bnez	s2,4fe0 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    501a:	20100593          	li	a1,513
    501e:	00003517          	auipc	a0,0x3
    5022:	dfa50513          	addi	a0,a0,-518 # 7e18 <malloc+0x21e0>
    5026:	00001097          	auipc	ra,0x1
    502a:	804080e7          	jalr	-2044(ra) # 582a <open>
    502e:	84aa                	mv	s1,a0
  if(fd < 0){
    5030:	04054863          	bltz	a0,5080 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    5034:	4605                	li	a2,1
    5036:	00001597          	auipc	a1,0x1
    503a:	0f258593          	addi	a1,a1,242 # 6128 <malloc+0x4f0>
    503e:	00000097          	auipc	ra,0x0
    5042:	7cc080e7          	jalr	1996(ra) # 580a <write>
    5046:	4785                	li	a5,1
    5048:	04f50963          	beq	a0,a5,509a <badwrite+0xec>
    printf("write failed\n");
    504c:	00003517          	auipc	a0,0x3
    5050:	dec50513          	addi	a0,a0,-532 # 7e38 <malloc+0x2200>
    5054:	00001097          	auipc	ra,0x1
    5058:	b26080e7          	jalr	-1242(ra) # 5b7a <printf>
    exit(1);
    505c:	4505                	li	a0,1
    505e:	00000097          	auipc	ra,0x0
    5062:	78c080e7          	jalr	1932(ra) # 57ea <exit>
      printf("open junk failed\n");
    5066:	00003517          	auipc	a0,0x3
    506a:	dba50513          	addi	a0,a0,-582 # 7e20 <malloc+0x21e8>
    506e:	00001097          	auipc	ra,0x1
    5072:	b0c080e7          	jalr	-1268(ra) # 5b7a <printf>
      exit(1);
    5076:	4505                	li	a0,1
    5078:	00000097          	auipc	ra,0x0
    507c:	772080e7          	jalr	1906(ra) # 57ea <exit>
    printf("open junk failed\n");
    5080:	00003517          	auipc	a0,0x3
    5084:	da050513          	addi	a0,a0,-608 # 7e20 <malloc+0x21e8>
    5088:	00001097          	auipc	ra,0x1
    508c:	af2080e7          	jalr	-1294(ra) # 5b7a <printf>
    exit(1);
    5090:	4505                	li	a0,1
    5092:	00000097          	auipc	ra,0x0
    5096:	758080e7          	jalr	1880(ra) # 57ea <exit>
  close(fd);
    509a:	8526                	mv	a0,s1
    509c:	00000097          	auipc	ra,0x0
    50a0:	776080e7          	jalr	1910(ra) # 5812 <close>
  unlink("junk");
    50a4:	00003517          	auipc	a0,0x3
    50a8:	d7450513          	addi	a0,a0,-652 # 7e18 <malloc+0x21e0>
    50ac:	00000097          	auipc	ra,0x0
    50b0:	78e080e7          	jalr	1934(ra) # 583a <unlink>
  exit(0);
    50b4:	4501                	li	a0,0
    50b6:	00000097          	auipc	ra,0x0
    50ba:	734080e7          	jalr	1844(ra) # 57ea <exit>

00000000000050be <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    50be:	715d                	addi	sp,sp,-80
    50c0:	e486                	sd	ra,72(sp)
    50c2:	e0a2                	sd	s0,64(sp)
    50c4:	fc26                	sd	s1,56(sp)
    50c6:	f84a                	sd	s2,48(sp)
    50c8:	f44e                	sd	s3,40(sp)
    50ca:	f052                	sd	s4,32(sp)
    50cc:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    50ce:	4901                	li	s2,0
    50d0:	49bd                	li	s3,15
    int pid = fork();
    50d2:	00000097          	auipc	ra,0x0
    50d6:	710080e7          	jalr	1808(ra) # 57e2 <fork>
    50da:	84aa                	mv	s1,a0
    if(pid < 0){
    50dc:	02054063          	bltz	a0,50fc <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    50e0:	c91d                	beqz	a0,5116 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    50e2:	4501                	li	a0,0
    50e4:	00000097          	auipc	ra,0x0
    50e8:	70e080e7          	jalr	1806(ra) # 57f2 <wait>
  for(int avail = 0; avail < 15; avail++){
    50ec:	2905                	addiw	s2,s2,1
    50ee:	ff3912e3          	bne	s2,s3,50d2 <execout+0x14>
    }
  }

  exit(0);
    50f2:	4501                	li	a0,0
    50f4:	00000097          	auipc	ra,0x0
    50f8:	6f6080e7          	jalr	1782(ra) # 57ea <exit>
      printf("fork failed\n");
    50fc:	00002517          	auipc	a0,0x2
    5100:	83c50513          	addi	a0,a0,-1988 # 6938 <malloc+0xd00>
    5104:	00001097          	auipc	ra,0x1
    5108:	a76080e7          	jalr	-1418(ra) # 5b7a <printf>
      exit(1);
    510c:	4505                	li	a0,1
    510e:	00000097          	auipc	ra,0x0
    5112:	6dc080e7          	jalr	1756(ra) # 57ea <exit>
        if(a == 0xffffffffffffffffLL)
    5116:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    5118:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    511a:	6505                	lui	a0,0x1
    511c:	00000097          	auipc	ra,0x0
    5120:	756080e7          	jalr	1878(ra) # 5872 <sbrk>
        if(a == 0xffffffffffffffffLL)
    5124:	01350763          	beq	a0,s3,5132 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    5128:	6785                	lui	a5,0x1
    512a:	953e                	add	a0,a0,a5
    512c:	ff450fa3          	sb	s4,-1(a0) # fff <preempt+0x191>
      while(1){
    5130:	b7ed                	j	511a <execout+0x5c>
      for(int i = 0; i < avail; i++)
    5132:	01205a63          	blez	s2,5146 <execout+0x88>
        sbrk(-4096);
    5136:	757d                	lui	a0,0xfffff
    5138:	00000097          	auipc	ra,0x0
    513c:	73a080e7          	jalr	1850(ra) # 5872 <sbrk>
      for(int i = 0; i < avail; i++)
    5140:	2485                	addiw	s1,s1,1
    5142:	ff249ae3          	bne	s1,s2,5136 <execout+0x78>
      close(1);
    5146:	4505                	li	a0,1
    5148:	00000097          	auipc	ra,0x0
    514c:	6ca080e7          	jalr	1738(ra) # 5812 <close>
      char *args[] = { "echo", "x", 0 };
    5150:	00001517          	auipc	a0,0x1
    5154:	f6850513          	addi	a0,a0,-152 # 60b8 <malloc+0x480>
    5158:	faa43c23          	sd	a0,-72(s0)
    515c:	00001797          	auipc	a5,0x1
    5160:	fcc78793          	addi	a5,a5,-52 # 6128 <malloc+0x4f0>
    5164:	fcf43023          	sd	a5,-64(s0)
    5168:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    516c:	fb840593          	addi	a1,s0,-72
    5170:	00000097          	auipc	ra,0x0
    5174:	6b2080e7          	jalr	1714(ra) # 5822 <exec>
      exit(0);
    5178:	4501                	li	a0,0
    517a:	00000097          	auipc	ra,0x0
    517e:	670080e7          	jalr	1648(ra) # 57ea <exit>

0000000000005182 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    5182:	7139                	addi	sp,sp,-64
    5184:	fc06                	sd	ra,56(sp)
    5186:	f822                	sd	s0,48(sp)
    5188:	f426                	sd	s1,40(sp)
    518a:	f04a                	sd	s2,32(sp)
    518c:	ec4e                	sd	s3,24(sp)
    518e:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    5190:	fc840513          	addi	a0,s0,-56
    5194:	00000097          	auipc	ra,0x0
    5198:	666080e7          	jalr	1638(ra) # 57fa <pipe>
    519c:	06054763          	bltz	a0,520a <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    51a0:	00000097          	auipc	ra,0x0
    51a4:	642080e7          	jalr	1602(ra) # 57e2 <fork>

  if(pid < 0){
    51a8:	06054e63          	bltz	a0,5224 <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    51ac:	ed51                	bnez	a0,5248 <countfree+0xc6>
    close(fds[0]);
    51ae:	fc842503          	lw	a0,-56(s0)
    51b2:	00000097          	auipc	ra,0x0
    51b6:	660080e7          	jalr	1632(ra) # 5812 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    51ba:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    51bc:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    51be:	00001997          	auipc	s3,0x1
    51c2:	f6a98993          	addi	s3,s3,-150 # 6128 <malloc+0x4f0>
      uint64 a = (uint64) sbrk(4096);
    51c6:	6505                	lui	a0,0x1
    51c8:	00000097          	auipc	ra,0x0
    51cc:	6aa080e7          	jalr	1706(ra) # 5872 <sbrk>
      if(a == 0xffffffffffffffff){
    51d0:	07250763          	beq	a0,s2,523e <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    51d4:	6785                	lui	a5,0x1
    51d6:	953e                	add	a0,a0,a5
    51d8:	fe950fa3          	sb	s1,-1(a0) # fff <preempt+0x191>
      if(write(fds[1], "x", 1) != 1){
    51dc:	8626                	mv	a2,s1
    51de:	85ce                	mv	a1,s3
    51e0:	fcc42503          	lw	a0,-52(s0)
    51e4:	00000097          	auipc	ra,0x0
    51e8:	626080e7          	jalr	1574(ra) # 580a <write>
    51ec:	fc950de3          	beq	a0,s1,51c6 <countfree+0x44>
        printf("write() failed in countfree()\n");
    51f0:	00003517          	auipc	a0,0x3
    51f4:	c9850513          	addi	a0,a0,-872 # 7e88 <malloc+0x2250>
    51f8:	00001097          	auipc	ra,0x1
    51fc:	982080e7          	jalr	-1662(ra) # 5b7a <printf>
        exit(1);
    5200:	4505                	li	a0,1
    5202:	00000097          	auipc	ra,0x0
    5206:	5e8080e7          	jalr	1512(ra) # 57ea <exit>
    printf("pipe() failed in countfree()\n");
    520a:	00003517          	auipc	a0,0x3
    520e:	c3e50513          	addi	a0,a0,-962 # 7e48 <malloc+0x2210>
    5212:	00001097          	auipc	ra,0x1
    5216:	968080e7          	jalr	-1688(ra) # 5b7a <printf>
    exit(1);
    521a:	4505                	li	a0,1
    521c:	00000097          	auipc	ra,0x0
    5220:	5ce080e7          	jalr	1486(ra) # 57ea <exit>
    printf("fork failed in countfree()\n");
    5224:	00003517          	auipc	a0,0x3
    5228:	c4450513          	addi	a0,a0,-956 # 7e68 <malloc+0x2230>
    522c:	00001097          	auipc	ra,0x1
    5230:	94e080e7          	jalr	-1714(ra) # 5b7a <printf>
    exit(1);
    5234:	4505                	li	a0,1
    5236:	00000097          	auipc	ra,0x0
    523a:	5b4080e7          	jalr	1460(ra) # 57ea <exit>
      }
    }

    exit(0);
    523e:	4501                	li	a0,0
    5240:	00000097          	auipc	ra,0x0
    5244:	5aa080e7          	jalr	1450(ra) # 57ea <exit>
  }

  close(fds[1]);
    5248:	fcc42503          	lw	a0,-52(s0)
    524c:	00000097          	auipc	ra,0x0
    5250:	5c6080e7          	jalr	1478(ra) # 5812 <close>

  int n = 0;
    5254:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    5256:	4605                	li	a2,1
    5258:	fc740593          	addi	a1,s0,-57
    525c:	fc842503          	lw	a0,-56(s0)
    5260:	00000097          	auipc	ra,0x0
    5264:	5a2080e7          	jalr	1442(ra) # 5802 <read>
    if(cc < 0){
    5268:	00054563          	bltz	a0,5272 <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    526c:	c105                	beqz	a0,528c <countfree+0x10a>
      break;
    n += 1;
    526e:	2485                	addiw	s1,s1,1
  while(1){
    5270:	b7dd                	j	5256 <countfree+0xd4>
      printf("read() failed in countfree()\n");
    5272:	00003517          	auipc	a0,0x3
    5276:	c3650513          	addi	a0,a0,-970 # 7ea8 <malloc+0x2270>
    527a:	00001097          	auipc	ra,0x1
    527e:	900080e7          	jalr	-1792(ra) # 5b7a <printf>
      exit(1);
    5282:	4505                	li	a0,1
    5284:	00000097          	auipc	ra,0x0
    5288:	566080e7          	jalr	1382(ra) # 57ea <exit>
  }

  close(fds[0]);
    528c:	fc842503          	lw	a0,-56(s0)
    5290:	00000097          	auipc	ra,0x0
    5294:	582080e7          	jalr	1410(ra) # 5812 <close>
  wait((int*)0);
    5298:	4501                	li	a0,0
    529a:	00000097          	auipc	ra,0x0
    529e:	558080e7          	jalr	1368(ra) # 57f2 <wait>
  
  return n;
}
    52a2:	8526                	mv	a0,s1
    52a4:	70e2                	ld	ra,56(sp)
    52a6:	7442                	ld	s0,48(sp)
    52a8:	74a2                	ld	s1,40(sp)
    52aa:	7902                	ld	s2,32(sp)
    52ac:	69e2                	ld	s3,24(sp)
    52ae:	6121                	addi	sp,sp,64
    52b0:	8082                	ret

00000000000052b2 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    52b2:	7179                	addi	sp,sp,-48
    52b4:	f406                	sd	ra,40(sp)
    52b6:	f022                	sd	s0,32(sp)
    52b8:	ec26                	sd	s1,24(sp)
    52ba:	e84a                	sd	s2,16(sp)
    52bc:	1800                	addi	s0,sp,48
    52be:	84aa                	mv	s1,a0
    52c0:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    52c2:	00003517          	auipc	a0,0x3
    52c6:	c0650513          	addi	a0,a0,-1018 # 7ec8 <malloc+0x2290>
    52ca:	00001097          	auipc	ra,0x1
    52ce:	8b0080e7          	jalr	-1872(ra) # 5b7a <printf>
  if((pid = fork()) < 0) {
    52d2:	00000097          	auipc	ra,0x0
    52d6:	510080e7          	jalr	1296(ra) # 57e2 <fork>
    52da:	02054e63          	bltz	a0,5316 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    52de:	c929                	beqz	a0,5330 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    52e0:	fdc40513          	addi	a0,s0,-36
    52e4:	00000097          	auipc	ra,0x0
    52e8:	50e080e7          	jalr	1294(ra) # 57f2 <wait>
    if(xstatus != 0) 
    52ec:	fdc42783          	lw	a5,-36(s0)
    52f0:	c7b9                	beqz	a5,533e <run+0x8c>
      printf("FAILED\n");
    52f2:	00003517          	auipc	a0,0x3
    52f6:	bfe50513          	addi	a0,a0,-1026 # 7ef0 <malloc+0x22b8>
    52fa:	00001097          	auipc	ra,0x1
    52fe:	880080e7          	jalr	-1920(ra) # 5b7a <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5302:	fdc42503          	lw	a0,-36(s0)
  }
}
    5306:	00153513          	seqz	a0,a0
    530a:	70a2                	ld	ra,40(sp)
    530c:	7402                	ld	s0,32(sp)
    530e:	64e2                	ld	s1,24(sp)
    5310:	6942                	ld	s2,16(sp)
    5312:	6145                	addi	sp,sp,48
    5314:	8082                	ret
    printf("runtest: fork error\n");
    5316:	00003517          	auipc	a0,0x3
    531a:	bc250513          	addi	a0,a0,-1086 # 7ed8 <malloc+0x22a0>
    531e:	00001097          	auipc	ra,0x1
    5322:	85c080e7          	jalr	-1956(ra) # 5b7a <printf>
    exit(1);
    5326:	4505                	li	a0,1
    5328:	00000097          	auipc	ra,0x0
    532c:	4c2080e7          	jalr	1218(ra) # 57ea <exit>
    f(s);
    5330:	854a                	mv	a0,s2
    5332:	9482                	jalr	s1
    exit(0);
    5334:	4501                	li	a0,0
    5336:	00000097          	auipc	ra,0x0
    533a:	4b4080e7          	jalr	1204(ra) # 57ea <exit>
      printf("OK\n");
    533e:	00003517          	auipc	a0,0x3
    5342:	bba50513          	addi	a0,a0,-1094 # 7ef8 <malloc+0x22c0>
    5346:	00001097          	auipc	ra,0x1
    534a:	834080e7          	jalr	-1996(ra) # 5b7a <printf>
    534e:	bf55                	j	5302 <run+0x50>

0000000000005350 <main>:

int
main(int argc, char *argv[])
{
    5350:	d4010113          	addi	sp,sp,-704
    5354:	2a113c23          	sd	ra,696(sp)
    5358:	2a813823          	sd	s0,688(sp)
    535c:	2a913423          	sd	s1,680(sp)
    5360:	2b213023          	sd	s2,672(sp)
    5364:	29313c23          	sd	s3,664(sp)
    5368:	29413823          	sd	s4,656(sp)
    536c:	29513423          	sd	s5,648(sp)
    5370:	29613023          	sd	s6,640(sp)
    5374:	0580                	addi	s0,sp,704
    5376:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5378:	4789                	li	a5,2
    537a:	08f50763          	beq	a0,a5,5408 <main+0xb8>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    537e:	4785                	li	a5,1
  char *justone = 0;
    5380:	4901                	li	s2,0
  } else if(argc > 1){
    5382:	0ca7c163          	blt	a5,a0,5444 <main+0xf4>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    5386:	00003797          	auipc	a5,0x3
    538a:	c8a78793          	addi	a5,a5,-886 # 8010 <malloc+0x23d8>
    538e:	d4040713          	addi	a4,s0,-704
    5392:	00003817          	auipc	a6,0x3
    5396:	efe80813          	addi	a6,a6,-258 # 8290 <malloc+0x2658>
    539a:	6388                	ld	a0,0(a5)
    539c:	678c                	ld	a1,8(a5)
    539e:	6b90                	ld	a2,16(a5)
    53a0:	6f94                	ld	a3,24(a5)
    53a2:	e308                	sd	a0,0(a4)
    53a4:	e70c                	sd	a1,8(a4)
    53a6:	eb10                	sd	a2,16(a4)
    53a8:	ef14                	sd	a3,24(a4)
    53aa:	02078793          	addi	a5,a5,32
    53ae:	02070713          	addi	a4,a4,32
    53b2:	ff0794e3          	bne	a5,a6,539a <main+0x4a>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    53b6:	00003517          	auipc	a0,0x3
    53ba:	bfa50513          	addi	a0,a0,-1030 # 7fb0 <malloc+0x2378>
    53be:	00000097          	auipc	ra,0x0
    53c2:	7bc080e7          	jalr	1980(ra) # 5b7a <printf>
  int free0 = countfree();
    53c6:	00000097          	auipc	ra,0x0
    53ca:	dbc080e7          	jalr	-580(ra) # 5182 <countfree>
    53ce:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    53d0:	d4843503          	ld	a0,-696(s0)
    53d4:	d4040493          	addi	s1,s0,-704
  int fail = 0;
    53d8:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    53da:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    53dc:	e55d                	bnez	a0,548a <main+0x13a>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    53de:	00000097          	auipc	ra,0x0
    53e2:	da4080e7          	jalr	-604(ra) # 5182 <countfree>
    53e6:	85aa                	mv	a1,a0
    53e8:	0f455163          	bge	a0,s4,54ca <main+0x17a>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    53ec:	8652                	mv	a2,s4
    53ee:	00003517          	auipc	a0,0x3
    53f2:	b7a50513          	addi	a0,a0,-1158 # 7f68 <malloc+0x2330>
    53f6:	00000097          	auipc	ra,0x0
    53fa:	784080e7          	jalr	1924(ra) # 5b7a <printf>
    exit(1);
    53fe:	4505                	li	a0,1
    5400:	00000097          	auipc	ra,0x0
    5404:	3ea080e7          	jalr	1002(ra) # 57ea <exit>
    5408:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    540a:	00003597          	auipc	a1,0x3
    540e:	af658593          	addi	a1,a1,-1290 # 7f00 <malloc+0x22c8>
    5412:	6488                	ld	a0,8(s1)
    5414:	00000097          	auipc	ra,0x0
    5418:	184080e7          	jalr	388(ra) # 5598 <strcmp>
    541c:	10050563          	beqz	a0,5526 <main+0x1d6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5420:	00003597          	auipc	a1,0x3
    5424:	bc858593          	addi	a1,a1,-1080 # 7fe8 <malloc+0x23b0>
    5428:	6488                	ld	a0,8(s1)
    542a:	00000097          	auipc	ra,0x0
    542e:	16e080e7          	jalr	366(ra) # 5598 <strcmp>
    5432:	c97d                	beqz	a0,5528 <main+0x1d8>
  } else if(argc == 2 && argv[1][0] != '-'){
    5434:	0084b903          	ld	s2,8(s1)
    5438:	00094703          	lbu	a4,0(s2)
    543c:	02d00793          	li	a5,45
    5440:	f4f713e3          	bne	a4,a5,5386 <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    5444:	00003517          	auipc	a0,0x3
    5448:	ac450513          	addi	a0,a0,-1340 # 7f08 <malloc+0x22d0>
    544c:	00000097          	auipc	ra,0x0
    5450:	72e080e7          	jalr	1838(ra) # 5b7a <printf>
    exit(1);
    5454:	4505                	li	a0,1
    5456:	00000097          	auipc	ra,0x0
    545a:	394080e7          	jalr	916(ra) # 57ea <exit>
          exit(1);
    545e:	4505                	li	a0,1
    5460:	00000097          	auipc	ra,0x0
    5464:	38a080e7          	jalr	906(ra) # 57ea <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5468:	40a905bb          	subw	a1,s2,a0
    546c:	855a                	mv	a0,s6
    546e:	00000097          	auipc	ra,0x0
    5472:	70c080e7          	jalr	1804(ra) # 5b7a <printf>
        if(continuous != 2)
    5476:	09498463          	beq	s3,s4,54fe <main+0x1ae>
          exit(1);
    547a:	4505                	li	a0,1
    547c:	00000097          	auipc	ra,0x0
    5480:	36e080e7          	jalr	878(ra) # 57ea <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    5484:	04c1                	addi	s1,s1,16
    5486:	6488                	ld	a0,8(s1)
    5488:	c115                	beqz	a0,54ac <main+0x15c>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    548a:	00090863          	beqz	s2,549a <main+0x14a>
    548e:	85ca                	mv	a1,s2
    5490:	00000097          	auipc	ra,0x0
    5494:	108080e7          	jalr	264(ra) # 5598 <strcmp>
    5498:	f575                	bnez	a0,5484 <main+0x134>
      if(!run(t->f, t->s))
    549a:	648c                	ld	a1,8(s1)
    549c:	6088                	ld	a0,0(s1)
    549e:	00000097          	auipc	ra,0x0
    54a2:	e14080e7          	jalr	-492(ra) # 52b2 <run>
    54a6:	fd79                	bnez	a0,5484 <main+0x134>
        fail = 1;
    54a8:	89d6                	mv	s3,s5
    54aa:	bfe9                	j	5484 <main+0x134>
  if(fail){
    54ac:	f20989e3          	beqz	s3,53de <main+0x8e>
    printf("SOME TESTS FAILED\n");
    54b0:	00003517          	auipc	a0,0x3
    54b4:	aa050513          	addi	a0,a0,-1376 # 7f50 <malloc+0x2318>
    54b8:	00000097          	auipc	ra,0x0
    54bc:	6c2080e7          	jalr	1730(ra) # 5b7a <printf>
    exit(1);
    54c0:	4505                	li	a0,1
    54c2:	00000097          	auipc	ra,0x0
    54c6:	328080e7          	jalr	808(ra) # 57ea <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    54ca:	00003517          	auipc	a0,0x3
    54ce:	ace50513          	addi	a0,a0,-1330 # 7f98 <malloc+0x2360>
    54d2:	00000097          	auipc	ra,0x0
    54d6:	6a8080e7          	jalr	1704(ra) # 5b7a <printf>
    exit(0);
    54da:	4501                	li	a0,0
    54dc:	00000097          	auipc	ra,0x0
    54e0:	30e080e7          	jalr	782(ra) # 57ea <exit>
        printf("SOME TESTS FAILED\n");
    54e4:	8556                	mv	a0,s5
    54e6:	00000097          	auipc	ra,0x0
    54ea:	694080e7          	jalr	1684(ra) # 5b7a <printf>
        if(continuous != 2)
    54ee:	f74998e3          	bne	s3,s4,545e <main+0x10e>
      int free1 = countfree();
    54f2:	00000097          	auipc	ra,0x0
    54f6:	c90080e7          	jalr	-880(ra) # 5182 <countfree>
      if(free1 < free0){
    54fa:	f72547e3          	blt	a0,s2,5468 <main+0x118>
      int free0 = countfree();
    54fe:	00000097          	auipc	ra,0x0
    5502:	c84080e7          	jalr	-892(ra) # 5182 <countfree>
    5506:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5508:	d4843583          	ld	a1,-696(s0)
    550c:	d1fd                	beqz	a1,54f2 <main+0x1a2>
    550e:	d4040493          	addi	s1,s0,-704
        if(!run(t->f, t->s)){
    5512:	6088                	ld	a0,0(s1)
    5514:	00000097          	auipc	ra,0x0
    5518:	d9e080e7          	jalr	-610(ra) # 52b2 <run>
    551c:	d561                	beqz	a0,54e4 <main+0x194>
      for (struct test *t = tests; t->s != 0; t++) {
    551e:	04c1                	addi	s1,s1,16
    5520:	648c                	ld	a1,8(s1)
    5522:	f9e5                	bnez	a1,5512 <main+0x1c2>
    5524:	b7f9                	j	54f2 <main+0x1a2>
    continuous = 1;
    5526:	4985                	li	s3,1
  } tests[] = {
    5528:	00003797          	auipc	a5,0x3
    552c:	ae878793          	addi	a5,a5,-1304 # 8010 <malloc+0x23d8>
    5530:	d4040713          	addi	a4,s0,-704
    5534:	00003817          	auipc	a6,0x3
    5538:	d5c80813          	addi	a6,a6,-676 # 8290 <malloc+0x2658>
    553c:	6388                	ld	a0,0(a5)
    553e:	678c                	ld	a1,8(a5)
    5540:	6b90                	ld	a2,16(a5)
    5542:	6f94                	ld	a3,24(a5)
    5544:	e308                	sd	a0,0(a4)
    5546:	e70c                	sd	a1,8(a4)
    5548:	eb10                	sd	a2,16(a4)
    554a:	ef14                	sd	a3,24(a4)
    554c:	02078793          	addi	a5,a5,32
    5550:	02070713          	addi	a4,a4,32
    5554:	ff0794e3          	bne	a5,a6,553c <main+0x1ec>
    printf("continuous usertests starting\n");
    5558:	00003517          	auipc	a0,0x3
    555c:	a7050513          	addi	a0,a0,-1424 # 7fc8 <malloc+0x2390>
    5560:	00000097          	auipc	ra,0x0
    5564:	61a080e7          	jalr	1562(ra) # 5b7a <printf>
        printf("SOME TESTS FAILED\n");
    5568:	00003a97          	auipc	s5,0x3
    556c:	9e8a8a93          	addi	s5,s5,-1560 # 7f50 <malloc+0x2318>
        if(continuous != 2)
    5570:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5572:	00003b17          	auipc	s6,0x3
    5576:	9beb0b13          	addi	s6,s6,-1602 # 7f30 <malloc+0x22f8>
    557a:	b751                	j	54fe <main+0x1ae>

000000000000557c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    557c:	1141                	addi	sp,sp,-16
    557e:	e422                	sd	s0,8(sp)
    5580:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5582:	87aa                	mv	a5,a0
    5584:	0585                	addi	a1,a1,1
    5586:	0785                	addi	a5,a5,1
    5588:	fff5c703          	lbu	a4,-1(a1)
    558c:	fee78fa3          	sb	a4,-1(a5)
    5590:	fb75                	bnez	a4,5584 <strcpy+0x8>
    ;
  return os;
}
    5592:	6422                	ld	s0,8(sp)
    5594:	0141                	addi	sp,sp,16
    5596:	8082                	ret

0000000000005598 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5598:	1141                	addi	sp,sp,-16
    559a:	e422                	sd	s0,8(sp)
    559c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    559e:	00054783          	lbu	a5,0(a0)
    55a2:	cb91                	beqz	a5,55b6 <strcmp+0x1e>
    55a4:	0005c703          	lbu	a4,0(a1)
    55a8:	00f71763          	bne	a4,a5,55b6 <strcmp+0x1e>
    p++, q++;
    55ac:	0505                	addi	a0,a0,1
    55ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    55b0:	00054783          	lbu	a5,0(a0)
    55b4:	fbe5                	bnez	a5,55a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    55b6:	0005c503          	lbu	a0,0(a1)
}
    55ba:	40a7853b          	subw	a0,a5,a0
    55be:	6422                	ld	s0,8(sp)
    55c0:	0141                	addi	sp,sp,16
    55c2:	8082                	ret

00000000000055c4 <strlen>:

uint
strlen(const char *s)
{
    55c4:	1141                	addi	sp,sp,-16
    55c6:	e422                	sd	s0,8(sp)
    55c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    55ca:	00054783          	lbu	a5,0(a0)
    55ce:	cf91                	beqz	a5,55ea <strlen+0x26>
    55d0:	0505                	addi	a0,a0,1
    55d2:	87aa                	mv	a5,a0
    55d4:	4685                	li	a3,1
    55d6:	9e89                	subw	a3,a3,a0
    55d8:	00f6853b          	addw	a0,a3,a5
    55dc:	0785                	addi	a5,a5,1
    55de:	fff7c703          	lbu	a4,-1(a5)
    55e2:	fb7d                	bnez	a4,55d8 <strlen+0x14>
    ;
  return n;
}
    55e4:	6422                	ld	s0,8(sp)
    55e6:	0141                	addi	sp,sp,16
    55e8:	8082                	ret
  for(n = 0; s[n]; n++)
    55ea:	4501                	li	a0,0
    55ec:	bfe5                	j	55e4 <strlen+0x20>

00000000000055ee <memset>:

void*
memset(void *dst, int c, uint n)
{
    55ee:	1141                	addi	sp,sp,-16
    55f0:	e422                	sd	s0,8(sp)
    55f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    55f4:	ca19                	beqz	a2,560a <memset+0x1c>
    55f6:	87aa                	mv	a5,a0
    55f8:	1602                	slli	a2,a2,0x20
    55fa:	9201                	srli	a2,a2,0x20
    55fc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    5600:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5604:	0785                	addi	a5,a5,1
    5606:	fee79de3          	bne	a5,a4,5600 <memset+0x12>
  }
  return dst;
}
    560a:	6422                	ld	s0,8(sp)
    560c:	0141                	addi	sp,sp,16
    560e:	8082                	ret

0000000000005610 <strchr>:

char*
strchr(const char *s, char c)
{
    5610:	1141                	addi	sp,sp,-16
    5612:	e422                	sd	s0,8(sp)
    5614:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5616:	00054783          	lbu	a5,0(a0)
    561a:	cb99                	beqz	a5,5630 <strchr+0x20>
    if(*s == c)
    561c:	00f58763          	beq	a1,a5,562a <strchr+0x1a>
  for(; *s; s++)
    5620:	0505                	addi	a0,a0,1
    5622:	00054783          	lbu	a5,0(a0)
    5626:	fbfd                	bnez	a5,561c <strchr+0xc>
      return (char*)s;
  return 0;
    5628:	4501                	li	a0,0
}
    562a:	6422                	ld	s0,8(sp)
    562c:	0141                	addi	sp,sp,16
    562e:	8082                	ret
  return 0;
    5630:	4501                	li	a0,0
    5632:	bfe5                	j	562a <strchr+0x1a>

0000000000005634 <gets>:

char*
gets(char *buf, int max)
{
    5634:	711d                	addi	sp,sp,-96
    5636:	ec86                	sd	ra,88(sp)
    5638:	e8a2                	sd	s0,80(sp)
    563a:	e4a6                	sd	s1,72(sp)
    563c:	e0ca                	sd	s2,64(sp)
    563e:	fc4e                	sd	s3,56(sp)
    5640:	f852                	sd	s4,48(sp)
    5642:	f456                	sd	s5,40(sp)
    5644:	f05a                	sd	s6,32(sp)
    5646:	ec5e                	sd	s7,24(sp)
    5648:	1080                	addi	s0,sp,96
    564a:	8baa                	mv	s7,a0
    564c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    564e:	892a                	mv	s2,a0
    5650:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5652:	4aa9                	li	s5,10
    5654:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5656:	89a6                	mv	s3,s1
    5658:	2485                	addiw	s1,s1,1
    565a:	0344d863          	bge	s1,s4,568a <gets+0x56>
    cc = read(0, &c, 1);
    565e:	4605                	li	a2,1
    5660:	faf40593          	addi	a1,s0,-81
    5664:	4501                	li	a0,0
    5666:	00000097          	auipc	ra,0x0
    566a:	19c080e7          	jalr	412(ra) # 5802 <read>
    if(cc < 1)
    566e:	00a05e63          	blez	a0,568a <gets+0x56>
    buf[i++] = c;
    5672:	faf44783          	lbu	a5,-81(s0)
    5676:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    567a:	01578763          	beq	a5,s5,5688 <gets+0x54>
    567e:	0905                	addi	s2,s2,1
    5680:	fd679be3          	bne	a5,s6,5656 <gets+0x22>
  for(i=0; i+1 < max; ){
    5684:	89a6                	mv	s3,s1
    5686:	a011                	j	568a <gets+0x56>
    5688:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    568a:	99de                	add	s3,s3,s7
    568c:	00098023          	sb	zero,0(s3)
  return buf;
}
    5690:	855e                	mv	a0,s7
    5692:	60e6                	ld	ra,88(sp)
    5694:	6446                	ld	s0,80(sp)
    5696:	64a6                	ld	s1,72(sp)
    5698:	6906                	ld	s2,64(sp)
    569a:	79e2                	ld	s3,56(sp)
    569c:	7a42                	ld	s4,48(sp)
    569e:	7aa2                	ld	s5,40(sp)
    56a0:	7b02                	ld	s6,32(sp)
    56a2:	6be2                	ld	s7,24(sp)
    56a4:	6125                	addi	sp,sp,96
    56a6:	8082                	ret

00000000000056a8 <stat>:

int
stat(const char *n, struct stat *st)
{
    56a8:	1101                	addi	sp,sp,-32
    56aa:	ec06                	sd	ra,24(sp)
    56ac:	e822                	sd	s0,16(sp)
    56ae:	e426                	sd	s1,8(sp)
    56b0:	e04a                	sd	s2,0(sp)
    56b2:	1000                	addi	s0,sp,32
    56b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    56b6:	4581                	li	a1,0
    56b8:	00000097          	auipc	ra,0x0
    56bc:	172080e7          	jalr	370(ra) # 582a <open>
  if(fd < 0)
    56c0:	02054563          	bltz	a0,56ea <stat+0x42>
    56c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    56c6:	85ca                	mv	a1,s2
    56c8:	00000097          	auipc	ra,0x0
    56cc:	17a080e7          	jalr	378(ra) # 5842 <fstat>
    56d0:	892a                	mv	s2,a0
  close(fd);
    56d2:	8526                	mv	a0,s1
    56d4:	00000097          	auipc	ra,0x0
    56d8:	13e080e7          	jalr	318(ra) # 5812 <close>
  return r;
}
    56dc:	854a                	mv	a0,s2
    56de:	60e2                	ld	ra,24(sp)
    56e0:	6442                	ld	s0,16(sp)
    56e2:	64a2                	ld	s1,8(sp)
    56e4:	6902                	ld	s2,0(sp)
    56e6:	6105                	addi	sp,sp,32
    56e8:	8082                	ret
    return -1;
    56ea:	597d                	li	s2,-1
    56ec:	bfc5                	j	56dc <stat+0x34>

00000000000056ee <atoi>:

int
atoi(const char *s)
{
    56ee:	1141                	addi	sp,sp,-16
    56f0:	e422                	sd	s0,8(sp)
    56f2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    56f4:	00054603          	lbu	a2,0(a0)
    56f8:	fd06079b          	addiw	a5,a2,-48
    56fc:	0ff7f793          	andi	a5,a5,255
    5700:	4725                	li	a4,9
    5702:	02f76963          	bltu	a4,a5,5734 <atoi+0x46>
    5706:	86aa                	mv	a3,a0
  n = 0;
    5708:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    570a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    570c:	0685                	addi	a3,a3,1
    570e:	0025179b          	slliw	a5,a0,0x2
    5712:	9fa9                	addw	a5,a5,a0
    5714:	0017979b          	slliw	a5,a5,0x1
    5718:	9fb1                	addw	a5,a5,a2
    571a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    571e:	0006c603          	lbu	a2,0(a3)
    5722:	fd06071b          	addiw	a4,a2,-48
    5726:	0ff77713          	andi	a4,a4,255
    572a:	fee5f1e3          	bgeu	a1,a4,570c <atoi+0x1e>
  return n;
}
    572e:	6422                	ld	s0,8(sp)
    5730:	0141                	addi	sp,sp,16
    5732:	8082                	ret
  n = 0;
    5734:	4501                	li	a0,0
    5736:	bfe5                	j	572e <atoi+0x40>

0000000000005738 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5738:	1141                	addi	sp,sp,-16
    573a:	e422                	sd	s0,8(sp)
    573c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    573e:	02b57463          	bgeu	a0,a1,5766 <memmove+0x2e>
    while(n-- > 0)
    5742:	00c05f63          	blez	a2,5760 <memmove+0x28>
    5746:	1602                	slli	a2,a2,0x20
    5748:	9201                	srli	a2,a2,0x20
    574a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    574e:	872a                	mv	a4,a0
      *dst++ = *src++;
    5750:	0585                	addi	a1,a1,1
    5752:	0705                	addi	a4,a4,1
    5754:	fff5c683          	lbu	a3,-1(a1)
    5758:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    575c:	fee79ae3          	bne	a5,a4,5750 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5760:	6422                	ld	s0,8(sp)
    5762:	0141                	addi	sp,sp,16
    5764:	8082                	ret
    dst += n;
    5766:	00c50733          	add	a4,a0,a2
    src += n;
    576a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    576c:	fec05ae3          	blez	a2,5760 <memmove+0x28>
    5770:	fff6079b          	addiw	a5,a2,-1
    5774:	1782                	slli	a5,a5,0x20
    5776:	9381                	srli	a5,a5,0x20
    5778:	fff7c793          	not	a5,a5
    577c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    577e:	15fd                	addi	a1,a1,-1
    5780:	177d                	addi	a4,a4,-1
    5782:	0005c683          	lbu	a3,0(a1)
    5786:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    578a:	fee79ae3          	bne	a5,a4,577e <memmove+0x46>
    578e:	bfc9                	j	5760 <memmove+0x28>

0000000000005790 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5790:	1141                	addi	sp,sp,-16
    5792:	e422                	sd	s0,8(sp)
    5794:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5796:	ca05                	beqz	a2,57c6 <memcmp+0x36>
    5798:	fff6069b          	addiw	a3,a2,-1
    579c:	1682                	slli	a3,a3,0x20
    579e:	9281                	srli	a3,a3,0x20
    57a0:	0685                	addi	a3,a3,1
    57a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    57a4:	00054783          	lbu	a5,0(a0)
    57a8:	0005c703          	lbu	a4,0(a1)
    57ac:	00e79863          	bne	a5,a4,57bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    57b0:	0505                	addi	a0,a0,1
    p2++;
    57b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    57b4:	fed518e3          	bne	a0,a3,57a4 <memcmp+0x14>
  }
  return 0;
    57b8:	4501                	li	a0,0
    57ba:	a019                	j	57c0 <memcmp+0x30>
      return *p1 - *p2;
    57bc:	40e7853b          	subw	a0,a5,a4
}
    57c0:	6422                	ld	s0,8(sp)
    57c2:	0141                	addi	sp,sp,16
    57c4:	8082                	ret
  return 0;
    57c6:	4501                	li	a0,0
    57c8:	bfe5                	j	57c0 <memcmp+0x30>

00000000000057ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    57ca:	1141                	addi	sp,sp,-16
    57cc:	e406                	sd	ra,8(sp)
    57ce:	e022                	sd	s0,0(sp)
    57d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    57d2:	00000097          	auipc	ra,0x0
    57d6:	f66080e7          	jalr	-154(ra) # 5738 <memmove>
}
    57da:	60a2                	ld	ra,8(sp)
    57dc:	6402                	ld	s0,0(sp)
    57de:	0141                	addi	sp,sp,16
    57e0:	8082                	ret

00000000000057e2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    57e2:	4885                	li	a7,1
 ecall
    57e4:	00000073          	ecall
 ret
    57e8:	8082                	ret

00000000000057ea <exit>:
.global exit
exit:
 li a7, SYS_exit
    57ea:	4889                	li	a7,2
 ecall
    57ec:	00000073          	ecall
 ret
    57f0:	8082                	ret

00000000000057f2 <wait>:
.global wait
wait:
 li a7, SYS_wait
    57f2:	488d                	li	a7,3
 ecall
    57f4:	00000073          	ecall
 ret
    57f8:	8082                	ret

00000000000057fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    57fa:	4891                	li	a7,4
 ecall
    57fc:	00000073          	ecall
 ret
    5800:	8082                	ret

0000000000005802 <read>:
.global read
read:
 li a7, SYS_read
    5802:	4895                	li	a7,5
 ecall
    5804:	00000073          	ecall
 ret
    5808:	8082                	ret

000000000000580a <write>:
.global write
write:
 li a7, SYS_write
    580a:	48c1                	li	a7,16
 ecall
    580c:	00000073          	ecall
 ret
    5810:	8082                	ret

0000000000005812 <close>:
.global close
close:
 li a7, SYS_close
    5812:	48d5                	li	a7,21
 ecall
    5814:	00000073          	ecall
 ret
    5818:	8082                	ret

000000000000581a <kill>:
.global kill
kill:
 li a7, SYS_kill
    581a:	4899                	li	a7,6
 ecall
    581c:	00000073          	ecall
 ret
    5820:	8082                	ret

0000000000005822 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5822:	489d                	li	a7,7
 ecall
    5824:	00000073          	ecall
 ret
    5828:	8082                	ret

000000000000582a <open>:
.global open
open:
 li a7, SYS_open
    582a:	48bd                	li	a7,15
 ecall
    582c:	00000073          	ecall
 ret
    5830:	8082                	ret

0000000000005832 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5832:	48c5                	li	a7,17
 ecall
    5834:	00000073          	ecall
 ret
    5838:	8082                	ret

000000000000583a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    583a:	48c9                	li	a7,18
 ecall
    583c:	00000073          	ecall
 ret
    5840:	8082                	ret

0000000000005842 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5842:	48a1                	li	a7,8
 ecall
    5844:	00000073          	ecall
 ret
    5848:	8082                	ret

000000000000584a <link>:
.global link
link:
 li a7, SYS_link
    584a:	48cd                	li	a7,19
 ecall
    584c:	00000073          	ecall
 ret
    5850:	8082                	ret

0000000000005852 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5852:	48d1                	li	a7,20
 ecall
    5854:	00000073          	ecall
 ret
    5858:	8082                	ret

000000000000585a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    585a:	48a5                	li	a7,9
 ecall
    585c:	00000073          	ecall
 ret
    5860:	8082                	ret

0000000000005862 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5862:	48a9                	li	a7,10
 ecall
    5864:	00000073          	ecall
 ret
    5868:	8082                	ret

000000000000586a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    586a:	48ad                	li	a7,11
 ecall
    586c:	00000073          	ecall
 ret
    5870:	8082                	ret

0000000000005872 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5872:	48b1                	li	a7,12
 ecall
    5874:	00000073          	ecall
 ret
    5878:	8082                	ret

000000000000587a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    587a:	48b5                	li	a7,13
 ecall
    587c:	00000073          	ecall
 ret
    5880:	8082                	ret

0000000000005882 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5882:	48b9                	li	a7,14
 ecall
    5884:	00000073          	ecall
 ret
    5888:	8082                	ret

000000000000588a <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
    588a:	48d9                	li	a7,22
 ecall
    588c:	00000073          	ecall
 ret
    5890:	8082                	ret

0000000000005892 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
    5892:	48dd                	li	a7,23
 ecall
    5894:	00000073          	ecall
 ret
    5898:	8082                	ret

000000000000589a <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
    589a:	48e1                	li	a7,24
 ecall
    589c:	00000073          	ecall
 ret
    58a0:	8082                	ret

00000000000058a2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    58a2:	1101                	addi	sp,sp,-32
    58a4:	ec06                	sd	ra,24(sp)
    58a6:	e822                	sd	s0,16(sp)
    58a8:	1000                	addi	s0,sp,32
    58aa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    58ae:	4605                	li	a2,1
    58b0:	fef40593          	addi	a1,s0,-17
    58b4:	00000097          	auipc	ra,0x0
    58b8:	f56080e7          	jalr	-170(ra) # 580a <write>
}
    58bc:	60e2                	ld	ra,24(sp)
    58be:	6442                	ld	s0,16(sp)
    58c0:	6105                	addi	sp,sp,32
    58c2:	8082                	ret

00000000000058c4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    58c4:	7139                	addi	sp,sp,-64
    58c6:	fc06                	sd	ra,56(sp)
    58c8:	f822                	sd	s0,48(sp)
    58ca:	f426                	sd	s1,40(sp)
    58cc:	f04a                	sd	s2,32(sp)
    58ce:	ec4e                	sd	s3,24(sp)
    58d0:	0080                	addi	s0,sp,64
    58d2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    58d4:	c299                	beqz	a3,58da <printint+0x16>
    58d6:	0805c863          	bltz	a1,5966 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    58da:	2581                	sext.w	a1,a1
  neg = 0;
    58dc:	4881                	li	a7,0
    58de:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    58e2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    58e4:	2601                	sext.w	a2,a2
    58e6:	00003517          	auipc	a0,0x3
    58ea:	9b250513          	addi	a0,a0,-1614 # 8298 <digits>
    58ee:	883a                	mv	a6,a4
    58f0:	2705                	addiw	a4,a4,1
    58f2:	02c5f7bb          	remuw	a5,a1,a2
    58f6:	1782                	slli	a5,a5,0x20
    58f8:	9381                	srli	a5,a5,0x20
    58fa:	97aa                	add	a5,a5,a0
    58fc:	0007c783          	lbu	a5,0(a5)
    5900:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5904:	0005879b          	sext.w	a5,a1
    5908:	02c5d5bb          	divuw	a1,a1,a2
    590c:	0685                	addi	a3,a3,1
    590e:	fec7f0e3          	bgeu	a5,a2,58ee <printint+0x2a>
  if(neg)
    5912:	00088b63          	beqz	a7,5928 <printint+0x64>
    buf[i++] = '-';
    5916:	fd040793          	addi	a5,s0,-48
    591a:	973e                	add	a4,a4,a5
    591c:	02d00793          	li	a5,45
    5920:	fef70823          	sb	a5,-16(a4)
    5924:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5928:	02e05863          	blez	a4,5958 <printint+0x94>
    592c:	fc040793          	addi	a5,s0,-64
    5930:	00e78933          	add	s2,a5,a4
    5934:	fff78993          	addi	s3,a5,-1
    5938:	99ba                	add	s3,s3,a4
    593a:	377d                	addiw	a4,a4,-1
    593c:	1702                	slli	a4,a4,0x20
    593e:	9301                	srli	a4,a4,0x20
    5940:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5944:	fff94583          	lbu	a1,-1(s2)
    5948:	8526                	mv	a0,s1
    594a:	00000097          	auipc	ra,0x0
    594e:	f58080e7          	jalr	-168(ra) # 58a2 <putc>
  while(--i >= 0)
    5952:	197d                	addi	s2,s2,-1
    5954:	ff3918e3          	bne	s2,s3,5944 <printint+0x80>
}
    5958:	70e2                	ld	ra,56(sp)
    595a:	7442                	ld	s0,48(sp)
    595c:	74a2                	ld	s1,40(sp)
    595e:	7902                	ld	s2,32(sp)
    5960:	69e2                	ld	s3,24(sp)
    5962:	6121                	addi	sp,sp,64
    5964:	8082                	ret
    x = -xx;
    5966:	40b005bb          	negw	a1,a1
    neg = 1;
    596a:	4885                	li	a7,1
    x = -xx;
    596c:	bf8d                	j	58de <printint+0x1a>

000000000000596e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    596e:	7119                	addi	sp,sp,-128
    5970:	fc86                	sd	ra,120(sp)
    5972:	f8a2                	sd	s0,112(sp)
    5974:	f4a6                	sd	s1,104(sp)
    5976:	f0ca                	sd	s2,96(sp)
    5978:	ecce                	sd	s3,88(sp)
    597a:	e8d2                	sd	s4,80(sp)
    597c:	e4d6                	sd	s5,72(sp)
    597e:	e0da                	sd	s6,64(sp)
    5980:	fc5e                	sd	s7,56(sp)
    5982:	f862                	sd	s8,48(sp)
    5984:	f466                	sd	s9,40(sp)
    5986:	f06a                	sd	s10,32(sp)
    5988:	ec6e                	sd	s11,24(sp)
    598a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    598c:	0005c903          	lbu	s2,0(a1)
    5990:	18090f63          	beqz	s2,5b2e <vprintf+0x1c0>
    5994:	8aaa                	mv	s5,a0
    5996:	8b32                	mv	s6,a2
    5998:	00158493          	addi	s1,a1,1
  state = 0;
    599c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    599e:	02500a13          	li	s4,37
      if(c == 'd'){
    59a2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    59a6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    59aa:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    59ae:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    59b2:	00003b97          	auipc	s7,0x3
    59b6:	8e6b8b93          	addi	s7,s7,-1818 # 8298 <digits>
    59ba:	a839                	j	59d8 <vprintf+0x6a>
        putc(fd, c);
    59bc:	85ca                	mv	a1,s2
    59be:	8556                	mv	a0,s5
    59c0:	00000097          	auipc	ra,0x0
    59c4:	ee2080e7          	jalr	-286(ra) # 58a2 <putc>
    59c8:	a019                	j	59ce <vprintf+0x60>
    } else if(state == '%'){
    59ca:	01498f63          	beq	s3,s4,59e8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    59ce:	0485                	addi	s1,s1,1
    59d0:	fff4c903          	lbu	s2,-1(s1)
    59d4:	14090d63          	beqz	s2,5b2e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    59d8:	0009079b          	sext.w	a5,s2
    if(state == 0){
    59dc:	fe0997e3          	bnez	s3,59ca <vprintf+0x5c>
      if(c == '%'){
    59e0:	fd479ee3          	bne	a5,s4,59bc <vprintf+0x4e>
        state = '%';
    59e4:	89be                	mv	s3,a5
    59e6:	b7e5                	j	59ce <vprintf+0x60>
      if(c == 'd'){
    59e8:	05878063          	beq	a5,s8,5a28 <vprintf+0xba>
      } else if(c == 'l') {
    59ec:	05978c63          	beq	a5,s9,5a44 <vprintf+0xd6>
      } else if(c == 'x') {
    59f0:	07a78863          	beq	a5,s10,5a60 <vprintf+0xf2>
      } else if(c == 'p') {
    59f4:	09b78463          	beq	a5,s11,5a7c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    59f8:	07300713          	li	a4,115
    59fc:	0ce78663          	beq	a5,a4,5ac8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5a00:	06300713          	li	a4,99
    5a04:	0ee78e63          	beq	a5,a4,5b00 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5a08:	11478863          	beq	a5,s4,5b18 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5a0c:	85d2                	mv	a1,s4
    5a0e:	8556                	mv	a0,s5
    5a10:	00000097          	auipc	ra,0x0
    5a14:	e92080e7          	jalr	-366(ra) # 58a2 <putc>
        putc(fd, c);
    5a18:	85ca                	mv	a1,s2
    5a1a:	8556                	mv	a0,s5
    5a1c:	00000097          	auipc	ra,0x0
    5a20:	e86080e7          	jalr	-378(ra) # 58a2 <putc>
      }
      state = 0;
    5a24:	4981                	li	s3,0
    5a26:	b765                	j	59ce <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5a28:	008b0913          	addi	s2,s6,8
    5a2c:	4685                	li	a3,1
    5a2e:	4629                	li	a2,10
    5a30:	000b2583          	lw	a1,0(s6)
    5a34:	8556                	mv	a0,s5
    5a36:	00000097          	auipc	ra,0x0
    5a3a:	e8e080e7          	jalr	-370(ra) # 58c4 <printint>
    5a3e:	8b4a                	mv	s6,s2
      state = 0;
    5a40:	4981                	li	s3,0
    5a42:	b771                	j	59ce <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5a44:	008b0913          	addi	s2,s6,8
    5a48:	4681                	li	a3,0
    5a4a:	4629                	li	a2,10
    5a4c:	000b2583          	lw	a1,0(s6)
    5a50:	8556                	mv	a0,s5
    5a52:	00000097          	auipc	ra,0x0
    5a56:	e72080e7          	jalr	-398(ra) # 58c4 <printint>
    5a5a:	8b4a                	mv	s6,s2
      state = 0;
    5a5c:	4981                	li	s3,0
    5a5e:	bf85                	j	59ce <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5a60:	008b0913          	addi	s2,s6,8
    5a64:	4681                	li	a3,0
    5a66:	4641                	li	a2,16
    5a68:	000b2583          	lw	a1,0(s6)
    5a6c:	8556                	mv	a0,s5
    5a6e:	00000097          	auipc	ra,0x0
    5a72:	e56080e7          	jalr	-426(ra) # 58c4 <printint>
    5a76:	8b4a                	mv	s6,s2
      state = 0;
    5a78:	4981                	li	s3,0
    5a7a:	bf91                	j	59ce <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5a7c:	008b0793          	addi	a5,s6,8
    5a80:	f8f43423          	sd	a5,-120(s0)
    5a84:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5a88:	03000593          	li	a1,48
    5a8c:	8556                	mv	a0,s5
    5a8e:	00000097          	auipc	ra,0x0
    5a92:	e14080e7          	jalr	-492(ra) # 58a2 <putc>
  putc(fd, 'x');
    5a96:	85ea                	mv	a1,s10
    5a98:	8556                	mv	a0,s5
    5a9a:	00000097          	auipc	ra,0x0
    5a9e:	e08080e7          	jalr	-504(ra) # 58a2 <putc>
    5aa2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5aa4:	03c9d793          	srli	a5,s3,0x3c
    5aa8:	97de                	add	a5,a5,s7
    5aaa:	0007c583          	lbu	a1,0(a5)
    5aae:	8556                	mv	a0,s5
    5ab0:	00000097          	auipc	ra,0x0
    5ab4:	df2080e7          	jalr	-526(ra) # 58a2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5ab8:	0992                	slli	s3,s3,0x4
    5aba:	397d                	addiw	s2,s2,-1
    5abc:	fe0914e3          	bnez	s2,5aa4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5ac0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5ac4:	4981                	li	s3,0
    5ac6:	b721                	j	59ce <vprintf+0x60>
        s = va_arg(ap, char*);
    5ac8:	008b0993          	addi	s3,s6,8
    5acc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5ad0:	02090163          	beqz	s2,5af2 <vprintf+0x184>
        while(*s != 0){
    5ad4:	00094583          	lbu	a1,0(s2)
    5ad8:	c9a1                	beqz	a1,5b28 <vprintf+0x1ba>
          putc(fd, *s);
    5ada:	8556                	mv	a0,s5
    5adc:	00000097          	auipc	ra,0x0
    5ae0:	dc6080e7          	jalr	-570(ra) # 58a2 <putc>
          s++;
    5ae4:	0905                	addi	s2,s2,1
        while(*s != 0){
    5ae6:	00094583          	lbu	a1,0(s2)
    5aea:	f9e5                	bnez	a1,5ada <vprintf+0x16c>
        s = va_arg(ap, char*);
    5aec:	8b4e                	mv	s6,s3
      state = 0;
    5aee:	4981                	li	s3,0
    5af0:	bdf9                	j	59ce <vprintf+0x60>
          s = "(null)";
    5af2:	00002917          	auipc	s2,0x2
    5af6:	79e90913          	addi	s2,s2,1950 # 8290 <malloc+0x2658>
        while(*s != 0){
    5afa:	02800593          	li	a1,40
    5afe:	bff1                	j	5ada <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5b00:	008b0913          	addi	s2,s6,8
    5b04:	000b4583          	lbu	a1,0(s6)
    5b08:	8556                	mv	a0,s5
    5b0a:	00000097          	auipc	ra,0x0
    5b0e:	d98080e7          	jalr	-616(ra) # 58a2 <putc>
    5b12:	8b4a                	mv	s6,s2
      state = 0;
    5b14:	4981                	li	s3,0
    5b16:	bd65                	j	59ce <vprintf+0x60>
        putc(fd, c);
    5b18:	85d2                	mv	a1,s4
    5b1a:	8556                	mv	a0,s5
    5b1c:	00000097          	auipc	ra,0x0
    5b20:	d86080e7          	jalr	-634(ra) # 58a2 <putc>
      state = 0;
    5b24:	4981                	li	s3,0
    5b26:	b565                	j	59ce <vprintf+0x60>
        s = va_arg(ap, char*);
    5b28:	8b4e                	mv	s6,s3
      state = 0;
    5b2a:	4981                	li	s3,0
    5b2c:	b54d                	j	59ce <vprintf+0x60>
    }
  }
}
    5b2e:	70e6                	ld	ra,120(sp)
    5b30:	7446                	ld	s0,112(sp)
    5b32:	74a6                	ld	s1,104(sp)
    5b34:	7906                	ld	s2,96(sp)
    5b36:	69e6                	ld	s3,88(sp)
    5b38:	6a46                	ld	s4,80(sp)
    5b3a:	6aa6                	ld	s5,72(sp)
    5b3c:	6b06                	ld	s6,64(sp)
    5b3e:	7be2                	ld	s7,56(sp)
    5b40:	7c42                	ld	s8,48(sp)
    5b42:	7ca2                	ld	s9,40(sp)
    5b44:	7d02                	ld	s10,32(sp)
    5b46:	6de2                	ld	s11,24(sp)
    5b48:	6109                	addi	sp,sp,128
    5b4a:	8082                	ret

0000000000005b4c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5b4c:	715d                	addi	sp,sp,-80
    5b4e:	ec06                	sd	ra,24(sp)
    5b50:	e822                	sd	s0,16(sp)
    5b52:	1000                	addi	s0,sp,32
    5b54:	e010                	sd	a2,0(s0)
    5b56:	e414                	sd	a3,8(s0)
    5b58:	e818                	sd	a4,16(s0)
    5b5a:	ec1c                	sd	a5,24(s0)
    5b5c:	03043023          	sd	a6,32(s0)
    5b60:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5b64:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5b68:	8622                	mv	a2,s0
    5b6a:	00000097          	auipc	ra,0x0
    5b6e:	e04080e7          	jalr	-508(ra) # 596e <vprintf>
}
    5b72:	60e2                	ld	ra,24(sp)
    5b74:	6442                	ld	s0,16(sp)
    5b76:	6161                	addi	sp,sp,80
    5b78:	8082                	ret

0000000000005b7a <printf>:

void
printf(const char *fmt, ...)
{
    5b7a:	711d                	addi	sp,sp,-96
    5b7c:	ec06                	sd	ra,24(sp)
    5b7e:	e822                	sd	s0,16(sp)
    5b80:	1000                	addi	s0,sp,32
    5b82:	e40c                	sd	a1,8(s0)
    5b84:	e810                	sd	a2,16(s0)
    5b86:	ec14                	sd	a3,24(s0)
    5b88:	f018                	sd	a4,32(s0)
    5b8a:	f41c                	sd	a5,40(s0)
    5b8c:	03043823          	sd	a6,48(s0)
    5b90:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5b94:	00840613          	addi	a2,s0,8
    5b98:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5b9c:	85aa                	mv	a1,a0
    5b9e:	4505                	li	a0,1
    5ba0:	00000097          	auipc	ra,0x0
    5ba4:	dce080e7          	jalr	-562(ra) # 596e <vprintf>
}
    5ba8:	60e2                	ld	ra,24(sp)
    5baa:	6442                	ld	s0,16(sp)
    5bac:	6125                	addi	sp,sp,96
    5bae:	8082                	ret

0000000000005bb0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5bb0:	1141                	addi	sp,sp,-16
    5bb2:	e422                	sd	s0,8(sp)
    5bb4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5bb6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5bba:	00002797          	auipc	a5,0x2
    5bbe:	70e7b783          	ld	a5,1806(a5) # 82c8 <freep>
    5bc2:	a805                	j	5bf2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5bc4:	4618                	lw	a4,8(a2)
    5bc6:	9db9                	addw	a1,a1,a4
    5bc8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5bcc:	6398                	ld	a4,0(a5)
    5bce:	6318                	ld	a4,0(a4)
    5bd0:	fee53823          	sd	a4,-16(a0)
    5bd4:	a091                	j	5c18 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5bd6:	ff852703          	lw	a4,-8(a0)
    5bda:	9e39                	addw	a2,a2,a4
    5bdc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5bde:	ff053703          	ld	a4,-16(a0)
    5be2:	e398                	sd	a4,0(a5)
    5be4:	a099                	j	5c2a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5be6:	6398                	ld	a4,0(a5)
    5be8:	00e7e463          	bltu	a5,a4,5bf0 <free+0x40>
    5bec:	00e6ea63          	bltu	a3,a4,5c00 <free+0x50>
{
    5bf0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5bf2:	fed7fae3          	bgeu	a5,a3,5be6 <free+0x36>
    5bf6:	6398                	ld	a4,0(a5)
    5bf8:	00e6e463          	bltu	a3,a4,5c00 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5bfc:	fee7eae3          	bltu	a5,a4,5bf0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5c00:	ff852583          	lw	a1,-8(a0)
    5c04:	6390                	ld	a2,0(a5)
    5c06:	02059813          	slli	a6,a1,0x20
    5c0a:	01c85713          	srli	a4,a6,0x1c
    5c0e:	9736                	add	a4,a4,a3
    5c10:	fae60ae3          	beq	a2,a4,5bc4 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5c14:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5c18:	4790                	lw	a2,8(a5)
    5c1a:	02061593          	slli	a1,a2,0x20
    5c1e:	01c5d713          	srli	a4,a1,0x1c
    5c22:	973e                	add	a4,a4,a5
    5c24:	fae689e3          	beq	a3,a4,5bd6 <free+0x26>
  } else
    p->s.ptr = bp;
    5c28:	e394                	sd	a3,0(a5)
  freep = p;
    5c2a:	00002717          	auipc	a4,0x2
    5c2e:	68f73f23          	sd	a5,1694(a4) # 82c8 <freep>
}
    5c32:	6422                	ld	s0,8(sp)
    5c34:	0141                	addi	sp,sp,16
    5c36:	8082                	ret

0000000000005c38 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5c38:	7139                	addi	sp,sp,-64
    5c3a:	fc06                	sd	ra,56(sp)
    5c3c:	f822                	sd	s0,48(sp)
    5c3e:	f426                	sd	s1,40(sp)
    5c40:	f04a                	sd	s2,32(sp)
    5c42:	ec4e                	sd	s3,24(sp)
    5c44:	e852                	sd	s4,16(sp)
    5c46:	e456                	sd	s5,8(sp)
    5c48:	e05a                	sd	s6,0(sp)
    5c4a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5c4c:	02051493          	slli	s1,a0,0x20
    5c50:	9081                	srli	s1,s1,0x20
    5c52:	04bd                	addi	s1,s1,15
    5c54:	8091                	srli	s1,s1,0x4
    5c56:	0014899b          	addiw	s3,s1,1
    5c5a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5c5c:	00002517          	auipc	a0,0x2
    5c60:	66c53503          	ld	a0,1644(a0) # 82c8 <freep>
    5c64:	c515                	beqz	a0,5c90 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5c66:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5c68:	4798                	lw	a4,8(a5)
    5c6a:	02977f63          	bgeu	a4,s1,5ca8 <malloc+0x70>
    5c6e:	8a4e                	mv	s4,s3
    5c70:	0009871b          	sext.w	a4,s3
    5c74:	6685                	lui	a3,0x1
    5c76:	00d77363          	bgeu	a4,a3,5c7c <malloc+0x44>
    5c7a:	6a05                	lui	s4,0x1
    5c7c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5c80:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5c84:	00002917          	auipc	s2,0x2
    5c88:	64490913          	addi	s2,s2,1604 # 82c8 <freep>
  if(p == (char*)-1)
    5c8c:	5afd                	li	s5,-1
    5c8e:	a895                	j	5d02 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    5c90:	00009797          	auipc	a5,0x9
    5c94:	e5878793          	addi	a5,a5,-424 # eae8 <base>
    5c98:	00002717          	auipc	a4,0x2
    5c9c:	62f73823          	sd	a5,1584(a4) # 82c8 <freep>
    5ca0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5ca2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5ca6:	b7e1                	j	5c6e <malloc+0x36>
      if(p->s.size == nunits)
    5ca8:	02e48c63          	beq	s1,a4,5ce0 <malloc+0xa8>
        p->s.size -= nunits;
    5cac:	4137073b          	subw	a4,a4,s3
    5cb0:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5cb2:	02071693          	slli	a3,a4,0x20
    5cb6:	01c6d713          	srli	a4,a3,0x1c
    5cba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5cbc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5cc0:	00002717          	auipc	a4,0x2
    5cc4:	60a73423          	sd	a0,1544(a4) # 82c8 <freep>
      return (void*)(p + 1);
    5cc8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5ccc:	70e2                	ld	ra,56(sp)
    5cce:	7442                	ld	s0,48(sp)
    5cd0:	74a2                	ld	s1,40(sp)
    5cd2:	7902                	ld	s2,32(sp)
    5cd4:	69e2                	ld	s3,24(sp)
    5cd6:	6a42                	ld	s4,16(sp)
    5cd8:	6aa2                	ld	s5,8(sp)
    5cda:	6b02                	ld	s6,0(sp)
    5cdc:	6121                	addi	sp,sp,64
    5cde:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5ce0:	6398                	ld	a4,0(a5)
    5ce2:	e118                	sd	a4,0(a0)
    5ce4:	bff1                	j	5cc0 <malloc+0x88>
  hp->s.size = nu;
    5ce6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5cea:	0541                	addi	a0,a0,16
    5cec:	00000097          	auipc	ra,0x0
    5cf0:	ec4080e7          	jalr	-316(ra) # 5bb0 <free>
  return freep;
    5cf4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5cf8:	d971                	beqz	a0,5ccc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5cfa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5cfc:	4798                	lw	a4,8(a5)
    5cfe:	fa9775e3          	bgeu	a4,s1,5ca8 <malloc+0x70>
    if(p == freep)
    5d02:	00093703          	ld	a4,0(s2)
    5d06:	853e                	mv	a0,a5
    5d08:	fef719e3          	bne	a4,a5,5cfa <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    5d0c:	8552                	mv	a0,s4
    5d0e:	00000097          	auipc	ra,0x0
    5d12:	b64080e7          	jalr	-1180(ra) # 5872 <sbrk>
  if(p == (char*)-1)
    5d16:	fd5518e3          	bne	a0,s5,5ce6 <malloc+0xae>
        return 0;
    5d1a:	4501                	li	a0,0
    5d1c:	bf45                	j	5ccc <malloc+0x94>
