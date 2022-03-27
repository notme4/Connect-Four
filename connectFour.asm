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

	
	Board:				.asciiz		"0000000\0       \n       \n       \n       \n       \n       \n\n"
	# Board is an array of 56 bytes, each row of the connect four Board is 7 bytes with a \n in the 8th for ease of printing
	#		the 0th row are pointers to the next empty locations (relative to it's location) in each column (ascii '0' just happened to be the right number)
	
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
	
	loop1:			
		
		# store counter parity in $s6
		andi $s6, Counter, 1
		
		# jump to makePlay to set $ra
		j makePlay
	choice:
		# arguments prepared for choice
		add $a0, $s0, $zero
		# if Counter is even AI turn, else player turn
		bnez $s6, AIChoice
	# AIChoice takes 1 argument: address of Board; and has 2 returns: the address of the column and the address of the play
		# jump to playerChoice 'function'
		j PlayerChoice
	# PlayerChoice take 1 argument: address of Board; and has 2 returns: the address of the column and the address of the play
		
	makePlay:
		# set $ra for after the choice
		jal choice

		# address of the column is moved to $s1
		add $s1, $v0, $zero
		# address of the play is moved to $s2
		add $s2, $v1, $zero


		# arguments prepared for addPiece
		add $a0, $s0, $zero
		add $a1, $s1, $zero

	#	jal addPiece
	# addPiece takes 2 arguments: address of board, and address of play; and has 0 returns: updates board

		# address of the spot played is moved to $s2
		add $s2, $v1, $zero
		
	# TO BE MOVED to addPiece ==================
		# store token value in cell
		li $t9, 'O'
		beqz $s6, Store
			addi $t9, $t9, 9
		Store:
		sb $t9, 0($s2)
		# decrement column height value
		lb $t1, ($s1)
		addi $t0, $t1, -8
		sb $t0, ($s1)
	# END TO BE MOVED to addPiece ==============
		

# can this be deleted now? ===================================================
		# argument prepared for displayBoard
		add $a0, $s0, $zero
		# jump to displayBoard 'function'
		jal DisplayBoard		
	# displayBoard takes 1 argument: address of Board, and has no return
# ============================================================================
		
		# arguments prepared for WinCheck
		add $a0, $s0, $zero
		add $a1, $s2, $zero
		# jump to winCheck 'function'
		jal WinCheck		# winCheck has 3 arguments: Board address, play spot, and turn #; and has 1 return: 1 for win, 0 for no win
		# if someone has won, $v0 is 1
		
		# jumps to gameEnd checks if game has been won
		bnez $v0, GameOver
		
		# increment Counter
		addi Counter, Counter, 1
		
		# jump to beginning of loop
		j loop1
		
# ==================================

.include "Choice.asm"
.include "WinCheck.asm"
# .include fileForAddPiece
# ==========================================

GameOver:
	exit
