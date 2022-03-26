# ==============================================================================
# Project: Connect 4
# 	Description:    Connect 4 game against an AI
# 	Author(s):	    Connor Funk
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
		# set $t0 to the start of the board
		addi $t0, $a0, 7

		# initiate counter
		add $t1, $zero, $zero

		# set syscall choice to print char
		li $v0, 11

		# begin print loop
		loop2:
			# print out spacer between cols
			add $t0, $t0, 1
			li $a0, '|'
			syscall

			# print out space
			lb $a0, 0($t0)
			syscall

			# increment counter
			addi $t1, $t1, 1

			# loop if line is not finished printing
			bne $a0, '\n', loop2
				# print out spacers between rows
				la $a0, BoardSplit
				li $v0, 4
				syscall
				
				# reset syscall choice to print char
				li $v0, 11
		# loop if board is not finished printing
		bne $t1, 48, loop2
		
		# print new lines to seperate board
		li $a0, '\n'
		syscall
		syscall

		# return
		jr $ra