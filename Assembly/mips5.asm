# CS 218, MIPS Assignment #5, Morgan Kiger
#  Provided template

# ####################################################################
#  data segment

.data

# -----
#  Constants

TRUE = 1
FALSE = 0

# -----
#  Variables for main

hdr:		.ascii	"\n**********************************************\n"
  .ascii	"MIPS Assignment #5 - Morgan Kiger\n"
  .asciiz	"Ways to Make Change Program\n"

endMsg:		.ascii	"\nYou have reached recursive nirvana.\n"
  .asciiz	"Program Terminated.\n"

amountMinimum:	.word	1		# $0.01 dollars or 1 cent
amountMaximum:	.word	500		# $10.00 dollars or 1000 cents
initialAmount:	.word	0
waysCount:	.word	0
errorLimit:	.word	3		# 3 errors allowed, 4th error exits

coins:		.word	500, 100, 50, 25, 10, 5, 1
coinsCount:	.word	7

# -----
#  Variables for showWays() function.

cntMsg1:	.asciiz	"\nFor an amount of $"
cntDot:		.asciiz	"."
cntMsg2:	.asciiz	", there are "
cntMsg3:	.asciiz	" ways to make change.\n"

# -----
#  Variables for readInitAmt() function.

amtPmt1:	.asciiz	"  Enter Amount ("
amtPmt2:	.asciiz	" - "
amtPmt3:	.asciiz	"): "

err1:		.ascii	"\nError, amount out of range. \n"
  .asciiz	"Please re-enter data.\n"

err2:		.ascii	"\nSorry your having problems.\n"
  .asciiz	"Please try again later.\n"

spc:		.asciiz	"   "

# -----
#  Variables for prtNewline function.

newLine:	.asciiz	"\n"


# -----
#  Variables for makeChange() function.


# -----
#  Variables for continue.

qPmt:		.asciiz	"\nTry another amount (y/n)? "
ansErr:		.asciiz	"Error, must answer with (y/n)."

ans:		.space	3


#####################################################################
#  text/code segment

.text

.globl main
.ent main
main:

# -----
#  Display program header.

la	$a0, hdr
li	$v0, 4
syscall					# print header

# -----
#  Function to read and amount (1-AMT_MAX).

doAnother:
sw	$zero, initialAmount		# re-set variables
sw	$zero, waysCount

lw	$a0, amountMinimum		# min
lw	$a1, amountMaximum		# max
lw	$a2, errorLimit			# allowed errors
la	$a3, initialAmount
jal	readInitAmt

bne	$v0, TRUE, programDone		# if not TRUE, exit

# -----
#  call makeChange to determine how many ways change could be made.
#	Returns integer answer.
#	HLL Call:
#		waysCount = makeChange(denomCount, initialAmount)

la	$a0, coins
lw	$a1, coinsCount
lw	$a2, initialAmount
jal	makeChange

sw	$v0, waysCount

# ----
#  Display results (formatted).

lw	$a0, initialAmount
lw	$a1, waysCount
jal	showWays

# -----
#  See if user wants to do another?

jal	continue
beq	$v0, TRUE, doAnother

programDone:
li	$v0, 4
la	$a0, endMsg
syscall

# -----
#  Done, terminate program.

li	$v0, 10
syscall					# all done...
.end main

# =================================================================
#  Very simple function to print a new line.
#	Note, this routine is optional.

.globl	prtNewline
.ent	prtNewline
prtNewline:
la	$a0, newLine
li	$v0, 4
syscall

jr	$ra
.end	prtNewline

# =================================================================
#  Function to print final result (formatted).

#  Formatted message:
#    For an amount of $xx.yy, there are zz ways to make change.

# -----
#  Arguments
#	$a0 - initial amount
#	$a1 - ways to make change

.globl showWays
.ent showWays
showWays:
  sub		$sp, $sp, 16
  sw		$s0, 0($sp)
  sw 		$s1, 4($sp)
  sw    $s2, 8($sp)
  sw    $s3, 12($sp)
  add		$fp, $sp, 16

  move  $s0, $a0
  move  $s1, $a1

  div   $s2, $a0, 100
  rem   $s3, $a0, 100
# ----------------------
# display first msg
# ----------------------
  li    $v0, 4
  la    $a0, cntMsg1
  syscall
# ----------------------
# print first digit
# ----------------------
  li    $v0, 1
  move  $a0, $s2
  syscall
# ----------------------
# print the dot
# ----------------------
  li    $v0, 4
  la    $a0, cntDot
  syscall
# ----------------------
# print rest of amount
# ----------------------
  li    $v0, 1
  move  $a0, $s3
  syscall

  bnez  $s3, skipZero

  li    $v0, 1
  move  $a0, $s3
  syscall
skipZero:
# ----------------------
# print msg 2
# ----------------------
  li    $v0, 4
  la    $a0, cntMsg2
  syscall
# ----------------------
# print number of ways
# ----------------------
  li    $v0, 1
  move  $a0, $s1
  syscall
# ----------------------
# print msg 3
# ----------------------
  li    $v0, 4
  la    $a0, cntMsg3
  syscall
# ----------------------

  lw		$s0, 0($sp)
  lw 		$s1, 4($sp)
  lw    $s2, 8($sp)
  lw    $s3, 12($sp)
  add		$sp, $sp, 16

  jr    $ra
.end showWays


# =================================================================
#  Function to prompt for and read initial amount.
#  Ensure that amount is between min cents (passed)
#  and max cents (passed).

# -----
#  HLL Call:
#	bool = readInitAmt(min, max, errLimit, &initAmt)

# -----
#    Arguments:
#	$a0 - minimum amount
#	$a1 - maximum amount
#	$a2 - error limit
#	$a3 - initial amount
#    Returns:
#	$v0 - true or false

.globl readInitAmt
.ent readInitAmt
readInitAmt:
  sub   $sp, $sp, 28
  sw    $s0, 0($sp)
  sw    $s1, 4($sp)
  sw    $s2, 8($sp)
  sw    $s3, 12($sp)
  sw    $s4, 16($sp)
  sw    $s5, 20($sp)
  sw    $ra, 24($sp)
  add   $fp, $sp, 28

  move  $s0, $a0
  move  $s1, $a1
  move  $s2, $a2
  move  $s3, $a3

  move  $s4, $zero

promptUser:
# ----------------------
# promptUser to enter a value between (1-500)
  li    $v0, 4
  la    $a0, amtPmt1
  syscall

  li    $v0, 1
  move  $a0, $s0
  syscall

  li    $v0, 4
  la    $a0, amtPmt2
  syscall

  li    $v0, 1
  move  $a0, $s1
  syscall

  li    $v0, 4
  la    $a0, amtPmt3
  syscall

  li    $v0, 5
  syscall

  move  $s4, $v0                      # user input
# ----------------------
# check to make sure input is between (1-500)
  blt   $s4, $s0, invalidIn
  bgt   $s4, $s1, invalidIn
# if passes checks return the value
  b     storeInput
# ----------------------
# if not output err1 and errcount++
invalidIn:
  add   $s5, $s5, 1                   # error count
  bgt   $s5, $s2, tooManyErrs

  li    $v0, 4
  la    $a0, err1
  syscall
# ----------------------
# if more then err + 1 then print err2 return false
tooManyErrs:
  li    $v0, 4
  la    $a0, err2
  syscall

  li    $v0, 0
  b     goBack
# ----------------------
# store the input and return true
storeInput:
  sw    $s4, ($s3)
  li    $v0, 1

goBack:
  lw		$s0, 0($sp)
	lw		$s1, 4($sp)
	lw		$s2, 8($sp)
	lw		$s3, 12($sp)
	lw		$s4, 16($sp)
	lw		$s5, 20($sp)
  lw    $ra, 24($sp)
	add		$sp, $sp, 28

  jr    $ra

.end readInitAmt



# ####################################################################
#  Function to count the number of ways that change can be made
#  given our standard US monetary denominations (cent,
#  nickel, dime, quarter, etc.).

# -----
#  Arguments:
#	$a0 - coins array
#	$a1 - denomCnt
#	$a2 - currentAmount
#  Returns:
#	$v0 - ways count

.globl makeChange
.ent makeChange
makeChange:
  sub		$sp, $sp, 24
  sw		$s0, 0($sp)
  sw 		$s1, 4($sp)
  sw    $s2, 8($sp)
  sw    $s3, 12($sp)
  sw    $s4, 16($sp)
  sw    $ra, 20($sp)
  add		$fp, $sp, 24

  move  $s0, $a0
  move  $s1, $a1
  move  $s2, $a2

  beqz  $a2, returnOne
  bltz  $a2, returnZero
  ble   $a1, $zero, returnZero

  add   $s3, $s3, $v0
  move  $v0, $s3
# --------------------------------------
# prtA = makeChange(coins, coinCnt-1, currAmt);
# --------------------------------------
  sub   $a1, $a1, 1
  jal   makeChange
  add   $s4, $s4, $v0
# --------------------------------------
# prtB = makeChange(coins, coinCnt, currAmt-coins[coinCnt-1]);
# --------------------------------------
  move  $a0, $s0
  move  $a1, $s1
  mul   $t0, $a1, 4
  add   $t0, $t0, $s0
  lw    $t1, ($t0)
  sub   $a2, $a2, $t1
  jal   makeChange

  add   $v0, $v0, $s4

  b     getOut

returnOne:
  li    $v0, 1
  b     getOut
returnZero:
  move  $v0, $zero
getOut:
  lw		$s0, 0($sp)
  lw 		$s1, 4($sp)
  lw    $s2, 8($sp)
  lw    $s3, 12($sp)
  lw    $s4, 16($sp)
  lw    $ra, 20($sp)
  add		$sp, $sp, 24

  jr  $ra
.end makeChange


# ####################################################################
#  Function to ask user if they want to continue.

#  Basic flow:
#	prompt user
#	read user answer (as character)
#		if y -> return TRUE
#		if n -> return FALSE
#	otherwise, display error and loop to re-prompt

# -----
#  Arguments:
#	none
#  Returns:
#	$v0 - TRUE/FALSE

.globl	continue
.ent	continue
continue:
# display prompt
	li		$v0, 4
	la		$a0, qPmt
	syscall

	li		$v0, 12
	syscall

	beq		$v0, 0x79, retTrue
	beq		$v0, 0x59, retTrue
	beq		$v0, 0x6E, retFalse
	beq		$v0, 0x4E, retFalse

	li		$v0, 4
	la		$a0, ansErr
	syscall
	li		$v0, 4
	la		$a0, newLine
	syscall
	b			continue
retTrue:
  li		$v0, 4
  la		$a0, newLine
  syscall

	li 	$v0, 1
	b		returnAns
retFalse:
	li	$v0, 0
returnAns:

	jr	$ra

.end	doAnother

# ####################################################################
