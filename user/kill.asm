
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7dd63          	bge	a5,a0,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1ae080e7          	jalr	430(ra) # 1d6 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2d2080e7          	jalr	722(ra) # 302 <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	292080e7          	jalr	658(ra) # 2d2 <exit>
    fprintf(2, "usage: kill pid...\n");
  48:	00000597          	auipc	a1,0x0
  4c:	7e058593          	addi	a1,a1,2016 # 828 <malloc+0xe8>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	602080e7          	jalr	1538(ra) # 654 <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	276080e7          	jalr	630(ra) # 2d2 <exit>

0000000000000064 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  64:	1141                	addi	sp,sp,-16
  66:	e422                	sd	s0,8(sp)
  68:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  6a:	87aa                	mv	a5,a0
  6c:	0585                	addi	a1,a1,1
  6e:	0785                	addi	a5,a5,1
  70:	fff5c703          	lbu	a4,-1(a1)
  74:	fee78fa3          	sb	a4,-1(a5)
  78:	fb75                	bnez	a4,6c <strcpy+0x8>
    ;
  return os;
}
  7a:	6422                	ld	s0,8(sp)
  7c:	0141                	addi	sp,sp,16
  7e:	8082                	ret

0000000000000080 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80:	1141                	addi	sp,sp,-16
  82:	e422                	sd	s0,8(sp)
  84:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  86:	00054783          	lbu	a5,0(a0)
  8a:	cb91                	beqz	a5,9e <strcmp+0x1e>
  8c:	0005c703          	lbu	a4,0(a1)
  90:	00f71763          	bne	a4,a5,9e <strcmp+0x1e>
    p++, q++;
  94:	0505                	addi	a0,a0,1
  96:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  98:	00054783          	lbu	a5,0(a0)
  9c:	fbe5                	bnez	a5,8c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9e:	0005c503          	lbu	a0,0(a1)
}
  a2:	40a7853b          	subw	a0,a5,a0
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret

00000000000000ac <strlen>:

uint
strlen(const char *s)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e422                	sd	s0,8(sp)
  b0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	cf91                	beqz	a5,d2 <strlen+0x26>
  b8:	0505                	addi	a0,a0,1
  ba:	87aa                	mv	a5,a0
  bc:	4685                	li	a3,1
  be:	9e89                	subw	a3,a3,a0
  c0:	00f6853b          	addw	a0,a3,a5
  c4:	0785                	addi	a5,a5,1
  c6:	fff7c703          	lbu	a4,-1(a5)
  ca:	fb7d                	bnez	a4,c0 <strlen+0x14>
    ;
  return n;
}
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret
  for(n = 0; s[n]; n++)
  d2:	4501                	li	a0,0
  d4:	bfe5                	j	cc <strlen+0x20>

00000000000000d6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  dc:	ca19                	beqz	a2,f2 <memset+0x1c>
  de:	87aa                	mv	a5,a0
  e0:	1602                	slli	a2,a2,0x20
  e2:	9201                	srli	a2,a2,0x20
  e4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ec:	0785                	addi	a5,a5,1
  ee:	fee79de3          	bne	a5,a4,e8 <memset+0x12>
  }
  return dst;
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret

00000000000000f8 <strchr>:

char*
strchr(const char *s, char c)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fe:	00054783          	lbu	a5,0(a0)
 102:	cb99                	beqz	a5,118 <strchr+0x20>
    if(*s == c)
 104:	00f58763          	beq	a1,a5,112 <strchr+0x1a>
  for(; *s; s++)
 108:	0505                	addi	a0,a0,1
 10a:	00054783          	lbu	a5,0(a0)
 10e:	fbfd                	bnez	a5,104 <strchr+0xc>
      return (char*)s;
  return 0;
 110:	4501                	li	a0,0
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret
  return 0;
 118:	4501                	li	a0,0
 11a:	bfe5                	j	112 <strchr+0x1a>

000000000000011c <gets>:

char*
gets(char *buf, int max)
{
 11c:	711d                	addi	sp,sp,-96
 11e:	ec86                	sd	ra,88(sp)
 120:	e8a2                	sd	s0,80(sp)
 122:	e4a6                	sd	s1,72(sp)
 124:	e0ca                	sd	s2,64(sp)
 126:	fc4e                	sd	s3,56(sp)
 128:	f852                	sd	s4,48(sp)
 12a:	f456                	sd	s5,40(sp)
 12c:	f05a                	sd	s6,32(sp)
 12e:	ec5e                	sd	s7,24(sp)
 130:	1080                	addi	s0,sp,96
 132:	8baa                	mv	s7,a0
 134:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 136:	892a                	mv	s2,a0
 138:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 13a:	4aa9                	li	s5,10
 13c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13e:	89a6                	mv	s3,s1
 140:	2485                	addiw	s1,s1,1
 142:	0344d863          	bge	s1,s4,172 <gets+0x56>
    cc = read(0, &c, 1);
 146:	4605                	li	a2,1
 148:	faf40593          	addi	a1,s0,-81
 14c:	4501                	li	a0,0
 14e:	00000097          	auipc	ra,0x0
 152:	19c080e7          	jalr	412(ra) # 2ea <read>
    if(cc < 1)
 156:	00a05e63          	blez	a0,172 <gets+0x56>
    buf[i++] = c;
 15a:	faf44783          	lbu	a5,-81(s0)
 15e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 162:	01578763          	beq	a5,s5,170 <gets+0x54>
 166:	0905                	addi	s2,s2,1
 168:	fd679be3          	bne	a5,s6,13e <gets+0x22>
  for(i=0; i+1 < max; ){
 16c:	89a6                	mv	s3,s1
 16e:	a011                	j	172 <gets+0x56>
 170:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 172:	99de                	add	s3,s3,s7
 174:	00098023          	sb	zero,0(s3)
  return buf;
}
 178:	855e                	mv	a0,s7
 17a:	60e6                	ld	ra,88(sp)
 17c:	6446                	ld	s0,80(sp)
 17e:	64a6                	ld	s1,72(sp)
 180:	6906                	ld	s2,64(sp)
 182:	79e2                	ld	s3,56(sp)
 184:	7a42                	ld	s4,48(sp)
 186:	7aa2                	ld	s5,40(sp)
 188:	7b02                	ld	s6,32(sp)
 18a:	6be2                	ld	s7,24(sp)
 18c:	6125                	addi	sp,sp,96
 18e:	8082                	ret

0000000000000190 <stat>:

int
stat(const char *n, struct stat *st)
{
 190:	1101                	addi	sp,sp,-32
 192:	ec06                	sd	ra,24(sp)
 194:	e822                	sd	s0,16(sp)
 196:	e426                	sd	s1,8(sp)
 198:	e04a                	sd	s2,0(sp)
 19a:	1000                	addi	s0,sp,32
 19c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19e:	4581                	li	a1,0
 1a0:	00000097          	auipc	ra,0x0
 1a4:	172080e7          	jalr	370(ra) # 312 <open>
  if(fd < 0)
 1a8:	02054563          	bltz	a0,1d2 <stat+0x42>
 1ac:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ae:	85ca                	mv	a1,s2
 1b0:	00000097          	auipc	ra,0x0
 1b4:	17a080e7          	jalr	378(ra) # 32a <fstat>
 1b8:	892a                	mv	s2,a0
  close(fd);
 1ba:	8526                	mv	a0,s1
 1bc:	00000097          	auipc	ra,0x0
 1c0:	13e080e7          	jalr	318(ra) # 2fa <close>
  return r;
}
 1c4:	854a                	mv	a0,s2
 1c6:	60e2                	ld	ra,24(sp)
 1c8:	6442                	ld	s0,16(sp)
 1ca:	64a2                	ld	s1,8(sp)
 1cc:	6902                	ld	s2,0(sp)
 1ce:	6105                	addi	sp,sp,32
 1d0:	8082                	ret
    return -1;
 1d2:	597d                	li	s2,-1
 1d4:	bfc5                	j	1c4 <stat+0x34>

00000000000001d6 <atoi>:

int
atoi(const char *s)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1dc:	00054603          	lbu	a2,0(a0)
 1e0:	fd06079b          	addiw	a5,a2,-48
 1e4:	0ff7f793          	andi	a5,a5,255
 1e8:	4725                	li	a4,9
 1ea:	02f76963          	bltu	a4,a5,21c <atoi+0x46>
 1ee:	86aa                	mv	a3,a0
  n = 0;
 1f0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1f2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1f4:	0685                	addi	a3,a3,1
 1f6:	0025179b          	slliw	a5,a0,0x2
 1fa:	9fa9                	addw	a5,a5,a0
 1fc:	0017979b          	slliw	a5,a5,0x1
 200:	9fb1                	addw	a5,a5,a2
 202:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 206:	0006c603          	lbu	a2,0(a3)
 20a:	fd06071b          	addiw	a4,a2,-48
 20e:	0ff77713          	andi	a4,a4,255
 212:	fee5f1e3          	bgeu	a1,a4,1f4 <atoi+0x1e>
  return n;
}
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret
  n = 0;
 21c:	4501                	li	a0,0
 21e:	bfe5                	j	216 <atoi+0x40>

0000000000000220 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 220:	1141                	addi	sp,sp,-16
 222:	e422                	sd	s0,8(sp)
 224:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 226:	02b57463          	bgeu	a0,a1,24e <memmove+0x2e>
    while(n-- > 0)
 22a:	00c05f63          	blez	a2,248 <memmove+0x28>
 22e:	1602                	slli	a2,a2,0x20
 230:	9201                	srli	a2,a2,0x20
 232:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 236:	872a                	mv	a4,a0
      *dst++ = *src++;
 238:	0585                	addi	a1,a1,1
 23a:	0705                	addi	a4,a4,1
 23c:	fff5c683          	lbu	a3,-1(a1)
 240:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 244:	fee79ae3          	bne	a5,a4,238 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
    dst += n;
 24e:	00c50733          	add	a4,a0,a2
    src += n;
 252:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 254:	fec05ae3          	blez	a2,248 <memmove+0x28>
 258:	fff6079b          	addiw	a5,a2,-1
 25c:	1782                	slli	a5,a5,0x20
 25e:	9381                	srli	a5,a5,0x20
 260:	fff7c793          	not	a5,a5
 264:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 266:	15fd                	addi	a1,a1,-1
 268:	177d                	addi	a4,a4,-1
 26a:	0005c683          	lbu	a3,0(a1)
 26e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 272:	fee79ae3          	bne	a5,a4,266 <memmove+0x46>
 276:	bfc9                	j	248 <memmove+0x28>

0000000000000278 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 27e:	ca05                	beqz	a2,2ae <memcmp+0x36>
 280:	fff6069b          	addiw	a3,a2,-1
 284:	1682                	slli	a3,a3,0x20
 286:	9281                	srli	a3,a3,0x20
 288:	0685                	addi	a3,a3,1
 28a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 28c:	00054783          	lbu	a5,0(a0)
 290:	0005c703          	lbu	a4,0(a1)
 294:	00e79863          	bne	a5,a4,2a4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 298:	0505                	addi	a0,a0,1
    p2++;
 29a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 29c:	fed518e3          	bne	a0,a3,28c <memcmp+0x14>
  }
  return 0;
 2a0:	4501                	li	a0,0
 2a2:	a019                	j	2a8 <memcmp+0x30>
      return *p1 - *p2;
 2a4:	40e7853b          	subw	a0,a5,a4
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
  return 0;
 2ae:	4501                	li	a0,0
 2b0:	bfe5                	j	2a8 <memcmp+0x30>

00000000000002b2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e406                	sd	ra,8(sp)
 2b6:	e022                	sd	s0,0(sp)
 2b8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ba:	00000097          	auipc	ra,0x0
 2be:	f66080e7          	jalr	-154(ra) # 220 <memmove>
}
 2c2:	60a2                	ld	ra,8(sp)
 2c4:	6402                	ld	s0,0(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ca:	4885                	li	a7,1
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2d2:	4889                	li	a7,2
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <wait>:
.global wait
wait:
 li a7, SYS_wait
 2da:	488d                	li	a7,3
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2e2:	4891                	li	a7,4
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <read>:
.global read
read:
 li a7, SYS_read
 2ea:	4895                	li	a7,5
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <write>:
.global write
write:
 li a7, SYS_write
 2f2:	48c1                	li	a7,16
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <close>:
.global close
close:
 li a7, SYS_close
 2fa:	48d5                	li	a7,21
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <kill>:
.global kill
kill:
 li a7, SYS_kill
 302:	4899                	li	a7,6
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <exec>:
.global exec
exec:
 li a7, SYS_exec
 30a:	489d                	li	a7,7
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <open>:
.global open
open:
 li a7, SYS_open
 312:	48bd                	li	a7,15
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 31a:	48c5                	li	a7,17
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 322:	48c9                	li	a7,18
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 32a:	48a1                	li	a7,8
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <link>:
.global link
link:
 li a7, SYS_link
 332:	48cd                	li	a7,19
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 33a:	48d1                	li	a7,20
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 342:	48a5                	li	a7,9
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <dup>:
.global dup
dup:
 li a7, SYS_dup
 34a:	48a9                	li	a7,10
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 352:	48ad                	li	a7,11
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 35a:	48b1                	li	a7,12
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 362:	48b5                	li	a7,13
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 36a:	48b9                	li	a7,14
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 372:	48d9                	li	a7,22
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 37a:	48dd                	li	a7,23
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 382:	48e1                	li	a7,24
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
 38a:	48e5                	li	a7,25
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
 392:	48e9                	li	a7,26
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
 39a:	48ed                	li	a7,27
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
 3a2:	48f1                	li	a7,28
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3aa:	1101                	addi	sp,sp,-32
 3ac:	ec06                	sd	ra,24(sp)
 3ae:	e822                	sd	s0,16(sp)
 3b0:	1000                	addi	s0,sp,32
 3b2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b6:	4605                	li	a2,1
 3b8:	fef40593          	addi	a1,s0,-17
 3bc:	00000097          	auipc	ra,0x0
 3c0:	f36080e7          	jalr	-202(ra) # 2f2 <write>
}
 3c4:	60e2                	ld	ra,24(sp)
 3c6:	6442                	ld	s0,16(sp)
 3c8:	6105                	addi	sp,sp,32
 3ca:	8082                	ret

00000000000003cc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3cc:	7139                	addi	sp,sp,-64
 3ce:	fc06                	sd	ra,56(sp)
 3d0:	f822                	sd	s0,48(sp)
 3d2:	f426                	sd	s1,40(sp)
 3d4:	f04a                	sd	s2,32(sp)
 3d6:	ec4e                	sd	s3,24(sp)
 3d8:	0080                	addi	s0,sp,64
 3da:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3dc:	c299                	beqz	a3,3e2 <printint+0x16>
 3de:	0805c863          	bltz	a1,46e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3e2:	2581                	sext.w	a1,a1
  neg = 0;
 3e4:	4881                	li	a7,0
 3e6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ea:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ec:	2601                	sext.w	a2,a2
 3ee:	00000517          	auipc	a0,0x0
 3f2:	45a50513          	addi	a0,a0,1114 # 848 <digits>
 3f6:	883a                	mv	a6,a4
 3f8:	2705                	addiw	a4,a4,1
 3fa:	02c5f7bb          	remuw	a5,a1,a2
 3fe:	1782                	slli	a5,a5,0x20
 400:	9381                	srli	a5,a5,0x20
 402:	97aa                	add	a5,a5,a0
 404:	0007c783          	lbu	a5,0(a5)
 408:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 40c:	0005879b          	sext.w	a5,a1
 410:	02c5d5bb          	divuw	a1,a1,a2
 414:	0685                	addi	a3,a3,1
 416:	fec7f0e3          	bgeu	a5,a2,3f6 <printint+0x2a>
  if(neg)
 41a:	00088b63          	beqz	a7,430 <printint+0x64>
    buf[i++] = '-';
 41e:	fd040793          	addi	a5,s0,-48
 422:	973e                	add	a4,a4,a5
 424:	02d00793          	li	a5,45
 428:	fef70823          	sb	a5,-16(a4)
 42c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 430:	02e05863          	blez	a4,460 <printint+0x94>
 434:	fc040793          	addi	a5,s0,-64
 438:	00e78933          	add	s2,a5,a4
 43c:	fff78993          	addi	s3,a5,-1
 440:	99ba                	add	s3,s3,a4
 442:	377d                	addiw	a4,a4,-1
 444:	1702                	slli	a4,a4,0x20
 446:	9301                	srli	a4,a4,0x20
 448:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 44c:	fff94583          	lbu	a1,-1(s2)
 450:	8526                	mv	a0,s1
 452:	00000097          	auipc	ra,0x0
 456:	f58080e7          	jalr	-168(ra) # 3aa <putc>
  while(--i >= 0)
 45a:	197d                	addi	s2,s2,-1
 45c:	ff3918e3          	bne	s2,s3,44c <printint+0x80>
}
 460:	70e2                	ld	ra,56(sp)
 462:	7442                	ld	s0,48(sp)
 464:	74a2                	ld	s1,40(sp)
 466:	7902                	ld	s2,32(sp)
 468:	69e2                	ld	s3,24(sp)
 46a:	6121                	addi	sp,sp,64
 46c:	8082                	ret
    x = -xx;
 46e:	40b005bb          	negw	a1,a1
    neg = 1;
 472:	4885                	li	a7,1
    x = -xx;
 474:	bf8d                	j	3e6 <printint+0x1a>

0000000000000476 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 476:	7119                	addi	sp,sp,-128
 478:	fc86                	sd	ra,120(sp)
 47a:	f8a2                	sd	s0,112(sp)
 47c:	f4a6                	sd	s1,104(sp)
 47e:	f0ca                	sd	s2,96(sp)
 480:	ecce                	sd	s3,88(sp)
 482:	e8d2                	sd	s4,80(sp)
 484:	e4d6                	sd	s5,72(sp)
 486:	e0da                	sd	s6,64(sp)
 488:	fc5e                	sd	s7,56(sp)
 48a:	f862                	sd	s8,48(sp)
 48c:	f466                	sd	s9,40(sp)
 48e:	f06a                	sd	s10,32(sp)
 490:	ec6e                	sd	s11,24(sp)
 492:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 494:	0005c903          	lbu	s2,0(a1)
 498:	18090f63          	beqz	s2,636 <vprintf+0x1c0>
 49c:	8aaa                	mv	s5,a0
 49e:	8b32                	mv	s6,a2
 4a0:	00158493          	addi	s1,a1,1
  state = 0;
 4a4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4a6:	02500a13          	li	s4,37
      if(c == 'd'){
 4aa:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4ae:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4b2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4b6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ba:	00000b97          	auipc	s7,0x0
 4be:	38eb8b93          	addi	s7,s7,910 # 848 <digits>
 4c2:	a839                	j	4e0 <vprintf+0x6a>
        putc(fd, c);
 4c4:	85ca                	mv	a1,s2
 4c6:	8556                	mv	a0,s5
 4c8:	00000097          	auipc	ra,0x0
 4cc:	ee2080e7          	jalr	-286(ra) # 3aa <putc>
 4d0:	a019                	j	4d6 <vprintf+0x60>
    } else if(state == '%'){
 4d2:	01498f63          	beq	s3,s4,4f0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4d6:	0485                	addi	s1,s1,1
 4d8:	fff4c903          	lbu	s2,-1(s1)
 4dc:	14090d63          	beqz	s2,636 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4e0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4e4:	fe0997e3          	bnez	s3,4d2 <vprintf+0x5c>
      if(c == '%'){
 4e8:	fd479ee3          	bne	a5,s4,4c4 <vprintf+0x4e>
        state = '%';
 4ec:	89be                	mv	s3,a5
 4ee:	b7e5                	j	4d6 <vprintf+0x60>
      if(c == 'd'){
 4f0:	05878063          	beq	a5,s8,530 <vprintf+0xba>
      } else if(c == 'l') {
 4f4:	05978c63          	beq	a5,s9,54c <vprintf+0xd6>
      } else if(c == 'x') {
 4f8:	07a78863          	beq	a5,s10,568 <vprintf+0xf2>
      } else if(c == 'p') {
 4fc:	09b78463          	beq	a5,s11,584 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 500:	07300713          	li	a4,115
 504:	0ce78663          	beq	a5,a4,5d0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 508:	06300713          	li	a4,99
 50c:	0ee78e63          	beq	a5,a4,608 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 510:	11478863          	beq	a5,s4,620 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 514:	85d2                	mv	a1,s4
 516:	8556                	mv	a0,s5
 518:	00000097          	auipc	ra,0x0
 51c:	e92080e7          	jalr	-366(ra) # 3aa <putc>
        putc(fd, c);
 520:	85ca                	mv	a1,s2
 522:	8556                	mv	a0,s5
 524:	00000097          	auipc	ra,0x0
 528:	e86080e7          	jalr	-378(ra) # 3aa <putc>
      }
      state = 0;
 52c:	4981                	li	s3,0
 52e:	b765                	j	4d6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 530:	008b0913          	addi	s2,s6,8
 534:	4685                	li	a3,1
 536:	4629                	li	a2,10
 538:	000b2583          	lw	a1,0(s6)
 53c:	8556                	mv	a0,s5
 53e:	00000097          	auipc	ra,0x0
 542:	e8e080e7          	jalr	-370(ra) # 3cc <printint>
 546:	8b4a                	mv	s6,s2
      state = 0;
 548:	4981                	li	s3,0
 54a:	b771                	j	4d6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 54c:	008b0913          	addi	s2,s6,8
 550:	4681                	li	a3,0
 552:	4629                	li	a2,10
 554:	000b2583          	lw	a1,0(s6)
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	e72080e7          	jalr	-398(ra) # 3cc <printint>
 562:	8b4a                	mv	s6,s2
      state = 0;
 564:	4981                	li	s3,0
 566:	bf85                	j	4d6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 568:	008b0913          	addi	s2,s6,8
 56c:	4681                	li	a3,0
 56e:	4641                	li	a2,16
 570:	000b2583          	lw	a1,0(s6)
 574:	8556                	mv	a0,s5
 576:	00000097          	auipc	ra,0x0
 57a:	e56080e7          	jalr	-426(ra) # 3cc <printint>
 57e:	8b4a                	mv	s6,s2
      state = 0;
 580:	4981                	li	s3,0
 582:	bf91                	j	4d6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 584:	008b0793          	addi	a5,s6,8
 588:	f8f43423          	sd	a5,-120(s0)
 58c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 590:	03000593          	li	a1,48
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	e14080e7          	jalr	-492(ra) # 3aa <putc>
  putc(fd, 'x');
 59e:	85ea                	mv	a1,s10
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e08080e7          	jalr	-504(ra) # 3aa <putc>
 5aa:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ac:	03c9d793          	srli	a5,s3,0x3c
 5b0:	97de                	add	a5,a5,s7
 5b2:	0007c583          	lbu	a1,0(a5)
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	df2080e7          	jalr	-526(ra) # 3aa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5c0:	0992                	slli	s3,s3,0x4
 5c2:	397d                	addiw	s2,s2,-1
 5c4:	fe0914e3          	bnez	s2,5ac <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5c8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5cc:	4981                	li	s3,0
 5ce:	b721                	j	4d6 <vprintf+0x60>
        s = va_arg(ap, char*);
 5d0:	008b0993          	addi	s3,s6,8
 5d4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5d8:	02090163          	beqz	s2,5fa <vprintf+0x184>
        while(*s != 0){
 5dc:	00094583          	lbu	a1,0(s2)
 5e0:	c9a1                	beqz	a1,630 <vprintf+0x1ba>
          putc(fd, *s);
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	dc6080e7          	jalr	-570(ra) # 3aa <putc>
          s++;
 5ec:	0905                	addi	s2,s2,1
        while(*s != 0){
 5ee:	00094583          	lbu	a1,0(s2)
 5f2:	f9e5                	bnez	a1,5e2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5f4:	8b4e                	mv	s6,s3
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	bdf9                	j	4d6 <vprintf+0x60>
          s = "(null)";
 5fa:	00000917          	auipc	s2,0x0
 5fe:	24690913          	addi	s2,s2,582 # 840 <malloc+0x100>
        while(*s != 0){
 602:	02800593          	li	a1,40
 606:	bff1                	j	5e2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 608:	008b0913          	addi	s2,s6,8
 60c:	000b4583          	lbu	a1,0(s6)
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	d98080e7          	jalr	-616(ra) # 3aa <putc>
 61a:	8b4a                	mv	s6,s2
      state = 0;
 61c:	4981                	li	s3,0
 61e:	bd65                	j	4d6 <vprintf+0x60>
        putc(fd, c);
 620:	85d2                	mv	a1,s4
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	d86080e7          	jalr	-634(ra) # 3aa <putc>
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b565                	j	4d6 <vprintf+0x60>
        s = va_arg(ap, char*);
 630:	8b4e                	mv	s6,s3
      state = 0;
 632:	4981                	li	s3,0
 634:	b54d                	j	4d6 <vprintf+0x60>
    }
  }
}
 636:	70e6                	ld	ra,120(sp)
 638:	7446                	ld	s0,112(sp)
 63a:	74a6                	ld	s1,104(sp)
 63c:	7906                	ld	s2,96(sp)
 63e:	69e6                	ld	s3,88(sp)
 640:	6a46                	ld	s4,80(sp)
 642:	6aa6                	ld	s5,72(sp)
 644:	6b06                	ld	s6,64(sp)
 646:	7be2                	ld	s7,56(sp)
 648:	7c42                	ld	s8,48(sp)
 64a:	7ca2                	ld	s9,40(sp)
 64c:	7d02                	ld	s10,32(sp)
 64e:	6de2                	ld	s11,24(sp)
 650:	6109                	addi	sp,sp,128
 652:	8082                	ret

0000000000000654 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 654:	715d                	addi	sp,sp,-80
 656:	ec06                	sd	ra,24(sp)
 658:	e822                	sd	s0,16(sp)
 65a:	1000                	addi	s0,sp,32
 65c:	e010                	sd	a2,0(s0)
 65e:	e414                	sd	a3,8(s0)
 660:	e818                	sd	a4,16(s0)
 662:	ec1c                	sd	a5,24(s0)
 664:	03043023          	sd	a6,32(s0)
 668:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 66c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 670:	8622                	mv	a2,s0
 672:	00000097          	auipc	ra,0x0
 676:	e04080e7          	jalr	-508(ra) # 476 <vprintf>
}
 67a:	60e2                	ld	ra,24(sp)
 67c:	6442                	ld	s0,16(sp)
 67e:	6161                	addi	sp,sp,80
 680:	8082                	ret

0000000000000682 <printf>:

void
printf(const char *fmt, ...)
{
 682:	711d                	addi	sp,sp,-96
 684:	ec06                	sd	ra,24(sp)
 686:	e822                	sd	s0,16(sp)
 688:	1000                	addi	s0,sp,32
 68a:	e40c                	sd	a1,8(s0)
 68c:	e810                	sd	a2,16(s0)
 68e:	ec14                	sd	a3,24(s0)
 690:	f018                	sd	a4,32(s0)
 692:	f41c                	sd	a5,40(s0)
 694:	03043823          	sd	a6,48(s0)
 698:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 69c:	00840613          	addi	a2,s0,8
 6a0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6a4:	85aa                	mv	a1,a0
 6a6:	4505                	li	a0,1
 6a8:	00000097          	auipc	ra,0x0
 6ac:	dce080e7          	jalr	-562(ra) # 476 <vprintf>
}
 6b0:	60e2                	ld	ra,24(sp)
 6b2:	6442                	ld	s0,16(sp)
 6b4:	6125                	addi	sp,sp,96
 6b6:	8082                	ret

00000000000006b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b8:	1141                	addi	sp,sp,-16
 6ba:	e422                	sd	s0,8(sp)
 6bc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6be:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c2:	00000797          	auipc	a5,0x0
 6c6:	19e7b783          	ld	a5,414(a5) # 860 <freep>
 6ca:	a805                	j	6fa <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6cc:	4618                	lw	a4,8(a2)
 6ce:	9db9                	addw	a1,a1,a4
 6d0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d4:	6398                	ld	a4,0(a5)
 6d6:	6318                	ld	a4,0(a4)
 6d8:	fee53823          	sd	a4,-16(a0)
 6dc:	a091                	j	720 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6de:	ff852703          	lw	a4,-8(a0)
 6e2:	9e39                	addw	a2,a2,a4
 6e4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6e6:	ff053703          	ld	a4,-16(a0)
 6ea:	e398                	sd	a4,0(a5)
 6ec:	a099                	j	732 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ee:	6398                	ld	a4,0(a5)
 6f0:	00e7e463          	bltu	a5,a4,6f8 <free+0x40>
 6f4:	00e6ea63          	bltu	a3,a4,708 <free+0x50>
{
 6f8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fa:	fed7fae3          	bgeu	a5,a3,6ee <free+0x36>
 6fe:	6398                	ld	a4,0(a5)
 700:	00e6e463          	bltu	a3,a4,708 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 704:	fee7eae3          	bltu	a5,a4,6f8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 708:	ff852583          	lw	a1,-8(a0)
 70c:	6390                	ld	a2,0(a5)
 70e:	02059813          	slli	a6,a1,0x20
 712:	01c85713          	srli	a4,a6,0x1c
 716:	9736                	add	a4,a4,a3
 718:	fae60ae3          	beq	a2,a4,6cc <free+0x14>
    bp->s.ptr = p->s.ptr;
 71c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 720:	4790                	lw	a2,8(a5)
 722:	02061593          	slli	a1,a2,0x20
 726:	01c5d713          	srli	a4,a1,0x1c
 72a:	973e                	add	a4,a4,a5
 72c:	fae689e3          	beq	a3,a4,6de <free+0x26>
  } else
    p->s.ptr = bp;
 730:	e394                	sd	a3,0(a5)
  freep = p;
 732:	00000717          	auipc	a4,0x0
 736:	12f73723          	sd	a5,302(a4) # 860 <freep>
}
 73a:	6422                	ld	s0,8(sp)
 73c:	0141                	addi	sp,sp,16
 73e:	8082                	ret

0000000000000740 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 740:	7139                	addi	sp,sp,-64
 742:	fc06                	sd	ra,56(sp)
 744:	f822                	sd	s0,48(sp)
 746:	f426                	sd	s1,40(sp)
 748:	f04a                	sd	s2,32(sp)
 74a:	ec4e                	sd	s3,24(sp)
 74c:	e852                	sd	s4,16(sp)
 74e:	e456                	sd	s5,8(sp)
 750:	e05a                	sd	s6,0(sp)
 752:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 754:	02051493          	slli	s1,a0,0x20
 758:	9081                	srli	s1,s1,0x20
 75a:	04bd                	addi	s1,s1,15
 75c:	8091                	srli	s1,s1,0x4
 75e:	0014899b          	addiw	s3,s1,1
 762:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 764:	00000517          	auipc	a0,0x0
 768:	0fc53503          	ld	a0,252(a0) # 860 <freep>
 76c:	c515                	beqz	a0,798 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 76e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 770:	4798                	lw	a4,8(a5)
 772:	02977f63          	bgeu	a4,s1,7b0 <malloc+0x70>
 776:	8a4e                	mv	s4,s3
 778:	0009871b          	sext.w	a4,s3
 77c:	6685                	lui	a3,0x1
 77e:	00d77363          	bgeu	a4,a3,784 <malloc+0x44>
 782:	6a05                	lui	s4,0x1
 784:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 788:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 78c:	00000917          	auipc	s2,0x0
 790:	0d490913          	addi	s2,s2,212 # 860 <freep>
  if(p == (char*)-1)
 794:	5afd                	li	s5,-1
 796:	a895                	j	80a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 798:	00000797          	auipc	a5,0x0
 79c:	0d078793          	addi	a5,a5,208 # 868 <base>
 7a0:	00000717          	auipc	a4,0x0
 7a4:	0cf73023          	sd	a5,192(a4) # 860 <freep>
 7a8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7aa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ae:	b7e1                	j	776 <malloc+0x36>
      if(p->s.size == nunits)
 7b0:	02e48c63          	beq	s1,a4,7e8 <malloc+0xa8>
        p->s.size -= nunits;
 7b4:	4137073b          	subw	a4,a4,s3
 7b8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ba:	02071693          	slli	a3,a4,0x20
 7be:	01c6d713          	srli	a4,a3,0x1c
 7c2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7c4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c8:	00000717          	auipc	a4,0x0
 7cc:	08a73c23          	sd	a0,152(a4) # 860 <freep>
      return (void*)(p + 1);
 7d0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7d4:	70e2                	ld	ra,56(sp)
 7d6:	7442                	ld	s0,48(sp)
 7d8:	74a2                	ld	s1,40(sp)
 7da:	7902                	ld	s2,32(sp)
 7dc:	69e2                	ld	s3,24(sp)
 7de:	6a42                	ld	s4,16(sp)
 7e0:	6aa2                	ld	s5,8(sp)
 7e2:	6b02                	ld	s6,0(sp)
 7e4:	6121                	addi	sp,sp,64
 7e6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e8:	6398                	ld	a4,0(a5)
 7ea:	e118                	sd	a4,0(a0)
 7ec:	bff1                	j	7c8 <malloc+0x88>
  hp->s.size = nu;
 7ee:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7f2:	0541                	addi	a0,a0,16
 7f4:	00000097          	auipc	ra,0x0
 7f8:	ec4080e7          	jalr	-316(ra) # 6b8 <free>
  return freep;
 7fc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 800:	d971                	beqz	a0,7d4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 802:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 804:	4798                	lw	a4,8(a5)
 806:	fa9775e3          	bgeu	a4,s1,7b0 <malloc+0x70>
    if(p == freep)
 80a:	00093703          	ld	a4,0(s2)
 80e:	853e                	mv	a0,a5
 810:	fef719e3          	bne	a4,a5,802 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 814:	8552                	mv	a0,s4
 816:	00000097          	auipc	ra,0x0
 81a:	b44080e7          	jalr	-1212(ra) # 35a <sbrk>
  if(p == (char*)-1)
 81e:	fd5518e3          	bne	a0,s5,7ee <malloc+0xae>
        return 0;
 822:	4501                	li	a0,0
 824:	bf45                	j	7d4 <malloc+0x94>
