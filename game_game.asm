22		.data
grid:   	.space 1000 #space allocation for main grid
grid2:  	.space  1000 #space allocation for the temp grid for holding bombs places
text1: 		.asciiz "\nEnter the row value:\n"
text2: 		.asciiz "\nEnter the column value:\n"   	
dot :		.asciiz "."
o: 		.asciiz "O"
buffer:		.space 40 #buffer for taking input from user
newline_char: 	.byte 10  #newLine char for the output represantation of the grid


		.text	


main:  		
		li $v0,4
		la $a0,text1
		syscall #printing the "enter the row" string 
		addi $s0,$zero,0 #counter or the timer
		li $v0,5 #reading the row value
		syscall
		addi $s1,$v0,0 # s1 = row 
		
		li $v0,4
		la $a0,text2
		syscall #printing the "enter the column" string 
		li $v0,5 #reading the column value
		syscall
		addi $s2,$v0,0 # s2 = column 		
		la $s3,grid # s3 = &grid  
		mul $t1, $s1, $s2 # determining grid size
		addi $s4 ,$t1,0 # s4 = size_of_grid (row*column)
		
		addi $t2,$zero,0 # t2 = 0 
		addi $t1,$s4,0 # t1 = s4 
		addi $t0 ,$s2,0 # t0 = columnTemp
		la $s5,0($s3) #   s5 = &grid[0][0]

MainLoop:	
		beq $s0,5,Exit # if(counter==0) then exit
		beq $s0,0,call_initial_state # if(counter  == 0) then initial_state
		beq $s0,1,call_first_state   # if(counter  == 1) then call_first_state
		beq $s0,2,call_second_state  # if(counter  == 2) then call_second_state
		beq $s0,3,call_last_state    # if(counter  == 3) then call_last_state
		addi $s0,$s0,1  # i++ 
		j MainLoop 	
call_initial_state:
		addi $a0,$s4,0 # storing grid size as param
		jal initial_state # jump and link to inital state where we are taking the input
		addi $s0,$s0,1 # increment i++
		j MainLoop # return to main loop	
call_first_state: 
		addi $a0,$s4,0 # storing grid size as param
		addi $a1,$s2,0 # storing column size as param	
		jal first_state # jump and link to inital state where we analyzing input and stroring the bomb places into a temp array
		addi $s0,$s0,1 # increment i++
		j MainLoop    # return to main loop
call_second_state:
		addi $a0,$s4,0 # storing grid size as param
		addi $a1,$s2,0 # storing column size as param
		jal second_state # jump and link to a procedure that provides filling all indexes with bomb
		addi $s0,$s0,1 # increment i++
		j MainLoop     # return to main loop
call_last_state:
		addi $a0,$s4,0 # storing grid size as param
		addi $a1,$s2,0 # storing column size as param
		jal last_state # jump and link to to procedure that detonates bombs as the instructions says
		addi $s0,$s0,1 #icnrement i++
		j MainLoop     # return to main loop	
Exit:		
		li $v0,10 # terminating the program
		syscall
##############################
initial_state: #initialzing grid with input values 
		addi $t1,$a0,0 # grid size
Loop:		
		beq $t1,$t2,Loop_End  # t2 is counter and t1 is the last index && if they are equal end the loop
		li $v0,12
		syscall # char sets to v0
		sb $v0,0($s3) # grid[t1][t2] = v0 
		addi $s3,$s3,1 #increment the address by one because we are working on with chars
		addi $t2,$t2,1 # increment the counter
		j Loop	
Loop_End:
		lb $a0, newline_char # printing the new line for indicating you are in new line
    		li $v0, 11  
    		syscall	
		jr $ra #returning the address of where we came from here 

### printing first state and memorizing it's bomb places in another array (grid2)
first_state:		
		addi $s4,$a0,0 # grid size
		addi $s2,$a1,0 #col size
loop1Header:	#setting the index value as 0 also printing new line to make things clear
		addi $t1,$zero,0
		lb $a0, newline_char
    		li $v0, 11  
    		syscall		

Loop1:		#outer loop
		beq $t1, $s4,end1 # if( i= gridSize ) then end1
		li $t0 ,0  # col_counter = 0
Loop2:
		beq $t0, $s2,end2 # if ( colCounter == colSize ) then go end2  
		li $v0,11	
		lb $a0,grid($t1) # loading byte inside that grid index and storing it in $a0 for printing
		sb $a0,grid2($t1) # stroring $a0 contents to grid2 to memorize where bombs are
		lb $a0,grid($t1) 
    		li $v0, 11  
    		syscall # printing the grid
    		
		addi $t0,$t0,1 # increment col counter	
		addi $t1,$t1,1 # i = i + 1;
end:		
		j Loop2 # jump again loop2
end2:
		lb $a0, newline_char
    		li $v0, 11  
    		syscall # printing new line on each line (after the each inner loop process are finished) 
		j Loop1

end1:		jr $ra # returning to where the procedure called

#########################################################################

second_state:	#just filling with grid2 bombs with
		addi $s4,$a0,0 # grid size
		addi $s2,$a1,0 #col size
Loop_Header_Second_State:	
		addi $t1,$zero,0 #setting index counter to 0
		lb $a0, newline_char
    		li $v0, 11  
    		syscall	#printing newLine for clearity
Loop_Head_Second:		
		beq $t1, $s4,Loop_Head_End_Second # if( i= gridSize ) then end1
		li $t0 ,0  # col_counter = 0
Loop_Inner_Start_Second:
		beq $t0, $s2,Loop_Inner_End_Second # if ( colCounter == colSize ) then Loop_inner_end 
		la  $t3,o # load the addres of asci char of  'O'
		lb $t3,0($t3) #then store the contents of 'O' into $t3
		sb $t3,grid2($t1) # then fill the that index of grid2 with $t3 content
		li $v0,11	
		lb $a0,grid2($t1)
		syscall #at the end print the grid line
		addi $t0,$t0,1 # increment col counter	
		addi $t1,$t1,1 # i = i + 1;
		
		j Loop_Inner_Start_Second
		
Loop_Inner_End_Second:
		lb $a0, newline_char
    		li $v0, 11  
    		syscall # printing the newLine
		j Loop_Head_Second #jumping to the outer array loop

Loop_Head_End_Second:
		jr $ra	# jumping the the procedure's calling address
	
###########################################
#show the exploaded areas	
last_state:	
		addi $s4,$a0,0 # grid size
		addi $s2,$a1,0 #col size			
Print_Second_Array:	
		addi $t1,$zero,0 # setting the index = 0

Print_Second_Array_Outer:	
	
		beq $t1, $s4,Print_Outer_Array_End # if( i = gridSize ) then Print_Outer_Array_End
		li $t0 ,0  # col_counter = 0
Print_Second_Array_Outer_Inner:

		beq $t0, $s2,Print_Inner_Array_End # if ( colCounter == colSize ) then go Print_Inner_Array_End:
		lb $t2,grid($t1) # load content of the grid(index) to the $t2
		la $t3,o	# then set $t3 content to the 'O' character addres
		lb $t3,0($t3)  # then store the first of $t3 content into $t3 again
		beq $t3,$t2,setExplosion # compare the grid(index) content with the 'O' 
					 # char if they are equal then
					 # go jump to set explosion
	
incrementer:	
		addi $t0,$t0,1 # increment col counter	
		addi $t1,$t1,1 # i = i + 1;
				
		j Print_Second_Array_Outer_Inner # jump to inner loop
		
Print_Inner_Array_End:

		j Print_Second_Array_Outer      # jump to outer loop

Print_Outer_Array_End:
TestHeader:     #printing the resulting array	
		addi $t1,$zero,0
		lb $a0, newline_char
    		li $v0, 11  
    		syscall	#printing newLine

Loop1Test:		
		beq $t1, $s4,end1Test # if( i= gridSize ) then end2Test
		li $t0 ,0  # col_counter = 0
Loop2Test:
		beq $t0, $s2,end2Test # if ( colCounter == colSize ) then go end2  
		li $v0,11	
		lb $a0,grid2($t1)
		syscall #printing the char
		addi $t0,$t0,1 # increment col counter	
		addi $t1,$t1,1 # i = i + 1;
endTest:		
		j Loop2Test #jump head of inner loop
end2Test:
		lb $a0, newline_char
    		li $v0, 11  
    		syscall #printing newLine
		j Loop1Test #jump to outer loop

end1Test:	jr $ra # return where you have been called
		
# detonating the bombs according to rules
setExplosion:	
		la $t3,dot # storing '.' value address into $t3
		lb $t3,0($t3) # and getting it's value into $t3 again
		la $t4,o      # storing 'O' value address into $t4
		lb $t4,0($t4) # and getting it's value into $t4 again
		sb $t3,grid2($t1) # getting grid2(index) value into $t3

		# looking for one step back for detonation
		addi $t0,$t0,-1 # decrementing the column index value by -1 
		addi $t1,$t1,-1 # decrementing the total index value by -1
		bltz  $t0,oneStepMove # if the column index less than zero skip this part because we are out of bounds 
		bltz $t1,oneStepMove  # if the total index value less than zero than skip this part because we are out of bounds
		lb $t5,grid($t1) # load content of grid(index) to compare the content of index before that should not have a bomb
		beq $t5,$t4,oneStepMove # if both have bomb then skip this part
		sb $t3,grid2($t1) # store $t3 ('.') value content into grid2 (which means detonated bombs)

		j oneStepMove # jumping for the another step which is looking for incremented index
oneStepMove:	
		la $t3,dot # storing '.' value address into $t3
		lb $t3,0($t3) # and getting it's value into $t3 again
		la $t4,o # storing 'O' value address into $t4
		lb $t4,0($t4) # and getting it's value into $t4 again
		
		#set index and col as usual
		addi $t1,$t1,1 #setting the index values again
		addi $t0,$t0,1 #setting the col values again
			
		addi $t0,$t0,1	# incrementing col value by one for looking for the one incremented index
		addi $t1,$t1,1  # incrementing total_index by one for looking for the one incremented index
		beq $t0,$s2,oneStepUp #if col counter equals the column value then skip this part for not getting out of bounds
		lb $t5,grid($t1) # get the content of grid(index) to $t5
		beq $t5,$t4,oneStepUp # if their content both  'O' then skip this part 
		sb $t3,grid2($t1) # store the content of $t3 into grid2[index] => grid[index]='.'

		j oneStepUp
oneStepUp:	
	
		addi $t1,$t1,-1 # setting index_values to their old values for not skipping some part 
		addi $t0,$t0,-1  # setting col_values to their old values for not skipping some part
		addi $t7,$zero,0
		addi $t7,$s2,0 # setting t7 content to $s2 content which have the column value
		sub  $t1,$t1,$t7 # substracting the index with colum value because the index value to go upper
		bltz $t1,oneStepDown # if index less than zero than we are out of bounds then skip this part
		sb $t3,grid2($t1) # if not set $t3 ('.') contents to grid[index]

		j oneStepDown	
oneStepDown:	
		add $t1,$t1,$t7 #setting index to it's old value which is index = index + column
		addi $t7,$s2,0 # setting $s2 content to $t7 
		add $t1,$t1,$t7 # for looking bottom part of the line we are summing index value with column value to find bottom index
		bge $t1,$s3,endScope # if index bigger than index value then end this scope
		lb $t5,grid($t1) # loading grid[index] to the $t5
		beq $t5,$t4,endScope # if $t5 content equal to $t4 ('O'=='O') then end scope again , because we dont need to detonate grid that has bomb
		sb $t3,grid2($t1) # than store $t3 content ('.') to grid[index]
		j endScope # then finish this scope
endScope:		
		sub $t1,$t1,$t7 # return the idnex value again the old one
		j incrementer	# return to the incrementer to lookup another values in grid and detonate if they have bombs
				

				
		
		
		
		
		
		
		
		
		
		
		
		
		
		
