
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	addi	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	addi	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	addi	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	addi	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
{
 11a:	715d                	addi	sp,sp,-80
 11c:	e486                	sd	ra,72(sp)
 11e:	e0a2                	sd	s0,64(sp)
 120:	fc26                	sd	s1,56(sp)
 122:	f84a                	sd	s2,48(sp)
 124:	f44e                	sd	s3,40(sp)
 126:	f052                	sd	s4,32(sp)
 128:	ec56                	sd	s5,24(sp)
 12a:	e85a                	sd	s6,16(sp)
 12c:	e45e                	sd	s7,8(sp)
 12e:	0880                	addi	s0,sp,80
 130:	89aa                	mv	s3,a0
 132:	8b2e                	mv	s6,a1
  m = 0;
 134:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 136:	3ff00b93          	li	s7,1023
 13a:	00001a97          	auipc	s5,0x1
 13e:	986a8a93          	addi	s5,s5,-1658 # ac0 <buf>
 142:	a0a1                	j	18a <grep+0x70>
      p = q+1;
 144:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 148:	45a9                	li	a1,10
 14a:	854a                	mv	a0,s2
 14c:	00000097          	auipc	ra,0x0
 150:	1e6080e7          	jalr	486(ra) # 332 <strchr>
 154:	84aa                	mv	s1,a0
 156:	c905                	beqz	a0,186 <grep+0x6c>
      *q = 0;
 158:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 15c:	85ca                	mv	a1,s2
 15e:	854e                	mv	a0,s3
 160:	00000097          	auipc	ra,0x0
 164:	f6c080e7          	jalr	-148(ra) # cc <match>
 168:	dd71                	beqz	a0,144 <grep+0x2a>
        *q = '\n';
 16a:	47a9                	li	a5,10
 16c:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 170:	00148613          	addi	a2,s1,1
 174:	4126063b          	subw	a2,a2,s2
 178:	85ca                	mv	a1,s2
 17a:	4505                	li	a0,1
 17c:	00000097          	auipc	ra,0x0
 180:	3b0080e7          	jalr	944(ra) # 52c <write>
 184:	b7c1                	j	144 <grep+0x2a>
    if(m > 0){
 186:	03404563          	bgtz	s4,1b0 <grep+0x96>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 18a:	414b863b          	subw	a2,s7,s4
 18e:	014a85b3          	add	a1,s5,s4
 192:	855a                	mv	a0,s6
 194:	00000097          	auipc	ra,0x0
 198:	390080e7          	jalr	912(ra) # 524 <read>
 19c:	02a05663          	blez	a0,1c8 <grep+0xae>
    m += n;
 1a0:	00aa0a3b          	addw	s4,s4,a0
    buf[m] = '\0';
 1a4:	014a87b3          	add	a5,s5,s4
 1a8:	00078023          	sb	zero,0(a5)
    p = buf;
 1ac:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 1ae:	bf69                	j	148 <grep+0x2e>
      m -= p - buf;
 1b0:	415907b3          	sub	a5,s2,s5
 1b4:	40fa0a3b          	subw	s4,s4,a5
      memmove(buf, p, m);
 1b8:	8652                	mv	a2,s4
 1ba:	85ca                	mv	a1,s2
 1bc:	8556                	mv	a0,s5
 1be:	00000097          	auipc	ra,0x0
 1c2:	29c080e7          	jalr	668(ra) # 45a <memmove>
 1c6:	b7d1                	j	18a <grep+0x70>
}
 1c8:	60a6                	ld	ra,72(sp)
 1ca:	6406                	ld	s0,64(sp)
 1cc:	74e2                	ld	s1,56(sp)
 1ce:	7942                	ld	s2,48(sp)
 1d0:	79a2                	ld	s3,40(sp)
 1d2:	7a02                	ld	s4,32(sp)
 1d4:	6ae2                	ld	s5,24(sp)
 1d6:	6b42                	ld	s6,16(sp)
 1d8:	6ba2                	ld	s7,8(sp)
 1da:	6161                	addi	sp,sp,80
 1dc:	8082                	ret

00000000000001de <main>:
{
 1de:	7139                	addi	sp,sp,-64
 1e0:	fc06                	sd	ra,56(sp)
 1e2:	f822                	sd	s0,48(sp)
 1e4:	f426                	sd	s1,40(sp)
 1e6:	f04a                	sd	s2,32(sp)
 1e8:	ec4e                	sd	s3,24(sp)
 1ea:	e852                	sd	s4,16(sp)
 1ec:	e456                	sd	s5,8(sp)
 1ee:	0080                	addi	s0,sp,64
  if(argc <= 1){
 1f0:	4785                	li	a5,1
 1f2:	04a7de63          	bge	a5,a0,24e <main+0x70>
  pattern = argv[1];
 1f6:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1fa:	4789                	li	a5,2
 1fc:	06a7d763          	bge	a5,a0,26a <main+0x8c>
 200:	01058913          	addi	s2,a1,16
 204:	ffd5099b          	addiw	s3,a0,-3
 208:	02099793          	slli	a5,s3,0x20
 20c:	01d7d993          	srli	s3,a5,0x1d
 210:	05e1                	addi	a1,a1,24
 212:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], 0)) < 0){
 214:	4581                	li	a1,0
 216:	00093503          	ld	a0,0(s2)
 21a:	00000097          	auipc	ra,0x0
 21e:	332080e7          	jalr	818(ra) # 54c <open>
 222:	84aa                	mv	s1,a0
 224:	04054e63          	bltz	a0,280 <main+0xa2>
    grep(pattern, fd);
 228:	85aa                	mv	a1,a0
 22a:	8552                	mv	a0,s4
 22c:	00000097          	auipc	ra,0x0
 230:	eee080e7          	jalr	-274(ra) # 11a <grep>
    close(fd);
 234:	8526                	mv	a0,s1
 236:	00000097          	auipc	ra,0x0
 23a:	2fe080e7          	jalr	766(ra) # 534 <close>
  for(i = 2; i < argc; i++){
 23e:	0921                	addi	s2,s2,8
 240:	fd391ae3          	bne	s2,s3,214 <main+0x36>
  exit(0);
 244:	4501                	li	a0,0
 246:	00000097          	auipc	ra,0x0
 24a:	2c6080e7          	jalr	710(ra) # 50c <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 24e:	00001597          	auipc	a1,0x1
 252:	81258593          	addi	a1,a1,-2030 # a60 <malloc+0xe6>
 256:	4509                	li	a0,2
 258:	00000097          	auipc	ra,0x0
 25c:	636080e7          	jalr	1590(ra) # 88e <fprintf>
    exit(1);
 260:	4505                	li	a0,1
 262:	00000097          	auipc	ra,0x0
 266:	2aa080e7          	jalr	682(ra) # 50c <exit>
    grep(pattern, 0);
 26a:	4581                	li	a1,0
 26c:	8552                	mv	a0,s4
 26e:	00000097          	auipc	ra,0x0
 272:	eac080e7          	jalr	-340(ra) # 11a <grep>
    exit(0);
 276:	4501                	li	a0,0
 278:	00000097          	auipc	ra,0x0
 27c:	294080e7          	jalr	660(ra) # 50c <exit>
      printf("grep: cannot open %s\n", argv[i]);
 280:	00093583          	ld	a1,0(s2)
 284:	00000517          	auipc	a0,0x0
 288:	7fc50513          	addi	a0,a0,2044 # a80 <malloc+0x106>
 28c:	00000097          	auipc	ra,0x0
 290:	630080e7          	jalr	1584(ra) # 8bc <printf>
      exit(1);
 294:	4505                	li	a0,1
 296:	00000097          	auipc	ra,0x0
 29a:	276080e7          	jalr	630(ra) # 50c <exit>

000000000000029e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2a4:	87aa                	mv	a5,a0
 2a6:	0585                	addi	a1,a1,1
 2a8:	0785                	addi	a5,a5,1
 2aa:	fff5c703          	lbu	a4,-1(a1)
 2ae:	fee78fa3          	sb	a4,-1(a5)
 2b2:	fb75                	bnez	a4,2a6 <strcpy+0x8>
    ;
  return os;
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret

00000000000002ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2c0:	00054783          	lbu	a5,0(a0)
 2c4:	cb91                	beqz	a5,2d8 <strcmp+0x1e>
 2c6:	0005c703          	lbu	a4,0(a1)
 2ca:	00f71763          	bne	a4,a5,2d8 <strcmp+0x1e>
    p++, q++;
 2ce:	0505                	addi	a0,a0,1
 2d0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2d2:	00054783          	lbu	a5,0(a0)
 2d6:	fbe5                	bnez	a5,2c6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2d8:	0005c503          	lbu	a0,0(a1)
}
 2dc:	40a7853b          	subw	a0,a5,a0
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret

00000000000002e6 <strlen>:

uint
strlen(const char *s)
{
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e422                	sd	s0,8(sp)
 2ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ec:	00054783          	lbu	a5,0(a0)
 2f0:	cf91                	beqz	a5,30c <strlen+0x26>
 2f2:	0505                	addi	a0,a0,1
 2f4:	87aa                	mv	a5,a0
 2f6:	4685                	li	a3,1
 2f8:	9e89                	subw	a3,a3,a0
 2fa:	00f6853b          	addw	a0,a3,a5
 2fe:	0785                	addi	a5,a5,1
 300:	fff7c703          	lbu	a4,-1(a5)
 304:	fb7d                	bnez	a4,2fa <strlen+0x14>
    ;
  return n;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  for(n = 0; s[n]; n++)
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <strlen+0x20>

0000000000000310 <memset>:

void*
memset(void *dst, int c, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 316:	ca19                	beqz	a2,32c <memset+0x1c>
 318:	87aa                	mv	a5,a0
 31a:	1602                	slli	a2,a2,0x20
 31c:	9201                	srli	a2,a2,0x20
 31e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 322:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 326:	0785                	addi	a5,a5,1
 328:	fee79de3          	bne	a5,a4,322 <memset+0x12>
  }
  return dst;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret

0000000000000332 <strchr>:

char*
strchr(const char *s, char c)
{
 332:	1141                	addi	sp,sp,-16
 334:	e422                	sd	s0,8(sp)
 336:	0800                	addi	s0,sp,16
  for(; *s; s++)
 338:	00054783          	lbu	a5,0(a0)
 33c:	cb99                	beqz	a5,352 <strchr+0x20>
    if(*s == c)
 33e:	00f58763          	beq	a1,a5,34c <strchr+0x1a>
  for(; *s; s++)
 342:	0505                	addi	a0,a0,1
 344:	00054783          	lbu	a5,0(a0)
 348:	fbfd                	bnez	a5,33e <strchr+0xc>
      return (char*)s;
  return 0;
 34a:	4501                	li	a0,0
}
 34c:	6422                	ld	s0,8(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret
  return 0;
 352:	4501                	li	a0,0
 354:	bfe5                	j	34c <strchr+0x1a>

0000000000000356 <gets>:

char*
gets(char *buf, int max)
{
 356:	711d                	addi	sp,sp,-96
 358:	ec86                	sd	ra,88(sp)
 35a:	e8a2                	sd	s0,80(sp)
 35c:	e4a6                	sd	s1,72(sp)
 35e:	e0ca                	sd	s2,64(sp)
 360:	fc4e                	sd	s3,56(sp)
 362:	f852                	sd	s4,48(sp)
 364:	f456                	sd	s5,40(sp)
 366:	f05a                	sd	s6,32(sp)
 368:	ec5e                	sd	s7,24(sp)
 36a:	1080                	addi	s0,sp,96
 36c:	8baa                	mv	s7,a0
 36e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 370:	892a                	mv	s2,a0
 372:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 374:	4aa9                	li	s5,10
 376:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 378:	89a6                	mv	s3,s1
 37a:	2485                	addiw	s1,s1,1
 37c:	0344d863          	bge	s1,s4,3ac <gets+0x56>
    cc = read(0, &c, 1);
 380:	4605                	li	a2,1
 382:	faf40593          	addi	a1,s0,-81
 386:	4501                	li	a0,0
 388:	00000097          	auipc	ra,0x0
 38c:	19c080e7          	jalr	412(ra) # 524 <read>
    if(cc < 1)
 390:	00a05e63          	blez	a0,3ac <gets+0x56>
    buf[i++] = c;
 394:	faf44783          	lbu	a5,-81(s0)
 398:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 39c:	01578763          	beq	a5,s5,3aa <gets+0x54>
 3a0:	0905                	addi	s2,s2,1
 3a2:	fd679be3          	bne	a5,s6,378 <gets+0x22>
  for(i=0; i+1 < max; ){
 3a6:	89a6                	mv	s3,s1
 3a8:	a011                	j	3ac <gets+0x56>
 3aa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3ac:	99de                	add	s3,s3,s7
 3ae:	00098023          	sb	zero,0(s3)
  return buf;
}
 3b2:	855e                	mv	a0,s7
 3b4:	60e6                	ld	ra,88(sp)
 3b6:	6446                	ld	s0,80(sp)
 3b8:	64a6                	ld	s1,72(sp)
 3ba:	6906                	ld	s2,64(sp)
 3bc:	79e2                	ld	s3,56(sp)
 3be:	7a42                	ld	s4,48(sp)
 3c0:	7aa2                	ld	s5,40(sp)
 3c2:	7b02                	ld	s6,32(sp)
 3c4:	6be2                	ld	s7,24(sp)
 3c6:	6125                	addi	sp,sp,96
 3c8:	8082                	ret

00000000000003ca <stat>:

int
stat(const char *n, struct stat *st)
{
 3ca:	1101                	addi	sp,sp,-32
 3cc:	ec06                	sd	ra,24(sp)
 3ce:	e822                	sd	s0,16(sp)
 3d0:	e426                	sd	s1,8(sp)
 3d2:	e04a                	sd	s2,0(sp)
 3d4:	1000                	addi	s0,sp,32
 3d6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3d8:	4581                	li	a1,0
 3da:	00000097          	auipc	ra,0x0
 3de:	172080e7          	jalr	370(ra) # 54c <open>
  if(fd < 0)
 3e2:	02054563          	bltz	a0,40c <stat+0x42>
 3e6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3e8:	85ca                	mv	a1,s2
 3ea:	00000097          	auipc	ra,0x0
 3ee:	17a080e7          	jalr	378(ra) # 564 <fstat>
 3f2:	892a                	mv	s2,a0
  close(fd);
 3f4:	8526                	mv	a0,s1
 3f6:	00000097          	auipc	ra,0x0
 3fa:	13e080e7          	jalr	318(ra) # 534 <close>
  return r;
}
 3fe:	854a                	mv	a0,s2
 400:	60e2                	ld	ra,24(sp)
 402:	6442                	ld	s0,16(sp)
 404:	64a2                	ld	s1,8(sp)
 406:	6902                	ld	s2,0(sp)
 408:	6105                	addi	sp,sp,32
 40a:	8082                	ret
    return -1;
 40c:	597d                	li	s2,-1
 40e:	bfc5                	j	3fe <stat+0x34>

0000000000000410 <atoi>:

int
atoi(const char *s)
{
 410:	1141                	addi	sp,sp,-16
 412:	e422                	sd	s0,8(sp)
 414:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 416:	00054603          	lbu	a2,0(a0)
 41a:	fd06079b          	addiw	a5,a2,-48
 41e:	0ff7f793          	andi	a5,a5,255
 422:	4725                	li	a4,9
 424:	02f76963          	bltu	a4,a5,456 <atoi+0x46>
 428:	86aa                	mv	a3,a0
  n = 0;
 42a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 42c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 42e:	0685                	addi	a3,a3,1
 430:	0025179b          	slliw	a5,a0,0x2
 434:	9fa9                	addw	a5,a5,a0
 436:	0017979b          	slliw	a5,a5,0x1
 43a:	9fb1                	addw	a5,a5,a2
 43c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 440:	0006c603          	lbu	a2,0(a3)
 444:	fd06071b          	addiw	a4,a2,-48
 448:	0ff77713          	andi	a4,a4,255
 44c:	fee5f1e3          	bgeu	a1,a4,42e <atoi+0x1e>
  return n;
}
 450:	6422                	ld	s0,8(sp)
 452:	0141                	addi	sp,sp,16
 454:	8082                	ret
  n = 0;
 456:	4501                	li	a0,0
 458:	bfe5                	j	450 <atoi+0x40>

000000000000045a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 45a:	1141                	addi	sp,sp,-16
 45c:	e422                	sd	s0,8(sp)
 45e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 460:	02b57463          	bgeu	a0,a1,488 <memmove+0x2e>
    while(n-- > 0)
 464:	00c05f63          	blez	a2,482 <memmove+0x28>
 468:	1602                	slli	a2,a2,0x20
 46a:	9201                	srli	a2,a2,0x20
 46c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 470:	872a                	mv	a4,a0
      *dst++ = *src++;
 472:	0585                	addi	a1,a1,1
 474:	0705                	addi	a4,a4,1
 476:	fff5c683          	lbu	a3,-1(a1)
 47a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 47e:	fee79ae3          	bne	a5,a4,472 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 482:	6422                	ld	s0,8(sp)
 484:	0141                	addi	sp,sp,16
 486:	8082                	ret
    dst += n;
 488:	00c50733          	add	a4,a0,a2
    src += n;
 48c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 48e:	fec05ae3          	blez	a2,482 <memmove+0x28>
 492:	fff6079b          	addiw	a5,a2,-1
 496:	1782                	slli	a5,a5,0x20
 498:	9381                	srli	a5,a5,0x20
 49a:	fff7c793          	not	a5,a5
 49e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4a0:	15fd                	addi	a1,a1,-1
 4a2:	177d                	addi	a4,a4,-1
 4a4:	0005c683          	lbu	a3,0(a1)
 4a8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4ac:	fee79ae3          	bne	a5,a4,4a0 <memmove+0x46>
 4b0:	bfc9                	j	482 <memmove+0x28>

00000000000004b2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4b2:	1141                	addi	sp,sp,-16
 4b4:	e422                	sd	s0,8(sp)
 4b6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4b8:	ca05                	beqz	a2,4e8 <memcmp+0x36>
 4ba:	fff6069b          	addiw	a3,a2,-1
 4be:	1682                	slli	a3,a3,0x20
 4c0:	9281                	srli	a3,a3,0x20
 4c2:	0685                	addi	a3,a3,1
 4c4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4c6:	00054783          	lbu	a5,0(a0)
 4ca:	0005c703          	lbu	a4,0(a1)
 4ce:	00e79863          	bne	a5,a4,4de <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4d2:	0505                	addi	a0,a0,1
    p2++;
 4d4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4d6:	fed518e3          	bne	a0,a3,4c6 <memcmp+0x14>
  }
  return 0;
 4da:	4501                	li	a0,0
 4dc:	a019                	j	4e2 <memcmp+0x30>
      return *p1 - *p2;
 4de:	40e7853b          	subw	a0,a5,a4
}
 4e2:	6422                	ld	s0,8(sp)
 4e4:	0141                	addi	sp,sp,16
 4e6:	8082                	ret
  return 0;
 4e8:	4501                	li	a0,0
 4ea:	bfe5                	j	4e2 <memcmp+0x30>

00000000000004ec <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ec:	1141                	addi	sp,sp,-16
 4ee:	e406                	sd	ra,8(sp)
 4f0:	e022                	sd	s0,0(sp)
 4f2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4f4:	00000097          	auipc	ra,0x0
 4f8:	f66080e7          	jalr	-154(ra) # 45a <memmove>
}
 4fc:	60a2                	ld	ra,8(sp)
 4fe:	6402                	ld	s0,0(sp)
 500:	0141                	addi	sp,sp,16
 502:	8082                	ret

0000000000000504 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 504:	4885                	li	a7,1
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <exit>:
.global exit
exit:
 li a7, SYS_exit
 50c:	4889                	li	a7,2
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <wait>:
.global wait
wait:
 li a7, SYS_wait
 514:	488d                	li	a7,3
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 51c:	4891                	li	a7,4
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <read>:
.global read
read:
 li a7, SYS_read
 524:	4895                	li	a7,5
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <write>:
.global write
write:
 li a7, SYS_write
 52c:	48c1                	li	a7,16
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <close>:
.global close
close:
 li a7, SYS_close
 534:	48d5                	li	a7,21
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <kill>:
.global kill
kill:
 li a7, SYS_kill
 53c:	4899                	li	a7,6
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <exec>:
.global exec
exec:
 li a7, SYS_exec
 544:	489d                	li	a7,7
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <open>:
.global open
open:
 li a7, SYS_open
 54c:	48bd                	li	a7,15
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 554:	48c5                	li	a7,17
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 55c:	48c9                	li	a7,18
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 564:	48a1                	li	a7,8
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <link>:
.global link
link:
 li a7, SYS_link
 56c:	48cd                	li	a7,19
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 574:	48d1                	li	a7,20
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 57c:	48a5                	li	a7,9
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <dup>:
.global dup
dup:
 li a7, SYS_dup
 584:	48a9                	li	a7,10
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 58c:	48ad                	li	a7,11
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 594:	48b1                	li	a7,12
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 59c:	48b5                	li	a7,13
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5a4:	48b9                	li	a7,14
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 5ac:	48d9                	li	a7,22
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 5b4:	48dd                	li	a7,23
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 5bc:	48e1                	li	a7,24
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
 5c4:	48e5                	li	a7,25
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
 5cc:	48e9                	li	a7,26
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
 5d4:	48ed                	li	a7,27
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
 5dc:	48f1                	li	a7,28
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5e4:	1101                	addi	sp,sp,-32
 5e6:	ec06                	sd	ra,24(sp)
 5e8:	e822                	sd	s0,16(sp)
 5ea:	1000                	addi	s0,sp,32
 5ec:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5f0:	4605                	li	a2,1
 5f2:	fef40593          	addi	a1,s0,-17
 5f6:	00000097          	auipc	ra,0x0
 5fa:	f36080e7          	jalr	-202(ra) # 52c <write>
}
 5fe:	60e2                	ld	ra,24(sp)
 600:	6442                	ld	s0,16(sp)
 602:	6105                	addi	sp,sp,32
 604:	8082                	ret

0000000000000606 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 606:	7139                	addi	sp,sp,-64
 608:	fc06                	sd	ra,56(sp)
 60a:	f822                	sd	s0,48(sp)
 60c:	f426                	sd	s1,40(sp)
 60e:	f04a                	sd	s2,32(sp)
 610:	ec4e                	sd	s3,24(sp)
 612:	0080                	addi	s0,sp,64
 614:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 616:	c299                	beqz	a3,61c <printint+0x16>
 618:	0805c863          	bltz	a1,6a8 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 61c:	2581                	sext.w	a1,a1
  neg = 0;
 61e:	4881                	li	a7,0
 620:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 624:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 626:	2601                	sext.w	a2,a2
 628:	00000517          	auipc	a0,0x0
 62c:	47850513          	addi	a0,a0,1144 # aa0 <digits>
 630:	883a                	mv	a6,a4
 632:	2705                	addiw	a4,a4,1
 634:	02c5f7bb          	remuw	a5,a1,a2
 638:	1782                	slli	a5,a5,0x20
 63a:	9381                	srli	a5,a5,0x20
 63c:	97aa                	add	a5,a5,a0
 63e:	0007c783          	lbu	a5,0(a5)
 642:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 646:	0005879b          	sext.w	a5,a1
 64a:	02c5d5bb          	divuw	a1,a1,a2
 64e:	0685                	addi	a3,a3,1
 650:	fec7f0e3          	bgeu	a5,a2,630 <printint+0x2a>
  if(neg)
 654:	00088b63          	beqz	a7,66a <printint+0x64>
    buf[i++] = '-';
 658:	fd040793          	addi	a5,s0,-48
 65c:	973e                	add	a4,a4,a5
 65e:	02d00793          	li	a5,45
 662:	fef70823          	sb	a5,-16(a4)
 666:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 66a:	02e05863          	blez	a4,69a <printint+0x94>
 66e:	fc040793          	addi	a5,s0,-64
 672:	00e78933          	add	s2,a5,a4
 676:	fff78993          	addi	s3,a5,-1
 67a:	99ba                	add	s3,s3,a4
 67c:	377d                	addiw	a4,a4,-1
 67e:	1702                	slli	a4,a4,0x20
 680:	9301                	srli	a4,a4,0x20
 682:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 686:	fff94583          	lbu	a1,-1(s2)
 68a:	8526                	mv	a0,s1
 68c:	00000097          	auipc	ra,0x0
 690:	f58080e7          	jalr	-168(ra) # 5e4 <putc>
  while(--i >= 0)
 694:	197d                	addi	s2,s2,-1
 696:	ff3918e3          	bne	s2,s3,686 <printint+0x80>
}
 69a:	70e2                	ld	ra,56(sp)
 69c:	7442                	ld	s0,48(sp)
 69e:	74a2                	ld	s1,40(sp)
 6a0:	7902                	ld	s2,32(sp)
 6a2:	69e2                	ld	s3,24(sp)
 6a4:	6121                	addi	sp,sp,64
 6a6:	8082                	ret
    x = -xx;
 6a8:	40b005bb          	negw	a1,a1
    neg = 1;
 6ac:	4885                	li	a7,1
    x = -xx;
 6ae:	bf8d                	j	620 <printint+0x1a>

00000000000006b0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6b0:	7119                	addi	sp,sp,-128
 6b2:	fc86                	sd	ra,120(sp)
 6b4:	f8a2                	sd	s0,112(sp)
 6b6:	f4a6                	sd	s1,104(sp)
 6b8:	f0ca                	sd	s2,96(sp)
 6ba:	ecce                	sd	s3,88(sp)
 6bc:	e8d2                	sd	s4,80(sp)
 6be:	e4d6                	sd	s5,72(sp)
 6c0:	e0da                	sd	s6,64(sp)
 6c2:	fc5e                	sd	s7,56(sp)
 6c4:	f862                	sd	s8,48(sp)
 6c6:	f466                	sd	s9,40(sp)
 6c8:	f06a                	sd	s10,32(sp)
 6ca:	ec6e                	sd	s11,24(sp)
 6cc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6ce:	0005c903          	lbu	s2,0(a1)
 6d2:	18090f63          	beqz	s2,870 <vprintf+0x1c0>
 6d6:	8aaa                	mv	s5,a0
 6d8:	8b32                	mv	s6,a2
 6da:	00158493          	addi	s1,a1,1
  state = 0;
 6de:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6e0:	02500a13          	li	s4,37
      if(c == 'd'){
 6e4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 6e8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6ec:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6f0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6f4:	00000b97          	auipc	s7,0x0
 6f8:	3acb8b93          	addi	s7,s7,940 # aa0 <digits>
 6fc:	a839                	j	71a <vprintf+0x6a>
        putc(fd, c);
 6fe:	85ca                	mv	a1,s2
 700:	8556                	mv	a0,s5
 702:	00000097          	auipc	ra,0x0
 706:	ee2080e7          	jalr	-286(ra) # 5e4 <putc>
 70a:	a019                	j	710 <vprintf+0x60>
    } else if(state == '%'){
 70c:	01498f63          	beq	s3,s4,72a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 710:	0485                	addi	s1,s1,1
 712:	fff4c903          	lbu	s2,-1(s1)
 716:	14090d63          	beqz	s2,870 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 71a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 71e:	fe0997e3          	bnez	s3,70c <vprintf+0x5c>
      if(c == '%'){
 722:	fd479ee3          	bne	a5,s4,6fe <vprintf+0x4e>
        state = '%';
 726:	89be                	mv	s3,a5
 728:	b7e5                	j	710 <vprintf+0x60>
      if(c == 'd'){
 72a:	05878063          	beq	a5,s8,76a <vprintf+0xba>
      } else if(c == 'l') {
 72e:	05978c63          	beq	a5,s9,786 <vprintf+0xd6>
      } else if(c == 'x') {
 732:	07a78863          	beq	a5,s10,7a2 <vprintf+0xf2>
      } else if(c == 'p') {
 736:	09b78463          	beq	a5,s11,7be <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 73a:	07300713          	li	a4,115
 73e:	0ce78663          	beq	a5,a4,80a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 742:	06300713          	li	a4,99
 746:	0ee78e63          	beq	a5,a4,842 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 74a:	11478863          	beq	a5,s4,85a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 74e:	85d2                	mv	a1,s4
 750:	8556                	mv	a0,s5
 752:	00000097          	auipc	ra,0x0
 756:	e92080e7          	jalr	-366(ra) # 5e4 <putc>
        putc(fd, c);
 75a:	85ca                	mv	a1,s2
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	e86080e7          	jalr	-378(ra) # 5e4 <putc>
      }
      state = 0;
 766:	4981                	li	s3,0
 768:	b765                	j	710 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 76a:	008b0913          	addi	s2,s6,8
 76e:	4685                	li	a3,1
 770:	4629                	li	a2,10
 772:	000b2583          	lw	a1,0(s6)
 776:	8556                	mv	a0,s5
 778:	00000097          	auipc	ra,0x0
 77c:	e8e080e7          	jalr	-370(ra) # 606 <printint>
 780:	8b4a                	mv	s6,s2
      state = 0;
 782:	4981                	li	s3,0
 784:	b771                	j	710 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 786:	008b0913          	addi	s2,s6,8
 78a:	4681                	li	a3,0
 78c:	4629                	li	a2,10
 78e:	000b2583          	lw	a1,0(s6)
 792:	8556                	mv	a0,s5
 794:	00000097          	auipc	ra,0x0
 798:	e72080e7          	jalr	-398(ra) # 606 <printint>
 79c:	8b4a                	mv	s6,s2
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	bf85                	j	710 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7a2:	008b0913          	addi	s2,s6,8
 7a6:	4681                	li	a3,0
 7a8:	4641                	li	a2,16
 7aa:	000b2583          	lw	a1,0(s6)
 7ae:	8556                	mv	a0,s5
 7b0:	00000097          	auipc	ra,0x0
 7b4:	e56080e7          	jalr	-426(ra) # 606 <printint>
 7b8:	8b4a                	mv	s6,s2
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	bf91                	j	710 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7be:	008b0793          	addi	a5,s6,8
 7c2:	f8f43423          	sd	a5,-120(s0)
 7c6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7ca:	03000593          	li	a1,48
 7ce:	8556                	mv	a0,s5
 7d0:	00000097          	auipc	ra,0x0
 7d4:	e14080e7          	jalr	-492(ra) # 5e4 <putc>
  putc(fd, 'x');
 7d8:	85ea                	mv	a1,s10
 7da:	8556                	mv	a0,s5
 7dc:	00000097          	auipc	ra,0x0
 7e0:	e08080e7          	jalr	-504(ra) # 5e4 <putc>
 7e4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7e6:	03c9d793          	srli	a5,s3,0x3c
 7ea:	97de                	add	a5,a5,s7
 7ec:	0007c583          	lbu	a1,0(a5)
 7f0:	8556                	mv	a0,s5
 7f2:	00000097          	auipc	ra,0x0
 7f6:	df2080e7          	jalr	-526(ra) # 5e4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7fa:	0992                	slli	s3,s3,0x4
 7fc:	397d                	addiw	s2,s2,-1
 7fe:	fe0914e3          	bnez	s2,7e6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 802:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 806:	4981                	li	s3,0
 808:	b721                	j	710 <vprintf+0x60>
        s = va_arg(ap, char*);
 80a:	008b0993          	addi	s3,s6,8
 80e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 812:	02090163          	beqz	s2,834 <vprintf+0x184>
        while(*s != 0){
 816:	00094583          	lbu	a1,0(s2)
 81a:	c9a1                	beqz	a1,86a <vprintf+0x1ba>
          putc(fd, *s);
 81c:	8556                	mv	a0,s5
 81e:	00000097          	auipc	ra,0x0
 822:	dc6080e7          	jalr	-570(ra) # 5e4 <putc>
          s++;
 826:	0905                	addi	s2,s2,1
        while(*s != 0){
 828:	00094583          	lbu	a1,0(s2)
 82c:	f9e5                	bnez	a1,81c <vprintf+0x16c>
        s = va_arg(ap, char*);
 82e:	8b4e                	mv	s6,s3
      state = 0;
 830:	4981                	li	s3,0
 832:	bdf9                	j	710 <vprintf+0x60>
          s = "(null)";
 834:	00000917          	auipc	s2,0x0
 838:	26490913          	addi	s2,s2,612 # a98 <malloc+0x11e>
        while(*s != 0){
 83c:	02800593          	li	a1,40
 840:	bff1                	j	81c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 842:	008b0913          	addi	s2,s6,8
 846:	000b4583          	lbu	a1,0(s6)
 84a:	8556                	mv	a0,s5
 84c:	00000097          	auipc	ra,0x0
 850:	d98080e7          	jalr	-616(ra) # 5e4 <putc>
 854:	8b4a                	mv	s6,s2
      state = 0;
 856:	4981                	li	s3,0
 858:	bd65                	j	710 <vprintf+0x60>
        putc(fd, c);
 85a:	85d2                	mv	a1,s4
 85c:	8556                	mv	a0,s5
 85e:	00000097          	auipc	ra,0x0
 862:	d86080e7          	jalr	-634(ra) # 5e4 <putc>
      state = 0;
 866:	4981                	li	s3,0
 868:	b565                	j	710 <vprintf+0x60>
        s = va_arg(ap, char*);
 86a:	8b4e                	mv	s6,s3
      state = 0;
 86c:	4981                	li	s3,0
 86e:	b54d                	j	710 <vprintf+0x60>
    }
  }
}
 870:	70e6                	ld	ra,120(sp)
 872:	7446                	ld	s0,112(sp)
 874:	74a6                	ld	s1,104(sp)
 876:	7906                	ld	s2,96(sp)
 878:	69e6                	ld	s3,88(sp)
 87a:	6a46                	ld	s4,80(sp)
 87c:	6aa6                	ld	s5,72(sp)
 87e:	6b06                	ld	s6,64(sp)
 880:	7be2                	ld	s7,56(sp)
 882:	7c42                	ld	s8,48(sp)
 884:	7ca2                	ld	s9,40(sp)
 886:	7d02                	ld	s10,32(sp)
 888:	6de2                	ld	s11,24(sp)
 88a:	6109                	addi	sp,sp,128
 88c:	8082                	ret

000000000000088e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 88e:	715d                	addi	sp,sp,-80
 890:	ec06                	sd	ra,24(sp)
 892:	e822                	sd	s0,16(sp)
 894:	1000                	addi	s0,sp,32
 896:	e010                	sd	a2,0(s0)
 898:	e414                	sd	a3,8(s0)
 89a:	e818                	sd	a4,16(s0)
 89c:	ec1c                	sd	a5,24(s0)
 89e:	03043023          	sd	a6,32(s0)
 8a2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8a6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8aa:	8622                	mv	a2,s0
 8ac:	00000097          	auipc	ra,0x0
 8b0:	e04080e7          	jalr	-508(ra) # 6b0 <vprintf>
}
 8b4:	60e2                	ld	ra,24(sp)
 8b6:	6442                	ld	s0,16(sp)
 8b8:	6161                	addi	sp,sp,80
 8ba:	8082                	ret

00000000000008bc <printf>:

void
printf(const char *fmt, ...)
{
 8bc:	711d                	addi	sp,sp,-96
 8be:	ec06                	sd	ra,24(sp)
 8c0:	e822                	sd	s0,16(sp)
 8c2:	1000                	addi	s0,sp,32
 8c4:	e40c                	sd	a1,8(s0)
 8c6:	e810                	sd	a2,16(s0)
 8c8:	ec14                	sd	a3,24(s0)
 8ca:	f018                	sd	a4,32(s0)
 8cc:	f41c                	sd	a5,40(s0)
 8ce:	03043823          	sd	a6,48(s0)
 8d2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8d6:	00840613          	addi	a2,s0,8
 8da:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8de:	85aa                	mv	a1,a0
 8e0:	4505                	li	a0,1
 8e2:	00000097          	auipc	ra,0x0
 8e6:	dce080e7          	jalr	-562(ra) # 6b0 <vprintf>
}
 8ea:	60e2                	ld	ra,24(sp)
 8ec:	6442                	ld	s0,16(sp)
 8ee:	6125                	addi	sp,sp,96
 8f0:	8082                	ret

00000000000008f2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8f2:	1141                	addi	sp,sp,-16
 8f4:	e422                	sd	s0,8(sp)
 8f6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8f8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fc:	00000797          	auipc	a5,0x0
 900:	1bc7b783          	ld	a5,444(a5) # ab8 <freep>
 904:	a805                	j	934 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 906:	4618                	lw	a4,8(a2)
 908:	9db9                	addw	a1,a1,a4
 90a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 90e:	6398                	ld	a4,0(a5)
 910:	6318                	ld	a4,0(a4)
 912:	fee53823          	sd	a4,-16(a0)
 916:	a091                	j	95a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 918:	ff852703          	lw	a4,-8(a0)
 91c:	9e39                	addw	a2,a2,a4
 91e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 920:	ff053703          	ld	a4,-16(a0)
 924:	e398                	sd	a4,0(a5)
 926:	a099                	j	96c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 928:	6398                	ld	a4,0(a5)
 92a:	00e7e463          	bltu	a5,a4,932 <free+0x40>
 92e:	00e6ea63          	bltu	a3,a4,942 <free+0x50>
{
 932:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 934:	fed7fae3          	bgeu	a5,a3,928 <free+0x36>
 938:	6398                	ld	a4,0(a5)
 93a:	00e6e463          	bltu	a3,a4,942 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 93e:	fee7eae3          	bltu	a5,a4,932 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 942:	ff852583          	lw	a1,-8(a0)
 946:	6390                	ld	a2,0(a5)
 948:	02059813          	slli	a6,a1,0x20
 94c:	01c85713          	srli	a4,a6,0x1c
 950:	9736                	add	a4,a4,a3
 952:	fae60ae3          	beq	a2,a4,906 <free+0x14>
    bp->s.ptr = p->s.ptr;
 956:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 95a:	4790                	lw	a2,8(a5)
 95c:	02061593          	slli	a1,a2,0x20
 960:	01c5d713          	srli	a4,a1,0x1c
 964:	973e                	add	a4,a4,a5
 966:	fae689e3          	beq	a3,a4,918 <free+0x26>
  } else
    p->s.ptr = bp;
 96a:	e394                	sd	a3,0(a5)
  freep = p;
 96c:	00000717          	auipc	a4,0x0
 970:	14f73623          	sd	a5,332(a4) # ab8 <freep>
}
 974:	6422                	ld	s0,8(sp)
 976:	0141                	addi	sp,sp,16
 978:	8082                	ret

000000000000097a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 97a:	7139                	addi	sp,sp,-64
 97c:	fc06                	sd	ra,56(sp)
 97e:	f822                	sd	s0,48(sp)
 980:	f426                	sd	s1,40(sp)
 982:	f04a                	sd	s2,32(sp)
 984:	ec4e                	sd	s3,24(sp)
 986:	e852                	sd	s4,16(sp)
 988:	e456                	sd	s5,8(sp)
 98a:	e05a                	sd	s6,0(sp)
 98c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 98e:	02051493          	slli	s1,a0,0x20
 992:	9081                	srli	s1,s1,0x20
 994:	04bd                	addi	s1,s1,15
 996:	8091                	srli	s1,s1,0x4
 998:	0014899b          	addiw	s3,s1,1
 99c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 99e:	00000517          	auipc	a0,0x0
 9a2:	11a53503          	ld	a0,282(a0) # ab8 <freep>
 9a6:	c515                	beqz	a0,9d2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9aa:	4798                	lw	a4,8(a5)
 9ac:	02977f63          	bgeu	a4,s1,9ea <malloc+0x70>
 9b0:	8a4e                	mv	s4,s3
 9b2:	0009871b          	sext.w	a4,s3
 9b6:	6685                	lui	a3,0x1
 9b8:	00d77363          	bgeu	a4,a3,9be <malloc+0x44>
 9bc:	6a05                	lui	s4,0x1
 9be:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9c2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9c6:	00000917          	auipc	s2,0x0
 9ca:	0f290913          	addi	s2,s2,242 # ab8 <freep>
  if(p == (char*)-1)
 9ce:	5afd                	li	s5,-1
 9d0:	a895                	j	a44 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 9d2:	00000797          	auipc	a5,0x0
 9d6:	4ee78793          	addi	a5,a5,1262 # ec0 <base>
 9da:	00000717          	auipc	a4,0x0
 9de:	0cf73f23          	sd	a5,222(a4) # ab8 <freep>
 9e2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9e4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9e8:	b7e1                	j	9b0 <malloc+0x36>
      if(p->s.size == nunits)
 9ea:	02e48c63          	beq	s1,a4,a22 <malloc+0xa8>
        p->s.size -= nunits;
 9ee:	4137073b          	subw	a4,a4,s3
 9f2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9f4:	02071693          	slli	a3,a4,0x20
 9f8:	01c6d713          	srli	a4,a3,0x1c
 9fc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9fe:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a02:	00000717          	auipc	a4,0x0
 a06:	0aa73b23          	sd	a0,182(a4) # ab8 <freep>
      return (void*)(p + 1);
 a0a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a0e:	70e2                	ld	ra,56(sp)
 a10:	7442                	ld	s0,48(sp)
 a12:	74a2                	ld	s1,40(sp)
 a14:	7902                	ld	s2,32(sp)
 a16:	69e2                	ld	s3,24(sp)
 a18:	6a42                	ld	s4,16(sp)
 a1a:	6aa2                	ld	s5,8(sp)
 a1c:	6b02                	ld	s6,0(sp)
 a1e:	6121                	addi	sp,sp,64
 a20:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a22:	6398                	ld	a4,0(a5)
 a24:	e118                	sd	a4,0(a0)
 a26:	bff1                	j	a02 <malloc+0x88>
  hp->s.size = nu;
 a28:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a2c:	0541                	addi	a0,a0,16
 a2e:	00000097          	auipc	ra,0x0
 a32:	ec4080e7          	jalr	-316(ra) # 8f2 <free>
  return freep;
 a36:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a3a:	d971                	beqz	a0,a0e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a3e:	4798                	lw	a4,8(a5)
 a40:	fa9775e3          	bgeu	a4,s1,9ea <malloc+0x70>
    if(p == freep)
 a44:	00093703          	ld	a4,0(s2)
 a48:	853e                	mv	a0,a5
 a4a:	fef719e3          	bne	a4,a5,a3c <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a4e:	8552                	mv	a0,s4
 a50:	00000097          	auipc	ra,0x0
 a54:	b44080e7          	jalr	-1212(ra) # 594 <sbrk>
  if(p == (char*)-1)
 a58:	fd5518e3          	bne	a0,s5,a28 <malloc+0xae>
        return 0;
 a5c:	4501                	li	a0,0
 a5e:	bf45                	j	a0e <malloc+0x94>
