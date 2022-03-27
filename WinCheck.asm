# ==============================================================================
# WinCheck.asm:
#	Description:	'function' to determine if someone has won the game
#	Author:		    Connor Funk
#`	Date:		    Mar. 26, 2022
#	Version:        0.0.1
#	Notes:		
# ==============================================================================
.data
    TieMsg:				.asciiz	 	"Game was a Tie :|"
	AIWinMsg:			.asciiz		"You lost :("
	PlayerWinMsg:		.asciiz		"You Won! :D"

    .globl WinCheck

# ==============================================================================
.text
# =======================================================
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
    li $v0, %returnVal

	# return
    jr $ra

.end_macro 
# ======================================================

    WinCheck:
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

        # store value of last play in $t0
        lb $t0, ($s2)
         # load win amount into $t6
        li $t6, 4

        # initiate counter
        li $t7, 0
        # set $t2 to address of play
        add $t2, $s2, $zero

        # upper left
        winCheckLoop1:
            # increment counter
            addi $t7, 1
            # if counter == 4, game has been won
            beq $t7, $t6, GameEnd
            
            # load next spot
            addi $t2, $t2, 7

            # if looking at non-existant '7th' row, break out of loop
            addi $t3, $s0, 56
            bgt $t2, $t3, afterLoop1

            lb $t1, ($t2)
        beq $t0, $t1, winCheckLoop1
        
        afterLoop1:

        # set $t2 to address of next spot
        addi $t2, $s2, -7

        # bottom right
        winCheckLoop2:
            # increment counter
            addi $t7, 1
            # if counter == 4, game has been won
            beq $t7, $t6, GameEnd
            
            # load next spot
            addi $t2, $t2, -7

            # if looking at non-existant '7th' row, break out of loop
            addi $t3, $s0, 8
            bgt $t2, $t3, afterLoop2

            lb $t1, ($t2)
        beq $t0, $t1, winCheckLoop2
        
        afterLoop2:

        # initiate counter
        li $t7, 0
        # set $t2 to address of play
        add $t2, $s2, $zero

        # left
        winCheckLoop3:
            # increment counter
            addi $t7, 1
            # if counter == 4, game has been won
            beq $t7, $t6, GameEnd
            
            # load next spot
            addi $t2, $t2, 1

            # if looking at non-existant '7th' row, break out of loop
            addi $t3, $s0, 56
            bgt $t2, $t3, afterLoop3

            lb $t1, ($t2)
        beq $t0, $t1, winCheckLoop3
        
        afterLoop3:

        # set $t2 to address of next spot
        addi $t2, $s2, -1

        # right
        winCheckLoop4:
            # increment counter
            addi $t7, 1
            # if counter == 4, game has been won
            beq $t7, $t6, GameEnd
            
            # load next spot
            addi $t2, $t2, -1

            # if looking at non-existant '7th' row, break out of loop
            addi $t3, $s0, 8
            bgt $t2, $t3, afterLoop4

            lb $t1, ($t2)
        beq $t0, $t1, winCheckLoop4
        
        afterLoop4:

        # initiate counter
        li $t7, 0
        # set $t2 to address of play
        add $t2, $s2, $zero

        # bottom left
        winCheckLoop5:
            # increment counter
            addi $t7, 1
            # if counter == 4, game has been won
            beq $t7, $t6, GameEnd
            
            # load next spot
            addi $t2, $t2, 9

            # if looking at non-existant '7th' row, break out of loop
            addi $t3, $s0, 56
            bgt $t2, $t3, afterLoop5

            lb $t1, ($t2)
        beq $t0, $t1, winCheckLoop5
        
        afterLoop5:

        # set $t2 to address of next spot
        addi $t2, $s2, -9

        # upper right
        winCheckLoop6:
            # increment counter
            addi $t7, 1
            # if counter == 4, game has been won
            beq $t7, $t6, GameEnd
            
            # load next spot
            addi $t2, $t2, -9

            # if looking at non-existant '7th' row, break out of loop
            addi $t3, $s0, 8
            bgt $t2, $t3, afterLoop6

            lb $t1, ($t2)
        beq $t0, $t1, winCheckLoop6
        
        afterLoop6:

        # initiate counter
        li $t7, 0
        # set $t2 to address of play
        add $t2, $s2, $zero

        # bottom
        winCheckLoop7:
            # increment counter
            addi $t7, 1
            # if counter == 4, game has been won
            beq $t7, $t6, GameEnd
            
            # load next spot
            addi $t2, $t2, -8

            # if looking at non-existant '7th' row, break out of loop
            addi $t3, $s0, 8
            bgt $t2, $t3, afterLoop7

            lb $t1, ($t2)
        beq $t0, $t1, winCheckLoop7
        
        afterLoop7:

        # if all spaces filled game is a Tie
		beq $s7, 42, Tie

      return (0)


# check who won
GameEnd:		
		li $v0, 4
		# if turn is even AI Won, else player won
		beqz $s6, AIWin
		
# print 'You Won! :D', then exit
PlayerWin:		
		la $a0, PlayerWinMsg
		syscall
		return (1)
# ===================================
# print 'You Lost :(', then exit
AIWin:			
		la $a0, AIWinMsg
		syscall
		return (1)
# ===================================
# print 'Game was a Tie :|', then exit
Tie:			
		la $a0, TieMsg
		li $v0, 4
		syscall
		return (1)
# =============