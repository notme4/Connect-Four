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
# check for win macro
.macro check (%counter, %next, %val)

    WinCheckLoop:
        # get value of the next in direction and put in $t1
        lb $t1, (%next)
    # if $t1 != $t2 (next spot has a different value to play spot) break out of loop
    bne $t0, $t1, AfterWinCheckLoop

        # increment counter
        addi %counter, %counter, 1
        # if counter == 4, game has been won
        beq %counter, $t6, GameEnd

        # load next spot
        addi %next, %next, %val
        
        # if looking at non-existant '7th' row, break out of loop
        addi $t3, $s0, 56
    bgt %next, $t3, AfterWinCheckLoop

        # if looking at non-existant '0th' row, break out of loop
        addi $t3, $s0, 8
    blt %next, $t3, AfterWinCheckLoop

    j WinCheckLoop
    
    AfterWinCheckLoop:
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

        # check \ direction
        li $t7, 0
        # set $t2 to address of play
        addi $t2, $s2, 0
        check ($t7, $t2, 7)
        # set $t2 to address of first spot in next direction
        addi $t2, $s2, -7
        check ($t7, $t2, -7)

        # check - direction
        li $t7, 0
        # set $t2 to address of play
        addi $t2, $s2, 0
        check ($t7, $t2, 1)
        # set $t2 to address of first spot in next direction
        addi $t2, $s2, -1
        check ($t7, $t2, -1)

        # check / direction
        li $t7, 0
        # set $t2 to address of play
        addi $t2, $s2, 0
        check ($t7, $t2, -9)
        # set $t2 to address of first spot in next direction
        addi $t2, $s2, 9
        check ($t7, $t2, 9)

        # check | direction
        li $t7, 0
        # set $t2 to address of play
        addi $t2, $s2, 0
        check ($t7, $t2, -8)
        # set $t2 to address of first spot in next direction
        addi $t2, $s2, 8
        check ($t7, $t2, 8)

        # if all spaces filled game is a Tie
		beq $s7, 42, Tie

      return (0)


# check who won
GameEnd:		
		li $v0, 4
		# if turn is odd AI Won, else player won
		bnez $s6, AIWin
		
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
