# ==============================================================================
# DisplayBoard.asm:
#	Description:	'function' to display board for Connect 4 project
#	Author:		    notme4
#	Date:		    Mar. 28, 2022
#	Notes:		
# ==============================================================================
.data
	BoardSplit:			.asciiz		"|-+-+-+-+-+-+-|\n"

    .globl  DisplayBoard

.text
    DisplayBoard:	
	# print out the Board
	# DisplayBoard takes 1 argument: address of Board, and has no return
	
		# set $t0 to the start of the board
		addi $t0, $a0, 8

		# initiate end spot
		addi $t1, $a0, 56

		# set syscall choice to print char
		li $v0, 11

		# begin printing loop
		DisplayLoop:
			# print out column seperator
			li $a0, '|'
			syscall

			# print out value of cell
			lb $a0, 0($t0)
			syscall

			# increment counter
			addi $t0, $t0, 1

			# loop if line is not finished printing
			bne $a0, '\n', DisplayLoop
			
				# print out row seperator
				la $a0, BoardSplit
				li $v0, 4
				syscall
				
				# reset syscall choice to print char
				li $v0, 11
				
		# loop if board is not finished printing
		bne $t0, $t1, DisplayLoop
		
		# print new lines to seperate board
		li $a0, '\n'
		syscall
		syscall

		# return
		jr $ra
