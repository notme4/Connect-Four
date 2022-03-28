# ==============================================================================
# connectFour.asm:
#	Purpose:	main 'function' for Connect 4 project
#	Author:		notme4 
#`	Date:		Mar. 28, 2022
#	Notes:		
# ==============================================================================
.data

	
	Board:				.asciiz		"0000000\0       \n       \n       \n       \n       \n       \n\n"
	# Board is an array of 56 bytes, each row of the connect four Board is 7 bytes with a '\n' in the 8th byte for ease of printing
	# 	the bytes in the 0th row show the byte offset (from itself) to the next empty spot in it's column (0 just happened to be the 
	# ascii character with the right number) 
	
	.globl Main
	.globl MakePlay
	
	
.text
# =======================================================
# exit Program macro
.macro exit
				li $v0, 10
				syscall	
.end_macro 
# ======================================================

Main:
	# main function for Connect-Four
	
	# store Board address in $s0
	la $s0, Board
	# set turn counter to 0
	li $s7, 0
	
	GameplayLoop:
		
		# store turn counter parity in $s6
		# 0 means player 1's turn
		# 1 means player 2's turn (AI)
		andi $s6, $s7, 1
		
		# jump to MakePlay to set $ra to return after the Choice
		j MakePlay
	Choice:
		# arguments prepared for Choice
		add $a0, $s0, $zero
		# if turn counter is odd Player 1's turn, else player 2's (AI's) turn
		beqz $s6, PlayerChoice
			j AIChoice
		
	MakePlay:
		# set $ra for after the Choice
		jal Choice

		# the choice of column and play location are returned in $v0 and $v1 respectively
		
		# address of the column is moved to $s1
		add $s1, $v0, $zero
		# address of the play is moved to $s2
		add $s2, $v1, $zero


		# arguments prepared for addPiece
		add $a0, $s0, $zero
		add $a1, $s1, $zero

	#	jal addPiece
	# addPiece takes 2 arguments: address of board, and address of play; and has 0 returns: updates board
		
	# TO BE MOVED to addPiece ==================
		# get token value
		li $t9, 'O'
		beqz $s6, Store
			# add add to make token value 'X'
			addi $t9, $t9, 9
			
		Store:
		# store token value in cell
		sb $t9, 0($s2)
		
		# decrement column height value
		lb $t1, ($s1)
		addi $t0, $t1, -8
		sb $t0, ($s1)
	# END TO BE MOVED to addPiece ==============
		
		# argument prepared for displayBoard
		add $a0, $s0, $zero
		# jump to displayBoard 'function'
		jal DisplayBoard		
		
		
		# arguments prepared for WinCheck
		add $a0, $s0, $zero
		add $a1, $s2, $zero
		add $a2, $s7, $zero
		# jump to winCheck 'function'
		jal WinCheck
		
		# if someone has won, $v0 is not 0
		bnez $v0, GameOver
		
		# increment turn counter
		addi $s7, $s7, 1
		
		# jump to beginning of GameplayLoop
		j GameplayLoop
		
# ==================================

.include "Choice.asm"
.include "WinCheck.asm"
# .include fileForAddPiece
# ==========================================

GameOver:
	exit
