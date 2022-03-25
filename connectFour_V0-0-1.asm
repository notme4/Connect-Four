# ==============================================================================
# Project: Connect 4
# 	Purpose:	Connect 4 game against an AI
# 	Authors:	Connor Funk, Blackout, SyedQadri, Thomas
#	Date:		
#	Version:	1.0
# ==============================================================================
# connectFour.asm:
#	Purpose:	main 'function' for Connect 4 project
#	Author:		Connor Funk
#`	Date:		Feb. 22, 2022
#	Version:	1.0.1
#	Notes:		adjusted to better follow standards
# ==============================================================================
.data

	
	board:				.ascii		"\0\0\0\0\0\0\0\n\0\0\0\0\0\0\0\n\0\0\0\0\0\0\0\n\0\0\0\0\0\0\0\n\0\0\0\0\0\0\0\n\0\0\0\0\0\0\0\n\0\0\0\0\0\0\0\n"
	# board is an array of 56 bytes, each row of the connect four board is 7 bytes with an empty 8th to keep it word aligned
	#		the 0th row is a count of how many tokens are in each column
	TieMsg:				.asciiz	 	"Game was a Tie :|"
	AIWinMsg:			.asciiz		"You lost :("
	PlayerWinMsg:		.asciiz		"You Won! :D"
	InvalidChoiceMsg:	.asciiz		"Invalid Choice: column is full"
	
	
	.eqv Counter $s7
	
	.globl main
	.globl AfterChoice
	
.text
# =======================================================
# exit Program macro
.macro exit
				li $v0, 10
				syscall	
.end_macro 
# ======================================================

main:			
	# store board address in $s0
	la $s0, board
	# set counter to 0
	li Counter, 0
				
	loop1:			
		# argument prepared for displayBoard
		add $a0, $s0, $zero
		# jump to displayBoard 'function'
		jal DisplayBoard		
	# displayBoard takes 1 argument: address of board, and has no return
		# store counter parity in $s6
		andi $s6, Counter, 1
				
	choice:			
		# arguments prepared for choice
		add $a0, $s0, $zero
		# if Counter is even AI turn, else player turn
		beqz $s6, AIChoice		
	# AIChoice takes 1 argument: address of board, and has 2 returns the address of the column and the address of the play, jumps to afterChoice at end
		# jump to playerChoice 'function'
		jal PlayerChoice		
	# PlayerChoice take 1 argument: address of board, and has 2 returns: the address of the column and the address of the play
				
	AfterChoice:	
		# address of the column is moved to $s1
		add $s1, $v0, $zero
		# address of the spot played is moved to $s2
		add $s2, $v1, $zero
		
#	partial code for check if choice is valid should be in AIChoice and PlayerChoice	
#		# store address for the column height in $s1
#		add $s1, $s0, $s3
#		# store value of Column height in $t0
#		lb $t0, 0($s1)
#		# if column is full choice is invalid and a new choice needs to be made
#		beq $t0, 7, invalidChoice		
#		# store address for the cell in $s2
#		sll $t1, $t0, 3
#		add $s2, $s1, $t1
		
		# store token value in cell
		li $t9, 'R'
		beqz $s6, Store
			addi $t9, $t9, 7
		Store:
		sb $t9, 0($s2)
		
		# increment column height value
		addi $t0, $t0, 1
		sb $t0, ($s1)
		
		add $a0, $s0, $zero
		add $a1, $s2, $zero
		
		# jump to winCheck 'function'
		jal WinCheck		# winCheck has 2 arguments: board address and play spot, and has 1 return: 1 for win, 0 for no win
		# if someone has won, $v0 is 1
		
		# jumps to gameEnd checks if game has been won
		bnez $v0, GameEnd
		
		# increment Counter
		addi Counter, Counter, 1
				
		# if all spaces filled game is a Tie
		beq Counter, 42, Tie
		
		# jump to beginning of loop
		j loop1
		
# ==================================
# print 'Invalid Choice: column is full' then jump to choice again
InvalidChoice:  
		li $v0, 4
		la $a0, InvalidChoiceMsg
		syscall
		j choice
# ==================================
# check who won
GameEnd:		
		li $v0, 4
		# if turn is even AI Won, else player won
		beqz $s6, AIWin
# =============
# print 'You Won! :D', then jump to exit call
PlayerWin:		
		la $a0, PlayerWinMsg
		syscall
		exit
# ===================================
# print 'You Lost :(', then jump to exit call
AIWin:			
		la $a0, AIWinMsg
		syscall
		exit
# ===================================
# print 'Game was a Tie :|', then jump to exit call
Tie:			
		la $a0, TieMsg
		li $v0, 4
		syscall
		exit
# =============

# .include 	fileForAIChoice				
# .include	fileForPlayerChoice
# .include 	fileForDisplayBoard
# .include 	fileForWinCheck

# ==========================================
# test code DELETE BEFORE TURN IN
AIChoice:		li $t7, 1
				add $v0, $s0, $t7
				lb $t0, ($v0)
				sll $t1, $t0, 3
				addi $t1, $t1, 8
				add $t1, $t1, $t7
				add $v1, $t1, $s0
				#la $v1, 0($t2)
				j AfterChoice

PlayerChoice:	li $t7, 5
				add $v0, $s0, $t7
				lb $t0, ($v0)
				sll $t1, $t0, 3
				addi $t1, $t1, 8
				add $t1, $t1, $t7
				add $v1, $t1, $s0
				#la $v1, 0($t1)
				jr $ra

DisplayBoard:	jr $ra

WinCheck:		add $v0, $s7, $zero
				jr $ra