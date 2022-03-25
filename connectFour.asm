# ==============================================================================
# Project: Connect 4
# 	Purpose:	Connect 4 game against an AI
# 	Author(s):	Connor Funk
#	Date:		
#	Version:	0.0
# ==============================================================================
# connectFour.asm:
#	Purpose:	main 'function' for Connect 4 project
#	Author:		Connor Funk
#`	Date:		Mar. 20, 2022
#	Version:	0.0.3
#	Notes:		grouped unnecessary elements for later deletion
# 				changed Board data structure for easier use
# ==============================================================================
.data

	
	Board:				.asciiz		"0000000\00000000\n0000000\n0000000\n0000000\n0000000\n0000000\n\n"
	# Board is an array of 56 bytes, each row of the connect four Board is 7 bytes with a \n in the 8th for ease of printing
	#		the 0th row are pointers to the next empty locations (relative to it's location) in each column (ascii '0' just happened to be the right number)
	TieMsg:				.asciiz	 	"Game was a Tie :|"
	AIWinMsg:			.asciiz		"You lost :("
	PlayerWinMsg:		.asciiz		"You Won! :D"
	
	.globl main
	.globl makePlay
	.eqv Counter $s7
	
.text
# =======================================================
# exit Program macro
.macro exit
				li $v0, 10
				syscall	
.end_macro 
# ======================================================

main:			
	# store Board address in $s0
	la $s0, Board
	# set counter to 0
	li Counter, 0
	# argument prepared for displayBoard
	add $a0, $s0, $zero
	# jump to displayBoard 'function'
	jal DisplayBoard		
	# displayBoard takes 1 argument: address of Board, and has no return	
	
	loop1:			
		
		# store counter parity in $s6
		andi $s6, Counter, 1
				
	choice:			
		# arguments prepared for choice
		add $a0, $s0, $zero
		# if Counter is even AI turn, else player turn
		beqz $s6, AIChoice		
	# AIChoice takes 1 argument: address of Board, and has 1 return the address of the column, jumps to makePlay at end
		# jump to playerChoice 'function'
		jal PlayerChoice		
	# PlayerChoice take 1 argument: address of Board, and has 1 returns: the address of the column
				
	makePlay:

		# address of the column is moved to $s1
		add $s1, $v0, $zero

		# arguments prepared for addPiece
		add $a0, $s0, $zero
		add $a1, $s1, $zero

		jal addPiece
	# addPiece takes 2 arguments: address of board, and address of column; and has 1 return address of play

		# address of the spot played is moved to $s2
		add $s2, $v1, $zero
		
	# TO BE MOVED to addPiece ==================
		# store token value in cell
		li $t9, 'R'
		beqz $s6, Store
			addi $t9, $t9, 7
		Store:
		sb $t9, 0($s2)
	# END TO BE MOVED to addPiece ==============
		
		# decrement column height value
		addi $t0, $t1, -9	# TODO: why is it 9 and not 8?
		sb $t0, ($s1)
		
		# argument prepared for displayBoard
		add $a0, $s0, $zero
		# jump to displayBoard 'function'
		jal DisplayBoard		
	# displayBoard takes 1 argument: address of Board, and has no return
		
		
		add $a0, $s0, $zero
		add $a1, $s2, $zero
		# jump to winCheck 'function'
		jal WinCheck		# winCheck has 2 arguments: Board address and play spot, and has 1 return: 1 for win, 0 for no win
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
# check who won
GameEnd:		
		li $v0, 4
		# if turn is even AI Won, else player won
		beqz $s6, AIWin
		
# print 'You Won! :D', then exit
PlayerWin:		
		la $a0, PlayerWinMsg
		syscall
		exit
# ===================================
# print 'You Lost :(', then exit
AIWin:			
		la $a0, AIWinMsg
		syscall
		exit
# ===================================
# print 'Game was a Tie :|', then exit
Tie:			
		la $a0, TieMsg
		li $v0, 4
		syscall
		exit
# =============

# .include fileForAIChoice
# .include fileForPlayerChoice
.include DisplayBoard
# .include fileForWinCheck

# ==========================================
AIChoice:		
				# AI "Choice"
				li $t7, 1
				
				# get next open location in that column
				add $v0, $s0, $t7
				lb $t1, ($v0)
				
				# get the address of the play
				add $t1, $t1, $t7
				add $v1, $t1, $s0

				j makePlay

PlayerChoice:	
				# Player "Choice"
				li $t7, 5
				
				# get the next open location in that column
				add $v0, $s0, $t7
				lb $t1, ($v0)
				
				# get the address of the play
				add $t1, $t1, $t7
				add $v1, $t1, $s0

				jr $ra

WinCheck:		
				add $v0, $s6, $zero
				jr $ra
				
#	partial code for check if choice is valid should be in AIChoice and PlayerChoice
#		InvalidChoiceMsg:	.asciiz		"Invalid Choice: column is full"
#		# ==================================	
#		# store address for the column height in $s1
#		add $s1, $s0, $s3
#		# store value of Column height in $t0
#		lb $t0, 0($s1)
#		# if column is full choice is invalid and a new choice needs to be made
#		beq $t0, 7, invalidChoice		
#		# store address for the cell in $s2
#		sll $t1, $t0, 3
#		add $s2, $s1, $t1
#		# ==================================
#	# print 'Invalid Choice: column is full' then jump to choice again
#	InvalidChoice:  
#		li $v0, 4
#		la $a0, InvalidChoiceMsg
#		syscall
#		j choice
