# ==============================================================================
# Project: Connect 4
# 	Description:    Connect 4 game against an AI
# 	Author(s):	    Connor Funk
#	Date:		    
#	Version:	    0.0
# ==============================================================================
# Choice.asm:
#	Description:	'function' to get the player/AI's choice for Connect 4 project
#	Author:		    Connor Funk
#`	Date:		    Mar. 25, 2022
#	Version:        0.0.1
#	Notes:		
# ==============================================================================
.data
# data segment for both Choice 'functions'

    .globl  AIChoice
    .globl  PlayerChoice

# ==============================================================================
# data segment for AIChoice


.text
    AIChoice:


# ==============================================================================
.data
# data segment for PlayerChoice

    prompt:         .asciiz         "Enter a number between 0 and 6 \n"
    spots:          .asciiz         " 0 1 2 3 4 5 6 \n | | | | | | | \n v v v v v v v \n"

    tooSmallMsg:    .asciiz         "Error: input must be at least 0"
    tooLargeMsg:    .asciiz         "Error: input must be at most 6"
    colFullMsg:     .asciiz         "Error: column is full"

.text
    PlayerChoice:
        # save $s0 and $ra to stack
        addi $sp, -8
        sw $s0, 8($sp)
        sw $ra, 4($sp)
        
        # move address of board to $s0
        add $s0, $a0, $zero
    
        getPlayerChoice:
            # print spots
            li $v0, 4
            la $a0, spots
            syscall

            # prepare for DisplayBoard
            add $a0, $s0, $zero
            # jump to DisplayBoard
            jal DisplayBoard

            # print prompt
            li $v0, 4
            la $a0, prompt
            syscall

            # get user input
            li $v0, 5
            syscall

            # move answer to $t0
            add $t0, $v0, $zero

        # if player choice is too low get a new input
        blt $t0, $zero, getPlayerChoice
        
        # if player choice is too high get a new input
        li $t1, 6
        bgt $t0, $t1, getPlayerChoice
            
            # get address of col and put in $v0
            add $t2, $t0, $s0
            
            # find out how many spaces are left in the col
            lb $t3, ($t2)

        # col is filled get a new input
        beq $t3, $zero, getPlayerChoice

        # get address of play and store in $v0
        add $v0, $t3, $t2

        # fix $s0, and prepare to return
        addi $sp, $sp, 8
        lw $s0, -8($sp)
        lw $ra, -4($sp)

        # return
        jr $ra

    .macro errorMsg (%label) # ==============================
        # print error message
        li $v0, 4
        la $a0, %label
        syscall

        # jump to getPlayerChoice
        j getPlayerChoice
    .end_macro # ============================================

    tooSmall:
        errorMsg (tooSmallMsg)

    tooLarge:
        errorMsg (tooLargeMsg)

    colFull:
        errorMsg (colFullMsg)