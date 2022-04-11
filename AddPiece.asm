# ==============================================================================
# AddPiece.asm:
#	Purpose:	'function' to add a piece to the board for Connect 4 project
#	Author:		notme4 
#	Date:		Mar. 28, 2022
#	Notes:		
# ==============================================================================
.data
# data segment of AddPiece 'function'

	.globl AddPiece
	
.text
# text segment of AddPiece 'function'
	AddPiece:
	# add a piece to the board
	# addPiece takes 3 arguments: address of column, address of play, and turn parity; and has 0 returns; updates board
	
	  # save $s#'s and $ra to stack
      addi $sp, $sp, -16
      sw $s6, 12($sp)
      sw $s2, 8($sp)
      sw $s1, 4($sp)
      sw $ra, 0($sp)
      
        # store address of column in $s1
        add $s1, $a0, $zero
      	# store address of play in $s2
      	add $s2, $a1, $zero
      	#store turn parity in $s6
      	add $s6, $a2, $zero
      	
		# get token value
		li $t9, 'o'
		beqz $s6, Store
			# add add to make token value 'X'
			li $t9, 215
			
		Store:
		# store token value in cell
		sb $t9, 0($s2)
		
		# decrement column height value
		lb $t1, ($s1)
		addi $t0, $t1, -8
		sb $t0, ($s1)
	
	  # fix $s#'s for return
      lw $s6, 12($sp)
      lw $s2, 8($sp)
      lw $s1, 4($sp)
      lw $ra, 0,($sp)
      addi $sp, $sp, 16

	# return
    jr $ra
