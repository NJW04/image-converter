# Nathan Wells
# WLLNAT033

.data 
    inputfile: .asciiz "/Users/nathanwells/Desktop/CS2002/Assignment 4/sample_images/jet_64_in_ascii_cr.ppm"
    outputfile: .asciiz "/Users/nathanwells/Desktop/CS2002/Assignment 4/ALTERED_IMAGE.ppm"

    fileContents: .space 50000 
    big_buffer: .space 50000
    small_buffer: .space 4

    newline: .asciiz "\n"
    result_string: .space 20
    original_prompt: .asciiz "Average pixel value of the original image:\n"
    new_prompt: .asciiz "Average pixel value of new image:\n"
.text
.globl main
main:

    #Open File To Read
    li $v0, 13
    la $a0, inputfile
    li $a1, 0
    syscall
    move $s0, $v0

    #Read entire file
    li $v0, 14
    move $a0, $s0
    la $a1, fileContents
    la $a2, 50000
    syscall

    #Close file
    li $v0, 16
    move $a0, $s0
    syscall

    move $t0, $a1             # t0 contains the pointer to the file
    move $t1, $zero           # t1 stores the number of lines that have been read
    la $t2, small_buffer      # t2 contains the pointer to  small buffer
    la $t5, big_buffer        # t5 contains pointer to big buffer
    move $s2, $zero           # s2 stores the sum of pixel values
    move $s3, $zero           # s3 stores the sum of increased pixel values
    move $s6,$zero            # s6 stores total bits written counter, used at end
    
store_first_four_lines:
    beq $t1, 19, end_store_first_four_lines
    lb $t4, 0($t0)
    sb $t4, 0($t5)
    addi $t5,1
    addi $t0,1
    addi $t1,1
    addi $s6,1
    j store_first_four_lines

end_store_first_four_lines:

    li $t9, 10
    move $t6, $zero


main_loop:

    beq $t6, 12288, write_big_buffer 

    lb $t4, 0($t0) #load byte from file
    sb $t4, 0($t2) #store byte in small buffer

    addi $t0,1
    addi $t2,1
    beq $t4, 13, process_pixel  #When new-line character 

    j main_loop

process_pixel:
    addi $t6,1
    la $t2, small_buffer
     
end_store_small_buffer:
    li  $s5, 13
    li  $s4, 10
    li  $s7, 48
    la  $t2, small_buffer

convert_string_to_int:
    move $t8, $zero         #Keeps the integer result

str_to_int_loop:
    lb  $s0, 0($t2)
    addi $t2,1
    beq $s0, $s5, end_str_to_int_loop
    sub $s1, $s0, $s7
    mul $t8, $t8, $s4
    add $t8, $t8, $s1
    j   str_to_int_loop

end_str_to_int_loop:
    add $s2, $s2, $t8   #Updating the running total for pre added pixel values
    addi $t8,10         #Add 10 to the integer number
    add $s3, $s3, $t8   #Updating the running total for the post added pixel values
   
    la $a0, result_string   # Load the address of the result string
    li $a3, 10              
    sb $zero, ($a0)         # Null terminate the string
    addi $a0,10             # Move to the end of the string

int_to_str_loop:
    div $t8, $a3            # Divide $t8 by 10
    mflo $s4                # Set $s4 to the quotient
    mfhi $s5                # Set $s5 as remainder

    addi $s5,48             # Convert back to ASCII string 
    sb $s5, -1($a0)         # Store the digit in the string

    addi $a0,-1             # Move to next position in the string
    beqz $s4, end_convert   # Check if the quotient is zero

    # If not 0, continue the loop
    move $t8, $s4
    j int_to_str_loop

end_convert:
    move $s7, $a0

add_to_big_buffer:
    
    lb $t8, 0($s7)
    beq $t8, 0, end_add_to_big_buffer
    sb $t8, 0($t5)
    addi $s7,1
    addi $t5,1
    addi $s6,1
    j add_to_big_buffer


end_add_to_big_buffer:
    lb $t8, newline
    #lb $t8,13
    sb $t8, 0($t5)
    addi $t5,1
    addi $s6,1
    la $t2, small_buffer   
    j main_loop 

write_big_buffer:

    li $v0, 13
    la $a0, outputfile
    li $a1, 1
    syscall
    move $s1, $v0

    li $v0, 15
    move $a0, $s1
    la $a1, big_buffer
    move $a2,$s6            #Must tell it the EXACT number of bytes to write, if not it gets a load of null characters at the end, BAD!
    syscall

    li $v0, 16
    move $a0, $s1
    syscall

exit:

    #Convert from integer to floating point
    mtc1 $s2, $f2           
    mtc1 $s3, $f3
    mtc1 $t6, $f6 

    #Floating point division
    div.s $f0, $f2, $f6    
    div.s $f1, $f3, $f6     


    # Print prompt
    li $v0, 4
    la $a0, original_prompt
    syscall

    li $v0, 2
    mov.s $f12, $f0  
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    # Print prompt
    li $v0, 4
    la $a0, new_prompt
    syscall

    li $v0, 2
    mov.s $f12, $f1
    syscall

    li $v0, 10       
    syscall