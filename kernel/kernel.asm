
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
    80000068:	3dc78793          	addi	a5,a5,988 # 80006440 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc07ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dec78793          	addi	a5,a5,-532 # 80000e9a <main>
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
    80000122:	6d8080e7          	jalr	1752(ra) # 800027f6 <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	788080e7          	jalr	1928(ra) # 800008b6 <uartputc>
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
    80000188:	a54080e7          	jalr	-1452(ra) # 80000bd8 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed || mythread()->killed){
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
    8000019e:	5cfd                	li	s9,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4c29                	li	s8,10
  while(n > 0){
    800001a2:	07305f63          	blez	s3,80000220 <consoleread+0xca>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71b63          	bne	a4,a5,800001e4 <consoleread+0x8e>
      if(myproc()->killed || mythread()->killed){
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	8a4080e7          	jalr	-1884(ra) # 80001a56 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	efad                	bnez	a5,80000236 <consoleread+0xe0>
    800001be:	00002097          	auipc	ra,0x2
    800001c2:	91e080e7          	jalr	-1762(ra) # 80001adc <mythread>
    800001c6:	09852783          	lw	a5,152(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xe0>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	18e080e7          	jalr	398(ra) # 8000235e <sleep>
    while(cons.r == cons.w){
    800001d8:	0984a783          	lw	a5,152(s1)
    800001dc:	09c4a703          	lw	a4,156(s1)
    800001e0:	fcf709e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e4:	0017871b          	addiw	a4,a5,1
    800001e8:	08e4ac23          	sw	a4,152(s1)
    800001ec:	07f7f713          	andi	a4,a5,127
    800001f0:	9726                	add	a4,a4,s1
    800001f2:	01874703          	lbu	a4,24(a4)
    800001f6:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001fa:	077d0563          	beq	s10,s7,80000264 <consoleread+0x10e>
    cbuf = c;
    800001fe:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000202:	4685                	li	a3,1
    80000204:	f9f40613          	addi	a2,s0,-97
    80000208:	85d2                	mv	a1,s4
    8000020a:	8556                	mv	a0,s5
    8000020c:	00002097          	auipc	ra,0x2
    80000210:	594080e7          	jalr	1428(ra) # 800027a0 <either_copyout>
    80000214:	01950663          	beq	a0,s9,80000220 <consoleread+0xca>
    dst++;
    80000218:	0a05                	addi	s4,s4,1
    --n;
    8000021a:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000021c:	f98d13e3          	bne	s10,s8,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000220:	00011517          	auipc	a0,0x11
    80000224:	f6050513          	addi	a0,a0,-160 # 80011180 <cons>
    80000228:	00001097          	auipc	ra,0x1
    8000022c:	a7c080e7          	jalr	-1412(ra) # 80000ca4 <release>

  return target - n;
    80000230:	413b053b          	subw	a0,s6,s3
    80000234:	a811                	j	80000248 <consoleread+0xf2>
        release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	f4a50513          	addi	a0,a0,-182 # 80011180 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	a66080e7          	jalr	-1434(ra) # 80000ca4 <release>
        return -1;
    80000246:	557d                	li	a0,-1
}
    80000248:	70a6                	ld	ra,104(sp)
    8000024a:	7406                	ld	s0,96(sp)
    8000024c:	64e6                	ld	s1,88(sp)
    8000024e:	6946                	ld	s2,80(sp)
    80000250:	69a6                	ld	s3,72(sp)
    80000252:	6a06                	ld	s4,64(sp)
    80000254:	7ae2                	ld	s5,56(sp)
    80000256:	7b42                	ld	s6,48(sp)
    80000258:	7ba2                	ld	s7,40(sp)
    8000025a:	7c02                	ld	s8,32(sp)
    8000025c:	6ce2                	ld	s9,24(sp)
    8000025e:	6d42                	ld	s10,16(sp)
    80000260:	6165                	addi	sp,sp,112
    80000262:	8082                	ret
      if(n < target){
    80000264:	0009871b          	sext.w	a4,s3
    80000268:	fb677ce3          	bgeu	a4,s6,80000220 <consoleread+0xca>
        cons.r--;
    8000026c:	00011717          	auipc	a4,0x11
    80000270:	faf72623          	sw	a5,-84(a4) # 80011218 <cons+0x98>
    80000274:	b775                	j	80000220 <consoleread+0xca>

0000000080000276 <consputc>:
{
    80000276:	1141                	addi	sp,sp,-16
    80000278:	e406                	sd	ra,8(sp)
    8000027a:	e022                	sd	s0,0(sp)
    8000027c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027e:	10000793          	li	a5,256
    80000282:	00f50a63          	beq	a0,a5,80000296 <consputc+0x20>
    uartputc_sync(c);
    80000286:	00000097          	auipc	ra,0x0
    8000028a:	55e080e7          	jalr	1374(ra) # 800007e4 <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	00000097          	auipc	ra,0x0
    8000029c:	54c080e7          	jalr	1356(ra) # 800007e4 <uartputc_sync>
    800002a0:	02000513          	li	a0,32
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	540080e7          	jalr	1344(ra) # 800007e4 <uartputc_sync>
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	536080e7          	jalr	1334(ra) # 800007e4 <uartputc_sync>
    800002b6:	bfe1                	j	8000028e <consputc+0x18>

00000000800002b8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b8:	1101                	addi	sp,sp,-32
    800002ba:	ec06                	sd	ra,24(sp)
    800002bc:	e822                	sd	s0,16(sp)
    800002be:	e426                	sd	s1,8(sp)
    800002c0:	e04a                	sd	s2,0(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00011517          	auipc	a0,0x11
    800002ca:	eba50513          	addi	a0,a0,-326 # 80011180 <cons>
    800002ce:	00001097          	auipc	ra,0x1
    800002d2:	90a080e7          	jalr	-1782(ra) # 80000bd8 <acquire>

  switch(c){
    800002d6:	47d5                	li	a5,21
    800002d8:	0af48663          	beq	s1,a5,80000384 <consoleintr+0xcc>
    800002dc:	0297ca63          	blt	a5,s1,80000310 <consoleintr+0x58>
    800002e0:	47a1                	li	a5,8
    800002e2:	0ef48763          	beq	s1,a5,800003d0 <consoleintr+0x118>
    800002e6:	47c1                	li	a5,16
    800002e8:	10f49a63          	bne	s1,a5,800003fc <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ec:	00002097          	auipc	ra,0x2
    800002f0:	560080e7          	jalr	1376(ra) # 8000284c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f4:	00011517          	auipc	a0,0x11
    800002f8:	e8c50513          	addi	a0,a0,-372 # 80011180 <cons>
    800002fc:	00001097          	auipc	ra,0x1
    80000300:	9a8080e7          	jalr	-1624(ra) # 80000ca4 <release>
}
    80000304:	60e2                	ld	ra,24(sp)
    80000306:	6442                	ld	s0,16(sp)
    80000308:	64a2                	ld	s1,8(sp)
    8000030a:	6902                	ld	s2,0(sp)
    8000030c:	6105                	addi	sp,sp,32
    8000030e:	8082                	ret
  switch(c){
    80000310:	07f00793          	li	a5,127
    80000314:	0af48e63          	beq	s1,a5,800003d0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000318:	00011717          	auipc	a4,0x11
    8000031c:	e6870713          	addi	a4,a4,-408 # 80011180 <cons>
    80000320:	0a072783          	lw	a5,160(a4)
    80000324:	09872703          	lw	a4,152(a4)
    80000328:	9f99                	subw	a5,a5,a4
    8000032a:	07f00713          	li	a4,127
    8000032e:	fcf763e3          	bltu	a4,a5,800002f4 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000332:	47b5                	li	a5,13
    80000334:	0cf48763          	beq	s1,a5,80000402 <consoleintr+0x14a>
      consputc(c);
    80000338:	8526                	mv	a0,s1
    8000033a:	00000097          	auipc	ra,0x0
    8000033e:	f3c080e7          	jalr	-196(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000342:	00011797          	auipc	a5,0x11
    80000346:	e3e78793          	addi	a5,a5,-450 # 80011180 <cons>
    8000034a:	0a07a703          	lw	a4,160(a5)
    8000034e:	0017069b          	addiw	a3,a4,1
    80000352:	0006861b          	sext.w	a2,a3
    80000356:	0ad7a023          	sw	a3,160(a5)
    8000035a:	07f77713          	andi	a4,a4,127
    8000035e:	97ba                	add	a5,a5,a4
    80000360:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000364:	47a9                	li	a5,10
    80000366:	0cf48563          	beq	s1,a5,80000430 <consoleintr+0x178>
    8000036a:	4791                	li	a5,4
    8000036c:	0cf48263          	beq	s1,a5,80000430 <consoleintr+0x178>
    80000370:	00011797          	auipc	a5,0x11
    80000374:	ea87a783          	lw	a5,-344(a5) # 80011218 <cons+0x98>
    80000378:	0807879b          	addiw	a5,a5,128
    8000037c:	f6f61ce3          	bne	a2,a5,800002f4 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000380:	863e                	mv	a2,a5
    80000382:	a07d                	j	80000430 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000384:	00011717          	auipc	a4,0x11
    80000388:	dfc70713          	addi	a4,a4,-516 # 80011180 <cons>
    8000038c:	0a072783          	lw	a5,160(a4)
    80000390:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	00011497          	auipc	s1,0x11
    80000398:	dec48493          	addi	s1,s1,-532 # 80011180 <cons>
    while(cons.e != cons.w &&
    8000039c:	4929                	li	s2,10
    8000039e:	f4f70be3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a2:	37fd                	addiw	a5,a5,-1
    800003a4:	07f7f713          	andi	a4,a5,127
    800003a8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003aa:	01874703          	lbu	a4,24(a4)
    800003ae:	f52703e3          	beq	a4,s2,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003b2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b6:	10000513          	li	a0,256
    800003ba:	00000097          	auipc	ra,0x0
    800003be:	ebc080e7          	jalr	-324(ra) # 80000276 <consputc>
    while(cons.e != cons.w &&
    800003c2:	0a04a783          	lw	a5,160(s1)
    800003c6:	09c4a703          	lw	a4,156(s1)
    800003ca:	fcf71ce3          	bne	a4,a5,800003a2 <consoleintr+0xea>
    800003ce:	b71d                	j	800002f4 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d0:	00011717          	auipc	a4,0x11
    800003d4:	db070713          	addi	a4,a4,-592 # 80011180 <cons>
    800003d8:	0a072783          	lw	a5,160(a4)
    800003dc:	09c72703          	lw	a4,156(a4)
    800003e0:	f0f70ae3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003e4:	37fd                	addiw	a5,a5,-1
    800003e6:	00011717          	auipc	a4,0x11
    800003ea:	e2f72d23          	sw	a5,-454(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003ee:	10000513          	li	a0,256
    800003f2:	00000097          	auipc	ra,0x0
    800003f6:	e84080e7          	jalr	-380(ra) # 80000276 <consputc>
    800003fa:	bded                	j	800002f4 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003fc:	ee048ce3          	beqz	s1,800002f4 <consoleintr+0x3c>
    80000400:	bf21                	j	80000318 <consoleintr+0x60>
      consputc(c);
    80000402:	4529                	li	a0,10
    80000404:	00000097          	auipc	ra,0x0
    80000408:	e72080e7          	jalr	-398(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000040c:	00011797          	auipc	a5,0x11
    80000410:	d7478793          	addi	a5,a5,-652 # 80011180 <cons>
    80000414:	0a07a703          	lw	a4,160(a5)
    80000418:	0017069b          	addiw	a3,a4,1
    8000041c:	0006861b          	sext.w	a2,a3
    80000420:	0ad7a023          	sw	a3,160(a5)
    80000424:	07f77713          	andi	a4,a4,127
    80000428:	97ba                	add	a5,a5,a4
    8000042a:	4729                	li	a4,10
    8000042c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000430:	00011797          	auipc	a5,0x11
    80000434:	dec7a623          	sw	a2,-532(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    80000438:	00011517          	auipc	a0,0x11
    8000043c:	de050513          	addi	a0,a0,-544 # 80011218 <cons+0x98>
    80000440:	00002097          	auipc	ra,0x2
    80000444:	0b4080e7          	jalr	180(ra) # 800024f4 <wakeup>
    80000448:	b575                	j	800002f4 <consoleintr+0x3c>

000000008000044a <consoleinit>:

void
consoleinit(void)
{
    8000044a:	1141                	addi	sp,sp,-16
    8000044c:	e406                	sd	ra,8(sp)
    8000044e:	e022                	sd	s0,0(sp)
    80000450:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000452:	00008597          	auipc	a1,0x8
    80000456:	bbe58593          	addi	a1,a1,-1090 # 80008010 <etext+0x10>
    8000045a:	00011517          	auipc	a0,0x11
    8000045e:	d2650513          	addi	a0,a0,-730 # 80011180 <cons>
    80000462:	00000097          	auipc	ra,0x0
    80000466:	6de080e7          	jalr	1758(ra) # 80000b40 <initlock>

  uartinit();
    8000046a:	00000097          	auipc	ra,0x0
    8000046e:	32a080e7          	jalr	810(ra) # 80000794 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000472:	00039797          	auipc	a5,0x39
    80000476:	2fe78793          	addi	a5,a5,766 # 80039770 <devsw>
    8000047a:	00000717          	auipc	a4,0x0
    8000047e:	cdc70713          	addi	a4,a4,-804 # 80000156 <consoleread>
    80000482:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000484:	00000717          	auipc	a4,0x0
    80000488:	c7070713          	addi	a4,a4,-912 # 800000f4 <consolewrite>
    8000048c:	ef98                	sd	a4,24(a5)
}
    8000048e:	60a2                	ld	ra,8(sp)
    80000490:	6402                	ld	s0,0(sp)
    80000492:	0141                	addi	sp,sp,16
    80000494:	8082                	ret

0000000080000496 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000496:	7179                	addi	sp,sp,-48
    80000498:	f406                	sd	ra,40(sp)
    8000049a:	f022                	sd	s0,32(sp)
    8000049c:	ec26                	sd	s1,24(sp)
    8000049e:	e84a                	sd	s2,16(sp)
    800004a0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a2:	c219                	beqz	a2,800004a8 <printint+0x12>
    800004a4:	08054663          	bltz	a0,80000530 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004a8:	2501                	sext.w	a0,a0
    800004aa:	4881                	li	a7,0
    800004ac:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b2:	2581                	sext.w	a1,a1
    800004b4:	00008617          	auipc	a2,0x8
    800004b8:	b8c60613          	addi	a2,a2,-1140 # 80008040 <digits>
    800004bc:	883a                	mv	a6,a4
    800004be:	2705                	addiw	a4,a4,1
    800004c0:	02b577bb          	remuw	a5,a0,a1
    800004c4:	1782                	slli	a5,a5,0x20
    800004c6:	9381                	srli	a5,a5,0x20
    800004c8:	97b2                	add	a5,a5,a2
    800004ca:	0007c783          	lbu	a5,0(a5)
    800004ce:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d2:	0005079b          	sext.w	a5,a0
    800004d6:	02b5553b          	divuw	a0,a0,a1
    800004da:	0685                	addi	a3,a3,1
    800004dc:	feb7f0e3          	bgeu	a5,a1,800004bc <printint+0x26>

  if(sign)
    800004e0:	00088b63          	beqz	a7,800004f6 <printint+0x60>
    buf[i++] = '-';
    800004e4:	fe040793          	addi	a5,s0,-32
    800004e8:	973e                	add	a4,a4,a5
    800004ea:	02d00793          	li	a5,45
    800004ee:	fef70823          	sb	a5,-16(a4)
    800004f2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004f6:	02e05763          	blez	a4,80000524 <printint+0x8e>
    800004fa:	fd040793          	addi	a5,s0,-48
    800004fe:	00e784b3          	add	s1,a5,a4
    80000502:	fff78913          	addi	s2,a5,-1
    80000506:	993a                	add	s2,s2,a4
    80000508:	377d                	addiw	a4,a4,-1
    8000050a:	1702                	slli	a4,a4,0x20
    8000050c:	9301                	srli	a4,a4,0x20
    8000050e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000512:	fff4c503          	lbu	a0,-1(s1)
    80000516:	00000097          	auipc	ra,0x0
    8000051a:	d60080e7          	jalr	-672(ra) # 80000276 <consputc>
  while(--i >= 0)
    8000051e:	14fd                	addi	s1,s1,-1
    80000520:	ff2499e3          	bne	s1,s2,80000512 <printint+0x7c>
}
    80000524:	70a2                	ld	ra,40(sp)
    80000526:	7402                	ld	s0,32(sp)
    80000528:	64e2                	ld	s1,24(sp)
    8000052a:	6942                	ld	s2,16(sp)
    8000052c:	6145                	addi	sp,sp,48
    8000052e:	8082                	ret
    x = -xx;
    80000530:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000534:	4885                	li	a7,1
    x = -xx;
    80000536:	bf9d                	j	800004ac <printint+0x16>

0000000080000538 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000538:	1101                	addi	sp,sp,-32
    8000053a:	ec06                	sd	ra,24(sp)
    8000053c:	e822                	sd	s0,16(sp)
    8000053e:	e426                	sd	s1,8(sp)
    80000540:	1000                	addi	s0,sp,32
    80000542:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000544:	00011797          	auipc	a5,0x11
    80000548:	ce07ae23          	sw	zero,-772(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000054c:	00008517          	auipc	a0,0x8
    80000550:	acc50513          	addi	a0,a0,-1332 # 80008018 <etext+0x18>
    80000554:	00000097          	auipc	ra,0x0
    80000558:	02e080e7          	jalr	46(ra) # 80000582 <printf>
  printf(s);
    8000055c:	8526                	mv	a0,s1
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	024080e7          	jalr	36(ra) # 80000582 <printf>
  printf("\n");
    80000566:	00008517          	auipc	a0,0x8
    8000056a:	b7250513          	addi	a0,a0,-1166 # 800080d8 <digits+0x98>
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	014080e7          	jalr	20(ra) # 80000582 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000576:	4785                	li	a5,1
    80000578:	00009717          	auipc	a4,0x9
    8000057c:	a8f72423          	sw	a5,-1400(a4) # 80009000 <panicked>
  for(;;)
    80000580:	a001                	j	80000580 <panic+0x48>

0000000080000582 <printf>:
{
    80000582:	7131                	addi	sp,sp,-192
    80000584:	fc86                	sd	ra,120(sp)
    80000586:	f8a2                	sd	s0,112(sp)
    80000588:	f4a6                	sd	s1,104(sp)
    8000058a:	f0ca                	sd	s2,96(sp)
    8000058c:	ecce                	sd	s3,88(sp)
    8000058e:	e8d2                	sd	s4,80(sp)
    80000590:	e4d6                	sd	s5,72(sp)
    80000592:	e0da                	sd	s6,64(sp)
    80000594:	fc5e                	sd	s7,56(sp)
    80000596:	f862                	sd	s8,48(sp)
    80000598:	f466                	sd	s9,40(sp)
    8000059a:	f06a                	sd	s10,32(sp)
    8000059c:	ec6e                	sd	s11,24(sp)
    8000059e:	0100                	addi	s0,sp,128
    800005a0:	8a2a                	mv	s4,a0
    800005a2:	e40c                	sd	a1,8(s0)
    800005a4:	e810                	sd	a2,16(s0)
    800005a6:	ec14                	sd	a3,24(s0)
    800005a8:	f018                	sd	a4,32(s0)
    800005aa:	f41c                	sd	a5,40(s0)
    800005ac:	03043823          	sd	a6,48(s0)
    800005b0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b4:	00011d97          	auipc	s11,0x11
    800005b8:	c8cdad83          	lw	s11,-884(s11) # 80011240 <pr+0x18>
  if(locking)
    800005bc:	020d9b63          	bnez	s11,800005f2 <printf+0x70>
  if (fmt == 0)
    800005c0:	040a0263          	beqz	s4,80000604 <printf+0x82>
  va_start(ap, fmt);
    800005c4:	00840793          	addi	a5,s0,8
    800005c8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005cc:	000a4503          	lbu	a0,0(s4)
    800005d0:	14050f63          	beqz	a0,8000072e <printf+0x1ac>
    800005d4:	4981                	li	s3,0
    if(c != '%'){
    800005d6:	02500a93          	li	s5,37
    switch(c){
    800005da:	07000b93          	li	s7,112
  consputc('x');
    800005de:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e0:	00008b17          	auipc	s6,0x8
    800005e4:	a60b0b13          	addi	s6,s6,-1440 # 80008040 <digits>
    switch(c){
    800005e8:	07300c93          	li	s9,115
    800005ec:	06400c13          	li	s8,100
    800005f0:	a82d                	j	8000062a <printf+0xa8>
    acquire(&pr.lock);
    800005f2:	00011517          	auipc	a0,0x11
    800005f6:	c3650513          	addi	a0,a0,-970 # 80011228 <pr>
    800005fa:	00000097          	auipc	ra,0x0
    800005fe:	5de080e7          	jalr	1502(ra) # 80000bd8 <acquire>
    80000602:	bf7d                	j	800005c0 <printf+0x3e>
    panic("null fmt");
    80000604:	00008517          	auipc	a0,0x8
    80000608:	a2450513          	addi	a0,a0,-1500 # 80008028 <etext+0x28>
    8000060c:	00000097          	auipc	ra,0x0
    80000610:	f2c080e7          	jalr	-212(ra) # 80000538 <panic>
      consputc(c);
    80000614:	00000097          	auipc	ra,0x0
    80000618:	c62080e7          	jalr	-926(ra) # 80000276 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000061c:	2985                	addiw	s3,s3,1
    8000061e:	013a07b3          	add	a5,s4,s3
    80000622:	0007c503          	lbu	a0,0(a5)
    80000626:	10050463          	beqz	a0,8000072e <printf+0x1ac>
    if(c != '%'){
    8000062a:	ff5515e3          	bne	a0,s5,80000614 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000062e:	2985                	addiw	s3,s3,1
    80000630:	013a07b3          	add	a5,s4,s3
    80000634:	0007c783          	lbu	a5,0(a5)
    80000638:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000063c:	cbed                	beqz	a5,8000072e <printf+0x1ac>
    switch(c){
    8000063e:	05778a63          	beq	a5,s7,80000692 <printf+0x110>
    80000642:	02fbf663          	bgeu	s7,a5,8000066e <printf+0xec>
    80000646:	09978863          	beq	a5,s9,800006d6 <printf+0x154>
    8000064a:	07800713          	li	a4,120
    8000064e:	0ce79563          	bne	a5,a4,80000718 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4605                	li	a2,1
    80000660:	85ea                	mv	a1,s10
    80000662:	4388                	lw	a0,0(a5)
    80000664:	00000097          	auipc	ra,0x0
    80000668:	e32080e7          	jalr	-462(ra) # 80000496 <printint>
      break;
    8000066c:	bf45                	j	8000061c <printf+0x9a>
    switch(c){
    8000066e:	09578f63          	beq	a5,s5,8000070c <printf+0x18a>
    80000672:	0b879363          	bne	a5,s8,80000718 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000676:	f8843783          	ld	a5,-120(s0)
    8000067a:	00878713          	addi	a4,a5,8
    8000067e:	f8e43423          	sd	a4,-120(s0)
    80000682:	4605                	li	a2,1
    80000684:	45a9                	li	a1,10
    80000686:	4388                	lw	a0,0(a5)
    80000688:	00000097          	auipc	ra,0x0
    8000068c:	e0e080e7          	jalr	-498(ra) # 80000496 <printint>
      break;
    80000690:	b771                	j	8000061c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a2:	03000513          	li	a0,48
    800006a6:	00000097          	auipc	ra,0x0
    800006aa:	bd0080e7          	jalr	-1072(ra) # 80000276 <consputc>
  consputc('x');
    800006ae:	07800513          	li	a0,120
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bc4080e7          	jalr	-1084(ra) # 80000276 <consputc>
    800006ba:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006bc:	03c95793          	srli	a5,s2,0x3c
    800006c0:	97da                	add	a5,a5,s6
    800006c2:	0007c503          	lbu	a0,0(a5)
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	bb0080e7          	jalr	-1104(ra) # 80000276 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ce:	0912                	slli	s2,s2,0x4
    800006d0:	34fd                	addiw	s1,s1,-1
    800006d2:	f4ed                	bnez	s1,800006bc <printf+0x13a>
    800006d4:	b7a1                	j	8000061c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d6:	f8843783          	ld	a5,-120(s0)
    800006da:	00878713          	addi	a4,a5,8
    800006de:	f8e43423          	sd	a4,-120(s0)
    800006e2:	6384                	ld	s1,0(a5)
    800006e4:	cc89                	beqz	s1,800006fe <printf+0x17c>
      for(; *s; s++)
    800006e6:	0004c503          	lbu	a0,0(s1)
    800006ea:	d90d                	beqz	a0,8000061c <printf+0x9a>
        consputc(*s);
    800006ec:	00000097          	auipc	ra,0x0
    800006f0:	b8a080e7          	jalr	-1142(ra) # 80000276 <consputc>
      for(; *s; s++)
    800006f4:	0485                	addi	s1,s1,1
    800006f6:	0004c503          	lbu	a0,0(s1)
    800006fa:	f96d                	bnez	a0,800006ec <printf+0x16a>
    800006fc:	b705                	j	8000061c <printf+0x9a>
        s = "(null)";
    800006fe:	00008497          	auipc	s1,0x8
    80000702:	92248493          	addi	s1,s1,-1758 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000706:	02800513          	li	a0,40
    8000070a:	b7cd                	j	800006ec <printf+0x16a>
      consputc('%');
    8000070c:	8556                	mv	a0,s5
    8000070e:	00000097          	auipc	ra,0x0
    80000712:	b68080e7          	jalr	-1176(ra) # 80000276 <consputc>
      break;
    80000716:	b719                	j	8000061c <printf+0x9a>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b5c080e7          	jalr	-1188(ra) # 80000276 <consputc>
      consputc(c);
    80000722:	8526                	mv	a0,s1
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b52080e7          	jalr	-1198(ra) # 80000276 <consputc>
      break;
    8000072c:	bdc5                	j	8000061c <printf+0x9a>
  if(locking)
    8000072e:	020d9163          	bnez	s11,80000750 <printf+0x1ce>
}
    80000732:	70e6                	ld	ra,120(sp)
    80000734:	7446                	ld	s0,112(sp)
    80000736:	74a6                	ld	s1,104(sp)
    80000738:	7906                	ld	s2,96(sp)
    8000073a:	69e6                	ld	s3,88(sp)
    8000073c:	6a46                	ld	s4,80(sp)
    8000073e:	6aa6                	ld	s5,72(sp)
    80000740:	6b06                	ld	s6,64(sp)
    80000742:	7be2                	ld	s7,56(sp)
    80000744:	7c42                	ld	s8,48(sp)
    80000746:	7ca2                	ld	s9,40(sp)
    80000748:	7d02                	ld	s10,32(sp)
    8000074a:	6de2                	ld	s11,24(sp)
    8000074c:	6129                	addi	sp,sp,192
    8000074e:	8082                	ret
    release(&pr.lock);
    80000750:	00011517          	auipc	a0,0x11
    80000754:	ad850513          	addi	a0,a0,-1320 # 80011228 <pr>
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	54c080e7          	jalr	1356(ra) # 80000ca4 <release>
}
    80000760:	bfc9                	j	80000732 <printf+0x1b0>

0000000080000762 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000762:	1101                	addi	sp,sp,-32
    80000764:	ec06                	sd	ra,24(sp)
    80000766:	e822                	sd	s0,16(sp)
    80000768:	e426                	sd	s1,8(sp)
    8000076a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076c:	00011497          	auipc	s1,0x11
    80000770:	abc48493          	addi	s1,s1,-1348 # 80011228 <pr>
    80000774:	00008597          	auipc	a1,0x8
    80000778:	8c458593          	addi	a1,a1,-1852 # 80008038 <etext+0x38>
    8000077c:	8526                	mv	a0,s1
    8000077e:	00000097          	auipc	ra,0x0
    80000782:	3c2080e7          	jalr	962(ra) # 80000b40 <initlock>
  pr.locking = 1;
    80000786:	4785                	li	a5,1
    80000788:	cc9c                	sw	a5,24(s1)
}
    8000078a:	60e2                	ld	ra,24(sp)
    8000078c:	6442                	ld	s0,16(sp)
    8000078e:	64a2                	ld	s1,8(sp)
    80000790:	6105                	addi	sp,sp,32
    80000792:	8082                	ret

0000000080000794 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000794:	1141                	addi	sp,sp,-16
    80000796:	e406                	sd	ra,8(sp)
    80000798:	e022                	sd	s0,0(sp)
    8000079a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079c:	100007b7          	lui	a5,0x10000
    800007a0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a4:	f8000713          	li	a4,-128
    800007a8:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ac:	470d                	li	a4,3
    800007ae:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b2:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b6:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ba:	469d                	li	a3,7
    800007bc:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c0:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	89458593          	addi	a1,a1,-1900 # 80008058 <digits+0x18>
    800007cc:	00011517          	auipc	a0,0x11
    800007d0:	a7c50513          	addi	a0,a0,-1412 # 80011248 <uart_tx_lock>
    800007d4:	00000097          	auipc	ra,0x0
    800007d8:	36c080e7          	jalr	876(ra) # 80000b40 <initlock>
}
    800007dc:	60a2                	ld	ra,8(sp)
    800007de:	6402                	ld	s0,0(sp)
    800007e0:	0141                	addi	sp,sp,16
    800007e2:	8082                	ret

00000000800007e4 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e4:	1101                	addi	sp,sp,-32
    800007e6:	ec06                	sd	ra,24(sp)
    800007e8:	e822                	sd	s0,16(sp)
    800007ea:	e426                	sd	s1,8(sp)
    800007ec:	1000                	addi	s0,sp,32
    800007ee:	84aa                	mv	s1,a0
  push_off();
    800007f0:	00000097          	auipc	ra,0x0
    800007f4:	394080e7          	jalr	916(ra) # 80000b84 <push_off>

  if(panicked){
    800007f8:	00009797          	auipc	a5,0x9
    800007fc:	8087a783          	lw	a5,-2040(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000800:	10000737          	lui	a4,0x10000
  if(panicked){
    80000804:	c391                	beqz	a5,80000808 <uartputc_sync+0x24>
    for(;;)
    80000806:	a001                	j	80000806 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080c:	0207f793          	andi	a5,a5,32
    80000810:	dfe5                	beqz	a5,80000808 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000812:	0ff4f513          	andi	a0,s1,255
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000081e:	00000097          	auipc	ra,0x0
    80000822:	420080e7          	jalr	1056(ra) # 80000c3e <pop_off>
}
    80000826:	60e2                	ld	ra,24(sp)
    80000828:	6442                	ld	s0,16(sp)
    8000082a:	64a2                	ld	s1,8(sp)
    8000082c:	6105                	addi	sp,sp,32
    8000082e:	8082                	ret

0000000080000830 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000830:	00008797          	auipc	a5,0x8
    80000834:	7d87b783          	ld	a5,2008(a5) # 80009008 <uart_tx_r>
    80000838:	00008717          	auipc	a4,0x8
    8000083c:	7d873703          	ld	a4,2008(a4) # 80009010 <uart_tx_w>
    80000840:	06f70a63          	beq	a4,a5,800008b4 <uartstart+0x84>
{
    80000844:	7139                	addi	sp,sp,-64
    80000846:	fc06                	sd	ra,56(sp)
    80000848:	f822                	sd	s0,48(sp)
    8000084a:	f426                	sd	s1,40(sp)
    8000084c:	f04a                	sd	s2,32(sp)
    8000084e:	ec4e                	sd	s3,24(sp)
    80000850:	e852                	sd	s4,16(sp)
    80000852:	e456                	sd	s5,8(sp)
    80000854:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000856:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085a:	00011a17          	auipc	s4,0x11
    8000085e:	9eea0a13          	addi	s4,s4,-1554 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000862:	00008497          	auipc	s1,0x8
    80000866:	7a648493          	addi	s1,s1,1958 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086a:	00008997          	auipc	s3,0x8
    8000086e:	7a698993          	addi	s3,s3,1958 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000872:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000876:	02077713          	andi	a4,a4,32
    8000087a:	c705                	beqz	a4,800008a2 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000087c:	01f7f713          	andi	a4,a5,31
    80000880:	9752                	add	a4,a4,s4
    80000882:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000886:	0785                	addi	a5,a5,1
    80000888:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088a:	8526                	mv	a0,s1
    8000088c:	00002097          	auipc	ra,0x2
    80000890:	c68080e7          	jalr	-920(ra) # 800024f4 <wakeup>
    
    WriteReg(THR, c);
    80000894:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80000898:	609c                	ld	a5,0(s1)
    8000089a:	0009b703          	ld	a4,0(s3)
    8000089e:	fcf71ae3          	bne	a4,a5,80000872 <uartstart+0x42>
  }
}
    800008a2:	70e2                	ld	ra,56(sp)
    800008a4:	7442                	ld	s0,48(sp)
    800008a6:	74a2                	ld	s1,40(sp)
    800008a8:	7902                	ld	s2,32(sp)
    800008aa:	69e2                	ld	s3,24(sp)
    800008ac:	6a42                	ld	s4,16(sp)
    800008ae:	6aa2                	ld	s5,8(sp)
    800008b0:	6121                	addi	sp,sp,64
    800008b2:	8082                	ret
    800008b4:	8082                	ret

00000000800008b6 <uartputc>:
{
    800008b6:	7179                	addi	sp,sp,-48
    800008b8:	f406                	sd	ra,40(sp)
    800008ba:	f022                	sd	s0,32(sp)
    800008bc:	ec26                	sd	s1,24(sp)
    800008be:	e84a                	sd	s2,16(sp)
    800008c0:	e44e                	sd	s3,8(sp)
    800008c2:	e052                	sd	s4,0(sp)
    800008c4:	1800                	addi	s0,sp,48
    800008c6:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008c8:	00011517          	auipc	a0,0x11
    800008cc:	98050513          	addi	a0,a0,-1664 # 80011248 <uart_tx_lock>
    800008d0:	00000097          	auipc	ra,0x0
    800008d4:	308080e7          	jalr	776(ra) # 80000bd8 <acquire>
  if(panicked){
    800008d8:	00008797          	auipc	a5,0x8
    800008dc:	7287a783          	lw	a5,1832(a5) # 80009000 <panicked>
    800008e0:	c391                	beqz	a5,800008e4 <uartputc+0x2e>
    for(;;)
    800008e2:	a001                	j	800008e2 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e4:	00008717          	auipc	a4,0x8
    800008e8:	72c73703          	ld	a4,1836(a4) # 80009010 <uart_tx_w>
    800008ec:	00008797          	auipc	a5,0x8
    800008f0:	71c7b783          	ld	a5,1820(a5) # 80009008 <uart_tx_r>
    800008f4:	02078793          	addi	a5,a5,32
    800008f8:	02e79b63          	bne	a5,a4,8000092e <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00011997          	auipc	s3,0x11
    80000900:	94c98993          	addi	s3,s3,-1716 # 80011248 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	70448493          	addi	s1,s1,1796 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	70490913          	addi	s2,s2,1796 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000914:	85ce                	mv	a1,s3
    80000916:	8526                	mv	a0,s1
    80000918:	00002097          	auipc	ra,0x2
    8000091c:	a46080e7          	jalr	-1466(ra) # 8000235e <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00093703          	ld	a4,0(s2)
    80000924:	609c                	ld	a5,0(s1)
    80000926:	02078793          	addi	a5,a5,32
    8000092a:	fee785e3          	beq	a5,a4,80000914 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000092e:	00011497          	auipc	s1,0x11
    80000932:	91a48493          	addi	s1,s1,-1766 # 80011248 <uart_tx_lock>
    80000936:	01f77793          	andi	a5,a4,31
    8000093a:	97a6                	add	a5,a5,s1
    8000093c:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000940:	0705                	addi	a4,a4,1
    80000942:	00008797          	auipc	a5,0x8
    80000946:	6ce7b723          	sd	a4,1742(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	ee6080e7          	jalr	-282(ra) # 80000830 <uartstart>
      release(&uart_tx_lock);
    80000952:	8526                	mv	a0,s1
    80000954:	00000097          	auipc	ra,0x0
    80000958:	350080e7          	jalr	848(ra) # 80000ca4 <release>
}
    8000095c:	70a2                	ld	ra,40(sp)
    8000095e:	7402                	ld	s0,32(sp)
    80000960:	64e2                	ld	s1,24(sp)
    80000962:	6942                	ld	s2,16(sp)
    80000964:	69a2                	ld	s3,8(sp)
    80000966:	6a02                	ld	s4,0(sp)
    80000968:	6145                	addi	sp,sp,48
    8000096a:	8082                	ret

000000008000096c <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000096c:	1141                	addi	sp,sp,-16
    8000096e:	e422                	sd	s0,8(sp)
    80000970:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000972:	100007b7          	lui	a5,0x10000
    80000976:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097a:	8b85                	andi	a5,a5,1
    8000097c:	cb91                	beqz	a5,80000990 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    8000097e:	100007b7          	lui	a5,0x10000
    80000982:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000986:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1e>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	916080e7          	jalr	-1770(ra) # 800002b8 <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc2080e7          	jalr	-62(ra) # 8000096c <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00011497          	auipc	s1,0x11
    800009ba:	89248493          	addi	s1,s1,-1902 # 80011248 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	218080e7          	jalr	536(ra) # 80000bd8 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e68080e7          	jalr	-408(ra) # 80000830 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2d2080e7          	jalr	722(ra) # 80000ca4 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	0003d797          	auipc	a5,0x3d
    800009fc:	60878793          	addi	a5,a5,1544 # 8003e000 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2dc080e7          	jalr	732(ra) # 80000cec <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00011917          	auipc	s2,0x11
    80000a1c:	86890913          	addi	s2,s2,-1944 # 80011280 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b6080e7          	jalr	438(ra) # 80000bd8 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	26e080e7          	jalr	622(ra) # 80000ca4 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	ae6080e7          	jalr	-1306(ra) # 80000538 <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	94aa                	add	s1,s1,a0
    80000a72:	757d                	lui	a0,0xfffff
    80000a74:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a76:	94be                	add	s1,s1,a5
    80000a78:	0095ee63          	bltu	a1,s1,80000a94 <freerange+0x3a>
    80000a7c:	892e                	mv	s2,a1
    kfree(p);
    80000a7e:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	6985                	lui	s3,0x1
    kfree(p);
    80000a82:	01448533          	add	a0,s1,s4
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	f5e080e7          	jalr	-162(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8e:	94ce                	add	s1,s1,s3
    80000a90:	fe9979e3          	bgeu	s2,s1,80000a82 <freerange+0x28>
}
    80000a94:	70a2                	ld	ra,40(sp)
    80000a96:	7402                	ld	s0,32(sp)
    80000a98:	64e2                	ld	s1,24(sp)
    80000a9a:	6942                	ld	s2,16(sp)
    80000a9c:	69a2                	ld	s3,8(sp)
    80000a9e:	6a02                	ld	s4,0(sp)
    80000aa0:	6145                	addi	sp,sp,48
    80000aa2:	8082                	ret

0000000080000aa4 <kinit>:
{
    80000aa4:	1141                	addi	sp,sp,-16
    80000aa6:	e406                	sd	ra,8(sp)
    80000aa8:	e022                	sd	s0,0(sp)
    80000aaa:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aac:	00007597          	auipc	a1,0x7
    80000ab0:	5bc58593          	addi	a1,a1,1468 # 80008068 <digits+0x28>
    80000ab4:	00010517          	auipc	a0,0x10
    80000ab8:	7cc50513          	addi	a0,a0,1996 # 80011280 <kmem>
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	084080e7          	jalr	132(ra) # 80000b40 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac4:	45c5                	li	a1,17
    80000ac6:	05ee                	slli	a1,a1,0x1b
    80000ac8:	0003d517          	auipc	a0,0x3d
    80000acc:	53850513          	addi	a0,a0,1336 # 8003e000 <end>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	f8a080e7          	jalr	-118(ra) # 80000a5a <freerange>
}
    80000ad8:	60a2                	ld	ra,8(sp)
    80000ada:	6402                	ld	s0,0(sp)
    80000adc:	0141                	addi	sp,sp,16
    80000ade:	8082                	ret

0000000080000ae0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae0:	1101                	addi	sp,sp,-32
    80000ae2:	ec06                	sd	ra,24(sp)
    80000ae4:	e822                	sd	s0,16(sp)
    80000ae6:	e426                	sd	s1,8(sp)
    80000ae8:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aea:	00010497          	auipc	s1,0x10
    80000aee:	79648493          	addi	s1,s1,1942 # 80011280 <kmem>
    80000af2:	8526                	mv	a0,s1
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	0e4080e7          	jalr	228(ra) # 80000bd8 <acquire>
  r = kmem.freelist;
    80000afc:	6c84                	ld	s1,24(s1)
  if(r)
    80000afe:	c885                	beqz	s1,80000b2e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b00:	609c                	ld	a5,0(s1)
    80000b02:	00010517          	auipc	a0,0x10
    80000b06:	77e50513          	addi	a0,a0,1918 # 80011280 <kmem>
    80000b0a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	198080e7          	jalr	408(ra) # 80000ca4 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b14:	6605                	lui	a2,0x1
    80000b16:	4595                	li	a1,5
    80000b18:	8526                	mv	a0,s1
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	1d2080e7          	jalr	466(ra) # 80000cec <memset>
  return (void*)r;
}
    80000b22:	8526                	mv	a0,s1
    80000b24:	60e2                	ld	ra,24(sp)
    80000b26:	6442                	ld	s0,16(sp)
    80000b28:	64a2                	ld	s1,8(sp)
    80000b2a:	6105                	addi	sp,sp,32
    80000b2c:	8082                	ret
  release(&kmem.lock);
    80000b2e:	00010517          	auipc	a0,0x10
    80000b32:	75250513          	addi	a0,a0,1874 # 80011280 <kmem>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	16e080e7          	jalr	366(ra) # 80000ca4 <release>
  if(r)
    80000b3e:	b7d5                	j	80000b22 <kalloc+0x42>

0000000080000b40 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b40:	1141                	addi	sp,sp,-16
    80000b42:	e422                	sd	s0,8(sp)
    80000b44:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b46:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b48:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4c:	00053823          	sd	zero,16(a0)
}
    80000b50:	6422                	ld	s0,8(sp)
    80000b52:	0141                	addi	sp,sp,16
    80000b54:	8082                	ret

0000000080000b56 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b56:	411c                	lw	a5,0(a0)
    80000b58:	e399                	bnez	a5,80000b5e <holding+0x8>
    80000b5a:	4501                	li	a0,0
  return r;
}
    80000b5c:	8082                	ret
{
    80000b5e:	1101                	addi	sp,sp,-32
    80000b60:	ec06                	sd	ra,24(sp)
    80000b62:	e822                	sd	s0,16(sp)
    80000b64:	e426                	sd	s1,8(sp)
    80000b66:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b68:	6904                	ld	s1,16(a0)
    80000b6a:	00001097          	auipc	ra,0x1
    80000b6e:	ec8080e7          	jalr	-312(ra) # 80001a32 <mycpu>
    80000b72:	40a48533          	sub	a0,s1,a0
    80000b76:	00153513          	seqz	a0,a0
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret

0000000080000b84 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b84:	1101                	addi	sp,sp,-32
    80000b86:	ec06                	sd	ra,24(sp)
    80000b88:	e822                	sd	s0,16(sp)
    80000b8a:	e426                	sd	s1,8(sp)
    80000b8c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b8e:	100024f3          	csrr	s1,sstatus
    80000b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b96:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b98:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9c:	00001097          	auipc	ra,0x1
    80000ba0:	e96080e7          	jalr	-362(ra) # 80001a32 <mycpu>
    80000ba4:	08052783          	lw	a5,128(a0)
    80000ba8:	cf99                	beqz	a5,80000bc6 <push_off+0x42>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	e88080e7          	jalr	-376(ra) # 80001a32 <mycpu>
    80000bb2:	08052783          	lw	a5,128(a0)
    80000bb6:	2785                	addiw	a5,a5,1
    80000bb8:	08f52023          	sw	a5,128(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	e6c080e7          	jalr	-404(ra) # 80001a32 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	08952223          	sw	s1,132(a0)
    80000bd6:	bfd1                	j	80000baa <push_off+0x26>

0000000080000bd8 <acquire>:
{
    80000bd8:	1101                	addi	sp,sp,-32
    80000bda:	ec06                	sd	ra,24(sp)
    80000bdc:	e822                	sd	s0,16(sp)
    80000bde:	e426                	sd	s1,8(sp)
    80000be0:	1000                	addi	s0,sp,32
    80000be2:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be4:	00000097          	auipc	ra,0x0
    80000be8:	fa0080e7          	jalr	-96(ra) # 80000b84 <push_off>
  if(holding(lk)){
    80000bec:	8526                	mv	a0,s1
    80000bee:	00000097          	auipc	ra,0x0
    80000bf2:	f68080e7          	jalr	-152(ra) # 80000b56 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf6:	4705                	li	a4,1
  if(holding(lk)){
    80000bf8:	e115                	bnez	a0,80000c1c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bfa:	87ba                	mv	a5,a4
    80000bfc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c00:	2781                	sext.w	a5,a5
    80000c02:	ffe5                	bnez	a5,80000bfa <acquire+0x22>
  __sync_synchronize();
    80000c04:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c08:	00001097          	auipc	ra,0x1
    80000c0c:	e2a080e7          	jalr	-470(ra) # 80001a32 <mycpu>
    80000c10:	e888                	sd	a0,16(s1)
}
    80000c12:	60e2                	ld	ra,24(sp)
    80000c14:	6442                	ld	s0,16(sp)
    80000c16:	64a2                	ld	s1,8(sp)
    80000c18:	6105                	addi	sp,sp,32
    80000c1a:	8082                	ret
    printf("lcokname: %s",lk->name);
    80000c1c:	648c                	ld	a1,8(s1)
    80000c1e:	00007517          	auipc	a0,0x7
    80000c22:	45250513          	addi	a0,a0,1106 # 80008070 <digits+0x30>
    80000c26:	00000097          	auipc	ra,0x0
    80000c2a:	95c080e7          	jalr	-1700(ra) # 80000582 <printf>
    panic("acquire");
    80000c2e:	00007517          	auipc	a0,0x7
    80000c32:	45250513          	addi	a0,a0,1106 # 80008080 <digits+0x40>
    80000c36:	00000097          	auipc	ra,0x0
    80000c3a:	902080e7          	jalr	-1790(ra) # 80000538 <panic>

0000000080000c3e <pop_off>:

void
pop_off(void)
{
    80000c3e:	1141                	addi	sp,sp,-16
    80000c40:	e406                	sd	ra,8(sp)
    80000c42:	e022                	sd	s0,0(sp)
    80000c44:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c46:	00001097          	auipc	ra,0x1
    80000c4a:	dec080e7          	jalr	-532(ra) # 80001a32 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c54:	eb85                	bnez	a5,80000c84 <pop_off+0x46>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c56:	08052783          	lw	a5,128(a0)
    80000c5a:	02f05d63          	blez	a5,80000c94 <pop_off+0x56>
    panic("pop_off");
  c->noff -= 1;
    80000c5e:	37fd                	addiw	a5,a5,-1
    80000c60:	0007871b          	sext.w	a4,a5
    80000c64:	08f52023          	sw	a5,128(a0)
  if(c->noff == 0 && c->intena)
    80000c68:	eb11                	bnez	a4,80000c7c <pop_off+0x3e>
    80000c6a:	08452783          	lw	a5,132(a0)
    80000c6e:	c799                	beqz	a5,80000c7c <pop_off+0x3e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c70:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c74:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c78:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c7c:	60a2                	ld	ra,8(sp)
    80000c7e:	6402                	ld	s0,0(sp)
    80000c80:	0141                	addi	sp,sp,16
    80000c82:	8082                	ret
    panic("pop_off - interruptible");
    80000c84:	00007517          	auipc	a0,0x7
    80000c88:	40450513          	addi	a0,a0,1028 # 80008088 <digits+0x48>
    80000c8c:	00000097          	auipc	ra,0x0
    80000c90:	8ac080e7          	jalr	-1876(ra) # 80000538 <panic>
    panic("pop_off");
    80000c94:	00007517          	auipc	a0,0x7
    80000c98:	40c50513          	addi	a0,a0,1036 # 800080a0 <digits+0x60>
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	89c080e7          	jalr	-1892(ra) # 80000538 <panic>

0000000080000ca4 <release>:
{
    80000ca4:	1101                	addi	sp,sp,-32
    80000ca6:	ec06                	sd	ra,24(sp)
    80000ca8:	e822                	sd	s0,16(sp)
    80000caa:	e426                	sd	s1,8(sp)
    80000cac:	1000                	addi	s0,sp,32
    80000cae:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	ea6080e7          	jalr	-346(ra) # 80000b56 <holding>
    80000cb8:	c115                	beqz	a0,80000cdc <release+0x38>
  lk->cpu = 0;
    80000cba:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cbe:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cc2:	0f50000f          	fence	iorw,ow
    80000cc6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	f74080e7          	jalr	-140(ra) # 80000c3e <pop_off>
}
    80000cd2:	60e2                	ld	ra,24(sp)
    80000cd4:	6442                	ld	s0,16(sp)
    80000cd6:	64a2                	ld	s1,8(sp)
    80000cd8:	6105                	addi	sp,sp,32
    80000cda:	8082                	ret
    panic("release");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	3cc50513          	addi	a0,a0,972 # 800080a8 <digits+0x68>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	854080e7          	jalr	-1964(ra) # 80000538 <panic>

0000000080000cec <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cec:	1141                	addi	sp,sp,-16
    80000cee:	e422                	sd	s0,8(sp)
    80000cf0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cf2:	ca19                	beqz	a2,80000d08 <memset+0x1c>
    80000cf4:	87aa                	mv	a5,a0
    80000cf6:	1602                	slli	a2,a2,0x20
    80000cf8:	9201                	srli	a2,a2,0x20
    80000cfa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cfe:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d02:	0785                	addi	a5,a5,1
    80000d04:	fee79de3          	bne	a5,a4,80000cfe <memset+0x12>
  }
  return dst;
}
    80000d08:	6422                	ld	s0,8(sp)
    80000d0a:	0141                	addi	sp,sp,16
    80000d0c:	8082                	ret

0000000080000d0e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d0e:	1141                	addi	sp,sp,-16
    80000d10:	e422                	sd	s0,8(sp)
    80000d12:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d14:	ca05                	beqz	a2,80000d44 <memcmp+0x36>
    80000d16:	fff6069b          	addiw	a3,a2,-1
    80000d1a:	1682                	slli	a3,a3,0x20
    80000d1c:	9281                	srli	a3,a3,0x20
    80000d1e:	0685                	addi	a3,a3,1
    80000d20:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d22:	00054783          	lbu	a5,0(a0)
    80000d26:	0005c703          	lbu	a4,0(a1)
    80000d2a:	00e79863          	bne	a5,a4,80000d3a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d2e:	0505                	addi	a0,a0,1
    80000d30:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d32:	fed518e3          	bne	a0,a3,80000d22 <memcmp+0x14>
  }

  return 0;
    80000d36:	4501                	li	a0,0
    80000d38:	a019                	j	80000d3e <memcmp+0x30>
      return *s1 - *s2;
    80000d3a:	40e7853b          	subw	a0,a5,a4
}
    80000d3e:	6422                	ld	s0,8(sp)
    80000d40:	0141                	addi	sp,sp,16
    80000d42:	8082                	ret
  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	bfe5                	j	80000d3e <memcmp+0x30>

0000000080000d48 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d48:	1141                	addi	sp,sp,-16
    80000d4a:	e422                	sd	s0,8(sp)
    80000d4c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d4e:	02a5e563          	bltu	a1,a0,80000d78 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d52:	fff6069b          	addiw	a3,a2,-1
    80000d56:	ce11                	beqz	a2,80000d72 <memmove+0x2a>
    80000d58:	1682                	slli	a3,a3,0x20
    80000d5a:	9281                	srli	a3,a3,0x20
    80000d5c:	0685                	addi	a3,a3,1
    80000d5e:	96ae                	add	a3,a3,a1
    80000d60:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d62:	0585                	addi	a1,a1,1
    80000d64:	0785                	addi	a5,a5,1
    80000d66:	fff5c703          	lbu	a4,-1(a1)
    80000d6a:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d6e:	fed59ae3          	bne	a1,a3,80000d62 <memmove+0x1a>

  return dst;
}
    80000d72:	6422                	ld	s0,8(sp)
    80000d74:	0141                	addi	sp,sp,16
    80000d76:	8082                	ret
  if(s < d && s + n > d){
    80000d78:	02061713          	slli	a4,a2,0x20
    80000d7c:	9301                	srli	a4,a4,0x20
    80000d7e:	00e587b3          	add	a5,a1,a4
    80000d82:	fcf578e3          	bgeu	a0,a5,80000d52 <memmove+0xa>
    d += n;
    80000d86:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d88:	fff6069b          	addiw	a3,a2,-1
    80000d8c:	d27d                	beqz	a2,80000d72 <memmove+0x2a>
    80000d8e:	02069613          	slli	a2,a3,0x20
    80000d92:	9201                	srli	a2,a2,0x20
    80000d94:	fff64613          	not	a2,a2
    80000d98:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d9a:	17fd                	addi	a5,a5,-1
    80000d9c:	177d                	addi	a4,a4,-1
    80000d9e:	0007c683          	lbu	a3,0(a5)
    80000da2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000da6:	fef61ae3          	bne	a2,a5,80000d9a <memmove+0x52>
    80000daa:	b7e1                	j	80000d72 <memmove+0x2a>

0000000080000dac <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dac:	1141                	addi	sp,sp,-16
    80000dae:	e406                	sd	ra,8(sp)
    80000db0:	e022                	sd	s0,0(sp)
    80000db2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000db4:	00000097          	auipc	ra,0x0
    80000db8:	f94080e7          	jalr	-108(ra) # 80000d48 <memmove>
}
    80000dbc:	60a2                	ld	ra,8(sp)
    80000dbe:	6402                	ld	s0,0(sp)
    80000dc0:	0141                	addi	sp,sp,16
    80000dc2:	8082                	ret

0000000080000dc4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dc4:	1141                	addi	sp,sp,-16
    80000dc6:	e422                	sd	s0,8(sp)
    80000dc8:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dca:	ce11                	beqz	a2,80000de6 <strncmp+0x22>
    80000dcc:	00054783          	lbu	a5,0(a0)
    80000dd0:	cf89                	beqz	a5,80000dea <strncmp+0x26>
    80000dd2:	0005c703          	lbu	a4,0(a1)
    80000dd6:	00f71a63          	bne	a4,a5,80000dea <strncmp+0x26>
    n--, p++, q++;
    80000dda:	367d                	addiw	a2,a2,-1
    80000ddc:	0505                	addi	a0,a0,1
    80000dde:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000de0:	f675                	bnez	a2,80000dcc <strncmp+0x8>
  if(n == 0)
    return 0;
    80000de2:	4501                	li	a0,0
    80000de4:	a809                	j	80000df6 <strncmp+0x32>
    80000de6:	4501                	li	a0,0
    80000de8:	a039                	j	80000df6 <strncmp+0x32>
  if(n == 0)
    80000dea:	ca09                	beqz	a2,80000dfc <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dec:	00054503          	lbu	a0,0(a0)
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	9d1d                	subw	a0,a0,a5
}
    80000df6:	6422                	ld	s0,8(sp)
    80000df8:	0141                	addi	sp,sp,16
    80000dfa:	8082                	ret
    return 0;
    80000dfc:	4501                	li	a0,0
    80000dfe:	bfe5                	j	80000df6 <strncmp+0x32>

0000000080000e00 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e00:	1141                	addi	sp,sp,-16
    80000e02:	e422                	sd	s0,8(sp)
    80000e04:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e06:	872a                	mv	a4,a0
    80000e08:	8832                	mv	a6,a2
    80000e0a:	367d                	addiw	a2,a2,-1
    80000e0c:	01005963          	blez	a6,80000e1e <strncpy+0x1e>
    80000e10:	0705                	addi	a4,a4,1
    80000e12:	0005c783          	lbu	a5,0(a1)
    80000e16:	fef70fa3          	sb	a5,-1(a4)
    80000e1a:	0585                	addi	a1,a1,1
    80000e1c:	f7f5                	bnez	a5,80000e08 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e1e:	86ba                	mv	a3,a4
    80000e20:	00c05c63          	blez	a2,80000e38 <strncpy+0x38>
    *s++ = 0;
    80000e24:	0685                	addi	a3,a3,1
    80000e26:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e2a:	fff6c793          	not	a5,a3
    80000e2e:	9fb9                	addw	a5,a5,a4
    80000e30:	010787bb          	addw	a5,a5,a6
    80000e34:	fef048e3          	bgtz	a5,80000e24 <strncpy+0x24>
  return os;
}
    80000e38:	6422                	ld	s0,8(sp)
    80000e3a:	0141                	addi	sp,sp,16
    80000e3c:	8082                	ret

0000000080000e3e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e3e:	1141                	addi	sp,sp,-16
    80000e40:	e422                	sd	s0,8(sp)
    80000e42:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e44:	02c05363          	blez	a2,80000e6a <safestrcpy+0x2c>
    80000e48:	fff6069b          	addiw	a3,a2,-1
    80000e4c:	1682                	slli	a3,a3,0x20
    80000e4e:	9281                	srli	a3,a3,0x20
    80000e50:	96ae                	add	a3,a3,a1
    80000e52:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e54:	00d58963          	beq	a1,a3,80000e66 <safestrcpy+0x28>
    80000e58:	0585                	addi	a1,a1,1
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff5c703          	lbu	a4,-1(a1)
    80000e60:	fee78fa3          	sb	a4,-1(a5)
    80000e64:	fb65                	bnez	a4,80000e54 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e66:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e6a:	6422                	ld	s0,8(sp)
    80000e6c:	0141                	addi	sp,sp,16
    80000e6e:	8082                	ret

0000000080000e70 <strlen>:

int
strlen(const char *s)
{
    80000e70:	1141                	addi	sp,sp,-16
    80000e72:	e422                	sd	s0,8(sp)
    80000e74:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e76:	00054783          	lbu	a5,0(a0)
    80000e7a:	cf91                	beqz	a5,80000e96 <strlen+0x26>
    80000e7c:	0505                	addi	a0,a0,1
    80000e7e:	87aa                	mv	a5,a0
    80000e80:	4685                	li	a3,1
    80000e82:	9e89                	subw	a3,a3,a0
    80000e84:	00f6853b          	addw	a0,a3,a5
    80000e88:	0785                	addi	a5,a5,1
    80000e8a:	fff7c703          	lbu	a4,-1(a5)
    80000e8e:	fb7d                	bnez	a4,80000e84 <strlen+0x14>
    ;
  return n;
}
    80000e90:	6422                	ld	s0,8(sp)
    80000e92:	0141                	addi	sp,sp,16
    80000e94:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e96:	4501                	li	a0,0
    80000e98:	bfe5                	j	80000e90 <strlen+0x20>

0000000080000e9a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e9a:	1141                	addi	sp,sp,-16
    80000e9c:	e406                	sd	ra,8(sp)
    80000e9e:	e022                	sd	s0,0(sp)
    80000ea0:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ea2:	00001097          	auipc	ra,0x1
    80000ea6:	b80080e7          	jalr	-1152(ra) # 80001a22 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eaa:	00008717          	auipc	a4,0x8
    80000eae:	16e70713          	addi	a4,a4,366 # 80009018 <started>
  if(cpuid() == 0){
    80000eb2:	c139                	beqz	a0,80000ef8 <main+0x5e>
    while(started == 0)
    80000eb4:	431c                	lw	a5,0(a4)
    80000eb6:	2781                	sext.w	a5,a5
    80000eb8:	dff5                	beqz	a5,80000eb4 <main+0x1a>
      ;
    __sync_synchronize();
    80000eba:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	b64080e7          	jalr	-1180(ra) # 80001a22 <cpuid>
    80000ec6:	85aa                	mv	a1,a0
    80000ec8:	00007517          	auipc	a0,0x7
    80000ecc:	20050513          	addi	a0,a0,512 # 800080c8 <digits+0x88>
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	6b2080e7          	jalr	1714(ra) # 80000582 <printf>
    kvminithart();    // turn on paging
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	0d8080e7          	jalr	216(ra) # 80000fb0 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee0:	00002097          	auipc	ra,0x2
    80000ee4:	dea080e7          	jalr	-534(ra) # 80002cca <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	00005097          	auipc	ra,0x5
    80000eec:	598080e7          	jalr	1432(ra) # 80006480 <plicinithart>
  }
  scheduler();        
    80000ef0:	00001097          	auipc	ra,0x1
    80000ef4:	256080e7          	jalr	598(ra) # 80002146 <scheduler>
    consoleinit();
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	552080e7          	jalr	1362(ra) # 8000044a <consoleinit>
    printfinit();
    80000f00:	00000097          	auipc	ra,0x0
    80000f04:	862080e7          	jalr	-1950(ra) # 80000762 <printfinit>
    printf("\n");
    80000f08:	00007517          	auipc	a0,0x7
    80000f0c:	1d050513          	addi	a0,a0,464 # 800080d8 <digits+0x98>
    80000f10:	fffff097          	auipc	ra,0xfffff
    80000f14:	672080e7          	jalr	1650(ra) # 80000582 <printf>
    printf("xv6 kernel is booting\n");
    80000f18:	00007517          	auipc	a0,0x7
    80000f1c:	19850513          	addi	a0,a0,408 # 800080b0 <digits+0x70>
    80000f20:	fffff097          	auipc	ra,0xfffff
    80000f24:	662080e7          	jalr	1634(ra) # 80000582 <printf>
    printf("\n");
    80000f28:	00007517          	auipc	a0,0x7
    80000f2c:	1b050513          	addi	a0,a0,432 # 800080d8 <digits+0x98>
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	652080e7          	jalr	1618(ra) # 80000582 <printf>
    kinit();         // physical page allocator
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	b6c080e7          	jalr	-1172(ra) # 80000aa4 <kinit>
    kvminit();       // create kernel page table
    80000f40:	00000097          	auipc	ra,0x0
    80000f44:	310080e7          	jalr	784(ra) # 80001250 <kvminit>
    kvminithart();   // turn on paging
    80000f48:	00000097          	auipc	ra,0x0
    80000f4c:	068080e7          	jalr	104(ra) # 80000fb0 <kvminithart>
    procinit();      // process table
    80000f50:	00001097          	auipc	ra,0x1
    80000f54:	9c8080e7          	jalr	-1592(ra) # 80001918 <procinit>
    trapinit();      // trap vectors
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	d4a080e7          	jalr	-694(ra) # 80002ca2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f60:	00002097          	auipc	ra,0x2
    80000f64:	d6a080e7          	jalr	-662(ra) # 80002cca <trapinithart>
    plicinit();      // set up interrupt controller
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	502080e7          	jalr	1282(ra) # 8000646a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f70:	00005097          	auipc	ra,0x5
    80000f74:	510080e7          	jalr	1296(ra) # 80006480 <plicinithart>
    binit();         // buffer cache
    80000f78:	00002097          	auipc	ra,0x2
    80000f7c:	670080e7          	jalr	1648(ra) # 800035e8 <binit>
    iinit();         // inode cache
    80000f80:	00003097          	auipc	ra,0x3
    80000f84:	d02080e7          	jalr	-766(ra) # 80003c82 <iinit>
    fileinit();      // file table
    80000f88:	00004097          	auipc	ra,0x4
    80000f8c:	cb0080e7          	jalr	-848(ra) # 80004c38 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f90:	00005097          	auipc	ra,0x5
    80000f94:	612080e7          	jalr	1554(ra) # 800065a2 <virtio_disk_init>
    userinit();      // first user process
    80000f98:	00001097          	auipc	ra,0x1
    80000f9c:	ee6080e7          	jalr	-282(ra) # 80001e7e <userinit>
    __sync_synchronize();
    80000fa0:	0ff0000f          	fence
    started = 1;
    80000fa4:	4785                	li	a5,1
    80000fa6:	00008717          	auipc	a4,0x8
    80000faa:	06f72923          	sw	a5,114(a4) # 80009018 <started>
    80000fae:	b789                	j	80000ef0 <main+0x56>

0000000080000fb0 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fb0:	1141                	addi	sp,sp,-16
    80000fb2:	e422                	sd	s0,8(sp)
    80000fb4:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fb6:	00008797          	auipc	a5,0x8
    80000fba:	06a7b783          	ld	a5,106(a5) # 80009020 <kernel_pagetable>
    80000fbe:	83b1                	srli	a5,a5,0xc
    80000fc0:	577d                	li	a4,-1
    80000fc2:	177e                	slli	a4,a4,0x3f
    80000fc4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fc6:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fca:	12000073          	sfence.vma
  sfence_vma();
}
    80000fce:	6422                	ld	s0,8(sp)
    80000fd0:	0141                	addi	sp,sp,16
    80000fd2:	8082                	ret

0000000080000fd4 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fd4:	7139                	addi	sp,sp,-64
    80000fd6:	fc06                	sd	ra,56(sp)
    80000fd8:	f822                	sd	s0,48(sp)
    80000fda:	f426                	sd	s1,40(sp)
    80000fdc:	f04a                	sd	s2,32(sp)
    80000fde:	ec4e                	sd	s3,24(sp)
    80000fe0:	e852                	sd	s4,16(sp)
    80000fe2:	e456                	sd	s5,8(sp)
    80000fe4:	e05a                	sd	s6,0(sp)
    80000fe6:	0080                	addi	s0,sp,64
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	89ae                	mv	s3,a1
    80000fec:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fee:	57fd                	li	a5,-1
    80000ff0:	83e9                	srli	a5,a5,0x1a
    80000ff2:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ff4:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ff6:	04b7f263          	bgeu	a5,a1,8000103a <walk+0x66>
    panic("walk");
    80000ffa:	00007517          	auipc	a0,0x7
    80000ffe:	0e650513          	addi	a0,a0,230 # 800080e0 <digits+0xa0>
    80001002:	fffff097          	auipc	ra,0xfffff
    80001006:	536080e7          	jalr	1334(ra) # 80000538 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000100a:	060a8663          	beqz	s5,80001076 <walk+0xa2>
    8000100e:	00000097          	auipc	ra,0x0
    80001012:	ad2080e7          	jalr	-1326(ra) # 80000ae0 <kalloc>
    80001016:	84aa                	mv	s1,a0
    80001018:	c529                	beqz	a0,80001062 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000101a:	6605                	lui	a2,0x1
    8000101c:	4581                	li	a1,0
    8000101e:	00000097          	auipc	ra,0x0
    80001022:	cce080e7          	jalr	-818(ra) # 80000cec <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001026:	00c4d793          	srli	a5,s1,0xc
    8000102a:	07aa                	slli	a5,a5,0xa
    8000102c:	0017e793          	ori	a5,a5,1
    80001030:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001034:	3a5d                	addiw	s4,s4,-9
    80001036:	036a0063          	beq	s4,s6,80001056 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000103a:	0149d933          	srl	s2,s3,s4
    8000103e:	1ff97913          	andi	s2,s2,511
    80001042:	090e                	slli	s2,s2,0x3
    80001044:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001046:	00093483          	ld	s1,0(s2)
    8000104a:	0014f793          	andi	a5,s1,1
    8000104e:	dfd5                	beqz	a5,8000100a <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001050:	80a9                	srli	s1,s1,0xa
    80001052:	04b2                	slli	s1,s1,0xc
    80001054:	b7c5                	j	80001034 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001056:	00c9d513          	srli	a0,s3,0xc
    8000105a:	1ff57513          	andi	a0,a0,511
    8000105e:	050e                	slli	a0,a0,0x3
    80001060:	9526                	add	a0,a0,s1
}
    80001062:	70e2                	ld	ra,56(sp)
    80001064:	7442                	ld	s0,48(sp)
    80001066:	74a2                	ld	s1,40(sp)
    80001068:	7902                	ld	s2,32(sp)
    8000106a:	69e2                	ld	s3,24(sp)
    8000106c:	6a42                	ld	s4,16(sp)
    8000106e:	6aa2                	ld	s5,8(sp)
    80001070:	6b02                	ld	s6,0(sp)
    80001072:	6121                	addi	sp,sp,64
    80001074:	8082                	ret
        return 0;
    80001076:	4501                	li	a0,0
    80001078:	b7ed                	j	80001062 <walk+0x8e>

000000008000107a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000107a:	57fd                	li	a5,-1
    8000107c:	83e9                	srli	a5,a5,0x1a
    8000107e:	00b7f463          	bgeu	a5,a1,80001086 <walkaddr+0xc>
    return 0;
    80001082:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001084:	8082                	ret
{
    80001086:	1141                	addi	sp,sp,-16
    80001088:	e406                	sd	ra,8(sp)
    8000108a:	e022                	sd	s0,0(sp)
    8000108c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000108e:	4601                	li	a2,0
    80001090:	00000097          	auipc	ra,0x0
    80001094:	f44080e7          	jalr	-188(ra) # 80000fd4 <walk>
  if(pte == 0)
    80001098:	c105                	beqz	a0,800010b8 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000109a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000109c:	0117f693          	andi	a3,a5,17
    800010a0:	4745                	li	a4,17
    return 0;
    800010a2:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a4:	00e68663          	beq	a3,a4,800010b0 <walkaddr+0x36>
}
    800010a8:	60a2                	ld	ra,8(sp)
    800010aa:	6402                	ld	s0,0(sp)
    800010ac:	0141                	addi	sp,sp,16
    800010ae:	8082                	ret
  pa = PTE2PA(*pte);
    800010b0:	00a7d513          	srli	a0,a5,0xa
    800010b4:	0532                	slli	a0,a0,0xc
  return pa;
    800010b6:	bfcd                	j	800010a8 <walkaddr+0x2e>
    return 0;
    800010b8:	4501                	li	a0,0
    800010ba:	b7fd                	j	800010a8 <walkaddr+0x2e>

00000000800010bc <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010bc:	715d                	addi	sp,sp,-80
    800010be:	e486                	sd	ra,72(sp)
    800010c0:	e0a2                	sd	s0,64(sp)
    800010c2:	fc26                	sd	s1,56(sp)
    800010c4:	f84a                	sd	s2,48(sp)
    800010c6:	f44e                	sd	s3,40(sp)
    800010c8:	f052                	sd	s4,32(sp)
    800010ca:	ec56                	sd	s5,24(sp)
    800010cc:	e85a                	sd	s6,16(sp)
    800010ce:	e45e                	sd	s7,8(sp)
    800010d0:	0880                	addi	s0,sp,80
    800010d2:	8aaa                	mv	s5,a0
    800010d4:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010d6:	777d                	lui	a4,0xfffff
    800010d8:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010dc:	167d                	addi	a2,a2,-1
    800010de:	00b609b3          	add	s3,a2,a1
    800010e2:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010e6:	893e                	mv	s2,a5
    800010e8:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ec:	6b85                	lui	s7,0x1
    800010ee:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010f2:	4605                	li	a2,1
    800010f4:	85ca                	mv	a1,s2
    800010f6:	8556                	mv	a0,s5
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	edc080e7          	jalr	-292(ra) # 80000fd4 <walk>
    80001100:	c51d                	beqz	a0,8000112e <mappages+0x72>
    if(*pte & PTE_V)
    80001102:	611c                	ld	a5,0(a0)
    80001104:	8b85                	andi	a5,a5,1
    80001106:	ef81                	bnez	a5,8000111e <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001108:	80b1                	srli	s1,s1,0xc
    8000110a:	04aa                	slli	s1,s1,0xa
    8000110c:	0164e4b3          	or	s1,s1,s6
    80001110:	0014e493          	ori	s1,s1,1
    80001114:	e104                	sd	s1,0(a0)
    if(a == last)
    80001116:	03390863          	beq	s2,s3,80001146 <mappages+0x8a>
    a += PGSIZE;
    8000111a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000111c:	bfc9                	j	800010ee <mappages+0x32>
      panic("remap");
    8000111e:	00007517          	auipc	a0,0x7
    80001122:	fca50513          	addi	a0,a0,-54 # 800080e8 <digits+0xa8>
    80001126:	fffff097          	auipc	ra,0xfffff
    8000112a:	412080e7          	jalr	1042(ra) # 80000538 <panic>
      return -1;
    8000112e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001130:	60a6                	ld	ra,72(sp)
    80001132:	6406                	ld	s0,64(sp)
    80001134:	74e2                	ld	s1,56(sp)
    80001136:	7942                	ld	s2,48(sp)
    80001138:	79a2                	ld	s3,40(sp)
    8000113a:	7a02                	ld	s4,32(sp)
    8000113c:	6ae2                	ld	s5,24(sp)
    8000113e:	6b42                	ld	s6,16(sp)
    80001140:	6ba2                	ld	s7,8(sp)
    80001142:	6161                	addi	sp,sp,80
    80001144:	8082                	ret
  return 0;
    80001146:	4501                	li	a0,0
    80001148:	b7e5                	j	80001130 <mappages+0x74>

000000008000114a <kvmmap>:
{
    8000114a:	1141                	addi	sp,sp,-16
    8000114c:	e406                	sd	ra,8(sp)
    8000114e:	e022                	sd	s0,0(sp)
    80001150:	0800                	addi	s0,sp,16
    80001152:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001154:	86b2                	mv	a3,a2
    80001156:	863e                	mv	a2,a5
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	f64080e7          	jalr	-156(ra) # 800010bc <mappages>
    80001160:	e509                	bnez	a0,8000116a <kvmmap+0x20>
}
    80001162:	60a2                	ld	ra,8(sp)
    80001164:	6402                	ld	s0,0(sp)
    80001166:	0141                	addi	sp,sp,16
    80001168:	8082                	ret
    panic("kvmmap");
    8000116a:	00007517          	auipc	a0,0x7
    8000116e:	f8650513          	addi	a0,a0,-122 # 800080f0 <digits+0xb0>
    80001172:	fffff097          	auipc	ra,0xfffff
    80001176:	3c6080e7          	jalr	966(ra) # 80000538 <panic>

000000008000117a <kvmmake>:
{
    8000117a:	1101                	addi	sp,sp,-32
    8000117c:	ec06                	sd	ra,24(sp)
    8000117e:	e822                	sd	s0,16(sp)
    80001180:	e426                	sd	s1,8(sp)
    80001182:	e04a                	sd	s2,0(sp)
    80001184:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001186:	00000097          	auipc	ra,0x0
    8000118a:	95a080e7          	jalr	-1702(ra) # 80000ae0 <kalloc>
    8000118e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001190:	6605                	lui	a2,0x1
    80001192:	4581                	li	a1,0
    80001194:	00000097          	auipc	ra,0x0
    80001198:	b58080e7          	jalr	-1192(ra) # 80000cec <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000119c:	4719                	li	a4,6
    8000119e:	6685                	lui	a3,0x1
    800011a0:	10000637          	lui	a2,0x10000
    800011a4:	100005b7          	lui	a1,0x10000
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	fa0080e7          	jalr	-96(ra) # 8000114a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b2:	4719                	li	a4,6
    800011b4:	6685                	lui	a3,0x1
    800011b6:	10001637          	lui	a2,0x10001
    800011ba:	100015b7          	lui	a1,0x10001
    800011be:	8526                	mv	a0,s1
    800011c0:	00000097          	auipc	ra,0x0
    800011c4:	f8a080e7          	jalr	-118(ra) # 8000114a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011c8:	4719                	li	a4,6
    800011ca:	004006b7          	lui	a3,0x400
    800011ce:	0c000637          	lui	a2,0xc000
    800011d2:	0c0005b7          	lui	a1,0xc000
    800011d6:	8526                	mv	a0,s1
    800011d8:	00000097          	auipc	ra,0x0
    800011dc:	f72080e7          	jalr	-142(ra) # 8000114a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e0:	00007917          	auipc	s2,0x7
    800011e4:	e2090913          	addi	s2,s2,-480 # 80008000 <etext>
    800011e8:	4729                	li	a4,10
    800011ea:	80007697          	auipc	a3,0x80007
    800011ee:	e1668693          	addi	a3,a3,-490 # 8000 <_entry-0x7fff8000>
    800011f2:	4605                	li	a2,1
    800011f4:	067e                	slli	a2,a2,0x1f
    800011f6:	85b2                	mv	a1,a2
    800011f8:	8526                	mv	a0,s1
    800011fa:	00000097          	auipc	ra,0x0
    800011fe:	f50080e7          	jalr	-176(ra) # 8000114a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001202:	4719                	li	a4,6
    80001204:	46c5                	li	a3,17
    80001206:	06ee                	slli	a3,a3,0x1b
    80001208:	412686b3          	sub	a3,a3,s2
    8000120c:	864a                	mv	a2,s2
    8000120e:	85ca                	mv	a1,s2
    80001210:	8526                	mv	a0,s1
    80001212:	00000097          	auipc	ra,0x0
    80001216:	f38080e7          	jalr	-200(ra) # 8000114a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000121a:	4729                	li	a4,10
    8000121c:	6685                	lui	a3,0x1
    8000121e:	00006617          	auipc	a2,0x6
    80001222:	de260613          	addi	a2,a2,-542 # 80007000 <_trampoline>
    80001226:	040005b7          	lui	a1,0x4000
    8000122a:	15fd                	addi	a1,a1,-1
    8000122c:	05b2                	slli	a1,a1,0xc
    8000122e:	8526                	mv	a0,s1
    80001230:	00000097          	auipc	ra,0x0
    80001234:	f1a080e7          	jalr	-230(ra) # 8000114a <kvmmap>
  proc_mapstacks(kpgtbl);
    80001238:	8526                	mv	a0,s1
    8000123a:	00000097          	auipc	ra,0x0
    8000123e:	600080e7          	jalr	1536(ra) # 8000183a <proc_mapstacks>
}
    80001242:	8526                	mv	a0,s1
    80001244:	60e2                	ld	ra,24(sp)
    80001246:	6442                	ld	s0,16(sp)
    80001248:	64a2                	ld	s1,8(sp)
    8000124a:	6902                	ld	s2,0(sp)
    8000124c:	6105                	addi	sp,sp,32
    8000124e:	8082                	ret

0000000080001250 <kvminit>:
{
    80001250:	1141                	addi	sp,sp,-16
    80001252:	e406                	sd	ra,8(sp)
    80001254:	e022                	sd	s0,0(sp)
    80001256:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001258:	00000097          	auipc	ra,0x0
    8000125c:	f22080e7          	jalr	-222(ra) # 8000117a <kvmmake>
    80001260:	00008797          	auipc	a5,0x8
    80001264:	dca7b023          	sd	a0,-576(a5) # 80009020 <kernel_pagetable>
}
    80001268:	60a2                	ld	ra,8(sp)
    8000126a:	6402                	ld	s0,0(sp)
    8000126c:	0141                	addi	sp,sp,16
    8000126e:	8082                	ret

0000000080001270 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001270:	715d                	addi	sp,sp,-80
    80001272:	e486                	sd	ra,72(sp)
    80001274:	e0a2                	sd	s0,64(sp)
    80001276:	fc26                	sd	s1,56(sp)
    80001278:	f84a                	sd	s2,48(sp)
    8000127a:	f44e                	sd	s3,40(sp)
    8000127c:	f052                	sd	s4,32(sp)
    8000127e:	ec56                	sd	s5,24(sp)
    80001280:	e85a                	sd	s6,16(sp)
    80001282:	e45e                	sd	s7,8(sp)
    80001284:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001286:	03459793          	slli	a5,a1,0x34
    8000128a:	e795                	bnez	a5,800012b6 <uvmunmap+0x46>
    8000128c:	8a2a                	mv	s4,a0
    8000128e:	892e                	mv	s2,a1
    80001290:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001292:	0632                	slli	a2,a2,0xc
    80001294:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001298:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000129a:	6b05                	lui	s6,0x1
    8000129c:	0735e263          	bltu	a1,s3,80001300 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012a0:	60a6                	ld	ra,72(sp)
    800012a2:	6406                	ld	s0,64(sp)
    800012a4:	74e2                	ld	s1,56(sp)
    800012a6:	7942                	ld	s2,48(sp)
    800012a8:	79a2                	ld	s3,40(sp)
    800012aa:	7a02                	ld	s4,32(sp)
    800012ac:	6ae2                	ld	s5,24(sp)
    800012ae:	6b42                	ld	s6,16(sp)
    800012b0:	6ba2                	ld	s7,8(sp)
    800012b2:	6161                	addi	sp,sp,80
    800012b4:	8082                	ret
    panic("uvmunmap: not aligned");
    800012b6:	00007517          	auipc	a0,0x7
    800012ba:	e4250513          	addi	a0,a0,-446 # 800080f8 <digits+0xb8>
    800012be:	fffff097          	auipc	ra,0xfffff
    800012c2:	27a080e7          	jalr	634(ra) # 80000538 <panic>
      panic("uvmunmap: walk");
    800012c6:	00007517          	auipc	a0,0x7
    800012ca:	e4a50513          	addi	a0,a0,-438 # 80008110 <digits+0xd0>
    800012ce:	fffff097          	auipc	ra,0xfffff
    800012d2:	26a080e7          	jalr	618(ra) # 80000538 <panic>
      panic("uvmunmap: not mapped");
    800012d6:	00007517          	auipc	a0,0x7
    800012da:	e4a50513          	addi	a0,a0,-438 # 80008120 <digits+0xe0>
    800012de:	fffff097          	auipc	ra,0xfffff
    800012e2:	25a080e7          	jalr	602(ra) # 80000538 <panic>
      panic("uvmunmap: not a leaf");
    800012e6:	00007517          	auipc	a0,0x7
    800012ea:	e5250513          	addi	a0,a0,-430 # 80008138 <digits+0xf8>
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	24a080e7          	jalr	586(ra) # 80000538 <panic>
    *pte = 0;
    800012f6:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012fa:	995a                	add	s2,s2,s6
    800012fc:	fb3972e3          	bgeu	s2,s3,800012a0 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001300:	4601                	li	a2,0
    80001302:	85ca                	mv	a1,s2
    80001304:	8552                	mv	a0,s4
    80001306:	00000097          	auipc	ra,0x0
    8000130a:	cce080e7          	jalr	-818(ra) # 80000fd4 <walk>
    8000130e:	84aa                	mv	s1,a0
    80001310:	d95d                	beqz	a0,800012c6 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001312:	6108                	ld	a0,0(a0)
    80001314:	00157793          	andi	a5,a0,1
    80001318:	dfdd                	beqz	a5,800012d6 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000131a:	3ff57793          	andi	a5,a0,1023
    8000131e:	fd7784e3          	beq	a5,s7,800012e6 <uvmunmap+0x76>
    if(do_free){
    80001322:	fc0a8ae3          	beqz	s5,800012f6 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001326:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001328:	0532                	slli	a0,a0,0xc
    8000132a:	fffff097          	auipc	ra,0xfffff
    8000132e:	6ba080e7          	jalr	1722(ra) # 800009e4 <kfree>
    80001332:	b7d1                	j	800012f6 <uvmunmap+0x86>

0000000080001334 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001334:	1101                	addi	sp,sp,-32
    80001336:	ec06                	sd	ra,24(sp)
    80001338:	e822                	sd	s0,16(sp)
    8000133a:	e426                	sd	s1,8(sp)
    8000133c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000133e:	fffff097          	auipc	ra,0xfffff
    80001342:	7a2080e7          	jalr	1954(ra) # 80000ae0 <kalloc>
    80001346:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001348:	c519                	beqz	a0,80001356 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000134a:	6605                	lui	a2,0x1
    8000134c:	4581                	li	a1,0
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	99e080e7          	jalr	-1634(ra) # 80000cec <memset>
  return pagetable;
}
    80001356:	8526                	mv	a0,s1
    80001358:	60e2                	ld	ra,24(sp)
    8000135a:	6442                	ld	s0,16(sp)
    8000135c:	64a2                	ld	s1,8(sp)
    8000135e:	6105                	addi	sp,sp,32
    80001360:	8082                	ret

0000000080001362 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001362:	7179                	addi	sp,sp,-48
    80001364:	f406                	sd	ra,40(sp)
    80001366:	f022                	sd	s0,32(sp)
    80001368:	ec26                	sd	s1,24(sp)
    8000136a:	e84a                	sd	s2,16(sp)
    8000136c:	e44e                	sd	s3,8(sp)
    8000136e:	e052                	sd	s4,0(sp)
    80001370:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001372:	6785                	lui	a5,0x1
    80001374:	04f67863          	bgeu	a2,a5,800013c4 <uvminit+0x62>
    80001378:	8a2a                	mv	s4,a0
    8000137a:	89ae                	mv	s3,a1
    8000137c:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000137e:	fffff097          	auipc	ra,0xfffff
    80001382:	762080e7          	jalr	1890(ra) # 80000ae0 <kalloc>
    80001386:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001388:	6605                	lui	a2,0x1
    8000138a:	4581                	li	a1,0
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	960080e7          	jalr	-1696(ra) # 80000cec <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001394:	4779                	li	a4,30
    80001396:	86ca                	mv	a3,s2
    80001398:	6605                	lui	a2,0x1
    8000139a:	4581                	li	a1,0
    8000139c:	8552                	mv	a0,s4
    8000139e:	00000097          	auipc	ra,0x0
    800013a2:	d1e080e7          	jalr	-738(ra) # 800010bc <mappages>
  memmove(mem, src, sz);
    800013a6:	8626                	mv	a2,s1
    800013a8:	85ce                	mv	a1,s3
    800013aa:	854a                	mv	a0,s2
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	99c080e7          	jalr	-1636(ra) # 80000d48 <memmove>
}
    800013b4:	70a2                	ld	ra,40(sp)
    800013b6:	7402                	ld	s0,32(sp)
    800013b8:	64e2                	ld	s1,24(sp)
    800013ba:	6942                	ld	s2,16(sp)
    800013bc:	69a2                	ld	s3,8(sp)
    800013be:	6a02                	ld	s4,0(sp)
    800013c0:	6145                	addi	sp,sp,48
    800013c2:	8082                	ret
    panic("inituvm: more than a page");
    800013c4:	00007517          	auipc	a0,0x7
    800013c8:	d8c50513          	addi	a0,a0,-628 # 80008150 <digits+0x110>
    800013cc:	fffff097          	auipc	ra,0xfffff
    800013d0:	16c080e7          	jalr	364(ra) # 80000538 <panic>

00000000800013d4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013d4:	1101                	addi	sp,sp,-32
    800013d6:	ec06                	sd	ra,24(sp)
    800013d8:	e822                	sd	s0,16(sp)
    800013da:	e426                	sd	s1,8(sp)
    800013dc:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013de:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e0:	00b67d63          	bgeu	a2,a1,800013fa <uvmdealloc+0x26>
    800013e4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013e6:	6785                	lui	a5,0x1
    800013e8:	17fd                	addi	a5,a5,-1
    800013ea:	00f60733          	add	a4,a2,a5
    800013ee:	767d                	lui	a2,0xfffff
    800013f0:	8f71                	and	a4,a4,a2
    800013f2:	97ae                	add	a5,a5,a1
    800013f4:	8ff1                	and	a5,a5,a2
    800013f6:	00f76863          	bltu	a4,a5,80001406 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013fa:	8526                	mv	a0,s1
    800013fc:	60e2                	ld	ra,24(sp)
    800013fe:	6442                	ld	s0,16(sp)
    80001400:	64a2                	ld	s1,8(sp)
    80001402:	6105                	addi	sp,sp,32
    80001404:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001406:	8f99                	sub	a5,a5,a4
    80001408:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000140a:	4685                	li	a3,1
    8000140c:	0007861b          	sext.w	a2,a5
    80001410:	85ba                	mv	a1,a4
    80001412:	00000097          	auipc	ra,0x0
    80001416:	e5e080e7          	jalr	-418(ra) # 80001270 <uvmunmap>
    8000141a:	b7c5                	j	800013fa <uvmdealloc+0x26>

000000008000141c <uvmalloc>:
  if(newsz < oldsz)
    8000141c:	0ab66163          	bltu	a2,a1,800014be <uvmalloc+0xa2>
{
    80001420:	7139                	addi	sp,sp,-64
    80001422:	fc06                	sd	ra,56(sp)
    80001424:	f822                	sd	s0,48(sp)
    80001426:	f426                	sd	s1,40(sp)
    80001428:	f04a                	sd	s2,32(sp)
    8000142a:	ec4e                	sd	s3,24(sp)
    8000142c:	e852                	sd	s4,16(sp)
    8000142e:	e456                	sd	s5,8(sp)
    80001430:	0080                	addi	s0,sp,64
    80001432:	8aaa                	mv	s5,a0
    80001434:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001436:	6985                	lui	s3,0x1
    80001438:	19fd                	addi	s3,s3,-1
    8000143a:	95ce                	add	a1,a1,s3
    8000143c:	79fd                	lui	s3,0xfffff
    8000143e:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001442:	08c9f063          	bgeu	s3,a2,800014c2 <uvmalloc+0xa6>
    80001446:	894e                	mv	s2,s3
    mem = kalloc();
    80001448:	fffff097          	auipc	ra,0xfffff
    8000144c:	698080e7          	jalr	1688(ra) # 80000ae0 <kalloc>
    80001450:	84aa                	mv	s1,a0
    if(mem == 0){
    80001452:	c51d                	beqz	a0,80001480 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001454:	6605                	lui	a2,0x1
    80001456:	4581                	li	a1,0
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	894080e7          	jalr	-1900(ra) # 80000cec <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001460:	4779                	li	a4,30
    80001462:	86a6                	mv	a3,s1
    80001464:	6605                	lui	a2,0x1
    80001466:	85ca                	mv	a1,s2
    80001468:	8556                	mv	a0,s5
    8000146a:	00000097          	auipc	ra,0x0
    8000146e:	c52080e7          	jalr	-942(ra) # 800010bc <mappages>
    80001472:	e905                	bnez	a0,800014a2 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001474:	6785                	lui	a5,0x1
    80001476:	993e                	add	s2,s2,a5
    80001478:	fd4968e3          	bltu	s2,s4,80001448 <uvmalloc+0x2c>
  return newsz;
    8000147c:	8552                	mv	a0,s4
    8000147e:	a809                	j	80001490 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001480:	864e                	mv	a2,s3
    80001482:	85ca                	mv	a1,s2
    80001484:	8556                	mv	a0,s5
    80001486:	00000097          	auipc	ra,0x0
    8000148a:	f4e080e7          	jalr	-178(ra) # 800013d4 <uvmdealloc>
      return 0;
    8000148e:	4501                	li	a0,0
}
    80001490:	70e2                	ld	ra,56(sp)
    80001492:	7442                	ld	s0,48(sp)
    80001494:	74a2                	ld	s1,40(sp)
    80001496:	7902                	ld	s2,32(sp)
    80001498:	69e2                	ld	s3,24(sp)
    8000149a:	6a42                	ld	s4,16(sp)
    8000149c:	6aa2                	ld	s5,8(sp)
    8000149e:	6121                	addi	sp,sp,64
    800014a0:	8082                	ret
      kfree(mem);
    800014a2:	8526                	mv	a0,s1
    800014a4:	fffff097          	auipc	ra,0xfffff
    800014a8:	540080e7          	jalr	1344(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014ac:	864e                	mv	a2,s3
    800014ae:	85ca                	mv	a1,s2
    800014b0:	8556                	mv	a0,s5
    800014b2:	00000097          	auipc	ra,0x0
    800014b6:	f22080e7          	jalr	-222(ra) # 800013d4 <uvmdealloc>
      return 0;
    800014ba:	4501                	li	a0,0
    800014bc:	bfd1                	j	80001490 <uvmalloc+0x74>
    return oldsz;
    800014be:	852e                	mv	a0,a1
}
    800014c0:	8082                	ret
  return newsz;
    800014c2:	8532                	mv	a0,a2
    800014c4:	b7f1                	j	80001490 <uvmalloc+0x74>

00000000800014c6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c6:	7179                	addi	sp,sp,-48
    800014c8:	f406                	sd	ra,40(sp)
    800014ca:	f022                	sd	s0,32(sp)
    800014cc:	ec26                	sd	s1,24(sp)
    800014ce:	e84a                	sd	s2,16(sp)
    800014d0:	e44e                	sd	s3,8(sp)
    800014d2:	e052                	sd	s4,0(sp)
    800014d4:	1800                	addi	s0,sp,48
    800014d6:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d8:	84aa                	mv	s1,a0
    800014da:	6905                	lui	s2,0x1
    800014dc:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014de:	4985                	li	s3,1
    800014e0:	a821                	j	800014f8 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e2:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e4:	0532                	slli	a0,a0,0xc
    800014e6:	00000097          	auipc	ra,0x0
    800014ea:	fe0080e7          	jalr	-32(ra) # 800014c6 <freewalk>
      pagetable[i] = 0;
    800014ee:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f2:	04a1                	addi	s1,s1,8
    800014f4:	03248163          	beq	s1,s2,80001516 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f8:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014fa:	00f57793          	andi	a5,a0,15
    800014fe:	ff3782e3          	beq	a5,s3,800014e2 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001502:	8905                	andi	a0,a0,1
    80001504:	d57d                	beqz	a0,800014f2 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001506:	00007517          	auipc	a0,0x7
    8000150a:	c6a50513          	addi	a0,a0,-918 # 80008170 <digits+0x130>
    8000150e:	fffff097          	auipc	ra,0xfffff
    80001512:	02a080e7          	jalr	42(ra) # 80000538 <panic>
    }
  }
  kfree((void*)pagetable);
    80001516:	8552                	mv	a0,s4
    80001518:	fffff097          	auipc	ra,0xfffff
    8000151c:	4cc080e7          	jalr	1228(ra) # 800009e4 <kfree>
}
    80001520:	70a2                	ld	ra,40(sp)
    80001522:	7402                	ld	s0,32(sp)
    80001524:	64e2                	ld	s1,24(sp)
    80001526:	6942                	ld	s2,16(sp)
    80001528:	69a2                	ld	s3,8(sp)
    8000152a:	6a02                	ld	s4,0(sp)
    8000152c:	6145                	addi	sp,sp,48
    8000152e:	8082                	ret

0000000080001530 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001530:	1101                	addi	sp,sp,-32
    80001532:	ec06                	sd	ra,24(sp)
    80001534:	e822                	sd	s0,16(sp)
    80001536:	e426                	sd	s1,8(sp)
    80001538:	1000                	addi	s0,sp,32
    8000153a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153c:	e999                	bnez	a1,80001552 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153e:	8526                	mv	a0,s1
    80001540:	00000097          	auipc	ra,0x0
    80001544:	f86080e7          	jalr	-122(ra) # 800014c6 <freewalk>
}
    80001548:	60e2                	ld	ra,24(sp)
    8000154a:	6442                	ld	s0,16(sp)
    8000154c:	64a2                	ld	s1,8(sp)
    8000154e:	6105                	addi	sp,sp,32
    80001550:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001552:	6605                	lui	a2,0x1
    80001554:	167d                	addi	a2,a2,-1
    80001556:	962e                	add	a2,a2,a1
    80001558:	4685                	li	a3,1
    8000155a:	8231                	srli	a2,a2,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d12080e7          	jalr	-750(ra) # 80001270 <uvmunmap>
    80001566:	bfe1                	j	8000153e <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a46080e7          	jalr	-1466(ra) # 80000fd4 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	534080e7          	jalr	1332(ra) # 80000ae0 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	78c080e7          	jalr	1932(ra) # 80000d48 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	aee080e7          	jalr	-1298(ra) # 800010bc <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	b9e50513          	addi	a0,a0,-1122 # 80008180 <digits+0x140>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f4e080e7          	jalr	-178(ra) # 80000538 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bae50513          	addi	a0,a0,-1106 # 800081a0 <digits+0x160>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f3e080e7          	jalr	-194(ra) # 80000538 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e0080e7          	jalr	992(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c5a080e7          	jalr	-934(ra) # 80001270 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	990080e7          	jalr	-1648(ra) # 80000fd4 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6450513          	addi	a0,a0,-1180 # 800081c0 <digits+0x180>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	ed4080e7          	jalr	-300(ra) # 80000538 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	6a8080e7          	jalr	1704(ra) # 80000d48 <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	9bc080e7          	jalr	-1604(ra) # 8000107a <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	61a080e7          	jalr	1562(ra) # 80000d48 <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	92e080e7          	jalr	-1746(ra) # 8000107a <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    if(n > len)
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c6c5                	beqz	a3,8000182e <copyinstr+0xa8>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a035                	j	800017d6 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	0017b793          	seqz	a5,a5
    800017b6:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017ba:	60a6                	ld	ra,72(sp)
    800017bc:	6406                	ld	s0,64(sp)
    800017be:	74e2                	ld	s1,56(sp)
    800017c0:	7942                	ld	s2,48(sp)
    800017c2:	79a2                	ld	s3,40(sp)
    800017c4:	7a02                	ld	s4,32(sp)
    800017c6:	6ae2                	ld	s5,24(sp)
    800017c8:	6b42                	ld	s6,16(sp)
    800017ca:	6ba2                	ld	s7,8(sp)
    800017cc:	6161                	addi	sp,sp,80
    800017ce:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d0:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d4:	c8a9                	beqz	s1,80001826 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d6:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017da:	85ca                	mv	a1,s2
    800017dc:	8552                	mv	a0,s4
    800017de:	00000097          	auipc	ra,0x0
    800017e2:	89c080e7          	jalr	-1892(ra) # 8000107a <walkaddr>
    if(pa0 == 0)
    800017e6:	c131                	beqz	a0,8000182a <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e8:	41790833          	sub	a6,s2,s7
    800017ec:	984e                	add	a6,a6,s3
    if(n > max)
    800017ee:	0104f363          	bgeu	s1,a6,800017f4 <copyinstr+0x6e>
    800017f2:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f4:	955e                	add	a0,a0,s7
    800017f6:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fa:	fc080be3          	beqz	a6,800017d0 <copyinstr+0x4a>
    800017fe:	985a                	add	a6,a6,s6
    80001800:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001802:	41650633          	sub	a2,a0,s6
    80001806:	14fd                	addi	s1,s1,-1
    80001808:	9b26                	add	s6,s6,s1
    8000180a:	00f60733          	add	a4,a2,a5
    8000180e:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffc1000>
    80001812:	df49                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001814:	00e78023          	sb	a4,0(a5)
      --max;
    80001818:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000181c:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181e:	ff0796e3          	bne	a5,a6,8000180a <copyinstr+0x84>
      dst++;
    80001822:	8b42                	mv	s6,a6
    80001824:	b775                	j	800017d0 <copyinstr+0x4a>
    80001826:	4781                	li	a5,0
    80001828:	b769                	j	800017b2 <copyinstr+0x2c>
      return -1;
    8000182a:	557d                	li	a0,-1
    8000182c:	b779                	j	800017ba <copyinstr+0x34>
  int got_null = 0;
    8000182e:	4781                	li	a5,0
  if(got_null){
    80001830:	0017b793          	seqz	a5,a5
    80001834:	40f00533          	neg	a0,a5
}
    80001838:	8082                	ret

000000008000183a <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000183a:	711d                	addi	sp,sp,-96
    8000183c:	ec86                	sd	ra,88(sp)
    8000183e:	e8a2                	sd	s0,80(sp)
    80001840:	e4a6                	sd	s1,72(sp)
    80001842:	e0ca                	sd	s2,64(sp)
    80001844:	fc4e                	sd	s3,56(sp)
    80001846:	f852                	sd	s4,48(sp)
    80001848:	f456                	sd	s5,40(sp)
    8000184a:	f05a                	sd	s6,32(sp)
    8000184c:	ec5e                	sd	s7,24(sp)
    8000184e:	e862                	sd	s8,16(sp)
    80001850:	e466                	sd	s9,8(sp)
    80001852:	e06a                	sd	s10,0(sp)
    80001854:	1080                	addi	s0,sp,96
    80001856:	8b2a                	mv	s6,a0
  struct proc *p;
  struct thread *t;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001858:	00010997          	auipc	s3,0x10
    8000185c:	64898993          	addi	s3,s3,1608 # 80011ea0 <proc+0x778>
    80001860:	0002ed17          	auipc	s10,0x2e
    80001864:	440d0d13          	addi	s10,s10,1088 # 8002fca0 <bcache+0x760>
    for(t = p->threads; t < &p->threads[NTHREAD]; t++){
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      int t_indx = (int) (t - p->threads);
      int p_indx = (int) (p - proc);
    80001868:	00010c97          	auipc	s9,0x10
    8000186c:	ec0c8c93          	addi	s9,s9,-320 # 80011728 <proc>
    80001870:	00006c17          	auipc	s8,0x6
    80001874:	790c3c03          	ld	s8,1936(s8) # 80008000 <etext>
      int t_indx = (int) (t - p->threads);
    80001878:	00006b97          	auipc	s7,0x6
    8000187c:	790b8b93          	addi	s7,s7,1936 # 80008008 <etext+0x8>
      uint64 va = KSTACK((NTHREAD*(p_indx)+t_indx));
    80001880:	04000ab7          	lui	s5,0x4000
    80001884:	1afd                	addi	s5,s5,-1
    80001886:	0ab2                	slli	s5,s5,0xc
    80001888:	a829                	j	800018a2 <proc_mapstacks+0x68>
        panic("kalloc");
    8000188a:	00007517          	auipc	a0,0x7
    8000188e:	94650513          	addi	a0,a0,-1722 # 800081d0 <digits+0x190>
    80001892:	fffff097          	auipc	ra,0xfffff
    80001896:	ca6080e7          	jalr	-858(ra) # 80000538 <panic>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189a:	77898993          	addi	s3,s3,1912
    8000189e:	05a98f63          	beq	s3,s10,800018fc <proc_mapstacks+0xc2>
    for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    800018a2:	b0098a13          	addi	s4,s3,-1280
      int p_indx = (int) (p - proc);
    800018a6:	88898913          	addi	s2,s3,-1912
    800018aa:	41990933          	sub	s2,s2,s9
    800018ae:	40395913          	srai	s2,s2,0x3
    800018b2:	03890933          	mul	s2,s2,s8
    800018b6:	0039191b          	slliw	s2,s2,0x3
    for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    800018ba:	84d2                	mv	s1,s4
      char *pa = kalloc();
    800018bc:	fffff097          	auipc	ra,0xfffff
    800018c0:	224080e7          	jalr	548(ra) # 80000ae0 <kalloc>
    800018c4:	862a                	mv	a2,a0
      if(pa == 0)
    800018c6:	d171                	beqz	a0,8000188a <proc_mapstacks+0x50>
      int t_indx = (int) (t - p->threads);
    800018c8:	414485b3          	sub	a1,s1,s4
    800018cc:	8595                	srai	a1,a1,0x5
    800018ce:	000bb783          	ld	a5,0(s7)
    800018d2:	02f585b3          	mul	a1,a1,a5
      uint64 va = KSTACK((NTHREAD*(p_indx)+t_indx));
    800018d6:	012585bb          	addw	a1,a1,s2
    800018da:	2585                	addiw	a1,a1,1
    800018dc:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018e0:	4719                	li	a4,6
    800018e2:	6685                	lui	a3,0x1
    800018e4:	40ba85b3          	sub	a1,s5,a1
    800018e8:	855a                	mv	a0,s6
    800018ea:	00000097          	auipc	ra,0x0
    800018ee:	860080e7          	jalr	-1952(ra) # 8000114a <kvmmap>
    for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    800018f2:	0a048493          	addi	s1,s1,160
    800018f6:	fd3493e3          	bne	s1,s3,800018bc <proc_mapstacks+0x82>
    800018fa:	b745                	j	8000189a <proc_mapstacks+0x60>
    }
  }
}
    800018fc:	60e6                	ld	ra,88(sp)
    800018fe:	6446                	ld	s0,80(sp)
    80001900:	64a6                	ld	s1,72(sp)
    80001902:	6906                	ld	s2,64(sp)
    80001904:	79e2                	ld	s3,56(sp)
    80001906:	7a42                	ld	s4,48(sp)
    80001908:	7aa2                	ld	s5,40(sp)
    8000190a:	7b02                	ld	s6,32(sp)
    8000190c:	6be2                	ld	s7,24(sp)
    8000190e:	6c42                	ld	s8,16(sp)
    80001910:	6ca2                	ld	s9,8(sp)
    80001912:	6d02                	ld	s10,0(sp)
    80001914:	6125                	addi	sp,sp,96
    80001916:	8082                	ret

0000000080001918 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001918:	715d                	addi	sp,sp,-80
    8000191a:	e486                	sd	ra,72(sp)
    8000191c:	e0a2                	sd	s0,64(sp)
    8000191e:	fc26                	sd	s1,56(sp)
    80001920:	f84a                	sd	s2,48(sp)
    80001922:	f44e                	sd	s3,40(sp)
    80001924:	f052                	sd	s4,32(sp)
    80001926:	ec56                	sd	s5,24(sp)
    80001928:	e85a                	sd	s6,16(sp)
    8000192a:	e45e                	sd	s7,8(sp)
    8000192c:	e062                	sd	s8,0(sp)
    8000192e:	0880                	addi	s0,sp,80
  struct proc *p;
  struct thread *t;

  initlock(&pid_lock, "nextpid");
    80001930:	00007597          	auipc	a1,0x7
    80001934:	8a858593          	addi	a1,a1,-1880 # 800081d8 <digits+0x198>
    80001938:	00010517          	auipc	a0,0x10
    8000193c:	96850513          	addi	a0,a0,-1688 # 800112a0 <pid_lock>
    80001940:	fffff097          	auipc	ra,0xfffff
    80001944:	200080e7          	jalr	512(ra) # 80000b40 <initlock>
  initlock(&tid_lock, "nexttid");
    80001948:	00007597          	auipc	a1,0x7
    8000194c:	89858593          	addi	a1,a1,-1896 # 800081e0 <digits+0x1a0>
    80001950:	00010517          	auipc	a0,0x10
    80001954:	96850513          	addi	a0,a0,-1688 # 800112b8 <tid_lock>
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	1e8080e7          	jalr	488(ra) # 80000b40 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001960:	00007597          	auipc	a1,0x7
    80001964:	88858593          	addi	a1,a1,-1912 # 800081e8 <digits+0x1a8>
    80001968:	00010517          	auipc	a0,0x10
    8000196c:	96850513          	addi	a0,a0,-1688 # 800112d0 <wait_lock>
    80001970:	fffff097          	auipc	ra,0xfffff
    80001974:	1d0080e7          	jalr	464(ra) # 80000b40 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001978:	00010497          	auipc	s1,0x10
    8000197c:	52848493          	addi	s1,s1,1320 # 80011ea0 <proc+0x778>
    80001980:	00010997          	auipc	s3,0x10
    80001984:	da898993          	addi	s3,s3,-600 # 80011728 <proc>
      initlock(&p->lock, "proc");
    80001988:	00007c17          	auipc	s8,0x7
    8000198c:	870c0c13          	addi	s8,s8,-1936 # 800081f8 <digits+0x1b8>
      for(t = p->threads; t < &p->threads[NTHREAD]; t++){
        int t_indx = (int) (t - p->threads);
        int p_indx = (int) (p - proc);
    80001990:	8bce                	mv	s7,s3
    80001992:	00006b17          	auipc	s6,0x6
    80001996:	66eb0b13          	addi	s6,s6,1646 # 80008000 <etext>
        int t_indx = (int) (t - p->threads);
    8000199a:	00006a97          	auipc	s5,0x6
    8000199e:	66ea8a93          	addi	s5,s5,1646 # 80008008 <etext+0x8>

        t->kstack = KSTACK((NTHREAD*(p_indx)+t_indx));
    800019a2:	04000937          	lui	s2,0x4000
    800019a6:	197d                	addi	s2,s2,-1
    800019a8:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019aa:	0002ea17          	auipc	s4,0x2e
    800019ae:	b7ea0a13          	addi	s4,s4,-1154 # 8002f528 <tickslock>
    800019b2:	a039                	j	800019c0 <procinit+0xa8>
    800019b4:	77898993          	addi	s3,s3,1912
    800019b8:	77848493          	addi	s1,s1,1912
    800019bc:	05498763          	beq	s3,s4,80001a0a <procinit+0xf2>
      initlock(&p->lock, "proc");
    800019c0:	85e2                	mv	a1,s8
    800019c2:	854e                	mv	a0,s3
    800019c4:	fffff097          	auipc	ra,0xfffff
    800019c8:	17c080e7          	jalr	380(ra) # 80000b40 <initlock>
      for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    800019cc:	27898613          	addi	a2,s3,632
        int p_indx = (int) (p - proc);
    800019d0:	417986b3          	sub	a3,s3,s7
    800019d4:	868d                	srai	a3,a3,0x3
    800019d6:	000b3783          	ld	a5,0(s6)
    800019da:	02f686b3          	mul	a3,a3,a5
        t->kstack = KSTACK((NTHREAD*(p_indx)+t_indx));
    800019de:	0036969b          	slliw	a3,a3,0x3
      for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    800019e2:	8732                	mv	a4,a2
        int t_indx = (int) (t - p->threads);
    800019e4:	000ab583          	ld	a1,0(s5)
    800019e8:	40c707b3          	sub	a5,a4,a2
    800019ec:	8795                	srai	a5,a5,0x5
    800019ee:	02b787b3          	mul	a5,a5,a1
        t->kstack = KSTACK((NTHREAD*(p_indx)+t_indx));
    800019f2:	9fb5                	addw	a5,a5,a3
    800019f4:	2785                	addiw	a5,a5,1
    800019f6:	00d7979b          	slliw	a5,a5,0xd
    800019fa:	40f907b3          	sub	a5,s2,a5
    800019fe:	eb1c                	sd	a5,16(a4)
      for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80001a00:	0a070713          	addi	a4,a4,160
    80001a04:	fe9712e3          	bne	a4,s1,800019e8 <procinit+0xd0>
    80001a08:	b775                	j	800019b4 <procinit+0x9c>
      }
      //was:
      //p->kstack = KSTACK((int) (p - proc));
  }
}
    80001a0a:	60a6                	ld	ra,72(sp)
    80001a0c:	6406                	ld	s0,64(sp)
    80001a0e:	74e2                	ld	s1,56(sp)
    80001a10:	7942                	ld	s2,48(sp)
    80001a12:	79a2                	ld	s3,40(sp)
    80001a14:	7a02                	ld	s4,32(sp)
    80001a16:	6ae2                	ld	s5,24(sp)
    80001a18:	6b42                	ld	s6,16(sp)
    80001a1a:	6ba2                	ld	s7,8(sp)
    80001a1c:	6c02                	ld	s8,0(sp)
    80001a1e:	6161                	addi	sp,sp,80
    80001a20:	8082                	ret

0000000080001a22 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a22:	1141                	addi	sp,sp,-16
    80001a24:	e422                	sd	s0,8(sp)
    80001a26:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a28:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a2a:	2501                	sext.w	a0,a0
    80001a2c:	6422                	ld	s0,8(sp)
    80001a2e:	0141                	addi	sp,sp,16
    80001a30:	8082                	ret

0000000080001a32 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a32:	1141                	addi	sp,sp,-16
    80001a34:	e422                	sd	s0,8(sp)
    80001a36:	0800                	addi	s0,sp,16
    80001a38:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a3a:	0007851b          	sext.w	a0,a5
    80001a3e:	00451793          	slli	a5,a0,0x4
    80001a42:	97aa                	add	a5,a5,a0
    80001a44:	078e                	slli	a5,a5,0x3
  return c;
}
    80001a46:	00010517          	auipc	a0,0x10
    80001a4a:	8a250513          	addi	a0,a0,-1886 # 800112e8 <cpus>
    80001a4e:	953e                	add	a0,a0,a5
    80001a50:	6422                	ld	s0,8(sp)
    80001a52:	0141                	addi	sp,sp,16
    80001a54:	8082                	ret

0000000080001a56 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a56:	1101                	addi	sp,sp,-32
    80001a58:	ec06                	sd	ra,24(sp)
    80001a5a:	e822                	sd	s0,16(sp)
    80001a5c:	e426                	sd	s1,8(sp)
    80001a5e:	1000                	addi	s0,sp,32
  push_off();
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	124080e7          	jalr	292(ra) # 80000b84 <push_off>
    80001a68:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a6a:	0007871b          	sext.w	a4,a5
    80001a6e:	00471793          	slli	a5,a4,0x4
    80001a72:	97ba                	add	a5,a5,a4
    80001a74:	078e                	slli	a5,a5,0x3
    80001a76:	00010717          	auipc	a4,0x10
    80001a7a:	82a70713          	addi	a4,a4,-2006 # 800112a0 <pid_lock>
    80001a7e:	97ba                	add	a5,a5,a4
    80001a80:	67a4                	ld	s1,72(a5)
  pop_off();
    80001a82:	fffff097          	auipc	ra,0xfffff
    80001a86:	1bc080e7          	jalr	444(ra) # 80000c3e <pop_off>
  return p;
}
    80001a8a:	8526                	mv	a0,s1
    80001a8c:	60e2                	ld	ra,24(sp)
    80001a8e:	6442                	ld	s0,16(sp)
    80001a90:	64a2                	ld	s1,8(sp)
    80001a92:	6105                	addi	sp,sp,32
    80001a94:	8082                	ret

0000000080001a96 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a96:	1141                	addi	sp,sp,-16
    80001a98:	e406                	sd	ra,8(sp)
    80001a9a:	e022                	sd	s0,0(sp)
    80001a9c:	0800                	addi	s0,sp,16
  static int first = 1;
  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a9e:	00000097          	auipc	ra,0x0
    80001aa2:	fb8080e7          	jalr	-72(ra) # 80001a56 <myproc>
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	1fe080e7          	jalr	510(ra) # 80000ca4 <release>

  if (first) {
    80001aae:	00007797          	auipc	a5,0x7
    80001ab2:	dc27a783          	lw	a5,-574(a5) # 80008870 <first.1>
    80001ab6:	eb89                	bnez	a5,80001ac8 <forkret+0x32>
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }
  usertrapret();
    80001ab8:	00001097          	auipc	ra,0x1
    80001abc:	22a080e7          	jalr	554(ra) # 80002ce2 <usertrapret>
}
    80001ac0:	60a2                	ld	ra,8(sp)
    80001ac2:	6402                	ld	s0,0(sp)
    80001ac4:	0141                	addi	sp,sp,16
    80001ac6:	8082                	ret
    first = 0;
    80001ac8:	00007797          	auipc	a5,0x7
    80001acc:	da07a423          	sw	zero,-600(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001ad0:	4505                	li	a0,1
    80001ad2:	00002097          	auipc	ra,0x2
    80001ad6:	130080e7          	jalr	304(ra) # 80003c02 <fsinit>
    80001ada:	bff9                	j	80001ab8 <forkret+0x22>

0000000080001adc <mythread>:
mythread(void) {
    80001adc:	1101                	addi	sp,sp,-32
    80001ade:	ec06                	sd	ra,24(sp)
    80001ae0:	e822                	sd	s0,16(sp)
    80001ae2:	e426                	sd	s1,8(sp)
    80001ae4:	1000                	addi	s0,sp,32
  push_off();
    80001ae6:	fffff097          	auipc	ra,0xfffff
    80001aea:	09e080e7          	jalr	158(ra) # 80000b84 <push_off>
    80001aee:	8792                	mv	a5,tp
  struct thread *t = c->thread;
    80001af0:	0007871b          	sext.w	a4,a5
    80001af4:	00471793          	slli	a5,a4,0x4
    80001af8:	97ba                	add	a5,a5,a4
    80001afa:	078e                	slli	a5,a5,0x3
    80001afc:	0000f717          	auipc	a4,0xf
    80001b00:	7a470713          	addi	a4,a4,1956 # 800112a0 <pid_lock>
    80001b04:	97ba                	add	a5,a5,a4
    80001b06:	6ba4                	ld	s1,80(a5)
  pop_off();
    80001b08:	fffff097          	auipc	ra,0xfffff
    80001b0c:	136080e7          	jalr	310(ra) # 80000c3e <pop_off>
}
    80001b10:	8526                	mv	a0,s1
    80001b12:	60e2                	ld	ra,24(sp)
    80001b14:	6442                	ld	s0,16(sp)
    80001b16:	64a2                	ld	s1,8(sp)
    80001b18:	6105                	addi	sp,sp,32
    80001b1a:	8082                	ret

0000000080001b1c <allocpid>:
allocpid() {
    80001b1c:	1101                	addi	sp,sp,-32
    80001b1e:	ec06                	sd	ra,24(sp)
    80001b20:	e822                	sd	s0,16(sp)
    80001b22:	e426                	sd	s1,8(sp)
    80001b24:	e04a                	sd	s2,0(sp)
    80001b26:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b28:	0000f917          	auipc	s2,0xf
    80001b2c:	77890913          	addi	s2,s2,1912 # 800112a0 <pid_lock>
    80001b30:	854a                	mv	a0,s2
    80001b32:	fffff097          	auipc	ra,0xfffff
    80001b36:	0a6080e7          	jalr	166(ra) # 80000bd8 <acquire>
  pid = nextpid;
    80001b3a:	00007797          	auipc	a5,0x7
    80001b3e:	d3e78793          	addi	a5,a5,-706 # 80008878 <nextpid>
    80001b42:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b44:	0014871b          	addiw	a4,s1,1
    80001b48:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b4a:	854a                	mv	a0,s2
    80001b4c:	fffff097          	auipc	ra,0xfffff
    80001b50:	158080e7          	jalr	344(ra) # 80000ca4 <release>
}
    80001b54:	8526                	mv	a0,s1
    80001b56:	60e2                	ld	ra,24(sp)
    80001b58:	6442                	ld	s0,16(sp)
    80001b5a:	64a2                	ld	s1,8(sp)
    80001b5c:	6902                	ld	s2,0(sp)
    80001b5e:	6105                	addi	sp,sp,32
    80001b60:	8082                	ret

0000000080001b62 <alloctid>:
alloctid() {
    80001b62:	1101                	addi	sp,sp,-32
    80001b64:	ec06                	sd	ra,24(sp)
    80001b66:	e822                	sd	s0,16(sp)
    80001b68:	e426                	sd	s1,8(sp)
    80001b6a:	e04a                	sd	s2,0(sp)
    80001b6c:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001b6e:	0000f917          	auipc	s2,0xf
    80001b72:	74a90913          	addi	s2,s2,1866 # 800112b8 <tid_lock>
    80001b76:	854a                	mv	a0,s2
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	060080e7          	jalr	96(ra) # 80000bd8 <acquire>
  tid = nexttid;
    80001b80:	00007797          	auipc	a5,0x7
    80001b84:	cf478793          	addi	a5,a5,-780 # 80008874 <nexttid>
    80001b88:	4384                	lw	s1,0(a5)
  nexttid = nexttid + 1;
    80001b8a:	0014871b          	addiw	a4,s1,1
    80001b8e:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001b90:	854a                	mv	a0,s2
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	112080e7          	jalr	274(ra) # 80000ca4 <release>
}
    80001b9a:	8526                	mv	a0,s1
    80001b9c:	60e2                	ld	ra,24(sp)
    80001b9e:	6442                	ld	s0,16(sp)
    80001ba0:	64a2                	ld	s1,8(sp)
    80001ba2:	6902                	ld	s2,0(sp)
    80001ba4:	6105                	addi	sp,sp,32
    80001ba6:	8082                	ret

0000000080001ba8 <allocthread>:
{
    80001ba8:	1101                	addi	sp,sp,-32
    80001baa:	ec06                	sd	ra,24(sp)
    80001bac:	e822                	sd	s0,16(sp)
    80001bae:	e426                	sd	s1,8(sp)
    80001bb0:	e04a                	sd	s2,0(sp)
    80001bb2:	1000                	addi	s0,sp,32
    80001bb4:	892a                	mv	s2,a0
  for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80001bb6:	27850493          	addi	s1,a0,632
    80001bba:	77850713          	addi	a4,a0,1912
    if(t->state == UNUSED) {
    80001bbe:	40dc                	lw	a5,4(s1)
    80001bc0:	c395                	beqz	a5,80001be4 <allocthread+0x3c>
  for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80001bc2:	0a048493          	addi	s1,s1,160
    80001bc6:	fee49ce3          	bne	s1,a4,80001bbe <allocthread+0x16>
  release(&p->lock);
    80001bca:	854a                	mv	a0,s2
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	0d8080e7          	jalr	216(ra) # 80000ca4 <release>
  return 0;
    80001bd4:	4481                	li	s1,0
}
    80001bd6:	8526                	mv	a0,s1
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6902                	ld	s2,0(sp)
    80001be0:	6105                	addi	sp,sp,32
    80001be2:	8082                	ret
  t->id = alloctid();
    80001be4:	00000097          	auipc	ra,0x0
    80001be8:	f7e080e7          	jalr	-130(ra) # 80001b62 <alloctid>
    80001bec:	c088                	sw	a0,0(s1)
  t->state = USED;
    80001bee:	4785                	li	a5,1
    80001bf0:	c0dc                	sw	a5,4(s1)
  t->tproc = p;
    80001bf2:	0124b423          	sd	s2,8(s1)
  memset(&t->context, 0, sizeof(t->context));
    80001bf6:	07000613          	li	a2,112
    80001bfa:	4581                	li	a1,0
    80001bfc:	02048513          	addi	a0,s1,32
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	0ec080e7          	jalr	236(ra) # 80000cec <memset>
  t->context.ra = (uint64)forkret;
    80001c08:	00000797          	auipc	a5,0x0
    80001c0c:	e8e78793          	addi	a5,a5,-370 # 80001a96 <forkret>
    80001c10:	f09c                	sd	a5,32(s1)
  t->context.sp = t->kstack + PGSIZE;
    80001c12:	689c                	ld	a5,16(s1)
    80001c14:	6705                	lui	a4,0x1
    80001c16:	97ba                	add	a5,a5,a4
    80001c18:	f49c                	sd	a5,40(s1)
  return t;
    80001c1a:	bf75                	j	80001bd6 <allocthread+0x2e>

0000000080001c1c <proc_pagetable>:
{
    80001c1c:	1101                	addi	sp,sp,-32
    80001c1e:	ec06                	sd	ra,24(sp)
    80001c20:	e822                	sd	s0,16(sp)
    80001c22:	e426                	sd	s1,8(sp)
    80001c24:	e04a                	sd	s2,0(sp)
    80001c26:	1000                	addi	s0,sp,32
    80001c28:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	70a080e7          	jalr	1802(ra) # 80001334 <uvmcreate>
    80001c32:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c34:	c121                	beqz	a0,80001c74 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c36:	4729                	li	a4,10
    80001c38:	00005697          	auipc	a3,0x5
    80001c3c:	3c868693          	addi	a3,a3,968 # 80007000 <_trampoline>
    80001c40:	6605                	lui	a2,0x1
    80001c42:	040005b7          	lui	a1,0x4000
    80001c46:	15fd                	addi	a1,a1,-1
    80001c48:	05b2                	slli	a1,a1,0xc
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	472080e7          	jalr	1138(ra) # 800010bc <mappages>
    80001c52:	02054863          	bltz	a0,80001c82 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c56:	4719                	li	a4,6
    80001c58:	05893683          	ld	a3,88(s2)
    80001c5c:	6605                	lui	a2,0x1
    80001c5e:	020005b7          	lui	a1,0x2000
    80001c62:	15fd                	addi	a1,a1,-1
    80001c64:	05b6                	slli	a1,a1,0xd
    80001c66:	8526                	mv	a0,s1
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	454080e7          	jalr	1108(ra) # 800010bc <mappages>
    80001c70:	02054163          	bltz	a0,80001c92 <proc_pagetable+0x76>
}
    80001c74:	8526                	mv	a0,s1
    80001c76:	60e2                	ld	ra,24(sp)
    80001c78:	6442                	ld	s0,16(sp)
    80001c7a:	64a2                	ld	s1,8(sp)
    80001c7c:	6902                	ld	s2,0(sp)
    80001c7e:	6105                	addi	sp,sp,32
    80001c80:	8082                	ret
    uvmfree(pagetable, 0);
    80001c82:	4581                	li	a1,0
    80001c84:	8526                	mv	a0,s1
    80001c86:	00000097          	auipc	ra,0x0
    80001c8a:	8aa080e7          	jalr	-1878(ra) # 80001530 <uvmfree>
    return 0;
    80001c8e:	4481                	li	s1,0
    80001c90:	b7d5                	j	80001c74 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c92:	4681                	li	a3,0
    80001c94:	4605                	li	a2,1
    80001c96:	040005b7          	lui	a1,0x4000
    80001c9a:	15fd                	addi	a1,a1,-1
    80001c9c:	05b2                	slli	a1,a1,0xc
    80001c9e:	8526                	mv	a0,s1
    80001ca0:	fffff097          	auipc	ra,0xfffff
    80001ca4:	5d0080e7          	jalr	1488(ra) # 80001270 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ca8:	4581                	li	a1,0
    80001caa:	8526                	mv	a0,s1
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	884080e7          	jalr	-1916(ra) # 80001530 <uvmfree>
    return 0;
    80001cb4:	4481                	li	s1,0
    80001cb6:	bf7d                	j	80001c74 <proc_pagetable+0x58>

0000000080001cb8 <proc_freepagetable>:
{
    80001cb8:	1101                	addi	sp,sp,-32
    80001cba:	ec06                	sd	ra,24(sp)
    80001cbc:	e822                	sd	s0,16(sp)
    80001cbe:	e426                	sd	s1,8(sp)
    80001cc0:	e04a                	sd	s2,0(sp)
    80001cc2:	1000                	addi	s0,sp,32
    80001cc4:	84aa                	mv	s1,a0
    80001cc6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cc8:	4681                	li	a3,0
    80001cca:	4605                	li	a2,1
    80001ccc:	040005b7          	lui	a1,0x4000
    80001cd0:	15fd                	addi	a1,a1,-1
    80001cd2:	05b2                	slli	a1,a1,0xc
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	59c080e7          	jalr	1436(ra) # 80001270 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cdc:	4681                	li	a3,0
    80001cde:	4605                	li	a2,1
    80001ce0:	020005b7          	lui	a1,0x2000
    80001ce4:	15fd                	addi	a1,a1,-1
    80001ce6:	05b6                	slli	a1,a1,0xd
    80001ce8:	8526                	mv	a0,s1
    80001cea:	fffff097          	auipc	ra,0xfffff
    80001cee:	586080e7          	jalr	1414(ra) # 80001270 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cf2:	85ca                	mv	a1,s2
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	00000097          	auipc	ra,0x0
    80001cfa:	83a080e7          	jalr	-1990(ra) # 80001530 <uvmfree>
}
    80001cfe:	60e2                	ld	ra,24(sp)
    80001d00:	6442                	ld	s0,16(sp)
    80001d02:	64a2                	ld	s1,8(sp)
    80001d04:	6902                	ld	s2,0(sp)
    80001d06:	6105                	addi	sp,sp,32
    80001d08:	8082                	ret

0000000080001d0a <freeproc>:
{
    80001d0a:	1101                	addi	sp,sp,-32
    80001d0c:	ec06                	sd	ra,24(sp)
    80001d0e:	e822                	sd	s0,16(sp)
    80001d10:	e426                	sd	s1,8(sp)
    80001d12:	1000                	addi	s0,sp,32
    80001d14:	84aa                	mv	s1,a0
  for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80001d16:	27850793          	addi	a5,a0,632
    80001d1a:	77850693          	addi	a3,a0,1912
    80001d1e:	a029                	j	80001d28 <freeproc+0x1e>
    80001d20:	0a078793          	addi	a5,a5,160
    80001d24:	02f68463          	beq	a3,a5,80001d4c <freeproc+0x42>
    if(t->state != UNUSED && t->state != RUNNING) {
    80001d28:	43d8                	lw	a4,4(a5)
    80001d2a:	9b6d                	andi	a4,a4,-5
    80001d2c:	db75                	beqz	a4,80001d20 <freeproc+0x16>
      t->trapframe = 0;
    80001d2e:	0007bc23          	sd	zero,24(a5)
  t->id = 0;
    80001d32:	0007a023          	sw	zero,0(a5)
  t->tproc = 0;
    80001d36:	0007b423          	sd	zero,8(a5)
  t->chan = 0;
    80001d3a:	0807b823          	sd	zero,144(a5)
  t->killed = 0;
    80001d3e:	0807ac23          	sw	zero,152(a5)
  t->xstate = 0;
    80001d42:	0807ae23          	sw	zero,156(a5)
  t->state = UNUSED;
    80001d46:	0007a223          	sw	zero,4(a5)
}
    80001d4a:	bfd9                	j	80001d20 <freeproc+0x16>
  if(p->trapframe)
    80001d4c:	6ca8                	ld	a0,88(s1)
    80001d4e:	c509                	beqz	a0,80001d58 <freeproc+0x4e>
    kfree((void*)p->trapframe);
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	c94080e7          	jalr	-876(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001d58:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001d5c:	68a8                	ld	a0,80(s1)
    80001d5e:	c511                	beqz	a0,80001d6a <freeproc+0x60>
    proc_freepagetable(p->pagetable, p->sz);
    80001d60:	64ac                	ld	a1,72(s1)
    80001d62:	00000097          	auipc	ra,0x0
    80001d66:	f56080e7          	jalr	-170(ra) # 80001cb8 <proc_freepagetable>
  p->pagetable = 0;
    80001d6a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d6e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d72:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d76:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d7a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d7e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d82:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d86:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d8a:	0004ac23          	sw	zero,24(s1)
}
    80001d8e:	60e2                	ld	ra,24(sp)
    80001d90:	6442                	ld	s0,16(sp)
    80001d92:	64a2                	ld	s1,8(sp)
    80001d94:	6105                	addi	sp,sp,32
    80001d96:	8082                	ret

0000000080001d98 <allocproc>:
{
    80001d98:	1101                	addi	sp,sp,-32
    80001d9a:	ec06                	sd	ra,24(sp)
    80001d9c:	e822                	sd	s0,16(sp)
    80001d9e:	e426                	sd	s1,8(sp)
    80001da0:	e04a                	sd	s2,0(sp)
    80001da2:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001da4:	00010497          	auipc	s1,0x10
    80001da8:	98448493          	addi	s1,s1,-1660 # 80011728 <proc>
    80001dac:	0002d917          	auipc	s2,0x2d
    80001db0:	77c90913          	addi	s2,s2,1916 # 8002f528 <tickslock>
    acquire(&p->lock);
    80001db4:	8526                	mv	a0,s1
    80001db6:	fffff097          	auipc	ra,0xfffff
    80001dba:	e22080e7          	jalr	-478(ra) # 80000bd8 <acquire>
    if(p->state == UNUSED) {
    80001dbe:	4c9c                	lw	a5,24(s1)
    80001dc0:	cf81                	beqz	a5,80001dd8 <allocproc+0x40>
      release(&p->lock);
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	ee0080e7          	jalr	-288(ra) # 80000ca4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dcc:	77848493          	addi	s1,s1,1912
    80001dd0:	ff2492e3          	bne	s1,s2,80001db4 <allocproc+0x1c>
  return 0;
    80001dd4:	4901                	li	s2,0
    80001dd6:	a8a1                	j	80001e2e <allocproc+0x96>
  p->pid = allocpid();
    80001dd8:	00000097          	auipc	ra,0x0
    80001ddc:	d44080e7          	jalr	-700(ra) # 80001b1c <allocpid>
    80001de0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001de2:	4785                	li	a5,1
    80001de4:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	cfa080e7          	jalr	-774(ra) # 80000ae0 <kalloc>
    80001dee:	892a                	mv	s2,a0
    80001df0:	eca8                	sd	a0,88(s1)
    80001df2:	c529                	beqz	a0,80001e3c <allocproc+0xa4>
  for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80001df4:	27848793          	addi	a5,s1,632
    80001df8:	777d                	lui	a4,0xfffff
    80001dfa:	70070713          	addi	a4,a4,1792 # fffffffffffff700 <end+0xffffffff7ffc1700>
    80001dfe:	972a                	add	a4,a4,a0
    t->trapframe = tr;
    80001e00:	0127bc23          	sd	s2,24(a5)
    tr--;
    80001e04:	ee090913          	addi	s2,s2,-288
  for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80001e08:	0a078793          	addi	a5,a5,160
    80001e0c:	fee91ae3          	bne	s2,a4,80001e00 <allocproc+0x68>
  p->pagetable = proc_pagetable(p);
    80001e10:	8526                	mv	a0,s1
    80001e12:	00000097          	auipc	ra,0x0
    80001e16:	e0a080e7          	jalr	-502(ra) # 80001c1c <proc_pagetable>
    80001e1a:	892a                	mv	s2,a0
    80001e1c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001e1e:	c915                	beqz	a0,80001e52 <allocproc+0xba>
  t = allocthread(p);
    80001e20:	8526                	mv	a0,s1
    80001e22:	00000097          	auipc	ra,0x0
    80001e26:	d86080e7          	jalr	-634(ra) # 80001ba8 <allocthread>
    80001e2a:	892a                	mv	s2,a0
  if(t == 0){
    80001e2c:	cd15                	beqz	a0,80001e68 <allocproc+0xd0>
}
    80001e2e:	854a                	mv	a0,s2
    80001e30:	60e2                	ld	ra,24(sp)
    80001e32:	6442                	ld	s0,16(sp)
    80001e34:	64a2                	ld	s1,8(sp)
    80001e36:	6902                	ld	s2,0(sp)
    80001e38:	6105                	addi	sp,sp,32
    80001e3a:	8082                	ret
    freeproc(p);
    80001e3c:	8526                	mv	a0,s1
    80001e3e:	00000097          	auipc	ra,0x0
    80001e42:	ecc080e7          	jalr	-308(ra) # 80001d0a <freeproc>
    release(&p->lock);
    80001e46:	8526                	mv	a0,s1
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	e5c080e7          	jalr	-420(ra) # 80000ca4 <release>
    return 0;
    80001e50:	bff9                	j	80001e2e <allocproc+0x96>
    freeproc(p);
    80001e52:	8526                	mv	a0,s1
    80001e54:	00000097          	auipc	ra,0x0
    80001e58:	eb6080e7          	jalr	-330(ra) # 80001d0a <freeproc>
    release(&p->lock);
    80001e5c:	8526                	mv	a0,s1
    80001e5e:	fffff097          	auipc	ra,0xfffff
    80001e62:	e46080e7          	jalr	-442(ra) # 80000ca4 <release>
    return 0;
    80001e66:	b7e1                	j	80001e2e <allocproc+0x96>
    freeproc(p);
    80001e68:	8526                	mv	a0,s1
    80001e6a:	00000097          	auipc	ra,0x0
    80001e6e:	ea0080e7          	jalr	-352(ra) # 80001d0a <freeproc>
    release(&p->lock);
    80001e72:	8526                	mv	a0,s1
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	e30080e7          	jalr	-464(ra) # 80000ca4 <release>
    return 0;
    80001e7c:	bf4d                	j	80001e2e <allocproc+0x96>

0000000080001e7e <userinit>:
{
    80001e7e:	1101                	addi	sp,sp,-32
    80001e80:	ec06                	sd	ra,24(sp)
    80001e82:	e822                	sd	s0,16(sp)
    80001e84:	e426                	sd	s1,8(sp)
    80001e86:	e04a                	sd	s2,0(sp)
    80001e88:	1000                	addi	s0,sp,32
  t = allocproc();
    80001e8a:	00000097          	auipc	ra,0x0
    80001e8e:	f0e080e7          	jalr	-242(ra) # 80001d98 <allocproc>
    80001e92:	892a                	mv	s2,a0
  p = t->tproc;
    80001e94:	6504                	ld	s1,8(a0)
  initproc = p;
    80001e96:	00007797          	auipc	a5,0x7
    80001e9a:	1897b923          	sd	s1,402(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e9e:	03400613          	li	a2,52
    80001ea2:	00007597          	auipc	a1,0x7
    80001ea6:	9de58593          	addi	a1,a1,-1570 # 80008880 <initcode>
    80001eaa:	68a8                	ld	a0,80(s1)
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	4b6080e7          	jalr	1206(ra) # 80001362 <uvminit>
  p->sz = PGSIZE;
    80001eb4:	6785                	lui	a5,0x1
    80001eb6:	e4bc                	sd	a5,72(s1)
  t->trapframe->epc = 0;      // user program counter
    80001eb8:	01893703          	ld	a4,24(s2)
    80001ebc:	00073c23          	sd	zero,24(a4)
  t->trapframe->sp = PGSIZE;  // user stack pointer
    80001ec0:	01893703          	ld	a4,24(s2)
    80001ec4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ec6:	4641                	li	a2,16
    80001ec8:	00006597          	auipc	a1,0x6
    80001ecc:	33858593          	addi	a1,a1,824 # 80008200 <digits+0x1c0>
    80001ed0:	15848513          	addi	a0,s1,344
    80001ed4:	fffff097          	auipc	ra,0xfffff
    80001ed8:	f6a080e7          	jalr	-150(ra) # 80000e3e <safestrcpy>
  p->cwd = namei("/");
    80001edc:	00006517          	auipc	a0,0x6
    80001ee0:	33450513          	addi	a0,a0,820 # 80008210 <digits+0x1d0>
    80001ee4:	00002097          	auipc	ra,0x2
    80001ee8:	74c080e7          	jalr	1868(ra) # 80004630 <namei>
    80001eec:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ef0:	478d                	li	a5,3
    80001ef2:	cc9c                	sw	a5,24(s1)
  t->state = RUNNABLE;
    80001ef4:	00f92223          	sw	a5,4(s2)
  release(&p->lock);
    80001ef8:	8526                	mv	a0,s1
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	daa080e7          	jalr	-598(ra) # 80000ca4 <release>
}
    80001f02:	60e2                	ld	ra,24(sp)
    80001f04:	6442                	ld	s0,16(sp)
    80001f06:	64a2                	ld	s1,8(sp)
    80001f08:	6902                	ld	s2,0(sp)
    80001f0a:	6105                	addi	sp,sp,32
    80001f0c:	8082                	ret

0000000080001f0e <growproc>:
{
    80001f0e:	7179                	addi	sp,sp,-48
    80001f10:	f406                	sd	ra,40(sp)
    80001f12:	f022                	sd	s0,32(sp)
    80001f14:	ec26                	sd	s1,24(sp)
    80001f16:	e84a                	sd	s2,16(sp)
    80001f18:	e44e                	sd	s3,8(sp)
    80001f1a:	1800                	addi	s0,sp,48
    80001f1c:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    80001f1e:	00000097          	auipc	ra,0x0
    80001f22:	b38080e7          	jalr	-1224(ra) # 80001a56 <myproc>
    80001f26:	84aa                	mv	s1,a0
  sz = p->sz;
    80001f28:	652c                	ld	a1,72(a0)
    80001f2a:	0005891b          	sext.w	s2,a1
  if(n > 0){
    80001f2e:	03304b63          	bgtz	s3,80001f64 <growproc+0x56>
  } else if(n < 0){
    80001f32:	0409ca63          	bltz	s3,80001f86 <growproc+0x78>
  acquire(&p->lock);    //task3
    80001f36:	8526                	mv	a0,s1
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	ca0080e7          	jalr	-864(ra) # 80000bd8 <acquire>
  p->sz = sz;
    80001f40:	1902                	slli	s2,s2,0x20
    80001f42:	02095913          	srli	s2,s2,0x20
    80001f46:	0524b423          	sd	s2,72(s1)
  release(&p->lock);    //task3
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	d58080e7          	jalr	-680(ra) # 80000ca4 <release>
  return 0;
    80001f54:	4501                	li	a0,0
}
    80001f56:	70a2                	ld	ra,40(sp)
    80001f58:	7402                	ld	s0,32(sp)
    80001f5a:	64e2                	ld	s1,24(sp)
    80001f5c:	6942                	ld	s2,16(sp)
    80001f5e:	69a2                	ld	s3,8(sp)
    80001f60:	6145                	addi	sp,sp,48
    80001f62:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001f64:	0129863b          	addw	a2,s3,s2
    80001f68:	1602                	slli	a2,a2,0x20
    80001f6a:	9201                	srli	a2,a2,0x20
    80001f6c:	1582                	slli	a1,a1,0x20
    80001f6e:	9181                	srli	a1,a1,0x20
    80001f70:	6928                	ld	a0,80(a0)
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	4aa080e7          	jalr	1194(ra) # 8000141c <uvmalloc>
    80001f7a:	0005091b          	sext.w	s2,a0
    80001f7e:	fa091ce3          	bnez	s2,80001f36 <growproc+0x28>
      return -1;
    80001f82:	557d                	li	a0,-1
    80001f84:	bfc9                	j	80001f56 <growproc+0x48>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f86:	0129863b          	addw	a2,s3,s2
    80001f8a:	1602                	slli	a2,a2,0x20
    80001f8c:	9201                	srli	a2,a2,0x20
    80001f8e:	1582                	slli	a1,a1,0x20
    80001f90:	9181                	srli	a1,a1,0x20
    80001f92:	6928                	ld	a0,80(a0)
    80001f94:	fffff097          	auipc	ra,0xfffff
    80001f98:	440080e7          	jalr	1088(ra) # 800013d4 <uvmdealloc>
    80001f9c:	0005091b          	sext.w	s2,a0
    80001fa0:	bf59                	j	80001f36 <growproc+0x28>

0000000080001fa2 <fork>:
{
    80001fa2:	7139                	addi	sp,sp,-64
    80001fa4:	fc06                	sd	ra,56(sp)
    80001fa6:	f822                	sd	s0,48(sp)
    80001fa8:	f426                	sd	s1,40(sp)
    80001faa:	f04a                	sd	s2,32(sp)
    80001fac:	ec4e                	sd	s3,24(sp)
    80001fae:	e852                	sd	s4,16(sp)
    80001fb0:	e456                	sd	s5,8(sp)
    80001fb2:	e05a                	sd	s6,0(sp)
    80001fb4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001fb6:	00000097          	auipc	ra,0x0
    80001fba:	aa0080e7          	jalr	-1376(ra) # 80001a56 <myproc>
    80001fbe:	8a2a                	mv	s4,a0
  struct thread *t = mythread();
    80001fc0:	00000097          	auipc	ra,0x0
    80001fc4:	b1c080e7          	jalr	-1252(ra) # 80001adc <mythread>
    80001fc8:	84aa                	mv	s1,a0
  if((nt = allocproc()) == 0){
    80001fca:	00000097          	auipc	ra,0x0
    80001fce:	dce080e7          	jalr	-562(ra) # 80001d98 <allocproc>
    80001fd2:	16050863          	beqz	a0,80002142 <fork+0x1a0>
    80001fd6:	8aaa                	mv	s5,a0
  np = nt->tproc;
    80001fd8:	00853983          	ld	s3,8(a0)
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001fdc:	048a3603          	ld	a2,72(s4)
    80001fe0:	0509b583          	ld	a1,80(s3)
    80001fe4:	050a3503          	ld	a0,80(s4)
    80001fe8:	fffff097          	auipc	ra,0xfffff
    80001fec:	580080e7          	jalr	1408(ra) # 80001568 <uvmcopy>
    80001ff0:	06054e63          	bltz	a0,8000206c <fork+0xca>
  np->sz = p->sz;
    80001ff4:	048a3783          	ld	a5,72(s4)
    80001ff8:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ffc:	058a3683          	ld	a3,88(s4)
    80002000:	87b6                	mv	a5,a3
    80002002:	0589b703          	ld	a4,88(s3)
    80002006:	12068693          	addi	a3,a3,288
    8000200a:	6388                	ld	a0,0(a5)
    8000200c:	0087b803          	ld	a6,8(a5) # 1008 <_entry-0x7fffeff8>
    80002010:	6b8c                	ld	a1,16(a5)
    80002012:	6f90                	ld	a2,24(a5)
    80002014:	e308                	sd	a0,0(a4)
    80002016:	01073423          	sd	a6,8(a4)
    8000201a:	eb0c                	sd	a1,16(a4)
    8000201c:	ef10                	sd	a2,24(a4)
    8000201e:	02078793          	addi	a5,a5,32
    80002022:	02070713          	addi	a4,a4,32
    80002026:	fed792e3          	bne	a5,a3,8000200a <fork+0x68>
  *(nt->trapframe) = *(t->trapframe);
    8000202a:	6c94                	ld	a3,24(s1)
    8000202c:	87b6                	mv	a5,a3
    8000202e:	018ab703          	ld	a4,24(s5)
    80002032:	12068693          	addi	a3,a3,288
    80002036:	0007b803          	ld	a6,0(a5)
    8000203a:	6788                	ld	a0,8(a5)
    8000203c:	6b8c                	ld	a1,16(a5)
    8000203e:	6f90                	ld	a2,24(a5)
    80002040:	01073023          	sd	a6,0(a4)
    80002044:	e708                	sd	a0,8(a4)
    80002046:	eb0c                	sd	a1,16(a4)
    80002048:	ef10                	sd	a2,24(a4)
    8000204a:	02078793          	addi	a5,a5,32
    8000204e:	02070713          	addi	a4,a4,32
    80002052:	fed792e3          	bne	a5,a3,80002036 <fork+0x94>
  nt->trapframe->a0 = 0;
    80002056:	018ab783          	ld	a5,24(s5)
    8000205a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    8000205e:	0d0a0493          	addi	s1,s4,208
    80002062:	0d098913          	addi	s2,s3,208
    80002066:	150a0b13          	addi	s6,s4,336
    8000206a:	a00d                	j	8000208c <fork+0xea>
    freeproc(np);
    8000206c:	854e                	mv	a0,s3
    8000206e:	00000097          	auipc	ra,0x0
    80002072:	c9c080e7          	jalr	-868(ra) # 80001d0a <freeproc>
    release(&np->lock);
    80002076:	854e                	mv	a0,s3
    80002078:	fffff097          	auipc	ra,0xfffff
    8000207c:	c2c080e7          	jalr	-980(ra) # 80000ca4 <release>
    return -1;
    80002080:	597d                	li	s2,-1
    80002082:	a06d                	j	8000212c <fork+0x18a>
  for(i = 0; i < NOFILE; i++)
    80002084:	04a1                	addi	s1,s1,8
    80002086:	0921                	addi	s2,s2,8
    80002088:	01648b63          	beq	s1,s6,8000209e <fork+0xfc>
    if(p->ofile[i])
    8000208c:	6088                	ld	a0,0(s1)
    8000208e:	d97d                	beqz	a0,80002084 <fork+0xe2>
      np->ofile[i] = filedup(p->ofile[i]);
    80002090:	00003097          	auipc	ra,0x3
    80002094:	c3a080e7          	jalr	-966(ra) # 80004cca <filedup>
    80002098:	00a93023          	sd	a0,0(s2)
    8000209c:	b7e5                	j	80002084 <fork+0xe2>
  np->cwd = idup(p->cwd);
    8000209e:	150a3503          	ld	a0,336(s4)
    800020a2:	00002097          	auipc	ra,0x2
    800020a6:	d9a080e7          	jalr	-614(ra) # 80003e3c <idup>
    800020aa:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020ae:	4641                	li	a2,16
    800020b0:	158a0593          	addi	a1,s4,344
    800020b4:	15898513          	addi	a0,s3,344
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	d86080e7          	jalr	-634(ra) # 80000e3e <safestrcpy>
  pid = np->pid;
    800020c0:	0309a903          	lw	s2,48(s3)
  np->signal_mask=p->signal_mask; 
    800020c4:	16ca2783          	lw	a5,364(s4)
    800020c8:	16f9a623          	sw	a5,364(s3)
  for(int i=0;i<32;i++)
    800020cc:	170a0793          	addi	a5,s4,368
    800020d0:	17098713          	addi	a4,s3,368
    800020d4:	270a0613          	addi	a2,s4,624
    np->signal_handlers[i]=p->signal_handlers[i]; 
    800020d8:	6394                	ld	a3,0(a5)
    800020da:	e314                	sd	a3,0(a4)
  for(int i=0;i<32;i++)
    800020dc:	07a1                	addi	a5,a5,8
    800020de:	0721                	addi	a4,a4,8
    800020e0:	fec79ce3          	bne	a5,a2,800020d8 <fork+0x136>
  release(&np->lock);
    800020e4:	854e                	mv	a0,s3
    800020e6:	fffff097          	auipc	ra,0xfffff
    800020ea:	bbe080e7          	jalr	-1090(ra) # 80000ca4 <release>
  acquire(&wait_lock);
    800020ee:	0000f497          	auipc	s1,0xf
    800020f2:	1e248493          	addi	s1,s1,482 # 800112d0 <wait_lock>
    800020f6:	8526                	mv	a0,s1
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	ae0080e7          	jalr	-1312(ra) # 80000bd8 <acquire>
  np->parent = p;
    80002100:	0349bc23          	sd	s4,56(s3)
  release(&wait_lock);
    80002104:	8526                	mv	a0,s1
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	b9e080e7          	jalr	-1122(ra) # 80000ca4 <release>
  acquire(&np->lock);
    8000210e:	854e                	mv	a0,s3
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	ac8080e7          	jalr	-1336(ra) # 80000bd8 <acquire>
  np->state = RUNNABLE;
    80002118:	478d                	li	a5,3
    8000211a:	00f9ac23          	sw	a5,24(s3)
  nt->state = RUNNABLE;
    8000211e:	00faa223          	sw	a5,4(s5)
  release(&np->lock);
    80002122:	854e                	mv	a0,s3
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	b80080e7          	jalr	-1152(ra) # 80000ca4 <release>
}
    8000212c:	854a                	mv	a0,s2
    8000212e:	70e2                	ld	ra,56(sp)
    80002130:	7442                	ld	s0,48(sp)
    80002132:	74a2                	ld	s1,40(sp)
    80002134:	7902                	ld	s2,32(sp)
    80002136:	69e2                	ld	s3,24(sp)
    80002138:	6a42                	ld	s4,16(sp)
    8000213a:	6aa2                	ld	s5,8(sp)
    8000213c:	6b02                	ld	s6,0(sp)
    8000213e:	6121                	addi	sp,sp,64
    80002140:	8082                	ret
    return -1;
    80002142:	597d                	li	s2,-1
    80002144:	b7e5                	j	8000212c <fork+0x18a>

0000000080002146 <scheduler>:
{
    80002146:	715d                	addi	sp,sp,-80
    80002148:	e486                	sd	ra,72(sp)
    8000214a:	e0a2                	sd	s0,64(sp)
    8000214c:	fc26                	sd	s1,56(sp)
    8000214e:	f84a                	sd	s2,48(sp)
    80002150:	f44e                	sd	s3,40(sp)
    80002152:	f052                	sd	s4,32(sp)
    80002154:	ec56                	sd	s5,24(sp)
    80002156:	e85a                	sd	s6,16(sp)
    80002158:	e45e                	sd	s7,8(sp)
    8000215a:	0880                	addi	s0,sp,80
    8000215c:	8792                	mv	a5,tp
  int id = r_tp();
    8000215e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002160:	00479713          	slli	a4,a5,0x4
    80002164:	00f706b3          	add	a3,a4,a5
    80002168:	00369613          	slli	a2,a3,0x3
    8000216c:	0000f697          	auipc	a3,0xf
    80002170:	13468693          	addi	a3,a3,308 # 800112a0 <pid_lock>
    80002174:	96b2                	add	a3,a3,a2
    80002176:	0406b423          	sd	zero,72(a3)
  c->thread = 0;
    8000217a:	0406b823          	sd	zero,80(a3)
            swtch(&c->context, &t->context);
    8000217e:	0000f717          	auipc	a4,0xf
    80002182:	17a70713          	addi	a4,a4,378 # 800112f8 <cpus+0x10>
    80002186:	00e60ab3          	add	s5,a2,a4
            t->state = RUNNING;
    8000218a:	4b11                	li	s6,4
            c->thread = t;
    8000218c:	8a36                	mv	s4,a3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000218e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002192:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002196:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000219a:	0000f497          	auipc	s1,0xf
    8000219e:	58e48493          	addi	s1,s1,1422 # 80011728 <proc>
    800021a2:	a881                	j	800021f2 <scheduler+0xac>
        for(t = p->threads; t < &p->threads[NTHREAD]; t++) {
    800021a4:	0a090913          	addi	s2,s2,160
    800021a8:	03390863          	beq	s2,s3,800021d8 <scheduler+0x92>
          if(t->state == RUNNABLE) {
    800021ac:	00492783          	lw	a5,4(s2)
    800021b0:	ff779ae3          	bne	a5,s7,800021a4 <scheduler+0x5e>
            t->state = RUNNING;
    800021b4:	01692223          	sw	s6,4(s2)
            c->thread = t;
    800021b8:	052a3823          	sd	s2,80(s4)
            c->proc = p;
    800021bc:	049a3423          	sd	s1,72(s4)
            swtch(&c->context, &t->context);
    800021c0:	02090593          	addi	a1,s2,32
    800021c4:	8556                	mv	a0,s5
    800021c6:	00001097          	auipc	ra,0x1
    800021ca:	a72080e7          	jalr	-1422(ra) # 80002c38 <swtch>
            c->thread = 0;
    800021ce:	040a3823          	sd	zero,80(s4)
            c->proc = 0;
    800021d2:	040a3423          	sd	zero,72(s4)
    800021d6:	b7f9                	j	800021a4 <scheduler+0x5e>
      release(&p->lock);
    800021d8:	8526                	mv	a0,s1
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	aca080e7          	jalr	-1334(ra) # 80000ca4 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800021e2:	77848493          	addi	s1,s1,1912
    800021e6:	0002d797          	auipc	a5,0x2d
    800021ea:	34278793          	addi	a5,a5,834 # 8002f528 <tickslock>
    800021ee:	faf480e3          	beq	s1,a5,8000218e <scheduler+0x48>
      acquire(&p->lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	9e4080e7          	jalr	-1564(ra) # 80000bd8 <acquire>
      if(p->state == RUNNABLE) {
    800021fc:	4c98                	lw	a4,24(s1)
    800021fe:	478d                	li	a5,3
    80002200:	fcf71ce3          	bne	a4,a5,800021d8 <scheduler+0x92>
        for(t = p->threads; t < &p->threads[NTHREAD]; t++) {
    80002204:	27848913          	addi	s2,s1,632
          if(t->state == RUNNABLE) {
    80002208:	4b8d                	li	s7,3
        for(t = p->threads; t < &p->threads[NTHREAD]; t++) {
    8000220a:	77848993          	addi	s3,s1,1912
    8000220e:	bf79                	j	800021ac <scheduler+0x66>

0000000080002210 <sched>:
{
    80002210:	7179                	addi	sp,sp,-48
    80002212:	f406                	sd	ra,40(sp)
    80002214:	f022                	sd	s0,32(sp)
    80002216:	ec26                	sd	s1,24(sp)
    80002218:	e84a                	sd	s2,16(sp)
    8000221a:	e44e                	sd	s3,8(sp)
    8000221c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000221e:	00000097          	auipc	ra,0x0
    80002222:	838080e7          	jalr	-1992(ra) # 80001a56 <myproc>
    80002226:	892a                	mv	s2,a0
  struct thread *t = mythread();
    80002228:	00000097          	auipc	ra,0x0
    8000222c:	8b4080e7          	jalr	-1868(ra) # 80001adc <mythread>
    80002230:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002232:	854a                	mv	a0,s2
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	922080e7          	jalr	-1758(ra) # 80000b56 <holding>
    8000223c:	c959                	beqz	a0,800022d2 <sched+0xc2>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000223e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002240:	0007871b          	sext.w	a4,a5
    80002244:	00471793          	slli	a5,a4,0x4
    80002248:	97ba                	add	a5,a5,a4
    8000224a:	078e                	slli	a5,a5,0x3
    8000224c:	0000f717          	auipc	a4,0xf
    80002250:	05470713          	addi	a4,a4,84 # 800112a0 <pid_lock>
    80002254:	97ba                	add	a5,a5,a4
    80002256:	0c87a703          	lw	a4,200(a5)
    8000225a:	4785                	li	a5,1
    8000225c:	08f71363          	bne	a4,a5,800022e2 <sched+0xd2>
  if(t->state == RUNNING)
    80002260:	40d8                	lw	a4,4(s1)
    80002262:	4791                	li	a5,4
    80002264:	08f70763          	beq	a4,a5,800022f2 <sched+0xe2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002268:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000226c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000226e:	ebd1                	bnez	a5,80002302 <sched+0xf2>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002270:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002272:	0000f917          	auipc	s2,0xf
    80002276:	02e90913          	addi	s2,s2,46 # 800112a0 <pid_lock>
    8000227a:	0007871b          	sext.w	a4,a5
    8000227e:	00471793          	slli	a5,a4,0x4
    80002282:	97ba                	add	a5,a5,a4
    80002284:	078e                	slli	a5,a5,0x3
    80002286:	97ca                	add	a5,a5,s2
    80002288:	0cc7a983          	lw	s3,204(a5)
    8000228c:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    8000228e:	0007859b          	sext.w	a1,a5
    80002292:	00459793          	slli	a5,a1,0x4
    80002296:	97ae                	add	a5,a5,a1
    80002298:	078e                	slli	a5,a5,0x3
    8000229a:	0000f597          	auipc	a1,0xf
    8000229e:	05e58593          	addi	a1,a1,94 # 800112f8 <cpus+0x10>
    800022a2:	95be                	add	a1,a1,a5
    800022a4:	02048513          	addi	a0,s1,32
    800022a8:	00001097          	auipc	ra,0x1
    800022ac:	990080e7          	jalr	-1648(ra) # 80002c38 <swtch>
    800022b0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800022b2:	0007871b          	sext.w	a4,a5
    800022b6:	00471793          	slli	a5,a4,0x4
    800022ba:	97ba                	add	a5,a5,a4
    800022bc:	078e                	slli	a5,a5,0x3
    800022be:	97ca                	add	a5,a5,s2
    800022c0:	0d37a623          	sw	s3,204(a5)
}
    800022c4:	70a2                	ld	ra,40(sp)
    800022c6:	7402                	ld	s0,32(sp)
    800022c8:	64e2                	ld	s1,24(sp)
    800022ca:	6942                	ld	s2,16(sp)
    800022cc:	69a2                	ld	s3,8(sp)
    800022ce:	6145                	addi	sp,sp,48
    800022d0:	8082                	ret
    panic("sched p->lock");
    800022d2:	00006517          	auipc	a0,0x6
    800022d6:	f4650513          	addi	a0,a0,-186 # 80008218 <digits+0x1d8>
    800022da:	ffffe097          	auipc	ra,0xffffe
    800022de:	25e080e7          	jalr	606(ra) # 80000538 <panic>
    panic("sched locks");
    800022e2:	00006517          	auipc	a0,0x6
    800022e6:	f4650513          	addi	a0,a0,-186 # 80008228 <digits+0x1e8>
    800022ea:	ffffe097          	auipc	ra,0xffffe
    800022ee:	24e080e7          	jalr	590(ra) # 80000538 <panic>
    panic("sched running");
    800022f2:	00006517          	auipc	a0,0x6
    800022f6:	f4650513          	addi	a0,a0,-186 # 80008238 <digits+0x1f8>
    800022fa:	ffffe097          	auipc	ra,0xffffe
    800022fe:	23e080e7          	jalr	574(ra) # 80000538 <panic>
    panic("sched interruptible");
    80002302:	00006517          	auipc	a0,0x6
    80002306:	f4650513          	addi	a0,a0,-186 # 80008248 <digits+0x208>
    8000230a:	ffffe097          	auipc	ra,0xffffe
    8000230e:	22e080e7          	jalr	558(ra) # 80000538 <panic>

0000000080002312 <yield>:
{
    80002312:	1101                	addi	sp,sp,-32
    80002314:	ec06                	sd	ra,24(sp)
    80002316:	e822                	sd	s0,16(sp)
    80002318:	e426                	sd	s1,8(sp)
    8000231a:	e04a                	sd	s2,0(sp)
    8000231c:	1000                	addi	s0,sp,32
  struct thread *t = mythread();
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	7be080e7          	jalr	1982(ra) # 80001adc <mythread>
    80002326:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	72e080e7          	jalr	1838(ra) # 80001a56 <myproc>
    80002330:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002332:	fffff097          	auipc	ra,0xfffff
    80002336:	8a6080e7          	jalr	-1882(ra) # 80000bd8 <acquire>
  t->state = RUNNABLE;
    8000233a:	478d                	li	a5,3
    8000233c:	00f92223          	sw	a5,4(s2)
  sched();
    80002340:	00000097          	auipc	ra,0x0
    80002344:	ed0080e7          	jalr	-304(ra) # 80002210 <sched>
  release(&p->lock);
    80002348:	8526                	mv	a0,s1
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	95a080e7          	jalr	-1702(ra) # 80000ca4 <release>
}
    80002352:	60e2                	ld	ra,24(sp)
    80002354:	6442                	ld	s0,16(sp)
    80002356:	64a2                	ld	s1,8(sp)
    80002358:	6902                	ld	s2,0(sp)
    8000235a:	6105                	addi	sp,sp,32
    8000235c:	8082                	ret

000000008000235e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000235e:	7179                	addi	sp,sp,-48
    80002360:	f406                	sd	ra,40(sp)
    80002362:	f022                	sd	s0,32(sp)
    80002364:	ec26                	sd	s1,24(sp)
    80002366:	e84a                	sd	s2,16(sp)
    80002368:	e44e                	sd	s3,8(sp)
    8000236a:	e052                	sd	s4,0(sp)
    8000236c:	1800                	addi	s0,sp,48
    8000236e:	89aa                	mv	s3,a0
    80002370:	892e                	mv	s2,a1
  //struct proc *p = myproc();
  struct thread *t = mythread();
    80002372:	fffff097          	auipc	ra,0xfffff
    80002376:	76a080e7          	jalr	1898(ra) # 80001adc <mythread>
    8000237a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000237c:	00853a03          	ld	s4,8(a0)
    80002380:	8552                	mv	a0,s4
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	856080e7          	jalr	-1962(ra) # 80000bd8 <acquire>
  release(lk);
    8000238a:	854a                	mv	a0,s2
    8000238c:	fffff097          	auipc	ra,0xfffff
    80002390:	918080e7          	jalr	-1768(ra) # 80000ca4 <release>

  // Go to sleep.
  t->chan = chan;
    80002394:	0934b823          	sd	s3,144(s1)
  t->state = SLEEPING;
    80002398:	4789                	li	a5,2
    8000239a:	c0dc                	sw	a5,4(s1)

  sched();
    8000239c:	00000097          	auipc	ra,0x0
    800023a0:	e74080e7          	jalr	-396(ra) # 80002210 <sched>

  // Tidy up.
  t->chan = 0;
    800023a4:	0804b823          	sd	zero,144(s1)

  // Reacquire original lock.
  release(&p->lock);
    800023a8:	8552                	mv	a0,s4
    800023aa:	fffff097          	auipc	ra,0xfffff
    800023ae:	8fa080e7          	jalr	-1798(ra) # 80000ca4 <release>
  acquire(lk);
    800023b2:	854a                	mv	a0,s2
    800023b4:	fffff097          	auipc	ra,0xfffff
    800023b8:	824080e7          	jalr	-2012(ra) # 80000bd8 <acquire>
}
    800023bc:	70a2                	ld	ra,40(sp)
    800023be:	7402                	ld	s0,32(sp)
    800023c0:	64e2                	ld	s1,24(sp)
    800023c2:	6942                	ld	s2,16(sp)
    800023c4:	69a2                	ld	s3,8(sp)
    800023c6:	6a02                	ld	s4,0(sp)
    800023c8:	6145                	addi	sp,sp,48
    800023ca:	8082                	ret

00000000800023cc <wait>:
{
    800023cc:	715d                	addi	sp,sp,-80
    800023ce:	e486                	sd	ra,72(sp)
    800023d0:	e0a2                	sd	s0,64(sp)
    800023d2:	fc26                	sd	s1,56(sp)
    800023d4:	f84a                	sd	s2,48(sp)
    800023d6:	f44e                	sd	s3,40(sp)
    800023d8:	f052                	sd	s4,32(sp)
    800023da:	ec56                	sd	s5,24(sp)
    800023dc:	e85a                	sd	s6,16(sp)
    800023de:	e45e                	sd	s7,8(sp)
    800023e0:	e062                	sd	s8,0(sp)
    800023e2:	0880                	addi	s0,sp,80
    800023e4:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	670080e7          	jalr	1648(ra) # 80001a56 <myproc>
    800023ee:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023f0:	0000f517          	auipc	a0,0xf
    800023f4:	ee050513          	addi	a0,a0,-288 # 800112d0 <wait_lock>
    800023f8:	ffffe097          	auipc	ra,0xffffe
    800023fc:	7e0080e7          	jalr	2016(ra) # 80000bd8 <acquire>
    havekids = 0;
    80002400:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002402:	4a15                	li	s4,5
        havekids = 1;
    80002404:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002406:	0002d997          	auipc	s3,0x2d
    8000240a:	12298993          	addi	s3,s3,290 # 8002f528 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000240e:	0000fc17          	auipc	s8,0xf
    80002412:	ec2c0c13          	addi	s8,s8,-318 # 800112d0 <wait_lock>
    havekids = 0;
    80002416:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002418:	0000f497          	auipc	s1,0xf
    8000241c:	31048493          	addi	s1,s1,784 # 80011728 <proc>
    80002420:	a0bd                	j	8000248e <wait+0xc2>
          pid = np->pid;
    80002422:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002426:	000b0e63          	beqz	s6,80002442 <wait+0x76>
    8000242a:	4691                	li	a3,4
    8000242c:	02c48613          	addi	a2,s1,44
    80002430:	85da                	mv	a1,s6
    80002432:	05093503          	ld	a0,80(s2)
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	236080e7          	jalr	566(ra) # 8000166c <copyout>
    8000243e:	02054563          	bltz	a0,80002468 <wait+0x9c>
          freeproc(np);
    80002442:	8526                	mv	a0,s1
    80002444:	00000097          	auipc	ra,0x0
    80002448:	8c6080e7          	jalr	-1850(ra) # 80001d0a <freeproc>
          release(&np->lock);
    8000244c:	8526                	mv	a0,s1
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	856080e7          	jalr	-1962(ra) # 80000ca4 <release>
          release(&wait_lock);
    80002456:	0000f517          	auipc	a0,0xf
    8000245a:	e7a50513          	addi	a0,a0,-390 # 800112d0 <wait_lock>
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	846080e7          	jalr	-1978(ra) # 80000ca4 <release>
          return pid;
    80002466:	a09d                	j	800024cc <wait+0x100>
            release(&np->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	83a080e7          	jalr	-1990(ra) # 80000ca4 <release>
            release(&wait_lock);
    80002472:	0000f517          	auipc	a0,0xf
    80002476:	e5e50513          	addi	a0,a0,-418 # 800112d0 <wait_lock>
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	82a080e7          	jalr	-2006(ra) # 80000ca4 <release>
            return -1;
    80002482:	59fd                	li	s3,-1
    80002484:	a0a1                	j	800024cc <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002486:	77848493          	addi	s1,s1,1912
    8000248a:	03348463          	beq	s1,s3,800024b2 <wait+0xe6>
      if(np->parent == p){
    8000248e:	7c9c                	ld	a5,56(s1)
    80002490:	ff279be3          	bne	a5,s2,80002486 <wait+0xba>
        acquire(&np->lock);
    80002494:	8526                	mv	a0,s1
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	742080e7          	jalr	1858(ra) # 80000bd8 <acquire>
        if(np->state == ZOMBIE){
    8000249e:	4c9c                	lw	a5,24(s1)
    800024a0:	f94781e3          	beq	a5,s4,80002422 <wait+0x56>
        release(&np->lock);
    800024a4:	8526                	mv	a0,s1
    800024a6:	ffffe097          	auipc	ra,0xffffe
    800024aa:	7fe080e7          	jalr	2046(ra) # 80000ca4 <release>
        havekids = 1;
    800024ae:	8756                	mv	a4,s5
    800024b0:	bfd9                	j	80002486 <wait+0xba>
    if(!havekids || p->killed){
    800024b2:	c701                	beqz	a4,800024ba <wait+0xee>
    800024b4:	02892783          	lw	a5,40(s2)
    800024b8:	c79d                	beqz	a5,800024e6 <wait+0x11a>
      release(&wait_lock);
    800024ba:	0000f517          	auipc	a0,0xf
    800024be:	e1650513          	addi	a0,a0,-490 # 800112d0 <wait_lock>
    800024c2:	ffffe097          	auipc	ra,0xffffe
    800024c6:	7e2080e7          	jalr	2018(ra) # 80000ca4 <release>
      return -1;
    800024ca:	59fd                	li	s3,-1
}
    800024cc:	854e                	mv	a0,s3
    800024ce:	60a6                	ld	ra,72(sp)
    800024d0:	6406                	ld	s0,64(sp)
    800024d2:	74e2                	ld	s1,56(sp)
    800024d4:	7942                	ld	s2,48(sp)
    800024d6:	79a2                	ld	s3,40(sp)
    800024d8:	7a02                	ld	s4,32(sp)
    800024da:	6ae2                	ld	s5,24(sp)
    800024dc:	6b42                	ld	s6,16(sp)
    800024de:	6ba2                	ld	s7,8(sp)
    800024e0:	6c02                	ld	s8,0(sp)
    800024e2:	6161                	addi	sp,sp,80
    800024e4:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024e6:	85e2                	mv	a1,s8
    800024e8:	854a                	mv	a0,s2
    800024ea:	00000097          	auipc	ra,0x0
    800024ee:	e74080e7          	jalr	-396(ra) # 8000235e <sleep>
    havekids = 0;
    800024f2:	b715                	j	80002416 <wait+0x4a>

00000000800024f4 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800024f4:	715d                	addi	sp,sp,-80
    800024f6:	e486                	sd	ra,72(sp)
    800024f8:	e0a2                	sd	s0,64(sp)
    800024fa:	fc26                	sd	s1,56(sp)
    800024fc:	f84a                	sd	s2,48(sp)
    800024fe:	f44e                	sd	s3,40(sp)
    80002500:	f052                	sd	s4,32(sp)
    80002502:	ec56                	sd	s5,24(sp)
    80002504:	e85a                	sd	s6,16(sp)
    80002506:	e45e                	sd	s7,8(sp)
    80002508:	0880                	addi	s0,sp,80
    8000250a:	8b2a                	mv	s6,a0
  struct proc *p;
  struct thread *t;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000250c:	00010997          	auipc	s3,0x10
    80002510:	99498993          	addi	s3,s3,-1644 # 80011ea0 <proc+0x778>
    80002514:	0000f917          	auipc	s2,0xf
    80002518:	21490913          	addi	s2,s2,532 # 80011728 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000251c:	4a09                	li	s4,2
        p->state = RUNNABLE;
      }
      for(t = p->threads; t < &p->threads[NTHREAD]; t++){
        if(t->state == SLEEPING && t->chan == chan) {
          t->state = RUNNABLE;
    8000251e:	4b8d                	li	s7,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002520:	0002da97          	auipc	s5,0x2d
    80002524:	008a8a93          	addi	s5,s5,8 # 8002f528 <tickslock>
    80002528:	a081                	j	80002568 <wakeup+0x74>
      if(p->state == SLEEPING && p->chan == chan) {
    8000252a:	02093783          	ld	a5,32(s2)
    8000252e:	05679d63          	bne	a5,s6,80002588 <wakeup+0x94>
        p->state = RUNNABLE;
    80002532:	01792c23          	sw	s7,24(s2)
    80002536:	a889                	j	80002588 <wakeup+0x94>
      for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80002538:	0a078793          	addi	a5,a5,160
    8000253c:	01378b63          	beq	a5,s3,80002552 <wakeup+0x5e>
        if(t->state == SLEEPING && t->chan == chan) {
    80002540:	43d8                	lw	a4,4(a5)
    80002542:	ff471be3          	bne	a4,s4,80002538 <wakeup+0x44>
    80002546:	6bd8                	ld	a4,144(a5)
    80002548:	ff6718e3          	bne	a4,s6,80002538 <wakeup+0x44>
          t->state = RUNNABLE;
    8000254c:	0177a223          	sw	s7,4(a5)
    80002550:	b7e5                	j	80002538 <wakeup+0x44>
        }
      }
      release(&p->lock);
    80002552:	854a                	mv	a0,s2
    80002554:	ffffe097          	auipc	ra,0xffffe
    80002558:	750080e7          	jalr	1872(ra) # 80000ca4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000255c:	77890913          	addi	s2,s2,1912
    80002560:	77898993          	addi	s3,s3,1912
    80002564:	03590563          	beq	s2,s5,8000258e <wakeup+0x9a>
    if(p != myproc()){
    80002568:	fffff097          	auipc	ra,0xfffff
    8000256c:	4ee080e7          	jalr	1262(ra) # 80001a56 <myproc>
    80002570:	fea906e3          	beq	s2,a0,8000255c <wakeup+0x68>
      acquire(&p->lock);
    80002574:	84ca                	mv	s1,s2
    80002576:	854a                	mv	a0,s2
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	660080e7          	jalr	1632(ra) # 80000bd8 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002580:	01892783          	lw	a5,24(s2)
    80002584:	fb4783e3          	beq	a5,s4,8000252a <wakeup+0x36>
      for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80002588:	27848793          	addi	a5,s1,632
    8000258c:	bf55                	j	80002540 <wakeup+0x4c>
    }
  }
}
    8000258e:	60a6                	ld	ra,72(sp)
    80002590:	6406                	ld	s0,64(sp)
    80002592:	74e2                	ld	s1,56(sp)
    80002594:	7942                	ld	s2,48(sp)
    80002596:	79a2                	ld	s3,40(sp)
    80002598:	7a02                	ld	s4,32(sp)
    8000259a:	6ae2                	ld	s5,24(sp)
    8000259c:	6b42                	ld	s6,16(sp)
    8000259e:	6ba2                	ld	s7,8(sp)
    800025a0:	6161                	addi	sp,sp,80
    800025a2:	8082                	ret

00000000800025a4 <reparent>:
{
    800025a4:	7179                	addi	sp,sp,-48
    800025a6:	f406                	sd	ra,40(sp)
    800025a8:	f022                	sd	s0,32(sp)
    800025aa:	ec26                	sd	s1,24(sp)
    800025ac:	e84a                	sd	s2,16(sp)
    800025ae:	e44e                	sd	s3,8(sp)
    800025b0:	e052                	sd	s4,0(sp)
    800025b2:	1800                	addi	s0,sp,48
    800025b4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800025b6:	0000f497          	auipc	s1,0xf
    800025ba:	17248493          	addi	s1,s1,370 # 80011728 <proc>
      pp->parent = initproc;
    800025be:	00007a17          	auipc	s4,0x7
    800025c2:	a6aa0a13          	addi	s4,s4,-1430 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800025c6:	0002d997          	auipc	s3,0x2d
    800025ca:	f6298993          	addi	s3,s3,-158 # 8002f528 <tickslock>
    800025ce:	a029                	j	800025d8 <reparent+0x34>
    800025d0:	77848493          	addi	s1,s1,1912
    800025d4:	01348d63          	beq	s1,s3,800025ee <reparent+0x4a>
    if(pp->parent == p){
    800025d8:	7c9c                	ld	a5,56(s1)
    800025da:	ff279be3          	bne	a5,s2,800025d0 <reparent+0x2c>
      pp->parent = initproc;
    800025de:	000a3503          	ld	a0,0(s4)
    800025e2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800025e4:	00000097          	auipc	ra,0x0
    800025e8:	f10080e7          	jalr	-240(ra) # 800024f4 <wakeup>
    800025ec:	b7d5                	j	800025d0 <reparent+0x2c>
}
    800025ee:	70a2                	ld	ra,40(sp)
    800025f0:	7402                	ld	s0,32(sp)
    800025f2:	64e2                	ld	s1,24(sp)
    800025f4:	6942                	ld	s2,16(sp)
    800025f6:	69a2                	ld	s3,8(sp)
    800025f8:	6a02                	ld	s4,0(sp)
    800025fa:	6145                	addi	sp,sp,48
    800025fc:	8082                	ret

00000000800025fe <exit>:
{
    800025fe:	7179                	addi	sp,sp,-48
    80002600:	f406                	sd	ra,40(sp)
    80002602:	f022                	sd	s0,32(sp)
    80002604:	ec26                	sd	s1,24(sp)
    80002606:	e84a                	sd	s2,16(sp)
    80002608:	e44e                	sd	s3,8(sp)
    8000260a:	e052                	sd	s4,0(sp)
    8000260c:	1800                	addi	s0,sp,48
    8000260e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002610:	fffff097          	auipc	ra,0xfffff
    80002614:	446080e7          	jalr	1094(ra) # 80001a56 <myproc>
    80002618:	89aa                	mv	s3,a0
  if(p == initproc)
    8000261a:	00007797          	auipc	a5,0x7
    8000261e:	a0e7b783          	ld	a5,-1522(a5) # 80009028 <initproc>
    80002622:	0d050493          	addi	s1,a0,208
    80002626:	15050913          	addi	s2,a0,336
    8000262a:	02a79363          	bne	a5,a0,80002650 <exit+0x52>
    panic("init exiting");
    8000262e:	00006517          	auipc	a0,0x6
    80002632:	c3250513          	addi	a0,a0,-974 # 80008260 <digits+0x220>
    80002636:	ffffe097          	auipc	ra,0xffffe
    8000263a:	f02080e7          	jalr	-254(ra) # 80000538 <panic>
      fileclose(f);
    8000263e:	00002097          	auipc	ra,0x2
    80002642:	6de080e7          	jalr	1758(ra) # 80004d1c <fileclose>
      p->ofile[fd] = 0;
    80002646:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000264a:	04a1                	addi	s1,s1,8
    8000264c:	01248563          	beq	s1,s2,80002656 <exit+0x58>
    if(p->ofile[fd]){
    80002650:	6088                	ld	a0,0(s1)
    80002652:	f575                	bnez	a0,8000263e <exit+0x40>
    80002654:	bfdd                	j	8000264a <exit+0x4c>
  begin_op();
    80002656:	00002097          	auipc	ra,0x2
    8000265a:	1fa080e7          	jalr	506(ra) # 80004850 <begin_op>
  iput(p->cwd);
    8000265e:	1509b503          	ld	a0,336(s3)
    80002662:	00002097          	auipc	ra,0x2
    80002666:	9d2080e7          	jalr	-1582(ra) # 80004034 <iput>
  end_op();
    8000266a:	00002097          	auipc	ra,0x2
    8000266e:	266080e7          	jalr	614(ra) # 800048d0 <end_op>
  p->cwd = 0;
    80002672:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002676:	0000f517          	auipc	a0,0xf
    8000267a:	c5a50513          	addi	a0,a0,-934 # 800112d0 <wait_lock>
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	55a080e7          	jalr	1370(ra) # 80000bd8 <acquire>
  reparent(p);
    80002686:	854e                	mv	a0,s3
    80002688:	00000097          	auipc	ra,0x0
    8000268c:	f1c080e7          	jalr	-228(ra) # 800025a4 <reparent>
  wakeup(p->parent);
    80002690:	0389b503          	ld	a0,56(s3)
    80002694:	00000097          	auipc	ra,0x0
    80002698:	e60080e7          	jalr	-416(ra) # 800024f4 <wakeup>
  acquire(&p->lock);
    8000269c:	854e                	mv	a0,s3
    8000269e:	ffffe097          	auipc	ra,0xffffe
    800026a2:	53a080e7          	jalr	1338(ra) # 80000bd8 <acquire>
  for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    800026a6:	27898793          	addi	a5,s3,632
    800026aa:	77898693          	addi	a3,s3,1912
    if(t->state != UNUSED && t->state != ZOMBIE){
    800026ae:	4615                	li	a2,5
      t->killed = 1;
    800026b0:	4585                	li	a1,1
    800026b2:	a029                	j	800026bc <exit+0xbe>
  for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    800026b4:	0a078793          	addi	a5,a5,160
    800026b8:	00f68c63          	beq	a3,a5,800026d0 <exit+0xd2>
    if(t->state != UNUSED && t->state != ZOMBIE){
    800026bc:	43d8                	lw	a4,4(a5)
    800026be:	db7d                	beqz	a4,800026b4 <exit+0xb6>
    800026c0:	fec70ae3          	beq	a4,a2,800026b4 <exit+0xb6>
      t->killed = 1;
    800026c4:	08b7ac23          	sw	a1,152(a5)
      t->state = ZOMBIE;
    800026c8:	c3d0                	sw	a2,4(a5)
      t->xstate = status;
    800026ca:	0947ae23          	sw	s4,156(a5)
      if(t->state == SLEEPING){
    800026ce:	b7dd                	j	800026b4 <exit+0xb6>
  p->xstate = status;
    800026d0:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800026d4:	4795                	li	a5,5
    800026d6:	00f9ac23          	sw	a5,24(s3)
  p->killed = 1;
    800026da:	4785                	li	a5,1
    800026dc:	02f9a423          	sw	a5,40(s3)
  release(&wait_lock);
    800026e0:	0000f517          	auipc	a0,0xf
    800026e4:	bf050513          	addi	a0,a0,-1040 # 800112d0 <wait_lock>
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	5bc080e7          	jalr	1468(ra) # 80000ca4 <release>
  sched();
    800026f0:	00000097          	auipc	ra,0x0
    800026f4:	b20080e7          	jalr	-1248(ra) # 80002210 <sched>
  panic("zombie exit");
    800026f8:	00006517          	auipc	a0,0x6
    800026fc:	b7850513          	addi	a0,a0,-1160 # 80008270 <digits+0x230>
    80002700:	ffffe097          	auipc	ra,0xffffe
    80002704:	e38080e7          	jalr	-456(ra) # 80000538 <panic>

0000000080002708 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002708:	7179                	addi	sp,sp,-48
    8000270a:	f406                	sd	ra,40(sp)
    8000270c:	f022                	sd	s0,32(sp)
    8000270e:	ec26                	sd	s1,24(sp)
    80002710:	e84a                	sd	s2,16(sp)
    80002712:	e44e                	sd	s3,8(sp)
    80002714:	1800                	addi	s0,sp,48
    80002716:	892a                	mv	s2,a0
  struct proc *p;
  struct thread *t;

  for(p = proc; p < &proc[NPROC]; p++){
    80002718:	0000f497          	auipc	s1,0xf
    8000271c:	01048493          	addi	s1,s1,16 # 80011728 <proc>
    80002720:	0002d997          	auipc	s3,0x2d
    80002724:	e0898993          	addi	s3,s3,-504 # 8002f528 <tickslock>
    acquire(&p->lock);
    80002728:	8526                	mv	a0,s1
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	4ae080e7          	jalr	1198(ra) # 80000bd8 <acquire>
    if(p->pid == pid){
    80002732:	589c                	lw	a5,48(s1)
    80002734:	01278d63          	beq	a5,s2,8000274e <kill+0x46>
      }

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002738:	8526                	mv	a0,s1
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	56a080e7          	jalr	1386(ra) # 80000ca4 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002742:	77848493          	addi	s1,s1,1912
    80002746:	ff3491e3          	bne	s1,s3,80002728 <kill+0x20>
  }
  return -1;
    8000274a:	557d                	li	a0,-1
    8000274c:	a099                	j	80002792 <kill+0x8a>
      p->killed = 1;
    8000274e:	4785                	li	a5,1
    80002750:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002752:	4c98                	lw	a4,24(s1)
    80002754:	4789                	li	a5,2
    80002756:	00f70a63          	beq	a4,a5,8000276a <kill+0x62>
      for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    8000275a:	27848793          	addi	a5,s1,632
    8000275e:	77848593          	addi	a1,s1,1912
        t->killed = 1; //TODO?
    80002762:	4605                	li	a2,1
        if(t->state == SLEEPING){
    80002764:	4689                	li	a3,2
          t->state = RUNNABLE;
    80002766:	450d                	li	a0,3
    80002768:	a801                	j	80002778 <kill+0x70>
        p->state = RUNNABLE;
    8000276a:	478d                	li	a5,3
    8000276c:	cc9c                	sw	a5,24(s1)
    8000276e:	b7f5                	j	8000275a <kill+0x52>
      for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80002770:	0a078793          	addi	a5,a5,160
    80002774:	00b78963          	beq	a5,a1,80002786 <kill+0x7e>
        t->killed = 1; //TODO?
    80002778:	08c7ac23          	sw	a2,152(a5)
        if(t->state == SLEEPING){
    8000277c:	43d8                	lw	a4,4(a5)
    8000277e:	fed719e3          	bne	a4,a3,80002770 <kill+0x68>
          t->state = RUNNABLE;
    80002782:	c3c8                	sw	a0,4(a5)
    80002784:	b7f5                	j	80002770 <kill+0x68>
      release(&p->lock);
    80002786:	8526                	mv	a0,s1
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	51c080e7          	jalr	1308(ra) # 80000ca4 <release>
      return 0;
    80002790:	4501                	li	a0,0
}
    80002792:	70a2                	ld	ra,40(sp)
    80002794:	7402                	ld	s0,32(sp)
    80002796:	64e2                	ld	s1,24(sp)
    80002798:	6942                	ld	s2,16(sp)
    8000279a:	69a2                	ld	s3,8(sp)
    8000279c:	6145                	addi	sp,sp,48
    8000279e:	8082                	ret

00000000800027a0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027a0:	7179                	addi	sp,sp,-48
    800027a2:	f406                	sd	ra,40(sp)
    800027a4:	f022                	sd	s0,32(sp)
    800027a6:	ec26                	sd	s1,24(sp)
    800027a8:	e84a                	sd	s2,16(sp)
    800027aa:	e44e                	sd	s3,8(sp)
    800027ac:	e052                	sd	s4,0(sp)
    800027ae:	1800                	addi	s0,sp,48
    800027b0:	84aa                	mv	s1,a0
    800027b2:	892e                	mv	s2,a1
    800027b4:	89b2                	mv	s3,a2
    800027b6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027b8:	fffff097          	auipc	ra,0xfffff
    800027bc:	29e080e7          	jalr	670(ra) # 80001a56 <myproc>
  if(user_dst){
    800027c0:	c08d                	beqz	s1,800027e2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800027c2:	86d2                	mv	a3,s4
    800027c4:	864e                	mv	a2,s3
    800027c6:	85ca                	mv	a1,s2
    800027c8:	6928                	ld	a0,80(a0)
    800027ca:	fffff097          	auipc	ra,0xfffff
    800027ce:	ea2080e7          	jalr	-350(ra) # 8000166c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027d2:	70a2                	ld	ra,40(sp)
    800027d4:	7402                	ld	s0,32(sp)
    800027d6:	64e2                	ld	s1,24(sp)
    800027d8:	6942                	ld	s2,16(sp)
    800027da:	69a2                	ld	s3,8(sp)
    800027dc:	6a02                	ld	s4,0(sp)
    800027de:	6145                	addi	sp,sp,48
    800027e0:	8082                	ret
    memmove((char *)dst, src, len);
    800027e2:	000a061b          	sext.w	a2,s4
    800027e6:	85ce                	mv	a1,s3
    800027e8:	854a                	mv	a0,s2
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	55e080e7          	jalr	1374(ra) # 80000d48 <memmove>
    return 0;
    800027f2:	8526                	mv	a0,s1
    800027f4:	bff9                	j	800027d2 <either_copyout+0x32>

00000000800027f6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027f6:	7179                	addi	sp,sp,-48
    800027f8:	f406                	sd	ra,40(sp)
    800027fa:	f022                	sd	s0,32(sp)
    800027fc:	ec26                	sd	s1,24(sp)
    800027fe:	e84a                	sd	s2,16(sp)
    80002800:	e44e                	sd	s3,8(sp)
    80002802:	e052                	sd	s4,0(sp)
    80002804:	1800                	addi	s0,sp,48
    80002806:	892a                	mv	s2,a0
    80002808:	84ae                	mv	s1,a1
    8000280a:	89b2                	mv	s3,a2
    8000280c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000280e:	fffff097          	auipc	ra,0xfffff
    80002812:	248080e7          	jalr	584(ra) # 80001a56 <myproc>
  if(user_src){
    80002816:	c08d                	beqz	s1,80002838 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002818:	86d2                	mv	a3,s4
    8000281a:	864e                	mv	a2,s3
    8000281c:	85ca                	mv	a1,s2
    8000281e:	6928                	ld	a0,80(a0)
    80002820:	fffff097          	auipc	ra,0xfffff
    80002824:	ed8080e7          	jalr	-296(ra) # 800016f8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002828:	70a2                	ld	ra,40(sp)
    8000282a:	7402                	ld	s0,32(sp)
    8000282c:	64e2                	ld	s1,24(sp)
    8000282e:	6942                	ld	s2,16(sp)
    80002830:	69a2                	ld	s3,8(sp)
    80002832:	6a02                	ld	s4,0(sp)
    80002834:	6145                	addi	sp,sp,48
    80002836:	8082                	ret
    memmove(dst, (char*)src, len);
    80002838:	000a061b          	sext.w	a2,s4
    8000283c:	85ce                	mv	a1,s3
    8000283e:	854a                	mv	a0,s2
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	508080e7          	jalr	1288(ra) # 80000d48 <memmove>
    return 0;
    80002848:	8526                	mv	a0,s1
    8000284a:	bff9                	j	80002828 <either_copyin+0x32>

000000008000284c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000284c:	715d                	addi	sp,sp,-80
    8000284e:	e486                	sd	ra,72(sp)
    80002850:	e0a2                	sd	s0,64(sp)
    80002852:	fc26                	sd	s1,56(sp)
    80002854:	f84a                	sd	s2,48(sp)
    80002856:	f44e                	sd	s3,40(sp)
    80002858:	f052                	sd	s4,32(sp)
    8000285a:	ec56                	sd	s5,24(sp)
    8000285c:	e85a                	sd	s6,16(sp)
    8000285e:	e45e                	sd	s7,8(sp)
    80002860:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002862:	00006517          	auipc	a0,0x6
    80002866:	87650513          	addi	a0,a0,-1930 # 800080d8 <digits+0x98>
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	d18080e7          	jalr	-744(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002872:	0000f497          	auipc	s1,0xf
    80002876:	00e48493          	addi	s1,s1,14 # 80011880 <proc+0x158>
    8000287a:	0002d917          	auipc	s2,0x2d
    8000287e:	e0690913          	addi	s2,s2,-506 # 8002f680 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002882:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002884:	00006997          	auipc	s3,0x6
    80002888:	9fc98993          	addi	s3,s3,-1540 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000288c:	00006a97          	auipc	s5,0x6
    80002890:	9fca8a93          	addi	s5,s5,-1540 # 80008288 <digits+0x248>
    printf("\n");
    80002894:	00006a17          	auipc	s4,0x6
    80002898:	844a0a13          	addi	s4,s4,-1980 # 800080d8 <digits+0x98>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000289c:	00006b97          	auipc	s7,0x6
    800028a0:	a3cb8b93          	addi	s7,s7,-1476 # 800082d8 <states.0>
    800028a4:	a00d                	j	800028c6 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800028a6:	ed86a583          	lw	a1,-296(a3)
    800028aa:	8556                	mv	a0,s5
    800028ac:	ffffe097          	auipc	ra,0xffffe
    800028b0:	cd6080e7          	jalr	-810(ra) # 80000582 <printf>
    printf("\n");
    800028b4:	8552                	mv	a0,s4
    800028b6:	ffffe097          	auipc	ra,0xffffe
    800028ba:	ccc080e7          	jalr	-820(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028be:	77848493          	addi	s1,s1,1912
    800028c2:	03248263          	beq	s1,s2,800028e6 <procdump+0x9a>
    if(p->state == UNUSED)
    800028c6:	86a6                	mv	a3,s1
    800028c8:	ec04a783          	lw	a5,-320(s1)
    800028cc:	dbed                	beqz	a5,800028be <procdump+0x72>
      state = "???";
    800028ce:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028d0:	fcfb6be3          	bltu	s6,a5,800028a6 <procdump+0x5a>
    800028d4:	02079713          	slli	a4,a5,0x20
    800028d8:	01d75793          	srli	a5,a4,0x1d
    800028dc:	97de                	add	a5,a5,s7
    800028de:	6390                	ld	a2,0(a5)
    800028e0:	f279                	bnez	a2,800028a6 <procdump+0x5a>
      state = "???";
    800028e2:	864e                	mv	a2,s3
    800028e4:	b7c9                	j	800028a6 <procdump+0x5a>
  }
}
    800028e6:	60a6                	ld	ra,72(sp)
    800028e8:	6406                	ld	s0,64(sp)
    800028ea:	74e2                	ld	s1,56(sp)
    800028ec:	7942                	ld	s2,48(sp)
    800028ee:	79a2                	ld	s3,40(sp)
    800028f0:	7a02                	ld	s4,32(sp)
    800028f2:	6ae2                	ld	s5,24(sp)
    800028f4:	6b42                	ld	s6,16(sp)
    800028f6:	6ba2                	ld	s7,8(sp)
    800028f8:	6161                	addi	sp,sp,80
    800028fa:	8082                	ret

00000000800028fc <sigprocmask>:

//task 1.3
uint
sigprocmask(uint sigmask){
    800028fc:	7179                	addi	sp,sp,-48
    800028fe:	f406                	sd	ra,40(sp)
    80002900:	f022                	sd	s0,32(sp)
    80002902:	ec26                	sd	s1,24(sp)
    80002904:	e84a                	sd	s2,16(sp)
    80002906:	e44e                	sd	s3,8(sp)
    80002908:	1800                	addi	s0,sp,48
    8000290a:	892a                	mv	s2,a0
  struct proc *p=myproc();
    8000290c:	fffff097          	auipc	ra,0xfffff
    80002910:	14a080e7          	jalr	330(ra) # 80001a56 <myproc>
    80002914:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	2c2080e7          	jalr	706(ra) # 80000bd8 <acquire>
  uint prev=p->signal_mask;
    8000291e:	16c4a983          	lw	s3,364(s1)
  p->signal_mask=sigmask;
    80002922:	1724a623          	sw	s2,364(s1)
  release(&p->lock);
    80002926:	8526                	mv	a0,s1
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	37c080e7          	jalr	892(ra) # 80000ca4 <release>
  return prev;

}
    80002930:	854e                	mv	a0,s3
    80002932:	70a2                	ld	ra,40(sp)
    80002934:	7402                	ld	s0,32(sp)
    80002936:	64e2                	ld	s1,24(sp)
    80002938:	6942                	ld	s2,16(sp)
    8000293a:	69a2                	ld	s3,8(sp)
    8000293c:	6145                	addi	sp,sp,48
    8000293e:	8082                	ret

0000000080002940 <sigaction>:
//task 1.3

//task 1.4
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  if(signum==SIGKILL || signum==SIGSTOP) // return error if its sigstop or sigkill
    80002940:	ff75079b          	addiw	a5,a0,-9
    80002944:	9bdd                	andi	a5,a5,-9
    80002946:	2781                	sext.w	a5,a5
    80002948:	cba1                	beqz	a5,80002998 <sigaction+0x58>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    8000294a:	7179                	addi	sp,sp,-48
    8000294c:	f406                	sd	ra,40(sp)
    8000294e:	f022                	sd	s0,32(sp)
    80002950:	ec26                	sd	s1,24(sp)
    80002952:	e84a                	sd	s2,16(sp)
    80002954:	e44e                	sd	s3,8(sp)
    80002956:	1800                	addi	s0,sp,48
    80002958:	84aa                	mv	s1,a0
    8000295a:	892e                	mv	s2,a1
    return -1;
  struct proc *p=myproc();
    8000295c:	fffff097          	auipc	ra,0xfffff
    80002960:	0fa080e7          	jalr	250(ra) # 80001a56 <myproc>
    80002964:	89aa                	mv	s3,a0
  acquire(&p->lock);
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	272080e7          	jalr	626(ra) # 80000bd8 <acquire>
  if(oldact!=0)
    oldact=p->signal_handlers[signum];
  if(act!=0)
    8000296e:	00090863          	beqz	s2,8000297e <sigaction+0x3e>
    p->signal_handlers[signum]=(void*)act;
    80002972:	02e48493          	addi	s1,s1,46
    80002976:	048e                	slli	s1,s1,0x3
    80002978:	94ce                	add	s1,s1,s3
    8000297a:	0124b023          	sd	s2,0(s1)
  release(&p->lock);
    8000297e:	854e                	mv	a0,s3
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	324080e7          	jalr	804(ra) # 80000ca4 <release>
  return 0; // success
    80002988:	4501                	li	a0,0
}
    8000298a:	70a2                	ld	ra,40(sp)
    8000298c:	7402                	ld	s0,32(sp)
    8000298e:	64e2                	ld	s1,24(sp)
    80002990:	6942                	ld	s2,16(sp)
    80002992:	69a2                	ld	s3,8(sp)
    80002994:	6145                	addi	sp,sp,48
    80002996:	8082                	ret
    return -1;
    80002998:	557d                	li	a0,-1
}
    8000299a:	8082                	ret

000000008000299c <sigret>:
//task 1.4

//task 1.5
  void
  sigret(void){
    8000299c:	1141                	addi	sp,sp,-16
    8000299e:	e422                	sd	s0,8(sp)
    800029a0:	0800                	addi	s0,sp,16
    //todo after 2.4 is done
  }
    800029a2:	6422                	ld	s0,8(sp)
    800029a4:	0141                	addi	sp,sp,16
    800029a6:	8082                	ret

00000000800029a8 <kthread_create>:
//task 1.5

int kthread_create(uint64 start_func, uint64 stack){
    800029a8:	7139                	addi	sp,sp,-64
    800029aa:	fc06                	sd	ra,56(sp)
    800029ac:	f822                	sd	s0,48(sp)
    800029ae:	f426                	sd	s1,40(sp)
    800029b0:	f04a                	sd	s2,32(sp)
    800029b2:	ec4e                	sd	s3,24(sp)
    800029b4:	e852                	sd	s4,16(sp)
    800029b6:	e456                	sd	s5,8(sp)
    800029b8:	0080                	addi	s0,sp,64
    800029ba:	8aaa                	mv	s5,a0
    800029bc:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800029be:	fffff097          	auipc	ra,0xfffff
    800029c2:	098080e7          	jalr	152(ra) # 80001a56 <myproc>
    800029c6:	89aa                	mv	s3,a0
  struct thread *t = mythread();
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	114080e7          	jalr	276(ra) # 80001adc <mythread>
    800029d0:	892a                	mv	s2,a0
  struct thread *nt;

  acquire(&p->lock);
    800029d2:	854e                	mv	a0,s3
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	204080e7          	jalr	516(ra) # 80000bd8 <acquire>
  
  nt = allocthread(p);
    800029dc:	854e                	mv	a0,s3
    800029de:	fffff097          	auipc	ra,0xfffff
    800029e2:	1ca080e7          	jalr	458(ra) # 80001ba8 <allocthread>
  if(nt == 0){
    800029e6:	c125                	beqz	a0,80002a46 <kthread_create+0x9e>
    800029e8:	84aa                	mv	s1,a0
    release(&p->lock);
    return 0;
  }

  *(nt->trapframe) = *(t->trapframe);
    800029ea:	01893683          	ld	a3,24(s2)
    800029ee:	87b6                	mv	a5,a3
    800029f0:	6d18                	ld	a4,24(a0)
    800029f2:	12068693          	addi	a3,a3,288
    800029f6:	0007b803          	ld	a6,0(a5)
    800029fa:	6788                	ld	a0,8(a5)
    800029fc:	6b8c                	ld	a1,16(a5)
    800029fe:	6f90                	ld	a2,24(a5)
    80002a00:	01073023          	sd	a6,0(a4)
    80002a04:	e708                	sd	a0,8(a4)
    80002a06:	eb0c                	sd	a1,16(a4)
    80002a08:	ef10                	sd	a2,24(a4)
    80002a0a:	02078793          	addi	a5,a5,32
    80002a0e:	02070713          	addi	a4,a4,32
    80002a12:	fed792e3          	bne	a5,a3,800029f6 <kthread_create+0x4e>
  nt->trapframe->epc = start_func;  // initial program counter = start_func
    80002a16:	6c9c                	ld	a5,24(s1)
    80002a18:	0157bc23          	sd	s5,24(a5)
  nt->trapframe->sp = stack+MAX_STACK_SIZE; // initial stack pointer
    80002a1c:	6c9c                	ld	a5,24(s1)
    80002a1e:	190a0593          	addi	a1,s4,400
    80002a22:	fb8c                	sd	a1,48(a5)
  nt->state = RUNNABLE;
    80002a24:	478d                	li	a5,3
    80002a26:	c0dc                	sw	a5,4(s1)

  release(&p->lock);
    80002a28:	854e                	mv	a0,s3
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	27a080e7          	jalr	634(ra) # 80000ca4 <release>
  return nt->id;
    80002a32:	4088                	lw	a0,0(s1)

}
    80002a34:	70e2                	ld	ra,56(sp)
    80002a36:	7442                	ld	s0,48(sp)
    80002a38:	74a2                	ld	s1,40(sp)
    80002a3a:	7902                	ld	s2,32(sp)
    80002a3c:	69e2                	ld	s3,24(sp)
    80002a3e:	6a42                	ld	s4,16(sp)
    80002a40:	6aa2                	ld	s5,8(sp)
    80002a42:	6121                	addi	sp,sp,64
    80002a44:	8082                	ret
    release(&p->lock);
    80002a46:	854e                	mv	a0,s3
    80002a48:	ffffe097          	auipc	ra,0xffffe
    80002a4c:	25c080e7          	jalr	604(ra) # 80000ca4 <release>
    return 0;
    80002a50:	4501                	li	a0,0
    80002a52:	b7cd                	j	80002a34 <kthread_create+0x8c>

0000000080002a54 <kthread_id>:

//task3
int kthread_id(){
    80002a54:	1141                	addi	sp,sp,-16
    80002a56:	e406                	sd	ra,8(sp)
    80002a58:	e022                	sd	s0,0(sp)
    80002a5a:	0800                	addi	s0,sp,16
  return mythread()->id;
    80002a5c:	fffff097          	auipc	ra,0xfffff
    80002a60:	080080e7          	jalr	128(ra) # 80001adc <mythread>
}
    80002a64:	4108                	lw	a0,0(a0)
    80002a66:	60a2                	ld	ra,8(sp)
    80002a68:	6402                	ld	s0,0(sp)
    80002a6a:	0141                	addi	sp,sp,16
    80002a6c:	8082                	ret

0000000080002a6e <kthread_exit>:

//task3
void kthread_exit(int status){
    80002a6e:	7179                	addi	sp,sp,-48
    80002a70:	f406                	sd	ra,40(sp)
    80002a72:	f022                	sd	s0,32(sp)
    80002a74:	ec26                	sd	s1,24(sp)
    80002a76:	e84a                	sd	s2,16(sp)
    80002a78:	e44e                	sd	s3,8(sp)
    80002a7a:	1800                	addi	s0,sp,48
    80002a7c:	892a                	mv	s2,a0
  struct thread *myt = mythread();
    80002a7e:	fffff097          	auipc	ra,0xfffff
    80002a82:	05e080e7          	jalr	94(ra) # 80001adc <mythread>
    80002a86:	84aa                	mv	s1,a0
  struct proc *p = myt->tproc;
    80002a88:	00853983          	ld	s3,8(a0)
  struct thread *t;
  int running_threads = 0;
  acquire(&p->lock);
    80002a8c:	854e                	mv	a0,s3
    80002a8e:	ffffe097          	auipc	ra,0xffffe
    80002a92:	14a080e7          	jalr	330(ra) # 80000bd8 <acquire>

  myt->state = ZOMBIE;
    80002a96:	4795                	li	a5,5
    80002a98:	c0dc                	sw	a5,4(s1)
  myt->xstate = status;
    80002a9a:	0924ae23          	sw	s2,156(s1)
  for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80002a9e:	27898793          	addi	a5,s3,632
    80002aa2:	77898693          	addi	a3,s3,1912
  int running_threads = 0;
    80002aa6:	4601                	li	a2,0
    if(t->state != UNUSED && t->state != ZOMBIE){
    80002aa8:	4595                	li	a1,5
    80002aaa:	a029                	j	80002ab4 <kthread_exit+0x46>
  for(t = p->threads; t < &p->threads[NTHREAD]; t++){
    80002aac:	0a078793          	addi	a5,a5,160
    80002ab0:	00f68863          	beq	a3,a5,80002ac0 <kthread_exit+0x52>
    if(t->state != UNUSED && t->state != ZOMBIE){
    80002ab4:	43d8                	lw	a4,4(a5)
    80002ab6:	db7d                	beqz	a4,80002aac <kthread_exit+0x3e>
    80002ab8:	feb70ae3          	beq	a4,a1,80002aac <kthread_exit+0x3e>
      running_threads++;
    80002abc:	2605                	addiw	a2,a2,1
    80002abe:	b7fd                	j	80002aac <kthread_exit+0x3e>
    }
  }
  if(!running_threads){
    80002ac0:	c215                	beqz	a2,80002ae4 <kthread_exit+0x76>
    release(&p->lock);
    exit(status);
  }

  wakeup(myt);
    80002ac2:	8526                	mv	a0,s1
    80002ac4:	00000097          	auipc	ra,0x0
    80002ac8:	a30080e7          	jalr	-1488(ra) # 800024f4 <wakeup>
  sched();
    80002acc:	fffff097          	auipc	ra,0xfffff
    80002ad0:	744080e7          	jalr	1860(ra) # 80002210 <sched>
  panic("thread zombie exit");
    80002ad4:	00005517          	auipc	a0,0x5
    80002ad8:	7c450513          	addi	a0,a0,1988 # 80008298 <digits+0x258>
    80002adc:	ffffe097          	auipc	ra,0xffffe
    80002ae0:	a5c080e7          	jalr	-1444(ra) # 80000538 <panic>
    release(&p->lock);
    80002ae4:	854e                	mv	a0,s3
    80002ae6:	ffffe097          	auipc	ra,0xffffe
    80002aea:	1be080e7          	jalr	446(ra) # 80000ca4 <release>
    exit(status);
    80002aee:	854a                	mv	a0,s2
    80002af0:	00000097          	auipc	ra,0x0
    80002af4:	b0e080e7          	jalr	-1266(ra) # 800025fe <exit>

0000000080002af8 <kthread_join>:
}

//task3
int kthread_join(int thread_id, uint64 addr){
    80002af8:	711d                	addi	sp,sp,-96
    80002afa:	ec86                	sd	ra,88(sp)
    80002afc:	e8a2                	sd	s0,80(sp)
    80002afe:	e4a6                	sd	s1,72(sp)
    80002b00:	e0ca                	sd	s2,64(sp)
    80002b02:	fc4e                	sd	s3,56(sp)
    80002b04:	f852                	sd	s4,48(sp)
    80002b06:	f456                	sd	s5,40(sp)
    80002b08:	f05a                	sd	s6,32(sp)
    80002b0a:	ec5e                	sd	s7,24(sp)
    80002b0c:	e862                	sd	s8,16(sp)
    80002b0e:	e466                	sd	s9,8(sp)
    80002b10:	e06a                	sd	s10,0(sp)
    80002b12:	1080                	addi	s0,sp,96
    80002b14:	892a                	mv	s2,a0
    80002b16:	8aae                	mv	s5,a1
  struct thread *nt, *found_t;
  int found;
  struct proc *p = mythread()->tproc;
    80002b18:	fffff097          	auipc	ra,0xfffff
    80002b1c:	fc4080e7          	jalr	-60(ra) # 80001adc <mythread>
    80002b20:	00853a03          	ld	s4,8(a0)

  acquire(&wait_lock);
    80002b24:	0000e517          	auipc	a0,0xe
    80002b28:	7ac50513          	addi	a0,a0,1964 # 800112d0 <wait_lock>
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	0ac080e7          	jalr	172(ra) # 80000bd8 <acquire>
    80002b34:	778a0993          	addi	s3,s4,1912

  for(;;){
    // Scan through table looking for exited children.
    found = 0;
    80002b38:	4c01                	li	s8,0
        // make sure the child isn't still in exit() or swtch().
        acquire(&p->lock);

        found = 1;
        found_t = nt;
        if(nt->state == ZOMBIE){
    80002b3a:	4b15                	li	s6,5
        found = 1;
    80002b3c:	4b85                	li	s7,1
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(found_t, &wait_lock);  //DOC: wait-sleep
    80002b3e:	0000ed17          	auipc	s10,0xe
    80002b42:	792d0d13          	addi	s10,s10,1938 # 800112d0 <wait_lock>
    for(nt = p->threads; nt < &p->threads[NTHREAD]; nt++){
    80002b46:	278a0493          	addi	s1,s4,632
    found = 0;
    80002b4a:	8762                	mv	a4,s8
    80002b4c:	a8ad                	j	80002bc6 <kthread_join+0xce>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&nt->xstate,
    80002b4e:	000a8e63          	beqz	s5,80002b6a <kthread_join+0x72>
    80002b52:	4691                	li	a3,4
    80002b54:	09c48613          	addi	a2,s1,156
    80002b58:	85d6                	mv	a1,s5
    80002b5a:	050a3503          	ld	a0,80(s4)
    80002b5e:	fffff097          	auipc	ra,0xfffff
    80002b62:	b0e080e7          	jalr	-1266(ra) # 8000166c <copyout>
    80002b66:	02054d63          	bltz	a0,80002ba0 <kthread_join+0xa8>
  t->id = 0;
    80002b6a:	0004a023          	sw	zero,0(s1)
  t->tproc = 0;
    80002b6e:	0004b423          	sd	zero,8(s1)
  t->chan = 0;
    80002b72:	0804b823          	sd	zero,144(s1)
  t->killed = 0;
    80002b76:	0804ac23          	sw	zero,152(s1)
  t->xstate = 0;
    80002b7a:	0804ae23          	sw	zero,156(s1)
  t->state = UNUSED;
    80002b7e:	0004a223          	sw	zero,4(s1)
          release(&p->lock);
    80002b82:	8552                	mv	a0,s4
    80002b84:	ffffe097          	auipc	ra,0xffffe
    80002b88:	120080e7          	jalr	288(ra) # 80000ca4 <release>
          release(&wait_lock);
    80002b8c:	0000e517          	auipc	a0,0xe
    80002b90:	74450513          	addi	a0,a0,1860 # 800112d0 <wait_lock>
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	110080e7          	jalr	272(ra) # 80000ca4 <release>
          return 0;
    80002b9c:	4501                	li	a0,0
    80002b9e:	a885                	j	80002c0e <kthread_join+0x116>
            release(&p->lock);
    80002ba0:	8552                	mv	a0,s4
    80002ba2:	ffffe097          	auipc	ra,0xffffe
    80002ba6:	102080e7          	jalr	258(ra) # 80000ca4 <release>
            release(&wait_lock);
    80002baa:	0000e517          	auipc	a0,0xe
    80002bae:	72650513          	addi	a0,a0,1830 # 800112d0 <wait_lock>
    80002bb2:	ffffe097          	auipc	ra,0xffffe
    80002bb6:	0f2080e7          	jalr	242(ra) # 80000ca4 <release>
            return -1;
    80002bba:	557d                	li	a0,-1
    80002bbc:	a889                	j	80002c0e <kthread_join+0x116>
    for(nt = p->threads; nt < &p->threads[NTHREAD]; nt++){
    80002bbe:	0a048493          	addi	s1,s1,160
    80002bc2:	03348563          	beq	s1,s3,80002bec <kthread_join+0xf4>
      if(nt->id == thread_id){
    80002bc6:	409c                	lw	a5,0(s1)
    80002bc8:	ff279be3          	bne	a5,s2,80002bbe <kthread_join+0xc6>
        acquire(&p->lock);
    80002bcc:	8552                	mv	a0,s4
    80002bce:	ffffe097          	auipc	ra,0xffffe
    80002bd2:	00a080e7          	jalr	10(ra) # 80000bd8 <acquire>
        if(nt->state == ZOMBIE){
    80002bd6:	40dc                	lw	a5,4(s1)
    80002bd8:	f7678be3          	beq	a5,s6,80002b4e <kthread_join+0x56>
        release(&p->lock);
    80002bdc:	8552                	mv	a0,s4
    80002bde:	ffffe097          	auipc	ra,0xffffe
    80002be2:	0c6080e7          	jalr	198(ra) # 80000ca4 <release>
    80002be6:	8ca6                	mv	s9,s1
        found = 1;
    80002be8:	875e                	mv	a4,s7
    80002bea:	bfd1                	j	80002bbe <kthread_join+0xc6>
    if(!found || mythread()->killed){
    80002bec:	cb01                	beqz	a4,80002bfc <kthread_join+0x104>
    80002bee:	fffff097          	auipc	ra,0xfffff
    80002bf2:	eee080e7          	jalr	-274(ra) # 80001adc <mythread>
    80002bf6:	09852783          	lw	a5,152(a0)
    80002bfa:	cb85                	beqz	a5,80002c2a <kthread_join+0x132>
      release(&wait_lock);
    80002bfc:	0000e517          	auipc	a0,0xe
    80002c00:	6d450513          	addi	a0,a0,1748 # 800112d0 <wait_lock>
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	0a0080e7          	jalr	160(ra) # 80000ca4 <release>
      return -1;
    80002c0c:	557d                	li	a0,-1
  }
}
    80002c0e:	60e6                	ld	ra,88(sp)
    80002c10:	6446                	ld	s0,80(sp)
    80002c12:	64a6                	ld	s1,72(sp)
    80002c14:	6906                	ld	s2,64(sp)
    80002c16:	79e2                	ld	s3,56(sp)
    80002c18:	7a42                	ld	s4,48(sp)
    80002c1a:	7aa2                	ld	s5,40(sp)
    80002c1c:	7b02                	ld	s6,32(sp)
    80002c1e:	6be2                	ld	s7,24(sp)
    80002c20:	6c42                	ld	s8,16(sp)
    80002c22:	6ca2                	ld	s9,8(sp)
    80002c24:	6d02                	ld	s10,0(sp)
    80002c26:	6125                	addi	sp,sp,96
    80002c28:	8082                	ret
    sleep(found_t, &wait_lock);  //DOC: wait-sleep
    80002c2a:	85ea                	mv	a1,s10
    80002c2c:	8566                	mv	a0,s9
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	730080e7          	jalr	1840(ra) # 8000235e <sleep>
    found = 0;
    80002c36:	bf01                	j	80002b46 <kthread_join+0x4e>

0000000080002c38 <swtch>:
    80002c38:	00153023          	sd	ra,0(a0)
    80002c3c:	00253423          	sd	sp,8(a0)
    80002c40:	e900                	sd	s0,16(a0)
    80002c42:	ed04                	sd	s1,24(a0)
    80002c44:	03253023          	sd	s2,32(a0)
    80002c48:	03353423          	sd	s3,40(a0)
    80002c4c:	03453823          	sd	s4,48(a0)
    80002c50:	03553c23          	sd	s5,56(a0)
    80002c54:	05653023          	sd	s6,64(a0)
    80002c58:	05753423          	sd	s7,72(a0)
    80002c5c:	05853823          	sd	s8,80(a0)
    80002c60:	05953c23          	sd	s9,88(a0)
    80002c64:	07a53023          	sd	s10,96(a0)
    80002c68:	07b53423          	sd	s11,104(a0)
    80002c6c:	0005b083          	ld	ra,0(a1)
    80002c70:	0085b103          	ld	sp,8(a1)
    80002c74:	6980                	ld	s0,16(a1)
    80002c76:	6d84                	ld	s1,24(a1)
    80002c78:	0205b903          	ld	s2,32(a1)
    80002c7c:	0285b983          	ld	s3,40(a1)
    80002c80:	0305ba03          	ld	s4,48(a1)
    80002c84:	0385ba83          	ld	s5,56(a1)
    80002c88:	0405bb03          	ld	s6,64(a1)
    80002c8c:	0485bb83          	ld	s7,72(a1)
    80002c90:	0505bc03          	ld	s8,80(a1)
    80002c94:	0585bc83          	ld	s9,88(a1)
    80002c98:	0605bd03          	ld	s10,96(a1)
    80002c9c:	0685bd83          	ld	s11,104(a1)
    80002ca0:	8082                	ret

0000000080002ca2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002ca2:	1141                	addi	sp,sp,-16
    80002ca4:	e406                	sd	ra,8(sp)
    80002ca6:	e022                	sd	s0,0(sp)
    80002ca8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002caa:	00005597          	auipc	a1,0x5
    80002cae:	65e58593          	addi	a1,a1,1630 # 80008308 <states.0+0x30>
    80002cb2:	0002d517          	auipc	a0,0x2d
    80002cb6:	87650513          	addi	a0,a0,-1930 # 8002f528 <tickslock>
    80002cba:	ffffe097          	auipc	ra,0xffffe
    80002cbe:	e86080e7          	jalr	-378(ra) # 80000b40 <initlock>
}
    80002cc2:	60a2                	ld	ra,8(sp)
    80002cc4:	6402                	ld	s0,0(sp)
    80002cc6:	0141                	addi	sp,sp,16
    80002cc8:	8082                	ret

0000000080002cca <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002cca:	1141                	addi	sp,sp,-16
    80002ccc:	e422                	sd	s0,8(sp)
    80002cce:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cd0:	00003797          	auipc	a5,0x3
    80002cd4:	6e078793          	addi	a5,a5,1760 # 800063b0 <kernelvec>
    80002cd8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002cdc:	6422                	ld	s0,8(sp)
    80002cde:	0141                	addi	sp,sp,16
    80002ce0:	8082                	ret

0000000080002ce2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002ce2:	1101                	addi	sp,sp,-32
    80002ce4:	ec06                	sd	ra,24(sp)
    80002ce6:	e822                	sd	s0,16(sp)
    80002ce8:	e426                	sd	s1,8(sp)
    80002cea:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	d6a080e7          	jalr	-662(ra) # 80001a56 <myproc>
    80002cf4:	84aa                	mv	s1,a0
  struct thread *t = mythread();
    80002cf6:	fffff097          	auipc	ra,0xfffff
    80002cfa:	de6080e7          	jalr	-538(ra) # 80001adc <mythread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cfe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002d02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d04:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002d08:	00004617          	auipc	a2,0x4
    80002d0c:	2f860613          	addi	a2,a2,760 # 80007000 <_trampoline>
    80002d10:	00004697          	auipc	a3,0x4
    80002d14:	2f068693          	addi	a3,a3,752 # 80007000 <_trampoline>
    80002d18:	8e91                	sub	a3,a3,a2
    80002d1a:	040007b7          	lui	a5,0x4000
    80002d1e:	17fd                	addi	a5,a5,-1
    80002d20:	07b2                	slli	a5,a5,0xc
    80002d22:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d24:	10569073          	csrw	stvec,a3
  /*p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()*/

  t->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d28:	6d18                	ld	a4,24(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d2a:	180026f3          	csrr	a3,satp
    80002d2e:	e314                	sd	a3,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    80002d30:	6d18                	ld	a4,24(a0)
    80002d32:	6914                	ld	a3,16(a0)
    80002d34:	6585                	lui	a1,0x1
    80002d36:	96ae                	add	a3,a3,a1
    80002d38:	e714                	sd	a3,8(a4)
  t->trapframe->kernel_trap = (uint64)usertrap;
    80002d3a:	6d18                	ld	a4,24(a0)
    80002d3c:	00000697          	auipc	a3,0x0
    80002d40:	13a68693          	addi	a3,a3,314 # 80002e76 <usertrap>
    80002d44:	eb14                	sd	a3,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002d46:	6d18                	ld	a4,24(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d48:	8692                	mv	a3,tp
    80002d4a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d4c:	100026f3          	csrr	a3,sstatus
  // to get to user space.
  //printf("here2?\n");
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d50:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d54:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d58:	10069073          	csrw	sstatus,a3
  w_sstatus(x);
  //printf("here3?\n");
  // set S Exception Program Counter to the saved user pc.
  w_sepc(t->trapframe->epc);
    80002d5c:	6d18                	ld	a4,24(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d5e:	6f18                	ld	a4,24(a4)
    80002d60:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002d64:	68ac                	ld	a1,80(s1)
    80002d66:	81b1                	srli	a1,a1,0xc
  //printf("here4?\n");
  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002d68:	00004717          	auipc	a4,0x4
    80002d6c:	32870713          	addi	a4,a4,808 # 80007090 <userret>
    80002d70:	8f11                	sub	a4,a4,a2
    80002d72:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002d74:	577d                	li	a4,-1
    80002d76:	177e                	slli	a4,a4,0x3f
    80002d78:	8dd9                	or	a1,a1,a4
    80002d7a:	02000537          	lui	a0,0x2000
    80002d7e:	157d                	addi	a0,a0,-1
    80002d80:	0536                	slli	a0,a0,0xd
    80002d82:	9782                	jalr	a5
  //printf("here5?\n");
}
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	64a2                	ld	s1,8(sp)
    80002d8a:	6105                	addi	sp,sp,32
    80002d8c:	8082                	ret

0000000080002d8e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002d8e:	1101                	addi	sp,sp,-32
    80002d90:	ec06                	sd	ra,24(sp)
    80002d92:	e822                	sd	s0,16(sp)
    80002d94:	e426                	sd	s1,8(sp)
    80002d96:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002d98:	0002c497          	auipc	s1,0x2c
    80002d9c:	79048493          	addi	s1,s1,1936 # 8002f528 <tickslock>
    80002da0:	8526                	mv	a0,s1
    80002da2:	ffffe097          	auipc	ra,0xffffe
    80002da6:	e36080e7          	jalr	-458(ra) # 80000bd8 <acquire>
  ticks++;
    80002daa:	00006517          	auipc	a0,0x6
    80002dae:	28650513          	addi	a0,a0,646 # 80009030 <ticks>
    80002db2:	411c                	lw	a5,0(a0)
    80002db4:	2785                	addiw	a5,a5,1
    80002db6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	73c080e7          	jalr	1852(ra) # 800024f4 <wakeup>
  release(&tickslock);
    80002dc0:	8526                	mv	a0,s1
    80002dc2:	ffffe097          	auipc	ra,0xffffe
    80002dc6:	ee2080e7          	jalr	-286(ra) # 80000ca4 <release>
}
    80002dca:	60e2                	ld	ra,24(sp)
    80002dcc:	6442                	ld	s0,16(sp)
    80002dce:	64a2                	ld	s1,8(sp)
    80002dd0:	6105                	addi	sp,sp,32
    80002dd2:	8082                	ret

0000000080002dd4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002dd4:	1101                	addi	sp,sp,-32
    80002dd6:	ec06                	sd	ra,24(sp)
    80002dd8:	e822                	sd	s0,16(sp)
    80002dda:	e426                	sd	s1,8(sp)
    80002ddc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dde:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002de2:	00074d63          	bltz	a4,80002dfc <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002de6:	57fd                	li	a5,-1
    80002de8:	17fe                	slli	a5,a5,0x3f
    80002dea:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002dec:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002dee:	06f70363          	beq	a4,a5,80002e54 <devintr+0x80>
  }
}
    80002df2:	60e2                	ld	ra,24(sp)
    80002df4:	6442                	ld	s0,16(sp)
    80002df6:	64a2                	ld	s1,8(sp)
    80002df8:	6105                	addi	sp,sp,32
    80002dfa:	8082                	ret
     (scause & 0xff) == 9){
    80002dfc:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002e00:	46a5                	li	a3,9
    80002e02:	fed792e3          	bne	a5,a3,80002de6 <devintr+0x12>
    int irq = plic_claim();
    80002e06:	00003097          	auipc	ra,0x3
    80002e0a:	6b2080e7          	jalr	1714(ra) # 800064b8 <plic_claim>
    80002e0e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002e10:	47a9                	li	a5,10
    80002e12:	02f50763          	beq	a0,a5,80002e40 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002e16:	4785                	li	a5,1
    80002e18:	02f50963          	beq	a0,a5,80002e4a <devintr+0x76>
    return 1;
    80002e1c:	4505                	li	a0,1
    } else if(irq){
    80002e1e:	d8f1                	beqz	s1,80002df2 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002e20:	85a6                	mv	a1,s1
    80002e22:	00005517          	auipc	a0,0x5
    80002e26:	4ee50513          	addi	a0,a0,1262 # 80008310 <states.0+0x38>
    80002e2a:	ffffd097          	auipc	ra,0xffffd
    80002e2e:	758080e7          	jalr	1880(ra) # 80000582 <printf>
      plic_complete(irq);
    80002e32:	8526                	mv	a0,s1
    80002e34:	00003097          	auipc	ra,0x3
    80002e38:	6a8080e7          	jalr	1704(ra) # 800064dc <plic_complete>
    return 1;
    80002e3c:	4505                	li	a0,1
    80002e3e:	bf55                	j	80002df2 <devintr+0x1e>
      uartintr();
    80002e40:	ffffe097          	auipc	ra,0xffffe
    80002e44:	b54080e7          	jalr	-1196(ra) # 80000994 <uartintr>
    80002e48:	b7ed                	j	80002e32 <devintr+0x5e>
      virtio_disk_intr();
    80002e4a:	00004097          	auipc	ra,0x4
    80002e4e:	b24080e7          	jalr	-1244(ra) # 8000696e <virtio_disk_intr>
    80002e52:	b7c5                	j	80002e32 <devintr+0x5e>
    if(cpuid() == 0){
    80002e54:	fffff097          	auipc	ra,0xfffff
    80002e58:	bce080e7          	jalr	-1074(ra) # 80001a22 <cpuid>
    80002e5c:	c901                	beqz	a0,80002e6c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002e5e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002e62:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002e64:	14479073          	csrw	sip,a5
    return 2;
    80002e68:	4509                	li	a0,2
    80002e6a:	b761                	j	80002df2 <devintr+0x1e>
      clockintr();
    80002e6c:	00000097          	auipc	ra,0x0
    80002e70:	f22080e7          	jalr	-222(ra) # 80002d8e <clockintr>
    80002e74:	b7ed                	j	80002e5e <devintr+0x8a>

0000000080002e76 <usertrap>:
{
    80002e76:	7179                	addi	sp,sp,-48
    80002e78:	f406                	sd	ra,40(sp)
    80002e7a:	f022                	sd	s0,32(sp)
    80002e7c:	ec26                	sd	s1,24(sp)
    80002e7e:	e84a                	sd	s2,16(sp)
    80002e80:	e44e                	sd	s3,8(sp)
    80002e82:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e84:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002e88:	1007f793          	andi	a5,a5,256
    80002e8c:	e3d9                	bnez	a5,80002f12 <usertrap+0x9c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e8e:	00003797          	auipc	a5,0x3
    80002e92:	52278793          	addi	a5,a5,1314 # 800063b0 <kernelvec>
    80002e96:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e9a:	fffff097          	auipc	ra,0xfffff
    80002e9e:	bbc080e7          	jalr	-1092(ra) # 80001a56 <myproc>
    80002ea2:	892a                	mv	s2,a0
  struct thread *t = mythread();
    80002ea4:	fffff097          	auipc	ra,0xfffff
    80002ea8:	c38080e7          	jalr	-968(ra) # 80001adc <mythread>
    80002eac:	84aa                	mv	s1,a0
  t->trapframe->epc = r_sepc();
    80002eae:	6d1c                	ld	a5,24(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002eb0:	14102773          	csrr	a4,sepc
    80002eb4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002eb6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002eba:	47a1                	li	a5,8
    80002ebc:	06f71f63          	bne	a4,a5,80002f3a <usertrap+0xc4>
    if(p->killed)
    80002ec0:	02892783          	lw	a5,40(s2)
    80002ec4:	efb9                	bnez	a5,80002f22 <usertrap+0xac>
    if(t->killed)
    80002ec6:	0984a783          	lw	a5,152(s1)
    80002eca:	e3b5                	bnez	a5,80002f2e <usertrap+0xb8>
    t->trapframe->epc += 4;
    80002ecc:	6c98                	ld	a4,24(s1)
    80002ece:	6f1c                	ld	a5,24(a4)
    80002ed0:	0791                	addi	a5,a5,4
    80002ed2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ed4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ed8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002edc:	10079073          	csrw	sstatus,a5
    syscall();
    80002ee0:	00000097          	auipc	ra,0x0
    80002ee4:	30c080e7          	jalr	780(ra) # 800031ec <syscall>
  int which_dev = 0;
    80002ee8:	4981                	li	s3,0
  if(p->killed)
    80002eea:	02892783          	lw	a5,40(s2)
    80002eee:	e3dd                	bnez	a5,80002f94 <usertrap+0x11e>
  if(t->killed)
    80002ef0:	0984a783          	lw	a5,152(s1)
    80002ef4:	ebd1                	bnez	a5,80002f88 <usertrap+0x112>
  if(which_dev == 2)
    80002ef6:	4789                	li	a5,2
    80002ef8:	0af98463          	beq	s3,a5,80002fa0 <usertrap+0x12a>
  usertrapret();
    80002efc:	00000097          	auipc	ra,0x0
    80002f00:	de6080e7          	jalr	-538(ra) # 80002ce2 <usertrapret>
}
    80002f04:	70a2                	ld	ra,40(sp)
    80002f06:	7402                	ld	s0,32(sp)
    80002f08:	64e2                	ld	s1,24(sp)
    80002f0a:	6942                	ld	s2,16(sp)
    80002f0c:	69a2                	ld	s3,8(sp)
    80002f0e:	6145                	addi	sp,sp,48
    80002f10:	8082                	ret
    panic("usertrap: not from user mode");
    80002f12:	00005517          	auipc	a0,0x5
    80002f16:	41e50513          	addi	a0,a0,1054 # 80008330 <states.0+0x58>
    80002f1a:	ffffd097          	auipc	ra,0xffffd
    80002f1e:	61e080e7          	jalr	1566(ra) # 80000538 <panic>
      exit(-1);
    80002f22:	557d                	li	a0,-1
    80002f24:	fffff097          	auipc	ra,0xfffff
    80002f28:	6da080e7          	jalr	1754(ra) # 800025fe <exit>
    80002f2c:	bf69                	j	80002ec6 <usertrap+0x50>
      kthread_exit(-1);
    80002f2e:	557d                	li	a0,-1
    80002f30:	00000097          	auipc	ra,0x0
    80002f34:	b3e080e7          	jalr	-1218(ra) # 80002a6e <kthread_exit>
    80002f38:	bf51                	j	80002ecc <usertrap+0x56>
  } else if((which_dev = devintr()) != 0){
    80002f3a:	00000097          	auipc	ra,0x0
    80002f3e:	e9a080e7          	jalr	-358(ra) # 80002dd4 <devintr>
    80002f42:	89aa                	mv	s3,a0
    80002f44:	f15d                	bnez	a0,80002eea <usertrap+0x74>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f46:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002f4a:	03092603          	lw	a2,48(s2)
    80002f4e:	00005517          	auipc	a0,0x5
    80002f52:	40250513          	addi	a0,a0,1026 # 80008350 <states.0+0x78>
    80002f56:	ffffd097          	auipc	ra,0xffffd
    80002f5a:	62c080e7          	jalr	1580(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f5e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f62:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f66:	00005517          	auipc	a0,0x5
    80002f6a:	41a50513          	addi	a0,a0,1050 # 80008380 <states.0+0xa8>
    80002f6e:	ffffd097          	auipc	ra,0xffffd
    80002f72:	614080e7          	jalr	1556(ra) # 80000582 <printf>
    p->killed = 1;
    80002f76:	4785                	li	a5,1
    80002f78:	02f92423          	sw	a5,40(s2)
    t->killed = 1;
    80002f7c:	08f4ac23          	sw	a5,152(s1)
  if(p->killed)
    80002f80:	02892783          	lw	a5,40(s2)
    80002f84:	eb81                	bnez	a5,80002f94 <usertrap+0x11e>
  } else if((which_dev = devintr()) != 0){
    80002f86:	89be                	mv	s3,a5
    kthread_exit(-1);
    80002f88:	557d                	li	a0,-1
    80002f8a:	00000097          	auipc	ra,0x0
    80002f8e:	ae4080e7          	jalr	-1308(ra) # 80002a6e <kthread_exit>
    80002f92:	b795                	j	80002ef6 <usertrap+0x80>
    exit(-1);
    80002f94:	557d                	li	a0,-1
    80002f96:	fffff097          	auipc	ra,0xfffff
    80002f9a:	668080e7          	jalr	1640(ra) # 800025fe <exit>
    80002f9e:	bf89                	j	80002ef0 <usertrap+0x7a>
    yield();
    80002fa0:	fffff097          	auipc	ra,0xfffff
    80002fa4:	372080e7          	jalr	882(ra) # 80002312 <yield>
    80002fa8:	bf91                	j	80002efc <usertrap+0x86>

0000000080002faa <kerneltrap>:
{
    80002faa:	7179                	addi	sp,sp,-48
    80002fac:	f406                	sd	ra,40(sp)
    80002fae:	f022                	sd	s0,32(sp)
    80002fb0:	ec26                	sd	s1,24(sp)
    80002fb2:	e84a                	sd	s2,16(sp)
    80002fb4:	e44e                	sd	s3,8(sp)
    80002fb6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fb8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fbc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fc0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002fc4:	1004f793          	andi	a5,s1,256
    80002fc8:	cb85                	beqz	a5,80002ff8 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fca:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002fce:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002fd0:	ef85                	bnez	a5,80003008 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002fd2:	00000097          	auipc	ra,0x0
    80002fd6:	e02080e7          	jalr	-510(ra) # 80002dd4 <devintr>
    80002fda:	cd1d                	beqz	a0,80003018 <kerneltrap+0x6e>
  if(which_dev == 2 && mythread() != 0 && mythread()->state == RUNNING)
    80002fdc:	4789                	li	a5,2
    80002fde:	06f50a63          	beq	a0,a5,80003052 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002fe2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fe6:	10049073          	csrw	sstatus,s1
}
    80002fea:	70a2                	ld	ra,40(sp)
    80002fec:	7402                	ld	s0,32(sp)
    80002fee:	64e2                	ld	s1,24(sp)
    80002ff0:	6942                	ld	s2,16(sp)
    80002ff2:	69a2                	ld	s3,8(sp)
    80002ff4:	6145                	addi	sp,sp,48
    80002ff6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ff8:	00005517          	auipc	a0,0x5
    80002ffc:	3a850513          	addi	a0,a0,936 # 800083a0 <states.0+0xc8>
    80003000:	ffffd097          	auipc	ra,0xffffd
    80003004:	538080e7          	jalr	1336(ra) # 80000538 <panic>
    panic("kerneltrap: interrupts enabled");
    80003008:	00005517          	auipc	a0,0x5
    8000300c:	3c050513          	addi	a0,a0,960 # 800083c8 <states.0+0xf0>
    80003010:	ffffd097          	auipc	ra,0xffffd
    80003014:	528080e7          	jalr	1320(ra) # 80000538 <panic>
    printf("scause %p\n", scause);
    80003018:	85ce                	mv	a1,s3
    8000301a:	00005517          	auipc	a0,0x5
    8000301e:	3ce50513          	addi	a0,a0,974 # 800083e8 <states.0+0x110>
    80003022:	ffffd097          	auipc	ra,0xffffd
    80003026:	560080e7          	jalr	1376(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000302a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000302e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003032:	00005517          	auipc	a0,0x5
    80003036:	3c650513          	addi	a0,a0,966 # 800083f8 <states.0+0x120>
    8000303a:	ffffd097          	auipc	ra,0xffffd
    8000303e:	548080e7          	jalr	1352(ra) # 80000582 <printf>
    panic("kerneltrap");
    80003042:	00005517          	auipc	a0,0x5
    80003046:	3ce50513          	addi	a0,a0,974 # 80008410 <states.0+0x138>
    8000304a:	ffffd097          	auipc	ra,0xffffd
    8000304e:	4ee080e7          	jalr	1262(ra) # 80000538 <panic>
  if(which_dev == 2 && mythread() != 0 && mythread()->state == RUNNING)
    80003052:	fffff097          	auipc	ra,0xfffff
    80003056:	a8a080e7          	jalr	-1398(ra) # 80001adc <mythread>
    8000305a:	d541                	beqz	a0,80002fe2 <kerneltrap+0x38>
    8000305c:	fffff097          	auipc	ra,0xfffff
    80003060:	a80080e7          	jalr	-1408(ra) # 80001adc <mythread>
    80003064:	4158                	lw	a4,4(a0)
    80003066:	4791                	li	a5,4
    80003068:	f6f71de3          	bne	a4,a5,80002fe2 <kerneltrap+0x38>
    yield();
    8000306c:	fffff097          	auipc	ra,0xfffff
    80003070:	2a6080e7          	jalr	678(ra) # 80002312 <yield>
    80003074:	b7bd                	j	80002fe2 <kerneltrap+0x38>

0000000080003076 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003076:	1101                	addi	sp,sp,-32
    80003078:	ec06                	sd	ra,24(sp)
    8000307a:	e822                	sd	s0,16(sp)
    8000307c:	e426                	sd	s1,8(sp)
    8000307e:	1000                	addi	s0,sp,32
    80003080:	84aa                	mv	s1,a0
  struct thread *t = mythread();
    80003082:	fffff097          	auipc	ra,0xfffff
    80003086:	a5a080e7          	jalr	-1446(ra) # 80001adc <mythread>
  switch (n) {
    8000308a:	4795                	li	a5,5
    8000308c:	0497e163          	bltu	a5,s1,800030ce <argraw+0x58>
    80003090:	048a                	slli	s1,s1,0x2
    80003092:	00005717          	auipc	a4,0x5
    80003096:	3be70713          	addi	a4,a4,958 # 80008450 <states.0+0x178>
    8000309a:	94ba                	add	s1,s1,a4
    8000309c:	409c                	lw	a5,0(s1)
    8000309e:	97ba                	add	a5,a5,a4
    800030a0:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    800030a2:	6d1c                	ld	a5,24(a0)
    800030a4:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800030a6:	60e2                	ld	ra,24(sp)
    800030a8:	6442                	ld	s0,16(sp)
    800030aa:	64a2                	ld	s1,8(sp)
    800030ac:	6105                	addi	sp,sp,32
    800030ae:	8082                	ret
    return t->trapframe->a1;
    800030b0:	6d1c                	ld	a5,24(a0)
    800030b2:	7fa8                	ld	a0,120(a5)
    800030b4:	bfcd                	j	800030a6 <argraw+0x30>
    return t->trapframe->a2;
    800030b6:	6d1c                	ld	a5,24(a0)
    800030b8:	63c8                	ld	a0,128(a5)
    800030ba:	b7f5                	j	800030a6 <argraw+0x30>
    return t->trapframe->a3;
    800030bc:	6d1c                	ld	a5,24(a0)
    800030be:	67c8                	ld	a0,136(a5)
    800030c0:	b7dd                	j	800030a6 <argraw+0x30>
    return t->trapframe->a4;
    800030c2:	6d1c                	ld	a5,24(a0)
    800030c4:	6bc8                	ld	a0,144(a5)
    800030c6:	b7c5                	j	800030a6 <argraw+0x30>
    return t->trapframe->a5;
    800030c8:	6d1c                	ld	a5,24(a0)
    800030ca:	6fc8                	ld	a0,152(a5)
    800030cc:	bfe9                	j	800030a6 <argraw+0x30>
  panic("argraw");
    800030ce:	00005517          	auipc	a0,0x5
    800030d2:	35250513          	addi	a0,a0,850 # 80008420 <states.0+0x148>
    800030d6:	ffffd097          	auipc	ra,0xffffd
    800030da:	462080e7          	jalr	1122(ra) # 80000538 <panic>

00000000800030de <fetchaddr>:
{
    800030de:	1101                	addi	sp,sp,-32
    800030e0:	ec06                	sd	ra,24(sp)
    800030e2:	e822                	sd	s0,16(sp)
    800030e4:	e426                	sd	s1,8(sp)
    800030e6:	e04a                	sd	s2,0(sp)
    800030e8:	1000                	addi	s0,sp,32
    800030ea:	84aa                	mv	s1,a0
    800030ec:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800030ee:	fffff097          	auipc	ra,0xfffff
    800030f2:	968080e7          	jalr	-1688(ra) # 80001a56 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800030f6:	653c                	ld	a5,72(a0)
    800030f8:	02f4f863          	bgeu	s1,a5,80003128 <fetchaddr+0x4a>
    800030fc:	00848713          	addi	a4,s1,8
    80003100:	02e7e663          	bltu	a5,a4,8000312c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003104:	46a1                	li	a3,8
    80003106:	8626                	mv	a2,s1
    80003108:	85ca                	mv	a1,s2
    8000310a:	6928                	ld	a0,80(a0)
    8000310c:	ffffe097          	auipc	ra,0xffffe
    80003110:	5ec080e7          	jalr	1516(ra) # 800016f8 <copyin>
    80003114:	00a03533          	snez	a0,a0
    80003118:	40a00533          	neg	a0,a0
}
    8000311c:	60e2                	ld	ra,24(sp)
    8000311e:	6442                	ld	s0,16(sp)
    80003120:	64a2                	ld	s1,8(sp)
    80003122:	6902                	ld	s2,0(sp)
    80003124:	6105                	addi	sp,sp,32
    80003126:	8082                	ret
    return -1;
    80003128:	557d                	li	a0,-1
    8000312a:	bfcd                	j	8000311c <fetchaddr+0x3e>
    8000312c:	557d                	li	a0,-1
    8000312e:	b7fd                	j	8000311c <fetchaddr+0x3e>

0000000080003130 <fetchstr>:
{
    80003130:	7179                	addi	sp,sp,-48
    80003132:	f406                	sd	ra,40(sp)
    80003134:	f022                	sd	s0,32(sp)
    80003136:	ec26                	sd	s1,24(sp)
    80003138:	e84a                	sd	s2,16(sp)
    8000313a:	e44e                	sd	s3,8(sp)
    8000313c:	1800                	addi	s0,sp,48
    8000313e:	892a                	mv	s2,a0
    80003140:	84ae                	mv	s1,a1
    80003142:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003144:	fffff097          	auipc	ra,0xfffff
    80003148:	912080e7          	jalr	-1774(ra) # 80001a56 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    8000314c:	86ce                	mv	a3,s3
    8000314e:	864a                	mv	a2,s2
    80003150:	85a6                	mv	a1,s1
    80003152:	6928                	ld	a0,80(a0)
    80003154:	ffffe097          	auipc	ra,0xffffe
    80003158:	632080e7          	jalr	1586(ra) # 80001786 <copyinstr>
  if(err < 0)
    8000315c:	00054763          	bltz	a0,8000316a <fetchstr+0x3a>
  return strlen(buf);
    80003160:	8526                	mv	a0,s1
    80003162:	ffffe097          	auipc	ra,0xffffe
    80003166:	d0e080e7          	jalr	-754(ra) # 80000e70 <strlen>
}
    8000316a:	70a2                	ld	ra,40(sp)
    8000316c:	7402                	ld	s0,32(sp)
    8000316e:	64e2                	ld	s1,24(sp)
    80003170:	6942                	ld	s2,16(sp)
    80003172:	69a2                	ld	s3,8(sp)
    80003174:	6145                	addi	sp,sp,48
    80003176:	8082                	ret

0000000080003178 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003178:	1101                	addi	sp,sp,-32
    8000317a:	ec06                	sd	ra,24(sp)
    8000317c:	e822                	sd	s0,16(sp)
    8000317e:	e426                	sd	s1,8(sp)
    80003180:	1000                	addi	s0,sp,32
    80003182:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003184:	00000097          	auipc	ra,0x0
    80003188:	ef2080e7          	jalr	-270(ra) # 80003076 <argraw>
    8000318c:	c088                	sw	a0,0(s1)
  return 0;
}
    8000318e:	4501                	li	a0,0
    80003190:	60e2                	ld	ra,24(sp)
    80003192:	6442                	ld	s0,16(sp)
    80003194:	64a2                	ld	s1,8(sp)
    80003196:	6105                	addi	sp,sp,32
    80003198:	8082                	ret

000000008000319a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000319a:	1101                	addi	sp,sp,-32
    8000319c:	ec06                	sd	ra,24(sp)
    8000319e:	e822                	sd	s0,16(sp)
    800031a0:	e426                	sd	s1,8(sp)
    800031a2:	1000                	addi	s0,sp,32
    800031a4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800031a6:	00000097          	auipc	ra,0x0
    800031aa:	ed0080e7          	jalr	-304(ra) # 80003076 <argraw>
    800031ae:	e088                	sd	a0,0(s1)
  return 0;
}
    800031b0:	4501                	li	a0,0
    800031b2:	60e2                	ld	ra,24(sp)
    800031b4:	6442                	ld	s0,16(sp)
    800031b6:	64a2                	ld	s1,8(sp)
    800031b8:	6105                	addi	sp,sp,32
    800031ba:	8082                	ret

00000000800031bc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800031bc:	1101                	addi	sp,sp,-32
    800031be:	ec06                	sd	ra,24(sp)
    800031c0:	e822                	sd	s0,16(sp)
    800031c2:	e426                	sd	s1,8(sp)
    800031c4:	e04a                	sd	s2,0(sp)
    800031c6:	1000                	addi	s0,sp,32
    800031c8:	84ae                	mv	s1,a1
    800031ca:	8932                	mv	s2,a2
  *ip = argraw(n);
    800031cc:	00000097          	auipc	ra,0x0
    800031d0:	eaa080e7          	jalr	-342(ra) # 80003076 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800031d4:	864a                	mv	a2,s2
    800031d6:	85a6                	mv	a1,s1
    800031d8:	00000097          	auipc	ra,0x0
    800031dc:	f58080e7          	jalr	-168(ra) # 80003130 <fetchstr>
}
    800031e0:	60e2                	ld	ra,24(sp)
    800031e2:	6442                	ld	s0,16(sp)
    800031e4:	64a2                	ld	s1,8(sp)
    800031e6:	6902                	ld	s2,0(sp)
    800031e8:	6105                	addi	sp,sp,32
    800031ea:	8082                	ret

00000000800031ec <syscall>:
[SYS_kthread_join] sys_kthread_join,
};

void
syscall(void)
{
    800031ec:	1101                	addi	sp,sp,-32
    800031ee:	ec06                	sd	ra,24(sp)
    800031f0:	e822                	sd	s0,16(sp)
    800031f2:	e426                	sd	s1,8(sp)
    800031f4:	e04a                	sd	s2,0(sp)
    800031f6:	1000                	addi	s0,sp,32
  int num;
  struct thread *t = mythread();
    800031f8:	fffff097          	auipc	ra,0xfffff
    800031fc:	8e4080e7          	jalr	-1820(ra) # 80001adc <mythread>
    80003200:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    80003202:	01853903          	ld	s2,24(a0)
    80003206:	0a893783          	ld	a5,168(s2)
    8000320a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000320e:	37fd                	addiw	a5,a5,-1
    80003210:	476d                	li	a4,27
    80003212:	00f76f63          	bltu	a4,a5,80003230 <syscall+0x44>
    80003216:	00369713          	slli	a4,a3,0x3
    8000321a:	00005797          	auipc	a5,0x5
    8000321e:	24e78793          	addi	a5,a5,590 # 80008468 <syscalls>
    80003222:	97ba                	add	a5,a5,a4
    80003224:	639c                	ld	a5,0(a5)
    80003226:	c789                	beqz	a5,80003230 <syscall+0x44>
    t->trapframe->a0 = syscalls[num]();
    80003228:	9782                	jalr	a5
    8000322a:	06a93823          	sd	a0,112(s2)
    8000322e:	a00d                	j	80003250 <syscall+0x64>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003230:	00005617          	auipc	a2,0x5
    80003234:	1f860613          	addi	a2,a2,504 # 80008428 <states.0+0x150>
    80003238:	408c                	lw	a1,0(s1)
    8000323a:	00005517          	auipc	a0,0x5
    8000323e:	1f650513          	addi	a0,a0,502 # 80008430 <states.0+0x158>
    80003242:	ffffd097          	auipc	ra,0xffffd
    80003246:	340080e7          	jalr	832(ra) # 80000582 <printf>
            t->id, "thread", num);
    t->trapframe->a0 = -1;
    8000324a:	6c9c                	ld	a5,24(s1)
    8000324c:	577d                	li	a4,-1
    8000324e:	fbb8                	sd	a4,112(a5)
  }
}
    80003250:	60e2                	ld	ra,24(sp)
    80003252:	6442                	ld	s0,16(sp)
    80003254:	64a2                	ld	s1,8(sp)
    80003256:	6902                	ld	s2,0(sp)
    80003258:	6105                	addi	sp,sp,32
    8000325a:	8082                	ret

000000008000325c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000325c:	1101                	addi	sp,sp,-32
    8000325e:	ec06                	sd	ra,24(sp)
    80003260:	e822                	sd	s0,16(sp)
    80003262:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003264:	fec40593          	addi	a1,s0,-20
    80003268:	4501                	li	a0,0
    8000326a:	00000097          	auipc	ra,0x0
    8000326e:	f0e080e7          	jalr	-242(ra) # 80003178 <argint>
    return -1;
    80003272:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003274:	00054963          	bltz	a0,80003286 <sys_exit+0x2a>
  exit(n);
    80003278:	fec42503          	lw	a0,-20(s0)
    8000327c:	fffff097          	auipc	ra,0xfffff
    80003280:	382080e7          	jalr	898(ra) # 800025fe <exit>
  return 0;  // not reached
    80003284:	4781                	li	a5,0
}
    80003286:	853e                	mv	a0,a5
    80003288:	60e2                	ld	ra,24(sp)
    8000328a:	6442                	ld	s0,16(sp)
    8000328c:	6105                	addi	sp,sp,32
    8000328e:	8082                	ret

0000000080003290 <sys_sigprocmask>:

//task 1.3
uint64
sys_sigprocmask(void)
{
    80003290:	1101                	addi	sp,sp,-32
    80003292:	ec06                	sd	ra,24(sp)
    80003294:	e822                	sd	s0,16(sp)
    80003296:	1000                	addi	s0,sp,32
    int newmask;
    if(argint(0, &newmask) < 0)
    80003298:	fec40593          	addi	a1,s0,-20
    8000329c:	4501                	li	a0,0
    8000329e:	00000097          	auipc	ra,0x0
    800032a2:	eda080e7          	jalr	-294(ra) # 80003178 <argint>
    800032a6:	87aa                	mv	a5,a0
      return -1;
    800032a8:	557d                	li	a0,-1
    if(argint(0, &newmask) < 0)
    800032aa:	0007ca63          	bltz	a5,800032be <sys_sigprocmask+0x2e>
    return sigprocmask(newmask);
    800032ae:	fec42503          	lw	a0,-20(s0)
    800032b2:	fffff097          	auipc	ra,0xfffff
    800032b6:	64a080e7          	jalr	1610(ra) # 800028fc <sigprocmask>
    800032ba:	1502                	slli	a0,a0,0x20
    800032bc:	9101                	srli	a0,a0,0x20
}
    800032be:	60e2                	ld	ra,24(sp)
    800032c0:	6442                	ld	s0,16(sp)
    800032c2:	6105                	addi	sp,sp,32
    800032c4:	8082                	ret

00000000800032c6 <sys_sigaction>:
//task 1.3

//task 1.4
uint64
sys_sigaction(void)
{
    800032c6:	7179                	addi	sp,sp,-48
    800032c8:	f406                	sd	ra,40(sp)
    800032ca:	f022                	sd	s0,32(sp)
    800032cc:	1800                	addi	s0,sp,48
  uint64 oldact;
  //struct sigaction *act;
  //struct sigaction *oldact;
  int signum;
  
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    800032ce:	fdc40593          	addi	a1,s0,-36
    800032d2:	4501                	li	a0,0
    800032d4:	00000097          	auipc	ra,0x0
    800032d8:	ea4080e7          	jalr	-348(ra) # 80003178 <argint>
    return -1;
    800032dc:	57fd                	li	a5,-1
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    800032de:	04054163          	bltz	a0,80003320 <sys_sigaction+0x5a>
    800032e2:	fe840593          	addi	a1,s0,-24
    800032e6:	4505                	li	a0,1
    800032e8:	00000097          	auipc	ra,0x0
    800032ec:	eb2080e7          	jalr	-334(ra) # 8000319a <argaddr>
    return -1;
    800032f0:	57fd                	li	a5,-1
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    800032f2:	02054763          	bltz	a0,80003320 <sys_sigaction+0x5a>
    800032f6:	fe040593          	addi	a1,s0,-32
    800032fa:	4509                	li	a0,2
    800032fc:	00000097          	auipc	ra,0x0
    80003300:	e9e080e7          	jalr	-354(ra) # 8000319a <argaddr>
    return -1;
    80003304:	57fd                	li	a5,-1
  if(argint(0,&signum)<0 || argaddr(1,&act) < 0 || argaddr(2,&oldact) < 0)
    80003306:	00054d63          	bltz	a0,80003320 <sys_sigaction+0x5a>
  return sigaction(signum,(struct sigaction*)act,(struct sigaction*)oldact);
    8000330a:	fe043603          	ld	a2,-32(s0)
    8000330e:	fe843583          	ld	a1,-24(s0)
    80003312:	fdc42503          	lw	a0,-36(s0)
    80003316:	fffff097          	auipc	ra,0xfffff
    8000331a:	62a080e7          	jalr	1578(ra) # 80002940 <sigaction>
    8000331e:	87aa                	mv	a5,a0
}
    80003320:	853e                	mv	a0,a5
    80003322:	70a2                	ld	ra,40(sp)
    80003324:	7402                	ld	s0,32(sp)
    80003326:	6145                	addi	sp,sp,48
    80003328:	8082                	ret

000000008000332a <sys_sigret>:
//task 1.4

//task 1.5
uint64
sys_sigret(void)
{
    8000332a:	1141                	addi	sp,sp,-16
    8000332c:	e422                	sd	s0,8(sp)
    8000332e:	0800                	addi	s0,sp,16
  return 0; //todo change after 2.4 is done
}
    80003330:	4501                	li	a0,0
    80003332:	6422                	ld	s0,8(sp)
    80003334:	0141                	addi	sp,sp,16
    80003336:	8082                	ret

0000000080003338 <sys_getpid>:
//task1.5

uint64
sys_getpid(void)
{
    80003338:	1141                	addi	sp,sp,-16
    8000333a:	e406                	sd	ra,8(sp)
    8000333c:	e022                	sd	s0,0(sp)
    8000333e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003340:	ffffe097          	auipc	ra,0xffffe
    80003344:	716080e7          	jalr	1814(ra) # 80001a56 <myproc>
}
    80003348:	5908                	lw	a0,48(a0)
    8000334a:	60a2                	ld	ra,8(sp)
    8000334c:	6402                	ld	s0,0(sp)
    8000334e:	0141                	addi	sp,sp,16
    80003350:	8082                	ret

0000000080003352 <sys_fork>:

uint64
sys_fork(void)
{
    80003352:	1141                	addi	sp,sp,-16
    80003354:	e406                	sd	ra,8(sp)
    80003356:	e022                	sd	s0,0(sp)
    80003358:	0800                	addi	s0,sp,16
  return fork();
    8000335a:	fffff097          	auipc	ra,0xfffff
    8000335e:	c48080e7          	jalr	-952(ra) # 80001fa2 <fork>
}
    80003362:	60a2                	ld	ra,8(sp)
    80003364:	6402                	ld	s0,0(sp)
    80003366:	0141                	addi	sp,sp,16
    80003368:	8082                	ret

000000008000336a <sys_wait>:

uint64
sys_wait(void)
{
    8000336a:	1101                	addi	sp,sp,-32
    8000336c:	ec06                	sd	ra,24(sp)
    8000336e:	e822                	sd	s0,16(sp)
    80003370:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003372:	fe840593          	addi	a1,s0,-24
    80003376:	4501                	li	a0,0
    80003378:	00000097          	auipc	ra,0x0
    8000337c:	e22080e7          	jalr	-478(ra) # 8000319a <argaddr>
    80003380:	87aa                	mv	a5,a0
    return -1;
    80003382:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003384:	0007c863          	bltz	a5,80003394 <sys_wait+0x2a>
  return wait(p);
    80003388:	fe843503          	ld	a0,-24(s0)
    8000338c:	fffff097          	auipc	ra,0xfffff
    80003390:	040080e7          	jalr	64(ra) # 800023cc <wait>
}
    80003394:	60e2                	ld	ra,24(sp)
    80003396:	6442                	ld	s0,16(sp)
    80003398:	6105                	addi	sp,sp,32
    8000339a:	8082                	ret

000000008000339c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000339c:	7179                	addi	sp,sp,-48
    8000339e:	f406                	sd	ra,40(sp)
    800033a0:	f022                	sd	s0,32(sp)
    800033a2:	ec26                	sd	s1,24(sp)
    800033a4:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800033a6:	fdc40593          	addi	a1,s0,-36
    800033aa:	4501                	li	a0,0
    800033ac:	00000097          	auipc	ra,0x0
    800033b0:	dcc080e7          	jalr	-564(ra) # 80003178 <argint>
    return -1;
    800033b4:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800033b6:	00054f63          	bltz	a0,800033d4 <sys_sbrk+0x38>
  addr = myproc()->sz;
    800033ba:	ffffe097          	auipc	ra,0xffffe
    800033be:	69c080e7          	jalr	1692(ra) # 80001a56 <myproc>
    800033c2:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800033c4:	fdc42503          	lw	a0,-36(s0)
    800033c8:	fffff097          	auipc	ra,0xfffff
    800033cc:	b46080e7          	jalr	-1210(ra) # 80001f0e <growproc>
    800033d0:	00054863          	bltz	a0,800033e0 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800033d4:	8526                	mv	a0,s1
    800033d6:	70a2                	ld	ra,40(sp)
    800033d8:	7402                	ld	s0,32(sp)
    800033da:	64e2                	ld	s1,24(sp)
    800033dc:	6145                	addi	sp,sp,48
    800033de:	8082                	ret
    return -1;
    800033e0:	54fd                	li	s1,-1
    800033e2:	bfcd                	j	800033d4 <sys_sbrk+0x38>

00000000800033e4 <sys_sleep>:

uint64
sys_sleep(void)
{
    800033e4:	7139                	addi	sp,sp,-64
    800033e6:	fc06                	sd	ra,56(sp)
    800033e8:	f822                	sd	s0,48(sp)
    800033ea:	f426                	sd	s1,40(sp)
    800033ec:	f04a                	sd	s2,32(sp)
    800033ee:	ec4e                	sd	s3,24(sp)
    800033f0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800033f2:	fcc40593          	addi	a1,s0,-52
    800033f6:	4501                	li	a0,0
    800033f8:	00000097          	auipc	ra,0x0
    800033fc:	d80080e7          	jalr	-640(ra) # 80003178 <argint>
    return -1;
    80003400:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003402:	06054563          	bltz	a0,8000346c <sys_sleep+0x88>
  acquire(&tickslock);
    80003406:	0002c517          	auipc	a0,0x2c
    8000340a:	12250513          	addi	a0,a0,290 # 8002f528 <tickslock>
    8000340e:	ffffd097          	auipc	ra,0xffffd
    80003412:	7ca080e7          	jalr	1994(ra) # 80000bd8 <acquire>
  ticks0 = ticks;
    80003416:	00006917          	auipc	s2,0x6
    8000341a:	c1a92903          	lw	s2,-998(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    8000341e:	fcc42783          	lw	a5,-52(s0)
    80003422:	cf85                	beqz	a5,8000345a <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003424:	0002c997          	auipc	s3,0x2c
    80003428:	10498993          	addi	s3,s3,260 # 8002f528 <tickslock>
    8000342c:	00006497          	auipc	s1,0x6
    80003430:	c0448493          	addi	s1,s1,-1020 # 80009030 <ticks>
    if(myproc()->killed){
    80003434:	ffffe097          	auipc	ra,0xffffe
    80003438:	622080e7          	jalr	1570(ra) # 80001a56 <myproc>
    8000343c:	551c                	lw	a5,40(a0)
    8000343e:	ef9d                	bnez	a5,8000347c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003440:	85ce                	mv	a1,s3
    80003442:	8526                	mv	a0,s1
    80003444:	fffff097          	auipc	ra,0xfffff
    80003448:	f1a080e7          	jalr	-230(ra) # 8000235e <sleep>
  while(ticks - ticks0 < n){
    8000344c:	409c                	lw	a5,0(s1)
    8000344e:	412787bb          	subw	a5,a5,s2
    80003452:	fcc42703          	lw	a4,-52(s0)
    80003456:	fce7efe3          	bltu	a5,a4,80003434 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000345a:	0002c517          	auipc	a0,0x2c
    8000345e:	0ce50513          	addi	a0,a0,206 # 8002f528 <tickslock>
    80003462:	ffffe097          	auipc	ra,0xffffe
    80003466:	842080e7          	jalr	-1982(ra) # 80000ca4 <release>
  return 0;
    8000346a:	4781                	li	a5,0
}
    8000346c:	853e                	mv	a0,a5
    8000346e:	70e2                	ld	ra,56(sp)
    80003470:	7442                	ld	s0,48(sp)
    80003472:	74a2                	ld	s1,40(sp)
    80003474:	7902                	ld	s2,32(sp)
    80003476:	69e2                	ld	s3,24(sp)
    80003478:	6121                	addi	sp,sp,64
    8000347a:	8082                	ret
      release(&tickslock);
    8000347c:	0002c517          	auipc	a0,0x2c
    80003480:	0ac50513          	addi	a0,a0,172 # 8002f528 <tickslock>
    80003484:	ffffe097          	auipc	ra,0xffffe
    80003488:	820080e7          	jalr	-2016(ra) # 80000ca4 <release>
      return -1;
    8000348c:	57fd                	li	a5,-1
    8000348e:	bff9                	j	8000346c <sys_sleep+0x88>

0000000080003490 <sys_kill>:

uint64
sys_kill(void)
{
    80003490:	1101                	addi	sp,sp,-32
    80003492:	ec06                	sd	ra,24(sp)
    80003494:	e822                	sd	s0,16(sp)
    80003496:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003498:	fec40593          	addi	a1,s0,-20
    8000349c:	4501                	li	a0,0
    8000349e:	00000097          	auipc	ra,0x0
    800034a2:	cda080e7          	jalr	-806(ra) # 80003178 <argint>
    800034a6:	87aa                	mv	a5,a0
    return -1;
    800034a8:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800034aa:	0007c863          	bltz	a5,800034ba <sys_kill+0x2a>
  return kill(pid);
    800034ae:	fec42503          	lw	a0,-20(s0)
    800034b2:	fffff097          	auipc	ra,0xfffff
    800034b6:	256080e7          	jalr	598(ra) # 80002708 <kill>
}
    800034ba:	60e2                	ld	ra,24(sp)
    800034bc:	6442                	ld	s0,16(sp)
    800034be:	6105                	addi	sp,sp,32
    800034c0:	8082                	ret

00000000800034c2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800034c2:	1101                	addi	sp,sp,-32
    800034c4:	ec06                	sd	ra,24(sp)
    800034c6:	e822                	sd	s0,16(sp)
    800034c8:	e426                	sd	s1,8(sp)
    800034ca:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800034cc:	0002c517          	auipc	a0,0x2c
    800034d0:	05c50513          	addi	a0,a0,92 # 8002f528 <tickslock>
    800034d4:	ffffd097          	auipc	ra,0xffffd
    800034d8:	704080e7          	jalr	1796(ra) # 80000bd8 <acquire>
  xticks = ticks;
    800034dc:	00006497          	auipc	s1,0x6
    800034e0:	b544a483          	lw	s1,-1196(s1) # 80009030 <ticks>
  release(&tickslock);
    800034e4:	0002c517          	auipc	a0,0x2c
    800034e8:	04450513          	addi	a0,a0,68 # 8002f528 <tickslock>
    800034ec:	ffffd097          	auipc	ra,0xffffd
    800034f0:	7b8080e7          	jalr	1976(ra) # 80000ca4 <release>
  return xticks;
}
    800034f4:	02049513          	slli	a0,s1,0x20
    800034f8:	9101                	srli	a0,a0,0x20
    800034fa:	60e2                	ld	ra,24(sp)
    800034fc:	6442                	ld	s0,16(sp)
    800034fe:	64a2                	ld	s1,8(sp)
    80003500:	6105                	addi	sp,sp,32
    80003502:	8082                	ret

0000000080003504 <sys_kthread_create>:

uint64 sys_kthread_create(void){
    80003504:	1101                	addi	sp,sp,-32
    80003506:	ec06                	sd	ra,24(sp)
    80003508:	e822                	sd	s0,16(sp)
    8000350a:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;

  if(argaddr(0, &start_func) < 0)
    8000350c:	fe840593          	addi	a1,s0,-24
    80003510:	4501                	li	a0,0
    80003512:	00000097          	auipc	ra,0x0
    80003516:	c88080e7          	jalr	-888(ra) # 8000319a <argaddr>
    return -1;
    8000351a:	57fd                	li	a5,-1
  if(argaddr(0, &start_func) < 0)
    8000351c:	02054563          	bltz	a0,80003546 <sys_kthread_create+0x42>
  if(argaddr(1, &stack) < 0)
    80003520:	fe040593          	addi	a1,s0,-32
    80003524:	4505                	li	a0,1
    80003526:	00000097          	auipc	ra,0x0
    8000352a:	c74080e7          	jalr	-908(ra) # 8000319a <argaddr>
    return -1;
    8000352e:	57fd                	li	a5,-1
  if(argaddr(1, &stack) < 0)
    80003530:	00054b63          	bltz	a0,80003546 <sys_kthread_create+0x42>
  return kthread_create(start_func,stack);
    80003534:	fe043583          	ld	a1,-32(s0)
    80003538:	fe843503          	ld	a0,-24(s0)
    8000353c:	fffff097          	auipc	ra,0xfffff
    80003540:	46c080e7          	jalr	1132(ra) # 800029a8 <kthread_create>
    80003544:	87aa                	mv	a5,a0
}
    80003546:	853e                	mv	a0,a5
    80003548:	60e2                	ld	ra,24(sp)
    8000354a:	6442                	ld	s0,16(sp)
    8000354c:	6105                	addi	sp,sp,32
    8000354e:	8082                	ret

0000000080003550 <sys_kthread_id>:

uint64 sys_kthread_id(void){
    80003550:	1141                	addi	sp,sp,-16
    80003552:	e406                	sd	ra,8(sp)
    80003554:	e022                	sd	s0,0(sp)
    80003556:	0800                	addi	s0,sp,16
  return kthread_id();
    80003558:	fffff097          	auipc	ra,0xfffff
    8000355c:	4fc080e7          	jalr	1276(ra) # 80002a54 <kthread_id>
}
    80003560:	60a2                	ld	ra,8(sp)
    80003562:	6402                	ld	s0,0(sp)
    80003564:	0141                	addi	sp,sp,16
    80003566:	8082                	ret

0000000080003568 <sys_kthread_exit>:

uint64 sys_kthread_exit(void){
    80003568:	1101                	addi	sp,sp,-32
    8000356a:	ec06                	sd	ra,24(sp)
    8000356c:	e822                	sd	s0,16(sp)
    8000356e:	1000                	addi	s0,sp,32
  int status;

  if(argint(0, &status) < 0)
    80003570:	fec40593          	addi	a1,s0,-20
    80003574:	4501                	li	a0,0
    80003576:	00000097          	auipc	ra,0x0
    8000357a:	c02080e7          	jalr	-1022(ra) # 80003178 <argint>
    return -1;
    8000357e:	57fd                	li	a5,-1
  if(argint(0, &status) < 0)
    80003580:	00054963          	bltz	a0,80003592 <sys_kthread_exit+0x2a>
  kthread_exit(status);
    80003584:	fec42503          	lw	a0,-20(s0)
    80003588:	fffff097          	auipc	ra,0xfffff
    8000358c:	4e6080e7          	jalr	1254(ra) # 80002a6e <kthread_exit>
  return 0;
    80003590:	4781                	li	a5,0
}
    80003592:	853e                	mv	a0,a5
    80003594:	60e2                	ld	ra,24(sp)
    80003596:	6442                	ld	s0,16(sp)
    80003598:	6105                	addi	sp,sp,32
    8000359a:	8082                	ret

000000008000359c <sys_kthread_join>:

uint64 sys_kthread_join(void){
    8000359c:	1101                	addi	sp,sp,-32
    8000359e:	ec06                	sd	ra,24(sp)
    800035a0:	e822                	sd	s0,16(sp)
    800035a2:	1000                	addi	s0,sp,32
  int id;
  uint64 status;
  if(argint(0, &id) < 0)
    800035a4:	fec40593          	addi	a1,s0,-20
    800035a8:	4501                	li	a0,0
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	bce080e7          	jalr	-1074(ra) # 80003178 <argint>
    return -1;
    800035b2:	57fd                	li	a5,-1
  if(argint(0, &id) < 0)
    800035b4:	02054563          	bltz	a0,800035de <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    800035b8:	fe040593          	addi	a1,s0,-32
    800035bc:	4505                	li	a0,1
    800035be:	00000097          	auipc	ra,0x0
    800035c2:	bdc080e7          	jalr	-1060(ra) # 8000319a <argaddr>
    return -1;
    800035c6:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    800035c8:	00054b63          	bltz	a0,800035de <sys_kthread_join+0x42>
  return kthread_join(id, status);
    800035cc:	fe043583          	ld	a1,-32(s0)
    800035d0:	fec42503          	lw	a0,-20(s0)
    800035d4:	fffff097          	auipc	ra,0xfffff
    800035d8:	524080e7          	jalr	1316(ra) # 80002af8 <kthread_join>
    800035dc:	87aa                	mv	a5,a0
    800035de:	853e                	mv	a0,a5
    800035e0:	60e2                	ld	ra,24(sp)
    800035e2:	6442                	ld	s0,16(sp)
    800035e4:	6105                	addi	sp,sp,32
    800035e6:	8082                	ret

00000000800035e8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800035e8:	7179                	addi	sp,sp,-48
    800035ea:	f406                	sd	ra,40(sp)
    800035ec:	f022                	sd	s0,32(sp)
    800035ee:	ec26                	sd	s1,24(sp)
    800035f0:	e84a                	sd	s2,16(sp)
    800035f2:	e44e                	sd	s3,8(sp)
    800035f4:	e052                	sd	s4,0(sp)
    800035f6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800035f8:	00005597          	auipc	a1,0x5
    800035fc:	f5858593          	addi	a1,a1,-168 # 80008550 <syscalls+0xe8>
    80003600:	0002c517          	auipc	a0,0x2c
    80003604:	f4050513          	addi	a0,a0,-192 # 8002f540 <bcache>
    80003608:	ffffd097          	auipc	ra,0xffffd
    8000360c:	538080e7          	jalr	1336(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003610:	00034797          	auipc	a5,0x34
    80003614:	f3078793          	addi	a5,a5,-208 # 80037540 <bcache+0x8000>
    80003618:	00034717          	auipc	a4,0x34
    8000361c:	19070713          	addi	a4,a4,400 # 800377a8 <bcache+0x8268>
    80003620:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003624:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003628:	0002c497          	auipc	s1,0x2c
    8000362c:	f3048493          	addi	s1,s1,-208 # 8002f558 <bcache+0x18>
    b->next = bcache.head.next;
    80003630:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003632:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003634:	00005a17          	auipc	s4,0x5
    80003638:	f24a0a13          	addi	s4,s4,-220 # 80008558 <syscalls+0xf0>
    b->next = bcache.head.next;
    8000363c:	2b893783          	ld	a5,696(s2)
    80003640:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003642:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003646:	85d2                	mv	a1,s4
    80003648:	01048513          	addi	a0,s1,16
    8000364c:	00001097          	auipc	ra,0x1
    80003650:	4c2080e7          	jalr	1218(ra) # 80004b0e <initsleeplock>
    bcache.head.next->prev = b;
    80003654:	2b893783          	ld	a5,696(s2)
    80003658:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000365a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000365e:	45848493          	addi	s1,s1,1112
    80003662:	fd349de3          	bne	s1,s3,8000363c <binit+0x54>
  }
}
    80003666:	70a2                	ld	ra,40(sp)
    80003668:	7402                	ld	s0,32(sp)
    8000366a:	64e2                	ld	s1,24(sp)
    8000366c:	6942                	ld	s2,16(sp)
    8000366e:	69a2                	ld	s3,8(sp)
    80003670:	6a02                	ld	s4,0(sp)
    80003672:	6145                	addi	sp,sp,48
    80003674:	8082                	ret

0000000080003676 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003676:	7179                	addi	sp,sp,-48
    80003678:	f406                	sd	ra,40(sp)
    8000367a:	f022                	sd	s0,32(sp)
    8000367c:	ec26                	sd	s1,24(sp)
    8000367e:	e84a                	sd	s2,16(sp)
    80003680:	e44e                	sd	s3,8(sp)
    80003682:	1800                	addi	s0,sp,48
    80003684:	892a                	mv	s2,a0
    80003686:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003688:	0002c517          	auipc	a0,0x2c
    8000368c:	eb850513          	addi	a0,a0,-328 # 8002f540 <bcache>
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	548080e7          	jalr	1352(ra) # 80000bd8 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003698:	00034497          	auipc	s1,0x34
    8000369c:	1604b483          	ld	s1,352(s1) # 800377f8 <bcache+0x82b8>
    800036a0:	00034797          	auipc	a5,0x34
    800036a4:	10878793          	addi	a5,a5,264 # 800377a8 <bcache+0x8268>
    800036a8:	02f48f63          	beq	s1,a5,800036e6 <bread+0x70>
    800036ac:	873e                	mv	a4,a5
    800036ae:	a021                	j	800036b6 <bread+0x40>
    800036b0:	68a4                	ld	s1,80(s1)
    800036b2:	02e48a63          	beq	s1,a4,800036e6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800036b6:	449c                	lw	a5,8(s1)
    800036b8:	ff279ce3          	bne	a5,s2,800036b0 <bread+0x3a>
    800036bc:	44dc                	lw	a5,12(s1)
    800036be:	ff3799e3          	bne	a5,s3,800036b0 <bread+0x3a>
      b->refcnt++;
    800036c2:	40bc                	lw	a5,64(s1)
    800036c4:	2785                	addiw	a5,a5,1
    800036c6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036c8:	0002c517          	auipc	a0,0x2c
    800036cc:	e7850513          	addi	a0,a0,-392 # 8002f540 <bcache>
    800036d0:	ffffd097          	auipc	ra,0xffffd
    800036d4:	5d4080e7          	jalr	1492(ra) # 80000ca4 <release>
      acquiresleep(&b->lock);
    800036d8:	01048513          	addi	a0,s1,16
    800036dc:	00001097          	auipc	ra,0x1
    800036e0:	46c080e7          	jalr	1132(ra) # 80004b48 <acquiresleep>
      return b;
    800036e4:	a8b9                	j	80003742 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036e6:	00034497          	auipc	s1,0x34
    800036ea:	10a4b483          	ld	s1,266(s1) # 800377f0 <bcache+0x82b0>
    800036ee:	00034797          	auipc	a5,0x34
    800036f2:	0ba78793          	addi	a5,a5,186 # 800377a8 <bcache+0x8268>
    800036f6:	00f48863          	beq	s1,a5,80003706 <bread+0x90>
    800036fa:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800036fc:	40bc                	lw	a5,64(s1)
    800036fe:	cf81                	beqz	a5,80003716 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003700:	64a4                	ld	s1,72(s1)
    80003702:	fee49de3          	bne	s1,a4,800036fc <bread+0x86>
  panic("bget: no buffers");
    80003706:	00005517          	auipc	a0,0x5
    8000370a:	e5a50513          	addi	a0,a0,-422 # 80008560 <syscalls+0xf8>
    8000370e:	ffffd097          	auipc	ra,0xffffd
    80003712:	e2a080e7          	jalr	-470(ra) # 80000538 <panic>
      b->dev = dev;
    80003716:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000371a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000371e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003722:	4785                	li	a5,1
    80003724:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003726:	0002c517          	auipc	a0,0x2c
    8000372a:	e1a50513          	addi	a0,a0,-486 # 8002f540 <bcache>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	576080e7          	jalr	1398(ra) # 80000ca4 <release>
      acquiresleep(&b->lock);
    80003736:	01048513          	addi	a0,s1,16
    8000373a:	00001097          	auipc	ra,0x1
    8000373e:	40e080e7          	jalr	1038(ra) # 80004b48 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003742:	409c                	lw	a5,0(s1)
    80003744:	cb89                	beqz	a5,80003756 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003746:	8526                	mv	a0,s1
    80003748:	70a2                	ld	ra,40(sp)
    8000374a:	7402                	ld	s0,32(sp)
    8000374c:	64e2                	ld	s1,24(sp)
    8000374e:	6942                	ld	s2,16(sp)
    80003750:	69a2                	ld	s3,8(sp)
    80003752:	6145                	addi	sp,sp,48
    80003754:	8082                	ret
    virtio_disk_rw(b, 0);
    80003756:	4581                	li	a1,0
    80003758:	8526                	mv	a0,s1
    8000375a:	00003097          	auipc	ra,0x3
    8000375e:	f8c080e7          	jalr	-116(ra) # 800066e6 <virtio_disk_rw>
    b->valid = 1;
    80003762:	4785                	li	a5,1
    80003764:	c09c                	sw	a5,0(s1)
  return b;
    80003766:	b7c5                	j	80003746 <bread+0xd0>

0000000080003768 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003768:	1101                	addi	sp,sp,-32
    8000376a:	ec06                	sd	ra,24(sp)
    8000376c:	e822                	sd	s0,16(sp)
    8000376e:	e426                	sd	s1,8(sp)
    80003770:	1000                	addi	s0,sp,32
    80003772:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003774:	0541                	addi	a0,a0,16
    80003776:	00001097          	auipc	ra,0x1
    8000377a:	46c080e7          	jalr	1132(ra) # 80004be2 <holdingsleep>
    8000377e:	cd01                	beqz	a0,80003796 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003780:	4585                	li	a1,1
    80003782:	8526                	mv	a0,s1
    80003784:	00003097          	auipc	ra,0x3
    80003788:	f62080e7          	jalr	-158(ra) # 800066e6 <virtio_disk_rw>
}
    8000378c:	60e2                	ld	ra,24(sp)
    8000378e:	6442                	ld	s0,16(sp)
    80003790:	64a2                	ld	s1,8(sp)
    80003792:	6105                	addi	sp,sp,32
    80003794:	8082                	ret
    panic("bwrite");
    80003796:	00005517          	auipc	a0,0x5
    8000379a:	de250513          	addi	a0,a0,-542 # 80008578 <syscalls+0x110>
    8000379e:	ffffd097          	auipc	ra,0xffffd
    800037a2:	d9a080e7          	jalr	-614(ra) # 80000538 <panic>

00000000800037a6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800037a6:	1101                	addi	sp,sp,-32
    800037a8:	ec06                	sd	ra,24(sp)
    800037aa:	e822                	sd	s0,16(sp)
    800037ac:	e426                	sd	s1,8(sp)
    800037ae:	e04a                	sd	s2,0(sp)
    800037b0:	1000                	addi	s0,sp,32
    800037b2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800037b4:	01050913          	addi	s2,a0,16
    800037b8:	854a                	mv	a0,s2
    800037ba:	00001097          	auipc	ra,0x1
    800037be:	428080e7          	jalr	1064(ra) # 80004be2 <holdingsleep>
    800037c2:	c92d                	beqz	a0,80003834 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800037c4:	854a                	mv	a0,s2
    800037c6:	00001097          	auipc	ra,0x1
    800037ca:	3d8080e7          	jalr	984(ra) # 80004b9e <releasesleep>

  acquire(&bcache.lock);
    800037ce:	0002c517          	auipc	a0,0x2c
    800037d2:	d7250513          	addi	a0,a0,-654 # 8002f540 <bcache>
    800037d6:	ffffd097          	auipc	ra,0xffffd
    800037da:	402080e7          	jalr	1026(ra) # 80000bd8 <acquire>
  b->refcnt--;
    800037de:	40bc                	lw	a5,64(s1)
    800037e0:	37fd                	addiw	a5,a5,-1
    800037e2:	0007871b          	sext.w	a4,a5
    800037e6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800037e8:	eb05                	bnez	a4,80003818 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800037ea:	68bc                	ld	a5,80(s1)
    800037ec:	64b8                	ld	a4,72(s1)
    800037ee:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800037f0:	64bc                	ld	a5,72(s1)
    800037f2:	68b8                	ld	a4,80(s1)
    800037f4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800037f6:	00034797          	auipc	a5,0x34
    800037fa:	d4a78793          	addi	a5,a5,-694 # 80037540 <bcache+0x8000>
    800037fe:	2b87b703          	ld	a4,696(a5)
    80003802:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003804:	00034717          	auipc	a4,0x34
    80003808:	fa470713          	addi	a4,a4,-92 # 800377a8 <bcache+0x8268>
    8000380c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000380e:	2b87b703          	ld	a4,696(a5)
    80003812:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003814:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003818:	0002c517          	auipc	a0,0x2c
    8000381c:	d2850513          	addi	a0,a0,-728 # 8002f540 <bcache>
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	484080e7          	jalr	1156(ra) # 80000ca4 <release>
}
    80003828:	60e2                	ld	ra,24(sp)
    8000382a:	6442                	ld	s0,16(sp)
    8000382c:	64a2                	ld	s1,8(sp)
    8000382e:	6902                	ld	s2,0(sp)
    80003830:	6105                	addi	sp,sp,32
    80003832:	8082                	ret
    panic("brelse");
    80003834:	00005517          	auipc	a0,0x5
    80003838:	d4c50513          	addi	a0,a0,-692 # 80008580 <syscalls+0x118>
    8000383c:	ffffd097          	auipc	ra,0xffffd
    80003840:	cfc080e7          	jalr	-772(ra) # 80000538 <panic>

0000000080003844 <bpin>:

void
bpin(struct buf *b) {
    80003844:	1101                	addi	sp,sp,-32
    80003846:	ec06                	sd	ra,24(sp)
    80003848:	e822                	sd	s0,16(sp)
    8000384a:	e426                	sd	s1,8(sp)
    8000384c:	1000                	addi	s0,sp,32
    8000384e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003850:	0002c517          	auipc	a0,0x2c
    80003854:	cf050513          	addi	a0,a0,-784 # 8002f540 <bcache>
    80003858:	ffffd097          	auipc	ra,0xffffd
    8000385c:	380080e7          	jalr	896(ra) # 80000bd8 <acquire>
  b->refcnt++;
    80003860:	40bc                	lw	a5,64(s1)
    80003862:	2785                	addiw	a5,a5,1
    80003864:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003866:	0002c517          	auipc	a0,0x2c
    8000386a:	cda50513          	addi	a0,a0,-806 # 8002f540 <bcache>
    8000386e:	ffffd097          	auipc	ra,0xffffd
    80003872:	436080e7          	jalr	1078(ra) # 80000ca4 <release>
}
    80003876:	60e2                	ld	ra,24(sp)
    80003878:	6442                	ld	s0,16(sp)
    8000387a:	64a2                	ld	s1,8(sp)
    8000387c:	6105                	addi	sp,sp,32
    8000387e:	8082                	ret

0000000080003880 <bunpin>:

void
bunpin(struct buf *b) {
    80003880:	1101                	addi	sp,sp,-32
    80003882:	ec06                	sd	ra,24(sp)
    80003884:	e822                	sd	s0,16(sp)
    80003886:	e426                	sd	s1,8(sp)
    80003888:	1000                	addi	s0,sp,32
    8000388a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000388c:	0002c517          	auipc	a0,0x2c
    80003890:	cb450513          	addi	a0,a0,-844 # 8002f540 <bcache>
    80003894:	ffffd097          	auipc	ra,0xffffd
    80003898:	344080e7          	jalr	836(ra) # 80000bd8 <acquire>
  b->refcnt--;
    8000389c:	40bc                	lw	a5,64(s1)
    8000389e:	37fd                	addiw	a5,a5,-1
    800038a0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038a2:	0002c517          	auipc	a0,0x2c
    800038a6:	c9e50513          	addi	a0,a0,-866 # 8002f540 <bcache>
    800038aa:	ffffd097          	auipc	ra,0xffffd
    800038ae:	3fa080e7          	jalr	1018(ra) # 80000ca4 <release>
}
    800038b2:	60e2                	ld	ra,24(sp)
    800038b4:	6442                	ld	s0,16(sp)
    800038b6:	64a2                	ld	s1,8(sp)
    800038b8:	6105                	addi	sp,sp,32
    800038ba:	8082                	ret

00000000800038bc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800038bc:	1101                	addi	sp,sp,-32
    800038be:	ec06                	sd	ra,24(sp)
    800038c0:	e822                	sd	s0,16(sp)
    800038c2:	e426                	sd	s1,8(sp)
    800038c4:	e04a                	sd	s2,0(sp)
    800038c6:	1000                	addi	s0,sp,32
    800038c8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800038ca:	00d5d59b          	srliw	a1,a1,0xd
    800038ce:	00034797          	auipc	a5,0x34
    800038d2:	34e7a783          	lw	a5,846(a5) # 80037c1c <sb+0x1c>
    800038d6:	9dbd                	addw	a1,a1,a5
    800038d8:	00000097          	auipc	ra,0x0
    800038dc:	d9e080e7          	jalr	-610(ra) # 80003676 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800038e0:	0074f713          	andi	a4,s1,7
    800038e4:	4785                	li	a5,1
    800038e6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800038ea:	14ce                	slli	s1,s1,0x33
    800038ec:	90d9                	srli	s1,s1,0x36
    800038ee:	00950733          	add	a4,a0,s1
    800038f2:	05874703          	lbu	a4,88(a4)
    800038f6:	00e7f6b3          	and	a3,a5,a4
    800038fa:	c69d                	beqz	a3,80003928 <bfree+0x6c>
    800038fc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800038fe:	94aa                	add	s1,s1,a0
    80003900:	fff7c793          	not	a5,a5
    80003904:	8ff9                	and	a5,a5,a4
    80003906:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000390a:	00001097          	auipc	ra,0x1
    8000390e:	11e080e7          	jalr	286(ra) # 80004a28 <log_write>
  brelse(bp);
    80003912:	854a                	mv	a0,s2
    80003914:	00000097          	auipc	ra,0x0
    80003918:	e92080e7          	jalr	-366(ra) # 800037a6 <brelse>
}
    8000391c:	60e2                	ld	ra,24(sp)
    8000391e:	6442                	ld	s0,16(sp)
    80003920:	64a2                	ld	s1,8(sp)
    80003922:	6902                	ld	s2,0(sp)
    80003924:	6105                	addi	sp,sp,32
    80003926:	8082                	ret
    panic("freeing free block");
    80003928:	00005517          	auipc	a0,0x5
    8000392c:	c6050513          	addi	a0,a0,-928 # 80008588 <syscalls+0x120>
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	c08080e7          	jalr	-1016(ra) # 80000538 <panic>

0000000080003938 <balloc>:
{
    80003938:	711d                	addi	sp,sp,-96
    8000393a:	ec86                	sd	ra,88(sp)
    8000393c:	e8a2                	sd	s0,80(sp)
    8000393e:	e4a6                	sd	s1,72(sp)
    80003940:	e0ca                	sd	s2,64(sp)
    80003942:	fc4e                	sd	s3,56(sp)
    80003944:	f852                	sd	s4,48(sp)
    80003946:	f456                	sd	s5,40(sp)
    80003948:	f05a                	sd	s6,32(sp)
    8000394a:	ec5e                	sd	s7,24(sp)
    8000394c:	e862                	sd	s8,16(sp)
    8000394e:	e466                	sd	s9,8(sp)
    80003950:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003952:	00034797          	auipc	a5,0x34
    80003956:	2b27a783          	lw	a5,690(a5) # 80037c04 <sb+0x4>
    8000395a:	cbd1                	beqz	a5,800039ee <balloc+0xb6>
    8000395c:	8baa                	mv	s7,a0
    8000395e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003960:	00034b17          	auipc	s6,0x34
    80003964:	2a0b0b13          	addi	s6,s6,672 # 80037c00 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003968:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000396a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000396c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000396e:	6c89                	lui	s9,0x2
    80003970:	a831                	j	8000398c <balloc+0x54>
    brelse(bp);
    80003972:	854a                	mv	a0,s2
    80003974:	00000097          	auipc	ra,0x0
    80003978:	e32080e7          	jalr	-462(ra) # 800037a6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000397c:	015c87bb          	addw	a5,s9,s5
    80003980:	00078a9b          	sext.w	s5,a5
    80003984:	004b2703          	lw	a4,4(s6)
    80003988:	06eaf363          	bgeu	s5,a4,800039ee <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000398c:	41fad79b          	sraiw	a5,s5,0x1f
    80003990:	0137d79b          	srliw	a5,a5,0x13
    80003994:	015787bb          	addw	a5,a5,s5
    80003998:	40d7d79b          	sraiw	a5,a5,0xd
    8000399c:	01cb2583          	lw	a1,28(s6)
    800039a0:	9dbd                	addw	a1,a1,a5
    800039a2:	855e                	mv	a0,s7
    800039a4:	00000097          	auipc	ra,0x0
    800039a8:	cd2080e7          	jalr	-814(ra) # 80003676 <bread>
    800039ac:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039ae:	004b2503          	lw	a0,4(s6)
    800039b2:	000a849b          	sext.w	s1,s5
    800039b6:	8662                	mv	a2,s8
    800039b8:	faa4fde3          	bgeu	s1,a0,80003972 <balloc+0x3a>
      m = 1 << (bi % 8);
    800039bc:	41f6579b          	sraiw	a5,a2,0x1f
    800039c0:	01d7d69b          	srliw	a3,a5,0x1d
    800039c4:	00c6873b          	addw	a4,a3,a2
    800039c8:	00777793          	andi	a5,a4,7
    800039cc:	9f95                	subw	a5,a5,a3
    800039ce:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800039d2:	4037571b          	sraiw	a4,a4,0x3
    800039d6:	00e906b3          	add	a3,s2,a4
    800039da:	0586c683          	lbu	a3,88(a3)
    800039de:	00d7f5b3          	and	a1,a5,a3
    800039e2:	cd91                	beqz	a1,800039fe <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039e4:	2605                	addiw	a2,a2,1
    800039e6:	2485                	addiw	s1,s1,1
    800039e8:	fd4618e3          	bne	a2,s4,800039b8 <balloc+0x80>
    800039ec:	b759                	j	80003972 <balloc+0x3a>
  panic("balloc: out of blocks");
    800039ee:	00005517          	auipc	a0,0x5
    800039f2:	bb250513          	addi	a0,a0,-1102 # 800085a0 <syscalls+0x138>
    800039f6:	ffffd097          	auipc	ra,0xffffd
    800039fa:	b42080e7          	jalr	-1214(ra) # 80000538 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800039fe:	974a                	add	a4,a4,s2
    80003a00:	8fd5                	or	a5,a5,a3
    80003a02:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003a06:	854a                	mv	a0,s2
    80003a08:	00001097          	auipc	ra,0x1
    80003a0c:	020080e7          	jalr	32(ra) # 80004a28 <log_write>
        brelse(bp);
    80003a10:	854a                	mv	a0,s2
    80003a12:	00000097          	auipc	ra,0x0
    80003a16:	d94080e7          	jalr	-620(ra) # 800037a6 <brelse>
  bp = bread(dev, bno);
    80003a1a:	85a6                	mv	a1,s1
    80003a1c:	855e                	mv	a0,s7
    80003a1e:	00000097          	auipc	ra,0x0
    80003a22:	c58080e7          	jalr	-936(ra) # 80003676 <bread>
    80003a26:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003a28:	40000613          	li	a2,1024
    80003a2c:	4581                	li	a1,0
    80003a2e:	05850513          	addi	a0,a0,88
    80003a32:	ffffd097          	auipc	ra,0xffffd
    80003a36:	2ba080e7          	jalr	698(ra) # 80000cec <memset>
  log_write(bp);
    80003a3a:	854a                	mv	a0,s2
    80003a3c:	00001097          	auipc	ra,0x1
    80003a40:	fec080e7          	jalr	-20(ra) # 80004a28 <log_write>
  brelse(bp);
    80003a44:	854a                	mv	a0,s2
    80003a46:	00000097          	auipc	ra,0x0
    80003a4a:	d60080e7          	jalr	-672(ra) # 800037a6 <brelse>
}
    80003a4e:	8526                	mv	a0,s1
    80003a50:	60e6                	ld	ra,88(sp)
    80003a52:	6446                	ld	s0,80(sp)
    80003a54:	64a6                	ld	s1,72(sp)
    80003a56:	6906                	ld	s2,64(sp)
    80003a58:	79e2                	ld	s3,56(sp)
    80003a5a:	7a42                	ld	s4,48(sp)
    80003a5c:	7aa2                	ld	s5,40(sp)
    80003a5e:	7b02                	ld	s6,32(sp)
    80003a60:	6be2                	ld	s7,24(sp)
    80003a62:	6c42                	ld	s8,16(sp)
    80003a64:	6ca2                	ld	s9,8(sp)
    80003a66:	6125                	addi	sp,sp,96
    80003a68:	8082                	ret

0000000080003a6a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a6a:	7179                	addi	sp,sp,-48
    80003a6c:	f406                	sd	ra,40(sp)
    80003a6e:	f022                	sd	s0,32(sp)
    80003a70:	ec26                	sd	s1,24(sp)
    80003a72:	e84a                	sd	s2,16(sp)
    80003a74:	e44e                	sd	s3,8(sp)
    80003a76:	e052                	sd	s4,0(sp)
    80003a78:	1800                	addi	s0,sp,48
    80003a7a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003a7c:	47ad                	li	a5,11
    80003a7e:	04b7fe63          	bgeu	a5,a1,80003ada <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003a82:	ff45849b          	addiw	s1,a1,-12
    80003a86:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003a8a:	0ff00793          	li	a5,255
    80003a8e:	0ae7e463          	bltu	a5,a4,80003b36 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003a92:	08052583          	lw	a1,128(a0)
    80003a96:	c5b5                	beqz	a1,80003b02 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003a98:	00092503          	lw	a0,0(s2)
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	bda080e7          	jalr	-1062(ra) # 80003676 <bread>
    80003aa4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003aa6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003aaa:	02049713          	slli	a4,s1,0x20
    80003aae:	01e75593          	srli	a1,a4,0x1e
    80003ab2:	00b784b3          	add	s1,a5,a1
    80003ab6:	0004a983          	lw	s3,0(s1)
    80003aba:	04098e63          	beqz	s3,80003b16 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003abe:	8552                	mv	a0,s4
    80003ac0:	00000097          	auipc	ra,0x0
    80003ac4:	ce6080e7          	jalr	-794(ra) # 800037a6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003ac8:	854e                	mv	a0,s3
    80003aca:	70a2                	ld	ra,40(sp)
    80003acc:	7402                	ld	s0,32(sp)
    80003ace:	64e2                	ld	s1,24(sp)
    80003ad0:	6942                	ld	s2,16(sp)
    80003ad2:	69a2                	ld	s3,8(sp)
    80003ad4:	6a02                	ld	s4,0(sp)
    80003ad6:	6145                	addi	sp,sp,48
    80003ad8:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003ada:	02059793          	slli	a5,a1,0x20
    80003ade:	01e7d593          	srli	a1,a5,0x1e
    80003ae2:	00b504b3          	add	s1,a0,a1
    80003ae6:	0504a983          	lw	s3,80(s1)
    80003aea:	fc099fe3          	bnez	s3,80003ac8 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003aee:	4108                	lw	a0,0(a0)
    80003af0:	00000097          	auipc	ra,0x0
    80003af4:	e48080e7          	jalr	-440(ra) # 80003938 <balloc>
    80003af8:	0005099b          	sext.w	s3,a0
    80003afc:	0534a823          	sw	s3,80(s1)
    80003b00:	b7e1                	j	80003ac8 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003b02:	4108                	lw	a0,0(a0)
    80003b04:	00000097          	auipc	ra,0x0
    80003b08:	e34080e7          	jalr	-460(ra) # 80003938 <balloc>
    80003b0c:	0005059b          	sext.w	a1,a0
    80003b10:	08b92023          	sw	a1,128(s2)
    80003b14:	b751                	j	80003a98 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003b16:	00092503          	lw	a0,0(s2)
    80003b1a:	00000097          	auipc	ra,0x0
    80003b1e:	e1e080e7          	jalr	-482(ra) # 80003938 <balloc>
    80003b22:	0005099b          	sext.w	s3,a0
    80003b26:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003b2a:	8552                	mv	a0,s4
    80003b2c:	00001097          	auipc	ra,0x1
    80003b30:	efc080e7          	jalr	-260(ra) # 80004a28 <log_write>
    80003b34:	b769                	j	80003abe <bmap+0x54>
  panic("bmap: out of range");
    80003b36:	00005517          	auipc	a0,0x5
    80003b3a:	a8250513          	addi	a0,a0,-1406 # 800085b8 <syscalls+0x150>
    80003b3e:	ffffd097          	auipc	ra,0xffffd
    80003b42:	9fa080e7          	jalr	-1542(ra) # 80000538 <panic>

0000000080003b46 <iget>:
{
    80003b46:	7179                	addi	sp,sp,-48
    80003b48:	f406                	sd	ra,40(sp)
    80003b4a:	f022                	sd	s0,32(sp)
    80003b4c:	ec26                	sd	s1,24(sp)
    80003b4e:	e84a                	sd	s2,16(sp)
    80003b50:	e44e                	sd	s3,8(sp)
    80003b52:	e052                	sd	s4,0(sp)
    80003b54:	1800                	addi	s0,sp,48
    80003b56:	89aa                	mv	s3,a0
    80003b58:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b5a:	00034517          	auipc	a0,0x34
    80003b5e:	0c650513          	addi	a0,a0,198 # 80037c20 <itable>
    80003b62:	ffffd097          	auipc	ra,0xffffd
    80003b66:	076080e7          	jalr	118(ra) # 80000bd8 <acquire>
  empty = 0;
    80003b6a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b6c:	00034497          	auipc	s1,0x34
    80003b70:	0cc48493          	addi	s1,s1,204 # 80037c38 <itable+0x18>
    80003b74:	00036697          	auipc	a3,0x36
    80003b78:	b5468693          	addi	a3,a3,-1196 # 800396c8 <log>
    80003b7c:	a039                	j	80003b8a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b7e:	02090b63          	beqz	s2,80003bb4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b82:	08848493          	addi	s1,s1,136
    80003b86:	02d48a63          	beq	s1,a3,80003bba <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003b8a:	449c                	lw	a5,8(s1)
    80003b8c:	fef059e3          	blez	a5,80003b7e <iget+0x38>
    80003b90:	4098                	lw	a4,0(s1)
    80003b92:	ff3716e3          	bne	a4,s3,80003b7e <iget+0x38>
    80003b96:	40d8                	lw	a4,4(s1)
    80003b98:	ff4713e3          	bne	a4,s4,80003b7e <iget+0x38>
      ip->ref++;
    80003b9c:	2785                	addiw	a5,a5,1
    80003b9e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003ba0:	00034517          	auipc	a0,0x34
    80003ba4:	08050513          	addi	a0,a0,128 # 80037c20 <itable>
    80003ba8:	ffffd097          	auipc	ra,0xffffd
    80003bac:	0fc080e7          	jalr	252(ra) # 80000ca4 <release>
      return ip;
    80003bb0:	8926                	mv	s2,s1
    80003bb2:	a03d                	j	80003be0 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003bb4:	f7f9                	bnez	a5,80003b82 <iget+0x3c>
    80003bb6:	8926                	mv	s2,s1
    80003bb8:	b7e9                	j	80003b82 <iget+0x3c>
  if(empty == 0)
    80003bba:	02090c63          	beqz	s2,80003bf2 <iget+0xac>
  ip->dev = dev;
    80003bbe:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003bc2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003bc6:	4785                	li	a5,1
    80003bc8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003bcc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003bd0:	00034517          	auipc	a0,0x34
    80003bd4:	05050513          	addi	a0,a0,80 # 80037c20 <itable>
    80003bd8:	ffffd097          	auipc	ra,0xffffd
    80003bdc:	0cc080e7          	jalr	204(ra) # 80000ca4 <release>
}
    80003be0:	854a                	mv	a0,s2
    80003be2:	70a2                	ld	ra,40(sp)
    80003be4:	7402                	ld	s0,32(sp)
    80003be6:	64e2                	ld	s1,24(sp)
    80003be8:	6942                	ld	s2,16(sp)
    80003bea:	69a2                	ld	s3,8(sp)
    80003bec:	6a02                	ld	s4,0(sp)
    80003bee:	6145                	addi	sp,sp,48
    80003bf0:	8082                	ret
    panic("iget: no inodes");
    80003bf2:	00005517          	auipc	a0,0x5
    80003bf6:	9de50513          	addi	a0,a0,-1570 # 800085d0 <syscalls+0x168>
    80003bfa:	ffffd097          	auipc	ra,0xffffd
    80003bfe:	93e080e7          	jalr	-1730(ra) # 80000538 <panic>

0000000080003c02 <fsinit>:
fsinit(int dev) {
    80003c02:	7179                	addi	sp,sp,-48
    80003c04:	f406                	sd	ra,40(sp)
    80003c06:	f022                	sd	s0,32(sp)
    80003c08:	ec26                	sd	s1,24(sp)
    80003c0a:	e84a                	sd	s2,16(sp)
    80003c0c:	e44e                	sd	s3,8(sp)
    80003c0e:	1800                	addi	s0,sp,48
    80003c10:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003c12:	4585                	li	a1,1
    80003c14:	00000097          	auipc	ra,0x0
    80003c18:	a62080e7          	jalr	-1438(ra) # 80003676 <bread>
    80003c1c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003c1e:	00034997          	auipc	s3,0x34
    80003c22:	fe298993          	addi	s3,s3,-30 # 80037c00 <sb>
    80003c26:	02000613          	li	a2,32
    80003c2a:	05850593          	addi	a1,a0,88
    80003c2e:	854e                	mv	a0,s3
    80003c30:	ffffd097          	auipc	ra,0xffffd
    80003c34:	118080e7          	jalr	280(ra) # 80000d48 <memmove>
  brelse(bp);
    80003c38:	8526                	mv	a0,s1
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	b6c080e7          	jalr	-1172(ra) # 800037a6 <brelse>
  if(sb.magic != FSMAGIC)
    80003c42:	0009a703          	lw	a4,0(s3)
    80003c46:	102037b7          	lui	a5,0x10203
    80003c4a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c4e:	02f71263          	bne	a4,a5,80003c72 <fsinit+0x70>
  initlog(dev, &sb);
    80003c52:	00034597          	auipc	a1,0x34
    80003c56:	fae58593          	addi	a1,a1,-82 # 80037c00 <sb>
    80003c5a:	854a                	mv	a0,s2
    80003c5c:	00001097          	auipc	ra,0x1
    80003c60:	b4e080e7          	jalr	-1202(ra) # 800047aa <initlog>
}
    80003c64:	70a2                	ld	ra,40(sp)
    80003c66:	7402                	ld	s0,32(sp)
    80003c68:	64e2                	ld	s1,24(sp)
    80003c6a:	6942                	ld	s2,16(sp)
    80003c6c:	69a2                	ld	s3,8(sp)
    80003c6e:	6145                	addi	sp,sp,48
    80003c70:	8082                	ret
    panic("invalid file system");
    80003c72:	00005517          	auipc	a0,0x5
    80003c76:	96e50513          	addi	a0,a0,-1682 # 800085e0 <syscalls+0x178>
    80003c7a:	ffffd097          	auipc	ra,0xffffd
    80003c7e:	8be080e7          	jalr	-1858(ra) # 80000538 <panic>

0000000080003c82 <iinit>:
{
    80003c82:	7179                	addi	sp,sp,-48
    80003c84:	f406                	sd	ra,40(sp)
    80003c86:	f022                	sd	s0,32(sp)
    80003c88:	ec26                	sd	s1,24(sp)
    80003c8a:	e84a                	sd	s2,16(sp)
    80003c8c:	e44e                	sd	s3,8(sp)
    80003c8e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003c90:	00005597          	auipc	a1,0x5
    80003c94:	96858593          	addi	a1,a1,-1688 # 800085f8 <syscalls+0x190>
    80003c98:	00034517          	auipc	a0,0x34
    80003c9c:	f8850513          	addi	a0,a0,-120 # 80037c20 <itable>
    80003ca0:	ffffd097          	auipc	ra,0xffffd
    80003ca4:	ea0080e7          	jalr	-352(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ca8:	00034497          	auipc	s1,0x34
    80003cac:	fa048493          	addi	s1,s1,-96 # 80037c48 <itable+0x28>
    80003cb0:	00036997          	auipc	s3,0x36
    80003cb4:	a2898993          	addi	s3,s3,-1496 # 800396d8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003cb8:	00005917          	auipc	s2,0x5
    80003cbc:	94890913          	addi	s2,s2,-1720 # 80008600 <syscalls+0x198>
    80003cc0:	85ca                	mv	a1,s2
    80003cc2:	8526                	mv	a0,s1
    80003cc4:	00001097          	auipc	ra,0x1
    80003cc8:	e4a080e7          	jalr	-438(ra) # 80004b0e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ccc:	08848493          	addi	s1,s1,136
    80003cd0:	ff3498e3          	bne	s1,s3,80003cc0 <iinit+0x3e>
}
    80003cd4:	70a2                	ld	ra,40(sp)
    80003cd6:	7402                	ld	s0,32(sp)
    80003cd8:	64e2                	ld	s1,24(sp)
    80003cda:	6942                	ld	s2,16(sp)
    80003cdc:	69a2                	ld	s3,8(sp)
    80003cde:	6145                	addi	sp,sp,48
    80003ce0:	8082                	ret

0000000080003ce2 <ialloc>:
{
    80003ce2:	715d                	addi	sp,sp,-80
    80003ce4:	e486                	sd	ra,72(sp)
    80003ce6:	e0a2                	sd	s0,64(sp)
    80003ce8:	fc26                	sd	s1,56(sp)
    80003cea:	f84a                	sd	s2,48(sp)
    80003cec:	f44e                	sd	s3,40(sp)
    80003cee:	f052                	sd	s4,32(sp)
    80003cf0:	ec56                	sd	s5,24(sp)
    80003cf2:	e85a                	sd	s6,16(sp)
    80003cf4:	e45e                	sd	s7,8(sp)
    80003cf6:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003cf8:	00034717          	auipc	a4,0x34
    80003cfc:	f1472703          	lw	a4,-236(a4) # 80037c0c <sb+0xc>
    80003d00:	4785                	li	a5,1
    80003d02:	04e7fa63          	bgeu	a5,a4,80003d56 <ialloc+0x74>
    80003d06:	8aaa                	mv	s5,a0
    80003d08:	8bae                	mv	s7,a1
    80003d0a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003d0c:	00034a17          	auipc	s4,0x34
    80003d10:	ef4a0a13          	addi	s4,s4,-268 # 80037c00 <sb>
    80003d14:	00048b1b          	sext.w	s6,s1
    80003d18:	0044d793          	srli	a5,s1,0x4
    80003d1c:	018a2583          	lw	a1,24(s4)
    80003d20:	9dbd                	addw	a1,a1,a5
    80003d22:	8556                	mv	a0,s5
    80003d24:	00000097          	auipc	ra,0x0
    80003d28:	952080e7          	jalr	-1710(ra) # 80003676 <bread>
    80003d2c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003d2e:	05850993          	addi	s3,a0,88
    80003d32:	00f4f793          	andi	a5,s1,15
    80003d36:	079a                	slli	a5,a5,0x6
    80003d38:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003d3a:	00099783          	lh	a5,0(s3)
    80003d3e:	c785                	beqz	a5,80003d66 <ialloc+0x84>
    brelse(bp);
    80003d40:	00000097          	auipc	ra,0x0
    80003d44:	a66080e7          	jalr	-1434(ra) # 800037a6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d48:	0485                	addi	s1,s1,1
    80003d4a:	00ca2703          	lw	a4,12(s4)
    80003d4e:	0004879b          	sext.w	a5,s1
    80003d52:	fce7e1e3          	bltu	a5,a4,80003d14 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003d56:	00005517          	auipc	a0,0x5
    80003d5a:	8b250513          	addi	a0,a0,-1870 # 80008608 <syscalls+0x1a0>
    80003d5e:	ffffc097          	auipc	ra,0xffffc
    80003d62:	7da080e7          	jalr	2010(ra) # 80000538 <panic>
      memset(dip, 0, sizeof(*dip));
    80003d66:	04000613          	li	a2,64
    80003d6a:	4581                	li	a1,0
    80003d6c:	854e                	mv	a0,s3
    80003d6e:	ffffd097          	auipc	ra,0xffffd
    80003d72:	f7e080e7          	jalr	-130(ra) # 80000cec <memset>
      dip->type = type;
    80003d76:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003d7a:	854a                	mv	a0,s2
    80003d7c:	00001097          	auipc	ra,0x1
    80003d80:	cac080e7          	jalr	-852(ra) # 80004a28 <log_write>
      brelse(bp);
    80003d84:	854a                	mv	a0,s2
    80003d86:	00000097          	auipc	ra,0x0
    80003d8a:	a20080e7          	jalr	-1504(ra) # 800037a6 <brelse>
      return iget(dev, inum);
    80003d8e:	85da                	mv	a1,s6
    80003d90:	8556                	mv	a0,s5
    80003d92:	00000097          	auipc	ra,0x0
    80003d96:	db4080e7          	jalr	-588(ra) # 80003b46 <iget>
}
    80003d9a:	60a6                	ld	ra,72(sp)
    80003d9c:	6406                	ld	s0,64(sp)
    80003d9e:	74e2                	ld	s1,56(sp)
    80003da0:	7942                	ld	s2,48(sp)
    80003da2:	79a2                	ld	s3,40(sp)
    80003da4:	7a02                	ld	s4,32(sp)
    80003da6:	6ae2                	ld	s5,24(sp)
    80003da8:	6b42                	ld	s6,16(sp)
    80003daa:	6ba2                	ld	s7,8(sp)
    80003dac:	6161                	addi	sp,sp,80
    80003dae:	8082                	ret

0000000080003db0 <iupdate>:
{
    80003db0:	1101                	addi	sp,sp,-32
    80003db2:	ec06                	sd	ra,24(sp)
    80003db4:	e822                	sd	s0,16(sp)
    80003db6:	e426                	sd	s1,8(sp)
    80003db8:	e04a                	sd	s2,0(sp)
    80003dba:	1000                	addi	s0,sp,32
    80003dbc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003dbe:	415c                	lw	a5,4(a0)
    80003dc0:	0047d79b          	srliw	a5,a5,0x4
    80003dc4:	00034597          	auipc	a1,0x34
    80003dc8:	e545a583          	lw	a1,-428(a1) # 80037c18 <sb+0x18>
    80003dcc:	9dbd                	addw	a1,a1,a5
    80003dce:	4108                	lw	a0,0(a0)
    80003dd0:	00000097          	auipc	ra,0x0
    80003dd4:	8a6080e7          	jalr	-1882(ra) # 80003676 <bread>
    80003dd8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003dda:	05850793          	addi	a5,a0,88
    80003dde:	40c8                	lw	a0,4(s1)
    80003de0:	893d                	andi	a0,a0,15
    80003de2:	051a                	slli	a0,a0,0x6
    80003de4:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003de6:	04449703          	lh	a4,68(s1)
    80003dea:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003dee:	04649703          	lh	a4,70(s1)
    80003df2:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003df6:	04849703          	lh	a4,72(s1)
    80003dfa:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003dfe:	04a49703          	lh	a4,74(s1)
    80003e02:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003e06:	44f8                	lw	a4,76(s1)
    80003e08:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e0a:	03400613          	li	a2,52
    80003e0e:	05048593          	addi	a1,s1,80
    80003e12:	0531                	addi	a0,a0,12
    80003e14:	ffffd097          	auipc	ra,0xffffd
    80003e18:	f34080e7          	jalr	-204(ra) # 80000d48 <memmove>
  log_write(bp);
    80003e1c:	854a                	mv	a0,s2
    80003e1e:	00001097          	auipc	ra,0x1
    80003e22:	c0a080e7          	jalr	-1014(ra) # 80004a28 <log_write>
  brelse(bp);
    80003e26:	854a                	mv	a0,s2
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	97e080e7          	jalr	-1666(ra) # 800037a6 <brelse>
}
    80003e30:	60e2                	ld	ra,24(sp)
    80003e32:	6442                	ld	s0,16(sp)
    80003e34:	64a2                	ld	s1,8(sp)
    80003e36:	6902                	ld	s2,0(sp)
    80003e38:	6105                	addi	sp,sp,32
    80003e3a:	8082                	ret

0000000080003e3c <idup>:
{
    80003e3c:	1101                	addi	sp,sp,-32
    80003e3e:	ec06                	sd	ra,24(sp)
    80003e40:	e822                	sd	s0,16(sp)
    80003e42:	e426                	sd	s1,8(sp)
    80003e44:	1000                	addi	s0,sp,32
    80003e46:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e48:	00034517          	auipc	a0,0x34
    80003e4c:	dd850513          	addi	a0,a0,-552 # 80037c20 <itable>
    80003e50:	ffffd097          	auipc	ra,0xffffd
    80003e54:	d88080e7          	jalr	-632(ra) # 80000bd8 <acquire>
  ip->ref++;
    80003e58:	449c                	lw	a5,8(s1)
    80003e5a:	2785                	addiw	a5,a5,1
    80003e5c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e5e:	00034517          	auipc	a0,0x34
    80003e62:	dc250513          	addi	a0,a0,-574 # 80037c20 <itable>
    80003e66:	ffffd097          	auipc	ra,0xffffd
    80003e6a:	e3e080e7          	jalr	-450(ra) # 80000ca4 <release>
}
    80003e6e:	8526                	mv	a0,s1
    80003e70:	60e2                	ld	ra,24(sp)
    80003e72:	6442                	ld	s0,16(sp)
    80003e74:	64a2                	ld	s1,8(sp)
    80003e76:	6105                	addi	sp,sp,32
    80003e78:	8082                	ret

0000000080003e7a <ilock>:
{
    80003e7a:	1101                	addi	sp,sp,-32
    80003e7c:	ec06                	sd	ra,24(sp)
    80003e7e:	e822                	sd	s0,16(sp)
    80003e80:	e426                	sd	s1,8(sp)
    80003e82:	e04a                	sd	s2,0(sp)
    80003e84:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003e86:	c115                	beqz	a0,80003eaa <ilock+0x30>
    80003e88:	84aa                	mv	s1,a0
    80003e8a:	451c                	lw	a5,8(a0)
    80003e8c:	00f05f63          	blez	a5,80003eaa <ilock+0x30>
  acquiresleep(&ip->lock);
    80003e90:	0541                	addi	a0,a0,16
    80003e92:	00001097          	auipc	ra,0x1
    80003e96:	cb6080e7          	jalr	-842(ra) # 80004b48 <acquiresleep>
  if(ip->valid == 0){
    80003e9a:	40bc                	lw	a5,64(s1)
    80003e9c:	cf99                	beqz	a5,80003eba <ilock+0x40>
}
    80003e9e:	60e2                	ld	ra,24(sp)
    80003ea0:	6442                	ld	s0,16(sp)
    80003ea2:	64a2                	ld	s1,8(sp)
    80003ea4:	6902                	ld	s2,0(sp)
    80003ea6:	6105                	addi	sp,sp,32
    80003ea8:	8082                	ret
    panic("ilock");
    80003eaa:	00004517          	auipc	a0,0x4
    80003eae:	77650513          	addi	a0,a0,1910 # 80008620 <syscalls+0x1b8>
    80003eb2:	ffffc097          	auipc	ra,0xffffc
    80003eb6:	686080e7          	jalr	1670(ra) # 80000538 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003eba:	40dc                	lw	a5,4(s1)
    80003ebc:	0047d79b          	srliw	a5,a5,0x4
    80003ec0:	00034597          	auipc	a1,0x34
    80003ec4:	d585a583          	lw	a1,-680(a1) # 80037c18 <sb+0x18>
    80003ec8:	9dbd                	addw	a1,a1,a5
    80003eca:	4088                	lw	a0,0(s1)
    80003ecc:	fffff097          	auipc	ra,0xfffff
    80003ed0:	7aa080e7          	jalr	1962(ra) # 80003676 <bread>
    80003ed4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ed6:	05850593          	addi	a1,a0,88
    80003eda:	40dc                	lw	a5,4(s1)
    80003edc:	8bbd                	andi	a5,a5,15
    80003ede:	079a                	slli	a5,a5,0x6
    80003ee0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ee2:	00059783          	lh	a5,0(a1)
    80003ee6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003eea:	00259783          	lh	a5,2(a1)
    80003eee:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ef2:	00459783          	lh	a5,4(a1)
    80003ef6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003efa:	00659783          	lh	a5,6(a1)
    80003efe:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f02:	459c                	lw	a5,8(a1)
    80003f04:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f06:	03400613          	li	a2,52
    80003f0a:	05b1                	addi	a1,a1,12
    80003f0c:	05048513          	addi	a0,s1,80
    80003f10:	ffffd097          	auipc	ra,0xffffd
    80003f14:	e38080e7          	jalr	-456(ra) # 80000d48 <memmove>
    brelse(bp);
    80003f18:	854a                	mv	a0,s2
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	88c080e7          	jalr	-1908(ra) # 800037a6 <brelse>
    ip->valid = 1;
    80003f22:	4785                	li	a5,1
    80003f24:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f26:	04449783          	lh	a5,68(s1)
    80003f2a:	fbb5                	bnez	a5,80003e9e <ilock+0x24>
      panic("ilock: no type");
    80003f2c:	00004517          	auipc	a0,0x4
    80003f30:	6fc50513          	addi	a0,a0,1788 # 80008628 <syscalls+0x1c0>
    80003f34:	ffffc097          	auipc	ra,0xffffc
    80003f38:	604080e7          	jalr	1540(ra) # 80000538 <panic>

0000000080003f3c <iunlock>:
{
    80003f3c:	1101                	addi	sp,sp,-32
    80003f3e:	ec06                	sd	ra,24(sp)
    80003f40:	e822                	sd	s0,16(sp)
    80003f42:	e426                	sd	s1,8(sp)
    80003f44:	e04a                	sd	s2,0(sp)
    80003f46:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f48:	c905                	beqz	a0,80003f78 <iunlock+0x3c>
    80003f4a:	84aa                	mv	s1,a0
    80003f4c:	01050913          	addi	s2,a0,16
    80003f50:	854a                	mv	a0,s2
    80003f52:	00001097          	auipc	ra,0x1
    80003f56:	c90080e7          	jalr	-880(ra) # 80004be2 <holdingsleep>
    80003f5a:	cd19                	beqz	a0,80003f78 <iunlock+0x3c>
    80003f5c:	449c                	lw	a5,8(s1)
    80003f5e:	00f05d63          	blez	a5,80003f78 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003f62:	854a                	mv	a0,s2
    80003f64:	00001097          	auipc	ra,0x1
    80003f68:	c3a080e7          	jalr	-966(ra) # 80004b9e <releasesleep>
}
    80003f6c:	60e2                	ld	ra,24(sp)
    80003f6e:	6442                	ld	s0,16(sp)
    80003f70:	64a2                	ld	s1,8(sp)
    80003f72:	6902                	ld	s2,0(sp)
    80003f74:	6105                	addi	sp,sp,32
    80003f76:	8082                	ret
    panic("iunlock");
    80003f78:	00004517          	auipc	a0,0x4
    80003f7c:	6c050513          	addi	a0,a0,1728 # 80008638 <syscalls+0x1d0>
    80003f80:	ffffc097          	auipc	ra,0xffffc
    80003f84:	5b8080e7          	jalr	1464(ra) # 80000538 <panic>

0000000080003f88 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003f88:	7179                	addi	sp,sp,-48
    80003f8a:	f406                	sd	ra,40(sp)
    80003f8c:	f022                	sd	s0,32(sp)
    80003f8e:	ec26                	sd	s1,24(sp)
    80003f90:	e84a                	sd	s2,16(sp)
    80003f92:	e44e                	sd	s3,8(sp)
    80003f94:	e052                	sd	s4,0(sp)
    80003f96:	1800                	addi	s0,sp,48
    80003f98:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003f9a:	05050493          	addi	s1,a0,80
    80003f9e:	08050913          	addi	s2,a0,128
    80003fa2:	a021                	j	80003faa <itrunc+0x22>
    80003fa4:	0491                	addi	s1,s1,4
    80003fa6:	01248d63          	beq	s1,s2,80003fc0 <itrunc+0x38>
    if(ip->addrs[i]){
    80003faa:	408c                	lw	a1,0(s1)
    80003fac:	dde5                	beqz	a1,80003fa4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003fae:	0009a503          	lw	a0,0(s3)
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	90a080e7          	jalr	-1782(ra) # 800038bc <bfree>
      ip->addrs[i] = 0;
    80003fba:	0004a023          	sw	zero,0(s1)
    80003fbe:	b7dd                	j	80003fa4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003fc0:	0809a583          	lw	a1,128(s3)
    80003fc4:	e185                	bnez	a1,80003fe4 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003fc6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003fca:	854e                	mv	a0,s3
    80003fcc:	00000097          	auipc	ra,0x0
    80003fd0:	de4080e7          	jalr	-540(ra) # 80003db0 <iupdate>
}
    80003fd4:	70a2                	ld	ra,40(sp)
    80003fd6:	7402                	ld	s0,32(sp)
    80003fd8:	64e2                	ld	s1,24(sp)
    80003fda:	6942                	ld	s2,16(sp)
    80003fdc:	69a2                	ld	s3,8(sp)
    80003fde:	6a02                	ld	s4,0(sp)
    80003fe0:	6145                	addi	sp,sp,48
    80003fe2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003fe4:	0009a503          	lw	a0,0(s3)
    80003fe8:	fffff097          	auipc	ra,0xfffff
    80003fec:	68e080e7          	jalr	1678(ra) # 80003676 <bread>
    80003ff0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ff2:	05850493          	addi	s1,a0,88
    80003ff6:	45850913          	addi	s2,a0,1112
    80003ffa:	a021                	j	80004002 <itrunc+0x7a>
    80003ffc:	0491                	addi	s1,s1,4
    80003ffe:	01248b63          	beq	s1,s2,80004014 <itrunc+0x8c>
      if(a[j])
    80004002:	408c                	lw	a1,0(s1)
    80004004:	dde5                	beqz	a1,80003ffc <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004006:	0009a503          	lw	a0,0(s3)
    8000400a:	00000097          	auipc	ra,0x0
    8000400e:	8b2080e7          	jalr	-1870(ra) # 800038bc <bfree>
    80004012:	b7ed                	j	80003ffc <itrunc+0x74>
    brelse(bp);
    80004014:	8552                	mv	a0,s4
    80004016:	fffff097          	auipc	ra,0xfffff
    8000401a:	790080e7          	jalr	1936(ra) # 800037a6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000401e:	0809a583          	lw	a1,128(s3)
    80004022:	0009a503          	lw	a0,0(s3)
    80004026:	00000097          	auipc	ra,0x0
    8000402a:	896080e7          	jalr	-1898(ra) # 800038bc <bfree>
    ip->addrs[NDIRECT] = 0;
    8000402e:	0809a023          	sw	zero,128(s3)
    80004032:	bf51                	j	80003fc6 <itrunc+0x3e>

0000000080004034 <iput>:
{
    80004034:	1101                	addi	sp,sp,-32
    80004036:	ec06                	sd	ra,24(sp)
    80004038:	e822                	sd	s0,16(sp)
    8000403a:	e426                	sd	s1,8(sp)
    8000403c:	e04a                	sd	s2,0(sp)
    8000403e:	1000                	addi	s0,sp,32
    80004040:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004042:	00034517          	auipc	a0,0x34
    80004046:	bde50513          	addi	a0,a0,-1058 # 80037c20 <itable>
    8000404a:	ffffd097          	auipc	ra,0xffffd
    8000404e:	b8e080e7          	jalr	-1138(ra) # 80000bd8 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004052:	4498                	lw	a4,8(s1)
    80004054:	4785                	li	a5,1
    80004056:	02f70363          	beq	a4,a5,8000407c <iput+0x48>
  ip->ref--;
    8000405a:	449c                	lw	a5,8(s1)
    8000405c:	37fd                	addiw	a5,a5,-1
    8000405e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004060:	00034517          	auipc	a0,0x34
    80004064:	bc050513          	addi	a0,a0,-1088 # 80037c20 <itable>
    80004068:	ffffd097          	auipc	ra,0xffffd
    8000406c:	c3c080e7          	jalr	-964(ra) # 80000ca4 <release>
}
    80004070:	60e2                	ld	ra,24(sp)
    80004072:	6442                	ld	s0,16(sp)
    80004074:	64a2                	ld	s1,8(sp)
    80004076:	6902                	ld	s2,0(sp)
    80004078:	6105                	addi	sp,sp,32
    8000407a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000407c:	40bc                	lw	a5,64(s1)
    8000407e:	dff1                	beqz	a5,8000405a <iput+0x26>
    80004080:	04a49783          	lh	a5,74(s1)
    80004084:	fbf9                	bnez	a5,8000405a <iput+0x26>
    acquiresleep(&ip->lock);
    80004086:	01048913          	addi	s2,s1,16
    8000408a:	854a                	mv	a0,s2
    8000408c:	00001097          	auipc	ra,0x1
    80004090:	abc080e7          	jalr	-1348(ra) # 80004b48 <acquiresleep>
    release(&itable.lock);
    80004094:	00034517          	auipc	a0,0x34
    80004098:	b8c50513          	addi	a0,a0,-1140 # 80037c20 <itable>
    8000409c:	ffffd097          	auipc	ra,0xffffd
    800040a0:	c08080e7          	jalr	-1016(ra) # 80000ca4 <release>
    itrunc(ip);
    800040a4:	8526                	mv	a0,s1
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	ee2080e7          	jalr	-286(ra) # 80003f88 <itrunc>
    ip->type = 0;
    800040ae:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800040b2:	8526                	mv	a0,s1
    800040b4:	00000097          	auipc	ra,0x0
    800040b8:	cfc080e7          	jalr	-772(ra) # 80003db0 <iupdate>
    ip->valid = 0;
    800040bc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800040c0:	854a                	mv	a0,s2
    800040c2:	00001097          	auipc	ra,0x1
    800040c6:	adc080e7          	jalr	-1316(ra) # 80004b9e <releasesleep>
    acquire(&itable.lock);
    800040ca:	00034517          	auipc	a0,0x34
    800040ce:	b5650513          	addi	a0,a0,-1194 # 80037c20 <itable>
    800040d2:	ffffd097          	auipc	ra,0xffffd
    800040d6:	b06080e7          	jalr	-1274(ra) # 80000bd8 <acquire>
    800040da:	b741                	j	8000405a <iput+0x26>

00000000800040dc <iunlockput>:
{
    800040dc:	1101                	addi	sp,sp,-32
    800040de:	ec06                	sd	ra,24(sp)
    800040e0:	e822                	sd	s0,16(sp)
    800040e2:	e426                	sd	s1,8(sp)
    800040e4:	1000                	addi	s0,sp,32
    800040e6:	84aa                	mv	s1,a0
  iunlock(ip);
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	e54080e7          	jalr	-428(ra) # 80003f3c <iunlock>
  iput(ip);
    800040f0:	8526                	mv	a0,s1
    800040f2:	00000097          	auipc	ra,0x0
    800040f6:	f42080e7          	jalr	-190(ra) # 80004034 <iput>
}
    800040fa:	60e2                	ld	ra,24(sp)
    800040fc:	6442                	ld	s0,16(sp)
    800040fe:	64a2                	ld	s1,8(sp)
    80004100:	6105                	addi	sp,sp,32
    80004102:	8082                	ret

0000000080004104 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004104:	1141                	addi	sp,sp,-16
    80004106:	e422                	sd	s0,8(sp)
    80004108:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000410a:	411c                	lw	a5,0(a0)
    8000410c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000410e:	415c                	lw	a5,4(a0)
    80004110:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004112:	04451783          	lh	a5,68(a0)
    80004116:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000411a:	04a51783          	lh	a5,74(a0)
    8000411e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004122:	04c56783          	lwu	a5,76(a0)
    80004126:	e99c                	sd	a5,16(a1)
}
    80004128:	6422                	ld	s0,8(sp)
    8000412a:	0141                	addi	sp,sp,16
    8000412c:	8082                	ret

000000008000412e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000412e:	457c                	lw	a5,76(a0)
    80004130:	0ed7e963          	bltu	a5,a3,80004222 <readi+0xf4>
{
    80004134:	7159                	addi	sp,sp,-112
    80004136:	f486                	sd	ra,104(sp)
    80004138:	f0a2                	sd	s0,96(sp)
    8000413a:	eca6                	sd	s1,88(sp)
    8000413c:	e8ca                	sd	s2,80(sp)
    8000413e:	e4ce                	sd	s3,72(sp)
    80004140:	e0d2                	sd	s4,64(sp)
    80004142:	fc56                	sd	s5,56(sp)
    80004144:	f85a                	sd	s6,48(sp)
    80004146:	f45e                	sd	s7,40(sp)
    80004148:	f062                	sd	s8,32(sp)
    8000414a:	ec66                	sd	s9,24(sp)
    8000414c:	e86a                	sd	s10,16(sp)
    8000414e:	e46e                	sd	s11,8(sp)
    80004150:	1880                	addi	s0,sp,112
    80004152:	8baa                	mv	s7,a0
    80004154:	8c2e                	mv	s8,a1
    80004156:	8ab2                	mv	s5,a2
    80004158:	84b6                	mv	s1,a3
    8000415a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000415c:	9f35                	addw	a4,a4,a3
    return 0;
    8000415e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004160:	0ad76063          	bltu	a4,a3,80004200 <readi+0xd2>
  if(off + n > ip->size)
    80004164:	00e7f463          	bgeu	a5,a4,8000416c <readi+0x3e>
    n = ip->size - off;
    80004168:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000416c:	0a0b0963          	beqz	s6,8000421e <readi+0xf0>
    80004170:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004172:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004176:	5cfd                	li	s9,-1
    80004178:	a82d                	j	800041b2 <readi+0x84>
    8000417a:	020a1d93          	slli	s11,s4,0x20
    8000417e:	020ddd93          	srli	s11,s11,0x20
    80004182:	05890793          	addi	a5,s2,88
    80004186:	86ee                	mv	a3,s11
    80004188:	963e                	add	a2,a2,a5
    8000418a:	85d6                	mv	a1,s5
    8000418c:	8562                	mv	a0,s8
    8000418e:	ffffe097          	auipc	ra,0xffffe
    80004192:	612080e7          	jalr	1554(ra) # 800027a0 <either_copyout>
    80004196:	05950d63          	beq	a0,s9,800041f0 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000419a:	854a                	mv	a0,s2
    8000419c:	fffff097          	auipc	ra,0xfffff
    800041a0:	60a080e7          	jalr	1546(ra) # 800037a6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041a4:	013a09bb          	addw	s3,s4,s3
    800041a8:	009a04bb          	addw	s1,s4,s1
    800041ac:	9aee                	add	s5,s5,s11
    800041ae:	0569f763          	bgeu	s3,s6,800041fc <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800041b2:	000ba903          	lw	s2,0(s7)
    800041b6:	00a4d59b          	srliw	a1,s1,0xa
    800041ba:	855e                	mv	a0,s7
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	8ae080e7          	jalr	-1874(ra) # 80003a6a <bmap>
    800041c4:	0005059b          	sext.w	a1,a0
    800041c8:	854a                	mv	a0,s2
    800041ca:	fffff097          	auipc	ra,0xfffff
    800041ce:	4ac080e7          	jalr	1196(ra) # 80003676 <bread>
    800041d2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041d4:	3ff4f613          	andi	a2,s1,1023
    800041d8:	40cd07bb          	subw	a5,s10,a2
    800041dc:	413b073b          	subw	a4,s6,s3
    800041e0:	8a3e                	mv	s4,a5
    800041e2:	2781                	sext.w	a5,a5
    800041e4:	0007069b          	sext.w	a3,a4
    800041e8:	f8f6f9e3          	bgeu	a3,a5,8000417a <readi+0x4c>
    800041ec:	8a3a                	mv	s4,a4
    800041ee:	b771                	j	8000417a <readi+0x4c>
      brelse(bp);
    800041f0:	854a                	mv	a0,s2
    800041f2:	fffff097          	auipc	ra,0xfffff
    800041f6:	5b4080e7          	jalr	1460(ra) # 800037a6 <brelse>
      tot = -1;
    800041fa:	59fd                	li	s3,-1
  }
  return tot;
    800041fc:	0009851b          	sext.w	a0,s3
}
    80004200:	70a6                	ld	ra,104(sp)
    80004202:	7406                	ld	s0,96(sp)
    80004204:	64e6                	ld	s1,88(sp)
    80004206:	6946                	ld	s2,80(sp)
    80004208:	69a6                	ld	s3,72(sp)
    8000420a:	6a06                	ld	s4,64(sp)
    8000420c:	7ae2                	ld	s5,56(sp)
    8000420e:	7b42                	ld	s6,48(sp)
    80004210:	7ba2                	ld	s7,40(sp)
    80004212:	7c02                	ld	s8,32(sp)
    80004214:	6ce2                	ld	s9,24(sp)
    80004216:	6d42                	ld	s10,16(sp)
    80004218:	6da2                	ld	s11,8(sp)
    8000421a:	6165                	addi	sp,sp,112
    8000421c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000421e:	89da                	mv	s3,s6
    80004220:	bff1                	j	800041fc <readi+0xce>
    return 0;
    80004222:	4501                	li	a0,0
}
    80004224:	8082                	ret

0000000080004226 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004226:	457c                	lw	a5,76(a0)
    80004228:	10d7e863          	bltu	a5,a3,80004338 <writei+0x112>
{
    8000422c:	7159                	addi	sp,sp,-112
    8000422e:	f486                	sd	ra,104(sp)
    80004230:	f0a2                	sd	s0,96(sp)
    80004232:	eca6                	sd	s1,88(sp)
    80004234:	e8ca                	sd	s2,80(sp)
    80004236:	e4ce                	sd	s3,72(sp)
    80004238:	e0d2                	sd	s4,64(sp)
    8000423a:	fc56                	sd	s5,56(sp)
    8000423c:	f85a                	sd	s6,48(sp)
    8000423e:	f45e                	sd	s7,40(sp)
    80004240:	f062                	sd	s8,32(sp)
    80004242:	ec66                	sd	s9,24(sp)
    80004244:	e86a                	sd	s10,16(sp)
    80004246:	e46e                	sd	s11,8(sp)
    80004248:	1880                	addi	s0,sp,112
    8000424a:	8b2a                	mv	s6,a0
    8000424c:	8c2e                	mv	s8,a1
    8000424e:	8ab2                	mv	s5,a2
    80004250:	8936                	mv	s2,a3
    80004252:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004254:	00e687bb          	addw	a5,a3,a4
    80004258:	0ed7e263          	bltu	a5,a3,8000433c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000425c:	00043737          	lui	a4,0x43
    80004260:	0ef76063          	bltu	a4,a5,80004340 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004264:	0c0b8863          	beqz	s7,80004334 <writei+0x10e>
    80004268:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000426a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000426e:	5cfd                	li	s9,-1
    80004270:	a091                	j	800042b4 <writei+0x8e>
    80004272:	02099d93          	slli	s11,s3,0x20
    80004276:	020ddd93          	srli	s11,s11,0x20
    8000427a:	05848793          	addi	a5,s1,88
    8000427e:	86ee                	mv	a3,s11
    80004280:	8656                	mv	a2,s5
    80004282:	85e2                	mv	a1,s8
    80004284:	953e                	add	a0,a0,a5
    80004286:	ffffe097          	auipc	ra,0xffffe
    8000428a:	570080e7          	jalr	1392(ra) # 800027f6 <either_copyin>
    8000428e:	07950263          	beq	a0,s9,800042f2 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004292:	8526                	mv	a0,s1
    80004294:	00000097          	auipc	ra,0x0
    80004298:	794080e7          	jalr	1940(ra) # 80004a28 <log_write>
    brelse(bp);
    8000429c:	8526                	mv	a0,s1
    8000429e:	fffff097          	auipc	ra,0xfffff
    800042a2:	508080e7          	jalr	1288(ra) # 800037a6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042a6:	01498a3b          	addw	s4,s3,s4
    800042aa:	0129893b          	addw	s2,s3,s2
    800042ae:	9aee                	add	s5,s5,s11
    800042b0:	057a7663          	bgeu	s4,s7,800042fc <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800042b4:	000b2483          	lw	s1,0(s6)
    800042b8:	00a9559b          	srliw	a1,s2,0xa
    800042bc:	855a                	mv	a0,s6
    800042be:	fffff097          	auipc	ra,0xfffff
    800042c2:	7ac080e7          	jalr	1964(ra) # 80003a6a <bmap>
    800042c6:	0005059b          	sext.w	a1,a0
    800042ca:	8526                	mv	a0,s1
    800042cc:	fffff097          	auipc	ra,0xfffff
    800042d0:	3aa080e7          	jalr	938(ra) # 80003676 <bread>
    800042d4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042d6:	3ff97513          	andi	a0,s2,1023
    800042da:	40ad07bb          	subw	a5,s10,a0
    800042de:	414b873b          	subw	a4,s7,s4
    800042e2:	89be                	mv	s3,a5
    800042e4:	2781                	sext.w	a5,a5
    800042e6:	0007069b          	sext.w	a3,a4
    800042ea:	f8f6f4e3          	bgeu	a3,a5,80004272 <writei+0x4c>
    800042ee:	89ba                	mv	s3,a4
    800042f0:	b749                	j	80004272 <writei+0x4c>
      brelse(bp);
    800042f2:	8526                	mv	a0,s1
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	4b2080e7          	jalr	1202(ra) # 800037a6 <brelse>
  }

  if(off > ip->size)
    800042fc:	04cb2783          	lw	a5,76(s6)
    80004300:	0127f463          	bgeu	a5,s2,80004308 <writei+0xe2>
    ip->size = off;
    80004304:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004308:	855a                	mv	a0,s6
    8000430a:	00000097          	auipc	ra,0x0
    8000430e:	aa6080e7          	jalr	-1370(ra) # 80003db0 <iupdate>

  return tot;
    80004312:	000a051b          	sext.w	a0,s4
}
    80004316:	70a6                	ld	ra,104(sp)
    80004318:	7406                	ld	s0,96(sp)
    8000431a:	64e6                	ld	s1,88(sp)
    8000431c:	6946                	ld	s2,80(sp)
    8000431e:	69a6                	ld	s3,72(sp)
    80004320:	6a06                	ld	s4,64(sp)
    80004322:	7ae2                	ld	s5,56(sp)
    80004324:	7b42                	ld	s6,48(sp)
    80004326:	7ba2                	ld	s7,40(sp)
    80004328:	7c02                	ld	s8,32(sp)
    8000432a:	6ce2                	ld	s9,24(sp)
    8000432c:	6d42                	ld	s10,16(sp)
    8000432e:	6da2                	ld	s11,8(sp)
    80004330:	6165                	addi	sp,sp,112
    80004332:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004334:	8a5e                	mv	s4,s7
    80004336:	bfc9                	j	80004308 <writei+0xe2>
    return -1;
    80004338:	557d                	li	a0,-1
}
    8000433a:	8082                	ret
    return -1;
    8000433c:	557d                	li	a0,-1
    8000433e:	bfe1                	j	80004316 <writei+0xf0>
    return -1;
    80004340:	557d                	li	a0,-1
    80004342:	bfd1                	j	80004316 <writei+0xf0>

0000000080004344 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004344:	1141                	addi	sp,sp,-16
    80004346:	e406                	sd	ra,8(sp)
    80004348:	e022                	sd	s0,0(sp)
    8000434a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000434c:	4639                	li	a2,14
    8000434e:	ffffd097          	auipc	ra,0xffffd
    80004352:	a76080e7          	jalr	-1418(ra) # 80000dc4 <strncmp>
}
    80004356:	60a2                	ld	ra,8(sp)
    80004358:	6402                	ld	s0,0(sp)
    8000435a:	0141                	addi	sp,sp,16
    8000435c:	8082                	ret

000000008000435e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000435e:	7139                	addi	sp,sp,-64
    80004360:	fc06                	sd	ra,56(sp)
    80004362:	f822                	sd	s0,48(sp)
    80004364:	f426                	sd	s1,40(sp)
    80004366:	f04a                	sd	s2,32(sp)
    80004368:	ec4e                	sd	s3,24(sp)
    8000436a:	e852                	sd	s4,16(sp)
    8000436c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000436e:	04451703          	lh	a4,68(a0)
    80004372:	4785                	li	a5,1
    80004374:	00f71a63          	bne	a4,a5,80004388 <dirlookup+0x2a>
    80004378:	892a                	mv	s2,a0
    8000437a:	89ae                	mv	s3,a1
    8000437c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000437e:	457c                	lw	a5,76(a0)
    80004380:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004382:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004384:	e79d                	bnez	a5,800043b2 <dirlookup+0x54>
    80004386:	a8a5                	j	800043fe <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004388:	00004517          	auipc	a0,0x4
    8000438c:	2b850513          	addi	a0,a0,696 # 80008640 <syscalls+0x1d8>
    80004390:	ffffc097          	auipc	ra,0xffffc
    80004394:	1a8080e7          	jalr	424(ra) # 80000538 <panic>
      panic("dirlookup read");
    80004398:	00004517          	auipc	a0,0x4
    8000439c:	2c050513          	addi	a0,a0,704 # 80008658 <syscalls+0x1f0>
    800043a0:	ffffc097          	auipc	ra,0xffffc
    800043a4:	198080e7          	jalr	408(ra) # 80000538 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043a8:	24c1                	addiw	s1,s1,16
    800043aa:	04c92783          	lw	a5,76(s2)
    800043ae:	04f4f763          	bgeu	s1,a5,800043fc <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043b2:	4741                	li	a4,16
    800043b4:	86a6                	mv	a3,s1
    800043b6:	fc040613          	addi	a2,s0,-64
    800043ba:	4581                	li	a1,0
    800043bc:	854a                	mv	a0,s2
    800043be:	00000097          	auipc	ra,0x0
    800043c2:	d70080e7          	jalr	-656(ra) # 8000412e <readi>
    800043c6:	47c1                	li	a5,16
    800043c8:	fcf518e3          	bne	a0,a5,80004398 <dirlookup+0x3a>
    if(de.inum == 0)
    800043cc:	fc045783          	lhu	a5,-64(s0)
    800043d0:	dfe1                	beqz	a5,800043a8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800043d2:	fc240593          	addi	a1,s0,-62
    800043d6:	854e                	mv	a0,s3
    800043d8:	00000097          	auipc	ra,0x0
    800043dc:	f6c080e7          	jalr	-148(ra) # 80004344 <namecmp>
    800043e0:	f561                	bnez	a0,800043a8 <dirlookup+0x4a>
      if(poff)
    800043e2:	000a0463          	beqz	s4,800043ea <dirlookup+0x8c>
        *poff = off;
    800043e6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800043ea:	fc045583          	lhu	a1,-64(s0)
    800043ee:	00092503          	lw	a0,0(s2)
    800043f2:	fffff097          	auipc	ra,0xfffff
    800043f6:	754080e7          	jalr	1876(ra) # 80003b46 <iget>
    800043fa:	a011                	j	800043fe <dirlookup+0xa0>
  return 0;
    800043fc:	4501                	li	a0,0
}
    800043fe:	70e2                	ld	ra,56(sp)
    80004400:	7442                	ld	s0,48(sp)
    80004402:	74a2                	ld	s1,40(sp)
    80004404:	7902                	ld	s2,32(sp)
    80004406:	69e2                	ld	s3,24(sp)
    80004408:	6a42                	ld	s4,16(sp)
    8000440a:	6121                	addi	sp,sp,64
    8000440c:	8082                	ret

000000008000440e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000440e:	711d                	addi	sp,sp,-96
    80004410:	ec86                	sd	ra,88(sp)
    80004412:	e8a2                	sd	s0,80(sp)
    80004414:	e4a6                	sd	s1,72(sp)
    80004416:	e0ca                	sd	s2,64(sp)
    80004418:	fc4e                	sd	s3,56(sp)
    8000441a:	f852                	sd	s4,48(sp)
    8000441c:	f456                	sd	s5,40(sp)
    8000441e:	f05a                	sd	s6,32(sp)
    80004420:	ec5e                	sd	s7,24(sp)
    80004422:	e862                	sd	s8,16(sp)
    80004424:	e466                	sd	s9,8(sp)
    80004426:	1080                	addi	s0,sp,96
    80004428:	84aa                	mv	s1,a0
    8000442a:	8aae                	mv	s5,a1
    8000442c:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000442e:	00054703          	lbu	a4,0(a0)
    80004432:	02f00793          	li	a5,47
    80004436:	02f70363          	beq	a4,a5,8000445c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000443a:	ffffd097          	auipc	ra,0xffffd
    8000443e:	61c080e7          	jalr	1564(ra) # 80001a56 <myproc>
    80004442:	15053503          	ld	a0,336(a0)
    80004446:	00000097          	auipc	ra,0x0
    8000444a:	9f6080e7          	jalr	-1546(ra) # 80003e3c <idup>
    8000444e:	89aa                	mv	s3,a0
  while(*path == '/')
    80004450:	02f00913          	li	s2,47
  len = path - s;
    80004454:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004456:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004458:	4b85                	li	s7,1
    8000445a:	a865                	j	80004512 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000445c:	4585                	li	a1,1
    8000445e:	4505                	li	a0,1
    80004460:	fffff097          	auipc	ra,0xfffff
    80004464:	6e6080e7          	jalr	1766(ra) # 80003b46 <iget>
    80004468:	89aa                	mv	s3,a0
    8000446a:	b7dd                	j	80004450 <namex+0x42>
      iunlockput(ip);
    8000446c:	854e                	mv	a0,s3
    8000446e:	00000097          	auipc	ra,0x0
    80004472:	c6e080e7          	jalr	-914(ra) # 800040dc <iunlockput>
      return 0;
    80004476:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004478:	854e                	mv	a0,s3
    8000447a:	60e6                	ld	ra,88(sp)
    8000447c:	6446                	ld	s0,80(sp)
    8000447e:	64a6                	ld	s1,72(sp)
    80004480:	6906                	ld	s2,64(sp)
    80004482:	79e2                	ld	s3,56(sp)
    80004484:	7a42                	ld	s4,48(sp)
    80004486:	7aa2                	ld	s5,40(sp)
    80004488:	7b02                	ld	s6,32(sp)
    8000448a:	6be2                	ld	s7,24(sp)
    8000448c:	6c42                	ld	s8,16(sp)
    8000448e:	6ca2                	ld	s9,8(sp)
    80004490:	6125                	addi	sp,sp,96
    80004492:	8082                	ret
      iunlock(ip);
    80004494:	854e                	mv	a0,s3
    80004496:	00000097          	auipc	ra,0x0
    8000449a:	aa6080e7          	jalr	-1370(ra) # 80003f3c <iunlock>
      return ip;
    8000449e:	bfe9                	j	80004478 <namex+0x6a>
      iunlockput(ip);
    800044a0:	854e                	mv	a0,s3
    800044a2:	00000097          	auipc	ra,0x0
    800044a6:	c3a080e7          	jalr	-966(ra) # 800040dc <iunlockput>
      return 0;
    800044aa:	89e6                	mv	s3,s9
    800044ac:	b7f1                	j	80004478 <namex+0x6a>
  len = path - s;
    800044ae:	40b48633          	sub	a2,s1,a1
    800044b2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800044b6:	099c5463          	bge	s8,s9,8000453e <namex+0x130>
    memmove(name, s, DIRSIZ);
    800044ba:	4639                	li	a2,14
    800044bc:	8552                	mv	a0,s4
    800044be:	ffffd097          	auipc	ra,0xffffd
    800044c2:	88a080e7          	jalr	-1910(ra) # 80000d48 <memmove>
  while(*path == '/')
    800044c6:	0004c783          	lbu	a5,0(s1)
    800044ca:	01279763          	bne	a5,s2,800044d8 <namex+0xca>
    path++;
    800044ce:	0485                	addi	s1,s1,1
  while(*path == '/')
    800044d0:	0004c783          	lbu	a5,0(s1)
    800044d4:	ff278de3          	beq	a5,s2,800044ce <namex+0xc0>
    ilock(ip);
    800044d8:	854e                	mv	a0,s3
    800044da:	00000097          	auipc	ra,0x0
    800044de:	9a0080e7          	jalr	-1632(ra) # 80003e7a <ilock>
    if(ip->type != T_DIR){
    800044e2:	04499783          	lh	a5,68(s3)
    800044e6:	f97793e3          	bne	a5,s7,8000446c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800044ea:	000a8563          	beqz	s5,800044f4 <namex+0xe6>
    800044ee:	0004c783          	lbu	a5,0(s1)
    800044f2:	d3cd                	beqz	a5,80004494 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800044f4:	865a                	mv	a2,s6
    800044f6:	85d2                	mv	a1,s4
    800044f8:	854e                	mv	a0,s3
    800044fa:	00000097          	auipc	ra,0x0
    800044fe:	e64080e7          	jalr	-412(ra) # 8000435e <dirlookup>
    80004502:	8caa                	mv	s9,a0
    80004504:	dd51                	beqz	a0,800044a0 <namex+0x92>
    iunlockput(ip);
    80004506:	854e                	mv	a0,s3
    80004508:	00000097          	auipc	ra,0x0
    8000450c:	bd4080e7          	jalr	-1068(ra) # 800040dc <iunlockput>
    ip = next;
    80004510:	89e6                	mv	s3,s9
  while(*path == '/')
    80004512:	0004c783          	lbu	a5,0(s1)
    80004516:	05279763          	bne	a5,s2,80004564 <namex+0x156>
    path++;
    8000451a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000451c:	0004c783          	lbu	a5,0(s1)
    80004520:	ff278de3          	beq	a5,s2,8000451a <namex+0x10c>
  if(*path == 0)
    80004524:	c79d                	beqz	a5,80004552 <namex+0x144>
    path++;
    80004526:	85a6                	mv	a1,s1
  len = path - s;
    80004528:	8cda                	mv	s9,s6
    8000452a:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000452c:	01278963          	beq	a5,s2,8000453e <namex+0x130>
    80004530:	dfbd                	beqz	a5,800044ae <namex+0xa0>
    path++;
    80004532:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004534:	0004c783          	lbu	a5,0(s1)
    80004538:	ff279ce3          	bne	a5,s2,80004530 <namex+0x122>
    8000453c:	bf8d                	j	800044ae <namex+0xa0>
    memmove(name, s, len);
    8000453e:	2601                	sext.w	a2,a2
    80004540:	8552                	mv	a0,s4
    80004542:	ffffd097          	auipc	ra,0xffffd
    80004546:	806080e7          	jalr	-2042(ra) # 80000d48 <memmove>
    name[len] = 0;
    8000454a:	9cd2                	add	s9,s9,s4
    8000454c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004550:	bf9d                	j	800044c6 <namex+0xb8>
  if(nameiparent){
    80004552:	f20a83e3          	beqz	s5,80004478 <namex+0x6a>
    iput(ip);
    80004556:	854e                	mv	a0,s3
    80004558:	00000097          	auipc	ra,0x0
    8000455c:	adc080e7          	jalr	-1316(ra) # 80004034 <iput>
    return 0;
    80004560:	4981                	li	s3,0
    80004562:	bf19                	j	80004478 <namex+0x6a>
  if(*path == 0)
    80004564:	d7fd                	beqz	a5,80004552 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004566:	0004c783          	lbu	a5,0(s1)
    8000456a:	85a6                	mv	a1,s1
    8000456c:	b7d1                	j	80004530 <namex+0x122>

000000008000456e <dirlink>:
{
    8000456e:	7139                	addi	sp,sp,-64
    80004570:	fc06                	sd	ra,56(sp)
    80004572:	f822                	sd	s0,48(sp)
    80004574:	f426                	sd	s1,40(sp)
    80004576:	f04a                	sd	s2,32(sp)
    80004578:	ec4e                	sd	s3,24(sp)
    8000457a:	e852                	sd	s4,16(sp)
    8000457c:	0080                	addi	s0,sp,64
    8000457e:	892a                	mv	s2,a0
    80004580:	8a2e                	mv	s4,a1
    80004582:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004584:	4601                	li	a2,0
    80004586:	00000097          	auipc	ra,0x0
    8000458a:	dd8080e7          	jalr	-552(ra) # 8000435e <dirlookup>
    8000458e:	e93d                	bnez	a0,80004604 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004590:	04c92483          	lw	s1,76(s2)
    80004594:	c49d                	beqz	s1,800045c2 <dirlink+0x54>
    80004596:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004598:	4741                	li	a4,16
    8000459a:	86a6                	mv	a3,s1
    8000459c:	fc040613          	addi	a2,s0,-64
    800045a0:	4581                	li	a1,0
    800045a2:	854a                	mv	a0,s2
    800045a4:	00000097          	auipc	ra,0x0
    800045a8:	b8a080e7          	jalr	-1142(ra) # 8000412e <readi>
    800045ac:	47c1                	li	a5,16
    800045ae:	06f51163          	bne	a0,a5,80004610 <dirlink+0xa2>
    if(de.inum == 0)
    800045b2:	fc045783          	lhu	a5,-64(s0)
    800045b6:	c791                	beqz	a5,800045c2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045b8:	24c1                	addiw	s1,s1,16
    800045ba:	04c92783          	lw	a5,76(s2)
    800045be:	fcf4ede3          	bltu	s1,a5,80004598 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800045c2:	4639                	li	a2,14
    800045c4:	85d2                	mv	a1,s4
    800045c6:	fc240513          	addi	a0,s0,-62
    800045ca:	ffffd097          	auipc	ra,0xffffd
    800045ce:	836080e7          	jalr	-1994(ra) # 80000e00 <strncpy>
  de.inum = inum;
    800045d2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045d6:	4741                	li	a4,16
    800045d8:	86a6                	mv	a3,s1
    800045da:	fc040613          	addi	a2,s0,-64
    800045de:	4581                	li	a1,0
    800045e0:	854a                	mv	a0,s2
    800045e2:	00000097          	auipc	ra,0x0
    800045e6:	c44080e7          	jalr	-956(ra) # 80004226 <writei>
    800045ea:	872a                	mv	a4,a0
    800045ec:	47c1                	li	a5,16
  return 0;
    800045ee:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045f0:	02f71863          	bne	a4,a5,80004620 <dirlink+0xb2>
}
    800045f4:	70e2                	ld	ra,56(sp)
    800045f6:	7442                	ld	s0,48(sp)
    800045f8:	74a2                	ld	s1,40(sp)
    800045fa:	7902                	ld	s2,32(sp)
    800045fc:	69e2                	ld	s3,24(sp)
    800045fe:	6a42                	ld	s4,16(sp)
    80004600:	6121                	addi	sp,sp,64
    80004602:	8082                	ret
    iput(ip);
    80004604:	00000097          	auipc	ra,0x0
    80004608:	a30080e7          	jalr	-1488(ra) # 80004034 <iput>
    return -1;
    8000460c:	557d                	li	a0,-1
    8000460e:	b7dd                	j	800045f4 <dirlink+0x86>
      panic("dirlink read");
    80004610:	00004517          	auipc	a0,0x4
    80004614:	05850513          	addi	a0,a0,88 # 80008668 <syscalls+0x200>
    80004618:	ffffc097          	auipc	ra,0xffffc
    8000461c:	f20080e7          	jalr	-224(ra) # 80000538 <panic>
    panic("dirlink");
    80004620:	00004517          	auipc	a0,0x4
    80004624:	15850513          	addi	a0,a0,344 # 80008778 <syscalls+0x310>
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	f10080e7          	jalr	-240(ra) # 80000538 <panic>

0000000080004630 <namei>:

struct inode*
namei(char *path)
{
    80004630:	1101                	addi	sp,sp,-32
    80004632:	ec06                	sd	ra,24(sp)
    80004634:	e822                	sd	s0,16(sp)
    80004636:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004638:	fe040613          	addi	a2,s0,-32
    8000463c:	4581                	li	a1,0
    8000463e:	00000097          	auipc	ra,0x0
    80004642:	dd0080e7          	jalr	-560(ra) # 8000440e <namex>
}
    80004646:	60e2                	ld	ra,24(sp)
    80004648:	6442                	ld	s0,16(sp)
    8000464a:	6105                	addi	sp,sp,32
    8000464c:	8082                	ret

000000008000464e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000464e:	1141                	addi	sp,sp,-16
    80004650:	e406                	sd	ra,8(sp)
    80004652:	e022                	sd	s0,0(sp)
    80004654:	0800                	addi	s0,sp,16
    80004656:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004658:	4585                	li	a1,1
    8000465a:	00000097          	auipc	ra,0x0
    8000465e:	db4080e7          	jalr	-588(ra) # 8000440e <namex>
}
    80004662:	60a2                	ld	ra,8(sp)
    80004664:	6402                	ld	s0,0(sp)
    80004666:	0141                	addi	sp,sp,16
    80004668:	8082                	ret

000000008000466a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000466a:	1101                	addi	sp,sp,-32
    8000466c:	ec06                	sd	ra,24(sp)
    8000466e:	e822                	sd	s0,16(sp)
    80004670:	e426                	sd	s1,8(sp)
    80004672:	e04a                	sd	s2,0(sp)
    80004674:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004676:	00035917          	auipc	s2,0x35
    8000467a:	05290913          	addi	s2,s2,82 # 800396c8 <log>
    8000467e:	01892583          	lw	a1,24(s2)
    80004682:	02892503          	lw	a0,40(s2)
    80004686:	fffff097          	auipc	ra,0xfffff
    8000468a:	ff0080e7          	jalr	-16(ra) # 80003676 <bread>
    8000468e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004690:	02c92683          	lw	a3,44(s2)
    80004694:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004696:	02d05863          	blez	a3,800046c6 <write_head+0x5c>
    8000469a:	00035797          	auipc	a5,0x35
    8000469e:	05e78793          	addi	a5,a5,94 # 800396f8 <log+0x30>
    800046a2:	05c50713          	addi	a4,a0,92
    800046a6:	36fd                	addiw	a3,a3,-1
    800046a8:	02069613          	slli	a2,a3,0x20
    800046ac:	01e65693          	srli	a3,a2,0x1e
    800046b0:	00035617          	auipc	a2,0x35
    800046b4:	04c60613          	addi	a2,a2,76 # 800396fc <log+0x34>
    800046b8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800046ba:	4390                	lw	a2,0(a5)
    800046bc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046be:	0791                	addi	a5,a5,4
    800046c0:	0711                	addi	a4,a4,4
    800046c2:	fed79ce3          	bne	a5,a3,800046ba <write_head+0x50>
  }
  bwrite(buf);
    800046c6:	8526                	mv	a0,s1
    800046c8:	fffff097          	auipc	ra,0xfffff
    800046cc:	0a0080e7          	jalr	160(ra) # 80003768 <bwrite>
  brelse(buf);
    800046d0:	8526                	mv	a0,s1
    800046d2:	fffff097          	auipc	ra,0xfffff
    800046d6:	0d4080e7          	jalr	212(ra) # 800037a6 <brelse>
}
    800046da:	60e2                	ld	ra,24(sp)
    800046dc:	6442                	ld	s0,16(sp)
    800046de:	64a2                	ld	s1,8(sp)
    800046e0:	6902                	ld	s2,0(sp)
    800046e2:	6105                	addi	sp,sp,32
    800046e4:	8082                	ret

00000000800046e6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800046e6:	00035797          	auipc	a5,0x35
    800046ea:	00e7a783          	lw	a5,14(a5) # 800396f4 <log+0x2c>
    800046ee:	0af05d63          	blez	a5,800047a8 <install_trans+0xc2>
{
    800046f2:	7139                	addi	sp,sp,-64
    800046f4:	fc06                	sd	ra,56(sp)
    800046f6:	f822                	sd	s0,48(sp)
    800046f8:	f426                	sd	s1,40(sp)
    800046fa:	f04a                	sd	s2,32(sp)
    800046fc:	ec4e                	sd	s3,24(sp)
    800046fe:	e852                	sd	s4,16(sp)
    80004700:	e456                	sd	s5,8(sp)
    80004702:	e05a                	sd	s6,0(sp)
    80004704:	0080                	addi	s0,sp,64
    80004706:	8b2a                	mv	s6,a0
    80004708:	00035a97          	auipc	s5,0x35
    8000470c:	ff0a8a93          	addi	s5,s5,-16 # 800396f8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004710:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004712:	00035997          	auipc	s3,0x35
    80004716:	fb698993          	addi	s3,s3,-74 # 800396c8 <log>
    8000471a:	a00d                	j	8000473c <install_trans+0x56>
    brelse(lbuf);
    8000471c:	854a                	mv	a0,s2
    8000471e:	fffff097          	auipc	ra,0xfffff
    80004722:	088080e7          	jalr	136(ra) # 800037a6 <brelse>
    brelse(dbuf);
    80004726:	8526                	mv	a0,s1
    80004728:	fffff097          	auipc	ra,0xfffff
    8000472c:	07e080e7          	jalr	126(ra) # 800037a6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004730:	2a05                	addiw	s4,s4,1
    80004732:	0a91                	addi	s5,s5,4
    80004734:	02c9a783          	lw	a5,44(s3)
    80004738:	04fa5e63          	bge	s4,a5,80004794 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000473c:	0189a583          	lw	a1,24(s3)
    80004740:	014585bb          	addw	a1,a1,s4
    80004744:	2585                	addiw	a1,a1,1
    80004746:	0289a503          	lw	a0,40(s3)
    8000474a:	fffff097          	auipc	ra,0xfffff
    8000474e:	f2c080e7          	jalr	-212(ra) # 80003676 <bread>
    80004752:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004754:	000aa583          	lw	a1,0(s5)
    80004758:	0289a503          	lw	a0,40(s3)
    8000475c:	fffff097          	auipc	ra,0xfffff
    80004760:	f1a080e7          	jalr	-230(ra) # 80003676 <bread>
    80004764:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004766:	40000613          	li	a2,1024
    8000476a:	05890593          	addi	a1,s2,88
    8000476e:	05850513          	addi	a0,a0,88
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	5d6080e7          	jalr	1494(ra) # 80000d48 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000477a:	8526                	mv	a0,s1
    8000477c:	fffff097          	auipc	ra,0xfffff
    80004780:	fec080e7          	jalr	-20(ra) # 80003768 <bwrite>
    if(recovering == 0)
    80004784:	f80b1ce3          	bnez	s6,8000471c <install_trans+0x36>
      bunpin(dbuf);
    80004788:	8526                	mv	a0,s1
    8000478a:	fffff097          	auipc	ra,0xfffff
    8000478e:	0f6080e7          	jalr	246(ra) # 80003880 <bunpin>
    80004792:	b769                	j	8000471c <install_trans+0x36>
}
    80004794:	70e2                	ld	ra,56(sp)
    80004796:	7442                	ld	s0,48(sp)
    80004798:	74a2                	ld	s1,40(sp)
    8000479a:	7902                	ld	s2,32(sp)
    8000479c:	69e2                	ld	s3,24(sp)
    8000479e:	6a42                	ld	s4,16(sp)
    800047a0:	6aa2                	ld	s5,8(sp)
    800047a2:	6b02                	ld	s6,0(sp)
    800047a4:	6121                	addi	sp,sp,64
    800047a6:	8082                	ret
    800047a8:	8082                	ret

00000000800047aa <initlog>:
{
    800047aa:	7179                	addi	sp,sp,-48
    800047ac:	f406                	sd	ra,40(sp)
    800047ae:	f022                	sd	s0,32(sp)
    800047b0:	ec26                	sd	s1,24(sp)
    800047b2:	e84a                	sd	s2,16(sp)
    800047b4:	e44e                	sd	s3,8(sp)
    800047b6:	1800                	addi	s0,sp,48
    800047b8:	892a                	mv	s2,a0
    800047ba:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800047bc:	00035497          	auipc	s1,0x35
    800047c0:	f0c48493          	addi	s1,s1,-244 # 800396c8 <log>
    800047c4:	00004597          	auipc	a1,0x4
    800047c8:	eb458593          	addi	a1,a1,-332 # 80008678 <syscalls+0x210>
    800047cc:	8526                	mv	a0,s1
    800047ce:	ffffc097          	auipc	ra,0xffffc
    800047d2:	372080e7          	jalr	882(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    800047d6:	0149a583          	lw	a1,20(s3)
    800047da:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800047dc:	0109a783          	lw	a5,16(s3)
    800047e0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800047e2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800047e6:	854a                	mv	a0,s2
    800047e8:	fffff097          	auipc	ra,0xfffff
    800047ec:	e8e080e7          	jalr	-370(ra) # 80003676 <bread>
  log.lh.n = lh->n;
    800047f0:	4d34                	lw	a3,88(a0)
    800047f2:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800047f4:	02d05663          	blez	a3,80004820 <initlog+0x76>
    800047f8:	05c50793          	addi	a5,a0,92
    800047fc:	00035717          	auipc	a4,0x35
    80004800:	efc70713          	addi	a4,a4,-260 # 800396f8 <log+0x30>
    80004804:	36fd                	addiw	a3,a3,-1
    80004806:	02069613          	slli	a2,a3,0x20
    8000480a:	01e65693          	srli	a3,a2,0x1e
    8000480e:	06050613          	addi	a2,a0,96
    80004812:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004814:	4390                	lw	a2,0(a5)
    80004816:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004818:	0791                	addi	a5,a5,4
    8000481a:	0711                	addi	a4,a4,4
    8000481c:	fed79ce3          	bne	a5,a3,80004814 <initlog+0x6a>
  brelse(buf);
    80004820:	fffff097          	auipc	ra,0xfffff
    80004824:	f86080e7          	jalr	-122(ra) # 800037a6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004828:	4505                	li	a0,1
    8000482a:	00000097          	auipc	ra,0x0
    8000482e:	ebc080e7          	jalr	-324(ra) # 800046e6 <install_trans>
  log.lh.n = 0;
    80004832:	00035797          	auipc	a5,0x35
    80004836:	ec07a123          	sw	zero,-318(a5) # 800396f4 <log+0x2c>
  write_head(); // clear the log
    8000483a:	00000097          	auipc	ra,0x0
    8000483e:	e30080e7          	jalr	-464(ra) # 8000466a <write_head>
}
    80004842:	70a2                	ld	ra,40(sp)
    80004844:	7402                	ld	s0,32(sp)
    80004846:	64e2                	ld	s1,24(sp)
    80004848:	6942                	ld	s2,16(sp)
    8000484a:	69a2                	ld	s3,8(sp)
    8000484c:	6145                	addi	sp,sp,48
    8000484e:	8082                	ret

0000000080004850 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004850:	1101                	addi	sp,sp,-32
    80004852:	ec06                	sd	ra,24(sp)
    80004854:	e822                	sd	s0,16(sp)
    80004856:	e426                	sd	s1,8(sp)
    80004858:	e04a                	sd	s2,0(sp)
    8000485a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000485c:	00035517          	auipc	a0,0x35
    80004860:	e6c50513          	addi	a0,a0,-404 # 800396c8 <log>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	374080e7          	jalr	884(ra) # 80000bd8 <acquire>
  while(1){
    if(log.committing){
    8000486c:	00035497          	auipc	s1,0x35
    80004870:	e5c48493          	addi	s1,s1,-420 # 800396c8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004874:	4979                	li	s2,30
    80004876:	a039                	j	80004884 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004878:	85a6                	mv	a1,s1
    8000487a:	8526                	mv	a0,s1
    8000487c:	ffffe097          	auipc	ra,0xffffe
    80004880:	ae2080e7          	jalr	-1310(ra) # 8000235e <sleep>
    if(log.committing){
    80004884:	50dc                	lw	a5,36(s1)
    80004886:	fbed                	bnez	a5,80004878 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004888:	509c                	lw	a5,32(s1)
    8000488a:	0017871b          	addiw	a4,a5,1
    8000488e:	0007069b          	sext.w	a3,a4
    80004892:	0027179b          	slliw	a5,a4,0x2
    80004896:	9fb9                	addw	a5,a5,a4
    80004898:	0017979b          	slliw	a5,a5,0x1
    8000489c:	54d8                	lw	a4,44(s1)
    8000489e:	9fb9                	addw	a5,a5,a4
    800048a0:	00f95963          	bge	s2,a5,800048b2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800048a4:	85a6                	mv	a1,s1
    800048a6:	8526                	mv	a0,s1
    800048a8:	ffffe097          	auipc	ra,0xffffe
    800048ac:	ab6080e7          	jalr	-1354(ra) # 8000235e <sleep>
    800048b0:	bfd1                	j	80004884 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800048b2:	00035517          	auipc	a0,0x35
    800048b6:	e1650513          	addi	a0,a0,-490 # 800396c8 <log>
    800048ba:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	3e8080e7          	jalr	1000(ra) # 80000ca4 <release>
      break;
    }
  }
}
    800048c4:	60e2                	ld	ra,24(sp)
    800048c6:	6442                	ld	s0,16(sp)
    800048c8:	64a2                	ld	s1,8(sp)
    800048ca:	6902                	ld	s2,0(sp)
    800048cc:	6105                	addi	sp,sp,32
    800048ce:	8082                	ret

00000000800048d0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800048d0:	7139                	addi	sp,sp,-64
    800048d2:	fc06                	sd	ra,56(sp)
    800048d4:	f822                	sd	s0,48(sp)
    800048d6:	f426                	sd	s1,40(sp)
    800048d8:	f04a                	sd	s2,32(sp)
    800048da:	ec4e                	sd	s3,24(sp)
    800048dc:	e852                	sd	s4,16(sp)
    800048de:	e456                	sd	s5,8(sp)
    800048e0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800048e2:	00035497          	auipc	s1,0x35
    800048e6:	de648493          	addi	s1,s1,-538 # 800396c8 <log>
    800048ea:	8526                	mv	a0,s1
    800048ec:	ffffc097          	auipc	ra,0xffffc
    800048f0:	2ec080e7          	jalr	748(ra) # 80000bd8 <acquire>
  log.outstanding -= 1;
    800048f4:	509c                	lw	a5,32(s1)
    800048f6:	37fd                	addiw	a5,a5,-1
    800048f8:	0007891b          	sext.w	s2,a5
    800048fc:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800048fe:	50dc                	lw	a5,36(s1)
    80004900:	e7b9                	bnez	a5,8000494e <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004902:	04091e63          	bnez	s2,8000495e <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004906:	00035497          	auipc	s1,0x35
    8000490a:	dc248493          	addi	s1,s1,-574 # 800396c8 <log>
    8000490e:	4785                	li	a5,1
    80004910:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004912:	8526                	mv	a0,s1
    80004914:	ffffc097          	auipc	ra,0xffffc
    80004918:	390080e7          	jalr	912(ra) # 80000ca4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000491c:	54dc                	lw	a5,44(s1)
    8000491e:	06f04763          	bgtz	a5,8000498c <end_op+0xbc>
    acquire(&log.lock);
    80004922:	00035497          	auipc	s1,0x35
    80004926:	da648493          	addi	s1,s1,-602 # 800396c8 <log>
    8000492a:	8526                	mv	a0,s1
    8000492c:	ffffc097          	auipc	ra,0xffffc
    80004930:	2ac080e7          	jalr	684(ra) # 80000bd8 <acquire>
    log.committing = 0;
    80004934:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004938:	8526                	mv	a0,s1
    8000493a:	ffffe097          	auipc	ra,0xffffe
    8000493e:	bba080e7          	jalr	-1094(ra) # 800024f4 <wakeup>
    release(&log.lock);
    80004942:	8526                	mv	a0,s1
    80004944:	ffffc097          	auipc	ra,0xffffc
    80004948:	360080e7          	jalr	864(ra) # 80000ca4 <release>
}
    8000494c:	a03d                	j	8000497a <end_op+0xaa>
    panic("log.committing");
    8000494e:	00004517          	auipc	a0,0x4
    80004952:	d3250513          	addi	a0,a0,-718 # 80008680 <syscalls+0x218>
    80004956:	ffffc097          	auipc	ra,0xffffc
    8000495a:	be2080e7          	jalr	-1054(ra) # 80000538 <panic>
    wakeup(&log);
    8000495e:	00035497          	auipc	s1,0x35
    80004962:	d6a48493          	addi	s1,s1,-662 # 800396c8 <log>
    80004966:	8526                	mv	a0,s1
    80004968:	ffffe097          	auipc	ra,0xffffe
    8000496c:	b8c080e7          	jalr	-1140(ra) # 800024f4 <wakeup>
  release(&log.lock);
    80004970:	8526                	mv	a0,s1
    80004972:	ffffc097          	auipc	ra,0xffffc
    80004976:	332080e7          	jalr	818(ra) # 80000ca4 <release>
}
    8000497a:	70e2                	ld	ra,56(sp)
    8000497c:	7442                	ld	s0,48(sp)
    8000497e:	74a2                	ld	s1,40(sp)
    80004980:	7902                	ld	s2,32(sp)
    80004982:	69e2                	ld	s3,24(sp)
    80004984:	6a42                	ld	s4,16(sp)
    80004986:	6aa2                	ld	s5,8(sp)
    80004988:	6121                	addi	sp,sp,64
    8000498a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000498c:	00035a97          	auipc	s5,0x35
    80004990:	d6ca8a93          	addi	s5,s5,-660 # 800396f8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004994:	00035a17          	auipc	s4,0x35
    80004998:	d34a0a13          	addi	s4,s4,-716 # 800396c8 <log>
    8000499c:	018a2583          	lw	a1,24(s4)
    800049a0:	012585bb          	addw	a1,a1,s2
    800049a4:	2585                	addiw	a1,a1,1
    800049a6:	028a2503          	lw	a0,40(s4)
    800049aa:	fffff097          	auipc	ra,0xfffff
    800049ae:	ccc080e7          	jalr	-820(ra) # 80003676 <bread>
    800049b2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049b4:	000aa583          	lw	a1,0(s5)
    800049b8:	028a2503          	lw	a0,40(s4)
    800049bc:	fffff097          	auipc	ra,0xfffff
    800049c0:	cba080e7          	jalr	-838(ra) # 80003676 <bread>
    800049c4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049c6:	40000613          	li	a2,1024
    800049ca:	05850593          	addi	a1,a0,88
    800049ce:	05848513          	addi	a0,s1,88
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	376080e7          	jalr	886(ra) # 80000d48 <memmove>
    bwrite(to);  // write the log
    800049da:	8526                	mv	a0,s1
    800049dc:	fffff097          	auipc	ra,0xfffff
    800049e0:	d8c080e7          	jalr	-628(ra) # 80003768 <bwrite>
    brelse(from);
    800049e4:	854e                	mv	a0,s3
    800049e6:	fffff097          	auipc	ra,0xfffff
    800049ea:	dc0080e7          	jalr	-576(ra) # 800037a6 <brelse>
    brelse(to);
    800049ee:	8526                	mv	a0,s1
    800049f0:	fffff097          	auipc	ra,0xfffff
    800049f4:	db6080e7          	jalr	-586(ra) # 800037a6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049f8:	2905                	addiw	s2,s2,1
    800049fa:	0a91                	addi	s5,s5,4
    800049fc:	02ca2783          	lw	a5,44(s4)
    80004a00:	f8f94ee3          	blt	s2,a5,8000499c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004a04:	00000097          	auipc	ra,0x0
    80004a08:	c66080e7          	jalr	-922(ra) # 8000466a <write_head>
    install_trans(0); // Now install writes to home locations
    80004a0c:	4501                	li	a0,0
    80004a0e:	00000097          	auipc	ra,0x0
    80004a12:	cd8080e7          	jalr	-808(ra) # 800046e6 <install_trans>
    log.lh.n = 0;
    80004a16:	00035797          	auipc	a5,0x35
    80004a1a:	cc07af23          	sw	zero,-802(a5) # 800396f4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004a1e:	00000097          	auipc	ra,0x0
    80004a22:	c4c080e7          	jalr	-948(ra) # 8000466a <write_head>
    80004a26:	bdf5                	j	80004922 <end_op+0x52>

0000000080004a28 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a28:	1101                	addi	sp,sp,-32
    80004a2a:	ec06                	sd	ra,24(sp)
    80004a2c:	e822                	sd	s0,16(sp)
    80004a2e:	e426                	sd	s1,8(sp)
    80004a30:	e04a                	sd	s2,0(sp)
    80004a32:	1000                	addi	s0,sp,32
    80004a34:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a36:	00035917          	auipc	s2,0x35
    80004a3a:	c9290913          	addi	s2,s2,-878 # 800396c8 <log>
    80004a3e:	854a                	mv	a0,s2
    80004a40:	ffffc097          	auipc	ra,0xffffc
    80004a44:	198080e7          	jalr	408(ra) # 80000bd8 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004a48:	02c92603          	lw	a2,44(s2)
    80004a4c:	47f5                	li	a5,29
    80004a4e:	06c7c563          	blt	a5,a2,80004ab8 <log_write+0x90>
    80004a52:	00035797          	auipc	a5,0x35
    80004a56:	c927a783          	lw	a5,-878(a5) # 800396e4 <log+0x1c>
    80004a5a:	37fd                	addiw	a5,a5,-1
    80004a5c:	04f65e63          	bge	a2,a5,80004ab8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a60:	00035797          	auipc	a5,0x35
    80004a64:	c887a783          	lw	a5,-888(a5) # 800396e8 <log+0x20>
    80004a68:	06f05063          	blez	a5,80004ac8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a6c:	4781                	li	a5,0
    80004a6e:	06c05563          	blez	a2,80004ad8 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004a72:	44cc                	lw	a1,12(s1)
    80004a74:	00035717          	auipc	a4,0x35
    80004a78:	c8470713          	addi	a4,a4,-892 # 800396f8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004a7c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004a7e:	4314                	lw	a3,0(a4)
    80004a80:	04b68c63          	beq	a3,a1,80004ad8 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004a84:	2785                	addiw	a5,a5,1
    80004a86:	0711                	addi	a4,a4,4
    80004a88:	fef61be3          	bne	a2,a5,80004a7e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004a8c:	0621                	addi	a2,a2,8
    80004a8e:	060a                	slli	a2,a2,0x2
    80004a90:	00035797          	auipc	a5,0x35
    80004a94:	c3878793          	addi	a5,a5,-968 # 800396c8 <log>
    80004a98:	963e                	add	a2,a2,a5
    80004a9a:	44dc                	lw	a5,12(s1)
    80004a9c:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004a9e:	8526                	mv	a0,s1
    80004aa0:	fffff097          	auipc	ra,0xfffff
    80004aa4:	da4080e7          	jalr	-604(ra) # 80003844 <bpin>
    log.lh.n++;
    80004aa8:	00035717          	auipc	a4,0x35
    80004aac:	c2070713          	addi	a4,a4,-992 # 800396c8 <log>
    80004ab0:	575c                	lw	a5,44(a4)
    80004ab2:	2785                	addiw	a5,a5,1
    80004ab4:	d75c                	sw	a5,44(a4)
    80004ab6:	a835                	j	80004af2 <log_write+0xca>
    panic("too big a transaction");
    80004ab8:	00004517          	auipc	a0,0x4
    80004abc:	bd850513          	addi	a0,a0,-1064 # 80008690 <syscalls+0x228>
    80004ac0:	ffffc097          	auipc	ra,0xffffc
    80004ac4:	a78080e7          	jalr	-1416(ra) # 80000538 <panic>
    panic("log_write outside of trans");
    80004ac8:	00004517          	auipc	a0,0x4
    80004acc:	be050513          	addi	a0,a0,-1056 # 800086a8 <syscalls+0x240>
    80004ad0:	ffffc097          	auipc	ra,0xffffc
    80004ad4:	a68080e7          	jalr	-1432(ra) # 80000538 <panic>
  log.lh.block[i] = b->blockno;
    80004ad8:	00878713          	addi	a4,a5,8
    80004adc:	00271693          	slli	a3,a4,0x2
    80004ae0:	00035717          	auipc	a4,0x35
    80004ae4:	be870713          	addi	a4,a4,-1048 # 800396c8 <log>
    80004ae8:	9736                	add	a4,a4,a3
    80004aea:	44d4                	lw	a3,12(s1)
    80004aec:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004aee:	faf608e3          	beq	a2,a5,80004a9e <log_write+0x76>
  }
  release(&log.lock);
    80004af2:	00035517          	auipc	a0,0x35
    80004af6:	bd650513          	addi	a0,a0,-1066 # 800396c8 <log>
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	1aa080e7          	jalr	426(ra) # 80000ca4 <release>
}
    80004b02:	60e2                	ld	ra,24(sp)
    80004b04:	6442                	ld	s0,16(sp)
    80004b06:	64a2                	ld	s1,8(sp)
    80004b08:	6902                	ld	s2,0(sp)
    80004b0a:	6105                	addi	sp,sp,32
    80004b0c:	8082                	ret

0000000080004b0e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b0e:	1101                	addi	sp,sp,-32
    80004b10:	ec06                	sd	ra,24(sp)
    80004b12:	e822                	sd	s0,16(sp)
    80004b14:	e426                	sd	s1,8(sp)
    80004b16:	e04a                	sd	s2,0(sp)
    80004b18:	1000                	addi	s0,sp,32
    80004b1a:	84aa                	mv	s1,a0
    80004b1c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b1e:	00004597          	auipc	a1,0x4
    80004b22:	baa58593          	addi	a1,a1,-1110 # 800086c8 <syscalls+0x260>
    80004b26:	0521                	addi	a0,a0,8
    80004b28:	ffffc097          	auipc	ra,0xffffc
    80004b2c:	018080e7          	jalr	24(ra) # 80000b40 <initlock>
  lk->name = name;
    80004b30:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b34:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b38:	0204a423          	sw	zero,40(s1)
}
    80004b3c:	60e2                	ld	ra,24(sp)
    80004b3e:	6442                	ld	s0,16(sp)
    80004b40:	64a2                	ld	s1,8(sp)
    80004b42:	6902                	ld	s2,0(sp)
    80004b44:	6105                	addi	sp,sp,32
    80004b46:	8082                	ret

0000000080004b48 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b48:	1101                	addi	sp,sp,-32
    80004b4a:	ec06                	sd	ra,24(sp)
    80004b4c:	e822                	sd	s0,16(sp)
    80004b4e:	e426                	sd	s1,8(sp)
    80004b50:	e04a                	sd	s2,0(sp)
    80004b52:	1000                	addi	s0,sp,32
    80004b54:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b56:	00850913          	addi	s2,a0,8
    80004b5a:	854a                	mv	a0,s2
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	07c080e7          	jalr	124(ra) # 80000bd8 <acquire>
  while (lk->locked) {
    80004b64:	409c                	lw	a5,0(s1)
    80004b66:	cb89                	beqz	a5,80004b78 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004b68:	85ca                	mv	a1,s2
    80004b6a:	8526                	mv	a0,s1
    80004b6c:	ffffd097          	auipc	ra,0xffffd
    80004b70:	7f2080e7          	jalr	2034(ra) # 8000235e <sleep>
  while (lk->locked) {
    80004b74:	409c                	lw	a5,0(s1)
    80004b76:	fbed                	bnez	a5,80004b68 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004b78:	4785                	li	a5,1
    80004b7a:	c09c                	sw	a5,0(s1)
  lk->pid = mythread()->id;
    80004b7c:	ffffd097          	auipc	ra,0xffffd
    80004b80:	f60080e7          	jalr	-160(ra) # 80001adc <mythread>
    80004b84:	411c                	lw	a5,0(a0)
    80004b86:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004b88:	854a                	mv	a0,s2
    80004b8a:	ffffc097          	auipc	ra,0xffffc
    80004b8e:	11a080e7          	jalr	282(ra) # 80000ca4 <release>
}
    80004b92:	60e2                	ld	ra,24(sp)
    80004b94:	6442                	ld	s0,16(sp)
    80004b96:	64a2                	ld	s1,8(sp)
    80004b98:	6902                	ld	s2,0(sp)
    80004b9a:	6105                	addi	sp,sp,32
    80004b9c:	8082                	ret

0000000080004b9e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004b9e:	1101                	addi	sp,sp,-32
    80004ba0:	ec06                	sd	ra,24(sp)
    80004ba2:	e822                	sd	s0,16(sp)
    80004ba4:	e426                	sd	s1,8(sp)
    80004ba6:	e04a                	sd	s2,0(sp)
    80004ba8:	1000                	addi	s0,sp,32
    80004baa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bac:	00850913          	addi	s2,a0,8
    80004bb0:	854a                	mv	a0,s2
    80004bb2:	ffffc097          	auipc	ra,0xffffc
    80004bb6:	026080e7          	jalr	38(ra) # 80000bd8 <acquire>
  lk->locked = 0;
    80004bba:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bbe:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004bc2:	8526                	mv	a0,s1
    80004bc4:	ffffe097          	auipc	ra,0xffffe
    80004bc8:	930080e7          	jalr	-1744(ra) # 800024f4 <wakeup>
  release(&lk->lk);
    80004bcc:	854a                	mv	a0,s2
    80004bce:	ffffc097          	auipc	ra,0xffffc
    80004bd2:	0d6080e7          	jalr	214(ra) # 80000ca4 <release>
}
    80004bd6:	60e2                	ld	ra,24(sp)
    80004bd8:	6442                	ld	s0,16(sp)
    80004bda:	64a2                	ld	s1,8(sp)
    80004bdc:	6902                	ld	s2,0(sp)
    80004bde:	6105                	addi	sp,sp,32
    80004be0:	8082                	ret

0000000080004be2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004be2:	7179                	addi	sp,sp,-48
    80004be4:	f406                	sd	ra,40(sp)
    80004be6:	f022                	sd	s0,32(sp)
    80004be8:	ec26                	sd	s1,24(sp)
    80004bea:	e84a                	sd	s2,16(sp)
    80004bec:	e44e                	sd	s3,8(sp)
    80004bee:	1800                	addi	s0,sp,48
    80004bf0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004bf2:	00850913          	addi	s2,a0,8
    80004bf6:	854a                	mv	a0,s2
    80004bf8:	ffffc097          	auipc	ra,0xffffc
    80004bfc:	fe0080e7          	jalr	-32(ra) # 80000bd8 <acquire>
  r = lk->locked && (lk->pid == mythread()->id);
    80004c00:	409c                	lw	a5,0(s1)
    80004c02:	ef99                	bnez	a5,80004c20 <holdingsleep+0x3e>
    80004c04:	4481                	li	s1,0
  release(&lk->lk);
    80004c06:	854a                	mv	a0,s2
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	09c080e7          	jalr	156(ra) # 80000ca4 <release>
  return r;
}
    80004c10:	8526                	mv	a0,s1
    80004c12:	70a2                	ld	ra,40(sp)
    80004c14:	7402                	ld	s0,32(sp)
    80004c16:	64e2                	ld	s1,24(sp)
    80004c18:	6942                	ld	s2,16(sp)
    80004c1a:	69a2                	ld	s3,8(sp)
    80004c1c:	6145                	addi	sp,sp,48
    80004c1e:	8082                	ret
  r = lk->locked && (lk->pid == mythread()->id);
    80004c20:	0284a983          	lw	s3,40(s1)
    80004c24:	ffffd097          	auipc	ra,0xffffd
    80004c28:	eb8080e7          	jalr	-328(ra) # 80001adc <mythread>
    80004c2c:	4104                	lw	s1,0(a0)
    80004c2e:	413484b3          	sub	s1,s1,s3
    80004c32:	0014b493          	seqz	s1,s1
    80004c36:	bfc1                	j	80004c06 <holdingsleep+0x24>

0000000080004c38 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c38:	1141                	addi	sp,sp,-16
    80004c3a:	e406                	sd	ra,8(sp)
    80004c3c:	e022                	sd	s0,0(sp)
    80004c3e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c40:	00004597          	auipc	a1,0x4
    80004c44:	a9858593          	addi	a1,a1,-1384 # 800086d8 <syscalls+0x270>
    80004c48:	00035517          	auipc	a0,0x35
    80004c4c:	bc850513          	addi	a0,a0,-1080 # 80039810 <ftable>
    80004c50:	ffffc097          	auipc	ra,0xffffc
    80004c54:	ef0080e7          	jalr	-272(ra) # 80000b40 <initlock>
}
    80004c58:	60a2                	ld	ra,8(sp)
    80004c5a:	6402                	ld	s0,0(sp)
    80004c5c:	0141                	addi	sp,sp,16
    80004c5e:	8082                	ret

0000000080004c60 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c60:	1101                	addi	sp,sp,-32
    80004c62:	ec06                	sd	ra,24(sp)
    80004c64:	e822                	sd	s0,16(sp)
    80004c66:	e426                	sd	s1,8(sp)
    80004c68:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c6a:	00035517          	auipc	a0,0x35
    80004c6e:	ba650513          	addi	a0,a0,-1114 # 80039810 <ftable>
    80004c72:	ffffc097          	auipc	ra,0xffffc
    80004c76:	f66080e7          	jalr	-154(ra) # 80000bd8 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c7a:	00035497          	auipc	s1,0x35
    80004c7e:	bae48493          	addi	s1,s1,-1106 # 80039828 <ftable+0x18>
    80004c82:	00036717          	auipc	a4,0x36
    80004c86:	b4670713          	addi	a4,a4,-1210 # 8003a7c8 <ftable+0xfb8>
    if(f->ref == 0){
    80004c8a:	40dc                	lw	a5,4(s1)
    80004c8c:	cf99                	beqz	a5,80004caa <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c8e:	02848493          	addi	s1,s1,40
    80004c92:	fee49ce3          	bne	s1,a4,80004c8a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004c96:	00035517          	auipc	a0,0x35
    80004c9a:	b7a50513          	addi	a0,a0,-1158 # 80039810 <ftable>
    80004c9e:	ffffc097          	auipc	ra,0xffffc
    80004ca2:	006080e7          	jalr	6(ra) # 80000ca4 <release>
  return 0;
    80004ca6:	4481                	li	s1,0
    80004ca8:	a819                	j	80004cbe <filealloc+0x5e>
      f->ref = 1;
    80004caa:	4785                	li	a5,1
    80004cac:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004cae:	00035517          	auipc	a0,0x35
    80004cb2:	b6250513          	addi	a0,a0,-1182 # 80039810 <ftable>
    80004cb6:	ffffc097          	auipc	ra,0xffffc
    80004cba:	fee080e7          	jalr	-18(ra) # 80000ca4 <release>
}
    80004cbe:	8526                	mv	a0,s1
    80004cc0:	60e2                	ld	ra,24(sp)
    80004cc2:	6442                	ld	s0,16(sp)
    80004cc4:	64a2                	ld	s1,8(sp)
    80004cc6:	6105                	addi	sp,sp,32
    80004cc8:	8082                	ret

0000000080004cca <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004cca:	1101                	addi	sp,sp,-32
    80004ccc:	ec06                	sd	ra,24(sp)
    80004cce:	e822                	sd	s0,16(sp)
    80004cd0:	e426                	sd	s1,8(sp)
    80004cd2:	1000                	addi	s0,sp,32
    80004cd4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004cd6:	00035517          	auipc	a0,0x35
    80004cda:	b3a50513          	addi	a0,a0,-1222 # 80039810 <ftable>
    80004cde:	ffffc097          	auipc	ra,0xffffc
    80004ce2:	efa080e7          	jalr	-262(ra) # 80000bd8 <acquire>
  if(f->ref < 1)
    80004ce6:	40dc                	lw	a5,4(s1)
    80004ce8:	02f05263          	blez	a5,80004d0c <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004cec:	2785                	addiw	a5,a5,1
    80004cee:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004cf0:	00035517          	auipc	a0,0x35
    80004cf4:	b2050513          	addi	a0,a0,-1248 # 80039810 <ftable>
    80004cf8:	ffffc097          	auipc	ra,0xffffc
    80004cfc:	fac080e7          	jalr	-84(ra) # 80000ca4 <release>
  return f;
}
    80004d00:	8526                	mv	a0,s1
    80004d02:	60e2                	ld	ra,24(sp)
    80004d04:	6442                	ld	s0,16(sp)
    80004d06:	64a2                	ld	s1,8(sp)
    80004d08:	6105                	addi	sp,sp,32
    80004d0a:	8082                	ret
    panic("filedup");
    80004d0c:	00004517          	auipc	a0,0x4
    80004d10:	9d450513          	addi	a0,a0,-1580 # 800086e0 <syscalls+0x278>
    80004d14:	ffffc097          	auipc	ra,0xffffc
    80004d18:	824080e7          	jalr	-2012(ra) # 80000538 <panic>

0000000080004d1c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004d1c:	7139                	addi	sp,sp,-64
    80004d1e:	fc06                	sd	ra,56(sp)
    80004d20:	f822                	sd	s0,48(sp)
    80004d22:	f426                	sd	s1,40(sp)
    80004d24:	f04a                	sd	s2,32(sp)
    80004d26:	ec4e                	sd	s3,24(sp)
    80004d28:	e852                	sd	s4,16(sp)
    80004d2a:	e456                	sd	s5,8(sp)
    80004d2c:	0080                	addi	s0,sp,64
    80004d2e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d30:	00035517          	auipc	a0,0x35
    80004d34:	ae050513          	addi	a0,a0,-1312 # 80039810 <ftable>
    80004d38:	ffffc097          	auipc	ra,0xffffc
    80004d3c:	ea0080e7          	jalr	-352(ra) # 80000bd8 <acquire>
  if(f->ref < 1)
    80004d40:	40dc                	lw	a5,4(s1)
    80004d42:	06f05163          	blez	a5,80004da4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004d46:	37fd                	addiw	a5,a5,-1
    80004d48:	0007871b          	sext.w	a4,a5
    80004d4c:	c0dc                	sw	a5,4(s1)
    80004d4e:	06e04363          	bgtz	a4,80004db4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004d52:	0004a903          	lw	s2,0(s1)
    80004d56:	0094ca83          	lbu	s5,9(s1)
    80004d5a:	0104ba03          	ld	s4,16(s1)
    80004d5e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d62:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d66:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d6a:	00035517          	auipc	a0,0x35
    80004d6e:	aa650513          	addi	a0,a0,-1370 # 80039810 <ftable>
    80004d72:	ffffc097          	auipc	ra,0xffffc
    80004d76:	f32080e7          	jalr	-206(ra) # 80000ca4 <release>

  if(ff.type == FD_PIPE){
    80004d7a:	4785                	li	a5,1
    80004d7c:	04f90d63          	beq	s2,a5,80004dd6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004d80:	3979                	addiw	s2,s2,-2
    80004d82:	4785                	li	a5,1
    80004d84:	0527e063          	bltu	a5,s2,80004dc4 <fileclose+0xa8>
    begin_op();
    80004d88:	00000097          	auipc	ra,0x0
    80004d8c:	ac8080e7          	jalr	-1336(ra) # 80004850 <begin_op>
    iput(ff.ip);
    80004d90:	854e                	mv	a0,s3
    80004d92:	fffff097          	auipc	ra,0xfffff
    80004d96:	2a2080e7          	jalr	674(ra) # 80004034 <iput>
    end_op();
    80004d9a:	00000097          	auipc	ra,0x0
    80004d9e:	b36080e7          	jalr	-1226(ra) # 800048d0 <end_op>
    80004da2:	a00d                	j	80004dc4 <fileclose+0xa8>
    panic("fileclose");
    80004da4:	00004517          	auipc	a0,0x4
    80004da8:	94450513          	addi	a0,a0,-1724 # 800086e8 <syscalls+0x280>
    80004dac:	ffffb097          	auipc	ra,0xffffb
    80004db0:	78c080e7          	jalr	1932(ra) # 80000538 <panic>
    release(&ftable.lock);
    80004db4:	00035517          	auipc	a0,0x35
    80004db8:	a5c50513          	addi	a0,a0,-1444 # 80039810 <ftable>
    80004dbc:	ffffc097          	auipc	ra,0xffffc
    80004dc0:	ee8080e7          	jalr	-280(ra) # 80000ca4 <release>
  }
}
    80004dc4:	70e2                	ld	ra,56(sp)
    80004dc6:	7442                	ld	s0,48(sp)
    80004dc8:	74a2                	ld	s1,40(sp)
    80004dca:	7902                	ld	s2,32(sp)
    80004dcc:	69e2                	ld	s3,24(sp)
    80004dce:	6a42                	ld	s4,16(sp)
    80004dd0:	6aa2                	ld	s5,8(sp)
    80004dd2:	6121                	addi	sp,sp,64
    80004dd4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004dd6:	85d6                	mv	a1,s5
    80004dd8:	8552                	mv	a0,s4
    80004dda:	00000097          	auipc	ra,0x0
    80004dde:	34c080e7          	jalr	844(ra) # 80005126 <pipeclose>
    80004de2:	b7cd                	j	80004dc4 <fileclose+0xa8>

0000000080004de4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004de4:	715d                	addi	sp,sp,-80
    80004de6:	e486                	sd	ra,72(sp)
    80004de8:	e0a2                	sd	s0,64(sp)
    80004dea:	fc26                	sd	s1,56(sp)
    80004dec:	f84a                	sd	s2,48(sp)
    80004dee:	f44e                	sd	s3,40(sp)
    80004df0:	0880                	addi	s0,sp,80
    80004df2:	84aa                	mv	s1,a0
    80004df4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004df6:	ffffd097          	auipc	ra,0xffffd
    80004dfa:	c60080e7          	jalr	-928(ra) # 80001a56 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004dfe:	409c                	lw	a5,0(s1)
    80004e00:	37f9                	addiw	a5,a5,-2
    80004e02:	4705                	li	a4,1
    80004e04:	04f76763          	bltu	a4,a5,80004e52 <filestat+0x6e>
    80004e08:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e0a:	6c88                	ld	a0,24(s1)
    80004e0c:	fffff097          	auipc	ra,0xfffff
    80004e10:	06e080e7          	jalr	110(ra) # 80003e7a <ilock>
    stati(f->ip, &st);
    80004e14:	fb840593          	addi	a1,s0,-72
    80004e18:	6c88                	ld	a0,24(s1)
    80004e1a:	fffff097          	auipc	ra,0xfffff
    80004e1e:	2ea080e7          	jalr	746(ra) # 80004104 <stati>
    iunlock(f->ip);
    80004e22:	6c88                	ld	a0,24(s1)
    80004e24:	fffff097          	auipc	ra,0xfffff
    80004e28:	118080e7          	jalr	280(ra) # 80003f3c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e2c:	46e1                	li	a3,24
    80004e2e:	fb840613          	addi	a2,s0,-72
    80004e32:	85ce                	mv	a1,s3
    80004e34:	05093503          	ld	a0,80(s2)
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	834080e7          	jalr	-1996(ra) # 8000166c <copyout>
    80004e40:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004e44:	60a6                	ld	ra,72(sp)
    80004e46:	6406                	ld	s0,64(sp)
    80004e48:	74e2                	ld	s1,56(sp)
    80004e4a:	7942                	ld	s2,48(sp)
    80004e4c:	79a2                	ld	s3,40(sp)
    80004e4e:	6161                	addi	sp,sp,80
    80004e50:	8082                	ret
  return -1;
    80004e52:	557d                	li	a0,-1
    80004e54:	bfc5                	j	80004e44 <filestat+0x60>

0000000080004e56 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e56:	7179                	addi	sp,sp,-48
    80004e58:	f406                	sd	ra,40(sp)
    80004e5a:	f022                	sd	s0,32(sp)
    80004e5c:	ec26                	sd	s1,24(sp)
    80004e5e:	e84a                	sd	s2,16(sp)
    80004e60:	e44e                	sd	s3,8(sp)
    80004e62:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e64:	00854783          	lbu	a5,8(a0)
    80004e68:	c3d5                	beqz	a5,80004f0c <fileread+0xb6>
    80004e6a:	84aa                	mv	s1,a0
    80004e6c:	89ae                	mv	s3,a1
    80004e6e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e70:	411c                	lw	a5,0(a0)
    80004e72:	4705                	li	a4,1
    80004e74:	04e78963          	beq	a5,a4,80004ec6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e78:	470d                	li	a4,3
    80004e7a:	04e78d63          	beq	a5,a4,80004ed4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e7e:	4709                	li	a4,2
    80004e80:	06e79e63          	bne	a5,a4,80004efc <fileread+0xa6>
    ilock(f->ip);
    80004e84:	6d08                	ld	a0,24(a0)
    80004e86:	fffff097          	auipc	ra,0xfffff
    80004e8a:	ff4080e7          	jalr	-12(ra) # 80003e7a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004e8e:	874a                	mv	a4,s2
    80004e90:	5094                	lw	a3,32(s1)
    80004e92:	864e                	mv	a2,s3
    80004e94:	4585                	li	a1,1
    80004e96:	6c88                	ld	a0,24(s1)
    80004e98:	fffff097          	auipc	ra,0xfffff
    80004e9c:	296080e7          	jalr	662(ra) # 8000412e <readi>
    80004ea0:	892a                	mv	s2,a0
    80004ea2:	00a05563          	blez	a0,80004eac <fileread+0x56>
      f->off += r;
    80004ea6:	509c                	lw	a5,32(s1)
    80004ea8:	9fa9                	addw	a5,a5,a0
    80004eaa:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004eac:	6c88                	ld	a0,24(s1)
    80004eae:	fffff097          	auipc	ra,0xfffff
    80004eb2:	08e080e7          	jalr	142(ra) # 80003f3c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004eb6:	854a                	mv	a0,s2
    80004eb8:	70a2                	ld	ra,40(sp)
    80004eba:	7402                	ld	s0,32(sp)
    80004ebc:	64e2                	ld	s1,24(sp)
    80004ebe:	6942                	ld	s2,16(sp)
    80004ec0:	69a2                	ld	s3,8(sp)
    80004ec2:	6145                	addi	sp,sp,48
    80004ec4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ec6:	6908                	ld	a0,16(a0)
    80004ec8:	00000097          	auipc	ra,0x0
    80004ecc:	3c0080e7          	jalr	960(ra) # 80005288 <piperead>
    80004ed0:	892a                	mv	s2,a0
    80004ed2:	b7d5                	j	80004eb6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004ed4:	02451783          	lh	a5,36(a0)
    80004ed8:	03079693          	slli	a3,a5,0x30
    80004edc:	92c1                	srli	a3,a3,0x30
    80004ede:	4725                	li	a4,9
    80004ee0:	02d76863          	bltu	a4,a3,80004f10 <fileread+0xba>
    80004ee4:	0792                	slli	a5,a5,0x4
    80004ee6:	00035717          	auipc	a4,0x35
    80004eea:	88a70713          	addi	a4,a4,-1910 # 80039770 <devsw>
    80004eee:	97ba                	add	a5,a5,a4
    80004ef0:	639c                	ld	a5,0(a5)
    80004ef2:	c38d                	beqz	a5,80004f14 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004ef4:	4505                	li	a0,1
    80004ef6:	9782                	jalr	a5
    80004ef8:	892a                	mv	s2,a0
    80004efa:	bf75                	j	80004eb6 <fileread+0x60>
    panic("fileread");
    80004efc:	00003517          	auipc	a0,0x3
    80004f00:	7fc50513          	addi	a0,a0,2044 # 800086f8 <syscalls+0x290>
    80004f04:	ffffb097          	auipc	ra,0xffffb
    80004f08:	634080e7          	jalr	1588(ra) # 80000538 <panic>
    return -1;
    80004f0c:	597d                	li	s2,-1
    80004f0e:	b765                	j	80004eb6 <fileread+0x60>
      return -1;
    80004f10:	597d                	li	s2,-1
    80004f12:	b755                	j	80004eb6 <fileread+0x60>
    80004f14:	597d                	li	s2,-1
    80004f16:	b745                	j	80004eb6 <fileread+0x60>

0000000080004f18 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004f18:	715d                	addi	sp,sp,-80
    80004f1a:	e486                	sd	ra,72(sp)
    80004f1c:	e0a2                	sd	s0,64(sp)
    80004f1e:	fc26                	sd	s1,56(sp)
    80004f20:	f84a                	sd	s2,48(sp)
    80004f22:	f44e                	sd	s3,40(sp)
    80004f24:	f052                	sd	s4,32(sp)
    80004f26:	ec56                	sd	s5,24(sp)
    80004f28:	e85a                	sd	s6,16(sp)
    80004f2a:	e45e                	sd	s7,8(sp)
    80004f2c:	e062                	sd	s8,0(sp)
    80004f2e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004f30:	00954783          	lbu	a5,9(a0)
    80004f34:	10078663          	beqz	a5,80005040 <filewrite+0x128>
    80004f38:	892a                	mv	s2,a0
    80004f3a:	8aae                	mv	s5,a1
    80004f3c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f3e:	411c                	lw	a5,0(a0)
    80004f40:	4705                	li	a4,1
    80004f42:	02e78263          	beq	a5,a4,80004f66 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f46:	470d                	li	a4,3
    80004f48:	02e78663          	beq	a5,a4,80004f74 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f4c:	4709                	li	a4,2
    80004f4e:	0ee79163          	bne	a5,a4,80005030 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f52:	0ac05d63          	blez	a2,8000500c <filewrite+0xf4>
    int i = 0;
    80004f56:	4981                	li	s3,0
    80004f58:	6b05                	lui	s6,0x1
    80004f5a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004f5e:	6b85                	lui	s7,0x1
    80004f60:	c00b8b9b          	addiw	s7,s7,-1024
    80004f64:	a861                	j	80004ffc <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004f66:	6908                	ld	a0,16(a0)
    80004f68:	00000097          	auipc	ra,0x0
    80004f6c:	22e080e7          	jalr	558(ra) # 80005196 <pipewrite>
    80004f70:	8a2a                	mv	s4,a0
    80004f72:	a045                	j	80005012 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004f74:	02451783          	lh	a5,36(a0)
    80004f78:	03079693          	slli	a3,a5,0x30
    80004f7c:	92c1                	srli	a3,a3,0x30
    80004f7e:	4725                	li	a4,9
    80004f80:	0cd76263          	bltu	a4,a3,80005044 <filewrite+0x12c>
    80004f84:	0792                	slli	a5,a5,0x4
    80004f86:	00034717          	auipc	a4,0x34
    80004f8a:	7ea70713          	addi	a4,a4,2026 # 80039770 <devsw>
    80004f8e:	97ba                	add	a5,a5,a4
    80004f90:	679c                	ld	a5,8(a5)
    80004f92:	cbdd                	beqz	a5,80005048 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004f94:	4505                	li	a0,1
    80004f96:	9782                	jalr	a5
    80004f98:	8a2a                	mv	s4,a0
    80004f9a:	a8a5                	j	80005012 <filewrite+0xfa>
    80004f9c:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004fa0:	00000097          	auipc	ra,0x0
    80004fa4:	8b0080e7          	jalr	-1872(ra) # 80004850 <begin_op>
      ilock(f->ip);
    80004fa8:	01893503          	ld	a0,24(s2)
    80004fac:	fffff097          	auipc	ra,0xfffff
    80004fb0:	ece080e7          	jalr	-306(ra) # 80003e7a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004fb4:	8762                	mv	a4,s8
    80004fb6:	02092683          	lw	a3,32(s2)
    80004fba:	01598633          	add	a2,s3,s5
    80004fbe:	4585                	li	a1,1
    80004fc0:	01893503          	ld	a0,24(s2)
    80004fc4:	fffff097          	auipc	ra,0xfffff
    80004fc8:	262080e7          	jalr	610(ra) # 80004226 <writei>
    80004fcc:	84aa                	mv	s1,a0
    80004fce:	00a05763          	blez	a0,80004fdc <filewrite+0xc4>
        f->off += r;
    80004fd2:	02092783          	lw	a5,32(s2)
    80004fd6:	9fa9                	addw	a5,a5,a0
    80004fd8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004fdc:	01893503          	ld	a0,24(s2)
    80004fe0:	fffff097          	auipc	ra,0xfffff
    80004fe4:	f5c080e7          	jalr	-164(ra) # 80003f3c <iunlock>
      end_op();
    80004fe8:	00000097          	auipc	ra,0x0
    80004fec:	8e8080e7          	jalr	-1816(ra) # 800048d0 <end_op>

      if(r != n1){
    80004ff0:	009c1f63          	bne	s8,s1,8000500e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004ff4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ff8:	0149db63          	bge	s3,s4,8000500e <filewrite+0xf6>
      int n1 = n - i;
    80004ffc:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005000:	84be                	mv	s1,a5
    80005002:	2781                	sext.w	a5,a5
    80005004:	f8fb5ce3          	bge	s6,a5,80004f9c <filewrite+0x84>
    80005008:	84de                	mv	s1,s7
    8000500a:	bf49                	j	80004f9c <filewrite+0x84>
    int i = 0;
    8000500c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000500e:	013a1f63          	bne	s4,s3,8000502c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005012:	8552                	mv	a0,s4
    80005014:	60a6                	ld	ra,72(sp)
    80005016:	6406                	ld	s0,64(sp)
    80005018:	74e2                	ld	s1,56(sp)
    8000501a:	7942                	ld	s2,48(sp)
    8000501c:	79a2                	ld	s3,40(sp)
    8000501e:	7a02                	ld	s4,32(sp)
    80005020:	6ae2                	ld	s5,24(sp)
    80005022:	6b42                	ld	s6,16(sp)
    80005024:	6ba2                	ld	s7,8(sp)
    80005026:	6c02                	ld	s8,0(sp)
    80005028:	6161                	addi	sp,sp,80
    8000502a:	8082                	ret
    ret = (i == n ? n : -1);
    8000502c:	5a7d                	li	s4,-1
    8000502e:	b7d5                	j	80005012 <filewrite+0xfa>
    panic("filewrite");
    80005030:	00003517          	auipc	a0,0x3
    80005034:	6d850513          	addi	a0,a0,1752 # 80008708 <syscalls+0x2a0>
    80005038:	ffffb097          	auipc	ra,0xffffb
    8000503c:	500080e7          	jalr	1280(ra) # 80000538 <panic>
    return -1;
    80005040:	5a7d                	li	s4,-1
    80005042:	bfc1                	j	80005012 <filewrite+0xfa>
      return -1;
    80005044:	5a7d                	li	s4,-1
    80005046:	b7f1                	j	80005012 <filewrite+0xfa>
    80005048:	5a7d                	li	s4,-1
    8000504a:	b7e1                	j	80005012 <filewrite+0xfa>

000000008000504c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000504c:	7179                	addi	sp,sp,-48
    8000504e:	f406                	sd	ra,40(sp)
    80005050:	f022                	sd	s0,32(sp)
    80005052:	ec26                	sd	s1,24(sp)
    80005054:	e84a                	sd	s2,16(sp)
    80005056:	e44e                	sd	s3,8(sp)
    80005058:	e052                	sd	s4,0(sp)
    8000505a:	1800                	addi	s0,sp,48
    8000505c:	84aa                	mv	s1,a0
    8000505e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005060:	0005b023          	sd	zero,0(a1)
    80005064:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005068:	00000097          	auipc	ra,0x0
    8000506c:	bf8080e7          	jalr	-1032(ra) # 80004c60 <filealloc>
    80005070:	e088                	sd	a0,0(s1)
    80005072:	c551                	beqz	a0,800050fe <pipealloc+0xb2>
    80005074:	00000097          	auipc	ra,0x0
    80005078:	bec080e7          	jalr	-1044(ra) # 80004c60 <filealloc>
    8000507c:	00aa3023          	sd	a0,0(s4)
    80005080:	c92d                	beqz	a0,800050f2 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005082:	ffffc097          	auipc	ra,0xffffc
    80005086:	a5e080e7          	jalr	-1442(ra) # 80000ae0 <kalloc>
    8000508a:	892a                	mv	s2,a0
    8000508c:	c125                	beqz	a0,800050ec <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000508e:	4985                	li	s3,1
    80005090:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005094:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005098:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000509c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800050a0:	00003597          	auipc	a1,0x3
    800050a4:	67858593          	addi	a1,a1,1656 # 80008718 <syscalls+0x2b0>
    800050a8:	ffffc097          	auipc	ra,0xffffc
    800050ac:	a98080e7          	jalr	-1384(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    800050b0:	609c                	ld	a5,0(s1)
    800050b2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800050b6:	609c                	ld	a5,0(s1)
    800050b8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800050bc:	609c                	ld	a5,0(s1)
    800050be:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800050c2:	609c                	ld	a5,0(s1)
    800050c4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800050c8:	000a3783          	ld	a5,0(s4)
    800050cc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800050d0:	000a3783          	ld	a5,0(s4)
    800050d4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800050d8:	000a3783          	ld	a5,0(s4)
    800050dc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800050e0:	000a3783          	ld	a5,0(s4)
    800050e4:	0127b823          	sd	s2,16(a5)
  return 0;
    800050e8:	4501                	li	a0,0
    800050ea:	a025                	j	80005112 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800050ec:	6088                	ld	a0,0(s1)
    800050ee:	e501                	bnez	a0,800050f6 <pipealloc+0xaa>
    800050f0:	a039                	j	800050fe <pipealloc+0xb2>
    800050f2:	6088                	ld	a0,0(s1)
    800050f4:	c51d                	beqz	a0,80005122 <pipealloc+0xd6>
    fileclose(*f0);
    800050f6:	00000097          	auipc	ra,0x0
    800050fa:	c26080e7          	jalr	-986(ra) # 80004d1c <fileclose>
  if(*f1)
    800050fe:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005102:	557d                	li	a0,-1
  if(*f1)
    80005104:	c799                	beqz	a5,80005112 <pipealloc+0xc6>
    fileclose(*f1);
    80005106:	853e                	mv	a0,a5
    80005108:	00000097          	auipc	ra,0x0
    8000510c:	c14080e7          	jalr	-1004(ra) # 80004d1c <fileclose>
  return -1;
    80005110:	557d                	li	a0,-1
}
    80005112:	70a2                	ld	ra,40(sp)
    80005114:	7402                	ld	s0,32(sp)
    80005116:	64e2                	ld	s1,24(sp)
    80005118:	6942                	ld	s2,16(sp)
    8000511a:	69a2                	ld	s3,8(sp)
    8000511c:	6a02                	ld	s4,0(sp)
    8000511e:	6145                	addi	sp,sp,48
    80005120:	8082                	ret
  return -1;
    80005122:	557d                	li	a0,-1
    80005124:	b7fd                	j	80005112 <pipealloc+0xc6>

0000000080005126 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005126:	1101                	addi	sp,sp,-32
    80005128:	ec06                	sd	ra,24(sp)
    8000512a:	e822                	sd	s0,16(sp)
    8000512c:	e426                	sd	s1,8(sp)
    8000512e:	e04a                	sd	s2,0(sp)
    80005130:	1000                	addi	s0,sp,32
    80005132:	84aa                	mv	s1,a0
    80005134:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005136:	ffffc097          	auipc	ra,0xffffc
    8000513a:	aa2080e7          	jalr	-1374(ra) # 80000bd8 <acquire>
  if(writable){
    8000513e:	02090d63          	beqz	s2,80005178 <pipeclose+0x52>
    pi->writeopen = 0;
    80005142:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005146:	21848513          	addi	a0,s1,536
    8000514a:	ffffd097          	auipc	ra,0xffffd
    8000514e:	3aa080e7          	jalr	938(ra) # 800024f4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005152:	2204b783          	ld	a5,544(s1)
    80005156:	eb95                	bnez	a5,8000518a <pipeclose+0x64>
    release(&pi->lock);
    80005158:	8526                	mv	a0,s1
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	b4a080e7          	jalr	-1206(ra) # 80000ca4 <release>
    kfree((char*)pi);
    80005162:	8526                	mv	a0,s1
    80005164:	ffffc097          	auipc	ra,0xffffc
    80005168:	880080e7          	jalr	-1920(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    8000516c:	60e2                	ld	ra,24(sp)
    8000516e:	6442                	ld	s0,16(sp)
    80005170:	64a2                	ld	s1,8(sp)
    80005172:	6902                	ld	s2,0(sp)
    80005174:	6105                	addi	sp,sp,32
    80005176:	8082                	ret
    pi->readopen = 0;
    80005178:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000517c:	21c48513          	addi	a0,s1,540
    80005180:	ffffd097          	auipc	ra,0xffffd
    80005184:	374080e7          	jalr	884(ra) # 800024f4 <wakeup>
    80005188:	b7e9                	j	80005152 <pipeclose+0x2c>
    release(&pi->lock);
    8000518a:	8526                	mv	a0,s1
    8000518c:	ffffc097          	auipc	ra,0xffffc
    80005190:	b18080e7          	jalr	-1256(ra) # 80000ca4 <release>
}
    80005194:	bfe1                	j	8000516c <pipeclose+0x46>

0000000080005196 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005196:	711d                	addi	sp,sp,-96
    80005198:	ec86                	sd	ra,88(sp)
    8000519a:	e8a2                	sd	s0,80(sp)
    8000519c:	e4a6                	sd	s1,72(sp)
    8000519e:	e0ca                	sd	s2,64(sp)
    800051a0:	fc4e                	sd	s3,56(sp)
    800051a2:	f852                	sd	s4,48(sp)
    800051a4:	f456                	sd	s5,40(sp)
    800051a6:	f05a                	sd	s6,32(sp)
    800051a8:	ec5e                	sd	s7,24(sp)
    800051aa:	e862                	sd	s8,16(sp)
    800051ac:	1080                	addi	s0,sp,96
    800051ae:	84aa                	mv	s1,a0
    800051b0:	8aae                	mv	s5,a1
    800051b2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800051b4:	ffffd097          	auipc	ra,0xffffd
    800051b8:	8a2080e7          	jalr	-1886(ra) # 80001a56 <myproc>
    800051bc:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800051be:	8526                	mv	a0,s1
    800051c0:	ffffc097          	auipc	ra,0xffffc
    800051c4:	a18080e7          	jalr	-1512(ra) # 80000bd8 <acquire>
  while(i < n){
    800051c8:	0b405363          	blez	s4,8000526e <pipewrite+0xd8>
  int i = 0;
    800051cc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051ce:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800051d0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800051d4:	21c48b93          	addi	s7,s1,540
    800051d8:	a089                	j	8000521a <pipewrite+0x84>
      release(&pi->lock);
    800051da:	8526                	mv	a0,s1
    800051dc:	ffffc097          	auipc	ra,0xffffc
    800051e0:	ac8080e7          	jalr	-1336(ra) # 80000ca4 <release>
      return -1;
    800051e4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800051e6:	854a                	mv	a0,s2
    800051e8:	60e6                	ld	ra,88(sp)
    800051ea:	6446                	ld	s0,80(sp)
    800051ec:	64a6                	ld	s1,72(sp)
    800051ee:	6906                	ld	s2,64(sp)
    800051f0:	79e2                	ld	s3,56(sp)
    800051f2:	7a42                	ld	s4,48(sp)
    800051f4:	7aa2                	ld	s5,40(sp)
    800051f6:	7b02                	ld	s6,32(sp)
    800051f8:	6be2                	ld	s7,24(sp)
    800051fa:	6c42                	ld	s8,16(sp)
    800051fc:	6125                	addi	sp,sp,96
    800051fe:	8082                	ret
      wakeup(&pi->nread);
    80005200:	8562                	mv	a0,s8
    80005202:	ffffd097          	auipc	ra,0xffffd
    80005206:	2f2080e7          	jalr	754(ra) # 800024f4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000520a:	85a6                	mv	a1,s1
    8000520c:	855e                	mv	a0,s7
    8000520e:	ffffd097          	auipc	ra,0xffffd
    80005212:	150080e7          	jalr	336(ra) # 8000235e <sleep>
  while(i < n){
    80005216:	05495d63          	bge	s2,s4,80005270 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    8000521a:	2204a783          	lw	a5,544(s1)
    8000521e:	dfd5                	beqz	a5,800051da <pipewrite+0x44>
    80005220:	0289a783          	lw	a5,40(s3)
    80005224:	fbdd                	bnez	a5,800051da <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005226:	2184a783          	lw	a5,536(s1)
    8000522a:	21c4a703          	lw	a4,540(s1)
    8000522e:	2007879b          	addiw	a5,a5,512
    80005232:	fcf707e3          	beq	a4,a5,80005200 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005236:	4685                	li	a3,1
    80005238:	01590633          	add	a2,s2,s5
    8000523c:	faf40593          	addi	a1,s0,-81
    80005240:	0509b503          	ld	a0,80(s3)
    80005244:	ffffc097          	auipc	ra,0xffffc
    80005248:	4b4080e7          	jalr	1204(ra) # 800016f8 <copyin>
    8000524c:	03650263          	beq	a0,s6,80005270 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005250:	21c4a783          	lw	a5,540(s1)
    80005254:	0017871b          	addiw	a4,a5,1
    80005258:	20e4ae23          	sw	a4,540(s1)
    8000525c:	1ff7f793          	andi	a5,a5,511
    80005260:	97a6                	add	a5,a5,s1
    80005262:	faf44703          	lbu	a4,-81(s0)
    80005266:	00e78c23          	sb	a4,24(a5)
      i++;
    8000526a:	2905                	addiw	s2,s2,1
    8000526c:	b76d                	j	80005216 <pipewrite+0x80>
  int i = 0;
    8000526e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005270:	21848513          	addi	a0,s1,536
    80005274:	ffffd097          	auipc	ra,0xffffd
    80005278:	280080e7          	jalr	640(ra) # 800024f4 <wakeup>
  release(&pi->lock);
    8000527c:	8526                	mv	a0,s1
    8000527e:	ffffc097          	auipc	ra,0xffffc
    80005282:	a26080e7          	jalr	-1498(ra) # 80000ca4 <release>
  return i;
    80005286:	b785                	j	800051e6 <pipewrite+0x50>

0000000080005288 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005288:	715d                	addi	sp,sp,-80
    8000528a:	e486                	sd	ra,72(sp)
    8000528c:	e0a2                	sd	s0,64(sp)
    8000528e:	fc26                	sd	s1,56(sp)
    80005290:	f84a                	sd	s2,48(sp)
    80005292:	f44e                	sd	s3,40(sp)
    80005294:	f052                	sd	s4,32(sp)
    80005296:	ec56                	sd	s5,24(sp)
    80005298:	e85a                	sd	s6,16(sp)
    8000529a:	0880                	addi	s0,sp,80
    8000529c:	84aa                	mv	s1,a0
    8000529e:	892e                	mv	s2,a1
    800052a0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800052a2:	ffffc097          	auipc	ra,0xffffc
    800052a6:	7b4080e7          	jalr	1972(ra) # 80001a56 <myproc>
    800052aa:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800052ac:	8526                	mv	a0,s1
    800052ae:	ffffc097          	auipc	ra,0xffffc
    800052b2:	92a080e7          	jalr	-1750(ra) # 80000bd8 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052b6:	2184a703          	lw	a4,536(s1)
    800052ba:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052be:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052c2:	02f71463          	bne	a4,a5,800052ea <piperead+0x62>
    800052c6:	2244a783          	lw	a5,548(s1)
    800052ca:	c385                	beqz	a5,800052ea <piperead+0x62>
    if(pr->killed){
    800052cc:	028a2783          	lw	a5,40(s4)
    800052d0:	ebc1                	bnez	a5,80005360 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052d2:	85a6                	mv	a1,s1
    800052d4:	854e                	mv	a0,s3
    800052d6:	ffffd097          	auipc	ra,0xffffd
    800052da:	088080e7          	jalr	136(ra) # 8000235e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052de:	2184a703          	lw	a4,536(s1)
    800052e2:	21c4a783          	lw	a5,540(s1)
    800052e6:	fef700e3          	beq	a4,a5,800052c6 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052ea:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800052ec:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052ee:	05505363          	blez	s5,80005334 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800052f2:	2184a783          	lw	a5,536(s1)
    800052f6:	21c4a703          	lw	a4,540(s1)
    800052fa:	02f70d63          	beq	a4,a5,80005334 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800052fe:	0017871b          	addiw	a4,a5,1
    80005302:	20e4ac23          	sw	a4,536(s1)
    80005306:	1ff7f793          	andi	a5,a5,511
    8000530a:	97a6                	add	a5,a5,s1
    8000530c:	0187c783          	lbu	a5,24(a5)
    80005310:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005314:	4685                	li	a3,1
    80005316:	fbf40613          	addi	a2,s0,-65
    8000531a:	85ca                	mv	a1,s2
    8000531c:	050a3503          	ld	a0,80(s4)
    80005320:	ffffc097          	auipc	ra,0xffffc
    80005324:	34c080e7          	jalr	844(ra) # 8000166c <copyout>
    80005328:	01650663          	beq	a0,s6,80005334 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000532c:	2985                	addiw	s3,s3,1
    8000532e:	0905                	addi	s2,s2,1
    80005330:	fd3a91e3          	bne	s5,s3,800052f2 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005334:	21c48513          	addi	a0,s1,540
    80005338:	ffffd097          	auipc	ra,0xffffd
    8000533c:	1bc080e7          	jalr	444(ra) # 800024f4 <wakeup>
  release(&pi->lock);
    80005340:	8526                	mv	a0,s1
    80005342:	ffffc097          	auipc	ra,0xffffc
    80005346:	962080e7          	jalr	-1694(ra) # 80000ca4 <release>
  return i;
}
    8000534a:	854e                	mv	a0,s3
    8000534c:	60a6                	ld	ra,72(sp)
    8000534e:	6406                	ld	s0,64(sp)
    80005350:	74e2                	ld	s1,56(sp)
    80005352:	7942                	ld	s2,48(sp)
    80005354:	79a2                	ld	s3,40(sp)
    80005356:	7a02                	ld	s4,32(sp)
    80005358:	6ae2                	ld	s5,24(sp)
    8000535a:	6b42                	ld	s6,16(sp)
    8000535c:	6161                	addi	sp,sp,80
    8000535e:	8082                	ret
      release(&pi->lock);
    80005360:	8526                	mv	a0,s1
    80005362:	ffffc097          	auipc	ra,0xffffc
    80005366:	942080e7          	jalr	-1726(ra) # 80000ca4 <release>
      return -1;
    8000536a:	59fd                	li	s3,-1
    8000536c:	bff9                	j	8000534a <piperead+0xc2>

000000008000536e <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    8000536e:	de010113          	addi	sp,sp,-544
    80005372:	20113c23          	sd	ra,536(sp)
    80005376:	20813823          	sd	s0,528(sp)
    8000537a:	20913423          	sd	s1,520(sp)
    8000537e:	21213023          	sd	s2,512(sp)
    80005382:	ffce                	sd	s3,504(sp)
    80005384:	fbd2                	sd	s4,496(sp)
    80005386:	f7d6                	sd	s5,488(sp)
    80005388:	f3da                	sd	s6,480(sp)
    8000538a:	efde                	sd	s7,472(sp)
    8000538c:	ebe2                	sd	s8,464(sp)
    8000538e:	e7e6                	sd	s9,456(sp)
    80005390:	e3ea                	sd	s10,448(sp)
    80005392:	ff6e                	sd	s11,440(sp)
    80005394:	1400                	addi	s0,sp,544
    80005396:	dea43c23          	sd	a0,-520(s0)
    8000539a:	deb43423          	sd	a1,-536(s0)
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  struct thread *ot;
  pagetable_t pagetable = 0, oldpagetable;
  struct thread *t = mythread();
    8000539e:	ffffc097          	auipc	ra,0xffffc
    800053a2:	73e080e7          	jalr	1854(ra) # 80001adc <mythread>
    800053a6:	892a                	mv	s2,a0
  struct proc *p = t->tproc;
    800053a8:	00853983          	ld	s3,8(a0)

  acquire(&p->lock);
    800053ac:	854e                	mv	a0,s3
    800053ae:	ffffc097          	auipc	ra,0xffffc
    800053b2:	82a080e7          	jalr	-2006(ra) # 80000bd8 <acquire>
  for(ot = p->threads; ot < &p->threads[NTHREAD]; ot++){
    800053b6:	27898a13          	addi	s4,s3,632
    800053ba:	77898493          	addi	s1,s3,1912
    800053be:	87d2                	mv	a5,s4
    if(ot->state != UNUSED && t != ot) {
      ot->killed = 1;
    800053c0:	4605                	li	a2,1
      if(ot->state == SLEEPING){
    800053c2:	4689                	li	a3,2
        ot->state = RUNNABLE;
    800053c4:	458d                	li	a1,3
    800053c6:	a029                	j	800053d0 <exec+0x62>
  for(ot = p->threads; ot < &p->threads[NTHREAD]; ot++){
    800053c8:	0a078793          	addi	a5,a5,160
    800053cc:	00978c63          	beq	a5,s1,800053e4 <exec+0x76>
    if(ot->state != UNUSED && t != ot) {
    800053d0:	43d8                	lw	a4,4(a5)
    800053d2:	db7d                	beqz	a4,800053c8 <exec+0x5a>
    800053d4:	fef90ae3          	beq	s2,a5,800053c8 <exec+0x5a>
      ot->killed = 1;
    800053d8:	08c7ac23          	sw	a2,152(a5)
      if(ot->state == SLEEPING){
    800053dc:	fed716e3          	bne	a4,a3,800053c8 <exec+0x5a>
        ot->state = RUNNABLE;
    800053e0:	c3cc                	sw	a1,4(a5)
    800053e2:	b7dd                	j	800053c8 <exec+0x5a>
      }
    }
  }
  release(&p->lock);
    800053e4:	854e                	mv	a0,s3
    800053e6:	ffffc097          	auipc	ra,0xffffc
    800053ea:	8be080e7          	jalr	-1858(ra) # 80000ca4 <release>

  while(1){
    int live_threads = 0;
    800053ee:	4581                	li	a1,0
    for(ot = p->threads; ot < &p->threads[NTHREAD]; ot++){
      if(ot->state != UNUSED && t != ot && ot->state != ZOMBIE) {
    800053f0:	4695                	li	a3,5
        live_threads = 1;
    800053f2:	4605                	li	a2,1
    for(ot = p->threads; ot < &p->threads[NTHREAD]; ot++){
    800053f4:	87d2                	mv	a5,s4
    int live_threads = 0;
    800053f6:	e0b43423          	sd	a1,-504(s0)
    800053fa:	a029                	j	80005404 <exec+0x96>
    for(ot = p->threads; ot < &p->threads[NTHREAD]; ot++){
    800053fc:	0a078793          	addi	a5,a5,160
    80005400:	00978b63          	beq	a5,s1,80005416 <exec+0xa8>
      if(ot->state != UNUSED && t != ot && ot->state != ZOMBIE) {
    80005404:	43d8                	lw	a4,4(a5)
    80005406:	db7d                	beqz	a4,800053fc <exec+0x8e>
    80005408:	fef90ae3          	beq	s2,a5,800053fc <exec+0x8e>
    8000540c:	fed708e3          	beq	a4,a3,800053fc <exec+0x8e>
        live_threads = 1;
    80005410:	e0c43423          	sd	a2,-504(s0)
    80005414:	b7e5                	j	800053fc <exec+0x8e>
      }
    }
    if(!live_threads) break;
    80005416:	e0843783          	ld	a5,-504(s0)
    8000541a:	ffe9                	bnez	a5,800053f4 <exec+0x86>
  }
  

  begin_op();
    8000541c:	fffff097          	auipc	ra,0xfffff
    80005420:	434080e7          	jalr	1076(ra) # 80004850 <begin_op>

  if((ip = namei(path)) == 0){
    80005424:	df843503          	ld	a0,-520(s0)
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	208080e7          	jalr	520(ra) # 80004630 <namei>
    80005430:	8aaa                	mv	s5,a0
    80005432:	c935                	beqz	a0,800054a6 <exec+0x138>
    end_op();
    return -1;
  }
  ilock(ip);
    80005434:	fffff097          	auipc	ra,0xfffff
    80005438:	a46080e7          	jalr	-1466(ra) # 80003e7a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000543c:	04000713          	li	a4,64
    80005440:	4681                	li	a3,0
    80005442:	e4840613          	addi	a2,s0,-440
    80005446:	4581                	li	a1,0
    80005448:	8556                	mv	a0,s5
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	ce4080e7          	jalr	-796(ra) # 8000412e <readi>
    80005452:	04000793          	li	a5,64
    80005456:	00f51a63          	bne	a0,a5,8000546a <exec+0xfc>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000545a:	e4842703          	lw	a4,-440(s0)
    8000545e:	464c47b7          	lui	a5,0x464c4
    80005462:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005466:	04f70663          	beq	a4,a5,800054b2 <exec+0x144>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000546a:	8556                	mv	a0,s5
    8000546c:	fffff097          	auipc	ra,0xfffff
    80005470:	c70080e7          	jalr	-912(ra) # 800040dc <iunlockput>
    end_op();
    80005474:	fffff097          	auipc	ra,0xfffff
    80005478:	45c080e7          	jalr	1116(ra) # 800048d0 <end_op>
  }
  return -1;
    8000547c:	557d                	li	a0,-1
}
    8000547e:	21813083          	ld	ra,536(sp)
    80005482:	21013403          	ld	s0,528(sp)
    80005486:	20813483          	ld	s1,520(sp)
    8000548a:	20013903          	ld	s2,512(sp)
    8000548e:	79fe                	ld	s3,504(sp)
    80005490:	7a5e                	ld	s4,496(sp)
    80005492:	7abe                	ld	s5,488(sp)
    80005494:	7b1e                	ld	s6,480(sp)
    80005496:	6bfe                	ld	s7,472(sp)
    80005498:	6c5e                	ld	s8,464(sp)
    8000549a:	6cbe                	ld	s9,456(sp)
    8000549c:	6d1e                	ld	s10,448(sp)
    8000549e:	7dfa                	ld	s11,440(sp)
    800054a0:	22010113          	addi	sp,sp,544
    800054a4:	8082                	ret
    end_op();
    800054a6:	fffff097          	auipc	ra,0xfffff
    800054aa:	42a080e7          	jalr	1066(ra) # 800048d0 <end_op>
    return -1;
    800054ae:	557d                	li	a0,-1
    800054b0:	b7f9                	j	8000547e <exec+0x110>
  if((pagetable = proc_pagetable(p)) == 0)
    800054b2:	854e                	mv	a0,s3
    800054b4:	ffffc097          	auipc	ra,0xffffc
    800054b8:	768080e7          	jalr	1896(ra) # 80001c1c <proc_pagetable>
    800054bc:	8b2a                	mv	s6,a0
    800054be:	d555                	beqz	a0,8000546a <exec+0xfc>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054c0:	e6842783          	lw	a5,-408(s0)
    800054c4:	e8045703          	lhu	a4,-384(s0)
    800054c8:	c725                	beqz	a4,80005530 <exec+0x1c2>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800054ca:	4481                	li	s1,0
    if(ph.vaddr % PGSIZE != 0)
    800054cc:	6a05                	lui	s4,0x1
    800054ce:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800054d2:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800054d6:	6d85                	lui	s11,0x1
    800054d8:	7d7d                	lui	s10,0xfffff
    800054da:	a435                	j	80005706 <exec+0x398>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800054dc:	00003517          	auipc	a0,0x3
    800054e0:	24450513          	addi	a0,a0,580 # 80008720 <syscalls+0x2b8>
    800054e4:	ffffb097          	auipc	ra,0xffffb
    800054e8:	054080e7          	jalr	84(ra) # 80000538 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800054ec:	874a                	mv	a4,s2
    800054ee:	009c86bb          	addw	a3,s9,s1
    800054f2:	4581                	li	a1,0
    800054f4:	8556                	mv	a0,s5
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	c38080e7          	jalr	-968(ra) # 8000412e <readi>
    800054fe:	2501                	sext.w	a0,a0
    80005500:	1aa91963          	bne	s2,a0,800056b2 <exec+0x344>
  for(i = 0; i < sz; i += PGSIZE){
    80005504:	009d84bb          	addw	s1,s11,s1
    80005508:	013d09bb          	addw	s3,s10,s3
    8000550c:	1d74fd63          	bgeu	s1,s7,800056e6 <exec+0x378>
    pa = walkaddr(pagetable, va + i);
    80005510:	02049593          	slli	a1,s1,0x20
    80005514:	9181                	srli	a1,a1,0x20
    80005516:	95e2                	add	a1,a1,s8
    80005518:	855a                	mv	a0,s6
    8000551a:	ffffc097          	auipc	ra,0xffffc
    8000551e:	b60080e7          	jalr	-1184(ra) # 8000107a <walkaddr>
    80005522:	862a                	mv	a2,a0
    if(pa == 0)
    80005524:	dd45                	beqz	a0,800054dc <exec+0x16e>
      n = PGSIZE;
    80005526:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005528:	fd49f2e3          	bgeu	s3,s4,800054ec <exec+0x17e>
      n = sz - i;
    8000552c:	894e                	mv	s2,s3
    8000552e:	bf7d                	j	800054ec <exec+0x17e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005530:	4481                	li	s1,0
  iunlockput(ip);
    80005532:	8556                	mv	a0,s5
    80005534:	fffff097          	auipc	ra,0xfffff
    80005538:	ba8080e7          	jalr	-1112(ra) # 800040dc <iunlockput>
  end_op();
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	394080e7          	jalr	916(ra) # 800048d0 <end_op>
  t = mythread();
    80005544:	ffffc097          	auipc	ra,0xffffc
    80005548:	598080e7          	jalr	1432(ra) # 80001adc <mythread>
    8000554c:	8caa                	mv	s9,a0
  p = t->tproc;
    8000554e:	00853b83          	ld	s7,8(a0)
  uint64 oldsz = p->sz;
    80005552:	048bbd03          	ld	s10,72(s7) # 1048 <_entry-0x7fffefb8>
  sz = PGROUNDUP(sz);
    80005556:	6785                	lui	a5,0x1
    80005558:	17fd                	addi	a5,a5,-1
    8000555a:	94be                	add	s1,s1,a5
    8000555c:	77fd                	lui	a5,0xfffff
    8000555e:	8cfd                	and	s1,s1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005560:	6609                	lui	a2,0x2
    80005562:	9626                	add	a2,a2,s1
    80005564:	85a6                	mv	a1,s1
    80005566:	855a                	mv	a0,s6
    80005568:	ffffc097          	auipc	ra,0xffffc
    8000556c:	eb4080e7          	jalr	-332(ra) # 8000141c <uvmalloc>
    80005570:	892a                	mv	s2,a0
    80005572:	dea43823          	sd	a0,-528(s0)
    80005576:	e509                	bnez	a0,80005580 <exec+0x212>
  sz = PGROUNDUP(sz);
    80005578:	de943823          	sd	s1,-528(s0)
  ip = 0;
    8000557c:	4a81                	li	s5,0
    8000557e:	aa15                	j	800056b2 <exec+0x344>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005580:	75f9                	lui	a1,0xffffe
    80005582:	95aa                	add	a1,a1,a0
    80005584:	855a                	mv	a0,s6
    80005586:	ffffc097          	auipc	ra,0xffffc
    8000558a:	0b4080e7          	jalr	180(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    8000558e:	7c7d                	lui	s8,0xfffff
    80005590:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    80005592:	de843783          	ld	a5,-536(s0)
    80005596:	6388                	ld	a0,0(a5)
    80005598:	c52d                	beqz	a0,80005602 <exec+0x294>
    8000559a:	e8840993          	addi	s3,s0,-376
    8000559e:	f8840a93          	addi	s5,s0,-120
    800055a2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800055a4:	ffffc097          	auipc	ra,0xffffc
    800055a8:	8cc080e7          	jalr	-1844(ra) # 80000e70 <strlen>
    800055ac:	0015079b          	addiw	a5,a0,1
    800055b0:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800055b4:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800055b8:	13896163          	bltu	s2,s8,800056da <exec+0x36c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800055bc:	de843d83          	ld	s11,-536(s0)
    800055c0:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800055c4:	8552                	mv	a0,s4
    800055c6:	ffffc097          	auipc	ra,0xffffc
    800055ca:	8aa080e7          	jalr	-1878(ra) # 80000e70 <strlen>
    800055ce:	0015069b          	addiw	a3,a0,1
    800055d2:	8652                	mv	a2,s4
    800055d4:	85ca                	mv	a1,s2
    800055d6:	855a                	mv	a0,s6
    800055d8:	ffffc097          	auipc	ra,0xffffc
    800055dc:	094080e7          	jalr	148(ra) # 8000166c <copyout>
    800055e0:	0e054f63          	bltz	a0,800056de <exec+0x370>
    ustack[argc] = sp;
    800055e4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800055e8:	0485                	addi	s1,s1,1
    800055ea:	008d8793          	addi	a5,s11,8
    800055ee:	def43423          	sd	a5,-536(s0)
    800055f2:	008db503          	ld	a0,8(s11)
    800055f6:	c909                	beqz	a0,80005608 <exec+0x29a>
    if(argc >= MAXARG)
    800055f8:	09a1                	addi	s3,s3,8
    800055fa:	fb3a95e3          	bne	s5,s3,800055a4 <exec+0x236>
  ip = 0;
    800055fe:	4a81                	li	s5,0
    80005600:	a84d                	j	800056b2 <exec+0x344>
  sp = sz;
    80005602:	df043903          	ld	s2,-528(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005606:	4481                	li	s1,0
  ustack[argc] = 0;
    80005608:	00349793          	slli	a5,s1,0x3
    8000560c:	f9040713          	addi	a4,s0,-112
    80005610:	97ba                	add	a5,a5,a4
    80005612:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffc0ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005616:	00148693          	addi	a3,s1,1
    8000561a:	068e                	slli	a3,a3,0x3
    8000561c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005620:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80005624:	4a81                	li	s5,0
  if(sp < stackbase)
    80005626:	09896663          	bltu	s2,s8,800056b2 <exec+0x344>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000562a:	e8840613          	addi	a2,s0,-376
    8000562e:	85ca                	mv	a1,s2
    80005630:	855a                	mv	a0,s6
    80005632:	ffffc097          	auipc	ra,0xffffc
    80005636:	03a080e7          	jalr	58(ra) # 8000166c <copyout>
    8000563a:	0a054463          	bltz	a0,800056e2 <exec+0x374>
  t->trapframe->a1 = sp;
    8000563e:	018cb783          	ld	a5,24(s9)
    80005642:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005646:	df843783          	ld	a5,-520(s0)
    8000564a:	0007c703          	lbu	a4,0(a5)
    8000564e:	cf11                	beqz	a4,8000566a <exec+0x2fc>
    80005650:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005652:	02f00693          	li	a3,47
    80005656:	a029                	j	80005660 <exec+0x2f2>
  for(last=s=path; *s; s++)
    80005658:	0785                	addi	a5,a5,1
    8000565a:	fff7c703          	lbu	a4,-1(a5)
    8000565e:	c711                	beqz	a4,8000566a <exec+0x2fc>
    if(*s == '/')
    80005660:	fed71ce3          	bne	a4,a3,80005658 <exec+0x2ea>
      last = s+1;
    80005664:	def43c23          	sd	a5,-520(s0)
    80005668:	bfc5                	j	80005658 <exec+0x2ea>
  safestrcpy(p->name, last, sizeof(p->name));
    8000566a:	4641                	li	a2,16
    8000566c:	df843583          	ld	a1,-520(s0)
    80005670:	158b8513          	addi	a0,s7,344
    80005674:	ffffb097          	auipc	ra,0xffffb
    80005678:	7ca080e7          	jalr	1994(ra) # 80000e3e <safestrcpy>
  oldpagetable = p->pagetable;
    8000567c:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005680:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005684:	df043783          	ld	a5,-528(s0)
    80005688:	04fbb423          	sd	a5,72(s7)
  t->trapframe->epc = elf.entry;  // initial program counter = main
    8000568c:	018cb783          	ld	a5,24(s9)
    80005690:	e6043703          	ld	a4,-416(s0)
    80005694:	ef98                	sd	a4,24(a5)
  t->trapframe->sp = sp; // initial stack pointer
    80005696:	018cb783          	ld	a5,24(s9)
    8000569a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000569e:	85ea                	mv	a1,s10
    800056a0:	ffffc097          	auipc	ra,0xffffc
    800056a4:	618080e7          	jalr	1560(ra) # 80001cb8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800056a8:	0004851b          	sext.w	a0,s1
    800056ac:	bbc9                	j	8000547e <exec+0x110>
    800056ae:	de943823          	sd	s1,-528(s0)
    proc_freepagetable(pagetable, sz);
    800056b2:	df043583          	ld	a1,-528(s0)
    800056b6:	855a                	mv	a0,s6
    800056b8:	ffffc097          	auipc	ra,0xffffc
    800056bc:	600080e7          	jalr	1536(ra) # 80001cb8 <proc_freepagetable>
  if(ip){
    800056c0:	da0a95e3          	bnez	s5,8000546a <exec+0xfc>
  return -1;
    800056c4:	557d                	li	a0,-1
    800056c6:	bb65                	j	8000547e <exec+0x110>
    800056c8:	de943823          	sd	s1,-528(s0)
    800056cc:	b7dd                	j	800056b2 <exec+0x344>
    800056ce:	de943823          	sd	s1,-528(s0)
    800056d2:	b7c5                	j	800056b2 <exec+0x344>
    800056d4:	de943823          	sd	s1,-528(s0)
    800056d8:	bfe9                	j	800056b2 <exec+0x344>
  ip = 0;
    800056da:	4a81                	li	s5,0
    800056dc:	bfd9                	j	800056b2 <exec+0x344>
    800056de:	4a81                	li	s5,0
    800056e0:	bfc9                	j	800056b2 <exec+0x344>
    800056e2:	4a81                	li	s5,0
    800056e4:	b7f9                	j	800056b2 <exec+0x344>
    sz = sz1;
    800056e6:	df043483          	ld	s1,-528(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056ea:	e0843783          	ld	a5,-504(s0)
    800056ee:	0017869b          	addiw	a3,a5,1
    800056f2:	e0d43423          	sd	a3,-504(s0)
    800056f6:	e0043783          	ld	a5,-512(s0)
    800056fa:	0387879b          	addiw	a5,a5,56
    800056fe:	e8045703          	lhu	a4,-384(s0)
    80005702:	e2e6d8e3          	bge	a3,a4,80005532 <exec+0x1c4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005706:	2781                	sext.w	a5,a5
    80005708:	e0f43023          	sd	a5,-512(s0)
    8000570c:	03800713          	li	a4,56
    80005710:	86be                	mv	a3,a5
    80005712:	e1040613          	addi	a2,s0,-496
    80005716:	4581                	li	a1,0
    80005718:	8556                	mv	a0,s5
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	a14080e7          	jalr	-1516(ra) # 8000412e <readi>
    80005722:	03800793          	li	a5,56
    80005726:	f8f514e3          	bne	a0,a5,800056ae <exec+0x340>
    if(ph.type != ELF_PROG_LOAD)
    8000572a:	e1042783          	lw	a5,-496(s0)
    8000572e:	4705                	li	a4,1
    80005730:	fae79de3          	bne	a5,a4,800056ea <exec+0x37c>
    if(ph.memsz < ph.filesz)
    80005734:	e3843603          	ld	a2,-456(s0)
    80005738:	e3043783          	ld	a5,-464(s0)
    8000573c:	f8f666e3          	bltu	a2,a5,800056c8 <exec+0x35a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005740:	e2043783          	ld	a5,-480(s0)
    80005744:	963e                	add	a2,a2,a5
    80005746:	f8f664e3          	bltu	a2,a5,800056ce <exec+0x360>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000574a:	85a6                	mv	a1,s1
    8000574c:	855a                	mv	a0,s6
    8000574e:	ffffc097          	auipc	ra,0xffffc
    80005752:	cce080e7          	jalr	-818(ra) # 8000141c <uvmalloc>
    80005756:	dea43823          	sd	a0,-528(s0)
    8000575a:	dd2d                	beqz	a0,800056d4 <exec+0x366>
    if(ph.vaddr % PGSIZE != 0)
    8000575c:	e2043c03          	ld	s8,-480(s0)
    80005760:	de043783          	ld	a5,-544(s0)
    80005764:	00fc77b3          	and	a5,s8,a5
    80005768:	f7a9                	bnez	a5,800056b2 <exec+0x344>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000576a:	e1842c83          	lw	s9,-488(s0)
    8000576e:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005772:	f60b8ae3          	beqz	s7,800056e6 <exec+0x378>
    80005776:	89de                	mv	s3,s7
    80005778:	4481                	li	s1,0
    8000577a:	bb59                	j	80005510 <exec+0x1a2>

000000008000577c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000577c:	7179                	addi	sp,sp,-48
    8000577e:	f406                	sd	ra,40(sp)
    80005780:	f022                	sd	s0,32(sp)
    80005782:	ec26                	sd	s1,24(sp)
    80005784:	e84a                	sd	s2,16(sp)
    80005786:	1800                	addi	s0,sp,48
    80005788:	892e                	mv	s2,a1
    8000578a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000578c:	fdc40593          	addi	a1,s0,-36
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	9e8080e7          	jalr	-1560(ra) # 80003178 <argint>
    80005798:	04054063          	bltz	a0,800057d8 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000579c:	fdc42703          	lw	a4,-36(s0)
    800057a0:	47bd                	li	a5,15
    800057a2:	02e7ed63          	bltu	a5,a4,800057dc <argfd+0x60>
    800057a6:	ffffc097          	auipc	ra,0xffffc
    800057aa:	2b0080e7          	jalr	688(ra) # 80001a56 <myproc>
    800057ae:	fdc42703          	lw	a4,-36(s0)
    800057b2:	01a70793          	addi	a5,a4,26
    800057b6:	078e                	slli	a5,a5,0x3
    800057b8:	953e                	add	a0,a0,a5
    800057ba:	611c                	ld	a5,0(a0)
    800057bc:	c395                	beqz	a5,800057e0 <argfd+0x64>
    return -1;
  if(pfd)
    800057be:	00090463          	beqz	s2,800057c6 <argfd+0x4a>
    *pfd = fd;
    800057c2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800057c6:	4501                	li	a0,0
  if(pf)
    800057c8:	c091                	beqz	s1,800057cc <argfd+0x50>
    *pf = f;
    800057ca:	e09c                	sd	a5,0(s1)
}
    800057cc:	70a2                	ld	ra,40(sp)
    800057ce:	7402                	ld	s0,32(sp)
    800057d0:	64e2                	ld	s1,24(sp)
    800057d2:	6942                	ld	s2,16(sp)
    800057d4:	6145                	addi	sp,sp,48
    800057d6:	8082                	ret
    return -1;
    800057d8:	557d                	li	a0,-1
    800057da:	bfcd                	j	800057cc <argfd+0x50>
    return -1;
    800057dc:	557d                	li	a0,-1
    800057de:	b7fd                	j	800057cc <argfd+0x50>
    800057e0:	557d                	li	a0,-1
    800057e2:	b7ed                	j	800057cc <argfd+0x50>

00000000800057e4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800057e4:	1101                	addi	sp,sp,-32
    800057e6:	ec06                	sd	ra,24(sp)
    800057e8:	e822                	sd	s0,16(sp)
    800057ea:	e426                	sd	s1,8(sp)
    800057ec:	1000                	addi	s0,sp,32
    800057ee:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800057f0:	ffffc097          	auipc	ra,0xffffc
    800057f4:	266080e7          	jalr	614(ra) # 80001a56 <myproc>
    800057f8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800057fa:	0d050793          	addi	a5,a0,208
    800057fe:	4501                	li	a0,0
    80005800:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005802:	6398                	ld	a4,0(a5)
    80005804:	cb19                	beqz	a4,8000581a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005806:	2505                	addiw	a0,a0,1
    80005808:	07a1                	addi	a5,a5,8
    8000580a:	fed51ce3          	bne	a0,a3,80005802 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000580e:	557d                	li	a0,-1
}
    80005810:	60e2                	ld	ra,24(sp)
    80005812:	6442                	ld	s0,16(sp)
    80005814:	64a2                	ld	s1,8(sp)
    80005816:	6105                	addi	sp,sp,32
    80005818:	8082                	ret
      p->ofile[fd] = f;
    8000581a:	01a50793          	addi	a5,a0,26
    8000581e:	078e                	slli	a5,a5,0x3
    80005820:	963e                	add	a2,a2,a5
    80005822:	e204                	sd	s1,0(a2)
      return fd;
    80005824:	b7f5                	j	80005810 <fdalloc+0x2c>

0000000080005826 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005826:	715d                	addi	sp,sp,-80
    80005828:	e486                	sd	ra,72(sp)
    8000582a:	e0a2                	sd	s0,64(sp)
    8000582c:	fc26                	sd	s1,56(sp)
    8000582e:	f84a                	sd	s2,48(sp)
    80005830:	f44e                	sd	s3,40(sp)
    80005832:	f052                	sd	s4,32(sp)
    80005834:	ec56                	sd	s5,24(sp)
    80005836:	0880                	addi	s0,sp,80
    80005838:	89ae                	mv	s3,a1
    8000583a:	8ab2                	mv	s5,a2
    8000583c:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000583e:	fb040593          	addi	a1,s0,-80
    80005842:	fffff097          	auipc	ra,0xfffff
    80005846:	e0c080e7          	jalr	-500(ra) # 8000464e <nameiparent>
    8000584a:	892a                	mv	s2,a0
    8000584c:	12050e63          	beqz	a0,80005988 <create+0x162>
    return 0;

  ilock(dp);
    80005850:	ffffe097          	auipc	ra,0xffffe
    80005854:	62a080e7          	jalr	1578(ra) # 80003e7a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005858:	4601                	li	a2,0
    8000585a:	fb040593          	addi	a1,s0,-80
    8000585e:	854a                	mv	a0,s2
    80005860:	fffff097          	auipc	ra,0xfffff
    80005864:	afe080e7          	jalr	-1282(ra) # 8000435e <dirlookup>
    80005868:	84aa                	mv	s1,a0
    8000586a:	c921                	beqz	a0,800058ba <create+0x94>
    iunlockput(dp);
    8000586c:	854a                	mv	a0,s2
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	86e080e7          	jalr	-1938(ra) # 800040dc <iunlockput>
    ilock(ip);
    80005876:	8526                	mv	a0,s1
    80005878:	ffffe097          	auipc	ra,0xffffe
    8000587c:	602080e7          	jalr	1538(ra) # 80003e7a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005880:	2981                	sext.w	s3,s3
    80005882:	4789                	li	a5,2
    80005884:	02f99463          	bne	s3,a5,800058ac <create+0x86>
    80005888:	0444d783          	lhu	a5,68(s1)
    8000588c:	37f9                	addiw	a5,a5,-2
    8000588e:	17c2                	slli	a5,a5,0x30
    80005890:	93c1                	srli	a5,a5,0x30
    80005892:	4705                	li	a4,1
    80005894:	00f76c63          	bltu	a4,a5,800058ac <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005898:	8526                	mv	a0,s1
    8000589a:	60a6                	ld	ra,72(sp)
    8000589c:	6406                	ld	s0,64(sp)
    8000589e:	74e2                	ld	s1,56(sp)
    800058a0:	7942                	ld	s2,48(sp)
    800058a2:	79a2                	ld	s3,40(sp)
    800058a4:	7a02                	ld	s4,32(sp)
    800058a6:	6ae2                	ld	s5,24(sp)
    800058a8:	6161                	addi	sp,sp,80
    800058aa:	8082                	ret
    iunlockput(ip);
    800058ac:	8526                	mv	a0,s1
    800058ae:	fffff097          	auipc	ra,0xfffff
    800058b2:	82e080e7          	jalr	-2002(ra) # 800040dc <iunlockput>
    return 0;
    800058b6:	4481                	li	s1,0
    800058b8:	b7c5                	j	80005898 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800058ba:	85ce                	mv	a1,s3
    800058bc:	00092503          	lw	a0,0(s2)
    800058c0:	ffffe097          	auipc	ra,0xffffe
    800058c4:	422080e7          	jalr	1058(ra) # 80003ce2 <ialloc>
    800058c8:	84aa                	mv	s1,a0
    800058ca:	c521                	beqz	a0,80005912 <create+0xec>
  ilock(ip);
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	5ae080e7          	jalr	1454(ra) # 80003e7a <ilock>
  ip->major = major;
    800058d4:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800058d8:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800058dc:	4a05                	li	s4,1
    800058de:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800058e2:	8526                	mv	a0,s1
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	4cc080e7          	jalr	1228(ra) # 80003db0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800058ec:	2981                	sext.w	s3,s3
    800058ee:	03498a63          	beq	s3,s4,80005922 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800058f2:	40d0                	lw	a2,4(s1)
    800058f4:	fb040593          	addi	a1,s0,-80
    800058f8:	854a                	mv	a0,s2
    800058fa:	fffff097          	auipc	ra,0xfffff
    800058fe:	c74080e7          	jalr	-908(ra) # 8000456e <dirlink>
    80005902:	06054b63          	bltz	a0,80005978 <create+0x152>
  iunlockput(dp);
    80005906:	854a                	mv	a0,s2
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	7d4080e7          	jalr	2004(ra) # 800040dc <iunlockput>
  return ip;
    80005910:	b761                	j	80005898 <create+0x72>
    panic("create: ialloc");
    80005912:	00003517          	auipc	a0,0x3
    80005916:	e2e50513          	addi	a0,a0,-466 # 80008740 <syscalls+0x2d8>
    8000591a:	ffffb097          	auipc	ra,0xffffb
    8000591e:	c1e080e7          	jalr	-994(ra) # 80000538 <panic>
    dp->nlink++;  // for ".."
    80005922:	04a95783          	lhu	a5,74(s2)
    80005926:	2785                	addiw	a5,a5,1
    80005928:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000592c:	854a                	mv	a0,s2
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	482080e7          	jalr	1154(ra) # 80003db0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005936:	40d0                	lw	a2,4(s1)
    80005938:	00003597          	auipc	a1,0x3
    8000593c:	e1858593          	addi	a1,a1,-488 # 80008750 <syscalls+0x2e8>
    80005940:	8526                	mv	a0,s1
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	c2c080e7          	jalr	-980(ra) # 8000456e <dirlink>
    8000594a:	00054f63          	bltz	a0,80005968 <create+0x142>
    8000594e:	00492603          	lw	a2,4(s2)
    80005952:	00003597          	auipc	a1,0x3
    80005956:	e0658593          	addi	a1,a1,-506 # 80008758 <syscalls+0x2f0>
    8000595a:	8526                	mv	a0,s1
    8000595c:	fffff097          	auipc	ra,0xfffff
    80005960:	c12080e7          	jalr	-1006(ra) # 8000456e <dirlink>
    80005964:	f80557e3          	bgez	a0,800058f2 <create+0xcc>
      panic("create dots");
    80005968:	00003517          	auipc	a0,0x3
    8000596c:	df850513          	addi	a0,a0,-520 # 80008760 <syscalls+0x2f8>
    80005970:	ffffb097          	auipc	ra,0xffffb
    80005974:	bc8080e7          	jalr	-1080(ra) # 80000538 <panic>
    panic("create: dirlink");
    80005978:	00003517          	auipc	a0,0x3
    8000597c:	df850513          	addi	a0,a0,-520 # 80008770 <syscalls+0x308>
    80005980:	ffffb097          	auipc	ra,0xffffb
    80005984:	bb8080e7          	jalr	-1096(ra) # 80000538 <panic>
    return 0;
    80005988:	84aa                	mv	s1,a0
    8000598a:	b739                	j	80005898 <create+0x72>

000000008000598c <sys_dup>:
{
    8000598c:	7179                	addi	sp,sp,-48
    8000598e:	f406                	sd	ra,40(sp)
    80005990:	f022                	sd	s0,32(sp)
    80005992:	ec26                	sd	s1,24(sp)
    80005994:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005996:	fd840613          	addi	a2,s0,-40
    8000599a:	4581                	li	a1,0
    8000599c:	4501                	li	a0,0
    8000599e:	00000097          	auipc	ra,0x0
    800059a2:	dde080e7          	jalr	-546(ra) # 8000577c <argfd>
    return -1;
    800059a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800059a8:	02054363          	bltz	a0,800059ce <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800059ac:	fd843503          	ld	a0,-40(s0)
    800059b0:	00000097          	auipc	ra,0x0
    800059b4:	e34080e7          	jalr	-460(ra) # 800057e4 <fdalloc>
    800059b8:	84aa                	mv	s1,a0
    return -1;
    800059ba:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800059bc:	00054963          	bltz	a0,800059ce <sys_dup+0x42>
  filedup(f);
    800059c0:	fd843503          	ld	a0,-40(s0)
    800059c4:	fffff097          	auipc	ra,0xfffff
    800059c8:	306080e7          	jalr	774(ra) # 80004cca <filedup>
  return fd;
    800059cc:	87a6                	mv	a5,s1
}
    800059ce:	853e                	mv	a0,a5
    800059d0:	70a2                	ld	ra,40(sp)
    800059d2:	7402                	ld	s0,32(sp)
    800059d4:	64e2                	ld	s1,24(sp)
    800059d6:	6145                	addi	sp,sp,48
    800059d8:	8082                	ret

00000000800059da <sys_read>:
{
    800059da:	7179                	addi	sp,sp,-48
    800059dc:	f406                	sd	ra,40(sp)
    800059de:	f022                	sd	s0,32(sp)
    800059e0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800059e2:	fe840613          	addi	a2,s0,-24
    800059e6:	4581                	li	a1,0
    800059e8:	4501                	li	a0,0
    800059ea:	00000097          	auipc	ra,0x0
    800059ee:	d92080e7          	jalr	-622(ra) # 8000577c <argfd>
    return -1;
    800059f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800059f4:	04054163          	bltz	a0,80005a36 <sys_read+0x5c>
    800059f8:	fe440593          	addi	a1,s0,-28
    800059fc:	4509                	li	a0,2
    800059fe:	ffffd097          	auipc	ra,0xffffd
    80005a02:	77a080e7          	jalr	1914(ra) # 80003178 <argint>
    return -1;
    80005a06:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a08:	02054763          	bltz	a0,80005a36 <sys_read+0x5c>
    80005a0c:	fd840593          	addi	a1,s0,-40
    80005a10:	4505                	li	a0,1
    80005a12:	ffffd097          	auipc	ra,0xffffd
    80005a16:	788080e7          	jalr	1928(ra) # 8000319a <argaddr>
    return -1;
    80005a1a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a1c:	00054d63          	bltz	a0,80005a36 <sys_read+0x5c>
  return fileread(f, p, n);
    80005a20:	fe442603          	lw	a2,-28(s0)
    80005a24:	fd843583          	ld	a1,-40(s0)
    80005a28:	fe843503          	ld	a0,-24(s0)
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	42a080e7          	jalr	1066(ra) # 80004e56 <fileread>
    80005a34:	87aa                	mv	a5,a0
}
    80005a36:	853e                	mv	a0,a5
    80005a38:	70a2                	ld	ra,40(sp)
    80005a3a:	7402                	ld	s0,32(sp)
    80005a3c:	6145                	addi	sp,sp,48
    80005a3e:	8082                	ret

0000000080005a40 <sys_write>:
{
    80005a40:	7179                	addi	sp,sp,-48
    80005a42:	f406                	sd	ra,40(sp)
    80005a44:	f022                	sd	s0,32(sp)
    80005a46:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a48:	fe840613          	addi	a2,s0,-24
    80005a4c:	4581                	li	a1,0
    80005a4e:	4501                	li	a0,0
    80005a50:	00000097          	auipc	ra,0x0
    80005a54:	d2c080e7          	jalr	-724(ra) # 8000577c <argfd>
    return -1;
    80005a58:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a5a:	04054163          	bltz	a0,80005a9c <sys_write+0x5c>
    80005a5e:	fe440593          	addi	a1,s0,-28
    80005a62:	4509                	li	a0,2
    80005a64:	ffffd097          	auipc	ra,0xffffd
    80005a68:	714080e7          	jalr	1812(ra) # 80003178 <argint>
    return -1;
    80005a6c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a6e:	02054763          	bltz	a0,80005a9c <sys_write+0x5c>
    80005a72:	fd840593          	addi	a1,s0,-40
    80005a76:	4505                	li	a0,1
    80005a78:	ffffd097          	auipc	ra,0xffffd
    80005a7c:	722080e7          	jalr	1826(ra) # 8000319a <argaddr>
    return -1;
    80005a80:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a82:	00054d63          	bltz	a0,80005a9c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005a86:	fe442603          	lw	a2,-28(s0)
    80005a8a:	fd843583          	ld	a1,-40(s0)
    80005a8e:	fe843503          	ld	a0,-24(s0)
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	486080e7          	jalr	1158(ra) # 80004f18 <filewrite>
    80005a9a:	87aa                	mv	a5,a0
}
    80005a9c:	853e                	mv	a0,a5
    80005a9e:	70a2                	ld	ra,40(sp)
    80005aa0:	7402                	ld	s0,32(sp)
    80005aa2:	6145                	addi	sp,sp,48
    80005aa4:	8082                	ret

0000000080005aa6 <sys_close>:
{
    80005aa6:	1101                	addi	sp,sp,-32
    80005aa8:	ec06                	sd	ra,24(sp)
    80005aaa:	e822                	sd	s0,16(sp)
    80005aac:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005aae:	fe040613          	addi	a2,s0,-32
    80005ab2:	fec40593          	addi	a1,s0,-20
    80005ab6:	4501                	li	a0,0
    80005ab8:	00000097          	auipc	ra,0x0
    80005abc:	cc4080e7          	jalr	-828(ra) # 8000577c <argfd>
    return -1;
    80005ac0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005ac2:	02054463          	bltz	a0,80005aea <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005ac6:	ffffc097          	auipc	ra,0xffffc
    80005aca:	f90080e7          	jalr	-112(ra) # 80001a56 <myproc>
    80005ace:	fec42783          	lw	a5,-20(s0)
    80005ad2:	07e9                	addi	a5,a5,26
    80005ad4:	078e                	slli	a5,a5,0x3
    80005ad6:	97aa                	add	a5,a5,a0
    80005ad8:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005adc:	fe043503          	ld	a0,-32(s0)
    80005ae0:	fffff097          	auipc	ra,0xfffff
    80005ae4:	23c080e7          	jalr	572(ra) # 80004d1c <fileclose>
  return 0;
    80005ae8:	4781                	li	a5,0
}
    80005aea:	853e                	mv	a0,a5
    80005aec:	60e2                	ld	ra,24(sp)
    80005aee:	6442                	ld	s0,16(sp)
    80005af0:	6105                	addi	sp,sp,32
    80005af2:	8082                	ret

0000000080005af4 <sys_fstat>:
{
    80005af4:	1101                	addi	sp,sp,-32
    80005af6:	ec06                	sd	ra,24(sp)
    80005af8:	e822                	sd	s0,16(sp)
    80005afa:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005afc:	fe840613          	addi	a2,s0,-24
    80005b00:	4581                	li	a1,0
    80005b02:	4501                	li	a0,0
    80005b04:	00000097          	auipc	ra,0x0
    80005b08:	c78080e7          	jalr	-904(ra) # 8000577c <argfd>
    return -1;
    80005b0c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005b0e:	02054563          	bltz	a0,80005b38 <sys_fstat+0x44>
    80005b12:	fe040593          	addi	a1,s0,-32
    80005b16:	4505                	li	a0,1
    80005b18:	ffffd097          	auipc	ra,0xffffd
    80005b1c:	682080e7          	jalr	1666(ra) # 8000319a <argaddr>
    return -1;
    80005b20:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005b22:	00054b63          	bltz	a0,80005b38 <sys_fstat+0x44>
  return filestat(f, st);
    80005b26:	fe043583          	ld	a1,-32(s0)
    80005b2a:	fe843503          	ld	a0,-24(s0)
    80005b2e:	fffff097          	auipc	ra,0xfffff
    80005b32:	2b6080e7          	jalr	694(ra) # 80004de4 <filestat>
    80005b36:	87aa                	mv	a5,a0
}
    80005b38:	853e                	mv	a0,a5
    80005b3a:	60e2                	ld	ra,24(sp)
    80005b3c:	6442                	ld	s0,16(sp)
    80005b3e:	6105                	addi	sp,sp,32
    80005b40:	8082                	ret

0000000080005b42 <sys_link>:
{
    80005b42:	7169                	addi	sp,sp,-304
    80005b44:	f606                	sd	ra,296(sp)
    80005b46:	f222                	sd	s0,288(sp)
    80005b48:	ee26                	sd	s1,280(sp)
    80005b4a:	ea4a                	sd	s2,272(sp)
    80005b4c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b4e:	08000613          	li	a2,128
    80005b52:	ed040593          	addi	a1,s0,-304
    80005b56:	4501                	li	a0,0
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	664080e7          	jalr	1636(ra) # 800031bc <argstr>
    return -1;
    80005b60:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b62:	10054e63          	bltz	a0,80005c7e <sys_link+0x13c>
    80005b66:	08000613          	li	a2,128
    80005b6a:	f5040593          	addi	a1,s0,-176
    80005b6e:	4505                	li	a0,1
    80005b70:	ffffd097          	auipc	ra,0xffffd
    80005b74:	64c080e7          	jalr	1612(ra) # 800031bc <argstr>
    return -1;
    80005b78:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b7a:	10054263          	bltz	a0,80005c7e <sys_link+0x13c>
  begin_op();
    80005b7e:	fffff097          	auipc	ra,0xfffff
    80005b82:	cd2080e7          	jalr	-814(ra) # 80004850 <begin_op>
  if((ip = namei(old)) == 0){
    80005b86:	ed040513          	addi	a0,s0,-304
    80005b8a:	fffff097          	auipc	ra,0xfffff
    80005b8e:	aa6080e7          	jalr	-1370(ra) # 80004630 <namei>
    80005b92:	84aa                	mv	s1,a0
    80005b94:	c551                	beqz	a0,80005c20 <sys_link+0xde>
  ilock(ip);
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	2e4080e7          	jalr	740(ra) # 80003e7a <ilock>
  if(ip->type == T_DIR){
    80005b9e:	04449703          	lh	a4,68(s1)
    80005ba2:	4785                	li	a5,1
    80005ba4:	08f70463          	beq	a4,a5,80005c2c <sys_link+0xea>
  ip->nlink++;
    80005ba8:	04a4d783          	lhu	a5,74(s1)
    80005bac:	2785                	addiw	a5,a5,1
    80005bae:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005bb2:	8526                	mv	a0,s1
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	1fc080e7          	jalr	508(ra) # 80003db0 <iupdate>
  iunlock(ip);
    80005bbc:	8526                	mv	a0,s1
    80005bbe:	ffffe097          	auipc	ra,0xffffe
    80005bc2:	37e080e7          	jalr	894(ra) # 80003f3c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005bc6:	fd040593          	addi	a1,s0,-48
    80005bca:	f5040513          	addi	a0,s0,-176
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	a80080e7          	jalr	-1408(ra) # 8000464e <nameiparent>
    80005bd6:	892a                	mv	s2,a0
    80005bd8:	c935                	beqz	a0,80005c4c <sys_link+0x10a>
  ilock(dp);
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	2a0080e7          	jalr	672(ra) # 80003e7a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005be2:	00092703          	lw	a4,0(s2)
    80005be6:	409c                	lw	a5,0(s1)
    80005be8:	04f71d63          	bne	a4,a5,80005c42 <sys_link+0x100>
    80005bec:	40d0                	lw	a2,4(s1)
    80005bee:	fd040593          	addi	a1,s0,-48
    80005bf2:	854a                	mv	a0,s2
    80005bf4:	fffff097          	auipc	ra,0xfffff
    80005bf8:	97a080e7          	jalr	-1670(ra) # 8000456e <dirlink>
    80005bfc:	04054363          	bltz	a0,80005c42 <sys_link+0x100>
  iunlockput(dp);
    80005c00:	854a                	mv	a0,s2
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	4da080e7          	jalr	1242(ra) # 800040dc <iunlockput>
  iput(ip);
    80005c0a:	8526                	mv	a0,s1
    80005c0c:	ffffe097          	auipc	ra,0xffffe
    80005c10:	428080e7          	jalr	1064(ra) # 80004034 <iput>
  end_op();
    80005c14:	fffff097          	auipc	ra,0xfffff
    80005c18:	cbc080e7          	jalr	-836(ra) # 800048d0 <end_op>
  return 0;
    80005c1c:	4781                	li	a5,0
    80005c1e:	a085                	j	80005c7e <sys_link+0x13c>
    end_op();
    80005c20:	fffff097          	auipc	ra,0xfffff
    80005c24:	cb0080e7          	jalr	-848(ra) # 800048d0 <end_op>
    return -1;
    80005c28:	57fd                	li	a5,-1
    80005c2a:	a891                	j	80005c7e <sys_link+0x13c>
    iunlockput(ip);
    80005c2c:	8526                	mv	a0,s1
    80005c2e:	ffffe097          	auipc	ra,0xffffe
    80005c32:	4ae080e7          	jalr	1198(ra) # 800040dc <iunlockput>
    end_op();
    80005c36:	fffff097          	auipc	ra,0xfffff
    80005c3a:	c9a080e7          	jalr	-870(ra) # 800048d0 <end_op>
    return -1;
    80005c3e:	57fd                	li	a5,-1
    80005c40:	a83d                	j	80005c7e <sys_link+0x13c>
    iunlockput(dp);
    80005c42:	854a                	mv	a0,s2
    80005c44:	ffffe097          	auipc	ra,0xffffe
    80005c48:	498080e7          	jalr	1176(ra) # 800040dc <iunlockput>
  ilock(ip);
    80005c4c:	8526                	mv	a0,s1
    80005c4e:	ffffe097          	auipc	ra,0xffffe
    80005c52:	22c080e7          	jalr	556(ra) # 80003e7a <ilock>
  ip->nlink--;
    80005c56:	04a4d783          	lhu	a5,74(s1)
    80005c5a:	37fd                	addiw	a5,a5,-1
    80005c5c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c60:	8526                	mv	a0,s1
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	14e080e7          	jalr	334(ra) # 80003db0 <iupdate>
  iunlockput(ip);
    80005c6a:	8526                	mv	a0,s1
    80005c6c:	ffffe097          	auipc	ra,0xffffe
    80005c70:	470080e7          	jalr	1136(ra) # 800040dc <iunlockput>
  end_op();
    80005c74:	fffff097          	auipc	ra,0xfffff
    80005c78:	c5c080e7          	jalr	-932(ra) # 800048d0 <end_op>
  return -1;
    80005c7c:	57fd                	li	a5,-1
}
    80005c7e:	853e                	mv	a0,a5
    80005c80:	70b2                	ld	ra,296(sp)
    80005c82:	7412                	ld	s0,288(sp)
    80005c84:	64f2                	ld	s1,280(sp)
    80005c86:	6952                	ld	s2,272(sp)
    80005c88:	6155                	addi	sp,sp,304
    80005c8a:	8082                	ret

0000000080005c8c <sys_unlink>:
{
    80005c8c:	7151                	addi	sp,sp,-240
    80005c8e:	f586                	sd	ra,232(sp)
    80005c90:	f1a2                	sd	s0,224(sp)
    80005c92:	eda6                	sd	s1,216(sp)
    80005c94:	e9ca                	sd	s2,208(sp)
    80005c96:	e5ce                	sd	s3,200(sp)
    80005c98:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c9a:	08000613          	li	a2,128
    80005c9e:	f3040593          	addi	a1,s0,-208
    80005ca2:	4501                	li	a0,0
    80005ca4:	ffffd097          	auipc	ra,0xffffd
    80005ca8:	518080e7          	jalr	1304(ra) # 800031bc <argstr>
    80005cac:	18054163          	bltz	a0,80005e2e <sys_unlink+0x1a2>
  begin_op();
    80005cb0:	fffff097          	auipc	ra,0xfffff
    80005cb4:	ba0080e7          	jalr	-1120(ra) # 80004850 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005cb8:	fb040593          	addi	a1,s0,-80
    80005cbc:	f3040513          	addi	a0,s0,-208
    80005cc0:	fffff097          	auipc	ra,0xfffff
    80005cc4:	98e080e7          	jalr	-1650(ra) # 8000464e <nameiparent>
    80005cc8:	84aa                	mv	s1,a0
    80005cca:	c979                	beqz	a0,80005da0 <sys_unlink+0x114>
  ilock(dp);
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	1ae080e7          	jalr	430(ra) # 80003e7a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005cd4:	00003597          	auipc	a1,0x3
    80005cd8:	a7c58593          	addi	a1,a1,-1412 # 80008750 <syscalls+0x2e8>
    80005cdc:	fb040513          	addi	a0,s0,-80
    80005ce0:	ffffe097          	auipc	ra,0xffffe
    80005ce4:	664080e7          	jalr	1636(ra) # 80004344 <namecmp>
    80005ce8:	14050a63          	beqz	a0,80005e3c <sys_unlink+0x1b0>
    80005cec:	00003597          	auipc	a1,0x3
    80005cf0:	a6c58593          	addi	a1,a1,-1428 # 80008758 <syscalls+0x2f0>
    80005cf4:	fb040513          	addi	a0,s0,-80
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	64c080e7          	jalr	1612(ra) # 80004344 <namecmp>
    80005d00:	12050e63          	beqz	a0,80005e3c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005d04:	f2c40613          	addi	a2,s0,-212
    80005d08:	fb040593          	addi	a1,s0,-80
    80005d0c:	8526                	mv	a0,s1
    80005d0e:	ffffe097          	auipc	ra,0xffffe
    80005d12:	650080e7          	jalr	1616(ra) # 8000435e <dirlookup>
    80005d16:	892a                	mv	s2,a0
    80005d18:	12050263          	beqz	a0,80005e3c <sys_unlink+0x1b0>
  ilock(ip);
    80005d1c:	ffffe097          	auipc	ra,0xffffe
    80005d20:	15e080e7          	jalr	350(ra) # 80003e7a <ilock>
  if(ip->nlink < 1)
    80005d24:	04a91783          	lh	a5,74(s2)
    80005d28:	08f05263          	blez	a5,80005dac <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005d2c:	04491703          	lh	a4,68(s2)
    80005d30:	4785                	li	a5,1
    80005d32:	08f70563          	beq	a4,a5,80005dbc <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005d36:	4641                	li	a2,16
    80005d38:	4581                	li	a1,0
    80005d3a:	fc040513          	addi	a0,s0,-64
    80005d3e:	ffffb097          	auipc	ra,0xffffb
    80005d42:	fae080e7          	jalr	-82(ra) # 80000cec <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d46:	4741                	li	a4,16
    80005d48:	f2c42683          	lw	a3,-212(s0)
    80005d4c:	fc040613          	addi	a2,s0,-64
    80005d50:	4581                	li	a1,0
    80005d52:	8526                	mv	a0,s1
    80005d54:	ffffe097          	auipc	ra,0xffffe
    80005d58:	4d2080e7          	jalr	1234(ra) # 80004226 <writei>
    80005d5c:	47c1                	li	a5,16
    80005d5e:	0af51563          	bne	a0,a5,80005e08 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005d62:	04491703          	lh	a4,68(s2)
    80005d66:	4785                	li	a5,1
    80005d68:	0af70863          	beq	a4,a5,80005e18 <sys_unlink+0x18c>
  iunlockput(dp);
    80005d6c:	8526                	mv	a0,s1
    80005d6e:	ffffe097          	auipc	ra,0xffffe
    80005d72:	36e080e7          	jalr	878(ra) # 800040dc <iunlockput>
  ip->nlink--;
    80005d76:	04a95783          	lhu	a5,74(s2)
    80005d7a:	37fd                	addiw	a5,a5,-1
    80005d7c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005d80:	854a                	mv	a0,s2
    80005d82:	ffffe097          	auipc	ra,0xffffe
    80005d86:	02e080e7          	jalr	46(ra) # 80003db0 <iupdate>
  iunlockput(ip);
    80005d8a:	854a                	mv	a0,s2
    80005d8c:	ffffe097          	auipc	ra,0xffffe
    80005d90:	350080e7          	jalr	848(ra) # 800040dc <iunlockput>
  end_op();
    80005d94:	fffff097          	auipc	ra,0xfffff
    80005d98:	b3c080e7          	jalr	-1220(ra) # 800048d0 <end_op>
  return 0;
    80005d9c:	4501                	li	a0,0
    80005d9e:	a84d                	j	80005e50 <sys_unlink+0x1c4>
    end_op();
    80005da0:	fffff097          	auipc	ra,0xfffff
    80005da4:	b30080e7          	jalr	-1232(ra) # 800048d0 <end_op>
    return -1;
    80005da8:	557d                	li	a0,-1
    80005daa:	a05d                	j	80005e50 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005dac:	00003517          	auipc	a0,0x3
    80005db0:	9d450513          	addi	a0,a0,-1580 # 80008780 <syscalls+0x318>
    80005db4:	ffffa097          	auipc	ra,0xffffa
    80005db8:	784080e7          	jalr	1924(ra) # 80000538 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005dbc:	04c92703          	lw	a4,76(s2)
    80005dc0:	02000793          	li	a5,32
    80005dc4:	f6e7f9e3          	bgeu	a5,a4,80005d36 <sys_unlink+0xaa>
    80005dc8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005dcc:	4741                	li	a4,16
    80005dce:	86ce                	mv	a3,s3
    80005dd0:	f1840613          	addi	a2,s0,-232
    80005dd4:	4581                	li	a1,0
    80005dd6:	854a                	mv	a0,s2
    80005dd8:	ffffe097          	auipc	ra,0xffffe
    80005ddc:	356080e7          	jalr	854(ra) # 8000412e <readi>
    80005de0:	47c1                	li	a5,16
    80005de2:	00f51b63          	bne	a0,a5,80005df8 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005de6:	f1845783          	lhu	a5,-232(s0)
    80005dea:	e7a1                	bnez	a5,80005e32 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005dec:	29c1                	addiw	s3,s3,16
    80005dee:	04c92783          	lw	a5,76(s2)
    80005df2:	fcf9ede3          	bltu	s3,a5,80005dcc <sys_unlink+0x140>
    80005df6:	b781                	j	80005d36 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005df8:	00003517          	auipc	a0,0x3
    80005dfc:	9a050513          	addi	a0,a0,-1632 # 80008798 <syscalls+0x330>
    80005e00:	ffffa097          	auipc	ra,0xffffa
    80005e04:	738080e7          	jalr	1848(ra) # 80000538 <panic>
    panic("unlink: writei");
    80005e08:	00003517          	auipc	a0,0x3
    80005e0c:	9a850513          	addi	a0,a0,-1624 # 800087b0 <syscalls+0x348>
    80005e10:	ffffa097          	auipc	ra,0xffffa
    80005e14:	728080e7          	jalr	1832(ra) # 80000538 <panic>
    dp->nlink--;
    80005e18:	04a4d783          	lhu	a5,74(s1)
    80005e1c:	37fd                	addiw	a5,a5,-1
    80005e1e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005e22:	8526                	mv	a0,s1
    80005e24:	ffffe097          	auipc	ra,0xffffe
    80005e28:	f8c080e7          	jalr	-116(ra) # 80003db0 <iupdate>
    80005e2c:	b781                	j	80005d6c <sys_unlink+0xe0>
    return -1;
    80005e2e:	557d                	li	a0,-1
    80005e30:	a005                	j	80005e50 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005e32:	854a                	mv	a0,s2
    80005e34:	ffffe097          	auipc	ra,0xffffe
    80005e38:	2a8080e7          	jalr	680(ra) # 800040dc <iunlockput>
  iunlockput(dp);
    80005e3c:	8526                	mv	a0,s1
    80005e3e:	ffffe097          	auipc	ra,0xffffe
    80005e42:	29e080e7          	jalr	670(ra) # 800040dc <iunlockput>
  end_op();
    80005e46:	fffff097          	auipc	ra,0xfffff
    80005e4a:	a8a080e7          	jalr	-1398(ra) # 800048d0 <end_op>
  return -1;
    80005e4e:	557d                	li	a0,-1
}
    80005e50:	70ae                	ld	ra,232(sp)
    80005e52:	740e                	ld	s0,224(sp)
    80005e54:	64ee                	ld	s1,216(sp)
    80005e56:	694e                	ld	s2,208(sp)
    80005e58:	69ae                	ld	s3,200(sp)
    80005e5a:	616d                	addi	sp,sp,240
    80005e5c:	8082                	ret

0000000080005e5e <sys_open>:

uint64
sys_open(void)
{
    80005e5e:	7131                	addi	sp,sp,-192
    80005e60:	fd06                	sd	ra,184(sp)
    80005e62:	f922                	sd	s0,176(sp)
    80005e64:	f526                	sd	s1,168(sp)
    80005e66:	f14a                	sd	s2,160(sp)
    80005e68:	ed4e                	sd	s3,152(sp)
    80005e6a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005e6c:	08000613          	li	a2,128
    80005e70:	f5040593          	addi	a1,s0,-176
    80005e74:	4501                	li	a0,0
    80005e76:	ffffd097          	auipc	ra,0xffffd
    80005e7a:	346080e7          	jalr	838(ra) # 800031bc <argstr>
    return -1;
    80005e7e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005e80:	0c054163          	bltz	a0,80005f42 <sys_open+0xe4>
    80005e84:	f4c40593          	addi	a1,s0,-180
    80005e88:	4505                	li	a0,1
    80005e8a:	ffffd097          	auipc	ra,0xffffd
    80005e8e:	2ee080e7          	jalr	750(ra) # 80003178 <argint>
    80005e92:	0a054863          	bltz	a0,80005f42 <sys_open+0xe4>

  begin_op();
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	9ba080e7          	jalr	-1606(ra) # 80004850 <begin_op>

  if(omode & O_CREATE){
    80005e9e:	f4c42783          	lw	a5,-180(s0)
    80005ea2:	2007f793          	andi	a5,a5,512
    80005ea6:	cbdd                	beqz	a5,80005f5c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005ea8:	4681                	li	a3,0
    80005eaa:	4601                	li	a2,0
    80005eac:	4589                	li	a1,2
    80005eae:	f5040513          	addi	a0,s0,-176
    80005eb2:	00000097          	auipc	ra,0x0
    80005eb6:	974080e7          	jalr	-1676(ra) # 80005826 <create>
    80005eba:	892a                	mv	s2,a0
    if(ip == 0){
    80005ebc:	c959                	beqz	a0,80005f52 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ebe:	04491703          	lh	a4,68(s2)
    80005ec2:	478d                	li	a5,3
    80005ec4:	00f71763          	bne	a4,a5,80005ed2 <sys_open+0x74>
    80005ec8:	04695703          	lhu	a4,70(s2)
    80005ecc:	47a5                	li	a5,9
    80005ece:	0ce7ec63          	bltu	a5,a4,80005fa6 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ed2:	fffff097          	auipc	ra,0xfffff
    80005ed6:	d8e080e7          	jalr	-626(ra) # 80004c60 <filealloc>
    80005eda:	89aa                	mv	s3,a0
    80005edc:	10050263          	beqz	a0,80005fe0 <sys_open+0x182>
    80005ee0:	00000097          	auipc	ra,0x0
    80005ee4:	904080e7          	jalr	-1788(ra) # 800057e4 <fdalloc>
    80005ee8:	84aa                	mv	s1,a0
    80005eea:	0e054663          	bltz	a0,80005fd6 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005eee:	04491703          	lh	a4,68(s2)
    80005ef2:	478d                	li	a5,3
    80005ef4:	0cf70463          	beq	a4,a5,80005fbc <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ef8:	4789                	li	a5,2
    80005efa:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005efe:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005f02:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005f06:	f4c42783          	lw	a5,-180(s0)
    80005f0a:	0017c713          	xori	a4,a5,1
    80005f0e:	8b05                	andi	a4,a4,1
    80005f10:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f14:	0037f713          	andi	a4,a5,3
    80005f18:	00e03733          	snez	a4,a4
    80005f1c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005f20:	4007f793          	andi	a5,a5,1024
    80005f24:	c791                	beqz	a5,80005f30 <sys_open+0xd2>
    80005f26:	04491703          	lh	a4,68(s2)
    80005f2a:	4789                	li	a5,2
    80005f2c:	08f70f63          	beq	a4,a5,80005fca <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005f30:	854a                	mv	a0,s2
    80005f32:	ffffe097          	auipc	ra,0xffffe
    80005f36:	00a080e7          	jalr	10(ra) # 80003f3c <iunlock>
  end_op();
    80005f3a:	fffff097          	auipc	ra,0xfffff
    80005f3e:	996080e7          	jalr	-1642(ra) # 800048d0 <end_op>

  return fd;
}
    80005f42:	8526                	mv	a0,s1
    80005f44:	70ea                	ld	ra,184(sp)
    80005f46:	744a                	ld	s0,176(sp)
    80005f48:	74aa                	ld	s1,168(sp)
    80005f4a:	790a                	ld	s2,160(sp)
    80005f4c:	69ea                	ld	s3,152(sp)
    80005f4e:	6129                	addi	sp,sp,192
    80005f50:	8082                	ret
      end_op();
    80005f52:	fffff097          	auipc	ra,0xfffff
    80005f56:	97e080e7          	jalr	-1666(ra) # 800048d0 <end_op>
      return -1;
    80005f5a:	b7e5                	j	80005f42 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005f5c:	f5040513          	addi	a0,s0,-176
    80005f60:	ffffe097          	auipc	ra,0xffffe
    80005f64:	6d0080e7          	jalr	1744(ra) # 80004630 <namei>
    80005f68:	892a                	mv	s2,a0
    80005f6a:	c905                	beqz	a0,80005f9a <sys_open+0x13c>
    ilock(ip);
    80005f6c:	ffffe097          	auipc	ra,0xffffe
    80005f70:	f0e080e7          	jalr	-242(ra) # 80003e7a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f74:	04491703          	lh	a4,68(s2)
    80005f78:	4785                	li	a5,1
    80005f7a:	f4f712e3          	bne	a4,a5,80005ebe <sys_open+0x60>
    80005f7e:	f4c42783          	lw	a5,-180(s0)
    80005f82:	dba1                	beqz	a5,80005ed2 <sys_open+0x74>
      iunlockput(ip);
    80005f84:	854a                	mv	a0,s2
    80005f86:	ffffe097          	auipc	ra,0xffffe
    80005f8a:	156080e7          	jalr	342(ra) # 800040dc <iunlockput>
      end_op();
    80005f8e:	fffff097          	auipc	ra,0xfffff
    80005f92:	942080e7          	jalr	-1726(ra) # 800048d0 <end_op>
      return -1;
    80005f96:	54fd                	li	s1,-1
    80005f98:	b76d                	j	80005f42 <sys_open+0xe4>
      end_op();
    80005f9a:	fffff097          	auipc	ra,0xfffff
    80005f9e:	936080e7          	jalr	-1738(ra) # 800048d0 <end_op>
      return -1;
    80005fa2:	54fd                	li	s1,-1
    80005fa4:	bf79                	j	80005f42 <sys_open+0xe4>
    iunlockput(ip);
    80005fa6:	854a                	mv	a0,s2
    80005fa8:	ffffe097          	auipc	ra,0xffffe
    80005fac:	134080e7          	jalr	308(ra) # 800040dc <iunlockput>
    end_op();
    80005fb0:	fffff097          	auipc	ra,0xfffff
    80005fb4:	920080e7          	jalr	-1760(ra) # 800048d0 <end_op>
    return -1;
    80005fb8:	54fd                	li	s1,-1
    80005fba:	b761                	j	80005f42 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005fbc:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005fc0:	04691783          	lh	a5,70(s2)
    80005fc4:	02f99223          	sh	a5,36(s3)
    80005fc8:	bf2d                	j	80005f02 <sys_open+0xa4>
    itrunc(ip);
    80005fca:	854a                	mv	a0,s2
    80005fcc:	ffffe097          	auipc	ra,0xffffe
    80005fd0:	fbc080e7          	jalr	-68(ra) # 80003f88 <itrunc>
    80005fd4:	bfb1                	j	80005f30 <sys_open+0xd2>
      fileclose(f);
    80005fd6:	854e                	mv	a0,s3
    80005fd8:	fffff097          	auipc	ra,0xfffff
    80005fdc:	d44080e7          	jalr	-700(ra) # 80004d1c <fileclose>
    iunlockput(ip);
    80005fe0:	854a                	mv	a0,s2
    80005fe2:	ffffe097          	auipc	ra,0xffffe
    80005fe6:	0fa080e7          	jalr	250(ra) # 800040dc <iunlockput>
    end_op();
    80005fea:	fffff097          	auipc	ra,0xfffff
    80005fee:	8e6080e7          	jalr	-1818(ra) # 800048d0 <end_op>
    return -1;
    80005ff2:	54fd                	li	s1,-1
    80005ff4:	b7b9                	j	80005f42 <sys_open+0xe4>

0000000080005ff6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ff6:	7175                	addi	sp,sp,-144
    80005ff8:	e506                	sd	ra,136(sp)
    80005ffa:	e122                	sd	s0,128(sp)
    80005ffc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ffe:	fffff097          	auipc	ra,0xfffff
    80006002:	852080e7          	jalr	-1966(ra) # 80004850 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006006:	08000613          	li	a2,128
    8000600a:	f7040593          	addi	a1,s0,-144
    8000600e:	4501                	li	a0,0
    80006010:	ffffd097          	auipc	ra,0xffffd
    80006014:	1ac080e7          	jalr	428(ra) # 800031bc <argstr>
    80006018:	02054963          	bltz	a0,8000604a <sys_mkdir+0x54>
    8000601c:	4681                	li	a3,0
    8000601e:	4601                	li	a2,0
    80006020:	4585                	li	a1,1
    80006022:	f7040513          	addi	a0,s0,-144
    80006026:	00000097          	auipc	ra,0x0
    8000602a:	800080e7          	jalr	-2048(ra) # 80005826 <create>
    8000602e:	cd11                	beqz	a0,8000604a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006030:	ffffe097          	auipc	ra,0xffffe
    80006034:	0ac080e7          	jalr	172(ra) # 800040dc <iunlockput>
  end_op();
    80006038:	fffff097          	auipc	ra,0xfffff
    8000603c:	898080e7          	jalr	-1896(ra) # 800048d0 <end_op>
  return 0;
    80006040:	4501                	li	a0,0
}
    80006042:	60aa                	ld	ra,136(sp)
    80006044:	640a                	ld	s0,128(sp)
    80006046:	6149                	addi	sp,sp,144
    80006048:	8082                	ret
    end_op();
    8000604a:	fffff097          	auipc	ra,0xfffff
    8000604e:	886080e7          	jalr	-1914(ra) # 800048d0 <end_op>
    return -1;
    80006052:	557d                	li	a0,-1
    80006054:	b7fd                	j	80006042 <sys_mkdir+0x4c>

0000000080006056 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006056:	7135                	addi	sp,sp,-160
    80006058:	ed06                	sd	ra,152(sp)
    8000605a:	e922                	sd	s0,144(sp)
    8000605c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000605e:	ffffe097          	auipc	ra,0xffffe
    80006062:	7f2080e7          	jalr	2034(ra) # 80004850 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006066:	08000613          	li	a2,128
    8000606a:	f7040593          	addi	a1,s0,-144
    8000606e:	4501                	li	a0,0
    80006070:	ffffd097          	auipc	ra,0xffffd
    80006074:	14c080e7          	jalr	332(ra) # 800031bc <argstr>
    80006078:	04054a63          	bltz	a0,800060cc <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000607c:	f6c40593          	addi	a1,s0,-148
    80006080:	4505                	li	a0,1
    80006082:	ffffd097          	auipc	ra,0xffffd
    80006086:	0f6080e7          	jalr	246(ra) # 80003178 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000608a:	04054163          	bltz	a0,800060cc <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000608e:	f6840593          	addi	a1,s0,-152
    80006092:	4509                	li	a0,2
    80006094:	ffffd097          	auipc	ra,0xffffd
    80006098:	0e4080e7          	jalr	228(ra) # 80003178 <argint>
     argint(1, &major) < 0 ||
    8000609c:	02054863          	bltz	a0,800060cc <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800060a0:	f6841683          	lh	a3,-152(s0)
    800060a4:	f6c41603          	lh	a2,-148(s0)
    800060a8:	458d                	li	a1,3
    800060aa:	f7040513          	addi	a0,s0,-144
    800060ae:	fffff097          	auipc	ra,0xfffff
    800060b2:	778080e7          	jalr	1912(ra) # 80005826 <create>
     argint(2, &minor) < 0 ||
    800060b6:	c919                	beqz	a0,800060cc <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060b8:	ffffe097          	auipc	ra,0xffffe
    800060bc:	024080e7          	jalr	36(ra) # 800040dc <iunlockput>
  end_op();
    800060c0:	fffff097          	auipc	ra,0xfffff
    800060c4:	810080e7          	jalr	-2032(ra) # 800048d0 <end_op>
  return 0;
    800060c8:	4501                	li	a0,0
    800060ca:	a031                	j	800060d6 <sys_mknod+0x80>
    end_op();
    800060cc:	fffff097          	auipc	ra,0xfffff
    800060d0:	804080e7          	jalr	-2044(ra) # 800048d0 <end_op>
    return -1;
    800060d4:	557d                	li	a0,-1
}
    800060d6:	60ea                	ld	ra,152(sp)
    800060d8:	644a                	ld	s0,144(sp)
    800060da:	610d                	addi	sp,sp,160
    800060dc:	8082                	ret

00000000800060de <sys_chdir>:

uint64
sys_chdir(void)
{
    800060de:	7135                	addi	sp,sp,-160
    800060e0:	ed06                	sd	ra,152(sp)
    800060e2:	e922                	sd	s0,144(sp)
    800060e4:	e526                	sd	s1,136(sp)
    800060e6:	e14a                	sd	s2,128(sp)
    800060e8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060ea:	ffffc097          	auipc	ra,0xffffc
    800060ee:	96c080e7          	jalr	-1684(ra) # 80001a56 <myproc>
    800060f2:	892a                	mv	s2,a0
  
  begin_op();
    800060f4:	ffffe097          	auipc	ra,0xffffe
    800060f8:	75c080e7          	jalr	1884(ra) # 80004850 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800060fc:	08000613          	li	a2,128
    80006100:	f6040593          	addi	a1,s0,-160
    80006104:	4501                	li	a0,0
    80006106:	ffffd097          	auipc	ra,0xffffd
    8000610a:	0b6080e7          	jalr	182(ra) # 800031bc <argstr>
    8000610e:	04054b63          	bltz	a0,80006164 <sys_chdir+0x86>
    80006112:	f6040513          	addi	a0,s0,-160
    80006116:	ffffe097          	auipc	ra,0xffffe
    8000611a:	51a080e7          	jalr	1306(ra) # 80004630 <namei>
    8000611e:	84aa                	mv	s1,a0
    80006120:	c131                	beqz	a0,80006164 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006122:	ffffe097          	auipc	ra,0xffffe
    80006126:	d58080e7          	jalr	-680(ra) # 80003e7a <ilock>
  if(ip->type != T_DIR){
    8000612a:	04449703          	lh	a4,68(s1)
    8000612e:	4785                	li	a5,1
    80006130:	04f71063          	bne	a4,a5,80006170 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006134:	8526                	mv	a0,s1
    80006136:	ffffe097          	auipc	ra,0xffffe
    8000613a:	e06080e7          	jalr	-506(ra) # 80003f3c <iunlock>
  iput(p->cwd);
    8000613e:	15093503          	ld	a0,336(s2)
    80006142:	ffffe097          	auipc	ra,0xffffe
    80006146:	ef2080e7          	jalr	-270(ra) # 80004034 <iput>
  end_op();
    8000614a:	ffffe097          	auipc	ra,0xffffe
    8000614e:	786080e7          	jalr	1926(ra) # 800048d0 <end_op>
  p->cwd = ip;
    80006152:	14993823          	sd	s1,336(s2)
  return 0;
    80006156:	4501                	li	a0,0
}
    80006158:	60ea                	ld	ra,152(sp)
    8000615a:	644a                	ld	s0,144(sp)
    8000615c:	64aa                	ld	s1,136(sp)
    8000615e:	690a                	ld	s2,128(sp)
    80006160:	610d                	addi	sp,sp,160
    80006162:	8082                	ret
    end_op();
    80006164:	ffffe097          	auipc	ra,0xffffe
    80006168:	76c080e7          	jalr	1900(ra) # 800048d0 <end_op>
    return -1;
    8000616c:	557d                	li	a0,-1
    8000616e:	b7ed                	j	80006158 <sys_chdir+0x7a>
    iunlockput(ip);
    80006170:	8526                	mv	a0,s1
    80006172:	ffffe097          	auipc	ra,0xffffe
    80006176:	f6a080e7          	jalr	-150(ra) # 800040dc <iunlockput>
    end_op();
    8000617a:	ffffe097          	auipc	ra,0xffffe
    8000617e:	756080e7          	jalr	1878(ra) # 800048d0 <end_op>
    return -1;
    80006182:	557d                	li	a0,-1
    80006184:	bfd1                	j	80006158 <sys_chdir+0x7a>

0000000080006186 <sys_exec>:

uint64
sys_exec(void)
{
    80006186:	7145                	addi	sp,sp,-464
    80006188:	e786                	sd	ra,456(sp)
    8000618a:	e3a2                	sd	s0,448(sp)
    8000618c:	ff26                	sd	s1,440(sp)
    8000618e:	fb4a                	sd	s2,432(sp)
    80006190:	f74e                	sd	s3,424(sp)
    80006192:	f352                	sd	s4,416(sp)
    80006194:	ef56                	sd	s5,408(sp)
    80006196:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006198:	08000613          	li	a2,128
    8000619c:	f4040593          	addi	a1,s0,-192
    800061a0:	4501                	li	a0,0
    800061a2:	ffffd097          	auipc	ra,0xffffd
    800061a6:	01a080e7          	jalr	26(ra) # 800031bc <argstr>
    return -1;
    800061aa:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800061ac:	0c054a63          	bltz	a0,80006280 <sys_exec+0xfa>
    800061b0:	e3840593          	addi	a1,s0,-456
    800061b4:	4505                	li	a0,1
    800061b6:	ffffd097          	auipc	ra,0xffffd
    800061ba:	fe4080e7          	jalr	-28(ra) # 8000319a <argaddr>
    800061be:	0c054163          	bltz	a0,80006280 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800061c2:	10000613          	li	a2,256
    800061c6:	4581                	li	a1,0
    800061c8:	e4040513          	addi	a0,s0,-448
    800061cc:	ffffb097          	auipc	ra,0xffffb
    800061d0:	b20080e7          	jalr	-1248(ra) # 80000cec <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800061d4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800061d8:	89a6                	mv	s3,s1
    800061da:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800061dc:	02000a13          	li	s4,32
    800061e0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061e4:	00391793          	slli	a5,s2,0x3
    800061e8:	e3040593          	addi	a1,s0,-464
    800061ec:	e3843503          	ld	a0,-456(s0)
    800061f0:	953e                	add	a0,a0,a5
    800061f2:	ffffd097          	auipc	ra,0xffffd
    800061f6:	eec080e7          	jalr	-276(ra) # 800030de <fetchaddr>
    800061fa:	02054a63          	bltz	a0,8000622e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800061fe:	e3043783          	ld	a5,-464(s0)
    80006202:	c3b9                	beqz	a5,80006248 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006204:	ffffb097          	auipc	ra,0xffffb
    80006208:	8dc080e7          	jalr	-1828(ra) # 80000ae0 <kalloc>
    8000620c:	85aa                	mv	a1,a0
    8000620e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006212:	cd11                	beqz	a0,8000622e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006214:	6605                	lui	a2,0x1
    80006216:	e3043503          	ld	a0,-464(s0)
    8000621a:	ffffd097          	auipc	ra,0xffffd
    8000621e:	f16080e7          	jalr	-234(ra) # 80003130 <fetchstr>
    80006222:	00054663          	bltz	a0,8000622e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006226:	0905                	addi	s2,s2,1
    80006228:	09a1                	addi	s3,s3,8
    8000622a:	fb491be3          	bne	s2,s4,800061e0 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000622e:	10048913          	addi	s2,s1,256
    80006232:	6088                	ld	a0,0(s1)
    80006234:	c529                	beqz	a0,8000627e <sys_exec+0xf8>
    kfree(argv[i]);
    80006236:	ffffa097          	auipc	ra,0xffffa
    8000623a:	7ae080e7          	jalr	1966(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000623e:	04a1                	addi	s1,s1,8
    80006240:	ff2499e3          	bne	s1,s2,80006232 <sys_exec+0xac>
  return -1;
    80006244:	597d                	li	s2,-1
    80006246:	a82d                	j	80006280 <sys_exec+0xfa>
      argv[i] = 0;
    80006248:	0a8e                	slli	s5,s5,0x3
    8000624a:	fc040793          	addi	a5,s0,-64
    8000624e:	9abe                	add	s5,s5,a5
    80006250:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006254:	e4040593          	addi	a1,s0,-448
    80006258:	f4040513          	addi	a0,s0,-192
    8000625c:	fffff097          	auipc	ra,0xfffff
    80006260:	112080e7          	jalr	274(ra) # 8000536e <exec>
    80006264:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006266:	10048993          	addi	s3,s1,256
    8000626a:	6088                	ld	a0,0(s1)
    8000626c:	c911                	beqz	a0,80006280 <sys_exec+0xfa>
    kfree(argv[i]);
    8000626e:	ffffa097          	auipc	ra,0xffffa
    80006272:	776080e7          	jalr	1910(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006276:	04a1                	addi	s1,s1,8
    80006278:	ff3499e3          	bne	s1,s3,8000626a <sys_exec+0xe4>
    8000627c:	a011                	j	80006280 <sys_exec+0xfa>
  return -1;
    8000627e:	597d                	li	s2,-1
}
    80006280:	854a                	mv	a0,s2
    80006282:	60be                	ld	ra,456(sp)
    80006284:	641e                	ld	s0,448(sp)
    80006286:	74fa                	ld	s1,440(sp)
    80006288:	795a                	ld	s2,432(sp)
    8000628a:	79ba                	ld	s3,424(sp)
    8000628c:	7a1a                	ld	s4,416(sp)
    8000628e:	6afa                	ld	s5,408(sp)
    80006290:	6179                	addi	sp,sp,464
    80006292:	8082                	ret

0000000080006294 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006294:	7139                	addi	sp,sp,-64
    80006296:	fc06                	sd	ra,56(sp)
    80006298:	f822                	sd	s0,48(sp)
    8000629a:	f426                	sd	s1,40(sp)
    8000629c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000629e:	ffffb097          	auipc	ra,0xffffb
    800062a2:	7b8080e7          	jalr	1976(ra) # 80001a56 <myproc>
    800062a6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800062a8:	fd840593          	addi	a1,s0,-40
    800062ac:	4501                	li	a0,0
    800062ae:	ffffd097          	auipc	ra,0xffffd
    800062b2:	eec080e7          	jalr	-276(ra) # 8000319a <argaddr>
    return -1;
    800062b6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800062b8:	0e054063          	bltz	a0,80006398 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800062bc:	fc840593          	addi	a1,s0,-56
    800062c0:	fd040513          	addi	a0,s0,-48
    800062c4:	fffff097          	auipc	ra,0xfffff
    800062c8:	d88080e7          	jalr	-632(ra) # 8000504c <pipealloc>
    return -1;
    800062cc:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800062ce:	0c054563          	bltz	a0,80006398 <sys_pipe+0x104>
  fd0 = -1;
    800062d2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800062d6:	fd043503          	ld	a0,-48(s0)
    800062da:	fffff097          	auipc	ra,0xfffff
    800062de:	50a080e7          	jalr	1290(ra) # 800057e4 <fdalloc>
    800062e2:	fca42223          	sw	a0,-60(s0)
    800062e6:	08054c63          	bltz	a0,8000637e <sys_pipe+0xea>
    800062ea:	fc843503          	ld	a0,-56(s0)
    800062ee:	fffff097          	auipc	ra,0xfffff
    800062f2:	4f6080e7          	jalr	1270(ra) # 800057e4 <fdalloc>
    800062f6:	fca42023          	sw	a0,-64(s0)
    800062fa:	06054863          	bltz	a0,8000636a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062fe:	4691                	li	a3,4
    80006300:	fc440613          	addi	a2,s0,-60
    80006304:	fd843583          	ld	a1,-40(s0)
    80006308:	68a8                	ld	a0,80(s1)
    8000630a:	ffffb097          	auipc	ra,0xffffb
    8000630e:	362080e7          	jalr	866(ra) # 8000166c <copyout>
    80006312:	02054063          	bltz	a0,80006332 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006316:	4691                	li	a3,4
    80006318:	fc040613          	addi	a2,s0,-64
    8000631c:	fd843583          	ld	a1,-40(s0)
    80006320:	0591                	addi	a1,a1,4
    80006322:	68a8                	ld	a0,80(s1)
    80006324:	ffffb097          	auipc	ra,0xffffb
    80006328:	348080e7          	jalr	840(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000632c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000632e:	06055563          	bgez	a0,80006398 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006332:	fc442783          	lw	a5,-60(s0)
    80006336:	07e9                	addi	a5,a5,26
    80006338:	078e                	slli	a5,a5,0x3
    8000633a:	97a6                	add	a5,a5,s1
    8000633c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006340:	fc042503          	lw	a0,-64(s0)
    80006344:	0569                	addi	a0,a0,26
    80006346:	050e                	slli	a0,a0,0x3
    80006348:	9526                	add	a0,a0,s1
    8000634a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000634e:	fd043503          	ld	a0,-48(s0)
    80006352:	fffff097          	auipc	ra,0xfffff
    80006356:	9ca080e7          	jalr	-1590(ra) # 80004d1c <fileclose>
    fileclose(wf);
    8000635a:	fc843503          	ld	a0,-56(s0)
    8000635e:	fffff097          	auipc	ra,0xfffff
    80006362:	9be080e7          	jalr	-1602(ra) # 80004d1c <fileclose>
    return -1;
    80006366:	57fd                	li	a5,-1
    80006368:	a805                	j	80006398 <sys_pipe+0x104>
    if(fd0 >= 0)
    8000636a:	fc442783          	lw	a5,-60(s0)
    8000636e:	0007c863          	bltz	a5,8000637e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006372:	01a78513          	addi	a0,a5,26
    80006376:	050e                	slli	a0,a0,0x3
    80006378:	9526                	add	a0,a0,s1
    8000637a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000637e:	fd043503          	ld	a0,-48(s0)
    80006382:	fffff097          	auipc	ra,0xfffff
    80006386:	99a080e7          	jalr	-1638(ra) # 80004d1c <fileclose>
    fileclose(wf);
    8000638a:	fc843503          	ld	a0,-56(s0)
    8000638e:	fffff097          	auipc	ra,0xfffff
    80006392:	98e080e7          	jalr	-1650(ra) # 80004d1c <fileclose>
    return -1;
    80006396:	57fd                	li	a5,-1
}
    80006398:	853e                	mv	a0,a5
    8000639a:	70e2                	ld	ra,56(sp)
    8000639c:	7442                	ld	s0,48(sp)
    8000639e:	74a2                	ld	s1,40(sp)
    800063a0:	6121                	addi	sp,sp,64
    800063a2:	8082                	ret
	...

00000000800063b0 <kernelvec>:
    800063b0:	7111                	addi	sp,sp,-256
    800063b2:	e006                	sd	ra,0(sp)
    800063b4:	e40a                	sd	sp,8(sp)
    800063b6:	e80e                	sd	gp,16(sp)
    800063b8:	ec12                	sd	tp,24(sp)
    800063ba:	f016                	sd	t0,32(sp)
    800063bc:	f41a                	sd	t1,40(sp)
    800063be:	f81e                	sd	t2,48(sp)
    800063c0:	fc22                	sd	s0,56(sp)
    800063c2:	e0a6                	sd	s1,64(sp)
    800063c4:	e4aa                	sd	a0,72(sp)
    800063c6:	e8ae                	sd	a1,80(sp)
    800063c8:	ecb2                	sd	a2,88(sp)
    800063ca:	f0b6                	sd	a3,96(sp)
    800063cc:	f4ba                	sd	a4,104(sp)
    800063ce:	f8be                	sd	a5,112(sp)
    800063d0:	fcc2                	sd	a6,120(sp)
    800063d2:	e146                	sd	a7,128(sp)
    800063d4:	e54a                	sd	s2,136(sp)
    800063d6:	e94e                	sd	s3,144(sp)
    800063d8:	ed52                	sd	s4,152(sp)
    800063da:	f156                	sd	s5,160(sp)
    800063dc:	f55a                	sd	s6,168(sp)
    800063de:	f95e                	sd	s7,176(sp)
    800063e0:	fd62                	sd	s8,184(sp)
    800063e2:	e1e6                	sd	s9,192(sp)
    800063e4:	e5ea                	sd	s10,200(sp)
    800063e6:	e9ee                	sd	s11,208(sp)
    800063e8:	edf2                	sd	t3,216(sp)
    800063ea:	f1f6                	sd	t4,224(sp)
    800063ec:	f5fa                	sd	t5,232(sp)
    800063ee:	f9fe                	sd	t6,240(sp)
    800063f0:	bbbfc0ef          	jal	ra,80002faa <kerneltrap>
    800063f4:	6082                	ld	ra,0(sp)
    800063f6:	6122                	ld	sp,8(sp)
    800063f8:	61c2                	ld	gp,16(sp)
    800063fa:	7282                	ld	t0,32(sp)
    800063fc:	7322                	ld	t1,40(sp)
    800063fe:	73c2                	ld	t2,48(sp)
    80006400:	7462                	ld	s0,56(sp)
    80006402:	6486                	ld	s1,64(sp)
    80006404:	6526                	ld	a0,72(sp)
    80006406:	65c6                	ld	a1,80(sp)
    80006408:	6666                	ld	a2,88(sp)
    8000640a:	7686                	ld	a3,96(sp)
    8000640c:	7726                	ld	a4,104(sp)
    8000640e:	77c6                	ld	a5,112(sp)
    80006410:	7866                	ld	a6,120(sp)
    80006412:	688a                	ld	a7,128(sp)
    80006414:	692a                	ld	s2,136(sp)
    80006416:	69ca                	ld	s3,144(sp)
    80006418:	6a6a                	ld	s4,152(sp)
    8000641a:	7a8a                	ld	s5,160(sp)
    8000641c:	7b2a                	ld	s6,168(sp)
    8000641e:	7bca                	ld	s7,176(sp)
    80006420:	7c6a                	ld	s8,184(sp)
    80006422:	6c8e                	ld	s9,192(sp)
    80006424:	6d2e                	ld	s10,200(sp)
    80006426:	6dce                	ld	s11,208(sp)
    80006428:	6e6e                	ld	t3,216(sp)
    8000642a:	7e8e                	ld	t4,224(sp)
    8000642c:	7f2e                	ld	t5,232(sp)
    8000642e:	7fce                	ld	t6,240(sp)
    80006430:	6111                	addi	sp,sp,256
    80006432:	10200073          	sret
    80006436:	00000013          	nop
    8000643a:	00000013          	nop
    8000643e:	0001                	nop

0000000080006440 <timervec>:
    80006440:	34051573          	csrrw	a0,mscratch,a0
    80006444:	e10c                	sd	a1,0(a0)
    80006446:	e510                	sd	a2,8(a0)
    80006448:	e914                	sd	a3,16(a0)
    8000644a:	6d0c                	ld	a1,24(a0)
    8000644c:	7110                	ld	a2,32(a0)
    8000644e:	6194                	ld	a3,0(a1)
    80006450:	96b2                	add	a3,a3,a2
    80006452:	e194                	sd	a3,0(a1)
    80006454:	4589                	li	a1,2
    80006456:	14459073          	csrw	sip,a1
    8000645a:	6914                	ld	a3,16(a0)
    8000645c:	6510                	ld	a2,8(a0)
    8000645e:	610c                	ld	a1,0(a0)
    80006460:	34051573          	csrrw	a0,mscratch,a0
    80006464:	30200073          	mret
	...

000000008000646a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000646a:	1141                	addi	sp,sp,-16
    8000646c:	e422                	sd	s0,8(sp)
    8000646e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006470:	0c0007b7          	lui	a5,0xc000
    80006474:	4705                	li	a4,1
    80006476:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006478:	c3d8                	sw	a4,4(a5)
}
    8000647a:	6422                	ld	s0,8(sp)
    8000647c:	0141                	addi	sp,sp,16
    8000647e:	8082                	ret

0000000080006480 <plicinithart>:

void
plicinithart(void)
{
    80006480:	1141                	addi	sp,sp,-16
    80006482:	e406                	sd	ra,8(sp)
    80006484:	e022                	sd	s0,0(sp)
    80006486:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006488:	ffffb097          	auipc	ra,0xffffb
    8000648c:	59a080e7          	jalr	1434(ra) # 80001a22 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006490:	0085171b          	slliw	a4,a0,0x8
    80006494:	0c0027b7          	lui	a5,0xc002
    80006498:	97ba                	add	a5,a5,a4
    8000649a:	40200713          	li	a4,1026
    8000649e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800064a2:	00d5151b          	slliw	a0,a0,0xd
    800064a6:	0c2017b7          	lui	a5,0xc201
    800064aa:	953e                	add	a0,a0,a5
    800064ac:	00052023          	sw	zero,0(a0)
}
    800064b0:	60a2                	ld	ra,8(sp)
    800064b2:	6402                	ld	s0,0(sp)
    800064b4:	0141                	addi	sp,sp,16
    800064b6:	8082                	ret

00000000800064b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800064b8:	1141                	addi	sp,sp,-16
    800064ba:	e406                	sd	ra,8(sp)
    800064bc:	e022                	sd	s0,0(sp)
    800064be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064c0:	ffffb097          	auipc	ra,0xffffb
    800064c4:	562080e7          	jalr	1378(ra) # 80001a22 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800064c8:	00d5179b          	slliw	a5,a0,0xd
    800064cc:	0c201537          	lui	a0,0xc201
    800064d0:	953e                	add	a0,a0,a5
  return irq;
}
    800064d2:	4148                	lw	a0,4(a0)
    800064d4:	60a2                	ld	ra,8(sp)
    800064d6:	6402                	ld	s0,0(sp)
    800064d8:	0141                	addi	sp,sp,16
    800064da:	8082                	ret

00000000800064dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800064dc:	1101                	addi	sp,sp,-32
    800064de:	ec06                	sd	ra,24(sp)
    800064e0:	e822                	sd	s0,16(sp)
    800064e2:	e426                	sd	s1,8(sp)
    800064e4:	1000                	addi	s0,sp,32
    800064e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800064e8:	ffffb097          	auipc	ra,0xffffb
    800064ec:	53a080e7          	jalr	1338(ra) # 80001a22 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800064f0:	00d5151b          	slliw	a0,a0,0xd
    800064f4:	0c2017b7          	lui	a5,0xc201
    800064f8:	97aa                	add	a5,a5,a0
    800064fa:	c3c4                	sw	s1,4(a5)
}
    800064fc:	60e2                	ld	ra,24(sp)
    800064fe:	6442                	ld	s0,16(sp)
    80006500:	64a2                	ld	s1,8(sp)
    80006502:	6105                	addi	sp,sp,32
    80006504:	8082                	ret

0000000080006506 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006506:	1141                	addi	sp,sp,-16
    80006508:	e406                	sd	ra,8(sp)
    8000650a:	e022                	sd	s0,0(sp)
    8000650c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000650e:	479d                	li	a5,7
    80006510:	06a7c963          	blt	a5,a0,80006582 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006514:	00035797          	auipc	a5,0x35
    80006518:	aec78793          	addi	a5,a5,-1300 # 8003b000 <disk>
    8000651c:	00a78733          	add	a4,a5,a0
    80006520:	6789                	lui	a5,0x2
    80006522:	97ba                	add	a5,a5,a4
    80006524:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006528:	e7ad                	bnez	a5,80006592 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000652a:	00451793          	slli	a5,a0,0x4
    8000652e:	00037717          	auipc	a4,0x37
    80006532:	ad270713          	addi	a4,a4,-1326 # 8003d000 <disk+0x2000>
    80006536:	6314                	ld	a3,0(a4)
    80006538:	96be                	add	a3,a3,a5
    8000653a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000653e:	6314                	ld	a3,0(a4)
    80006540:	96be                	add	a3,a3,a5
    80006542:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006546:	6314                	ld	a3,0(a4)
    80006548:	96be                	add	a3,a3,a5
    8000654a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000654e:	6318                	ld	a4,0(a4)
    80006550:	97ba                	add	a5,a5,a4
    80006552:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006556:	00035797          	auipc	a5,0x35
    8000655a:	aaa78793          	addi	a5,a5,-1366 # 8003b000 <disk>
    8000655e:	97aa                	add	a5,a5,a0
    80006560:	6509                	lui	a0,0x2
    80006562:	953e                	add	a0,a0,a5
    80006564:	4785                	li	a5,1
    80006566:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000656a:	00037517          	auipc	a0,0x37
    8000656e:	aae50513          	addi	a0,a0,-1362 # 8003d018 <disk+0x2018>
    80006572:	ffffc097          	auipc	ra,0xffffc
    80006576:	f82080e7          	jalr	-126(ra) # 800024f4 <wakeup>
}
    8000657a:	60a2                	ld	ra,8(sp)
    8000657c:	6402                	ld	s0,0(sp)
    8000657e:	0141                	addi	sp,sp,16
    80006580:	8082                	ret
    panic("free_desc 1");
    80006582:	00002517          	auipc	a0,0x2
    80006586:	23e50513          	addi	a0,a0,574 # 800087c0 <syscalls+0x358>
    8000658a:	ffffa097          	auipc	ra,0xffffa
    8000658e:	fae080e7          	jalr	-82(ra) # 80000538 <panic>
    panic("free_desc 2");
    80006592:	00002517          	auipc	a0,0x2
    80006596:	23e50513          	addi	a0,a0,574 # 800087d0 <syscalls+0x368>
    8000659a:	ffffa097          	auipc	ra,0xffffa
    8000659e:	f9e080e7          	jalr	-98(ra) # 80000538 <panic>

00000000800065a2 <virtio_disk_init>:
{
    800065a2:	1101                	addi	sp,sp,-32
    800065a4:	ec06                	sd	ra,24(sp)
    800065a6:	e822                	sd	s0,16(sp)
    800065a8:	e426                	sd	s1,8(sp)
    800065aa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800065ac:	00002597          	auipc	a1,0x2
    800065b0:	23458593          	addi	a1,a1,564 # 800087e0 <syscalls+0x378>
    800065b4:	00037517          	auipc	a0,0x37
    800065b8:	b7450513          	addi	a0,a0,-1164 # 8003d128 <disk+0x2128>
    800065bc:	ffffa097          	auipc	ra,0xffffa
    800065c0:	584080e7          	jalr	1412(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065c4:	100017b7          	lui	a5,0x10001
    800065c8:	4398                	lw	a4,0(a5)
    800065ca:	2701                	sext.w	a4,a4
    800065cc:	747277b7          	lui	a5,0x74727
    800065d0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800065d4:	0ef71163          	bne	a4,a5,800066b6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800065d8:	100017b7          	lui	a5,0x10001
    800065dc:	43dc                	lw	a5,4(a5)
    800065de:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065e0:	4705                	li	a4,1
    800065e2:	0ce79a63          	bne	a5,a4,800066b6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065e6:	100017b7          	lui	a5,0x10001
    800065ea:	479c                	lw	a5,8(a5)
    800065ec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800065ee:	4709                	li	a4,2
    800065f0:	0ce79363          	bne	a5,a4,800066b6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800065f4:	100017b7          	lui	a5,0x10001
    800065f8:	47d8                	lw	a4,12(a5)
    800065fa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065fc:	554d47b7          	lui	a5,0x554d4
    80006600:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006604:	0af71963          	bne	a4,a5,800066b6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006608:	100017b7          	lui	a5,0x10001
    8000660c:	4705                	li	a4,1
    8000660e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006610:	470d                	li	a4,3
    80006612:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006614:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006616:	c7ffe737          	lui	a4,0xc7ffe
    8000661a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc075f>
    8000661e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006620:	2701                	sext.w	a4,a4
    80006622:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006624:	472d                	li	a4,11
    80006626:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006628:	473d                	li	a4,15
    8000662a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000662c:	6705                	lui	a4,0x1
    8000662e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006630:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006634:	5bdc                	lw	a5,52(a5)
    80006636:	2781                	sext.w	a5,a5
  if(max == 0)
    80006638:	c7d9                	beqz	a5,800066c6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000663a:	471d                	li	a4,7
    8000663c:	08f77d63          	bgeu	a4,a5,800066d6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006640:	100014b7          	lui	s1,0x10001
    80006644:	47a1                	li	a5,8
    80006646:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006648:	6609                	lui	a2,0x2
    8000664a:	4581                	li	a1,0
    8000664c:	00035517          	auipc	a0,0x35
    80006650:	9b450513          	addi	a0,a0,-1612 # 8003b000 <disk>
    80006654:	ffffa097          	auipc	ra,0xffffa
    80006658:	698080e7          	jalr	1688(ra) # 80000cec <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000665c:	00035717          	auipc	a4,0x35
    80006660:	9a470713          	addi	a4,a4,-1628 # 8003b000 <disk>
    80006664:	00c75793          	srli	a5,a4,0xc
    80006668:	2781                	sext.w	a5,a5
    8000666a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000666c:	00037797          	auipc	a5,0x37
    80006670:	99478793          	addi	a5,a5,-1644 # 8003d000 <disk+0x2000>
    80006674:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006676:	00035717          	auipc	a4,0x35
    8000667a:	a0a70713          	addi	a4,a4,-1526 # 8003b080 <disk+0x80>
    8000667e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006680:	00036717          	auipc	a4,0x36
    80006684:	98070713          	addi	a4,a4,-1664 # 8003c000 <disk+0x1000>
    80006688:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000668a:	4705                	li	a4,1
    8000668c:	00e78c23          	sb	a4,24(a5)
    80006690:	00e78ca3          	sb	a4,25(a5)
    80006694:	00e78d23          	sb	a4,26(a5)
    80006698:	00e78da3          	sb	a4,27(a5)
    8000669c:	00e78e23          	sb	a4,28(a5)
    800066a0:	00e78ea3          	sb	a4,29(a5)
    800066a4:	00e78f23          	sb	a4,30(a5)
    800066a8:	00e78fa3          	sb	a4,31(a5)
}
    800066ac:	60e2                	ld	ra,24(sp)
    800066ae:	6442                	ld	s0,16(sp)
    800066b0:	64a2                	ld	s1,8(sp)
    800066b2:	6105                	addi	sp,sp,32
    800066b4:	8082                	ret
    panic("could not find virtio disk");
    800066b6:	00002517          	auipc	a0,0x2
    800066ba:	13a50513          	addi	a0,a0,314 # 800087f0 <syscalls+0x388>
    800066be:	ffffa097          	auipc	ra,0xffffa
    800066c2:	e7a080e7          	jalr	-390(ra) # 80000538 <panic>
    panic("virtio disk has no queue 0");
    800066c6:	00002517          	auipc	a0,0x2
    800066ca:	14a50513          	addi	a0,a0,330 # 80008810 <syscalls+0x3a8>
    800066ce:	ffffa097          	auipc	ra,0xffffa
    800066d2:	e6a080e7          	jalr	-406(ra) # 80000538 <panic>
    panic("virtio disk max queue too short");
    800066d6:	00002517          	auipc	a0,0x2
    800066da:	15a50513          	addi	a0,a0,346 # 80008830 <syscalls+0x3c8>
    800066de:	ffffa097          	auipc	ra,0xffffa
    800066e2:	e5a080e7          	jalr	-422(ra) # 80000538 <panic>

00000000800066e6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800066e6:	7119                	addi	sp,sp,-128
    800066e8:	fc86                	sd	ra,120(sp)
    800066ea:	f8a2                	sd	s0,112(sp)
    800066ec:	f4a6                	sd	s1,104(sp)
    800066ee:	f0ca                	sd	s2,96(sp)
    800066f0:	ecce                	sd	s3,88(sp)
    800066f2:	e8d2                	sd	s4,80(sp)
    800066f4:	e4d6                	sd	s5,72(sp)
    800066f6:	e0da                	sd	s6,64(sp)
    800066f8:	fc5e                	sd	s7,56(sp)
    800066fa:	f862                	sd	s8,48(sp)
    800066fc:	f466                	sd	s9,40(sp)
    800066fe:	f06a                	sd	s10,32(sp)
    80006700:	ec6e                	sd	s11,24(sp)
    80006702:	0100                	addi	s0,sp,128
    80006704:	8aaa                	mv	s5,a0
    80006706:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006708:	00c52c83          	lw	s9,12(a0)
    8000670c:	001c9c9b          	slliw	s9,s9,0x1
    80006710:	1c82                	slli	s9,s9,0x20
    80006712:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006716:	00037517          	auipc	a0,0x37
    8000671a:	a1250513          	addi	a0,a0,-1518 # 8003d128 <disk+0x2128>
    8000671e:	ffffa097          	auipc	ra,0xffffa
    80006722:	4ba080e7          	jalr	1210(ra) # 80000bd8 <acquire>
  for(int i = 0; i < 3; i++){
    80006726:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006728:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000672a:	00035c17          	auipc	s8,0x35
    8000672e:	8d6c0c13          	addi	s8,s8,-1834 # 8003b000 <disk>
    80006732:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006734:	4b0d                	li	s6,3
    80006736:	a0ad                	j	800067a0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006738:	00fc0733          	add	a4,s8,a5
    8000673c:	975e                	add	a4,a4,s7
    8000673e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006742:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006744:	0207c563          	bltz	a5,8000676e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006748:	2905                	addiw	s2,s2,1
    8000674a:	0611                	addi	a2,a2,4
    8000674c:	19690d63          	beq	s2,s6,800068e6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006750:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006752:	00037717          	auipc	a4,0x37
    80006756:	8c670713          	addi	a4,a4,-1850 # 8003d018 <disk+0x2018>
    8000675a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000675c:	00074683          	lbu	a3,0(a4)
    80006760:	fee1                	bnez	a3,80006738 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006762:	2785                	addiw	a5,a5,1
    80006764:	0705                	addi	a4,a4,1
    80006766:	fe979be3          	bne	a5,s1,8000675c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000676a:	57fd                	li	a5,-1
    8000676c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000676e:	01205d63          	blez	s2,80006788 <virtio_disk_rw+0xa2>
    80006772:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006774:	000a2503          	lw	a0,0(s4)
    80006778:	00000097          	auipc	ra,0x0
    8000677c:	d8e080e7          	jalr	-626(ra) # 80006506 <free_desc>
      for(int j = 0; j < i; j++)
    80006780:	2d85                	addiw	s11,s11,1
    80006782:	0a11                	addi	s4,s4,4
    80006784:	ffb918e3          	bne	s2,s11,80006774 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006788:	00037597          	auipc	a1,0x37
    8000678c:	9a058593          	addi	a1,a1,-1632 # 8003d128 <disk+0x2128>
    80006790:	00037517          	auipc	a0,0x37
    80006794:	88850513          	addi	a0,a0,-1912 # 8003d018 <disk+0x2018>
    80006798:	ffffc097          	auipc	ra,0xffffc
    8000679c:	bc6080e7          	jalr	-1082(ra) # 8000235e <sleep>
  for(int i = 0; i < 3; i++){
    800067a0:	f8040a13          	addi	s4,s0,-128
{
    800067a4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800067a6:	894e                	mv	s2,s3
    800067a8:	b765                	j	80006750 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800067aa:	00037697          	auipc	a3,0x37
    800067ae:	8566b683          	ld	a3,-1962(a3) # 8003d000 <disk+0x2000>
    800067b2:	96ba                	add	a3,a3,a4
    800067b4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800067b8:	00035817          	auipc	a6,0x35
    800067bc:	84880813          	addi	a6,a6,-1976 # 8003b000 <disk>
    800067c0:	00037697          	auipc	a3,0x37
    800067c4:	84068693          	addi	a3,a3,-1984 # 8003d000 <disk+0x2000>
    800067c8:	6290                	ld	a2,0(a3)
    800067ca:	963a                	add	a2,a2,a4
    800067cc:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800067d0:	0015e593          	ori	a1,a1,1
    800067d4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800067d8:	f8842603          	lw	a2,-120(s0)
    800067dc:	628c                	ld	a1,0(a3)
    800067de:	972e                	add	a4,a4,a1
    800067e0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800067e4:	20050593          	addi	a1,a0,512
    800067e8:	0592                	slli	a1,a1,0x4
    800067ea:	95c2                	add	a1,a1,a6
    800067ec:	577d                	li	a4,-1
    800067ee:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800067f2:	00461713          	slli	a4,a2,0x4
    800067f6:	6290                	ld	a2,0(a3)
    800067f8:	963a                	add	a2,a2,a4
    800067fa:	03078793          	addi	a5,a5,48
    800067fe:	97c2                	add	a5,a5,a6
    80006800:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006802:	629c                	ld	a5,0(a3)
    80006804:	97ba                	add	a5,a5,a4
    80006806:	4605                	li	a2,1
    80006808:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000680a:	629c                	ld	a5,0(a3)
    8000680c:	97ba                	add	a5,a5,a4
    8000680e:	4809                	li	a6,2
    80006810:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006814:	629c                	ld	a5,0(a3)
    80006816:	973e                	add	a4,a4,a5
    80006818:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000681c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006820:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006824:	6698                	ld	a4,8(a3)
    80006826:	00275783          	lhu	a5,2(a4)
    8000682a:	8b9d                	andi	a5,a5,7
    8000682c:	0786                	slli	a5,a5,0x1
    8000682e:	97ba                	add	a5,a5,a4
    80006830:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006834:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006838:	6698                	ld	a4,8(a3)
    8000683a:	00275783          	lhu	a5,2(a4)
    8000683e:	2785                	addiw	a5,a5,1
    80006840:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006844:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006848:	100017b7          	lui	a5,0x10001
    8000684c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006850:	004aa783          	lw	a5,4(s5)
    80006854:	02c79163          	bne	a5,a2,80006876 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006858:	00037917          	auipc	s2,0x37
    8000685c:	8d090913          	addi	s2,s2,-1840 # 8003d128 <disk+0x2128>
  while(b->disk == 1) {
    80006860:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006862:	85ca                	mv	a1,s2
    80006864:	8556                	mv	a0,s5
    80006866:	ffffc097          	auipc	ra,0xffffc
    8000686a:	af8080e7          	jalr	-1288(ra) # 8000235e <sleep>
  while(b->disk == 1) {
    8000686e:	004aa783          	lw	a5,4(s5)
    80006872:	fe9788e3          	beq	a5,s1,80006862 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006876:	f8042903          	lw	s2,-128(s0)
    8000687a:	20090793          	addi	a5,s2,512
    8000687e:	00479713          	slli	a4,a5,0x4
    80006882:	00034797          	auipc	a5,0x34
    80006886:	77e78793          	addi	a5,a5,1918 # 8003b000 <disk>
    8000688a:	97ba                	add	a5,a5,a4
    8000688c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006890:	00036997          	auipc	s3,0x36
    80006894:	77098993          	addi	s3,s3,1904 # 8003d000 <disk+0x2000>
    80006898:	00491713          	slli	a4,s2,0x4
    8000689c:	0009b783          	ld	a5,0(s3)
    800068a0:	97ba                	add	a5,a5,a4
    800068a2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800068a6:	854a                	mv	a0,s2
    800068a8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800068ac:	00000097          	auipc	ra,0x0
    800068b0:	c5a080e7          	jalr	-934(ra) # 80006506 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800068b4:	8885                	andi	s1,s1,1
    800068b6:	f0ed                	bnez	s1,80006898 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800068b8:	00037517          	auipc	a0,0x37
    800068bc:	87050513          	addi	a0,a0,-1936 # 8003d128 <disk+0x2128>
    800068c0:	ffffa097          	auipc	ra,0xffffa
    800068c4:	3e4080e7          	jalr	996(ra) # 80000ca4 <release>
}
    800068c8:	70e6                	ld	ra,120(sp)
    800068ca:	7446                	ld	s0,112(sp)
    800068cc:	74a6                	ld	s1,104(sp)
    800068ce:	7906                	ld	s2,96(sp)
    800068d0:	69e6                	ld	s3,88(sp)
    800068d2:	6a46                	ld	s4,80(sp)
    800068d4:	6aa6                	ld	s5,72(sp)
    800068d6:	6b06                	ld	s6,64(sp)
    800068d8:	7be2                	ld	s7,56(sp)
    800068da:	7c42                	ld	s8,48(sp)
    800068dc:	7ca2                	ld	s9,40(sp)
    800068de:	7d02                	ld	s10,32(sp)
    800068e0:	6de2                	ld	s11,24(sp)
    800068e2:	6109                	addi	sp,sp,128
    800068e4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800068e6:	f8042503          	lw	a0,-128(s0)
    800068ea:	20050793          	addi	a5,a0,512
    800068ee:	0792                	slli	a5,a5,0x4
  if(write)
    800068f0:	00034817          	auipc	a6,0x34
    800068f4:	71080813          	addi	a6,a6,1808 # 8003b000 <disk>
    800068f8:	00f80733          	add	a4,a6,a5
    800068fc:	01a036b3          	snez	a3,s10
    80006900:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006904:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006908:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000690c:	7679                	lui	a2,0xffffe
    8000690e:	963e                	add	a2,a2,a5
    80006910:	00036697          	auipc	a3,0x36
    80006914:	6f068693          	addi	a3,a3,1776 # 8003d000 <disk+0x2000>
    80006918:	6298                	ld	a4,0(a3)
    8000691a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000691c:	0a878593          	addi	a1,a5,168
    80006920:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006922:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006924:	6298                	ld	a4,0(a3)
    80006926:	9732                	add	a4,a4,a2
    80006928:	45c1                	li	a1,16
    8000692a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000692c:	6298                	ld	a4,0(a3)
    8000692e:	9732                	add	a4,a4,a2
    80006930:	4585                	li	a1,1
    80006932:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006936:	f8442703          	lw	a4,-124(s0)
    8000693a:	628c                	ld	a1,0(a3)
    8000693c:	962e                	add	a2,a2,a1
    8000693e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffc000e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006942:	0712                	slli	a4,a4,0x4
    80006944:	6290                	ld	a2,0(a3)
    80006946:	963a                	add	a2,a2,a4
    80006948:	058a8593          	addi	a1,s5,88
    8000694c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000694e:	6294                	ld	a3,0(a3)
    80006950:	96ba                	add	a3,a3,a4
    80006952:	40000613          	li	a2,1024
    80006956:	c690                	sw	a2,8(a3)
  if(write)
    80006958:	e40d19e3          	bnez	s10,800067aa <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000695c:	00036697          	auipc	a3,0x36
    80006960:	6a46b683          	ld	a3,1700(a3) # 8003d000 <disk+0x2000>
    80006964:	96ba                	add	a3,a3,a4
    80006966:	4609                	li	a2,2
    80006968:	00c69623          	sh	a2,12(a3)
    8000696c:	b5b1                	j	800067b8 <virtio_disk_rw+0xd2>

000000008000696e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000696e:	1101                	addi	sp,sp,-32
    80006970:	ec06                	sd	ra,24(sp)
    80006972:	e822                	sd	s0,16(sp)
    80006974:	e426                	sd	s1,8(sp)
    80006976:	e04a                	sd	s2,0(sp)
    80006978:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000697a:	00036517          	auipc	a0,0x36
    8000697e:	7ae50513          	addi	a0,a0,1966 # 8003d128 <disk+0x2128>
    80006982:	ffffa097          	auipc	ra,0xffffa
    80006986:	256080e7          	jalr	598(ra) # 80000bd8 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000698a:	10001737          	lui	a4,0x10001
    8000698e:	533c                	lw	a5,96(a4)
    80006990:	8b8d                	andi	a5,a5,3
    80006992:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006994:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006998:	00036797          	auipc	a5,0x36
    8000699c:	66878793          	addi	a5,a5,1640 # 8003d000 <disk+0x2000>
    800069a0:	6b94                	ld	a3,16(a5)
    800069a2:	0207d703          	lhu	a4,32(a5)
    800069a6:	0026d783          	lhu	a5,2(a3)
    800069aa:	06f70163          	beq	a4,a5,80006a0c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800069ae:	00034917          	auipc	s2,0x34
    800069b2:	65290913          	addi	s2,s2,1618 # 8003b000 <disk>
    800069b6:	00036497          	auipc	s1,0x36
    800069ba:	64a48493          	addi	s1,s1,1610 # 8003d000 <disk+0x2000>
    __sync_synchronize();
    800069be:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800069c2:	6898                	ld	a4,16(s1)
    800069c4:	0204d783          	lhu	a5,32(s1)
    800069c8:	8b9d                	andi	a5,a5,7
    800069ca:	078e                	slli	a5,a5,0x3
    800069cc:	97ba                	add	a5,a5,a4
    800069ce:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800069d0:	20078713          	addi	a4,a5,512
    800069d4:	0712                	slli	a4,a4,0x4
    800069d6:	974a                	add	a4,a4,s2
    800069d8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800069dc:	e731                	bnez	a4,80006a28 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800069de:	20078793          	addi	a5,a5,512
    800069e2:	0792                	slli	a5,a5,0x4
    800069e4:	97ca                	add	a5,a5,s2
    800069e6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800069e8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800069ec:	ffffc097          	auipc	ra,0xffffc
    800069f0:	b08080e7          	jalr	-1272(ra) # 800024f4 <wakeup>

    disk.used_idx += 1;
    800069f4:	0204d783          	lhu	a5,32(s1)
    800069f8:	2785                	addiw	a5,a5,1
    800069fa:	17c2                	slli	a5,a5,0x30
    800069fc:	93c1                	srli	a5,a5,0x30
    800069fe:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a02:	6898                	ld	a4,16(s1)
    80006a04:	00275703          	lhu	a4,2(a4)
    80006a08:	faf71be3          	bne	a4,a5,800069be <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006a0c:	00036517          	auipc	a0,0x36
    80006a10:	71c50513          	addi	a0,a0,1820 # 8003d128 <disk+0x2128>
    80006a14:	ffffa097          	auipc	ra,0xffffa
    80006a18:	290080e7          	jalr	656(ra) # 80000ca4 <release>
}
    80006a1c:	60e2                	ld	ra,24(sp)
    80006a1e:	6442                	ld	s0,16(sp)
    80006a20:	64a2                	ld	s1,8(sp)
    80006a22:	6902                	ld	s2,0(sp)
    80006a24:	6105                	addi	sp,sp,32
    80006a26:	8082                	ret
      panic("virtio_disk_intr status");
    80006a28:	00002517          	auipc	a0,0x2
    80006a2c:	e2850513          	addi	a0,a0,-472 # 80008850 <syscalls+0x3e8>
    80006a30:	ffffa097          	auipc	ra,0xffffa
    80006a34:	b08080e7          	jalr	-1272(ra) # 80000538 <panic>
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
