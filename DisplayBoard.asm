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
		addi $t0, $a0, 8

		# initiate end spot
		addi $t1, $a0, 56

		# set syscall choice to print char
		li $v0, 11

		# begin print loop
		displayLoop:
			# print out spacer between cols
			li $a0, '|'
			syscall

			# print out space
			lb $a0, 0($t0)
			syscall

			# increment counter
			addi $t0, $t0, 1

			# loop if line is not finished printing
			bne $a0, '\n', displayLoop
				# print out spacers between rows
				la $a0, BoardSplit
				li $v0, 4
				syscall
				
				# reset syscall choice to print char
				li $v0, 11
		# loop if board is not finished printing
		bne $t0, $t1, displayLoop
		
		# print new lines to seperate board
		li $a0, '\n'
		syscall
		syscall

		# return
		jr $ra
