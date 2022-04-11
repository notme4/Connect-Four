# ==============================================================================
# WinCheck.asm:
#	Description:	'function' to determine if someone has won the game
#	Author:		    notme4
#	Date:		    Mar. 28, 2022
#	Notes:		
# ==============================================================================
.data
    TieMsg:				.asciiz	 	"Game was a Tie :|"
	AIWinMsg:			.asciiz		"You lost :("
	PlayerWinMsg:		.asciiz		"You Won! :D"

    .globl WinCheck

# ==============================================================================
.text
# macros for WinCheck

# exit Program macro
.macro return (%returnVal)
    # fix $s#'s
    lw $s7, 16($sp)
    lw $s6, 12($sp)
    lw $s2, 8($sp)
    lw $s0, 4($sp)
    
    # prepare to return
    lw $ra, 0($sp)
    addi $sp, $sp, 20
    add $v0, %returnVal, $zero

	# return
    jr $ra

.end_macro 
# ===========================================
# check for win macro
.macro check (%counter, %next, %directionVal)

    WinCheckLoop:
        # get value of the next in direction and put in $t1
        lb $t1, (%next)
    # if $t1 != $t0 (next spot has a different value to play spot) break out of loop
    bne $t0, $t1, AfterWinCheckLoop

        # increment counter
        addi %counter, %counter, 1
        # if counter == 4, game has been won
        addi $t4, $zero, %directionVal
        beq %counter, $t6, GameEnd

        # load next spot
        addi %next, %next, %directionVal
        
        # if looking at non-existant '7th' row, break out of loop
        addi $t3, $s0, 56
    bgt %next, $t3, AfterWinCheckLoop

        # if looking at non-existant '0th' row, break out of loop
        addi $t3, $s0, 8
    blt %next, $t3, AfterWinCheckLoop

    j WinCheckLoop
    
    AfterWinCheckLoop:
.end_macro 
# ===========================================
# check for win macro
.macro replace (%replaceVal, %directionVal)
		add $t2, $s2, $zero
    ReplaceLoop:
        # get value of the next in direction and put in $t1
        add $t2, $t2, %directionVal
        lb $t1, ($t2)
    # if $t1 != $t0 (next spot has a different value to play spot) break out of loop
    bne $t0, $t1, AfterReplaceLoop
        
        # if looking at non-existant '7th' row, break out of loop
        addi $t3, $s0, 56
    bgt $t2, $t3, AfterReplaceLoop

        # if looking at non-existant '0th' row, break out of loop
        addi $t3, $s0, 8
    blt $t2, $t3, AfterReplaceLoop
		
		sb %replaceVal ($t2)
    j ReplaceLoop
    
    AfterReplaceLoop:
.end_macro 
# =================================================================================
# text segment

    WinCheck:
    # check if the game has been won, and return the direction-Value if so, or 0 if not
    # WinCheck has 3 arguments: Board address, play spot, and turn #; and has 1 return: directionVal or 0, depending on if a win occured
    
      # save $s#'s and $ra to stack
      addi $sp, $sp, -20
      sw $s7, 16($sp)
      sw $s6, 12($sp)
      sw $s2, 8($sp)
      sw $s0, 4($sp)
      sw $ra, 0($sp)

        # store arguments
            # store board in $s0
            add $s0, $a0, $zero
            # store play in $s2
            add $s2, $a1, $zero
            # store counter in $s7
            add $s7, $a2, $zero
            # store turn parity in $s6
            andi $s6, $s7, 1

        # store value of cell at last play in $t0
        lb $t0, ($s2)
         # load win amount into $t6
        li $t6, 4

        # check \ direction
        # the cell to the top left of a cell is 7 bytes more, and the cell to the bottom right is 7 bytes less
        # if $t7 reaches 4 during those checks the game has been won
        	# set counter
        	li $t7, 0
        	# set $t2 to address of play
        	addi $t2, $s2, 0
        	check ($t7, $t2, 7)
        	# set $t2 to address of first spot in next direction
        	addi $t2, $s2, -7
        	check ($t7, $t2, -7)

        # check - direction
        # the cell to the left of a cell is 1 byte less, and the cell to the bottom right is 1 byte more
        # if $t7 reaches 4 during those checks the game has been won
        	# reset counter
        	li $t7, 0
        	# set $t2 to address of play
        	addi $t2, $s2, 0
        	check ($t7, $t2, -1)
        	# set $t2 to address of first spot in next direction
        	addi $t2, $s2, 1
        	check ($t7, $t2, 1)

        # check / direction
        # the cell to the bottom left of a cell is 9 bytes less, and the cell to the bottom right is 9 bytes more
        # if $t7 reaches 4 during those checks the game has been won
        	# reset counter
        	li $t7, 0
        	# set $t2 to address of play
        	addi $t2, $s2, 0
        	check ($t7, $t2, -9)
        	# set $t2 to address of first spot in next direction
        	addi $t2, $s2, 9
        	check ($t7, $t2, 9)

        # check | direction
        # the cell to the bottom of a cell is 8 bytes less, and the cell to top is 8 bytes more
        # if $t7 reaches 4 during those checks the game has been won
        # checking the cell to the top shouldn't be necessary, but it doesn't work without it
        	# reset counter
        	li $t7, 0
        	# set $t2 to address of play
        	addi $t2, $s2, 0
        	check ($t7, $t2, -8)
        	# set $t2 to address of first spot in next direction
        	addi $t2, $s2, 8
        	check ($t7, $t2, 8)

        # if all spaces filled game is a Tie
		beq $s7, 41, Tie

      return ($zero)


# check who won
GameEnd:		
		# if turn is odd AI Won, else player won
		bnez $s6, AIWin
		
# print 'You Won! :D', then exit
PlayerWin:	
		li $t7, 'Ø'
		replace ($t7, $t4)
		sub $t4, $zero, $t4
		replace ($t7, $t4)
		sb $t7, ($s2)
		
		#break
		
		jal DisplayBoard
		
		li $v0, 4
		la $a0, PlayerWinMsg
		syscall
		
		return ($t4)
# ===================================
# print 'You Lost :(', then exit
AIWin:	
		li $t7, '¤'
		replace ($t7, $t4)
		sub $t4, $zero, $t4
		replace ($t7, $t4)
		sb $t7, ($s2)
		
		jal DisplayBoard
		
		li $v0, 4
		la $a0, AIWinMsg
		syscall
		return ($t4)
# ===================================
# print 'Game was a Tie :|', then exit
Tie:			
		la $a0, TieMsg
		li $v0, 4
		syscall
		li $t4, 57
		return ($t4)
# =============

