# ==============================================================================
# Choice.asm:
#	Description:	'functions' to get the player/AI's choice for Connect 4 project
#	Author:		    notme4
#	Date:		    Mar. 28, 2022
#	Notes:		
# ==============================================================================
.data
# data segment for both Choice 'functions'

    .globl  AIChoice
    .globl  PlayerChoice

# ==============================================================================
# data segment for AIChoice
    PosPlays:       .byte   0,  1,  2,  3,  4,  5,  6
    
    OpenCols:       .byte   7
    # AI's choice of 

# ==============================================================================
.text
# text segment for AIChoice

    AIChoice:
    # get the AI's choice of column, and the actual location of the play
    # AIChoice takes 1 argument: address of Board; and has 2 returns: the address of the column and the address of the play
    
      # save $s0 and $ra to stack
      addi $sp, $sp, -8
      sw $s0, 4($sp)
      sw $ra, 0($sp)
		
        # set $s0 to board
        add $s0, $a0, $zero

	Rechoose:

        # get a random integer in range 0 to [#-of-open-columns] inclusive
        li $v0, 42
        lb $a1, OpenCols
        syscall
		
		#set $t6 to AI's choice of open column
		add $t6, $a0, $zero
        # set $t7 to AI's choice of actual column
        lb $t7, PosPlays($a0)
        # for example if AI chooses 4th open column and column 3 is full, then the AI actually* chooses column 5
        # * the check for column availability only happens if the AI chooses that column, so if the AI had not chosen
        #     column 3 after it was filled, the AI would choose column 4, even though the 4th open column is actually
        #     column 5

		# get next open location offset for that column
		add $v0, $s0, $t7
		lb $t1, ($v0)
		
        # if no more valid plays on the column (next open location offset is 0) play is invalid and the column needs to
        #     be deleted from available columns
        beqz $t1, InvalidPlay

		# get the address of the play and store in $v1
		add $t1, $t1, $t7
		add $v1, $t1, $s0

	  # fix $s0, and prepare to return
      lw $s0, 4($sp)
      lw $ra, 0($sp)
      addi $sp, $sp, 8

      # return
      jr $ra

    InvalidPlay:
    	# column stored in $v0 is full, and it needs to be deleted from the available columns
    	
        # decrement OpenCols
        lb $t0, OpenCols
        addi $t0, $t0, -1
        sb $t0, OpenCols

        PosPlaysLoop:
        # end loop if no more open columns
        bge $t6, $t0, Rechoose
        
            # move the column in spot + 1 spot into this spot
            lb $t3, PosPlays + 1 ($t6)
            sb $t3, PosPlays ($t6)
            
            # increment spot
            addi $t6, $t6, 1

        j PosPlaysLoop


# ==============================================================================
.data
# data segment for PlayerChoice

    Prompt:         .asciiz         "Enter a number between 0 and 6 \n"
    PlayArrows:          .asciiz         " 0 1 2 3 4 5 6 \n | | | | | | | \n v v v v v v v \n"

    TooSmallMsg:    .asciiz         "Error: input must be at least 0 \n"
    TooLargeMsg:    .asciiz         "Error: input must be at most 6 \n"
    ColFullMsg:     .asciiz         "Error: column is full \n"

.text
# macros for PlayerChoice ======================================================

    .macro errorMsg (%Label, %ReturnLabel) # ======================
    	# print error message at %label and return to %returnLabel
        # print error message
        li $v0, 4
        la $a0, %Label
        syscall

        # jump to GetPlayerChoice
        j %ReturnLabel
    .end_macro # ==================================================
    
# ==============================================================================
# text segment for PlayerChoice

    PlayerChoice:
    # get the Player's choice of column, and the actual location of the play
    # PlayerChoice take 1 argument: address of Board; and has 2 returns: the address of the column and the address of the play
    
      # save $s0 and $ra to stack
      addi $sp, $sp, -8
      sw $s0, 4($sp)
      sw $ra, 0($sp)
        
        # move address of board to $s0
        add $s0, $a0, $zero
		
		GetPlayerChoice:
            
            # print PlayArrows
            li $v0, 4
            la $a0, PlayArrows
            syscall
			
			# print board
	            # prepare for DisplayBoard
    	        add $a0, $s0, $zero
    	        # jump to DisplayBoard
        	    jal DisplayBoard

            # print Prompt
            li $v0, 4
            la $a0, Prompt
            syscall

            # get user input
            li $v0, 5
            syscall

            # move answer to $t0
            add $t0, $v0, $zero

        # if player choice is too low get a new input
        blt $t0, $zero, TooSmall
        
        # if player choice is too high get a new input
        li $t1, 6
        bgt $t0, $t1, TooLarge
            
            # get address of column and put in $v0
            add $v0, $t0, $s0
            
            # find out the offset to next empty cell in the column
            lb $t3, ($v0)

        # if column is filled (offset is 0), get a new input
        beqz $t3, ColFull

        # get address of play and store in $v1
        add $v1, $t3, $v0

      # fix $s0, and prepare to return
      lw $s0, 4($sp)
      lw $ra, 0($sp)
      addi $sp, $sp, 8

      # return
      jr $ra

# ======================================================================

    TooSmall:
        errorMsg (TooSmallMsg, GetPlayerChoice)

    TooLarge:
        errorMsg (TooLargeMsg, GetPlayerChoice)

    ColFull:
        errorMsg (ColFullMsg, GetPlayerChoice)

.include "DisplayBoard.asm"
