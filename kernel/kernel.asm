
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
    80000068:	20c78793          	addi	a5,a5,524 # 80006270 <timervec>
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
    8000055c:	d8050513          	addi	a0,a0,-640 # 800082d8 <digits+0x298>
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
    80000eb6:	da0080e7          	jalr	-608(ra) # 80002c52 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	3f6080e7          	jalr	1014(ra) # 800062b0 <plicinithart>
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
    80000ede:	3fe50513          	addi	a0,a0,1022 # 800082d8 <digits+0x298>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1b650513          	addi	a0,a0,438 # 800080a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	3de50513          	addi	a0,a0,990 # 800082d8 <digits+0x298>
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
    80000f2e:	d00080e7          	jalr	-768(ra) # 80002c2a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	d20080e7          	jalr	-736(ra) # 80002c52 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	360080e7          	jalr	864(ra) # 8000629a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	36e080e7          	jalr	878(ra) # 800062b0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	518080e7          	jalr	1304(ra) # 80003462 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	baa080e7          	jalr	-1110(ra) # 80003afc <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	b58080e7          	jalr	-1192(ra) # 80004ab2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	470080e7          	jalr	1136(ra) # 800063d2 <virtio_disk_init>
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
    80001a08:	e6c7a783          	lw	a5,-404(a5) # 80008870 <first.1>
    80001a0c:	eb89                	bnez	a5,80001a1e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a0e:	00001097          	auipc	ra,0x1
    80001a12:	25c080e7          	jalr	604(ra) # 80002c6a <usertrapret>
}
    80001a16:	60a2                	ld	ra,8(sp)
    80001a18:	6402                	ld	s0,0(sp)
    80001a1a:	0141                	addi	sp,sp,16
    80001a1c:	8082                	ret
    first = 0;
    80001a1e:	00007797          	auipc	a5,0x7
    80001a22:	e407a923          	sw	zero,-430(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001a26:	4505                	li	a0,1
    80001a28:	00002097          	auipc	ra,0x2
    80001a2c:	054080e7          	jalr	84(ra) # 80003a7c <fsinit>
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
    80001aaa:	dce78793          	addi	a5,a5,-562 # 80008874 <nextpid>
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
    80001d26:	b5e58593          	addi	a1,a1,-1186 # 80008880 <initcode>
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
    80001d64:	74a080e7          	jalr	1866(ra) # 800044aa <namei>
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
    80001eb4:	c94080e7          	jalr	-876(ra) # 80004b44 <filedup>
    80001eb8:	00aa3023          	sd	a0,0(s4)
    80001ebc:	b7e5                	j	80001ea4 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ebe:	1509b503          	ld	a0,336(s3)
    80001ec2:	00002097          	auipc	ra,0x2
    80001ec6:	df4080e7          	jalr	-524(ra) # 80003cb6 <idup>
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
    80002010:	bb0080e7          	jalr	-1104(ra) # 80002bbc <swtch>
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
    80002092:	b2e080e7          	jalr	-1234(ra) # 80002bbc <swtch>
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
    800023c8:	00002097          	auipc	ra,0x2
    800023cc:	7ce080e7          	jalr	1998(ra) # 80004b96 <fileclose>
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
    800023e4:	2ea080e7          	jalr	746(ra) # 800046ca <begin_op>
  iput(p->cwd);
    800023e8:	1509b503          	ld	a0,336(s3)
    800023ec:	00002097          	auipc	ra,0x2
    800023f0:	ac2080e7          	jalr	-1342(ra) # 80003eae <iput>
  end_op();
    800023f4:	00002097          	auipc	ra,0x2
    800023f8:	356080e7          	jalr	854(ra) # 8000474a <end_op>
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
    800025a4:	d3850513          	addi	a0,a0,-712 # 800082d8 <digits+0x298>
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
    800025d6:	d06a0a13          	addi	s4,s4,-762 # 800082d8 <digits+0x298>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025da:	00006b97          	auipc	s7,0x6
    800025de:	d2eb8b93          	addi	s7,s7,-722 # 80008308 <states.0>
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
    80002952:	0080                	addi	s0,sp,64
    80002954:	892a                	mv	s2,a0
  
  struct proc *p=myproc();
    80002956:	fffff097          	auipc	ra,0xfffff
    8000295a:	05e080e7          	jalr	94(ra) # 800019b4 <myproc>
    8000295e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	262080e7          	jalr	610(ra) # 80000bc2 <acquire>

  void* local_handler=0;// maybe delete
    80002968:	fc043423          	sd	zero,-56(s0)
  copyin(p->pagetable,(char*)&local_handler,(uint64)p->signal_handlers[i],sizeof(void*));
    8000296c:	00391993          	slli	s3,s2,0x3
    80002970:	99a6                	add	s3,s3,s1
    80002972:	46a1                	li	a3,8
    80002974:	1709b603          	ld	a2,368(s3)
    80002978:	fc840593          	addi	a1,s0,-56
    8000297c:	68a8                	ld	a0,80(s1)
    8000297e:	fffff097          	auipc	ra,0xfffff
    80002982:	d4c080e7          	jalr	-692(ra) # 800016ca <copyin>
  printf("local is: %d\n",local_handler);
    80002986:	fc843583          	ld	a1,-56(s0)
    8000298a:	00006517          	auipc	a0,0x6
    8000298e:	92650513          	addi	a0,a0,-1754 # 800082b0 <digits+0x270>
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	be2080e7          	jalr	-1054(ra) # 80000574 <printf>

  //step 2 -backup proc sigmask
  p->signal_mask_backup=p->signal_mask;
    8000299a:	16c4a783          	lw	a5,364(s1)
    8000299e:	2ef4ae23          	sw	a5,764(s1)
  p->signal_mask=p->signal_handlers_mask[i];
    800029a2:	09c90913          	addi	s2,s2,156
    800029a6:	090a                	slli	s2,s2,0x2
    800029a8:	9926                	add	s2,s2,s1
    800029aa:	00092783          	lw	a5,0(s2)
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
  memmove((void*)& p->trapframe->sp,p->trapframe,sizeof(struct trapframe));
    800029c2:	6cac                	ld	a1,88(s1)
    800029c4:	12000613          	li	a2,288
    800029c8:	03058513          	addi	a0,a1,48
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	34e080e7          	jalr	846(ra) # 80000d1a <memmove>
  
  p->user_trap_frame_backup->sp=p->trapframe->sp;
    800029d4:	2f04b783          	ld	a5,752(s1)
    800029d8:	6cb8                	ld	a4,88(s1)
    800029da:	7b18                	ld	a4,48(a4)
    800029dc:	fb98                	sd	a4,48(a5)
   printf("here&&&\n");
    800029de:	00006517          	auipc	a0,0x6
    800029e2:	8e250513          	addi	a0,a0,-1822 # 800082c0 <digits+0x280>
    800029e6:	ffffe097          	auipc	ra,0xffffe
    800029ea:	b8e080e7          	jalr	-1138(ra) # 80000574 <printf>
  //copyout(p->pagetable,(uint64)p->trapframe,(char*)(&p->user_trap_frame_backup->sp),sizeof(struct trapframe));
      


  //step 6
  p->trapframe->epc=(uint64)p->signal_handlers[i];
    800029ee:	6cbc                	ld	a5,88(s1)
    800029f0:	1709b703          	ld	a4,368(s3)
    800029f4:	ef98                	sd	a4,24(a5)
  
  // step 7
  int sigret_size= endFunc-startCalcSize; // cacl func size
    800029f6:	00000997          	auipc	s3,0x0
    800029fa:	23098993          	addi	s3,s3,560 # 80002c26 <startCalcSize>
  p->trapframe->sp-=sigret_size;
    800029fe:	6cb8                	ld	a4,88(s1)
    80002a00:	00000917          	auipc	s2,0x0
    80002a04:	22a90913          	addi	s2,s2,554 # 80002c2a <trapinit>
    80002a08:	4139093b          	subw	s2,s2,s3
    80002a0c:	7b1c                	ld	a5,48(a4)
    80002a0e:	412787b3          	sub	a5,a5,s2
    80002a12:	fb1c                	sd	a5,48(a4)
  memmove((void*) p->trapframe->sp,sigret,sigret_size);
    80002a14:	6cbc                	ld	a5,88(s1)
    80002a16:	864a                	mv	a2,s2
    80002a18:	fffff597          	auipc	a1,0xfffff
    80002a1c:	01a58593          	addi	a1,a1,26 # 80001a32 <sigret>
    80002a20:	7b88                	ld	a0,48(a5)
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	2f8080e7          	jalr	760(ra) # 80000d1a <memmove>
  

  //step 8
  copyout(p->pagetable,(uint64)startCalcSize,(char*)&p->trapframe->sp,sigret_size);
    80002a2a:	6cb0                	ld	a2,88(s1)
    80002a2c:	86ca                	mv	a3,s2
    80002a2e:	03060613          	addi	a2,a2,48 # 1030 <_entry-0x7fffefd0>
    80002a32:	85ce                	mv	a1,s3
    80002a34:	68a8                	ld	a0,80(s1)
    80002a36:	fffff097          	auipc	ra,0xfffff
    80002a3a:	c08080e7          	jalr	-1016(ra) # 8000163e <copyout>
  copyout(p->pagetable,(uint64)startCalcSize,(char*)p->trapframe->sp,sigret_size);

  p->trapframe->a0=i; // put signum in a0
  p->trapframe->ra=p->trapframe->sp; */

}
    80002a3e:	70e2                	ld	ra,56(sp)
    80002a40:	7442                	ld	s0,48(sp)
    80002a42:	74a2                	ld	s1,40(sp)
    80002a44:	7902                	ld	s2,32(sp)
    80002a46:	69e2                	ld	s3,24(sp)
    80002a48:	6121                	addi	sp,sp,64
    80002a4a:	8082                	ret

0000000080002a4c <handle_pendding_sinals>:

void
handle_pendding_sinals(){
    80002a4c:	7159                	addi	sp,sp,-112
    80002a4e:	f486                	sd	ra,104(sp)
    80002a50:	f0a2                	sd	s0,96(sp)
    80002a52:	eca6                	sd	s1,88(sp)
    80002a54:	e8ca                	sd	s2,80(sp)
    80002a56:	e4ce                	sd	s3,72(sp)
    80002a58:	e0d2                	sd	s4,64(sp)
    80002a5a:	fc56                	sd	s5,56(sp)
    80002a5c:	f85a                	sd	s6,48(sp)
    80002a5e:	f45e                	sd	s7,40(sp)
    80002a60:	f062                	sd	s8,32(sp)
    80002a62:	ec66                	sd	s9,24(sp)
    80002a64:	e86a                	sd	s10,16(sp)
    80002a66:	e46e                	sd	s11,8(sp)
    80002a68:	1880                	addi	s0,sp,112
 struct proc *p=myproc();
    80002a6a:	fffff097          	auipc	ra,0xfffff
    80002a6e:	f4a080e7          	jalr	-182(ra) # 800019b4 <myproc>
    80002a72:	89aa                	mv	s3,a0
 
  while (p->frozen==1){// while the process is still frozen
    80002a74:	2f852703          	lw	a4,760(a0)
    80002a78:	4785                	li	a5,1
    80002a7a:	04f71363          	bne	a4,a5,80002ac0 <handle_pendding_sinals+0x74>
     if(p->frozen==1 && ((p->pendding_signals & (uint)1<<SIGCONT)==0))// check if proc is frozen and cont bit is off
    80002a7e:	00080937          	lui	s2,0x80
      yield();
    else if(p->frozen==1 && ((p->pendding_signals & (uint)1<<SIGCONT)!=0)){ // if frozen and cont bit is on handle it
      sigContHandler();
      p->pendding_signals &= ~((uint)1<<SIGCONT);// discard sigcont 
    80002a82:	fff807b7          	lui	a5,0xfff80
    80002a86:	fff78a13          	addi	s4,a5,-1 # fffffffffff7ffff <end+0xffffffff7ff53fff>
  while (p->frozen==1){// while the process is still frozen
    80002a8a:	4485                	li	s1,1
    80002a8c:	a809                	j	80002a9e <handle_pendding_sinals+0x52>
      yield();
    80002a8e:	fffff097          	auipc	ra,0xfffff
    80002a92:	662080e7          	jalr	1634(ra) # 800020f0 <yield>
  while (p->frozen==1){// while the process is still frozen
    80002a96:	2f89a783          	lw	a5,760(s3)
    80002a9a:	02979363          	bne	a5,s1,80002ac0 <handle_pendding_sinals+0x74>
     if(p->frozen==1 && ((p->pendding_signals & (uint)1<<SIGCONT)==0))// check if proc is frozen and cont bit is off
    80002a9e:	1689a783          	lw	a5,360(s3)
    80002aa2:	0127f7b3          	and	a5,a5,s2
    80002aa6:	2781                	sext.w	a5,a5
    80002aa8:	d3fd                	beqz	a5,80002a8e <handle_pendding_sinals+0x42>
      sigContHandler();
    80002aaa:	00000097          	auipc	ra,0x0
    80002aae:	c1c080e7          	jalr	-996(ra) # 800026c6 <sigContHandler>
      p->pendding_signals &= ~((uint)1<<SIGCONT);// discard sigcont 
    80002ab2:	1689a783          	lw	a5,360(s3)
    80002ab6:	0147f7b3          	and	a5,a5,s4
    80002aba:	16f9a423          	sw	a5,360(s3)
    80002abe:	bfe1                	j	80002a96 <handle_pendding_sinals+0x4a>
    }
  }  
  for(int i=0;i<32;i++){
    80002ac0:	17098a93          	addi	s5,s3,368
handle_pendding_sinals(){
    80002ac4:	4905                	li	s2,1
    80002ac6:	4481                	li	s1,0
    uint signal_bit_to_check= 1<<i;
    80002ac8:	4b85                	li	s7,1
  for(int i=0;i<32;i++){
    80002aca:	4c7d                	li	s8,31
    void *currentHandler=p->signal_handlers[i];
    if((p->pendding_signals & signal_bit_to_check)!=0 && p->signal_handling_flag==0){
      

      if(i== SIGKILL)
    80002acc:	4ca5                	li	s9,9
        sigKillHandler();
      else if(i== SIGSTOP)
    80002ace:	4d45                	li	s10,17
      //check if signal is blocked in the process 
      else if((p->signal_mask & signal_bit_to_check) ==0 ){
        //signal is not blocked 

        //check if signal handler is IGN if true discard the signal
        if(currentHandler==(void*) SIG_IGN)
    80002ad0:	4d85                	li	s11,1
    80002ad2:	a805                	j	80002b02 <handle_pendding_sinals+0xb6>
        sigKillHandler();
    80002ad4:	00000097          	auipc	ra,0x0
    80002ad8:	baa080e7          	jalr	-1110(ra) # 8000267e <sigKillHandler>
    80002adc:	a005                	j	80002afc <handle_pendding_sinals+0xb0>
        sigStopHandler();
    80002ade:	00000097          	auipc	ra,0x0
    80002ae2:	bca080e7          	jalr	-1078(ra) # 800026a8 <sigStopHandler>
    80002ae6:	a819                	j	80002afc <handle_pendding_sinals+0xb0>
          p->pendding_signals &= ~(signal_bit_to_check);
    80002ae8:	fffa4a13          	not	s4,s4
    80002aec:	00ea7733          	and	a4,s4,a4
    80002af0:	16e9a423          	sw	a4,360(s3)
  for(int i=0;i<32;i++){
    80002af4:	0009079b          	sext.w	a5,s2
    80002af8:	0afc4363          	blt	s8,a5,80002b9e <handle_pendding_sinals+0x152>
    80002afc:	2485                	addiw	s1,s1,1
    80002afe:	2905                	addiw	s2,s2,1
    80002b00:	0aa1                	addi	s5,s5,8
    80002b02:	00048b1b          	sext.w	s6,s1
    uint signal_bit_to_check= 1<<i;
    80002b06:	009b9a3b          	sllw	s4,s7,s1
    if((p->pendding_signals & signal_bit_to_check)!=0 && p->signal_handling_flag==0){
    80002b0a:	1689a703          	lw	a4,360(s3)
    80002b0e:	014777b3          	and	a5,a4,s4
    80002b12:	2781                	sext.w	a5,a5
    80002b14:	d3e5                	beqz	a5,80002af4 <handle_pendding_sinals+0xa8>
    80002b16:	3009a783          	lw	a5,768(s3)
    80002b1a:	ffe9                	bnez	a5,80002af4 <handle_pendding_sinals+0xa8>
      if(i== SIGKILL)
    80002b1c:	fb9b0ce3          	beq	s6,s9,80002ad4 <handle_pendding_sinals+0x88>
      else if(i== SIGSTOP)
    80002b20:	fbab0fe3          	beq	s6,s10,80002ade <handle_pendding_sinals+0x92>
      else if((p->signal_mask & signal_bit_to_check) ==0 ){
    80002b24:	16c9a783          	lw	a5,364(s3)
    80002b28:	0147f7b3          	and	a5,a5,s4
    80002b2c:	2781                	sext.w	a5,a5
    80002b2e:	f3f9                	bnez	a5,80002af4 <handle_pendding_sinals+0xa8>
    void *currentHandler=p->signal_handlers[i];
    80002b30:	000ab783          	ld	a5,0(s5)
        if(currentHandler==(void*) SIG_IGN)
    80002b34:	fbb78ae3          	beq	a5,s11,80002ae8 <handle_pendding_sinals+0x9c>
        else if(currentHandler== (void*)  SIGSTOP){
    80002b38:	03a78663          	beq	a5,s10,80002b64 <handle_pendding_sinals+0x118>
          sigStopHandler();
          p->pendding_signals &= ~(signal_bit_to_check);
        }
          
        else if(currentHandler==(void*) SIGCONT){
    80002b3c:	474d                	li	a4,19
    80002b3e:	02e78f63          	beq	a5,a4,80002b7c <handle_pendding_sinals+0x130>
    
          sigContHandler();
          p->pendding_signals &= ~(signal_bit_to_check);
        }
        else if( currentHandler==(void*) SIGKILL || currentHandler==(void*) SIG_DFL)
    80002b42:	05978963          	beq	a5,s9,80002b94 <handle_pendding_sinals+0x148>
    80002b46:	c7b9                	beqz	a5,80002b94 <handle_pendding_sinals+0x148>
          sigKillHandler();
        else{// its a user space handler 
          printf("herer!\n\n\n");
    80002b48:	00005517          	auipc	a0,0x5
    80002b4c:	78850513          	addi	a0,a0,1928 # 800082d0 <digits+0x290>
    80002b50:	ffffe097          	auipc	ra,0xffffe
    80002b54:	a24080e7          	jalr	-1500(ra) # 80000574 <printf>
          userhandler(i);
    80002b58:	855a                	mv	a0,s6
    80002b5a:	00000097          	auipc	ra,0x0
    80002b5e:	dec080e7          	jalr	-532(ra) # 80002946 <userhandler>
    80002b62:	bf49                	j	80002af4 <handle_pendding_sinals+0xa8>
          sigStopHandler();
    80002b64:	00000097          	auipc	ra,0x0
    80002b68:	b44080e7          	jalr	-1212(ra) # 800026a8 <sigStopHandler>
          p->pendding_signals &= ~(signal_bit_to_check);
    80002b6c:	fffa4793          	not	a5,s4
    80002b70:	1689a703          	lw	a4,360(s3)
    80002b74:	8ff9                	and	a5,a5,a4
    80002b76:	16f9a423          	sw	a5,360(s3)
    80002b7a:	bfad                	j	80002af4 <handle_pendding_sinals+0xa8>
          sigContHandler();
    80002b7c:	00000097          	auipc	ra,0x0
    80002b80:	b4a080e7          	jalr	-1206(ra) # 800026c6 <sigContHandler>
          p->pendding_signals &= ~(signal_bit_to_check);
    80002b84:	fffa4793          	not	a5,s4
    80002b88:	1689a703          	lw	a4,360(s3)
    80002b8c:	8ff9                	and	a5,a5,a4
    80002b8e:	16f9a423          	sw	a5,360(s3)
    80002b92:	b78d                	j	80002af4 <handle_pendding_sinals+0xa8>
          sigKillHandler();
    80002b94:	00000097          	auipc	ra,0x0
    80002b98:	aea080e7          	jalr	-1302(ra) # 8000267e <sigKillHandler>
    80002b9c:	bfa1                	j	80002af4 <handle_pendding_sinals+0xa8>


    }
  }
  
    80002b9e:	70a6                	ld	ra,104(sp)
    80002ba0:	7406                	ld	s0,96(sp)
    80002ba2:	64e6                	ld	s1,88(sp)
    80002ba4:	6946                	ld	s2,80(sp)
    80002ba6:	69a6                	ld	s3,72(sp)
    80002ba8:	6a06                	ld	s4,64(sp)
    80002baa:	7ae2                	ld	s5,56(sp)
    80002bac:	7b42                	ld	s6,48(sp)
    80002bae:	7ba2                	ld	s7,40(sp)
    80002bb0:	7c02                	ld	s8,32(sp)
    80002bb2:	6ce2                	ld	s9,24(sp)
    80002bb4:	6d42                	ld	s10,16(sp)
    80002bb6:	6da2                	ld	s11,8(sp)
    80002bb8:	6165                	addi	sp,sp,112
    80002bba:	8082                	ret

0000000080002bbc <swtch>:
    80002bbc:	00153023          	sd	ra,0(a0)
    80002bc0:	00253423          	sd	sp,8(a0)
    80002bc4:	e900                	sd	s0,16(a0)
    80002bc6:	ed04                	sd	s1,24(a0)
    80002bc8:	03253023          	sd	s2,32(a0)
    80002bcc:	03353423          	sd	s3,40(a0)
    80002bd0:	03453823          	sd	s4,48(a0)
    80002bd4:	03553c23          	sd	s5,56(a0)
    80002bd8:	05653023          	sd	s6,64(a0)
    80002bdc:	05753423          	sd	s7,72(a0)
    80002be0:	05853823          	sd	s8,80(a0)
    80002be4:	05953c23          	sd	s9,88(a0)
    80002be8:	07a53023          	sd	s10,96(a0)
    80002bec:	07b53423          	sd	s11,104(a0)
    80002bf0:	0005b083          	ld	ra,0(a1)
    80002bf4:	0085b103          	ld	sp,8(a1)
    80002bf8:	6980                	ld	s0,16(a1)
    80002bfa:	6d84                	ld	s1,24(a1)
    80002bfc:	0205b903          	ld	s2,32(a1)
    80002c00:	0285b983          	ld	s3,40(a1)
    80002c04:	0305ba03          	ld	s4,48(a1)
    80002c08:	0385ba83          	ld	s5,56(a1)
    80002c0c:	0405bb03          	ld	s6,64(a1)
    80002c10:	0485bb83          	ld	s7,72(a1)
    80002c14:	0505bc03          	ld	s8,80(a1)
    80002c18:	0585bc83          	ld	s9,88(a1)
    80002c1c:	0605bd03          	ld	s10,96(a1)
    80002c20:	0685bd83          	ld	s11,104(a1)
    80002c24:	8082                	ret

0000000080002c26 <startCalcSize>:
    80002c26:	e0dfe0ef          	jal	ra,80001a32 <sigret>

0000000080002c2a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002c2a:	1141                	addi	sp,sp,-16
    80002c2c:	e406                	sd	ra,8(sp)
    80002c2e:	e022                	sd	s0,0(sp)
    80002c30:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c32:	00005597          	auipc	a1,0x5
    80002c36:	70658593          	addi	a1,a1,1798 # 80008338 <states.0+0x30>
    80002c3a:	0001b517          	auipc	a0,0x1b
    80002c3e:	c9650513          	addi	a0,a0,-874 # 8001d8d0 <tickslock>
    80002c42:	ffffe097          	auipc	ra,0xffffe
    80002c46:	ef0080e7          	jalr	-272(ra) # 80000b32 <initlock>
}
    80002c4a:	60a2                	ld	ra,8(sp)
    80002c4c:	6402                	ld	s0,0(sp)
    80002c4e:	0141                	addi	sp,sp,16
    80002c50:	8082                	ret

0000000080002c52 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002c52:	1141                	addi	sp,sp,-16
    80002c54:	e422                	sd	s0,8(sp)
    80002c56:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c58:	00003797          	auipc	a5,0x3
    80002c5c:	58878793          	addi	a5,a5,1416 # 800061e0 <kernelvec>
    80002c60:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002c64:	6422                	ld	s0,8(sp)
    80002c66:	0141                	addi	sp,sp,16
    80002c68:	8082                	ret

0000000080002c6a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002c6a:	1101                	addi	sp,sp,-32
    80002c6c:	ec06                	sd	ra,24(sp)
    80002c6e:	e822                	sd	s0,16(sp)
    80002c70:	e426                	sd	s1,8(sp)
    80002c72:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002c74:	fffff097          	auipc	ra,0xfffff
    80002c78:	d40080e7          	jalr	-704(ra) # 800019b4 <myproc>
    80002c7c:	84aa                	mv	s1,a0
  handle_pendding_sinals();
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	dce080e7          	jalr	-562(ra) # 80002a4c <handle_pendding_sinals>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c86:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002c8a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c8c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002c90:	00004617          	auipc	a2,0x4
    80002c94:	37060613          	addi	a2,a2,880 # 80007000 <_trampoline>
    80002c98:	00004697          	auipc	a3,0x4
    80002c9c:	36868693          	addi	a3,a3,872 # 80007000 <_trampoline>
    80002ca0:	8e91                	sub	a3,a3,a2
    80002ca2:	040007b7          	lui	a5,0x4000
    80002ca6:	17fd                	addi	a5,a5,-1
    80002ca8:	07b2                	slli	a5,a5,0xc
    80002caa:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cac:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002cb0:	6cb8                	ld	a4,88(s1)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002cb2:	180026f3          	csrr	a3,satp
    80002cb6:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002cb8:	6cb8                	ld	a4,88(s1)
    80002cba:	60b4                	ld	a3,64(s1)
    80002cbc:	6585                	lui	a1,0x1
    80002cbe:	96ae                	add	a3,a3,a1
    80002cc0:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002cc2:	6cb8                	ld	a4,88(s1)
    80002cc4:	00000697          	auipc	a3,0x0
    80002cc8:	13a68693          	addi	a3,a3,314 # 80002dfe <usertrap>
    80002ccc:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002cce:	6cb8                	ld	a4,88(s1)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002cd0:	8692                	mv	a3,tp
    80002cd2:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cd4:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002cd8:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002cdc:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ce0:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002ce4:	6cb8                	ld	a4,88(s1)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ce6:	6f18                	ld	a4,24(a4)
    80002ce8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002cec:	68ac                	ld	a1,80(s1)
    80002cee:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002cf0:	00004717          	auipc	a4,0x4
    80002cf4:	3a070713          	addi	a4,a4,928 # 80007090 <userret>
    80002cf8:	8f11                	sub	a4,a4,a2
    80002cfa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002cfc:	577d                	li	a4,-1
    80002cfe:	177e                	slli	a4,a4,0x3f
    80002d00:	8dd9                	or	a1,a1,a4
    80002d02:	02000537          	lui	a0,0x2000
    80002d06:	157d                	addi	a0,a0,-1
    80002d08:	0536                	slli	a0,a0,0xd
    80002d0a:	9782                	jalr	a5
}
    80002d0c:	60e2                	ld	ra,24(sp)
    80002d0e:	6442                	ld	s0,16(sp)
    80002d10:	64a2                	ld	s1,8(sp)
    80002d12:	6105                	addi	sp,sp,32
    80002d14:	8082                	ret

0000000080002d16 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002d16:	1101                	addi	sp,sp,-32
    80002d18:	ec06                	sd	ra,24(sp)
    80002d1a:	e822                	sd	s0,16(sp)
    80002d1c:	e426                	sd	s1,8(sp)
    80002d1e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002d20:	0001b497          	auipc	s1,0x1b
    80002d24:	bb048493          	addi	s1,s1,-1104 # 8001d8d0 <tickslock>
    80002d28:	8526                	mv	a0,s1
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	e98080e7          	jalr	-360(ra) # 80000bc2 <acquire>
  ticks++;
    80002d32:	00006517          	auipc	a0,0x6
    80002d36:	2fe50513          	addi	a0,a0,766 # 80009030 <ticks>
    80002d3a:	411c                	lw	a5,0(a0)
    80002d3c:	2785                	addiw	a5,a5,1
    80002d3e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	578080e7          	jalr	1400(ra) # 800022b8 <wakeup>
  release(&tickslock);
    80002d48:	8526                	mv	a0,s1
    80002d4a:	ffffe097          	auipc	ra,0xffffe
    80002d4e:	f2c080e7          	jalr	-212(ra) # 80000c76 <release>
}
    80002d52:	60e2                	ld	ra,24(sp)
    80002d54:	6442                	ld	s0,16(sp)
    80002d56:	64a2                	ld	s1,8(sp)
    80002d58:	6105                	addi	sp,sp,32
    80002d5a:	8082                	ret

0000000080002d5c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002d5c:	1101                	addi	sp,sp,-32
    80002d5e:	ec06                	sd	ra,24(sp)
    80002d60:	e822                	sd	s0,16(sp)
    80002d62:	e426                	sd	s1,8(sp)
    80002d64:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d66:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002d6a:	00074d63          	bltz	a4,80002d84 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002d6e:	57fd                	li	a5,-1
    80002d70:	17fe                	slli	a5,a5,0x3f
    80002d72:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002d74:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002d76:	06f70363          	beq	a4,a5,80002ddc <devintr+0x80>
  }
}
    80002d7a:	60e2                	ld	ra,24(sp)
    80002d7c:	6442                	ld	s0,16(sp)
    80002d7e:	64a2                	ld	s1,8(sp)
    80002d80:	6105                	addi	sp,sp,32
    80002d82:	8082                	ret
     (scause & 0xff) == 9){
    80002d84:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002d88:	46a5                	li	a3,9
    80002d8a:	fed792e3          	bne	a5,a3,80002d6e <devintr+0x12>
    int irq = plic_claim();
    80002d8e:	00003097          	auipc	ra,0x3
    80002d92:	55a080e7          	jalr	1370(ra) # 800062e8 <plic_claim>
    80002d96:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002d98:	47a9                	li	a5,10
    80002d9a:	02f50763          	beq	a0,a5,80002dc8 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002d9e:	4785                	li	a5,1
    80002da0:	02f50963          	beq	a0,a5,80002dd2 <devintr+0x76>
    return 1;
    80002da4:	4505                	li	a0,1
    } else if(irq){
    80002da6:	d8f1                	beqz	s1,80002d7a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002da8:	85a6                	mv	a1,s1
    80002daa:	00005517          	auipc	a0,0x5
    80002dae:	59650513          	addi	a0,a0,1430 # 80008340 <states.0+0x38>
    80002db2:	ffffd097          	auipc	ra,0xffffd
    80002db6:	7c2080e7          	jalr	1986(ra) # 80000574 <printf>
      plic_complete(irq);
    80002dba:	8526                	mv	a0,s1
    80002dbc:	00003097          	auipc	ra,0x3
    80002dc0:	550080e7          	jalr	1360(ra) # 8000630c <plic_complete>
    return 1;
    80002dc4:	4505                	li	a0,1
    80002dc6:	bf55                	j	80002d7a <devintr+0x1e>
      uartintr();
    80002dc8:	ffffe097          	auipc	ra,0xffffe
    80002dcc:	bbe080e7          	jalr	-1090(ra) # 80000986 <uartintr>
    80002dd0:	b7ed                	j	80002dba <devintr+0x5e>
      virtio_disk_intr();
    80002dd2:	00004097          	auipc	ra,0x4
    80002dd6:	9cc080e7          	jalr	-1588(ra) # 8000679e <virtio_disk_intr>
    80002dda:	b7c5                	j	80002dba <devintr+0x5e>
    if(cpuid() == 0){
    80002ddc:	fffff097          	auipc	ra,0xfffff
    80002de0:	bac080e7          	jalr	-1108(ra) # 80001988 <cpuid>
    80002de4:	c901                	beqz	a0,80002df4 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002de6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002dea:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002dec:	14479073          	csrw	sip,a5
    return 2;
    80002df0:	4509                	li	a0,2
    80002df2:	b761                	j	80002d7a <devintr+0x1e>
      clockintr();
    80002df4:	00000097          	auipc	ra,0x0
    80002df8:	f22080e7          	jalr	-222(ra) # 80002d16 <clockintr>
    80002dfc:	b7ed                	j	80002de6 <devintr+0x8a>

0000000080002dfe <usertrap>:
{
    80002dfe:	1101                	addi	sp,sp,-32
    80002e00:	ec06                	sd	ra,24(sp)
    80002e02:	e822                	sd	s0,16(sp)
    80002e04:	e426                	sd	s1,8(sp)
    80002e06:	e04a                	sd	s2,0(sp)
    80002e08:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e0a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002e0e:	1007f793          	andi	a5,a5,256
    80002e12:	e3ad                	bnez	a5,80002e74 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e14:	00003797          	auipc	a5,0x3
    80002e18:	3cc78793          	addi	a5,a5,972 # 800061e0 <kernelvec>
    80002e1c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	b94080e7          	jalr	-1132(ra) # 800019b4 <myproc>
    80002e28:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e2a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e2c:	14102773          	csrr	a4,sepc
    80002e30:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e32:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002e36:	47a1                	li	a5,8
    80002e38:	04f71c63          	bne	a4,a5,80002e90 <usertrap+0x92>
    if(p->killed)
    80002e3c:	551c                	lw	a5,40(a0)
    80002e3e:	e3b9                	bnez	a5,80002e84 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002e40:	6cb8                	ld	a4,88(s1)
    80002e42:	6f1c                	ld	a5,24(a4)
    80002e44:	0791                	addi	a5,a5,4
    80002e46:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e48:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002e4c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e50:	10079073          	csrw	sstatus,a5
    syscall();
    80002e54:	00000097          	auipc	ra,0x0
    80002e58:	2e0080e7          	jalr	736(ra) # 80003134 <syscall>
  if(p->killed)
    80002e5c:	549c                	lw	a5,40(s1)
    80002e5e:	ebc1                	bnez	a5,80002eee <usertrap+0xf0>
  usertrapret();
    80002e60:	00000097          	auipc	ra,0x0
    80002e64:	e0a080e7          	jalr	-502(ra) # 80002c6a <usertrapret>
}
    80002e68:	60e2                	ld	ra,24(sp)
    80002e6a:	6442                	ld	s0,16(sp)
    80002e6c:	64a2                	ld	s1,8(sp)
    80002e6e:	6902                	ld	s2,0(sp)
    80002e70:	6105                	addi	sp,sp,32
    80002e72:	8082                	ret
    panic("usertrap: not from user mode");
    80002e74:	00005517          	auipc	a0,0x5
    80002e78:	4ec50513          	addi	a0,a0,1260 # 80008360 <states.0+0x58>
    80002e7c:	ffffd097          	auipc	ra,0xffffd
    80002e80:	6ae080e7          	jalr	1710(ra) # 8000052a <panic>
      exit(-1);
    80002e84:	557d                	li	a0,-1
    80002e86:	fffff097          	auipc	ra,0xfffff
    80002e8a:	502080e7          	jalr	1282(ra) # 80002388 <exit>
    80002e8e:	bf4d                	j	80002e40 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002e90:	00000097          	auipc	ra,0x0
    80002e94:	ecc080e7          	jalr	-308(ra) # 80002d5c <devintr>
    80002e98:	892a                	mv	s2,a0
    80002e9a:	c501                	beqz	a0,80002ea2 <usertrap+0xa4>
  if(p->killed)
    80002e9c:	549c                	lw	a5,40(s1)
    80002e9e:	c3a1                	beqz	a5,80002ede <usertrap+0xe0>
    80002ea0:	a815                	j	80002ed4 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ea2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ea6:	5890                	lw	a2,48(s1)
    80002ea8:	00005517          	auipc	a0,0x5
    80002eac:	4d850513          	addi	a0,a0,1240 # 80008380 <states.0+0x78>
    80002eb0:	ffffd097          	auipc	ra,0xffffd
    80002eb4:	6c4080e7          	jalr	1732(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002eb8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ebc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ec0:	00005517          	auipc	a0,0x5
    80002ec4:	4f050513          	addi	a0,a0,1264 # 800083b0 <states.0+0xa8>
    80002ec8:	ffffd097          	auipc	ra,0xffffd
    80002ecc:	6ac080e7          	jalr	1708(ra) # 80000574 <printf>
    p->killed = 1;
    80002ed0:	4785                	li	a5,1
    80002ed2:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002ed4:	557d                	li	a0,-1
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	4b2080e7          	jalr	1202(ra) # 80002388 <exit>
  if(which_dev == 2)
    80002ede:	4789                	li	a5,2
    80002ee0:	f8f910e3          	bne	s2,a5,80002e60 <usertrap+0x62>
    yield();
    80002ee4:	fffff097          	auipc	ra,0xfffff
    80002ee8:	20c080e7          	jalr	524(ra) # 800020f0 <yield>
    80002eec:	bf95                	j	80002e60 <usertrap+0x62>
  int which_dev = 0;
    80002eee:	4901                	li	s2,0
    80002ef0:	b7d5                	j	80002ed4 <usertrap+0xd6>

0000000080002ef2 <kerneltrap>:
{
    80002ef2:	7179                	addi	sp,sp,-48
    80002ef4:	f406                	sd	ra,40(sp)
    80002ef6:	f022                	sd	s0,32(sp)
    80002ef8:	ec26                	sd	s1,24(sp)
    80002efa:	e84a                	sd	s2,16(sp)
    80002efc:	e44e                	sd	s3,8(sp)
    80002efe:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f00:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f04:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f08:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002f0c:	1004f793          	andi	a5,s1,256
    80002f10:	cb85                	beqz	a5,80002f40 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f12:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002f16:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002f18:	ef85                	bnez	a5,80002f50 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002f1a:	00000097          	auipc	ra,0x0
    80002f1e:	e42080e7          	jalr	-446(ra) # 80002d5c <devintr>
    80002f22:	cd1d                	beqz	a0,80002f60 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING )
    80002f24:	4789                	li	a5,2
    80002f26:	06f50a63          	beq	a0,a5,80002f9a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f2a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f2e:	10049073          	csrw	sstatus,s1
}
    80002f32:	70a2                	ld	ra,40(sp)
    80002f34:	7402                	ld	s0,32(sp)
    80002f36:	64e2                	ld	s1,24(sp)
    80002f38:	6942                	ld	s2,16(sp)
    80002f3a:	69a2                	ld	s3,8(sp)
    80002f3c:	6145                	addi	sp,sp,48
    80002f3e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002f40:	00005517          	auipc	a0,0x5
    80002f44:	49050513          	addi	a0,a0,1168 # 800083d0 <states.0+0xc8>
    80002f48:	ffffd097          	auipc	ra,0xffffd
    80002f4c:	5e2080e7          	jalr	1506(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002f50:	00005517          	auipc	a0,0x5
    80002f54:	4a850513          	addi	a0,a0,1192 # 800083f8 <states.0+0xf0>
    80002f58:	ffffd097          	auipc	ra,0xffffd
    80002f5c:	5d2080e7          	jalr	1490(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002f60:	85ce                	mv	a1,s3
    80002f62:	00005517          	auipc	a0,0x5
    80002f66:	4b650513          	addi	a0,a0,1206 # 80008418 <states.0+0x110>
    80002f6a:	ffffd097          	auipc	ra,0xffffd
    80002f6e:	60a080e7          	jalr	1546(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f72:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f76:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f7a:	00005517          	auipc	a0,0x5
    80002f7e:	4ae50513          	addi	a0,a0,1198 # 80008428 <states.0+0x120>
    80002f82:	ffffd097          	auipc	ra,0xffffd
    80002f86:	5f2080e7          	jalr	1522(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002f8a:	00005517          	auipc	a0,0x5
    80002f8e:	4b650513          	addi	a0,a0,1206 # 80008440 <states.0+0x138>
    80002f92:	ffffd097          	auipc	ra,0xffffd
    80002f96:	598080e7          	jalr	1432(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING )
    80002f9a:	fffff097          	auipc	ra,0xfffff
    80002f9e:	a1a080e7          	jalr	-1510(ra) # 800019b4 <myproc>
    80002fa2:	d541                	beqz	a0,80002f2a <kerneltrap+0x38>
    80002fa4:	fffff097          	auipc	ra,0xfffff
    80002fa8:	a10080e7          	jalr	-1520(ra) # 800019b4 <myproc>
    80002fac:	4d18                	lw	a4,24(a0)
    80002fae:	4791                	li	a5,4
    80002fb0:	f6f71de3          	bne	a4,a5,80002f2a <kerneltrap+0x38>
    yield();
    80002fb4:	fffff097          	auipc	ra,0xfffff
    80002fb8:	13c080e7          	jalr	316(ra) # 800020f0 <yield>
    80002fbc:	b7bd                	j	80002f2a <kerneltrap+0x38>

0000000080002fbe <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002fbe:	1101                	addi	sp,sp,-32
    80002fc0:	ec06                	sd	ra,24(sp)
    80002fc2:	e822                	sd	s0,16(sp)
    80002fc4:	e426                	sd	s1,8(sp)
    80002fc6:	1000                	addi	s0,sp,32
    80002fc8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002fca:	fffff097          	auipc	ra,0xfffff
    80002fce:	9ea080e7          	jalr	-1558(ra) # 800019b4 <myproc>
  switch (n) {
    80002fd2:	4795                	li	a5,5
    80002fd4:	0497e163          	bltu	a5,s1,80003016 <argraw+0x58>
    80002fd8:	048a                	slli	s1,s1,0x2
    80002fda:	00005717          	auipc	a4,0x5
    80002fde:	49e70713          	addi	a4,a4,1182 # 80008478 <states.0+0x170>
    80002fe2:	94ba                	add	s1,s1,a4
    80002fe4:	409c                	lw	a5,0(s1)
    80002fe6:	97ba                	add	a5,a5,a4
    80002fe8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002fea:	6d3c                	ld	a5,88(a0)
    80002fec:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002fee:	60e2                	ld	ra,24(sp)
    80002ff0:	6442                	ld	s0,16(sp)
    80002ff2:	64a2                	ld	s1,8(sp)
    80002ff4:	6105                	addi	sp,sp,32
    80002ff6:	8082                	ret
    return p->trapframe->a1;
    80002ff8:	6d3c                	ld	a5,88(a0)
    80002ffa:	7fa8                	ld	a0,120(a5)
    80002ffc:	bfcd                	j	80002fee <argraw+0x30>
    return p->trapframe->a2;
    80002ffe:	6d3c                	ld	a5,88(a0)
    80003000:	63c8                	ld	a0,128(a5)
    80003002:	b7f5                	j	80002fee <argraw+0x30>
    return p->trapframe->a3;
    80003004:	6d3c                	ld	a5,88(a0)
    80003006:	67c8                	ld	a0,136(a5)
    80003008:	b7dd                	j	80002fee <argraw+0x30>
    return p->trapframe->a4;
    8000300a:	6d3c                	ld	a5,88(a0)
    8000300c:	6bc8                	ld	a0,144(a5)
    8000300e:	b7c5                	j	80002fee <argraw+0x30>
    return p->trapframe->a5;
    80003010:	6d3c                	ld	a5,88(a0)
    80003012:	6fc8                	ld	a0,152(a5)
    80003014:	bfe9                	j	80002fee <argraw+0x30>
  panic("argraw");
    80003016:	00005517          	auipc	a0,0x5
    8000301a:	43a50513          	addi	a0,a0,1082 # 80008450 <states.0+0x148>
    8000301e:	ffffd097          	auipc	ra,0xffffd
    80003022:	50c080e7          	jalr	1292(ra) # 8000052a <panic>

0000000080003026 <fetchaddr>:
{
    80003026:	1101                	addi	sp,sp,-32
    80003028:	ec06                	sd	ra,24(sp)
    8000302a:	e822                	sd	s0,16(sp)
    8000302c:	e426                	sd	s1,8(sp)
    8000302e:	e04a                	sd	s2,0(sp)
    80003030:	1000                	addi	s0,sp,32
    80003032:	84aa                	mv	s1,a0
    80003034:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003036:	fffff097          	auipc	ra,0xfffff
    8000303a:	97e080e7          	jalr	-1666(ra) # 800019b4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    8000303e:	653c                	ld	a5,72(a0)
    80003040:	02f4f863          	bgeu	s1,a5,80003070 <fetchaddr+0x4a>
    80003044:	00848713          	addi	a4,s1,8
    80003048:	02e7e663          	bltu	a5,a4,80003074 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000304c:	46a1                	li	a3,8
    8000304e:	8626                	mv	a2,s1
    80003050:	85ca                	mv	a1,s2
    80003052:	6928                	ld	a0,80(a0)
    80003054:	ffffe097          	auipc	ra,0xffffe
    80003058:	676080e7          	jalr	1654(ra) # 800016ca <copyin>
    8000305c:	00a03533          	snez	a0,a0
    80003060:	40a00533          	neg	a0,a0
}
    80003064:	60e2                	ld	ra,24(sp)
    80003066:	6442                	ld	s0,16(sp)
    80003068:	64a2                	ld	s1,8(sp)
    8000306a:	6902                	ld	s2,0(sp)
    8000306c:	6105                	addi	sp,sp,32
    8000306e:	8082                	ret
    return -1;
    80003070:	557d                	li	a0,-1
    80003072:	bfcd                	j	80003064 <fetchaddr+0x3e>
    80003074:	557d                	li	a0,-1
    80003076:	b7fd                	j	80003064 <fetchaddr+0x3e>

0000000080003078 <fetchstr>:
{
    80003078:	7179                	addi	sp,sp,-48
    8000307a:	f406                	sd	ra,40(sp)
    8000307c:	f022                	sd	s0,32(sp)
    8000307e:	ec26                	sd	s1,24(sp)
    80003080:	e84a                	sd	s2,16(sp)
    80003082:	e44e                	sd	s3,8(sp)
    80003084:	1800                	addi	s0,sp,48
    80003086:	892a                	mv	s2,a0
    80003088:	84ae                	mv	s1,a1
    8000308a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000308c:	fffff097          	auipc	ra,0xfffff
    80003090:	928080e7          	jalr	-1752(ra) # 800019b4 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003094:	86ce                	mv	a3,s3
    80003096:	864a                	mv	a2,s2
    80003098:	85a6                	mv	a1,s1
    8000309a:	6928                	ld	a0,80(a0)
    8000309c:	ffffe097          	auipc	ra,0xffffe
    800030a0:	6bc080e7          	jalr	1724(ra) # 80001758 <copyinstr>
  if(err < 0)
    800030a4:	00054763          	bltz	a0,800030b2 <fetchstr+0x3a>
  return strlen(buf);
    800030a8:	8526                	mv	a0,s1
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	d98080e7          	jalr	-616(ra) # 80000e42 <strlen>
}
    800030b2:	70a2                	ld	ra,40(sp)
    800030b4:	7402                	ld	s0,32(sp)
    800030b6:	64e2                	ld	s1,24(sp)
    800030b8:	6942                	ld	s2,16(sp)
    800030ba:	69a2                	ld	s3,8(sp)
    800030bc:	6145                	addi	sp,sp,48
    800030be:	8082                	ret

00000000800030c0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800030c0:	1101                	addi	sp,sp,-32
    800030c2:	ec06                	sd	ra,24(sp)
    800030c4:	e822                	sd	s0,16(sp)
    800030c6:	e426                	sd	s1,8(sp)
    800030c8:	1000                	addi	s0,sp,32
    800030ca:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030cc:	00000097          	auipc	ra,0x0
    800030d0:	ef2080e7          	jalr	-270(ra) # 80002fbe <argraw>
    800030d4:	c088                	sw	a0,0(s1)
  return 0;
}
    800030d6:	4501                	li	a0,0
    800030d8:	60e2                	ld	ra,24(sp)
    800030da:	6442                	ld	s0,16(sp)
    800030dc:	64a2                	ld	s1,8(sp)
    800030de:	6105                	addi	sp,sp,32
    800030e0:	8082                	ret

00000000800030e2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800030e2:	1101                	addi	sp,sp,-32
    800030e4:	ec06                	sd	ra,24(sp)
    800030e6:	e822                	sd	s0,16(sp)
    800030e8:	e426                	sd	s1,8(sp)
    800030ea:	1000                	addi	s0,sp,32
    800030ec:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030ee:	00000097          	auipc	ra,0x0
    800030f2:	ed0080e7          	jalr	-304(ra) # 80002fbe <argraw>
    800030f6:	e088                	sd	a0,0(s1)
  return 0;
}
    800030f8:	4501                	li	a0,0
    800030fa:	60e2                	ld	ra,24(sp)
    800030fc:	6442                	ld	s0,16(sp)
    800030fe:	64a2                	ld	s1,8(sp)
    80003100:	6105                	addi	sp,sp,32
    80003102:	8082                	ret

0000000080003104 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003104:	1101                	addi	sp,sp,-32
    80003106:	ec06                	sd	ra,24(sp)
    80003108:	e822                	sd	s0,16(sp)
    8000310a:	e426                	sd	s1,8(sp)
    8000310c:	e04a                	sd	s2,0(sp)
    8000310e:	1000                	addi	s0,sp,32
    80003110:	84ae                	mv	s1,a1
    80003112:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003114:	00000097          	auipc	ra,0x0
    80003118:	eaa080e7          	jalr	-342(ra) # 80002fbe <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000311c:	864a                	mv	a2,s2
    8000311e:	85a6                	mv	a1,s1
    80003120:	00000097          	auipc	ra,0x0
    80003124:	f58080e7          	jalr	-168(ra) # 80003078 <fetchstr>
}
    80003128:	60e2                	ld	ra,24(sp)
    8000312a:	6442                	ld	s0,16(sp)
    8000312c:	64a2                	ld	s1,8(sp)
    8000312e:	6902                	ld	s2,0(sp)
    80003130:	6105                	addi	sp,sp,32
    80003132:	8082                	ret

0000000080003134 <syscall>:
//task 1.5
};

void
syscall(void)
{
    80003134:	1101                	addi	sp,sp,-32
    80003136:	ec06                	sd	ra,24(sp)
    80003138:	e822                	sd	s0,16(sp)
    8000313a:	e426                	sd	s1,8(sp)
    8000313c:	e04a                	sd	s2,0(sp)
    8000313e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003140:	fffff097          	auipc	ra,0xfffff
    80003144:	874080e7          	jalr	-1932(ra) # 800019b4 <myproc>
    80003148:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000314a:	05853903          	ld	s2,88(a0)
    8000314e:	0a893783          	ld	a5,168(s2) # 800a8 <_entry-0x7ff7ff58>
    80003152:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003156:	37fd                	addiw	a5,a5,-1
    80003158:	475d                	li	a4,23
    8000315a:	00f76f63          	bltu	a4,a5,80003178 <syscall+0x44>
    8000315e:	00369713          	slli	a4,a3,0x3
    80003162:	00005797          	auipc	a5,0x5
    80003166:	32e78793          	addi	a5,a5,814 # 80008490 <syscalls>
    8000316a:	97ba                	add	a5,a5,a4
    8000316c:	639c                	ld	a5,0(a5)
    8000316e:	c789                	beqz	a5,80003178 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80003170:	9782                	jalr	a5
    80003172:	06a93823          	sd	a0,112(s2)
    80003176:	a839                	j	80003194 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003178:	15848613          	addi	a2,s1,344
    8000317c:	588c                	lw	a1,48(s1)
    8000317e:	00005517          	auipc	a0,0x5
    80003182:	2da50513          	addi	a0,a0,730 # 80008458 <states.0+0x150>
    80003186:	ffffd097          	auipc	ra,0xffffd
    8000318a:	3ee080e7          	jalr	1006(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000318e:	6cbc                	ld	a5,88(s1)
    80003190:	577d                	li	a4,-1
    80003192:	fbb8                	sd	a4,112(a5)
  }
}
    80003194:	60e2                	ld	ra,24(sp)
    80003196:	6442                	ld	s0,16(sp)
    80003198:	64a2                	ld	s1,8(sp)
    8000319a:	6902                	ld	s2,0(sp)
    8000319c:	6105                	addi	sp,sp,32
    8000319e:	8082                	ret

00000000800031a0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800031a0:	1101                	addi	sp,sp,-32
    800031a2:	ec06                	sd	ra,24(sp)
    800031a4:	e822                	sd	s0,16(sp)
    800031a6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800031a8:	fec40593          	addi	a1,s0,-20
    800031ac:	4501                	li	a0,0
    800031ae:	00000097          	auipc	ra,0x0
    800031b2:	f12080e7          	jalr	-238(ra) # 800030c0 <argint>
    return -1;
    800031b6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800031b8:	00054963          	bltz	a0,800031ca <sys_exit+0x2a>
  exit(n);
    800031bc:	fec42503          	lw	a0,-20(s0)
    800031c0:	fffff097          	auipc	ra,0xfffff
    800031c4:	1c8080e7          	jalr	456(ra) # 80002388 <exit>
  return 0;  // not reached
    800031c8:	4781                	li	a5,0
}
    800031ca:	853e                	mv	a0,a5
    800031cc:	60e2                	ld	ra,24(sp)
    800031ce:	6442                	ld	s0,16(sp)
    800031d0:	6105                	addi	sp,sp,32
    800031d2:	8082                	ret

00000000800031d4 <sys_sigprocmask>:

//task 1.3
uint64
sys_sigprocmask(void)
{
    800031d4:	1101                	addi	sp,sp,-32
    800031d6:	ec06                	sd	ra,24(sp)
    800031d8:	e822                	sd	s0,16(sp)
    800031da:	1000                	addi	s0,sp,32
    int newmask;
    if(argint(0, &newmask) < 0)
    800031dc:	fec40593          	addi	a1,s0,-20
    800031e0:	4501                	li	a0,0
    800031e2:	00000097          	auipc	ra,0x0
    800031e6:	ede080e7          	jalr	-290(ra) # 800030c0 <argint>
    800031ea:	87aa                	mv	a5,a0
      return -1;
    800031ec:	557d                	li	a0,-1
    if(argint(0, &newmask) < 0)
    800031ee:	0007ca63          	bltz	a5,80003202 <sys_sigprocmask+0x2e>
    return sigprocmask(newmask);
    800031f2:	fec42503          	lw	a0,-20(s0)
    800031f6:	fffff097          	auipc	ra,0xfffff
    800031fa:	444080e7          	jalr	1092(ra) # 8000263a <sigprocmask>
    800031fe:	1502                	slli	a0,a0,0x20
    80003200:	9101                	srli	a0,a0,0x20
}
    80003202:	60e2                	ld	ra,24(sp)
    80003204:	6442                	ld	s0,16(sp)
    80003206:	6105                	addi	sp,sp,32
    80003208:	8082                	ret

000000008000320a <sys_sigaction>:
//task 1.3

//task 1.4
uint64
sys_sigaction(void)
{
    8000320a:	7179                	addi	sp,sp,-48
    8000320c:	f406                	sd	ra,40(sp)
    8000320e:	f022                	sd	s0,32(sp)
    80003210:	1800                	addi	s0,sp,48
  uint64 oldact;
  //struct sigaction *act;
  //struct sigaction *oldact;
  int signum;
  
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    80003212:	fdc40593          	addi	a1,s0,-36
    80003216:	4501                	li	a0,0
    80003218:	00000097          	auipc	ra,0x0
    8000321c:	ea8080e7          	jalr	-344(ra) # 800030c0 <argint>
    return -1;
    80003220:	57fd                	li	a5,-1
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    80003222:	04054163          	bltz	a0,80003264 <sys_sigaction+0x5a>
    80003226:	fe840593          	addi	a1,s0,-24
    8000322a:	4505                	li	a0,1
    8000322c:	00000097          	auipc	ra,0x0
    80003230:	eb6080e7          	jalr	-330(ra) # 800030e2 <argaddr>
    return -1;
    80003234:	57fd                	li	a5,-1
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    80003236:	02054763          	bltz	a0,80003264 <sys_sigaction+0x5a>
    8000323a:	fe040593          	addi	a1,s0,-32
    8000323e:	4509                	li	a0,2
    80003240:	00000097          	auipc	ra,0x0
    80003244:	ea2080e7          	jalr	-350(ra) # 800030e2 <argaddr>
    return -1;
    80003248:	57fd                	li	a5,-1
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    8000324a:	00054d63          	bltz	a0,80003264 <sys_sigaction+0x5a>
  return sigaction(signum,(struct sigaction*)act,(struct sigaction*)oldact);
    8000324e:	fe043603          	ld	a2,-32(s0)
    80003252:	fe843583          	ld	a1,-24(s0)
    80003256:	fdc42503          	lw	a0,-36(s0)
    8000325a:	fffff097          	auipc	ra,0xfffff
    8000325e:	488080e7          	jalr	1160(ra) # 800026e2 <sigaction>
    80003262:	87aa                	mv	a5,a0
}
    80003264:	853e                	mv	a0,a5
    80003266:	70a2                	ld	ra,40(sp)
    80003268:	7402                	ld	s0,32(sp)
    8000326a:	6145                	addi	sp,sp,48
    8000326c:	8082                	ret

000000008000326e <sys_sigret>:
//task 1.4

//task 1.5
uint64
sys_sigret(void)
{
    8000326e:	1141                	addi	sp,sp,-16
    80003270:	e422                	sd	s0,8(sp)
    80003272:	0800                	addi	s0,sp,16
  return 0; //todo change after 2.4 is done
}
    80003274:	4501                	li	a0,0
    80003276:	6422                	ld	s0,8(sp)
    80003278:	0141                	addi	sp,sp,16
    8000327a:	8082                	ret

000000008000327c <sys_getpid>:
//task1.5

uint64
sys_getpid(void)
{
    8000327c:	1141                	addi	sp,sp,-16
    8000327e:	e406                	sd	ra,8(sp)
    80003280:	e022                	sd	s0,0(sp)
    80003282:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003284:	ffffe097          	auipc	ra,0xffffe
    80003288:	730080e7          	jalr	1840(ra) # 800019b4 <myproc>
}
    8000328c:	5908                	lw	a0,48(a0)
    8000328e:	60a2                	ld	ra,8(sp)
    80003290:	6402                	ld	s0,0(sp)
    80003292:	0141                	addi	sp,sp,16
    80003294:	8082                	ret

0000000080003296 <sys_fork>:

uint64
sys_fork(void)
{
    80003296:	1141                	addi	sp,sp,-16
    80003298:	e406                	sd	ra,8(sp)
    8000329a:	e022                	sd	s0,0(sp)
    8000329c:	0800                	addi	s0,sp,16
  return fork();
    8000329e:	fffff097          	auipc	ra,0xfffff
    800032a2:	b62080e7          	jalr	-1182(ra) # 80001e00 <fork>
}
    800032a6:	60a2                	ld	ra,8(sp)
    800032a8:	6402                	ld	s0,0(sp)
    800032aa:	0141                	addi	sp,sp,16
    800032ac:	8082                	ret

00000000800032ae <sys_wait>:

uint64
sys_wait(void)
{
    800032ae:	1101                	addi	sp,sp,-32
    800032b0:	ec06                	sd	ra,24(sp)
    800032b2:	e822                	sd	s0,16(sp)
    800032b4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800032b6:	fe840593          	addi	a1,s0,-24
    800032ba:	4501                	li	a0,0
    800032bc:	00000097          	auipc	ra,0x0
    800032c0:	e26080e7          	jalr	-474(ra) # 800030e2 <argaddr>
    800032c4:	87aa                	mv	a5,a0
    return -1;
    800032c6:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800032c8:	0007c863          	bltz	a5,800032d8 <sys_wait+0x2a>
  return wait(p);
    800032cc:	fe843503          	ld	a0,-24(s0)
    800032d0:	fffff097          	auipc	ra,0xfffff
    800032d4:	ec0080e7          	jalr	-320(ra) # 80002190 <wait>
}
    800032d8:	60e2                	ld	ra,24(sp)
    800032da:	6442                	ld	s0,16(sp)
    800032dc:	6105                	addi	sp,sp,32
    800032de:	8082                	ret

00000000800032e0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800032e0:	7179                	addi	sp,sp,-48
    800032e2:	f406                	sd	ra,40(sp)
    800032e4:	f022                	sd	s0,32(sp)
    800032e6:	ec26                	sd	s1,24(sp)
    800032e8:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800032ea:	fdc40593          	addi	a1,s0,-36
    800032ee:	4501                	li	a0,0
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	dd0080e7          	jalr	-560(ra) # 800030c0 <argint>
    return -1;
    800032f8:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800032fa:	00054f63          	bltz	a0,80003318 <sys_sbrk+0x38>
  addr = myproc()->sz;
    800032fe:	ffffe097          	auipc	ra,0xffffe
    80003302:	6b6080e7          	jalr	1718(ra) # 800019b4 <myproc>
    80003306:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80003308:	fdc42503          	lw	a0,-36(s0)
    8000330c:	fffff097          	auipc	ra,0xfffff
    80003310:	a80080e7          	jalr	-1408(ra) # 80001d8c <growproc>
    80003314:	00054863          	bltz	a0,80003324 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003318:	8526                	mv	a0,s1
    8000331a:	70a2                	ld	ra,40(sp)
    8000331c:	7402                	ld	s0,32(sp)
    8000331e:	64e2                	ld	s1,24(sp)
    80003320:	6145                	addi	sp,sp,48
    80003322:	8082                	ret
    return -1;
    80003324:	54fd                	li	s1,-1
    80003326:	bfcd                	j	80003318 <sys_sbrk+0x38>

0000000080003328 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003328:	7139                	addi	sp,sp,-64
    8000332a:	fc06                	sd	ra,56(sp)
    8000332c:	f822                	sd	s0,48(sp)
    8000332e:	f426                	sd	s1,40(sp)
    80003330:	f04a                	sd	s2,32(sp)
    80003332:	ec4e                	sd	s3,24(sp)
    80003334:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003336:	fcc40593          	addi	a1,s0,-52
    8000333a:	4501                	li	a0,0
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	d84080e7          	jalr	-636(ra) # 800030c0 <argint>
    return -1;
    80003344:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003346:	06054563          	bltz	a0,800033b0 <sys_sleep+0x88>
  acquire(&tickslock);
    8000334a:	0001a517          	auipc	a0,0x1a
    8000334e:	58650513          	addi	a0,a0,1414 # 8001d8d0 <tickslock>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	870080e7          	jalr	-1936(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    8000335a:	00006917          	auipc	s2,0x6
    8000335e:	cd692903          	lw	s2,-810(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003362:	fcc42783          	lw	a5,-52(s0)
    80003366:	cf85                	beqz	a5,8000339e <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003368:	0001a997          	auipc	s3,0x1a
    8000336c:	56898993          	addi	s3,s3,1384 # 8001d8d0 <tickslock>
    80003370:	00006497          	auipc	s1,0x6
    80003374:	cc048493          	addi	s1,s1,-832 # 80009030 <ticks>
    if(myproc()->killed){
    80003378:	ffffe097          	auipc	ra,0xffffe
    8000337c:	63c080e7          	jalr	1596(ra) # 800019b4 <myproc>
    80003380:	551c                	lw	a5,40(a0)
    80003382:	ef9d                	bnez	a5,800033c0 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003384:	85ce                	mv	a1,s3
    80003386:	8526                	mv	a0,s1
    80003388:	fffff097          	auipc	ra,0xfffff
    8000338c:	da4080e7          	jalr	-604(ra) # 8000212c <sleep>
  while(ticks - ticks0 < n){
    80003390:	409c                	lw	a5,0(s1)
    80003392:	412787bb          	subw	a5,a5,s2
    80003396:	fcc42703          	lw	a4,-52(s0)
    8000339a:	fce7efe3          	bltu	a5,a4,80003378 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000339e:	0001a517          	auipc	a0,0x1a
    800033a2:	53250513          	addi	a0,a0,1330 # 8001d8d0 <tickslock>
    800033a6:	ffffe097          	auipc	ra,0xffffe
    800033aa:	8d0080e7          	jalr	-1840(ra) # 80000c76 <release>
  return 0;
    800033ae:	4781                	li	a5,0
}
    800033b0:	853e                	mv	a0,a5
    800033b2:	70e2                	ld	ra,56(sp)
    800033b4:	7442                	ld	s0,48(sp)
    800033b6:	74a2                	ld	s1,40(sp)
    800033b8:	7902                	ld	s2,32(sp)
    800033ba:	69e2                	ld	s3,24(sp)
    800033bc:	6121                	addi	sp,sp,64
    800033be:	8082                	ret
      release(&tickslock);
    800033c0:	0001a517          	auipc	a0,0x1a
    800033c4:	51050513          	addi	a0,a0,1296 # 8001d8d0 <tickslock>
    800033c8:	ffffe097          	auipc	ra,0xffffe
    800033cc:	8ae080e7          	jalr	-1874(ra) # 80000c76 <release>
      return -1;
    800033d0:	57fd                	li	a5,-1
    800033d2:	bff9                	j	800033b0 <sys_sleep+0x88>

00000000800033d4 <sys_kill>:

uint64
sys_kill(void)
{
    800033d4:	1101                	addi	sp,sp,-32
    800033d6:	ec06                	sd	ra,24(sp)
    800033d8:	e822                	sd	s0,16(sp)
    800033da:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    800033dc:	fec40593          	addi	a1,s0,-20
    800033e0:	4501                	li	a0,0
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	cde080e7          	jalr	-802(ra) # 800030c0 <argint>
    return -1;
    800033ea:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    800033ec:	02054563          	bltz	a0,80003416 <sys_kill+0x42>
  if(argint(1, &signum) < 0)
    800033f0:	fe840593          	addi	a1,s0,-24
    800033f4:	4505                	li	a0,1
    800033f6:	00000097          	auipc	ra,0x0
    800033fa:	cca080e7          	jalr	-822(ra) # 800030c0 <argint>
    return -1;
    800033fe:	57fd                	li	a5,-1
  if(argint(1, &signum) < 0)
    80003400:	00054b63          	bltz	a0,80003416 <sys_kill+0x42>
 
  return kill(pid,signum);
    80003404:	fe842583          	lw	a1,-24(s0)
    80003408:	fec42503          	lw	a0,-20(s0)
    8000340c:	fffff097          	auipc	ra,0xfffff
    80003410:	052080e7          	jalr	82(ra) # 8000245e <kill>
    80003414:	87aa                	mv	a5,a0
}
    80003416:	853e                	mv	a0,a5
    80003418:	60e2                	ld	ra,24(sp)
    8000341a:	6442                	ld	s0,16(sp)
    8000341c:	6105                	addi	sp,sp,32
    8000341e:	8082                	ret

0000000080003420 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003420:	1101                	addi	sp,sp,-32
    80003422:	ec06                	sd	ra,24(sp)
    80003424:	e822                	sd	s0,16(sp)
    80003426:	e426                	sd	s1,8(sp)
    80003428:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000342a:	0001a517          	auipc	a0,0x1a
    8000342e:	4a650513          	addi	a0,a0,1190 # 8001d8d0 <tickslock>
    80003432:	ffffd097          	auipc	ra,0xffffd
    80003436:	790080e7          	jalr	1936(ra) # 80000bc2 <acquire>
  xticks = ticks;
    8000343a:	00006497          	auipc	s1,0x6
    8000343e:	bf64a483          	lw	s1,-1034(s1) # 80009030 <ticks>
  release(&tickslock);
    80003442:	0001a517          	auipc	a0,0x1a
    80003446:	48e50513          	addi	a0,a0,1166 # 8001d8d0 <tickslock>
    8000344a:	ffffe097          	auipc	ra,0xffffe
    8000344e:	82c080e7          	jalr	-2004(ra) # 80000c76 <release>
  return xticks;
}
    80003452:	02049513          	slli	a0,s1,0x20
    80003456:	9101                	srli	a0,a0,0x20
    80003458:	60e2                	ld	ra,24(sp)
    8000345a:	6442                	ld	s0,16(sp)
    8000345c:	64a2                	ld	s1,8(sp)
    8000345e:	6105                	addi	sp,sp,32
    80003460:	8082                	ret

0000000080003462 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003462:	7179                	addi	sp,sp,-48
    80003464:	f406                	sd	ra,40(sp)
    80003466:	f022                	sd	s0,32(sp)
    80003468:	ec26                	sd	s1,24(sp)
    8000346a:	e84a                	sd	s2,16(sp)
    8000346c:	e44e                	sd	s3,8(sp)
    8000346e:	e052                	sd	s4,0(sp)
    80003470:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003472:	00005597          	auipc	a1,0x5
    80003476:	0e658593          	addi	a1,a1,230 # 80008558 <syscalls+0xc8>
    8000347a:	0001a517          	auipc	a0,0x1a
    8000347e:	46e50513          	addi	a0,a0,1134 # 8001d8e8 <bcache>
    80003482:	ffffd097          	auipc	ra,0xffffd
    80003486:	6b0080e7          	jalr	1712(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000348a:	00022797          	auipc	a5,0x22
    8000348e:	45e78793          	addi	a5,a5,1118 # 800258e8 <bcache+0x8000>
    80003492:	00022717          	auipc	a4,0x22
    80003496:	6be70713          	addi	a4,a4,1726 # 80025b50 <bcache+0x8268>
    8000349a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000349e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034a2:	0001a497          	auipc	s1,0x1a
    800034a6:	45e48493          	addi	s1,s1,1118 # 8001d900 <bcache+0x18>
    b->next = bcache.head.next;
    800034aa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800034ac:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800034ae:	00005a17          	auipc	s4,0x5
    800034b2:	0b2a0a13          	addi	s4,s4,178 # 80008560 <syscalls+0xd0>
    b->next = bcache.head.next;
    800034b6:	2b893783          	ld	a5,696(s2)
    800034ba:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800034bc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800034c0:	85d2                	mv	a1,s4
    800034c2:	01048513          	addi	a0,s1,16
    800034c6:	00001097          	auipc	ra,0x1
    800034ca:	4c2080e7          	jalr	1218(ra) # 80004988 <initsleeplock>
    bcache.head.next->prev = b;
    800034ce:	2b893783          	ld	a5,696(s2)
    800034d2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034d4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034d8:	45848493          	addi	s1,s1,1112
    800034dc:	fd349de3          	bne	s1,s3,800034b6 <binit+0x54>
  }
}
    800034e0:	70a2                	ld	ra,40(sp)
    800034e2:	7402                	ld	s0,32(sp)
    800034e4:	64e2                	ld	s1,24(sp)
    800034e6:	6942                	ld	s2,16(sp)
    800034e8:	69a2                	ld	s3,8(sp)
    800034ea:	6a02                	ld	s4,0(sp)
    800034ec:	6145                	addi	sp,sp,48
    800034ee:	8082                	ret

00000000800034f0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034f0:	7179                	addi	sp,sp,-48
    800034f2:	f406                	sd	ra,40(sp)
    800034f4:	f022                	sd	s0,32(sp)
    800034f6:	ec26                	sd	s1,24(sp)
    800034f8:	e84a                	sd	s2,16(sp)
    800034fa:	e44e                	sd	s3,8(sp)
    800034fc:	1800                	addi	s0,sp,48
    800034fe:	892a                	mv	s2,a0
    80003500:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003502:	0001a517          	auipc	a0,0x1a
    80003506:	3e650513          	addi	a0,a0,998 # 8001d8e8 <bcache>
    8000350a:	ffffd097          	auipc	ra,0xffffd
    8000350e:	6b8080e7          	jalr	1720(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003512:	00022497          	auipc	s1,0x22
    80003516:	68e4b483          	ld	s1,1678(s1) # 80025ba0 <bcache+0x82b8>
    8000351a:	00022797          	auipc	a5,0x22
    8000351e:	63678793          	addi	a5,a5,1590 # 80025b50 <bcache+0x8268>
    80003522:	02f48f63          	beq	s1,a5,80003560 <bread+0x70>
    80003526:	873e                	mv	a4,a5
    80003528:	a021                	j	80003530 <bread+0x40>
    8000352a:	68a4                	ld	s1,80(s1)
    8000352c:	02e48a63          	beq	s1,a4,80003560 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003530:	449c                	lw	a5,8(s1)
    80003532:	ff279ce3          	bne	a5,s2,8000352a <bread+0x3a>
    80003536:	44dc                	lw	a5,12(s1)
    80003538:	ff3799e3          	bne	a5,s3,8000352a <bread+0x3a>
      b->refcnt++;
    8000353c:	40bc                	lw	a5,64(s1)
    8000353e:	2785                	addiw	a5,a5,1
    80003540:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003542:	0001a517          	auipc	a0,0x1a
    80003546:	3a650513          	addi	a0,a0,934 # 8001d8e8 <bcache>
    8000354a:	ffffd097          	auipc	ra,0xffffd
    8000354e:	72c080e7          	jalr	1836(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003552:	01048513          	addi	a0,s1,16
    80003556:	00001097          	auipc	ra,0x1
    8000355a:	46c080e7          	jalr	1132(ra) # 800049c2 <acquiresleep>
      return b;
    8000355e:	a8b9                	j	800035bc <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003560:	00022497          	auipc	s1,0x22
    80003564:	6384b483          	ld	s1,1592(s1) # 80025b98 <bcache+0x82b0>
    80003568:	00022797          	auipc	a5,0x22
    8000356c:	5e878793          	addi	a5,a5,1512 # 80025b50 <bcache+0x8268>
    80003570:	00f48863          	beq	s1,a5,80003580 <bread+0x90>
    80003574:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003576:	40bc                	lw	a5,64(s1)
    80003578:	cf81                	beqz	a5,80003590 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000357a:	64a4                	ld	s1,72(s1)
    8000357c:	fee49de3          	bne	s1,a4,80003576 <bread+0x86>
  panic("bget: no buffers");
    80003580:	00005517          	auipc	a0,0x5
    80003584:	fe850513          	addi	a0,a0,-24 # 80008568 <syscalls+0xd8>
    80003588:	ffffd097          	auipc	ra,0xffffd
    8000358c:	fa2080e7          	jalr	-94(ra) # 8000052a <panic>
      b->dev = dev;
    80003590:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003594:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003598:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000359c:	4785                	li	a5,1
    8000359e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035a0:	0001a517          	auipc	a0,0x1a
    800035a4:	34850513          	addi	a0,a0,840 # 8001d8e8 <bcache>
    800035a8:	ffffd097          	auipc	ra,0xffffd
    800035ac:	6ce080e7          	jalr	1742(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800035b0:	01048513          	addi	a0,s1,16
    800035b4:	00001097          	auipc	ra,0x1
    800035b8:	40e080e7          	jalr	1038(ra) # 800049c2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800035bc:	409c                	lw	a5,0(s1)
    800035be:	cb89                	beqz	a5,800035d0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035c0:	8526                	mv	a0,s1
    800035c2:	70a2                	ld	ra,40(sp)
    800035c4:	7402                	ld	s0,32(sp)
    800035c6:	64e2                	ld	s1,24(sp)
    800035c8:	6942                	ld	s2,16(sp)
    800035ca:	69a2                	ld	s3,8(sp)
    800035cc:	6145                	addi	sp,sp,48
    800035ce:	8082                	ret
    virtio_disk_rw(b, 0);
    800035d0:	4581                	li	a1,0
    800035d2:	8526                	mv	a0,s1
    800035d4:	00003097          	auipc	ra,0x3
    800035d8:	f42080e7          	jalr	-190(ra) # 80006516 <virtio_disk_rw>
    b->valid = 1;
    800035dc:	4785                	li	a5,1
    800035de:	c09c                	sw	a5,0(s1)
  return b;
    800035e0:	b7c5                	j	800035c0 <bread+0xd0>

00000000800035e2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035e2:	1101                	addi	sp,sp,-32
    800035e4:	ec06                	sd	ra,24(sp)
    800035e6:	e822                	sd	s0,16(sp)
    800035e8:	e426                	sd	s1,8(sp)
    800035ea:	1000                	addi	s0,sp,32
    800035ec:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035ee:	0541                	addi	a0,a0,16
    800035f0:	00001097          	auipc	ra,0x1
    800035f4:	46c080e7          	jalr	1132(ra) # 80004a5c <holdingsleep>
    800035f8:	cd01                	beqz	a0,80003610 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035fa:	4585                	li	a1,1
    800035fc:	8526                	mv	a0,s1
    800035fe:	00003097          	auipc	ra,0x3
    80003602:	f18080e7          	jalr	-232(ra) # 80006516 <virtio_disk_rw>
}
    80003606:	60e2                	ld	ra,24(sp)
    80003608:	6442                	ld	s0,16(sp)
    8000360a:	64a2                	ld	s1,8(sp)
    8000360c:	6105                	addi	sp,sp,32
    8000360e:	8082                	ret
    panic("bwrite");
    80003610:	00005517          	auipc	a0,0x5
    80003614:	f7050513          	addi	a0,a0,-144 # 80008580 <syscalls+0xf0>
    80003618:	ffffd097          	auipc	ra,0xffffd
    8000361c:	f12080e7          	jalr	-238(ra) # 8000052a <panic>

0000000080003620 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003620:	1101                	addi	sp,sp,-32
    80003622:	ec06                	sd	ra,24(sp)
    80003624:	e822                	sd	s0,16(sp)
    80003626:	e426                	sd	s1,8(sp)
    80003628:	e04a                	sd	s2,0(sp)
    8000362a:	1000                	addi	s0,sp,32
    8000362c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000362e:	01050913          	addi	s2,a0,16
    80003632:	854a                	mv	a0,s2
    80003634:	00001097          	auipc	ra,0x1
    80003638:	428080e7          	jalr	1064(ra) # 80004a5c <holdingsleep>
    8000363c:	c92d                	beqz	a0,800036ae <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000363e:	854a                	mv	a0,s2
    80003640:	00001097          	auipc	ra,0x1
    80003644:	3d8080e7          	jalr	984(ra) # 80004a18 <releasesleep>

  acquire(&bcache.lock);
    80003648:	0001a517          	auipc	a0,0x1a
    8000364c:	2a050513          	addi	a0,a0,672 # 8001d8e8 <bcache>
    80003650:	ffffd097          	auipc	ra,0xffffd
    80003654:	572080e7          	jalr	1394(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003658:	40bc                	lw	a5,64(s1)
    8000365a:	37fd                	addiw	a5,a5,-1
    8000365c:	0007871b          	sext.w	a4,a5
    80003660:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003662:	eb05                	bnez	a4,80003692 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003664:	68bc                	ld	a5,80(s1)
    80003666:	64b8                	ld	a4,72(s1)
    80003668:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000366a:	64bc                	ld	a5,72(s1)
    8000366c:	68b8                	ld	a4,80(s1)
    8000366e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003670:	00022797          	auipc	a5,0x22
    80003674:	27878793          	addi	a5,a5,632 # 800258e8 <bcache+0x8000>
    80003678:	2b87b703          	ld	a4,696(a5)
    8000367c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000367e:	00022717          	auipc	a4,0x22
    80003682:	4d270713          	addi	a4,a4,1234 # 80025b50 <bcache+0x8268>
    80003686:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003688:	2b87b703          	ld	a4,696(a5)
    8000368c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000368e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003692:	0001a517          	auipc	a0,0x1a
    80003696:	25650513          	addi	a0,a0,598 # 8001d8e8 <bcache>
    8000369a:	ffffd097          	auipc	ra,0xffffd
    8000369e:	5dc080e7          	jalr	1500(ra) # 80000c76 <release>
}
    800036a2:	60e2                	ld	ra,24(sp)
    800036a4:	6442                	ld	s0,16(sp)
    800036a6:	64a2                	ld	s1,8(sp)
    800036a8:	6902                	ld	s2,0(sp)
    800036aa:	6105                	addi	sp,sp,32
    800036ac:	8082                	ret
    panic("brelse");
    800036ae:	00005517          	auipc	a0,0x5
    800036b2:	eda50513          	addi	a0,a0,-294 # 80008588 <syscalls+0xf8>
    800036b6:	ffffd097          	auipc	ra,0xffffd
    800036ba:	e74080e7          	jalr	-396(ra) # 8000052a <panic>

00000000800036be <bpin>:

void
bpin(struct buf *b) {
    800036be:	1101                	addi	sp,sp,-32
    800036c0:	ec06                	sd	ra,24(sp)
    800036c2:	e822                	sd	s0,16(sp)
    800036c4:	e426                	sd	s1,8(sp)
    800036c6:	1000                	addi	s0,sp,32
    800036c8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036ca:	0001a517          	auipc	a0,0x1a
    800036ce:	21e50513          	addi	a0,a0,542 # 8001d8e8 <bcache>
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	4f0080e7          	jalr	1264(ra) # 80000bc2 <acquire>
  b->refcnt++;
    800036da:	40bc                	lw	a5,64(s1)
    800036dc:	2785                	addiw	a5,a5,1
    800036de:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036e0:	0001a517          	auipc	a0,0x1a
    800036e4:	20850513          	addi	a0,a0,520 # 8001d8e8 <bcache>
    800036e8:	ffffd097          	auipc	ra,0xffffd
    800036ec:	58e080e7          	jalr	1422(ra) # 80000c76 <release>
}
    800036f0:	60e2                	ld	ra,24(sp)
    800036f2:	6442                	ld	s0,16(sp)
    800036f4:	64a2                	ld	s1,8(sp)
    800036f6:	6105                	addi	sp,sp,32
    800036f8:	8082                	ret

00000000800036fa <bunpin>:

void
bunpin(struct buf *b) {
    800036fa:	1101                	addi	sp,sp,-32
    800036fc:	ec06                	sd	ra,24(sp)
    800036fe:	e822                	sd	s0,16(sp)
    80003700:	e426                	sd	s1,8(sp)
    80003702:	1000                	addi	s0,sp,32
    80003704:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003706:	0001a517          	auipc	a0,0x1a
    8000370a:	1e250513          	addi	a0,a0,482 # 8001d8e8 <bcache>
    8000370e:	ffffd097          	auipc	ra,0xffffd
    80003712:	4b4080e7          	jalr	1204(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003716:	40bc                	lw	a5,64(s1)
    80003718:	37fd                	addiw	a5,a5,-1
    8000371a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000371c:	0001a517          	auipc	a0,0x1a
    80003720:	1cc50513          	addi	a0,a0,460 # 8001d8e8 <bcache>
    80003724:	ffffd097          	auipc	ra,0xffffd
    80003728:	552080e7          	jalr	1362(ra) # 80000c76 <release>
}
    8000372c:	60e2                	ld	ra,24(sp)
    8000372e:	6442                	ld	s0,16(sp)
    80003730:	64a2                	ld	s1,8(sp)
    80003732:	6105                	addi	sp,sp,32
    80003734:	8082                	ret

0000000080003736 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003736:	1101                	addi	sp,sp,-32
    80003738:	ec06                	sd	ra,24(sp)
    8000373a:	e822                	sd	s0,16(sp)
    8000373c:	e426                	sd	s1,8(sp)
    8000373e:	e04a                	sd	s2,0(sp)
    80003740:	1000                	addi	s0,sp,32
    80003742:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003744:	00d5d59b          	srliw	a1,a1,0xd
    80003748:	00023797          	auipc	a5,0x23
    8000374c:	87c7a783          	lw	a5,-1924(a5) # 80025fc4 <sb+0x1c>
    80003750:	9dbd                	addw	a1,a1,a5
    80003752:	00000097          	auipc	ra,0x0
    80003756:	d9e080e7          	jalr	-610(ra) # 800034f0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000375a:	0074f713          	andi	a4,s1,7
    8000375e:	4785                	li	a5,1
    80003760:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003764:	14ce                	slli	s1,s1,0x33
    80003766:	90d9                	srli	s1,s1,0x36
    80003768:	00950733          	add	a4,a0,s1
    8000376c:	05874703          	lbu	a4,88(a4)
    80003770:	00e7f6b3          	and	a3,a5,a4
    80003774:	c69d                	beqz	a3,800037a2 <bfree+0x6c>
    80003776:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003778:	94aa                	add	s1,s1,a0
    8000377a:	fff7c793          	not	a5,a5
    8000377e:	8ff9                	and	a5,a5,a4
    80003780:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003784:	00001097          	auipc	ra,0x1
    80003788:	11e080e7          	jalr	286(ra) # 800048a2 <log_write>
  brelse(bp);
    8000378c:	854a                	mv	a0,s2
    8000378e:	00000097          	auipc	ra,0x0
    80003792:	e92080e7          	jalr	-366(ra) # 80003620 <brelse>
}
    80003796:	60e2                	ld	ra,24(sp)
    80003798:	6442                	ld	s0,16(sp)
    8000379a:	64a2                	ld	s1,8(sp)
    8000379c:	6902                	ld	s2,0(sp)
    8000379e:	6105                	addi	sp,sp,32
    800037a0:	8082                	ret
    panic("freeing free block");
    800037a2:	00005517          	auipc	a0,0x5
    800037a6:	dee50513          	addi	a0,a0,-530 # 80008590 <syscalls+0x100>
    800037aa:	ffffd097          	auipc	ra,0xffffd
    800037ae:	d80080e7          	jalr	-640(ra) # 8000052a <panic>

00000000800037b2 <balloc>:
{
    800037b2:	711d                	addi	sp,sp,-96
    800037b4:	ec86                	sd	ra,88(sp)
    800037b6:	e8a2                	sd	s0,80(sp)
    800037b8:	e4a6                	sd	s1,72(sp)
    800037ba:	e0ca                	sd	s2,64(sp)
    800037bc:	fc4e                	sd	s3,56(sp)
    800037be:	f852                	sd	s4,48(sp)
    800037c0:	f456                	sd	s5,40(sp)
    800037c2:	f05a                	sd	s6,32(sp)
    800037c4:	ec5e                	sd	s7,24(sp)
    800037c6:	e862                	sd	s8,16(sp)
    800037c8:	e466                	sd	s9,8(sp)
    800037ca:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800037cc:	00022797          	auipc	a5,0x22
    800037d0:	7e07a783          	lw	a5,2016(a5) # 80025fac <sb+0x4>
    800037d4:	cbd1                	beqz	a5,80003868 <balloc+0xb6>
    800037d6:	8baa                	mv	s7,a0
    800037d8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037da:	00022b17          	auipc	s6,0x22
    800037de:	7ceb0b13          	addi	s6,s6,1998 # 80025fa8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037e2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800037e4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037e6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037e8:	6c89                	lui	s9,0x2
    800037ea:	a831                	j	80003806 <balloc+0x54>
    brelse(bp);
    800037ec:	854a                	mv	a0,s2
    800037ee:	00000097          	auipc	ra,0x0
    800037f2:	e32080e7          	jalr	-462(ra) # 80003620 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037f6:	015c87bb          	addw	a5,s9,s5
    800037fa:	00078a9b          	sext.w	s5,a5
    800037fe:	004b2703          	lw	a4,4(s6)
    80003802:	06eaf363          	bgeu	s5,a4,80003868 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003806:	41fad79b          	sraiw	a5,s5,0x1f
    8000380a:	0137d79b          	srliw	a5,a5,0x13
    8000380e:	015787bb          	addw	a5,a5,s5
    80003812:	40d7d79b          	sraiw	a5,a5,0xd
    80003816:	01cb2583          	lw	a1,28(s6)
    8000381a:	9dbd                	addw	a1,a1,a5
    8000381c:	855e                	mv	a0,s7
    8000381e:	00000097          	auipc	ra,0x0
    80003822:	cd2080e7          	jalr	-814(ra) # 800034f0 <bread>
    80003826:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003828:	004b2503          	lw	a0,4(s6)
    8000382c:	000a849b          	sext.w	s1,s5
    80003830:	8662                	mv	a2,s8
    80003832:	faa4fde3          	bgeu	s1,a0,800037ec <balloc+0x3a>
      m = 1 << (bi % 8);
    80003836:	41f6579b          	sraiw	a5,a2,0x1f
    8000383a:	01d7d69b          	srliw	a3,a5,0x1d
    8000383e:	00c6873b          	addw	a4,a3,a2
    80003842:	00777793          	andi	a5,a4,7
    80003846:	9f95                	subw	a5,a5,a3
    80003848:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000384c:	4037571b          	sraiw	a4,a4,0x3
    80003850:	00e906b3          	add	a3,s2,a4
    80003854:	0586c683          	lbu	a3,88(a3)
    80003858:	00d7f5b3          	and	a1,a5,a3
    8000385c:	cd91                	beqz	a1,80003878 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000385e:	2605                	addiw	a2,a2,1
    80003860:	2485                	addiw	s1,s1,1
    80003862:	fd4618e3          	bne	a2,s4,80003832 <balloc+0x80>
    80003866:	b759                	j	800037ec <balloc+0x3a>
  panic("balloc: out of blocks");
    80003868:	00005517          	auipc	a0,0x5
    8000386c:	d4050513          	addi	a0,a0,-704 # 800085a8 <syscalls+0x118>
    80003870:	ffffd097          	auipc	ra,0xffffd
    80003874:	cba080e7          	jalr	-838(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003878:	974a                	add	a4,a4,s2
    8000387a:	8fd5                	or	a5,a5,a3
    8000387c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003880:	854a                	mv	a0,s2
    80003882:	00001097          	auipc	ra,0x1
    80003886:	020080e7          	jalr	32(ra) # 800048a2 <log_write>
        brelse(bp);
    8000388a:	854a                	mv	a0,s2
    8000388c:	00000097          	auipc	ra,0x0
    80003890:	d94080e7          	jalr	-620(ra) # 80003620 <brelse>
  bp = bread(dev, bno);
    80003894:	85a6                	mv	a1,s1
    80003896:	855e                	mv	a0,s7
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	c58080e7          	jalr	-936(ra) # 800034f0 <bread>
    800038a0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038a2:	40000613          	li	a2,1024
    800038a6:	4581                	li	a1,0
    800038a8:	05850513          	addi	a0,a0,88
    800038ac:	ffffd097          	auipc	ra,0xffffd
    800038b0:	412080e7          	jalr	1042(ra) # 80000cbe <memset>
  log_write(bp);
    800038b4:	854a                	mv	a0,s2
    800038b6:	00001097          	auipc	ra,0x1
    800038ba:	fec080e7          	jalr	-20(ra) # 800048a2 <log_write>
  brelse(bp);
    800038be:	854a                	mv	a0,s2
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	d60080e7          	jalr	-672(ra) # 80003620 <brelse>
}
    800038c8:	8526                	mv	a0,s1
    800038ca:	60e6                	ld	ra,88(sp)
    800038cc:	6446                	ld	s0,80(sp)
    800038ce:	64a6                	ld	s1,72(sp)
    800038d0:	6906                	ld	s2,64(sp)
    800038d2:	79e2                	ld	s3,56(sp)
    800038d4:	7a42                	ld	s4,48(sp)
    800038d6:	7aa2                	ld	s5,40(sp)
    800038d8:	7b02                	ld	s6,32(sp)
    800038da:	6be2                	ld	s7,24(sp)
    800038dc:	6c42                	ld	s8,16(sp)
    800038de:	6ca2                	ld	s9,8(sp)
    800038e0:	6125                	addi	sp,sp,96
    800038e2:	8082                	ret

00000000800038e4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800038e4:	7179                	addi	sp,sp,-48
    800038e6:	f406                	sd	ra,40(sp)
    800038e8:	f022                	sd	s0,32(sp)
    800038ea:	ec26                	sd	s1,24(sp)
    800038ec:	e84a                	sd	s2,16(sp)
    800038ee:	e44e                	sd	s3,8(sp)
    800038f0:	e052                	sd	s4,0(sp)
    800038f2:	1800                	addi	s0,sp,48
    800038f4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038f6:	47ad                	li	a5,11
    800038f8:	04b7fe63          	bgeu	a5,a1,80003954 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800038fc:	ff45849b          	addiw	s1,a1,-12
    80003900:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003904:	0ff00793          	li	a5,255
    80003908:	0ae7e463          	bltu	a5,a4,800039b0 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000390c:	08052583          	lw	a1,128(a0)
    80003910:	c5b5                	beqz	a1,8000397c <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003912:	00092503          	lw	a0,0(s2)
    80003916:	00000097          	auipc	ra,0x0
    8000391a:	bda080e7          	jalr	-1062(ra) # 800034f0 <bread>
    8000391e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003920:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003924:	02049713          	slli	a4,s1,0x20
    80003928:	01e75593          	srli	a1,a4,0x1e
    8000392c:	00b784b3          	add	s1,a5,a1
    80003930:	0004a983          	lw	s3,0(s1)
    80003934:	04098e63          	beqz	s3,80003990 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003938:	8552                	mv	a0,s4
    8000393a:	00000097          	auipc	ra,0x0
    8000393e:	ce6080e7          	jalr	-794(ra) # 80003620 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003942:	854e                	mv	a0,s3
    80003944:	70a2                	ld	ra,40(sp)
    80003946:	7402                	ld	s0,32(sp)
    80003948:	64e2                	ld	s1,24(sp)
    8000394a:	6942                	ld	s2,16(sp)
    8000394c:	69a2                	ld	s3,8(sp)
    8000394e:	6a02                	ld	s4,0(sp)
    80003950:	6145                	addi	sp,sp,48
    80003952:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003954:	02059793          	slli	a5,a1,0x20
    80003958:	01e7d593          	srli	a1,a5,0x1e
    8000395c:	00b504b3          	add	s1,a0,a1
    80003960:	0504a983          	lw	s3,80(s1)
    80003964:	fc099fe3          	bnez	s3,80003942 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003968:	4108                	lw	a0,0(a0)
    8000396a:	00000097          	auipc	ra,0x0
    8000396e:	e48080e7          	jalr	-440(ra) # 800037b2 <balloc>
    80003972:	0005099b          	sext.w	s3,a0
    80003976:	0534a823          	sw	s3,80(s1)
    8000397a:	b7e1                	j	80003942 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000397c:	4108                	lw	a0,0(a0)
    8000397e:	00000097          	auipc	ra,0x0
    80003982:	e34080e7          	jalr	-460(ra) # 800037b2 <balloc>
    80003986:	0005059b          	sext.w	a1,a0
    8000398a:	08b92023          	sw	a1,128(s2)
    8000398e:	b751                	j	80003912 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003990:	00092503          	lw	a0,0(s2)
    80003994:	00000097          	auipc	ra,0x0
    80003998:	e1e080e7          	jalr	-482(ra) # 800037b2 <balloc>
    8000399c:	0005099b          	sext.w	s3,a0
    800039a0:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800039a4:	8552                	mv	a0,s4
    800039a6:	00001097          	auipc	ra,0x1
    800039aa:	efc080e7          	jalr	-260(ra) # 800048a2 <log_write>
    800039ae:	b769                	j	80003938 <bmap+0x54>
  panic("bmap: out of range");
    800039b0:	00005517          	auipc	a0,0x5
    800039b4:	c1050513          	addi	a0,a0,-1008 # 800085c0 <syscalls+0x130>
    800039b8:	ffffd097          	auipc	ra,0xffffd
    800039bc:	b72080e7          	jalr	-1166(ra) # 8000052a <panic>

00000000800039c0 <iget>:
{
    800039c0:	7179                	addi	sp,sp,-48
    800039c2:	f406                	sd	ra,40(sp)
    800039c4:	f022                	sd	s0,32(sp)
    800039c6:	ec26                	sd	s1,24(sp)
    800039c8:	e84a                	sd	s2,16(sp)
    800039ca:	e44e                	sd	s3,8(sp)
    800039cc:	e052                	sd	s4,0(sp)
    800039ce:	1800                	addi	s0,sp,48
    800039d0:	89aa                	mv	s3,a0
    800039d2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800039d4:	00022517          	auipc	a0,0x22
    800039d8:	5f450513          	addi	a0,a0,1524 # 80025fc8 <itable>
    800039dc:	ffffd097          	auipc	ra,0xffffd
    800039e0:	1e6080e7          	jalr	486(ra) # 80000bc2 <acquire>
  empty = 0;
    800039e4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039e6:	00022497          	auipc	s1,0x22
    800039ea:	5fa48493          	addi	s1,s1,1530 # 80025fe0 <itable+0x18>
    800039ee:	00024697          	auipc	a3,0x24
    800039f2:	08268693          	addi	a3,a3,130 # 80027a70 <log>
    800039f6:	a039                	j	80003a04 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039f8:	02090b63          	beqz	s2,80003a2e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039fc:	08848493          	addi	s1,s1,136
    80003a00:	02d48a63          	beq	s1,a3,80003a34 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a04:	449c                	lw	a5,8(s1)
    80003a06:	fef059e3          	blez	a5,800039f8 <iget+0x38>
    80003a0a:	4098                	lw	a4,0(s1)
    80003a0c:	ff3716e3          	bne	a4,s3,800039f8 <iget+0x38>
    80003a10:	40d8                	lw	a4,4(s1)
    80003a12:	ff4713e3          	bne	a4,s4,800039f8 <iget+0x38>
      ip->ref++;
    80003a16:	2785                	addiw	a5,a5,1
    80003a18:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a1a:	00022517          	auipc	a0,0x22
    80003a1e:	5ae50513          	addi	a0,a0,1454 # 80025fc8 <itable>
    80003a22:	ffffd097          	auipc	ra,0xffffd
    80003a26:	254080e7          	jalr	596(ra) # 80000c76 <release>
      return ip;
    80003a2a:	8926                	mv	s2,s1
    80003a2c:	a03d                	j	80003a5a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a2e:	f7f9                	bnez	a5,800039fc <iget+0x3c>
    80003a30:	8926                	mv	s2,s1
    80003a32:	b7e9                	j	800039fc <iget+0x3c>
  if(empty == 0)
    80003a34:	02090c63          	beqz	s2,80003a6c <iget+0xac>
  ip->dev = dev;
    80003a38:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a3c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a40:	4785                	li	a5,1
    80003a42:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a46:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a4a:	00022517          	auipc	a0,0x22
    80003a4e:	57e50513          	addi	a0,a0,1406 # 80025fc8 <itable>
    80003a52:	ffffd097          	auipc	ra,0xffffd
    80003a56:	224080e7          	jalr	548(ra) # 80000c76 <release>
}
    80003a5a:	854a                	mv	a0,s2
    80003a5c:	70a2                	ld	ra,40(sp)
    80003a5e:	7402                	ld	s0,32(sp)
    80003a60:	64e2                	ld	s1,24(sp)
    80003a62:	6942                	ld	s2,16(sp)
    80003a64:	69a2                	ld	s3,8(sp)
    80003a66:	6a02                	ld	s4,0(sp)
    80003a68:	6145                	addi	sp,sp,48
    80003a6a:	8082                	ret
    panic("iget: no inodes");
    80003a6c:	00005517          	auipc	a0,0x5
    80003a70:	b6c50513          	addi	a0,a0,-1172 # 800085d8 <syscalls+0x148>
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	ab6080e7          	jalr	-1354(ra) # 8000052a <panic>

0000000080003a7c <fsinit>:
fsinit(int dev) {
    80003a7c:	7179                	addi	sp,sp,-48
    80003a7e:	f406                	sd	ra,40(sp)
    80003a80:	f022                	sd	s0,32(sp)
    80003a82:	ec26                	sd	s1,24(sp)
    80003a84:	e84a                	sd	s2,16(sp)
    80003a86:	e44e                	sd	s3,8(sp)
    80003a88:	1800                	addi	s0,sp,48
    80003a8a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a8c:	4585                	li	a1,1
    80003a8e:	00000097          	auipc	ra,0x0
    80003a92:	a62080e7          	jalr	-1438(ra) # 800034f0 <bread>
    80003a96:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a98:	00022997          	auipc	s3,0x22
    80003a9c:	51098993          	addi	s3,s3,1296 # 80025fa8 <sb>
    80003aa0:	02000613          	li	a2,32
    80003aa4:	05850593          	addi	a1,a0,88
    80003aa8:	854e                	mv	a0,s3
    80003aaa:	ffffd097          	auipc	ra,0xffffd
    80003aae:	270080e7          	jalr	624(ra) # 80000d1a <memmove>
  brelse(bp);
    80003ab2:	8526                	mv	a0,s1
    80003ab4:	00000097          	auipc	ra,0x0
    80003ab8:	b6c080e7          	jalr	-1172(ra) # 80003620 <brelse>
  if(sb.magic != FSMAGIC)
    80003abc:	0009a703          	lw	a4,0(s3)
    80003ac0:	102037b7          	lui	a5,0x10203
    80003ac4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ac8:	02f71263          	bne	a4,a5,80003aec <fsinit+0x70>
  initlog(dev, &sb);
    80003acc:	00022597          	auipc	a1,0x22
    80003ad0:	4dc58593          	addi	a1,a1,1244 # 80025fa8 <sb>
    80003ad4:	854a                	mv	a0,s2
    80003ad6:	00001097          	auipc	ra,0x1
    80003ada:	b4e080e7          	jalr	-1202(ra) # 80004624 <initlog>
}
    80003ade:	70a2                	ld	ra,40(sp)
    80003ae0:	7402                	ld	s0,32(sp)
    80003ae2:	64e2                	ld	s1,24(sp)
    80003ae4:	6942                	ld	s2,16(sp)
    80003ae6:	69a2                	ld	s3,8(sp)
    80003ae8:	6145                	addi	sp,sp,48
    80003aea:	8082                	ret
    panic("invalid file system");
    80003aec:	00005517          	auipc	a0,0x5
    80003af0:	afc50513          	addi	a0,a0,-1284 # 800085e8 <syscalls+0x158>
    80003af4:	ffffd097          	auipc	ra,0xffffd
    80003af8:	a36080e7          	jalr	-1482(ra) # 8000052a <panic>

0000000080003afc <iinit>:
{
    80003afc:	7179                	addi	sp,sp,-48
    80003afe:	f406                	sd	ra,40(sp)
    80003b00:	f022                	sd	s0,32(sp)
    80003b02:	ec26                	sd	s1,24(sp)
    80003b04:	e84a                	sd	s2,16(sp)
    80003b06:	e44e                	sd	s3,8(sp)
    80003b08:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b0a:	00005597          	auipc	a1,0x5
    80003b0e:	af658593          	addi	a1,a1,-1290 # 80008600 <syscalls+0x170>
    80003b12:	00022517          	auipc	a0,0x22
    80003b16:	4b650513          	addi	a0,a0,1206 # 80025fc8 <itable>
    80003b1a:	ffffd097          	auipc	ra,0xffffd
    80003b1e:	018080e7          	jalr	24(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b22:	00022497          	auipc	s1,0x22
    80003b26:	4ce48493          	addi	s1,s1,1230 # 80025ff0 <itable+0x28>
    80003b2a:	00024997          	auipc	s3,0x24
    80003b2e:	f5698993          	addi	s3,s3,-170 # 80027a80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b32:	00005917          	auipc	s2,0x5
    80003b36:	ad690913          	addi	s2,s2,-1322 # 80008608 <syscalls+0x178>
    80003b3a:	85ca                	mv	a1,s2
    80003b3c:	8526                	mv	a0,s1
    80003b3e:	00001097          	auipc	ra,0x1
    80003b42:	e4a080e7          	jalr	-438(ra) # 80004988 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b46:	08848493          	addi	s1,s1,136
    80003b4a:	ff3498e3          	bne	s1,s3,80003b3a <iinit+0x3e>
}
    80003b4e:	70a2                	ld	ra,40(sp)
    80003b50:	7402                	ld	s0,32(sp)
    80003b52:	64e2                	ld	s1,24(sp)
    80003b54:	6942                	ld	s2,16(sp)
    80003b56:	69a2                	ld	s3,8(sp)
    80003b58:	6145                	addi	sp,sp,48
    80003b5a:	8082                	ret

0000000080003b5c <ialloc>:
{
    80003b5c:	715d                	addi	sp,sp,-80
    80003b5e:	e486                	sd	ra,72(sp)
    80003b60:	e0a2                	sd	s0,64(sp)
    80003b62:	fc26                	sd	s1,56(sp)
    80003b64:	f84a                	sd	s2,48(sp)
    80003b66:	f44e                	sd	s3,40(sp)
    80003b68:	f052                	sd	s4,32(sp)
    80003b6a:	ec56                	sd	s5,24(sp)
    80003b6c:	e85a                	sd	s6,16(sp)
    80003b6e:	e45e                	sd	s7,8(sp)
    80003b70:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b72:	00022717          	auipc	a4,0x22
    80003b76:	44272703          	lw	a4,1090(a4) # 80025fb4 <sb+0xc>
    80003b7a:	4785                	li	a5,1
    80003b7c:	04e7fa63          	bgeu	a5,a4,80003bd0 <ialloc+0x74>
    80003b80:	8aaa                	mv	s5,a0
    80003b82:	8bae                	mv	s7,a1
    80003b84:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b86:	00022a17          	auipc	s4,0x22
    80003b8a:	422a0a13          	addi	s4,s4,1058 # 80025fa8 <sb>
    80003b8e:	00048b1b          	sext.w	s6,s1
    80003b92:	0044d793          	srli	a5,s1,0x4
    80003b96:	018a2583          	lw	a1,24(s4)
    80003b9a:	9dbd                	addw	a1,a1,a5
    80003b9c:	8556                	mv	a0,s5
    80003b9e:	00000097          	auipc	ra,0x0
    80003ba2:	952080e7          	jalr	-1710(ra) # 800034f0 <bread>
    80003ba6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ba8:	05850993          	addi	s3,a0,88
    80003bac:	00f4f793          	andi	a5,s1,15
    80003bb0:	079a                	slli	a5,a5,0x6
    80003bb2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003bb4:	00099783          	lh	a5,0(s3)
    80003bb8:	c785                	beqz	a5,80003be0 <ialloc+0x84>
    brelse(bp);
    80003bba:	00000097          	auipc	ra,0x0
    80003bbe:	a66080e7          	jalr	-1434(ra) # 80003620 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003bc2:	0485                	addi	s1,s1,1
    80003bc4:	00ca2703          	lw	a4,12(s4)
    80003bc8:	0004879b          	sext.w	a5,s1
    80003bcc:	fce7e1e3          	bltu	a5,a4,80003b8e <ialloc+0x32>
  panic("ialloc: no inodes");
    80003bd0:	00005517          	auipc	a0,0x5
    80003bd4:	a4050513          	addi	a0,a0,-1472 # 80008610 <syscalls+0x180>
    80003bd8:	ffffd097          	auipc	ra,0xffffd
    80003bdc:	952080e7          	jalr	-1710(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003be0:	04000613          	li	a2,64
    80003be4:	4581                	li	a1,0
    80003be6:	854e                	mv	a0,s3
    80003be8:	ffffd097          	auipc	ra,0xffffd
    80003bec:	0d6080e7          	jalr	214(ra) # 80000cbe <memset>
      dip->type = type;
    80003bf0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003bf4:	854a                	mv	a0,s2
    80003bf6:	00001097          	auipc	ra,0x1
    80003bfa:	cac080e7          	jalr	-852(ra) # 800048a2 <log_write>
      brelse(bp);
    80003bfe:	854a                	mv	a0,s2
    80003c00:	00000097          	auipc	ra,0x0
    80003c04:	a20080e7          	jalr	-1504(ra) # 80003620 <brelse>
      return iget(dev, inum);
    80003c08:	85da                	mv	a1,s6
    80003c0a:	8556                	mv	a0,s5
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	db4080e7          	jalr	-588(ra) # 800039c0 <iget>
}
    80003c14:	60a6                	ld	ra,72(sp)
    80003c16:	6406                	ld	s0,64(sp)
    80003c18:	74e2                	ld	s1,56(sp)
    80003c1a:	7942                	ld	s2,48(sp)
    80003c1c:	79a2                	ld	s3,40(sp)
    80003c1e:	7a02                	ld	s4,32(sp)
    80003c20:	6ae2                	ld	s5,24(sp)
    80003c22:	6b42                	ld	s6,16(sp)
    80003c24:	6ba2                	ld	s7,8(sp)
    80003c26:	6161                	addi	sp,sp,80
    80003c28:	8082                	ret

0000000080003c2a <iupdate>:
{
    80003c2a:	1101                	addi	sp,sp,-32
    80003c2c:	ec06                	sd	ra,24(sp)
    80003c2e:	e822                	sd	s0,16(sp)
    80003c30:	e426                	sd	s1,8(sp)
    80003c32:	e04a                	sd	s2,0(sp)
    80003c34:	1000                	addi	s0,sp,32
    80003c36:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c38:	415c                	lw	a5,4(a0)
    80003c3a:	0047d79b          	srliw	a5,a5,0x4
    80003c3e:	00022597          	auipc	a1,0x22
    80003c42:	3825a583          	lw	a1,898(a1) # 80025fc0 <sb+0x18>
    80003c46:	9dbd                	addw	a1,a1,a5
    80003c48:	4108                	lw	a0,0(a0)
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	8a6080e7          	jalr	-1882(ra) # 800034f0 <bread>
    80003c52:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c54:	05850793          	addi	a5,a0,88
    80003c58:	40c8                	lw	a0,4(s1)
    80003c5a:	893d                	andi	a0,a0,15
    80003c5c:	051a                	slli	a0,a0,0x6
    80003c5e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003c60:	04449703          	lh	a4,68(s1)
    80003c64:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c68:	04649703          	lh	a4,70(s1)
    80003c6c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c70:	04849703          	lh	a4,72(s1)
    80003c74:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c78:	04a49703          	lh	a4,74(s1)
    80003c7c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c80:	44f8                	lw	a4,76(s1)
    80003c82:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c84:	03400613          	li	a2,52
    80003c88:	05048593          	addi	a1,s1,80
    80003c8c:	0531                	addi	a0,a0,12
    80003c8e:	ffffd097          	auipc	ra,0xffffd
    80003c92:	08c080e7          	jalr	140(ra) # 80000d1a <memmove>
  log_write(bp);
    80003c96:	854a                	mv	a0,s2
    80003c98:	00001097          	auipc	ra,0x1
    80003c9c:	c0a080e7          	jalr	-1014(ra) # 800048a2 <log_write>
  brelse(bp);
    80003ca0:	854a                	mv	a0,s2
    80003ca2:	00000097          	auipc	ra,0x0
    80003ca6:	97e080e7          	jalr	-1666(ra) # 80003620 <brelse>
}
    80003caa:	60e2                	ld	ra,24(sp)
    80003cac:	6442                	ld	s0,16(sp)
    80003cae:	64a2                	ld	s1,8(sp)
    80003cb0:	6902                	ld	s2,0(sp)
    80003cb2:	6105                	addi	sp,sp,32
    80003cb4:	8082                	ret

0000000080003cb6 <idup>:
{
    80003cb6:	1101                	addi	sp,sp,-32
    80003cb8:	ec06                	sd	ra,24(sp)
    80003cba:	e822                	sd	s0,16(sp)
    80003cbc:	e426                	sd	s1,8(sp)
    80003cbe:	1000                	addi	s0,sp,32
    80003cc0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cc2:	00022517          	auipc	a0,0x22
    80003cc6:	30650513          	addi	a0,a0,774 # 80025fc8 <itable>
    80003cca:	ffffd097          	auipc	ra,0xffffd
    80003cce:	ef8080e7          	jalr	-264(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003cd2:	449c                	lw	a5,8(s1)
    80003cd4:	2785                	addiw	a5,a5,1
    80003cd6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cd8:	00022517          	auipc	a0,0x22
    80003cdc:	2f050513          	addi	a0,a0,752 # 80025fc8 <itable>
    80003ce0:	ffffd097          	auipc	ra,0xffffd
    80003ce4:	f96080e7          	jalr	-106(ra) # 80000c76 <release>
}
    80003ce8:	8526                	mv	a0,s1
    80003cea:	60e2                	ld	ra,24(sp)
    80003cec:	6442                	ld	s0,16(sp)
    80003cee:	64a2                	ld	s1,8(sp)
    80003cf0:	6105                	addi	sp,sp,32
    80003cf2:	8082                	ret

0000000080003cf4 <ilock>:
{
    80003cf4:	1101                	addi	sp,sp,-32
    80003cf6:	ec06                	sd	ra,24(sp)
    80003cf8:	e822                	sd	s0,16(sp)
    80003cfa:	e426                	sd	s1,8(sp)
    80003cfc:	e04a                	sd	s2,0(sp)
    80003cfe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d00:	c115                	beqz	a0,80003d24 <ilock+0x30>
    80003d02:	84aa                	mv	s1,a0
    80003d04:	451c                	lw	a5,8(a0)
    80003d06:	00f05f63          	blez	a5,80003d24 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d0a:	0541                	addi	a0,a0,16
    80003d0c:	00001097          	auipc	ra,0x1
    80003d10:	cb6080e7          	jalr	-842(ra) # 800049c2 <acquiresleep>
  if(ip->valid == 0){
    80003d14:	40bc                	lw	a5,64(s1)
    80003d16:	cf99                	beqz	a5,80003d34 <ilock+0x40>
}
    80003d18:	60e2                	ld	ra,24(sp)
    80003d1a:	6442                	ld	s0,16(sp)
    80003d1c:	64a2                	ld	s1,8(sp)
    80003d1e:	6902                	ld	s2,0(sp)
    80003d20:	6105                	addi	sp,sp,32
    80003d22:	8082                	ret
    panic("ilock");
    80003d24:	00005517          	auipc	a0,0x5
    80003d28:	90450513          	addi	a0,a0,-1788 # 80008628 <syscalls+0x198>
    80003d2c:	ffffc097          	auipc	ra,0xffffc
    80003d30:	7fe080e7          	jalr	2046(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d34:	40dc                	lw	a5,4(s1)
    80003d36:	0047d79b          	srliw	a5,a5,0x4
    80003d3a:	00022597          	auipc	a1,0x22
    80003d3e:	2865a583          	lw	a1,646(a1) # 80025fc0 <sb+0x18>
    80003d42:	9dbd                	addw	a1,a1,a5
    80003d44:	4088                	lw	a0,0(s1)
    80003d46:	fffff097          	auipc	ra,0xfffff
    80003d4a:	7aa080e7          	jalr	1962(ra) # 800034f0 <bread>
    80003d4e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d50:	05850593          	addi	a1,a0,88
    80003d54:	40dc                	lw	a5,4(s1)
    80003d56:	8bbd                	andi	a5,a5,15
    80003d58:	079a                	slli	a5,a5,0x6
    80003d5a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d5c:	00059783          	lh	a5,0(a1)
    80003d60:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d64:	00259783          	lh	a5,2(a1)
    80003d68:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d6c:	00459783          	lh	a5,4(a1)
    80003d70:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d74:	00659783          	lh	a5,6(a1)
    80003d78:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d7c:	459c                	lw	a5,8(a1)
    80003d7e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d80:	03400613          	li	a2,52
    80003d84:	05b1                	addi	a1,a1,12
    80003d86:	05048513          	addi	a0,s1,80
    80003d8a:	ffffd097          	auipc	ra,0xffffd
    80003d8e:	f90080e7          	jalr	-112(ra) # 80000d1a <memmove>
    brelse(bp);
    80003d92:	854a                	mv	a0,s2
    80003d94:	00000097          	auipc	ra,0x0
    80003d98:	88c080e7          	jalr	-1908(ra) # 80003620 <brelse>
    ip->valid = 1;
    80003d9c:	4785                	li	a5,1
    80003d9e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003da0:	04449783          	lh	a5,68(s1)
    80003da4:	fbb5                	bnez	a5,80003d18 <ilock+0x24>
      panic("ilock: no type");
    80003da6:	00005517          	auipc	a0,0x5
    80003daa:	88a50513          	addi	a0,a0,-1910 # 80008630 <syscalls+0x1a0>
    80003dae:	ffffc097          	auipc	ra,0xffffc
    80003db2:	77c080e7          	jalr	1916(ra) # 8000052a <panic>

0000000080003db6 <iunlock>:
{
    80003db6:	1101                	addi	sp,sp,-32
    80003db8:	ec06                	sd	ra,24(sp)
    80003dba:	e822                	sd	s0,16(sp)
    80003dbc:	e426                	sd	s1,8(sp)
    80003dbe:	e04a                	sd	s2,0(sp)
    80003dc0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003dc2:	c905                	beqz	a0,80003df2 <iunlock+0x3c>
    80003dc4:	84aa                	mv	s1,a0
    80003dc6:	01050913          	addi	s2,a0,16
    80003dca:	854a                	mv	a0,s2
    80003dcc:	00001097          	auipc	ra,0x1
    80003dd0:	c90080e7          	jalr	-880(ra) # 80004a5c <holdingsleep>
    80003dd4:	cd19                	beqz	a0,80003df2 <iunlock+0x3c>
    80003dd6:	449c                	lw	a5,8(s1)
    80003dd8:	00f05d63          	blez	a5,80003df2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ddc:	854a                	mv	a0,s2
    80003dde:	00001097          	auipc	ra,0x1
    80003de2:	c3a080e7          	jalr	-966(ra) # 80004a18 <releasesleep>
}
    80003de6:	60e2                	ld	ra,24(sp)
    80003de8:	6442                	ld	s0,16(sp)
    80003dea:	64a2                	ld	s1,8(sp)
    80003dec:	6902                	ld	s2,0(sp)
    80003dee:	6105                	addi	sp,sp,32
    80003df0:	8082                	ret
    panic("iunlock");
    80003df2:	00005517          	auipc	a0,0x5
    80003df6:	84e50513          	addi	a0,a0,-1970 # 80008640 <syscalls+0x1b0>
    80003dfa:	ffffc097          	auipc	ra,0xffffc
    80003dfe:	730080e7          	jalr	1840(ra) # 8000052a <panic>

0000000080003e02 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e02:	7179                	addi	sp,sp,-48
    80003e04:	f406                	sd	ra,40(sp)
    80003e06:	f022                	sd	s0,32(sp)
    80003e08:	ec26                	sd	s1,24(sp)
    80003e0a:	e84a                	sd	s2,16(sp)
    80003e0c:	e44e                	sd	s3,8(sp)
    80003e0e:	e052                	sd	s4,0(sp)
    80003e10:	1800                	addi	s0,sp,48
    80003e12:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e14:	05050493          	addi	s1,a0,80
    80003e18:	08050913          	addi	s2,a0,128
    80003e1c:	a021                	j	80003e24 <itrunc+0x22>
    80003e1e:	0491                	addi	s1,s1,4
    80003e20:	01248d63          	beq	s1,s2,80003e3a <itrunc+0x38>
    if(ip->addrs[i]){
    80003e24:	408c                	lw	a1,0(s1)
    80003e26:	dde5                	beqz	a1,80003e1e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e28:	0009a503          	lw	a0,0(s3)
    80003e2c:	00000097          	auipc	ra,0x0
    80003e30:	90a080e7          	jalr	-1782(ra) # 80003736 <bfree>
      ip->addrs[i] = 0;
    80003e34:	0004a023          	sw	zero,0(s1)
    80003e38:	b7dd                	j	80003e1e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e3a:	0809a583          	lw	a1,128(s3)
    80003e3e:	e185                	bnez	a1,80003e5e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e40:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e44:	854e                	mv	a0,s3
    80003e46:	00000097          	auipc	ra,0x0
    80003e4a:	de4080e7          	jalr	-540(ra) # 80003c2a <iupdate>
}
    80003e4e:	70a2                	ld	ra,40(sp)
    80003e50:	7402                	ld	s0,32(sp)
    80003e52:	64e2                	ld	s1,24(sp)
    80003e54:	6942                	ld	s2,16(sp)
    80003e56:	69a2                	ld	s3,8(sp)
    80003e58:	6a02                	ld	s4,0(sp)
    80003e5a:	6145                	addi	sp,sp,48
    80003e5c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e5e:	0009a503          	lw	a0,0(s3)
    80003e62:	fffff097          	auipc	ra,0xfffff
    80003e66:	68e080e7          	jalr	1678(ra) # 800034f0 <bread>
    80003e6a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e6c:	05850493          	addi	s1,a0,88
    80003e70:	45850913          	addi	s2,a0,1112
    80003e74:	a021                	j	80003e7c <itrunc+0x7a>
    80003e76:	0491                	addi	s1,s1,4
    80003e78:	01248b63          	beq	s1,s2,80003e8e <itrunc+0x8c>
      if(a[j])
    80003e7c:	408c                	lw	a1,0(s1)
    80003e7e:	dde5                	beqz	a1,80003e76 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003e80:	0009a503          	lw	a0,0(s3)
    80003e84:	00000097          	auipc	ra,0x0
    80003e88:	8b2080e7          	jalr	-1870(ra) # 80003736 <bfree>
    80003e8c:	b7ed                	j	80003e76 <itrunc+0x74>
    brelse(bp);
    80003e8e:	8552                	mv	a0,s4
    80003e90:	fffff097          	auipc	ra,0xfffff
    80003e94:	790080e7          	jalr	1936(ra) # 80003620 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e98:	0809a583          	lw	a1,128(s3)
    80003e9c:	0009a503          	lw	a0,0(s3)
    80003ea0:	00000097          	auipc	ra,0x0
    80003ea4:	896080e7          	jalr	-1898(ra) # 80003736 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ea8:	0809a023          	sw	zero,128(s3)
    80003eac:	bf51                	j	80003e40 <itrunc+0x3e>

0000000080003eae <iput>:
{
    80003eae:	1101                	addi	sp,sp,-32
    80003eb0:	ec06                	sd	ra,24(sp)
    80003eb2:	e822                	sd	s0,16(sp)
    80003eb4:	e426                	sd	s1,8(sp)
    80003eb6:	e04a                	sd	s2,0(sp)
    80003eb8:	1000                	addi	s0,sp,32
    80003eba:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ebc:	00022517          	auipc	a0,0x22
    80003ec0:	10c50513          	addi	a0,a0,268 # 80025fc8 <itable>
    80003ec4:	ffffd097          	auipc	ra,0xffffd
    80003ec8:	cfe080e7          	jalr	-770(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ecc:	4498                	lw	a4,8(s1)
    80003ece:	4785                	li	a5,1
    80003ed0:	02f70363          	beq	a4,a5,80003ef6 <iput+0x48>
  ip->ref--;
    80003ed4:	449c                	lw	a5,8(s1)
    80003ed6:	37fd                	addiw	a5,a5,-1
    80003ed8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003eda:	00022517          	auipc	a0,0x22
    80003ede:	0ee50513          	addi	a0,a0,238 # 80025fc8 <itable>
    80003ee2:	ffffd097          	auipc	ra,0xffffd
    80003ee6:	d94080e7          	jalr	-620(ra) # 80000c76 <release>
}
    80003eea:	60e2                	ld	ra,24(sp)
    80003eec:	6442                	ld	s0,16(sp)
    80003eee:	64a2                	ld	s1,8(sp)
    80003ef0:	6902                	ld	s2,0(sp)
    80003ef2:	6105                	addi	sp,sp,32
    80003ef4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ef6:	40bc                	lw	a5,64(s1)
    80003ef8:	dff1                	beqz	a5,80003ed4 <iput+0x26>
    80003efa:	04a49783          	lh	a5,74(s1)
    80003efe:	fbf9                	bnez	a5,80003ed4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003f00:	01048913          	addi	s2,s1,16
    80003f04:	854a                	mv	a0,s2
    80003f06:	00001097          	auipc	ra,0x1
    80003f0a:	abc080e7          	jalr	-1348(ra) # 800049c2 <acquiresleep>
    release(&itable.lock);
    80003f0e:	00022517          	auipc	a0,0x22
    80003f12:	0ba50513          	addi	a0,a0,186 # 80025fc8 <itable>
    80003f16:	ffffd097          	auipc	ra,0xffffd
    80003f1a:	d60080e7          	jalr	-672(ra) # 80000c76 <release>
    itrunc(ip);
    80003f1e:	8526                	mv	a0,s1
    80003f20:	00000097          	auipc	ra,0x0
    80003f24:	ee2080e7          	jalr	-286(ra) # 80003e02 <itrunc>
    ip->type = 0;
    80003f28:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	00000097          	auipc	ra,0x0
    80003f32:	cfc080e7          	jalr	-772(ra) # 80003c2a <iupdate>
    ip->valid = 0;
    80003f36:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f3a:	854a                	mv	a0,s2
    80003f3c:	00001097          	auipc	ra,0x1
    80003f40:	adc080e7          	jalr	-1316(ra) # 80004a18 <releasesleep>
    acquire(&itable.lock);
    80003f44:	00022517          	auipc	a0,0x22
    80003f48:	08450513          	addi	a0,a0,132 # 80025fc8 <itable>
    80003f4c:	ffffd097          	auipc	ra,0xffffd
    80003f50:	c76080e7          	jalr	-906(ra) # 80000bc2 <acquire>
    80003f54:	b741                	j	80003ed4 <iput+0x26>

0000000080003f56 <iunlockput>:
{
    80003f56:	1101                	addi	sp,sp,-32
    80003f58:	ec06                	sd	ra,24(sp)
    80003f5a:	e822                	sd	s0,16(sp)
    80003f5c:	e426                	sd	s1,8(sp)
    80003f5e:	1000                	addi	s0,sp,32
    80003f60:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f62:	00000097          	auipc	ra,0x0
    80003f66:	e54080e7          	jalr	-428(ra) # 80003db6 <iunlock>
  iput(ip);
    80003f6a:	8526                	mv	a0,s1
    80003f6c:	00000097          	auipc	ra,0x0
    80003f70:	f42080e7          	jalr	-190(ra) # 80003eae <iput>
}
    80003f74:	60e2                	ld	ra,24(sp)
    80003f76:	6442                	ld	s0,16(sp)
    80003f78:	64a2                	ld	s1,8(sp)
    80003f7a:	6105                	addi	sp,sp,32
    80003f7c:	8082                	ret

0000000080003f7e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f7e:	1141                	addi	sp,sp,-16
    80003f80:	e422                	sd	s0,8(sp)
    80003f82:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f84:	411c                	lw	a5,0(a0)
    80003f86:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f88:	415c                	lw	a5,4(a0)
    80003f8a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f8c:	04451783          	lh	a5,68(a0)
    80003f90:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f94:	04a51783          	lh	a5,74(a0)
    80003f98:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f9c:	04c56783          	lwu	a5,76(a0)
    80003fa0:	e99c                	sd	a5,16(a1)
}
    80003fa2:	6422                	ld	s0,8(sp)
    80003fa4:	0141                	addi	sp,sp,16
    80003fa6:	8082                	ret

0000000080003fa8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fa8:	457c                	lw	a5,76(a0)
    80003faa:	0ed7e963          	bltu	a5,a3,8000409c <readi+0xf4>
{
    80003fae:	7159                	addi	sp,sp,-112
    80003fb0:	f486                	sd	ra,104(sp)
    80003fb2:	f0a2                	sd	s0,96(sp)
    80003fb4:	eca6                	sd	s1,88(sp)
    80003fb6:	e8ca                	sd	s2,80(sp)
    80003fb8:	e4ce                	sd	s3,72(sp)
    80003fba:	e0d2                	sd	s4,64(sp)
    80003fbc:	fc56                	sd	s5,56(sp)
    80003fbe:	f85a                	sd	s6,48(sp)
    80003fc0:	f45e                	sd	s7,40(sp)
    80003fc2:	f062                	sd	s8,32(sp)
    80003fc4:	ec66                	sd	s9,24(sp)
    80003fc6:	e86a                	sd	s10,16(sp)
    80003fc8:	e46e                	sd	s11,8(sp)
    80003fca:	1880                	addi	s0,sp,112
    80003fcc:	8baa                	mv	s7,a0
    80003fce:	8c2e                	mv	s8,a1
    80003fd0:	8ab2                	mv	s5,a2
    80003fd2:	84b6                	mv	s1,a3
    80003fd4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fd6:	9f35                	addw	a4,a4,a3
    return 0;
    80003fd8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003fda:	0ad76063          	bltu	a4,a3,8000407a <readi+0xd2>
  if(off + n > ip->size)
    80003fde:	00e7f463          	bgeu	a5,a4,80003fe6 <readi+0x3e>
    n = ip->size - off;
    80003fe2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fe6:	0a0b0963          	beqz	s6,80004098 <readi+0xf0>
    80003fea:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fec:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ff0:	5cfd                	li	s9,-1
    80003ff2:	a82d                	j	8000402c <readi+0x84>
    80003ff4:	020a1d93          	slli	s11,s4,0x20
    80003ff8:	020ddd93          	srli	s11,s11,0x20
    80003ffc:	05890793          	addi	a5,s2,88
    80004000:	86ee                	mv	a3,s11
    80004002:	963e                	add	a2,a2,a5
    80004004:	85d6                	mv	a1,s5
    80004006:	8562                	mv	a0,s8
    80004008:	ffffe097          	auipc	ra,0xffffe
    8000400c:	4d6080e7          	jalr	1238(ra) # 800024de <either_copyout>
    80004010:	05950d63          	beq	a0,s9,8000406a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004014:	854a                	mv	a0,s2
    80004016:	fffff097          	auipc	ra,0xfffff
    8000401a:	60a080e7          	jalr	1546(ra) # 80003620 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000401e:	013a09bb          	addw	s3,s4,s3
    80004022:	009a04bb          	addw	s1,s4,s1
    80004026:	9aee                	add	s5,s5,s11
    80004028:	0569f763          	bgeu	s3,s6,80004076 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000402c:	000ba903          	lw	s2,0(s7)
    80004030:	00a4d59b          	srliw	a1,s1,0xa
    80004034:	855e                	mv	a0,s7
    80004036:	00000097          	auipc	ra,0x0
    8000403a:	8ae080e7          	jalr	-1874(ra) # 800038e4 <bmap>
    8000403e:	0005059b          	sext.w	a1,a0
    80004042:	854a                	mv	a0,s2
    80004044:	fffff097          	auipc	ra,0xfffff
    80004048:	4ac080e7          	jalr	1196(ra) # 800034f0 <bread>
    8000404c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000404e:	3ff4f613          	andi	a2,s1,1023
    80004052:	40cd07bb          	subw	a5,s10,a2
    80004056:	413b073b          	subw	a4,s6,s3
    8000405a:	8a3e                	mv	s4,a5
    8000405c:	2781                	sext.w	a5,a5
    8000405e:	0007069b          	sext.w	a3,a4
    80004062:	f8f6f9e3          	bgeu	a3,a5,80003ff4 <readi+0x4c>
    80004066:	8a3a                	mv	s4,a4
    80004068:	b771                	j	80003ff4 <readi+0x4c>
      brelse(bp);
    8000406a:	854a                	mv	a0,s2
    8000406c:	fffff097          	auipc	ra,0xfffff
    80004070:	5b4080e7          	jalr	1460(ra) # 80003620 <brelse>
      tot = -1;
    80004074:	59fd                	li	s3,-1
  }
  return tot;
    80004076:	0009851b          	sext.w	a0,s3
}
    8000407a:	70a6                	ld	ra,104(sp)
    8000407c:	7406                	ld	s0,96(sp)
    8000407e:	64e6                	ld	s1,88(sp)
    80004080:	6946                	ld	s2,80(sp)
    80004082:	69a6                	ld	s3,72(sp)
    80004084:	6a06                	ld	s4,64(sp)
    80004086:	7ae2                	ld	s5,56(sp)
    80004088:	7b42                	ld	s6,48(sp)
    8000408a:	7ba2                	ld	s7,40(sp)
    8000408c:	7c02                	ld	s8,32(sp)
    8000408e:	6ce2                	ld	s9,24(sp)
    80004090:	6d42                	ld	s10,16(sp)
    80004092:	6da2                	ld	s11,8(sp)
    80004094:	6165                	addi	sp,sp,112
    80004096:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004098:	89da                	mv	s3,s6
    8000409a:	bff1                	j	80004076 <readi+0xce>
    return 0;
    8000409c:	4501                	li	a0,0
}
    8000409e:	8082                	ret

00000000800040a0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040a0:	457c                	lw	a5,76(a0)
    800040a2:	10d7e863          	bltu	a5,a3,800041b2 <writei+0x112>
{
    800040a6:	7159                	addi	sp,sp,-112
    800040a8:	f486                	sd	ra,104(sp)
    800040aa:	f0a2                	sd	s0,96(sp)
    800040ac:	eca6                	sd	s1,88(sp)
    800040ae:	e8ca                	sd	s2,80(sp)
    800040b0:	e4ce                	sd	s3,72(sp)
    800040b2:	e0d2                	sd	s4,64(sp)
    800040b4:	fc56                	sd	s5,56(sp)
    800040b6:	f85a                	sd	s6,48(sp)
    800040b8:	f45e                	sd	s7,40(sp)
    800040ba:	f062                	sd	s8,32(sp)
    800040bc:	ec66                	sd	s9,24(sp)
    800040be:	e86a                	sd	s10,16(sp)
    800040c0:	e46e                	sd	s11,8(sp)
    800040c2:	1880                	addi	s0,sp,112
    800040c4:	8b2a                	mv	s6,a0
    800040c6:	8c2e                	mv	s8,a1
    800040c8:	8ab2                	mv	s5,a2
    800040ca:	8936                	mv	s2,a3
    800040cc:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800040ce:	00e687bb          	addw	a5,a3,a4
    800040d2:	0ed7e263          	bltu	a5,a3,800041b6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040d6:	00043737          	lui	a4,0x43
    800040da:	0ef76063          	bltu	a4,a5,800041ba <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040de:	0c0b8863          	beqz	s7,800041ae <writei+0x10e>
    800040e2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800040e4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040e8:	5cfd                	li	s9,-1
    800040ea:	a091                	j	8000412e <writei+0x8e>
    800040ec:	02099d93          	slli	s11,s3,0x20
    800040f0:	020ddd93          	srli	s11,s11,0x20
    800040f4:	05848793          	addi	a5,s1,88
    800040f8:	86ee                	mv	a3,s11
    800040fa:	8656                	mv	a2,s5
    800040fc:	85e2                	mv	a1,s8
    800040fe:	953e                	add	a0,a0,a5
    80004100:	ffffe097          	auipc	ra,0xffffe
    80004104:	434080e7          	jalr	1076(ra) # 80002534 <either_copyin>
    80004108:	07950263          	beq	a0,s9,8000416c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000410c:	8526                	mv	a0,s1
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	794080e7          	jalr	1940(ra) # 800048a2 <log_write>
    brelse(bp);
    80004116:	8526                	mv	a0,s1
    80004118:	fffff097          	auipc	ra,0xfffff
    8000411c:	508080e7          	jalr	1288(ra) # 80003620 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004120:	01498a3b          	addw	s4,s3,s4
    80004124:	0129893b          	addw	s2,s3,s2
    80004128:	9aee                	add	s5,s5,s11
    8000412a:	057a7663          	bgeu	s4,s7,80004176 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000412e:	000b2483          	lw	s1,0(s6)
    80004132:	00a9559b          	srliw	a1,s2,0xa
    80004136:	855a                	mv	a0,s6
    80004138:	fffff097          	auipc	ra,0xfffff
    8000413c:	7ac080e7          	jalr	1964(ra) # 800038e4 <bmap>
    80004140:	0005059b          	sext.w	a1,a0
    80004144:	8526                	mv	a0,s1
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	3aa080e7          	jalr	938(ra) # 800034f0 <bread>
    8000414e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004150:	3ff97513          	andi	a0,s2,1023
    80004154:	40ad07bb          	subw	a5,s10,a0
    80004158:	414b873b          	subw	a4,s7,s4
    8000415c:	89be                	mv	s3,a5
    8000415e:	2781                	sext.w	a5,a5
    80004160:	0007069b          	sext.w	a3,a4
    80004164:	f8f6f4e3          	bgeu	a3,a5,800040ec <writei+0x4c>
    80004168:	89ba                	mv	s3,a4
    8000416a:	b749                	j	800040ec <writei+0x4c>
      brelse(bp);
    8000416c:	8526                	mv	a0,s1
    8000416e:	fffff097          	auipc	ra,0xfffff
    80004172:	4b2080e7          	jalr	1202(ra) # 80003620 <brelse>
  }

  if(off > ip->size)
    80004176:	04cb2783          	lw	a5,76(s6)
    8000417a:	0127f463          	bgeu	a5,s2,80004182 <writei+0xe2>
    ip->size = off;
    8000417e:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004182:	855a                	mv	a0,s6
    80004184:	00000097          	auipc	ra,0x0
    80004188:	aa6080e7          	jalr	-1370(ra) # 80003c2a <iupdate>

  return tot;
    8000418c:	000a051b          	sext.w	a0,s4
}
    80004190:	70a6                	ld	ra,104(sp)
    80004192:	7406                	ld	s0,96(sp)
    80004194:	64e6                	ld	s1,88(sp)
    80004196:	6946                	ld	s2,80(sp)
    80004198:	69a6                	ld	s3,72(sp)
    8000419a:	6a06                	ld	s4,64(sp)
    8000419c:	7ae2                	ld	s5,56(sp)
    8000419e:	7b42                	ld	s6,48(sp)
    800041a0:	7ba2                	ld	s7,40(sp)
    800041a2:	7c02                	ld	s8,32(sp)
    800041a4:	6ce2                	ld	s9,24(sp)
    800041a6:	6d42                	ld	s10,16(sp)
    800041a8:	6da2                	ld	s11,8(sp)
    800041aa:	6165                	addi	sp,sp,112
    800041ac:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041ae:	8a5e                	mv	s4,s7
    800041b0:	bfc9                	j	80004182 <writei+0xe2>
    return -1;
    800041b2:	557d                	li	a0,-1
}
    800041b4:	8082                	ret
    return -1;
    800041b6:	557d                	li	a0,-1
    800041b8:	bfe1                	j	80004190 <writei+0xf0>
    return -1;
    800041ba:	557d                	li	a0,-1
    800041bc:	bfd1                	j	80004190 <writei+0xf0>

00000000800041be <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800041be:	1141                	addi	sp,sp,-16
    800041c0:	e406                	sd	ra,8(sp)
    800041c2:	e022                	sd	s0,0(sp)
    800041c4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041c6:	4639                	li	a2,14
    800041c8:	ffffd097          	auipc	ra,0xffffd
    800041cc:	bce080e7          	jalr	-1074(ra) # 80000d96 <strncmp>
}
    800041d0:	60a2                	ld	ra,8(sp)
    800041d2:	6402                	ld	s0,0(sp)
    800041d4:	0141                	addi	sp,sp,16
    800041d6:	8082                	ret

00000000800041d8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041d8:	7139                	addi	sp,sp,-64
    800041da:	fc06                	sd	ra,56(sp)
    800041dc:	f822                	sd	s0,48(sp)
    800041de:	f426                	sd	s1,40(sp)
    800041e0:	f04a                	sd	s2,32(sp)
    800041e2:	ec4e                	sd	s3,24(sp)
    800041e4:	e852                	sd	s4,16(sp)
    800041e6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041e8:	04451703          	lh	a4,68(a0)
    800041ec:	4785                	li	a5,1
    800041ee:	00f71a63          	bne	a4,a5,80004202 <dirlookup+0x2a>
    800041f2:	892a                	mv	s2,a0
    800041f4:	89ae                	mv	s3,a1
    800041f6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041f8:	457c                	lw	a5,76(a0)
    800041fa:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041fc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041fe:	e79d                	bnez	a5,8000422c <dirlookup+0x54>
    80004200:	a8a5                	j	80004278 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004202:	00004517          	auipc	a0,0x4
    80004206:	44650513          	addi	a0,a0,1094 # 80008648 <syscalls+0x1b8>
    8000420a:	ffffc097          	auipc	ra,0xffffc
    8000420e:	320080e7          	jalr	800(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004212:	00004517          	auipc	a0,0x4
    80004216:	44e50513          	addi	a0,a0,1102 # 80008660 <syscalls+0x1d0>
    8000421a:	ffffc097          	auipc	ra,0xffffc
    8000421e:	310080e7          	jalr	784(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004222:	24c1                	addiw	s1,s1,16
    80004224:	04c92783          	lw	a5,76(s2)
    80004228:	04f4f763          	bgeu	s1,a5,80004276 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000422c:	4741                	li	a4,16
    8000422e:	86a6                	mv	a3,s1
    80004230:	fc040613          	addi	a2,s0,-64
    80004234:	4581                	li	a1,0
    80004236:	854a                	mv	a0,s2
    80004238:	00000097          	auipc	ra,0x0
    8000423c:	d70080e7          	jalr	-656(ra) # 80003fa8 <readi>
    80004240:	47c1                	li	a5,16
    80004242:	fcf518e3          	bne	a0,a5,80004212 <dirlookup+0x3a>
    if(de.inum == 0)
    80004246:	fc045783          	lhu	a5,-64(s0)
    8000424a:	dfe1                	beqz	a5,80004222 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000424c:	fc240593          	addi	a1,s0,-62
    80004250:	854e                	mv	a0,s3
    80004252:	00000097          	auipc	ra,0x0
    80004256:	f6c080e7          	jalr	-148(ra) # 800041be <namecmp>
    8000425a:	f561                	bnez	a0,80004222 <dirlookup+0x4a>
      if(poff)
    8000425c:	000a0463          	beqz	s4,80004264 <dirlookup+0x8c>
        *poff = off;
    80004260:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004264:	fc045583          	lhu	a1,-64(s0)
    80004268:	00092503          	lw	a0,0(s2)
    8000426c:	fffff097          	auipc	ra,0xfffff
    80004270:	754080e7          	jalr	1876(ra) # 800039c0 <iget>
    80004274:	a011                	j	80004278 <dirlookup+0xa0>
  return 0;
    80004276:	4501                	li	a0,0
}
    80004278:	70e2                	ld	ra,56(sp)
    8000427a:	7442                	ld	s0,48(sp)
    8000427c:	74a2                	ld	s1,40(sp)
    8000427e:	7902                	ld	s2,32(sp)
    80004280:	69e2                	ld	s3,24(sp)
    80004282:	6a42                	ld	s4,16(sp)
    80004284:	6121                	addi	sp,sp,64
    80004286:	8082                	ret

0000000080004288 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004288:	711d                	addi	sp,sp,-96
    8000428a:	ec86                	sd	ra,88(sp)
    8000428c:	e8a2                	sd	s0,80(sp)
    8000428e:	e4a6                	sd	s1,72(sp)
    80004290:	e0ca                	sd	s2,64(sp)
    80004292:	fc4e                	sd	s3,56(sp)
    80004294:	f852                	sd	s4,48(sp)
    80004296:	f456                	sd	s5,40(sp)
    80004298:	f05a                	sd	s6,32(sp)
    8000429a:	ec5e                	sd	s7,24(sp)
    8000429c:	e862                	sd	s8,16(sp)
    8000429e:	e466                	sd	s9,8(sp)
    800042a0:	1080                	addi	s0,sp,96
    800042a2:	84aa                	mv	s1,a0
    800042a4:	8aae                	mv	s5,a1
    800042a6:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800042a8:	00054703          	lbu	a4,0(a0)
    800042ac:	02f00793          	li	a5,47
    800042b0:	02f70363          	beq	a4,a5,800042d6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800042b4:	ffffd097          	auipc	ra,0xffffd
    800042b8:	700080e7          	jalr	1792(ra) # 800019b4 <myproc>
    800042bc:	15053503          	ld	a0,336(a0)
    800042c0:	00000097          	auipc	ra,0x0
    800042c4:	9f6080e7          	jalr	-1546(ra) # 80003cb6 <idup>
    800042c8:	89aa                	mv	s3,a0
  while(*path == '/')
    800042ca:	02f00913          	li	s2,47
  len = path - s;
    800042ce:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800042d0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800042d2:	4b85                	li	s7,1
    800042d4:	a865                	j	8000438c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800042d6:	4585                	li	a1,1
    800042d8:	4505                	li	a0,1
    800042da:	fffff097          	auipc	ra,0xfffff
    800042de:	6e6080e7          	jalr	1766(ra) # 800039c0 <iget>
    800042e2:	89aa                	mv	s3,a0
    800042e4:	b7dd                	j	800042ca <namex+0x42>
      iunlockput(ip);
    800042e6:	854e                	mv	a0,s3
    800042e8:	00000097          	auipc	ra,0x0
    800042ec:	c6e080e7          	jalr	-914(ra) # 80003f56 <iunlockput>
      return 0;
    800042f0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042f2:	854e                	mv	a0,s3
    800042f4:	60e6                	ld	ra,88(sp)
    800042f6:	6446                	ld	s0,80(sp)
    800042f8:	64a6                	ld	s1,72(sp)
    800042fa:	6906                	ld	s2,64(sp)
    800042fc:	79e2                	ld	s3,56(sp)
    800042fe:	7a42                	ld	s4,48(sp)
    80004300:	7aa2                	ld	s5,40(sp)
    80004302:	7b02                	ld	s6,32(sp)
    80004304:	6be2                	ld	s7,24(sp)
    80004306:	6c42                	ld	s8,16(sp)
    80004308:	6ca2                	ld	s9,8(sp)
    8000430a:	6125                	addi	sp,sp,96
    8000430c:	8082                	ret
      iunlock(ip);
    8000430e:	854e                	mv	a0,s3
    80004310:	00000097          	auipc	ra,0x0
    80004314:	aa6080e7          	jalr	-1370(ra) # 80003db6 <iunlock>
      return ip;
    80004318:	bfe9                	j	800042f2 <namex+0x6a>
      iunlockput(ip);
    8000431a:	854e                	mv	a0,s3
    8000431c:	00000097          	auipc	ra,0x0
    80004320:	c3a080e7          	jalr	-966(ra) # 80003f56 <iunlockput>
      return 0;
    80004324:	89e6                	mv	s3,s9
    80004326:	b7f1                	j	800042f2 <namex+0x6a>
  len = path - s;
    80004328:	40b48633          	sub	a2,s1,a1
    8000432c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004330:	099c5463          	bge	s8,s9,800043b8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004334:	4639                	li	a2,14
    80004336:	8552                	mv	a0,s4
    80004338:	ffffd097          	auipc	ra,0xffffd
    8000433c:	9e2080e7          	jalr	-1566(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004340:	0004c783          	lbu	a5,0(s1)
    80004344:	01279763          	bne	a5,s2,80004352 <namex+0xca>
    path++;
    80004348:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000434a:	0004c783          	lbu	a5,0(s1)
    8000434e:	ff278de3          	beq	a5,s2,80004348 <namex+0xc0>
    ilock(ip);
    80004352:	854e                	mv	a0,s3
    80004354:	00000097          	auipc	ra,0x0
    80004358:	9a0080e7          	jalr	-1632(ra) # 80003cf4 <ilock>
    if(ip->type != T_DIR){
    8000435c:	04499783          	lh	a5,68(s3)
    80004360:	f97793e3          	bne	a5,s7,800042e6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004364:	000a8563          	beqz	s5,8000436e <namex+0xe6>
    80004368:	0004c783          	lbu	a5,0(s1)
    8000436c:	d3cd                	beqz	a5,8000430e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000436e:	865a                	mv	a2,s6
    80004370:	85d2                	mv	a1,s4
    80004372:	854e                	mv	a0,s3
    80004374:	00000097          	auipc	ra,0x0
    80004378:	e64080e7          	jalr	-412(ra) # 800041d8 <dirlookup>
    8000437c:	8caa                	mv	s9,a0
    8000437e:	dd51                	beqz	a0,8000431a <namex+0x92>
    iunlockput(ip);
    80004380:	854e                	mv	a0,s3
    80004382:	00000097          	auipc	ra,0x0
    80004386:	bd4080e7          	jalr	-1068(ra) # 80003f56 <iunlockput>
    ip = next;
    8000438a:	89e6                	mv	s3,s9
  while(*path == '/')
    8000438c:	0004c783          	lbu	a5,0(s1)
    80004390:	05279763          	bne	a5,s2,800043de <namex+0x156>
    path++;
    80004394:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004396:	0004c783          	lbu	a5,0(s1)
    8000439a:	ff278de3          	beq	a5,s2,80004394 <namex+0x10c>
  if(*path == 0)
    8000439e:	c79d                	beqz	a5,800043cc <namex+0x144>
    path++;
    800043a0:	85a6                	mv	a1,s1
  len = path - s;
    800043a2:	8cda                	mv	s9,s6
    800043a4:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800043a6:	01278963          	beq	a5,s2,800043b8 <namex+0x130>
    800043aa:	dfbd                	beqz	a5,80004328 <namex+0xa0>
    path++;
    800043ac:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800043ae:	0004c783          	lbu	a5,0(s1)
    800043b2:	ff279ce3          	bne	a5,s2,800043aa <namex+0x122>
    800043b6:	bf8d                	j	80004328 <namex+0xa0>
    memmove(name, s, len);
    800043b8:	2601                	sext.w	a2,a2
    800043ba:	8552                	mv	a0,s4
    800043bc:	ffffd097          	auipc	ra,0xffffd
    800043c0:	95e080e7          	jalr	-1698(ra) # 80000d1a <memmove>
    name[len] = 0;
    800043c4:	9cd2                	add	s9,s9,s4
    800043c6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800043ca:	bf9d                	j	80004340 <namex+0xb8>
  if(nameiparent){
    800043cc:	f20a83e3          	beqz	s5,800042f2 <namex+0x6a>
    iput(ip);
    800043d0:	854e                	mv	a0,s3
    800043d2:	00000097          	auipc	ra,0x0
    800043d6:	adc080e7          	jalr	-1316(ra) # 80003eae <iput>
    return 0;
    800043da:	4981                	li	s3,0
    800043dc:	bf19                	j	800042f2 <namex+0x6a>
  if(*path == 0)
    800043de:	d7fd                	beqz	a5,800043cc <namex+0x144>
  while(*path != '/' && *path != 0)
    800043e0:	0004c783          	lbu	a5,0(s1)
    800043e4:	85a6                	mv	a1,s1
    800043e6:	b7d1                	j	800043aa <namex+0x122>

00000000800043e8 <dirlink>:
{
    800043e8:	7139                	addi	sp,sp,-64
    800043ea:	fc06                	sd	ra,56(sp)
    800043ec:	f822                	sd	s0,48(sp)
    800043ee:	f426                	sd	s1,40(sp)
    800043f0:	f04a                	sd	s2,32(sp)
    800043f2:	ec4e                	sd	s3,24(sp)
    800043f4:	e852                	sd	s4,16(sp)
    800043f6:	0080                	addi	s0,sp,64
    800043f8:	892a                	mv	s2,a0
    800043fa:	8a2e                	mv	s4,a1
    800043fc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043fe:	4601                	li	a2,0
    80004400:	00000097          	auipc	ra,0x0
    80004404:	dd8080e7          	jalr	-552(ra) # 800041d8 <dirlookup>
    80004408:	e93d                	bnez	a0,8000447e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000440a:	04c92483          	lw	s1,76(s2)
    8000440e:	c49d                	beqz	s1,8000443c <dirlink+0x54>
    80004410:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004412:	4741                	li	a4,16
    80004414:	86a6                	mv	a3,s1
    80004416:	fc040613          	addi	a2,s0,-64
    8000441a:	4581                	li	a1,0
    8000441c:	854a                	mv	a0,s2
    8000441e:	00000097          	auipc	ra,0x0
    80004422:	b8a080e7          	jalr	-1142(ra) # 80003fa8 <readi>
    80004426:	47c1                	li	a5,16
    80004428:	06f51163          	bne	a0,a5,8000448a <dirlink+0xa2>
    if(de.inum == 0)
    8000442c:	fc045783          	lhu	a5,-64(s0)
    80004430:	c791                	beqz	a5,8000443c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004432:	24c1                	addiw	s1,s1,16
    80004434:	04c92783          	lw	a5,76(s2)
    80004438:	fcf4ede3          	bltu	s1,a5,80004412 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000443c:	4639                	li	a2,14
    8000443e:	85d2                	mv	a1,s4
    80004440:	fc240513          	addi	a0,s0,-62
    80004444:	ffffd097          	auipc	ra,0xffffd
    80004448:	98e080e7          	jalr	-1650(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    8000444c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004450:	4741                	li	a4,16
    80004452:	86a6                	mv	a3,s1
    80004454:	fc040613          	addi	a2,s0,-64
    80004458:	4581                	li	a1,0
    8000445a:	854a                	mv	a0,s2
    8000445c:	00000097          	auipc	ra,0x0
    80004460:	c44080e7          	jalr	-956(ra) # 800040a0 <writei>
    80004464:	872a                	mv	a4,a0
    80004466:	47c1                	li	a5,16
  return 0;
    80004468:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000446a:	02f71863          	bne	a4,a5,8000449a <dirlink+0xb2>
}
    8000446e:	70e2                	ld	ra,56(sp)
    80004470:	7442                	ld	s0,48(sp)
    80004472:	74a2                	ld	s1,40(sp)
    80004474:	7902                	ld	s2,32(sp)
    80004476:	69e2                	ld	s3,24(sp)
    80004478:	6a42                	ld	s4,16(sp)
    8000447a:	6121                	addi	sp,sp,64
    8000447c:	8082                	ret
    iput(ip);
    8000447e:	00000097          	auipc	ra,0x0
    80004482:	a30080e7          	jalr	-1488(ra) # 80003eae <iput>
    return -1;
    80004486:	557d                	li	a0,-1
    80004488:	b7dd                	j	8000446e <dirlink+0x86>
      panic("dirlink read");
    8000448a:	00004517          	auipc	a0,0x4
    8000448e:	1e650513          	addi	a0,a0,486 # 80008670 <syscalls+0x1e0>
    80004492:	ffffc097          	auipc	ra,0xffffc
    80004496:	098080e7          	jalr	152(ra) # 8000052a <panic>
    panic("dirlink");
    8000449a:	00004517          	auipc	a0,0x4
    8000449e:	2e650513          	addi	a0,a0,742 # 80008780 <syscalls+0x2f0>
    800044a2:	ffffc097          	auipc	ra,0xffffc
    800044a6:	088080e7          	jalr	136(ra) # 8000052a <panic>

00000000800044aa <namei>:

struct inode*
namei(char *path)
{
    800044aa:	1101                	addi	sp,sp,-32
    800044ac:	ec06                	sd	ra,24(sp)
    800044ae:	e822                	sd	s0,16(sp)
    800044b0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800044b2:	fe040613          	addi	a2,s0,-32
    800044b6:	4581                	li	a1,0
    800044b8:	00000097          	auipc	ra,0x0
    800044bc:	dd0080e7          	jalr	-560(ra) # 80004288 <namex>
}
    800044c0:	60e2                	ld	ra,24(sp)
    800044c2:	6442                	ld	s0,16(sp)
    800044c4:	6105                	addi	sp,sp,32
    800044c6:	8082                	ret

00000000800044c8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044c8:	1141                	addi	sp,sp,-16
    800044ca:	e406                	sd	ra,8(sp)
    800044cc:	e022                	sd	s0,0(sp)
    800044ce:	0800                	addi	s0,sp,16
    800044d0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044d2:	4585                	li	a1,1
    800044d4:	00000097          	auipc	ra,0x0
    800044d8:	db4080e7          	jalr	-588(ra) # 80004288 <namex>
}
    800044dc:	60a2                	ld	ra,8(sp)
    800044de:	6402                	ld	s0,0(sp)
    800044e0:	0141                	addi	sp,sp,16
    800044e2:	8082                	ret

00000000800044e4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044e4:	1101                	addi	sp,sp,-32
    800044e6:	ec06                	sd	ra,24(sp)
    800044e8:	e822                	sd	s0,16(sp)
    800044ea:	e426                	sd	s1,8(sp)
    800044ec:	e04a                	sd	s2,0(sp)
    800044ee:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044f0:	00023917          	auipc	s2,0x23
    800044f4:	58090913          	addi	s2,s2,1408 # 80027a70 <log>
    800044f8:	01892583          	lw	a1,24(s2)
    800044fc:	02892503          	lw	a0,40(s2)
    80004500:	fffff097          	auipc	ra,0xfffff
    80004504:	ff0080e7          	jalr	-16(ra) # 800034f0 <bread>
    80004508:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000450a:	02c92683          	lw	a3,44(s2)
    8000450e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004510:	02d05863          	blez	a3,80004540 <write_head+0x5c>
    80004514:	00023797          	auipc	a5,0x23
    80004518:	58c78793          	addi	a5,a5,1420 # 80027aa0 <log+0x30>
    8000451c:	05c50713          	addi	a4,a0,92
    80004520:	36fd                	addiw	a3,a3,-1
    80004522:	02069613          	slli	a2,a3,0x20
    80004526:	01e65693          	srli	a3,a2,0x1e
    8000452a:	00023617          	auipc	a2,0x23
    8000452e:	57a60613          	addi	a2,a2,1402 # 80027aa4 <log+0x34>
    80004532:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004534:	4390                	lw	a2,0(a5)
    80004536:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004538:	0791                	addi	a5,a5,4
    8000453a:	0711                	addi	a4,a4,4
    8000453c:	fed79ce3          	bne	a5,a3,80004534 <write_head+0x50>
  }
  bwrite(buf);
    80004540:	8526                	mv	a0,s1
    80004542:	fffff097          	auipc	ra,0xfffff
    80004546:	0a0080e7          	jalr	160(ra) # 800035e2 <bwrite>
  brelse(buf);
    8000454a:	8526                	mv	a0,s1
    8000454c:	fffff097          	auipc	ra,0xfffff
    80004550:	0d4080e7          	jalr	212(ra) # 80003620 <brelse>
}
    80004554:	60e2                	ld	ra,24(sp)
    80004556:	6442                	ld	s0,16(sp)
    80004558:	64a2                	ld	s1,8(sp)
    8000455a:	6902                	ld	s2,0(sp)
    8000455c:	6105                	addi	sp,sp,32
    8000455e:	8082                	ret

0000000080004560 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004560:	00023797          	auipc	a5,0x23
    80004564:	53c7a783          	lw	a5,1340(a5) # 80027a9c <log+0x2c>
    80004568:	0af05d63          	blez	a5,80004622 <install_trans+0xc2>
{
    8000456c:	7139                	addi	sp,sp,-64
    8000456e:	fc06                	sd	ra,56(sp)
    80004570:	f822                	sd	s0,48(sp)
    80004572:	f426                	sd	s1,40(sp)
    80004574:	f04a                	sd	s2,32(sp)
    80004576:	ec4e                	sd	s3,24(sp)
    80004578:	e852                	sd	s4,16(sp)
    8000457a:	e456                	sd	s5,8(sp)
    8000457c:	e05a                	sd	s6,0(sp)
    8000457e:	0080                	addi	s0,sp,64
    80004580:	8b2a                	mv	s6,a0
    80004582:	00023a97          	auipc	s5,0x23
    80004586:	51ea8a93          	addi	s5,s5,1310 # 80027aa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000458a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000458c:	00023997          	auipc	s3,0x23
    80004590:	4e498993          	addi	s3,s3,1252 # 80027a70 <log>
    80004594:	a00d                	j	800045b6 <install_trans+0x56>
    brelse(lbuf);
    80004596:	854a                	mv	a0,s2
    80004598:	fffff097          	auipc	ra,0xfffff
    8000459c:	088080e7          	jalr	136(ra) # 80003620 <brelse>
    brelse(dbuf);
    800045a0:	8526                	mv	a0,s1
    800045a2:	fffff097          	auipc	ra,0xfffff
    800045a6:	07e080e7          	jalr	126(ra) # 80003620 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045aa:	2a05                	addiw	s4,s4,1
    800045ac:	0a91                	addi	s5,s5,4
    800045ae:	02c9a783          	lw	a5,44(s3)
    800045b2:	04fa5e63          	bge	s4,a5,8000460e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045b6:	0189a583          	lw	a1,24(s3)
    800045ba:	014585bb          	addw	a1,a1,s4
    800045be:	2585                	addiw	a1,a1,1
    800045c0:	0289a503          	lw	a0,40(s3)
    800045c4:	fffff097          	auipc	ra,0xfffff
    800045c8:	f2c080e7          	jalr	-212(ra) # 800034f0 <bread>
    800045cc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045ce:	000aa583          	lw	a1,0(s5)
    800045d2:	0289a503          	lw	a0,40(s3)
    800045d6:	fffff097          	auipc	ra,0xfffff
    800045da:	f1a080e7          	jalr	-230(ra) # 800034f0 <bread>
    800045de:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045e0:	40000613          	li	a2,1024
    800045e4:	05890593          	addi	a1,s2,88
    800045e8:	05850513          	addi	a0,a0,88
    800045ec:	ffffc097          	auipc	ra,0xffffc
    800045f0:	72e080e7          	jalr	1838(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    800045f4:	8526                	mv	a0,s1
    800045f6:	fffff097          	auipc	ra,0xfffff
    800045fa:	fec080e7          	jalr	-20(ra) # 800035e2 <bwrite>
    if(recovering == 0)
    800045fe:	f80b1ce3          	bnez	s6,80004596 <install_trans+0x36>
      bunpin(dbuf);
    80004602:	8526                	mv	a0,s1
    80004604:	fffff097          	auipc	ra,0xfffff
    80004608:	0f6080e7          	jalr	246(ra) # 800036fa <bunpin>
    8000460c:	b769                	j	80004596 <install_trans+0x36>
}
    8000460e:	70e2                	ld	ra,56(sp)
    80004610:	7442                	ld	s0,48(sp)
    80004612:	74a2                	ld	s1,40(sp)
    80004614:	7902                	ld	s2,32(sp)
    80004616:	69e2                	ld	s3,24(sp)
    80004618:	6a42                	ld	s4,16(sp)
    8000461a:	6aa2                	ld	s5,8(sp)
    8000461c:	6b02                	ld	s6,0(sp)
    8000461e:	6121                	addi	sp,sp,64
    80004620:	8082                	ret
    80004622:	8082                	ret

0000000080004624 <initlog>:
{
    80004624:	7179                	addi	sp,sp,-48
    80004626:	f406                	sd	ra,40(sp)
    80004628:	f022                	sd	s0,32(sp)
    8000462a:	ec26                	sd	s1,24(sp)
    8000462c:	e84a                	sd	s2,16(sp)
    8000462e:	e44e                	sd	s3,8(sp)
    80004630:	1800                	addi	s0,sp,48
    80004632:	892a                	mv	s2,a0
    80004634:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004636:	00023497          	auipc	s1,0x23
    8000463a:	43a48493          	addi	s1,s1,1082 # 80027a70 <log>
    8000463e:	00004597          	auipc	a1,0x4
    80004642:	04258593          	addi	a1,a1,66 # 80008680 <syscalls+0x1f0>
    80004646:	8526                	mv	a0,s1
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	4ea080e7          	jalr	1258(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004650:	0149a583          	lw	a1,20(s3)
    80004654:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004656:	0109a783          	lw	a5,16(s3)
    8000465a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000465c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004660:	854a                	mv	a0,s2
    80004662:	fffff097          	auipc	ra,0xfffff
    80004666:	e8e080e7          	jalr	-370(ra) # 800034f0 <bread>
  log.lh.n = lh->n;
    8000466a:	4d34                	lw	a3,88(a0)
    8000466c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000466e:	02d05663          	blez	a3,8000469a <initlog+0x76>
    80004672:	05c50793          	addi	a5,a0,92
    80004676:	00023717          	auipc	a4,0x23
    8000467a:	42a70713          	addi	a4,a4,1066 # 80027aa0 <log+0x30>
    8000467e:	36fd                	addiw	a3,a3,-1
    80004680:	02069613          	slli	a2,a3,0x20
    80004684:	01e65693          	srli	a3,a2,0x1e
    80004688:	06050613          	addi	a2,a0,96
    8000468c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000468e:	4390                	lw	a2,0(a5)
    80004690:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004692:	0791                	addi	a5,a5,4
    80004694:	0711                	addi	a4,a4,4
    80004696:	fed79ce3          	bne	a5,a3,8000468e <initlog+0x6a>
  brelse(buf);
    8000469a:	fffff097          	auipc	ra,0xfffff
    8000469e:	f86080e7          	jalr	-122(ra) # 80003620 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800046a2:	4505                	li	a0,1
    800046a4:	00000097          	auipc	ra,0x0
    800046a8:	ebc080e7          	jalr	-324(ra) # 80004560 <install_trans>
  log.lh.n = 0;
    800046ac:	00023797          	auipc	a5,0x23
    800046b0:	3e07a823          	sw	zero,1008(a5) # 80027a9c <log+0x2c>
  write_head(); // clear the log
    800046b4:	00000097          	auipc	ra,0x0
    800046b8:	e30080e7          	jalr	-464(ra) # 800044e4 <write_head>
}
    800046bc:	70a2                	ld	ra,40(sp)
    800046be:	7402                	ld	s0,32(sp)
    800046c0:	64e2                	ld	s1,24(sp)
    800046c2:	6942                	ld	s2,16(sp)
    800046c4:	69a2                	ld	s3,8(sp)
    800046c6:	6145                	addi	sp,sp,48
    800046c8:	8082                	ret

00000000800046ca <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800046ca:	1101                	addi	sp,sp,-32
    800046cc:	ec06                	sd	ra,24(sp)
    800046ce:	e822                	sd	s0,16(sp)
    800046d0:	e426                	sd	s1,8(sp)
    800046d2:	e04a                	sd	s2,0(sp)
    800046d4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800046d6:	00023517          	auipc	a0,0x23
    800046da:	39a50513          	addi	a0,a0,922 # 80027a70 <log>
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	4e4080e7          	jalr	1252(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    800046e6:	00023497          	auipc	s1,0x23
    800046ea:	38a48493          	addi	s1,s1,906 # 80027a70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046ee:	4979                	li	s2,30
    800046f0:	a039                	j	800046fe <begin_op+0x34>
      sleep(&log, &log.lock);
    800046f2:	85a6                	mv	a1,s1
    800046f4:	8526                	mv	a0,s1
    800046f6:	ffffe097          	auipc	ra,0xffffe
    800046fa:	a36080e7          	jalr	-1482(ra) # 8000212c <sleep>
    if(log.committing){
    800046fe:	50dc                	lw	a5,36(s1)
    80004700:	fbed                	bnez	a5,800046f2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004702:	509c                	lw	a5,32(s1)
    80004704:	0017871b          	addiw	a4,a5,1
    80004708:	0007069b          	sext.w	a3,a4
    8000470c:	0027179b          	slliw	a5,a4,0x2
    80004710:	9fb9                	addw	a5,a5,a4
    80004712:	0017979b          	slliw	a5,a5,0x1
    80004716:	54d8                	lw	a4,44(s1)
    80004718:	9fb9                	addw	a5,a5,a4
    8000471a:	00f95963          	bge	s2,a5,8000472c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000471e:	85a6                	mv	a1,s1
    80004720:	8526                	mv	a0,s1
    80004722:	ffffe097          	auipc	ra,0xffffe
    80004726:	a0a080e7          	jalr	-1526(ra) # 8000212c <sleep>
    8000472a:	bfd1                	j	800046fe <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000472c:	00023517          	auipc	a0,0x23
    80004730:	34450513          	addi	a0,a0,836 # 80027a70 <log>
    80004734:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004736:	ffffc097          	auipc	ra,0xffffc
    8000473a:	540080e7          	jalr	1344(ra) # 80000c76 <release>
      break;
    }
  }
}
    8000473e:	60e2                	ld	ra,24(sp)
    80004740:	6442                	ld	s0,16(sp)
    80004742:	64a2                	ld	s1,8(sp)
    80004744:	6902                	ld	s2,0(sp)
    80004746:	6105                	addi	sp,sp,32
    80004748:	8082                	ret

000000008000474a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000474a:	7139                	addi	sp,sp,-64
    8000474c:	fc06                	sd	ra,56(sp)
    8000474e:	f822                	sd	s0,48(sp)
    80004750:	f426                	sd	s1,40(sp)
    80004752:	f04a                	sd	s2,32(sp)
    80004754:	ec4e                	sd	s3,24(sp)
    80004756:	e852                	sd	s4,16(sp)
    80004758:	e456                	sd	s5,8(sp)
    8000475a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000475c:	00023497          	auipc	s1,0x23
    80004760:	31448493          	addi	s1,s1,788 # 80027a70 <log>
    80004764:	8526                	mv	a0,s1
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	45c080e7          	jalr	1116(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    8000476e:	509c                	lw	a5,32(s1)
    80004770:	37fd                	addiw	a5,a5,-1
    80004772:	0007891b          	sext.w	s2,a5
    80004776:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004778:	50dc                	lw	a5,36(s1)
    8000477a:	e7b9                	bnez	a5,800047c8 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000477c:	04091e63          	bnez	s2,800047d8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004780:	00023497          	auipc	s1,0x23
    80004784:	2f048493          	addi	s1,s1,752 # 80027a70 <log>
    80004788:	4785                	li	a5,1
    8000478a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000478c:	8526                	mv	a0,s1
    8000478e:	ffffc097          	auipc	ra,0xffffc
    80004792:	4e8080e7          	jalr	1256(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004796:	54dc                	lw	a5,44(s1)
    80004798:	06f04763          	bgtz	a5,80004806 <end_op+0xbc>
    acquire(&log.lock);
    8000479c:	00023497          	auipc	s1,0x23
    800047a0:	2d448493          	addi	s1,s1,724 # 80027a70 <log>
    800047a4:	8526                	mv	a0,s1
    800047a6:	ffffc097          	auipc	ra,0xffffc
    800047aa:	41c080e7          	jalr	1052(ra) # 80000bc2 <acquire>
    log.committing = 0;
    800047ae:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800047b2:	8526                	mv	a0,s1
    800047b4:	ffffe097          	auipc	ra,0xffffe
    800047b8:	b04080e7          	jalr	-1276(ra) # 800022b8 <wakeup>
    release(&log.lock);
    800047bc:	8526                	mv	a0,s1
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	4b8080e7          	jalr	1208(ra) # 80000c76 <release>
}
    800047c6:	a03d                	j	800047f4 <end_op+0xaa>
    panic("log.committing");
    800047c8:	00004517          	auipc	a0,0x4
    800047cc:	ec050513          	addi	a0,a0,-320 # 80008688 <syscalls+0x1f8>
    800047d0:	ffffc097          	auipc	ra,0xffffc
    800047d4:	d5a080e7          	jalr	-678(ra) # 8000052a <panic>
    wakeup(&log);
    800047d8:	00023497          	auipc	s1,0x23
    800047dc:	29848493          	addi	s1,s1,664 # 80027a70 <log>
    800047e0:	8526                	mv	a0,s1
    800047e2:	ffffe097          	auipc	ra,0xffffe
    800047e6:	ad6080e7          	jalr	-1322(ra) # 800022b8 <wakeup>
  release(&log.lock);
    800047ea:	8526                	mv	a0,s1
    800047ec:	ffffc097          	auipc	ra,0xffffc
    800047f0:	48a080e7          	jalr	1162(ra) # 80000c76 <release>
}
    800047f4:	70e2                	ld	ra,56(sp)
    800047f6:	7442                	ld	s0,48(sp)
    800047f8:	74a2                	ld	s1,40(sp)
    800047fa:	7902                	ld	s2,32(sp)
    800047fc:	69e2                	ld	s3,24(sp)
    800047fe:	6a42                	ld	s4,16(sp)
    80004800:	6aa2                	ld	s5,8(sp)
    80004802:	6121                	addi	sp,sp,64
    80004804:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004806:	00023a97          	auipc	s5,0x23
    8000480a:	29aa8a93          	addi	s5,s5,666 # 80027aa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000480e:	00023a17          	auipc	s4,0x23
    80004812:	262a0a13          	addi	s4,s4,610 # 80027a70 <log>
    80004816:	018a2583          	lw	a1,24(s4)
    8000481a:	012585bb          	addw	a1,a1,s2
    8000481e:	2585                	addiw	a1,a1,1
    80004820:	028a2503          	lw	a0,40(s4)
    80004824:	fffff097          	auipc	ra,0xfffff
    80004828:	ccc080e7          	jalr	-820(ra) # 800034f0 <bread>
    8000482c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000482e:	000aa583          	lw	a1,0(s5)
    80004832:	028a2503          	lw	a0,40(s4)
    80004836:	fffff097          	auipc	ra,0xfffff
    8000483a:	cba080e7          	jalr	-838(ra) # 800034f0 <bread>
    8000483e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004840:	40000613          	li	a2,1024
    80004844:	05850593          	addi	a1,a0,88
    80004848:	05848513          	addi	a0,s1,88
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	4ce080e7          	jalr	1230(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004854:	8526                	mv	a0,s1
    80004856:	fffff097          	auipc	ra,0xfffff
    8000485a:	d8c080e7          	jalr	-628(ra) # 800035e2 <bwrite>
    brelse(from);
    8000485e:	854e                	mv	a0,s3
    80004860:	fffff097          	auipc	ra,0xfffff
    80004864:	dc0080e7          	jalr	-576(ra) # 80003620 <brelse>
    brelse(to);
    80004868:	8526                	mv	a0,s1
    8000486a:	fffff097          	auipc	ra,0xfffff
    8000486e:	db6080e7          	jalr	-586(ra) # 80003620 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004872:	2905                	addiw	s2,s2,1
    80004874:	0a91                	addi	s5,s5,4
    80004876:	02ca2783          	lw	a5,44(s4)
    8000487a:	f8f94ee3          	blt	s2,a5,80004816 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000487e:	00000097          	auipc	ra,0x0
    80004882:	c66080e7          	jalr	-922(ra) # 800044e4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004886:	4501                	li	a0,0
    80004888:	00000097          	auipc	ra,0x0
    8000488c:	cd8080e7          	jalr	-808(ra) # 80004560 <install_trans>
    log.lh.n = 0;
    80004890:	00023797          	auipc	a5,0x23
    80004894:	2007a623          	sw	zero,524(a5) # 80027a9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004898:	00000097          	auipc	ra,0x0
    8000489c:	c4c080e7          	jalr	-948(ra) # 800044e4 <write_head>
    800048a0:	bdf5                	j	8000479c <end_op+0x52>

00000000800048a2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800048a2:	1101                	addi	sp,sp,-32
    800048a4:	ec06                	sd	ra,24(sp)
    800048a6:	e822                	sd	s0,16(sp)
    800048a8:	e426                	sd	s1,8(sp)
    800048aa:	e04a                	sd	s2,0(sp)
    800048ac:	1000                	addi	s0,sp,32
    800048ae:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800048b0:	00023917          	auipc	s2,0x23
    800048b4:	1c090913          	addi	s2,s2,448 # 80027a70 <log>
    800048b8:	854a                	mv	a0,s2
    800048ba:	ffffc097          	auipc	ra,0xffffc
    800048be:	308080e7          	jalr	776(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800048c2:	02c92603          	lw	a2,44(s2)
    800048c6:	47f5                	li	a5,29
    800048c8:	06c7c563          	blt	a5,a2,80004932 <log_write+0x90>
    800048cc:	00023797          	auipc	a5,0x23
    800048d0:	1c07a783          	lw	a5,448(a5) # 80027a8c <log+0x1c>
    800048d4:	37fd                	addiw	a5,a5,-1
    800048d6:	04f65e63          	bge	a2,a5,80004932 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800048da:	00023797          	auipc	a5,0x23
    800048de:	1b67a783          	lw	a5,438(a5) # 80027a90 <log+0x20>
    800048e2:	06f05063          	blez	a5,80004942 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048e6:	4781                	li	a5,0
    800048e8:	06c05563          	blez	a2,80004952 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048ec:	44cc                	lw	a1,12(s1)
    800048ee:	00023717          	auipc	a4,0x23
    800048f2:	1b270713          	addi	a4,a4,434 # 80027aa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048f6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048f8:	4314                	lw	a3,0(a4)
    800048fa:	04b68c63          	beq	a3,a1,80004952 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800048fe:	2785                	addiw	a5,a5,1
    80004900:	0711                	addi	a4,a4,4
    80004902:	fef61be3          	bne	a2,a5,800048f8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004906:	0621                	addi	a2,a2,8
    80004908:	060a                	slli	a2,a2,0x2
    8000490a:	00023797          	auipc	a5,0x23
    8000490e:	16678793          	addi	a5,a5,358 # 80027a70 <log>
    80004912:	963e                	add	a2,a2,a5
    80004914:	44dc                	lw	a5,12(s1)
    80004916:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004918:	8526                	mv	a0,s1
    8000491a:	fffff097          	auipc	ra,0xfffff
    8000491e:	da4080e7          	jalr	-604(ra) # 800036be <bpin>
    log.lh.n++;
    80004922:	00023717          	auipc	a4,0x23
    80004926:	14e70713          	addi	a4,a4,334 # 80027a70 <log>
    8000492a:	575c                	lw	a5,44(a4)
    8000492c:	2785                	addiw	a5,a5,1
    8000492e:	d75c                	sw	a5,44(a4)
    80004930:	a835                	j	8000496c <log_write+0xca>
    panic("too big a transaction");
    80004932:	00004517          	auipc	a0,0x4
    80004936:	d6650513          	addi	a0,a0,-666 # 80008698 <syscalls+0x208>
    8000493a:	ffffc097          	auipc	ra,0xffffc
    8000493e:	bf0080e7          	jalr	-1040(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004942:	00004517          	auipc	a0,0x4
    80004946:	d6e50513          	addi	a0,a0,-658 # 800086b0 <syscalls+0x220>
    8000494a:	ffffc097          	auipc	ra,0xffffc
    8000494e:	be0080e7          	jalr	-1056(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004952:	00878713          	addi	a4,a5,8
    80004956:	00271693          	slli	a3,a4,0x2
    8000495a:	00023717          	auipc	a4,0x23
    8000495e:	11670713          	addi	a4,a4,278 # 80027a70 <log>
    80004962:	9736                	add	a4,a4,a3
    80004964:	44d4                	lw	a3,12(s1)
    80004966:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004968:	faf608e3          	beq	a2,a5,80004918 <log_write+0x76>
  }
  release(&log.lock);
    8000496c:	00023517          	auipc	a0,0x23
    80004970:	10450513          	addi	a0,a0,260 # 80027a70 <log>
    80004974:	ffffc097          	auipc	ra,0xffffc
    80004978:	302080e7          	jalr	770(ra) # 80000c76 <release>
}
    8000497c:	60e2                	ld	ra,24(sp)
    8000497e:	6442                	ld	s0,16(sp)
    80004980:	64a2                	ld	s1,8(sp)
    80004982:	6902                	ld	s2,0(sp)
    80004984:	6105                	addi	sp,sp,32
    80004986:	8082                	ret

0000000080004988 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004988:	1101                	addi	sp,sp,-32
    8000498a:	ec06                	sd	ra,24(sp)
    8000498c:	e822                	sd	s0,16(sp)
    8000498e:	e426                	sd	s1,8(sp)
    80004990:	e04a                	sd	s2,0(sp)
    80004992:	1000                	addi	s0,sp,32
    80004994:	84aa                	mv	s1,a0
    80004996:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004998:	00004597          	auipc	a1,0x4
    8000499c:	d3858593          	addi	a1,a1,-712 # 800086d0 <syscalls+0x240>
    800049a0:	0521                	addi	a0,a0,8
    800049a2:	ffffc097          	auipc	ra,0xffffc
    800049a6:	190080e7          	jalr	400(ra) # 80000b32 <initlock>
  lk->name = name;
    800049aa:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800049ae:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049b2:	0204a423          	sw	zero,40(s1)
}
    800049b6:	60e2                	ld	ra,24(sp)
    800049b8:	6442                	ld	s0,16(sp)
    800049ba:	64a2                	ld	s1,8(sp)
    800049bc:	6902                	ld	s2,0(sp)
    800049be:	6105                	addi	sp,sp,32
    800049c0:	8082                	ret

00000000800049c2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049c2:	1101                	addi	sp,sp,-32
    800049c4:	ec06                	sd	ra,24(sp)
    800049c6:	e822                	sd	s0,16(sp)
    800049c8:	e426                	sd	s1,8(sp)
    800049ca:	e04a                	sd	s2,0(sp)
    800049cc:	1000                	addi	s0,sp,32
    800049ce:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049d0:	00850913          	addi	s2,a0,8
    800049d4:	854a                	mv	a0,s2
    800049d6:	ffffc097          	auipc	ra,0xffffc
    800049da:	1ec080e7          	jalr	492(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    800049de:	409c                	lw	a5,0(s1)
    800049e0:	cb89                	beqz	a5,800049f2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049e2:	85ca                	mv	a1,s2
    800049e4:	8526                	mv	a0,s1
    800049e6:	ffffd097          	auipc	ra,0xffffd
    800049ea:	746080e7          	jalr	1862(ra) # 8000212c <sleep>
  while (lk->locked) {
    800049ee:	409c                	lw	a5,0(s1)
    800049f0:	fbed                	bnez	a5,800049e2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049f2:	4785                	li	a5,1
    800049f4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049f6:	ffffd097          	auipc	ra,0xffffd
    800049fa:	fbe080e7          	jalr	-66(ra) # 800019b4 <myproc>
    800049fe:	591c                	lw	a5,48(a0)
    80004a00:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a02:	854a                	mv	a0,s2
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	272080e7          	jalr	626(ra) # 80000c76 <release>
}
    80004a0c:	60e2                	ld	ra,24(sp)
    80004a0e:	6442                	ld	s0,16(sp)
    80004a10:	64a2                	ld	s1,8(sp)
    80004a12:	6902                	ld	s2,0(sp)
    80004a14:	6105                	addi	sp,sp,32
    80004a16:	8082                	ret

0000000080004a18 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a18:	1101                	addi	sp,sp,-32
    80004a1a:	ec06                	sd	ra,24(sp)
    80004a1c:	e822                	sd	s0,16(sp)
    80004a1e:	e426                	sd	s1,8(sp)
    80004a20:	e04a                	sd	s2,0(sp)
    80004a22:	1000                	addi	s0,sp,32
    80004a24:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a26:	00850913          	addi	s2,a0,8
    80004a2a:	854a                	mv	a0,s2
    80004a2c:	ffffc097          	auipc	ra,0xffffc
    80004a30:	196080e7          	jalr	406(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80004a34:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a38:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a3c:	8526                	mv	a0,s1
    80004a3e:	ffffe097          	auipc	ra,0xffffe
    80004a42:	87a080e7          	jalr	-1926(ra) # 800022b8 <wakeup>
  release(&lk->lk);
    80004a46:	854a                	mv	a0,s2
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	22e080e7          	jalr	558(ra) # 80000c76 <release>
}
    80004a50:	60e2                	ld	ra,24(sp)
    80004a52:	6442                	ld	s0,16(sp)
    80004a54:	64a2                	ld	s1,8(sp)
    80004a56:	6902                	ld	s2,0(sp)
    80004a58:	6105                	addi	sp,sp,32
    80004a5a:	8082                	ret

0000000080004a5c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a5c:	7179                	addi	sp,sp,-48
    80004a5e:	f406                	sd	ra,40(sp)
    80004a60:	f022                	sd	s0,32(sp)
    80004a62:	ec26                	sd	s1,24(sp)
    80004a64:	e84a                	sd	s2,16(sp)
    80004a66:	e44e                	sd	s3,8(sp)
    80004a68:	1800                	addi	s0,sp,48
    80004a6a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a6c:	00850913          	addi	s2,a0,8
    80004a70:	854a                	mv	a0,s2
    80004a72:	ffffc097          	auipc	ra,0xffffc
    80004a76:	150080e7          	jalr	336(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a7a:	409c                	lw	a5,0(s1)
    80004a7c:	ef99                	bnez	a5,80004a9a <holdingsleep+0x3e>
    80004a7e:	4481                	li	s1,0
  release(&lk->lk);
    80004a80:	854a                	mv	a0,s2
    80004a82:	ffffc097          	auipc	ra,0xffffc
    80004a86:	1f4080e7          	jalr	500(ra) # 80000c76 <release>
  return r;
}
    80004a8a:	8526                	mv	a0,s1
    80004a8c:	70a2                	ld	ra,40(sp)
    80004a8e:	7402                	ld	s0,32(sp)
    80004a90:	64e2                	ld	s1,24(sp)
    80004a92:	6942                	ld	s2,16(sp)
    80004a94:	69a2                	ld	s3,8(sp)
    80004a96:	6145                	addi	sp,sp,48
    80004a98:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a9a:	0284a983          	lw	s3,40(s1)
    80004a9e:	ffffd097          	auipc	ra,0xffffd
    80004aa2:	f16080e7          	jalr	-234(ra) # 800019b4 <myproc>
    80004aa6:	5904                	lw	s1,48(a0)
    80004aa8:	413484b3          	sub	s1,s1,s3
    80004aac:	0014b493          	seqz	s1,s1
    80004ab0:	bfc1                	j	80004a80 <holdingsleep+0x24>

0000000080004ab2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004ab2:	1141                	addi	sp,sp,-16
    80004ab4:	e406                	sd	ra,8(sp)
    80004ab6:	e022                	sd	s0,0(sp)
    80004ab8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004aba:	00004597          	auipc	a1,0x4
    80004abe:	c2658593          	addi	a1,a1,-986 # 800086e0 <syscalls+0x250>
    80004ac2:	00023517          	auipc	a0,0x23
    80004ac6:	0f650513          	addi	a0,a0,246 # 80027bb8 <ftable>
    80004aca:	ffffc097          	auipc	ra,0xffffc
    80004ace:	068080e7          	jalr	104(ra) # 80000b32 <initlock>
}
    80004ad2:	60a2                	ld	ra,8(sp)
    80004ad4:	6402                	ld	s0,0(sp)
    80004ad6:	0141                	addi	sp,sp,16
    80004ad8:	8082                	ret

0000000080004ada <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004ada:	1101                	addi	sp,sp,-32
    80004adc:	ec06                	sd	ra,24(sp)
    80004ade:	e822                	sd	s0,16(sp)
    80004ae0:	e426                	sd	s1,8(sp)
    80004ae2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ae4:	00023517          	auipc	a0,0x23
    80004ae8:	0d450513          	addi	a0,a0,212 # 80027bb8 <ftable>
    80004aec:	ffffc097          	auipc	ra,0xffffc
    80004af0:	0d6080e7          	jalr	214(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004af4:	00023497          	auipc	s1,0x23
    80004af8:	0dc48493          	addi	s1,s1,220 # 80027bd0 <ftable+0x18>
    80004afc:	00024717          	auipc	a4,0x24
    80004b00:	07470713          	addi	a4,a4,116 # 80028b70 <ftable+0xfb8>
    if(f->ref == 0){
    80004b04:	40dc                	lw	a5,4(s1)
    80004b06:	cf99                	beqz	a5,80004b24 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b08:	02848493          	addi	s1,s1,40
    80004b0c:	fee49ce3          	bne	s1,a4,80004b04 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b10:	00023517          	auipc	a0,0x23
    80004b14:	0a850513          	addi	a0,a0,168 # 80027bb8 <ftable>
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	15e080e7          	jalr	350(ra) # 80000c76 <release>
  return 0;
    80004b20:	4481                	li	s1,0
    80004b22:	a819                	j	80004b38 <filealloc+0x5e>
      f->ref = 1;
    80004b24:	4785                	li	a5,1
    80004b26:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b28:	00023517          	auipc	a0,0x23
    80004b2c:	09050513          	addi	a0,a0,144 # 80027bb8 <ftable>
    80004b30:	ffffc097          	auipc	ra,0xffffc
    80004b34:	146080e7          	jalr	326(ra) # 80000c76 <release>
}
    80004b38:	8526                	mv	a0,s1
    80004b3a:	60e2                	ld	ra,24(sp)
    80004b3c:	6442                	ld	s0,16(sp)
    80004b3e:	64a2                	ld	s1,8(sp)
    80004b40:	6105                	addi	sp,sp,32
    80004b42:	8082                	ret

0000000080004b44 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b44:	1101                	addi	sp,sp,-32
    80004b46:	ec06                	sd	ra,24(sp)
    80004b48:	e822                	sd	s0,16(sp)
    80004b4a:	e426                	sd	s1,8(sp)
    80004b4c:	1000                	addi	s0,sp,32
    80004b4e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b50:	00023517          	auipc	a0,0x23
    80004b54:	06850513          	addi	a0,a0,104 # 80027bb8 <ftable>
    80004b58:	ffffc097          	auipc	ra,0xffffc
    80004b5c:	06a080e7          	jalr	106(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b60:	40dc                	lw	a5,4(s1)
    80004b62:	02f05263          	blez	a5,80004b86 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b66:	2785                	addiw	a5,a5,1
    80004b68:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b6a:	00023517          	auipc	a0,0x23
    80004b6e:	04e50513          	addi	a0,a0,78 # 80027bb8 <ftable>
    80004b72:	ffffc097          	auipc	ra,0xffffc
    80004b76:	104080e7          	jalr	260(ra) # 80000c76 <release>
  return f;
}
    80004b7a:	8526                	mv	a0,s1
    80004b7c:	60e2                	ld	ra,24(sp)
    80004b7e:	6442                	ld	s0,16(sp)
    80004b80:	64a2                	ld	s1,8(sp)
    80004b82:	6105                	addi	sp,sp,32
    80004b84:	8082                	ret
    panic("filedup");
    80004b86:	00004517          	auipc	a0,0x4
    80004b8a:	b6250513          	addi	a0,a0,-1182 # 800086e8 <syscalls+0x258>
    80004b8e:	ffffc097          	auipc	ra,0xffffc
    80004b92:	99c080e7          	jalr	-1636(ra) # 8000052a <panic>

0000000080004b96 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b96:	7139                	addi	sp,sp,-64
    80004b98:	fc06                	sd	ra,56(sp)
    80004b9a:	f822                	sd	s0,48(sp)
    80004b9c:	f426                	sd	s1,40(sp)
    80004b9e:	f04a                	sd	s2,32(sp)
    80004ba0:	ec4e                	sd	s3,24(sp)
    80004ba2:	e852                	sd	s4,16(sp)
    80004ba4:	e456                	sd	s5,8(sp)
    80004ba6:	0080                	addi	s0,sp,64
    80004ba8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004baa:	00023517          	auipc	a0,0x23
    80004bae:	00e50513          	addi	a0,a0,14 # 80027bb8 <ftable>
    80004bb2:	ffffc097          	auipc	ra,0xffffc
    80004bb6:	010080e7          	jalr	16(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004bba:	40dc                	lw	a5,4(s1)
    80004bbc:	06f05163          	blez	a5,80004c1e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004bc0:	37fd                	addiw	a5,a5,-1
    80004bc2:	0007871b          	sext.w	a4,a5
    80004bc6:	c0dc                	sw	a5,4(s1)
    80004bc8:	06e04363          	bgtz	a4,80004c2e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004bcc:	0004a903          	lw	s2,0(s1)
    80004bd0:	0094ca83          	lbu	s5,9(s1)
    80004bd4:	0104ba03          	ld	s4,16(s1)
    80004bd8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004bdc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004be0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004be4:	00023517          	auipc	a0,0x23
    80004be8:	fd450513          	addi	a0,a0,-44 # 80027bb8 <ftable>
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	08a080e7          	jalr	138(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004bf4:	4785                	li	a5,1
    80004bf6:	04f90d63          	beq	s2,a5,80004c50 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004bfa:	3979                	addiw	s2,s2,-2
    80004bfc:	4785                	li	a5,1
    80004bfe:	0527e063          	bltu	a5,s2,80004c3e <fileclose+0xa8>
    begin_op();
    80004c02:	00000097          	auipc	ra,0x0
    80004c06:	ac8080e7          	jalr	-1336(ra) # 800046ca <begin_op>
    iput(ff.ip);
    80004c0a:	854e                	mv	a0,s3
    80004c0c:	fffff097          	auipc	ra,0xfffff
    80004c10:	2a2080e7          	jalr	674(ra) # 80003eae <iput>
    end_op();
    80004c14:	00000097          	auipc	ra,0x0
    80004c18:	b36080e7          	jalr	-1226(ra) # 8000474a <end_op>
    80004c1c:	a00d                	j	80004c3e <fileclose+0xa8>
    panic("fileclose");
    80004c1e:	00004517          	auipc	a0,0x4
    80004c22:	ad250513          	addi	a0,a0,-1326 # 800086f0 <syscalls+0x260>
    80004c26:	ffffc097          	auipc	ra,0xffffc
    80004c2a:	904080e7          	jalr	-1788(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004c2e:	00023517          	auipc	a0,0x23
    80004c32:	f8a50513          	addi	a0,a0,-118 # 80027bb8 <ftable>
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	040080e7          	jalr	64(ra) # 80000c76 <release>
  }
}
    80004c3e:	70e2                	ld	ra,56(sp)
    80004c40:	7442                	ld	s0,48(sp)
    80004c42:	74a2                	ld	s1,40(sp)
    80004c44:	7902                	ld	s2,32(sp)
    80004c46:	69e2                	ld	s3,24(sp)
    80004c48:	6a42                	ld	s4,16(sp)
    80004c4a:	6aa2                	ld	s5,8(sp)
    80004c4c:	6121                	addi	sp,sp,64
    80004c4e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c50:	85d6                	mv	a1,s5
    80004c52:	8552                	mv	a0,s4
    80004c54:	00000097          	auipc	ra,0x0
    80004c58:	34c080e7          	jalr	844(ra) # 80004fa0 <pipeclose>
    80004c5c:	b7cd                	j	80004c3e <fileclose+0xa8>

0000000080004c5e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c5e:	715d                	addi	sp,sp,-80
    80004c60:	e486                	sd	ra,72(sp)
    80004c62:	e0a2                	sd	s0,64(sp)
    80004c64:	fc26                	sd	s1,56(sp)
    80004c66:	f84a                	sd	s2,48(sp)
    80004c68:	f44e                	sd	s3,40(sp)
    80004c6a:	0880                	addi	s0,sp,80
    80004c6c:	84aa                	mv	s1,a0
    80004c6e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c70:	ffffd097          	auipc	ra,0xffffd
    80004c74:	d44080e7          	jalr	-700(ra) # 800019b4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c78:	409c                	lw	a5,0(s1)
    80004c7a:	37f9                	addiw	a5,a5,-2
    80004c7c:	4705                	li	a4,1
    80004c7e:	04f76763          	bltu	a4,a5,80004ccc <filestat+0x6e>
    80004c82:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c84:	6c88                	ld	a0,24(s1)
    80004c86:	fffff097          	auipc	ra,0xfffff
    80004c8a:	06e080e7          	jalr	110(ra) # 80003cf4 <ilock>
    stati(f->ip, &st);
    80004c8e:	fb840593          	addi	a1,s0,-72
    80004c92:	6c88                	ld	a0,24(s1)
    80004c94:	fffff097          	auipc	ra,0xfffff
    80004c98:	2ea080e7          	jalr	746(ra) # 80003f7e <stati>
    iunlock(f->ip);
    80004c9c:	6c88                	ld	a0,24(s1)
    80004c9e:	fffff097          	auipc	ra,0xfffff
    80004ca2:	118080e7          	jalr	280(ra) # 80003db6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ca6:	46e1                	li	a3,24
    80004ca8:	fb840613          	addi	a2,s0,-72
    80004cac:	85ce                	mv	a1,s3
    80004cae:	05093503          	ld	a0,80(s2)
    80004cb2:	ffffd097          	auipc	ra,0xffffd
    80004cb6:	98c080e7          	jalr	-1652(ra) # 8000163e <copyout>
    80004cba:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004cbe:	60a6                	ld	ra,72(sp)
    80004cc0:	6406                	ld	s0,64(sp)
    80004cc2:	74e2                	ld	s1,56(sp)
    80004cc4:	7942                	ld	s2,48(sp)
    80004cc6:	79a2                	ld	s3,40(sp)
    80004cc8:	6161                	addi	sp,sp,80
    80004cca:	8082                	ret
  return -1;
    80004ccc:	557d                	li	a0,-1
    80004cce:	bfc5                	j	80004cbe <filestat+0x60>

0000000080004cd0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004cd0:	7179                	addi	sp,sp,-48
    80004cd2:	f406                	sd	ra,40(sp)
    80004cd4:	f022                	sd	s0,32(sp)
    80004cd6:	ec26                	sd	s1,24(sp)
    80004cd8:	e84a                	sd	s2,16(sp)
    80004cda:	e44e                	sd	s3,8(sp)
    80004cdc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004cde:	00854783          	lbu	a5,8(a0)
    80004ce2:	c3d5                	beqz	a5,80004d86 <fileread+0xb6>
    80004ce4:	84aa                	mv	s1,a0
    80004ce6:	89ae                	mv	s3,a1
    80004ce8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cea:	411c                	lw	a5,0(a0)
    80004cec:	4705                	li	a4,1
    80004cee:	04e78963          	beq	a5,a4,80004d40 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cf2:	470d                	li	a4,3
    80004cf4:	04e78d63          	beq	a5,a4,80004d4e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cf8:	4709                	li	a4,2
    80004cfa:	06e79e63          	bne	a5,a4,80004d76 <fileread+0xa6>
    ilock(f->ip);
    80004cfe:	6d08                	ld	a0,24(a0)
    80004d00:	fffff097          	auipc	ra,0xfffff
    80004d04:	ff4080e7          	jalr	-12(ra) # 80003cf4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d08:	874a                	mv	a4,s2
    80004d0a:	5094                	lw	a3,32(s1)
    80004d0c:	864e                	mv	a2,s3
    80004d0e:	4585                	li	a1,1
    80004d10:	6c88                	ld	a0,24(s1)
    80004d12:	fffff097          	auipc	ra,0xfffff
    80004d16:	296080e7          	jalr	662(ra) # 80003fa8 <readi>
    80004d1a:	892a                	mv	s2,a0
    80004d1c:	00a05563          	blez	a0,80004d26 <fileread+0x56>
      f->off += r;
    80004d20:	509c                	lw	a5,32(s1)
    80004d22:	9fa9                	addw	a5,a5,a0
    80004d24:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d26:	6c88                	ld	a0,24(s1)
    80004d28:	fffff097          	auipc	ra,0xfffff
    80004d2c:	08e080e7          	jalr	142(ra) # 80003db6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d30:	854a                	mv	a0,s2
    80004d32:	70a2                	ld	ra,40(sp)
    80004d34:	7402                	ld	s0,32(sp)
    80004d36:	64e2                	ld	s1,24(sp)
    80004d38:	6942                	ld	s2,16(sp)
    80004d3a:	69a2                	ld	s3,8(sp)
    80004d3c:	6145                	addi	sp,sp,48
    80004d3e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d40:	6908                	ld	a0,16(a0)
    80004d42:	00000097          	auipc	ra,0x0
    80004d46:	3c0080e7          	jalr	960(ra) # 80005102 <piperead>
    80004d4a:	892a                	mv	s2,a0
    80004d4c:	b7d5                	j	80004d30 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d4e:	02451783          	lh	a5,36(a0)
    80004d52:	03079693          	slli	a3,a5,0x30
    80004d56:	92c1                	srli	a3,a3,0x30
    80004d58:	4725                	li	a4,9
    80004d5a:	02d76863          	bltu	a4,a3,80004d8a <fileread+0xba>
    80004d5e:	0792                	slli	a5,a5,0x4
    80004d60:	00023717          	auipc	a4,0x23
    80004d64:	db870713          	addi	a4,a4,-584 # 80027b18 <devsw>
    80004d68:	97ba                	add	a5,a5,a4
    80004d6a:	639c                	ld	a5,0(a5)
    80004d6c:	c38d                	beqz	a5,80004d8e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d6e:	4505                	li	a0,1
    80004d70:	9782                	jalr	a5
    80004d72:	892a                	mv	s2,a0
    80004d74:	bf75                	j	80004d30 <fileread+0x60>
    panic("fileread");
    80004d76:	00004517          	auipc	a0,0x4
    80004d7a:	98a50513          	addi	a0,a0,-1654 # 80008700 <syscalls+0x270>
    80004d7e:	ffffb097          	auipc	ra,0xffffb
    80004d82:	7ac080e7          	jalr	1964(ra) # 8000052a <panic>
    return -1;
    80004d86:	597d                	li	s2,-1
    80004d88:	b765                	j	80004d30 <fileread+0x60>
      return -1;
    80004d8a:	597d                	li	s2,-1
    80004d8c:	b755                	j	80004d30 <fileread+0x60>
    80004d8e:	597d                	li	s2,-1
    80004d90:	b745                	j	80004d30 <fileread+0x60>

0000000080004d92 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d92:	715d                	addi	sp,sp,-80
    80004d94:	e486                	sd	ra,72(sp)
    80004d96:	e0a2                	sd	s0,64(sp)
    80004d98:	fc26                	sd	s1,56(sp)
    80004d9a:	f84a                	sd	s2,48(sp)
    80004d9c:	f44e                	sd	s3,40(sp)
    80004d9e:	f052                	sd	s4,32(sp)
    80004da0:	ec56                	sd	s5,24(sp)
    80004da2:	e85a                	sd	s6,16(sp)
    80004da4:	e45e                	sd	s7,8(sp)
    80004da6:	e062                	sd	s8,0(sp)
    80004da8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004daa:	00954783          	lbu	a5,9(a0)
    80004dae:	10078663          	beqz	a5,80004eba <filewrite+0x128>
    80004db2:	892a                	mv	s2,a0
    80004db4:	8aae                	mv	s5,a1
    80004db6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004db8:	411c                	lw	a5,0(a0)
    80004dba:	4705                	li	a4,1
    80004dbc:	02e78263          	beq	a5,a4,80004de0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dc0:	470d                	li	a4,3
    80004dc2:	02e78663          	beq	a5,a4,80004dee <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dc6:	4709                	li	a4,2
    80004dc8:	0ee79163          	bne	a5,a4,80004eaa <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004dcc:	0ac05d63          	blez	a2,80004e86 <filewrite+0xf4>
    int i = 0;
    80004dd0:	4981                	li	s3,0
    80004dd2:	6b05                	lui	s6,0x1
    80004dd4:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004dd8:	6b85                	lui	s7,0x1
    80004dda:	c00b8b9b          	addiw	s7,s7,-1024
    80004dde:	a861                	j	80004e76 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004de0:	6908                	ld	a0,16(a0)
    80004de2:	00000097          	auipc	ra,0x0
    80004de6:	22e080e7          	jalr	558(ra) # 80005010 <pipewrite>
    80004dea:	8a2a                	mv	s4,a0
    80004dec:	a045                	j	80004e8c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004dee:	02451783          	lh	a5,36(a0)
    80004df2:	03079693          	slli	a3,a5,0x30
    80004df6:	92c1                	srli	a3,a3,0x30
    80004df8:	4725                	li	a4,9
    80004dfa:	0cd76263          	bltu	a4,a3,80004ebe <filewrite+0x12c>
    80004dfe:	0792                	slli	a5,a5,0x4
    80004e00:	00023717          	auipc	a4,0x23
    80004e04:	d1870713          	addi	a4,a4,-744 # 80027b18 <devsw>
    80004e08:	97ba                	add	a5,a5,a4
    80004e0a:	679c                	ld	a5,8(a5)
    80004e0c:	cbdd                	beqz	a5,80004ec2 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e0e:	4505                	li	a0,1
    80004e10:	9782                	jalr	a5
    80004e12:	8a2a                	mv	s4,a0
    80004e14:	a8a5                	j	80004e8c <filewrite+0xfa>
    80004e16:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e1a:	00000097          	auipc	ra,0x0
    80004e1e:	8b0080e7          	jalr	-1872(ra) # 800046ca <begin_op>
      ilock(f->ip);
    80004e22:	01893503          	ld	a0,24(s2)
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	ece080e7          	jalr	-306(ra) # 80003cf4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e2e:	8762                	mv	a4,s8
    80004e30:	02092683          	lw	a3,32(s2)
    80004e34:	01598633          	add	a2,s3,s5
    80004e38:	4585                	li	a1,1
    80004e3a:	01893503          	ld	a0,24(s2)
    80004e3e:	fffff097          	auipc	ra,0xfffff
    80004e42:	262080e7          	jalr	610(ra) # 800040a0 <writei>
    80004e46:	84aa                	mv	s1,a0
    80004e48:	00a05763          	blez	a0,80004e56 <filewrite+0xc4>
        f->off += r;
    80004e4c:	02092783          	lw	a5,32(s2)
    80004e50:	9fa9                	addw	a5,a5,a0
    80004e52:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e56:	01893503          	ld	a0,24(s2)
    80004e5a:	fffff097          	auipc	ra,0xfffff
    80004e5e:	f5c080e7          	jalr	-164(ra) # 80003db6 <iunlock>
      end_op();
    80004e62:	00000097          	auipc	ra,0x0
    80004e66:	8e8080e7          	jalr	-1816(ra) # 8000474a <end_op>

      if(r != n1){
    80004e6a:	009c1f63          	bne	s8,s1,80004e88 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e6e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e72:	0149db63          	bge	s3,s4,80004e88 <filewrite+0xf6>
      int n1 = n - i;
    80004e76:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e7a:	84be                	mv	s1,a5
    80004e7c:	2781                	sext.w	a5,a5
    80004e7e:	f8fb5ce3          	bge	s6,a5,80004e16 <filewrite+0x84>
    80004e82:	84de                	mv	s1,s7
    80004e84:	bf49                	j	80004e16 <filewrite+0x84>
    int i = 0;
    80004e86:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e88:	013a1f63          	bne	s4,s3,80004ea6 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e8c:	8552                	mv	a0,s4
    80004e8e:	60a6                	ld	ra,72(sp)
    80004e90:	6406                	ld	s0,64(sp)
    80004e92:	74e2                	ld	s1,56(sp)
    80004e94:	7942                	ld	s2,48(sp)
    80004e96:	79a2                	ld	s3,40(sp)
    80004e98:	7a02                	ld	s4,32(sp)
    80004e9a:	6ae2                	ld	s5,24(sp)
    80004e9c:	6b42                	ld	s6,16(sp)
    80004e9e:	6ba2                	ld	s7,8(sp)
    80004ea0:	6c02                	ld	s8,0(sp)
    80004ea2:	6161                	addi	sp,sp,80
    80004ea4:	8082                	ret
    ret = (i == n ? n : -1);
    80004ea6:	5a7d                	li	s4,-1
    80004ea8:	b7d5                	j	80004e8c <filewrite+0xfa>
    panic("filewrite");
    80004eaa:	00004517          	auipc	a0,0x4
    80004eae:	86650513          	addi	a0,a0,-1946 # 80008710 <syscalls+0x280>
    80004eb2:	ffffb097          	auipc	ra,0xffffb
    80004eb6:	678080e7          	jalr	1656(ra) # 8000052a <panic>
    return -1;
    80004eba:	5a7d                	li	s4,-1
    80004ebc:	bfc1                	j	80004e8c <filewrite+0xfa>
      return -1;
    80004ebe:	5a7d                	li	s4,-1
    80004ec0:	b7f1                	j	80004e8c <filewrite+0xfa>
    80004ec2:	5a7d                	li	s4,-1
    80004ec4:	b7e1                	j	80004e8c <filewrite+0xfa>

0000000080004ec6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ec6:	7179                	addi	sp,sp,-48
    80004ec8:	f406                	sd	ra,40(sp)
    80004eca:	f022                	sd	s0,32(sp)
    80004ecc:	ec26                	sd	s1,24(sp)
    80004ece:	e84a                	sd	s2,16(sp)
    80004ed0:	e44e                	sd	s3,8(sp)
    80004ed2:	e052                	sd	s4,0(sp)
    80004ed4:	1800                	addi	s0,sp,48
    80004ed6:	84aa                	mv	s1,a0
    80004ed8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004eda:	0005b023          	sd	zero,0(a1)
    80004ede:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ee2:	00000097          	auipc	ra,0x0
    80004ee6:	bf8080e7          	jalr	-1032(ra) # 80004ada <filealloc>
    80004eea:	e088                	sd	a0,0(s1)
    80004eec:	c551                	beqz	a0,80004f78 <pipealloc+0xb2>
    80004eee:	00000097          	auipc	ra,0x0
    80004ef2:	bec080e7          	jalr	-1044(ra) # 80004ada <filealloc>
    80004ef6:	00aa3023          	sd	a0,0(s4)
    80004efa:	c92d                	beqz	a0,80004f6c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004efc:	ffffc097          	auipc	ra,0xffffc
    80004f00:	bd6080e7          	jalr	-1066(ra) # 80000ad2 <kalloc>
    80004f04:	892a                	mv	s2,a0
    80004f06:	c125                	beqz	a0,80004f66 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f08:	4985                	li	s3,1
    80004f0a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f0e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f12:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f16:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f1a:	00004597          	auipc	a1,0x4
    80004f1e:	80658593          	addi	a1,a1,-2042 # 80008720 <syscalls+0x290>
    80004f22:	ffffc097          	auipc	ra,0xffffc
    80004f26:	c10080e7          	jalr	-1008(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004f2a:	609c                	ld	a5,0(s1)
    80004f2c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f30:	609c                	ld	a5,0(s1)
    80004f32:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f36:	609c                	ld	a5,0(s1)
    80004f38:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f3c:	609c                	ld	a5,0(s1)
    80004f3e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f42:	000a3783          	ld	a5,0(s4)
    80004f46:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f4a:	000a3783          	ld	a5,0(s4)
    80004f4e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f52:	000a3783          	ld	a5,0(s4)
    80004f56:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f5a:	000a3783          	ld	a5,0(s4)
    80004f5e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f62:	4501                	li	a0,0
    80004f64:	a025                	j	80004f8c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f66:	6088                	ld	a0,0(s1)
    80004f68:	e501                	bnez	a0,80004f70 <pipealloc+0xaa>
    80004f6a:	a039                	j	80004f78 <pipealloc+0xb2>
    80004f6c:	6088                	ld	a0,0(s1)
    80004f6e:	c51d                	beqz	a0,80004f9c <pipealloc+0xd6>
    fileclose(*f0);
    80004f70:	00000097          	auipc	ra,0x0
    80004f74:	c26080e7          	jalr	-986(ra) # 80004b96 <fileclose>
  if(*f1)
    80004f78:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f7c:	557d                	li	a0,-1
  if(*f1)
    80004f7e:	c799                	beqz	a5,80004f8c <pipealloc+0xc6>
    fileclose(*f1);
    80004f80:	853e                	mv	a0,a5
    80004f82:	00000097          	auipc	ra,0x0
    80004f86:	c14080e7          	jalr	-1004(ra) # 80004b96 <fileclose>
  return -1;
    80004f8a:	557d                	li	a0,-1
}
    80004f8c:	70a2                	ld	ra,40(sp)
    80004f8e:	7402                	ld	s0,32(sp)
    80004f90:	64e2                	ld	s1,24(sp)
    80004f92:	6942                	ld	s2,16(sp)
    80004f94:	69a2                	ld	s3,8(sp)
    80004f96:	6a02                	ld	s4,0(sp)
    80004f98:	6145                	addi	sp,sp,48
    80004f9a:	8082                	ret
  return -1;
    80004f9c:	557d                	li	a0,-1
    80004f9e:	b7fd                	j	80004f8c <pipealloc+0xc6>

0000000080004fa0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004fa0:	1101                	addi	sp,sp,-32
    80004fa2:	ec06                	sd	ra,24(sp)
    80004fa4:	e822                	sd	s0,16(sp)
    80004fa6:	e426                	sd	s1,8(sp)
    80004fa8:	e04a                	sd	s2,0(sp)
    80004faa:	1000                	addi	s0,sp,32
    80004fac:	84aa                	mv	s1,a0
    80004fae:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004fb0:	ffffc097          	auipc	ra,0xffffc
    80004fb4:	c12080e7          	jalr	-1006(ra) # 80000bc2 <acquire>
  if(writable){
    80004fb8:	02090d63          	beqz	s2,80004ff2 <pipeclose+0x52>
    pi->writeopen = 0;
    80004fbc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fc0:	21848513          	addi	a0,s1,536
    80004fc4:	ffffd097          	auipc	ra,0xffffd
    80004fc8:	2f4080e7          	jalr	756(ra) # 800022b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004fcc:	2204b783          	ld	a5,544(s1)
    80004fd0:	eb95                	bnez	a5,80005004 <pipeclose+0x64>
    release(&pi->lock);
    80004fd2:	8526                	mv	a0,s1
    80004fd4:	ffffc097          	auipc	ra,0xffffc
    80004fd8:	ca2080e7          	jalr	-862(ra) # 80000c76 <release>
    kfree((char*)pi);
    80004fdc:	8526                	mv	a0,s1
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	9f8080e7          	jalr	-1544(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80004fe6:	60e2                	ld	ra,24(sp)
    80004fe8:	6442                	ld	s0,16(sp)
    80004fea:	64a2                	ld	s1,8(sp)
    80004fec:	6902                	ld	s2,0(sp)
    80004fee:	6105                	addi	sp,sp,32
    80004ff0:	8082                	ret
    pi->readopen = 0;
    80004ff2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ff6:	21c48513          	addi	a0,s1,540
    80004ffa:	ffffd097          	auipc	ra,0xffffd
    80004ffe:	2be080e7          	jalr	702(ra) # 800022b8 <wakeup>
    80005002:	b7e9                	j	80004fcc <pipeclose+0x2c>
    release(&pi->lock);
    80005004:	8526                	mv	a0,s1
    80005006:	ffffc097          	auipc	ra,0xffffc
    8000500a:	c70080e7          	jalr	-912(ra) # 80000c76 <release>
}
    8000500e:	bfe1                	j	80004fe6 <pipeclose+0x46>

0000000080005010 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005010:	711d                	addi	sp,sp,-96
    80005012:	ec86                	sd	ra,88(sp)
    80005014:	e8a2                	sd	s0,80(sp)
    80005016:	e4a6                	sd	s1,72(sp)
    80005018:	e0ca                	sd	s2,64(sp)
    8000501a:	fc4e                	sd	s3,56(sp)
    8000501c:	f852                	sd	s4,48(sp)
    8000501e:	f456                	sd	s5,40(sp)
    80005020:	f05a                	sd	s6,32(sp)
    80005022:	ec5e                	sd	s7,24(sp)
    80005024:	e862                	sd	s8,16(sp)
    80005026:	1080                	addi	s0,sp,96
    80005028:	84aa                	mv	s1,a0
    8000502a:	8aae                	mv	s5,a1
    8000502c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000502e:	ffffd097          	auipc	ra,0xffffd
    80005032:	986080e7          	jalr	-1658(ra) # 800019b4 <myproc>
    80005036:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005038:	8526                	mv	a0,s1
    8000503a:	ffffc097          	auipc	ra,0xffffc
    8000503e:	b88080e7          	jalr	-1144(ra) # 80000bc2 <acquire>
  while(i < n){
    80005042:	0b405363          	blez	s4,800050e8 <pipewrite+0xd8>
  int i = 0;
    80005046:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005048:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000504a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000504e:	21c48b93          	addi	s7,s1,540
    80005052:	a089                	j	80005094 <pipewrite+0x84>
      release(&pi->lock);
    80005054:	8526                	mv	a0,s1
    80005056:	ffffc097          	auipc	ra,0xffffc
    8000505a:	c20080e7          	jalr	-992(ra) # 80000c76 <release>
      return -1;
    8000505e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005060:	854a                	mv	a0,s2
    80005062:	60e6                	ld	ra,88(sp)
    80005064:	6446                	ld	s0,80(sp)
    80005066:	64a6                	ld	s1,72(sp)
    80005068:	6906                	ld	s2,64(sp)
    8000506a:	79e2                	ld	s3,56(sp)
    8000506c:	7a42                	ld	s4,48(sp)
    8000506e:	7aa2                	ld	s5,40(sp)
    80005070:	7b02                	ld	s6,32(sp)
    80005072:	6be2                	ld	s7,24(sp)
    80005074:	6c42                	ld	s8,16(sp)
    80005076:	6125                	addi	sp,sp,96
    80005078:	8082                	ret
      wakeup(&pi->nread);
    8000507a:	8562                	mv	a0,s8
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	23c080e7          	jalr	572(ra) # 800022b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005084:	85a6                	mv	a1,s1
    80005086:	855e                	mv	a0,s7
    80005088:	ffffd097          	auipc	ra,0xffffd
    8000508c:	0a4080e7          	jalr	164(ra) # 8000212c <sleep>
  while(i < n){
    80005090:	05495d63          	bge	s2,s4,800050ea <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005094:	2204a783          	lw	a5,544(s1)
    80005098:	dfd5                	beqz	a5,80005054 <pipewrite+0x44>
    8000509a:	0289a783          	lw	a5,40(s3)
    8000509e:	fbdd                	bnez	a5,80005054 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050a0:	2184a783          	lw	a5,536(s1)
    800050a4:	21c4a703          	lw	a4,540(s1)
    800050a8:	2007879b          	addiw	a5,a5,512
    800050ac:	fcf707e3          	beq	a4,a5,8000507a <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050b0:	4685                	li	a3,1
    800050b2:	01590633          	add	a2,s2,s5
    800050b6:	faf40593          	addi	a1,s0,-81
    800050ba:	0509b503          	ld	a0,80(s3)
    800050be:	ffffc097          	auipc	ra,0xffffc
    800050c2:	60c080e7          	jalr	1548(ra) # 800016ca <copyin>
    800050c6:	03650263          	beq	a0,s6,800050ea <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800050ca:	21c4a783          	lw	a5,540(s1)
    800050ce:	0017871b          	addiw	a4,a5,1
    800050d2:	20e4ae23          	sw	a4,540(s1)
    800050d6:	1ff7f793          	andi	a5,a5,511
    800050da:	97a6                	add	a5,a5,s1
    800050dc:	faf44703          	lbu	a4,-81(s0)
    800050e0:	00e78c23          	sb	a4,24(a5)
      i++;
    800050e4:	2905                	addiw	s2,s2,1
    800050e6:	b76d                	j	80005090 <pipewrite+0x80>
  int i = 0;
    800050e8:	4901                	li	s2,0
  wakeup(&pi->nread);
    800050ea:	21848513          	addi	a0,s1,536
    800050ee:	ffffd097          	auipc	ra,0xffffd
    800050f2:	1ca080e7          	jalr	458(ra) # 800022b8 <wakeup>
  release(&pi->lock);
    800050f6:	8526                	mv	a0,s1
    800050f8:	ffffc097          	auipc	ra,0xffffc
    800050fc:	b7e080e7          	jalr	-1154(ra) # 80000c76 <release>
  return i;
    80005100:	b785                	j	80005060 <pipewrite+0x50>

0000000080005102 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005102:	715d                	addi	sp,sp,-80
    80005104:	e486                	sd	ra,72(sp)
    80005106:	e0a2                	sd	s0,64(sp)
    80005108:	fc26                	sd	s1,56(sp)
    8000510a:	f84a                	sd	s2,48(sp)
    8000510c:	f44e                	sd	s3,40(sp)
    8000510e:	f052                	sd	s4,32(sp)
    80005110:	ec56                	sd	s5,24(sp)
    80005112:	e85a                	sd	s6,16(sp)
    80005114:	0880                	addi	s0,sp,80
    80005116:	84aa                	mv	s1,a0
    80005118:	892e                	mv	s2,a1
    8000511a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000511c:	ffffd097          	auipc	ra,0xffffd
    80005120:	898080e7          	jalr	-1896(ra) # 800019b4 <myproc>
    80005124:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005126:	8526                	mv	a0,s1
    80005128:	ffffc097          	auipc	ra,0xffffc
    8000512c:	a9a080e7          	jalr	-1382(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005130:	2184a703          	lw	a4,536(s1)
    80005134:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005138:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000513c:	02f71463          	bne	a4,a5,80005164 <piperead+0x62>
    80005140:	2244a783          	lw	a5,548(s1)
    80005144:	c385                	beqz	a5,80005164 <piperead+0x62>
    if(pr->killed){
    80005146:	028a2783          	lw	a5,40(s4)
    8000514a:	ebc1                	bnez	a5,800051da <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000514c:	85a6                	mv	a1,s1
    8000514e:	854e                	mv	a0,s3
    80005150:	ffffd097          	auipc	ra,0xffffd
    80005154:	fdc080e7          	jalr	-36(ra) # 8000212c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005158:	2184a703          	lw	a4,536(s1)
    8000515c:	21c4a783          	lw	a5,540(s1)
    80005160:	fef700e3          	beq	a4,a5,80005140 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005164:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005166:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005168:	05505363          	blez	s5,800051ae <piperead+0xac>
    if(pi->nread == pi->nwrite)
    8000516c:	2184a783          	lw	a5,536(s1)
    80005170:	21c4a703          	lw	a4,540(s1)
    80005174:	02f70d63          	beq	a4,a5,800051ae <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005178:	0017871b          	addiw	a4,a5,1
    8000517c:	20e4ac23          	sw	a4,536(s1)
    80005180:	1ff7f793          	andi	a5,a5,511
    80005184:	97a6                	add	a5,a5,s1
    80005186:	0187c783          	lbu	a5,24(a5)
    8000518a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000518e:	4685                	li	a3,1
    80005190:	fbf40613          	addi	a2,s0,-65
    80005194:	85ca                	mv	a1,s2
    80005196:	050a3503          	ld	a0,80(s4)
    8000519a:	ffffc097          	auipc	ra,0xffffc
    8000519e:	4a4080e7          	jalr	1188(ra) # 8000163e <copyout>
    800051a2:	01650663          	beq	a0,s6,800051ae <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051a6:	2985                	addiw	s3,s3,1
    800051a8:	0905                	addi	s2,s2,1
    800051aa:	fd3a91e3          	bne	s5,s3,8000516c <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051ae:	21c48513          	addi	a0,s1,540
    800051b2:	ffffd097          	auipc	ra,0xffffd
    800051b6:	106080e7          	jalr	262(ra) # 800022b8 <wakeup>
  release(&pi->lock);
    800051ba:	8526                	mv	a0,s1
    800051bc:	ffffc097          	auipc	ra,0xffffc
    800051c0:	aba080e7          	jalr	-1350(ra) # 80000c76 <release>
  return i;
}
    800051c4:	854e                	mv	a0,s3
    800051c6:	60a6                	ld	ra,72(sp)
    800051c8:	6406                	ld	s0,64(sp)
    800051ca:	74e2                	ld	s1,56(sp)
    800051cc:	7942                	ld	s2,48(sp)
    800051ce:	79a2                	ld	s3,40(sp)
    800051d0:	7a02                	ld	s4,32(sp)
    800051d2:	6ae2                	ld	s5,24(sp)
    800051d4:	6b42                	ld	s6,16(sp)
    800051d6:	6161                	addi	sp,sp,80
    800051d8:	8082                	ret
      release(&pi->lock);
    800051da:	8526                	mv	a0,s1
    800051dc:	ffffc097          	auipc	ra,0xffffc
    800051e0:	a9a080e7          	jalr	-1382(ra) # 80000c76 <release>
      return -1;
    800051e4:	59fd                	li	s3,-1
    800051e6:	bff9                	j	800051c4 <piperead+0xc2>

00000000800051e8 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800051e8:	de010113          	addi	sp,sp,-544
    800051ec:	20113c23          	sd	ra,536(sp)
    800051f0:	20813823          	sd	s0,528(sp)
    800051f4:	20913423          	sd	s1,520(sp)
    800051f8:	21213023          	sd	s2,512(sp)
    800051fc:	ffce                	sd	s3,504(sp)
    800051fe:	fbd2                	sd	s4,496(sp)
    80005200:	f7d6                	sd	s5,488(sp)
    80005202:	f3da                	sd	s6,480(sp)
    80005204:	efde                	sd	s7,472(sp)
    80005206:	ebe2                	sd	s8,464(sp)
    80005208:	e7e6                	sd	s9,456(sp)
    8000520a:	e3ea                	sd	s10,448(sp)
    8000520c:	ff6e                	sd	s11,440(sp)
    8000520e:	1400                	addi	s0,sp,544
    80005210:	892a                	mv	s2,a0
    80005212:	dea43423          	sd	a0,-536(s0)
    80005216:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000521a:	ffffc097          	auipc	ra,0xffffc
    8000521e:	79a080e7          	jalr	1946(ra) # 800019b4 <myproc>
    80005222:	84aa                	mv	s1,a0

  begin_op();
    80005224:	fffff097          	auipc	ra,0xfffff
    80005228:	4a6080e7          	jalr	1190(ra) # 800046ca <begin_op>

  if((ip = namei(path)) == 0){
    8000522c:	854a                	mv	a0,s2
    8000522e:	fffff097          	auipc	ra,0xfffff
    80005232:	27c080e7          	jalr	636(ra) # 800044aa <namei>
    80005236:	c93d                	beqz	a0,800052ac <exec+0xc4>
    80005238:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000523a:	fffff097          	auipc	ra,0xfffff
    8000523e:	aba080e7          	jalr	-1350(ra) # 80003cf4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005242:	04000713          	li	a4,64
    80005246:	4681                	li	a3,0
    80005248:	e4840613          	addi	a2,s0,-440
    8000524c:	4581                	li	a1,0
    8000524e:	8556                	mv	a0,s5
    80005250:	fffff097          	auipc	ra,0xfffff
    80005254:	d58080e7          	jalr	-680(ra) # 80003fa8 <readi>
    80005258:	04000793          	li	a5,64
    8000525c:	00f51a63          	bne	a0,a5,80005270 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005260:	e4842703          	lw	a4,-440(s0)
    80005264:	464c47b7          	lui	a5,0x464c4
    80005268:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000526c:	04f70663          	beq	a4,a5,800052b8 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005270:	8556                	mv	a0,s5
    80005272:	fffff097          	auipc	ra,0xfffff
    80005276:	ce4080e7          	jalr	-796(ra) # 80003f56 <iunlockput>
    end_op();
    8000527a:	fffff097          	auipc	ra,0xfffff
    8000527e:	4d0080e7          	jalr	1232(ra) # 8000474a <end_op>
  }
  return -1;
    80005282:	557d                	li	a0,-1
}
    80005284:	21813083          	ld	ra,536(sp)
    80005288:	21013403          	ld	s0,528(sp)
    8000528c:	20813483          	ld	s1,520(sp)
    80005290:	20013903          	ld	s2,512(sp)
    80005294:	79fe                	ld	s3,504(sp)
    80005296:	7a5e                	ld	s4,496(sp)
    80005298:	7abe                	ld	s5,488(sp)
    8000529a:	7b1e                	ld	s6,480(sp)
    8000529c:	6bfe                	ld	s7,472(sp)
    8000529e:	6c5e                	ld	s8,464(sp)
    800052a0:	6cbe                	ld	s9,456(sp)
    800052a2:	6d1e                	ld	s10,448(sp)
    800052a4:	7dfa                	ld	s11,440(sp)
    800052a6:	22010113          	addi	sp,sp,544
    800052aa:	8082                	ret
    end_op();
    800052ac:	fffff097          	auipc	ra,0xfffff
    800052b0:	49e080e7          	jalr	1182(ra) # 8000474a <end_op>
    return -1;
    800052b4:	557d                	li	a0,-1
    800052b6:	b7f9                	j	80005284 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800052b8:	8526                	mv	a0,s1
    800052ba:	ffffd097          	auipc	ra,0xffffd
    800052be:	814080e7          	jalr	-2028(ra) # 80001ace <proc_pagetable>
    800052c2:	8b2a                	mv	s6,a0
    800052c4:	d555                	beqz	a0,80005270 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052c6:	e6842783          	lw	a5,-408(s0)
    800052ca:	e8045703          	lhu	a4,-384(s0)
    800052ce:	c735                	beqz	a4,8000533a <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800052d0:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052d2:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800052d6:	6a05                	lui	s4,0x1
    800052d8:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800052dc:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800052e0:	6d85                	lui	s11,0x1
    800052e2:	7d7d                	lui	s10,0xfffff
    800052e4:	aca9                	j	8000553e <exec+0x356>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800052e6:	00003517          	auipc	a0,0x3
    800052ea:	44250513          	addi	a0,a0,1090 # 80008728 <syscalls+0x298>
    800052ee:	ffffb097          	auipc	ra,0xffffb
    800052f2:	23c080e7          	jalr	572(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800052f6:	874a                	mv	a4,s2
    800052f8:	009c86bb          	addw	a3,s9,s1
    800052fc:	4581                	li	a1,0
    800052fe:	8556                	mv	a0,s5
    80005300:	fffff097          	auipc	ra,0xfffff
    80005304:	ca8080e7          	jalr	-856(ra) # 80003fa8 <readi>
    80005308:	2501                	sext.w	a0,a0
    8000530a:	1ca91a63          	bne	s2,a0,800054de <exec+0x2f6>
  for(i = 0; i < sz; i += PGSIZE){
    8000530e:	009d84bb          	addw	s1,s11,s1
    80005312:	013d09bb          	addw	s3,s10,s3
    80005316:	2174f463          	bgeu	s1,s7,8000551e <exec+0x336>
    pa = walkaddr(pagetable, va + i);
    8000531a:	02049593          	slli	a1,s1,0x20
    8000531e:	9181                	srli	a1,a1,0x20
    80005320:	95e2                	add	a1,a1,s8
    80005322:	855a                	mv	a0,s6
    80005324:	ffffc097          	auipc	ra,0xffffc
    80005328:	d28080e7          	jalr	-728(ra) # 8000104c <walkaddr>
    8000532c:	862a                	mv	a2,a0
    if(pa == 0)
    8000532e:	dd45                	beqz	a0,800052e6 <exec+0xfe>
      n = PGSIZE;
    80005330:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005332:	fd49f2e3          	bgeu	s3,s4,800052f6 <exec+0x10e>
      n = sz - i;
    80005336:	894e                	mv	s2,s3
    80005338:	bf7d                	j	800052f6 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000533a:	4481                	li	s1,0
  iunlockput(ip);
    8000533c:	8556                	mv	a0,s5
    8000533e:	fffff097          	auipc	ra,0xfffff
    80005342:	c18080e7          	jalr	-1000(ra) # 80003f56 <iunlockput>
  end_op();
    80005346:	fffff097          	auipc	ra,0xfffff
    8000534a:	404080e7          	jalr	1028(ra) # 8000474a <end_op>
  p = myproc();
    8000534e:	ffffc097          	auipc	ra,0xffffc
    80005352:	666080e7          	jalr	1638(ra) # 800019b4 <myproc>
    80005356:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005358:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000535c:	6785                	lui	a5,0x1
    8000535e:	17fd                	addi	a5,a5,-1
    80005360:	94be                	add	s1,s1,a5
    80005362:	77fd                	lui	a5,0xfffff
    80005364:	8fe5                	and	a5,a5,s1
    80005366:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000536a:	6609                	lui	a2,0x2
    8000536c:	963e                	add	a2,a2,a5
    8000536e:	85be                	mv	a1,a5
    80005370:	855a                	mv	a0,s6
    80005372:	ffffc097          	auipc	ra,0xffffc
    80005376:	07c080e7          	jalr	124(ra) # 800013ee <uvmalloc>
    8000537a:	8c2a                	mv	s8,a0
  ip = 0;
    8000537c:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000537e:	16050063          	beqz	a0,800054de <exec+0x2f6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005382:	75f9                	lui	a1,0xffffe
    80005384:	95aa                	add	a1,a1,a0
    80005386:	855a                	mv	a0,s6
    80005388:	ffffc097          	auipc	ra,0xffffc
    8000538c:	284080e7          	jalr	644(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    80005390:	7afd                	lui	s5,0xfffff
    80005392:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005394:	df043783          	ld	a5,-528(s0)
    80005398:	6388                	ld	a0,0(a5)
    8000539a:	c925                	beqz	a0,8000540a <exec+0x222>
    8000539c:	e8840993          	addi	s3,s0,-376
    800053a0:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    800053a4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800053a6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053a8:	ffffc097          	auipc	ra,0xffffc
    800053ac:	a9a080e7          	jalr	-1382(ra) # 80000e42 <strlen>
    800053b0:	0015079b          	addiw	a5,a0,1
    800053b4:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053b8:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800053bc:	15596563          	bltu	s2,s5,80005506 <exec+0x31e>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053c0:	df043d83          	ld	s11,-528(s0)
    800053c4:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800053c8:	8552                	mv	a0,s4
    800053ca:	ffffc097          	auipc	ra,0xffffc
    800053ce:	a78080e7          	jalr	-1416(ra) # 80000e42 <strlen>
    800053d2:	0015069b          	addiw	a3,a0,1
    800053d6:	8652                	mv	a2,s4
    800053d8:	85ca                	mv	a1,s2
    800053da:	855a                	mv	a0,s6
    800053dc:	ffffc097          	auipc	ra,0xffffc
    800053e0:	262080e7          	jalr	610(ra) # 8000163e <copyout>
    800053e4:	12054563          	bltz	a0,8000550e <exec+0x326>
    ustack[argc] = sp;
    800053e8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053ec:	0485                	addi	s1,s1,1
    800053ee:	008d8793          	addi	a5,s11,8
    800053f2:	def43823          	sd	a5,-528(s0)
    800053f6:	008db503          	ld	a0,8(s11)
    800053fa:	c911                	beqz	a0,8000540e <exec+0x226>
    if(argc >= MAXARG)
    800053fc:	09a1                	addi	s3,s3,8
    800053fe:	fb9995e3          	bne	s3,s9,800053a8 <exec+0x1c0>
  sz = sz1;
    80005402:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005406:	4a81                	li	s5,0
    80005408:	a8d9                	j	800054de <exec+0x2f6>
  sp = sz;
    8000540a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000540c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000540e:	00349793          	slli	a5,s1,0x3
    80005412:	f9040713          	addi	a4,s0,-112
    80005416:	97ba                	add	a5,a5,a4
    80005418:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd2ef8>
  sp -= (argc+1) * sizeof(uint64);
    8000541c:	00148693          	addi	a3,s1,1
    80005420:	068e                	slli	a3,a3,0x3
    80005422:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005426:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000542a:	01597663          	bgeu	s2,s5,80005436 <exec+0x24e>
  sz = sz1;
    8000542e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005432:	4a81                	li	s5,0
    80005434:	a06d                	j	800054de <exec+0x2f6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005436:	e8840613          	addi	a2,s0,-376
    8000543a:	85ca                	mv	a1,s2
    8000543c:	855a                	mv	a0,s6
    8000543e:	ffffc097          	auipc	ra,0xffffc
    80005442:	200080e7          	jalr	512(ra) # 8000163e <copyout>
    80005446:	0c054863          	bltz	a0,80005516 <exec+0x32e>
  p->trapframe->a1 = sp;
    8000544a:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    8000544e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005452:	de843783          	ld	a5,-536(s0)
    80005456:	0007c703          	lbu	a4,0(a5)
    8000545a:	cf11                	beqz	a4,80005476 <exec+0x28e>
    8000545c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000545e:	02f00693          	li	a3,47
    80005462:	a039                	j	80005470 <exec+0x288>
      last = s+1;
    80005464:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005468:	0785                	addi	a5,a5,1
    8000546a:	fff7c703          	lbu	a4,-1(a5)
    8000546e:	c701                	beqz	a4,80005476 <exec+0x28e>
    if(*s == '/')
    80005470:	fed71ce3          	bne	a4,a3,80005468 <exec+0x280>
    80005474:	bfc5                	j	80005464 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005476:	4641                	li	a2,16
    80005478:	de843583          	ld	a1,-536(s0)
    8000547c:	158b8513          	addi	a0,s7,344
    80005480:	ffffc097          	auipc	ra,0xffffc
    80005484:	990080e7          	jalr	-1648(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005488:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000548c:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005490:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005494:	058bb783          	ld	a5,88(s7)
    80005498:	e6043703          	ld	a4,-416(s0)
    8000549c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000549e:	058bb783          	ld	a5,88(s7)
    800054a2:	0327b823          	sd	s2,48(a5)
  for (int i = 0; i < 32; i++)
    800054a6:	170b8793          	addi	a5,s7,368
    800054aa:	270b8b93          	addi	s7,s7,624
    800054ae:	86de                	mv	a3,s7
    if( &p->signal_handlers[i] != (void*) SIG_DFL &&  &p->signal_handlers[i] != (void *)SIG_IGN){
    800054b0:	4705                	li	a4,1
    800054b2:	a029                	j	800054bc <exec+0x2d4>
  for (int i = 0; i < 32; i++)
    800054b4:	07a1                	addi	a5,a5,8
    800054b6:	0b91                	addi	s7,s7,4
    800054b8:	00f68963          	beq	a3,a5,800054ca <exec+0x2e2>
    if( &p->signal_handlers[i] != (void*) SIG_DFL &&  &p->signal_handlers[i] != (void *)SIG_IGN){
    800054bc:	fef77ce3          	bgeu	a4,a5,800054b4 <exec+0x2cc>
       p->signal_handlers[i] = (void *)SIG_DFL;
    800054c0:	0007b023          	sd	zero,0(a5)
       p->signal_handlers_mask[i]=0;
    800054c4:	000ba023          	sw	zero,0(s7)
    800054c8:	b7f5                	j	800054b4 <exec+0x2cc>
  proc_freepagetable(oldpagetable, oldsz);
    800054ca:	85ea                	mv	a1,s10
    800054cc:	ffffc097          	auipc	ra,0xffffc
    800054d0:	69e080e7          	jalr	1694(ra) # 80001b6a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054d4:	0004851b          	sext.w	a0,s1
    800054d8:	b375                	j	80005284 <exec+0x9c>
    800054da:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800054de:	df843583          	ld	a1,-520(s0)
    800054e2:	855a                	mv	a0,s6
    800054e4:	ffffc097          	auipc	ra,0xffffc
    800054e8:	686080e7          	jalr	1670(ra) # 80001b6a <proc_freepagetable>
  if(ip){
    800054ec:	d80a92e3          	bnez	s5,80005270 <exec+0x88>
  return -1;
    800054f0:	557d                	li	a0,-1
    800054f2:	bb49                	j	80005284 <exec+0x9c>
    800054f4:	de943c23          	sd	s1,-520(s0)
    800054f8:	b7dd                	j	800054de <exec+0x2f6>
    800054fa:	de943c23          	sd	s1,-520(s0)
    800054fe:	b7c5                	j	800054de <exec+0x2f6>
    80005500:	de943c23          	sd	s1,-520(s0)
    80005504:	bfe9                	j	800054de <exec+0x2f6>
  sz = sz1;
    80005506:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000550a:	4a81                	li	s5,0
    8000550c:	bfc9                	j	800054de <exec+0x2f6>
  sz = sz1;
    8000550e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005512:	4a81                	li	s5,0
    80005514:	b7e9                	j	800054de <exec+0x2f6>
  sz = sz1;
    80005516:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000551a:	4a81                	li	s5,0
    8000551c:	b7c9                	j	800054de <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000551e:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005522:	e0843783          	ld	a5,-504(s0)
    80005526:	0017869b          	addiw	a3,a5,1
    8000552a:	e0d43423          	sd	a3,-504(s0)
    8000552e:	e0043783          	ld	a5,-512(s0)
    80005532:	0387879b          	addiw	a5,a5,56
    80005536:	e8045703          	lhu	a4,-384(s0)
    8000553a:	e0e6d1e3          	bge	a3,a4,8000533c <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000553e:	2781                	sext.w	a5,a5
    80005540:	e0f43023          	sd	a5,-512(s0)
    80005544:	03800713          	li	a4,56
    80005548:	86be                	mv	a3,a5
    8000554a:	e1040613          	addi	a2,s0,-496
    8000554e:	4581                	li	a1,0
    80005550:	8556                	mv	a0,s5
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	a56080e7          	jalr	-1450(ra) # 80003fa8 <readi>
    8000555a:	03800793          	li	a5,56
    8000555e:	f6f51ee3          	bne	a0,a5,800054da <exec+0x2f2>
    if(ph.type != ELF_PROG_LOAD)
    80005562:	e1042783          	lw	a5,-496(s0)
    80005566:	4705                	li	a4,1
    80005568:	fae79de3          	bne	a5,a4,80005522 <exec+0x33a>
    if(ph.memsz < ph.filesz)
    8000556c:	e3843603          	ld	a2,-456(s0)
    80005570:	e3043783          	ld	a5,-464(s0)
    80005574:	f8f660e3          	bltu	a2,a5,800054f4 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005578:	e2043783          	ld	a5,-480(s0)
    8000557c:	963e                	add	a2,a2,a5
    8000557e:	f6f66ee3          	bltu	a2,a5,800054fa <exec+0x312>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005582:	85a6                	mv	a1,s1
    80005584:	855a                	mv	a0,s6
    80005586:	ffffc097          	auipc	ra,0xffffc
    8000558a:	e68080e7          	jalr	-408(ra) # 800013ee <uvmalloc>
    8000558e:	dea43c23          	sd	a0,-520(s0)
    80005592:	d53d                	beqz	a0,80005500 <exec+0x318>
    if(ph.vaddr % PGSIZE != 0)
    80005594:	e2043c03          	ld	s8,-480(s0)
    80005598:	de043783          	ld	a5,-544(s0)
    8000559c:	00fc77b3          	and	a5,s8,a5
    800055a0:	ff9d                	bnez	a5,800054de <exec+0x2f6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800055a2:	e1842c83          	lw	s9,-488(s0)
    800055a6:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800055aa:	f60b8ae3          	beqz	s7,8000551e <exec+0x336>
    800055ae:	89de                	mv	s3,s7
    800055b0:	4481                	li	s1,0
    800055b2:	b3a5                	j	8000531a <exec+0x132>

00000000800055b4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055b4:	7179                	addi	sp,sp,-48
    800055b6:	f406                	sd	ra,40(sp)
    800055b8:	f022                	sd	s0,32(sp)
    800055ba:	ec26                	sd	s1,24(sp)
    800055bc:	e84a                	sd	s2,16(sp)
    800055be:	1800                	addi	s0,sp,48
    800055c0:	892e                	mv	s2,a1
    800055c2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800055c4:	fdc40593          	addi	a1,s0,-36
    800055c8:	ffffe097          	auipc	ra,0xffffe
    800055cc:	af8080e7          	jalr	-1288(ra) # 800030c0 <argint>
    800055d0:	04054063          	bltz	a0,80005610 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055d4:	fdc42703          	lw	a4,-36(s0)
    800055d8:	47bd                	li	a5,15
    800055da:	02e7ed63          	bltu	a5,a4,80005614 <argfd+0x60>
    800055de:	ffffc097          	auipc	ra,0xffffc
    800055e2:	3d6080e7          	jalr	982(ra) # 800019b4 <myproc>
    800055e6:	fdc42703          	lw	a4,-36(s0)
    800055ea:	01a70793          	addi	a5,a4,26
    800055ee:	078e                	slli	a5,a5,0x3
    800055f0:	953e                	add	a0,a0,a5
    800055f2:	611c                	ld	a5,0(a0)
    800055f4:	c395                	beqz	a5,80005618 <argfd+0x64>
    return -1;
  if(pfd)
    800055f6:	00090463          	beqz	s2,800055fe <argfd+0x4a>
    *pfd = fd;
    800055fa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800055fe:	4501                	li	a0,0
  if(pf)
    80005600:	c091                	beqz	s1,80005604 <argfd+0x50>
    *pf = f;
    80005602:	e09c                	sd	a5,0(s1)
}
    80005604:	70a2                	ld	ra,40(sp)
    80005606:	7402                	ld	s0,32(sp)
    80005608:	64e2                	ld	s1,24(sp)
    8000560a:	6942                	ld	s2,16(sp)
    8000560c:	6145                	addi	sp,sp,48
    8000560e:	8082                	ret
    return -1;
    80005610:	557d                	li	a0,-1
    80005612:	bfcd                	j	80005604 <argfd+0x50>
    return -1;
    80005614:	557d                	li	a0,-1
    80005616:	b7fd                	j	80005604 <argfd+0x50>
    80005618:	557d                	li	a0,-1
    8000561a:	b7ed                	j	80005604 <argfd+0x50>

000000008000561c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000561c:	1101                	addi	sp,sp,-32
    8000561e:	ec06                	sd	ra,24(sp)
    80005620:	e822                	sd	s0,16(sp)
    80005622:	e426                	sd	s1,8(sp)
    80005624:	1000                	addi	s0,sp,32
    80005626:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005628:	ffffc097          	auipc	ra,0xffffc
    8000562c:	38c080e7          	jalr	908(ra) # 800019b4 <myproc>
    80005630:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005632:	0d050793          	addi	a5,a0,208
    80005636:	4501                	li	a0,0
    80005638:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000563a:	6398                	ld	a4,0(a5)
    8000563c:	cb19                	beqz	a4,80005652 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000563e:	2505                	addiw	a0,a0,1
    80005640:	07a1                	addi	a5,a5,8
    80005642:	fed51ce3          	bne	a0,a3,8000563a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005646:	557d                	li	a0,-1
}
    80005648:	60e2                	ld	ra,24(sp)
    8000564a:	6442                	ld	s0,16(sp)
    8000564c:	64a2                	ld	s1,8(sp)
    8000564e:	6105                	addi	sp,sp,32
    80005650:	8082                	ret
      p->ofile[fd] = f;
    80005652:	01a50793          	addi	a5,a0,26
    80005656:	078e                	slli	a5,a5,0x3
    80005658:	963e                	add	a2,a2,a5
    8000565a:	e204                	sd	s1,0(a2)
      return fd;
    8000565c:	b7f5                	j	80005648 <fdalloc+0x2c>

000000008000565e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000565e:	715d                	addi	sp,sp,-80
    80005660:	e486                	sd	ra,72(sp)
    80005662:	e0a2                	sd	s0,64(sp)
    80005664:	fc26                	sd	s1,56(sp)
    80005666:	f84a                	sd	s2,48(sp)
    80005668:	f44e                	sd	s3,40(sp)
    8000566a:	f052                	sd	s4,32(sp)
    8000566c:	ec56                	sd	s5,24(sp)
    8000566e:	0880                	addi	s0,sp,80
    80005670:	89ae                	mv	s3,a1
    80005672:	8ab2                	mv	s5,a2
    80005674:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005676:	fb040593          	addi	a1,s0,-80
    8000567a:	fffff097          	auipc	ra,0xfffff
    8000567e:	e4e080e7          	jalr	-434(ra) # 800044c8 <nameiparent>
    80005682:	892a                	mv	s2,a0
    80005684:	12050e63          	beqz	a0,800057c0 <create+0x162>
    return 0;

  ilock(dp);
    80005688:	ffffe097          	auipc	ra,0xffffe
    8000568c:	66c080e7          	jalr	1644(ra) # 80003cf4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005690:	4601                	li	a2,0
    80005692:	fb040593          	addi	a1,s0,-80
    80005696:	854a                	mv	a0,s2
    80005698:	fffff097          	auipc	ra,0xfffff
    8000569c:	b40080e7          	jalr	-1216(ra) # 800041d8 <dirlookup>
    800056a0:	84aa                	mv	s1,a0
    800056a2:	c921                	beqz	a0,800056f2 <create+0x94>
    iunlockput(dp);
    800056a4:	854a                	mv	a0,s2
    800056a6:	fffff097          	auipc	ra,0xfffff
    800056aa:	8b0080e7          	jalr	-1872(ra) # 80003f56 <iunlockput>
    ilock(ip);
    800056ae:	8526                	mv	a0,s1
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	644080e7          	jalr	1604(ra) # 80003cf4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056b8:	2981                	sext.w	s3,s3
    800056ba:	4789                	li	a5,2
    800056bc:	02f99463          	bne	s3,a5,800056e4 <create+0x86>
    800056c0:	0444d783          	lhu	a5,68(s1)
    800056c4:	37f9                	addiw	a5,a5,-2
    800056c6:	17c2                	slli	a5,a5,0x30
    800056c8:	93c1                	srli	a5,a5,0x30
    800056ca:	4705                	li	a4,1
    800056cc:	00f76c63          	bltu	a4,a5,800056e4 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800056d0:	8526                	mv	a0,s1
    800056d2:	60a6                	ld	ra,72(sp)
    800056d4:	6406                	ld	s0,64(sp)
    800056d6:	74e2                	ld	s1,56(sp)
    800056d8:	7942                	ld	s2,48(sp)
    800056da:	79a2                	ld	s3,40(sp)
    800056dc:	7a02                	ld	s4,32(sp)
    800056de:	6ae2                	ld	s5,24(sp)
    800056e0:	6161                	addi	sp,sp,80
    800056e2:	8082                	ret
    iunlockput(ip);
    800056e4:	8526                	mv	a0,s1
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	870080e7          	jalr	-1936(ra) # 80003f56 <iunlockput>
    return 0;
    800056ee:	4481                	li	s1,0
    800056f0:	b7c5                	j	800056d0 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800056f2:	85ce                	mv	a1,s3
    800056f4:	00092503          	lw	a0,0(s2)
    800056f8:	ffffe097          	auipc	ra,0xffffe
    800056fc:	464080e7          	jalr	1124(ra) # 80003b5c <ialloc>
    80005700:	84aa                	mv	s1,a0
    80005702:	c521                	beqz	a0,8000574a <create+0xec>
  ilock(ip);
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	5f0080e7          	jalr	1520(ra) # 80003cf4 <ilock>
  ip->major = major;
    8000570c:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005710:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005714:	4a05                	li	s4,1
    80005716:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000571a:	8526                	mv	a0,s1
    8000571c:	ffffe097          	auipc	ra,0xffffe
    80005720:	50e080e7          	jalr	1294(ra) # 80003c2a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005724:	2981                	sext.w	s3,s3
    80005726:	03498a63          	beq	s3,s4,8000575a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000572a:	40d0                	lw	a2,4(s1)
    8000572c:	fb040593          	addi	a1,s0,-80
    80005730:	854a                	mv	a0,s2
    80005732:	fffff097          	auipc	ra,0xfffff
    80005736:	cb6080e7          	jalr	-842(ra) # 800043e8 <dirlink>
    8000573a:	06054b63          	bltz	a0,800057b0 <create+0x152>
  iunlockput(dp);
    8000573e:	854a                	mv	a0,s2
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	816080e7          	jalr	-2026(ra) # 80003f56 <iunlockput>
  return ip;
    80005748:	b761                	j	800056d0 <create+0x72>
    panic("create: ialloc");
    8000574a:	00003517          	auipc	a0,0x3
    8000574e:	ffe50513          	addi	a0,a0,-2 # 80008748 <syscalls+0x2b8>
    80005752:	ffffb097          	auipc	ra,0xffffb
    80005756:	dd8080e7          	jalr	-552(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    8000575a:	04a95783          	lhu	a5,74(s2)
    8000575e:	2785                	addiw	a5,a5,1
    80005760:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005764:	854a                	mv	a0,s2
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	4c4080e7          	jalr	1220(ra) # 80003c2a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000576e:	40d0                	lw	a2,4(s1)
    80005770:	00003597          	auipc	a1,0x3
    80005774:	fe858593          	addi	a1,a1,-24 # 80008758 <syscalls+0x2c8>
    80005778:	8526                	mv	a0,s1
    8000577a:	fffff097          	auipc	ra,0xfffff
    8000577e:	c6e080e7          	jalr	-914(ra) # 800043e8 <dirlink>
    80005782:	00054f63          	bltz	a0,800057a0 <create+0x142>
    80005786:	00492603          	lw	a2,4(s2)
    8000578a:	00003597          	auipc	a1,0x3
    8000578e:	fd658593          	addi	a1,a1,-42 # 80008760 <syscalls+0x2d0>
    80005792:	8526                	mv	a0,s1
    80005794:	fffff097          	auipc	ra,0xfffff
    80005798:	c54080e7          	jalr	-940(ra) # 800043e8 <dirlink>
    8000579c:	f80557e3          	bgez	a0,8000572a <create+0xcc>
      panic("create dots");
    800057a0:	00003517          	auipc	a0,0x3
    800057a4:	fc850513          	addi	a0,a0,-56 # 80008768 <syscalls+0x2d8>
    800057a8:	ffffb097          	auipc	ra,0xffffb
    800057ac:	d82080e7          	jalr	-638(ra) # 8000052a <panic>
    panic("create: dirlink");
    800057b0:	00003517          	auipc	a0,0x3
    800057b4:	fc850513          	addi	a0,a0,-56 # 80008778 <syscalls+0x2e8>
    800057b8:	ffffb097          	auipc	ra,0xffffb
    800057bc:	d72080e7          	jalr	-654(ra) # 8000052a <panic>
    return 0;
    800057c0:	84aa                	mv	s1,a0
    800057c2:	b739                	j	800056d0 <create+0x72>

00000000800057c4 <sys_dup>:
{
    800057c4:	7179                	addi	sp,sp,-48
    800057c6:	f406                	sd	ra,40(sp)
    800057c8:	f022                	sd	s0,32(sp)
    800057ca:	ec26                	sd	s1,24(sp)
    800057cc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057ce:	fd840613          	addi	a2,s0,-40
    800057d2:	4581                	li	a1,0
    800057d4:	4501                	li	a0,0
    800057d6:	00000097          	auipc	ra,0x0
    800057da:	dde080e7          	jalr	-546(ra) # 800055b4 <argfd>
    return -1;
    800057de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057e0:	02054363          	bltz	a0,80005806 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800057e4:	fd843503          	ld	a0,-40(s0)
    800057e8:	00000097          	auipc	ra,0x0
    800057ec:	e34080e7          	jalr	-460(ra) # 8000561c <fdalloc>
    800057f0:	84aa                	mv	s1,a0
    return -1;
    800057f2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057f4:	00054963          	bltz	a0,80005806 <sys_dup+0x42>
  filedup(f);
    800057f8:	fd843503          	ld	a0,-40(s0)
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	348080e7          	jalr	840(ra) # 80004b44 <filedup>
  return fd;
    80005804:	87a6                	mv	a5,s1
}
    80005806:	853e                	mv	a0,a5
    80005808:	70a2                	ld	ra,40(sp)
    8000580a:	7402                	ld	s0,32(sp)
    8000580c:	64e2                	ld	s1,24(sp)
    8000580e:	6145                	addi	sp,sp,48
    80005810:	8082                	ret

0000000080005812 <sys_read>:
{
    80005812:	7179                	addi	sp,sp,-48
    80005814:	f406                	sd	ra,40(sp)
    80005816:	f022                	sd	s0,32(sp)
    80005818:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000581a:	fe840613          	addi	a2,s0,-24
    8000581e:	4581                	li	a1,0
    80005820:	4501                	li	a0,0
    80005822:	00000097          	auipc	ra,0x0
    80005826:	d92080e7          	jalr	-622(ra) # 800055b4 <argfd>
    return -1;
    8000582a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000582c:	04054163          	bltz	a0,8000586e <sys_read+0x5c>
    80005830:	fe440593          	addi	a1,s0,-28
    80005834:	4509                	li	a0,2
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	88a080e7          	jalr	-1910(ra) # 800030c0 <argint>
    return -1;
    8000583e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005840:	02054763          	bltz	a0,8000586e <sys_read+0x5c>
    80005844:	fd840593          	addi	a1,s0,-40
    80005848:	4505                	li	a0,1
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	898080e7          	jalr	-1896(ra) # 800030e2 <argaddr>
    return -1;
    80005852:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005854:	00054d63          	bltz	a0,8000586e <sys_read+0x5c>
  return fileread(f, p, n);
    80005858:	fe442603          	lw	a2,-28(s0)
    8000585c:	fd843583          	ld	a1,-40(s0)
    80005860:	fe843503          	ld	a0,-24(s0)
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	46c080e7          	jalr	1132(ra) # 80004cd0 <fileread>
    8000586c:	87aa                	mv	a5,a0
}
    8000586e:	853e                	mv	a0,a5
    80005870:	70a2                	ld	ra,40(sp)
    80005872:	7402                	ld	s0,32(sp)
    80005874:	6145                	addi	sp,sp,48
    80005876:	8082                	ret

0000000080005878 <sys_write>:
{
    80005878:	7179                	addi	sp,sp,-48
    8000587a:	f406                	sd	ra,40(sp)
    8000587c:	f022                	sd	s0,32(sp)
    8000587e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005880:	fe840613          	addi	a2,s0,-24
    80005884:	4581                	li	a1,0
    80005886:	4501                	li	a0,0
    80005888:	00000097          	auipc	ra,0x0
    8000588c:	d2c080e7          	jalr	-724(ra) # 800055b4 <argfd>
    return -1;
    80005890:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005892:	04054163          	bltz	a0,800058d4 <sys_write+0x5c>
    80005896:	fe440593          	addi	a1,s0,-28
    8000589a:	4509                	li	a0,2
    8000589c:	ffffe097          	auipc	ra,0xffffe
    800058a0:	824080e7          	jalr	-2012(ra) # 800030c0 <argint>
    return -1;
    800058a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058a6:	02054763          	bltz	a0,800058d4 <sys_write+0x5c>
    800058aa:	fd840593          	addi	a1,s0,-40
    800058ae:	4505                	li	a0,1
    800058b0:	ffffe097          	auipc	ra,0xffffe
    800058b4:	832080e7          	jalr	-1998(ra) # 800030e2 <argaddr>
    return -1;
    800058b8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058ba:	00054d63          	bltz	a0,800058d4 <sys_write+0x5c>
  return filewrite(f, p, n);
    800058be:	fe442603          	lw	a2,-28(s0)
    800058c2:	fd843583          	ld	a1,-40(s0)
    800058c6:	fe843503          	ld	a0,-24(s0)
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	4c8080e7          	jalr	1224(ra) # 80004d92 <filewrite>
    800058d2:	87aa                	mv	a5,a0
}
    800058d4:	853e                	mv	a0,a5
    800058d6:	70a2                	ld	ra,40(sp)
    800058d8:	7402                	ld	s0,32(sp)
    800058da:	6145                	addi	sp,sp,48
    800058dc:	8082                	ret

00000000800058de <sys_close>:
{
    800058de:	1101                	addi	sp,sp,-32
    800058e0:	ec06                	sd	ra,24(sp)
    800058e2:	e822                	sd	s0,16(sp)
    800058e4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058e6:	fe040613          	addi	a2,s0,-32
    800058ea:	fec40593          	addi	a1,s0,-20
    800058ee:	4501                	li	a0,0
    800058f0:	00000097          	auipc	ra,0x0
    800058f4:	cc4080e7          	jalr	-828(ra) # 800055b4 <argfd>
    return -1;
    800058f8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058fa:	02054463          	bltz	a0,80005922 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800058fe:	ffffc097          	auipc	ra,0xffffc
    80005902:	0b6080e7          	jalr	182(ra) # 800019b4 <myproc>
    80005906:	fec42783          	lw	a5,-20(s0)
    8000590a:	07e9                	addi	a5,a5,26
    8000590c:	078e                	slli	a5,a5,0x3
    8000590e:	97aa                	add	a5,a5,a0
    80005910:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005914:	fe043503          	ld	a0,-32(s0)
    80005918:	fffff097          	auipc	ra,0xfffff
    8000591c:	27e080e7          	jalr	638(ra) # 80004b96 <fileclose>
  return 0;
    80005920:	4781                	li	a5,0
}
    80005922:	853e                	mv	a0,a5
    80005924:	60e2                	ld	ra,24(sp)
    80005926:	6442                	ld	s0,16(sp)
    80005928:	6105                	addi	sp,sp,32
    8000592a:	8082                	ret

000000008000592c <sys_fstat>:
{
    8000592c:	1101                	addi	sp,sp,-32
    8000592e:	ec06                	sd	ra,24(sp)
    80005930:	e822                	sd	s0,16(sp)
    80005932:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005934:	fe840613          	addi	a2,s0,-24
    80005938:	4581                	li	a1,0
    8000593a:	4501                	li	a0,0
    8000593c:	00000097          	auipc	ra,0x0
    80005940:	c78080e7          	jalr	-904(ra) # 800055b4 <argfd>
    return -1;
    80005944:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005946:	02054563          	bltz	a0,80005970 <sys_fstat+0x44>
    8000594a:	fe040593          	addi	a1,s0,-32
    8000594e:	4505                	li	a0,1
    80005950:	ffffd097          	auipc	ra,0xffffd
    80005954:	792080e7          	jalr	1938(ra) # 800030e2 <argaddr>
    return -1;
    80005958:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000595a:	00054b63          	bltz	a0,80005970 <sys_fstat+0x44>
  return filestat(f, st);
    8000595e:	fe043583          	ld	a1,-32(s0)
    80005962:	fe843503          	ld	a0,-24(s0)
    80005966:	fffff097          	auipc	ra,0xfffff
    8000596a:	2f8080e7          	jalr	760(ra) # 80004c5e <filestat>
    8000596e:	87aa                	mv	a5,a0
}
    80005970:	853e                	mv	a0,a5
    80005972:	60e2                	ld	ra,24(sp)
    80005974:	6442                	ld	s0,16(sp)
    80005976:	6105                	addi	sp,sp,32
    80005978:	8082                	ret

000000008000597a <sys_link>:
{
    8000597a:	7169                	addi	sp,sp,-304
    8000597c:	f606                	sd	ra,296(sp)
    8000597e:	f222                	sd	s0,288(sp)
    80005980:	ee26                	sd	s1,280(sp)
    80005982:	ea4a                	sd	s2,272(sp)
    80005984:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005986:	08000613          	li	a2,128
    8000598a:	ed040593          	addi	a1,s0,-304
    8000598e:	4501                	li	a0,0
    80005990:	ffffd097          	auipc	ra,0xffffd
    80005994:	774080e7          	jalr	1908(ra) # 80003104 <argstr>
    return -1;
    80005998:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000599a:	10054e63          	bltz	a0,80005ab6 <sys_link+0x13c>
    8000599e:	08000613          	li	a2,128
    800059a2:	f5040593          	addi	a1,s0,-176
    800059a6:	4505                	li	a0,1
    800059a8:	ffffd097          	auipc	ra,0xffffd
    800059ac:	75c080e7          	jalr	1884(ra) # 80003104 <argstr>
    return -1;
    800059b0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059b2:	10054263          	bltz	a0,80005ab6 <sys_link+0x13c>
  begin_op();
    800059b6:	fffff097          	auipc	ra,0xfffff
    800059ba:	d14080e7          	jalr	-748(ra) # 800046ca <begin_op>
  if((ip = namei(old)) == 0){
    800059be:	ed040513          	addi	a0,s0,-304
    800059c2:	fffff097          	auipc	ra,0xfffff
    800059c6:	ae8080e7          	jalr	-1304(ra) # 800044aa <namei>
    800059ca:	84aa                	mv	s1,a0
    800059cc:	c551                	beqz	a0,80005a58 <sys_link+0xde>
  ilock(ip);
    800059ce:	ffffe097          	auipc	ra,0xffffe
    800059d2:	326080e7          	jalr	806(ra) # 80003cf4 <ilock>
  if(ip->type == T_DIR){
    800059d6:	04449703          	lh	a4,68(s1)
    800059da:	4785                	li	a5,1
    800059dc:	08f70463          	beq	a4,a5,80005a64 <sys_link+0xea>
  ip->nlink++;
    800059e0:	04a4d783          	lhu	a5,74(s1)
    800059e4:	2785                	addiw	a5,a5,1
    800059e6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059ea:	8526                	mv	a0,s1
    800059ec:	ffffe097          	auipc	ra,0xffffe
    800059f0:	23e080e7          	jalr	574(ra) # 80003c2a <iupdate>
  iunlock(ip);
    800059f4:	8526                	mv	a0,s1
    800059f6:	ffffe097          	auipc	ra,0xffffe
    800059fa:	3c0080e7          	jalr	960(ra) # 80003db6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800059fe:	fd040593          	addi	a1,s0,-48
    80005a02:	f5040513          	addi	a0,s0,-176
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	ac2080e7          	jalr	-1342(ra) # 800044c8 <nameiparent>
    80005a0e:	892a                	mv	s2,a0
    80005a10:	c935                	beqz	a0,80005a84 <sys_link+0x10a>
  ilock(dp);
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	2e2080e7          	jalr	738(ra) # 80003cf4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a1a:	00092703          	lw	a4,0(s2)
    80005a1e:	409c                	lw	a5,0(s1)
    80005a20:	04f71d63          	bne	a4,a5,80005a7a <sys_link+0x100>
    80005a24:	40d0                	lw	a2,4(s1)
    80005a26:	fd040593          	addi	a1,s0,-48
    80005a2a:	854a                	mv	a0,s2
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	9bc080e7          	jalr	-1604(ra) # 800043e8 <dirlink>
    80005a34:	04054363          	bltz	a0,80005a7a <sys_link+0x100>
  iunlockput(dp);
    80005a38:	854a                	mv	a0,s2
    80005a3a:	ffffe097          	auipc	ra,0xffffe
    80005a3e:	51c080e7          	jalr	1308(ra) # 80003f56 <iunlockput>
  iput(ip);
    80005a42:	8526                	mv	a0,s1
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	46a080e7          	jalr	1130(ra) # 80003eae <iput>
  end_op();
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	cfe080e7          	jalr	-770(ra) # 8000474a <end_op>
  return 0;
    80005a54:	4781                	li	a5,0
    80005a56:	a085                	j	80005ab6 <sys_link+0x13c>
    end_op();
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	cf2080e7          	jalr	-782(ra) # 8000474a <end_op>
    return -1;
    80005a60:	57fd                	li	a5,-1
    80005a62:	a891                	j	80005ab6 <sys_link+0x13c>
    iunlockput(ip);
    80005a64:	8526                	mv	a0,s1
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	4f0080e7          	jalr	1264(ra) # 80003f56 <iunlockput>
    end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	cdc080e7          	jalr	-804(ra) # 8000474a <end_op>
    return -1;
    80005a76:	57fd                	li	a5,-1
    80005a78:	a83d                	j	80005ab6 <sys_link+0x13c>
    iunlockput(dp);
    80005a7a:	854a                	mv	a0,s2
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	4da080e7          	jalr	1242(ra) # 80003f56 <iunlockput>
  ilock(ip);
    80005a84:	8526                	mv	a0,s1
    80005a86:	ffffe097          	auipc	ra,0xffffe
    80005a8a:	26e080e7          	jalr	622(ra) # 80003cf4 <ilock>
  ip->nlink--;
    80005a8e:	04a4d783          	lhu	a5,74(s1)
    80005a92:	37fd                	addiw	a5,a5,-1
    80005a94:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a98:	8526                	mv	a0,s1
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	190080e7          	jalr	400(ra) # 80003c2a <iupdate>
  iunlockput(ip);
    80005aa2:	8526                	mv	a0,s1
    80005aa4:	ffffe097          	auipc	ra,0xffffe
    80005aa8:	4b2080e7          	jalr	1202(ra) # 80003f56 <iunlockput>
  end_op();
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	c9e080e7          	jalr	-866(ra) # 8000474a <end_op>
  return -1;
    80005ab4:	57fd                	li	a5,-1
}
    80005ab6:	853e                	mv	a0,a5
    80005ab8:	70b2                	ld	ra,296(sp)
    80005aba:	7412                	ld	s0,288(sp)
    80005abc:	64f2                	ld	s1,280(sp)
    80005abe:	6952                	ld	s2,272(sp)
    80005ac0:	6155                	addi	sp,sp,304
    80005ac2:	8082                	ret

0000000080005ac4 <sys_unlink>:
{
    80005ac4:	7151                	addi	sp,sp,-240
    80005ac6:	f586                	sd	ra,232(sp)
    80005ac8:	f1a2                	sd	s0,224(sp)
    80005aca:	eda6                	sd	s1,216(sp)
    80005acc:	e9ca                	sd	s2,208(sp)
    80005ace:	e5ce                	sd	s3,200(sp)
    80005ad0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005ad2:	08000613          	li	a2,128
    80005ad6:	f3040593          	addi	a1,s0,-208
    80005ada:	4501                	li	a0,0
    80005adc:	ffffd097          	auipc	ra,0xffffd
    80005ae0:	628080e7          	jalr	1576(ra) # 80003104 <argstr>
    80005ae4:	18054163          	bltz	a0,80005c66 <sys_unlink+0x1a2>
  begin_op();
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	be2080e7          	jalr	-1054(ra) # 800046ca <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005af0:	fb040593          	addi	a1,s0,-80
    80005af4:	f3040513          	addi	a0,s0,-208
    80005af8:	fffff097          	auipc	ra,0xfffff
    80005afc:	9d0080e7          	jalr	-1584(ra) # 800044c8 <nameiparent>
    80005b00:	84aa                	mv	s1,a0
    80005b02:	c979                	beqz	a0,80005bd8 <sys_unlink+0x114>
  ilock(dp);
    80005b04:	ffffe097          	auipc	ra,0xffffe
    80005b08:	1f0080e7          	jalr	496(ra) # 80003cf4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b0c:	00003597          	auipc	a1,0x3
    80005b10:	c4c58593          	addi	a1,a1,-948 # 80008758 <syscalls+0x2c8>
    80005b14:	fb040513          	addi	a0,s0,-80
    80005b18:	ffffe097          	auipc	ra,0xffffe
    80005b1c:	6a6080e7          	jalr	1702(ra) # 800041be <namecmp>
    80005b20:	14050a63          	beqz	a0,80005c74 <sys_unlink+0x1b0>
    80005b24:	00003597          	auipc	a1,0x3
    80005b28:	c3c58593          	addi	a1,a1,-964 # 80008760 <syscalls+0x2d0>
    80005b2c:	fb040513          	addi	a0,s0,-80
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	68e080e7          	jalr	1678(ra) # 800041be <namecmp>
    80005b38:	12050e63          	beqz	a0,80005c74 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b3c:	f2c40613          	addi	a2,s0,-212
    80005b40:	fb040593          	addi	a1,s0,-80
    80005b44:	8526                	mv	a0,s1
    80005b46:	ffffe097          	auipc	ra,0xffffe
    80005b4a:	692080e7          	jalr	1682(ra) # 800041d8 <dirlookup>
    80005b4e:	892a                	mv	s2,a0
    80005b50:	12050263          	beqz	a0,80005c74 <sys_unlink+0x1b0>
  ilock(ip);
    80005b54:	ffffe097          	auipc	ra,0xffffe
    80005b58:	1a0080e7          	jalr	416(ra) # 80003cf4 <ilock>
  if(ip->nlink < 1)
    80005b5c:	04a91783          	lh	a5,74(s2)
    80005b60:	08f05263          	blez	a5,80005be4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b64:	04491703          	lh	a4,68(s2)
    80005b68:	4785                	li	a5,1
    80005b6a:	08f70563          	beq	a4,a5,80005bf4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b6e:	4641                	li	a2,16
    80005b70:	4581                	li	a1,0
    80005b72:	fc040513          	addi	a0,s0,-64
    80005b76:	ffffb097          	auipc	ra,0xffffb
    80005b7a:	148080e7          	jalr	328(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b7e:	4741                	li	a4,16
    80005b80:	f2c42683          	lw	a3,-212(s0)
    80005b84:	fc040613          	addi	a2,s0,-64
    80005b88:	4581                	li	a1,0
    80005b8a:	8526                	mv	a0,s1
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	514080e7          	jalr	1300(ra) # 800040a0 <writei>
    80005b94:	47c1                	li	a5,16
    80005b96:	0af51563          	bne	a0,a5,80005c40 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b9a:	04491703          	lh	a4,68(s2)
    80005b9e:	4785                	li	a5,1
    80005ba0:	0af70863          	beq	a4,a5,80005c50 <sys_unlink+0x18c>
  iunlockput(dp);
    80005ba4:	8526                	mv	a0,s1
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	3b0080e7          	jalr	944(ra) # 80003f56 <iunlockput>
  ip->nlink--;
    80005bae:	04a95783          	lhu	a5,74(s2)
    80005bb2:	37fd                	addiw	a5,a5,-1
    80005bb4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005bb8:	854a                	mv	a0,s2
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	070080e7          	jalr	112(ra) # 80003c2a <iupdate>
  iunlockput(ip);
    80005bc2:	854a                	mv	a0,s2
    80005bc4:	ffffe097          	auipc	ra,0xffffe
    80005bc8:	392080e7          	jalr	914(ra) # 80003f56 <iunlockput>
  end_op();
    80005bcc:	fffff097          	auipc	ra,0xfffff
    80005bd0:	b7e080e7          	jalr	-1154(ra) # 8000474a <end_op>
  return 0;
    80005bd4:	4501                	li	a0,0
    80005bd6:	a84d                	j	80005c88 <sys_unlink+0x1c4>
    end_op();
    80005bd8:	fffff097          	auipc	ra,0xfffff
    80005bdc:	b72080e7          	jalr	-1166(ra) # 8000474a <end_op>
    return -1;
    80005be0:	557d                	li	a0,-1
    80005be2:	a05d                	j	80005c88 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005be4:	00003517          	auipc	a0,0x3
    80005be8:	ba450513          	addi	a0,a0,-1116 # 80008788 <syscalls+0x2f8>
    80005bec:	ffffb097          	auipc	ra,0xffffb
    80005bf0:	93e080e7          	jalr	-1730(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bf4:	04c92703          	lw	a4,76(s2)
    80005bf8:	02000793          	li	a5,32
    80005bfc:	f6e7f9e3          	bgeu	a5,a4,80005b6e <sys_unlink+0xaa>
    80005c00:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c04:	4741                	li	a4,16
    80005c06:	86ce                	mv	a3,s3
    80005c08:	f1840613          	addi	a2,s0,-232
    80005c0c:	4581                	li	a1,0
    80005c0e:	854a                	mv	a0,s2
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	398080e7          	jalr	920(ra) # 80003fa8 <readi>
    80005c18:	47c1                	li	a5,16
    80005c1a:	00f51b63          	bne	a0,a5,80005c30 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005c1e:	f1845783          	lhu	a5,-232(s0)
    80005c22:	e7a1                	bnez	a5,80005c6a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c24:	29c1                	addiw	s3,s3,16
    80005c26:	04c92783          	lw	a5,76(s2)
    80005c2a:	fcf9ede3          	bltu	s3,a5,80005c04 <sys_unlink+0x140>
    80005c2e:	b781                	j	80005b6e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c30:	00003517          	auipc	a0,0x3
    80005c34:	b7050513          	addi	a0,a0,-1168 # 800087a0 <syscalls+0x310>
    80005c38:	ffffb097          	auipc	ra,0xffffb
    80005c3c:	8f2080e7          	jalr	-1806(ra) # 8000052a <panic>
    panic("unlink: writei");
    80005c40:	00003517          	auipc	a0,0x3
    80005c44:	b7850513          	addi	a0,a0,-1160 # 800087b8 <syscalls+0x328>
    80005c48:	ffffb097          	auipc	ra,0xffffb
    80005c4c:	8e2080e7          	jalr	-1822(ra) # 8000052a <panic>
    dp->nlink--;
    80005c50:	04a4d783          	lhu	a5,74(s1)
    80005c54:	37fd                	addiw	a5,a5,-1
    80005c56:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c5a:	8526                	mv	a0,s1
    80005c5c:	ffffe097          	auipc	ra,0xffffe
    80005c60:	fce080e7          	jalr	-50(ra) # 80003c2a <iupdate>
    80005c64:	b781                	j	80005ba4 <sys_unlink+0xe0>
    return -1;
    80005c66:	557d                	li	a0,-1
    80005c68:	a005                	j	80005c88 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c6a:	854a                	mv	a0,s2
    80005c6c:	ffffe097          	auipc	ra,0xffffe
    80005c70:	2ea080e7          	jalr	746(ra) # 80003f56 <iunlockput>
  iunlockput(dp);
    80005c74:	8526                	mv	a0,s1
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	2e0080e7          	jalr	736(ra) # 80003f56 <iunlockput>
  end_op();
    80005c7e:	fffff097          	auipc	ra,0xfffff
    80005c82:	acc080e7          	jalr	-1332(ra) # 8000474a <end_op>
  return -1;
    80005c86:	557d                	li	a0,-1
}
    80005c88:	70ae                	ld	ra,232(sp)
    80005c8a:	740e                	ld	s0,224(sp)
    80005c8c:	64ee                	ld	s1,216(sp)
    80005c8e:	694e                	ld	s2,208(sp)
    80005c90:	69ae                	ld	s3,200(sp)
    80005c92:	616d                	addi	sp,sp,240
    80005c94:	8082                	ret

0000000080005c96 <sys_open>:

uint64
sys_open(void)
{
    80005c96:	7131                	addi	sp,sp,-192
    80005c98:	fd06                	sd	ra,184(sp)
    80005c9a:	f922                	sd	s0,176(sp)
    80005c9c:	f526                	sd	s1,168(sp)
    80005c9e:	f14a                	sd	s2,160(sp)
    80005ca0:	ed4e                	sd	s3,152(sp)
    80005ca2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005ca4:	08000613          	li	a2,128
    80005ca8:	f5040593          	addi	a1,s0,-176
    80005cac:	4501                	li	a0,0
    80005cae:	ffffd097          	auipc	ra,0xffffd
    80005cb2:	456080e7          	jalr	1110(ra) # 80003104 <argstr>
    return -1;
    80005cb6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005cb8:	0c054163          	bltz	a0,80005d7a <sys_open+0xe4>
    80005cbc:	f4c40593          	addi	a1,s0,-180
    80005cc0:	4505                	li	a0,1
    80005cc2:	ffffd097          	auipc	ra,0xffffd
    80005cc6:	3fe080e7          	jalr	1022(ra) # 800030c0 <argint>
    80005cca:	0a054863          	bltz	a0,80005d7a <sys_open+0xe4>

  begin_op();
    80005cce:	fffff097          	auipc	ra,0xfffff
    80005cd2:	9fc080e7          	jalr	-1540(ra) # 800046ca <begin_op>

  if(omode & O_CREATE){
    80005cd6:	f4c42783          	lw	a5,-180(s0)
    80005cda:	2007f793          	andi	a5,a5,512
    80005cde:	cbdd                	beqz	a5,80005d94 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005ce0:	4681                	li	a3,0
    80005ce2:	4601                	li	a2,0
    80005ce4:	4589                	li	a1,2
    80005ce6:	f5040513          	addi	a0,s0,-176
    80005cea:	00000097          	auipc	ra,0x0
    80005cee:	974080e7          	jalr	-1676(ra) # 8000565e <create>
    80005cf2:	892a                	mv	s2,a0
    if(ip == 0){
    80005cf4:	c959                	beqz	a0,80005d8a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005cf6:	04491703          	lh	a4,68(s2)
    80005cfa:	478d                	li	a5,3
    80005cfc:	00f71763          	bne	a4,a5,80005d0a <sys_open+0x74>
    80005d00:	04695703          	lhu	a4,70(s2)
    80005d04:	47a5                	li	a5,9
    80005d06:	0ce7ec63          	bltu	a5,a4,80005dde <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d0a:	fffff097          	auipc	ra,0xfffff
    80005d0e:	dd0080e7          	jalr	-560(ra) # 80004ada <filealloc>
    80005d12:	89aa                	mv	s3,a0
    80005d14:	10050263          	beqz	a0,80005e18 <sys_open+0x182>
    80005d18:	00000097          	auipc	ra,0x0
    80005d1c:	904080e7          	jalr	-1788(ra) # 8000561c <fdalloc>
    80005d20:	84aa                	mv	s1,a0
    80005d22:	0e054663          	bltz	a0,80005e0e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d26:	04491703          	lh	a4,68(s2)
    80005d2a:	478d                	li	a5,3
    80005d2c:	0cf70463          	beq	a4,a5,80005df4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d30:	4789                	li	a5,2
    80005d32:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d36:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d3a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d3e:	f4c42783          	lw	a5,-180(s0)
    80005d42:	0017c713          	xori	a4,a5,1
    80005d46:	8b05                	andi	a4,a4,1
    80005d48:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d4c:	0037f713          	andi	a4,a5,3
    80005d50:	00e03733          	snez	a4,a4
    80005d54:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d58:	4007f793          	andi	a5,a5,1024
    80005d5c:	c791                	beqz	a5,80005d68 <sys_open+0xd2>
    80005d5e:	04491703          	lh	a4,68(s2)
    80005d62:	4789                	li	a5,2
    80005d64:	08f70f63          	beq	a4,a5,80005e02 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d68:	854a                	mv	a0,s2
    80005d6a:	ffffe097          	auipc	ra,0xffffe
    80005d6e:	04c080e7          	jalr	76(ra) # 80003db6 <iunlock>
  end_op();
    80005d72:	fffff097          	auipc	ra,0xfffff
    80005d76:	9d8080e7          	jalr	-1576(ra) # 8000474a <end_op>

  return fd;
}
    80005d7a:	8526                	mv	a0,s1
    80005d7c:	70ea                	ld	ra,184(sp)
    80005d7e:	744a                	ld	s0,176(sp)
    80005d80:	74aa                	ld	s1,168(sp)
    80005d82:	790a                	ld	s2,160(sp)
    80005d84:	69ea                	ld	s3,152(sp)
    80005d86:	6129                	addi	sp,sp,192
    80005d88:	8082                	ret
      end_op();
    80005d8a:	fffff097          	auipc	ra,0xfffff
    80005d8e:	9c0080e7          	jalr	-1600(ra) # 8000474a <end_op>
      return -1;
    80005d92:	b7e5                	j	80005d7a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d94:	f5040513          	addi	a0,s0,-176
    80005d98:	ffffe097          	auipc	ra,0xffffe
    80005d9c:	712080e7          	jalr	1810(ra) # 800044aa <namei>
    80005da0:	892a                	mv	s2,a0
    80005da2:	c905                	beqz	a0,80005dd2 <sys_open+0x13c>
    ilock(ip);
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	f50080e7          	jalr	-176(ra) # 80003cf4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005dac:	04491703          	lh	a4,68(s2)
    80005db0:	4785                	li	a5,1
    80005db2:	f4f712e3          	bne	a4,a5,80005cf6 <sys_open+0x60>
    80005db6:	f4c42783          	lw	a5,-180(s0)
    80005dba:	dba1                	beqz	a5,80005d0a <sys_open+0x74>
      iunlockput(ip);
    80005dbc:	854a                	mv	a0,s2
    80005dbe:	ffffe097          	auipc	ra,0xffffe
    80005dc2:	198080e7          	jalr	408(ra) # 80003f56 <iunlockput>
      end_op();
    80005dc6:	fffff097          	auipc	ra,0xfffff
    80005dca:	984080e7          	jalr	-1660(ra) # 8000474a <end_op>
      return -1;
    80005dce:	54fd                	li	s1,-1
    80005dd0:	b76d                	j	80005d7a <sys_open+0xe4>
      end_op();
    80005dd2:	fffff097          	auipc	ra,0xfffff
    80005dd6:	978080e7          	jalr	-1672(ra) # 8000474a <end_op>
      return -1;
    80005dda:	54fd                	li	s1,-1
    80005ddc:	bf79                	j	80005d7a <sys_open+0xe4>
    iunlockput(ip);
    80005dde:	854a                	mv	a0,s2
    80005de0:	ffffe097          	auipc	ra,0xffffe
    80005de4:	176080e7          	jalr	374(ra) # 80003f56 <iunlockput>
    end_op();
    80005de8:	fffff097          	auipc	ra,0xfffff
    80005dec:	962080e7          	jalr	-1694(ra) # 8000474a <end_op>
    return -1;
    80005df0:	54fd                	li	s1,-1
    80005df2:	b761                	j	80005d7a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005df4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005df8:	04691783          	lh	a5,70(s2)
    80005dfc:	02f99223          	sh	a5,36(s3)
    80005e00:	bf2d                	j	80005d3a <sys_open+0xa4>
    itrunc(ip);
    80005e02:	854a                	mv	a0,s2
    80005e04:	ffffe097          	auipc	ra,0xffffe
    80005e08:	ffe080e7          	jalr	-2(ra) # 80003e02 <itrunc>
    80005e0c:	bfb1                	j	80005d68 <sys_open+0xd2>
      fileclose(f);
    80005e0e:	854e                	mv	a0,s3
    80005e10:	fffff097          	auipc	ra,0xfffff
    80005e14:	d86080e7          	jalr	-634(ra) # 80004b96 <fileclose>
    iunlockput(ip);
    80005e18:	854a                	mv	a0,s2
    80005e1a:	ffffe097          	auipc	ra,0xffffe
    80005e1e:	13c080e7          	jalr	316(ra) # 80003f56 <iunlockput>
    end_op();
    80005e22:	fffff097          	auipc	ra,0xfffff
    80005e26:	928080e7          	jalr	-1752(ra) # 8000474a <end_op>
    return -1;
    80005e2a:	54fd                	li	s1,-1
    80005e2c:	b7b9                	j	80005d7a <sys_open+0xe4>

0000000080005e2e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e2e:	7175                	addi	sp,sp,-144
    80005e30:	e506                	sd	ra,136(sp)
    80005e32:	e122                	sd	s0,128(sp)
    80005e34:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e36:	fffff097          	auipc	ra,0xfffff
    80005e3a:	894080e7          	jalr	-1900(ra) # 800046ca <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e3e:	08000613          	li	a2,128
    80005e42:	f7040593          	addi	a1,s0,-144
    80005e46:	4501                	li	a0,0
    80005e48:	ffffd097          	auipc	ra,0xffffd
    80005e4c:	2bc080e7          	jalr	700(ra) # 80003104 <argstr>
    80005e50:	02054963          	bltz	a0,80005e82 <sys_mkdir+0x54>
    80005e54:	4681                	li	a3,0
    80005e56:	4601                	li	a2,0
    80005e58:	4585                	li	a1,1
    80005e5a:	f7040513          	addi	a0,s0,-144
    80005e5e:	00000097          	auipc	ra,0x0
    80005e62:	800080e7          	jalr	-2048(ra) # 8000565e <create>
    80005e66:	cd11                	beqz	a0,80005e82 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e68:	ffffe097          	auipc	ra,0xffffe
    80005e6c:	0ee080e7          	jalr	238(ra) # 80003f56 <iunlockput>
  end_op();
    80005e70:	fffff097          	auipc	ra,0xfffff
    80005e74:	8da080e7          	jalr	-1830(ra) # 8000474a <end_op>
  return 0;
    80005e78:	4501                	li	a0,0
}
    80005e7a:	60aa                	ld	ra,136(sp)
    80005e7c:	640a                	ld	s0,128(sp)
    80005e7e:	6149                	addi	sp,sp,144
    80005e80:	8082                	ret
    end_op();
    80005e82:	fffff097          	auipc	ra,0xfffff
    80005e86:	8c8080e7          	jalr	-1848(ra) # 8000474a <end_op>
    return -1;
    80005e8a:	557d                	li	a0,-1
    80005e8c:	b7fd                	j	80005e7a <sys_mkdir+0x4c>

0000000080005e8e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e8e:	7135                	addi	sp,sp,-160
    80005e90:	ed06                	sd	ra,152(sp)
    80005e92:	e922                	sd	s0,144(sp)
    80005e94:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	834080e7          	jalr	-1996(ra) # 800046ca <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e9e:	08000613          	li	a2,128
    80005ea2:	f7040593          	addi	a1,s0,-144
    80005ea6:	4501                	li	a0,0
    80005ea8:	ffffd097          	auipc	ra,0xffffd
    80005eac:	25c080e7          	jalr	604(ra) # 80003104 <argstr>
    80005eb0:	04054a63          	bltz	a0,80005f04 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005eb4:	f6c40593          	addi	a1,s0,-148
    80005eb8:	4505                	li	a0,1
    80005eba:	ffffd097          	auipc	ra,0xffffd
    80005ebe:	206080e7          	jalr	518(ra) # 800030c0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ec2:	04054163          	bltz	a0,80005f04 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ec6:	f6840593          	addi	a1,s0,-152
    80005eca:	4509                	li	a0,2
    80005ecc:	ffffd097          	auipc	ra,0xffffd
    80005ed0:	1f4080e7          	jalr	500(ra) # 800030c0 <argint>
     argint(1, &major) < 0 ||
    80005ed4:	02054863          	bltz	a0,80005f04 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ed8:	f6841683          	lh	a3,-152(s0)
    80005edc:	f6c41603          	lh	a2,-148(s0)
    80005ee0:	458d                	li	a1,3
    80005ee2:	f7040513          	addi	a0,s0,-144
    80005ee6:	fffff097          	auipc	ra,0xfffff
    80005eea:	778080e7          	jalr	1912(ra) # 8000565e <create>
     argint(2, &minor) < 0 ||
    80005eee:	c919                	beqz	a0,80005f04 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ef0:	ffffe097          	auipc	ra,0xffffe
    80005ef4:	066080e7          	jalr	102(ra) # 80003f56 <iunlockput>
  end_op();
    80005ef8:	fffff097          	auipc	ra,0xfffff
    80005efc:	852080e7          	jalr	-1966(ra) # 8000474a <end_op>
  return 0;
    80005f00:	4501                	li	a0,0
    80005f02:	a031                	j	80005f0e <sys_mknod+0x80>
    end_op();
    80005f04:	fffff097          	auipc	ra,0xfffff
    80005f08:	846080e7          	jalr	-1978(ra) # 8000474a <end_op>
    return -1;
    80005f0c:	557d                	li	a0,-1
}
    80005f0e:	60ea                	ld	ra,152(sp)
    80005f10:	644a                	ld	s0,144(sp)
    80005f12:	610d                	addi	sp,sp,160
    80005f14:	8082                	ret

0000000080005f16 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f16:	7135                	addi	sp,sp,-160
    80005f18:	ed06                	sd	ra,152(sp)
    80005f1a:	e922                	sd	s0,144(sp)
    80005f1c:	e526                	sd	s1,136(sp)
    80005f1e:	e14a                	sd	s2,128(sp)
    80005f20:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f22:	ffffc097          	auipc	ra,0xffffc
    80005f26:	a92080e7          	jalr	-1390(ra) # 800019b4 <myproc>
    80005f2a:	892a                	mv	s2,a0
  
  begin_op();
    80005f2c:	ffffe097          	auipc	ra,0xffffe
    80005f30:	79e080e7          	jalr	1950(ra) # 800046ca <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f34:	08000613          	li	a2,128
    80005f38:	f6040593          	addi	a1,s0,-160
    80005f3c:	4501                	li	a0,0
    80005f3e:	ffffd097          	auipc	ra,0xffffd
    80005f42:	1c6080e7          	jalr	454(ra) # 80003104 <argstr>
    80005f46:	04054b63          	bltz	a0,80005f9c <sys_chdir+0x86>
    80005f4a:	f6040513          	addi	a0,s0,-160
    80005f4e:	ffffe097          	auipc	ra,0xffffe
    80005f52:	55c080e7          	jalr	1372(ra) # 800044aa <namei>
    80005f56:	84aa                	mv	s1,a0
    80005f58:	c131                	beqz	a0,80005f9c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f5a:	ffffe097          	auipc	ra,0xffffe
    80005f5e:	d9a080e7          	jalr	-614(ra) # 80003cf4 <ilock>
  if(ip->type != T_DIR){
    80005f62:	04449703          	lh	a4,68(s1)
    80005f66:	4785                	li	a5,1
    80005f68:	04f71063          	bne	a4,a5,80005fa8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f6c:	8526                	mv	a0,s1
    80005f6e:	ffffe097          	auipc	ra,0xffffe
    80005f72:	e48080e7          	jalr	-440(ra) # 80003db6 <iunlock>
  iput(p->cwd);
    80005f76:	15093503          	ld	a0,336(s2)
    80005f7a:	ffffe097          	auipc	ra,0xffffe
    80005f7e:	f34080e7          	jalr	-204(ra) # 80003eae <iput>
  end_op();
    80005f82:	ffffe097          	auipc	ra,0xffffe
    80005f86:	7c8080e7          	jalr	1992(ra) # 8000474a <end_op>
  p->cwd = ip;
    80005f8a:	14993823          	sd	s1,336(s2)
  return 0;
    80005f8e:	4501                	li	a0,0
}
    80005f90:	60ea                	ld	ra,152(sp)
    80005f92:	644a                	ld	s0,144(sp)
    80005f94:	64aa                	ld	s1,136(sp)
    80005f96:	690a                	ld	s2,128(sp)
    80005f98:	610d                	addi	sp,sp,160
    80005f9a:	8082                	ret
    end_op();
    80005f9c:	ffffe097          	auipc	ra,0xffffe
    80005fa0:	7ae080e7          	jalr	1966(ra) # 8000474a <end_op>
    return -1;
    80005fa4:	557d                	li	a0,-1
    80005fa6:	b7ed                	j	80005f90 <sys_chdir+0x7a>
    iunlockput(ip);
    80005fa8:	8526                	mv	a0,s1
    80005faa:	ffffe097          	auipc	ra,0xffffe
    80005fae:	fac080e7          	jalr	-84(ra) # 80003f56 <iunlockput>
    end_op();
    80005fb2:	ffffe097          	auipc	ra,0xffffe
    80005fb6:	798080e7          	jalr	1944(ra) # 8000474a <end_op>
    return -1;
    80005fba:	557d                	li	a0,-1
    80005fbc:	bfd1                	j	80005f90 <sys_chdir+0x7a>

0000000080005fbe <sys_exec>:

uint64
sys_exec(void)
{
    80005fbe:	7145                	addi	sp,sp,-464
    80005fc0:	e786                	sd	ra,456(sp)
    80005fc2:	e3a2                	sd	s0,448(sp)
    80005fc4:	ff26                	sd	s1,440(sp)
    80005fc6:	fb4a                	sd	s2,432(sp)
    80005fc8:	f74e                	sd	s3,424(sp)
    80005fca:	f352                	sd	s4,416(sp)
    80005fcc:	ef56                	sd	s5,408(sp)
    80005fce:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005fd0:	08000613          	li	a2,128
    80005fd4:	f4040593          	addi	a1,s0,-192
    80005fd8:	4501                	li	a0,0
    80005fda:	ffffd097          	auipc	ra,0xffffd
    80005fde:	12a080e7          	jalr	298(ra) # 80003104 <argstr>
    return -1;
    80005fe2:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005fe4:	0c054a63          	bltz	a0,800060b8 <sys_exec+0xfa>
    80005fe8:	e3840593          	addi	a1,s0,-456
    80005fec:	4505                	li	a0,1
    80005fee:	ffffd097          	auipc	ra,0xffffd
    80005ff2:	0f4080e7          	jalr	244(ra) # 800030e2 <argaddr>
    80005ff6:	0c054163          	bltz	a0,800060b8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005ffa:	10000613          	li	a2,256
    80005ffe:	4581                	li	a1,0
    80006000:	e4040513          	addi	a0,s0,-448
    80006004:	ffffb097          	auipc	ra,0xffffb
    80006008:	cba080e7          	jalr	-838(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000600c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006010:	89a6                	mv	s3,s1
    80006012:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006014:	02000a13          	li	s4,32
    80006018:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000601c:	00391793          	slli	a5,s2,0x3
    80006020:	e3040593          	addi	a1,s0,-464
    80006024:	e3843503          	ld	a0,-456(s0)
    80006028:	953e                	add	a0,a0,a5
    8000602a:	ffffd097          	auipc	ra,0xffffd
    8000602e:	ffc080e7          	jalr	-4(ra) # 80003026 <fetchaddr>
    80006032:	02054a63          	bltz	a0,80006066 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006036:	e3043783          	ld	a5,-464(s0)
    8000603a:	c3b9                	beqz	a5,80006080 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000603c:	ffffb097          	auipc	ra,0xffffb
    80006040:	a96080e7          	jalr	-1386(ra) # 80000ad2 <kalloc>
    80006044:	85aa                	mv	a1,a0
    80006046:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000604a:	cd11                	beqz	a0,80006066 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000604c:	6605                	lui	a2,0x1
    8000604e:	e3043503          	ld	a0,-464(s0)
    80006052:	ffffd097          	auipc	ra,0xffffd
    80006056:	026080e7          	jalr	38(ra) # 80003078 <fetchstr>
    8000605a:	00054663          	bltz	a0,80006066 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    8000605e:	0905                	addi	s2,s2,1
    80006060:	09a1                	addi	s3,s3,8
    80006062:	fb491be3          	bne	s2,s4,80006018 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006066:	10048913          	addi	s2,s1,256
    8000606a:	6088                	ld	a0,0(s1)
    8000606c:	c529                	beqz	a0,800060b6 <sys_exec+0xf8>
    kfree(argv[i]);
    8000606e:	ffffb097          	auipc	ra,0xffffb
    80006072:	968080e7          	jalr	-1688(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006076:	04a1                	addi	s1,s1,8
    80006078:	ff2499e3          	bne	s1,s2,8000606a <sys_exec+0xac>
  return -1;
    8000607c:	597d                	li	s2,-1
    8000607e:	a82d                	j	800060b8 <sys_exec+0xfa>
      argv[i] = 0;
    80006080:	0a8e                	slli	s5,s5,0x3
    80006082:	fc040793          	addi	a5,s0,-64
    80006086:	9abe                	add	s5,s5,a5
    80006088:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd2e80>
  int ret = exec(path, argv);
    8000608c:	e4040593          	addi	a1,s0,-448
    80006090:	f4040513          	addi	a0,s0,-192
    80006094:	fffff097          	auipc	ra,0xfffff
    80006098:	154080e7          	jalr	340(ra) # 800051e8 <exec>
    8000609c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000609e:	10048993          	addi	s3,s1,256
    800060a2:	6088                	ld	a0,0(s1)
    800060a4:	c911                	beqz	a0,800060b8 <sys_exec+0xfa>
    kfree(argv[i]);
    800060a6:	ffffb097          	auipc	ra,0xffffb
    800060aa:	930080e7          	jalr	-1744(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060ae:	04a1                	addi	s1,s1,8
    800060b0:	ff3499e3          	bne	s1,s3,800060a2 <sys_exec+0xe4>
    800060b4:	a011                	j	800060b8 <sys_exec+0xfa>
  return -1;
    800060b6:	597d                	li	s2,-1
}
    800060b8:	854a                	mv	a0,s2
    800060ba:	60be                	ld	ra,456(sp)
    800060bc:	641e                	ld	s0,448(sp)
    800060be:	74fa                	ld	s1,440(sp)
    800060c0:	795a                	ld	s2,432(sp)
    800060c2:	79ba                	ld	s3,424(sp)
    800060c4:	7a1a                	ld	s4,416(sp)
    800060c6:	6afa                	ld	s5,408(sp)
    800060c8:	6179                	addi	sp,sp,464
    800060ca:	8082                	ret

00000000800060cc <sys_pipe>:

uint64
sys_pipe(void)
{
    800060cc:	7139                	addi	sp,sp,-64
    800060ce:	fc06                	sd	ra,56(sp)
    800060d0:	f822                	sd	s0,48(sp)
    800060d2:	f426                	sd	s1,40(sp)
    800060d4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800060d6:	ffffc097          	auipc	ra,0xffffc
    800060da:	8de080e7          	jalr	-1826(ra) # 800019b4 <myproc>
    800060de:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800060e0:	fd840593          	addi	a1,s0,-40
    800060e4:	4501                	li	a0,0
    800060e6:	ffffd097          	auipc	ra,0xffffd
    800060ea:	ffc080e7          	jalr	-4(ra) # 800030e2 <argaddr>
    return -1;
    800060ee:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800060f0:	0e054063          	bltz	a0,800061d0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800060f4:	fc840593          	addi	a1,s0,-56
    800060f8:	fd040513          	addi	a0,s0,-48
    800060fc:	fffff097          	auipc	ra,0xfffff
    80006100:	dca080e7          	jalr	-566(ra) # 80004ec6 <pipealloc>
    return -1;
    80006104:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006106:	0c054563          	bltz	a0,800061d0 <sys_pipe+0x104>
  fd0 = -1;
    8000610a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000610e:	fd043503          	ld	a0,-48(s0)
    80006112:	fffff097          	auipc	ra,0xfffff
    80006116:	50a080e7          	jalr	1290(ra) # 8000561c <fdalloc>
    8000611a:	fca42223          	sw	a0,-60(s0)
    8000611e:	08054c63          	bltz	a0,800061b6 <sys_pipe+0xea>
    80006122:	fc843503          	ld	a0,-56(s0)
    80006126:	fffff097          	auipc	ra,0xfffff
    8000612a:	4f6080e7          	jalr	1270(ra) # 8000561c <fdalloc>
    8000612e:	fca42023          	sw	a0,-64(s0)
    80006132:	06054863          	bltz	a0,800061a2 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006136:	4691                	li	a3,4
    80006138:	fc440613          	addi	a2,s0,-60
    8000613c:	fd843583          	ld	a1,-40(s0)
    80006140:	68a8                	ld	a0,80(s1)
    80006142:	ffffb097          	auipc	ra,0xffffb
    80006146:	4fc080e7          	jalr	1276(ra) # 8000163e <copyout>
    8000614a:	02054063          	bltz	a0,8000616a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000614e:	4691                	li	a3,4
    80006150:	fc040613          	addi	a2,s0,-64
    80006154:	fd843583          	ld	a1,-40(s0)
    80006158:	0591                	addi	a1,a1,4
    8000615a:	68a8                	ld	a0,80(s1)
    8000615c:	ffffb097          	auipc	ra,0xffffb
    80006160:	4e2080e7          	jalr	1250(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006164:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006166:	06055563          	bgez	a0,800061d0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    8000616a:	fc442783          	lw	a5,-60(s0)
    8000616e:	07e9                	addi	a5,a5,26
    80006170:	078e                	slli	a5,a5,0x3
    80006172:	97a6                	add	a5,a5,s1
    80006174:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006178:	fc042503          	lw	a0,-64(s0)
    8000617c:	0569                	addi	a0,a0,26
    8000617e:	050e                	slli	a0,a0,0x3
    80006180:	9526                	add	a0,a0,s1
    80006182:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006186:	fd043503          	ld	a0,-48(s0)
    8000618a:	fffff097          	auipc	ra,0xfffff
    8000618e:	a0c080e7          	jalr	-1524(ra) # 80004b96 <fileclose>
    fileclose(wf);
    80006192:	fc843503          	ld	a0,-56(s0)
    80006196:	fffff097          	auipc	ra,0xfffff
    8000619a:	a00080e7          	jalr	-1536(ra) # 80004b96 <fileclose>
    return -1;
    8000619e:	57fd                	li	a5,-1
    800061a0:	a805                	j	800061d0 <sys_pipe+0x104>
    if(fd0 >= 0)
    800061a2:	fc442783          	lw	a5,-60(s0)
    800061a6:	0007c863          	bltz	a5,800061b6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800061aa:	01a78513          	addi	a0,a5,26
    800061ae:	050e                	slli	a0,a0,0x3
    800061b0:	9526                	add	a0,a0,s1
    800061b2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    800061b6:	fd043503          	ld	a0,-48(s0)
    800061ba:	fffff097          	auipc	ra,0xfffff
    800061be:	9dc080e7          	jalr	-1572(ra) # 80004b96 <fileclose>
    fileclose(wf);
    800061c2:	fc843503          	ld	a0,-56(s0)
    800061c6:	fffff097          	auipc	ra,0xfffff
    800061ca:	9d0080e7          	jalr	-1584(ra) # 80004b96 <fileclose>
    return -1;
    800061ce:	57fd                	li	a5,-1
}
    800061d0:	853e                	mv	a0,a5
    800061d2:	70e2                	ld	ra,56(sp)
    800061d4:	7442                	ld	s0,48(sp)
    800061d6:	74a2                	ld	s1,40(sp)
    800061d8:	6121                	addi	sp,sp,64
    800061da:	8082                	ret
    800061dc:	0000                	unimp
	...

00000000800061e0 <kernelvec>:
    800061e0:	7111                	addi	sp,sp,-256
    800061e2:	e006                	sd	ra,0(sp)
    800061e4:	e40a                	sd	sp,8(sp)
    800061e6:	e80e                	sd	gp,16(sp)
    800061e8:	ec12                	sd	tp,24(sp)
    800061ea:	f016                	sd	t0,32(sp)
    800061ec:	f41a                	sd	t1,40(sp)
    800061ee:	f81e                	sd	t2,48(sp)
    800061f0:	fc22                	sd	s0,56(sp)
    800061f2:	e0a6                	sd	s1,64(sp)
    800061f4:	e4aa                	sd	a0,72(sp)
    800061f6:	e8ae                	sd	a1,80(sp)
    800061f8:	ecb2                	sd	a2,88(sp)
    800061fa:	f0b6                	sd	a3,96(sp)
    800061fc:	f4ba                	sd	a4,104(sp)
    800061fe:	f8be                	sd	a5,112(sp)
    80006200:	fcc2                	sd	a6,120(sp)
    80006202:	e146                	sd	a7,128(sp)
    80006204:	e54a                	sd	s2,136(sp)
    80006206:	e94e                	sd	s3,144(sp)
    80006208:	ed52                	sd	s4,152(sp)
    8000620a:	f156                	sd	s5,160(sp)
    8000620c:	f55a                	sd	s6,168(sp)
    8000620e:	f95e                	sd	s7,176(sp)
    80006210:	fd62                	sd	s8,184(sp)
    80006212:	e1e6                	sd	s9,192(sp)
    80006214:	e5ea                	sd	s10,200(sp)
    80006216:	e9ee                	sd	s11,208(sp)
    80006218:	edf2                	sd	t3,216(sp)
    8000621a:	f1f6                	sd	t4,224(sp)
    8000621c:	f5fa                	sd	t5,232(sp)
    8000621e:	f9fe                	sd	t6,240(sp)
    80006220:	cd3fc0ef          	jal	ra,80002ef2 <kerneltrap>
    80006224:	6082                	ld	ra,0(sp)
    80006226:	6122                	ld	sp,8(sp)
    80006228:	61c2                	ld	gp,16(sp)
    8000622a:	7282                	ld	t0,32(sp)
    8000622c:	7322                	ld	t1,40(sp)
    8000622e:	73c2                	ld	t2,48(sp)
    80006230:	7462                	ld	s0,56(sp)
    80006232:	6486                	ld	s1,64(sp)
    80006234:	6526                	ld	a0,72(sp)
    80006236:	65c6                	ld	a1,80(sp)
    80006238:	6666                	ld	a2,88(sp)
    8000623a:	7686                	ld	a3,96(sp)
    8000623c:	7726                	ld	a4,104(sp)
    8000623e:	77c6                	ld	a5,112(sp)
    80006240:	7866                	ld	a6,120(sp)
    80006242:	688a                	ld	a7,128(sp)
    80006244:	692a                	ld	s2,136(sp)
    80006246:	69ca                	ld	s3,144(sp)
    80006248:	6a6a                	ld	s4,152(sp)
    8000624a:	7a8a                	ld	s5,160(sp)
    8000624c:	7b2a                	ld	s6,168(sp)
    8000624e:	7bca                	ld	s7,176(sp)
    80006250:	7c6a                	ld	s8,184(sp)
    80006252:	6c8e                	ld	s9,192(sp)
    80006254:	6d2e                	ld	s10,200(sp)
    80006256:	6dce                	ld	s11,208(sp)
    80006258:	6e6e                	ld	t3,216(sp)
    8000625a:	7e8e                	ld	t4,224(sp)
    8000625c:	7f2e                	ld	t5,232(sp)
    8000625e:	7fce                	ld	t6,240(sp)
    80006260:	6111                	addi	sp,sp,256
    80006262:	10200073          	sret
    80006266:	00000013          	nop
    8000626a:	00000013          	nop
    8000626e:	0001                	nop

0000000080006270 <timervec>:
    80006270:	34051573          	csrrw	a0,mscratch,a0
    80006274:	e10c                	sd	a1,0(a0)
    80006276:	e510                	sd	a2,8(a0)
    80006278:	e914                	sd	a3,16(a0)
    8000627a:	6d0c                	ld	a1,24(a0)
    8000627c:	7110                	ld	a2,32(a0)
    8000627e:	6194                	ld	a3,0(a1)
    80006280:	96b2                	add	a3,a3,a2
    80006282:	e194                	sd	a3,0(a1)
    80006284:	4589                	li	a1,2
    80006286:	14459073          	csrw	sip,a1
    8000628a:	6914                	ld	a3,16(a0)
    8000628c:	6510                	ld	a2,8(a0)
    8000628e:	610c                	ld	a1,0(a0)
    80006290:	34051573          	csrrw	a0,mscratch,a0
    80006294:	30200073          	mret
	...

000000008000629a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000629a:	1141                	addi	sp,sp,-16
    8000629c:	e422                	sd	s0,8(sp)
    8000629e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800062a0:	0c0007b7          	lui	a5,0xc000
    800062a4:	4705                	li	a4,1
    800062a6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800062a8:	c3d8                	sw	a4,4(a5)
}
    800062aa:	6422                	ld	s0,8(sp)
    800062ac:	0141                	addi	sp,sp,16
    800062ae:	8082                	ret

00000000800062b0 <plicinithart>:

void
plicinithart(void)
{
    800062b0:	1141                	addi	sp,sp,-16
    800062b2:	e406                	sd	ra,8(sp)
    800062b4:	e022                	sd	s0,0(sp)
    800062b6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062b8:	ffffb097          	auipc	ra,0xffffb
    800062bc:	6d0080e7          	jalr	1744(ra) # 80001988 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062c0:	0085171b          	slliw	a4,a0,0x8
    800062c4:	0c0027b7          	lui	a5,0xc002
    800062c8:	97ba                	add	a5,a5,a4
    800062ca:	40200713          	li	a4,1026
    800062ce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062d2:	00d5151b          	slliw	a0,a0,0xd
    800062d6:	0c2017b7          	lui	a5,0xc201
    800062da:	953e                	add	a0,a0,a5
    800062dc:	00052023          	sw	zero,0(a0)
}
    800062e0:	60a2                	ld	ra,8(sp)
    800062e2:	6402                	ld	s0,0(sp)
    800062e4:	0141                	addi	sp,sp,16
    800062e6:	8082                	ret

00000000800062e8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062e8:	1141                	addi	sp,sp,-16
    800062ea:	e406                	sd	ra,8(sp)
    800062ec:	e022                	sd	s0,0(sp)
    800062ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062f0:	ffffb097          	auipc	ra,0xffffb
    800062f4:	698080e7          	jalr	1688(ra) # 80001988 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062f8:	00d5179b          	slliw	a5,a0,0xd
    800062fc:	0c201537          	lui	a0,0xc201
    80006300:	953e                	add	a0,a0,a5
  return irq;
}
    80006302:	4148                	lw	a0,4(a0)
    80006304:	60a2                	ld	ra,8(sp)
    80006306:	6402                	ld	s0,0(sp)
    80006308:	0141                	addi	sp,sp,16
    8000630a:	8082                	ret

000000008000630c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000630c:	1101                	addi	sp,sp,-32
    8000630e:	ec06                	sd	ra,24(sp)
    80006310:	e822                	sd	s0,16(sp)
    80006312:	e426                	sd	s1,8(sp)
    80006314:	1000                	addi	s0,sp,32
    80006316:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006318:	ffffb097          	auipc	ra,0xffffb
    8000631c:	670080e7          	jalr	1648(ra) # 80001988 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006320:	00d5151b          	slliw	a0,a0,0xd
    80006324:	0c2017b7          	lui	a5,0xc201
    80006328:	97aa                	add	a5,a5,a0
    8000632a:	c3c4                	sw	s1,4(a5)
}
    8000632c:	60e2                	ld	ra,24(sp)
    8000632e:	6442                	ld	s0,16(sp)
    80006330:	64a2                	ld	s1,8(sp)
    80006332:	6105                	addi	sp,sp,32
    80006334:	8082                	ret

0000000080006336 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006336:	1141                	addi	sp,sp,-16
    80006338:	e406                	sd	ra,8(sp)
    8000633a:	e022                	sd	s0,0(sp)
    8000633c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000633e:	479d                	li	a5,7
    80006340:	06a7c963          	blt	a5,a0,800063b2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006344:	00023797          	auipc	a5,0x23
    80006348:	cbc78793          	addi	a5,a5,-836 # 80029000 <disk>
    8000634c:	00a78733          	add	a4,a5,a0
    80006350:	6789                	lui	a5,0x2
    80006352:	97ba                	add	a5,a5,a4
    80006354:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006358:	e7ad                	bnez	a5,800063c2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000635a:	00451793          	slli	a5,a0,0x4
    8000635e:	00025717          	auipc	a4,0x25
    80006362:	ca270713          	addi	a4,a4,-862 # 8002b000 <disk+0x2000>
    80006366:	6314                	ld	a3,0(a4)
    80006368:	96be                	add	a3,a3,a5
    8000636a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000636e:	6314                	ld	a3,0(a4)
    80006370:	96be                	add	a3,a3,a5
    80006372:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006376:	6314                	ld	a3,0(a4)
    80006378:	96be                	add	a3,a3,a5
    8000637a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000637e:	6318                	ld	a4,0(a4)
    80006380:	97ba                	add	a5,a5,a4
    80006382:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006386:	00023797          	auipc	a5,0x23
    8000638a:	c7a78793          	addi	a5,a5,-902 # 80029000 <disk>
    8000638e:	97aa                	add	a5,a5,a0
    80006390:	6509                	lui	a0,0x2
    80006392:	953e                	add	a0,a0,a5
    80006394:	4785                	li	a5,1
    80006396:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000639a:	00025517          	auipc	a0,0x25
    8000639e:	c7e50513          	addi	a0,a0,-898 # 8002b018 <disk+0x2018>
    800063a2:	ffffc097          	auipc	ra,0xffffc
    800063a6:	f16080e7          	jalr	-234(ra) # 800022b8 <wakeup>
}
    800063aa:	60a2                	ld	ra,8(sp)
    800063ac:	6402                	ld	s0,0(sp)
    800063ae:	0141                	addi	sp,sp,16
    800063b0:	8082                	ret
    panic("free_desc 1");
    800063b2:	00002517          	auipc	a0,0x2
    800063b6:	41650513          	addi	a0,a0,1046 # 800087c8 <syscalls+0x338>
    800063ba:	ffffa097          	auipc	ra,0xffffa
    800063be:	170080e7          	jalr	368(ra) # 8000052a <panic>
    panic("free_desc 2");
    800063c2:	00002517          	auipc	a0,0x2
    800063c6:	41650513          	addi	a0,a0,1046 # 800087d8 <syscalls+0x348>
    800063ca:	ffffa097          	auipc	ra,0xffffa
    800063ce:	160080e7          	jalr	352(ra) # 8000052a <panic>

00000000800063d2 <virtio_disk_init>:
{
    800063d2:	1101                	addi	sp,sp,-32
    800063d4:	ec06                	sd	ra,24(sp)
    800063d6:	e822                	sd	s0,16(sp)
    800063d8:	e426                	sd	s1,8(sp)
    800063da:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800063dc:	00002597          	auipc	a1,0x2
    800063e0:	40c58593          	addi	a1,a1,1036 # 800087e8 <syscalls+0x358>
    800063e4:	00025517          	auipc	a0,0x25
    800063e8:	d4450513          	addi	a0,a0,-700 # 8002b128 <disk+0x2128>
    800063ec:	ffffa097          	auipc	ra,0xffffa
    800063f0:	746080e7          	jalr	1862(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063f4:	100017b7          	lui	a5,0x10001
    800063f8:	4398                	lw	a4,0(a5)
    800063fa:	2701                	sext.w	a4,a4
    800063fc:	747277b7          	lui	a5,0x74727
    80006400:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006404:	0ef71163          	bne	a4,a5,800064e6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006408:	100017b7          	lui	a5,0x10001
    8000640c:	43dc                	lw	a5,4(a5)
    8000640e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006410:	4705                	li	a4,1
    80006412:	0ce79a63          	bne	a5,a4,800064e6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006416:	100017b7          	lui	a5,0x10001
    8000641a:	479c                	lw	a5,8(a5)
    8000641c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000641e:	4709                	li	a4,2
    80006420:	0ce79363          	bne	a5,a4,800064e6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006424:	100017b7          	lui	a5,0x10001
    80006428:	47d8                	lw	a4,12(a5)
    8000642a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000642c:	554d47b7          	lui	a5,0x554d4
    80006430:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006434:	0af71963          	bne	a4,a5,800064e6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006438:	100017b7          	lui	a5,0x10001
    8000643c:	4705                	li	a4,1
    8000643e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006440:	470d                	li	a4,3
    80006442:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006444:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006446:	c7ffe737          	lui	a4,0xc7ffe
    8000644a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd275f>
    8000644e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006450:	2701                	sext.w	a4,a4
    80006452:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006454:	472d                	li	a4,11
    80006456:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006458:	473d                	li	a4,15
    8000645a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000645c:	6705                	lui	a4,0x1
    8000645e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006460:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006464:	5bdc                	lw	a5,52(a5)
    80006466:	2781                	sext.w	a5,a5
  if(max == 0)
    80006468:	c7d9                	beqz	a5,800064f6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000646a:	471d                	li	a4,7
    8000646c:	08f77d63          	bgeu	a4,a5,80006506 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006470:	100014b7          	lui	s1,0x10001
    80006474:	47a1                	li	a5,8
    80006476:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006478:	6609                	lui	a2,0x2
    8000647a:	4581                	li	a1,0
    8000647c:	00023517          	auipc	a0,0x23
    80006480:	b8450513          	addi	a0,a0,-1148 # 80029000 <disk>
    80006484:	ffffb097          	auipc	ra,0xffffb
    80006488:	83a080e7          	jalr	-1990(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000648c:	00023717          	auipc	a4,0x23
    80006490:	b7470713          	addi	a4,a4,-1164 # 80029000 <disk>
    80006494:	00c75793          	srli	a5,a4,0xc
    80006498:	2781                	sext.w	a5,a5
    8000649a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000649c:	00025797          	auipc	a5,0x25
    800064a0:	b6478793          	addi	a5,a5,-1180 # 8002b000 <disk+0x2000>
    800064a4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800064a6:	00023717          	auipc	a4,0x23
    800064aa:	bda70713          	addi	a4,a4,-1062 # 80029080 <disk+0x80>
    800064ae:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800064b0:	00024717          	auipc	a4,0x24
    800064b4:	b5070713          	addi	a4,a4,-1200 # 8002a000 <disk+0x1000>
    800064b8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800064ba:	4705                	li	a4,1
    800064bc:	00e78c23          	sb	a4,24(a5)
    800064c0:	00e78ca3          	sb	a4,25(a5)
    800064c4:	00e78d23          	sb	a4,26(a5)
    800064c8:	00e78da3          	sb	a4,27(a5)
    800064cc:	00e78e23          	sb	a4,28(a5)
    800064d0:	00e78ea3          	sb	a4,29(a5)
    800064d4:	00e78f23          	sb	a4,30(a5)
    800064d8:	00e78fa3          	sb	a4,31(a5)
}
    800064dc:	60e2                	ld	ra,24(sp)
    800064de:	6442                	ld	s0,16(sp)
    800064e0:	64a2                	ld	s1,8(sp)
    800064e2:	6105                	addi	sp,sp,32
    800064e4:	8082                	ret
    panic("could not find virtio disk");
    800064e6:	00002517          	auipc	a0,0x2
    800064ea:	31250513          	addi	a0,a0,786 # 800087f8 <syscalls+0x368>
    800064ee:	ffffa097          	auipc	ra,0xffffa
    800064f2:	03c080e7          	jalr	60(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    800064f6:	00002517          	auipc	a0,0x2
    800064fa:	32250513          	addi	a0,a0,802 # 80008818 <syscalls+0x388>
    800064fe:	ffffa097          	auipc	ra,0xffffa
    80006502:	02c080e7          	jalr	44(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006506:	00002517          	auipc	a0,0x2
    8000650a:	33250513          	addi	a0,a0,818 # 80008838 <syscalls+0x3a8>
    8000650e:	ffffa097          	auipc	ra,0xffffa
    80006512:	01c080e7          	jalr	28(ra) # 8000052a <panic>

0000000080006516 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006516:	7119                	addi	sp,sp,-128
    80006518:	fc86                	sd	ra,120(sp)
    8000651a:	f8a2                	sd	s0,112(sp)
    8000651c:	f4a6                	sd	s1,104(sp)
    8000651e:	f0ca                	sd	s2,96(sp)
    80006520:	ecce                	sd	s3,88(sp)
    80006522:	e8d2                	sd	s4,80(sp)
    80006524:	e4d6                	sd	s5,72(sp)
    80006526:	e0da                	sd	s6,64(sp)
    80006528:	fc5e                	sd	s7,56(sp)
    8000652a:	f862                	sd	s8,48(sp)
    8000652c:	f466                	sd	s9,40(sp)
    8000652e:	f06a                	sd	s10,32(sp)
    80006530:	ec6e                	sd	s11,24(sp)
    80006532:	0100                	addi	s0,sp,128
    80006534:	8aaa                	mv	s5,a0
    80006536:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006538:	00c52c83          	lw	s9,12(a0)
    8000653c:	001c9c9b          	slliw	s9,s9,0x1
    80006540:	1c82                	slli	s9,s9,0x20
    80006542:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006546:	00025517          	auipc	a0,0x25
    8000654a:	be250513          	addi	a0,a0,-1054 # 8002b128 <disk+0x2128>
    8000654e:	ffffa097          	auipc	ra,0xffffa
    80006552:	674080e7          	jalr	1652(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006556:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006558:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000655a:	00023c17          	auipc	s8,0x23
    8000655e:	aa6c0c13          	addi	s8,s8,-1370 # 80029000 <disk>
    80006562:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006564:	4b0d                	li	s6,3
    80006566:	a0ad                	j	800065d0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006568:	00fc0733          	add	a4,s8,a5
    8000656c:	975e                	add	a4,a4,s7
    8000656e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006572:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006574:	0207c563          	bltz	a5,8000659e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006578:	2905                	addiw	s2,s2,1
    8000657a:	0611                	addi	a2,a2,4
    8000657c:	19690d63          	beq	s2,s6,80006716 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006580:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006582:	00025717          	auipc	a4,0x25
    80006586:	a9670713          	addi	a4,a4,-1386 # 8002b018 <disk+0x2018>
    8000658a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000658c:	00074683          	lbu	a3,0(a4)
    80006590:	fee1                	bnez	a3,80006568 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006592:	2785                	addiw	a5,a5,1
    80006594:	0705                	addi	a4,a4,1
    80006596:	fe979be3          	bne	a5,s1,8000658c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000659a:	57fd                	li	a5,-1
    8000659c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000659e:	01205d63          	blez	s2,800065b8 <virtio_disk_rw+0xa2>
    800065a2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800065a4:	000a2503          	lw	a0,0(s4)
    800065a8:	00000097          	auipc	ra,0x0
    800065ac:	d8e080e7          	jalr	-626(ra) # 80006336 <free_desc>
      for(int j = 0; j < i; j++)
    800065b0:	2d85                	addiw	s11,s11,1
    800065b2:	0a11                	addi	s4,s4,4
    800065b4:	ffb918e3          	bne	s2,s11,800065a4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065b8:	00025597          	auipc	a1,0x25
    800065bc:	b7058593          	addi	a1,a1,-1168 # 8002b128 <disk+0x2128>
    800065c0:	00025517          	auipc	a0,0x25
    800065c4:	a5850513          	addi	a0,a0,-1448 # 8002b018 <disk+0x2018>
    800065c8:	ffffc097          	auipc	ra,0xffffc
    800065cc:	b64080e7          	jalr	-1180(ra) # 8000212c <sleep>
  for(int i = 0; i < 3; i++){
    800065d0:	f8040a13          	addi	s4,s0,-128
{
    800065d4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800065d6:	894e                	mv	s2,s3
    800065d8:	b765                	j	80006580 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800065da:	00025697          	auipc	a3,0x25
    800065de:	a266b683          	ld	a3,-1498(a3) # 8002b000 <disk+0x2000>
    800065e2:	96ba                	add	a3,a3,a4
    800065e4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065e8:	00023817          	auipc	a6,0x23
    800065ec:	a1880813          	addi	a6,a6,-1512 # 80029000 <disk>
    800065f0:	00025697          	auipc	a3,0x25
    800065f4:	a1068693          	addi	a3,a3,-1520 # 8002b000 <disk+0x2000>
    800065f8:	6290                	ld	a2,0(a3)
    800065fa:	963a                	add	a2,a2,a4
    800065fc:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006600:	0015e593          	ori	a1,a1,1
    80006604:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006608:	f8842603          	lw	a2,-120(s0)
    8000660c:	628c                	ld	a1,0(a3)
    8000660e:	972e                	add	a4,a4,a1
    80006610:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006614:	20050593          	addi	a1,a0,512
    80006618:	0592                	slli	a1,a1,0x4
    8000661a:	95c2                	add	a1,a1,a6
    8000661c:	577d                	li	a4,-1
    8000661e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006622:	00461713          	slli	a4,a2,0x4
    80006626:	6290                	ld	a2,0(a3)
    80006628:	963a                	add	a2,a2,a4
    8000662a:	03078793          	addi	a5,a5,48
    8000662e:	97c2                	add	a5,a5,a6
    80006630:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006632:	629c                	ld	a5,0(a3)
    80006634:	97ba                	add	a5,a5,a4
    80006636:	4605                	li	a2,1
    80006638:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000663a:	629c                	ld	a5,0(a3)
    8000663c:	97ba                	add	a5,a5,a4
    8000663e:	4809                	li	a6,2
    80006640:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006644:	629c                	ld	a5,0(a3)
    80006646:	973e                	add	a4,a4,a5
    80006648:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000664c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006650:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006654:	6698                	ld	a4,8(a3)
    80006656:	00275783          	lhu	a5,2(a4)
    8000665a:	8b9d                	andi	a5,a5,7
    8000665c:	0786                	slli	a5,a5,0x1
    8000665e:	97ba                	add	a5,a5,a4
    80006660:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006664:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006668:	6698                	ld	a4,8(a3)
    8000666a:	00275783          	lhu	a5,2(a4)
    8000666e:	2785                	addiw	a5,a5,1
    80006670:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006674:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006678:	100017b7          	lui	a5,0x10001
    8000667c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006680:	004aa783          	lw	a5,4(s5)
    80006684:	02c79163          	bne	a5,a2,800066a6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006688:	00025917          	auipc	s2,0x25
    8000668c:	aa090913          	addi	s2,s2,-1376 # 8002b128 <disk+0x2128>
  while(b->disk == 1) {
    80006690:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006692:	85ca                	mv	a1,s2
    80006694:	8556                	mv	a0,s5
    80006696:	ffffc097          	auipc	ra,0xffffc
    8000669a:	a96080e7          	jalr	-1386(ra) # 8000212c <sleep>
  while(b->disk == 1) {
    8000669e:	004aa783          	lw	a5,4(s5)
    800066a2:	fe9788e3          	beq	a5,s1,80006692 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800066a6:	f8042903          	lw	s2,-128(s0)
    800066aa:	20090793          	addi	a5,s2,512
    800066ae:	00479713          	slli	a4,a5,0x4
    800066b2:	00023797          	auipc	a5,0x23
    800066b6:	94e78793          	addi	a5,a5,-1714 # 80029000 <disk>
    800066ba:	97ba                	add	a5,a5,a4
    800066bc:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800066c0:	00025997          	auipc	s3,0x25
    800066c4:	94098993          	addi	s3,s3,-1728 # 8002b000 <disk+0x2000>
    800066c8:	00491713          	slli	a4,s2,0x4
    800066cc:	0009b783          	ld	a5,0(s3)
    800066d0:	97ba                	add	a5,a5,a4
    800066d2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800066d6:	854a                	mv	a0,s2
    800066d8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800066dc:	00000097          	auipc	ra,0x0
    800066e0:	c5a080e7          	jalr	-934(ra) # 80006336 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800066e4:	8885                	andi	s1,s1,1
    800066e6:	f0ed                	bnez	s1,800066c8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066e8:	00025517          	auipc	a0,0x25
    800066ec:	a4050513          	addi	a0,a0,-1472 # 8002b128 <disk+0x2128>
    800066f0:	ffffa097          	auipc	ra,0xffffa
    800066f4:	586080e7          	jalr	1414(ra) # 80000c76 <release>
}
    800066f8:	70e6                	ld	ra,120(sp)
    800066fa:	7446                	ld	s0,112(sp)
    800066fc:	74a6                	ld	s1,104(sp)
    800066fe:	7906                	ld	s2,96(sp)
    80006700:	69e6                	ld	s3,88(sp)
    80006702:	6a46                	ld	s4,80(sp)
    80006704:	6aa6                	ld	s5,72(sp)
    80006706:	6b06                	ld	s6,64(sp)
    80006708:	7be2                	ld	s7,56(sp)
    8000670a:	7c42                	ld	s8,48(sp)
    8000670c:	7ca2                	ld	s9,40(sp)
    8000670e:	7d02                	ld	s10,32(sp)
    80006710:	6de2                	ld	s11,24(sp)
    80006712:	6109                	addi	sp,sp,128
    80006714:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006716:	f8042503          	lw	a0,-128(s0)
    8000671a:	20050793          	addi	a5,a0,512
    8000671e:	0792                	slli	a5,a5,0x4
  if(write)
    80006720:	00023817          	auipc	a6,0x23
    80006724:	8e080813          	addi	a6,a6,-1824 # 80029000 <disk>
    80006728:	00f80733          	add	a4,a6,a5
    8000672c:	01a036b3          	snez	a3,s10
    80006730:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006734:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006738:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000673c:	7679                	lui	a2,0xffffe
    8000673e:	963e                	add	a2,a2,a5
    80006740:	00025697          	auipc	a3,0x25
    80006744:	8c068693          	addi	a3,a3,-1856 # 8002b000 <disk+0x2000>
    80006748:	6298                	ld	a4,0(a3)
    8000674a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000674c:	0a878593          	addi	a1,a5,168
    80006750:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006752:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006754:	6298                	ld	a4,0(a3)
    80006756:	9732                	add	a4,a4,a2
    80006758:	45c1                	li	a1,16
    8000675a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000675c:	6298                	ld	a4,0(a3)
    8000675e:	9732                	add	a4,a4,a2
    80006760:	4585                	li	a1,1
    80006762:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006766:	f8442703          	lw	a4,-124(s0)
    8000676a:	628c                	ld	a1,0(a3)
    8000676c:	962e                	add	a2,a2,a1
    8000676e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd200e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006772:	0712                	slli	a4,a4,0x4
    80006774:	6290                	ld	a2,0(a3)
    80006776:	963a                	add	a2,a2,a4
    80006778:	058a8593          	addi	a1,s5,88
    8000677c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000677e:	6294                	ld	a3,0(a3)
    80006780:	96ba                	add	a3,a3,a4
    80006782:	40000613          	li	a2,1024
    80006786:	c690                	sw	a2,8(a3)
  if(write)
    80006788:	e40d19e3          	bnez	s10,800065da <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000678c:	00025697          	auipc	a3,0x25
    80006790:	8746b683          	ld	a3,-1932(a3) # 8002b000 <disk+0x2000>
    80006794:	96ba                	add	a3,a3,a4
    80006796:	4609                	li	a2,2
    80006798:	00c69623          	sh	a2,12(a3)
    8000679c:	b5b1                	j	800065e8 <virtio_disk_rw+0xd2>

000000008000679e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000679e:	1101                	addi	sp,sp,-32
    800067a0:	ec06                	sd	ra,24(sp)
    800067a2:	e822                	sd	s0,16(sp)
    800067a4:	e426                	sd	s1,8(sp)
    800067a6:	e04a                	sd	s2,0(sp)
    800067a8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067aa:	00025517          	auipc	a0,0x25
    800067ae:	97e50513          	addi	a0,a0,-1666 # 8002b128 <disk+0x2128>
    800067b2:	ffffa097          	auipc	ra,0xffffa
    800067b6:	410080e7          	jalr	1040(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067ba:	10001737          	lui	a4,0x10001
    800067be:	533c                	lw	a5,96(a4)
    800067c0:	8b8d                	andi	a5,a5,3
    800067c2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800067c4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800067c8:	00025797          	auipc	a5,0x25
    800067cc:	83878793          	addi	a5,a5,-1992 # 8002b000 <disk+0x2000>
    800067d0:	6b94                	ld	a3,16(a5)
    800067d2:	0207d703          	lhu	a4,32(a5)
    800067d6:	0026d783          	lhu	a5,2(a3)
    800067da:	06f70163          	beq	a4,a5,8000683c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067de:	00023917          	auipc	s2,0x23
    800067e2:	82290913          	addi	s2,s2,-2014 # 80029000 <disk>
    800067e6:	00025497          	auipc	s1,0x25
    800067ea:	81a48493          	addi	s1,s1,-2022 # 8002b000 <disk+0x2000>
    __sync_synchronize();
    800067ee:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067f2:	6898                	ld	a4,16(s1)
    800067f4:	0204d783          	lhu	a5,32(s1)
    800067f8:	8b9d                	andi	a5,a5,7
    800067fa:	078e                	slli	a5,a5,0x3
    800067fc:	97ba                	add	a5,a5,a4
    800067fe:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006800:	20078713          	addi	a4,a5,512
    80006804:	0712                	slli	a4,a4,0x4
    80006806:	974a                	add	a4,a4,s2
    80006808:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000680c:	e731                	bnez	a4,80006858 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000680e:	20078793          	addi	a5,a5,512
    80006812:	0792                	slli	a5,a5,0x4
    80006814:	97ca                	add	a5,a5,s2
    80006816:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006818:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000681c:	ffffc097          	auipc	ra,0xffffc
    80006820:	a9c080e7          	jalr	-1380(ra) # 800022b8 <wakeup>

    disk.used_idx += 1;
    80006824:	0204d783          	lhu	a5,32(s1)
    80006828:	2785                	addiw	a5,a5,1
    8000682a:	17c2                	slli	a5,a5,0x30
    8000682c:	93c1                	srli	a5,a5,0x30
    8000682e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006832:	6898                	ld	a4,16(s1)
    80006834:	00275703          	lhu	a4,2(a4)
    80006838:	faf71be3          	bne	a4,a5,800067ee <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000683c:	00025517          	auipc	a0,0x25
    80006840:	8ec50513          	addi	a0,a0,-1812 # 8002b128 <disk+0x2128>
    80006844:	ffffa097          	auipc	ra,0xffffa
    80006848:	432080e7          	jalr	1074(ra) # 80000c76 <release>
}
    8000684c:	60e2                	ld	ra,24(sp)
    8000684e:	6442                	ld	s0,16(sp)
    80006850:	64a2                	ld	s1,8(sp)
    80006852:	6902                	ld	s2,0(sp)
    80006854:	6105                	addi	sp,sp,32
    80006856:	8082                	ret
      panic("virtio_disk_intr status");
    80006858:	00002517          	auipc	a0,0x2
    8000685c:	00050513          	mv	a0,a0
    80006860:	ffffa097          	auipc	ra,0xffffa
    80006864:	cca080e7          	jalr	-822(ra) # 8000052a <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0) # 80008880 <initcode>
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
