
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	addi	sp,sp,384 # 80009180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	25c78793          	addi	a5,a5,604 # 800062c0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd27ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dbe78793          	addi	a5,a5,-578 # 80000e6c <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	416080e7          	jalr	1046(ra) # 80002534 <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77a080e7          	jalr	1914(ra) # 800008a8 <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7159                	addi	sp,sp,-112
    80000158:	f486                	sd	ra,104(sp)
    8000015a:	f0a2                	sd	s0,96(sp)
    8000015c:	eca6                	sd	s1,88(sp)
    8000015e:	e8ca                	sd	s2,80(sp)
    80000160:	e4ce                	sd	s3,72(sp)
    80000162:	e0d2                	sd	s4,64(sp)
    80000164:	fc56                	sd	s5,56(sp)
    80000166:	f85a                	sd	s6,48(sp)
    80000168:	f45e                	sd	s7,40(sp)
    8000016a:	f062                	sd	s8,32(sp)
    8000016c:	ec66                	sd	s9,24(sp)
    8000016e:	e86a                	sd	s10,16(sp)
    80000170:	1880                	addi	s0,sp,112
    80000172:	8aaa                	mv	s5,a0
    80000174:	8a2e                	mv	s4,a1
    80000176:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00011917          	auipc	s2,0x11
    80000198:	08490913          	addi	s2,s2,132 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000019e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4ca9                	li	s9,10
  while(n > 0){
    800001a2:	07305863          	blez	s3,80000212 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71463          	bne	a4,a5,800001d6 <consoleread+0x80>
      if(myproc()->killed){
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	802080e7          	jalr	-2046(ra) # 800019b4 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	f6a080e7          	jalr	-150(ra) # 8000212c <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef700e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d6:	0017871b          	addiw	a4,a5,1
    800001da:	08e4ac23          	sw	a4,152(s1)
    800001de:	07f7f713          	andi	a4,a5,127
    800001e2:	9726                	add	a4,a4,s1
    800001e4:	01874703          	lbu	a4,24(a4)
    800001e8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ec:	077d0563          	beq	s10,s7,80000256 <consoleread+0x100>
    cbuf = c;
    800001f0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	f9f40613          	addi	a2,s0,-97
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00002097          	auipc	ra,0x2
    80000202:	2e0080e7          	jalr	736(ra) # 800024de <either_copyout>
    80000206:	01850663          	beq	a0,s8,80000212 <consoleread+0xbc>
    dst++;
    8000020a:	0a05                	addi	s4,s4,1
    --n;
    8000020c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000020e:	f99d1ae3          	bne	s10,s9,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000212:	00011517          	auipc	a0,0x11
    80000216:	f6e50513          	addi	a0,a0,-146 # 80011180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	f5850513          	addi	a0,a0,-168 # 80011180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
        return -1;
    80000238:	557d                	li	a0,-1
}
    8000023a:	70a6                	ld	ra,104(sp)
    8000023c:	7406                	ld	s0,96(sp)
    8000023e:	64e6                	ld	s1,88(sp)
    80000240:	6946                	ld	s2,80(sp)
    80000242:	69a6                	ld	s3,72(sp)
    80000244:	6a06                	ld	s4,64(sp)
    80000246:	7ae2                	ld	s5,56(sp)
    80000248:	7b42                	ld	s6,48(sp)
    8000024a:	7ba2                	ld	s7,40(sp)
    8000024c:	7c02                	ld	s8,32(sp)
    8000024e:	6ce2                	ld	s9,24(sp)
    80000250:	6d42                	ld	s10,16(sp)
    80000252:	6165                	addi	sp,sp,112
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	fb677ce3          	bgeu	a4,s6,80000212 <consoleread+0xbc>
        cons.r--;
    8000025e:	00011717          	auipc	a4,0x11
    80000262:	faf72d23          	sw	a5,-70(a4) # 80011218 <cons+0x98>
    80000266:	b775                	j	80000212 <consoleread+0xbc>

0000000080000268 <consputc>:
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e406                	sd	ra,8(sp)
    8000026c:	e022                	sd	s0,0(sp)
    8000026e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000270:	10000793          	li	a5,256
    80000274:	00f50a63          	beq	a0,a5,80000288 <consputc+0x20>
    uartputc_sync(c);
    80000278:	00000097          	auipc	ra,0x0
    8000027c:	55e080e7          	jalr	1374(ra) # 800007d6 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	54c080e7          	jalr	1356(ra) # 800007d6 <uartputc_sync>
    80000292:	02000513          	li	a0,32
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	540080e7          	jalr	1344(ra) # 800007d6 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	536080e7          	jalr	1334(ra) # 800007d6 <uartputc_sync>
    800002a8:	bfe1                	j	80000280 <consputc+0x18>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	e04a                	sd	s2,0(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00011517          	auipc	a0,0x11
    800002bc:	ec850513          	addi	a0,a0,-312 # 80011180 <cons>
    800002c0:	00001097          	auipc	ra,0x1
    800002c4:	902080e7          	jalr	-1790(ra) # 80000bc2 <acquire>

  switch(c){
    800002c8:	47d5                	li	a5,21
    800002ca:	0af48663          	beq	s1,a5,80000376 <consoleintr+0xcc>
    800002ce:	0297ca63          	blt	a5,s1,80000302 <consoleintr+0x58>
    800002d2:	47a1                	li	a5,8
    800002d4:	0ef48763          	beq	s1,a5,800003c2 <consoleintr+0x118>
    800002d8:	47c1                	li	a5,16
    800002da:	10f49a63          	bne	s1,a5,800003ee <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002de:	00002097          	auipc	ra,0x2
    800002e2:	2ac080e7          	jalr	684(ra) # 8000258a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00011517          	auipc	a0,0x11
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80011180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
}
    800002f6:	60e2                	ld	ra,24(sp)
    800002f8:	6442                	ld	s0,16(sp)
    800002fa:	64a2                	ld	s1,8(sp)
    800002fc:	6902                	ld	s2,0(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch(c){
    80000302:	07f00793          	li	a5,127
    80000306:	0af48e63          	beq	s1,a5,800003c2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030a:	00011717          	auipc	a4,0x11
    8000030e:	e7670713          	addi	a4,a4,-394 # 80011180 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf763e3          	bltu	a4,a5,800002e6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x14a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f3c080e7          	jalr	-196(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000334:	00011797          	auipc	a5,0x11
    80000338:	e4c78793          	addi	a5,a5,-436 # 80011180 <cons>
    8000033c:	0a07a703          	lw	a4,160(a5)
    80000340:	0017069b          	addiw	a3,a4,1
    80000344:	0006861b          	sext.w	a2,a3
    80000348:	0ad7a023          	sw	a3,160(a5)
    8000034c:	07f77713          	andi	a4,a4,127
    80000350:	97ba                	add	a5,a5,a4
    80000352:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000356:	47a9                	li	a5,10
    80000358:	0cf48563          	beq	s1,a5,80000422 <consoleintr+0x178>
    8000035c:	4791                	li	a5,4
    8000035e:	0cf48263          	beq	s1,a5,80000422 <consoleintr+0x178>
    80000362:	00011797          	auipc	a5,0x11
    80000366:	eb67a783          	lw	a5,-330(a5) # 80011218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00011717          	auipc	a4,0x11
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80011180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00011497          	auipc	s1,0x11
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80011180 <cons>
    while(cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
    80000390:	f4f70be3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	f52703e3          	beq	a4,s2,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	10000513          	li	a0,256
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	ebc080e7          	jalr	-324(ra) # 80000268 <consputc>
    while(cons.e != cons.w &&
    800003b4:	0a04a783          	lw	a5,160(s1)
    800003b8:	09c4a703          	lw	a4,156(s1)
    800003bc:	fcf71ce3          	bne	a4,a5,80000394 <consoleintr+0xea>
    800003c0:	b71d                	j	800002e6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c2:	00011717          	auipc	a4,0x11
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80011180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00011717          	auipc	a4,0x11
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e0:	10000513          	li	a0,256
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	e84080e7          	jalr	-380(ra) # 80000268 <consputc>
    800003ec:	bded                	j	800002e6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003ee:	ee048ce3          	beqz	s1,800002e6 <consoleintr+0x3c>
    800003f2:	bf21                	j	8000030a <consoleintr+0x60>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e72080e7          	jalr	-398(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003fe:	00011797          	auipc	a5,0x11
    80000402:	d8278793          	addi	a5,a5,-638 # 80011180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00011797          	auipc	a5,0x11
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00011517          	auipc	a0,0x11
    8000042e:	dee50513          	addi	a0,a0,-530 # 80011218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	e86080e7          	jalr	-378(ra) # 800022b8 <wakeup>
    8000043a:	b575                	j	800002e6 <consoleintr+0x3c>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00008597          	auipc	a1,0x8
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80008010 <etext+0x10>
    8000044c:	00011517          	auipc	a0,0x11
    80000450:	d3450513          	addi	a0,a0,-716 # 80011180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	00027797          	auipc	a5,0x27
    80000468:	6b478793          	addi	a5,a5,1716 # 80027b18 <devsw>
    8000046c:	00000717          	auipc	a4,0x0
    80000470:	cea70713          	addi	a4,a4,-790 # 80000156 <consoleread>
    80000474:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000476:	00000717          	auipc	a4,0x0
    8000047a:	c7e70713          	addi	a4,a4,-898 # 800000f4 <consolewrite>
    8000047e:	ef98                	sd	a4,24(a5)
}
    80000480:	60a2                	ld	ra,8(sp)
    80000482:	6402                	ld	s0,0(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000488:	7179                	addi	sp,sp,-48
    8000048a:	f406                	sd	ra,40(sp)
    8000048c:	f022                	sd	s0,32(sp)
    8000048e:	ec26                	sd	s1,24(sp)
    80000490:	e84a                	sd	s2,16(sp)
    80000492:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000494:	c219                	beqz	a2,8000049a <printint+0x12>
    80000496:	08054663          	bltz	a0,80000522 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049a:	2501                	sext.w	a0,a0
    8000049c:	4881                	li	a7,0
    8000049e:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a4:	2581                	sext.w	a1,a1
    800004a6:	00008617          	auipc	a2,0x8
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80008040 <digits>
    800004ae:	883a                	mv	a6,a4
    800004b0:	2705                	addiw	a4,a4,1
    800004b2:	02b577bb          	remuw	a5,a0,a1
    800004b6:	1782                	slli	a5,a5,0x20
    800004b8:	9381                	srli	a5,a5,0x20
    800004ba:	97b2                	add	a5,a5,a2
    800004bc:	0007c783          	lbu	a5,0(a5)
    800004c0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c4:	0005079b          	sext.w	a5,a0
    800004c8:	02b5553b          	divuw	a0,a0,a1
    800004cc:	0685                	addi	a3,a3,1
    800004ce:	feb7f0e3          	bgeu	a5,a1,800004ae <printint+0x26>

  if(sign)
    800004d2:	00088b63          	beqz	a7,800004e8 <printint+0x60>
    buf[i++] = '-';
    800004d6:	fe040793          	addi	a5,s0,-32
    800004da:	973e                	add	a4,a4,a5
    800004dc:	02d00793          	li	a5,45
    800004e0:	fef70823          	sb	a5,-16(a4)
    800004e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004e8:	02e05763          	blez	a4,80000516 <printint+0x8e>
    800004ec:	fd040793          	addi	a5,s0,-48
    800004f0:	00e784b3          	add	s1,a5,a4
    800004f4:	fff78913          	addi	s2,a5,-1
    800004f8:	993a                	add	s2,s2,a4
    800004fa:	377d                	addiw	a4,a4,-1
    800004fc:	1702                	slli	a4,a4,0x20
    800004fe:	9301                	srli	a4,a4,0x20
    80000500:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000504:	fff4c503          	lbu	a0,-1(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d60080e7          	jalr	-672(ra) # 80000268 <consputc>
  while(--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x7c>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
    x = -xx;
    80000522:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000526:	4885                	li	a7,1
    x = -xx;
    80000528:	bf9d                	j	8000049e <printint+0x16>

000000008000052a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052a:	1101                	addi	sp,sp,-32
    8000052c:	ec06                	sd	ra,24(sp)
    8000052e:	e822                	sd	s0,16(sp)
    80000530:	e426                	sd	s1,8(sp)
    80000532:	1000                	addi	s0,sp,32
    80000534:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000536:	00011797          	auipc	a5,0x11
    8000053a:	d007a523          	sw	zero,-758(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000053e:	00008517          	auipc	a0,0x8
    80000542:	ada50513          	addi	a0,a0,-1318 # 80008018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	d9050513          	addi	a0,a0,-624 # 800082e8 <digits+0x2a8>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	00009717          	auipc	a4,0x9
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 80009000 <panicked>
  for(;;)
    80000572:	a001                	j	80000572 <panic+0x48>

0000000080000574 <printf>:
{
    80000574:	7131                	addi	sp,sp,-192
    80000576:	fc86                	sd	ra,120(sp)
    80000578:	f8a2                	sd	s0,112(sp)
    8000057a:	f4a6                	sd	s1,104(sp)
    8000057c:	f0ca                	sd	s2,96(sp)
    8000057e:	ecce                	sd	s3,88(sp)
    80000580:	e8d2                	sd	s4,80(sp)
    80000582:	e4d6                	sd	s5,72(sp)
    80000584:	e0da                	sd	s6,64(sp)
    80000586:	fc5e                	sd	s7,56(sp)
    80000588:	f862                	sd	s8,48(sp)
    8000058a:	f466                	sd	s9,40(sp)
    8000058c:	f06a                	sd	s10,32(sp)
    8000058e:	ec6e                	sd	s11,24(sp)
    80000590:	0100                	addi	s0,sp,128
    80000592:	8a2a                	mv	s4,a0
    80000594:	e40c                	sd	a1,8(s0)
    80000596:	e810                	sd	a2,16(s0)
    80000598:	ec14                	sd	a3,24(s0)
    8000059a:	f018                	sd	a4,32(s0)
    8000059c:	f41c                	sd	a5,40(s0)
    8000059e:	03043823          	sd	a6,48(s0)
    800005a2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005a6:	00011d97          	auipc	s11,0x11
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80011240 <pr+0x18>
  if(locking)
    800005ae:	020d9b63          	bnez	s11,800005e4 <printf+0x70>
  if (fmt == 0)
    800005b2:	040a0263          	beqz	s4,800005f6 <printf+0x82>
  va_start(ap, fmt);
    800005b6:	00840793          	addi	a5,s0,8
    800005ba:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005be:	000a4503          	lbu	a0,0(s4)
    800005c2:	14050f63          	beqz	a0,80000720 <printf+0x1ac>
    800005c6:	4981                	li	s3,0
    if(c != '%'){
    800005c8:	02500a93          	li	s5,37
    switch(c){
    800005cc:	07000b93          	li	s7,112
  consputc('x');
    800005d0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d2:	00008b17          	auipc	s6,0x8
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80008040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00011517          	auipc	a0,0x11
    800005e8:	c4450513          	addi	a0,a0,-956 # 80011228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00008517          	auipc	a0,0x8
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80008028 <etext+0x28>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
      consputc(c);
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	c62080e7          	jalr	-926(ra) # 80000268 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060e:	2985                	addiw	s3,s3,1
    80000610:	013a07b3          	add	a5,s4,s3
    80000614:	0007c503          	lbu	a0,0(a5)
    80000618:	10050463          	beqz	a0,80000720 <printf+0x1ac>
    if(c != '%'){
    8000061c:	ff5515e3          	bne	a0,s5,80000606 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c783          	lbu	a5,0(a5)
    8000062a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000062e:	cbed                	beqz	a5,80000720 <printf+0x1ac>
    switch(c){
    80000630:	05778a63          	beq	a5,s7,80000684 <printf+0x110>
    80000634:	02fbf663          	bgeu	s7,a5,80000660 <printf+0xec>
    80000638:	09978863          	beq	a5,s9,800006c8 <printf+0x154>
    8000063c:	07800713          	li	a4,120
    80000640:	0ce79563          	bne	a5,a4,8000070a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	85ea                	mv	a1,s10
    80000654:	4388                	lw	a0,0(a5)
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	e32080e7          	jalr	-462(ra) # 80000488 <printint>
      break;
    8000065e:	bf45                	j	8000060e <printf+0x9a>
    switch(c){
    80000660:	09578f63          	beq	a5,s5,800006fe <printf+0x18a>
    80000664:	0b879363          	bne	a5,s8,8000070a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	45a9                	li	a1,10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e0e080e7          	jalr	-498(ra) # 80000488 <printint>
      break;
    80000682:	b771                	j	8000060e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000694:	03000513          	li	a0,48
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	bd0080e7          	jalr	-1072(ra) # 80000268 <consputc>
  consputc('x');
    800006a0:	07800513          	li	a0,120
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	bc4080e7          	jalr	-1084(ra) # 80000268 <consputc>
    800006ac:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ae:	03c95793          	srli	a5,s2,0x3c
    800006b2:	97da                	add	a5,a5,s6
    800006b4:	0007c503          	lbu	a0,0(a5)
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bb0080e7          	jalr	-1104(ra) # 80000268 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c0:	0912                	slli	s2,s2,0x4
    800006c2:	34fd                	addiw	s1,s1,-1
    800006c4:	f4ed                	bnez	s1,800006ae <printf+0x13a>
    800006c6:	b7a1                	j	8000060e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	6384                	ld	s1,0(a5)
    800006d6:	cc89                	beqz	s1,800006f0 <printf+0x17c>
      for(; *s; s++)
    800006d8:	0004c503          	lbu	a0,0(s1)
    800006dc:	d90d                	beqz	a0,8000060e <printf+0x9a>
        consputc(*s);
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b8a080e7          	jalr	-1142(ra) # 80000268 <consputc>
      for(; *s; s++)
    800006e6:	0485                	addi	s1,s1,1
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	f96d                	bnez	a0,800006de <printf+0x16a>
    800006ee:	b705                	j	8000060e <printf+0x9a>
        s = "(null)";
    800006f0:	00008497          	auipc	s1,0x8
    800006f4:	93048493          	addi	s1,s1,-1744 # 80008020 <etext+0x20>
      for(; *s; s++)
    800006f8:	02800513          	li	a0,40
    800006fc:	b7cd                	j	800006de <printf+0x16a>
      consputc('%');
    800006fe:	8556                	mv	a0,s5
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b68080e7          	jalr	-1176(ra) # 80000268 <consputc>
      break;
    80000708:	b719                	j	8000060e <printf+0x9a>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b5c080e7          	jalr	-1188(ra) # 80000268 <consputc>
      consputc(c);
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b52080e7          	jalr	-1198(ra) # 80000268 <consputc>
      break;
    8000071e:	bdc5                	j	8000060e <printf+0x9a>
  if(locking)
    80000720:	020d9163          	bnez	s11,80000742 <printf+0x1ce>
}
    80000724:	70e6                	ld	ra,120(sp)
    80000726:	7446                	ld	s0,112(sp)
    80000728:	74a6                	ld	s1,104(sp)
    8000072a:	7906                	ld	s2,96(sp)
    8000072c:	69e6                	ld	s3,88(sp)
    8000072e:	6a46                	ld	s4,80(sp)
    80000730:	6aa6                	ld	s5,72(sp)
    80000732:	6b06                	ld	s6,64(sp)
    80000734:	7be2                	ld	s7,56(sp)
    80000736:	7c42                	ld	s8,48(sp)
    80000738:	7ca2                	ld	s9,40(sp)
    8000073a:	7d02                	ld	s10,32(sp)
    8000073c:	6de2                	ld	s11,24(sp)
    8000073e:	6129                	addi	sp,sp,192
    80000740:	8082                	ret
    release(&pr.lock);
    80000742:	00011517          	auipc	a0,0x11
    80000746:	ae650513          	addi	a0,a0,-1306 # 80011228 <pr>
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	52c080e7          	jalr	1324(ra) # 80000c76 <release>
}
    80000752:	bfc9                	j	80000724 <printf+0x1b0>

0000000080000754 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000754:	1101                	addi	sp,sp,-32
    80000756:	ec06                	sd	ra,24(sp)
    80000758:	e822                	sd	s0,16(sp)
    8000075a:	e426                	sd	s1,8(sp)
    8000075c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000075e:	00011497          	auipc	s1,0x11
    80000762:	aca48493          	addi	s1,s1,-1334 # 80011228 <pr>
    80000766:	00008597          	auipc	a1,0x8
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80008038 <etext+0x38>
    8000076e:	8526                	mv	a0,s1
    80000770:	00000097          	auipc	ra,0x0
    80000774:	3c2080e7          	jalr	962(ra) # 80000b32 <initlock>
  pr.locking = 1;
    80000778:	4785                	li	a5,1
    8000077a:	cc9c                	sw	a5,24(s1)
}
    8000077c:	60e2                	ld	ra,24(sp)
    8000077e:	6442                	ld	s0,16(sp)
    80000780:	64a2                	ld	s1,8(sp)
    80000782:	6105                	addi	sp,sp,32
    80000784:	8082                	ret

0000000080000786 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000786:	1141                	addi	sp,sp,-16
    80000788:	e406                	sd	ra,8(sp)
    8000078a:	e022                	sd	s0,0(sp)
    8000078c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000078e:	100007b7          	lui	a5,0x10000
    80000792:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000796:	f8000713          	li	a4,-128
    8000079a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000079e:	470d                	li	a4,3
    800007a0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007a8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ac:	469d                	li	a3,7
    800007ae:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007b6:	00008597          	auipc	a1,0x8
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80008058 <digits+0x18>
    800007be:	00011517          	auipc	a0,0x11
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80011248 <uart_tx_lock>
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	36c080e7          	jalr	876(ra) # 80000b32 <initlock>
}
    800007ce:	60a2                	ld	ra,8(sp)
    800007d0:	6402                	ld	s0,0(sp)
    800007d2:	0141                	addi	sp,sp,16
    800007d4:	8082                	ret

00000000800007d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  push_off();
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	394080e7          	jalr	916(ra) # 80000b76 <push_off>

  if(panicked){
    800007ea:	00009797          	auipc	a5,0x9
    800007ee:	8167a783          	lw	a5,-2026(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800007f6:	c391                	beqz	a5,800007fa <uartputc_sync+0x24>
    for(;;)
    800007f8:	a001                	j	800007f8 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fa:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007fe:	0207f793          	andi	a5,a5,32
    80000802:	dfe5                	beqz	a5,800007fa <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000804:	0ff4f513          	andi	a0,s1,255
    80000808:	100007b7          	lui	a5,0x10000
    8000080c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000810:	00000097          	auipc	ra,0x0
    80000814:	406080e7          	jalr	1030(ra) # 80000c16 <pop_off>
}
    80000818:	60e2                	ld	ra,24(sp)
    8000081a:	6442                	ld	s0,16(sp)
    8000081c:	64a2                	ld	s1,8(sp)
    8000081e:	6105                	addi	sp,sp,32
    80000820:	8082                	ret

0000000080000822 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000822:	00008797          	auipc	a5,0x8
    80000826:	7e67b783          	ld	a5,2022(a5) # 80009008 <uart_tx_r>
    8000082a:	00008717          	auipc	a4,0x8
    8000082e:	7e673703          	ld	a4,2022(a4) # 80009010 <uart_tx_w>
    80000832:	06f70a63          	beq	a4,a5,800008a6 <uartstart+0x84>
{
    80000836:	7139                	addi	sp,sp,-64
    80000838:	fc06                	sd	ra,56(sp)
    8000083a:	f822                	sd	s0,48(sp)
    8000083c:	f426                	sd	s1,40(sp)
    8000083e:	f04a                	sd	s2,32(sp)
    80000840:	ec4e                	sd	s3,24(sp)
    80000842:	e852                	sd	s4,16(sp)
    80000844:	e456                	sd	s5,8(sp)
    80000846:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000848:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000084c:	00011a17          	auipc	s4,0x11
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00008497          	auipc	s1,0x8
    80000858:	7b448493          	addi	s1,s1,1972 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00008997          	auipc	s3,0x8
    80000860:	7b498993          	addi	s3,s3,1972 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000868:	02077713          	andi	a4,a4,32
    8000086c:	c705                	beqz	a4,80000894 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086e:	01f7f713          	andi	a4,a5,31
    80000872:	9752                	add	a4,a4,s4
    80000874:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000878:	0785                	addi	a5,a5,1
    8000087a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000087c:	8526                	mv	a0,s1
    8000087e:	00002097          	auipc	ra,0x2
    80000882:	a3a080e7          	jalr	-1478(ra) # 800022b8 <wakeup>
    
    WriteReg(THR, c);
    80000886:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088a:	609c                	ld	a5,0(s1)
    8000088c:	0009b703          	ld	a4,0(s3)
    80000890:	fcf71ae3          	bne	a4,a5,80000864 <uartstart+0x42>
  }
}
    80000894:	70e2                	ld	ra,56(sp)
    80000896:	7442                	ld	s0,48(sp)
    80000898:	74a2                	ld	s1,40(sp)
    8000089a:	7902                	ld	s2,32(sp)
    8000089c:	69e2                	ld	s3,24(sp)
    8000089e:	6a42                	ld	s4,16(sp)
    800008a0:	6aa2                	ld	s5,8(sp)
    800008a2:	6121                	addi	sp,sp,64
    800008a4:	8082                	ret
    800008a6:	8082                	ret

00000000800008a8 <uartputc>:
{
    800008a8:	7179                	addi	sp,sp,-48
    800008aa:	f406                	sd	ra,40(sp)
    800008ac:	f022                	sd	s0,32(sp)
    800008ae:	ec26                	sd	s1,24(sp)
    800008b0:	e84a                	sd	s2,16(sp)
    800008b2:	e44e                	sd	s3,8(sp)
    800008b4:	e052                	sd	s4,0(sp)
    800008b6:	1800                	addi	s0,sp,48
    800008b8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ba:	00011517          	auipc	a0,0x11
    800008be:	98e50513          	addi	a0,a0,-1650 # 80011248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00008797          	auipc	a5,0x8
    800008ce:	7367a783          	lw	a5,1846(a5) # 80009000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00008717          	auipc	a4,0x8
    800008da:	73a73703          	ld	a4,1850(a4) # 80009010 <uart_tx_w>
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	72a7b783          	ld	a5,1834(a5) # 80009008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00011997          	auipc	s3,0x11
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80011248 <uart_tx_lock>
    800008f6:	00008497          	auipc	s1,0x8
    800008fa:	71248493          	addi	s1,s1,1810 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00008917          	auipc	s2,0x8
    80000902:	71290913          	addi	s2,s2,1810 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	822080e7          	jalr	-2014(ra) # 8000212c <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00011497          	auipc	s1,0x11
    80000924:	92848493          	addi	s1,s1,-1752 # 80011248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00008797          	auipc	a5,0x8
    80000938:	6ce7be23          	sd	a4,1756(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	ee6080e7          	jalr	-282(ra) # 80000822 <uartstart>
      release(&uart_tx_lock);
    80000944:	8526                	mv	a0,s1
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	330080e7          	jalr	816(ra) # 80000c76 <release>
}
    8000094e:	70a2                	ld	ra,40(sp)
    80000950:	7402                	ld	s0,32(sp)
    80000952:	64e2                	ld	s1,24(sp)
    80000954:	6942                	ld	s2,16(sp)
    80000956:	69a2                	ld	s3,8(sp)
    80000958:	6a02                	ld	s4,0(sp)
    8000095a:	6145                	addi	sp,sp,48
    8000095c:	8082                	ret

000000008000095e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000095e:	1141                	addi	sp,sp,-16
    80000960:	e422                	sd	s0,8(sp)
    80000962:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000964:	100007b7          	lui	a5,0x10000
    80000968:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000096c:	8b85                	andi	a5,a5,1
    8000096e:	cb91                	beqz	a5,80000982 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000970:	100007b7          	lui	a5,0x10000
    80000974:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000978:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000097c:	6422                	ld	s0,8(sp)
    8000097e:	0141                	addi	sp,sp,16
    80000980:	8082                	ret
    return -1;
    80000982:	557d                	li	a0,-1
    80000984:	bfe5                	j	8000097c <uartgetc+0x1e>

0000000080000986 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000990:	54fd                	li	s1,-1
    80000992:	a029                	j	8000099c <uartintr+0x16>
      break;
    consoleintr(c);
    80000994:	00000097          	auipc	ra,0x0
    80000998:	916080e7          	jalr	-1770(ra) # 800002aa <consoleintr>
    int c = uartgetc();
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	fc2080e7          	jalr	-62(ra) # 8000095e <uartgetc>
    if(c == -1)
    800009a4:	fe9518e3          	bne	a0,s1,80000994 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009a8:	00011497          	auipc	s1,0x11
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80011248 <uart_tx_lock>
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	210080e7          	jalr	528(ra) # 80000bc2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    800009ea:	0002b797          	auipc	a5,0x2b
    800009ee:	61678793          	addi	a5,a5,1558 # 8002c000 <end>
    800009f2:	04f56563          	bltu	a0,a5,80000a3c <kfree+0x66>
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	04f57163          	bgeu	a0,a5,80000a3c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2bc080e7          	jalr	700(ra) # 80000cbe <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00011917          	auipc	s2,0x11
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80011280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ae080e7          	jalr	430(ra) # 80000bc2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00007517          	auipc	a0,0x7
    80000a40:	62450513          	addi	a0,a0,1572 # 80008060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>

0000000080000a4c <freerange>:
{
    80000a4c:	7179                	addi	sp,sp,-48
    80000a4e:	f406                	sd	ra,40(sp)
    80000a50:	f022                	sd	s0,32(sp)
    80000a52:	ec26                	sd	s1,24(sp)
    80000a54:	e84a                	sd	s2,16(sp)
    80000a56:	e44e                	sd	s3,8(sp)
    80000a58:	e052                	sd	s4,0(sp)
    80000a5a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a5c:	6785                	lui	a5,0x1
    80000a5e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a62:	94aa                	add	s1,s1,a0
    80000a64:	757d                	lui	a0,0xfffff
    80000a66:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a68:	94be                	add	s1,s1,a5
    80000a6a:	0095ee63          	bltu	a1,s1,80000a86 <freerange+0x3a>
    80000a6e:	892e                	mv	s2,a1
    kfree(p);
    80000a70:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a72:	6985                	lui	s3,0x1
    kfree(p);
    80000a74:	01448533          	add	a0,s1,s4
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	f5e080e7          	jalr	-162(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe9979e3          	bgeu	s2,s1,80000a74 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00007597          	auipc	a1,0x7
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80008068 <digits+0x28>
    80000aa6:	00010517          	auipc	a0,0x10
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80011280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	0002b517          	auipc	a0,0x2b
    80000abe:	54650513          	addi	a0,a0,1350 # 8002c000 <end>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f8a080e7          	jalr	-118(ra) # 80000a4c <freerange>
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret

0000000080000ad2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000adc:	00010497          	auipc	s1,0x10
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80011280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00010517          	auipc	a0,0x10
    80000af8:	78c50513          	addi	a0,a0,1932 # 80011280 <kmem>
    80000afc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	178080e7          	jalr	376(ra) # 80000c76 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b06:	6605                	lui	a2,0x1
    80000b08:	4595                	li	a1,5
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1b2080e7          	jalr	434(ra) # 80000cbe <memset>
  return (void*)r;
}
    80000b14:	8526                	mv	a0,s1
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret
  release(&kmem.lock);
    80000b20:	00010517          	auipc	a0,0x10
    80000b24:	76050513          	addi	a0,a0,1888 # 80011280 <kmem>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  if(r)
    80000b30:	b7d5                	j	80000b14 <kalloc+0x42>

0000000080000b32 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e422                	sd	s0,8(sp)
    80000b36:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b38:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b3e:	00053823          	sd	zero,16(a0)
}
    80000b42:	6422                	ld	s0,8(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b48:	411c                	lw	a5,0(a0)
    80000b4a:	e399                	bnez	a5,80000b50 <holding+0x8>
    80000b4c:	4501                	li	a0,0
  return r;
}
    80000b4e:	8082                	ret
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5a:	6904                	ld	s1,16(a0)
    80000b5c:	00001097          	auipc	ra,0x1
    80000b60:	e3c080e7          	jalr	-452(ra) # 80001998 <mycpu>
    80000b64:	40a48533          	sub	a0,s1,a0
    80000b68:	00153513          	seqz	a0,a0
}
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret

0000000080000b76 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b80:	100024f3          	csrr	s1,sstatus
    80000b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b8e:	00001097          	auipc	ra,0x1
    80000b92:	e0a080e7          	jalr	-502(ra) # 80001998 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	dfe080e7          	jalr	-514(ra) # 80001998 <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	2785                	addiw	a5,a5,1
    80000ba6:	dd3c                	sw	a5,120(a0)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    mycpu()->intena = old;
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	de6080e7          	jalr	-538(ra) # 80001998 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bba:	8085                	srli	s1,s1,0x1
    80000bbc:	8885                	andi	s1,s1,1
    80000bbe:	dd64                	sw	s1,124(a0)
    80000bc0:	bfe9                	j	80000b9a <push_off+0x24>

0000000080000bc2 <acquire>:
{
    80000bc2:	1101                	addi	sp,sp,-32
    80000bc4:	ec06                	sd	ra,24(sp)
    80000bc6:	e822                	sd	s0,16(sp)
    80000bc8:	e426                	sd	s1,8(sp)
    80000bca:	1000                	addi	s0,sp,32
    80000bcc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	fa8080e7          	jalr	-88(ra) # 80000b76 <push_off>
  if(holding(lk))
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f70080e7          	jalr	-144(ra) # 80000b48 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be0:	4705                	li	a4,1
  if(holding(lk))
    80000be2:	e115                	bnez	a0,80000c06 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	87ba                	mv	a5,a4
    80000be6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bea:	2781                	sext.w	a5,a5
    80000bec:	ffe5                	bnez	a5,80000be4 <acquire+0x22>
  __sync_synchronize();
    80000bee:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	da6080e7          	jalr	-602(ra) # 80001998 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00007517          	auipc	a0,0x7
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80008070 <digits+0x30>
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080000c16 <pop_off>:

void
pop_off(void)
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	d7a080e7          	jalr	-646(ra) # 80001998 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c2c:	e78d                	bnez	a5,80000c56 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	02f05b63          	blez	a5,80000c66 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c34:	37fd                	addiw	a5,a5,-1
    80000c36:	0007871b          	sext.w	a4,a5
    80000c3a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c3c:	eb09                	bnez	a4,80000c4e <pop_off+0x38>
    80000c3e:	5d7c                	lw	a5,124(a0)
    80000c40:	c799                	beqz	a5,80000c4e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c4a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("pop_off - interruptible");
    80000c56:	00007517          	auipc	a0,0x7
    80000c5a:	42250513          	addi	a0,a0,1058 # 80008078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80008090 <digits+0x50>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8bc080e7          	jalr	-1860(ra) # 8000052a <panic>

0000000080000c76 <release>:
{
    80000c76:	1101                	addi	sp,sp,-32
    80000c78:	ec06                	sd	ra,24(sp)
    80000c7a:	e822                	sd	s0,16(sp)
    80000c7c:	e426                	sd	s1,8(sp)
    80000c7e:	1000                	addi	s0,sp,32
    80000c80:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	ec6080e7          	jalr	-314(ra) # 80000b48 <holding>
    80000c8a:	c115                	beqz	a0,80000cae <release+0x38>
  lk->cpu = 0;
    80000c8c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c90:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c94:	0f50000f          	fence	iorw,ow
    80000c98:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	f7a080e7          	jalr	-134(ra) # 80000c16 <pop_off>
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("release");
    80000cae:	00007517          	auipc	a0,0x7
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80008098 <digits+0x58>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080000cbe <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e422                	sd	s0,8(sp)
    80000cc2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cc4:	ca19                	beqz	a2,80000cda <memset+0x1c>
    80000cc6:	87aa                	mv	a5,a0
    80000cc8:	1602                	slli	a2,a2,0x20
    80000cca:	9201                	srli	a2,a2,0x20
    80000ccc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cd0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cd4:	0785                	addi	a5,a5,1
    80000cd6:	fee79de3          	bne	a5,a4,80000cd0 <memset+0x12>
  }
  return dst;
}
    80000cda:	6422                	ld	s0,8(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ce6:	ca05                	beqz	a2,80000d16 <memcmp+0x36>
    80000ce8:	fff6069b          	addiw	a3,a2,-1
    80000cec:	1682                	slli	a3,a3,0x20
    80000cee:	9281                	srli	a3,a3,0x20
    80000cf0:	0685                	addi	a3,a3,1
    80000cf2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cf4:	00054783          	lbu	a5,0(a0)
    80000cf8:	0005c703          	lbu	a4,0(a1)
    80000cfc:	00e79863          	bne	a5,a4,80000d0c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d00:	0505                	addi	a0,a0,1
    80000d02:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d04:	fed518e3          	bne	a0,a3,80000cf4 <memcmp+0x14>
  }

  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a019                	j	80000d10 <memcmp+0x30>
      return *s1 - *s2;
    80000d0c:	40e7853b          	subw	a0,a5,a4
}
    80000d10:	6422                	ld	s0,8(sp)
    80000d12:	0141                	addi	sp,sp,16
    80000d14:	8082                	ret
  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	bfe5                	j	80000d10 <memcmp+0x30>

0000000080000d1a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e422                	sd	s0,8(sp)
    80000d1e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d20:	02a5e563          	bltu	a1,a0,80000d4a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	ce11                	beqz	a2,80000d44 <memmove+0x2a>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96ae                	add	a3,a3,a1
    80000d32:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d34:	0585                	addi	a1,a1,1
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff5c703          	lbu	a4,-1(a1)
    80000d3c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d40:	fed59ae3          	bne	a1,a3,80000d34 <memmove+0x1a>

  return dst;
}
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret
  if(s < d && s + n > d){
    80000d4a:	02061713          	slli	a4,a2,0x20
    80000d4e:	9301                	srli	a4,a4,0x20
    80000d50:	00e587b3          	add	a5,a1,a4
    80000d54:	fcf578e3          	bgeu	a0,a5,80000d24 <memmove+0xa>
    d += n;
    80000d58:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d5a:	fff6069b          	addiw	a3,a2,-1
    80000d5e:	d27d                	beqz	a2,80000d44 <memmove+0x2a>
    80000d60:	02069613          	slli	a2,a3,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	fff64613          	not	a2,a2
    80000d6a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d6c:	17fd                	addi	a5,a5,-1
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	0007c683          	lbu	a3,0(a5)
    80000d74:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d78:	fef61ae3          	bne	a2,a5,80000d6c <memmove+0x52>
    80000d7c:	b7e1                	j	80000d44 <memmove+0x2a>

0000000080000d7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e406                	sd	ra,8(sp)
    80000d82:	e022                	sd	s0,0(sp)
    80000d84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f94080e7          	jalr	-108(ra) # 80000d1a <memmove>
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9c:	ce11                	beqz	a2,80000db8 <strncmp+0x22>
    80000d9e:	00054783          	lbu	a5,0(a0)
    80000da2:	cf89                	beqz	a5,80000dbc <strncmp+0x26>
    80000da4:	0005c703          	lbu	a4,0(a1)
    80000da8:	00f71a63          	bne	a4,a5,80000dbc <strncmp+0x26>
    n--, p++, q++;
    80000dac:	367d                	addiw	a2,a2,-1
    80000dae:	0505                	addi	a0,a0,1
    80000db0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db2:	f675                	bnez	a2,80000d9e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db4:	4501                	li	a0,0
    80000db6:	a809                	j	80000dc8 <strncmp+0x32>
    80000db8:	4501                	li	a0,0
    80000dba:	a039                	j	80000dc8 <strncmp+0x32>
  if(n == 0)
    80000dbc:	ca09                	beqz	a2,80000dce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dbe:	00054503          	lbu	a0,0(a0)
    80000dc2:	0005c783          	lbu	a5,0(a1)
    80000dc6:	9d1d                	subw	a0,a0,a5
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	bfe5                	j	80000dc8 <strncmp+0x32>

0000000080000dd2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd8:	872a                	mv	a4,a0
    80000dda:	8832                	mv	a6,a2
    80000ddc:	367d                	addiw	a2,a2,-1
    80000dde:	01005963          	blez	a6,80000df0 <strncpy+0x1e>
    80000de2:	0705                	addi	a4,a4,1
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	fef70fa3          	sb	a5,-1(a4)
    80000dec:	0585                	addi	a1,a1,1
    80000dee:	f7f5                	bnez	a5,80000dda <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df0:	86ba                	mv	a3,a4
    80000df2:	00c05c63          	blez	a2,80000e0a <strncpy+0x38>
    *s++ = 0;
    80000df6:	0685                	addi	a3,a3,1
    80000df8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000dfc:	fff6c793          	not	a5,a3
    80000e00:	9fb9                	addw	a5,a5,a4
    80000e02:	010787bb          	addw	a5,a5,a6
    80000e06:	fef048e3          	bgtz	a5,80000df6 <strncpy+0x24>
  return os;
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e422                	sd	s0,8(sp)
    80000e14:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e16:	02c05363          	blez	a2,80000e3c <safestrcpy+0x2c>
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	1682                	slli	a3,a3,0x20
    80000e20:	9281                	srli	a3,a3,0x20
    80000e22:	96ae                	add	a3,a3,a1
    80000e24:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e26:	00d58963          	beq	a1,a3,80000e38 <safestrcpy+0x28>
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	0785                	addi	a5,a5,1
    80000e2e:	fff5c703          	lbu	a4,-1(a1)
    80000e32:	fee78fa3          	sb	a4,-1(a5)
    80000e36:	fb65                	bnez	a4,80000e26 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e38:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3c:	6422                	ld	s0,8(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret

0000000080000e42 <strlen>:

int
strlen(const char *s)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf91                	beqz	a5,80000e68 <strlen+0x26>
    80000e4e:	0505                	addi	a0,a0,1
    80000e50:	87aa                	mv	a5,a0
    80000e52:	4685                	li	a3,1
    80000e54:	9e89                	subw	a3,a3,a0
    80000e56:	00f6853b          	addw	a0,a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	fb7d                	bnez	a4,80000e56 <strlen+0x14>
    ;
  return n;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strlen+0x20>

0000000080000e6c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e406                	sd	ra,8(sp)
    80000e70:	e022                	sd	s0,0(sp)
    80000e72:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e74:	00001097          	auipc	ra,0x1
    80000e78:	b14080e7          	jalr	-1260(ra) # 80001988 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00008717          	auipc	a4,0x8
    80000e80:	19c70713          	addi	a4,a4,412 # 80009018 <started>
  if(cpuid() == 0){
    80000e84:	c139                	beqz	a0,80000eca <main+0x5e>
    while(started == 0)
    80000e86:	431c                	lw	a5,0(a4)
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	dff5                	beqz	a5,80000e86 <main+0x1a>
      ;
    __sync_synchronize();
    80000e8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	af8080e7          	jalr	-1288(ra) # 80001988 <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00007517          	auipc	a0,0x7
    80000e9e:	21e50513          	addi	a0,a0,542 # 800080b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	dd4080e7          	jalr	-556(ra) # 80002c86 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	446080e7          	jalr	1094(ra) # 80006300 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	0b8080e7          	jalr	184(ra) # 80001f7a <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00007517          	auipc	a0,0x7
    80000ede:	40e50513          	addi	a0,a0,1038 # 800082e8 <digits+0x2a8>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1b650513          	addi	a0,a0,438 # 800080a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	3ee50513          	addi	a0,a0,1006 # 800082e8 <digits+0x2a8>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	310080e7          	jalr	784(ra) # 80001222 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	980080e7          	jalr	-1664(ra) # 800018a2 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	d34080e7          	jalr	-716(ra) # 80002c5e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	d54080e7          	jalr	-684(ra) # 80002c86 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	3b0080e7          	jalr	944(ra) # 800062ea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	3be080e7          	jalr	958(ra) # 80006300 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	56c080e7          	jalr	1388(ra) # 800034b6 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	bfe080e7          	jalr	-1026(ra) # 80003b50 <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	bac080e7          	jalr	-1108(ra) # 80004b06 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	4c0080e7          	jalr	1216(ra) # 80006422 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	d98080e7          	jalr	-616(ra) # 80001d02 <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00008717          	auipc	a4,0x8
    80000f7c:	0af72023          	sw	a5,160(a4) # 80009018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	00008797          	auipc	a5,0x8
    80000f8c:	0987b783          	ld	a5,152(a5) # 80009020 <kernel_pagetable>
    80000f90:	83b1                	srli	a5,a5,0xc
    80000f92:	577d                	li	a4,-1
    80000f94:	177e                	slli	a4,a4,0x3f
    80000f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f98:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fa6:	7139                	addi	sp,sp,-64
    80000fa8:	fc06                	sd	ra,56(sp)
    80000faa:	f822                	sd	s0,48(sp)
    80000fac:	f426                	sd	s1,40(sp)
    80000fae:	f04a                	sd	s2,32(sp)
    80000fb0:	ec4e                	sd	s3,24(sp)
    80000fb2:	e852                	sd	s4,16(sp)
    80000fb4:	e456                	sd	s5,8(sp)
    80000fb6:	e05a                	sd	s6,0(sp)
    80000fb8:	0080                	addi	s0,sp,64
    80000fba:	84aa                	mv	s1,a0
    80000fbc:	89ae                	mv	s3,a1
    80000fbe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00007517          	auipc	a0,0x7
    80000fd0:	10450513          	addi	a0,a0,260 # 800080d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fdc:	060a8663          	beqz	s5,80001048 <walk+0xa2>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c529                	beqz	a0,80001034 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001018:	00093483          	ld	s1,0(s2)
    8000101c:	0014f793          	andi	a5,s1,1
    80001020:	dfd5                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001022:	80a9                	srli	s1,s1,0xa
    80001024:	04b2                	slli	s1,s1,0xc
    80001026:	b7c5                	j	80001006 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001028:	00c9d513          	srli	a0,s3,0xc
    8000102c:	1ff57513          	andi	a0,a0,511
    80001030:	050e                	slli	a0,a0,0x3
    80001032:	9526                	add	a0,a0,s1
}
    80001034:	70e2                	ld	ra,56(sp)
    80001036:	7442                	ld	s0,48(sp)
    80001038:	74a2                	ld	s1,40(sp)
    8000103a:	7902                	ld	s2,32(sp)
    8000103c:	69e2                	ld	s3,24(sp)
    8000103e:	6a42                	ld	s4,16(sp)
    80001040:	6aa2                	ld	s5,8(sp)
    80001042:	6b02                	ld	s6,0(sp)
    80001044:	6121                	addi	sp,sp,64
    80001046:	8082                	ret
        return 0;
    80001048:	4501                	li	a0,0
    8000104a:	b7ed                	j	80001034 <walk+0x8e>

000000008000104c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001056:	8082                	ret
{
    80001058:	1141                	addi	sp,sp,-16
    8000105a:	e406                	sd	ra,8(sp)
    8000105c:	e022                	sd	s0,0(sp)
    8000105e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001060:	4601                	li	a2,0
    80001062:	00000097          	auipc	ra,0x0
    80001066:	f44080e7          	jalr	-188(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000106a:	c105                	beqz	a0,8000108a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000106c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000106e:	0117f693          	andi	a3,a5,17
    80001072:	4745                	li	a4,17
    return 0;
    80001074:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001076:	00e68663          	beq	a3,a4,80001082 <walkaddr+0x36>
}
    8000107a:	60a2                	ld	ra,8(sp)
    8000107c:	6402                	ld	s0,0(sp)
    8000107e:	0141                	addi	sp,sp,16
    80001080:	8082                	ret
  pa = PTE2PA(*pte);
    80001082:	00a7d513          	srli	a0,a5,0xa
    80001086:	0532                	slli	a0,a0,0xc
  return pa;
    80001088:	bfcd                	j	8000107a <walkaddr+0x2e>
    return 0;
    8000108a:	4501                	li	a0,0
    8000108c:	b7fd                	j	8000107a <walkaddr+0x2e>

000000008000108e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000108e:	715d                	addi	sp,sp,-80
    80001090:	e486                	sd	ra,72(sp)
    80001092:	e0a2                	sd	s0,64(sp)
    80001094:	fc26                	sd	s1,56(sp)
    80001096:	f84a                	sd	s2,48(sp)
    80001098:	f44e                	sd	s3,40(sp)
    8000109a:	f052                	sd	s4,32(sp)
    8000109c:	ec56                	sd	s5,24(sp)
    8000109e:	e85a                	sd	s6,16(sp)
    800010a0:	e45e                	sd	s7,8(sp)
    800010a2:	0880                	addi	s0,sp,80
    800010a4:	8aaa                	mv	s5,a0
    800010a6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010a8:	777d                	lui	a4,0xfffff
    800010aa:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ae:	167d                	addi	a2,a2,-1
    800010b0:	00b609b3          	add	s3,a2,a1
    800010b4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010b8:	893e                	mv	s2,a5
    800010ba:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010be:	6b85                	lui	s7,0x1
    800010c0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c4:	4605                	li	a2,1
    800010c6:	85ca                	mv	a1,s2
    800010c8:	8556                	mv	a0,s5
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	edc080e7          	jalr	-292(ra) # 80000fa6 <walk>
    800010d2:	c51d                	beqz	a0,80001100 <mappages+0x72>
    if(*pte & PTE_V)
    800010d4:	611c                	ld	a5,0(a0)
    800010d6:	8b85                	andi	a5,a5,1
    800010d8:	ef81                	bnez	a5,800010f0 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010da:	80b1                	srli	s1,s1,0xc
    800010dc:	04aa                	slli	s1,s1,0xa
    800010de:	0164e4b3          	or	s1,s1,s6
    800010e2:	0014e493          	ori	s1,s1,1
    800010e6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010e8:	03390863          	beq	s2,s3,80001118 <mappages+0x8a>
    a += PGSIZE;
    800010ec:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ee:	bfc9                	j	800010c0 <mappages+0x32>
      panic("remap");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	432080e7          	jalr	1074(ra) # 8000052a <panic>
      return -1;
    80001100:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001102:	60a6                	ld	ra,72(sp)
    80001104:	6406                	ld	s0,64(sp)
    80001106:	74e2                	ld	s1,56(sp)
    80001108:	7942                	ld	s2,48(sp)
    8000110a:	79a2                	ld	s3,40(sp)
    8000110c:	7a02                	ld	s4,32(sp)
    8000110e:	6ae2                	ld	s5,24(sp)
    80001110:	6b42                	ld	s6,16(sp)
    80001112:	6ba2                	ld	s7,8(sp)
    80001114:	6161                	addi	sp,sp,80
    80001116:	8082                	ret
  return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7e5                	j	80001102 <mappages+0x74>

000000008000111c <kvmmap>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
    80001124:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001126:	86b2                	mv	a3,a2
    80001128:	863e                	mv	a2,a5
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	f64080e7          	jalr	-156(ra) # 8000108e <mappages>
    80001132:	e509                	bnez	a0,8000113c <kvmmap+0x20>
}
    80001134:	60a2                	ld	ra,8(sp)
    80001136:	6402                	ld	s0,0(sp)
    80001138:	0141                	addi	sp,sp,16
    8000113a:	8082                	ret
    panic("kvmmap");
    8000113c:	00007517          	auipc	a0,0x7
    80001140:	fa450513          	addi	a0,a0,-92 # 800080e0 <digits+0xa0>
    80001144:	fffff097          	auipc	ra,0xfffff
    80001148:	3e6080e7          	jalr	998(ra) # 8000052a <panic>

000000008000114c <kvmmake>:
{
    8000114c:	1101                	addi	sp,sp,-32
    8000114e:	ec06                	sd	ra,24(sp)
    80001150:	e822                	sd	s0,16(sp)
    80001152:	e426                	sd	s1,8(sp)
    80001154:	e04a                	sd	s2,0(sp)
    80001156:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	97a080e7          	jalr	-1670(ra) # 80000ad2 <kalloc>
    80001160:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	b58080e7          	jalr	-1192(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000116e:	4719                	li	a4,6
    80001170:	6685                	lui	a3,0x1
    80001172:	10000637          	lui	a2,0x10000
    80001176:	100005b7          	lui	a1,0x10000
    8000117a:	8526                	mv	a0,s1
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	fa0080e7          	jalr	-96(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10001637          	lui	a2,0x10001
    8000118c:	100015b7          	lui	a1,0x10001
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f8a080e7          	jalr	-118(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	004006b7          	lui	a3,0x400
    800011a0:	0c000637          	lui	a2,0xc000
    800011a4:	0c0005b7          	lui	a1,0xc000
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f72080e7          	jalr	-142(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011b2:	00007917          	auipc	s2,0x7
    800011b6:	e4e90913          	addi	s2,s2,-434 # 80008000 <etext>
    800011ba:	4729                	li	a4,10
    800011bc:	80007697          	auipc	a3,0x80007
    800011c0:	e4468693          	addi	a3,a3,-444 # 8000 <_entry-0x7fff8000>
    800011c4:	4605                	li	a2,1
    800011c6:	067e                	slli	a2,a2,0x1f
    800011c8:	85b2                	mv	a1,a2
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f50080e7          	jalr	-176(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	46c5                	li	a3,17
    800011d8:	06ee                	slli	a3,a3,0x1b
    800011da:	412686b3          	sub	a3,a3,s2
    800011de:	864a                	mv	a2,s2
    800011e0:	85ca                	mv	a1,s2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f38080e7          	jalr	-200(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ec:	4729                	li	a4,10
    800011ee:	6685                	lui	a3,0x1
    800011f0:	00006617          	auipc	a2,0x6
    800011f4:	e1060613          	addi	a2,a2,-496 # 80007000 <_trampoline>
    800011f8:	040005b7          	lui	a1,0x4000
    800011fc:	15fd                	addi	a1,a1,-1
    800011fe:	05b2                	slli	a1,a1,0xc
    80001200:	8526                	mv	a0,s1
    80001202:	00000097          	auipc	ra,0x0
    80001206:	f1a080e7          	jalr	-230(ra) # 8000111c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	600080e7          	jalr	1536(ra) # 8000180c <proc_mapstacks>
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6902                	ld	s2,0(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <kvminit>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f22080e7          	jalr	-222(ra) # 8000114c <kvmmake>
    80001232:	00008797          	auipc	a5,0x8
    80001236:	dea7b723          	sd	a0,-530(a5) # 80009020 <kernel_pagetable>
}
    8000123a:	60a2                	ld	ra,8(sp)
    8000123c:	6402                	ld	s0,0(sp)
    8000123e:	0141                	addi	sp,sp,16
    80001240:	8082                	ret

0000000080001242 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001242:	715d                	addi	sp,sp,-80
    80001244:	e486                	sd	ra,72(sp)
    80001246:	e0a2                	sd	s0,64(sp)
    80001248:	fc26                	sd	s1,56(sp)
    8000124a:	f84a                	sd	s2,48(sp)
    8000124c:	f44e                	sd	s3,40(sp)
    8000124e:	f052                	sd	s4,32(sp)
    80001250:	ec56                	sd	s5,24(sp)
    80001252:	e85a                	sd	s6,16(sp)
    80001254:	e45e                	sd	s7,8(sp)
    80001256:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001258:	03459793          	slli	a5,a1,0x34
    8000125c:	e795                	bnez	a5,80001288 <uvmunmap+0x46>
    8000125e:	8a2a                	mv	s4,a0
    80001260:	892e                	mv	s2,a1
    80001262:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001264:	0632                	slli	a2,a2,0xc
    80001266:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000126a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000126c:	6b05                	lui	s6,0x1
    8000126e:	0735e263          	bltu	a1,s3,800012d2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001272:	60a6                	ld	ra,72(sp)
    80001274:	6406                	ld	s0,64(sp)
    80001276:	74e2                	ld	s1,56(sp)
    80001278:	7942                	ld	s2,48(sp)
    8000127a:	79a2                	ld	s3,40(sp)
    8000127c:	7a02                	ld	s4,32(sp)
    8000127e:	6ae2                	ld	s5,24(sp)
    80001280:	6b42                	ld	s6,16(sp)
    80001282:	6ba2                	ld	s7,8(sp)
    80001284:	6161                	addi	sp,sp,80
    80001286:	8082                	ret
    panic("uvmunmap: not aligned");
    80001288:	00007517          	auipc	a0,0x7
    8000128c:	e6050513          	addi	a0,a0,-416 # 800080e8 <digits+0xa8>
    80001290:	fffff097          	auipc	ra,0xfffff
    80001294:	29a080e7          	jalr	666(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    80001298:	00007517          	auipc	a0,0x7
    8000129c:	e6850513          	addi	a0,a0,-408 # 80008100 <digits+0xc0>
    800012a0:	fffff097          	auipc	ra,0xfffff
    800012a4:	28a080e7          	jalr	650(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012a8:	00007517          	auipc	a0,0x7
    800012ac:	e6850513          	addi	a0,a0,-408 # 80008110 <digits+0xd0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	27a080e7          	jalr	634(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e7050513          	addi	a0,a0,-400 # 80008128 <digits+0xe8>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	26a080e7          	jalr	618(ra) # 8000052a <panic>
    *pte = 0;
    800012c8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012cc:	995a                	add	s2,s2,s6
    800012ce:	fb3972e3          	bgeu	s2,s3,80001272 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012d2:	4601                	li	a2,0
    800012d4:	85ca                	mv	a1,s2
    800012d6:	8552                	mv	a0,s4
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	cce080e7          	jalr	-818(ra) # 80000fa6 <walk>
    800012e0:	84aa                	mv	s1,a0
    800012e2:	d95d                	beqz	a0,80001298 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012e4:	6108                	ld	a0,0(a0)
    800012e6:	00157793          	andi	a5,a0,1
    800012ea:	dfdd                	beqz	a5,800012a8 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800012ec:	3ff57793          	andi	a5,a0,1023
    800012f0:	fd7784e3          	beq	a5,s7,800012b8 <uvmunmap+0x76>
    if(do_free){
    800012f4:	fc0a8ae3          	beqz	s5,800012c8 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800012f8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fa:	0532                	slli	a0,a0,0xc
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	6da080e7          	jalr	1754(ra) # 800009d6 <kfree>
    80001304:	b7d1                	j	800012c8 <uvmunmap+0x86>

0000000080001306 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001306:	1101                	addi	sp,sp,-32
    80001308:	ec06                	sd	ra,24(sp)
    8000130a:	e822                	sd	s0,16(sp)
    8000130c:	e426                	sd	s1,8(sp)
    8000130e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001310:	fffff097          	auipc	ra,0xfffff
    80001314:	7c2080e7          	jalr	1986(ra) # 80000ad2 <kalloc>
    80001318:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000131a:	c519                	beqz	a0,80001328 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000131c:	6605                	lui	a2,0x1
    8000131e:	4581                	li	a1,0
    80001320:	00000097          	auipc	ra,0x0
    80001324:	99e080e7          	jalr	-1634(ra) # 80000cbe <memset>
  return pagetable;
}
    80001328:	8526                	mv	a0,s1
    8000132a:	60e2                	ld	ra,24(sp)
    8000132c:	6442                	ld	s0,16(sp)
    8000132e:	64a2                	ld	s1,8(sp)
    80001330:	6105                	addi	sp,sp,32
    80001332:	8082                	ret

0000000080001334 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001334:	7179                	addi	sp,sp,-48
    80001336:	f406                	sd	ra,40(sp)
    80001338:	f022                	sd	s0,32(sp)
    8000133a:	ec26                	sd	s1,24(sp)
    8000133c:	e84a                	sd	s2,16(sp)
    8000133e:	e44e                	sd	s3,8(sp)
    80001340:	e052                	sd	s4,0(sp)
    80001342:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001344:	6785                	lui	a5,0x1
    80001346:	04f67863          	bgeu	a2,a5,80001396 <uvminit+0x62>
    8000134a:	8a2a                	mv	s4,a0
    8000134c:	89ae                	mv	s3,a1
    8000134e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	782080e7          	jalr	1922(ra) # 80000ad2 <kalloc>
    80001358:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	960080e7          	jalr	-1696(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001366:	4779                	li	a4,30
    80001368:	86ca                	mv	a3,s2
    8000136a:	6605                	lui	a2,0x1
    8000136c:	4581                	li	a1,0
    8000136e:	8552                	mv	a0,s4
    80001370:	00000097          	auipc	ra,0x0
    80001374:	d1e080e7          	jalr	-738(ra) # 8000108e <mappages>
  memmove(mem, src, sz);
    80001378:	8626                	mv	a2,s1
    8000137a:	85ce                	mv	a1,s3
    8000137c:	854a                	mv	a0,s2
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	99c080e7          	jalr	-1636(ra) # 80000d1a <memmove>
}
    80001386:	70a2                	ld	ra,40(sp)
    80001388:	7402                	ld	s0,32(sp)
    8000138a:	64e2                	ld	s1,24(sp)
    8000138c:	6942                	ld	s2,16(sp)
    8000138e:	69a2                	ld	s3,8(sp)
    80001390:	6a02                	ld	s4,0(sp)
    80001392:	6145                	addi	sp,sp,48
    80001394:	8082                	ret
    panic("inituvm: more than a page");
    80001396:	00007517          	auipc	a0,0x7
    8000139a:	daa50513          	addi	a0,a0,-598 # 80008140 <digits+0x100>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	18c080e7          	jalr	396(ra) # 8000052a <panic>

00000000800013a6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013a6:	1101                	addi	sp,sp,-32
    800013a8:	ec06                	sd	ra,24(sp)
    800013aa:	e822                	sd	s0,16(sp)
    800013ac:	e426                	sd	s1,8(sp)
    800013ae:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013b0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013b2:	00b67d63          	bgeu	a2,a1,800013cc <uvmdealloc+0x26>
    800013b6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013b8:	6785                	lui	a5,0x1
    800013ba:	17fd                	addi	a5,a5,-1
    800013bc:	00f60733          	add	a4,a2,a5
    800013c0:	767d                	lui	a2,0xfffff
    800013c2:	8f71                	and	a4,a4,a2
    800013c4:	97ae                	add	a5,a5,a1
    800013c6:	8ff1                	and	a5,a5,a2
    800013c8:	00f76863          	bltu	a4,a5,800013d8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013cc:	8526                	mv	a0,s1
    800013ce:	60e2                	ld	ra,24(sp)
    800013d0:	6442                	ld	s0,16(sp)
    800013d2:	64a2                	ld	s1,8(sp)
    800013d4:	6105                	addi	sp,sp,32
    800013d6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013d8:	8f99                	sub	a5,a5,a4
    800013da:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013dc:	4685                	li	a3,1
    800013de:	0007861b          	sext.w	a2,a5
    800013e2:	85ba                	mv	a1,a4
    800013e4:	00000097          	auipc	ra,0x0
    800013e8:	e5e080e7          	jalr	-418(ra) # 80001242 <uvmunmap>
    800013ec:	b7c5                	j	800013cc <uvmdealloc+0x26>

00000000800013ee <uvmalloc>:
  if(newsz < oldsz)
    800013ee:	0ab66163          	bltu	a2,a1,80001490 <uvmalloc+0xa2>
{
    800013f2:	7139                	addi	sp,sp,-64
    800013f4:	fc06                	sd	ra,56(sp)
    800013f6:	f822                	sd	s0,48(sp)
    800013f8:	f426                	sd	s1,40(sp)
    800013fa:	f04a                	sd	s2,32(sp)
    800013fc:	ec4e                	sd	s3,24(sp)
    800013fe:	e852                	sd	s4,16(sp)
    80001400:	e456                	sd	s5,8(sp)
    80001402:	0080                	addi	s0,sp,64
    80001404:	8aaa                	mv	s5,a0
    80001406:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001408:	6985                	lui	s3,0x1
    8000140a:	19fd                	addi	s3,s3,-1
    8000140c:	95ce                	add	a1,a1,s3
    8000140e:	79fd                	lui	s3,0xfffff
    80001410:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001414:	08c9f063          	bgeu	s3,a2,80001494 <uvmalloc+0xa6>
    80001418:	894e                	mv	s2,s3
    mem = kalloc();
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	6b8080e7          	jalr	1720(ra) # 80000ad2 <kalloc>
    80001422:	84aa                	mv	s1,a0
    if(mem == 0){
    80001424:	c51d                	beqz	a0,80001452 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001426:	6605                	lui	a2,0x1
    80001428:	4581                	li	a1,0
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	894080e7          	jalr	-1900(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001432:	4779                	li	a4,30
    80001434:	86a6                	mv	a3,s1
    80001436:	6605                	lui	a2,0x1
    80001438:	85ca                	mv	a1,s2
    8000143a:	8556                	mv	a0,s5
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	c52080e7          	jalr	-942(ra) # 8000108e <mappages>
    80001444:	e905                	bnez	a0,80001474 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001446:	6785                	lui	a5,0x1
    80001448:	993e                	add	s2,s2,a5
    8000144a:	fd4968e3          	bltu	s2,s4,8000141a <uvmalloc+0x2c>
  return newsz;
    8000144e:	8552                	mv	a0,s4
    80001450:	a809                	j	80001462 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001452:	864e                	mv	a2,s3
    80001454:	85ca                	mv	a1,s2
    80001456:	8556                	mv	a0,s5
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	f4e080e7          	jalr	-178(ra) # 800013a6 <uvmdealloc>
      return 0;
    80001460:	4501                	li	a0,0
}
    80001462:	70e2                	ld	ra,56(sp)
    80001464:	7442                	ld	s0,48(sp)
    80001466:	74a2                	ld	s1,40(sp)
    80001468:	7902                	ld	s2,32(sp)
    8000146a:	69e2                	ld	s3,24(sp)
    8000146c:	6a42                	ld	s4,16(sp)
    8000146e:	6aa2                	ld	s5,8(sp)
    80001470:	6121                	addi	sp,sp,64
    80001472:	8082                	ret
      kfree(mem);
    80001474:	8526                	mv	a0,s1
    80001476:	fffff097          	auipc	ra,0xfffff
    8000147a:	560080e7          	jalr	1376(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000147e:	864e                	mv	a2,s3
    80001480:	85ca                	mv	a1,s2
    80001482:	8556                	mv	a0,s5
    80001484:	00000097          	auipc	ra,0x0
    80001488:	f22080e7          	jalr	-222(ra) # 800013a6 <uvmdealloc>
      return 0;
    8000148c:	4501                	li	a0,0
    8000148e:	bfd1                	j	80001462 <uvmalloc+0x74>
    return oldsz;
    80001490:	852e                	mv	a0,a1
}
    80001492:	8082                	ret
  return newsz;
    80001494:	8532                	mv	a0,a2
    80001496:	b7f1                	j	80001462 <uvmalloc+0x74>

0000000080001498 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001498:	7179                	addi	sp,sp,-48
    8000149a:	f406                	sd	ra,40(sp)
    8000149c:	f022                	sd	s0,32(sp)
    8000149e:	ec26                	sd	s1,24(sp)
    800014a0:	e84a                	sd	s2,16(sp)
    800014a2:	e44e                	sd	s3,8(sp)
    800014a4:	e052                	sd	s4,0(sp)
    800014a6:	1800                	addi	s0,sp,48
    800014a8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014aa:	84aa                	mv	s1,a0
    800014ac:	6905                	lui	s2,0x1
    800014ae:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014b0:	4985                	li	s3,1
    800014b2:	a821                	j	800014ca <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014b4:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014b6:	0532                	slli	a0,a0,0xc
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	fe0080e7          	jalr	-32(ra) # 80001498 <freewalk>
      pagetable[i] = 0;
    800014c0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014c4:	04a1                	addi	s1,s1,8
    800014c6:	03248163          	beq	s1,s2,800014e8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014ca:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014cc:	00f57793          	andi	a5,a0,15
    800014d0:	ff3782e3          	beq	a5,s3,800014b4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014d4:	8905                	andi	a0,a0,1
    800014d6:	d57d                	beqz	a0,800014c4 <freewalk+0x2c>
      panic("freewalk: leaf");
    800014d8:	00007517          	auipc	a0,0x7
    800014dc:	c8850513          	addi	a0,a0,-888 # 80008160 <digits+0x120>
    800014e0:	fffff097          	auipc	ra,0xfffff
    800014e4:	04a080e7          	jalr	74(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800014e8:	8552                	mv	a0,s4
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	4ec080e7          	jalr	1260(ra) # 800009d6 <kfree>
}
    800014f2:	70a2                	ld	ra,40(sp)
    800014f4:	7402                	ld	s0,32(sp)
    800014f6:	64e2                	ld	s1,24(sp)
    800014f8:	6942                	ld	s2,16(sp)
    800014fa:	69a2                	ld	s3,8(sp)
    800014fc:	6a02                	ld	s4,0(sp)
    800014fe:	6145                	addi	sp,sp,48
    80001500:	8082                	ret

0000000080001502 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001502:	1101                	addi	sp,sp,-32
    80001504:	ec06                	sd	ra,24(sp)
    80001506:	e822                	sd	s0,16(sp)
    80001508:	e426                	sd	s1,8(sp)
    8000150a:	1000                	addi	s0,sp,32
    8000150c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000150e:	e999                	bnez	a1,80001524 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001510:	8526                	mv	a0,s1
    80001512:	00000097          	auipc	ra,0x0
    80001516:	f86080e7          	jalr	-122(ra) # 80001498 <freewalk>
}
    8000151a:	60e2                	ld	ra,24(sp)
    8000151c:	6442                	ld	s0,16(sp)
    8000151e:	64a2                	ld	s1,8(sp)
    80001520:	6105                	addi	sp,sp,32
    80001522:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001524:	6605                	lui	a2,0x1
    80001526:	167d                	addi	a2,a2,-1
    80001528:	962e                	add	a2,a2,a1
    8000152a:	4685                	li	a3,1
    8000152c:	8231                	srli	a2,a2,0xc
    8000152e:	4581                	li	a1,0
    80001530:	00000097          	auipc	ra,0x0
    80001534:	d12080e7          	jalr	-750(ra) # 80001242 <uvmunmap>
    80001538:	bfe1                	j	80001510 <uvmfree+0xe>

000000008000153a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000153a:	c679                	beqz	a2,80001608 <uvmcopy+0xce>
{
    8000153c:	715d                	addi	sp,sp,-80
    8000153e:	e486                	sd	ra,72(sp)
    80001540:	e0a2                	sd	s0,64(sp)
    80001542:	fc26                	sd	s1,56(sp)
    80001544:	f84a                	sd	s2,48(sp)
    80001546:	f44e                	sd	s3,40(sp)
    80001548:	f052                	sd	s4,32(sp)
    8000154a:	ec56                	sd	s5,24(sp)
    8000154c:	e85a                	sd	s6,16(sp)
    8000154e:	e45e                	sd	s7,8(sp)
    80001550:	0880                	addi	s0,sp,80
    80001552:	8b2a                	mv	s6,a0
    80001554:	8aae                	mv	s5,a1
    80001556:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001558:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000155a:	4601                	li	a2,0
    8000155c:	85ce                	mv	a1,s3
    8000155e:	855a                	mv	a0,s6
    80001560:	00000097          	auipc	ra,0x0
    80001564:	a46080e7          	jalr	-1466(ra) # 80000fa6 <walk>
    80001568:	c531                	beqz	a0,800015b4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000156a:	6118                	ld	a4,0(a0)
    8000156c:	00177793          	andi	a5,a4,1
    80001570:	cbb1                	beqz	a5,800015c4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001572:	00a75593          	srli	a1,a4,0xa
    80001576:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000157a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000157e:	fffff097          	auipc	ra,0xfffff
    80001582:	554080e7          	jalr	1364(ra) # 80000ad2 <kalloc>
    80001586:	892a                	mv	s2,a0
    80001588:	c939                	beqz	a0,800015de <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000158a:	6605                	lui	a2,0x1
    8000158c:	85de                	mv	a1,s7
    8000158e:	fffff097          	auipc	ra,0xfffff
    80001592:	78c080e7          	jalr	1932(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001596:	8726                	mv	a4,s1
    80001598:	86ca                	mv	a3,s2
    8000159a:	6605                	lui	a2,0x1
    8000159c:	85ce                	mv	a1,s3
    8000159e:	8556                	mv	a0,s5
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	aee080e7          	jalr	-1298(ra) # 8000108e <mappages>
    800015a8:	e515                	bnez	a0,800015d4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015aa:	6785                	lui	a5,0x1
    800015ac:	99be                	add	s3,s3,a5
    800015ae:	fb49e6e3          	bltu	s3,s4,8000155a <uvmcopy+0x20>
    800015b2:	a081                	j	800015f2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015b4:	00007517          	auipc	a0,0x7
    800015b8:	bbc50513          	addi	a0,a0,-1092 # 80008170 <digits+0x130>
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	f6e080e7          	jalr	-146(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800015c4:	00007517          	auipc	a0,0x7
    800015c8:	bcc50513          	addi	a0,a0,-1076 # 80008190 <digits+0x150>
    800015cc:	fffff097          	auipc	ra,0xfffff
    800015d0:	f5e080e7          	jalr	-162(ra) # 8000052a <panic>
      kfree(mem);
    800015d4:	854a                	mv	a0,s2
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	400080e7          	jalr	1024(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015de:	4685                	li	a3,1
    800015e0:	00c9d613          	srli	a2,s3,0xc
    800015e4:	4581                	li	a1,0
    800015e6:	8556                	mv	a0,s5
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	c5a080e7          	jalr	-934(ra) # 80001242 <uvmunmap>
  return -1;
    800015f0:	557d                	li	a0,-1
}
    800015f2:	60a6                	ld	ra,72(sp)
    800015f4:	6406                	ld	s0,64(sp)
    800015f6:	74e2                	ld	s1,56(sp)
    800015f8:	7942                	ld	s2,48(sp)
    800015fa:	79a2                	ld	s3,40(sp)
    800015fc:	7a02                	ld	s4,32(sp)
    800015fe:	6ae2                	ld	s5,24(sp)
    80001600:	6b42                	ld	s6,16(sp)
    80001602:	6ba2                	ld	s7,8(sp)
    80001604:	6161                	addi	sp,sp,80
    80001606:	8082                	ret
  return 0;
    80001608:	4501                	li	a0,0
}
    8000160a:	8082                	ret

000000008000160c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000160c:	1141                	addi	sp,sp,-16
    8000160e:	e406                	sd	ra,8(sp)
    80001610:	e022                	sd	s0,0(sp)
    80001612:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001614:	4601                	li	a2,0
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	990080e7          	jalr	-1648(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000161e:	c901                	beqz	a0,8000162e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001620:	611c                	ld	a5,0(a0)
    80001622:	9bbd                	andi	a5,a5,-17
    80001624:	e11c                	sd	a5,0(a0)
}
    80001626:	60a2                	ld	ra,8(sp)
    80001628:	6402                	ld	s0,0(sp)
    8000162a:	0141                	addi	sp,sp,16
    8000162c:	8082                	ret
    panic("uvmclear");
    8000162e:	00007517          	auipc	a0,0x7
    80001632:	b8250513          	addi	a0,a0,-1150 # 800081b0 <digits+0x170>
    80001636:	fffff097          	auipc	ra,0xfffff
    8000163a:	ef4080e7          	jalr	-268(ra) # 8000052a <panic>

000000008000163e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000163e:	c6bd                	beqz	a3,800016ac <copyout+0x6e>
{
    80001640:	715d                	addi	sp,sp,-80
    80001642:	e486                	sd	ra,72(sp)
    80001644:	e0a2                	sd	s0,64(sp)
    80001646:	fc26                	sd	s1,56(sp)
    80001648:	f84a                	sd	s2,48(sp)
    8000164a:	f44e                	sd	s3,40(sp)
    8000164c:	f052                	sd	s4,32(sp)
    8000164e:	ec56                	sd	s5,24(sp)
    80001650:	e85a                	sd	s6,16(sp)
    80001652:	e45e                	sd	s7,8(sp)
    80001654:	e062                	sd	s8,0(sp)
    80001656:	0880                	addi	s0,sp,80
    80001658:	8b2a                	mv	s6,a0
    8000165a:	8c2e                	mv	s8,a1
    8000165c:	8a32                	mv	s4,a2
    8000165e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001660:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001662:	6a85                	lui	s5,0x1
    80001664:	a015                	j	80001688 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001666:	9562                	add	a0,a0,s8
    80001668:	0004861b          	sext.w	a2,s1
    8000166c:	85d2                	mv	a1,s4
    8000166e:	41250533          	sub	a0,a0,s2
    80001672:	fffff097          	auipc	ra,0xfffff
    80001676:	6a8080e7          	jalr	1704(ra) # 80000d1a <memmove>

    len -= n;
    8000167a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000167e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001680:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001684:	02098263          	beqz	s3,800016a8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001688:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000168c:	85ca                	mv	a1,s2
    8000168e:	855a                	mv	a0,s6
    80001690:	00000097          	auipc	ra,0x0
    80001694:	9bc080e7          	jalr	-1604(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001698:	cd01                	beqz	a0,800016b0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000169a:	418904b3          	sub	s1,s2,s8
    8000169e:	94d6                	add	s1,s1,s5
    if(n > len)
    800016a0:	fc99f3e3          	bgeu	s3,s1,80001666 <copyout+0x28>
    800016a4:	84ce                	mv	s1,s3
    800016a6:	b7c1                	j	80001666 <copyout+0x28>
  }
  return 0;
    800016a8:	4501                	li	a0,0
    800016aa:	a021                	j	800016b2 <copyout+0x74>
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret
      return -1;
    800016b0:	557d                	li	a0,-1
}
    800016b2:	60a6                	ld	ra,72(sp)
    800016b4:	6406                	ld	s0,64(sp)
    800016b6:	74e2                	ld	s1,56(sp)
    800016b8:	7942                	ld	s2,48(sp)
    800016ba:	79a2                	ld	s3,40(sp)
    800016bc:	7a02                	ld	s4,32(sp)
    800016be:	6ae2                	ld	s5,24(sp)
    800016c0:	6b42                	ld	s6,16(sp)
    800016c2:	6ba2                	ld	s7,8(sp)
    800016c4:	6c02                	ld	s8,0(sp)
    800016c6:	6161                	addi	sp,sp,80
    800016c8:	8082                	ret

00000000800016ca <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ca:	caa5                	beqz	a3,8000173a <copyin+0x70>
{
    800016cc:	715d                	addi	sp,sp,-80
    800016ce:	e486                	sd	ra,72(sp)
    800016d0:	e0a2                	sd	s0,64(sp)
    800016d2:	fc26                	sd	s1,56(sp)
    800016d4:	f84a                	sd	s2,48(sp)
    800016d6:	f44e                	sd	s3,40(sp)
    800016d8:	f052                	sd	s4,32(sp)
    800016da:	ec56                	sd	s5,24(sp)
    800016dc:	e85a                	sd	s6,16(sp)
    800016de:	e45e                	sd	s7,8(sp)
    800016e0:	e062                	sd	s8,0(sp)
    800016e2:	0880                	addi	s0,sp,80
    800016e4:	8b2a                	mv	s6,a0
    800016e6:	8a2e                	mv	s4,a1
    800016e8:	8c32                	mv	s8,a2
    800016ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800016ec:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016ee:	6a85                	lui	s5,0x1
    800016f0:	a01d                	j	80001716 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016f2:	018505b3          	add	a1,a0,s8
    800016f6:	0004861b          	sext.w	a2,s1
    800016fa:	412585b3          	sub	a1,a1,s2
    800016fe:	8552                	mv	a0,s4
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	61a080e7          	jalr	1562(ra) # 80000d1a <memmove>

    len -= n;
    80001708:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000170c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000170e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001712:	02098263          	beqz	s3,80001736 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001716:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000171a:	85ca                	mv	a1,s2
    8000171c:	855a                	mv	a0,s6
    8000171e:	00000097          	auipc	ra,0x0
    80001722:	92e080e7          	jalr	-1746(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001726:	cd01                	beqz	a0,8000173e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001728:	418904b3          	sub	s1,s2,s8
    8000172c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000172e:	fc99f2e3          	bgeu	s3,s1,800016f2 <copyin+0x28>
    80001732:	84ce                	mv	s1,s3
    80001734:	bf7d                	j	800016f2 <copyin+0x28>
  }
  return 0;
    80001736:	4501                	li	a0,0
    80001738:	a021                	j	80001740 <copyin+0x76>
    8000173a:	4501                	li	a0,0
}
    8000173c:	8082                	ret
      return -1;
    8000173e:	557d                	li	a0,-1
}
    80001740:	60a6                	ld	ra,72(sp)
    80001742:	6406                	ld	s0,64(sp)
    80001744:	74e2                	ld	s1,56(sp)
    80001746:	7942                	ld	s2,48(sp)
    80001748:	79a2                	ld	s3,40(sp)
    8000174a:	7a02                	ld	s4,32(sp)
    8000174c:	6ae2                	ld	s5,24(sp)
    8000174e:	6b42                	ld	s6,16(sp)
    80001750:	6ba2                	ld	s7,8(sp)
    80001752:	6c02                	ld	s8,0(sp)
    80001754:	6161                	addi	sp,sp,80
    80001756:	8082                	ret

0000000080001758 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001758:	c6c5                	beqz	a3,80001800 <copyinstr+0xa8>
{
    8000175a:	715d                	addi	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	0880                	addi	s0,sp,80
    80001770:	8a2a                	mv	s4,a0
    80001772:	8b2e                	mv	s6,a1
    80001774:	8bb2                	mv	s7,a2
    80001776:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001778:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000177a:	6985                	lui	s3,0x1
    8000177c:	a035                	j	800017a8 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000177e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001782:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001784:	0017b793          	seqz	a5,a5
    80001788:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6161                	addi	sp,sp,80
    800017a0:	8082                	ret
    srcva = va0 + PGSIZE;
    800017a2:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017a6:	c8a9                	beqz	s1,800017f8 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017a8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ac:	85ca                	mv	a1,s2
    800017ae:	8552                	mv	a0,s4
    800017b0:	00000097          	auipc	ra,0x0
    800017b4:	89c080e7          	jalr	-1892(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800017b8:	c131                	beqz	a0,800017fc <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ba:	41790833          	sub	a6,s2,s7
    800017be:	984e                	add	a6,a6,s3
    if(n > max)
    800017c0:	0104f363          	bgeu	s1,a6,800017c6 <copyinstr+0x6e>
    800017c4:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017c6:	955e                	add	a0,a0,s7
    800017c8:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017cc:	fc080be3          	beqz	a6,800017a2 <copyinstr+0x4a>
    800017d0:	985a                	add	a6,a6,s6
    800017d2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017d4:	41650633          	sub	a2,a0,s6
    800017d8:	14fd                	addi	s1,s1,-1
    800017da:	9b26                	add	s6,s6,s1
    800017dc:	00f60733          	add	a4,a2,a5
    800017e0:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd3000>
    800017e4:	df49                	beqz	a4,8000177e <copyinstr+0x26>
        *dst = *p;
    800017e6:	00e78023          	sb	a4,0(a5)
      --max;
    800017ea:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800017ee:	0785                	addi	a5,a5,1
    while(n > 0){
    800017f0:	ff0796e3          	bne	a5,a6,800017dc <copyinstr+0x84>
      dst++;
    800017f4:	8b42                	mv	s6,a6
    800017f6:	b775                	j	800017a2 <copyinstr+0x4a>
    800017f8:	4781                	li	a5,0
    800017fa:	b769                	j	80001784 <copyinstr+0x2c>
      return -1;
    800017fc:	557d                	li	a0,-1
    800017fe:	b779                	j	8000178c <copyinstr+0x34>
  int got_null = 0;
    80001800:	4781                	li	a5,0
  if(got_null){
    80001802:	0017b793          	seqz	a5,a5
    80001806:	40f00533          	neg	a0,a5
}
    8000180a:	8082                	ret

000000008000180c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000180c:	7139                	addi	sp,sp,-64
    8000180e:	fc06                	sd	ra,56(sp)
    80001810:	f822                	sd	s0,48(sp)
    80001812:	f426                	sd	s1,40(sp)
    80001814:	f04a                	sd	s2,32(sp)
    80001816:	ec4e                	sd	s3,24(sp)
    80001818:	e852                	sd	s4,16(sp)
    8000181a:	e456                	sd	s5,8(sp)
    8000181c:	e05a                	sd	s6,0(sp)
    8000181e:	0080                	addi	s0,sp,64
    80001820:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001822:	00010497          	auipc	s1,0x10
    80001826:	eae48493          	addi	s1,s1,-338 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000182a:	8b26                	mv	s6,s1
    8000182c:	00006a97          	auipc	s5,0x6
    80001830:	7d4a8a93          	addi	s5,s5,2004 # 80008000 <etext>
    80001834:	04000937          	lui	s2,0x4000
    80001838:	197d                	addi	s2,s2,-1
    8000183a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183c:	0001ca17          	auipc	s4,0x1c
    80001840:	094a0a13          	addi	s4,s4,148 # 8001d8d0 <tickslock>
    char *pa = kalloc();
    80001844:	fffff097          	auipc	ra,0xfffff
    80001848:	28e080e7          	jalr	654(ra) # 80000ad2 <kalloc>
    8000184c:	862a                	mv	a2,a0
    if(pa == 0)
    8000184e:	c131                	beqz	a0,80001892 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001850:	416485b3          	sub	a1,s1,s6
    80001854:	858d                	srai	a1,a1,0x3
    80001856:	000ab783          	ld	a5,0(s5)
    8000185a:	02f585b3          	mul	a1,a1,a5
    8000185e:	2585                	addiw	a1,a1,1
    80001860:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001864:	4719                	li	a4,6
    80001866:	6685                	lui	a3,0x1
    80001868:	40b905b3          	sub	a1,s2,a1
    8000186c:	854e                	mv	a0,s3
    8000186e:	00000097          	auipc	ra,0x0
    80001872:	8ae080e7          	jalr	-1874(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001876:	30848493          	addi	s1,s1,776
    8000187a:	fd4495e3          	bne	s1,s4,80001844 <proc_mapstacks+0x38>
  }
}
    8000187e:	70e2                	ld	ra,56(sp)
    80001880:	7442                	ld	s0,48(sp)
    80001882:	74a2                	ld	s1,40(sp)
    80001884:	7902                	ld	s2,32(sp)
    80001886:	69e2                	ld	s3,24(sp)
    80001888:	6a42                	ld	s4,16(sp)
    8000188a:	6aa2                	ld	s5,8(sp)
    8000188c:	6b02                	ld	s6,0(sp)
    8000188e:	6121                	addi	sp,sp,64
    80001890:	8082                	ret
      panic("kalloc");
    80001892:	00007517          	auipc	a0,0x7
    80001896:	92e50513          	addi	a0,a0,-1746 # 800081c0 <digits+0x180>
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	c90080e7          	jalr	-880(ra) # 8000052a <panic>

00000000800018a2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018a2:	715d                	addi	sp,sp,-80
    800018a4:	e486                	sd	ra,72(sp)
    800018a6:	e0a2                	sd	s0,64(sp)
    800018a8:	fc26                	sd	s1,56(sp)
    800018aa:	f84a                	sd	s2,48(sp)
    800018ac:	f44e                	sd	s3,40(sp)
    800018ae:	f052                	sd	s4,32(sp)
    800018b0:	ec56                	sd	s5,24(sp)
    800018b2:	e85a                	sd	s6,16(sp)
    800018b4:	e45e                	sd	s7,8(sp)
    800018b6:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018b8:	00007597          	auipc	a1,0x7
    800018bc:	91058593          	addi	a1,a1,-1776 # 800081c8 <digits+0x188>
    800018c0:	00010517          	auipc	a0,0x10
    800018c4:	9e050513          	addi	a0,a0,-1568 # 800112a0 <pid_lock>
    800018c8:	fffff097          	auipc	ra,0xfffff
    800018cc:	26a080e7          	jalr	618(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018d0:	00007597          	auipc	a1,0x7
    800018d4:	90058593          	addi	a1,a1,-1792 # 800081d0 <digits+0x190>
    800018d8:	00010517          	auipc	a0,0x10
    800018dc:	9e050513          	addi	a0,a0,-1568 # 800112b8 <wait_lock>
    800018e0:	fffff097          	auipc	ra,0xfffff
    800018e4:	252080e7          	jalr	594(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e8:	00010497          	auipc	s1,0x10
    800018ec:	0d848493          	addi	s1,s1,216 # 800119c0 <proc+0x2f0>
    800018f0:	00010917          	auipc	s2,0x10
    800018f4:	de090913          	addi	s2,s2,-544 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    800018f8:	00007b97          	auipc	s7,0x7
    800018fc:	8e8b8b93          	addi	s7,s7,-1816 # 800081e0 <digits+0x1a0>
      p->kstack = KSTACK((int) (p - proc));
    80001900:	8b4a                	mv	s6,s2
    80001902:	00006a97          	auipc	s5,0x6
    80001906:	6fea8a93          	addi	s5,s5,1790 # 80008000 <etext>
    8000190a:	040009b7          	lui	s3,0x4000
    8000190e:	19fd                	addi	s3,s3,-1
    80001910:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001912:	0001ca17          	auipc	s4,0x1c
    80001916:	fbea0a13          	addi	s4,s4,-66 # 8001d8d0 <tickslock>
    8000191a:	a819                	j	80001930 <procinit+0x8e>
      //lock ?
      for(int i=0;i<32;i++){
        p->signal_handlers[i]=(void*)SIG_DFL;
        p->signal_handlers_mask[i]=0;
      }
      p->frozen=0;
    8000191c:	2e092c23          	sw	zero,760(s2)
      p->signal_handling_flag=0;
    80001920:	30092023          	sw	zero,768(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001924:	30890913          	addi	s2,s2,776
    80001928:	30848493          	addi	s1,s1,776
    8000192c:	05490363          	beq	s2,s4,80001972 <procinit+0xd0>
      initlock(&p->lock, "proc");
    80001930:	85de                	mv	a1,s7
    80001932:	854a                	mv	a0,s2
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	1fe080e7          	jalr	510(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000193c:	416907b3          	sub	a5,s2,s6
    80001940:	878d                	srai	a5,a5,0x3
    80001942:	000ab703          	ld	a4,0(s5)
    80001946:	02e787b3          	mul	a5,a5,a4
    8000194a:	2785                	addiw	a5,a5,1
    8000194c:	00d7979b          	slliw	a5,a5,0xd
    80001950:	40f987b3          	sub	a5,s3,a5
    80001954:	04f93023          	sd	a5,64(s2)
      for(int i=0;i<32;i++){
    80001958:	17090713          	addi	a4,s2,368
    8000195c:	27090793          	addi	a5,s2,624
        p->signal_handlers[i]=(void*)SIG_DFL;
    80001960:	00073023          	sd	zero,0(a4)
        p->signal_handlers_mask[i]=0;
    80001964:	0007a023          	sw	zero,0(a5)
      for(int i=0;i<32;i++){
    80001968:	0721                	addi	a4,a4,8
    8000196a:	0791                	addi	a5,a5,4
    8000196c:	fe979ae3          	bne	a5,s1,80001960 <procinit+0xbe>
    80001970:	b775                	j	8000191c <procinit+0x7a>
      //task 1.2
  }
}
    80001972:	60a6                	ld	ra,72(sp)
    80001974:	6406                	ld	s0,64(sp)
    80001976:	74e2                	ld	s1,56(sp)
    80001978:	7942                	ld	s2,48(sp)
    8000197a:	79a2                	ld	s3,40(sp)
    8000197c:	7a02                	ld	s4,32(sp)
    8000197e:	6ae2                	ld	s5,24(sp)
    80001980:	6b42                	ld	s6,16(sp)
    80001982:	6ba2                	ld	s7,8(sp)
    80001984:	6161                	addi	sp,sp,80
    80001986:	8082                	ret

0000000080001988 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001988:	1141                	addi	sp,sp,-16
    8000198a:	e422                	sd	s0,8(sp)
    8000198c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000198e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001990:	2501                	sext.w	a0,a0
    80001992:	6422                	ld	s0,8(sp)
    80001994:	0141                	addi	sp,sp,16
    80001996:	8082                	ret

0000000080001998 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001998:	1141                	addi	sp,sp,-16
    8000199a:	e422                	sd	s0,8(sp)
    8000199c:	0800                	addi	s0,sp,16
    8000199e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019a0:	2781                	sext.w	a5,a5
    800019a2:	079e                	slli	a5,a5,0x7
  return c;
}
    800019a4:	00010517          	auipc	a0,0x10
    800019a8:	92c50513          	addi	a0,a0,-1748 # 800112d0 <cpus>
    800019ac:	953e                	add	a0,a0,a5
    800019ae:	6422                	ld	s0,8(sp)
    800019b0:	0141                	addi	sp,sp,16
    800019b2:	8082                	ret

00000000800019b4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019b4:	1101                	addi	sp,sp,-32
    800019b6:	ec06                	sd	ra,24(sp)
    800019b8:	e822                	sd	s0,16(sp)
    800019ba:	e426                	sd	s1,8(sp)
    800019bc:	1000                	addi	s0,sp,32
  push_off();
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	1b8080e7          	jalr	440(ra) # 80000b76 <push_off>
    800019c6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c8:	2781                	sext.w	a5,a5
    800019ca:	079e                	slli	a5,a5,0x7
    800019cc:	00010717          	auipc	a4,0x10
    800019d0:	8d470713          	addi	a4,a4,-1836 # 800112a0 <pid_lock>
    800019d4:	97ba                	add	a5,a5,a4
    800019d6:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d8:	fffff097          	auipc	ra,0xfffff
    800019dc:	23e080e7          	jalr	574(ra) # 80000c16 <pop_off>
  return p;
}
    800019e0:	8526                	mv	a0,s1
    800019e2:	60e2                	ld	ra,24(sp)
    800019e4:	6442                	ld	s0,16(sp)
    800019e6:	64a2                	ld	s1,8(sp)
    800019e8:	6105                	addi	sp,sp,32
    800019ea:	8082                	ret

00000000800019ec <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ec:	1141                	addi	sp,sp,-16
    800019ee:	e406                	sd	ra,8(sp)
    800019f0:	e022                	sd	s0,0(sp)
    800019f2:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f4:	00000097          	auipc	ra,0x0
    800019f8:	fc0080e7          	jalr	-64(ra) # 800019b4 <myproc>
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	27a080e7          	jalr	634(ra) # 80000c76 <release>

  if (first) {
    80001a04:	00007797          	auipc	a5,0x7
    80001a08:	e7c7a783          	lw	a5,-388(a5) # 80008880 <first.1>
    80001a0c:	eb89                	bnez	a5,80001a1e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a0e:	00001097          	auipc	ra,0x1
    80001a12:	290080e7          	jalr	656(ra) # 80002c9e <usertrapret>
}
    80001a16:	60a2                	ld	ra,8(sp)
    80001a18:	6402                	ld	s0,0(sp)
    80001a1a:	0141                	addi	sp,sp,16
    80001a1c:	8082                	ret
    first = 0;
    80001a1e:	00007797          	auipc	a5,0x7
    80001a22:	e607a123          	sw	zero,-414(a5) # 80008880 <first.1>
    fsinit(ROOTDEV);
    80001a26:	4505                	li	a0,1
    80001a28:	00002097          	auipc	ra,0x2
    80001a2c:	0a8080e7          	jalr	168(ra) # 80003ad0 <fsinit>
    80001a30:	bff9                	j	80001a0e <forkret+0x22>

0000000080001a32 <sigret>:



//task 1.5
  void
  sigret(void){
    80001a32:	1101                	addi	sp,sp,-32
    80001a34:	ec06                	sd	ra,24(sp)
    80001a36:	e822                	sd	s0,16(sp)
    80001a38:	e426                	sd	s1,8(sp)
    80001a3a:	1000                	addi	s0,sp,32
    
  struct proc* p = myproc();
    80001a3c:	00000097          	auipc	ra,0x0
    80001a40:	f78080e7          	jalr	-136(ra) # 800019b4 <myproc>
    80001a44:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001a46:	fffff097          	auipc	ra,0xfffff
    80001a4a:	17c080e7          	jalr	380(ra) # 80000bc2 <acquire>
  memmove(p->trapframe, p->user_trap_frame_backup, sizeof(struct trapframe)); // trapframe restore
    80001a4e:	12000613          	li	a2,288
    80001a52:	2f04b583          	ld	a1,752(s1)
    80001a56:	6ca8                	ld	a0,88(s1)
    80001a58:	fffff097          	auipc	ra,0xfffff
    80001a5c:	2c2080e7          	jalr	706(ra) # 80000d1a <memmove>
  p->trapframe->sp += sizeof(p->trapframe);// add size
    80001a60:	6cb8                	ld	a4,88(s1)
    80001a62:	7b1c                	ld	a5,48(a4)
    80001a64:	07a1                	addi	a5,a5,8
    80001a66:	fb1c                	sd	a5,48(a4)
  p->signal_mask = p->signal_mask_backup; //restoring sigmask in case of change
    80001a68:	2fc4a783          	lw	a5,764(s1)
    80001a6c:	16f4a623          	sw	a5,364(s1)
  p->signal_handling_flag=0;
    80001a70:	3004a023          	sw	zero,768(s1)

  
  release(&p->lock);
    80001a74:	8526                	mv	a0,s1
    80001a76:	fffff097          	auipc	ra,0xfffff
    80001a7a:	200080e7          	jalr	512(ra) # 80000c76 <release>
  }
    80001a7e:	60e2                	ld	ra,24(sp)
    80001a80:	6442                	ld	s0,16(sp)
    80001a82:	64a2                	ld	s1,8(sp)
    80001a84:	6105                	addi	sp,sp,32
    80001a86:	8082                	ret

0000000080001a88 <allocpid>:
allocpid() {
    80001a88:	1101                	addi	sp,sp,-32
    80001a8a:	ec06                	sd	ra,24(sp)
    80001a8c:	e822                	sd	s0,16(sp)
    80001a8e:	e426                	sd	s1,8(sp)
    80001a90:	e04a                	sd	s2,0(sp)
    80001a92:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a94:	00010917          	auipc	s2,0x10
    80001a98:	80c90913          	addi	s2,s2,-2036 # 800112a0 <pid_lock>
    80001a9c:	854a                	mv	a0,s2
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	124080e7          	jalr	292(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001aa6:	00007797          	auipc	a5,0x7
    80001aaa:	dde78793          	addi	a5,a5,-546 # 80008884 <nextpid>
    80001aae:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ab0:	0014871b          	addiw	a4,s1,1
    80001ab4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ab6:	854a                	mv	a0,s2
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	1be080e7          	jalr	446(ra) # 80000c76 <release>
}
    80001ac0:	8526                	mv	a0,s1
    80001ac2:	60e2                	ld	ra,24(sp)
    80001ac4:	6442                	ld	s0,16(sp)
    80001ac6:	64a2                	ld	s1,8(sp)
    80001ac8:	6902                	ld	s2,0(sp)
    80001aca:	6105                	addi	sp,sp,32
    80001acc:	8082                	ret

0000000080001ace <proc_pagetable>:
{
    80001ace:	1101                	addi	sp,sp,-32
    80001ad0:	ec06                	sd	ra,24(sp)
    80001ad2:	e822                	sd	s0,16(sp)
    80001ad4:	e426                	sd	s1,8(sp)
    80001ad6:	e04a                	sd	s2,0(sp)
    80001ad8:	1000                	addi	s0,sp,32
    80001ada:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001adc:	00000097          	auipc	ra,0x0
    80001ae0:	82a080e7          	jalr	-2006(ra) # 80001306 <uvmcreate>
    80001ae4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ae6:	c121                	beqz	a0,80001b26 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ae8:	4729                	li	a4,10
    80001aea:	00005697          	auipc	a3,0x5
    80001aee:	51668693          	addi	a3,a3,1302 # 80007000 <_trampoline>
    80001af2:	6605                	lui	a2,0x1
    80001af4:	040005b7          	lui	a1,0x4000
    80001af8:	15fd                	addi	a1,a1,-1
    80001afa:	05b2                	slli	a1,a1,0xc
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	592080e7          	jalr	1426(ra) # 8000108e <mappages>
    80001b04:	02054863          	bltz	a0,80001b34 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b08:	4719                	li	a4,6
    80001b0a:	05893683          	ld	a3,88(s2)
    80001b0e:	6605                	lui	a2,0x1
    80001b10:	020005b7          	lui	a1,0x2000
    80001b14:	15fd                	addi	a1,a1,-1
    80001b16:	05b6                	slli	a1,a1,0xd
    80001b18:	8526                	mv	a0,s1
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	574080e7          	jalr	1396(ra) # 8000108e <mappages>
    80001b22:	02054163          	bltz	a0,80001b44 <proc_pagetable+0x76>
}
    80001b26:	8526                	mv	a0,s1
    80001b28:	60e2                	ld	ra,24(sp)
    80001b2a:	6442                	ld	s0,16(sp)
    80001b2c:	64a2                	ld	s1,8(sp)
    80001b2e:	6902                	ld	s2,0(sp)
    80001b30:	6105                	addi	sp,sp,32
    80001b32:	8082                	ret
    uvmfree(pagetable, 0);
    80001b34:	4581                	li	a1,0
    80001b36:	8526                	mv	a0,s1
    80001b38:	00000097          	auipc	ra,0x0
    80001b3c:	9ca080e7          	jalr	-1590(ra) # 80001502 <uvmfree>
    return 0;
    80001b40:	4481                	li	s1,0
    80001b42:	b7d5                	j	80001b26 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b44:	4681                	li	a3,0
    80001b46:	4605                	li	a2,1
    80001b48:	040005b7          	lui	a1,0x4000
    80001b4c:	15fd                	addi	a1,a1,-1
    80001b4e:	05b2                	slli	a1,a1,0xc
    80001b50:	8526                	mv	a0,s1
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	6f0080e7          	jalr	1776(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b5a:	4581                	li	a1,0
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	00000097          	auipc	ra,0x0
    80001b62:	9a4080e7          	jalr	-1628(ra) # 80001502 <uvmfree>
    return 0;
    80001b66:	4481                	li	s1,0
    80001b68:	bf7d                	j	80001b26 <proc_pagetable+0x58>

0000000080001b6a <proc_freepagetable>:
{
    80001b6a:	1101                	addi	sp,sp,-32
    80001b6c:	ec06                	sd	ra,24(sp)
    80001b6e:	e822                	sd	s0,16(sp)
    80001b70:	e426                	sd	s1,8(sp)
    80001b72:	e04a                	sd	s2,0(sp)
    80001b74:	1000                	addi	s0,sp,32
    80001b76:	84aa                	mv	s1,a0
    80001b78:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b7a:	4681                	li	a3,0
    80001b7c:	4605                	li	a2,1
    80001b7e:	040005b7          	lui	a1,0x4000
    80001b82:	15fd                	addi	a1,a1,-1
    80001b84:	05b2                	slli	a1,a1,0xc
    80001b86:	fffff097          	auipc	ra,0xfffff
    80001b8a:	6bc080e7          	jalr	1724(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b8e:	4681                	li	a3,0
    80001b90:	4605                	li	a2,1
    80001b92:	020005b7          	lui	a1,0x2000
    80001b96:	15fd                	addi	a1,a1,-1
    80001b98:	05b6                	slli	a1,a1,0xd
    80001b9a:	8526                	mv	a0,s1
    80001b9c:	fffff097          	auipc	ra,0xfffff
    80001ba0:	6a6080e7          	jalr	1702(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ba4:	85ca                	mv	a1,s2
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	00000097          	auipc	ra,0x0
    80001bac:	95a080e7          	jalr	-1702(ra) # 80001502 <uvmfree>
}
    80001bb0:	60e2                	ld	ra,24(sp)
    80001bb2:	6442                	ld	s0,16(sp)
    80001bb4:	64a2                	ld	s1,8(sp)
    80001bb6:	6902                	ld	s2,0(sp)
    80001bb8:	6105                	addi	sp,sp,32
    80001bba:	8082                	ret

0000000080001bbc <freeproc>:
{
    80001bbc:	1101                	addi	sp,sp,-32
    80001bbe:	ec06                	sd	ra,24(sp)
    80001bc0:	e822                	sd	s0,16(sp)
    80001bc2:	e426                	sd	s1,8(sp)
    80001bc4:	1000                	addi	s0,sp,32
    80001bc6:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bc8:	6d28                	ld	a0,88(a0)
    80001bca:	c509                	beqz	a0,80001bd4 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	e0a080e7          	jalr	-502(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001bd4:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bd8:	68a8                	ld	a0,80(s1)
    80001bda:	c511                	beqz	a0,80001be6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bdc:	64ac                	ld	a1,72(s1)
    80001bde:	00000097          	auipc	ra,0x0
    80001be2:	f8c080e7          	jalr	-116(ra) # 80001b6a <proc_freepagetable>
  p->pagetable = 0;
    80001be6:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bea:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bee:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bf2:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bf6:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bfa:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bfe:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c02:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c06:	0004ac23          	sw	zero,24(s1)
}
    80001c0a:	60e2                	ld	ra,24(sp)
    80001c0c:	6442                	ld	s0,16(sp)
    80001c0e:	64a2                	ld	s1,8(sp)
    80001c10:	6105                	addi	sp,sp,32
    80001c12:	8082                	ret

0000000080001c14 <allocproc>:
{
    80001c14:	7179                	addi	sp,sp,-48
    80001c16:	f406                	sd	ra,40(sp)
    80001c18:	f022                	sd	s0,32(sp)
    80001c1a:	ec26                	sd	s1,24(sp)
    80001c1c:	e84a                	sd	s2,16(sp)
    80001c1e:	e44e                	sd	s3,8(sp)
    80001c20:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c22:	00010497          	auipc	s1,0x10
    80001c26:	aae48493          	addi	s1,s1,-1362 # 800116d0 <proc>
    80001c2a:	0001c997          	auipc	s3,0x1c
    80001c2e:	ca698993          	addi	s3,s3,-858 # 8001d8d0 <tickslock>
    acquire(&p->lock);
    80001c32:	8526                	mv	a0,s1
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	f8e080e7          	jalr	-114(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001c3c:	4c9c                	lw	a5,24(s1)
    80001c3e:	cf81                	beqz	a5,80001c56 <allocproc+0x42>
      release(&p->lock);
    80001c40:	8526                	mv	a0,s1
    80001c42:	fffff097          	auipc	ra,0xfffff
    80001c46:	034080e7          	jalr	52(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c4a:	30848493          	addi	s1,s1,776
    80001c4e:	ff3492e3          	bne	s1,s3,80001c32 <allocproc+0x1e>
  return 0;
    80001c52:	4481                	li	s1,0
    80001c54:	a0bd                	j	80001cc2 <allocproc+0xae>
  p->pid = allocpid();
    80001c56:	00000097          	auipc	ra,0x0
    80001c5a:	e32080e7          	jalr	-462(ra) # 80001a88 <allocpid>
    80001c5e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c60:	4785                	li	a5,1
    80001c62:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	e6e080e7          	jalr	-402(ra) # 80000ad2 <kalloc>
    80001c6c:	89aa                	mv	s3,a0
    80001c6e:	eca8                	sd	a0,88(s1)
    80001c70:	c12d                	beqz	a0,80001cd2 <allocproc+0xbe>
  p->pagetable = proc_pagetable(p);
    80001c72:	8526                	mv	a0,s1
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	e5a080e7          	jalr	-422(ra) # 80001ace <proc_pagetable>
    80001c7c:	89aa                	mv	s3,a0
    80001c7e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c80:	c52d                	beqz	a0,80001cea <allocproc+0xd6>
  memset(&p->context, 0, sizeof(p->context));
    80001c82:	07000613          	li	a2,112
    80001c86:	4581                	li	a1,0
    80001c88:	06048513          	addi	a0,s1,96
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	032080e7          	jalr	50(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001c94:	00000797          	auipc	a5,0x0
    80001c98:	d5878793          	addi	a5,a5,-680 # 800019ec <forkret>
    80001c9c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c9e:	60bc                	ld	a5,64(s1)
    80001ca0:	6705                	lui	a4,0x1
    80001ca2:	97ba                	add	a5,a5,a4
    80001ca4:	f4bc                	sd	a5,104(s1)
  for(int i=0; i<32;i++){
    80001ca6:	17048713          	addi	a4,s1,368
    80001caa:	27048793          	addi	a5,s1,624
    80001cae:	2f048693          	addi	a3,s1,752
    p->signal_handlers[i]=(void*)SIG_DFL;
    80001cb2:	00073023          	sd	zero,0(a4) # 1000 <_entry-0x7ffff000>
    p->signal_handlers_mask[i]=0;
    80001cb6:	0007a023          	sw	zero,0(a5)
  for(int i=0; i<32;i++){
    80001cba:	0721                	addi	a4,a4,8
    80001cbc:	0791                	addi	a5,a5,4
    80001cbe:	fed79ae3          	bne	a5,a3,80001cb2 <allocproc+0x9e>
}
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	70a2                	ld	ra,40(sp)
    80001cc6:	7402                	ld	s0,32(sp)
    80001cc8:	64e2                	ld	s1,24(sp)
    80001cca:	6942                	ld	s2,16(sp)
    80001ccc:	69a2                	ld	s3,8(sp)
    80001cce:	6145                	addi	sp,sp,48
    80001cd0:	8082                	ret
    freeproc(p);
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	00000097          	auipc	ra,0x0
    80001cd8:	ee8080e7          	jalr	-280(ra) # 80001bbc <freeproc>
    release(&p->lock);
    80001cdc:	8526                	mv	a0,s1
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	f98080e7          	jalr	-104(ra) # 80000c76 <release>
    return 0;
    80001ce6:	84ce                	mv	s1,s3
    80001ce8:	bfe9                	j	80001cc2 <allocproc+0xae>
    freeproc(p);
    80001cea:	8526                	mv	a0,s1
    80001cec:	00000097          	auipc	ra,0x0
    80001cf0:	ed0080e7          	jalr	-304(ra) # 80001bbc <freeproc>
    release(&p->lock);
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	f80080e7          	jalr	-128(ra) # 80000c76 <release>
    return 0;
    80001cfe:	84ce                	mv	s1,s3
    80001d00:	b7c9                	j	80001cc2 <allocproc+0xae>

0000000080001d02 <userinit>:
{
    80001d02:	1101                	addi	sp,sp,-32
    80001d04:	ec06                	sd	ra,24(sp)
    80001d06:	e822                	sd	s0,16(sp)
    80001d08:	e426                	sd	s1,8(sp)
    80001d0a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d0c:	00000097          	auipc	ra,0x0
    80001d10:	f08080e7          	jalr	-248(ra) # 80001c14 <allocproc>
    80001d14:	84aa                	mv	s1,a0
  initproc = p;
    80001d16:	00007797          	auipc	a5,0x7
    80001d1a:	30a7b923          	sd	a0,786(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d1e:	03400613          	li	a2,52
    80001d22:	00007597          	auipc	a1,0x7
    80001d26:	b6e58593          	addi	a1,a1,-1170 # 80008890 <initcode>
    80001d2a:	6928                	ld	a0,80(a0)
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	608080e7          	jalr	1544(ra) # 80001334 <uvminit>
  p->sz = PGSIZE;
    80001d34:	6785                	lui	a5,0x1
    80001d36:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d38:	6cb8                	ld	a4,88(s1)
    80001d3a:	00073c23          	sd	zero,24(a4)
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d3e:	6cb8                	ld	a4,88(s1)
    80001d40:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d42:	4641                	li	a2,16
    80001d44:	00006597          	auipc	a1,0x6
    80001d48:	4a458593          	addi	a1,a1,1188 # 800081e8 <digits+0x1a8>
    80001d4c:	15848513          	addi	a0,s1,344
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	0c0080e7          	jalr	192(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001d58:	00006517          	auipc	a0,0x6
    80001d5c:	4a050513          	addi	a0,a0,1184 # 800081f8 <digits+0x1b8>
    80001d60:	00002097          	auipc	ra,0x2
    80001d64:	79e080e7          	jalr	1950(ra) # 800044fe <namei>
    80001d68:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d6c:	478d                	li	a5,3
    80001d6e:	cc9c                	sw	a5,24(s1)
  p->frozen=0;
    80001d70:	2e04ac23          	sw	zero,760(s1)
  p->signal_mask=0;
    80001d74:	1604a623          	sw	zero,364(s1)
  release(&p->lock);
    80001d78:	8526                	mv	a0,s1
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	efc080e7          	jalr	-260(ra) # 80000c76 <release>
}
    80001d82:	60e2                	ld	ra,24(sp)
    80001d84:	6442                	ld	s0,16(sp)
    80001d86:	64a2                	ld	s1,8(sp)
    80001d88:	6105                	addi	sp,sp,32
    80001d8a:	8082                	ret

0000000080001d8c <growproc>:
{
    80001d8c:	1101                	addi	sp,sp,-32
    80001d8e:	ec06                	sd	ra,24(sp)
    80001d90:	e822                	sd	s0,16(sp)
    80001d92:	e426                	sd	s1,8(sp)
    80001d94:	e04a                	sd	s2,0(sp)
    80001d96:	1000                	addi	s0,sp,32
    80001d98:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d9a:	00000097          	auipc	ra,0x0
    80001d9e:	c1a080e7          	jalr	-998(ra) # 800019b4 <myproc>
    80001da2:	892a                	mv	s2,a0
  sz = p->sz;
    80001da4:	652c                	ld	a1,72(a0)
    80001da6:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001daa:	00904f63          	bgtz	s1,80001dc8 <growproc+0x3c>
  } else if(n < 0){
    80001dae:	0204cc63          	bltz	s1,80001de6 <growproc+0x5a>
  p->sz = sz;
    80001db2:	1602                	slli	a2,a2,0x20
    80001db4:	9201                	srli	a2,a2,0x20
    80001db6:	04c93423          	sd	a2,72(s2)
  return 0;
    80001dba:	4501                	li	a0,0
}
    80001dbc:	60e2                	ld	ra,24(sp)
    80001dbe:	6442                	ld	s0,16(sp)
    80001dc0:	64a2                	ld	s1,8(sp)
    80001dc2:	6902                	ld	s2,0(sp)
    80001dc4:	6105                	addi	sp,sp,32
    80001dc6:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dc8:	9e25                	addw	a2,a2,s1
    80001dca:	1602                	slli	a2,a2,0x20
    80001dcc:	9201                	srli	a2,a2,0x20
    80001dce:	1582                	slli	a1,a1,0x20
    80001dd0:	9181                	srli	a1,a1,0x20
    80001dd2:	6928                	ld	a0,80(a0)
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	61a080e7          	jalr	1562(ra) # 800013ee <uvmalloc>
    80001ddc:	0005061b          	sext.w	a2,a0
    80001de0:	fa69                	bnez	a2,80001db2 <growproc+0x26>
      return -1;
    80001de2:	557d                	li	a0,-1
    80001de4:	bfe1                	j	80001dbc <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001de6:	9e25                	addw	a2,a2,s1
    80001de8:	1602                	slli	a2,a2,0x20
    80001dea:	9201                	srli	a2,a2,0x20
    80001dec:	1582                	slli	a1,a1,0x20
    80001dee:	9181                	srli	a1,a1,0x20
    80001df0:	6928                	ld	a0,80(a0)
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	5b4080e7          	jalr	1460(ra) # 800013a6 <uvmdealloc>
    80001dfa:	0005061b          	sext.w	a2,a0
    80001dfe:	bf55                	j	80001db2 <growproc+0x26>

0000000080001e00 <fork>:
{
    80001e00:	7139                	addi	sp,sp,-64
    80001e02:	fc06                	sd	ra,56(sp)
    80001e04:	f822                	sd	s0,48(sp)
    80001e06:	f426                	sd	s1,40(sp)
    80001e08:	f04a                	sd	s2,32(sp)
    80001e0a:	ec4e                	sd	s3,24(sp)
    80001e0c:	e852                	sd	s4,16(sp)
    80001e0e:	e456                	sd	s5,8(sp)
    80001e10:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e12:	00000097          	auipc	ra,0x0
    80001e16:	ba2080e7          	jalr	-1118(ra) # 800019b4 <myproc>
    80001e1a:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80001e1c:	00000097          	auipc	ra,0x0
    80001e20:	df8080e7          	jalr	-520(ra) # 80001c14 <allocproc>
    80001e24:	14050963          	beqz	a0,80001f76 <fork+0x176>
    80001e28:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e2a:	0489b603          	ld	a2,72(s3)
    80001e2e:	692c                	ld	a1,80(a0)
    80001e30:	0509b503          	ld	a0,80(s3)
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	706080e7          	jalr	1798(ra) # 8000153a <uvmcopy>
    80001e3c:	04054863          	bltz	a0,80001e8c <fork+0x8c>
  np->sz = p->sz;
    80001e40:	0489b783          	ld	a5,72(s3)
    80001e44:	04f93423          	sd	a5,72(s2)
  *(np->trapframe) = *(p->trapframe);
    80001e48:	0589b683          	ld	a3,88(s3)
    80001e4c:	87b6                	mv	a5,a3
    80001e4e:	05893703          	ld	a4,88(s2)
    80001e52:	12068693          	addi	a3,a3,288
    80001e56:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5a:	6788                	ld	a0,8(a5)
    80001e5c:	6b8c                	ld	a1,16(a5)
    80001e5e:	6f90                	ld	a2,24(a5)
    80001e60:	01073023          	sd	a6,0(a4)
    80001e64:	e708                	sd	a0,8(a4)
    80001e66:	eb0c                	sd	a1,16(a4)
    80001e68:	ef10                	sd	a2,24(a4)
    80001e6a:	02078793          	addi	a5,a5,32
    80001e6e:	02070713          	addi	a4,a4,32
    80001e72:	fed792e3          	bne	a5,a3,80001e56 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e76:	05893783          	ld	a5,88(s2)
    80001e7a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e7e:	0d098493          	addi	s1,s3,208
    80001e82:	0d090a13          	addi	s4,s2,208
    80001e86:	15098a93          	addi	s5,s3,336
    80001e8a:	a00d                	j	80001eac <fork+0xac>
    freeproc(np);
    80001e8c:	854a                	mv	a0,s2
    80001e8e:	00000097          	auipc	ra,0x0
    80001e92:	d2e080e7          	jalr	-722(ra) # 80001bbc <freeproc>
    release(&np->lock);
    80001e96:	854a                	mv	a0,s2
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	dde080e7          	jalr	-546(ra) # 80000c76 <release>
    return -1;
    80001ea0:	54fd                	li	s1,-1
    80001ea2:	a0c1                	j	80001f62 <fork+0x162>
  for(i = 0; i < NOFILE; i++)
    80001ea4:	04a1                	addi	s1,s1,8
    80001ea6:	0a21                	addi	s4,s4,8
    80001ea8:	01548b63          	beq	s1,s5,80001ebe <fork+0xbe>
    if(p->ofile[i])
    80001eac:	6088                	ld	a0,0(s1)
    80001eae:	d97d                	beqz	a0,80001ea4 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb0:	00003097          	auipc	ra,0x3
    80001eb4:	ce8080e7          	jalr	-792(ra) # 80004b98 <filedup>
    80001eb8:	00aa3023          	sd	a0,0(s4)
    80001ebc:	b7e5                	j	80001ea4 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ebe:	1509b503          	ld	a0,336(s3)
    80001ec2:	00002097          	auipc	ra,0x2
    80001ec6:	e48080e7          	jalr	-440(ra) # 80003d0a <idup>
    80001eca:	14a93823          	sd	a0,336(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ece:	4641                	li	a2,16
    80001ed0:	15898593          	addi	a1,s3,344
    80001ed4:	15890513          	addi	a0,s2,344
    80001ed8:	fffff097          	auipc	ra,0xfffff
    80001edc:	f38080e7          	jalr	-200(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80001ee0:	03092483          	lw	s1,48(s2)
  np->signal_mask=p->signal_mask; 
    80001ee4:	16c9a783          	lw	a5,364(s3)
    80001ee8:	16f92623          	sw	a5,364(s2)
  for(int i=0;i<32;i++){
    80001eec:	17098693          	addi	a3,s3,368
    80001ef0:	17090713          	addi	a4,s2,368
  np->signal_mask=p->signal_mask; 
    80001ef4:	27000793          	li	a5,624
  for(int i=0;i<32;i++){
    80001ef8:	2f000513          	li	a0,752
    np->signal_handlers[i]=(void*) p->signal_handlers[i]; 
    80001efc:	6290                	ld	a2,0(a3)
    80001efe:	e310                	sd	a2,0(a4)
    np->signal_handlers_mask[i]=p->signal_handlers_mask[i];
    80001f00:	00f98633          	add	a2,s3,a5
    80001f04:	420c                	lw	a1,0(a2)
    80001f06:	00f90633          	add	a2,s2,a5
    80001f0a:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    80001f0c:	06a1                	addi	a3,a3,8
    80001f0e:	0721                	addi	a4,a4,8
    80001f10:	0791                	addi	a5,a5,4
    80001f12:	fea795e3          	bne	a5,a0,80001efc <fork+0xfc>
  np->frozen=0;
    80001f16:	2e092c23          	sw	zero,760(s2)
  np->signal_handling_flag=0;
    80001f1a:	30092023          	sw	zero,768(s2)
  release(&np->lock);
    80001f1e:	854a                	mv	a0,s2
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	d56080e7          	jalr	-682(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80001f28:	0000fa17          	auipc	s4,0xf
    80001f2c:	390a0a13          	addi	s4,s4,912 # 800112b8 <wait_lock>
    80001f30:	8552                	mv	a0,s4
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	c90080e7          	jalr	-880(ra) # 80000bc2 <acquire>
  np->parent = p;
    80001f3a:	03393c23          	sd	s3,56(s2)
  release(&wait_lock);
    80001f3e:	8552                	mv	a0,s4
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	d36080e7          	jalr	-714(ra) # 80000c76 <release>
  acquire(&np->lock);
    80001f48:	854a                	mv	a0,s2
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	c78080e7          	jalr	-904(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80001f52:	478d                	li	a5,3
    80001f54:	00f92c23          	sw	a5,24(s2)
  release(&np->lock);
    80001f58:	854a                	mv	a0,s2
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	d1c080e7          	jalr	-740(ra) # 80000c76 <release>
}
    80001f62:	8526                	mv	a0,s1
    80001f64:	70e2                	ld	ra,56(sp)
    80001f66:	7442                	ld	s0,48(sp)
    80001f68:	74a2                	ld	s1,40(sp)
    80001f6a:	7902                	ld	s2,32(sp)
    80001f6c:	69e2                	ld	s3,24(sp)
    80001f6e:	6a42                	ld	s4,16(sp)
    80001f70:	6aa2                	ld	s5,8(sp)
    80001f72:	6121                	addi	sp,sp,64
    80001f74:	8082                	ret
    return -1;
    80001f76:	54fd                	li	s1,-1
    80001f78:	b7ed                	j	80001f62 <fork+0x162>

0000000080001f7a <scheduler>:
{
    80001f7a:	7139                	addi	sp,sp,-64
    80001f7c:	fc06                	sd	ra,56(sp)
    80001f7e:	f822                	sd	s0,48(sp)
    80001f80:	f426                	sd	s1,40(sp)
    80001f82:	f04a                	sd	s2,32(sp)
    80001f84:	ec4e                	sd	s3,24(sp)
    80001f86:	e852                	sd	s4,16(sp)
    80001f88:	e456                	sd	s5,8(sp)
    80001f8a:	e05a                	sd	s6,0(sp)
    80001f8c:	0080                	addi	s0,sp,64
    80001f8e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f90:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f92:	00779a93          	slli	s5,a5,0x7
    80001f96:	0000f717          	auipc	a4,0xf
    80001f9a:	30a70713          	addi	a4,a4,778 # 800112a0 <pid_lock>
    80001f9e:	9756                	add	a4,a4,s5
    80001fa0:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fa4:	0000f717          	auipc	a4,0xf
    80001fa8:	33470713          	addi	a4,a4,820 # 800112d8 <cpus+0x8>
    80001fac:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001fae:	498d                	li	s3,3
        p->state = RUNNING;
    80001fb0:	4b11                	li	s6,4
        c->proc = p;
    80001fb2:	079e                	slli	a5,a5,0x7
    80001fb4:	0000fa17          	auipc	s4,0xf
    80001fb8:	2eca0a13          	addi	s4,s4,748 # 800112a0 <pid_lock>
    80001fbc:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fbe:	0001c917          	auipc	s2,0x1c
    80001fc2:	91290913          	addi	s2,s2,-1774 # 8001d8d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fc6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fca:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fce:	10079073          	csrw	sstatus,a5
    80001fd2:	0000f497          	auipc	s1,0xf
    80001fd6:	6fe48493          	addi	s1,s1,1790 # 800116d0 <proc>
    80001fda:	a811                	j	80001fee <scheduler+0x74>
      release(&p->lock);
    80001fdc:	8526                	mv	a0,s1
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	c98080e7          	jalr	-872(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fe6:	30848493          	addi	s1,s1,776
    80001fea:	fd248ee3          	beq	s1,s2,80001fc6 <scheduler+0x4c>
      acquire(&p->lock);
    80001fee:	8526                	mv	a0,s1
    80001ff0:	fffff097          	auipc	ra,0xfffff
    80001ff4:	bd2080e7          	jalr	-1070(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    80001ff8:	4c9c                	lw	a5,24(s1)
    80001ffa:	ff3791e3          	bne	a5,s3,80001fdc <scheduler+0x62>
        p->state = RUNNING;
    80001ffe:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002002:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002006:	06048593          	addi	a1,s1,96
    8000200a:	8556                	mv	a0,s5
    8000200c:	00001097          	auipc	ra,0x1
    80002010:	be4080e7          	jalr	-1052(ra) # 80002bf0 <swtch>
        c->proc = 0;
    80002014:	020a3823          	sd	zero,48(s4)
    80002018:	b7d1                	j	80001fdc <scheduler+0x62>

000000008000201a <sched>:
{
    8000201a:	7179                	addi	sp,sp,-48
    8000201c:	f406                	sd	ra,40(sp)
    8000201e:	f022                	sd	s0,32(sp)
    80002020:	ec26                	sd	s1,24(sp)
    80002022:	e84a                	sd	s2,16(sp)
    80002024:	e44e                	sd	s3,8(sp)
    80002026:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002028:	00000097          	auipc	ra,0x0
    8000202c:	98c080e7          	jalr	-1652(ra) # 800019b4 <myproc>
    80002030:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002032:	fffff097          	auipc	ra,0xfffff
    80002036:	b16080e7          	jalr	-1258(ra) # 80000b48 <holding>
    8000203a:	c93d                	beqz	a0,800020b0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000203c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000203e:	2781                	sext.w	a5,a5
    80002040:	079e                	slli	a5,a5,0x7
    80002042:	0000f717          	auipc	a4,0xf
    80002046:	25e70713          	addi	a4,a4,606 # 800112a0 <pid_lock>
    8000204a:	97ba                	add	a5,a5,a4
    8000204c:	0a87a703          	lw	a4,168(a5)
    80002050:	4785                	li	a5,1
    80002052:	06f71763          	bne	a4,a5,800020c0 <sched+0xa6>
  if(p->state == RUNNING)
    80002056:	4c98                	lw	a4,24(s1)
    80002058:	4791                	li	a5,4
    8000205a:	06f70b63          	beq	a4,a5,800020d0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000205e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002062:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002064:	efb5                	bnez	a5,800020e0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002066:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002068:	0000f917          	auipc	s2,0xf
    8000206c:	23890913          	addi	s2,s2,568 # 800112a0 <pid_lock>
    80002070:	2781                	sext.w	a5,a5
    80002072:	079e                	slli	a5,a5,0x7
    80002074:	97ca                	add	a5,a5,s2
    80002076:	0ac7a983          	lw	s3,172(a5)
    8000207a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000207c:	2781                	sext.w	a5,a5
    8000207e:	079e                	slli	a5,a5,0x7
    80002080:	0000f597          	auipc	a1,0xf
    80002084:	25858593          	addi	a1,a1,600 # 800112d8 <cpus+0x8>
    80002088:	95be                	add	a1,a1,a5
    8000208a:	06048513          	addi	a0,s1,96
    8000208e:	00001097          	auipc	ra,0x1
    80002092:	b62080e7          	jalr	-1182(ra) # 80002bf0 <swtch>
    80002096:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002098:	2781                	sext.w	a5,a5
    8000209a:	079e                	slli	a5,a5,0x7
    8000209c:	97ca                	add	a5,a5,s2
    8000209e:	0b37a623          	sw	s3,172(a5)
}
    800020a2:	70a2                	ld	ra,40(sp)
    800020a4:	7402                	ld	s0,32(sp)
    800020a6:	64e2                	ld	s1,24(sp)
    800020a8:	6942                	ld	s2,16(sp)
    800020aa:	69a2                	ld	s3,8(sp)
    800020ac:	6145                	addi	sp,sp,48
    800020ae:	8082                	ret
    panic("sched p->lock");
    800020b0:	00006517          	auipc	a0,0x6
    800020b4:	15050513          	addi	a0,a0,336 # 80008200 <digits+0x1c0>
    800020b8:	ffffe097          	auipc	ra,0xffffe
    800020bc:	472080e7          	jalr	1138(ra) # 8000052a <panic>
    panic("sched locks");
    800020c0:	00006517          	auipc	a0,0x6
    800020c4:	15050513          	addi	a0,a0,336 # 80008210 <digits+0x1d0>
    800020c8:	ffffe097          	auipc	ra,0xffffe
    800020cc:	462080e7          	jalr	1122(ra) # 8000052a <panic>
    panic("sched running");
    800020d0:	00006517          	auipc	a0,0x6
    800020d4:	15050513          	addi	a0,a0,336 # 80008220 <digits+0x1e0>
    800020d8:	ffffe097          	auipc	ra,0xffffe
    800020dc:	452080e7          	jalr	1106(ra) # 8000052a <panic>
    panic("sched interruptible");
    800020e0:	00006517          	auipc	a0,0x6
    800020e4:	15050513          	addi	a0,a0,336 # 80008230 <digits+0x1f0>
    800020e8:	ffffe097          	auipc	ra,0xffffe
    800020ec:	442080e7          	jalr	1090(ra) # 8000052a <panic>

00000000800020f0 <yield>:
{
    800020f0:	1101                	addi	sp,sp,-32
    800020f2:	ec06                	sd	ra,24(sp)
    800020f4:	e822                	sd	s0,16(sp)
    800020f6:	e426                	sd	s1,8(sp)
    800020f8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020fa:	00000097          	auipc	ra,0x0
    800020fe:	8ba080e7          	jalr	-1862(ra) # 800019b4 <myproc>
    80002102:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002104:	fffff097          	auipc	ra,0xfffff
    80002108:	abe080e7          	jalr	-1346(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    8000210c:	478d                	li	a5,3
    8000210e:	cc9c                	sw	a5,24(s1)
  sched();
    80002110:	00000097          	auipc	ra,0x0
    80002114:	f0a080e7          	jalr	-246(ra) # 8000201a <sched>
  release(&p->lock);
    80002118:	8526                	mv	a0,s1
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	b5c080e7          	jalr	-1188(ra) # 80000c76 <release>
}
    80002122:	60e2                	ld	ra,24(sp)
    80002124:	6442                	ld	s0,16(sp)
    80002126:	64a2                	ld	s1,8(sp)
    80002128:	6105                	addi	sp,sp,32
    8000212a:	8082                	ret

000000008000212c <sleep>:
{
    8000212c:	7179                	addi	sp,sp,-48
    8000212e:	f406                	sd	ra,40(sp)
    80002130:	f022                	sd	s0,32(sp)
    80002132:	ec26                	sd	s1,24(sp)
    80002134:	e84a                	sd	s2,16(sp)
    80002136:	e44e                	sd	s3,8(sp)
    80002138:	1800                	addi	s0,sp,48
    8000213a:	89aa                	mv	s3,a0
    8000213c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000213e:	00000097          	auipc	ra,0x0
    80002142:	876080e7          	jalr	-1930(ra) # 800019b4 <myproc>
    80002146:	84aa                	mv	s1,a0
  acquire(&p->lock);  //DOC: sleeplock1
    80002148:	fffff097          	auipc	ra,0xfffff
    8000214c:	a7a080e7          	jalr	-1414(ra) # 80000bc2 <acquire>
  release(lk);
    80002150:	854a                	mv	a0,s2
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	b24080e7          	jalr	-1244(ra) # 80000c76 <release>
  p->chan = chan;
    8000215a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000215e:	4789                	li	a5,2
    80002160:	cc9c                	sw	a5,24(s1)
  sched();
    80002162:	00000097          	auipc	ra,0x0
    80002166:	eb8080e7          	jalr	-328(ra) # 8000201a <sched>
  p->chan = 0;
    8000216a:	0204b023          	sd	zero,32(s1)
  release(&p->lock);
    8000216e:	8526                	mv	a0,s1
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	b06080e7          	jalr	-1274(ra) # 80000c76 <release>
  acquire(lk);
    80002178:	854a                	mv	a0,s2
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	a48080e7          	jalr	-1464(ra) # 80000bc2 <acquire>
}
    80002182:	70a2                	ld	ra,40(sp)
    80002184:	7402                	ld	s0,32(sp)
    80002186:	64e2                	ld	s1,24(sp)
    80002188:	6942                	ld	s2,16(sp)
    8000218a:	69a2                	ld	s3,8(sp)
    8000218c:	6145                	addi	sp,sp,48
    8000218e:	8082                	ret

0000000080002190 <wait>:
{
    80002190:	715d                	addi	sp,sp,-80
    80002192:	e486                	sd	ra,72(sp)
    80002194:	e0a2                	sd	s0,64(sp)
    80002196:	fc26                	sd	s1,56(sp)
    80002198:	f84a                	sd	s2,48(sp)
    8000219a:	f44e                	sd	s3,40(sp)
    8000219c:	f052                	sd	s4,32(sp)
    8000219e:	ec56                	sd	s5,24(sp)
    800021a0:	e85a                	sd	s6,16(sp)
    800021a2:	e45e                	sd	s7,8(sp)
    800021a4:	e062                	sd	s8,0(sp)
    800021a6:	0880                	addi	s0,sp,80
    800021a8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800021aa:	00000097          	auipc	ra,0x0
    800021ae:	80a080e7          	jalr	-2038(ra) # 800019b4 <myproc>
    800021b2:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021b4:	0000f517          	auipc	a0,0xf
    800021b8:	10450513          	addi	a0,a0,260 # 800112b8 <wait_lock>
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	a06080e7          	jalr	-1530(ra) # 80000bc2 <acquire>
    havekids = 0;
    800021c4:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800021c6:	4a15                	li	s4,5
        havekids = 1;
    800021c8:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800021ca:	0001b997          	auipc	s3,0x1b
    800021ce:	70698993          	addi	s3,s3,1798 # 8001d8d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021d2:	0000fc17          	auipc	s8,0xf
    800021d6:	0e6c0c13          	addi	s8,s8,230 # 800112b8 <wait_lock>
    havekids = 0;
    800021da:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800021dc:	0000f497          	auipc	s1,0xf
    800021e0:	4f448493          	addi	s1,s1,1268 # 800116d0 <proc>
    800021e4:	a0bd                	j	80002252 <wait+0xc2>
          pid = np->pid;
    800021e6:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800021ea:	000b0e63          	beqz	s6,80002206 <wait+0x76>
    800021ee:	4691                	li	a3,4
    800021f0:	02c48613          	addi	a2,s1,44
    800021f4:	85da                	mv	a1,s6
    800021f6:	05093503          	ld	a0,80(s2)
    800021fa:	fffff097          	auipc	ra,0xfffff
    800021fe:	444080e7          	jalr	1092(ra) # 8000163e <copyout>
    80002202:	02054563          	bltz	a0,8000222c <wait+0x9c>
          freeproc(np);
    80002206:	8526                	mv	a0,s1
    80002208:	00000097          	auipc	ra,0x0
    8000220c:	9b4080e7          	jalr	-1612(ra) # 80001bbc <freeproc>
          release(&np->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	a64080e7          	jalr	-1436(ra) # 80000c76 <release>
          release(&wait_lock);
    8000221a:	0000f517          	auipc	a0,0xf
    8000221e:	09e50513          	addi	a0,a0,158 # 800112b8 <wait_lock>
    80002222:	fffff097          	auipc	ra,0xfffff
    80002226:	a54080e7          	jalr	-1452(ra) # 80000c76 <release>
          return pid;
    8000222a:	a09d                	j	80002290 <wait+0x100>
            release(&np->lock);
    8000222c:	8526                	mv	a0,s1
    8000222e:	fffff097          	auipc	ra,0xfffff
    80002232:	a48080e7          	jalr	-1464(ra) # 80000c76 <release>
            release(&wait_lock);
    80002236:	0000f517          	auipc	a0,0xf
    8000223a:	08250513          	addi	a0,a0,130 # 800112b8 <wait_lock>
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	a38080e7          	jalr	-1480(ra) # 80000c76 <release>
            return -1;
    80002246:	59fd                	li	s3,-1
    80002248:	a0a1                	j	80002290 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000224a:	30848493          	addi	s1,s1,776
    8000224e:	03348463          	beq	s1,s3,80002276 <wait+0xe6>
      if(np->parent == p){
    80002252:	7c9c                	ld	a5,56(s1)
    80002254:	ff279be3          	bne	a5,s2,8000224a <wait+0xba>
        acquire(&np->lock);
    80002258:	8526                	mv	a0,s1
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	968080e7          	jalr	-1688(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002262:	4c9c                	lw	a5,24(s1)
    80002264:	f94781e3          	beq	a5,s4,800021e6 <wait+0x56>
        release(&np->lock);
    80002268:	8526                	mv	a0,s1
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	a0c080e7          	jalr	-1524(ra) # 80000c76 <release>
        havekids = 1;
    80002272:	8756                	mv	a4,s5
    80002274:	bfd9                	j	8000224a <wait+0xba>
    if(!havekids || p->killed){
    80002276:	c701                	beqz	a4,8000227e <wait+0xee>
    80002278:	02892783          	lw	a5,40(s2)
    8000227c:	c79d                	beqz	a5,800022aa <wait+0x11a>
      release(&wait_lock);
    8000227e:	0000f517          	auipc	a0,0xf
    80002282:	03a50513          	addi	a0,a0,58 # 800112b8 <wait_lock>
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	9f0080e7          	jalr	-1552(ra) # 80000c76 <release>
      return -1;
    8000228e:	59fd                	li	s3,-1
}
    80002290:	854e                	mv	a0,s3
    80002292:	60a6                	ld	ra,72(sp)
    80002294:	6406                	ld	s0,64(sp)
    80002296:	74e2                	ld	s1,56(sp)
    80002298:	7942                	ld	s2,48(sp)
    8000229a:	79a2                	ld	s3,40(sp)
    8000229c:	7a02                	ld	s4,32(sp)
    8000229e:	6ae2                	ld	s5,24(sp)
    800022a0:	6b42                	ld	s6,16(sp)
    800022a2:	6ba2                	ld	s7,8(sp)
    800022a4:	6c02                	ld	s8,0(sp)
    800022a6:	6161                	addi	sp,sp,80
    800022a8:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022aa:	85e2                	mv	a1,s8
    800022ac:	854a                	mv	a0,s2
    800022ae:	00000097          	auipc	ra,0x0
    800022b2:	e7e080e7          	jalr	-386(ra) # 8000212c <sleep>
    havekids = 0;
    800022b6:	b715                	j	800021da <wait+0x4a>

00000000800022b8 <wakeup>:
{
    800022b8:	7139                	addi	sp,sp,-64
    800022ba:	fc06                	sd	ra,56(sp)
    800022bc:	f822                	sd	s0,48(sp)
    800022be:	f426                	sd	s1,40(sp)
    800022c0:	f04a                	sd	s2,32(sp)
    800022c2:	ec4e                	sd	s3,24(sp)
    800022c4:	e852                	sd	s4,16(sp)
    800022c6:	e456                	sd	s5,8(sp)
    800022c8:	0080                	addi	s0,sp,64
    800022ca:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800022cc:	0000f497          	auipc	s1,0xf
    800022d0:	40448493          	addi	s1,s1,1028 # 800116d0 <proc>
      if(p->state == SLEEPING && p->chan == chan) {
    800022d4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022d6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022d8:	0001b917          	auipc	s2,0x1b
    800022dc:	5f890913          	addi	s2,s2,1528 # 8001d8d0 <tickslock>
    800022e0:	a811                	j	800022f4 <wakeup+0x3c>
      release(&p->lock);
    800022e2:	8526                	mv	a0,s1
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	992080e7          	jalr	-1646(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022ec:	30848493          	addi	s1,s1,776
    800022f0:	03248663          	beq	s1,s2,8000231c <wakeup+0x64>
    if(p != myproc()){
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	6c0080e7          	jalr	1728(ra) # 800019b4 <myproc>
    800022fc:	fea488e3          	beq	s1,a0,800022ec <wakeup+0x34>
      acquire(&p->lock);
    80002300:	8526                	mv	a0,s1
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	8c0080e7          	jalr	-1856(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000230a:	4c9c                	lw	a5,24(s1)
    8000230c:	fd379be3          	bne	a5,s3,800022e2 <wakeup+0x2a>
    80002310:	709c                	ld	a5,32(s1)
    80002312:	fd4798e3          	bne	a5,s4,800022e2 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002316:	0154ac23          	sw	s5,24(s1)
    8000231a:	b7e1                	j	800022e2 <wakeup+0x2a>
}
    8000231c:	70e2                	ld	ra,56(sp)
    8000231e:	7442                	ld	s0,48(sp)
    80002320:	74a2                	ld	s1,40(sp)
    80002322:	7902                	ld	s2,32(sp)
    80002324:	69e2                	ld	s3,24(sp)
    80002326:	6a42                	ld	s4,16(sp)
    80002328:	6aa2                	ld	s5,8(sp)
    8000232a:	6121                	addi	sp,sp,64
    8000232c:	8082                	ret

000000008000232e <reparent>:
{
    8000232e:	7179                	addi	sp,sp,-48
    80002330:	f406                	sd	ra,40(sp)
    80002332:	f022                	sd	s0,32(sp)
    80002334:	ec26                	sd	s1,24(sp)
    80002336:	e84a                	sd	s2,16(sp)
    80002338:	e44e                	sd	s3,8(sp)
    8000233a:	e052                	sd	s4,0(sp)
    8000233c:	1800                	addi	s0,sp,48
    8000233e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002340:	0000f497          	auipc	s1,0xf
    80002344:	39048493          	addi	s1,s1,912 # 800116d0 <proc>
      pp->parent = initproc;
    80002348:	00007a17          	auipc	s4,0x7
    8000234c:	ce0a0a13          	addi	s4,s4,-800 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002350:	0001b997          	auipc	s3,0x1b
    80002354:	58098993          	addi	s3,s3,1408 # 8001d8d0 <tickslock>
    80002358:	a029                	j	80002362 <reparent+0x34>
    8000235a:	30848493          	addi	s1,s1,776
    8000235e:	01348d63          	beq	s1,s3,80002378 <reparent+0x4a>
    if(pp->parent == p){
    80002362:	7c9c                	ld	a5,56(s1)
    80002364:	ff279be3          	bne	a5,s2,8000235a <reparent+0x2c>
      pp->parent = initproc;
    80002368:	000a3503          	ld	a0,0(s4)
    8000236c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000236e:	00000097          	auipc	ra,0x0
    80002372:	f4a080e7          	jalr	-182(ra) # 800022b8 <wakeup>
    80002376:	b7d5                	j	8000235a <reparent+0x2c>
}
    80002378:	70a2                	ld	ra,40(sp)
    8000237a:	7402                	ld	s0,32(sp)
    8000237c:	64e2                	ld	s1,24(sp)
    8000237e:	6942                	ld	s2,16(sp)
    80002380:	69a2                	ld	s3,8(sp)
    80002382:	6a02                	ld	s4,0(sp)
    80002384:	6145                	addi	sp,sp,48
    80002386:	8082                	ret

0000000080002388 <exit>:
{
    80002388:	7179                	addi	sp,sp,-48
    8000238a:	f406                	sd	ra,40(sp)
    8000238c:	f022                	sd	s0,32(sp)
    8000238e:	ec26                	sd	s1,24(sp)
    80002390:	e84a                	sd	s2,16(sp)
    80002392:	e44e                	sd	s3,8(sp)
    80002394:	e052                	sd	s4,0(sp)
    80002396:	1800                	addi	s0,sp,48
    80002398:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	61a080e7          	jalr	1562(ra) # 800019b4 <myproc>
    800023a2:	89aa                	mv	s3,a0
  if(p == initproc)
    800023a4:	00007797          	auipc	a5,0x7
    800023a8:	c847b783          	ld	a5,-892(a5) # 80009028 <initproc>
    800023ac:	0d050493          	addi	s1,a0,208
    800023b0:	15050913          	addi	s2,a0,336
    800023b4:	02a79363          	bne	a5,a0,800023da <exit+0x52>
    panic("init exiting");
    800023b8:	00006517          	auipc	a0,0x6
    800023bc:	e9050513          	addi	a0,a0,-368 # 80008248 <digits+0x208>
    800023c0:	ffffe097          	auipc	ra,0xffffe
    800023c4:	16a080e7          	jalr	362(ra) # 8000052a <panic>
      fileclose(f);
    800023c8:	00003097          	auipc	ra,0x3
    800023cc:	822080e7          	jalr	-2014(ra) # 80004bea <fileclose>
      p->ofile[fd] = 0;
    800023d0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800023d4:	04a1                	addi	s1,s1,8
    800023d6:	01248563          	beq	s1,s2,800023e0 <exit+0x58>
    if(p->ofile[fd]){
    800023da:	6088                	ld	a0,0(s1)
    800023dc:	f575                	bnez	a0,800023c8 <exit+0x40>
    800023de:	bfdd                	j	800023d4 <exit+0x4c>
  begin_op();
    800023e0:	00002097          	auipc	ra,0x2
    800023e4:	33e080e7          	jalr	830(ra) # 8000471e <begin_op>
  iput(p->cwd);
    800023e8:	1509b503          	ld	a0,336(s3)
    800023ec:	00002097          	auipc	ra,0x2
    800023f0:	b16080e7          	jalr	-1258(ra) # 80003f02 <iput>
  end_op();
    800023f4:	00002097          	auipc	ra,0x2
    800023f8:	3aa080e7          	jalr	938(ra) # 8000479e <end_op>
  p->cwd = 0;
    800023fc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002400:	0000f497          	auipc	s1,0xf
    80002404:	eb848493          	addi	s1,s1,-328 # 800112b8 <wait_lock>
    80002408:	8526                	mv	a0,s1
    8000240a:	ffffe097          	auipc	ra,0xffffe
    8000240e:	7b8080e7          	jalr	1976(ra) # 80000bc2 <acquire>
  reparent(p);
    80002412:	854e                	mv	a0,s3
    80002414:	00000097          	auipc	ra,0x0
    80002418:	f1a080e7          	jalr	-230(ra) # 8000232e <reparent>
  wakeup(p->parent);
    8000241c:	0389b503          	ld	a0,56(s3)
    80002420:	00000097          	auipc	ra,0x0
    80002424:	e98080e7          	jalr	-360(ra) # 800022b8 <wakeup>
  acquire(&p->lock);
    80002428:	854e                	mv	a0,s3
    8000242a:	ffffe097          	auipc	ra,0xffffe
    8000242e:	798080e7          	jalr	1944(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002432:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002436:	4795                	li	a5,5
    80002438:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000243c:	8526                	mv	a0,s1
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	838080e7          	jalr	-1992(ra) # 80000c76 <release>
  sched();
    80002446:	00000097          	auipc	ra,0x0
    8000244a:	bd4080e7          	jalr	-1068(ra) # 8000201a <sched>
  panic("zombie exit");
    8000244e:	00006517          	auipc	a0,0x6
    80002452:	e0a50513          	addi	a0,a0,-502 # 80008258 <digits+0x218>
    80002456:	ffffe097          	auipc	ra,0xffffe
    8000245a:	0d4080e7          	jalr	212(ra) # 8000052a <panic>

000000008000245e <kill>:
  if(signum<0 || signum>31)
    8000245e:	47fd                	li	a5,31
    80002460:	06b7ed63          	bltu	a5,a1,800024da <kill+0x7c>
{
    80002464:	7179                	addi	sp,sp,-48
    80002466:	f406                	sd	ra,40(sp)
    80002468:	f022                	sd	s0,32(sp)
    8000246a:	ec26                	sd	s1,24(sp)
    8000246c:	e84a                	sd	s2,16(sp)
    8000246e:	e44e                	sd	s3,8(sp)
    80002470:	e052                	sd	s4,0(sp)
    80002472:	1800                	addi	s0,sp,48
    80002474:	892a                	mv	s2,a0
    80002476:	8a2e                	mv	s4,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80002478:	0000f497          	auipc	s1,0xf
    8000247c:	25848493          	addi	s1,s1,600 # 800116d0 <proc>
    80002480:	0001b997          	auipc	s3,0x1b
    80002484:	45098993          	addi	s3,s3,1104 # 8001d8d0 <tickslock>
    acquire(&p->lock);
    80002488:	8526                	mv	a0,s1
    8000248a:	ffffe097          	auipc	ra,0xffffe
    8000248e:	738080e7          	jalr	1848(ra) # 80000bc2 <acquire>
    if(p->pid == pid){// maybe check if ignore?
    80002492:	589c                	lw	a5,48(s1)
    80002494:	01278d63          	beq	a5,s2,800024ae <kill+0x50>
    release(&p->lock);
    80002498:	8526                	mv	a0,s1
    8000249a:	ffffe097          	auipc	ra,0xffffe
    8000249e:	7dc080e7          	jalr	2012(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024a2:	30848493          	addi	s1,s1,776
    800024a6:	ff3491e3          	bne	s1,s3,80002488 <kill+0x2a>
  return -1;
    800024aa:	557d                	li	a0,-1
    800024ac:	a839                	j	800024ca <kill+0x6c>
      p->pendding_signals |= ((uint)1 << signum);// or bitwise to turn on new signal in pedding signals
    800024ae:	4785                	li	a5,1
    800024b0:	0147973b          	sllw	a4,a5,s4
    800024b4:	1684a783          	lw	a5,360(s1)
    800024b8:	8fd9                	or	a5,a5,a4
    800024ba:	16f4a423          	sw	a5,360(s1)
      release(&p->lock);
    800024be:	8526                	mv	a0,s1
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	7b6080e7          	jalr	1974(ra) # 80000c76 <release>
      return 0;
    800024c8:	4501                	li	a0,0
}
    800024ca:	70a2                	ld	ra,40(sp)
    800024cc:	7402                	ld	s0,32(sp)
    800024ce:	64e2                	ld	s1,24(sp)
    800024d0:	6942                	ld	s2,16(sp)
    800024d2:	69a2                	ld	s3,8(sp)
    800024d4:	6a02                	ld	s4,0(sp)
    800024d6:	6145                	addi	sp,sp,48
    800024d8:	8082                	ret
    return -1;
    800024da:	557d                	li	a0,-1
}
    800024dc:	8082                	ret

00000000800024de <either_copyout>:
{
    800024de:	7179                	addi	sp,sp,-48
    800024e0:	f406                	sd	ra,40(sp)
    800024e2:	f022                	sd	s0,32(sp)
    800024e4:	ec26                	sd	s1,24(sp)
    800024e6:	e84a                	sd	s2,16(sp)
    800024e8:	e44e                	sd	s3,8(sp)
    800024ea:	e052                	sd	s4,0(sp)
    800024ec:	1800                	addi	s0,sp,48
    800024ee:	84aa                	mv	s1,a0
    800024f0:	892e                	mv	s2,a1
    800024f2:	89b2                	mv	s3,a2
    800024f4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	4be080e7          	jalr	1214(ra) # 800019b4 <myproc>
  if(user_dst){
    800024fe:	c08d                	beqz	s1,80002520 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002500:	86d2                	mv	a3,s4
    80002502:	864e                	mv	a2,s3
    80002504:	85ca                	mv	a1,s2
    80002506:	6928                	ld	a0,80(a0)
    80002508:	fffff097          	auipc	ra,0xfffff
    8000250c:	136080e7          	jalr	310(ra) # 8000163e <copyout>
}
    80002510:	70a2                	ld	ra,40(sp)
    80002512:	7402                	ld	s0,32(sp)
    80002514:	64e2                	ld	s1,24(sp)
    80002516:	6942                	ld	s2,16(sp)
    80002518:	69a2                	ld	s3,8(sp)
    8000251a:	6a02                	ld	s4,0(sp)
    8000251c:	6145                	addi	sp,sp,48
    8000251e:	8082                	ret
    memmove((char *)dst, src, len);
    80002520:	000a061b          	sext.w	a2,s4
    80002524:	85ce                	mv	a1,s3
    80002526:	854a                	mv	a0,s2
    80002528:	ffffe097          	auipc	ra,0xffffe
    8000252c:	7f2080e7          	jalr	2034(ra) # 80000d1a <memmove>
    return 0;
    80002530:	8526                	mv	a0,s1
    80002532:	bff9                	j	80002510 <either_copyout+0x32>

0000000080002534 <either_copyin>:
{
    80002534:	7179                	addi	sp,sp,-48
    80002536:	f406                	sd	ra,40(sp)
    80002538:	f022                	sd	s0,32(sp)
    8000253a:	ec26                	sd	s1,24(sp)
    8000253c:	e84a                	sd	s2,16(sp)
    8000253e:	e44e                	sd	s3,8(sp)
    80002540:	e052                	sd	s4,0(sp)
    80002542:	1800                	addi	s0,sp,48
    80002544:	892a                	mv	s2,a0
    80002546:	84ae                	mv	s1,a1
    80002548:	89b2                	mv	s3,a2
    8000254a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000254c:	fffff097          	auipc	ra,0xfffff
    80002550:	468080e7          	jalr	1128(ra) # 800019b4 <myproc>
  if(user_src){
    80002554:	c08d                	beqz	s1,80002576 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002556:	86d2                	mv	a3,s4
    80002558:	864e                	mv	a2,s3
    8000255a:	85ca                	mv	a1,s2
    8000255c:	6928                	ld	a0,80(a0)
    8000255e:	fffff097          	auipc	ra,0xfffff
    80002562:	16c080e7          	jalr	364(ra) # 800016ca <copyin>
}
    80002566:	70a2                	ld	ra,40(sp)
    80002568:	7402                	ld	s0,32(sp)
    8000256a:	64e2                	ld	s1,24(sp)
    8000256c:	6942                	ld	s2,16(sp)
    8000256e:	69a2                	ld	s3,8(sp)
    80002570:	6a02                	ld	s4,0(sp)
    80002572:	6145                	addi	sp,sp,48
    80002574:	8082                	ret
    memmove(dst, (char*)src, len);
    80002576:	000a061b          	sext.w	a2,s4
    8000257a:	85ce                	mv	a1,s3
    8000257c:	854a                	mv	a0,s2
    8000257e:	ffffe097          	auipc	ra,0xffffe
    80002582:	79c080e7          	jalr	1948(ra) # 80000d1a <memmove>
    return 0;
    80002586:	8526                	mv	a0,s1
    80002588:	bff9                	j	80002566 <either_copyin+0x32>

000000008000258a <procdump>:
{
    8000258a:	715d                	addi	sp,sp,-80
    8000258c:	e486                	sd	ra,72(sp)
    8000258e:	e0a2                	sd	s0,64(sp)
    80002590:	fc26                	sd	s1,56(sp)
    80002592:	f84a                	sd	s2,48(sp)
    80002594:	f44e                	sd	s3,40(sp)
    80002596:	f052                	sd	s4,32(sp)
    80002598:	ec56                	sd	s5,24(sp)
    8000259a:	e85a                	sd	s6,16(sp)
    8000259c:	e45e                	sd	s7,8(sp)
    8000259e:	0880                	addi	s0,sp,80
  printf("\n");
    800025a0:	00006517          	auipc	a0,0x6
    800025a4:	d4850513          	addi	a0,a0,-696 # 800082e8 <digits+0x2a8>
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	fcc080e7          	jalr	-52(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025b0:	0000f497          	auipc	s1,0xf
    800025b4:	27848493          	addi	s1,s1,632 # 80011828 <proc+0x158>
    800025b8:	0001b917          	auipc	s2,0x1b
    800025bc:	47090913          	addi	s2,s2,1136 # 8001da28 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025c0:	4b15                	li	s6,5
      state = "???";
    800025c2:	00006997          	auipc	s3,0x6
    800025c6:	ca698993          	addi	s3,s3,-858 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    800025ca:	00006a97          	auipc	s5,0x6
    800025ce:	ca6a8a93          	addi	s5,s5,-858 # 80008270 <digits+0x230>
    printf("\n");
    800025d2:	00006a17          	auipc	s4,0x6
    800025d6:	d16a0a13          	addi	s4,s4,-746 # 800082e8 <digits+0x2a8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025da:	00006b97          	auipc	s7,0x6
    800025de:	d3eb8b93          	addi	s7,s7,-706 # 80008318 <states.0>
    800025e2:	a00d                	j	80002604 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025e4:	ed86a583          	lw	a1,-296(a3)
    800025e8:	8556                	mv	a0,s5
    800025ea:	ffffe097          	auipc	ra,0xffffe
    800025ee:	f8a080e7          	jalr	-118(ra) # 80000574 <printf>
    printf("\n");
    800025f2:	8552                	mv	a0,s4
    800025f4:	ffffe097          	auipc	ra,0xffffe
    800025f8:	f80080e7          	jalr	-128(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025fc:	30848493          	addi	s1,s1,776
    80002600:	03248263          	beq	s1,s2,80002624 <procdump+0x9a>
    if(p->state == UNUSED)
    80002604:	86a6                	mv	a3,s1
    80002606:	ec04a783          	lw	a5,-320(s1)
    8000260a:	dbed                	beqz	a5,800025fc <procdump+0x72>
      state = "???";
    8000260c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000260e:	fcfb6be3          	bltu	s6,a5,800025e4 <procdump+0x5a>
    80002612:	02079713          	slli	a4,a5,0x20
    80002616:	01d75793          	srli	a5,a4,0x1d
    8000261a:	97de                	add	a5,a5,s7
    8000261c:	6390                	ld	a2,0(a5)
    8000261e:	f279                	bnez	a2,800025e4 <procdump+0x5a>
      state = "???";
    80002620:	864e                	mv	a2,s3
    80002622:	b7c9                	j	800025e4 <procdump+0x5a>
}
    80002624:	60a6                	ld	ra,72(sp)
    80002626:	6406                	ld	s0,64(sp)
    80002628:	74e2                	ld	s1,56(sp)
    8000262a:	7942                	ld	s2,48(sp)
    8000262c:	79a2                	ld	s3,40(sp)
    8000262e:	7a02                	ld	s4,32(sp)
    80002630:	6ae2                	ld	s5,24(sp)
    80002632:	6b42                	ld	s6,16(sp)
    80002634:	6ba2                	ld	s7,8(sp)
    80002636:	6161                	addi	sp,sp,80
    80002638:	8082                	ret

000000008000263a <sigprocmask>:
sigprocmask(uint sigmask){
    8000263a:	7179                	addi	sp,sp,-48
    8000263c:	f406                	sd	ra,40(sp)
    8000263e:	f022                	sd	s0,32(sp)
    80002640:	ec26                	sd	s1,24(sp)
    80002642:	e84a                	sd	s2,16(sp)
    80002644:	e44e                	sd	s3,8(sp)
    80002646:	1800                	addi	s0,sp,48
    80002648:	892a                	mv	s2,a0
  struct proc *p=myproc();
    8000264a:	fffff097          	auipc	ra,0xfffff
    8000264e:	36a080e7          	jalr	874(ra) # 800019b4 <myproc>
    80002652:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002654:	ffffe097          	auipc	ra,0xffffe
    80002658:	56e080e7          	jalr	1390(ra) # 80000bc2 <acquire>
  uint prev=p->signal_mask;
    8000265c:	16c4a983          	lw	s3,364(s1)
  p->signal_mask=sigmask;
    80002660:	1724a623          	sw	s2,364(s1)
  release(&p->lock);
    80002664:	8526                	mv	a0,s1
    80002666:	ffffe097          	auipc	ra,0xffffe
    8000266a:	610080e7          	jalr	1552(ra) # 80000c76 <release>
}
    8000266e:	854e                	mv	a0,s3
    80002670:	70a2                	ld	ra,40(sp)
    80002672:	7402                	ld	s0,32(sp)
    80002674:	64e2                	ld	s1,24(sp)
    80002676:	6942                	ld	s2,16(sp)
    80002678:	69a2                	ld	s3,8(sp)
    8000267a:	6145                	addi	sp,sp,48
    8000267c:	8082                	ret

000000008000267e <sigKillHandler>:
//task 1.5

//task 2.3
void
sigKillHandler(){
    8000267e:	1141                	addi	sp,sp,-16
    80002680:	e406                	sd	ra,8(sp)
    80002682:	e022                	sd	s0,0(sp)
    80002684:	0800                	addi	s0,sp,16
  struct proc *p=myproc();
    80002686:	fffff097          	auipc	ra,0xfffff
    8000268a:	32e080e7          	jalr	814(ra) # 800019b4 <myproc>
  p->killed = 1;
    8000268e:	4785                	li	a5,1
    80002690:	d51c                	sw	a5,40(a0)
  if(p->state == SLEEPING){
    80002692:	4d18                	lw	a4,24(a0)
    80002694:	4789                	li	a5,2
    80002696:	00f70663          	beq	a4,a5,800026a2 <sigKillHandler+0x24>
  //Wake process from sleep().
    p->state = RUNNABLE;
  return;
  }
}
    8000269a:	60a2                	ld	ra,8(sp)
    8000269c:	6402                	ld	s0,0(sp)
    8000269e:	0141                	addi	sp,sp,16
    800026a0:	8082                	ret
    p->state = RUNNABLE;
    800026a2:	478d                	li	a5,3
    800026a4:	cd1c                	sw	a5,24(a0)
  return;
    800026a6:	bfd5                	j	8000269a <sigKillHandler+0x1c>

00000000800026a8 <sigStopHandler>:
void
sigStopHandler(){
    800026a8:	1141                	addi	sp,sp,-16
    800026aa:	e406                	sd	ra,8(sp)
    800026ac:	e022                	sd	s0,0(sp)
    800026ae:	0800                	addi	s0,sp,16
  struct proc *p=myproc();
    800026b0:	fffff097          	auipc	ra,0xfffff
    800026b4:	304080e7          	jalr	772(ra) # 800019b4 <myproc>
  p->frozen=1;
    800026b8:	4785                	li	a5,1
    800026ba:	2ef52c23          	sw	a5,760(a0)
  return;
}
    800026be:	60a2                	ld	ra,8(sp)
    800026c0:	6402                	ld	s0,0(sp)
    800026c2:	0141                	addi	sp,sp,16
    800026c4:	8082                	ret

00000000800026c6 <sigContHandler>:
void
sigContHandler(){
    800026c6:	1141                	addi	sp,sp,-16
    800026c8:	e406                	sd	ra,8(sp)
    800026ca:	e022                	sd	s0,0(sp)
    800026cc:	0800                	addi	s0,sp,16
  struct proc *p=myproc();
    800026ce:	fffff097          	auipc	ra,0xfffff
    800026d2:	2e6080e7          	jalr	742(ra) # 800019b4 <myproc>
  p->frozen=0;
    800026d6:	2e052c23          	sw	zero,760(a0)
  return;
}
    800026da:	60a2                	ld	ra,8(sp)
    800026dc:	6402                	ld	s0,0(sp)
    800026de:	0141                	addi	sp,sp,16
    800026e0:	8082                	ret

00000000800026e2 <sigaction>:



//task 1.4
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    800026e2:	7159                	addi	sp,sp,-112
    800026e4:	f486                	sd	ra,104(sp)
    800026e6:	f0a2                	sd	s0,96(sp)
    800026e8:	eca6                	sd	s1,88(sp)
    800026ea:	e8ca                	sd	s2,80(sp)
    800026ec:	e4ce                	sd	s3,72(sp)
    800026ee:	e0d2                	sd	s4,64(sp)
    800026f0:	fc56                	sd	s5,56(sp)
    800026f2:	f85a                	sd	s6,48(sp)
    800026f4:	1880                	addi	s0,sp,112
    800026f6:	892a                	mv	s2,a0
    800026f8:	89ae                	mv	s3,a1
    800026fa:	8a32                	mv	s4,a2
  struct proc *p=myproc();
    800026fc:	fffff097          	auipc	ra,0xfffff
    80002700:	2b8080e7          	jalr	696(ra) # 800019b4 <myproc>
    80002704:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	4bc080e7          	jalr	1212(ra) # 80000bc2 <acquire>
  void* khandler=0;
    8000270e:	fa043c23          	sd	zero,-72(s0)
  uint kmask=0;
    80002712:	fa042a23          	sw	zero,-76(s0)

 


  if(signum<0 || signum >31 || signum==SIGKILL || signum ==SIGSTOP){ // signum invalid 
    80002716:	0009079b          	sext.w	a5,s2
    8000271a:	477d                	li	a4,31
    8000271c:	14f76f63          	bltu	a4,a5,8000287a <sigaction+0x198>
    80002720:	37dd                	addiw	a5,a5,-9
    80002722:	9bdd                	andi	a5,a5,-9
    80002724:	2781                	sext.w	a5,a5
    80002726:	14078a63          	beqz	a5,8000287a <sigaction+0x198>
    release(&p->lock);
    return -1;
  }
  
  if(act != 0){ //act is not null
    8000272a:	1a098963          	beqz	s3,800028dc <sigaction+0x1fa>
    
    if(copyin(p->pagetable,(char*)&kmask,(uint64)&act->sigmask,sizeof(uint))==-1 ||
    8000272e:	4691                	li	a3,4
    80002730:	00898613          	addi	a2,s3,8
    80002734:	fb440593          	addi	a1,s0,-76
    80002738:	68a8                	ld	a0,80(s1)
    8000273a:	fffff097          	auipc	ra,0xfffff
    8000273e:	f90080e7          	jalr	-112(ra) # 800016ca <copyin>
    80002742:	57fd                	li	a5,-1
    80002744:	14f50263          	beq	a0,a5,80002888 <sigaction+0x1a6>
       copyin(p->pagetable,(char*)&khandler,(uint64)&act->sa_handler,sizeof(void*))==-1 ){ // copyin sigmask and handler
    80002748:	46a1                	li	a3,8
    8000274a:	864e                	mv	a2,s3
    8000274c:	fb840593          	addi	a1,s0,-72
    80002750:	68a8                	ld	a0,80(s1)
    80002752:	fffff097          	auipc	ra,0xfffff
    80002756:	f78080e7          	jalr	-136(ra) # 800016ca <copyin>
    if(copyin(p->pagetable,(char*)&kmask,(uint64)&act->sigmask,sizeof(uint))==-1 ||
    8000275a:	57fd                	li	a5,-1
    8000275c:	12f50663          	beq	a0,a5,80002888 <sigaction+0x1a6>
          release(&p->lock);
          return -1;
    }

    
    printf("sig mask is %d\nkhandler is %d\n",kmask,khandler);
    80002760:	fb843603          	ld	a2,-72(s0)
    80002764:	fb442583          	lw	a1,-76(s0)
    80002768:	00006517          	auipc	a0,0x6
    8000276c:	b1850513          	addi	a0,a0,-1256 # 80008280 <digits+0x240>
    80002770:	ffffe097          	auipc	ra,0xffffe
    80002774:	e04080e7          	jalr	-508(ra) # 80000574 <printf>
    if(kmask<0){    // invalid sigmask
      release(&p->lock);
      return -1;
    }
    // check if current handler is a kernel handler
    void* cuurrent= p->signal_handlers[signum];
    80002778:	00391a93          	slli	s5,s2,0x3
    8000277c:	9aa6                	add	s5,s5,s1
    8000277e:	170ab783          	ld	a5,368(s5)
    80002782:	faf43023          	sd	a5,-96(s0)
    if(cuurrent==(void*)SIGKILL || cuurrent==(void*)SIGSTOP || cuurrent==(void*)SIG_DFL || cuurrent==(void*)SIGCONT || cuurrent==(void*)SIG_IGN){
    80002786:	4725                	li	a4,9
    80002788:	10e78763          	beq	a5,a4,80002896 <sigaction+0x1b4>
    8000278c:	4745                	li	a4,17
    8000278e:	10e78463          	beq	a5,a4,80002896 <sigaction+0x1b4>
    80002792:	10078263          	beqz	a5,80002896 <sigaction+0x1b4>
    80002796:	474d                	li	a4,19
    80002798:	0ee78f63          	beq	a5,a4,80002896 <sigaction+0x1b4>
    8000279c:	4705                	li	a4,1
    8000279e:	0ee78c63          	beq	a5,a4,80002896 <sigaction+0x1b4>
        //printf("got here  %d\n",p->signal_handlers[signum]);

      
      }
    }else{// current handler is a userspace handler
      if(oldact!=0){ // old act isnt null
    800027a2:	120a0d63          	beqz	s4,800028dc <sigaction+0x1fa>
        
        void* currenthandlerKaddr=0;
    800027a6:	fa043423          	sd	zero,-88(s0)
        uint cuurrentmaskKaddr=0;
    800027aa:	f8042e23          	sw	zero,-100(s0)
        //step 4.1
        if(copyin(p->pagetable,(char*)&cuurrentmaskKaddr,(uint64)&p->signal_handlers_mask[signum],sizeof(uint))==-1 ||
    800027ae:	09c90993          	addi	s3,s2,156
    800027b2:	098a                	slli	s3,s3,0x2
    800027b4:	99a6                	add	s3,s3,s1
    800027b6:	4691                	li	a3,4
    800027b8:	864e                	mv	a2,s3
    800027ba:	f9c40593          	addi	a1,s0,-100
    800027be:	68a8                	ld	a0,80(s1)
    800027c0:	fffff097          	auipc	ra,0xfffff
    800027c4:	f0a080e7          	jalr	-246(ra) # 800016ca <copyin>
    800027c8:	57fd                	li	a5,-1
    800027ca:	14f50063          	beq	a0,a5,8000290a <sigaction+0x228>
        copyin(p->pagetable,(char*)&currenthandlerKaddr,(uint64)&p->signal_handlers[signum],sizeof(void*))==-1 ){ // copyin sigmask and handler
    800027ce:	02e90b13          	addi	s6,s2,46
    800027d2:	0b0e                	slli	s6,s6,0x3
    800027d4:	9b26                	add	s6,s6,s1
    800027d6:	46a1                	li	a3,8
    800027d8:	865a                	mv	a2,s6
    800027da:	fa840593          	addi	a1,s0,-88
    800027de:	68a8                	ld	a0,80(s1)
    800027e0:	fffff097          	auipc	ra,0xfffff
    800027e4:	eea080e7          	jalr	-278(ra) # 800016ca <copyin>
        if(copyin(p->pagetable,(char*)&cuurrentmaskKaddr,(uint64)&p->signal_handlers_mask[signum],sizeof(uint))==-1 ||
    800027e8:	57fd                	li	a5,-1
    800027ea:	12f50063          	beq	a0,a5,8000290a <sigaction+0x228>
          release(&p->lock);
          return -1;
        }
        //step 4.2
        if(copyout(p->pagetable,(uint64)&oldact->sa_handler,(char*)&currenthandlerKaddr,sizeof(void*))==-1||
    800027ee:	46a1                	li	a3,8
    800027f0:	fa840613          	addi	a2,s0,-88
    800027f4:	85d2                	mv	a1,s4
    800027f6:	68a8                	ld	a0,80(s1)
    800027f8:	fffff097          	auipc	ra,0xfffff
    800027fc:	e46080e7          	jalr	-442(ra) # 8000163e <copyout>
    80002800:	57fd                	li	a5,-1
    80002802:	10f50b63          	beq	a0,a5,80002918 <sigaction+0x236>
        copyout(p->pagetable,(uint64)&oldact->sigmask,(char*)&cuurrentmaskKaddr,sizeof(uint))==-1){
    80002806:	4691                	li	a3,4
    80002808:	f9c40613          	addi	a2,s0,-100
    8000280c:	008a0593          	addi	a1,s4,8
    80002810:	68a8                	ld	a0,80(s1)
    80002812:	fffff097          	auipc	ra,0xfffff
    80002816:	e2c080e7          	jalr	-468(ra) # 8000163e <copyout>
        if(copyout(p->pagetable,(uint64)&oldact->sa_handler,(char*)&currenthandlerKaddr,sizeof(void*))==-1||
    8000281a:	57fd                	li	a5,-1
    8000281c:	0ef50e63          	beq	a0,a5,80002918 <sigaction+0x236>
          release(&p->lock);
          return -1;
        }
        //check if act is a kernel handler
        if(khandler==(void*)SIG_DFL ||khandler==(void*)SIG_IGN || khandler==(void*)SIGCONT || khandler==(void*)SIGKILL || khandler==(void*)SIGSTOP ){
    80002820:	fb843783          	ld	a5,-72(s0)
    80002824:	4705                	li	a4,1
    80002826:	10f77063          	bgeu	a4,a5,80002926 <sigaction+0x244>
    8000282a:	474d                	li	a4,19
    8000282c:	0ee78d63          	beq	a5,a4,80002926 <sigaction+0x244>
    80002830:	4725                	li	a4,9
    80002832:	0ee78a63          	beq	a5,a4,80002926 <sigaction+0x244>
    80002836:	4745                	li	a4,17
    80002838:	0ee78763          	beq	a5,a4,80002926 <sigaction+0x244>
          release(&p->lock);
          return 0;
          
        }
        //step 4.3  maybe change this
        if(copyout(p->pagetable,(uint64)&p->signal_handlers[signum],(char*)&khandler,sizeof(void*))==-1 ||
    8000283c:	46a1                	li	a3,8
    8000283e:	fb840613          	addi	a2,s0,-72
    80002842:	85da                	mv	a1,s6
    80002844:	68a8                	ld	a0,80(s1)
    80002846:	fffff097          	auipc	ra,0xfffff
    8000284a:	df8080e7          	jalr	-520(ra) # 8000163e <copyout>
    8000284e:	57fd                	li	a5,-1
    80002850:	00f50e63          	beq	a0,a5,8000286c <sigaction+0x18a>
        copyout(p->pagetable,(uint64)&p->signal_handlers_mask[signum],(char*)&kmask,sizeof(uint))==-1){
    80002854:	4691                	li	a3,4
    80002856:	fb440613          	addi	a2,s0,-76
    8000285a:	85ce                	mv	a1,s3
    8000285c:	68a8                	ld	a0,80(s1)
    8000285e:	fffff097          	auipc	ra,0xfffff
    80002862:	de0080e7          	jalr	-544(ra) # 8000163e <copyout>
        if(copyout(p->pagetable,(uint64)&p->signal_handlers[signum],(char*)&khandler,sizeof(void*))==-1 ||
    80002866:	57fd                	li	a5,-1
    80002868:	06f51a63          	bne	a0,a5,800028dc <sigaction+0x1fa>
          release(&p->lock);
    8000286c:	8526                	mv	a0,s1
    8000286e:	ffffe097          	auipc	ra,0xffffe
    80002872:	408080e7          	jalr	1032(ra) # 80000c76 <release>
          return -1;
    80002876:	59fd                	li	s3,-1
    80002878:	a885                	j	800028e8 <sigaction+0x206>
    release(&p->lock);
    8000287a:	8526                	mv	a0,s1
    8000287c:	ffffe097          	auipc	ra,0xffffe
    80002880:	3fa080e7          	jalr	1018(ra) # 80000c76 <release>
    return -1;
    80002884:	59fd                	li	s3,-1
    80002886:	a08d                	j	800028e8 <sigaction+0x206>
          release(&p->lock);
    80002888:	8526                	mv	a0,s1
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	3ec080e7          	jalr	1004(ra) # 80000c76 <release>
          return -1;
    80002892:	59fd                	li	s3,-1
    80002894:	a891                	j	800028e8 <sigaction+0x206>
      if(oldact!=0){// check if oldact is not null
    80002896:	040a0363          	beqz	s4,800028dc <sigaction+0x1fa>
        if(copyout(p->pagetable,(uint64)oldact,(char*)&cuurrent,sizeof(void*))==-1){// copyout kernrel handler
    8000289a:	46a1                	li	a3,8
    8000289c:	fa040613          	addi	a2,s0,-96
    800028a0:	85d2                	mv	a1,s4
    800028a2:	68a8                	ld	a0,80(s1)
    800028a4:	fffff097          	auipc	ra,0xfffff
    800028a8:	d9a080e7          	jalr	-614(ra) # 8000163e <copyout>
    800028ac:	89aa                	mv	s3,a0
    800028ae:	57fd                	li	a5,-1
    800028b0:	04f50763          	beq	a0,a5,800028fe <sigaction+0x21c>
        p->signal_handlers_mask[signum]=kmask;
    800028b4:	09c90913          	addi	s2,s2,156
    800028b8:	090a                	slli	s2,s2,0x2
    800028ba:	9926                	add	s2,s2,s1
    800028bc:	fb442783          	lw	a5,-76(s0)
    800028c0:	00f92023          	sw	a5,0(s2)
      p->signal_handlers[signum]=(void*)khandler;// was khandler
    800028c4:	fb843583          	ld	a1,-72(s0)
    800028c8:	16bab823          	sd	a1,368(s5)
      printf("pass %d\n",p->signal_handlers[signum]);
    800028cc:	00006517          	auipc	a0,0x6
    800028d0:	9d450513          	addi	a0,a0,-1580 # 800082a0 <digits+0x260>
    800028d4:	ffffe097          	auipc	ra,0xffffe
    800028d8:	ca0080e7          	jalr	-864(ra) # 80000574 <printf>
        }
      }
      }
  }

  release(&p->lock);
    800028dc:	8526                	mv	a0,s1
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	398080e7          	jalr	920(ra) # 80000c76 <release>
  return 0;
    800028e6:	4981                	li	s3,0
}
    800028e8:	854e                	mv	a0,s3
    800028ea:	70a6                	ld	ra,104(sp)
    800028ec:	7406                	ld	s0,96(sp)
    800028ee:	64e6                	ld	s1,88(sp)
    800028f0:	6946                	ld	s2,80(sp)
    800028f2:	69a6                	ld	s3,72(sp)
    800028f4:	6a06                	ld	s4,64(sp)
    800028f6:	7ae2                	ld	s5,56(sp)
    800028f8:	7b42                	ld	s6,48(sp)
    800028fa:	6165                	addi	sp,sp,112
    800028fc:	8082                	ret
          release(&p->lock);
    800028fe:	8526                	mv	a0,s1
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	376080e7          	jalr	886(ra) # 80000c76 <release>
          return -1;
    80002908:	b7c5                	j	800028e8 <sigaction+0x206>
          release(&p->lock);
    8000290a:	8526                	mv	a0,s1
    8000290c:	ffffe097          	auipc	ra,0xffffe
    80002910:	36a080e7          	jalr	874(ra) # 80000c76 <release>
          return -1;
    80002914:	59fd                	li	s3,-1
    80002916:	bfc9                	j	800028e8 <sigaction+0x206>
          release(&p->lock);
    80002918:	8526                	mv	a0,s1
    8000291a:	ffffe097          	auipc	ra,0xffffe
    8000291e:	35c080e7          	jalr	860(ra) # 80000c76 <release>
          return -1;
    80002922:	59fd                	li	s3,-1
    80002924:	b7d1                	j	800028e8 <sigaction+0x206>
          p->signal_handlers[signum]=(void*)khandler;
    80002926:	16fab823          	sd	a5,368(s5)
          p->signal_handlers_mask[signum]=kmask;
    8000292a:	09c90793          	addi	a5,s2,156
    8000292e:	078a                	slli	a5,a5,0x2
    80002930:	97a6                	add	a5,a5,s1
    80002932:	fb442703          	lw	a4,-76(s0)
    80002936:	c398                	sw	a4,0(a5)
          release(&p->lock);
    80002938:	8526                	mv	a0,s1
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	33c080e7          	jalr	828(ra) # 80000c76 <release>
          return 0;
    80002942:	4981                	li	s3,0
    80002944:	b755                	j	800028e8 <sigaction+0x206>

0000000080002946 <userhandler>:
//task 1.4



void
userhandler(int i){ // process and curent i to check
    80002946:	7139                	addi	sp,sp,-64
    80002948:	fc06                	sd	ra,56(sp)
    8000294a:	f822                	sd	s0,48(sp)
    8000294c:	f426                	sd	s1,40(sp)
    8000294e:	f04a                	sd	s2,32(sp)
    80002950:	ec4e                	sd	s3,24(sp)
    80002952:	e852                	sd	s4,16(sp)
    80002954:	0080                	addi	s0,sp,64
    80002956:	892a                	mv	s2,a0
  
  struct proc *p=myproc();
    80002958:	fffff097          	auipc	ra,0xfffff
    8000295c:	05c080e7          	jalr	92(ra) # 800019b4 <myproc>
    80002960:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002962:	ffffe097          	auipc	ra,0xffffe
    80002966:	260080e7          	jalr	608(ra) # 80000bc2 <acquire>

  void* local_handler=0;// maybe delete
    8000296a:	fc043423          	sd	zero,-56(s0)
  copyin(p->pagetable,(char*)&local_handler,(uint64)p->signal_handlers[i],sizeof(void*));
    8000296e:	02e90793          	addi	a5,s2,46
    80002972:	078e                	slli	a5,a5,0x3
    80002974:	97a6                	add	a5,a5,s1
    80002976:	46a1                	li	a3,8
    80002978:	6390                	ld	a2,0(a5)
    8000297a:	fc840593          	addi	a1,s0,-56
    8000297e:	68a8                	ld	a0,80(s1)
    80002980:	fffff097          	auipc	ra,0xfffff
    80002984:	d4a080e7          	jalr	-694(ra) # 800016ca <copyin>
  printf("local is: %d\n",local_handler);
    80002988:	fc843583          	ld	a1,-56(s0)
    8000298c:	00006517          	auipc	a0,0x6
    80002990:	92450513          	addi	a0,a0,-1756 # 800082b0 <digits+0x270>
    80002994:	ffffe097          	auipc	ra,0xffffe
    80002998:	be0080e7          	jalr	-1056(ra) # 80000574 <printf>

  //step 2 -backup proc sigmask
  p->signal_mask_backup=p->signal_mask;
    8000299c:	16c4a783          	lw	a5,364(s1)
    800029a0:	2ef4ae23          	sw	a5,764(s1)
  p->signal_mask=p->signal_handlers_mask[i];
    800029a4:	09c90793          	addi	a5,s2,156
    800029a8:	078a                	slli	a5,a5,0x2
    800029aa:	97a6                	add	a5,a5,s1
    800029ac:	439c                	lw	a5,0(a5)
    800029ae:	16f4a623          	sw	a5,364(s1)
  
  //step 3 - turn on flag
  p->signal_handling_flag=1;
    800029b2:	4785                	li	a5,1
    800029b4:	30f4a023          	sw	a5,768(s1)

  //step 4- reduce sp and buackup
  p->trapframe->sp -=sizeof(struct trapframe);
    800029b8:	6cb8                	ld	a4,88(s1)
    800029ba:	7b1c                	ld	a5,48(a4)
    800029bc:	ee078793          	addi	a5,a5,-288
    800029c0:	fb1c                	sd	a5,48(a4)
  //memmove((void*)& p->trapframe->sp,p->trapframe,sizeof(struct trapframe));
  
   
   // step 5 
  copyout(p->pagetable,(uint64)p->trapframe,(char*)(&p->user_trap_frame_backup->sp),sizeof(struct trapframe));
    800029c2:	2f04b603          	ld	a2,752(s1)
    800029c6:	12000693          	li	a3,288
    800029ca:	03060613          	addi	a2,a2,48 # 1030 <_entry-0x7fffefd0>
    800029ce:	6cac                	ld	a1,88(s1)
    800029d0:	68a8                	ld	a0,80(s1)
    800029d2:	fffff097          	auipc	ra,0xfffff
    800029d6:	c6c080e7          	jalr	-916(ra) # 8000163e <copyout>
      

  
  //step 6
  p->trapframe->epc=(uint64)local_handler;
    800029da:	6cbc                	ld	a5,88(s1)
    800029dc:	fc843703          	ld	a4,-56(s0)
    800029e0:	ef98                	sd	a4,24(a5)
  
  // step 7
  int sigret_size= endFunc-startCalcSize; // cacl func size
    800029e2:	00000a17          	auipc	s4,0x0
    800029e6:	278a0a13          	addi	s4,s4,632 # 80002c5a <startCalcSize>
    800029ea:	00000997          	auipc	s3,0x0
    800029ee:	27498993          	addi	s3,s3,628 # 80002c5e <trapinit>
    800029f2:	414989bb          	subw	s3,s3,s4
  

  p->trapframe->sp-=sigret_size;
    800029f6:	6cb8                	ld	a4,88(s1)
    800029f8:	7b1c                	ld	a5,48(a4)
    800029fa:	413787b3          	sub	a5,a5,s3
    800029fe:	fb1c                	sd	a5,48(a4)
  printf("here&&&   sigret size is : %d\n",sigret_size);
    80002a00:	85ce                	mv	a1,s3
    80002a02:	00006517          	auipc	a0,0x6
    80002a06:	8be50513          	addi	a0,a0,-1858 # 800082c0 <digits+0x280>
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	b6a080e7          	jalr	-1174(ra) # 80000574 <printf>
  memmove((void*) p->trapframe->sp,sigret,sigret_size);
    80002a12:	6cbc                	ld	a5,88(s1)
    80002a14:	864e                	mv	a2,s3
    80002a16:	fffff597          	auipc	a1,0xfffff
    80002a1a:	01c58593          	addi	a1,a1,28 # 80001a32 <sigret>
    80002a1e:	7b88                	ld	a0,48(a5)
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	2fa080e7          	jalr	762(ra) # 80000d1a <memmove>
  
  //step 8
  copyout(p->pagetable,(uint64)startCalcSize,(char*)&p->trapframe->sp,sigret_size);
    80002a28:	6cb0                	ld	a2,88(s1)
    80002a2a:	86ce                	mv	a3,s3
    80002a2c:	03060613          	addi	a2,a2,48
    80002a30:	85d2                	mv	a1,s4
    80002a32:	68a8                	ld	a0,80(s1)
    80002a34:	fffff097          	auipc	ra,0xfffff
    80002a38:	c0a080e7          	jalr	-1014(ra) # 8000163e <copyout>
  
  //step 9
  p->trapframe->a0=i; // put signum in a0
    80002a3c:	6cbc                	ld	a5,88(s1)
    80002a3e:	0727b823          	sd	s2,112(a5)
  p->trapframe->ra=p->trapframe->sp;
    80002a42:	6cbc                	ld	a5,88(s1)
    80002a44:	7b98                	ld	a4,48(a5)
    80002a46:	f798                	sd	a4,40(a5)

  p->pendding_signals &= ~((uint)1<<i); // turn off the signal
    80002a48:	4785                	li	a5,1
    80002a4a:	012797bb          	sllw	a5,a5,s2
    80002a4e:	fff7c793          	not	a5,a5
    80002a52:	1684a703          	lw	a4,360(s1)
    80002a56:	8ff9                	and	a5,a5,a4
    80002a58:	16f4a423          	sw	a5,360(s1)

  release(&p->lock);
    80002a5c:	8526                	mv	a0,s1
    80002a5e:	ffffe097          	auipc	ra,0xffffe
    80002a62:	218080e7          	jalr	536(ra) # 80000c76 <release>
  copyout(p->pagetable,(uint64)startCalcSize,(char*)p->trapframe->sp,sigret_size);

  p->trapframe->a0=i; // put signum in a0
  p->trapframe->ra=p->trapframe->sp; */

}
    80002a66:	70e2                	ld	ra,56(sp)
    80002a68:	7442                	ld	s0,48(sp)
    80002a6a:	74a2                	ld	s1,40(sp)
    80002a6c:	7902                	ld	s2,32(sp)
    80002a6e:	69e2                	ld	s3,24(sp)
    80002a70:	6a42                	ld	s4,16(sp)
    80002a72:	6121                	addi	sp,sp,64
    80002a74:	8082                	ret

0000000080002a76 <handle_pendding_sinals>:

int
handle_pendding_sinals(){
    80002a76:	711d                	addi	sp,sp,-96
    80002a78:	ec86                	sd	ra,88(sp)
    80002a7a:	e8a2                	sd	s0,80(sp)
    80002a7c:	e4a6                	sd	s1,72(sp)
    80002a7e:	e0ca                	sd	s2,64(sp)
    80002a80:	fc4e                	sd	s3,56(sp)
    80002a82:	f852                	sd	s4,48(sp)
    80002a84:	f456                	sd	s5,40(sp)
    80002a86:	f05a                	sd	s6,32(sp)
    80002a88:	ec5e                	sd	s7,24(sp)
    80002a8a:	e862                	sd	s8,16(sp)
    80002a8c:	e466                	sd	s9,8(sp)
    80002a8e:	1080                	addi	s0,sp,96
 struct proc *p=myproc();
    80002a90:	fffff097          	auipc	ra,0xfffff
    80002a94:	f24080e7          	jalr	-220(ra) # 800019b4 <myproc>
    80002a98:	892a                	mv	s2,a0
  p->user_trap_frame_backup=p->trapframe;
    80002a9a:	6d3c                	ld	a5,88(a0)
    80002a9c:	2ef53823          	sd	a5,752(a0)

  while (p->frozen==1){// while the process is still frozen
    80002aa0:	2f852703          	lw	a4,760(a0)
    80002aa4:	4785                	li	a5,1
    80002aa6:	04f71363          	bne	a4,a5,80002aec <handle_pendding_sinals+0x76>
     if(p->frozen==1 && ((p->pendding_signals & (uint)1<<SIGCONT)==0))// check if proc is frozen and cont bit is off
    80002aaa:	000809b7          	lui	s3,0x80
      yield();
    else if(p->frozen==1 && ((p->pendding_signals & (uint)1<<SIGCONT)!=0)){ // if frozen and cont bit is on handle it
      sigContHandler();
      p->pendding_signals &= ~((uint)1<<SIGCONT);// discard sigcont 
    80002aae:	fff807b7          	lui	a5,0xfff80
    80002ab2:	fff78a13          	addi	s4,a5,-1 # fffffffffff7ffff <end+0xffffffff7ff53fff>
  while (p->frozen==1){// while the process is still frozen
    80002ab6:	4485                	li	s1,1
    80002ab8:	a809                	j	80002aca <handle_pendding_sinals+0x54>
      yield();
    80002aba:	fffff097          	auipc	ra,0xfffff
    80002abe:	636080e7          	jalr	1590(ra) # 800020f0 <yield>
  while (p->frozen==1){// while the process is still frozen
    80002ac2:	2f892783          	lw	a5,760(s2)
    80002ac6:	02979363          	bne	a5,s1,80002aec <handle_pendding_sinals+0x76>
     if(p->frozen==1 && ((p->pendding_signals & (uint)1<<SIGCONT)==0))// check if proc is frozen and cont bit is off
    80002aca:	16892783          	lw	a5,360(s2)
    80002ace:	0137f7b3          	and	a5,a5,s3
    80002ad2:	2781                	sext.w	a5,a5
    80002ad4:	d3fd                	beqz	a5,80002aba <handle_pendding_sinals+0x44>
      sigContHandler();
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	bf0080e7          	jalr	-1040(ra) # 800026c6 <sigContHandler>
      p->pendding_signals &= ~((uint)1<<SIGCONT);// discard sigcont 
    80002ade:	16892783          	lw	a5,360(s2)
    80002ae2:	0147f7b3          	and	a5,a5,s4
    80002ae6:	16f92423          	sw	a5,360(s2)
    80002aea:	bfe1                	j	80002ac2 <handle_pendding_sinals+0x4c>
handle_pendding_sinals(){
    80002aec:	4985                	li	s3,1
    80002aee:	4481                	li	s1,0
    }
  }  
  for(int i=0;i<32;i++){
    uint signal_bit_to_check= 1<<i;
    80002af0:	4a85                	li	s5,1
  for(int i=0;i<32;i++){
    80002af2:	4bfd                	li	s7,31
    void *currentHandler=p->signal_handlers[i];
    if((p->pendding_signals & signal_bit_to_check)!=0 && p->signal_handling_flag==0){
      

      if(i== SIGKILL){
    80002af4:	4c25                	li	s8,9
         sigKillHandler();
         return -1;
      }
       
      else if(i== SIGSTOP){
    80002af6:	4cc5                	li	s9,17
    80002af8:	a895                	j	80002b6c <handle_pendding_sinals+0xf6>
         sigKillHandler();
    80002afa:	00000097          	auipc	ra,0x0
    80002afe:	b84080e7          	jalr	-1148(ra) # 8000267e <sigKillHandler>
         return -1;
    80002b02:	5a7d                	li	s4,-1
    80002b04:	a8c1                	j	80002bd4 <handle_pendding_sinals+0x15e>
        sigStopHandler();
    80002b06:	00000097          	auipc	ra,0x0
    80002b0a:	ba2080e7          	jalr	-1118(ra) # 800026a8 <sigStopHandler>
  for(int i=0;i<32;i++){
    80002b0e:	a8a9                	j	80002b68 <handle_pendding_sinals+0xf2>
      else if((p->signal_mask & signal_bit_to_check) ==0 ){
        //signal is not blocked 

        //check if signal handler is IGN if true discard the signal
        if(currentHandler==(void*) SIG_IGN){
          p->pendding_signals &= ~(signal_bit_to_check);
    80002b10:	fffb4b13          	not	s6,s6
    80002b14:	00db76b3          	and	a3,s6,a3
    80002b18:	16d92423          	sw	a3,360(s2)
          return -1;
    80002b1c:	5a7d                	li	s4,-1
    80002b1e:	a85d                	j	80002bd4 <handle_pendding_sinals+0x15e>
        }
          
        else if(currentHandler== (void*)  SIGSTOP){
          sigStopHandler();
    80002b20:	00000097          	auipc	ra,0x0
    80002b24:	b88080e7          	jalr	-1144(ra) # 800026a8 <sigStopHandler>
          p->pendding_signals &= ~(signal_bit_to_check);
    80002b28:	fffb4793          	not	a5,s6
    80002b2c:	16892703          	lw	a4,360(s2)
    80002b30:	8ff9                	and	a5,a5,a4
    80002b32:	16f92423          	sw	a5,360(s2)
          return -1;
    80002b36:	5a7d                	li	s4,-1
    80002b38:	a871                	j	80002bd4 <handle_pendding_sinals+0x15e>
        }
          
        else if(currentHandler==(void*) SIGCONT){
    
          sigContHandler();
    80002b3a:	00000097          	auipc	ra,0x0
    80002b3e:	b8c080e7          	jalr	-1140(ra) # 800026c6 <sigContHandler>
          p->pendding_signals &= ~(signal_bit_to_check);
    80002b42:	fffb4793          	not	a5,s6
    80002b46:	16892703          	lw	a4,360(s2)
    80002b4a:	8ff9                	and	a5,a5,a4
    80002b4c:	16f92423          	sw	a5,360(s2)
          return -1;
    80002b50:	5a7d                	li	s4,-1
    80002b52:	a049                	j	80002bd4 <handle_pendding_sinals+0x15e>
        }
        else if( currentHandler==(void*) SIGKILL || currentHandler==(void*) SIG_DFL){
          sigKillHandler();
    80002b54:	00000097          	auipc	ra,0x0
    80002b58:	b2a080e7          	jalr	-1238(ra) # 8000267e <sigKillHandler>
          return -1;
    80002b5c:	5a7d                	li	s4,-1
    80002b5e:	a89d                	j	80002bd4 <handle_pendding_sinals+0x15e>
  for(int i=0;i<32;i++){
    80002b60:	0009879b          	sext.w	a5,s3
    80002b64:	06fbc763          	blt	s7,a5,80002bd2 <handle_pendding_sinals+0x15c>
    80002b68:	2485                	addiw	s1,s1,1
    80002b6a:	2985                	addiw	s3,s3,1
    80002b6c:	00048a1b          	sext.w	s4,s1
    uint signal_bit_to_check= 1<<i;
    80002b70:	009a973b          	sllw	a4,s5,s1
    80002b74:	00070b1b          	sext.w	s6,a4
    if((p->pendding_signals & signal_bit_to_check)!=0 && p->signal_handling_flag==0){
    80002b78:	16892683          	lw	a3,360(s2)
    80002b7c:	00e6f7b3          	and	a5,a3,a4
    80002b80:	2781                	sext.w	a5,a5
    80002b82:	dff9                	beqz	a5,80002b60 <handle_pendding_sinals+0xea>
    80002b84:	30092783          	lw	a5,768(s2)
    80002b88:	ffe1                	bnez	a5,80002b60 <handle_pendding_sinals+0xea>
      if(i== SIGKILL){
    80002b8a:	f78a08e3          	beq	s4,s8,80002afa <handle_pendding_sinals+0x84>
      else if(i== SIGSTOP){
    80002b8e:	f79a0ce3          	beq	s4,s9,80002b06 <handle_pendding_sinals+0x90>
      else if((p->signal_mask & signal_bit_to_check) ==0 ){
    80002b92:	16c92783          	lw	a5,364(s2)
    80002b96:	8f7d                	and	a4,a4,a5
    80002b98:	2701                	sext.w	a4,a4
    80002b9a:	f379                	bnez	a4,80002b60 <handle_pendding_sinals+0xea>
    void *currentHandler=p->signal_handlers[i];
    80002b9c:	02ea0793          	addi	a5,s4,46
    80002ba0:	078e                	slli	a5,a5,0x3
    80002ba2:	97ca                	add	a5,a5,s2
    80002ba4:	639c                	ld	a5,0(a5)
        if(currentHandler==(void*) SIG_IGN){
    80002ba6:	4705                	li	a4,1
    80002ba8:	f6e784e3          	beq	a5,a4,80002b10 <handle_pendding_sinals+0x9a>
        else if(currentHandler== (void*)  SIGSTOP){
    80002bac:	4745                	li	a4,17
    80002bae:	f6e789e3          	beq	a5,a4,80002b20 <handle_pendding_sinals+0xaa>
        else if(currentHandler==(void*) SIGCONT){
    80002bb2:	474d                	li	a4,19
    80002bb4:	f8e783e3          	beq	a5,a4,80002b3a <handle_pendding_sinals+0xc4>
        else if( currentHandler==(void*) SIGKILL || currentHandler==(void*) SIG_DFL){
    80002bb8:	4725                	li	a4,9
    80002bba:	f8e78de3          	beq	a5,a4,80002b54 <handle_pendding_sinals+0xde>
    80002bbe:	dbd9                	beqz	a5,80002b54 <handle_pendding_sinals+0xde>
        }
          
        else{// its a user space handler 
          printf("herer!\n\n\n");
    80002bc0:	00005517          	auipc	a0,0x5
    80002bc4:	72050513          	addi	a0,a0,1824 # 800082e0 <digits+0x2a0>
    80002bc8:	ffffe097          	auipc	ra,0xffffe
    80002bcc:	9ac080e7          	jalr	-1620(ra) # 80000574 <printf>
          return i;
    80002bd0:	a011                	j	80002bd4 <handle_pendding_sinals+0x15e>



    }
  }
  return -1;
    80002bd2:	5a7d                	li	s4,-1
  
    80002bd4:	8552                	mv	a0,s4
    80002bd6:	60e6                	ld	ra,88(sp)
    80002bd8:	6446                	ld	s0,80(sp)
    80002bda:	64a6                	ld	s1,72(sp)
    80002bdc:	6906                	ld	s2,64(sp)
    80002bde:	79e2                	ld	s3,56(sp)
    80002be0:	7a42                	ld	s4,48(sp)
    80002be2:	7aa2                	ld	s5,40(sp)
    80002be4:	7b02                	ld	s6,32(sp)
    80002be6:	6be2                	ld	s7,24(sp)
    80002be8:	6c42                	ld	s8,16(sp)
    80002bea:	6ca2                	ld	s9,8(sp)
    80002bec:	6125                	addi	sp,sp,96
    80002bee:	8082                	ret

0000000080002bf0 <swtch>:
    80002bf0:	00153023          	sd	ra,0(a0)
    80002bf4:	00253423          	sd	sp,8(a0)
    80002bf8:	e900                	sd	s0,16(a0)
    80002bfa:	ed04                	sd	s1,24(a0)
    80002bfc:	03253023          	sd	s2,32(a0)
    80002c00:	03353423          	sd	s3,40(a0)
    80002c04:	03453823          	sd	s4,48(a0)
    80002c08:	03553c23          	sd	s5,56(a0)
    80002c0c:	05653023          	sd	s6,64(a0)
    80002c10:	05753423          	sd	s7,72(a0)
    80002c14:	05853823          	sd	s8,80(a0)
    80002c18:	05953c23          	sd	s9,88(a0)
    80002c1c:	07a53023          	sd	s10,96(a0)
    80002c20:	07b53423          	sd	s11,104(a0)
    80002c24:	0005b083          	ld	ra,0(a1)
    80002c28:	0085b103          	ld	sp,8(a1)
    80002c2c:	6980                	ld	s0,16(a1)
    80002c2e:	6d84                	ld	s1,24(a1)
    80002c30:	0205b903          	ld	s2,32(a1)
    80002c34:	0285b983          	ld	s3,40(a1)
    80002c38:	0305ba03          	ld	s4,48(a1)
    80002c3c:	0385ba83          	ld	s5,56(a1)
    80002c40:	0405bb03          	ld	s6,64(a1)
    80002c44:	0485bb83          	ld	s7,72(a1)
    80002c48:	0505bc03          	ld	s8,80(a1)
    80002c4c:	0585bc83          	ld	s9,88(a1)
    80002c50:	0605bd03          	ld	s10,96(a1)
    80002c54:	0685bd83          	ld	s11,104(a1)
    80002c58:	8082                	ret

0000000080002c5a <startCalcSize>:
    80002c5a:	dd9fe0ef          	jal	ra,80001a32 <sigret>

0000000080002c5e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002c5e:	1141                	addi	sp,sp,-16
    80002c60:	e406                	sd	ra,8(sp)
    80002c62:	e022                	sd	s0,0(sp)
    80002c64:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c66:	00005597          	auipc	a1,0x5
    80002c6a:	6e258593          	addi	a1,a1,1762 # 80008348 <states.0+0x30>
    80002c6e:	0001b517          	auipc	a0,0x1b
    80002c72:	c6250513          	addi	a0,a0,-926 # 8001d8d0 <tickslock>
    80002c76:	ffffe097          	auipc	ra,0xffffe
    80002c7a:	ebc080e7          	jalr	-324(ra) # 80000b32 <initlock>
}
    80002c7e:	60a2                	ld	ra,8(sp)
    80002c80:	6402                	ld	s0,0(sp)
    80002c82:	0141                	addi	sp,sp,16
    80002c84:	8082                	ret

0000000080002c86 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002c86:	1141                	addi	sp,sp,-16
    80002c88:	e422                	sd	s0,8(sp)
    80002c8a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c8c:	00003797          	auipc	a5,0x3
    80002c90:	5a478793          	addi	a5,a5,1444 # 80006230 <kernelvec>
    80002c94:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002c98:	6422                	ld	s0,8(sp)
    80002c9a:	0141                	addi	sp,sp,16
    80002c9c:	8082                	ret

0000000080002c9e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002c9e:	1101                	addi	sp,sp,-32
    80002ca0:	ec06                	sd	ra,24(sp)
    80002ca2:	e822                	sd	s0,16(sp)
    80002ca4:	e426                	sd	s1,8(sp)
    80002ca6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	d0c080e7          	jalr	-756(ra) # 800019b4 <myproc>
    80002cb0:	84aa                	mv	s1,a0
  int i=handle_pendding_sinals();
    80002cb2:	00000097          	auipc	ra,0x0
    80002cb6:	dc4080e7          	jalr	-572(ra) # 80002a76 <handle_pendding_sinals>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002cbe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cc0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002cc4:	04000737          	lui	a4,0x4000
    80002cc8:	00004797          	auipc	a5,0x4
    80002ccc:	33878793          	addi	a5,a5,824 # 80007000 <_trampoline>
    80002cd0:	00004697          	auipc	a3,0x4
    80002cd4:	33068693          	addi	a3,a3,816 # 80007000 <_trampoline>
    80002cd8:	8f95                	sub	a5,a5,a3
    80002cda:	177d                	addi	a4,a4,-1
    80002cdc:	0732                	slli	a4,a4,0xc
    80002cde:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ce0:	10579073          	csrw	stvec,a5

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ce4:	6cbc                	ld	a5,88(s1)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ce6:	18002773          	csrr	a4,satp
    80002cea:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002cec:	6cb8                	ld	a4,88(s1)
    80002cee:	60bc                	ld	a5,64(s1)
    80002cf0:	6685                	lui	a3,0x1
    80002cf2:	97b6                	add	a5,a5,a3
    80002cf4:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002cf6:	6cbc                	ld	a5,88(s1)
    80002cf8:	00000717          	auipc	a4,0x0
    80002cfc:	15a70713          	addi	a4,a4,346 # 80002e52 <usertrap>
    80002d00:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002d02:	6cbc                	ld	a5,88(s1)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d04:	8712                	mv	a4,tp
    80002d06:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d08:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d0c:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d10:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d14:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002d18:	6cbc                	ld	a5,88(s1)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d1a:	6f9c                	ld	a5,24(a5)
    80002d1c:	14179073          	csrw	sepc,a5
  if(i!=-1)
    80002d20:	57fd                	li	a5,-1
    80002d22:	02f51f63          	bne	a0,a5,80002d60 <usertrapret+0xc2>
    userhandler(i);

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002d26:	68ac                	ld	a1,80(s1)
    80002d28:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002d2a:	04000737          	lui	a4,0x4000
    80002d2e:	00004797          	auipc	a5,0x4
    80002d32:	36278793          	addi	a5,a5,866 # 80007090 <userret>
    80002d36:	00004697          	auipc	a3,0x4
    80002d3a:	2ca68693          	addi	a3,a3,714 # 80007000 <_trampoline>
    80002d3e:	8f95                	sub	a5,a5,a3
    80002d40:	177d                	addi	a4,a4,-1
    80002d42:	0732                	slli	a4,a4,0xc
    80002d44:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002d46:	577d                	li	a4,-1
    80002d48:	177e                	slli	a4,a4,0x3f
    80002d4a:	8dd9                	or	a1,a1,a4
    80002d4c:	02000537          	lui	a0,0x2000
    80002d50:	157d                	addi	a0,a0,-1
    80002d52:	0536                	slli	a0,a0,0xd
    80002d54:	9782                	jalr	a5
}
    80002d56:	60e2                	ld	ra,24(sp)
    80002d58:	6442                	ld	s0,16(sp)
    80002d5a:	64a2                	ld	s1,8(sp)
    80002d5c:	6105                	addi	sp,sp,32
    80002d5e:	8082                	ret
    userhandler(i);
    80002d60:	00000097          	auipc	ra,0x0
    80002d64:	be6080e7          	jalr	-1050(ra) # 80002946 <userhandler>
    80002d68:	bf7d                	j	80002d26 <usertrapret+0x88>

0000000080002d6a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	e426                	sd	s1,8(sp)
    80002d72:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002d74:	0001b497          	auipc	s1,0x1b
    80002d78:	b5c48493          	addi	s1,s1,-1188 # 8001d8d0 <tickslock>
    80002d7c:	8526                	mv	a0,s1
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	e44080e7          	jalr	-444(ra) # 80000bc2 <acquire>
  ticks++;
    80002d86:	00006517          	auipc	a0,0x6
    80002d8a:	2aa50513          	addi	a0,a0,682 # 80009030 <ticks>
    80002d8e:	411c                	lw	a5,0(a0)
    80002d90:	2785                	addiw	a5,a5,1
    80002d92:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	524080e7          	jalr	1316(ra) # 800022b8 <wakeup>
  release(&tickslock);
    80002d9c:	8526                	mv	a0,s1
    80002d9e:	ffffe097          	auipc	ra,0xffffe
    80002da2:	ed8080e7          	jalr	-296(ra) # 80000c76 <release>
}
    80002da6:	60e2                	ld	ra,24(sp)
    80002da8:	6442                	ld	s0,16(sp)
    80002daa:	64a2                	ld	s1,8(sp)
    80002dac:	6105                	addi	sp,sp,32
    80002dae:	8082                	ret

0000000080002db0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002db0:	1101                	addi	sp,sp,-32
    80002db2:	ec06                	sd	ra,24(sp)
    80002db4:	e822                	sd	s0,16(sp)
    80002db6:	e426                	sd	s1,8(sp)
    80002db8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dba:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002dbe:	00074d63          	bltz	a4,80002dd8 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002dc2:	57fd                	li	a5,-1
    80002dc4:	17fe                	slli	a5,a5,0x3f
    80002dc6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002dc8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002dca:	06f70363          	beq	a4,a5,80002e30 <devintr+0x80>
  }
}
    80002dce:	60e2                	ld	ra,24(sp)
    80002dd0:	6442                	ld	s0,16(sp)
    80002dd2:	64a2                	ld	s1,8(sp)
    80002dd4:	6105                	addi	sp,sp,32
    80002dd6:	8082                	ret
     (scause & 0xff) == 9){
    80002dd8:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002ddc:	46a5                	li	a3,9
    80002dde:	fed792e3          	bne	a5,a3,80002dc2 <devintr+0x12>
    int irq = plic_claim();
    80002de2:	00003097          	auipc	ra,0x3
    80002de6:	556080e7          	jalr	1366(ra) # 80006338 <plic_claim>
    80002dea:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002dec:	47a9                	li	a5,10
    80002dee:	02f50763          	beq	a0,a5,80002e1c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002df2:	4785                	li	a5,1
    80002df4:	02f50963          	beq	a0,a5,80002e26 <devintr+0x76>
    return 1;
    80002df8:	4505                	li	a0,1
    } else if(irq){
    80002dfa:	d8f1                	beqz	s1,80002dce <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002dfc:	85a6                	mv	a1,s1
    80002dfe:	00005517          	auipc	a0,0x5
    80002e02:	55250513          	addi	a0,a0,1362 # 80008350 <states.0+0x38>
    80002e06:	ffffd097          	auipc	ra,0xffffd
    80002e0a:	76e080e7          	jalr	1902(ra) # 80000574 <printf>
      plic_complete(irq);
    80002e0e:	8526                	mv	a0,s1
    80002e10:	00003097          	auipc	ra,0x3
    80002e14:	54c080e7          	jalr	1356(ra) # 8000635c <plic_complete>
    return 1;
    80002e18:	4505                	li	a0,1
    80002e1a:	bf55                	j	80002dce <devintr+0x1e>
      uartintr();
    80002e1c:	ffffe097          	auipc	ra,0xffffe
    80002e20:	b6a080e7          	jalr	-1174(ra) # 80000986 <uartintr>
    80002e24:	b7ed                	j	80002e0e <devintr+0x5e>
      virtio_disk_intr();
    80002e26:	00004097          	auipc	ra,0x4
    80002e2a:	9c8080e7          	jalr	-1592(ra) # 800067ee <virtio_disk_intr>
    80002e2e:	b7c5                	j	80002e0e <devintr+0x5e>
    if(cpuid() == 0){
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	b58080e7          	jalr	-1192(ra) # 80001988 <cpuid>
    80002e38:	c901                	beqz	a0,80002e48 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002e3a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002e3e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002e40:	14479073          	csrw	sip,a5
    return 2;
    80002e44:	4509                	li	a0,2
    80002e46:	b761                	j	80002dce <devintr+0x1e>
      clockintr();
    80002e48:	00000097          	auipc	ra,0x0
    80002e4c:	f22080e7          	jalr	-222(ra) # 80002d6a <clockintr>
    80002e50:	b7ed                	j	80002e3a <devintr+0x8a>

0000000080002e52 <usertrap>:
{
    80002e52:	1101                	addi	sp,sp,-32
    80002e54:	ec06                	sd	ra,24(sp)
    80002e56:	e822                	sd	s0,16(sp)
    80002e58:	e426                	sd	s1,8(sp)
    80002e5a:	e04a                	sd	s2,0(sp)
    80002e5c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e5e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002e62:	1007f793          	andi	a5,a5,256
    80002e66:	e3ad                	bnez	a5,80002ec8 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e68:	00003797          	auipc	a5,0x3
    80002e6c:	3c878793          	addi	a5,a5,968 # 80006230 <kernelvec>
    80002e70:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e74:	fffff097          	auipc	ra,0xfffff
    80002e78:	b40080e7          	jalr	-1216(ra) # 800019b4 <myproc>
    80002e7c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e7e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e80:	14102773          	csrr	a4,sepc
    80002e84:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e86:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002e8a:	47a1                	li	a5,8
    80002e8c:	04f71c63          	bne	a4,a5,80002ee4 <usertrap+0x92>
    if(p->killed)
    80002e90:	551c                	lw	a5,40(a0)
    80002e92:	e3b9                	bnez	a5,80002ed8 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002e94:	6cb8                	ld	a4,88(s1)
    80002e96:	6f1c                	ld	a5,24(a4)
    80002e98:	0791                	addi	a5,a5,4
    80002e9a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ea0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ea4:	10079073          	csrw	sstatus,a5
    syscall();
    80002ea8:	00000097          	auipc	ra,0x0
    80002eac:	2e0080e7          	jalr	736(ra) # 80003188 <syscall>
  if(p->killed)
    80002eb0:	549c                	lw	a5,40(s1)
    80002eb2:	ebc1                	bnez	a5,80002f42 <usertrap+0xf0>
  usertrapret();
    80002eb4:	00000097          	auipc	ra,0x0
    80002eb8:	dea080e7          	jalr	-534(ra) # 80002c9e <usertrapret>
}
    80002ebc:	60e2                	ld	ra,24(sp)
    80002ebe:	6442                	ld	s0,16(sp)
    80002ec0:	64a2                	ld	s1,8(sp)
    80002ec2:	6902                	ld	s2,0(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret
    panic("usertrap: not from user mode");
    80002ec8:	00005517          	auipc	a0,0x5
    80002ecc:	4a850513          	addi	a0,a0,1192 # 80008370 <states.0+0x58>
    80002ed0:	ffffd097          	auipc	ra,0xffffd
    80002ed4:	65a080e7          	jalr	1626(ra) # 8000052a <panic>
      exit(-1);
    80002ed8:	557d                	li	a0,-1
    80002eda:	fffff097          	auipc	ra,0xfffff
    80002ede:	4ae080e7          	jalr	1198(ra) # 80002388 <exit>
    80002ee2:	bf4d                	j	80002e94 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002ee4:	00000097          	auipc	ra,0x0
    80002ee8:	ecc080e7          	jalr	-308(ra) # 80002db0 <devintr>
    80002eec:	892a                	mv	s2,a0
    80002eee:	c501                	beqz	a0,80002ef6 <usertrap+0xa4>
  if(p->killed)
    80002ef0:	549c                	lw	a5,40(s1)
    80002ef2:	c3a1                	beqz	a5,80002f32 <usertrap+0xe0>
    80002ef4:	a815                	j	80002f28 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ef6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002efa:	5890                	lw	a2,48(s1)
    80002efc:	00005517          	auipc	a0,0x5
    80002f00:	49450513          	addi	a0,a0,1172 # 80008390 <states.0+0x78>
    80002f04:	ffffd097          	auipc	ra,0xffffd
    80002f08:	670080e7          	jalr	1648(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f0c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f10:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f14:	00005517          	auipc	a0,0x5
    80002f18:	4ac50513          	addi	a0,a0,1196 # 800083c0 <states.0+0xa8>
    80002f1c:	ffffd097          	auipc	ra,0xffffd
    80002f20:	658080e7          	jalr	1624(ra) # 80000574 <printf>
    p->killed = 1;
    80002f24:	4785                	li	a5,1
    80002f26:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002f28:	557d                	li	a0,-1
    80002f2a:	fffff097          	auipc	ra,0xfffff
    80002f2e:	45e080e7          	jalr	1118(ra) # 80002388 <exit>
  if(which_dev == 2)
    80002f32:	4789                	li	a5,2
    80002f34:	f8f910e3          	bne	s2,a5,80002eb4 <usertrap+0x62>
    yield();
    80002f38:	fffff097          	auipc	ra,0xfffff
    80002f3c:	1b8080e7          	jalr	440(ra) # 800020f0 <yield>
    80002f40:	bf95                	j	80002eb4 <usertrap+0x62>
  int which_dev = 0;
    80002f42:	4901                	li	s2,0
    80002f44:	b7d5                	j	80002f28 <usertrap+0xd6>

0000000080002f46 <kerneltrap>:
{
    80002f46:	7179                	addi	sp,sp,-48
    80002f48:	f406                	sd	ra,40(sp)
    80002f4a:	f022                	sd	s0,32(sp)
    80002f4c:	ec26                	sd	s1,24(sp)
    80002f4e:	e84a                	sd	s2,16(sp)
    80002f50:	e44e                	sd	s3,8(sp)
    80002f52:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f54:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f58:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f5c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002f60:	1004f793          	andi	a5,s1,256
    80002f64:	cb85                	beqz	a5,80002f94 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f66:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002f6a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002f6c:	ef85                	bnez	a5,80002fa4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002f6e:	00000097          	auipc	ra,0x0
    80002f72:	e42080e7          	jalr	-446(ra) # 80002db0 <devintr>
    80002f76:	cd1d                	beqz	a0,80002fb4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING )
    80002f78:	4789                	li	a5,2
    80002f7a:	06f50a63          	beq	a0,a5,80002fee <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f7e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f82:	10049073          	csrw	sstatus,s1
}
    80002f86:	70a2                	ld	ra,40(sp)
    80002f88:	7402                	ld	s0,32(sp)
    80002f8a:	64e2                	ld	s1,24(sp)
    80002f8c:	6942                	ld	s2,16(sp)
    80002f8e:	69a2                	ld	s3,8(sp)
    80002f90:	6145                	addi	sp,sp,48
    80002f92:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002f94:	00005517          	auipc	a0,0x5
    80002f98:	44c50513          	addi	a0,a0,1100 # 800083e0 <states.0+0xc8>
    80002f9c:	ffffd097          	auipc	ra,0xffffd
    80002fa0:	58e080e7          	jalr	1422(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002fa4:	00005517          	auipc	a0,0x5
    80002fa8:	46450513          	addi	a0,a0,1124 # 80008408 <states.0+0xf0>
    80002fac:	ffffd097          	auipc	ra,0xffffd
    80002fb0:	57e080e7          	jalr	1406(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002fb4:	85ce                	mv	a1,s3
    80002fb6:	00005517          	auipc	a0,0x5
    80002fba:	47250513          	addi	a0,a0,1138 # 80008428 <states.0+0x110>
    80002fbe:	ffffd097          	auipc	ra,0xffffd
    80002fc2:	5b6080e7          	jalr	1462(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fc6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fca:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fce:	00005517          	auipc	a0,0x5
    80002fd2:	46a50513          	addi	a0,a0,1130 # 80008438 <states.0+0x120>
    80002fd6:	ffffd097          	auipc	ra,0xffffd
    80002fda:	59e080e7          	jalr	1438(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002fde:	00005517          	auipc	a0,0x5
    80002fe2:	47250513          	addi	a0,a0,1138 # 80008450 <states.0+0x138>
    80002fe6:	ffffd097          	auipc	ra,0xffffd
    80002fea:	544080e7          	jalr	1348(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING )
    80002fee:	fffff097          	auipc	ra,0xfffff
    80002ff2:	9c6080e7          	jalr	-1594(ra) # 800019b4 <myproc>
    80002ff6:	d541                	beqz	a0,80002f7e <kerneltrap+0x38>
    80002ff8:	fffff097          	auipc	ra,0xfffff
    80002ffc:	9bc080e7          	jalr	-1604(ra) # 800019b4 <myproc>
    80003000:	4d18                	lw	a4,24(a0)
    80003002:	4791                	li	a5,4
    80003004:	f6f71de3          	bne	a4,a5,80002f7e <kerneltrap+0x38>
    yield();
    80003008:	fffff097          	auipc	ra,0xfffff
    8000300c:	0e8080e7          	jalr	232(ra) # 800020f0 <yield>
    80003010:	b7bd                	j	80002f7e <kerneltrap+0x38>

0000000080003012 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003012:	1101                	addi	sp,sp,-32
    80003014:	ec06                	sd	ra,24(sp)
    80003016:	e822                	sd	s0,16(sp)
    80003018:	e426                	sd	s1,8(sp)
    8000301a:	1000                	addi	s0,sp,32
    8000301c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000301e:	fffff097          	auipc	ra,0xfffff
    80003022:	996080e7          	jalr	-1642(ra) # 800019b4 <myproc>
  switch (n) {
    80003026:	4795                	li	a5,5
    80003028:	0497e163          	bltu	a5,s1,8000306a <argraw+0x58>
    8000302c:	048a                	slli	s1,s1,0x2
    8000302e:	00005717          	auipc	a4,0x5
    80003032:	45a70713          	addi	a4,a4,1114 # 80008488 <states.0+0x170>
    80003036:	94ba                	add	s1,s1,a4
    80003038:	409c                	lw	a5,0(s1)
    8000303a:	97ba                	add	a5,a5,a4
    8000303c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000303e:	6d3c                	ld	a5,88(a0)
    80003040:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003042:	60e2                	ld	ra,24(sp)
    80003044:	6442                	ld	s0,16(sp)
    80003046:	64a2                	ld	s1,8(sp)
    80003048:	6105                	addi	sp,sp,32
    8000304a:	8082                	ret
    return p->trapframe->a1;
    8000304c:	6d3c                	ld	a5,88(a0)
    8000304e:	7fa8                	ld	a0,120(a5)
    80003050:	bfcd                	j	80003042 <argraw+0x30>
    return p->trapframe->a2;
    80003052:	6d3c                	ld	a5,88(a0)
    80003054:	63c8                	ld	a0,128(a5)
    80003056:	b7f5                	j	80003042 <argraw+0x30>
    return p->trapframe->a3;
    80003058:	6d3c                	ld	a5,88(a0)
    8000305a:	67c8                	ld	a0,136(a5)
    8000305c:	b7dd                	j	80003042 <argraw+0x30>
    return p->trapframe->a4;
    8000305e:	6d3c                	ld	a5,88(a0)
    80003060:	6bc8                	ld	a0,144(a5)
    80003062:	b7c5                	j	80003042 <argraw+0x30>
    return p->trapframe->a5;
    80003064:	6d3c                	ld	a5,88(a0)
    80003066:	6fc8                	ld	a0,152(a5)
    80003068:	bfe9                	j	80003042 <argraw+0x30>
  panic("argraw");
    8000306a:	00005517          	auipc	a0,0x5
    8000306e:	3f650513          	addi	a0,a0,1014 # 80008460 <states.0+0x148>
    80003072:	ffffd097          	auipc	ra,0xffffd
    80003076:	4b8080e7          	jalr	1208(ra) # 8000052a <panic>

000000008000307a <fetchaddr>:
{
    8000307a:	1101                	addi	sp,sp,-32
    8000307c:	ec06                	sd	ra,24(sp)
    8000307e:	e822                	sd	s0,16(sp)
    80003080:	e426                	sd	s1,8(sp)
    80003082:	e04a                	sd	s2,0(sp)
    80003084:	1000                	addi	s0,sp,32
    80003086:	84aa                	mv	s1,a0
    80003088:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000308a:	fffff097          	auipc	ra,0xfffff
    8000308e:	92a080e7          	jalr	-1750(ra) # 800019b4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003092:	653c                	ld	a5,72(a0)
    80003094:	02f4f863          	bgeu	s1,a5,800030c4 <fetchaddr+0x4a>
    80003098:	00848713          	addi	a4,s1,8
    8000309c:	02e7e663          	bltu	a5,a4,800030c8 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800030a0:	46a1                	li	a3,8
    800030a2:	8626                	mv	a2,s1
    800030a4:	85ca                	mv	a1,s2
    800030a6:	6928                	ld	a0,80(a0)
    800030a8:	ffffe097          	auipc	ra,0xffffe
    800030ac:	622080e7          	jalr	1570(ra) # 800016ca <copyin>
    800030b0:	00a03533          	snez	a0,a0
    800030b4:	40a00533          	neg	a0,a0
}
    800030b8:	60e2                	ld	ra,24(sp)
    800030ba:	6442                	ld	s0,16(sp)
    800030bc:	64a2                	ld	s1,8(sp)
    800030be:	6902                	ld	s2,0(sp)
    800030c0:	6105                	addi	sp,sp,32
    800030c2:	8082                	ret
    return -1;
    800030c4:	557d                	li	a0,-1
    800030c6:	bfcd                	j	800030b8 <fetchaddr+0x3e>
    800030c8:	557d                	li	a0,-1
    800030ca:	b7fd                	j	800030b8 <fetchaddr+0x3e>

00000000800030cc <fetchstr>:
{
    800030cc:	7179                	addi	sp,sp,-48
    800030ce:	f406                	sd	ra,40(sp)
    800030d0:	f022                	sd	s0,32(sp)
    800030d2:	ec26                	sd	s1,24(sp)
    800030d4:	e84a                	sd	s2,16(sp)
    800030d6:	e44e                	sd	s3,8(sp)
    800030d8:	1800                	addi	s0,sp,48
    800030da:	892a                	mv	s2,a0
    800030dc:	84ae                	mv	s1,a1
    800030de:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030e0:	fffff097          	auipc	ra,0xfffff
    800030e4:	8d4080e7          	jalr	-1836(ra) # 800019b4 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800030e8:	86ce                	mv	a3,s3
    800030ea:	864a                	mv	a2,s2
    800030ec:	85a6                	mv	a1,s1
    800030ee:	6928                	ld	a0,80(a0)
    800030f0:	ffffe097          	auipc	ra,0xffffe
    800030f4:	668080e7          	jalr	1640(ra) # 80001758 <copyinstr>
  if(err < 0)
    800030f8:	00054763          	bltz	a0,80003106 <fetchstr+0x3a>
  return strlen(buf);
    800030fc:	8526                	mv	a0,s1
    800030fe:	ffffe097          	auipc	ra,0xffffe
    80003102:	d44080e7          	jalr	-700(ra) # 80000e42 <strlen>
}
    80003106:	70a2                	ld	ra,40(sp)
    80003108:	7402                	ld	s0,32(sp)
    8000310a:	64e2                	ld	s1,24(sp)
    8000310c:	6942                	ld	s2,16(sp)
    8000310e:	69a2                	ld	s3,8(sp)
    80003110:	6145                	addi	sp,sp,48
    80003112:	8082                	ret

0000000080003114 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003114:	1101                	addi	sp,sp,-32
    80003116:	ec06                	sd	ra,24(sp)
    80003118:	e822                	sd	s0,16(sp)
    8000311a:	e426                	sd	s1,8(sp)
    8000311c:	1000                	addi	s0,sp,32
    8000311e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003120:	00000097          	auipc	ra,0x0
    80003124:	ef2080e7          	jalr	-270(ra) # 80003012 <argraw>
    80003128:	c088                	sw	a0,0(s1)
  return 0;
}
    8000312a:	4501                	li	a0,0
    8000312c:	60e2                	ld	ra,24(sp)
    8000312e:	6442                	ld	s0,16(sp)
    80003130:	64a2                	ld	s1,8(sp)
    80003132:	6105                	addi	sp,sp,32
    80003134:	8082                	ret

0000000080003136 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003136:	1101                	addi	sp,sp,-32
    80003138:	ec06                	sd	ra,24(sp)
    8000313a:	e822                	sd	s0,16(sp)
    8000313c:	e426                	sd	s1,8(sp)
    8000313e:	1000                	addi	s0,sp,32
    80003140:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003142:	00000097          	auipc	ra,0x0
    80003146:	ed0080e7          	jalr	-304(ra) # 80003012 <argraw>
    8000314a:	e088                	sd	a0,0(s1)
  return 0;
}
    8000314c:	4501                	li	a0,0
    8000314e:	60e2                	ld	ra,24(sp)
    80003150:	6442                	ld	s0,16(sp)
    80003152:	64a2                	ld	s1,8(sp)
    80003154:	6105                	addi	sp,sp,32
    80003156:	8082                	ret

0000000080003158 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003158:	1101                	addi	sp,sp,-32
    8000315a:	ec06                	sd	ra,24(sp)
    8000315c:	e822                	sd	s0,16(sp)
    8000315e:	e426                	sd	s1,8(sp)
    80003160:	e04a                	sd	s2,0(sp)
    80003162:	1000                	addi	s0,sp,32
    80003164:	84ae                	mv	s1,a1
    80003166:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003168:	00000097          	auipc	ra,0x0
    8000316c:	eaa080e7          	jalr	-342(ra) # 80003012 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003170:	864a                	mv	a2,s2
    80003172:	85a6                	mv	a1,s1
    80003174:	00000097          	auipc	ra,0x0
    80003178:	f58080e7          	jalr	-168(ra) # 800030cc <fetchstr>
}
    8000317c:	60e2                	ld	ra,24(sp)
    8000317e:	6442                	ld	s0,16(sp)
    80003180:	64a2                	ld	s1,8(sp)
    80003182:	6902                	ld	s2,0(sp)
    80003184:	6105                	addi	sp,sp,32
    80003186:	8082                	ret

0000000080003188 <syscall>:
//task 1.5
};

void
syscall(void)
{
    80003188:	1101                	addi	sp,sp,-32
    8000318a:	ec06                	sd	ra,24(sp)
    8000318c:	e822                	sd	s0,16(sp)
    8000318e:	e426                	sd	s1,8(sp)
    80003190:	e04a                	sd	s2,0(sp)
    80003192:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	820080e7          	jalr	-2016(ra) # 800019b4 <myproc>
    8000319c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000319e:	05853903          	ld	s2,88(a0)
    800031a2:	0a893783          	ld	a5,168(s2)
    800031a6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800031aa:	37fd                	addiw	a5,a5,-1
    800031ac:	475d                	li	a4,23
    800031ae:	00f76f63          	bltu	a4,a5,800031cc <syscall+0x44>
    800031b2:	00369713          	slli	a4,a3,0x3
    800031b6:	00005797          	auipc	a5,0x5
    800031ba:	2ea78793          	addi	a5,a5,746 # 800084a0 <syscalls>
    800031be:	97ba                	add	a5,a5,a4
    800031c0:	639c                	ld	a5,0(a5)
    800031c2:	c789                	beqz	a5,800031cc <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800031c4:	9782                	jalr	a5
    800031c6:	06a93823          	sd	a0,112(s2)
    800031ca:	a839                	j	800031e8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800031cc:	15848613          	addi	a2,s1,344
    800031d0:	588c                	lw	a1,48(s1)
    800031d2:	00005517          	auipc	a0,0x5
    800031d6:	29650513          	addi	a0,a0,662 # 80008468 <states.0+0x150>
    800031da:	ffffd097          	auipc	ra,0xffffd
    800031de:	39a080e7          	jalr	922(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800031e2:	6cbc                	ld	a5,88(s1)
    800031e4:	577d                	li	a4,-1
    800031e6:	fbb8                	sd	a4,112(a5)
  }
}
    800031e8:	60e2                	ld	ra,24(sp)
    800031ea:	6442                	ld	s0,16(sp)
    800031ec:	64a2                	ld	s1,8(sp)
    800031ee:	6902                	ld	s2,0(sp)
    800031f0:	6105                	addi	sp,sp,32
    800031f2:	8082                	ret

00000000800031f4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800031f4:	1101                	addi	sp,sp,-32
    800031f6:	ec06                	sd	ra,24(sp)
    800031f8:	e822                	sd	s0,16(sp)
    800031fa:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800031fc:	fec40593          	addi	a1,s0,-20
    80003200:	4501                	li	a0,0
    80003202:	00000097          	auipc	ra,0x0
    80003206:	f12080e7          	jalr	-238(ra) # 80003114 <argint>
    return -1;
    8000320a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000320c:	00054963          	bltz	a0,8000321e <sys_exit+0x2a>
  exit(n);
    80003210:	fec42503          	lw	a0,-20(s0)
    80003214:	fffff097          	auipc	ra,0xfffff
    80003218:	174080e7          	jalr	372(ra) # 80002388 <exit>
  return 0;  // not reached
    8000321c:	4781                	li	a5,0
}
    8000321e:	853e                	mv	a0,a5
    80003220:	60e2                	ld	ra,24(sp)
    80003222:	6442                	ld	s0,16(sp)
    80003224:	6105                	addi	sp,sp,32
    80003226:	8082                	ret

0000000080003228 <sys_sigprocmask>:

//task 1.3
uint64
sys_sigprocmask(void)
{
    80003228:	1101                	addi	sp,sp,-32
    8000322a:	ec06                	sd	ra,24(sp)
    8000322c:	e822                	sd	s0,16(sp)
    8000322e:	1000                	addi	s0,sp,32
    int newmask;
    if(argint(0, &newmask) < 0)
    80003230:	fec40593          	addi	a1,s0,-20
    80003234:	4501                	li	a0,0
    80003236:	00000097          	auipc	ra,0x0
    8000323a:	ede080e7          	jalr	-290(ra) # 80003114 <argint>
    8000323e:	87aa                	mv	a5,a0
      return -1;
    80003240:	557d                	li	a0,-1
    if(argint(0, &newmask) < 0)
    80003242:	0007ca63          	bltz	a5,80003256 <sys_sigprocmask+0x2e>
    return sigprocmask(newmask);
    80003246:	fec42503          	lw	a0,-20(s0)
    8000324a:	fffff097          	auipc	ra,0xfffff
    8000324e:	3f0080e7          	jalr	1008(ra) # 8000263a <sigprocmask>
    80003252:	1502                	slli	a0,a0,0x20
    80003254:	9101                	srli	a0,a0,0x20
}
    80003256:	60e2                	ld	ra,24(sp)
    80003258:	6442                	ld	s0,16(sp)
    8000325a:	6105                	addi	sp,sp,32
    8000325c:	8082                	ret

000000008000325e <sys_sigaction>:
//task 1.3

//task 1.4
uint64
sys_sigaction(void)
{
    8000325e:	7179                	addi	sp,sp,-48
    80003260:	f406                	sd	ra,40(sp)
    80003262:	f022                	sd	s0,32(sp)
    80003264:	1800                	addi	s0,sp,48
  uint64 oldact;
  //struct sigaction *act;
  //struct sigaction *oldact;
  int signum;
  
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    80003266:	fdc40593          	addi	a1,s0,-36
    8000326a:	4501                	li	a0,0
    8000326c:	00000097          	auipc	ra,0x0
    80003270:	ea8080e7          	jalr	-344(ra) # 80003114 <argint>
    return -1;
    80003274:	57fd                	li	a5,-1
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    80003276:	04054163          	bltz	a0,800032b8 <sys_sigaction+0x5a>
    8000327a:	fe840593          	addi	a1,s0,-24
    8000327e:	4505                	li	a0,1
    80003280:	00000097          	auipc	ra,0x0
    80003284:	eb6080e7          	jalr	-330(ra) # 80003136 <argaddr>
    return -1;
    80003288:	57fd                	li	a5,-1
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    8000328a:	02054763          	bltz	a0,800032b8 <sys_sigaction+0x5a>
    8000328e:	fe040593          	addi	a1,s0,-32
    80003292:	4509                	li	a0,2
    80003294:	00000097          	auipc	ra,0x0
    80003298:	ea2080e7          	jalr	-350(ra) # 80003136 <argaddr>
    return -1;
    8000329c:	57fd                	li	a5,-1
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    8000329e:	00054d63          	bltz	a0,800032b8 <sys_sigaction+0x5a>
  return sigaction(signum,(struct sigaction*)act,(struct sigaction*)oldact);
    800032a2:	fe043603          	ld	a2,-32(s0)
    800032a6:	fe843583          	ld	a1,-24(s0)
    800032aa:	fdc42503          	lw	a0,-36(s0)
    800032ae:	fffff097          	auipc	ra,0xfffff
    800032b2:	434080e7          	jalr	1076(ra) # 800026e2 <sigaction>
    800032b6:	87aa                	mv	a5,a0
}
    800032b8:	853e                	mv	a0,a5
    800032ba:	70a2                	ld	ra,40(sp)
    800032bc:	7402                	ld	s0,32(sp)
    800032be:	6145                	addi	sp,sp,48
    800032c0:	8082                	ret

00000000800032c2 <sys_sigret>:
//task 1.4

//task 1.5
uint64
sys_sigret(void)
{
    800032c2:	1141                	addi	sp,sp,-16
    800032c4:	e422                	sd	s0,8(sp)
    800032c6:	0800                	addi	s0,sp,16
  return 0; //todo change after 2.4 is done
}
    800032c8:	4501                	li	a0,0
    800032ca:	6422                	ld	s0,8(sp)
    800032cc:	0141                	addi	sp,sp,16
    800032ce:	8082                	ret

00000000800032d0 <sys_getpid>:
//task1.5

uint64
sys_getpid(void)
{
    800032d0:	1141                	addi	sp,sp,-16
    800032d2:	e406                	sd	ra,8(sp)
    800032d4:	e022                	sd	s0,0(sp)
    800032d6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800032d8:	ffffe097          	auipc	ra,0xffffe
    800032dc:	6dc080e7          	jalr	1756(ra) # 800019b4 <myproc>
}
    800032e0:	5908                	lw	a0,48(a0)
    800032e2:	60a2                	ld	ra,8(sp)
    800032e4:	6402                	ld	s0,0(sp)
    800032e6:	0141                	addi	sp,sp,16
    800032e8:	8082                	ret

00000000800032ea <sys_fork>:

uint64
sys_fork(void)
{
    800032ea:	1141                	addi	sp,sp,-16
    800032ec:	e406                	sd	ra,8(sp)
    800032ee:	e022                	sd	s0,0(sp)
    800032f0:	0800                	addi	s0,sp,16
  return fork();
    800032f2:	fffff097          	auipc	ra,0xfffff
    800032f6:	b0e080e7          	jalr	-1266(ra) # 80001e00 <fork>
}
    800032fa:	60a2                	ld	ra,8(sp)
    800032fc:	6402                	ld	s0,0(sp)
    800032fe:	0141                	addi	sp,sp,16
    80003300:	8082                	ret

0000000080003302 <sys_wait>:

uint64
sys_wait(void)
{
    80003302:	1101                	addi	sp,sp,-32
    80003304:	ec06                	sd	ra,24(sp)
    80003306:	e822                	sd	s0,16(sp)
    80003308:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000330a:	fe840593          	addi	a1,s0,-24
    8000330e:	4501                	li	a0,0
    80003310:	00000097          	auipc	ra,0x0
    80003314:	e26080e7          	jalr	-474(ra) # 80003136 <argaddr>
    80003318:	87aa                	mv	a5,a0
    return -1;
    8000331a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    8000331c:	0007c863          	bltz	a5,8000332c <sys_wait+0x2a>
  return wait(p);
    80003320:	fe843503          	ld	a0,-24(s0)
    80003324:	fffff097          	auipc	ra,0xfffff
    80003328:	e6c080e7          	jalr	-404(ra) # 80002190 <wait>
}
    8000332c:	60e2                	ld	ra,24(sp)
    8000332e:	6442                	ld	s0,16(sp)
    80003330:	6105                	addi	sp,sp,32
    80003332:	8082                	ret

0000000080003334 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003334:	7179                	addi	sp,sp,-48
    80003336:	f406                	sd	ra,40(sp)
    80003338:	f022                	sd	s0,32(sp)
    8000333a:	ec26                	sd	s1,24(sp)
    8000333c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000333e:	fdc40593          	addi	a1,s0,-36
    80003342:	4501                	li	a0,0
    80003344:	00000097          	auipc	ra,0x0
    80003348:	dd0080e7          	jalr	-560(ra) # 80003114 <argint>
    return -1;
    8000334c:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000334e:	00054f63          	bltz	a0,8000336c <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	662080e7          	jalr	1634(ra) # 800019b4 <myproc>
    8000335a:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    8000335c:	fdc42503          	lw	a0,-36(s0)
    80003360:	fffff097          	auipc	ra,0xfffff
    80003364:	a2c080e7          	jalr	-1492(ra) # 80001d8c <growproc>
    80003368:	00054863          	bltz	a0,80003378 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    8000336c:	8526                	mv	a0,s1
    8000336e:	70a2                	ld	ra,40(sp)
    80003370:	7402                	ld	s0,32(sp)
    80003372:	64e2                	ld	s1,24(sp)
    80003374:	6145                	addi	sp,sp,48
    80003376:	8082                	ret
    return -1;
    80003378:	54fd                	li	s1,-1
    8000337a:	bfcd                	j	8000336c <sys_sbrk+0x38>

000000008000337c <sys_sleep>:

uint64
sys_sleep(void)
{
    8000337c:	7139                	addi	sp,sp,-64
    8000337e:	fc06                	sd	ra,56(sp)
    80003380:	f822                	sd	s0,48(sp)
    80003382:	f426                	sd	s1,40(sp)
    80003384:	f04a                	sd	s2,32(sp)
    80003386:	ec4e                	sd	s3,24(sp)
    80003388:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000338a:	fcc40593          	addi	a1,s0,-52
    8000338e:	4501                	li	a0,0
    80003390:	00000097          	auipc	ra,0x0
    80003394:	d84080e7          	jalr	-636(ra) # 80003114 <argint>
    return -1;
    80003398:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000339a:	06054563          	bltz	a0,80003404 <sys_sleep+0x88>
  acquire(&tickslock);
    8000339e:	0001a517          	auipc	a0,0x1a
    800033a2:	53250513          	addi	a0,a0,1330 # 8001d8d0 <tickslock>
    800033a6:	ffffe097          	auipc	ra,0xffffe
    800033aa:	81c080e7          	jalr	-2020(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    800033ae:	00006917          	auipc	s2,0x6
    800033b2:	c8292903          	lw	s2,-894(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    800033b6:	fcc42783          	lw	a5,-52(s0)
    800033ba:	cf85                	beqz	a5,800033f2 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800033bc:	0001a997          	auipc	s3,0x1a
    800033c0:	51498993          	addi	s3,s3,1300 # 8001d8d0 <tickslock>
    800033c4:	00006497          	auipc	s1,0x6
    800033c8:	c6c48493          	addi	s1,s1,-916 # 80009030 <ticks>
    if(myproc()->killed){
    800033cc:	ffffe097          	auipc	ra,0xffffe
    800033d0:	5e8080e7          	jalr	1512(ra) # 800019b4 <myproc>
    800033d4:	551c                	lw	a5,40(a0)
    800033d6:	ef9d                	bnez	a5,80003414 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800033d8:	85ce                	mv	a1,s3
    800033da:	8526                	mv	a0,s1
    800033dc:	fffff097          	auipc	ra,0xfffff
    800033e0:	d50080e7          	jalr	-688(ra) # 8000212c <sleep>
  while(ticks - ticks0 < n){
    800033e4:	409c                	lw	a5,0(s1)
    800033e6:	412787bb          	subw	a5,a5,s2
    800033ea:	fcc42703          	lw	a4,-52(s0)
    800033ee:	fce7efe3          	bltu	a5,a4,800033cc <sys_sleep+0x50>
  }
  release(&tickslock);
    800033f2:	0001a517          	auipc	a0,0x1a
    800033f6:	4de50513          	addi	a0,a0,1246 # 8001d8d0 <tickslock>
    800033fa:	ffffe097          	auipc	ra,0xffffe
    800033fe:	87c080e7          	jalr	-1924(ra) # 80000c76 <release>
  return 0;
    80003402:	4781                	li	a5,0
}
    80003404:	853e                	mv	a0,a5
    80003406:	70e2                	ld	ra,56(sp)
    80003408:	7442                	ld	s0,48(sp)
    8000340a:	74a2                	ld	s1,40(sp)
    8000340c:	7902                	ld	s2,32(sp)
    8000340e:	69e2                	ld	s3,24(sp)
    80003410:	6121                	addi	sp,sp,64
    80003412:	8082                	ret
      release(&tickslock);
    80003414:	0001a517          	auipc	a0,0x1a
    80003418:	4bc50513          	addi	a0,a0,1212 # 8001d8d0 <tickslock>
    8000341c:	ffffe097          	auipc	ra,0xffffe
    80003420:	85a080e7          	jalr	-1958(ra) # 80000c76 <release>
      return -1;
    80003424:	57fd                	li	a5,-1
    80003426:	bff9                	j	80003404 <sys_sleep+0x88>

0000000080003428 <sys_kill>:

uint64
sys_kill(void)
{
    80003428:	1101                	addi	sp,sp,-32
    8000342a:	ec06                	sd	ra,24(sp)
    8000342c:	e822                	sd	s0,16(sp)
    8000342e:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003430:	fec40593          	addi	a1,s0,-20
    80003434:	4501                	li	a0,0
    80003436:	00000097          	auipc	ra,0x0
    8000343a:	cde080e7          	jalr	-802(ra) # 80003114 <argint>
    return -1;
    8000343e:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    80003440:	02054563          	bltz	a0,8000346a <sys_kill+0x42>
  if(argint(1, &signum) < 0)
    80003444:	fe840593          	addi	a1,s0,-24
    80003448:	4505                	li	a0,1
    8000344a:	00000097          	auipc	ra,0x0
    8000344e:	cca080e7          	jalr	-822(ra) # 80003114 <argint>
    return -1;
    80003452:	57fd                	li	a5,-1
  if(argint(1, &signum) < 0)
    80003454:	00054b63          	bltz	a0,8000346a <sys_kill+0x42>
 
  return kill(pid,signum);
    80003458:	fe842583          	lw	a1,-24(s0)
    8000345c:	fec42503          	lw	a0,-20(s0)
    80003460:	fffff097          	auipc	ra,0xfffff
    80003464:	ffe080e7          	jalr	-2(ra) # 8000245e <kill>
    80003468:	87aa                	mv	a5,a0
}
    8000346a:	853e                	mv	a0,a5
    8000346c:	60e2                	ld	ra,24(sp)
    8000346e:	6442                	ld	s0,16(sp)
    80003470:	6105                	addi	sp,sp,32
    80003472:	8082                	ret

0000000080003474 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003474:	1101                	addi	sp,sp,-32
    80003476:	ec06                	sd	ra,24(sp)
    80003478:	e822                	sd	s0,16(sp)
    8000347a:	e426                	sd	s1,8(sp)
    8000347c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000347e:	0001a517          	auipc	a0,0x1a
    80003482:	45250513          	addi	a0,a0,1106 # 8001d8d0 <tickslock>
    80003486:	ffffd097          	auipc	ra,0xffffd
    8000348a:	73c080e7          	jalr	1852(ra) # 80000bc2 <acquire>
  xticks = ticks;
    8000348e:	00006497          	auipc	s1,0x6
    80003492:	ba24a483          	lw	s1,-1118(s1) # 80009030 <ticks>
  release(&tickslock);
    80003496:	0001a517          	auipc	a0,0x1a
    8000349a:	43a50513          	addi	a0,a0,1082 # 8001d8d0 <tickslock>
    8000349e:	ffffd097          	auipc	ra,0xffffd
    800034a2:	7d8080e7          	jalr	2008(ra) # 80000c76 <release>
  return xticks;
}
    800034a6:	02049513          	slli	a0,s1,0x20
    800034aa:	9101                	srli	a0,a0,0x20
    800034ac:	60e2                	ld	ra,24(sp)
    800034ae:	6442                	ld	s0,16(sp)
    800034b0:	64a2                	ld	s1,8(sp)
    800034b2:	6105                	addi	sp,sp,32
    800034b4:	8082                	ret

00000000800034b6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800034b6:	7179                	addi	sp,sp,-48
    800034b8:	f406                	sd	ra,40(sp)
    800034ba:	f022                	sd	s0,32(sp)
    800034bc:	ec26                	sd	s1,24(sp)
    800034be:	e84a                	sd	s2,16(sp)
    800034c0:	e44e                	sd	s3,8(sp)
    800034c2:	e052                	sd	s4,0(sp)
    800034c4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800034c6:	00005597          	auipc	a1,0x5
    800034ca:	0a258593          	addi	a1,a1,162 # 80008568 <syscalls+0xc8>
    800034ce:	0001a517          	auipc	a0,0x1a
    800034d2:	41a50513          	addi	a0,a0,1050 # 8001d8e8 <bcache>
    800034d6:	ffffd097          	auipc	ra,0xffffd
    800034da:	65c080e7          	jalr	1628(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800034de:	00022797          	auipc	a5,0x22
    800034e2:	40a78793          	addi	a5,a5,1034 # 800258e8 <bcache+0x8000>
    800034e6:	00022717          	auipc	a4,0x22
    800034ea:	66a70713          	addi	a4,a4,1642 # 80025b50 <bcache+0x8268>
    800034ee:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034f2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034f6:	0001a497          	auipc	s1,0x1a
    800034fa:	40a48493          	addi	s1,s1,1034 # 8001d900 <bcache+0x18>
    b->next = bcache.head.next;
    800034fe:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003500:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003502:	00005a17          	auipc	s4,0x5
    80003506:	06ea0a13          	addi	s4,s4,110 # 80008570 <syscalls+0xd0>
    b->next = bcache.head.next;
    8000350a:	2b893783          	ld	a5,696(s2)
    8000350e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003510:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003514:	85d2                	mv	a1,s4
    80003516:	01048513          	addi	a0,s1,16
    8000351a:	00001097          	auipc	ra,0x1
    8000351e:	4c2080e7          	jalr	1218(ra) # 800049dc <initsleeplock>
    bcache.head.next->prev = b;
    80003522:	2b893783          	ld	a5,696(s2)
    80003526:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003528:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000352c:	45848493          	addi	s1,s1,1112
    80003530:	fd349de3          	bne	s1,s3,8000350a <binit+0x54>
  }
}
    80003534:	70a2                	ld	ra,40(sp)
    80003536:	7402                	ld	s0,32(sp)
    80003538:	64e2                	ld	s1,24(sp)
    8000353a:	6942                	ld	s2,16(sp)
    8000353c:	69a2                	ld	s3,8(sp)
    8000353e:	6a02                	ld	s4,0(sp)
    80003540:	6145                	addi	sp,sp,48
    80003542:	8082                	ret

0000000080003544 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003544:	7179                	addi	sp,sp,-48
    80003546:	f406                	sd	ra,40(sp)
    80003548:	f022                	sd	s0,32(sp)
    8000354a:	ec26                	sd	s1,24(sp)
    8000354c:	e84a                	sd	s2,16(sp)
    8000354e:	e44e                	sd	s3,8(sp)
    80003550:	1800                	addi	s0,sp,48
    80003552:	892a                	mv	s2,a0
    80003554:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003556:	0001a517          	auipc	a0,0x1a
    8000355a:	39250513          	addi	a0,a0,914 # 8001d8e8 <bcache>
    8000355e:	ffffd097          	auipc	ra,0xffffd
    80003562:	664080e7          	jalr	1636(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003566:	00022497          	auipc	s1,0x22
    8000356a:	63a4b483          	ld	s1,1594(s1) # 80025ba0 <bcache+0x82b8>
    8000356e:	00022797          	auipc	a5,0x22
    80003572:	5e278793          	addi	a5,a5,1506 # 80025b50 <bcache+0x8268>
    80003576:	02f48f63          	beq	s1,a5,800035b4 <bread+0x70>
    8000357a:	873e                	mv	a4,a5
    8000357c:	a021                	j	80003584 <bread+0x40>
    8000357e:	68a4                	ld	s1,80(s1)
    80003580:	02e48a63          	beq	s1,a4,800035b4 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003584:	449c                	lw	a5,8(s1)
    80003586:	ff279ce3          	bne	a5,s2,8000357e <bread+0x3a>
    8000358a:	44dc                	lw	a5,12(s1)
    8000358c:	ff3799e3          	bne	a5,s3,8000357e <bread+0x3a>
      b->refcnt++;
    80003590:	40bc                	lw	a5,64(s1)
    80003592:	2785                	addiw	a5,a5,1
    80003594:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003596:	0001a517          	auipc	a0,0x1a
    8000359a:	35250513          	addi	a0,a0,850 # 8001d8e8 <bcache>
    8000359e:	ffffd097          	auipc	ra,0xffffd
    800035a2:	6d8080e7          	jalr	1752(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800035a6:	01048513          	addi	a0,s1,16
    800035aa:	00001097          	auipc	ra,0x1
    800035ae:	46c080e7          	jalr	1132(ra) # 80004a16 <acquiresleep>
      return b;
    800035b2:	a8b9                	j	80003610 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035b4:	00022497          	auipc	s1,0x22
    800035b8:	5e44b483          	ld	s1,1508(s1) # 80025b98 <bcache+0x82b0>
    800035bc:	00022797          	auipc	a5,0x22
    800035c0:	59478793          	addi	a5,a5,1428 # 80025b50 <bcache+0x8268>
    800035c4:	00f48863          	beq	s1,a5,800035d4 <bread+0x90>
    800035c8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800035ca:	40bc                	lw	a5,64(s1)
    800035cc:	cf81                	beqz	a5,800035e4 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035ce:	64a4                	ld	s1,72(s1)
    800035d0:	fee49de3          	bne	s1,a4,800035ca <bread+0x86>
  panic("bget: no buffers");
    800035d4:	00005517          	auipc	a0,0x5
    800035d8:	fa450513          	addi	a0,a0,-92 # 80008578 <syscalls+0xd8>
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	f4e080e7          	jalr	-178(ra) # 8000052a <panic>
      b->dev = dev;
    800035e4:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800035e8:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800035ec:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035f0:	4785                	li	a5,1
    800035f2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035f4:	0001a517          	auipc	a0,0x1a
    800035f8:	2f450513          	addi	a0,a0,756 # 8001d8e8 <bcache>
    800035fc:	ffffd097          	auipc	ra,0xffffd
    80003600:	67a080e7          	jalr	1658(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003604:	01048513          	addi	a0,s1,16
    80003608:	00001097          	auipc	ra,0x1
    8000360c:	40e080e7          	jalr	1038(ra) # 80004a16 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003610:	409c                	lw	a5,0(s1)
    80003612:	cb89                	beqz	a5,80003624 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003614:	8526                	mv	a0,s1
    80003616:	70a2                	ld	ra,40(sp)
    80003618:	7402                	ld	s0,32(sp)
    8000361a:	64e2                	ld	s1,24(sp)
    8000361c:	6942                	ld	s2,16(sp)
    8000361e:	69a2                	ld	s3,8(sp)
    80003620:	6145                	addi	sp,sp,48
    80003622:	8082                	ret
    virtio_disk_rw(b, 0);
    80003624:	4581                	li	a1,0
    80003626:	8526                	mv	a0,s1
    80003628:	00003097          	auipc	ra,0x3
    8000362c:	f3e080e7          	jalr	-194(ra) # 80006566 <virtio_disk_rw>
    b->valid = 1;
    80003630:	4785                	li	a5,1
    80003632:	c09c                	sw	a5,0(s1)
  return b;
    80003634:	b7c5                	j	80003614 <bread+0xd0>

0000000080003636 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003636:	1101                	addi	sp,sp,-32
    80003638:	ec06                	sd	ra,24(sp)
    8000363a:	e822                	sd	s0,16(sp)
    8000363c:	e426                	sd	s1,8(sp)
    8000363e:	1000                	addi	s0,sp,32
    80003640:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003642:	0541                	addi	a0,a0,16
    80003644:	00001097          	auipc	ra,0x1
    80003648:	46c080e7          	jalr	1132(ra) # 80004ab0 <holdingsleep>
    8000364c:	cd01                	beqz	a0,80003664 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000364e:	4585                	li	a1,1
    80003650:	8526                	mv	a0,s1
    80003652:	00003097          	auipc	ra,0x3
    80003656:	f14080e7          	jalr	-236(ra) # 80006566 <virtio_disk_rw>
}
    8000365a:	60e2                	ld	ra,24(sp)
    8000365c:	6442                	ld	s0,16(sp)
    8000365e:	64a2                	ld	s1,8(sp)
    80003660:	6105                	addi	sp,sp,32
    80003662:	8082                	ret
    panic("bwrite");
    80003664:	00005517          	auipc	a0,0x5
    80003668:	f2c50513          	addi	a0,a0,-212 # 80008590 <syscalls+0xf0>
    8000366c:	ffffd097          	auipc	ra,0xffffd
    80003670:	ebe080e7          	jalr	-322(ra) # 8000052a <panic>

0000000080003674 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003674:	1101                	addi	sp,sp,-32
    80003676:	ec06                	sd	ra,24(sp)
    80003678:	e822                	sd	s0,16(sp)
    8000367a:	e426                	sd	s1,8(sp)
    8000367c:	e04a                	sd	s2,0(sp)
    8000367e:	1000                	addi	s0,sp,32
    80003680:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003682:	01050913          	addi	s2,a0,16
    80003686:	854a                	mv	a0,s2
    80003688:	00001097          	auipc	ra,0x1
    8000368c:	428080e7          	jalr	1064(ra) # 80004ab0 <holdingsleep>
    80003690:	c92d                	beqz	a0,80003702 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003692:	854a                	mv	a0,s2
    80003694:	00001097          	auipc	ra,0x1
    80003698:	3d8080e7          	jalr	984(ra) # 80004a6c <releasesleep>

  acquire(&bcache.lock);
    8000369c:	0001a517          	auipc	a0,0x1a
    800036a0:	24c50513          	addi	a0,a0,588 # 8001d8e8 <bcache>
    800036a4:	ffffd097          	auipc	ra,0xffffd
    800036a8:	51e080e7          	jalr	1310(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800036ac:	40bc                	lw	a5,64(s1)
    800036ae:	37fd                	addiw	a5,a5,-1
    800036b0:	0007871b          	sext.w	a4,a5
    800036b4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800036b6:	eb05                	bnez	a4,800036e6 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800036b8:	68bc                	ld	a5,80(s1)
    800036ba:	64b8                	ld	a4,72(s1)
    800036bc:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800036be:	64bc                	ld	a5,72(s1)
    800036c0:	68b8                	ld	a4,80(s1)
    800036c2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800036c4:	00022797          	auipc	a5,0x22
    800036c8:	22478793          	addi	a5,a5,548 # 800258e8 <bcache+0x8000>
    800036cc:	2b87b703          	ld	a4,696(a5)
    800036d0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800036d2:	00022717          	auipc	a4,0x22
    800036d6:	47e70713          	addi	a4,a4,1150 # 80025b50 <bcache+0x8268>
    800036da:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800036dc:	2b87b703          	ld	a4,696(a5)
    800036e0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800036e2:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800036e6:	0001a517          	auipc	a0,0x1a
    800036ea:	20250513          	addi	a0,a0,514 # 8001d8e8 <bcache>
    800036ee:	ffffd097          	auipc	ra,0xffffd
    800036f2:	588080e7          	jalr	1416(ra) # 80000c76 <release>
}
    800036f6:	60e2                	ld	ra,24(sp)
    800036f8:	6442                	ld	s0,16(sp)
    800036fa:	64a2                	ld	s1,8(sp)
    800036fc:	6902                	ld	s2,0(sp)
    800036fe:	6105                	addi	sp,sp,32
    80003700:	8082                	ret
    panic("brelse");
    80003702:	00005517          	auipc	a0,0x5
    80003706:	e9650513          	addi	a0,a0,-362 # 80008598 <syscalls+0xf8>
    8000370a:	ffffd097          	auipc	ra,0xffffd
    8000370e:	e20080e7          	jalr	-480(ra) # 8000052a <panic>

0000000080003712 <bpin>:

void
bpin(struct buf *b) {
    80003712:	1101                	addi	sp,sp,-32
    80003714:	ec06                	sd	ra,24(sp)
    80003716:	e822                	sd	s0,16(sp)
    80003718:	e426                	sd	s1,8(sp)
    8000371a:	1000                	addi	s0,sp,32
    8000371c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000371e:	0001a517          	auipc	a0,0x1a
    80003722:	1ca50513          	addi	a0,a0,458 # 8001d8e8 <bcache>
    80003726:	ffffd097          	auipc	ra,0xffffd
    8000372a:	49c080e7          	jalr	1180(ra) # 80000bc2 <acquire>
  b->refcnt++;
    8000372e:	40bc                	lw	a5,64(s1)
    80003730:	2785                	addiw	a5,a5,1
    80003732:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003734:	0001a517          	auipc	a0,0x1a
    80003738:	1b450513          	addi	a0,a0,436 # 8001d8e8 <bcache>
    8000373c:	ffffd097          	auipc	ra,0xffffd
    80003740:	53a080e7          	jalr	1338(ra) # 80000c76 <release>
}
    80003744:	60e2                	ld	ra,24(sp)
    80003746:	6442                	ld	s0,16(sp)
    80003748:	64a2                	ld	s1,8(sp)
    8000374a:	6105                	addi	sp,sp,32
    8000374c:	8082                	ret

000000008000374e <bunpin>:

void
bunpin(struct buf *b) {
    8000374e:	1101                	addi	sp,sp,-32
    80003750:	ec06                	sd	ra,24(sp)
    80003752:	e822                	sd	s0,16(sp)
    80003754:	e426                	sd	s1,8(sp)
    80003756:	1000                	addi	s0,sp,32
    80003758:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000375a:	0001a517          	auipc	a0,0x1a
    8000375e:	18e50513          	addi	a0,a0,398 # 8001d8e8 <bcache>
    80003762:	ffffd097          	auipc	ra,0xffffd
    80003766:	460080e7          	jalr	1120(ra) # 80000bc2 <acquire>
  b->refcnt--;
    8000376a:	40bc                	lw	a5,64(s1)
    8000376c:	37fd                	addiw	a5,a5,-1
    8000376e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003770:	0001a517          	auipc	a0,0x1a
    80003774:	17850513          	addi	a0,a0,376 # 8001d8e8 <bcache>
    80003778:	ffffd097          	auipc	ra,0xffffd
    8000377c:	4fe080e7          	jalr	1278(ra) # 80000c76 <release>
}
    80003780:	60e2                	ld	ra,24(sp)
    80003782:	6442                	ld	s0,16(sp)
    80003784:	64a2                	ld	s1,8(sp)
    80003786:	6105                	addi	sp,sp,32
    80003788:	8082                	ret

000000008000378a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000378a:	1101                	addi	sp,sp,-32
    8000378c:	ec06                	sd	ra,24(sp)
    8000378e:	e822                	sd	s0,16(sp)
    80003790:	e426                	sd	s1,8(sp)
    80003792:	e04a                	sd	s2,0(sp)
    80003794:	1000                	addi	s0,sp,32
    80003796:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003798:	00d5d59b          	srliw	a1,a1,0xd
    8000379c:	00023797          	auipc	a5,0x23
    800037a0:	8287a783          	lw	a5,-2008(a5) # 80025fc4 <sb+0x1c>
    800037a4:	9dbd                	addw	a1,a1,a5
    800037a6:	00000097          	auipc	ra,0x0
    800037aa:	d9e080e7          	jalr	-610(ra) # 80003544 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800037ae:	0074f713          	andi	a4,s1,7
    800037b2:	4785                	li	a5,1
    800037b4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800037b8:	14ce                	slli	s1,s1,0x33
    800037ba:	90d9                	srli	s1,s1,0x36
    800037bc:	00950733          	add	a4,a0,s1
    800037c0:	05874703          	lbu	a4,88(a4)
    800037c4:	00e7f6b3          	and	a3,a5,a4
    800037c8:	c69d                	beqz	a3,800037f6 <bfree+0x6c>
    800037ca:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800037cc:	94aa                	add	s1,s1,a0
    800037ce:	fff7c793          	not	a5,a5
    800037d2:	8ff9                	and	a5,a5,a4
    800037d4:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800037d8:	00001097          	auipc	ra,0x1
    800037dc:	11e080e7          	jalr	286(ra) # 800048f6 <log_write>
  brelse(bp);
    800037e0:	854a                	mv	a0,s2
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	e92080e7          	jalr	-366(ra) # 80003674 <brelse>
}
    800037ea:	60e2                	ld	ra,24(sp)
    800037ec:	6442                	ld	s0,16(sp)
    800037ee:	64a2                	ld	s1,8(sp)
    800037f0:	6902                	ld	s2,0(sp)
    800037f2:	6105                	addi	sp,sp,32
    800037f4:	8082                	ret
    panic("freeing free block");
    800037f6:	00005517          	auipc	a0,0x5
    800037fa:	daa50513          	addi	a0,a0,-598 # 800085a0 <syscalls+0x100>
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	d2c080e7          	jalr	-724(ra) # 8000052a <panic>

0000000080003806 <balloc>:
{
    80003806:	711d                	addi	sp,sp,-96
    80003808:	ec86                	sd	ra,88(sp)
    8000380a:	e8a2                	sd	s0,80(sp)
    8000380c:	e4a6                	sd	s1,72(sp)
    8000380e:	e0ca                	sd	s2,64(sp)
    80003810:	fc4e                	sd	s3,56(sp)
    80003812:	f852                	sd	s4,48(sp)
    80003814:	f456                	sd	s5,40(sp)
    80003816:	f05a                	sd	s6,32(sp)
    80003818:	ec5e                	sd	s7,24(sp)
    8000381a:	e862                	sd	s8,16(sp)
    8000381c:	e466                	sd	s9,8(sp)
    8000381e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003820:	00022797          	auipc	a5,0x22
    80003824:	78c7a783          	lw	a5,1932(a5) # 80025fac <sb+0x4>
    80003828:	cbd1                	beqz	a5,800038bc <balloc+0xb6>
    8000382a:	8baa                	mv	s7,a0
    8000382c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000382e:	00022b17          	auipc	s6,0x22
    80003832:	77ab0b13          	addi	s6,s6,1914 # 80025fa8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003836:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003838:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000383a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000383c:	6c89                	lui	s9,0x2
    8000383e:	a831                	j	8000385a <balloc+0x54>
    brelse(bp);
    80003840:	854a                	mv	a0,s2
    80003842:	00000097          	auipc	ra,0x0
    80003846:	e32080e7          	jalr	-462(ra) # 80003674 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000384a:	015c87bb          	addw	a5,s9,s5
    8000384e:	00078a9b          	sext.w	s5,a5
    80003852:	004b2703          	lw	a4,4(s6)
    80003856:	06eaf363          	bgeu	s5,a4,800038bc <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000385a:	41fad79b          	sraiw	a5,s5,0x1f
    8000385e:	0137d79b          	srliw	a5,a5,0x13
    80003862:	015787bb          	addw	a5,a5,s5
    80003866:	40d7d79b          	sraiw	a5,a5,0xd
    8000386a:	01cb2583          	lw	a1,28(s6)
    8000386e:	9dbd                	addw	a1,a1,a5
    80003870:	855e                	mv	a0,s7
    80003872:	00000097          	auipc	ra,0x0
    80003876:	cd2080e7          	jalr	-814(ra) # 80003544 <bread>
    8000387a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000387c:	004b2503          	lw	a0,4(s6)
    80003880:	000a849b          	sext.w	s1,s5
    80003884:	8662                	mv	a2,s8
    80003886:	faa4fde3          	bgeu	s1,a0,80003840 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000388a:	41f6579b          	sraiw	a5,a2,0x1f
    8000388e:	01d7d69b          	srliw	a3,a5,0x1d
    80003892:	00c6873b          	addw	a4,a3,a2
    80003896:	00777793          	andi	a5,a4,7
    8000389a:	9f95                	subw	a5,a5,a3
    8000389c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800038a0:	4037571b          	sraiw	a4,a4,0x3
    800038a4:	00e906b3          	add	a3,s2,a4
    800038a8:	0586c683          	lbu	a3,88(a3)
    800038ac:	00d7f5b3          	and	a1,a5,a3
    800038b0:	cd91                	beqz	a1,800038cc <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038b2:	2605                	addiw	a2,a2,1
    800038b4:	2485                	addiw	s1,s1,1
    800038b6:	fd4618e3          	bne	a2,s4,80003886 <balloc+0x80>
    800038ba:	b759                	j	80003840 <balloc+0x3a>
  panic("balloc: out of blocks");
    800038bc:	00005517          	auipc	a0,0x5
    800038c0:	cfc50513          	addi	a0,a0,-772 # 800085b8 <syscalls+0x118>
    800038c4:	ffffd097          	auipc	ra,0xffffd
    800038c8:	c66080e7          	jalr	-922(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800038cc:	974a                	add	a4,a4,s2
    800038ce:	8fd5                	or	a5,a5,a3
    800038d0:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800038d4:	854a                	mv	a0,s2
    800038d6:	00001097          	auipc	ra,0x1
    800038da:	020080e7          	jalr	32(ra) # 800048f6 <log_write>
        brelse(bp);
    800038de:	854a                	mv	a0,s2
    800038e0:	00000097          	auipc	ra,0x0
    800038e4:	d94080e7          	jalr	-620(ra) # 80003674 <brelse>
  bp = bread(dev, bno);
    800038e8:	85a6                	mv	a1,s1
    800038ea:	855e                	mv	a0,s7
    800038ec:	00000097          	auipc	ra,0x0
    800038f0:	c58080e7          	jalr	-936(ra) # 80003544 <bread>
    800038f4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038f6:	40000613          	li	a2,1024
    800038fa:	4581                	li	a1,0
    800038fc:	05850513          	addi	a0,a0,88
    80003900:	ffffd097          	auipc	ra,0xffffd
    80003904:	3be080e7          	jalr	958(ra) # 80000cbe <memset>
  log_write(bp);
    80003908:	854a                	mv	a0,s2
    8000390a:	00001097          	auipc	ra,0x1
    8000390e:	fec080e7          	jalr	-20(ra) # 800048f6 <log_write>
  brelse(bp);
    80003912:	854a                	mv	a0,s2
    80003914:	00000097          	auipc	ra,0x0
    80003918:	d60080e7          	jalr	-672(ra) # 80003674 <brelse>
}
    8000391c:	8526                	mv	a0,s1
    8000391e:	60e6                	ld	ra,88(sp)
    80003920:	6446                	ld	s0,80(sp)
    80003922:	64a6                	ld	s1,72(sp)
    80003924:	6906                	ld	s2,64(sp)
    80003926:	79e2                	ld	s3,56(sp)
    80003928:	7a42                	ld	s4,48(sp)
    8000392a:	7aa2                	ld	s5,40(sp)
    8000392c:	7b02                	ld	s6,32(sp)
    8000392e:	6be2                	ld	s7,24(sp)
    80003930:	6c42                	ld	s8,16(sp)
    80003932:	6ca2                	ld	s9,8(sp)
    80003934:	6125                	addi	sp,sp,96
    80003936:	8082                	ret

0000000080003938 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003938:	7179                	addi	sp,sp,-48
    8000393a:	f406                	sd	ra,40(sp)
    8000393c:	f022                	sd	s0,32(sp)
    8000393e:	ec26                	sd	s1,24(sp)
    80003940:	e84a                	sd	s2,16(sp)
    80003942:	e44e                	sd	s3,8(sp)
    80003944:	e052                	sd	s4,0(sp)
    80003946:	1800                	addi	s0,sp,48
    80003948:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000394a:	47ad                	li	a5,11
    8000394c:	04b7fe63          	bgeu	a5,a1,800039a8 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003950:	ff45849b          	addiw	s1,a1,-12
    80003954:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003958:	0ff00793          	li	a5,255
    8000395c:	0ae7e463          	bltu	a5,a4,80003a04 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003960:	08052583          	lw	a1,128(a0)
    80003964:	c5b5                	beqz	a1,800039d0 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003966:	00092503          	lw	a0,0(s2)
    8000396a:	00000097          	auipc	ra,0x0
    8000396e:	bda080e7          	jalr	-1062(ra) # 80003544 <bread>
    80003972:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003974:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003978:	02049713          	slli	a4,s1,0x20
    8000397c:	01e75593          	srli	a1,a4,0x1e
    80003980:	00b784b3          	add	s1,a5,a1
    80003984:	0004a983          	lw	s3,0(s1)
    80003988:	04098e63          	beqz	s3,800039e4 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000398c:	8552                	mv	a0,s4
    8000398e:	00000097          	auipc	ra,0x0
    80003992:	ce6080e7          	jalr	-794(ra) # 80003674 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003996:	854e                	mv	a0,s3
    80003998:	70a2                	ld	ra,40(sp)
    8000399a:	7402                	ld	s0,32(sp)
    8000399c:	64e2                	ld	s1,24(sp)
    8000399e:	6942                	ld	s2,16(sp)
    800039a0:	69a2                	ld	s3,8(sp)
    800039a2:	6a02                	ld	s4,0(sp)
    800039a4:	6145                	addi	sp,sp,48
    800039a6:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800039a8:	02059793          	slli	a5,a1,0x20
    800039ac:	01e7d593          	srli	a1,a5,0x1e
    800039b0:	00b504b3          	add	s1,a0,a1
    800039b4:	0504a983          	lw	s3,80(s1)
    800039b8:	fc099fe3          	bnez	s3,80003996 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800039bc:	4108                	lw	a0,0(a0)
    800039be:	00000097          	auipc	ra,0x0
    800039c2:	e48080e7          	jalr	-440(ra) # 80003806 <balloc>
    800039c6:	0005099b          	sext.w	s3,a0
    800039ca:	0534a823          	sw	s3,80(s1)
    800039ce:	b7e1                	j	80003996 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800039d0:	4108                	lw	a0,0(a0)
    800039d2:	00000097          	auipc	ra,0x0
    800039d6:	e34080e7          	jalr	-460(ra) # 80003806 <balloc>
    800039da:	0005059b          	sext.w	a1,a0
    800039de:	08b92023          	sw	a1,128(s2)
    800039e2:	b751                	j	80003966 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800039e4:	00092503          	lw	a0,0(s2)
    800039e8:	00000097          	auipc	ra,0x0
    800039ec:	e1e080e7          	jalr	-482(ra) # 80003806 <balloc>
    800039f0:	0005099b          	sext.w	s3,a0
    800039f4:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800039f8:	8552                	mv	a0,s4
    800039fa:	00001097          	auipc	ra,0x1
    800039fe:	efc080e7          	jalr	-260(ra) # 800048f6 <log_write>
    80003a02:	b769                	j	8000398c <bmap+0x54>
  panic("bmap: out of range");
    80003a04:	00005517          	auipc	a0,0x5
    80003a08:	bcc50513          	addi	a0,a0,-1076 # 800085d0 <syscalls+0x130>
    80003a0c:	ffffd097          	auipc	ra,0xffffd
    80003a10:	b1e080e7          	jalr	-1250(ra) # 8000052a <panic>

0000000080003a14 <iget>:
{
    80003a14:	7179                	addi	sp,sp,-48
    80003a16:	f406                	sd	ra,40(sp)
    80003a18:	f022                	sd	s0,32(sp)
    80003a1a:	ec26                	sd	s1,24(sp)
    80003a1c:	e84a                	sd	s2,16(sp)
    80003a1e:	e44e                	sd	s3,8(sp)
    80003a20:	e052                	sd	s4,0(sp)
    80003a22:	1800                	addi	s0,sp,48
    80003a24:	89aa                	mv	s3,a0
    80003a26:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a28:	00022517          	auipc	a0,0x22
    80003a2c:	5a050513          	addi	a0,a0,1440 # 80025fc8 <itable>
    80003a30:	ffffd097          	auipc	ra,0xffffd
    80003a34:	192080e7          	jalr	402(ra) # 80000bc2 <acquire>
  empty = 0;
    80003a38:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a3a:	00022497          	auipc	s1,0x22
    80003a3e:	5a648493          	addi	s1,s1,1446 # 80025fe0 <itable+0x18>
    80003a42:	00024697          	auipc	a3,0x24
    80003a46:	02e68693          	addi	a3,a3,46 # 80027a70 <log>
    80003a4a:	a039                	j	80003a58 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a4c:	02090b63          	beqz	s2,80003a82 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a50:	08848493          	addi	s1,s1,136
    80003a54:	02d48a63          	beq	s1,a3,80003a88 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a58:	449c                	lw	a5,8(s1)
    80003a5a:	fef059e3          	blez	a5,80003a4c <iget+0x38>
    80003a5e:	4098                	lw	a4,0(s1)
    80003a60:	ff3716e3          	bne	a4,s3,80003a4c <iget+0x38>
    80003a64:	40d8                	lw	a4,4(s1)
    80003a66:	ff4713e3          	bne	a4,s4,80003a4c <iget+0x38>
      ip->ref++;
    80003a6a:	2785                	addiw	a5,a5,1
    80003a6c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a6e:	00022517          	auipc	a0,0x22
    80003a72:	55a50513          	addi	a0,a0,1370 # 80025fc8 <itable>
    80003a76:	ffffd097          	auipc	ra,0xffffd
    80003a7a:	200080e7          	jalr	512(ra) # 80000c76 <release>
      return ip;
    80003a7e:	8926                	mv	s2,s1
    80003a80:	a03d                	j	80003aae <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a82:	f7f9                	bnez	a5,80003a50 <iget+0x3c>
    80003a84:	8926                	mv	s2,s1
    80003a86:	b7e9                	j	80003a50 <iget+0x3c>
  if(empty == 0)
    80003a88:	02090c63          	beqz	s2,80003ac0 <iget+0xac>
  ip->dev = dev;
    80003a8c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a90:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a94:	4785                	li	a5,1
    80003a96:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a9a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a9e:	00022517          	auipc	a0,0x22
    80003aa2:	52a50513          	addi	a0,a0,1322 # 80025fc8 <itable>
    80003aa6:	ffffd097          	auipc	ra,0xffffd
    80003aaa:	1d0080e7          	jalr	464(ra) # 80000c76 <release>
}
    80003aae:	854a                	mv	a0,s2
    80003ab0:	70a2                	ld	ra,40(sp)
    80003ab2:	7402                	ld	s0,32(sp)
    80003ab4:	64e2                	ld	s1,24(sp)
    80003ab6:	6942                	ld	s2,16(sp)
    80003ab8:	69a2                	ld	s3,8(sp)
    80003aba:	6a02                	ld	s4,0(sp)
    80003abc:	6145                	addi	sp,sp,48
    80003abe:	8082                	ret
    panic("iget: no inodes");
    80003ac0:	00005517          	auipc	a0,0x5
    80003ac4:	b2850513          	addi	a0,a0,-1240 # 800085e8 <syscalls+0x148>
    80003ac8:	ffffd097          	auipc	ra,0xffffd
    80003acc:	a62080e7          	jalr	-1438(ra) # 8000052a <panic>

0000000080003ad0 <fsinit>:
fsinit(int dev) {
    80003ad0:	7179                	addi	sp,sp,-48
    80003ad2:	f406                	sd	ra,40(sp)
    80003ad4:	f022                	sd	s0,32(sp)
    80003ad6:	ec26                	sd	s1,24(sp)
    80003ad8:	e84a                	sd	s2,16(sp)
    80003ada:	e44e                	sd	s3,8(sp)
    80003adc:	1800                	addi	s0,sp,48
    80003ade:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003ae0:	4585                	li	a1,1
    80003ae2:	00000097          	auipc	ra,0x0
    80003ae6:	a62080e7          	jalr	-1438(ra) # 80003544 <bread>
    80003aea:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003aec:	00022997          	auipc	s3,0x22
    80003af0:	4bc98993          	addi	s3,s3,1212 # 80025fa8 <sb>
    80003af4:	02000613          	li	a2,32
    80003af8:	05850593          	addi	a1,a0,88
    80003afc:	854e                	mv	a0,s3
    80003afe:	ffffd097          	auipc	ra,0xffffd
    80003b02:	21c080e7          	jalr	540(ra) # 80000d1a <memmove>
  brelse(bp);
    80003b06:	8526                	mv	a0,s1
    80003b08:	00000097          	auipc	ra,0x0
    80003b0c:	b6c080e7          	jalr	-1172(ra) # 80003674 <brelse>
  if(sb.magic != FSMAGIC)
    80003b10:	0009a703          	lw	a4,0(s3)
    80003b14:	102037b7          	lui	a5,0x10203
    80003b18:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b1c:	02f71263          	bne	a4,a5,80003b40 <fsinit+0x70>
  initlog(dev, &sb);
    80003b20:	00022597          	auipc	a1,0x22
    80003b24:	48858593          	addi	a1,a1,1160 # 80025fa8 <sb>
    80003b28:	854a                	mv	a0,s2
    80003b2a:	00001097          	auipc	ra,0x1
    80003b2e:	b4e080e7          	jalr	-1202(ra) # 80004678 <initlog>
}
    80003b32:	70a2                	ld	ra,40(sp)
    80003b34:	7402                	ld	s0,32(sp)
    80003b36:	64e2                	ld	s1,24(sp)
    80003b38:	6942                	ld	s2,16(sp)
    80003b3a:	69a2                	ld	s3,8(sp)
    80003b3c:	6145                	addi	sp,sp,48
    80003b3e:	8082                	ret
    panic("invalid file system");
    80003b40:	00005517          	auipc	a0,0x5
    80003b44:	ab850513          	addi	a0,a0,-1352 # 800085f8 <syscalls+0x158>
    80003b48:	ffffd097          	auipc	ra,0xffffd
    80003b4c:	9e2080e7          	jalr	-1566(ra) # 8000052a <panic>

0000000080003b50 <iinit>:
{
    80003b50:	7179                	addi	sp,sp,-48
    80003b52:	f406                	sd	ra,40(sp)
    80003b54:	f022                	sd	s0,32(sp)
    80003b56:	ec26                	sd	s1,24(sp)
    80003b58:	e84a                	sd	s2,16(sp)
    80003b5a:	e44e                	sd	s3,8(sp)
    80003b5c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b5e:	00005597          	auipc	a1,0x5
    80003b62:	ab258593          	addi	a1,a1,-1358 # 80008610 <syscalls+0x170>
    80003b66:	00022517          	auipc	a0,0x22
    80003b6a:	46250513          	addi	a0,a0,1122 # 80025fc8 <itable>
    80003b6e:	ffffd097          	auipc	ra,0xffffd
    80003b72:	fc4080e7          	jalr	-60(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b76:	00022497          	auipc	s1,0x22
    80003b7a:	47a48493          	addi	s1,s1,1146 # 80025ff0 <itable+0x28>
    80003b7e:	00024997          	auipc	s3,0x24
    80003b82:	f0298993          	addi	s3,s3,-254 # 80027a80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b86:	00005917          	auipc	s2,0x5
    80003b8a:	a9290913          	addi	s2,s2,-1390 # 80008618 <syscalls+0x178>
    80003b8e:	85ca                	mv	a1,s2
    80003b90:	8526                	mv	a0,s1
    80003b92:	00001097          	auipc	ra,0x1
    80003b96:	e4a080e7          	jalr	-438(ra) # 800049dc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b9a:	08848493          	addi	s1,s1,136
    80003b9e:	ff3498e3          	bne	s1,s3,80003b8e <iinit+0x3e>
}
    80003ba2:	70a2                	ld	ra,40(sp)
    80003ba4:	7402                	ld	s0,32(sp)
    80003ba6:	64e2                	ld	s1,24(sp)
    80003ba8:	6942                	ld	s2,16(sp)
    80003baa:	69a2                	ld	s3,8(sp)
    80003bac:	6145                	addi	sp,sp,48
    80003bae:	8082                	ret

0000000080003bb0 <ialloc>:
{
    80003bb0:	715d                	addi	sp,sp,-80
    80003bb2:	e486                	sd	ra,72(sp)
    80003bb4:	e0a2                	sd	s0,64(sp)
    80003bb6:	fc26                	sd	s1,56(sp)
    80003bb8:	f84a                	sd	s2,48(sp)
    80003bba:	f44e                	sd	s3,40(sp)
    80003bbc:	f052                	sd	s4,32(sp)
    80003bbe:	ec56                	sd	s5,24(sp)
    80003bc0:	e85a                	sd	s6,16(sp)
    80003bc2:	e45e                	sd	s7,8(sp)
    80003bc4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003bc6:	00022717          	auipc	a4,0x22
    80003bca:	3ee72703          	lw	a4,1006(a4) # 80025fb4 <sb+0xc>
    80003bce:	4785                	li	a5,1
    80003bd0:	04e7fa63          	bgeu	a5,a4,80003c24 <ialloc+0x74>
    80003bd4:	8aaa                	mv	s5,a0
    80003bd6:	8bae                	mv	s7,a1
    80003bd8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003bda:	00022a17          	auipc	s4,0x22
    80003bde:	3cea0a13          	addi	s4,s4,974 # 80025fa8 <sb>
    80003be2:	00048b1b          	sext.w	s6,s1
    80003be6:	0044d793          	srli	a5,s1,0x4
    80003bea:	018a2583          	lw	a1,24(s4)
    80003bee:	9dbd                	addw	a1,a1,a5
    80003bf0:	8556                	mv	a0,s5
    80003bf2:	00000097          	auipc	ra,0x0
    80003bf6:	952080e7          	jalr	-1710(ra) # 80003544 <bread>
    80003bfa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003bfc:	05850993          	addi	s3,a0,88
    80003c00:	00f4f793          	andi	a5,s1,15
    80003c04:	079a                	slli	a5,a5,0x6
    80003c06:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c08:	00099783          	lh	a5,0(s3)
    80003c0c:	c785                	beqz	a5,80003c34 <ialloc+0x84>
    brelse(bp);
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	a66080e7          	jalr	-1434(ra) # 80003674 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c16:	0485                	addi	s1,s1,1
    80003c18:	00ca2703          	lw	a4,12(s4)
    80003c1c:	0004879b          	sext.w	a5,s1
    80003c20:	fce7e1e3          	bltu	a5,a4,80003be2 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003c24:	00005517          	auipc	a0,0x5
    80003c28:	9fc50513          	addi	a0,a0,-1540 # 80008620 <syscalls+0x180>
    80003c2c:	ffffd097          	auipc	ra,0xffffd
    80003c30:	8fe080e7          	jalr	-1794(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003c34:	04000613          	li	a2,64
    80003c38:	4581                	li	a1,0
    80003c3a:	854e                	mv	a0,s3
    80003c3c:	ffffd097          	auipc	ra,0xffffd
    80003c40:	082080e7          	jalr	130(ra) # 80000cbe <memset>
      dip->type = type;
    80003c44:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c48:	854a                	mv	a0,s2
    80003c4a:	00001097          	auipc	ra,0x1
    80003c4e:	cac080e7          	jalr	-852(ra) # 800048f6 <log_write>
      brelse(bp);
    80003c52:	854a                	mv	a0,s2
    80003c54:	00000097          	auipc	ra,0x0
    80003c58:	a20080e7          	jalr	-1504(ra) # 80003674 <brelse>
      return iget(dev, inum);
    80003c5c:	85da                	mv	a1,s6
    80003c5e:	8556                	mv	a0,s5
    80003c60:	00000097          	auipc	ra,0x0
    80003c64:	db4080e7          	jalr	-588(ra) # 80003a14 <iget>
}
    80003c68:	60a6                	ld	ra,72(sp)
    80003c6a:	6406                	ld	s0,64(sp)
    80003c6c:	74e2                	ld	s1,56(sp)
    80003c6e:	7942                	ld	s2,48(sp)
    80003c70:	79a2                	ld	s3,40(sp)
    80003c72:	7a02                	ld	s4,32(sp)
    80003c74:	6ae2                	ld	s5,24(sp)
    80003c76:	6b42                	ld	s6,16(sp)
    80003c78:	6ba2                	ld	s7,8(sp)
    80003c7a:	6161                	addi	sp,sp,80
    80003c7c:	8082                	ret

0000000080003c7e <iupdate>:
{
    80003c7e:	1101                	addi	sp,sp,-32
    80003c80:	ec06                	sd	ra,24(sp)
    80003c82:	e822                	sd	s0,16(sp)
    80003c84:	e426                	sd	s1,8(sp)
    80003c86:	e04a                	sd	s2,0(sp)
    80003c88:	1000                	addi	s0,sp,32
    80003c8a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c8c:	415c                	lw	a5,4(a0)
    80003c8e:	0047d79b          	srliw	a5,a5,0x4
    80003c92:	00022597          	auipc	a1,0x22
    80003c96:	32e5a583          	lw	a1,814(a1) # 80025fc0 <sb+0x18>
    80003c9a:	9dbd                	addw	a1,a1,a5
    80003c9c:	4108                	lw	a0,0(a0)
    80003c9e:	00000097          	auipc	ra,0x0
    80003ca2:	8a6080e7          	jalr	-1882(ra) # 80003544 <bread>
    80003ca6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ca8:	05850793          	addi	a5,a0,88
    80003cac:	40c8                	lw	a0,4(s1)
    80003cae:	893d                	andi	a0,a0,15
    80003cb0:	051a                	slli	a0,a0,0x6
    80003cb2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003cb4:	04449703          	lh	a4,68(s1)
    80003cb8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003cbc:	04649703          	lh	a4,70(s1)
    80003cc0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003cc4:	04849703          	lh	a4,72(s1)
    80003cc8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003ccc:	04a49703          	lh	a4,74(s1)
    80003cd0:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003cd4:	44f8                	lw	a4,76(s1)
    80003cd6:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003cd8:	03400613          	li	a2,52
    80003cdc:	05048593          	addi	a1,s1,80
    80003ce0:	0531                	addi	a0,a0,12
    80003ce2:	ffffd097          	auipc	ra,0xffffd
    80003ce6:	038080e7          	jalr	56(ra) # 80000d1a <memmove>
  log_write(bp);
    80003cea:	854a                	mv	a0,s2
    80003cec:	00001097          	auipc	ra,0x1
    80003cf0:	c0a080e7          	jalr	-1014(ra) # 800048f6 <log_write>
  brelse(bp);
    80003cf4:	854a                	mv	a0,s2
    80003cf6:	00000097          	auipc	ra,0x0
    80003cfa:	97e080e7          	jalr	-1666(ra) # 80003674 <brelse>
}
    80003cfe:	60e2                	ld	ra,24(sp)
    80003d00:	6442                	ld	s0,16(sp)
    80003d02:	64a2                	ld	s1,8(sp)
    80003d04:	6902                	ld	s2,0(sp)
    80003d06:	6105                	addi	sp,sp,32
    80003d08:	8082                	ret

0000000080003d0a <idup>:
{
    80003d0a:	1101                	addi	sp,sp,-32
    80003d0c:	ec06                	sd	ra,24(sp)
    80003d0e:	e822                	sd	s0,16(sp)
    80003d10:	e426                	sd	s1,8(sp)
    80003d12:	1000                	addi	s0,sp,32
    80003d14:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d16:	00022517          	auipc	a0,0x22
    80003d1a:	2b250513          	addi	a0,a0,690 # 80025fc8 <itable>
    80003d1e:	ffffd097          	auipc	ra,0xffffd
    80003d22:	ea4080e7          	jalr	-348(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003d26:	449c                	lw	a5,8(s1)
    80003d28:	2785                	addiw	a5,a5,1
    80003d2a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d2c:	00022517          	auipc	a0,0x22
    80003d30:	29c50513          	addi	a0,a0,668 # 80025fc8 <itable>
    80003d34:	ffffd097          	auipc	ra,0xffffd
    80003d38:	f42080e7          	jalr	-190(ra) # 80000c76 <release>
}
    80003d3c:	8526                	mv	a0,s1
    80003d3e:	60e2                	ld	ra,24(sp)
    80003d40:	6442                	ld	s0,16(sp)
    80003d42:	64a2                	ld	s1,8(sp)
    80003d44:	6105                	addi	sp,sp,32
    80003d46:	8082                	ret

0000000080003d48 <ilock>:
{
    80003d48:	1101                	addi	sp,sp,-32
    80003d4a:	ec06                	sd	ra,24(sp)
    80003d4c:	e822                	sd	s0,16(sp)
    80003d4e:	e426                	sd	s1,8(sp)
    80003d50:	e04a                	sd	s2,0(sp)
    80003d52:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d54:	c115                	beqz	a0,80003d78 <ilock+0x30>
    80003d56:	84aa                	mv	s1,a0
    80003d58:	451c                	lw	a5,8(a0)
    80003d5a:	00f05f63          	blez	a5,80003d78 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d5e:	0541                	addi	a0,a0,16
    80003d60:	00001097          	auipc	ra,0x1
    80003d64:	cb6080e7          	jalr	-842(ra) # 80004a16 <acquiresleep>
  if(ip->valid == 0){
    80003d68:	40bc                	lw	a5,64(s1)
    80003d6a:	cf99                	beqz	a5,80003d88 <ilock+0x40>
}
    80003d6c:	60e2                	ld	ra,24(sp)
    80003d6e:	6442                	ld	s0,16(sp)
    80003d70:	64a2                	ld	s1,8(sp)
    80003d72:	6902                	ld	s2,0(sp)
    80003d74:	6105                	addi	sp,sp,32
    80003d76:	8082                	ret
    panic("ilock");
    80003d78:	00005517          	auipc	a0,0x5
    80003d7c:	8c050513          	addi	a0,a0,-1856 # 80008638 <syscalls+0x198>
    80003d80:	ffffc097          	auipc	ra,0xffffc
    80003d84:	7aa080e7          	jalr	1962(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d88:	40dc                	lw	a5,4(s1)
    80003d8a:	0047d79b          	srliw	a5,a5,0x4
    80003d8e:	00022597          	auipc	a1,0x22
    80003d92:	2325a583          	lw	a1,562(a1) # 80025fc0 <sb+0x18>
    80003d96:	9dbd                	addw	a1,a1,a5
    80003d98:	4088                	lw	a0,0(s1)
    80003d9a:	fffff097          	auipc	ra,0xfffff
    80003d9e:	7aa080e7          	jalr	1962(ra) # 80003544 <bread>
    80003da2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003da4:	05850593          	addi	a1,a0,88
    80003da8:	40dc                	lw	a5,4(s1)
    80003daa:	8bbd                	andi	a5,a5,15
    80003dac:	079a                	slli	a5,a5,0x6
    80003dae:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003db0:	00059783          	lh	a5,0(a1)
    80003db4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003db8:	00259783          	lh	a5,2(a1)
    80003dbc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003dc0:	00459783          	lh	a5,4(a1)
    80003dc4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003dc8:	00659783          	lh	a5,6(a1)
    80003dcc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003dd0:	459c                	lw	a5,8(a1)
    80003dd2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003dd4:	03400613          	li	a2,52
    80003dd8:	05b1                	addi	a1,a1,12
    80003dda:	05048513          	addi	a0,s1,80
    80003dde:	ffffd097          	auipc	ra,0xffffd
    80003de2:	f3c080e7          	jalr	-196(ra) # 80000d1a <memmove>
    brelse(bp);
    80003de6:	854a                	mv	a0,s2
    80003de8:	00000097          	auipc	ra,0x0
    80003dec:	88c080e7          	jalr	-1908(ra) # 80003674 <brelse>
    ip->valid = 1;
    80003df0:	4785                	li	a5,1
    80003df2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003df4:	04449783          	lh	a5,68(s1)
    80003df8:	fbb5                	bnez	a5,80003d6c <ilock+0x24>
      panic("ilock: no type");
    80003dfa:	00005517          	auipc	a0,0x5
    80003dfe:	84650513          	addi	a0,a0,-1978 # 80008640 <syscalls+0x1a0>
    80003e02:	ffffc097          	auipc	ra,0xffffc
    80003e06:	728080e7          	jalr	1832(ra) # 8000052a <panic>

0000000080003e0a <iunlock>:
{
    80003e0a:	1101                	addi	sp,sp,-32
    80003e0c:	ec06                	sd	ra,24(sp)
    80003e0e:	e822                	sd	s0,16(sp)
    80003e10:	e426                	sd	s1,8(sp)
    80003e12:	e04a                	sd	s2,0(sp)
    80003e14:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e16:	c905                	beqz	a0,80003e46 <iunlock+0x3c>
    80003e18:	84aa                	mv	s1,a0
    80003e1a:	01050913          	addi	s2,a0,16
    80003e1e:	854a                	mv	a0,s2
    80003e20:	00001097          	auipc	ra,0x1
    80003e24:	c90080e7          	jalr	-880(ra) # 80004ab0 <holdingsleep>
    80003e28:	cd19                	beqz	a0,80003e46 <iunlock+0x3c>
    80003e2a:	449c                	lw	a5,8(s1)
    80003e2c:	00f05d63          	blez	a5,80003e46 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003e30:	854a                	mv	a0,s2
    80003e32:	00001097          	auipc	ra,0x1
    80003e36:	c3a080e7          	jalr	-966(ra) # 80004a6c <releasesleep>
}
    80003e3a:	60e2                	ld	ra,24(sp)
    80003e3c:	6442                	ld	s0,16(sp)
    80003e3e:	64a2                	ld	s1,8(sp)
    80003e40:	6902                	ld	s2,0(sp)
    80003e42:	6105                	addi	sp,sp,32
    80003e44:	8082                	ret
    panic("iunlock");
    80003e46:	00005517          	auipc	a0,0x5
    80003e4a:	80a50513          	addi	a0,a0,-2038 # 80008650 <syscalls+0x1b0>
    80003e4e:	ffffc097          	auipc	ra,0xffffc
    80003e52:	6dc080e7          	jalr	1756(ra) # 8000052a <panic>

0000000080003e56 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e56:	7179                	addi	sp,sp,-48
    80003e58:	f406                	sd	ra,40(sp)
    80003e5a:	f022                	sd	s0,32(sp)
    80003e5c:	ec26                	sd	s1,24(sp)
    80003e5e:	e84a                	sd	s2,16(sp)
    80003e60:	e44e                	sd	s3,8(sp)
    80003e62:	e052                	sd	s4,0(sp)
    80003e64:	1800                	addi	s0,sp,48
    80003e66:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e68:	05050493          	addi	s1,a0,80
    80003e6c:	08050913          	addi	s2,a0,128
    80003e70:	a021                	j	80003e78 <itrunc+0x22>
    80003e72:	0491                	addi	s1,s1,4
    80003e74:	01248d63          	beq	s1,s2,80003e8e <itrunc+0x38>
    if(ip->addrs[i]){
    80003e78:	408c                	lw	a1,0(s1)
    80003e7a:	dde5                	beqz	a1,80003e72 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e7c:	0009a503          	lw	a0,0(s3)
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	90a080e7          	jalr	-1782(ra) # 8000378a <bfree>
      ip->addrs[i] = 0;
    80003e88:	0004a023          	sw	zero,0(s1)
    80003e8c:	b7dd                	j	80003e72 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e8e:	0809a583          	lw	a1,128(s3)
    80003e92:	e185                	bnez	a1,80003eb2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e94:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e98:	854e                	mv	a0,s3
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	de4080e7          	jalr	-540(ra) # 80003c7e <iupdate>
}
    80003ea2:	70a2                	ld	ra,40(sp)
    80003ea4:	7402                	ld	s0,32(sp)
    80003ea6:	64e2                	ld	s1,24(sp)
    80003ea8:	6942                	ld	s2,16(sp)
    80003eaa:	69a2                	ld	s3,8(sp)
    80003eac:	6a02                	ld	s4,0(sp)
    80003eae:	6145                	addi	sp,sp,48
    80003eb0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003eb2:	0009a503          	lw	a0,0(s3)
    80003eb6:	fffff097          	auipc	ra,0xfffff
    80003eba:	68e080e7          	jalr	1678(ra) # 80003544 <bread>
    80003ebe:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ec0:	05850493          	addi	s1,a0,88
    80003ec4:	45850913          	addi	s2,a0,1112
    80003ec8:	a021                	j	80003ed0 <itrunc+0x7a>
    80003eca:	0491                	addi	s1,s1,4
    80003ecc:	01248b63          	beq	s1,s2,80003ee2 <itrunc+0x8c>
      if(a[j])
    80003ed0:	408c                	lw	a1,0(s1)
    80003ed2:	dde5                	beqz	a1,80003eca <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003ed4:	0009a503          	lw	a0,0(s3)
    80003ed8:	00000097          	auipc	ra,0x0
    80003edc:	8b2080e7          	jalr	-1870(ra) # 8000378a <bfree>
    80003ee0:	b7ed                	j	80003eca <itrunc+0x74>
    brelse(bp);
    80003ee2:	8552                	mv	a0,s4
    80003ee4:	fffff097          	auipc	ra,0xfffff
    80003ee8:	790080e7          	jalr	1936(ra) # 80003674 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003eec:	0809a583          	lw	a1,128(s3)
    80003ef0:	0009a503          	lw	a0,0(s3)
    80003ef4:	00000097          	auipc	ra,0x0
    80003ef8:	896080e7          	jalr	-1898(ra) # 8000378a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003efc:	0809a023          	sw	zero,128(s3)
    80003f00:	bf51                	j	80003e94 <itrunc+0x3e>

0000000080003f02 <iput>:
{
    80003f02:	1101                	addi	sp,sp,-32
    80003f04:	ec06                	sd	ra,24(sp)
    80003f06:	e822                	sd	s0,16(sp)
    80003f08:	e426                	sd	s1,8(sp)
    80003f0a:	e04a                	sd	s2,0(sp)
    80003f0c:	1000                	addi	s0,sp,32
    80003f0e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f10:	00022517          	auipc	a0,0x22
    80003f14:	0b850513          	addi	a0,a0,184 # 80025fc8 <itable>
    80003f18:	ffffd097          	auipc	ra,0xffffd
    80003f1c:	caa080e7          	jalr	-854(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f20:	4498                	lw	a4,8(s1)
    80003f22:	4785                	li	a5,1
    80003f24:	02f70363          	beq	a4,a5,80003f4a <iput+0x48>
  ip->ref--;
    80003f28:	449c                	lw	a5,8(s1)
    80003f2a:	37fd                	addiw	a5,a5,-1
    80003f2c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f2e:	00022517          	auipc	a0,0x22
    80003f32:	09a50513          	addi	a0,a0,154 # 80025fc8 <itable>
    80003f36:	ffffd097          	auipc	ra,0xffffd
    80003f3a:	d40080e7          	jalr	-704(ra) # 80000c76 <release>
}
    80003f3e:	60e2                	ld	ra,24(sp)
    80003f40:	6442                	ld	s0,16(sp)
    80003f42:	64a2                	ld	s1,8(sp)
    80003f44:	6902                	ld	s2,0(sp)
    80003f46:	6105                	addi	sp,sp,32
    80003f48:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f4a:	40bc                	lw	a5,64(s1)
    80003f4c:	dff1                	beqz	a5,80003f28 <iput+0x26>
    80003f4e:	04a49783          	lh	a5,74(s1)
    80003f52:	fbf9                	bnez	a5,80003f28 <iput+0x26>
    acquiresleep(&ip->lock);
    80003f54:	01048913          	addi	s2,s1,16
    80003f58:	854a                	mv	a0,s2
    80003f5a:	00001097          	auipc	ra,0x1
    80003f5e:	abc080e7          	jalr	-1348(ra) # 80004a16 <acquiresleep>
    release(&itable.lock);
    80003f62:	00022517          	auipc	a0,0x22
    80003f66:	06650513          	addi	a0,a0,102 # 80025fc8 <itable>
    80003f6a:	ffffd097          	auipc	ra,0xffffd
    80003f6e:	d0c080e7          	jalr	-756(ra) # 80000c76 <release>
    itrunc(ip);
    80003f72:	8526                	mv	a0,s1
    80003f74:	00000097          	auipc	ra,0x0
    80003f78:	ee2080e7          	jalr	-286(ra) # 80003e56 <itrunc>
    ip->type = 0;
    80003f7c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f80:	8526                	mv	a0,s1
    80003f82:	00000097          	auipc	ra,0x0
    80003f86:	cfc080e7          	jalr	-772(ra) # 80003c7e <iupdate>
    ip->valid = 0;
    80003f8a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f8e:	854a                	mv	a0,s2
    80003f90:	00001097          	auipc	ra,0x1
    80003f94:	adc080e7          	jalr	-1316(ra) # 80004a6c <releasesleep>
    acquire(&itable.lock);
    80003f98:	00022517          	auipc	a0,0x22
    80003f9c:	03050513          	addi	a0,a0,48 # 80025fc8 <itable>
    80003fa0:	ffffd097          	auipc	ra,0xffffd
    80003fa4:	c22080e7          	jalr	-990(ra) # 80000bc2 <acquire>
    80003fa8:	b741                	j	80003f28 <iput+0x26>

0000000080003faa <iunlockput>:
{
    80003faa:	1101                	addi	sp,sp,-32
    80003fac:	ec06                	sd	ra,24(sp)
    80003fae:	e822                	sd	s0,16(sp)
    80003fb0:	e426                	sd	s1,8(sp)
    80003fb2:	1000                	addi	s0,sp,32
    80003fb4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003fb6:	00000097          	auipc	ra,0x0
    80003fba:	e54080e7          	jalr	-428(ra) # 80003e0a <iunlock>
  iput(ip);
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	00000097          	auipc	ra,0x0
    80003fc4:	f42080e7          	jalr	-190(ra) # 80003f02 <iput>
}
    80003fc8:	60e2                	ld	ra,24(sp)
    80003fca:	6442                	ld	s0,16(sp)
    80003fcc:	64a2                	ld	s1,8(sp)
    80003fce:	6105                	addi	sp,sp,32
    80003fd0:	8082                	ret

0000000080003fd2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003fd2:	1141                	addi	sp,sp,-16
    80003fd4:	e422                	sd	s0,8(sp)
    80003fd6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003fd8:	411c                	lw	a5,0(a0)
    80003fda:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003fdc:	415c                	lw	a5,4(a0)
    80003fde:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003fe0:	04451783          	lh	a5,68(a0)
    80003fe4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003fe8:	04a51783          	lh	a5,74(a0)
    80003fec:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ff0:	04c56783          	lwu	a5,76(a0)
    80003ff4:	e99c                	sd	a5,16(a1)
}
    80003ff6:	6422                	ld	s0,8(sp)
    80003ff8:	0141                	addi	sp,sp,16
    80003ffa:	8082                	ret

0000000080003ffc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ffc:	457c                	lw	a5,76(a0)
    80003ffe:	0ed7e963          	bltu	a5,a3,800040f0 <readi+0xf4>
{
    80004002:	7159                	addi	sp,sp,-112
    80004004:	f486                	sd	ra,104(sp)
    80004006:	f0a2                	sd	s0,96(sp)
    80004008:	eca6                	sd	s1,88(sp)
    8000400a:	e8ca                	sd	s2,80(sp)
    8000400c:	e4ce                	sd	s3,72(sp)
    8000400e:	e0d2                	sd	s4,64(sp)
    80004010:	fc56                	sd	s5,56(sp)
    80004012:	f85a                	sd	s6,48(sp)
    80004014:	f45e                	sd	s7,40(sp)
    80004016:	f062                	sd	s8,32(sp)
    80004018:	ec66                	sd	s9,24(sp)
    8000401a:	e86a                	sd	s10,16(sp)
    8000401c:	e46e                	sd	s11,8(sp)
    8000401e:	1880                	addi	s0,sp,112
    80004020:	8baa                	mv	s7,a0
    80004022:	8c2e                	mv	s8,a1
    80004024:	8ab2                	mv	s5,a2
    80004026:	84b6                	mv	s1,a3
    80004028:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000402a:	9f35                	addw	a4,a4,a3
    return 0;
    8000402c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000402e:	0ad76063          	bltu	a4,a3,800040ce <readi+0xd2>
  if(off + n > ip->size)
    80004032:	00e7f463          	bgeu	a5,a4,8000403a <readi+0x3e>
    n = ip->size - off;
    80004036:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000403a:	0a0b0963          	beqz	s6,800040ec <readi+0xf0>
    8000403e:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004040:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004044:	5cfd                	li	s9,-1
    80004046:	a82d                	j	80004080 <readi+0x84>
    80004048:	020a1d93          	slli	s11,s4,0x20
    8000404c:	020ddd93          	srli	s11,s11,0x20
    80004050:	05890793          	addi	a5,s2,88
    80004054:	86ee                	mv	a3,s11
    80004056:	963e                	add	a2,a2,a5
    80004058:	85d6                	mv	a1,s5
    8000405a:	8562                	mv	a0,s8
    8000405c:	ffffe097          	auipc	ra,0xffffe
    80004060:	482080e7          	jalr	1154(ra) # 800024de <either_copyout>
    80004064:	05950d63          	beq	a0,s9,800040be <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004068:	854a                	mv	a0,s2
    8000406a:	fffff097          	auipc	ra,0xfffff
    8000406e:	60a080e7          	jalr	1546(ra) # 80003674 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004072:	013a09bb          	addw	s3,s4,s3
    80004076:	009a04bb          	addw	s1,s4,s1
    8000407a:	9aee                	add	s5,s5,s11
    8000407c:	0569f763          	bgeu	s3,s6,800040ca <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004080:	000ba903          	lw	s2,0(s7)
    80004084:	00a4d59b          	srliw	a1,s1,0xa
    80004088:	855e                	mv	a0,s7
    8000408a:	00000097          	auipc	ra,0x0
    8000408e:	8ae080e7          	jalr	-1874(ra) # 80003938 <bmap>
    80004092:	0005059b          	sext.w	a1,a0
    80004096:	854a                	mv	a0,s2
    80004098:	fffff097          	auipc	ra,0xfffff
    8000409c:	4ac080e7          	jalr	1196(ra) # 80003544 <bread>
    800040a0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040a2:	3ff4f613          	andi	a2,s1,1023
    800040a6:	40cd07bb          	subw	a5,s10,a2
    800040aa:	413b073b          	subw	a4,s6,s3
    800040ae:	8a3e                	mv	s4,a5
    800040b0:	2781                	sext.w	a5,a5
    800040b2:	0007069b          	sext.w	a3,a4
    800040b6:	f8f6f9e3          	bgeu	a3,a5,80004048 <readi+0x4c>
    800040ba:	8a3a                	mv	s4,a4
    800040bc:	b771                	j	80004048 <readi+0x4c>
      brelse(bp);
    800040be:	854a                	mv	a0,s2
    800040c0:	fffff097          	auipc	ra,0xfffff
    800040c4:	5b4080e7          	jalr	1460(ra) # 80003674 <brelse>
      tot = -1;
    800040c8:	59fd                	li	s3,-1
  }
  return tot;
    800040ca:	0009851b          	sext.w	a0,s3
}
    800040ce:	70a6                	ld	ra,104(sp)
    800040d0:	7406                	ld	s0,96(sp)
    800040d2:	64e6                	ld	s1,88(sp)
    800040d4:	6946                	ld	s2,80(sp)
    800040d6:	69a6                	ld	s3,72(sp)
    800040d8:	6a06                	ld	s4,64(sp)
    800040da:	7ae2                	ld	s5,56(sp)
    800040dc:	7b42                	ld	s6,48(sp)
    800040de:	7ba2                	ld	s7,40(sp)
    800040e0:	7c02                	ld	s8,32(sp)
    800040e2:	6ce2                	ld	s9,24(sp)
    800040e4:	6d42                	ld	s10,16(sp)
    800040e6:	6da2                	ld	s11,8(sp)
    800040e8:	6165                	addi	sp,sp,112
    800040ea:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040ec:	89da                	mv	s3,s6
    800040ee:	bff1                	j	800040ca <readi+0xce>
    return 0;
    800040f0:	4501                	li	a0,0
}
    800040f2:	8082                	ret

00000000800040f4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040f4:	457c                	lw	a5,76(a0)
    800040f6:	10d7e863          	bltu	a5,a3,80004206 <writei+0x112>
{
    800040fa:	7159                	addi	sp,sp,-112
    800040fc:	f486                	sd	ra,104(sp)
    800040fe:	f0a2                	sd	s0,96(sp)
    80004100:	eca6                	sd	s1,88(sp)
    80004102:	e8ca                	sd	s2,80(sp)
    80004104:	e4ce                	sd	s3,72(sp)
    80004106:	e0d2                	sd	s4,64(sp)
    80004108:	fc56                	sd	s5,56(sp)
    8000410a:	f85a                	sd	s6,48(sp)
    8000410c:	f45e                	sd	s7,40(sp)
    8000410e:	f062                	sd	s8,32(sp)
    80004110:	ec66                	sd	s9,24(sp)
    80004112:	e86a                	sd	s10,16(sp)
    80004114:	e46e                	sd	s11,8(sp)
    80004116:	1880                	addi	s0,sp,112
    80004118:	8b2a                	mv	s6,a0
    8000411a:	8c2e                	mv	s8,a1
    8000411c:	8ab2                	mv	s5,a2
    8000411e:	8936                	mv	s2,a3
    80004120:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004122:	00e687bb          	addw	a5,a3,a4
    80004126:	0ed7e263          	bltu	a5,a3,8000420a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000412a:	00043737          	lui	a4,0x43
    8000412e:	0ef76063          	bltu	a4,a5,8000420e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004132:	0c0b8863          	beqz	s7,80004202 <writei+0x10e>
    80004136:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004138:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000413c:	5cfd                	li	s9,-1
    8000413e:	a091                	j	80004182 <writei+0x8e>
    80004140:	02099d93          	slli	s11,s3,0x20
    80004144:	020ddd93          	srli	s11,s11,0x20
    80004148:	05848793          	addi	a5,s1,88
    8000414c:	86ee                	mv	a3,s11
    8000414e:	8656                	mv	a2,s5
    80004150:	85e2                	mv	a1,s8
    80004152:	953e                	add	a0,a0,a5
    80004154:	ffffe097          	auipc	ra,0xffffe
    80004158:	3e0080e7          	jalr	992(ra) # 80002534 <either_copyin>
    8000415c:	07950263          	beq	a0,s9,800041c0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004160:	8526                	mv	a0,s1
    80004162:	00000097          	auipc	ra,0x0
    80004166:	794080e7          	jalr	1940(ra) # 800048f6 <log_write>
    brelse(bp);
    8000416a:	8526                	mv	a0,s1
    8000416c:	fffff097          	auipc	ra,0xfffff
    80004170:	508080e7          	jalr	1288(ra) # 80003674 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004174:	01498a3b          	addw	s4,s3,s4
    80004178:	0129893b          	addw	s2,s3,s2
    8000417c:	9aee                	add	s5,s5,s11
    8000417e:	057a7663          	bgeu	s4,s7,800041ca <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004182:	000b2483          	lw	s1,0(s6)
    80004186:	00a9559b          	srliw	a1,s2,0xa
    8000418a:	855a                	mv	a0,s6
    8000418c:	fffff097          	auipc	ra,0xfffff
    80004190:	7ac080e7          	jalr	1964(ra) # 80003938 <bmap>
    80004194:	0005059b          	sext.w	a1,a0
    80004198:	8526                	mv	a0,s1
    8000419a:	fffff097          	auipc	ra,0xfffff
    8000419e:	3aa080e7          	jalr	938(ra) # 80003544 <bread>
    800041a2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041a4:	3ff97513          	andi	a0,s2,1023
    800041a8:	40ad07bb          	subw	a5,s10,a0
    800041ac:	414b873b          	subw	a4,s7,s4
    800041b0:	89be                	mv	s3,a5
    800041b2:	2781                	sext.w	a5,a5
    800041b4:	0007069b          	sext.w	a3,a4
    800041b8:	f8f6f4e3          	bgeu	a3,a5,80004140 <writei+0x4c>
    800041bc:	89ba                	mv	s3,a4
    800041be:	b749                	j	80004140 <writei+0x4c>
      brelse(bp);
    800041c0:	8526                	mv	a0,s1
    800041c2:	fffff097          	auipc	ra,0xfffff
    800041c6:	4b2080e7          	jalr	1202(ra) # 80003674 <brelse>
  }

  if(off > ip->size)
    800041ca:	04cb2783          	lw	a5,76(s6)
    800041ce:	0127f463          	bgeu	a5,s2,800041d6 <writei+0xe2>
    ip->size = off;
    800041d2:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800041d6:	855a                	mv	a0,s6
    800041d8:	00000097          	auipc	ra,0x0
    800041dc:	aa6080e7          	jalr	-1370(ra) # 80003c7e <iupdate>

  return tot;
    800041e0:	000a051b          	sext.w	a0,s4
}
    800041e4:	70a6                	ld	ra,104(sp)
    800041e6:	7406                	ld	s0,96(sp)
    800041e8:	64e6                	ld	s1,88(sp)
    800041ea:	6946                	ld	s2,80(sp)
    800041ec:	69a6                	ld	s3,72(sp)
    800041ee:	6a06                	ld	s4,64(sp)
    800041f0:	7ae2                	ld	s5,56(sp)
    800041f2:	7b42                	ld	s6,48(sp)
    800041f4:	7ba2                	ld	s7,40(sp)
    800041f6:	7c02                	ld	s8,32(sp)
    800041f8:	6ce2                	ld	s9,24(sp)
    800041fa:	6d42                	ld	s10,16(sp)
    800041fc:	6da2                	ld	s11,8(sp)
    800041fe:	6165                	addi	sp,sp,112
    80004200:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004202:	8a5e                	mv	s4,s7
    80004204:	bfc9                	j	800041d6 <writei+0xe2>
    return -1;
    80004206:	557d                	li	a0,-1
}
    80004208:	8082                	ret
    return -1;
    8000420a:	557d                	li	a0,-1
    8000420c:	bfe1                	j	800041e4 <writei+0xf0>
    return -1;
    8000420e:	557d                	li	a0,-1
    80004210:	bfd1                	j	800041e4 <writei+0xf0>

0000000080004212 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004212:	1141                	addi	sp,sp,-16
    80004214:	e406                	sd	ra,8(sp)
    80004216:	e022                	sd	s0,0(sp)
    80004218:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000421a:	4639                	li	a2,14
    8000421c:	ffffd097          	auipc	ra,0xffffd
    80004220:	b7a080e7          	jalr	-1158(ra) # 80000d96 <strncmp>
}
    80004224:	60a2                	ld	ra,8(sp)
    80004226:	6402                	ld	s0,0(sp)
    80004228:	0141                	addi	sp,sp,16
    8000422a:	8082                	ret

000000008000422c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000422c:	7139                	addi	sp,sp,-64
    8000422e:	fc06                	sd	ra,56(sp)
    80004230:	f822                	sd	s0,48(sp)
    80004232:	f426                	sd	s1,40(sp)
    80004234:	f04a                	sd	s2,32(sp)
    80004236:	ec4e                	sd	s3,24(sp)
    80004238:	e852                	sd	s4,16(sp)
    8000423a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000423c:	04451703          	lh	a4,68(a0)
    80004240:	4785                	li	a5,1
    80004242:	00f71a63          	bne	a4,a5,80004256 <dirlookup+0x2a>
    80004246:	892a                	mv	s2,a0
    80004248:	89ae                	mv	s3,a1
    8000424a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000424c:	457c                	lw	a5,76(a0)
    8000424e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004250:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004252:	e79d                	bnez	a5,80004280 <dirlookup+0x54>
    80004254:	a8a5                	j	800042cc <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004256:	00004517          	auipc	a0,0x4
    8000425a:	40250513          	addi	a0,a0,1026 # 80008658 <syscalls+0x1b8>
    8000425e:	ffffc097          	auipc	ra,0xffffc
    80004262:	2cc080e7          	jalr	716(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004266:	00004517          	auipc	a0,0x4
    8000426a:	40a50513          	addi	a0,a0,1034 # 80008670 <syscalls+0x1d0>
    8000426e:	ffffc097          	auipc	ra,0xffffc
    80004272:	2bc080e7          	jalr	700(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004276:	24c1                	addiw	s1,s1,16
    80004278:	04c92783          	lw	a5,76(s2)
    8000427c:	04f4f763          	bgeu	s1,a5,800042ca <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004280:	4741                	li	a4,16
    80004282:	86a6                	mv	a3,s1
    80004284:	fc040613          	addi	a2,s0,-64
    80004288:	4581                	li	a1,0
    8000428a:	854a                	mv	a0,s2
    8000428c:	00000097          	auipc	ra,0x0
    80004290:	d70080e7          	jalr	-656(ra) # 80003ffc <readi>
    80004294:	47c1                	li	a5,16
    80004296:	fcf518e3          	bne	a0,a5,80004266 <dirlookup+0x3a>
    if(de.inum == 0)
    8000429a:	fc045783          	lhu	a5,-64(s0)
    8000429e:	dfe1                	beqz	a5,80004276 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800042a0:	fc240593          	addi	a1,s0,-62
    800042a4:	854e                	mv	a0,s3
    800042a6:	00000097          	auipc	ra,0x0
    800042aa:	f6c080e7          	jalr	-148(ra) # 80004212 <namecmp>
    800042ae:	f561                	bnez	a0,80004276 <dirlookup+0x4a>
      if(poff)
    800042b0:	000a0463          	beqz	s4,800042b8 <dirlookup+0x8c>
        *poff = off;
    800042b4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800042b8:	fc045583          	lhu	a1,-64(s0)
    800042bc:	00092503          	lw	a0,0(s2)
    800042c0:	fffff097          	auipc	ra,0xfffff
    800042c4:	754080e7          	jalr	1876(ra) # 80003a14 <iget>
    800042c8:	a011                	j	800042cc <dirlookup+0xa0>
  return 0;
    800042ca:	4501                	li	a0,0
}
    800042cc:	70e2                	ld	ra,56(sp)
    800042ce:	7442                	ld	s0,48(sp)
    800042d0:	74a2                	ld	s1,40(sp)
    800042d2:	7902                	ld	s2,32(sp)
    800042d4:	69e2                	ld	s3,24(sp)
    800042d6:	6a42                	ld	s4,16(sp)
    800042d8:	6121                	addi	sp,sp,64
    800042da:	8082                	ret

00000000800042dc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800042dc:	711d                	addi	sp,sp,-96
    800042de:	ec86                	sd	ra,88(sp)
    800042e0:	e8a2                	sd	s0,80(sp)
    800042e2:	e4a6                	sd	s1,72(sp)
    800042e4:	e0ca                	sd	s2,64(sp)
    800042e6:	fc4e                	sd	s3,56(sp)
    800042e8:	f852                	sd	s4,48(sp)
    800042ea:	f456                	sd	s5,40(sp)
    800042ec:	f05a                	sd	s6,32(sp)
    800042ee:	ec5e                	sd	s7,24(sp)
    800042f0:	e862                	sd	s8,16(sp)
    800042f2:	e466                	sd	s9,8(sp)
    800042f4:	1080                	addi	s0,sp,96
    800042f6:	84aa                	mv	s1,a0
    800042f8:	8aae                	mv	s5,a1
    800042fa:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800042fc:	00054703          	lbu	a4,0(a0)
    80004300:	02f00793          	li	a5,47
    80004304:	02f70363          	beq	a4,a5,8000432a <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004308:	ffffd097          	auipc	ra,0xffffd
    8000430c:	6ac080e7          	jalr	1708(ra) # 800019b4 <myproc>
    80004310:	15053503          	ld	a0,336(a0)
    80004314:	00000097          	auipc	ra,0x0
    80004318:	9f6080e7          	jalr	-1546(ra) # 80003d0a <idup>
    8000431c:	89aa                	mv	s3,a0
  while(*path == '/')
    8000431e:	02f00913          	li	s2,47
  len = path - s;
    80004322:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004324:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004326:	4b85                	li	s7,1
    80004328:	a865                	j	800043e0 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000432a:	4585                	li	a1,1
    8000432c:	4505                	li	a0,1
    8000432e:	fffff097          	auipc	ra,0xfffff
    80004332:	6e6080e7          	jalr	1766(ra) # 80003a14 <iget>
    80004336:	89aa                	mv	s3,a0
    80004338:	b7dd                	j	8000431e <namex+0x42>
      iunlockput(ip);
    8000433a:	854e                	mv	a0,s3
    8000433c:	00000097          	auipc	ra,0x0
    80004340:	c6e080e7          	jalr	-914(ra) # 80003faa <iunlockput>
      return 0;
    80004344:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004346:	854e                	mv	a0,s3
    80004348:	60e6                	ld	ra,88(sp)
    8000434a:	6446                	ld	s0,80(sp)
    8000434c:	64a6                	ld	s1,72(sp)
    8000434e:	6906                	ld	s2,64(sp)
    80004350:	79e2                	ld	s3,56(sp)
    80004352:	7a42                	ld	s4,48(sp)
    80004354:	7aa2                	ld	s5,40(sp)
    80004356:	7b02                	ld	s6,32(sp)
    80004358:	6be2                	ld	s7,24(sp)
    8000435a:	6c42                	ld	s8,16(sp)
    8000435c:	6ca2                	ld	s9,8(sp)
    8000435e:	6125                	addi	sp,sp,96
    80004360:	8082                	ret
      iunlock(ip);
    80004362:	854e                	mv	a0,s3
    80004364:	00000097          	auipc	ra,0x0
    80004368:	aa6080e7          	jalr	-1370(ra) # 80003e0a <iunlock>
      return ip;
    8000436c:	bfe9                	j	80004346 <namex+0x6a>
      iunlockput(ip);
    8000436e:	854e                	mv	a0,s3
    80004370:	00000097          	auipc	ra,0x0
    80004374:	c3a080e7          	jalr	-966(ra) # 80003faa <iunlockput>
      return 0;
    80004378:	89e6                	mv	s3,s9
    8000437a:	b7f1                	j	80004346 <namex+0x6a>
  len = path - s;
    8000437c:	40b48633          	sub	a2,s1,a1
    80004380:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004384:	099c5463          	bge	s8,s9,8000440c <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004388:	4639                	li	a2,14
    8000438a:	8552                	mv	a0,s4
    8000438c:	ffffd097          	auipc	ra,0xffffd
    80004390:	98e080e7          	jalr	-1650(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004394:	0004c783          	lbu	a5,0(s1)
    80004398:	01279763          	bne	a5,s2,800043a6 <namex+0xca>
    path++;
    8000439c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000439e:	0004c783          	lbu	a5,0(s1)
    800043a2:	ff278de3          	beq	a5,s2,8000439c <namex+0xc0>
    ilock(ip);
    800043a6:	854e                	mv	a0,s3
    800043a8:	00000097          	auipc	ra,0x0
    800043ac:	9a0080e7          	jalr	-1632(ra) # 80003d48 <ilock>
    if(ip->type != T_DIR){
    800043b0:	04499783          	lh	a5,68(s3)
    800043b4:	f97793e3          	bne	a5,s7,8000433a <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800043b8:	000a8563          	beqz	s5,800043c2 <namex+0xe6>
    800043bc:	0004c783          	lbu	a5,0(s1)
    800043c0:	d3cd                	beqz	a5,80004362 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800043c2:	865a                	mv	a2,s6
    800043c4:	85d2                	mv	a1,s4
    800043c6:	854e                	mv	a0,s3
    800043c8:	00000097          	auipc	ra,0x0
    800043cc:	e64080e7          	jalr	-412(ra) # 8000422c <dirlookup>
    800043d0:	8caa                	mv	s9,a0
    800043d2:	dd51                	beqz	a0,8000436e <namex+0x92>
    iunlockput(ip);
    800043d4:	854e                	mv	a0,s3
    800043d6:	00000097          	auipc	ra,0x0
    800043da:	bd4080e7          	jalr	-1068(ra) # 80003faa <iunlockput>
    ip = next;
    800043de:	89e6                	mv	s3,s9
  while(*path == '/')
    800043e0:	0004c783          	lbu	a5,0(s1)
    800043e4:	05279763          	bne	a5,s2,80004432 <namex+0x156>
    path++;
    800043e8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043ea:	0004c783          	lbu	a5,0(s1)
    800043ee:	ff278de3          	beq	a5,s2,800043e8 <namex+0x10c>
  if(*path == 0)
    800043f2:	c79d                	beqz	a5,80004420 <namex+0x144>
    path++;
    800043f4:	85a6                	mv	a1,s1
  len = path - s;
    800043f6:	8cda                	mv	s9,s6
    800043f8:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800043fa:	01278963          	beq	a5,s2,8000440c <namex+0x130>
    800043fe:	dfbd                	beqz	a5,8000437c <namex+0xa0>
    path++;
    80004400:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004402:	0004c783          	lbu	a5,0(s1)
    80004406:	ff279ce3          	bne	a5,s2,800043fe <namex+0x122>
    8000440a:	bf8d                	j	8000437c <namex+0xa0>
    memmove(name, s, len);
    8000440c:	2601                	sext.w	a2,a2
    8000440e:	8552                	mv	a0,s4
    80004410:	ffffd097          	auipc	ra,0xffffd
    80004414:	90a080e7          	jalr	-1782(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004418:	9cd2                	add	s9,s9,s4
    8000441a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000441e:	bf9d                	j	80004394 <namex+0xb8>
  if(nameiparent){
    80004420:	f20a83e3          	beqz	s5,80004346 <namex+0x6a>
    iput(ip);
    80004424:	854e                	mv	a0,s3
    80004426:	00000097          	auipc	ra,0x0
    8000442a:	adc080e7          	jalr	-1316(ra) # 80003f02 <iput>
    return 0;
    8000442e:	4981                	li	s3,0
    80004430:	bf19                	j	80004346 <namex+0x6a>
  if(*path == 0)
    80004432:	d7fd                	beqz	a5,80004420 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004434:	0004c783          	lbu	a5,0(s1)
    80004438:	85a6                	mv	a1,s1
    8000443a:	b7d1                	j	800043fe <namex+0x122>

000000008000443c <dirlink>:
{
    8000443c:	7139                	addi	sp,sp,-64
    8000443e:	fc06                	sd	ra,56(sp)
    80004440:	f822                	sd	s0,48(sp)
    80004442:	f426                	sd	s1,40(sp)
    80004444:	f04a                	sd	s2,32(sp)
    80004446:	ec4e                	sd	s3,24(sp)
    80004448:	e852                	sd	s4,16(sp)
    8000444a:	0080                	addi	s0,sp,64
    8000444c:	892a                	mv	s2,a0
    8000444e:	8a2e                	mv	s4,a1
    80004450:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004452:	4601                	li	a2,0
    80004454:	00000097          	auipc	ra,0x0
    80004458:	dd8080e7          	jalr	-552(ra) # 8000422c <dirlookup>
    8000445c:	e93d                	bnez	a0,800044d2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000445e:	04c92483          	lw	s1,76(s2)
    80004462:	c49d                	beqz	s1,80004490 <dirlink+0x54>
    80004464:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004466:	4741                	li	a4,16
    80004468:	86a6                	mv	a3,s1
    8000446a:	fc040613          	addi	a2,s0,-64
    8000446e:	4581                	li	a1,0
    80004470:	854a                	mv	a0,s2
    80004472:	00000097          	auipc	ra,0x0
    80004476:	b8a080e7          	jalr	-1142(ra) # 80003ffc <readi>
    8000447a:	47c1                	li	a5,16
    8000447c:	06f51163          	bne	a0,a5,800044de <dirlink+0xa2>
    if(de.inum == 0)
    80004480:	fc045783          	lhu	a5,-64(s0)
    80004484:	c791                	beqz	a5,80004490 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004486:	24c1                	addiw	s1,s1,16
    80004488:	04c92783          	lw	a5,76(s2)
    8000448c:	fcf4ede3          	bltu	s1,a5,80004466 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004490:	4639                	li	a2,14
    80004492:	85d2                	mv	a1,s4
    80004494:	fc240513          	addi	a0,s0,-62
    80004498:	ffffd097          	auipc	ra,0xffffd
    8000449c:	93a080e7          	jalr	-1734(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    800044a0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044a4:	4741                	li	a4,16
    800044a6:	86a6                	mv	a3,s1
    800044a8:	fc040613          	addi	a2,s0,-64
    800044ac:	4581                	li	a1,0
    800044ae:	854a                	mv	a0,s2
    800044b0:	00000097          	auipc	ra,0x0
    800044b4:	c44080e7          	jalr	-956(ra) # 800040f4 <writei>
    800044b8:	872a                	mv	a4,a0
    800044ba:	47c1                	li	a5,16
  return 0;
    800044bc:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044be:	02f71863          	bne	a4,a5,800044ee <dirlink+0xb2>
}
    800044c2:	70e2                	ld	ra,56(sp)
    800044c4:	7442                	ld	s0,48(sp)
    800044c6:	74a2                	ld	s1,40(sp)
    800044c8:	7902                	ld	s2,32(sp)
    800044ca:	69e2                	ld	s3,24(sp)
    800044cc:	6a42                	ld	s4,16(sp)
    800044ce:	6121                	addi	sp,sp,64
    800044d0:	8082                	ret
    iput(ip);
    800044d2:	00000097          	auipc	ra,0x0
    800044d6:	a30080e7          	jalr	-1488(ra) # 80003f02 <iput>
    return -1;
    800044da:	557d                	li	a0,-1
    800044dc:	b7dd                	j	800044c2 <dirlink+0x86>
      panic("dirlink read");
    800044de:	00004517          	auipc	a0,0x4
    800044e2:	1a250513          	addi	a0,a0,418 # 80008680 <syscalls+0x1e0>
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	044080e7          	jalr	68(ra) # 8000052a <panic>
    panic("dirlink");
    800044ee:	00004517          	auipc	a0,0x4
    800044f2:	2a250513          	addi	a0,a0,674 # 80008790 <syscalls+0x2f0>
    800044f6:	ffffc097          	auipc	ra,0xffffc
    800044fa:	034080e7          	jalr	52(ra) # 8000052a <panic>

00000000800044fe <namei>:

struct inode*
namei(char *path)
{
    800044fe:	1101                	addi	sp,sp,-32
    80004500:	ec06                	sd	ra,24(sp)
    80004502:	e822                	sd	s0,16(sp)
    80004504:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004506:	fe040613          	addi	a2,s0,-32
    8000450a:	4581                	li	a1,0
    8000450c:	00000097          	auipc	ra,0x0
    80004510:	dd0080e7          	jalr	-560(ra) # 800042dc <namex>
}
    80004514:	60e2                	ld	ra,24(sp)
    80004516:	6442                	ld	s0,16(sp)
    80004518:	6105                	addi	sp,sp,32
    8000451a:	8082                	ret

000000008000451c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000451c:	1141                	addi	sp,sp,-16
    8000451e:	e406                	sd	ra,8(sp)
    80004520:	e022                	sd	s0,0(sp)
    80004522:	0800                	addi	s0,sp,16
    80004524:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004526:	4585                	li	a1,1
    80004528:	00000097          	auipc	ra,0x0
    8000452c:	db4080e7          	jalr	-588(ra) # 800042dc <namex>
}
    80004530:	60a2                	ld	ra,8(sp)
    80004532:	6402                	ld	s0,0(sp)
    80004534:	0141                	addi	sp,sp,16
    80004536:	8082                	ret

0000000080004538 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004538:	1101                	addi	sp,sp,-32
    8000453a:	ec06                	sd	ra,24(sp)
    8000453c:	e822                	sd	s0,16(sp)
    8000453e:	e426                	sd	s1,8(sp)
    80004540:	e04a                	sd	s2,0(sp)
    80004542:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004544:	00023917          	auipc	s2,0x23
    80004548:	52c90913          	addi	s2,s2,1324 # 80027a70 <log>
    8000454c:	01892583          	lw	a1,24(s2)
    80004550:	02892503          	lw	a0,40(s2)
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	ff0080e7          	jalr	-16(ra) # 80003544 <bread>
    8000455c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000455e:	02c92683          	lw	a3,44(s2)
    80004562:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004564:	02d05863          	blez	a3,80004594 <write_head+0x5c>
    80004568:	00023797          	auipc	a5,0x23
    8000456c:	53878793          	addi	a5,a5,1336 # 80027aa0 <log+0x30>
    80004570:	05c50713          	addi	a4,a0,92
    80004574:	36fd                	addiw	a3,a3,-1
    80004576:	02069613          	slli	a2,a3,0x20
    8000457a:	01e65693          	srli	a3,a2,0x1e
    8000457e:	00023617          	auipc	a2,0x23
    80004582:	52660613          	addi	a2,a2,1318 # 80027aa4 <log+0x34>
    80004586:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004588:	4390                	lw	a2,0(a5)
    8000458a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000458c:	0791                	addi	a5,a5,4
    8000458e:	0711                	addi	a4,a4,4
    80004590:	fed79ce3          	bne	a5,a3,80004588 <write_head+0x50>
  }
  bwrite(buf);
    80004594:	8526                	mv	a0,s1
    80004596:	fffff097          	auipc	ra,0xfffff
    8000459a:	0a0080e7          	jalr	160(ra) # 80003636 <bwrite>
  brelse(buf);
    8000459e:	8526                	mv	a0,s1
    800045a0:	fffff097          	auipc	ra,0xfffff
    800045a4:	0d4080e7          	jalr	212(ra) # 80003674 <brelse>
}
    800045a8:	60e2                	ld	ra,24(sp)
    800045aa:	6442                	ld	s0,16(sp)
    800045ac:	64a2                	ld	s1,8(sp)
    800045ae:	6902                	ld	s2,0(sp)
    800045b0:	6105                	addi	sp,sp,32
    800045b2:	8082                	ret

00000000800045b4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800045b4:	00023797          	auipc	a5,0x23
    800045b8:	4e87a783          	lw	a5,1256(a5) # 80027a9c <log+0x2c>
    800045bc:	0af05d63          	blez	a5,80004676 <install_trans+0xc2>
{
    800045c0:	7139                	addi	sp,sp,-64
    800045c2:	fc06                	sd	ra,56(sp)
    800045c4:	f822                	sd	s0,48(sp)
    800045c6:	f426                	sd	s1,40(sp)
    800045c8:	f04a                	sd	s2,32(sp)
    800045ca:	ec4e                	sd	s3,24(sp)
    800045cc:	e852                	sd	s4,16(sp)
    800045ce:	e456                	sd	s5,8(sp)
    800045d0:	e05a                	sd	s6,0(sp)
    800045d2:	0080                	addi	s0,sp,64
    800045d4:	8b2a                	mv	s6,a0
    800045d6:	00023a97          	auipc	s5,0x23
    800045da:	4caa8a93          	addi	s5,s5,1226 # 80027aa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045de:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045e0:	00023997          	auipc	s3,0x23
    800045e4:	49098993          	addi	s3,s3,1168 # 80027a70 <log>
    800045e8:	a00d                	j	8000460a <install_trans+0x56>
    brelse(lbuf);
    800045ea:	854a                	mv	a0,s2
    800045ec:	fffff097          	auipc	ra,0xfffff
    800045f0:	088080e7          	jalr	136(ra) # 80003674 <brelse>
    brelse(dbuf);
    800045f4:	8526                	mv	a0,s1
    800045f6:	fffff097          	auipc	ra,0xfffff
    800045fa:	07e080e7          	jalr	126(ra) # 80003674 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045fe:	2a05                	addiw	s4,s4,1
    80004600:	0a91                	addi	s5,s5,4
    80004602:	02c9a783          	lw	a5,44(s3)
    80004606:	04fa5e63          	bge	s4,a5,80004662 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000460a:	0189a583          	lw	a1,24(s3)
    8000460e:	014585bb          	addw	a1,a1,s4
    80004612:	2585                	addiw	a1,a1,1
    80004614:	0289a503          	lw	a0,40(s3)
    80004618:	fffff097          	auipc	ra,0xfffff
    8000461c:	f2c080e7          	jalr	-212(ra) # 80003544 <bread>
    80004620:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004622:	000aa583          	lw	a1,0(s5)
    80004626:	0289a503          	lw	a0,40(s3)
    8000462a:	fffff097          	auipc	ra,0xfffff
    8000462e:	f1a080e7          	jalr	-230(ra) # 80003544 <bread>
    80004632:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004634:	40000613          	li	a2,1024
    80004638:	05890593          	addi	a1,s2,88
    8000463c:	05850513          	addi	a0,a0,88
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	6da080e7          	jalr	1754(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004648:	8526                	mv	a0,s1
    8000464a:	fffff097          	auipc	ra,0xfffff
    8000464e:	fec080e7          	jalr	-20(ra) # 80003636 <bwrite>
    if(recovering == 0)
    80004652:	f80b1ce3          	bnez	s6,800045ea <install_trans+0x36>
      bunpin(dbuf);
    80004656:	8526                	mv	a0,s1
    80004658:	fffff097          	auipc	ra,0xfffff
    8000465c:	0f6080e7          	jalr	246(ra) # 8000374e <bunpin>
    80004660:	b769                	j	800045ea <install_trans+0x36>
}
    80004662:	70e2                	ld	ra,56(sp)
    80004664:	7442                	ld	s0,48(sp)
    80004666:	74a2                	ld	s1,40(sp)
    80004668:	7902                	ld	s2,32(sp)
    8000466a:	69e2                	ld	s3,24(sp)
    8000466c:	6a42                	ld	s4,16(sp)
    8000466e:	6aa2                	ld	s5,8(sp)
    80004670:	6b02                	ld	s6,0(sp)
    80004672:	6121                	addi	sp,sp,64
    80004674:	8082                	ret
    80004676:	8082                	ret

0000000080004678 <initlog>:
{
    80004678:	7179                	addi	sp,sp,-48
    8000467a:	f406                	sd	ra,40(sp)
    8000467c:	f022                	sd	s0,32(sp)
    8000467e:	ec26                	sd	s1,24(sp)
    80004680:	e84a                	sd	s2,16(sp)
    80004682:	e44e                	sd	s3,8(sp)
    80004684:	1800                	addi	s0,sp,48
    80004686:	892a                	mv	s2,a0
    80004688:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000468a:	00023497          	auipc	s1,0x23
    8000468e:	3e648493          	addi	s1,s1,998 # 80027a70 <log>
    80004692:	00004597          	auipc	a1,0x4
    80004696:	ffe58593          	addi	a1,a1,-2 # 80008690 <syscalls+0x1f0>
    8000469a:	8526                	mv	a0,s1
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	496080e7          	jalr	1174(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    800046a4:	0149a583          	lw	a1,20(s3)
    800046a8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800046aa:	0109a783          	lw	a5,16(s3)
    800046ae:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800046b0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800046b4:	854a                	mv	a0,s2
    800046b6:	fffff097          	auipc	ra,0xfffff
    800046ba:	e8e080e7          	jalr	-370(ra) # 80003544 <bread>
  log.lh.n = lh->n;
    800046be:	4d34                	lw	a3,88(a0)
    800046c0:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800046c2:	02d05663          	blez	a3,800046ee <initlog+0x76>
    800046c6:	05c50793          	addi	a5,a0,92
    800046ca:	00023717          	auipc	a4,0x23
    800046ce:	3d670713          	addi	a4,a4,982 # 80027aa0 <log+0x30>
    800046d2:	36fd                	addiw	a3,a3,-1
    800046d4:	02069613          	slli	a2,a3,0x20
    800046d8:	01e65693          	srli	a3,a2,0x1e
    800046dc:	06050613          	addi	a2,a0,96
    800046e0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800046e2:	4390                	lw	a2,0(a5)
    800046e4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046e6:	0791                	addi	a5,a5,4
    800046e8:	0711                	addi	a4,a4,4
    800046ea:	fed79ce3          	bne	a5,a3,800046e2 <initlog+0x6a>
  brelse(buf);
    800046ee:	fffff097          	auipc	ra,0xfffff
    800046f2:	f86080e7          	jalr	-122(ra) # 80003674 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800046f6:	4505                	li	a0,1
    800046f8:	00000097          	auipc	ra,0x0
    800046fc:	ebc080e7          	jalr	-324(ra) # 800045b4 <install_trans>
  log.lh.n = 0;
    80004700:	00023797          	auipc	a5,0x23
    80004704:	3807ae23          	sw	zero,924(a5) # 80027a9c <log+0x2c>
  write_head(); // clear the log
    80004708:	00000097          	auipc	ra,0x0
    8000470c:	e30080e7          	jalr	-464(ra) # 80004538 <write_head>
}
    80004710:	70a2                	ld	ra,40(sp)
    80004712:	7402                	ld	s0,32(sp)
    80004714:	64e2                	ld	s1,24(sp)
    80004716:	6942                	ld	s2,16(sp)
    80004718:	69a2                	ld	s3,8(sp)
    8000471a:	6145                	addi	sp,sp,48
    8000471c:	8082                	ret

000000008000471e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000471e:	1101                	addi	sp,sp,-32
    80004720:	ec06                	sd	ra,24(sp)
    80004722:	e822                	sd	s0,16(sp)
    80004724:	e426                	sd	s1,8(sp)
    80004726:	e04a                	sd	s2,0(sp)
    80004728:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000472a:	00023517          	auipc	a0,0x23
    8000472e:	34650513          	addi	a0,a0,838 # 80027a70 <log>
    80004732:	ffffc097          	auipc	ra,0xffffc
    80004736:	490080e7          	jalr	1168(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    8000473a:	00023497          	auipc	s1,0x23
    8000473e:	33648493          	addi	s1,s1,822 # 80027a70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004742:	4979                	li	s2,30
    80004744:	a039                	j	80004752 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004746:	85a6                	mv	a1,s1
    80004748:	8526                	mv	a0,s1
    8000474a:	ffffe097          	auipc	ra,0xffffe
    8000474e:	9e2080e7          	jalr	-1566(ra) # 8000212c <sleep>
    if(log.committing){
    80004752:	50dc                	lw	a5,36(s1)
    80004754:	fbed                	bnez	a5,80004746 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004756:	509c                	lw	a5,32(s1)
    80004758:	0017871b          	addiw	a4,a5,1
    8000475c:	0007069b          	sext.w	a3,a4
    80004760:	0027179b          	slliw	a5,a4,0x2
    80004764:	9fb9                	addw	a5,a5,a4
    80004766:	0017979b          	slliw	a5,a5,0x1
    8000476a:	54d8                	lw	a4,44(s1)
    8000476c:	9fb9                	addw	a5,a5,a4
    8000476e:	00f95963          	bge	s2,a5,80004780 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004772:	85a6                	mv	a1,s1
    80004774:	8526                	mv	a0,s1
    80004776:	ffffe097          	auipc	ra,0xffffe
    8000477a:	9b6080e7          	jalr	-1610(ra) # 8000212c <sleep>
    8000477e:	bfd1                	j	80004752 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004780:	00023517          	auipc	a0,0x23
    80004784:	2f050513          	addi	a0,a0,752 # 80027a70 <log>
    80004788:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000478a:	ffffc097          	auipc	ra,0xffffc
    8000478e:	4ec080e7          	jalr	1260(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004792:	60e2                	ld	ra,24(sp)
    80004794:	6442                	ld	s0,16(sp)
    80004796:	64a2                	ld	s1,8(sp)
    80004798:	6902                	ld	s2,0(sp)
    8000479a:	6105                	addi	sp,sp,32
    8000479c:	8082                	ret

000000008000479e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000479e:	7139                	addi	sp,sp,-64
    800047a0:	fc06                	sd	ra,56(sp)
    800047a2:	f822                	sd	s0,48(sp)
    800047a4:	f426                	sd	s1,40(sp)
    800047a6:	f04a                	sd	s2,32(sp)
    800047a8:	ec4e                	sd	s3,24(sp)
    800047aa:	e852                	sd	s4,16(sp)
    800047ac:	e456                	sd	s5,8(sp)
    800047ae:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800047b0:	00023497          	auipc	s1,0x23
    800047b4:	2c048493          	addi	s1,s1,704 # 80027a70 <log>
    800047b8:	8526                	mv	a0,s1
    800047ba:	ffffc097          	auipc	ra,0xffffc
    800047be:	408080e7          	jalr	1032(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    800047c2:	509c                	lw	a5,32(s1)
    800047c4:	37fd                	addiw	a5,a5,-1
    800047c6:	0007891b          	sext.w	s2,a5
    800047ca:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800047cc:	50dc                	lw	a5,36(s1)
    800047ce:	e7b9                	bnez	a5,8000481c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800047d0:	04091e63          	bnez	s2,8000482c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800047d4:	00023497          	auipc	s1,0x23
    800047d8:	29c48493          	addi	s1,s1,668 # 80027a70 <log>
    800047dc:	4785                	li	a5,1
    800047de:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800047e0:	8526                	mv	a0,s1
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	494080e7          	jalr	1172(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800047ea:	54dc                	lw	a5,44(s1)
    800047ec:	06f04763          	bgtz	a5,8000485a <end_op+0xbc>
    acquire(&log.lock);
    800047f0:	00023497          	auipc	s1,0x23
    800047f4:	28048493          	addi	s1,s1,640 # 80027a70 <log>
    800047f8:	8526                	mv	a0,s1
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	3c8080e7          	jalr	968(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004802:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004806:	8526                	mv	a0,s1
    80004808:	ffffe097          	auipc	ra,0xffffe
    8000480c:	ab0080e7          	jalr	-1360(ra) # 800022b8 <wakeup>
    release(&log.lock);
    80004810:	8526                	mv	a0,s1
    80004812:	ffffc097          	auipc	ra,0xffffc
    80004816:	464080e7          	jalr	1124(ra) # 80000c76 <release>
}
    8000481a:	a03d                	j	80004848 <end_op+0xaa>
    panic("log.committing");
    8000481c:	00004517          	auipc	a0,0x4
    80004820:	e7c50513          	addi	a0,a0,-388 # 80008698 <syscalls+0x1f8>
    80004824:	ffffc097          	auipc	ra,0xffffc
    80004828:	d06080e7          	jalr	-762(ra) # 8000052a <panic>
    wakeup(&log);
    8000482c:	00023497          	auipc	s1,0x23
    80004830:	24448493          	addi	s1,s1,580 # 80027a70 <log>
    80004834:	8526                	mv	a0,s1
    80004836:	ffffe097          	auipc	ra,0xffffe
    8000483a:	a82080e7          	jalr	-1406(ra) # 800022b8 <wakeup>
  release(&log.lock);
    8000483e:	8526                	mv	a0,s1
    80004840:	ffffc097          	auipc	ra,0xffffc
    80004844:	436080e7          	jalr	1078(ra) # 80000c76 <release>
}
    80004848:	70e2                	ld	ra,56(sp)
    8000484a:	7442                	ld	s0,48(sp)
    8000484c:	74a2                	ld	s1,40(sp)
    8000484e:	7902                	ld	s2,32(sp)
    80004850:	69e2                	ld	s3,24(sp)
    80004852:	6a42                	ld	s4,16(sp)
    80004854:	6aa2                	ld	s5,8(sp)
    80004856:	6121                	addi	sp,sp,64
    80004858:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000485a:	00023a97          	auipc	s5,0x23
    8000485e:	246a8a93          	addi	s5,s5,582 # 80027aa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004862:	00023a17          	auipc	s4,0x23
    80004866:	20ea0a13          	addi	s4,s4,526 # 80027a70 <log>
    8000486a:	018a2583          	lw	a1,24(s4)
    8000486e:	012585bb          	addw	a1,a1,s2
    80004872:	2585                	addiw	a1,a1,1
    80004874:	028a2503          	lw	a0,40(s4)
    80004878:	fffff097          	auipc	ra,0xfffff
    8000487c:	ccc080e7          	jalr	-820(ra) # 80003544 <bread>
    80004880:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004882:	000aa583          	lw	a1,0(s5)
    80004886:	028a2503          	lw	a0,40(s4)
    8000488a:	fffff097          	auipc	ra,0xfffff
    8000488e:	cba080e7          	jalr	-838(ra) # 80003544 <bread>
    80004892:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004894:	40000613          	li	a2,1024
    80004898:	05850593          	addi	a1,a0,88
    8000489c:	05848513          	addi	a0,s1,88
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	47a080e7          	jalr	1146(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    800048a8:	8526                	mv	a0,s1
    800048aa:	fffff097          	auipc	ra,0xfffff
    800048ae:	d8c080e7          	jalr	-628(ra) # 80003636 <bwrite>
    brelse(from);
    800048b2:	854e                	mv	a0,s3
    800048b4:	fffff097          	auipc	ra,0xfffff
    800048b8:	dc0080e7          	jalr	-576(ra) # 80003674 <brelse>
    brelse(to);
    800048bc:	8526                	mv	a0,s1
    800048be:	fffff097          	auipc	ra,0xfffff
    800048c2:	db6080e7          	jalr	-586(ra) # 80003674 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800048c6:	2905                	addiw	s2,s2,1
    800048c8:	0a91                	addi	s5,s5,4
    800048ca:	02ca2783          	lw	a5,44(s4)
    800048ce:	f8f94ee3          	blt	s2,a5,8000486a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800048d2:	00000097          	auipc	ra,0x0
    800048d6:	c66080e7          	jalr	-922(ra) # 80004538 <write_head>
    install_trans(0); // Now install writes to home locations
    800048da:	4501                	li	a0,0
    800048dc:	00000097          	auipc	ra,0x0
    800048e0:	cd8080e7          	jalr	-808(ra) # 800045b4 <install_trans>
    log.lh.n = 0;
    800048e4:	00023797          	auipc	a5,0x23
    800048e8:	1a07ac23          	sw	zero,440(a5) # 80027a9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800048ec:	00000097          	auipc	ra,0x0
    800048f0:	c4c080e7          	jalr	-948(ra) # 80004538 <write_head>
    800048f4:	bdf5                	j	800047f0 <end_op+0x52>

00000000800048f6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800048f6:	1101                	addi	sp,sp,-32
    800048f8:	ec06                	sd	ra,24(sp)
    800048fa:	e822                	sd	s0,16(sp)
    800048fc:	e426                	sd	s1,8(sp)
    800048fe:	e04a                	sd	s2,0(sp)
    80004900:	1000                	addi	s0,sp,32
    80004902:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004904:	00023917          	auipc	s2,0x23
    80004908:	16c90913          	addi	s2,s2,364 # 80027a70 <log>
    8000490c:	854a                	mv	a0,s2
    8000490e:	ffffc097          	auipc	ra,0xffffc
    80004912:	2b4080e7          	jalr	692(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004916:	02c92603          	lw	a2,44(s2)
    8000491a:	47f5                	li	a5,29
    8000491c:	06c7c563          	blt	a5,a2,80004986 <log_write+0x90>
    80004920:	00023797          	auipc	a5,0x23
    80004924:	16c7a783          	lw	a5,364(a5) # 80027a8c <log+0x1c>
    80004928:	37fd                	addiw	a5,a5,-1
    8000492a:	04f65e63          	bge	a2,a5,80004986 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000492e:	00023797          	auipc	a5,0x23
    80004932:	1627a783          	lw	a5,354(a5) # 80027a90 <log+0x20>
    80004936:	06f05063          	blez	a5,80004996 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000493a:	4781                	li	a5,0
    8000493c:	06c05563          	blez	a2,800049a6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004940:	44cc                	lw	a1,12(s1)
    80004942:	00023717          	auipc	a4,0x23
    80004946:	15e70713          	addi	a4,a4,350 # 80027aa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000494a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000494c:	4314                	lw	a3,0(a4)
    8000494e:	04b68c63          	beq	a3,a1,800049a6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004952:	2785                	addiw	a5,a5,1
    80004954:	0711                	addi	a4,a4,4
    80004956:	fef61be3          	bne	a2,a5,8000494c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000495a:	0621                	addi	a2,a2,8
    8000495c:	060a                	slli	a2,a2,0x2
    8000495e:	00023797          	auipc	a5,0x23
    80004962:	11278793          	addi	a5,a5,274 # 80027a70 <log>
    80004966:	963e                	add	a2,a2,a5
    80004968:	44dc                	lw	a5,12(s1)
    8000496a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000496c:	8526                	mv	a0,s1
    8000496e:	fffff097          	auipc	ra,0xfffff
    80004972:	da4080e7          	jalr	-604(ra) # 80003712 <bpin>
    log.lh.n++;
    80004976:	00023717          	auipc	a4,0x23
    8000497a:	0fa70713          	addi	a4,a4,250 # 80027a70 <log>
    8000497e:	575c                	lw	a5,44(a4)
    80004980:	2785                	addiw	a5,a5,1
    80004982:	d75c                	sw	a5,44(a4)
    80004984:	a835                	j	800049c0 <log_write+0xca>
    panic("too big a transaction");
    80004986:	00004517          	auipc	a0,0x4
    8000498a:	d2250513          	addi	a0,a0,-734 # 800086a8 <syscalls+0x208>
    8000498e:	ffffc097          	auipc	ra,0xffffc
    80004992:	b9c080e7          	jalr	-1124(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004996:	00004517          	auipc	a0,0x4
    8000499a:	d2a50513          	addi	a0,a0,-726 # 800086c0 <syscalls+0x220>
    8000499e:	ffffc097          	auipc	ra,0xffffc
    800049a2:	b8c080e7          	jalr	-1140(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    800049a6:	00878713          	addi	a4,a5,8
    800049aa:	00271693          	slli	a3,a4,0x2
    800049ae:	00023717          	auipc	a4,0x23
    800049b2:	0c270713          	addi	a4,a4,194 # 80027a70 <log>
    800049b6:	9736                	add	a4,a4,a3
    800049b8:	44d4                	lw	a3,12(s1)
    800049ba:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800049bc:	faf608e3          	beq	a2,a5,8000496c <log_write+0x76>
  }
  release(&log.lock);
    800049c0:	00023517          	auipc	a0,0x23
    800049c4:	0b050513          	addi	a0,a0,176 # 80027a70 <log>
    800049c8:	ffffc097          	auipc	ra,0xffffc
    800049cc:	2ae080e7          	jalr	686(ra) # 80000c76 <release>
}
    800049d0:	60e2                	ld	ra,24(sp)
    800049d2:	6442                	ld	s0,16(sp)
    800049d4:	64a2                	ld	s1,8(sp)
    800049d6:	6902                	ld	s2,0(sp)
    800049d8:	6105                	addi	sp,sp,32
    800049da:	8082                	ret

00000000800049dc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800049dc:	1101                	addi	sp,sp,-32
    800049de:	ec06                	sd	ra,24(sp)
    800049e0:	e822                	sd	s0,16(sp)
    800049e2:	e426                	sd	s1,8(sp)
    800049e4:	e04a                	sd	s2,0(sp)
    800049e6:	1000                	addi	s0,sp,32
    800049e8:	84aa                	mv	s1,a0
    800049ea:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800049ec:	00004597          	auipc	a1,0x4
    800049f0:	cf458593          	addi	a1,a1,-780 # 800086e0 <syscalls+0x240>
    800049f4:	0521                	addi	a0,a0,8
    800049f6:	ffffc097          	auipc	ra,0xffffc
    800049fa:	13c080e7          	jalr	316(ra) # 80000b32 <initlock>
  lk->name = name;
    800049fe:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004a02:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a06:	0204a423          	sw	zero,40(s1)
}
    80004a0a:	60e2                	ld	ra,24(sp)
    80004a0c:	6442                	ld	s0,16(sp)
    80004a0e:	64a2                	ld	s1,8(sp)
    80004a10:	6902                	ld	s2,0(sp)
    80004a12:	6105                	addi	sp,sp,32
    80004a14:	8082                	ret

0000000080004a16 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004a16:	1101                	addi	sp,sp,-32
    80004a18:	ec06                	sd	ra,24(sp)
    80004a1a:	e822                	sd	s0,16(sp)
    80004a1c:	e426                	sd	s1,8(sp)
    80004a1e:	e04a                	sd	s2,0(sp)
    80004a20:	1000                	addi	s0,sp,32
    80004a22:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a24:	00850913          	addi	s2,a0,8
    80004a28:	854a                	mv	a0,s2
    80004a2a:	ffffc097          	auipc	ra,0xffffc
    80004a2e:	198080e7          	jalr	408(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80004a32:	409c                	lw	a5,0(s1)
    80004a34:	cb89                	beqz	a5,80004a46 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004a36:	85ca                	mv	a1,s2
    80004a38:	8526                	mv	a0,s1
    80004a3a:	ffffd097          	auipc	ra,0xffffd
    80004a3e:	6f2080e7          	jalr	1778(ra) # 8000212c <sleep>
  while (lk->locked) {
    80004a42:	409c                	lw	a5,0(s1)
    80004a44:	fbed                	bnez	a5,80004a36 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004a46:	4785                	li	a5,1
    80004a48:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a4a:	ffffd097          	auipc	ra,0xffffd
    80004a4e:	f6a080e7          	jalr	-150(ra) # 800019b4 <myproc>
    80004a52:	591c                	lw	a5,48(a0)
    80004a54:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a56:	854a                	mv	a0,s2
    80004a58:	ffffc097          	auipc	ra,0xffffc
    80004a5c:	21e080e7          	jalr	542(ra) # 80000c76 <release>
}
    80004a60:	60e2                	ld	ra,24(sp)
    80004a62:	6442                	ld	s0,16(sp)
    80004a64:	64a2                	ld	s1,8(sp)
    80004a66:	6902                	ld	s2,0(sp)
    80004a68:	6105                	addi	sp,sp,32
    80004a6a:	8082                	ret

0000000080004a6c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a6c:	1101                	addi	sp,sp,-32
    80004a6e:	ec06                	sd	ra,24(sp)
    80004a70:	e822                	sd	s0,16(sp)
    80004a72:	e426                	sd	s1,8(sp)
    80004a74:	e04a                	sd	s2,0(sp)
    80004a76:	1000                	addi	s0,sp,32
    80004a78:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a7a:	00850913          	addi	s2,a0,8
    80004a7e:	854a                	mv	a0,s2
    80004a80:	ffffc097          	auipc	ra,0xffffc
    80004a84:	142080e7          	jalr	322(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004a88:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a8c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a90:	8526                	mv	a0,s1
    80004a92:	ffffe097          	auipc	ra,0xffffe
    80004a96:	826080e7          	jalr	-2010(ra) # 800022b8 <wakeup>
  release(&lk->lk);
    80004a9a:	854a                	mv	a0,s2
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	1da080e7          	jalr	474(ra) # 80000c76 <release>
}
    80004aa4:	60e2                	ld	ra,24(sp)
    80004aa6:	6442                	ld	s0,16(sp)
    80004aa8:	64a2                	ld	s1,8(sp)
    80004aaa:	6902                	ld	s2,0(sp)
    80004aac:	6105                	addi	sp,sp,32
    80004aae:	8082                	ret

0000000080004ab0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004ab0:	7179                	addi	sp,sp,-48
    80004ab2:	f406                	sd	ra,40(sp)
    80004ab4:	f022                	sd	s0,32(sp)
    80004ab6:	ec26                	sd	s1,24(sp)
    80004ab8:	e84a                	sd	s2,16(sp)
    80004aba:	e44e                	sd	s3,8(sp)
    80004abc:	1800                	addi	s0,sp,48
    80004abe:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004ac0:	00850913          	addi	s2,a0,8
    80004ac4:	854a                	mv	a0,s2
    80004ac6:	ffffc097          	auipc	ra,0xffffc
    80004aca:	0fc080e7          	jalr	252(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ace:	409c                	lw	a5,0(s1)
    80004ad0:	ef99                	bnez	a5,80004aee <holdingsleep+0x3e>
    80004ad2:	4481                	li	s1,0
  release(&lk->lk);
    80004ad4:	854a                	mv	a0,s2
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	1a0080e7          	jalr	416(ra) # 80000c76 <release>
  return r;
}
    80004ade:	8526                	mv	a0,s1
    80004ae0:	70a2                	ld	ra,40(sp)
    80004ae2:	7402                	ld	s0,32(sp)
    80004ae4:	64e2                	ld	s1,24(sp)
    80004ae6:	6942                	ld	s2,16(sp)
    80004ae8:	69a2                	ld	s3,8(sp)
    80004aea:	6145                	addi	sp,sp,48
    80004aec:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004aee:	0284a983          	lw	s3,40(s1)
    80004af2:	ffffd097          	auipc	ra,0xffffd
    80004af6:	ec2080e7          	jalr	-318(ra) # 800019b4 <myproc>
    80004afa:	5904                	lw	s1,48(a0)
    80004afc:	413484b3          	sub	s1,s1,s3
    80004b00:	0014b493          	seqz	s1,s1
    80004b04:	bfc1                	j	80004ad4 <holdingsleep+0x24>

0000000080004b06 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004b06:	1141                	addi	sp,sp,-16
    80004b08:	e406                	sd	ra,8(sp)
    80004b0a:	e022                	sd	s0,0(sp)
    80004b0c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b0e:	00004597          	auipc	a1,0x4
    80004b12:	be258593          	addi	a1,a1,-1054 # 800086f0 <syscalls+0x250>
    80004b16:	00023517          	auipc	a0,0x23
    80004b1a:	0a250513          	addi	a0,a0,162 # 80027bb8 <ftable>
    80004b1e:	ffffc097          	auipc	ra,0xffffc
    80004b22:	014080e7          	jalr	20(ra) # 80000b32 <initlock>
}
    80004b26:	60a2                	ld	ra,8(sp)
    80004b28:	6402                	ld	s0,0(sp)
    80004b2a:	0141                	addi	sp,sp,16
    80004b2c:	8082                	ret

0000000080004b2e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004b2e:	1101                	addi	sp,sp,-32
    80004b30:	ec06                	sd	ra,24(sp)
    80004b32:	e822                	sd	s0,16(sp)
    80004b34:	e426                	sd	s1,8(sp)
    80004b36:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004b38:	00023517          	auipc	a0,0x23
    80004b3c:	08050513          	addi	a0,a0,128 # 80027bb8 <ftable>
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	082080e7          	jalr	130(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b48:	00023497          	auipc	s1,0x23
    80004b4c:	08848493          	addi	s1,s1,136 # 80027bd0 <ftable+0x18>
    80004b50:	00024717          	auipc	a4,0x24
    80004b54:	02070713          	addi	a4,a4,32 # 80028b70 <ftable+0xfb8>
    if(f->ref == 0){
    80004b58:	40dc                	lw	a5,4(s1)
    80004b5a:	cf99                	beqz	a5,80004b78 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b5c:	02848493          	addi	s1,s1,40
    80004b60:	fee49ce3          	bne	s1,a4,80004b58 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b64:	00023517          	auipc	a0,0x23
    80004b68:	05450513          	addi	a0,a0,84 # 80027bb8 <ftable>
    80004b6c:	ffffc097          	auipc	ra,0xffffc
    80004b70:	10a080e7          	jalr	266(ra) # 80000c76 <release>
  return 0;
    80004b74:	4481                	li	s1,0
    80004b76:	a819                	j	80004b8c <filealloc+0x5e>
      f->ref = 1;
    80004b78:	4785                	li	a5,1
    80004b7a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b7c:	00023517          	auipc	a0,0x23
    80004b80:	03c50513          	addi	a0,a0,60 # 80027bb8 <ftable>
    80004b84:	ffffc097          	auipc	ra,0xffffc
    80004b88:	0f2080e7          	jalr	242(ra) # 80000c76 <release>
}
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	60e2                	ld	ra,24(sp)
    80004b90:	6442                	ld	s0,16(sp)
    80004b92:	64a2                	ld	s1,8(sp)
    80004b94:	6105                	addi	sp,sp,32
    80004b96:	8082                	ret

0000000080004b98 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b98:	1101                	addi	sp,sp,-32
    80004b9a:	ec06                	sd	ra,24(sp)
    80004b9c:	e822                	sd	s0,16(sp)
    80004b9e:	e426                	sd	s1,8(sp)
    80004ba0:	1000                	addi	s0,sp,32
    80004ba2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004ba4:	00023517          	auipc	a0,0x23
    80004ba8:	01450513          	addi	a0,a0,20 # 80027bb8 <ftable>
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	016080e7          	jalr	22(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004bb4:	40dc                	lw	a5,4(s1)
    80004bb6:	02f05263          	blez	a5,80004bda <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004bba:	2785                	addiw	a5,a5,1
    80004bbc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004bbe:	00023517          	auipc	a0,0x23
    80004bc2:	ffa50513          	addi	a0,a0,-6 # 80027bb8 <ftable>
    80004bc6:	ffffc097          	auipc	ra,0xffffc
    80004bca:	0b0080e7          	jalr	176(ra) # 80000c76 <release>
  return f;
}
    80004bce:	8526                	mv	a0,s1
    80004bd0:	60e2                	ld	ra,24(sp)
    80004bd2:	6442                	ld	s0,16(sp)
    80004bd4:	64a2                	ld	s1,8(sp)
    80004bd6:	6105                	addi	sp,sp,32
    80004bd8:	8082                	ret
    panic("filedup");
    80004bda:	00004517          	auipc	a0,0x4
    80004bde:	b1e50513          	addi	a0,a0,-1250 # 800086f8 <syscalls+0x258>
    80004be2:	ffffc097          	auipc	ra,0xffffc
    80004be6:	948080e7          	jalr	-1720(ra) # 8000052a <panic>

0000000080004bea <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004bea:	7139                	addi	sp,sp,-64
    80004bec:	fc06                	sd	ra,56(sp)
    80004bee:	f822                	sd	s0,48(sp)
    80004bf0:	f426                	sd	s1,40(sp)
    80004bf2:	f04a                	sd	s2,32(sp)
    80004bf4:	ec4e                	sd	s3,24(sp)
    80004bf6:	e852                	sd	s4,16(sp)
    80004bf8:	e456                	sd	s5,8(sp)
    80004bfa:	0080                	addi	s0,sp,64
    80004bfc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004bfe:	00023517          	auipc	a0,0x23
    80004c02:	fba50513          	addi	a0,a0,-70 # 80027bb8 <ftable>
    80004c06:	ffffc097          	auipc	ra,0xffffc
    80004c0a:	fbc080e7          	jalr	-68(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004c0e:	40dc                	lw	a5,4(s1)
    80004c10:	06f05163          	blez	a5,80004c72 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004c14:	37fd                	addiw	a5,a5,-1
    80004c16:	0007871b          	sext.w	a4,a5
    80004c1a:	c0dc                	sw	a5,4(s1)
    80004c1c:	06e04363          	bgtz	a4,80004c82 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c20:	0004a903          	lw	s2,0(s1)
    80004c24:	0094ca83          	lbu	s5,9(s1)
    80004c28:	0104ba03          	ld	s4,16(s1)
    80004c2c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004c30:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004c34:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004c38:	00023517          	auipc	a0,0x23
    80004c3c:	f8050513          	addi	a0,a0,-128 # 80027bb8 <ftable>
    80004c40:	ffffc097          	auipc	ra,0xffffc
    80004c44:	036080e7          	jalr	54(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004c48:	4785                	li	a5,1
    80004c4a:	04f90d63          	beq	s2,a5,80004ca4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004c4e:	3979                	addiw	s2,s2,-2
    80004c50:	4785                	li	a5,1
    80004c52:	0527e063          	bltu	a5,s2,80004c92 <fileclose+0xa8>
    begin_op();
    80004c56:	00000097          	auipc	ra,0x0
    80004c5a:	ac8080e7          	jalr	-1336(ra) # 8000471e <begin_op>
    iput(ff.ip);
    80004c5e:	854e                	mv	a0,s3
    80004c60:	fffff097          	auipc	ra,0xfffff
    80004c64:	2a2080e7          	jalr	674(ra) # 80003f02 <iput>
    end_op();
    80004c68:	00000097          	auipc	ra,0x0
    80004c6c:	b36080e7          	jalr	-1226(ra) # 8000479e <end_op>
    80004c70:	a00d                	j	80004c92 <fileclose+0xa8>
    panic("fileclose");
    80004c72:	00004517          	auipc	a0,0x4
    80004c76:	a8e50513          	addi	a0,a0,-1394 # 80008700 <syscalls+0x260>
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	8b0080e7          	jalr	-1872(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004c82:	00023517          	auipc	a0,0x23
    80004c86:	f3650513          	addi	a0,a0,-202 # 80027bb8 <ftable>
    80004c8a:	ffffc097          	auipc	ra,0xffffc
    80004c8e:	fec080e7          	jalr	-20(ra) # 80000c76 <release>
  }
}
    80004c92:	70e2                	ld	ra,56(sp)
    80004c94:	7442                	ld	s0,48(sp)
    80004c96:	74a2                	ld	s1,40(sp)
    80004c98:	7902                	ld	s2,32(sp)
    80004c9a:	69e2                	ld	s3,24(sp)
    80004c9c:	6a42                	ld	s4,16(sp)
    80004c9e:	6aa2                	ld	s5,8(sp)
    80004ca0:	6121                	addi	sp,sp,64
    80004ca2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ca4:	85d6                	mv	a1,s5
    80004ca6:	8552                	mv	a0,s4
    80004ca8:	00000097          	auipc	ra,0x0
    80004cac:	34c080e7          	jalr	844(ra) # 80004ff4 <pipeclose>
    80004cb0:	b7cd                	j	80004c92 <fileclose+0xa8>

0000000080004cb2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004cb2:	715d                	addi	sp,sp,-80
    80004cb4:	e486                	sd	ra,72(sp)
    80004cb6:	e0a2                	sd	s0,64(sp)
    80004cb8:	fc26                	sd	s1,56(sp)
    80004cba:	f84a                	sd	s2,48(sp)
    80004cbc:	f44e                	sd	s3,40(sp)
    80004cbe:	0880                	addi	s0,sp,80
    80004cc0:	84aa                	mv	s1,a0
    80004cc2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004cc4:	ffffd097          	auipc	ra,0xffffd
    80004cc8:	cf0080e7          	jalr	-784(ra) # 800019b4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ccc:	409c                	lw	a5,0(s1)
    80004cce:	37f9                	addiw	a5,a5,-2
    80004cd0:	4705                	li	a4,1
    80004cd2:	04f76763          	bltu	a4,a5,80004d20 <filestat+0x6e>
    80004cd6:	892a                	mv	s2,a0
    ilock(f->ip);
    80004cd8:	6c88                	ld	a0,24(s1)
    80004cda:	fffff097          	auipc	ra,0xfffff
    80004cde:	06e080e7          	jalr	110(ra) # 80003d48 <ilock>
    stati(f->ip, &st);
    80004ce2:	fb840593          	addi	a1,s0,-72
    80004ce6:	6c88                	ld	a0,24(s1)
    80004ce8:	fffff097          	auipc	ra,0xfffff
    80004cec:	2ea080e7          	jalr	746(ra) # 80003fd2 <stati>
    iunlock(f->ip);
    80004cf0:	6c88                	ld	a0,24(s1)
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	118080e7          	jalr	280(ra) # 80003e0a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004cfa:	46e1                	li	a3,24
    80004cfc:	fb840613          	addi	a2,s0,-72
    80004d00:	85ce                	mv	a1,s3
    80004d02:	05093503          	ld	a0,80(s2)
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	938080e7          	jalr	-1736(ra) # 8000163e <copyout>
    80004d0e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d12:	60a6                	ld	ra,72(sp)
    80004d14:	6406                	ld	s0,64(sp)
    80004d16:	74e2                	ld	s1,56(sp)
    80004d18:	7942                	ld	s2,48(sp)
    80004d1a:	79a2                	ld	s3,40(sp)
    80004d1c:	6161                	addi	sp,sp,80
    80004d1e:	8082                	ret
  return -1;
    80004d20:	557d                	li	a0,-1
    80004d22:	bfc5                	j	80004d12 <filestat+0x60>

0000000080004d24 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004d24:	7179                	addi	sp,sp,-48
    80004d26:	f406                	sd	ra,40(sp)
    80004d28:	f022                	sd	s0,32(sp)
    80004d2a:	ec26                	sd	s1,24(sp)
    80004d2c:	e84a                	sd	s2,16(sp)
    80004d2e:	e44e                	sd	s3,8(sp)
    80004d30:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004d32:	00854783          	lbu	a5,8(a0)
    80004d36:	c3d5                	beqz	a5,80004dda <fileread+0xb6>
    80004d38:	84aa                	mv	s1,a0
    80004d3a:	89ae                	mv	s3,a1
    80004d3c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d3e:	411c                	lw	a5,0(a0)
    80004d40:	4705                	li	a4,1
    80004d42:	04e78963          	beq	a5,a4,80004d94 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d46:	470d                	li	a4,3
    80004d48:	04e78d63          	beq	a5,a4,80004da2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d4c:	4709                	li	a4,2
    80004d4e:	06e79e63          	bne	a5,a4,80004dca <fileread+0xa6>
    ilock(f->ip);
    80004d52:	6d08                	ld	a0,24(a0)
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	ff4080e7          	jalr	-12(ra) # 80003d48 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d5c:	874a                	mv	a4,s2
    80004d5e:	5094                	lw	a3,32(s1)
    80004d60:	864e                	mv	a2,s3
    80004d62:	4585                	li	a1,1
    80004d64:	6c88                	ld	a0,24(s1)
    80004d66:	fffff097          	auipc	ra,0xfffff
    80004d6a:	296080e7          	jalr	662(ra) # 80003ffc <readi>
    80004d6e:	892a                	mv	s2,a0
    80004d70:	00a05563          	blez	a0,80004d7a <fileread+0x56>
      f->off += r;
    80004d74:	509c                	lw	a5,32(s1)
    80004d76:	9fa9                	addw	a5,a5,a0
    80004d78:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d7a:	6c88                	ld	a0,24(s1)
    80004d7c:	fffff097          	auipc	ra,0xfffff
    80004d80:	08e080e7          	jalr	142(ra) # 80003e0a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d84:	854a                	mv	a0,s2
    80004d86:	70a2                	ld	ra,40(sp)
    80004d88:	7402                	ld	s0,32(sp)
    80004d8a:	64e2                	ld	s1,24(sp)
    80004d8c:	6942                	ld	s2,16(sp)
    80004d8e:	69a2                	ld	s3,8(sp)
    80004d90:	6145                	addi	sp,sp,48
    80004d92:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d94:	6908                	ld	a0,16(a0)
    80004d96:	00000097          	auipc	ra,0x0
    80004d9a:	3c0080e7          	jalr	960(ra) # 80005156 <piperead>
    80004d9e:	892a                	mv	s2,a0
    80004da0:	b7d5                	j	80004d84 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004da2:	02451783          	lh	a5,36(a0)
    80004da6:	03079693          	slli	a3,a5,0x30
    80004daa:	92c1                	srli	a3,a3,0x30
    80004dac:	4725                	li	a4,9
    80004dae:	02d76863          	bltu	a4,a3,80004dde <fileread+0xba>
    80004db2:	0792                	slli	a5,a5,0x4
    80004db4:	00023717          	auipc	a4,0x23
    80004db8:	d6470713          	addi	a4,a4,-668 # 80027b18 <devsw>
    80004dbc:	97ba                	add	a5,a5,a4
    80004dbe:	639c                	ld	a5,0(a5)
    80004dc0:	c38d                	beqz	a5,80004de2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004dc2:	4505                	li	a0,1
    80004dc4:	9782                	jalr	a5
    80004dc6:	892a                	mv	s2,a0
    80004dc8:	bf75                	j	80004d84 <fileread+0x60>
    panic("fileread");
    80004dca:	00004517          	auipc	a0,0x4
    80004dce:	94650513          	addi	a0,a0,-1722 # 80008710 <syscalls+0x270>
    80004dd2:	ffffb097          	auipc	ra,0xffffb
    80004dd6:	758080e7          	jalr	1880(ra) # 8000052a <panic>
    return -1;
    80004dda:	597d                	li	s2,-1
    80004ddc:	b765                	j	80004d84 <fileread+0x60>
      return -1;
    80004dde:	597d                	li	s2,-1
    80004de0:	b755                	j	80004d84 <fileread+0x60>
    80004de2:	597d                	li	s2,-1
    80004de4:	b745                	j	80004d84 <fileread+0x60>

0000000080004de6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004de6:	715d                	addi	sp,sp,-80
    80004de8:	e486                	sd	ra,72(sp)
    80004dea:	e0a2                	sd	s0,64(sp)
    80004dec:	fc26                	sd	s1,56(sp)
    80004dee:	f84a                	sd	s2,48(sp)
    80004df0:	f44e                	sd	s3,40(sp)
    80004df2:	f052                	sd	s4,32(sp)
    80004df4:	ec56                	sd	s5,24(sp)
    80004df6:	e85a                	sd	s6,16(sp)
    80004df8:	e45e                	sd	s7,8(sp)
    80004dfa:	e062                	sd	s8,0(sp)
    80004dfc:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004dfe:	00954783          	lbu	a5,9(a0)
    80004e02:	10078663          	beqz	a5,80004f0e <filewrite+0x128>
    80004e06:	892a                	mv	s2,a0
    80004e08:	8aae                	mv	s5,a1
    80004e0a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e0c:	411c                	lw	a5,0(a0)
    80004e0e:	4705                	li	a4,1
    80004e10:	02e78263          	beq	a5,a4,80004e34 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e14:	470d                	li	a4,3
    80004e16:	02e78663          	beq	a5,a4,80004e42 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e1a:	4709                	li	a4,2
    80004e1c:	0ee79163          	bne	a5,a4,80004efe <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004e20:	0ac05d63          	blez	a2,80004eda <filewrite+0xf4>
    int i = 0;
    80004e24:	4981                	li	s3,0
    80004e26:	6b05                	lui	s6,0x1
    80004e28:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004e2c:	6b85                	lui	s7,0x1
    80004e2e:	c00b8b9b          	addiw	s7,s7,-1024
    80004e32:	a861                	j	80004eca <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004e34:	6908                	ld	a0,16(a0)
    80004e36:	00000097          	auipc	ra,0x0
    80004e3a:	22e080e7          	jalr	558(ra) # 80005064 <pipewrite>
    80004e3e:	8a2a                	mv	s4,a0
    80004e40:	a045                	j	80004ee0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004e42:	02451783          	lh	a5,36(a0)
    80004e46:	03079693          	slli	a3,a5,0x30
    80004e4a:	92c1                	srli	a3,a3,0x30
    80004e4c:	4725                	li	a4,9
    80004e4e:	0cd76263          	bltu	a4,a3,80004f12 <filewrite+0x12c>
    80004e52:	0792                	slli	a5,a5,0x4
    80004e54:	00023717          	auipc	a4,0x23
    80004e58:	cc470713          	addi	a4,a4,-828 # 80027b18 <devsw>
    80004e5c:	97ba                	add	a5,a5,a4
    80004e5e:	679c                	ld	a5,8(a5)
    80004e60:	cbdd                	beqz	a5,80004f16 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e62:	4505                	li	a0,1
    80004e64:	9782                	jalr	a5
    80004e66:	8a2a                	mv	s4,a0
    80004e68:	a8a5                	j	80004ee0 <filewrite+0xfa>
    80004e6a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e6e:	00000097          	auipc	ra,0x0
    80004e72:	8b0080e7          	jalr	-1872(ra) # 8000471e <begin_op>
      ilock(f->ip);
    80004e76:	01893503          	ld	a0,24(s2)
    80004e7a:	fffff097          	auipc	ra,0xfffff
    80004e7e:	ece080e7          	jalr	-306(ra) # 80003d48 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e82:	8762                	mv	a4,s8
    80004e84:	02092683          	lw	a3,32(s2)
    80004e88:	01598633          	add	a2,s3,s5
    80004e8c:	4585                	li	a1,1
    80004e8e:	01893503          	ld	a0,24(s2)
    80004e92:	fffff097          	auipc	ra,0xfffff
    80004e96:	262080e7          	jalr	610(ra) # 800040f4 <writei>
    80004e9a:	84aa                	mv	s1,a0
    80004e9c:	00a05763          	blez	a0,80004eaa <filewrite+0xc4>
        f->off += r;
    80004ea0:	02092783          	lw	a5,32(s2)
    80004ea4:	9fa9                	addw	a5,a5,a0
    80004ea6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004eaa:	01893503          	ld	a0,24(s2)
    80004eae:	fffff097          	auipc	ra,0xfffff
    80004eb2:	f5c080e7          	jalr	-164(ra) # 80003e0a <iunlock>
      end_op();
    80004eb6:	00000097          	auipc	ra,0x0
    80004eba:	8e8080e7          	jalr	-1816(ra) # 8000479e <end_op>

      if(r != n1){
    80004ebe:	009c1f63          	bne	s8,s1,80004edc <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004ec2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ec6:	0149db63          	bge	s3,s4,80004edc <filewrite+0xf6>
      int n1 = n - i;
    80004eca:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004ece:	84be                	mv	s1,a5
    80004ed0:	2781                	sext.w	a5,a5
    80004ed2:	f8fb5ce3          	bge	s6,a5,80004e6a <filewrite+0x84>
    80004ed6:	84de                	mv	s1,s7
    80004ed8:	bf49                	j	80004e6a <filewrite+0x84>
    int i = 0;
    80004eda:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004edc:	013a1f63          	bne	s4,s3,80004efa <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ee0:	8552                	mv	a0,s4
    80004ee2:	60a6                	ld	ra,72(sp)
    80004ee4:	6406                	ld	s0,64(sp)
    80004ee6:	74e2                	ld	s1,56(sp)
    80004ee8:	7942                	ld	s2,48(sp)
    80004eea:	79a2                	ld	s3,40(sp)
    80004eec:	7a02                	ld	s4,32(sp)
    80004eee:	6ae2                	ld	s5,24(sp)
    80004ef0:	6b42                	ld	s6,16(sp)
    80004ef2:	6ba2                	ld	s7,8(sp)
    80004ef4:	6c02                	ld	s8,0(sp)
    80004ef6:	6161                	addi	sp,sp,80
    80004ef8:	8082                	ret
    ret = (i == n ? n : -1);
    80004efa:	5a7d                	li	s4,-1
    80004efc:	b7d5                	j	80004ee0 <filewrite+0xfa>
    panic("filewrite");
    80004efe:	00004517          	auipc	a0,0x4
    80004f02:	82250513          	addi	a0,a0,-2014 # 80008720 <syscalls+0x280>
    80004f06:	ffffb097          	auipc	ra,0xffffb
    80004f0a:	624080e7          	jalr	1572(ra) # 8000052a <panic>
    return -1;
    80004f0e:	5a7d                	li	s4,-1
    80004f10:	bfc1                	j	80004ee0 <filewrite+0xfa>
      return -1;
    80004f12:	5a7d                	li	s4,-1
    80004f14:	b7f1                	j	80004ee0 <filewrite+0xfa>
    80004f16:	5a7d                	li	s4,-1
    80004f18:	b7e1                	j	80004ee0 <filewrite+0xfa>

0000000080004f1a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f1a:	7179                	addi	sp,sp,-48
    80004f1c:	f406                	sd	ra,40(sp)
    80004f1e:	f022                	sd	s0,32(sp)
    80004f20:	ec26                	sd	s1,24(sp)
    80004f22:	e84a                	sd	s2,16(sp)
    80004f24:	e44e                	sd	s3,8(sp)
    80004f26:	e052                	sd	s4,0(sp)
    80004f28:	1800                	addi	s0,sp,48
    80004f2a:	84aa                	mv	s1,a0
    80004f2c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f2e:	0005b023          	sd	zero,0(a1)
    80004f32:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f36:	00000097          	auipc	ra,0x0
    80004f3a:	bf8080e7          	jalr	-1032(ra) # 80004b2e <filealloc>
    80004f3e:	e088                	sd	a0,0(s1)
    80004f40:	c551                	beqz	a0,80004fcc <pipealloc+0xb2>
    80004f42:	00000097          	auipc	ra,0x0
    80004f46:	bec080e7          	jalr	-1044(ra) # 80004b2e <filealloc>
    80004f4a:	00aa3023          	sd	a0,0(s4)
    80004f4e:	c92d                	beqz	a0,80004fc0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f50:	ffffc097          	auipc	ra,0xffffc
    80004f54:	b82080e7          	jalr	-1150(ra) # 80000ad2 <kalloc>
    80004f58:	892a                	mv	s2,a0
    80004f5a:	c125                	beqz	a0,80004fba <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f5c:	4985                	li	s3,1
    80004f5e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f62:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f66:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f6a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f6e:	00003597          	auipc	a1,0x3
    80004f72:	7c258593          	addi	a1,a1,1986 # 80008730 <syscalls+0x290>
    80004f76:	ffffc097          	auipc	ra,0xffffc
    80004f7a:	bbc080e7          	jalr	-1092(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004f7e:	609c                	ld	a5,0(s1)
    80004f80:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f84:	609c                	ld	a5,0(s1)
    80004f86:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f8a:	609c                	ld	a5,0(s1)
    80004f8c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f90:	609c                	ld	a5,0(s1)
    80004f92:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f96:	000a3783          	ld	a5,0(s4)
    80004f9a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f9e:	000a3783          	ld	a5,0(s4)
    80004fa2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004fa6:	000a3783          	ld	a5,0(s4)
    80004faa:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004fae:	000a3783          	ld	a5,0(s4)
    80004fb2:	0127b823          	sd	s2,16(a5)
  return 0;
    80004fb6:	4501                	li	a0,0
    80004fb8:	a025                	j	80004fe0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004fba:	6088                	ld	a0,0(s1)
    80004fbc:	e501                	bnez	a0,80004fc4 <pipealloc+0xaa>
    80004fbe:	a039                	j	80004fcc <pipealloc+0xb2>
    80004fc0:	6088                	ld	a0,0(s1)
    80004fc2:	c51d                	beqz	a0,80004ff0 <pipealloc+0xd6>
    fileclose(*f0);
    80004fc4:	00000097          	auipc	ra,0x0
    80004fc8:	c26080e7          	jalr	-986(ra) # 80004bea <fileclose>
  if(*f1)
    80004fcc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004fd0:	557d                	li	a0,-1
  if(*f1)
    80004fd2:	c799                	beqz	a5,80004fe0 <pipealloc+0xc6>
    fileclose(*f1);
    80004fd4:	853e                	mv	a0,a5
    80004fd6:	00000097          	auipc	ra,0x0
    80004fda:	c14080e7          	jalr	-1004(ra) # 80004bea <fileclose>
  return -1;
    80004fde:	557d                	li	a0,-1
}
    80004fe0:	70a2                	ld	ra,40(sp)
    80004fe2:	7402                	ld	s0,32(sp)
    80004fe4:	64e2                	ld	s1,24(sp)
    80004fe6:	6942                	ld	s2,16(sp)
    80004fe8:	69a2                	ld	s3,8(sp)
    80004fea:	6a02                	ld	s4,0(sp)
    80004fec:	6145                	addi	sp,sp,48
    80004fee:	8082                	ret
  return -1;
    80004ff0:	557d                	li	a0,-1
    80004ff2:	b7fd                	j	80004fe0 <pipealloc+0xc6>

0000000080004ff4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ff4:	1101                	addi	sp,sp,-32
    80004ff6:	ec06                	sd	ra,24(sp)
    80004ff8:	e822                	sd	s0,16(sp)
    80004ffa:	e426                	sd	s1,8(sp)
    80004ffc:	e04a                	sd	s2,0(sp)
    80004ffe:	1000                	addi	s0,sp,32
    80005000:	84aa                	mv	s1,a0
    80005002:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005004:	ffffc097          	auipc	ra,0xffffc
    80005008:	bbe080e7          	jalr	-1090(ra) # 80000bc2 <acquire>
  if(writable){
    8000500c:	02090d63          	beqz	s2,80005046 <pipeclose+0x52>
    pi->writeopen = 0;
    80005010:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005014:	21848513          	addi	a0,s1,536
    80005018:	ffffd097          	auipc	ra,0xffffd
    8000501c:	2a0080e7          	jalr	672(ra) # 800022b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005020:	2204b783          	ld	a5,544(s1)
    80005024:	eb95                	bnez	a5,80005058 <pipeclose+0x64>
    release(&pi->lock);
    80005026:	8526                	mv	a0,s1
    80005028:	ffffc097          	auipc	ra,0xffffc
    8000502c:	c4e080e7          	jalr	-946(ra) # 80000c76 <release>
    kfree((char*)pi);
    80005030:	8526                	mv	a0,s1
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	9a4080e7          	jalr	-1628(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    8000503a:	60e2                	ld	ra,24(sp)
    8000503c:	6442                	ld	s0,16(sp)
    8000503e:	64a2                	ld	s1,8(sp)
    80005040:	6902                	ld	s2,0(sp)
    80005042:	6105                	addi	sp,sp,32
    80005044:	8082                	ret
    pi->readopen = 0;
    80005046:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000504a:	21c48513          	addi	a0,s1,540
    8000504e:	ffffd097          	auipc	ra,0xffffd
    80005052:	26a080e7          	jalr	618(ra) # 800022b8 <wakeup>
    80005056:	b7e9                	j	80005020 <pipeclose+0x2c>
    release(&pi->lock);
    80005058:	8526                	mv	a0,s1
    8000505a:	ffffc097          	auipc	ra,0xffffc
    8000505e:	c1c080e7          	jalr	-996(ra) # 80000c76 <release>
}
    80005062:	bfe1                	j	8000503a <pipeclose+0x46>

0000000080005064 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005064:	711d                	addi	sp,sp,-96
    80005066:	ec86                	sd	ra,88(sp)
    80005068:	e8a2                	sd	s0,80(sp)
    8000506a:	e4a6                	sd	s1,72(sp)
    8000506c:	e0ca                	sd	s2,64(sp)
    8000506e:	fc4e                	sd	s3,56(sp)
    80005070:	f852                	sd	s4,48(sp)
    80005072:	f456                	sd	s5,40(sp)
    80005074:	f05a                	sd	s6,32(sp)
    80005076:	ec5e                	sd	s7,24(sp)
    80005078:	e862                	sd	s8,16(sp)
    8000507a:	1080                	addi	s0,sp,96
    8000507c:	84aa                	mv	s1,a0
    8000507e:	8aae                	mv	s5,a1
    80005080:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005082:	ffffd097          	auipc	ra,0xffffd
    80005086:	932080e7          	jalr	-1742(ra) # 800019b4 <myproc>
    8000508a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000508c:	8526                	mv	a0,s1
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	b34080e7          	jalr	-1228(ra) # 80000bc2 <acquire>
  while(i < n){
    80005096:	0b405363          	blez	s4,8000513c <pipewrite+0xd8>
  int i = 0;
    8000509a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000509c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000509e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800050a2:	21c48b93          	addi	s7,s1,540
    800050a6:	a089                	j	800050e8 <pipewrite+0x84>
      release(&pi->lock);
    800050a8:	8526                	mv	a0,s1
    800050aa:	ffffc097          	auipc	ra,0xffffc
    800050ae:	bcc080e7          	jalr	-1076(ra) # 80000c76 <release>
      return -1;
    800050b2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800050b4:	854a                	mv	a0,s2
    800050b6:	60e6                	ld	ra,88(sp)
    800050b8:	6446                	ld	s0,80(sp)
    800050ba:	64a6                	ld	s1,72(sp)
    800050bc:	6906                	ld	s2,64(sp)
    800050be:	79e2                	ld	s3,56(sp)
    800050c0:	7a42                	ld	s4,48(sp)
    800050c2:	7aa2                	ld	s5,40(sp)
    800050c4:	7b02                	ld	s6,32(sp)
    800050c6:	6be2                	ld	s7,24(sp)
    800050c8:	6c42                	ld	s8,16(sp)
    800050ca:	6125                	addi	sp,sp,96
    800050cc:	8082                	ret
      wakeup(&pi->nread);
    800050ce:	8562                	mv	a0,s8
    800050d0:	ffffd097          	auipc	ra,0xffffd
    800050d4:	1e8080e7          	jalr	488(ra) # 800022b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050d8:	85a6                	mv	a1,s1
    800050da:	855e                	mv	a0,s7
    800050dc:	ffffd097          	auipc	ra,0xffffd
    800050e0:	050080e7          	jalr	80(ra) # 8000212c <sleep>
  while(i < n){
    800050e4:	05495d63          	bge	s2,s4,8000513e <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    800050e8:	2204a783          	lw	a5,544(s1)
    800050ec:	dfd5                	beqz	a5,800050a8 <pipewrite+0x44>
    800050ee:	0289a783          	lw	a5,40(s3)
    800050f2:	fbdd                	bnez	a5,800050a8 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050f4:	2184a783          	lw	a5,536(s1)
    800050f8:	21c4a703          	lw	a4,540(s1)
    800050fc:	2007879b          	addiw	a5,a5,512
    80005100:	fcf707e3          	beq	a4,a5,800050ce <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005104:	4685                	li	a3,1
    80005106:	01590633          	add	a2,s2,s5
    8000510a:	faf40593          	addi	a1,s0,-81
    8000510e:	0509b503          	ld	a0,80(s3)
    80005112:	ffffc097          	auipc	ra,0xffffc
    80005116:	5b8080e7          	jalr	1464(ra) # 800016ca <copyin>
    8000511a:	03650263          	beq	a0,s6,8000513e <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000511e:	21c4a783          	lw	a5,540(s1)
    80005122:	0017871b          	addiw	a4,a5,1
    80005126:	20e4ae23          	sw	a4,540(s1)
    8000512a:	1ff7f793          	andi	a5,a5,511
    8000512e:	97a6                	add	a5,a5,s1
    80005130:	faf44703          	lbu	a4,-81(s0)
    80005134:	00e78c23          	sb	a4,24(a5)
      i++;
    80005138:	2905                	addiw	s2,s2,1
    8000513a:	b76d                	j	800050e4 <pipewrite+0x80>
  int i = 0;
    8000513c:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000513e:	21848513          	addi	a0,s1,536
    80005142:	ffffd097          	auipc	ra,0xffffd
    80005146:	176080e7          	jalr	374(ra) # 800022b8 <wakeup>
  release(&pi->lock);
    8000514a:	8526                	mv	a0,s1
    8000514c:	ffffc097          	auipc	ra,0xffffc
    80005150:	b2a080e7          	jalr	-1238(ra) # 80000c76 <release>
  return i;
    80005154:	b785                	j	800050b4 <pipewrite+0x50>

0000000080005156 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005156:	715d                	addi	sp,sp,-80
    80005158:	e486                	sd	ra,72(sp)
    8000515a:	e0a2                	sd	s0,64(sp)
    8000515c:	fc26                	sd	s1,56(sp)
    8000515e:	f84a                	sd	s2,48(sp)
    80005160:	f44e                	sd	s3,40(sp)
    80005162:	f052                	sd	s4,32(sp)
    80005164:	ec56                	sd	s5,24(sp)
    80005166:	e85a                	sd	s6,16(sp)
    80005168:	0880                	addi	s0,sp,80
    8000516a:	84aa                	mv	s1,a0
    8000516c:	892e                	mv	s2,a1
    8000516e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005170:	ffffd097          	auipc	ra,0xffffd
    80005174:	844080e7          	jalr	-1980(ra) # 800019b4 <myproc>
    80005178:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000517a:	8526                	mv	a0,s1
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	a46080e7          	jalr	-1466(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005184:	2184a703          	lw	a4,536(s1)
    80005188:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000518c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005190:	02f71463          	bne	a4,a5,800051b8 <piperead+0x62>
    80005194:	2244a783          	lw	a5,548(s1)
    80005198:	c385                	beqz	a5,800051b8 <piperead+0x62>
    if(pr->killed){
    8000519a:	028a2783          	lw	a5,40(s4)
    8000519e:	ebc1                	bnez	a5,8000522e <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800051a0:	85a6                	mv	a1,s1
    800051a2:	854e                	mv	a0,s3
    800051a4:	ffffd097          	auipc	ra,0xffffd
    800051a8:	f88080e7          	jalr	-120(ra) # 8000212c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051ac:	2184a703          	lw	a4,536(s1)
    800051b0:	21c4a783          	lw	a5,540(s1)
    800051b4:	fef700e3          	beq	a4,a5,80005194 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051b8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051ba:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051bc:	05505363          	blez	s5,80005202 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800051c0:	2184a783          	lw	a5,536(s1)
    800051c4:	21c4a703          	lw	a4,540(s1)
    800051c8:	02f70d63          	beq	a4,a5,80005202 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800051cc:	0017871b          	addiw	a4,a5,1
    800051d0:	20e4ac23          	sw	a4,536(s1)
    800051d4:	1ff7f793          	andi	a5,a5,511
    800051d8:	97a6                	add	a5,a5,s1
    800051da:	0187c783          	lbu	a5,24(a5)
    800051de:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051e2:	4685                	li	a3,1
    800051e4:	fbf40613          	addi	a2,s0,-65
    800051e8:	85ca                	mv	a1,s2
    800051ea:	050a3503          	ld	a0,80(s4)
    800051ee:	ffffc097          	auipc	ra,0xffffc
    800051f2:	450080e7          	jalr	1104(ra) # 8000163e <copyout>
    800051f6:	01650663          	beq	a0,s6,80005202 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051fa:	2985                	addiw	s3,s3,1
    800051fc:	0905                	addi	s2,s2,1
    800051fe:	fd3a91e3          	bne	s5,s3,800051c0 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005202:	21c48513          	addi	a0,s1,540
    80005206:	ffffd097          	auipc	ra,0xffffd
    8000520a:	0b2080e7          	jalr	178(ra) # 800022b8 <wakeup>
  release(&pi->lock);
    8000520e:	8526                	mv	a0,s1
    80005210:	ffffc097          	auipc	ra,0xffffc
    80005214:	a66080e7          	jalr	-1434(ra) # 80000c76 <release>
  return i;
}
    80005218:	854e                	mv	a0,s3
    8000521a:	60a6                	ld	ra,72(sp)
    8000521c:	6406                	ld	s0,64(sp)
    8000521e:	74e2                	ld	s1,56(sp)
    80005220:	7942                	ld	s2,48(sp)
    80005222:	79a2                	ld	s3,40(sp)
    80005224:	7a02                	ld	s4,32(sp)
    80005226:	6ae2                	ld	s5,24(sp)
    80005228:	6b42                	ld	s6,16(sp)
    8000522a:	6161                	addi	sp,sp,80
    8000522c:	8082                	ret
      release(&pi->lock);
    8000522e:	8526                	mv	a0,s1
    80005230:	ffffc097          	auipc	ra,0xffffc
    80005234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
      return -1;
    80005238:	59fd                	li	s3,-1
    8000523a:	bff9                	j	80005218 <piperead+0xc2>

000000008000523c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    8000523c:	de010113          	addi	sp,sp,-544
    80005240:	20113c23          	sd	ra,536(sp)
    80005244:	20813823          	sd	s0,528(sp)
    80005248:	20913423          	sd	s1,520(sp)
    8000524c:	21213023          	sd	s2,512(sp)
    80005250:	ffce                	sd	s3,504(sp)
    80005252:	fbd2                	sd	s4,496(sp)
    80005254:	f7d6                	sd	s5,488(sp)
    80005256:	f3da                	sd	s6,480(sp)
    80005258:	efde                	sd	s7,472(sp)
    8000525a:	ebe2                	sd	s8,464(sp)
    8000525c:	e7e6                	sd	s9,456(sp)
    8000525e:	e3ea                	sd	s10,448(sp)
    80005260:	ff6e                	sd	s11,440(sp)
    80005262:	1400                	addi	s0,sp,544
    80005264:	892a                	mv	s2,a0
    80005266:	dea43423          	sd	a0,-536(s0)
    8000526a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000526e:	ffffc097          	auipc	ra,0xffffc
    80005272:	746080e7          	jalr	1862(ra) # 800019b4 <myproc>
    80005276:	84aa                	mv	s1,a0

  begin_op();
    80005278:	fffff097          	auipc	ra,0xfffff
    8000527c:	4a6080e7          	jalr	1190(ra) # 8000471e <begin_op>

  if((ip = namei(path)) == 0){
    80005280:	854a                	mv	a0,s2
    80005282:	fffff097          	auipc	ra,0xfffff
    80005286:	27c080e7          	jalr	636(ra) # 800044fe <namei>
    8000528a:	c93d                	beqz	a0,80005300 <exec+0xc4>
    8000528c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000528e:	fffff097          	auipc	ra,0xfffff
    80005292:	aba080e7          	jalr	-1350(ra) # 80003d48 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005296:	04000713          	li	a4,64
    8000529a:	4681                	li	a3,0
    8000529c:	e4840613          	addi	a2,s0,-440
    800052a0:	4581                	li	a1,0
    800052a2:	8556                	mv	a0,s5
    800052a4:	fffff097          	auipc	ra,0xfffff
    800052a8:	d58080e7          	jalr	-680(ra) # 80003ffc <readi>
    800052ac:	04000793          	li	a5,64
    800052b0:	00f51a63          	bne	a0,a5,800052c4 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800052b4:	e4842703          	lw	a4,-440(s0)
    800052b8:	464c47b7          	lui	a5,0x464c4
    800052bc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052c0:	04f70663          	beq	a4,a5,8000530c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800052c4:	8556                	mv	a0,s5
    800052c6:	fffff097          	auipc	ra,0xfffff
    800052ca:	ce4080e7          	jalr	-796(ra) # 80003faa <iunlockput>
    end_op();
    800052ce:	fffff097          	auipc	ra,0xfffff
    800052d2:	4d0080e7          	jalr	1232(ra) # 8000479e <end_op>
  }
  return -1;
    800052d6:	557d                	li	a0,-1
}
    800052d8:	21813083          	ld	ra,536(sp)
    800052dc:	21013403          	ld	s0,528(sp)
    800052e0:	20813483          	ld	s1,520(sp)
    800052e4:	20013903          	ld	s2,512(sp)
    800052e8:	79fe                	ld	s3,504(sp)
    800052ea:	7a5e                	ld	s4,496(sp)
    800052ec:	7abe                	ld	s5,488(sp)
    800052ee:	7b1e                	ld	s6,480(sp)
    800052f0:	6bfe                	ld	s7,472(sp)
    800052f2:	6c5e                	ld	s8,464(sp)
    800052f4:	6cbe                	ld	s9,456(sp)
    800052f6:	6d1e                	ld	s10,448(sp)
    800052f8:	7dfa                	ld	s11,440(sp)
    800052fa:	22010113          	addi	sp,sp,544
    800052fe:	8082                	ret
    end_op();
    80005300:	fffff097          	auipc	ra,0xfffff
    80005304:	49e080e7          	jalr	1182(ra) # 8000479e <end_op>
    return -1;
    80005308:	557d                	li	a0,-1
    8000530a:	b7f9                	j	800052d8 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000530c:	8526                	mv	a0,s1
    8000530e:	ffffc097          	auipc	ra,0xffffc
    80005312:	7c0080e7          	jalr	1984(ra) # 80001ace <proc_pagetable>
    80005316:	8b2a                	mv	s6,a0
    80005318:	d555                	beqz	a0,800052c4 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000531a:	e6842783          	lw	a5,-408(s0)
    8000531e:	e8045703          	lhu	a4,-384(s0)
    80005322:	c735                	beqz	a4,8000538e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005324:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005326:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000532a:	6a05                	lui	s4,0x1
    8000532c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005330:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005334:	6d85                	lui	s11,0x1
    80005336:	7d7d                	lui	s10,0xfffff
    80005338:	aca9                	j	80005592 <exec+0x356>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000533a:	00003517          	auipc	a0,0x3
    8000533e:	3fe50513          	addi	a0,a0,1022 # 80008738 <syscalls+0x298>
    80005342:	ffffb097          	auipc	ra,0xffffb
    80005346:	1e8080e7          	jalr	488(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000534a:	874a                	mv	a4,s2
    8000534c:	009c86bb          	addw	a3,s9,s1
    80005350:	4581                	li	a1,0
    80005352:	8556                	mv	a0,s5
    80005354:	fffff097          	auipc	ra,0xfffff
    80005358:	ca8080e7          	jalr	-856(ra) # 80003ffc <readi>
    8000535c:	2501                	sext.w	a0,a0
    8000535e:	1ca91a63          	bne	s2,a0,80005532 <exec+0x2f6>
  for(i = 0; i < sz; i += PGSIZE){
    80005362:	009d84bb          	addw	s1,s11,s1
    80005366:	013d09bb          	addw	s3,s10,s3
    8000536a:	2174f463          	bgeu	s1,s7,80005572 <exec+0x336>
    pa = walkaddr(pagetable, va + i);
    8000536e:	02049593          	slli	a1,s1,0x20
    80005372:	9181                	srli	a1,a1,0x20
    80005374:	95e2                	add	a1,a1,s8
    80005376:	855a                	mv	a0,s6
    80005378:	ffffc097          	auipc	ra,0xffffc
    8000537c:	cd4080e7          	jalr	-812(ra) # 8000104c <walkaddr>
    80005380:	862a                	mv	a2,a0
    if(pa == 0)
    80005382:	dd45                	beqz	a0,8000533a <exec+0xfe>
      n = PGSIZE;
    80005384:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005386:	fd49f2e3          	bgeu	s3,s4,8000534a <exec+0x10e>
      n = sz - i;
    8000538a:	894e                	mv	s2,s3
    8000538c:	bf7d                	j	8000534a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000538e:	4481                	li	s1,0
  iunlockput(ip);
    80005390:	8556                	mv	a0,s5
    80005392:	fffff097          	auipc	ra,0xfffff
    80005396:	c18080e7          	jalr	-1000(ra) # 80003faa <iunlockput>
  end_op();
    8000539a:	fffff097          	auipc	ra,0xfffff
    8000539e:	404080e7          	jalr	1028(ra) # 8000479e <end_op>
  p = myproc();
    800053a2:	ffffc097          	auipc	ra,0xffffc
    800053a6:	612080e7          	jalr	1554(ra) # 800019b4 <myproc>
    800053aa:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800053ac:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800053b0:	6785                	lui	a5,0x1
    800053b2:	17fd                	addi	a5,a5,-1
    800053b4:	94be                	add	s1,s1,a5
    800053b6:	77fd                	lui	a5,0xfffff
    800053b8:	8fe5                	and	a5,a5,s1
    800053ba:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800053be:	6609                	lui	a2,0x2
    800053c0:	963e                	add	a2,a2,a5
    800053c2:	85be                	mv	a1,a5
    800053c4:	855a                	mv	a0,s6
    800053c6:	ffffc097          	auipc	ra,0xffffc
    800053ca:	028080e7          	jalr	40(ra) # 800013ee <uvmalloc>
    800053ce:	8c2a                	mv	s8,a0
  ip = 0;
    800053d0:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800053d2:	16050063          	beqz	a0,80005532 <exec+0x2f6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800053d6:	75f9                	lui	a1,0xffffe
    800053d8:	95aa                	add	a1,a1,a0
    800053da:	855a                	mv	a0,s6
    800053dc:	ffffc097          	auipc	ra,0xffffc
    800053e0:	230080e7          	jalr	560(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    800053e4:	7afd                	lui	s5,0xfffff
    800053e6:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800053e8:	df043783          	ld	a5,-528(s0)
    800053ec:	6388                	ld	a0,0(a5)
    800053ee:	c925                	beqz	a0,8000545e <exec+0x222>
    800053f0:	e8840993          	addi	s3,s0,-376
    800053f4:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    800053f8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800053fa:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053fc:	ffffc097          	auipc	ra,0xffffc
    80005400:	a46080e7          	jalr	-1466(ra) # 80000e42 <strlen>
    80005404:	0015079b          	addiw	a5,a0,1
    80005408:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000540c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005410:	15596563          	bltu	s2,s5,8000555a <exec+0x31e>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005414:	df043d83          	ld	s11,-528(s0)
    80005418:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000541c:	8552                	mv	a0,s4
    8000541e:	ffffc097          	auipc	ra,0xffffc
    80005422:	a24080e7          	jalr	-1500(ra) # 80000e42 <strlen>
    80005426:	0015069b          	addiw	a3,a0,1
    8000542a:	8652                	mv	a2,s4
    8000542c:	85ca                	mv	a1,s2
    8000542e:	855a                	mv	a0,s6
    80005430:	ffffc097          	auipc	ra,0xffffc
    80005434:	20e080e7          	jalr	526(ra) # 8000163e <copyout>
    80005438:	12054563          	bltz	a0,80005562 <exec+0x326>
    ustack[argc] = sp;
    8000543c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005440:	0485                	addi	s1,s1,1
    80005442:	008d8793          	addi	a5,s11,8
    80005446:	def43823          	sd	a5,-528(s0)
    8000544a:	008db503          	ld	a0,8(s11)
    8000544e:	c911                	beqz	a0,80005462 <exec+0x226>
    if(argc >= MAXARG)
    80005450:	09a1                	addi	s3,s3,8
    80005452:	fb9995e3          	bne	s3,s9,800053fc <exec+0x1c0>
  sz = sz1;
    80005456:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000545a:	4a81                	li	s5,0
    8000545c:	a8d9                	j	80005532 <exec+0x2f6>
  sp = sz;
    8000545e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005460:	4481                	li	s1,0
  ustack[argc] = 0;
    80005462:	00349793          	slli	a5,s1,0x3
    80005466:	f9040713          	addi	a4,s0,-112
    8000546a:	97ba                	add	a5,a5,a4
    8000546c:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd2ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005470:	00148693          	addi	a3,s1,1
    80005474:	068e                	slli	a3,a3,0x3
    80005476:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000547a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000547e:	01597663          	bgeu	s2,s5,8000548a <exec+0x24e>
  sz = sz1;
    80005482:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005486:	4a81                	li	s5,0
    80005488:	a06d                	j	80005532 <exec+0x2f6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000548a:	e8840613          	addi	a2,s0,-376
    8000548e:	85ca                	mv	a1,s2
    80005490:	855a                	mv	a0,s6
    80005492:	ffffc097          	auipc	ra,0xffffc
    80005496:	1ac080e7          	jalr	428(ra) # 8000163e <copyout>
    8000549a:	0c054863          	bltz	a0,8000556a <exec+0x32e>
  p->trapframe->a1 = sp;
    8000549e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800054a2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800054a6:	de843783          	ld	a5,-536(s0)
    800054aa:	0007c703          	lbu	a4,0(a5)
    800054ae:	cf11                	beqz	a4,800054ca <exec+0x28e>
    800054b0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800054b2:	02f00693          	li	a3,47
    800054b6:	a039                	j	800054c4 <exec+0x288>
      last = s+1;
    800054b8:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800054bc:	0785                	addi	a5,a5,1
    800054be:	fff7c703          	lbu	a4,-1(a5)
    800054c2:	c701                	beqz	a4,800054ca <exec+0x28e>
    if(*s == '/')
    800054c4:	fed71ce3          	bne	a4,a3,800054bc <exec+0x280>
    800054c8:	bfc5                	j	800054b8 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    800054ca:	4641                	li	a2,16
    800054cc:	de843583          	ld	a1,-536(s0)
    800054d0:	158b8513          	addi	a0,s7,344
    800054d4:	ffffc097          	auipc	ra,0xffffc
    800054d8:	93c080e7          	jalr	-1732(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    800054dc:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800054e0:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800054e4:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800054e8:	058bb783          	ld	a5,88(s7)
    800054ec:	e6043703          	ld	a4,-416(s0)
    800054f0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800054f2:	058bb783          	ld	a5,88(s7)
    800054f6:	0327b823          	sd	s2,48(a5)
  for (int i = 0; i < 32; i++)
    800054fa:	170b8793          	addi	a5,s7,368
    800054fe:	270b8b93          	addi	s7,s7,624
    80005502:	86de                	mv	a3,s7
    if( &p->signal_handlers[i] != (void*) SIG_DFL &&  &p->signal_handlers[i] != (void *)SIG_IGN){
    80005504:	4705                	li	a4,1
    80005506:	a029                	j	80005510 <exec+0x2d4>
  for (int i = 0; i < 32; i++)
    80005508:	07a1                	addi	a5,a5,8
    8000550a:	0b91                	addi	s7,s7,4
    8000550c:	00f68963          	beq	a3,a5,8000551e <exec+0x2e2>
    if( &p->signal_handlers[i] != (void*) SIG_DFL &&  &p->signal_handlers[i] != (void *)SIG_IGN){
    80005510:	fef77ce3          	bgeu	a4,a5,80005508 <exec+0x2cc>
       p->signal_handlers[i] = (void *)SIG_DFL;
    80005514:	0007b023          	sd	zero,0(a5)
       p->signal_handlers_mask[i]=0;
    80005518:	000ba023          	sw	zero,0(s7)
    8000551c:	b7f5                	j	80005508 <exec+0x2cc>
  proc_freepagetable(oldpagetable, oldsz);
    8000551e:	85ea                	mv	a1,s10
    80005520:	ffffc097          	auipc	ra,0xffffc
    80005524:	64a080e7          	jalr	1610(ra) # 80001b6a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005528:	0004851b          	sext.w	a0,s1
    8000552c:	b375                	j	800052d8 <exec+0x9c>
    8000552e:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005532:	df843583          	ld	a1,-520(s0)
    80005536:	855a                	mv	a0,s6
    80005538:	ffffc097          	auipc	ra,0xffffc
    8000553c:	632080e7          	jalr	1586(ra) # 80001b6a <proc_freepagetable>
  if(ip){
    80005540:	d80a92e3          	bnez	s5,800052c4 <exec+0x88>
  return -1;
    80005544:	557d                	li	a0,-1
    80005546:	bb49                	j	800052d8 <exec+0x9c>
    80005548:	de943c23          	sd	s1,-520(s0)
    8000554c:	b7dd                	j	80005532 <exec+0x2f6>
    8000554e:	de943c23          	sd	s1,-520(s0)
    80005552:	b7c5                	j	80005532 <exec+0x2f6>
    80005554:	de943c23          	sd	s1,-520(s0)
    80005558:	bfe9                	j	80005532 <exec+0x2f6>
  sz = sz1;
    8000555a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000555e:	4a81                	li	s5,0
    80005560:	bfc9                	j	80005532 <exec+0x2f6>
  sz = sz1;
    80005562:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005566:	4a81                	li	s5,0
    80005568:	b7e9                	j	80005532 <exec+0x2f6>
  sz = sz1;
    8000556a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000556e:	4a81                	li	s5,0
    80005570:	b7c9                	j	80005532 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005572:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005576:	e0843783          	ld	a5,-504(s0)
    8000557a:	0017869b          	addiw	a3,a5,1
    8000557e:	e0d43423          	sd	a3,-504(s0)
    80005582:	e0043783          	ld	a5,-512(s0)
    80005586:	0387879b          	addiw	a5,a5,56
    8000558a:	e8045703          	lhu	a4,-384(s0)
    8000558e:	e0e6d1e3          	bge	a3,a4,80005390 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005592:	2781                	sext.w	a5,a5
    80005594:	e0f43023          	sd	a5,-512(s0)
    80005598:	03800713          	li	a4,56
    8000559c:	86be                	mv	a3,a5
    8000559e:	e1040613          	addi	a2,s0,-496
    800055a2:	4581                	li	a1,0
    800055a4:	8556                	mv	a0,s5
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	a56080e7          	jalr	-1450(ra) # 80003ffc <readi>
    800055ae:	03800793          	li	a5,56
    800055b2:	f6f51ee3          	bne	a0,a5,8000552e <exec+0x2f2>
    if(ph.type != ELF_PROG_LOAD)
    800055b6:	e1042783          	lw	a5,-496(s0)
    800055ba:	4705                	li	a4,1
    800055bc:	fae79de3          	bne	a5,a4,80005576 <exec+0x33a>
    if(ph.memsz < ph.filesz)
    800055c0:	e3843603          	ld	a2,-456(s0)
    800055c4:	e3043783          	ld	a5,-464(s0)
    800055c8:	f8f660e3          	bltu	a2,a5,80005548 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800055cc:	e2043783          	ld	a5,-480(s0)
    800055d0:	963e                	add	a2,a2,a5
    800055d2:	f6f66ee3          	bltu	a2,a5,8000554e <exec+0x312>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800055d6:	85a6                	mv	a1,s1
    800055d8:	855a                	mv	a0,s6
    800055da:	ffffc097          	auipc	ra,0xffffc
    800055de:	e14080e7          	jalr	-492(ra) # 800013ee <uvmalloc>
    800055e2:	dea43c23          	sd	a0,-520(s0)
    800055e6:	d53d                	beqz	a0,80005554 <exec+0x318>
    if(ph.vaddr % PGSIZE != 0)
    800055e8:	e2043c03          	ld	s8,-480(s0)
    800055ec:	de043783          	ld	a5,-544(s0)
    800055f0:	00fc77b3          	and	a5,s8,a5
    800055f4:	ff9d                	bnez	a5,80005532 <exec+0x2f6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800055f6:	e1842c83          	lw	s9,-488(s0)
    800055fa:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800055fe:	f60b8ae3          	beqz	s7,80005572 <exec+0x336>
    80005602:	89de                	mv	s3,s7
    80005604:	4481                	li	s1,0
    80005606:	b3a5                	j	8000536e <exec+0x132>

0000000080005608 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005608:	7179                	addi	sp,sp,-48
    8000560a:	f406                	sd	ra,40(sp)
    8000560c:	f022                	sd	s0,32(sp)
    8000560e:	ec26                	sd	s1,24(sp)
    80005610:	e84a                	sd	s2,16(sp)
    80005612:	1800                	addi	s0,sp,48
    80005614:	892e                	mv	s2,a1
    80005616:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005618:	fdc40593          	addi	a1,s0,-36
    8000561c:	ffffe097          	auipc	ra,0xffffe
    80005620:	af8080e7          	jalr	-1288(ra) # 80003114 <argint>
    80005624:	04054063          	bltz	a0,80005664 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005628:	fdc42703          	lw	a4,-36(s0)
    8000562c:	47bd                	li	a5,15
    8000562e:	02e7ed63          	bltu	a5,a4,80005668 <argfd+0x60>
    80005632:	ffffc097          	auipc	ra,0xffffc
    80005636:	382080e7          	jalr	898(ra) # 800019b4 <myproc>
    8000563a:	fdc42703          	lw	a4,-36(s0)
    8000563e:	01a70793          	addi	a5,a4,26
    80005642:	078e                	slli	a5,a5,0x3
    80005644:	953e                	add	a0,a0,a5
    80005646:	611c                	ld	a5,0(a0)
    80005648:	c395                	beqz	a5,8000566c <argfd+0x64>
    return -1;
  if(pfd)
    8000564a:	00090463          	beqz	s2,80005652 <argfd+0x4a>
    *pfd = fd;
    8000564e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005652:	4501                	li	a0,0
  if(pf)
    80005654:	c091                	beqz	s1,80005658 <argfd+0x50>
    *pf = f;
    80005656:	e09c                	sd	a5,0(s1)
}
    80005658:	70a2                	ld	ra,40(sp)
    8000565a:	7402                	ld	s0,32(sp)
    8000565c:	64e2                	ld	s1,24(sp)
    8000565e:	6942                	ld	s2,16(sp)
    80005660:	6145                	addi	sp,sp,48
    80005662:	8082                	ret
    return -1;
    80005664:	557d                	li	a0,-1
    80005666:	bfcd                	j	80005658 <argfd+0x50>
    return -1;
    80005668:	557d                	li	a0,-1
    8000566a:	b7fd                	j	80005658 <argfd+0x50>
    8000566c:	557d                	li	a0,-1
    8000566e:	b7ed                	j	80005658 <argfd+0x50>

0000000080005670 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005670:	1101                	addi	sp,sp,-32
    80005672:	ec06                	sd	ra,24(sp)
    80005674:	e822                	sd	s0,16(sp)
    80005676:	e426                	sd	s1,8(sp)
    80005678:	1000                	addi	s0,sp,32
    8000567a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000567c:	ffffc097          	auipc	ra,0xffffc
    80005680:	338080e7          	jalr	824(ra) # 800019b4 <myproc>
    80005684:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005686:	0d050793          	addi	a5,a0,208
    8000568a:	4501                	li	a0,0
    8000568c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000568e:	6398                	ld	a4,0(a5)
    80005690:	cb19                	beqz	a4,800056a6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005692:	2505                	addiw	a0,a0,1
    80005694:	07a1                	addi	a5,a5,8
    80005696:	fed51ce3          	bne	a0,a3,8000568e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000569a:	557d                	li	a0,-1
}
    8000569c:	60e2                	ld	ra,24(sp)
    8000569e:	6442                	ld	s0,16(sp)
    800056a0:	64a2                	ld	s1,8(sp)
    800056a2:	6105                	addi	sp,sp,32
    800056a4:	8082                	ret
      p->ofile[fd] = f;
    800056a6:	01a50793          	addi	a5,a0,26
    800056aa:	078e                	slli	a5,a5,0x3
    800056ac:	963e                	add	a2,a2,a5
    800056ae:	e204                	sd	s1,0(a2)
      return fd;
    800056b0:	b7f5                	j	8000569c <fdalloc+0x2c>

00000000800056b2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800056b2:	715d                	addi	sp,sp,-80
    800056b4:	e486                	sd	ra,72(sp)
    800056b6:	e0a2                	sd	s0,64(sp)
    800056b8:	fc26                	sd	s1,56(sp)
    800056ba:	f84a                	sd	s2,48(sp)
    800056bc:	f44e                	sd	s3,40(sp)
    800056be:	f052                	sd	s4,32(sp)
    800056c0:	ec56                	sd	s5,24(sp)
    800056c2:	0880                	addi	s0,sp,80
    800056c4:	89ae                	mv	s3,a1
    800056c6:	8ab2                	mv	s5,a2
    800056c8:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800056ca:	fb040593          	addi	a1,s0,-80
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	e4e080e7          	jalr	-434(ra) # 8000451c <nameiparent>
    800056d6:	892a                	mv	s2,a0
    800056d8:	12050e63          	beqz	a0,80005814 <create+0x162>
    return 0;

  ilock(dp);
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	66c080e7          	jalr	1644(ra) # 80003d48 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056e4:	4601                	li	a2,0
    800056e6:	fb040593          	addi	a1,s0,-80
    800056ea:	854a                	mv	a0,s2
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	b40080e7          	jalr	-1216(ra) # 8000422c <dirlookup>
    800056f4:	84aa                	mv	s1,a0
    800056f6:	c921                	beqz	a0,80005746 <create+0x94>
    iunlockput(dp);
    800056f8:	854a                	mv	a0,s2
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	8b0080e7          	jalr	-1872(ra) # 80003faa <iunlockput>
    ilock(ip);
    80005702:	8526                	mv	a0,s1
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	644080e7          	jalr	1604(ra) # 80003d48 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000570c:	2981                	sext.w	s3,s3
    8000570e:	4789                	li	a5,2
    80005710:	02f99463          	bne	s3,a5,80005738 <create+0x86>
    80005714:	0444d783          	lhu	a5,68(s1)
    80005718:	37f9                	addiw	a5,a5,-2
    8000571a:	17c2                	slli	a5,a5,0x30
    8000571c:	93c1                	srli	a5,a5,0x30
    8000571e:	4705                	li	a4,1
    80005720:	00f76c63          	bltu	a4,a5,80005738 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005724:	8526                	mv	a0,s1
    80005726:	60a6                	ld	ra,72(sp)
    80005728:	6406                	ld	s0,64(sp)
    8000572a:	74e2                	ld	s1,56(sp)
    8000572c:	7942                	ld	s2,48(sp)
    8000572e:	79a2                	ld	s3,40(sp)
    80005730:	7a02                	ld	s4,32(sp)
    80005732:	6ae2                	ld	s5,24(sp)
    80005734:	6161                	addi	sp,sp,80
    80005736:	8082                	ret
    iunlockput(ip);
    80005738:	8526                	mv	a0,s1
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	870080e7          	jalr	-1936(ra) # 80003faa <iunlockput>
    return 0;
    80005742:	4481                	li	s1,0
    80005744:	b7c5                	j	80005724 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005746:	85ce                	mv	a1,s3
    80005748:	00092503          	lw	a0,0(s2)
    8000574c:	ffffe097          	auipc	ra,0xffffe
    80005750:	464080e7          	jalr	1124(ra) # 80003bb0 <ialloc>
    80005754:	84aa                	mv	s1,a0
    80005756:	c521                	beqz	a0,8000579e <create+0xec>
  ilock(ip);
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	5f0080e7          	jalr	1520(ra) # 80003d48 <ilock>
  ip->major = major;
    80005760:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005764:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005768:	4a05                	li	s4,1
    8000576a:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000576e:	8526                	mv	a0,s1
    80005770:	ffffe097          	auipc	ra,0xffffe
    80005774:	50e080e7          	jalr	1294(ra) # 80003c7e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005778:	2981                	sext.w	s3,s3
    8000577a:	03498a63          	beq	s3,s4,800057ae <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000577e:	40d0                	lw	a2,4(s1)
    80005780:	fb040593          	addi	a1,s0,-80
    80005784:	854a                	mv	a0,s2
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	cb6080e7          	jalr	-842(ra) # 8000443c <dirlink>
    8000578e:	06054b63          	bltz	a0,80005804 <create+0x152>
  iunlockput(dp);
    80005792:	854a                	mv	a0,s2
    80005794:	fffff097          	auipc	ra,0xfffff
    80005798:	816080e7          	jalr	-2026(ra) # 80003faa <iunlockput>
  return ip;
    8000579c:	b761                	j	80005724 <create+0x72>
    panic("create: ialloc");
    8000579e:	00003517          	auipc	a0,0x3
    800057a2:	fba50513          	addi	a0,a0,-70 # 80008758 <syscalls+0x2b8>
    800057a6:	ffffb097          	auipc	ra,0xffffb
    800057aa:	d84080e7          	jalr	-636(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800057ae:	04a95783          	lhu	a5,74(s2)
    800057b2:	2785                	addiw	a5,a5,1
    800057b4:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800057b8:	854a                	mv	a0,s2
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	4c4080e7          	jalr	1220(ra) # 80003c7e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800057c2:	40d0                	lw	a2,4(s1)
    800057c4:	00003597          	auipc	a1,0x3
    800057c8:	fa458593          	addi	a1,a1,-92 # 80008768 <syscalls+0x2c8>
    800057cc:	8526                	mv	a0,s1
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	c6e080e7          	jalr	-914(ra) # 8000443c <dirlink>
    800057d6:	00054f63          	bltz	a0,800057f4 <create+0x142>
    800057da:	00492603          	lw	a2,4(s2)
    800057de:	00003597          	auipc	a1,0x3
    800057e2:	f9258593          	addi	a1,a1,-110 # 80008770 <syscalls+0x2d0>
    800057e6:	8526                	mv	a0,s1
    800057e8:	fffff097          	auipc	ra,0xfffff
    800057ec:	c54080e7          	jalr	-940(ra) # 8000443c <dirlink>
    800057f0:	f80557e3          	bgez	a0,8000577e <create+0xcc>
      panic("create dots");
    800057f4:	00003517          	auipc	a0,0x3
    800057f8:	f8450513          	addi	a0,a0,-124 # 80008778 <syscalls+0x2d8>
    800057fc:	ffffb097          	auipc	ra,0xffffb
    80005800:	d2e080e7          	jalr	-722(ra) # 8000052a <panic>
    panic("create: dirlink");
    80005804:	00003517          	auipc	a0,0x3
    80005808:	f8450513          	addi	a0,a0,-124 # 80008788 <syscalls+0x2e8>
    8000580c:	ffffb097          	auipc	ra,0xffffb
    80005810:	d1e080e7          	jalr	-738(ra) # 8000052a <panic>
    return 0;
    80005814:	84aa                	mv	s1,a0
    80005816:	b739                	j	80005724 <create+0x72>

0000000080005818 <sys_dup>:
{
    80005818:	7179                	addi	sp,sp,-48
    8000581a:	f406                	sd	ra,40(sp)
    8000581c:	f022                	sd	s0,32(sp)
    8000581e:	ec26                	sd	s1,24(sp)
    80005820:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005822:	fd840613          	addi	a2,s0,-40
    80005826:	4581                	li	a1,0
    80005828:	4501                	li	a0,0
    8000582a:	00000097          	auipc	ra,0x0
    8000582e:	dde080e7          	jalr	-546(ra) # 80005608 <argfd>
    return -1;
    80005832:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005834:	02054363          	bltz	a0,8000585a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005838:	fd843503          	ld	a0,-40(s0)
    8000583c:	00000097          	auipc	ra,0x0
    80005840:	e34080e7          	jalr	-460(ra) # 80005670 <fdalloc>
    80005844:	84aa                	mv	s1,a0
    return -1;
    80005846:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005848:	00054963          	bltz	a0,8000585a <sys_dup+0x42>
  filedup(f);
    8000584c:	fd843503          	ld	a0,-40(s0)
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	348080e7          	jalr	840(ra) # 80004b98 <filedup>
  return fd;
    80005858:	87a6                	mv	a5,s1
}
    8000585a:	853e                	mv	a0,a5
    8000585c:	70a2                	ld	ra,40(sp)
    8000585e:	7402                	ld	s0,32(sp)
    80005860:	64e2                	ld	s1,24(sp)
    80005862:	6145                	addi	sp,sp,48
    80005864:	8082                	ret

0000000080005866 <sys_read>:
{
    80005866:	7179                	addi	sp,sp,-48
    80005868:	f406                	sd	ra,40(sp)
    8000586a:	f022                	sd	s0,32(sp)
    8000586c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000586e:	fe840613          	addi	a2,s0,-24
    80005872:	4581                	li	a1,0
    80005874:	4501                	li	a0,0
    80005876:	00000097          	auipc	ra,0x0
    8000587a:	d92080e7          	jalr	-622(ra) # 80005608 <argfd>
    return -1;
    8000587e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005880:	04054163          	bltz	a0,800058c2 <sys_read+0x5c>
    80005884:	fe440593          	addi	a1,s0,-28
    80005888:	4509                	li	a0,2
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	88a080e7          	jalr	-1910(ra) # 80003114 <argint>
    return -1;
    80005892:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005894:	02054763          	bltz	a0,800058c2 <sys_read+0x5c>
    80005898:	fd840593          	addi	a1,s0,-40
    8000589c:	4505                	li	a0,1
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	898080e7          	jalr	-1896(ra) # 80003136 <argaddr>
    return -1;
    800058a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058a8:	00054d63          	bltz	a0,800058c2 <sys_read+0x5c>
  return fileread(f, p, n);
    800058ac:	fe442603          	lw	a2,-28(s0)
    800058b0:	fd843583          	ld	a1,-40(s0)
    800058b4:	fe843503          	ld	a0,-24(s0)
    800058b8:	fffff097          	auipc	ra,0xfffff
    800058bc:	46c080e7          	jalr	1132(ra) # 80004d24 <fileread>
    800058c0:	87aa                	mv	a5,a0
}
    800058c2:	853e                	mv	a0,a5
    800058c4:	70a2                	ld	ra,40(sp)
    800058c6:	7402                	ld	s0,32(sp)
    800058c8:	6145                	addi	sp,sp,48
    800058ca:	8082                	ret

00000000800058cc <sys_write>:
{
    800058cc:	7179                	addi	sp,sp,-48
    800058ce:	f406                	sd	ra,40(sp)
    800058d0:	f022                	sd	s0,32(sp)
    800058d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058d4:	fe840613          	addi	a2,s0,-24
    800058d8:	4581                	li	a1,0
    800058da:	4501                	li	a0,0
    800058dc:	00000097          	auipc	ra,0x0
    800058e0:	d2c080e7          	jalr	-724(ra) # 80005608 <argfd>
    return -1;
    800058e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058e6:	04054163          	bltz	a0,80005928 <sys_write+0x5c>
    800058ea:	fe440593          	addi	a1,s0,-28
    800058ee:	4509                	li	a0,2
    800058f0:	ffffe097          	auipc	ra,0xffffe
    800058f4:	824080e7          	jalr	-2012(ra) # 80003114 <argint>
    return -1;
    800058f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058fa:	02054763          	bltz	a0,80005928 <sys_write+0x5c>
    800058fe:	fd840593          	addi	a1,s0,-40
    80005902:	4505                	li	a0,1
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	832080e7          	jalr	-1998(ra) # 80003136 <argaddr>
    return -1;
    8000590c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000590e:	00054d63          	bltz	a0,80005928 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005912:	fe442603          	lw	a2,-28(s0)
    80005916:	fd843583          	ld	a1,-40(s0)
    8000591a:	fe843503          	ld	a0,-24(s0)
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	4c8080e7          	jalr	1224(ra) # 80004de6 <filewrite>
    80005926:	87aa                	mv	a5,a0
}
    80005928:	853e                	mv	a0,a5
    8000592a:	70a2                	ld	ra,40(sp)
    8000592c:	7402                	ld	s0,32(sp)
    8000592e:	6145                	addi	sp,sp,48
    80005930:	8082                	ret

0000000080005932 <sys_close>:
{
    80005932:	1101                	addi	sp,sp,-32
    80005934:	ec06                	sd	ra,24(sp)
    80005936:	e822                	sd	s0,16(sp)
    80005938:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000593a:	fe040613          	addi	a2,s0,-32
    8000593e:	fec40593          	addi	a1,s0,-20
    80005942:	4501                	li	a0,0
    80005944:	00000097          	auipc	ra,0x0
    80005948:	cc4080e7          	jalr	-828(ra) # 80005608 <argfd>
    return -1;
    8000594c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000594e:	02054463          	bltz	a0,80005976 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005952:	ffffc097          	auipc	ra,0xffffc
    80005956:	062080e7          	jalr	98(ra) # 800019b4 <myproc>
    8000595a:	fec42783          	lw	a5,-20(s0)
    8000595e:	07e9                	addi	a5,a5,26
    80005960:	078e                	slli	a5,a5,0x3
    80005962:	97aa                	add	a5,a5,a0
    80005964:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005968:	fe043503          	ld	a0,-32(s0)
    8000596c:	fffff097          	auipc	ra,0xfffff
    80005970:	27e080e7          	jalr	638(ra) # 80004bea <fileclose>
  return 0;
    80005974:	4781                	li	a5,0
}
    80005976:	853e                	mv	a0,a5
    80005978:	60e2                	ld	ra,24(sp)
    8000597a:	6442                	ld	s0,16(sp)
    8000597c:	6105                	addi	sp,sp,32
    8000597e:	8082                	ret

0000000080005980 <sys_fstat>:
{
    80005980:	1101                	addi	sp,sp,-32
    80005982:	ec06                	sd	ra,24(sp)
    80005984:	e822                	sd	s0,16(sp)
    80005986:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005988:	fe840613          	addi	a2,s0,-24
    8000598c:	4581                	li	a1,0
    8000598e:	4501                	li	a0,0
    80005990:	00000097          	auipc	ra,0x0
    80005994:	c78080e7          	jalr	-904(ra) # 80005608 <argfd>
    return -1;
    80005998:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000599a:	02054563          	bltz	a0,800059c4 <sys_fstat+0x44>
    8000599e:	fe040593          	addi	a1,s0,-32
    800059a2:	4505                	li	a0,1
    800059a4:	ffffd097          	auipc	ra,0xffffd
    800059a8:	792080e7          	jalr	1938(ra) # 80003136 <argaddr>
    return -1;
    800059ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800059ae:	00054b63          	bltz	a0,800059c4 <sys_fstat+0x44>
  return filestat(f, st);
    800059b2:	fe043583          	ld	a1,-32(s0)
    800059b6:	fe843503          	ld	a0,-24(s0)
    800059ba:	fffff097          	auipc	ra,0xfffff
    800059be:	2f8080e7          	jalr	760(ra) # 80004cb2 <filestat>
    800059c2:	87aa                	mv	a5,a0
}
    800059c4:	853e                	mv	a0,a5
    800059c6:	60e2                	ld	ra,24(sp)
    800059c8:	6442                	ld	s0,16(sp)
    800059ca:	6105                	addi	sp,sp,32
    800059cc:	8082                	ret

00000000800059ce <sys_link>:
{
    800059ce:	7169                	addi	sp,sp,-304
    800059d0:	f606                	sd	ra,296(sp)
    800059d2:	f222                	sd	s0,288(sp)
    800059d4:	ee26                	sd	s1,280(sp)
    800059d6:	ea4a                	sd	s2,272(sp)
    800059d8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059da:	08000613          	li	a2,128
    800059de:	ed040593          	addi	a1,s0,-304
    800059e2:	4501                	li	a0,0
    800059e4:	ffffd097          	auipc	ra,0xffffd
    800059e8:	774080e7          	jalr	1908(ra) # 80003158 <argstr>
    return -1;
    800059ec:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059ee:	10054e63          	bltz	a0,80005b0a <sys_link+0x13c>
    800059f2:	08000613          	li	a2,128
    800059f6:	f5040593          	addi	a1,s0,-176
    800059fa:	4505                	li	a0,1
    800059fc:	ffffd097          	auipc	ra,0xffffd
    80005a00:	75c080e7          	jalr	1884(ra) # 80003158 <argstr>
    return -1;
    80005a04:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a06:	10054263          	bltz	a0,80005b0a <sys_link+0x13c>
  begin_op();
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	d14080e7          	jalr	-748(ra) # 8000471e <begin_op>
  if((ip = namei(old)) == 0){
    80005a12:	ed040513          	addi	a0,s0,-304
    80005a16:	fffff097          	auipc	ra,0xfffff
    80005a1a:	ae8080e7          	jalr	-1304(ra) # 800044fe <namei>
    80005a1e:	84aa                	mv	s1,a0
    80005a20:	c551                	beqz	a0,80005aac <sys_link+0xde>
  ilock(ip);
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	326080e7          	jalr	806(ra) # 80003d48 <ilock>
  if(ip->type == T_DIR){
    80005a2a:	04449703          	lh	a4,68(s1)
    80005a2e:	4785                	li	a5,1
    80005a30:	08f70463          	beq	a4,a5,80005ab8 <sys_link+0xea>
  ip->nlink++;
    80005a34:	04a4d783          	lhu	a5,74(s1)
    80005a38:	2785                	addiw	a5,a5,1
    80005a3a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a3e:	8526                	mv	a0,s1
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	23e080e7          	jalr	574(ra) # 80003c7e <iupdate>
  iunlock(ip);
    80005a48:	8526                	mv	a0,s1
    80005a4a:	ffffe097          	auipc	ra,0xffffe
    80005a4e:	3c0080e7          	jalr	960(ra) # 80003e0a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a52:	fd040593          	addi	a1,s0,-48
    80005a56:	f5040513          	addi	a0,s0,-176
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	ac2080e7          	jalr	-1342(ra) # 8000451c <nameiparent>
    80005a62:	892a                	mv	s2,a0
    80005a64:	c935                	beqz	a0,80005ad8 <sys_link+0x10a>
  ilock(dp);
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	2e2080e7          	jalr	738(ra) # 80003d48 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a6e:	00092703          	lw	a4,0(s2)
    80005a72:	409c                	lw	a5,0(s1)
    80005a74:	04f71d63          	bne	a4,a5,80005ace <sys_link+0x100>
    80005a78:	40d0                	lw	a2,4(s1)
    80005a7a:	fd040593          	addi	a1,s0,-48
    80005a7e:	854a                	mv	a0,s2
    80005a80:	fffff097          	auipc	ra,0xfffff
    80005a84:	9bc080e7          	jalr	-1604(ra) # 8000443c <dirlink>
    80005a88:	04054363          	bltz	a0,80005ace <sys_link+0x100>
  iunlockput(dp);
    80005a8c:	854a                	mv	a0,s2
    80005a8e:	ffffe097          	auipc	ra,0xffffe
    80005a92:	51c080e7          	jalr	1308(ra) # 80003faa <iunlockput>
  iput(ip);
    80005a96:	8526                	mv	a0,s1
    80005a98:	ffffe097          	auipc	ra,0xffffe
    80005a9c:	46a080e7          	jalr	1130(ra) # 80003f02 <iput>
  end_op();
    80005aa0:	fffff097          	auipc	ra,0xfffff
    80005aa4:	cfe080e7          	jalr	-770(ra) # 8000479e <end_op>
  return 0;
    80005aa8:	4781                	li	a5,0
    80005aaa:	a085                	j	80005b0a <sys_link+0x13c>
    end_op();
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	cf2080e7          	jalr	-782(ra) # 8000479e <end_op>
    return -1;
    80005ab4:	57fd                	li	a5,-1
    80005ab6:	a891                	j	80005b0a <sys_link+0x13c>
    iunlockput(ip);
    80005ab8:	8526                	mv	a0,s1
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	4f0080e7          	jalr	1264(ra) # 80003faa <iunlockput>
    end_op();
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	cdc080e7          	jalr	-804(ra) # 8000479e <end_op>
    return -1;
    80005aca:	57fd                	li	a5,-1
    80005acc:	a83d                	j	80005b0a <sys_link+0x13c>
    iunlockput(dp);
    80005ace:	854a                	mv	a0,s2
    80005ad0:	ffffe097          	auipc	ra,0xffffe
    80005ad4:	4da080e7          	jalr	1242(ra) # 80003faa <iunlockput>
  ilock(ip);
    80005ad8:	8526                	mv	a0,s1
    80005ada:	ffffe097          	auipc	ra,0xffffe
    80005ade:	26e080e7          	jalr	622(ra) # 80003d48 <ilock>
  ip->nlink--;
    80005ae2:	04a4d783          	lhu	a5,74(s1)
    80005ae6:	37fd                	addiw	a5,a5,-1
    80005ae8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005aec:	8526                	mv	a0,s1
    80005aee:	ffffe097          	auipc	ra,0xffffe
    80005af2:	190080e7          	jalr	400(ra) # 80003c7e <iupdate>
  iunlockput(ip);
    80005af6:	8526                	mv	a0,s1
    80005af8:	ffffe097          	auipc	ra,0xffffe
    80005afc:	4b2080e7          	jalr	1202(ra) # 80003faa <iunlockput>
  end_op();
    80005b00:	fffff097          	auipc	ra,0xfffff
    80005b04:	c9e080e7          	jalr	-866(ra) # 8000479e <end_op>
  return -1;
    80005b08:	57fd                	li	a5,-1
}
    80005b0a:	853e                	mv	a0,a5
    80005b0c:	70b2                	ld	ra,296(sp)
    80005b0e:	7412                	ld	s0,288(sp)
    80005b10:	64f2                	ld	s1,280(sp)
    80005b12:	6952                	ld	s2,272(sp)
    80005b14:	6155                	addi	sp,sp,304
    80005b16:	8082                	ret

0000000080005b18 <sys_unlink>:
{
    80005b18:	7151                	addi	sp,sp,-240
    80005b1a:	f586                	sd	ra,232(sp)
    80005b1c:	f1a2                	sd	s0,224(sp)
    80005b1e:	eda6                	sd	s1,216(sp)
    80005b20:	e9ca                	sd	s2,208(sp)
    80005b22:	e5ce                	sd	s3,200(sp)
    80005b24:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005b26:	08000613          	li	a2,128
    80005b2a:	f3040593          	addi	a1,s0,-208
    80005b2e:	4501                	li	a0,0
    80005b30:	ffffd097          	auipc	ra,0xffffd
    80005b34:	628080e7          	jalr	1576(ra) # 80003158 <argstr>
    80005b38:	18054163          	bltz	a0,80005cba <sys_unlink+0x1a2>
  begin_op();
    80005b3c:	fffff097          	auipc	ra,0xfffff
    80005b40:	be2080e7          	jalr	-1054(ra) # 8000471e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b44:	fb040593          	addi	a1,s0,-80
    80005b48:	f3040513          	addi	a0,s0,-208
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	9d0080e7          	jalr	-1584(ra) # 8000451c <nameiparent>
    80005b54:	84aa                	mv	s1,a0
    80005b56:	c979                	beqz	a0,80005c2c <sys_unlink+0x114>
  ilock(dp);
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	1f0080e7          	jalr	496(ra) # 80003d48 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b60:	00003597          	auipc	a1,0x3
    80005b64:	c0858593          	addi	a1,a1,-1016 # 80008768 <syscalls+0x2c8>
    80005b68:	fb040513          	addi	a0,s0,-80
    80005b6c:	ffffe097          	auipc	ra,0xffffe
    80005b70:	6a6080e7          	jalr	1702(ra) # 80004212 <namecmp>
    80005b74:	14050a63          	beqz	a0,80005cc8 <sys_unlink+0x1b0>
    80005b78:	00003597          	auipc	a1,0x3
    80005b7c:	bf858593          	addi	a1,a1,-1032 # 80008770 <syscalls+0x2d0>
    80005b80:	fb040513          	addi	a0,s0,-80
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	68e080e7          	jalr	1678(ra) # 80004212 <namecmp>
    80005b8c:	12050e63          	beqz	a0,80005cc8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b90:	f2c40613          	addi	a2,s0,-212
    80005b94:	fb040593          	addi	a1,s0,-80
    80005b98:	8526                	mv	a0,s1
    80005b9a:	ffffe097          	auipc	ra,0xffffe
    80005b9e:	692080e7          	jalr	1682(ra) # 8000422c <dirlookup>
    80005ba2:	892a                	mv	s2,a0
    80005ba4:	12050263          	beqz	a0,80005cc8 <sys_unlink+0x1b0>
  ilock(ip);
    80005ba8:	ffffe097          	auipc	ra,0xffffe
    80005bac:	1a0080e7          	jalr	416(ra) # 80003d48 <ilock>
  if(ip->nlink < 1)
    80005bb0:	04a91783          	lh	a5,74(s2)
    80005bb4:	08f05263          	blez	a5,80005c38 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005bb8:	04491703          	lh	a4,68(s2)
    80005bbc:	4785                	li	a5,1
    80005bbe:	08f70563          	beq	a4,a5,80005c48 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005bc2:	4641                	li	a2,16
    80005bc4:	4581                	li	a1,0
    80005bc6:	fc040513          	addi	a0,s0,-64
    80005bca:	ffffb097          	auipc	ra,0xffffb
    80005bce:	0f4080e7          	jalr	244(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bd2:	4741                	li	a4,16
    80005bd4:	f2c42683          	lw	a3,-212(s0)
    80005bd8:	fc040613          	addi	a2,s0,-64
    80005bdc:	4581                	li	a1,0
    80005bde:	8526                	mv	a0,s1
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	514080e7          	jalr	1300(ra) # 800040f4 <writei>
    80005be8:	47c1                	li	a5,16
    80005bea:	0af51563          	bne	a0,a5,80005c94 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005bee:	04491703          	lh	a4,68(s2)
    80005bf2:	4785                	li	a5,1
    80005bf4:	0af70863          	beq	a4,a5,80005ca4 <sys_unlink+0x18c>
  iunlockput(dp);
    80005bf8:	8526                	mv	a0,s1
    80005bfa:	ffffe097          	auipc	ra,0xffffe
    80005bfe:	3b0080e7          	jalr	944(ra) # 80003faa <iunlockput>
  ip->nlink--;
    80005c02:	04a95783          	lhu	a5,74(s2)
    80005c06:	37fd                	addiw	a5,a5,-1
    80005c08:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c0c:	854a                	mv	a0,s2
    80005c0e:	ffffe097          	auipc	ra,0xffffe
    80005c12:	070080e7          	jalr	112(ra) # 80003c7e <iupdate>
  iunlockput(ip);
    80005c16:	854a                	mv	a0,s2
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	392080e7          	jalr	914(ra) # 80003faa <iunlockput>
  end_op();
    80005c20:	fffff097          	auipc	ra,0xfffff
    80005c24:	b7e080e7          	jalr	-1154(ra) # 8000479e <end_op>
  return 0;
    80005c28:	4501                	li	a0,0
    80005c2a:	a84d                	j	80005cdc <sys_unlink+0x1c4>
    end_op();
    80005c2c:	fffff097          	auipc	ra,0xfffff
    80005c30:	b72080e7          	jalr	-1166(ra) # 8000479e <end_op>
    return -1;
    80005c34:	557d                	li	a0,-1
    80005c36:	a05d                	j	80005cdc <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005c38:	00003517          	auipc	a0,0x3
    80005c3c:	b6050513          	addi	a0,a0,-1184 # 80008798 <syscalls+0x2f8>
    80005c40:	ffffb097          	auipc	ra,0xffffb
    80005c44:	8ea080e7          	jalr	-1814(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c48:	04c92703          	lw	a4,76(s2)
    80005c4c:	02000793          	li	a5,32
    80005c50:	f6e7f9e3          	bgeu	a5,a4,80005bc2 <sys_unlink+0xaa>
    80005c54:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c58:	4741                	li	a4,16
    80005c5a:	86ce                	mv	a3,s3
    80005c5c:	f1840613          	addi	a2,s0,-232
    80005c60:	4581                	li	a1,0
    80005c62:	854a                	mv	a0,s2
    80005c64:	ffffe097          	auipc	ra,0xffffe
    80005c68:	398080e7          	jalr	920(ra) # 80003ffc <readi>
    80005c6c:	47c1                	li	a5,16
    80005c6e:	00f51b63          	bne	a0,a5,80005c84 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005c72:	f1845783          	lhu	a5,-232(s0)
    80005c76:	e7a1                	bnez	a5,80005cbe <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c78:	29c1                	addiw	s3,s3,16
    80005c7a:	04c92783          	lw	a5,76(s2)
    80005c7e:	fcf9ede3          	bltu	s3,a5,80005c58 <sys_unlink+0x140>
    80005c82:	b781                	j	80005bc2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c84:	00003517          	auipc	a0,0x3
    80005c88:	b2c50513          	addi	a0,a0,-1236 # 800087b0 <syscalls+0x310>
    80005c8c:	ffffb097          	auipc	ra,0xffffb
    80005c90:	89e080e7          	jalr	-1890(ra) # 8000052a <panic>
    panic("unlink: writei");
    80005c94:	00003517          	auipc	a0,0x3
    80005c98:	b3450513          	addi	a0,a0,-1228 # 800087c8 <syscalls+0x328>
    80005c9c:	ffffb097          	auipc	ra,0xffffb
    80005ca0:	88e080e7          	jalr	-1906(ra) # 8000052a <panic>
    dp->nlink--;
    80005ca4:	04a4d783          	lhu	a5,74(s1)
    80005ca8:	37fd                	addiw	a5,a5,-1
    80005caa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005cae:	8526                	mv	a0,s1
    80005cb0:	ffffe097          	auipc	ra,0xffffe
    80005cb4:	fce080e7          	jalr	-50(ra) # 80003c7e <iupdate>
    80005cb8:	b781                	j	80005bf8 <sys_unlink+0xe0>
    return -1;
    80005cba:	557d                	li	a0,-1
    80005cbc:	a005                	j	80005cdc <sys_unlink+0x1c4>
    iunlockput(ip);
    80005cbe:	854a                	mv	a0,s2
    80005cc0:	ffffe097          	auipc	ra,0xffffe
    80005cc4:	2ea080e7          	jalr	746(ra) # 80003faa <iunlockput>
  iunlockput(dp);
    80005cc8:	8526                	mv	a0,s1
    80005cca:	ffffe097          	auipc	ra,0xffffe
    80005cce:	2e0080e7          	jalr	736(ra) # 80003faa <iunlockput>
  end_op();
    80005cd2:	fffff097          	auipc	ra,0xfffff
    80005cd6:	acc080e7          	jalr	-1332(ra) # 8000479e <end_op>
  return -1;
    80005cda:	557d                	li	a0,-1
}
    80005cdc:	70ae                	ld	ra,232(sp)
    80005cde:	740e                	ld	s0,224(sp)
    80005ce0:	64ee                	ld	s1,216(sp)
    80005ce2:	694e                	ld	s2,208(sp)
    80005ce4:	69ae                	ld	s3,200(sp)
    80005ce6:	616d                	addi	sp,sp,240
    80005ce8:	8082                	ret

0000000080005cea <sys_open>:

uint64
sys_open(void)
{
    80005cea:	7131                	addi	sp,sp,-192
    80005cec:	fd06                	sd	ra,184(sp)
    80005cee:	f922                	sd	s0,176(sp)
    80005cf0:	f526                	sd	s1,168(sp)
    80005cf2:	f14a                	sd	s2,160(sp)
    80005cf4:	ed4e                	sd	s3,152(sp)
    80005cf6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005cf8:	08000613          	li	a2,128
    80005cfc:	f5040593          	addi	a1,s0,-176
    80005d00:	4501                	li	a0,0
    80005d02:	ffffd097          	auipc	ra,0xffffd
    80005d06:	456080e7          	jalr	1110(ra) # 80003158 <argstr>
    return -1;
    80005d0a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d0c:	0c054163          	bltz	a0,80005dce <sys_open+0xe4>
    80005d10:	f4c40593          	addi	a1,s0,-180
    80005d14:	4505                	li	a0,1
    80005d16:	ffffd097          	auipc	ra,0xffffd
    80005d1a:	3fe080e7          	jalr	1022(ra) # 80003114 <argint>
    80005d1e:	0a054863          	bltz	a0,80005dce <sys_open+0xe4>

  begin_op();
    80005d22:	fffff097          	auipc	ra,0xfffff
    80005d26:	9fc080e7          	jalr	-1540(ra) # 8000471e <begin_op>

  if(omode & O_CREATE){
    80005d2a:	f4c42783          	lw	a5,-180(s0)
    80005d2e:	2007f793          	andi	a5,a5,512
    80005d32:	cbdd                	beqz	a5,80005de8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005d34:	4681                	li	a3,0
    80005d36:	4601                	li	a2,0
    80005d38:	4589                	li	a1,2
    80005d3a:	f5040513          	addi	a0,s0,-176
    80005d3e:	00000097          	auipc	ra,0x0
    80005d42:	974080e7          	jalr	-1676(ra) # 800056b2 <create>
    80005d46:	892a                	mv	s2,a0
    if(ip == 0){
    80005d48:	c959                	beqz	a0,80005dde <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d4a:	04491703          	lh	a4,68(s2)
    80005d4e:	478d                	li	a5,3
    80005d50:	00f71763          	bne	a4,a5,80005d5e <sys_open+0x74>
    80005d54:	04695703          	lhu	a4,70(s2)
    80005d58:	47a5                	li	a5,9
    80005d5a:	0ce7ec63          	bltu	a5,a4,80005e32 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d5e:	fffff097          	auipc	ra,0xfffff
    80005d62:	dd0080e7          	jalr	-560(ra) # 80004b2e <filealloc>
    80005d66:	89aa                	mv	s3,a0
    80005d68:	10050263          	beqz	a0,80005e6c <sys_open+0x182>
    80005d6c:	00000097          	auipc	ra,0x0
    80005d70:	904080e7          	jalr	-1788(ra) # 80005670 <fdalloc>
    80005d74:	84aa                	mv	s1,a0
    80005d76:	0e054663          	bltz	a0,80005e62 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d7a:	04491703          	lh	a4,68(s2)
    80005d7e:	478d                	li	a5,3
    80005d80:	0cf70463          	beq	a4,a5,80005e48 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d84:	4789                	li	a5,2
    80005d86:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d8a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d8e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d92:	f4c42783          	lw	a5,-180(s0)
    80005d96:	0017c713          	xori	a4,a5,1
    80005d9a:	8b05                	andi	a4,a4,1
    80005d9c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005da0:	0037f713          	andi	a4,a5,3
    80005da4:	00e03733          	snez	a4,a4
    80005da8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005dac:	4007f793          	andi	a5,a5,1024
    80005db0:	c791                	beqz	a5,80005dbc <sys_open+0xd2>
    80005db2:	04491703          	lh	a4,68(s2)
    80005db6:	4789                	li	a5,2
    80005db8:	08f70f63          	beq	a4,a5,80005e56 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005dbc:	854a                	mv	a0,s2
    80005dbe:	ffffe097          	auipc	ra,0xffffe
    80005dc2:	04c080e7          	jalr	76(ra) # 80003e0a <iunlock>
  end_op();
    80005dc6:	fffff097          	auipc	ra,0xfffff
    80005dca:	9d8080e7          	jalr	-1576(ra) # 8000479e <end_op>

  return fd;
}
    80005dce:	8526                	mv	a0,s1
    80005dd0:	70ea                	ld	ra,184(sp)
    80005dd2:	744a                	ld	s0,176(sp)
    80005dd4:	74aa                	ld	s1,168(sp)
    80005dd6:	790a                	ld	s2,160(sp)
    80005dd8:	69ea                	ld	s3,152(sp)
    80005dda:	6129                	addi	sp,sp,192
    80005ddc:	8082                	ret
      end_op();
    80005dde:	fffff097          	auipc	ra,0xfffff
    80005de2:	9c0080e7          	jalr	-1600(ra) # 8000479e <end_op>
      return -1;
    80005de6:	b7e5                	j	80005dce <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005de8:	f5040513          	addi	a0,s0,-176
    80005dec:	ffffe097          	auipc	ra,0xffffe
    80005df0:	712080e7          	jalr	1810(ra) # 800044fe <namei>
    80005df4:	892a                	mv	s2,a0
    80005df6:	c905                	beqz	a0,80005e26 <sys_open+0x13c>
    ilock(ip);
    80005df8:	ffffe097          	auipc	ra,0xffffe
    80005dfc:	f50080e7          	jalr	-176(ra) # 80003d48 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e00:	04491703          	lh	a4,68(s2)
    80005e04:	4785                	li	a5,1
    80005e06:	f4f712e3          	bne	a4,a5,80005d4a <sys_open+0x60>
    80005e0a:	f4c42783          	lw	a5,-180(s0)
    80005e0e:	dba1                	beqz	a5,80005d5e <sys_open+0x74>
      iunlockput(ip);
    80005e10:	854a                	mv	a0,s2
    80005e12:	ffffe097          	auipc	ra,0xffffe
    80005e16:	198080e7          	jalr	408(ra) # 80003faa <iunlockput>
      end_op();
    80005e1a:	fffff097          	auipc	ra,0xfffff
    80005e1e:	984080e7          	jalr	-1660(ra) # 8000479e <end_op>
      return -1;
    80005e22:	54fd                	li	s1,-1
    80005e24:	b76d                	j	80005dce <sys_open+0xe4>
      end_op();
    80005e26:	fffff097          	auipc	ra,0xfffff
    80005e2a:	978080e7          	jalr	-1672(ra) # 8000479e <end_op>
      return -1;
    80005e2e:	54fd                	li	s1,-1
    80005e30:	bf79                	j	80005dce <sys_open+0xe4>
    iunlockput(ip);
    80005e32:	854a                	mv	a0,s2
    80005e34:	ffffe097          	auipc	ra,0xffffe
    80005e38:	176080e7          	jalr	374(ra) # 80003faa <iunlockput>
    end_op();
    80005e3c:	fffff097          	auipc	ra,0xfffff
    80005e40:	962080e7          	jalr	-1694(ra) # 8000479e <end_op>
    return -1;
    80005e44:	54fd                	li	s1,-1
    80005e46:	b761                	j	80005dce <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005e48:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005e4c:	04691783          	lh	a5,70(s2)
    80005e50:	02f99223          	sh	a5,36(s3)
    80005e54:	bf2d                	j	80005d8e <sys_open+0xa4>
    itrunc(ip);
    80005e56:	854a                	mv	a0,s2
    80005e58:	ffffe097          	auipc	ra,0xffffe
    80005e5c:	ffe080e7          	jalr	-2(ra) # 80003e56 <itrunc>
    80005e60:	bfb1                	j	80005dbc <sys_open+0xd2>
      fileclose(f);
    80005e62:	854e                	mv	a0,s3
    80005e64:	fffff097          	auipc	ra,0xfffff
    80005e68:	d86080e7          	jalr	-634(ra) # 80004bea <fileclose>
    iunlockput(ip);
    80005e6c:	854a                	mv	a0,s2
    80005e6e:	ffffe097          	auipc	ra,0xffffe
    80005e72:	13c080e7          	jalr	316(ra) # 80003faa <iunlockput>
    end_op();
    80005e76:	fffff097          	auipc	ra,0xfffff
    80005e7a:	928080e7          	jalr	-1752(ra) # 8000479e <end_op>
    return -1;
    80005e7e:	54fd                	li	s1,-1
    80005e80:	b7b9                	j	80005dce <sys_open+0xe4>

0000000080005e82 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e82:	7175                	addi	sp,sp,-144
    80005e84:	e506                	sd	ra,136(sp)
    80005e86:	e122                	sd	s0,128(sp)
    80005e88:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	894080e7          	jalr	-1900(ra) # 8000471e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e92:	08000613          	li	a2,128
    80005e96:	f7040593          	addi	a1,s0,-144
    80005e9a:	4501                	li	a0,0
    80005e9c:	ffffd097          	auipc	ra,0xffffd
    80005ea0:	2bc080e7          	jalr	700(ra) # 80003158 <argstr>
    80005ea4:	02054963          	bltz	a0,80005ed6 <sys_mkdir+0x54>
    80005ea8:	4681                	li	a3,0
    80005eaa:	4601                	li	a2,0
    80005eac:	4585                	li	a1,1
    80005eae:	f7040513          	addi	a0,s0,-144
    80005eb2:	00000097          	auipc	ra,0x0
    80005eb6:	800080e7          	jalr	-2048(ra) # 800056b2 <create>
    80005eba:	cd11                	beqz	a0,80005ed6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ebc:	ffffe097          	auipc	ra,0xffffe
    80005ec0:	0ee080e7          	jalr	238(ra) # 80003faa <iunlockput>
  end_op();
    80005ec4:	fffff097          	auipc	ra,0xfffff
    80005ec8:	8da080e7          	jalr	-1830(ra) # 8000479e <end_op>
  return 0;
    80005ecc:	4501                	li	a0,0
}
    80005ece:	60aa                	ld	ra,136(sp)
    80005ed0:	640a                	ld	s0,128(sp)
    80005ed2:	6149                	addi	sp,sp,144
    80005ed4:	8082                	ret
    end_op();
    80005ed6:	fffff097          	auipc	ra,0xfffff
    80005eda:	8c8080e7          	jalr	-1848(ra) # 8000479e <end_op>
    return -1;
    80005ede:	557d                	li	a0,-1
    80005ee0:	b7fd                	j	80005ece <sys_mkdir+0x4c>

0000000080005ee2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ee2:	7135                	addi	sp,sp,-160
    80005ee4:	ed06                	sd	ra,152(sp)
    80005ee6:	e922                	sd	s0,144(sp)
    80005ee8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005eea:	fffff097          	auipc	ra,0xfffff
    80005eee:	834080e7          	jalr	-1996(ra) # 8000471e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ef2:	08000613          	li	a2,128
    80005ef6:	f7040593          	addi	a1,s0,-144
    80005efa:	4501                	li	a0,0
    80005efc:	ffffd097          	auipc	ra,0xffffd
    80005f00:	25c080e7          	jalr	604(ra) # 80003158 <argstr>
    80005f04:	04054a63          	bltz	a0,80005f58 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005f08:	f6c40593          	addi	a1,s0,-148
    80005f0c:	4505                	li	a0,1
    80005f0e:	ffffd097          	auipc	ra,0xffffd
    80005f12:	206080e7          	jalr	518(ra) # 80003114 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f16:	04054163          	bltz	a0,80005f58 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005f1a:	f6840593          	addi	a1,s0,-152
    80005f1e:	4509                	li	a0,2
    80005f20:	ffffd097          	auipc	ra,0xffffd
    80005f24:	1f4080e7          	jalr	500(ra) # 80003114 <argint>
     argint(1, &major) < 0 ||
    80005f28:	02054863          	bltz	a0,80005f58 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f2c:	f6841683          	lh	a3,-152(s0)
    80005f30:	f6c41603          	lh	a2,-148(s0)
    80005f34:	458d                	li	a1,3
    80005f36:	f7040513          	addi	a0,s0,-144
    80005f3a:	fffff097          	auipc	ra,0xfffff
    80005f3e:	778080e7          	jalr	1912(ra) # 800056b2 <create>
     argint(2, &minor) < 0 ||
    80005f42:	c919                	beqz	a0,80005f58 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f44:	ffffe097          	auipc	ra,0xffffe
    80005f48:	066080e7          	jalr	102(ra) # 80003faa <iunlockput>
  end_op();
    80005f4c:	fffff097          	auipc	ra,0xfffff
    80005f50:	852080e7          	jalr	-1966(ra) # 8000479e <end_op>
  return 0;
    80005f54:	4501                	li	a0,0
    80005f56:	a031                	j	80005f62 <sys_mknod+0x80>
    end_op();
    80005f58:	fffff097          	auipc	ra,0xfffff
    80005f5c:	846080e7          	jalr	-1978(ra) # 8000479e <end_op>
    return -1;
    80005f60:	557d                	li	a0,-1
}
    80005f62:	60ea                	ld	ra,152(sp)
    80005f64:	644a                	ld	s0,144(sp)
    80005f66:	610d                	addi	sp,sp,160
    80005f68:	8082                	ret

0000000080005f6a <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f6a:	7135                	addi	sp,sp,-160
    80005f6c:	ed06                	sd	ra,152(sp)
    80005f6e:	e922                	sd	s0,144(sp)
    80005f70:	e526                	sd	s1,136(sp)
    80005f72:	e14a                	sd	s2,128(sp)
    80005f74:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f76:	ffffc097          	auipc	ra,0xffffc
    80005f7a:	a3e080e7          	jalr	-1474(ra) # 800019b4 <myproc>
    80005f7e:	892a                	mv	s2,a0
  
  begin_op();
    80005f80:	ffffe097          	auipc	ra,0xffffe
    80005f84:	79e080e7          	jalr	1950(ra) # 8000471e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f88:	08000613          	li	a2,128
    80005f8c:	f6040593          	addi	a1,s0,-160
    80005f90:	4501                	li	a0,0
    80005f92:	ffffd097          	auipc	ra,0xffffd
    80005f96:	1c6080e7          	jalr	454(ra) # 80003158 <argstr>
    80005f9a:	04054b63          	bltz	a0,80005ff0 <sys_chdir+0x86>
    80005f9e:	f6040513          	addi	a0,s0,-160
    80005fa2:	ffffe097          	auipc	ra,0xffffe
    80005fa6:	55c080e7          	jalr	1372(ra) # 800044fe <namei>
    80005faa:	84aa                	mv	s1,a0
    80005fac:	c131                	beqz	a0,80005ff0 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	d9a080e7          	jalr	-614(ra) # 80003d48 <ilock>
  if(ip->type != T_DIR){
    80005fb6:	04449703          	lh	a4,68(s1)
    80005fba:	4785                	li	a5,1
    80005fbc:	04f71063          	bne	a4,a5,80005ffc <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005fc0:	8526                	mv	a0,s1
    80005fc2:	ffffe097          	auipc	ra,0xffffe
    80005fc6:	e48080e7          	jalr	-440(ra) # 80003e0a <iunlock>
  iput(p->cwd);
    80005fca:	15093503          	ld	a0,336(s2)
    80005fce:	ffffe097          	auipc	ra,0xffffe
    80005fd2:	f34080e7          	jalr	-204(ra) # 80003f02 <iput>
  end_op();
    80005fd6:	ffffe097          	auipc	ra,0xffffe
    80005fda:	7c8080e7          	jalr	1992(ra) # 8000479e <end_op>
  p->cwd = ip;
    80005fde:	14993823          	sd	s1,336(s2)
  return 0;
    80005fe2:	4501                	li	a0,0
}
    80005fe4:	60ea                	ld	ra,152(sp)
    80005fe6:	644a                	ld	s0,144(sp)
    80005fe8:	64aa                	ld	s1,136(sp)
    80005fea:	690a                	ld	s2,128(sp)
    80005fec:	610d                	addi	sp,sp,160
    80005fee:	8082                	ret
    end_op();
    80005ff0:	ffffe097          	auipc	ra,0xffffe
    80005ff4:	7ae080e7          	jalr	1966(ra) # 8000479e <end_op>
    return -1;
    80005ff8:	557d                	li	a0,-1
    80005ffa:	b7ed                	j	80005fe4 <sys_chdir+0x7a>
    iunlockput(ip);
    80005ffc:	8526                	mv	a0,s1
    80005ffe:	ffffe097          	auipc	ra,0xffffe
    80006002:	fac080e7          	jalr	-84(ra) # 80003faa <iunlockput>
    end_op();
    80006006:	ffffe097          	auipc	ra,0xffffe
    8000600a:	798080e7          	jalr	1944(ra) # 8000479e <end_op>
    return -1;
    8000600e:	557d                	li	a0,-1
    80006010:	bfd1                	j	80005fe4 <sys_chdir+0x7a>

0000000080006012 <sys_exec>:

uint64
sys_exec(void)
{
    80006012:	7145                	addi	sp,sp,-464
    80006014:	e786                	sd	ra,456(sp)
    80006016:	e3a2                	sd	s0,448(sp)
    80006018:	ff26                	sd	s1,440(sp)
    8000601a:	fb4a                	sd	s2,432(sp)
    8000601c:	f74e                	sd	s3,424(sp)
    8000601e:	f352                	sd	s4,416(sp)
    80006020:	ef56                	sd	s5,408(sp)
    80006022:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006024:	08000613          	li	a2,128
    80006028:	f4040593          	addi	a1,s0,-192
    8000602c:	4501                	li	a0,0
    8000602e:	ffffd097          	auipc	ra,0xffffd
    80006032:	12a080e7          	jalr	298(ra) # 80003158 <argstr>
    return -1;
    80006036:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006038:	0c054a63          	bltz	a0,8000610c <sys_exec+0xfa>
    8000603c:	e3840593          	addi	a1,s0,-456
    80006040:	4505                	li	a0,1
    80006042:	ffffd097          	auipc	ra,0xffffd
    80006046:	0f4080e7          	jalr	244(ra) # 80003136 <argaddr>
    8000604a:	0c054163          	bltz	a0,8000610c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000604e:	10000613          	li	a2,256
    80006052:	4581                	li	a1,0
    80006054:	e4040513          	addi	a0,s0,-448
    80006058:	ffffb097          	auipc	ra,0xffffb
    8000605c:	c66080e7          	jalr	-922(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006060:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006064:	89a6                	mv	s3,s1
    80006066:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006068:	02000a13          	li	s4,32
    8000606c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006070:	00391793          	slli	a5,s2,0x3
    80006074:	e3040593          	addi	a1,s0,-464
    80006078:	e3843503          	ld	a0,-456(s0)
    8000607c:	953e                	add	a0,a0,a5
    8000607e:	ffffd097          	auipc	ra,0xffffd
    80006082:	ffc080e7          	jalr	-4(ra) # 8000307a <fetchaddr>
    80006086:	02054a63          	bltz	a0,800060ba <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    8000608a:	e3043783          	ld	a5,-464(s0)
    8000608e:	c3b9                	beqz	a5,800060d4 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006090:	ffffb097          	auipc	ra,0xffffb
    80006094:	a42080e7          	jalr	-1470(ra) # 80000ad2 <kalloc>
    80006098:	85aa                	mv	a1,a0
    8000609a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000609e:	cd11                	beqz	a0,800060ba <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800060a0:	6605                	lui	a2,0x1
    800060a2:	e3043503          	ld	a0,-464(s0)
    800060a6:	ffffd097          	auipc	ra,0xffffd
    800060aa:	026080e7          	jalr	38(ra) # 800030cc <fetchstr>
    800060ae:	00054663          	bltz	a0,800060ba <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800060b2:	0905                	addi	s2,s2,1
    800060b4:	09a1                	addi	s3,s3,8
    800060b6:	fb491be3          	bne	s2,s4,8000606c <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060ba:	10048913          	addi	s2,s1,256
    800060be:	6088                	ld	a0,0(s1)
    800060c0:	c529                	beqz	a0,8000610a <sys_exec+0xf8>
    kfree(argv[i]);
    800060c2:	ffffb097          	auipc	ra,0xffffb
    800060c6:	914080e7          	jalr	-1772(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060ca:	04a1                	addi	s1,s1,8
    800060cc:	ff2499e3          	bne	s1,s2,800060be <sys_exec+0xac>
  return -1;
    800060d0:	597d                	li	s2,-1
    800060d2:	a82d                	j	8000610c <sys_exec+0xfa>
      argv[i] = 0;
    800060d4:	0a8e                	slli	s5,s5,0x3
    800060d6:	fc040793          	addi	a5,s0,-64
    800060da:	9abe                	add	s5,s5,a5
    800060dc:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd2e80>
  int ret = exec(path, argv);
    800060e0:	e4040593          	addi	a1,s0,-448
    800060e4:	f4040513          	addi	a0,s0,-192
    800060e8:	fffff097          	auipc	ra,0xfffff
    800060ec:	154080e7          	jalr	340(ra) # 8000523c <exec>
    800060f0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060f2:	10048993          	addi	s3,s1,256
    800060f6:	6088                	ld	a0,0(s1)
    800060f8:	c911                	beqz	a0,8000610c <sys_exec+0xfa>
    kfree(argv[i]);
    800060fa:	ffffb097          	auipc	ra,0xffffb
    800060fe:	8dc080e7          	jalr	-1828(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006102:	04a1                	addi	s1,s1,8
    80006104:	ff3499e3          	bne	s1,s3,800060f6 <sys_exec+0xe4>
    80006108:	a011                	j	8000610c <sys_exec+0xfa>
  return -1;
    8000610a:	597d                	li	s2,-1
}
    8000610c:	854a                	mv	a0,s2
    8000610e:	60be                	ld	ra,456(sp)
    80006110:	641e                	ld	s0,448(sp)
    80006112:	74fa                	ld	s1,440(sp)
    80006114:	795a                	ld	s2,432(sp)
    80006116:	79ba                	ld	s3,424(sp)
    80006118:	7a1a                	ld	s4,416(sp)
    8000611a:	6afa                	ld	s5,408(sp)
    8000611c:	6179                	addi	sp,sp,464
    8000611e:	8082                	ret

0000000080006120 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006120:	7139                	addi	sp,sp,-64
    80006122:	fc06                	sd	ra,56(sp)
    80006124:	f822                	sd	s0,48(sp)
    80006126:	f426                	sd	s1,40(sp)
    80006128:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000612a:	ffffc097          	auipc	ra,0xffffc
    8000612e:	88a080e7          	jalr	-1910(ra) # 800019b4 <myproc>
    80006132:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006134:	fd840593          	addi	a1,s0,-40
    80006138:	4501                	li	a0,0
    8000613a:	ffffd097          	auipc	ra,0xffffd
    8000613e:	ffc080e7          	jalr	-4(ra) # 80003136 <argaddr>
    return -1;
    80006142:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006144:	0e054063          	bltz	a0,80006224 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006148:	fc840593          	addi	a1,s0,-56
    8000614c:	fd040513          	addi	a0,s0,-48
    80006150:	fffff097          	auipc	ra,0xfffff
    80006154:	dca080e7          	jalr	-566(ra) # 80004f1a <pipealloc>
    return -1;
    80006158:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000615a:	0c054563          	bltz	a0,80006224 <sys_pipe+0x104>
  fd0 = -1;
    8000615e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006162:	fd043503          	ld	a0,-48(s0)
    80006166:	fffff097          	auipc	ra,0xfffff
    8000616a:	50a080e7          	jalr	1290(ra) # 80005670 <fdalloc>
    8000616e:	fca42223          	sw	a0,-60(s0)
    80006172:	08054c63          	bltz	a0,8000620a <sys_pipe+0xea>
    80006176:	fc843503          	ld	a0,-56(s0)
    8000617a:	fffff097          	auipc	ra,0xfffff
    8000617e:	4f6080e7          	jalr	1270(ra) # 80005670 <fdalloc>
    80006182:	fca42023          	sw	a0,-64(s0)
    80006186:	06054863          	bltz	a0,800061f6 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000618a:	4691                	li	a3,4
    8000618c:	fc440613          	addi	a2,s0,-60
    80006190:	fd843583          	ld	a1,-40(s0)
    80006194:	68a8                	ld	a0,80(s1)
    80006196:	ffffb097          	auipc	ra,0xffffb
    8000619a:	4a8080e7          	jalr	1192(ra) # 8000163e <copyout>
    8000619e:	02054063          	bltz	a0,800061be <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800061a2:	4691                	li	a3,4
    800061a4:	fc040613          	addi	a2,s0,-64
    800061a8:	fd843583          	ld	a1,-40(s0)
    800061ac:	0591                	addi	a1,a1,4
    800061ae:	68a8                	ld	a0,80(s1)
    800061b0:	ffffb097          	auipc	ra,0xffffb
    800061b4:	48e080e7          	jalr	1166(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800061b8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061ba:	06055563          	bgez	a0,80006224 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800061be:	fc442783          	lw	a5,-60(s0)
    800061c2:	07e9                	addi	a5,a5,26
    800061c4:	078e                	slli	a5,a5,0x3
    800061c6:	97a6                	add	a5,a5,s1
    800061c8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800061cc:	fc042503          	lw	a0,-64(s0)
    800061d0:	0569                	addi	a0,a0,26
    800061d2:	050e                	slli	a0,a0,0x3
    800061d4:	9526                	add	a0,a0,s1
    800061d6:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    800061da:	fd043503          	ld	a0,-48(s0)
    800061de:	fffff097          	auipc	ra,0xfffff
    800061e2:	a0c080e7          	jalr	-1524(ra) # 80004bea <fileclose>
    fileclose(wf);
    800061e6:	fc843503          	ld	a0,-56(s0)
    800061ea:	fffff097          	auipc	ra,0xfffff
    800061ee:	a00080e7          	jalr	-1536(ra) # 80004bea <fileclose>
    return -1;
    800061f2:	57fd                	li	a5,-1
    800061f4:	a805                	j	80006224 <sys_pipe+0x104>
    if(fd0 >= 0)
    800061f6:	fc442783          	lw	a5,-60(s0)
    800061fa:	0007c863          	bltz	a5,8000620a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800061fe:	01a78513          	addi	a0,a5,26
    80006202:	050e                	slli	a0,a0,0x3
    80006204:	9526                	add	a0,a0,s1
    80006206:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000620a:	fd043503          	ld	a0,-48(s0)
    8000620e:	fffff097          	auipc	ra,0xfffff
    80006212:	9dc080e7          	jalr	-1572(ra) # 80004bea <fileclose>
    fileclose(wf);
    80006216:	fc843503          	ld	a0,-56(s0)
    8000621a:	fffff097          	auipc	ra,0xfffff
    8000621e:	9d0080e7          	jalr	-1584(ra) # 80004bea <fileclose>
    return -1;
    80006222:	57fd                	li	a5,-1
}
    80006224:	853e                	mv	a0,a5
    80006226:	70e2                	ld	ra,56(sp)
    80006228:	7442                	ld	s0,48(sp)
    8000622a:	74a2                	ld	s1,40(sp)
    8000622c:	6121                	addi	sp,sp,64
    8000622e:	8082                	ret

0000000080006230 <kernelvec>:
    80006230:	7111                	addi	sp,sp,-256
    80006232:	e006                	sd	ra,0(sp)
    80006234:	e40a                	sd	sp,8(sp)
    80006236:	e80e                	sd	gp,16(sp)
    80006238:	ec12                	sd	tp,24(sp)
    8000623a:	f016                	sd	t0,32(sp)
    8000623c:	f41a                	sd	t1,40(sp)
    8000623e:	f81e                	sd	t2,48(sp)
    80006240:	fc22                	sd	s0,56(sp)
    80006242:	e0a6                	sd	s1,64(sp)
    80006244:	e4aa                	sd	a0,72(sp)
    80006246:	e8ae                	sd	a1,80(sp)
    80006248:	ecb2                	sd	a2,88(sp)
    8000624a:	f0b6                	sd	a3,96(sp)
    8000624c:	f4ba                	sd	a4,104(sp)
    8000624e:	f8be                	sd	a5,112(sp)
    80006250:	fcc2                	sd	a6,120(sp)
    80006252:	e146                	sd	a7,128(sp)
    80006254:	e54a                	sd	s2,136(sp)
    80006256:	e94e                	sd	s3,144(sp)
    80006258:	ed52                	sd	s4,152(sp)
    8000625a:	f156                	sd	s5,160(sp)
    8000625c:	f55a                	sd	s6,168(sp)
    8000625e:	f95e                	sd	s7,176(sp)
    80006260:	fd62                	sd	s8,184(sp)
    80006262:	e1e6                	sd	s9,192(sp)
    80006264:	e5ea                	sd	s10,200(sp)
    80006266:	e9ee                	sd	s11,208(sp)
    80006268:	edf2                	sd	t3,216(sp)
    8000626a:	f1f6                	sd	t4,224(sp)
    8000626c:	f5fa                	sd	t5,232(sp)
    8000626e:	f9fe                	sd	t6,240(sp)
    80006270:	cd7fc0ef          	jal	ra,80002f46 <kerneltrap>
    80006274:	6082                	ld	ra,0(sp)
    80006276:	6122                	ld	sp,8(sp)
    80006278:	61c2                	ld	gp,16(sp)
    8000627a:	7282                	ld	t0,32(sp)
    8000627c:	7322                	ld	t1,40(sp)
    8000627e:	73c2                	ld	t2,48(sp)
    80006280:	7462                	ld	s0,56(sp)
    80006282:	6486                	ld	s1,64(sp)
    80006284:	6526                	ld	a0,72(sp)
    80006286:	65c6                	ld	a1,80(sp)
    80006288:	6666                	ld	a2,88(sp)
    8000628a:	7686                	ld	a3,96(sp)
    8000628c:	7726                	ld	a4,104(sp)
    8000628e:	77c6                	ld	a5,112(sp)
    80006290:	7866                	ld	a6,120(sp)
    80006292:	688a                	ld	a7,128(sp)
    80006294:	692a                	ld	s2,136(sp)
    80006296:	69ca                	ld	s3,144(sp)
    80006298:	6a6a                	ld	s4,152(sp)
    8000629a:	7a8a                	ld	s5,160(sp)
    8000629c:	7b2a                	ld	s6,168(sp)
    8000629e:	7bca                	ld	s7,176(sp)
    800062a0:	7c6a                	ld	s8,184(sp)
    800062a2:	6c8e                	ld	s9,192(sp)
    800062a4:	6d2e                	ld	s10,200(sp)
    800062a6:	6dce                	ld	s11,208(sp)
    800062a8:	6e6e                	ld	t3,216(sp)
    800062aa:	7e8e                	ld	t4,224(sp)
    800062ac:	7f2e                	ld	t5,232(sp)
    800062ae:	7fce                	ld	t6,240(sp)
    800062b0:	6111                	addi	sp,sp,256
    800062b2:	10200073          	sret
    800062b6:	00000013          	nop
    800062ba:	00000013          	nop
    800062be:	0001                	nop

00000000800062c0 <timervec>:
    800062c0:	34051573          	csrrw	a0,mscratch,a0
    800062c4:	e10c                	sd	a1,0(a0)
    800062c6:	e510                	sd	a2,8(a0)
    800062c8:	e914                	sd	a3,16(a0)
    800062ca:	6d0c                	ld	a1,24(a0)
    800062cc:	7110                	ld	a2,32(a0)
    800062ce:	6194                	ld	a3,0(a1)
    800062d0:	96b2                	add	a3,a3,a2
    800062d2:	e194                	sd	a3,0(a1)
    800062d4:	4589                	li	a1,2
    800062d6:	14459073          	csrw	sip,a1
    800062da:	6914                	ld	a3,16(a0)
    800062dc:	6510                	ld	a2,8(a0)
    800062de:	610c                	ld	a1,0(a0)
    800062e0:	34051573          	csrrw	a0,mscratch,a0
    800062e4:	30200073          	mret
	...

00000000800062ea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800062ea:	1141                	addi	sp,sp,-16
    800062ec:	e422                	sd	s0,8(sp)
    800062ee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800062f0:	0c0007b7          	lui	a5,0xc000
    800062f4:	4705                	li	a4,1
    800062f6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800062f8:	c3d8                	sw	a4,4(a5)
}
    800062fa:	6422                	ld	s0,8(sp)
    800062fc:	0141                	addi	sp,sp,16
    800062fe:	8082                	ret

0000000080006300 <plicinithart>:

void
plicinithart(void)
{
    80006300:	1141                	addi	sp,sp,-16
    80006302:	e406                	sd	ra,8(sp)
    80006304:	e022                	sd	s0,0(sp)
    80006306:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006308:	ffffb097          	auipc	ra,0xffffb
    8000630c:	680080e7          	jalr	1664(ra) # 80001988 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006310:	0085171b          	slliw	a4,a0,0x8
    80006314:	0c0027b7          	lui	a5,0xc002
    80006318:	97ba                	add	a5,a5,a4
    8000631a:	40200713          	li	a4,1026
    8000631e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006322:	00d5151b          	slliw	a0,a0,0xd
    80006326:	0c2017b7          	lui	a5,0xc201
    8000632a:	953e                	add	a0,a0,a5
    8000632c:	00052023          	sw	zero,0(a0)
}
    80006330:	60a2                	ld	ra,8(sp)
    80006332:	6402                	ld	s0,0(sp)
    80006334:	0141                	addi	sp,sp,16
    80006336:	8082                	ret

0000000080006338 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006338:	1141                	addi	sp,sp,-16
    8000633a:	e406                	sd	ra,8(sp)
    8000633c:	e022                	sd	s0,0(sp)
    8000633e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006340:	ffffb097          	auipc	ra,0xffffb
    80006344:	648080e7          	jalr	1608(ra) # 80001988 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006348:	00d5179b          	slliw	a5,a0,0xd
    8000634c:	0c201537          	lui	a0,0xc201
    80006350:	953e                	add	a0,a0,a5
  return irq;
}
    80006352:	4148                	lw	a0,4(a0)
    80006354:	60a2                	ld	ra,8(sp)
    80006356:	6402                	ld	s0,0(sp)
    80006358:	0141                	addi	sp,sp,16
    8000635a:	8082                	ret

000000008000635c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000635c:	1101                	addi	sp,sp,-32
    8000635e:	ec06                	sd	ra,24(sp)
    80006360:	e822                	sd	s0,16(sp)
    80006362:	e426                	sd	s1,8(sp)
    80006364:	1000                	addi	s0,sp,32
    80006366:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006368:	ffffb097          	auipc	ra,0xffffb
    8000636c:	620080e7          	jalr	1568(ra) # 80001988 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006370:	00d5151b          	slliw	a0,a0,0xd
    80006374:	0c2017b7          	lui	a5,0xc201
    80006378:	97aa                	add	a5,a5,a0
    8000637a:	c3c4                	sw	s1,4(a5)
}
    8000637c:	60e2                	ld	ra,24(sp)
    8000637e:	6442                	ld	s0,16(sp)
    80006380:	64a2                	ld	s1,8(sp)
    80006382:	6105                	addi	sp,sp,32
    80006384:	8082                	ret

0000000080006386 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006386:	1141                	addi	sp,sp,-16
    80006388:	e406                	sd	ra,8(sp)
    8000638a:	e022                	sd	s0,0(sp)
    8000638c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000638e:	479d                	li	a5,7
    80006390:	06a7c963          	blt	a5,a0,80006402 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006394:	00023797          	auipc	a5,0x23
    80006398:	c6c78793          	addi	a5,a5,-916 # 80029000 <disk>
    8000639c:	00a78733          	add	a4,a5,a0
    800063a0:	6789                	lui	a5,0x2
    800063a2:	97ba                	add	a5,a5,a4
    800063a4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800063a8:	e7ad                	bnez	a5,80006412 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800063aa:	00451793          	slli	a5,a0,0x4
    800063ae:	00025717          	auipc	a4,0x25
    800063b2:	c5270713          	addi	a4,a4,-942 # 8002b000 <disk+0x2000>
    800063b6:	6314                	ld	a3,0(a4)
    800063b8:	96be                	add	a3,a3,a5
    800063ba:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800063be:	6314                	ld	a3,0(a4)
    800063c0:	96be                	add	a3,a3,a5
    800063c2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800063c6:	6314                	ld	a3,0(a4)
    800063c8:	96be                	add	a3,a3,a5
    800063ca:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800063ce:	6318                	ld	a4,0(a4)
    800063d0:	97ba                	add	a5,a5,a4
    800063d2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800063d6:	00023797          	auipc	a5,0x23
    800063da:	c2a78793          	addi	a5,a5,-982 # 80029000 <disk>
    800063de:	97aa                	add	a5,a5,a0
    800063e0:	6509                	lui	a0,0x2
    800063e2:	953e                	add	a0,a0,a5
    800063e4:	4785                	li	a5,1
    800063e6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800063ea:	00025517          	auipc	a0,0x25
    800063ee:	c2e50513          	addi	a0,a0,-978 # 8002b018 <disk+0x2018>
    800063f2:	ffffc097          	auipc	ra,0xffffc
    800063f6:	ec6080e7          	jalr	-314(ra) # 800022b8 <wakeup>
}
    800063fa:	60a2                	ld	ra,8(sp)
    800063fc:	6402                	ld	s0,0(sp)
    800063fe:	0141                	addi	sp,sp,16
    80006400:	8082                	ret
    panic("free_desc 1");
    80006402:	00002517          	auipc	a0,0x2
    80006406:	3d650513          	addi	a0,a0,982 # 800087d8 <syscalls+0x338>
    8000640a:	ffffa097          	auipc	ra,0xffffa
    8000640e:	120080e7          	jalr	288(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006412:	00002517          	auipc	a0,0x2
    80006416:	3d650513          	addi	a0,a0,982 # 800087e8 <syscalls+0x348>
    8000641a:	ffffa097          	auipc	ra,0xffffa
    8000641e:	110080e7          	jalr	272(ra) # 8000052a <panic>

0000000080006422 <virtio_disk_init>:
{
    80006422:	1101                	addi	sp,sp,-32
    80006424:	ec06                	sd	ra,24(sp)
    80006426:	e822                	sd	s0,16(sp)
    80006428:	e426                	sd	s1,8(sp)
    8000642a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000642c:	00002597          	auipc	a1,0x2
    80006430:	3cc58593          	addi	a1,a1,972 # 800087f8 <syscalls+0x358>
    80006434:	00025517          	auipc	a0,0x25
    80006438:	cf450513          	addi	a0,a0,-780 # 8002b128 <disk+0x2128>
    8000643c:	ffffa097          	auipc	ra,0xffffa
    80006440:	6f6080e7          	jalr	1782(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006444:	100017b7          	lui	a5,0x10001
    80006448:	4398                	lw	a4,0(a5)
    8000644a:	2701                	sext.w	a4,a4
    8000644c:	747277b7          	lui	a5,0x74727
    80006450:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006454:	0ef71163          	bne	a4,a5,80006536 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006458:	100017b7          	lui	a5,0x10001
    8000645c:	43dc                	lw	a5,4(a5)
    8000645e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006460:	4705                	li	a4,1
    80006462:	0ce79a63          	bne	a5,a4,80006536 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006466:	100017b7          	lui	a5,0x10001
    8000646a:	479c                	lw	a5,8(a5)
    8000646c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000646e:	4709                	li	a4,2
    80006470:	0ce79363          	bne	a5,a4,80006536 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006474:	100017b7          	lui	a5,0x10001
    80006478:	47d8                	lw	a4,12(a5)
    8000647a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000647c:	554d47b7          	lui	a5,0x554d4
    80006480:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006484:	0af71963          	bne	a4,a5,80006536 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006488:	100017b7          	lui	a5,0x10001
    8000648c:	4705                	li	a4,1
    8000648e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006490:	470d                	li	a4,3
    80006492:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006494:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006496:	c7ffe737          	lui	a4,0xc7ffe
    8000649a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd275f>
    8000649e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800064a0:	2701                	sext.w	a4,a4
    800064a2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064a4:	472d                	li	a4,11
    800064a6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064a8:	473d                	li	a4,15
    800064aa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800064ac:	6705                	lui	a4,0x1
    800064ae:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800064b0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800064b4:	5bdc                	lw	a5,52(a5)
    800064b6:	2781                	sext.w	a5,a5
  if(max == 0)
    800064b8:	c7d9                	beqz	a5,80006546 <virtio_disk_init+0x124>
  if(max < NUM)
    800064ba:	471d                	li	a4,7
    800064bc:	08f77d63          	bgeu	a4,a5,80006556 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800064c0:	100014b7          	lui	s1,0x10001
    800064c4:	47a1                	li	a5,8
    800064c6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800064c8:	6609                	lui	a2,0x2
    800064ca:	4581                	li	a1,0
    800064cc:	00023517          	auipc	a0,0x23
    800064d0:	b3450513          	addi	a0,a0,-1228 # 80029000 <disk>
    800064d4:	ffffa097          	auipc	ra,0xffffa
    800064d8:	7ea080e7          	jalr	2026(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800064dc:	00023717          	auipc	a4,0x23
    800064e0:	b2470713          	addi	a4,a4,-1244 # 80029000 <disk>
    800064e4:	00c75793          	srli	a5,a4,0xc
    800064e8:	2781                	sext.w	a5,a5
    800064ea:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800064ec:	00025797          	auipc	a5,0x25
    800064f0:	b1478793          	addi	a5,a5,-1260 # 8002b000 <disk+0x2000>
    800064f4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800064f6:	00023717          	auipc	a4,0x23
    800064fa:	b8a70713          	addi	a4,a4,-1142 # 80029080 <disk+0x80>
    800064fe:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006500:	00024717          	auipc	a4,0x24
    80006504:	b0070713          	addi	a4,a4,-1280 # 8002a000 <disk+0x1000>
    80006508:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000650a:	4705                	li	a4,1
    8000650c:	00e78c23          	sb	a4,24(a5)
    80006510:	00e78ca3          	sb	a4,25(a5)
    80006514:	00e78d23          	sb	a4,26(a5)
    80006518:	00e78da3          	sb	a4,27(a5)
    8000651c:	00e78e23          	sb	a4,28(a5)
    80006520:	00e78ea3          	sb	a4,29(a5)
    80006524:	00e78f23          	sb	a4,30(a5)
    80006528:	00e78fa3          	sb	a4,31(a5)
}
    8000652c:	60e2                	ld	ra,24(sp)
    8000652e:	6442                	ld	s0,16(sp)
    80006530:	64a2                	ld	s1,8(sp)
    80006532:	6105                	addi	sp,sp,32
    80006534:	8082                	ret
    panic("could not find virtio disk");
    80006536:	00002517          	auipc	a0,0x2
    8000653a:	2d250513          	addi	a0,a0,722 # 80008808 <syscalls+0x368>
    8000653e:	ffffa097          	auipc	ra,0xffffa
    80006542:	fec080e7          	jalr	-20(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006546:	00002517          	auipc	a0,0x2
    8000654a:	2e250513          	addi	a0,a0,738 # 80008828 <syscalls+0x388>
    8000654e:	ffffa097          	auipc	ra,0xffffa
    80006552:	fdc080e7          	jalr	-36(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006556:	00002517          	auipc	a0,0x2
    8000655a:	2f250513          	addi	a0,a0,754 # 80008848 <syscalls+0x3a8>
    8000655e:	ffffa097          	auipc	ra,0xffffa
    80006562:	fcc080e7          	jalr	-52(ra) # 8000052a <panic>

0000000080006566 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006566:	7119                	addi	sp,sp,-128
    80006568:	fc86                	sd	ra,120(sp)
    8000656a:	f8a2                	sd	s0,112(sp)
    8000656c:	f4a6                	sd	s1,104(sp)
    8000656e:	f0ca                	sd	s2,96(sp)
    80006570:	ecce                	sd	s3,88(sp)
    80006572:	e8d2                	sd	s4,80(sp)
    80006574:	e4d6                	sd	s5,72(sp)
    80006576:	e0da                	sd	s6,64(sp)
    80006578:	fc5e                	sd	s7,56(sp)
    8000657a:	f862                	sd	s8,48(sp)
    8000657c:	f466                	sd	s9,40(sp)
    8000657e:	f06a                	sd	s10,32(sp)
    80006580:	ec6e                	sd	s11,24(sp)
    80006582:	0100                	addi	s0,sp,128
    80006584:	8aaa                	mv	s5,a0
    80006586:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006588:	00c52c83          	lw	s9,12(a0)
    8000658c:	001c9c9b          	slliw	s9,s9,0x1
    80006590:	1c82                	slli	s9,s9,0x20
    80006592:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006596:	00025517          	auipc	a0,0x25
    8000659a:	b9250513          	addi	a0,a0,-1134 # 8002b128 <disk+0x2128>
    8000659e:	ffffa097          	auipc	ra,0xffffa
    800065a2:	624080e7          	jalr	1572(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    800065a6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800065a8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800065aa:	00023c17          	auipc	s8,0x23
    800065ae:	a56c0c13          	addi	s8,s8,-1450 # 80029000 <disk>
    800065b2:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800065b4:	4b0d                	li	s6,3
    800065b6:	a0ad                	j	80006620 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800065b8:	00fc0733          	add	a4,s8,a5
    800065bc:	975e                	add	a4,a4,s7
    800065be:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800065c2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800065c4:	0207c563          	bltz	a5,800065ee <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800065c8:	2905                	addiw	s2,s2,1
    800065ca:	0611                	addi	a2,a2,4
    800065cc:	19690d63          	beq	s2,s6,80006766 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    800065d0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800065d2:	00025717          	auipc	a4,0x25
    800065d6:	a4670713          	addi	a4,a4,-1466 # 8002b018 <disk+0x2018>
    800065da:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800065dc:	00074683          	lbu	a3,0(a4)
    800065e0:	fee1                	bnez	a3,800065b8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800065e2:	2785                	addiw	a5,a5,1
    800065e4:	0705                	addi	a4,a4,1
    800065e6:	fe979be3          	bne	a5,s1,800065dc <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800065ea:	57fd                	li	a5,-1
    800065ec:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800065ee:	01205d63          	blez	s2,80006608 <virtio_disk_rw+0xa2>
    800065f2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800065f4:	000a2503          	lw	a0,0(s4)
    800065f8:	00000097          	auipc	ra,0x0
    800065fc:	d8e080e7          	jalr	-626(ra) # 80006386 <free_desc>
      for(int j = 0; j < i; j++)
    80006600:	2d85                	addiw	s11,s11,1
    80006602:	0a11                	addi	s4,s4,4
    80006604:	ffb918e3          	bne	s2,s11,800065f4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006608:	00025597          	auipc	a1,0x25
    8000660c:	b2058593          	addi	a1,a1,-1248 # 8002b128 <disk+0x2128>
    80006610:	00025517          	auipc	a0,0x25
    80006614:	a0850513          	addi	a0,a0,-1528 # 8002b018 <disk+0x2018>
    80006618:	ffffc097          	auipc	ra,0xffffc
    8000661c:	b14080e7          	jalr	-1260(ra) # 8000212c <sleep>
  for(int i = 0; i < 3; i++){
    80006620:	f8040a13          	addi	s4,s0,-128
{
    80006624:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006626:	894e                	mv	s2,s3
    80006628:	b765                	j	800065d0 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000662a:	00025697          	auipc	a3,0x25
    8000662e:	9d66b683          	ld	a3,-1578(a3) # 8002b000 <disk+0x2000>
    80006632:	96ba                	add	a3,a3,a4
    80006634:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006638:	00023817          	auipc	a6,0x23
    8000663c:	9c880813          	addi	a6,a6,-1592 # 80029000 <disk>
    80006640:	00025697          	auipc	a3,0x25
    80006644:	9c068693          	addi	a3,a3,-1600 # 8002b000 <disk+0x2000>
    80006648:	6290                	ld	a2,0(a3)
    8000664a:	963a                	add	a2,a2,a4
    8000664c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006650:	0015e593          	ori	a1,a1,1
    80006654:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006658:	f8842603          	lw	a2,-120(s0)
    8000665c:	628c                	ld	a1,0(a3)
    8000665e:	972e                	add	a4,a4,a1
    80006660:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006664:	20050593          	addi	a1,a0,512
    80006668:	0592                	slli	a1,a1,0x4
    8000666a:	95c2                	add	a1,a1,a6
    8000666c:	577d                	li	a4,-1
    8000666e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006672:	00461713          	slli	a4,a2,0x4
    80006676:	6290                	ld	a2,0(a3)
    80006678:	963a                	add	a2,a2,a4
    8000667a:	03078793          	addi	a5,a5,48
    8000667e:	97c2                	add	a5,a5,a6
    80006680:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006682:	629c                	ld	a5,0(a3)
    80006684:	97ba                	add	a5,a5,a4
    80006686:	4605                	li	a2,1
    80006688:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000668a:	629c                	ld	a5,0(a3)
    8000668c:	97ba                	add	a5,a5,a4
    8000668e:	4809                	li	a6,2
    80006690:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006694:	629c                	ld	a5,0(a3)
    80006696:	973e                	add	a4,a4,a5
    80006698:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000669c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800066a0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066a4:	6698                	ld	a4,8(a3)
    800066a6:	00275783          	lhu	a5,2(a4)
    800066aa:	8b9d                	andi	a5,a5,7
    800066ac:	0786                	slli	a5,a5,0x1
    800066ae:	97ba                	add	a5,a5,a4
    800066b0:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    800066b4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800066b8:	6698                	ld	a4,8(a3)
    800066ba:	00275783          	lhu	a5,2(a4)
    800066be:	2785                	addiw	a5,a5,1
    800066c0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800066c4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800066c8:	100017b7          	lui	a5,0x10001
    800066cc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800066d0:	004aa783          	lw	a5,4(s5)
    800066d4:	02c79163          	bne	a5,a2,800066f6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800066d8:	00025917          	auipc	s2,0x25
    800066dc:	a5090913          	addi	s2,s2,-1456 # 8002b128 <disk+0x2128>
  while(b->disk == 1) {
    800066e0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800066e2:	85ca                	mv	a1,s2
    800066e4:	8556                	mv	a0,s5
    800066e6:	ffffc097          	auipc	ra,0xffffc
    800066ea:	a46080e7          	jalr	-1466(ra) # 8000212c <sleep>
  while(b->disk == 1) {
    800066ee:	004aa783          	lw	a5,4(s5)
    800066f2:	fe9788e3          	beq	a5,s1,800066e2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800066f6:	f8042903          	lw	s2,-128(s0)
    800066fa:	20090793          	addi	a5,s2,512
    800066fe:	00479713          	slli	a4,a5,0x4
    80006702:	00023797          	auipc	a5,0x23
    80006706:	8fe78793          	addi	a5,a5,-1794 # 80029000 <disk>
    8000670a:	97ba                	add	a5,a5,a4
    8000670c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006710:	00025997          	auipc	s3,0x25
    80006714:	8f098993          	addi	s3,s3,-1808 # 8002b000 <disk+0x2000>
    80006718:	00491713          	slli	a4,s2,0x4
    8000671c:	0009b783          	ld	a5,0(s3)
    80006720:	97ba                	add	a5,a5,a4
    80006722:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006726:	854a                	mv	a0,s2
    80006728:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000672c:	00000097          	auipc	ra,0x0
    80006730:	c5a080e7          	jalr	-934(ra) # 80006386 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006734:	8885                	andi	s1,s1,1
    80006736:	f0ed                	bnez	s1,80006718 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006738:	00025517          	auipc	a0,0x25
    8000673c:	9f050513          	addi	a0,a0,-1552 # 8002b128 <disk+0x2128>
    80006740:	ffffa097          	auipc	ra,0xffffa
    80006744:	536080e7          	jalr	1334(ra) # 80000c76 <release>
}
    80006748:	70e6                	ld	ra,120(sp)
    8000674a:	7446                	ld	s0,112(sp)
    8000674c:	74a6                	ld	s1,104(sp)
    8000674e:	7906                	ld	s2,96(sp)
    80006750:	69e6                	ld	s3,88(sp)
    80006752:	6a46                	ld	s4,80(sp)
    80006754:	6aa6                	ld	s5,72(sp)
    80006756:	6b06                	ld	s6,64(sp)
    80006758:	7be2                	ld	s7,56(sp)
    8000675a:	7c42                	ld	s8,48(sp)
    8000675c:	7ca2                	ld	s9,40(sp)
    8000675e:	7d02                	ld	s10,32(sp)
    80006760:	6de2                	ld	s11,24(sp)
    80006762:	6109                	addi	sp,sp,128
    80006764:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006766:	f8042503          	lw	a0,-128(s0)
    8000676a:	20050793          	addi	a5,a0,512
    8000676e:	0792                	slli	a5,a5,0x4
  if(write)
    80006770:	00023817          	auipc	a6,0x23
    80006774:	89080813          	addi	a6,a6,-1904 # 80029000 <disk>
    80006778:	00f80733          	add	a4,a6,a5
    8000677c:	01a036b3          	snez	a3,s10
    80006780:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006784:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006788:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000678c:	7679                	lui	a2,0xffffe
    8000678e:	963e                	add	a2,a2,a5
    80006790:	00025697          	auipc	a3,0x25
    80006794:	87068693          	addi	a3,a3,-1936 # 8002b000 <disk+0x2000>
    80006798:	6298                	ld	a4,0(a3)
    8000679a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000679c:	0a878593          	addi	a1,a5,168
    800067a0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800067a2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800067a4:	6298                	ld	a4,0(a3)
    800067a6:	9732                	add	a4,a4,a2
    800067a8:	45c1                	li	a1,16
    800067aa:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800067ac:	6298                	ld	a4,0(a3)
    800067ae:	9732                	add	a4,a4,a2
    800067b0:	4585                	li	a1,1
    800067b2:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800067b6:	f8442703          	lw	a4,-124(s0)
    800067ba:	628c                	ld	a1,0(a3)
    800067bc:	962e                	add	a2,a2,a1
    800067be:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd200e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800067c2:	0712                	slli	a4,a4,0x4
    800067c4:	6290                	ld	a2,0(a3)
    800067c6:	963a                	add	a2,a2,a4
    800067c8:	058a8593          	addi	a1,s5,88
    800067cc:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800067ce:	6294                	ld	a3,0(a3)
    800067d0:	96ba                	add	a3,a3,a4
    800067d2:	40000613          	li	a2,1024
    800067d6:	c690                	sw	a2,8(a3)
  if(write)
    800067d8:	e40d19e3          	bnez	s10,8000662a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800067dc:	00025697          	auipc	a3,0x25
    800067e0:	8246b683          	ld	a3,-2012(a3) # 8002b000 <disk+0x2000>
    800067e4:	96ba                	add	a3,a3,a4
    800067e6:	4609                	li	a2,2
    800067e8:	00c69623          	sh	a2,12(a3)
    800067ec:	b5b1                	j	80006638 <virtio_disk_rw+0xd2>

00000000800067ee <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067ee:	1101                	addi	sp,sp,-32
    800067f0:	ec06                	sd	ra,24(sp)
    800067f2:	e822                	sd	s0,16(sp)
    800067f4:	e426                	sd	s1,8(sp)
    800067f6:	e04a                	sd	s2,0(sp)
    800067f8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067fa:	00025517          	auipc	a0,0x25
    800067fe:	92e50513          	addi	a0,a0,-1746 # 8002b128 <disk+0x2128>
    80006802:	ffffa097          	auipc	ra,0xffffa
    80006806:	3c0080e7          	jalr	960(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000680a:	10001737          	lui	a4,0x10001
    8000680e:	533c                	lw	a5,96(a4)
    80006810:	8b8d                	andi	a5,a5,3
    80006812:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006814:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006818:	00024797          	auipc	a5,0x24
    8000681c:	7e878793          	addi	a5,a5,2024 # 8002b000 <disk+0x2000>
    80006820:	6b94                	ld	a3,16(a5)
    80006822:	0207d703          	lhu	a4,32(a5)
    80006826:	0026d783          	lhu	a5,2(a3)
    8000682a:	06f70163          	beq	a4,a5,8000688c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000682e:	00022917          	auipc	s2,0x22
    80006832:	7d290913          	addi	s2,s2,2002 # 80029000 <disk>
    80006836:	00024497          	auipc	s1,0x24
    8000683a:	7ca48493          	addi	s1,s1,1994 # 8002b000 <disk+0x2000>
    __sync_synchronize();
    8000683e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006842:	6898                	ld	a4,16(s1)
    80006844:	0204d783          	lhu	a5,32(s1)
    80006848:	8b9d                	andi	a5,a5,7
    8000684a:	078e                	slli	a5,a5,0x3
    8000684c:	97ba                	add	a5,a5,a4
    8000684e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006850:	20078713          	addi	a4,a5,512
    80006854:	0712                	slli	a4,a4,0x4
    80006856:	974a                	add	a4,a4,s2
    80006858:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000685c:	e731                	bnez	a4,800068a8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000685e:	20078793          	addi	a5,a5,512
    80006862:	0792                	slli	a5,a5,0x4
    80006864:	97ca                	add	a5,a5,s2
    80006866:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006868:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000686c:	ffffc097          	auipc	ra,0xffffc
    80006870:	a4c080e7          	jalr	-1460(ra) # 800022b8 <wakeup>

    disk.used_idx += 1;
    80006874:	0204d783          	lhu	a5,32(s1)
    80006878:	2785                	addiw	a5,a5,1
    8000687a:	17c2                	slli	a5,a5,0x30
    8000687c:	93c1                	srli	a5,a5,0x30
    8000687e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006882:	6898                	ld	a4,16(s1)
    80006884:	00275703          	lhu	a4,2(a4)
    80006888:	faf71be3          	bne	a4,a5,8000683e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000688c:	00025517          	auipc	a0,0x25
    80006890:	89c50513          	addi	a0,a0,-1892 # 8002b128 <disk+0x2128>
    80006894:	ffffa097          	auipc	ra,0xffffa
    80006898:	3e2080e7          	jalr	994(ra) # 80000c76 <release>
}
    8000689c:	60e2                	ld	ra,24(sp)
    8000689e:	6442                	ld	s0,16(sp)
    800068a0:	64a2                	ld	s1,8(sp)
    800068a2:	6902                	ld	s2,0(sp)
    800068a4:	6105                	addi	sp,sp,32
    800068a6:	8082                	ret
      panic("virtio_disk_intr status");
    800068a8:	00002517          	auipc	a0,0x2
    800068ac:	fc050513          	addi	a0,a0,-64 # 80008868 <syscalls+0x3c8>
    800068b0:	ffffa097          	auipc	ra,0xffffa
    800068b4:	c7a080e7          	jalr	-902(ra) # 8000052a <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
