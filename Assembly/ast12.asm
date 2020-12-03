;  Morgan Kiger - Section 1001
;  CS 218 - Assignment #12
;  Amicable Numbers Program
;  Provided template with threading calls

; -----
;  Example Amicable Numbers Numbers (base 10)
;	220(10)		284(10)
;	1184(10)	1210(10)
;	2620(10)	2924(10)
;	...		...

;  Example Amicable Numbers Numbers (base 13)
;	13C(13)		18B(13)
;	701(13)		721(13)
;	1267(13)	143C(13)
;	...		...


; ***************************************************************

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
ESC		equ	27			; escape key

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; call code for read
SYS_write	equ	1			; call code for write
SYS_open	equ	2			; call code for file open
SYS_close	equ	3			; call code for file close
SYS_fork	equ	57			; call code for fork
SYS_exit	equ	60			; call code for terminate
SYS_creat	equ	85			; call code for file open/create
SYS_time	equ	201			; call code for get time

; -----
;  Message strings

header		db	"**********************************************", LF
		db	ESC, "[1m", "Amicable Numbers Program"
		db	ESC, "[0m", LF, LF, NULL
msgStart	db	"--------------------------------------", LF	
		db	"Start Counting", LF, NULL
nMsgMain	db	"Amicable Numbers: ", NULL
msgProgDone	db	LF, "Completed.", LF, NULL

numberLimit	dq	0		; limit (quad)
thdCount	dd	0		; thread Count

; -----
;  Globals (used by threads)

idxCounter	dq	10
amicableCount	dq	0

myLock1		dq	0
myLock2		dq	0

; -----
;  Thread data structures

pthreadID0	dq	0, 0, 0, 0, 0
pthreadID1	dq	0, 0, 0, 0, 0
pthreadID2	dq	0, 0, 0, 0, 0
pthreadID3	dq	0, 0, 0, 0, 0

; -----
;  Variables for thread function.

msgThread1	db	" ...Thread starting...", LF, NULL
spc		db	"   ", NULL

; -----
;  Variables for printMessageValue

newLine		db	LF, NULL

; -----
;  Variables for getCommandLineArgs function

THREAD_MIN	equ	1
THREAD_MAX	equ	4

LIMIT_MIN	equ	10
LIMIT_MAX	equ	4000000000

errUsage	db	"Usgae: ./amicableNums -th <1|2|3|4> ",
		db	"-lm <tridecimalNumber>", LF, NULL
errOptions	db	"Error, invalid command line options."
		db	LF, NULL
errTHSpec	db	"Error, invalid thread count specifier."
		db	LF, NULL
errTHValue	db	"Error, thread count invalid."
		db	LF, NULL
errLMSpec	db	"Error, invalid limit specifier."
		db	LF, NULL
errLMValue	db	"Error, limit invalid."
		db	LF, NULL

; -----
;  Variables for int2tri function

tmpNum		dq	0

; -----
;  Uninitialized data

section	.bss

tmpString	resb	20
amicableNums1	resd	1000
amicableNums2	resd	1000


; ***************************************************************

section	.text

; -----
;  External statements for thread functions.

extern	pthread_create, pthread_join

; ================================================================
;  Amicable number program.

global main
main:

; -----
;  Check command line arguments

	mov	rdi, rdi			; argc
	mov	rsi, rsi			; argv
	mov	rdx, thdCount
	mov	rcx, numberLimit
	call	getCommandLineArgs

	cmp	rax, TRUE
	jne	progDone

; -----
;  Initial actions:
;	Display initial messages

	mov	rdi, header
	call	printString

	mov	rdi, msgStart
	call	printString

; -----
;  Create new thread(s) as appropriate
;	pthread_create(&pthreadID0, NULL, &threadFunction0, NULL);
	mov	rdi, msgThread1
	call	printString
	
	mov	rdi, pthreadID0
	mov	rsi, NULL
	mov	rdx, findAmicableNumbers
	mov	rcx, NULL
	call	pthread_create

;	As applicable, other thread calls, pthread_create(), go here...
	cmp	dword[thdCount], 2
	jb	WaitForThreadCompletion

	mov	rdi, msgThread1
	call	printString
	
	mov	rdi, pthreadID1
	mov	rsi, NULL
	mov	rdx, findAmicableNumbers
	mov	rcx, NULL
	call	pthread_create

	cmp	dword[thdCount], 3
	jb	WaitForThreadCompletion

	mov	rdi, msgThread1
	call	printString
	
	mov	rdi, pthreadID2
	mov	rsi, NULL
	mov	rdx, findAmicableNumbers
	mov	rcx, NULL
	call	pthread_create

	cmp	dword[thdCount], 4
	jb	WaitForThreadCompletion

	mov	rdi, msgThread1
	call	printString
	
	mov	rdi, pthreadID3
	mov	rsi, NULL
	mov	rdx, findAmicableNumbers
	mov	rcx, NULL
	call	pthread_create


; -----
;  Wait for thread(s) to complete.
;	pthread_join (pthreadID0, NULL);

WaitForThreadCompletion:
	mov	rdi, qword [pthreadID0]
	mov	rsi, NULL
	call	pthread_join

;	As applicable, other thread joins, pthread_join(), go here

	cmp	dword[thdCount], 2
	jb	showFinalResults

	mov	rdi, qword [pthreadID1]
	mov	rsi, NULL
	call	pthread_join

	cmp	dword[thdCount], 3
	jb	showFinalResults

	mov	rdi, qword [pthreadID2]
	mov	rsi, NULL
	call	pthread_join

	cmp	dword[thdCount], 4
	jb	showFinalResults

	mov	rdi, qword [pthreadID3]
	mov	rsi, NULL
	call	pthread_join


; -----
;  Display final count

showFinalResults:
	mov	rdi, newLine
	call	printString

	mov	rdi, nMsgMain
	call	printString
	mov	rdi, qword [amicableCount]		; index/count
	mov	rsi, tmpString
	call	int2tri
	mov	rdi, tmpString
	call	printString
	mov	rdi, newLine
	call	printString

	mov	rbx, 0
prtNumsLoop;
	mov	rdi, spc
	call	printString

	mov	edi, dword [amicableNums1+rbx*4]	; first num
	mov	rsi, tmpString
	call	int2tri
	mov	rdi, tmpString
	call	printString

	mov	rdi, spc
	call	printString
	mov	edi, dword [amicableNums2+rbx*4]	; second num
	mov	rsi, tmpString
	call	int2tri
	mov	rdi, tmpString
	call	printString

	mov	rdi, newLine
	call	printString

	inc	rbx
	cmp	rbx, qword [amicableCount]
	jb	prtNumsLoop

; **********
;  Program done, display final message
;	and terminate.

	mov	rdi, msgProgDone
	call	printString

progDone:
	mov	rax, SYS_exit			; system call for exit
	mov	rdi, SUCCESS			; return code SUCCESS
	syscall

; ******************************************************************
;  Thread function, findAmicableNumbers()
;	Find amicable numbers.
;	Note, function uses global variables so nothing is
;		passed and nothing is returned.

; -----
;  Arguments:
;	N/A (global variable accessed)
;  Returns:
;	N/A (global variable accessed)


global findAmicableNumbers
findAmicableNumbers:

				;beginning push
	push	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15
				;lock thread to grab first global, idxCounter
grabCount:
	call	spinLock1
	inc	qword[idxCounter]
	mov	r14, qword[idxCounter]
	call	spinUnlock1

				;before operations check if idxCounter is > limit
	cmp	r14, qword[numberLimit]
	ja	amicableDone
				;find amicable numbers
	mov	r11, 1		;i
	mov	r12, 0		;running sum 1
	mov	r13, 0		;running sum 2
rsum1Lp:
	mov	rdx, 0
	mov	rax, r14
	div	r11
	cmp	rdx, 0
	jne	contRSum1
	
	add	r12, r11
contRSum1:
	inc	r11
	cmp	r11, r14
	jb	rsum1Lp
					;check to see if divisor is equal to current global counter
	cmp	r12, r14
	je	grabCount
	mov	r11, 1
	
rsum2Lp:
	mov	rdx, 0
	mov	rax, r12
	div	r11
	cmp	rdx, 0
	jne	contRSum2
	add	r13, r11
contRSum2:
	inc	r11
	cmp	r11, r12
	jb 	rsum2Lp
	
	cmp	r14, r13
	jne	grabCount
	
					;place amicable numbers in array
	call	spinLock2
	lea	r11, qword[amicableNums1]
	lea	r15, qword[amicableNums2]
	mov	rbx, qword[amicableCount]
	
	cmp	rbx, 0
	je	storeNums
chkForTwo:
	dec	rbx
	cmp	r13d, dword[r15+rbx*4]
	je	twoNums
	
	cmp	rbx, 0
	ja	chkForTwo
	
	mov 	rbx, qword[amicableCount]
	
storeNums:
	mov	dword[r15 + rbx * 4], r12d
	mov	dword[r11 + rbx * 4], r13d
	
	inc	qword[amicableCount]
twoNums:
	
	call	spinUnlock2
	jmp	grabCount

amicableDone:
	
	pop 	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	mov	rsp, rbp
	pop	rbp
	
	ret
	
; ******************************************************************
;  Mutex lock
;	checks lock (shared gloabl variable)
;		if unlocked, sets lock
;		if locked, lops to recheck until lock is free

global	spinLock1
spinLock1:
	mov	rax, 1			; Set the REAX register to 1.

lock	xchg	rax, qword [myLock1]	; Atomically swap the RAX register with
					;  the lock variable.
					; This will always store 1 to the lock, leaving
					;  the previous value in the RAX register.

	test	rax, rax	        ; Test RAX with itself. Among other things, this will
					;  set the processor's Zero Flag if RAX is 0.
					; If RAX is 0, then the lock was unlocked and
					;  we just locked it.
					; Otherwise, RAX is 1 and we didn't acquire the lock.

	jnz	spinLock1		; Jump back to the MOV instruction if the Zero Flag is
					;  not set; the lock was previously locked, and so
					; we need to spin until it becomes unlocked.
	ret

; -----

global	spinLock2
spinLock2:
	mov	rax, 1			; Set the RAX register to 1.

lock	xchg	rax, qword [myLock2]	; Atomically swap the RAX register with
					;  the lock variable.
					; This will always store 1 to the lock, leaving
					;  the previous value in the RAX register.

	test	rax, rax	        ; Test RAX with itself. Among other things, this will
					;  set the processor's Zero Flag if RAX is 0.
					; If RAX is 0, then the lock was unlocked and
					;  we just locked it.
					; Otherwise, RAX is 1 and we didn't acquire the lock.

	jnz	spinLock2		; Jump back to the MOV instruction if the Zero Flag is
					;  not set; the lock was previously locked, and so
					; we need to spin until it becomes unlocked.
	ret

; ******************************************************************
;  Mutex unlock
;	unlock the lock (shared global variable)

global	spinUnlock1
spinUnlock1:
	mov	rax, 0			; Set the RAX register to 0.

	xchg	rax, qword [myLock1]	; Atomically swap the RAX register with
					;  the lock variable.
	ret

; -----

global	spinUnlock2
spinUnlock2:
	mov	rax, 0			; Set the RAX register to 0.

	xchg	rax, qword [myLock2]	; Atomically swap the RAX register with
					;  the lock variable.
	ret

; ******************************************************************
;  Function getCommandLineArgs()
;	Get, check, convert, verify range, and return the
;	thread count and the limit.

;  Example HLL call:
;	bool = getCommandLineArgs(argc, argv, &thdConut, &numberLimit)

;  This routine performs all error checking, conversion of
;  ASCII/tridecimal to integer, verifies legal range.
;  For errors, display applicable message and FALSE is returned.
;  For good data, all values are returned via references (addresses)
;  with TRUE returned.

;  Command line format (fixed order):
;	-th <1|2|3|4> -lm <tridecimalNumber>

; -----
;  Arguments:
;	1) ARGC, value - rdi
;	2) ARGV, address - rsi
;	3) thread count (dword), address - rdx
;	4) limit (qword), address - rcx


global getCommandLineArgs
getCommandLineArgs:	
	push	rbp
	mov	rbp, rsp

	push	rdx
	push	rcx
	push	rsi
				;check to make sure correct number for argc
	cmp	rdi, 1
	je	msgUsage

	cmp	rdi, 5
	jne	msgINopt

				;check argv[1] for "-th"
	mov	r10, qword[rsi+8]
	cmp	dword[r10], 0x0068742D
	jne	msgINthrSpec

				;check argv[2] for thread count (1 <_ tc <_ 4)
	mov	rdi, qword[rsi + 16]
	mov	rsi, thdCount
	call	tri2int

	cmp 	rax, 1
	je	msgINopt

	mov	r10, rsi
	
	cmp	qword[r10], THREAD_MAX
	ja	msgINthrVal

	cmp	qword[r10], THREAD_MIN
	jb	msgINthrVal

	pop	rsi

				;check argv[3] for "-lm"
	mov	r10, qword[rsi + 24]
	cmp	dword[r10], 0x006D6C2D
	jne	msgINlimSpec

				;check argv[4] for limit count (10 <_ lm <_ 40000000)

	
	mov	rdi, qword[rsi + 32]
	mov	rsi, numberLimit
	call	tri2int

	cmp 	rax, 1
	je	msgINopt

	mov	r10, rsi
	
	cmp	qword[r10], LIMIT_MIN
	jb	msgINlimVal

	cmp	qword[r10], LIMIT_MAX
	ja	msgINlimVal



	pop	rcx
	pop	rdx

	mov	rcx, numberLimit
	mov	rdx, thdCount
	
	mov	rax, TRUE
goBack:	
	mov	rsp, rbp
	pop	rbp

	ret

msgUsage:
	mov	rdi, errUsage
	call 	printString
	mov	rax, FALSE
	jmp	goBack
msgINopt:
	mov	rdi, errOptions
	call	printString
	mov	rax, FALSE
	jmp	goBack
msgINthrSpec:
	mov	rdi, errTHSpec
	call	printString
	mov	rax, FALSE
	jmp	goBack
msgINthrVal:
	mov	rdi, errTHValue
	call	printString
	mov	rax, FALSE
	jmp	goBack
msgINlimSpec:
	mov	rdi, errLMSpec
	call	printString
	mov	rax, FALSE
	jmp	goBack
msgINlimVal:	
	mov	rdi, errLMValue
	call	printString
	mov	rax, FALSE
	jmp	goBack
; ******************************************************************
;  Boolean Function: Check and convert ASCII/Tridecimal
;		string to integer.

;  Example HLL Call:
;	bool = tri2int(trideicmalStr, &num);


global tri2int
tri2int:
	push	rbp
	mov	rbp, rsp
	push	r12
	push	r13
	push	r14
	push	r15

	mov	rax, 0
	
	mov	r10, 13
	mov	r11, 0		;j
	
	mov	r12, 0
	mov	r13, 0		;space counter
	mov	r14, 0		;digit counter
	mov	r15, 0		;i
	
				;check for spaces
				;if(arr[i] == SPACE)
checkSpace:	
	mov	al, byte[rdi + r15]
	cmp	al, 0x20
	jne	digitCnt
				;	i++
	inc	r13
	inc	r15
				;	jmp checkSpace
	jmp	checkSpace
digitCnt:	
				;check Digit count
				;if(arr[i] != NULL)
	mov	al, byte[rdi + r15]
	cmp	al, NULL
	je	doneDC
				;	digitcount++
	inc	r14
				;	i++
	inc	r15
	jmp	digitCnt
doneDC:
				;reset i to after last space
	mov	r15, r13
				;check to make sure valid tri decimals
errCheck:
	mov	al, byte[rdi + r15]

	cmp	al, NULL
	je	validChkDone

	cmp	al, "0"
	jb	invalidTri
	cmp	al, "9"
	jbe	validNum

	cmp	al, "c"
	ja	invalidTri

	cmp	al, "C"
	ja	secondCheck
	jmp	skipCheck
secondCheck:
	cmp	al, "a"
	jb	invalidTri
skipCheck:
	cmp	al, "A"
	jb	invalidTri
validNum:
	inc	r15
	jmp	errCheck
validChkDone:
				;dc --
	dec	r14

	mov	r15, r13	;reset i after spaces
cvtLp:	
				;cvtLp
				;pow = dc
	mov	r13, r14
				;temp = arr[i]
	mov	al, byte[rdi +r15]
				;if(temp == NULL)
				;	cvtDone
	cmp	al, NULL
	je	cvtDone
				;if(arr[i] >_ "a")
				;	jmp intLChar
	cmp	al, "a"		
	jae	intLChar
				;if(arr[i] >_ "A")
				;	jmp intUChar
	cmp	al, "A"
	jae	intUChar
				;if(arr[i] <_ "9")
				;	jmp intNum
	cmp	al, "9"
	jbe	intNum
				;intLChar
				;temp = temp - "a" + 10
				;jmp startCvt
intLChar:	
	sub	al, "a"
	add	al, 10		
	jmp	startCvt
				;intUChar
				;temp = temp - "A" + 10
				;jmp startCvt
intUChar:	
	sub	al, "A"
	add	al, 10
	jmp	startCvt
				;intNum
				;temp = temp - "0"
intNum:
	sub	al, "0"
				;startCvt
				;if(dc == 0) dont multiply
				;	runSum
startCvt:	
	cmp	r14, 0
	je	runSum
				;mulThir
				;temp = temp*13^dc
				;	temp = temp * 13
				;	pow--
				;	cmp pow, 0
				;	if(pow > 0)
				;		jmp mulThir
mulThir:
	mul	r10
	dec	r13
	cmp	r13, 0
	jne	mulThir
				;runSum
				;	2 = 2 + temp
				;	dc--
				;	i++
				;	jmp cvtLp
runSum:
	add	r12, rax
	dec	r14
	inc	r15
	jmp	cvtLp
				;cvtDone
cvtDone:
	mov	qword[rsi], r12

goBack2:
	mov	rax, SUCCESS

	pop	r15
	pop	r14
	pop	r13
	pop	r12
	mov	rsp, rbp
	pop	rbp

	ret

invalidTri:
	mov	rax, NOSUCCESS
	jmp	goBack2


; ******************************************************************
;  Void Function: Convert integer to ASCII/Tridecimal string.
;	Note, no error checking done on integer.

;  Example HLL Call:
;	int2tri(num, string)

; -----
;  Arguments:
;	- integer, value - rdi
;	- string, address - rsi
; -----
;  Returns:
;	ASCII/Tridecimal string (NULL terminated)


global int2tri
int2tri:
				;beginning
	push	rbp
	mov	rbp, rsp
	push	r12
	push	r13
	push	r14
	push	r15

	mov	r10, 13
	
	mov	r12, 0		;running sum
	mov	r13, 0		;push counter
	mov	r14, 0		;digit counter
	mov	r15, 0		;i

	mov 	rax, rdi

cvt2tri:
	mov	rdx, 0
	div	r10
	push	rdx
	inc 	r13
	cmp	rax, 0
	jne	cvt2tri

triString:
	pop	rdx
	dec	r13

	cmp	rdx, 10
	jge	greatTen

	add	rdx, "0"
	jmp	saveString
greatTen:
	sub	rdx, 10
	add	rdx, "A"
saveString:	
	mov	byte[rsi + r15], dl
	inc 	r15
	cmp	r13, 0
	jne	triString

goBack1:
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	mov	rsp, rbp
	pop	rbp

	ret
	



; ******************************************************************
;  Generic procedure to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	- address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
; Count characters to write.

	mov	rdx, 0
strCountLoop:
	cmp	byte[rdi+rdx], NULL
	je	strCountLoopDone
	inc	rdx
	jmp	strCountLoop
strCountLoopDone:
	cmp	rdx, 0
	je	printStringDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************
