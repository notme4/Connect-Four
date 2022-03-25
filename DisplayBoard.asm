# ==============================================================================
# Project: Connect 4
# 	Description:    Connect 4 game against an AI
# 	Authors:	    Connor Funk
#	Date:		    
#	Version:	    0.0
# ==============================================================================
# displayBoard.asm:
#	Description:	'function' to display board for Connect 4 project
#	Author:		    Connor Funk
#`	Date:		    Mar. 25, 2022
#	Version:        0.0.1
#	Notes:		
# ==============================================================================
.data
	BoardSplit:			.asciiz		"|-+-+-+-+-+-+-|\n"

    .globl  DisplayBoard

.text
    DisplayBoard:	
			# print out the Board
			addi $t0, $a0, 7
			add $t1, $zero, $zero
			li $v0, 11
		loop2:
			add $t0, $t0, 1
			li $a0, '|'
			syscall
			lb $a0, 0($t0)
			syscall
			addi $t1, $t1, 1
			bne $a0, '\n', loop2
				la $a0, BoardSplit
				li $v0, 4
				syscall
				li $v0, 11
			bne $t1, 48, loop2
			
			li $a0, '\n'
			syscall
			syscall
			jr $ra