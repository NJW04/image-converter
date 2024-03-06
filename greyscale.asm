# Nathan Wells
# WLLNAT033

.data 
    inputfile: .asciiz "/Users/nathanwells/Desktop/CS2002/Assignment 4/sample_images/jet_64_in_ascii_cr.ppm"
    outputfile: .asciiz "/Users/nathanwells/Desktop/CS2002/Assignment 4/ALTERED_IMAGE.ppm"

    fileWords: .space 50000
    big_buffer: .space 50000
    small_buffer: .space 4
    newline: .asciiz "\n"
    result_string: .space 20
.text
.globl main
main:
    #Open File
    li $v0, 13
    la $a0, inputfile
    li $a1, 0
    syscall
    move $s0, $v0

    #Read entire file
    li $v0, 14
    move $a0, $s0
    la $a1, fileWords
    la $a2, 50000
    syscall

    #Close file
    li $v0, 16
    move $a0, $s0
    syscall

    move $t0, $a1             # t0 contains the pointer to the file
    la $t1, big_buffer        # t1 containts pointer to big buffer
    move $t2, $zero           # t2 stores the number of bytes that have been read
    la $t3, small_buffer      # t3 contains the pointer to the small buffer
    move $s2, $zero           # s2 stores the sum of pixel values
    move $s3, $zero           # s3 stores the sum of new pixel values

    move $t7,$zero            # t7 will store the number of bytes to write to the new file
    
store_first_four_lines:                 # store first four lines into the big buffer  
    beq $t2, 19, end_store_first_four_lines
    beq $t2, 1, make_p2
    lb $t4, 0($t0)
    sb $t4, 0($t1)
    addi $t1,1
    addi $t0,1
    addi $t2,1
    addi $t7,1
    j store_first_four_lines

make_p2:                         # change the 3 to a 2 on the first line, 2nd byte to make the image greyscale
    lb $t4, 0($t0)
    li $t5, 50
    sb $t5, 0($t1)
    addi $t1,1
    addi $t0,1
    addi $t2,1
    j store_first_four_lines

end_store_first_four_lines:

    move $t2, $zero      # t2 stores the number of pixels that have been summed
    move $t9, $zero     # $t9 stores the current running total of the pixels
    move $t6, $zero


main_loop:

    beq $t6, 12288, final_write_big_buffer

    lb $t4, 0($t0) #load byte into t4
    sb $t4, 0($t3) #store byte in small buffer


    addi $t0,1                      # increase the files pointer by 1
    addi $t3,1                      # increase small buffer pointer
    beq $t4, 13, process_pixel      # process the pixel

    j main_loop

process_pixel:
    addi $t6,1                      # increment the number of lines stored
    la $t3, small_buffer            # reset the pointer to the small buffer
     
end_store_small_buffer: 
    li  $s5, 13
    li  $s4, 10  
    li  $s7, 48
    la  $t3, small_buffer           # resetting pointer to small buffer again

convert_string_to_int:              # convert the string into an integer
    move $t8, $zero                 #t8 will hold the current built integer

str_to_int_loop:
    lb  $s0, 0($t3)
    addi $t3,1
    beq $s0, $s5, end_str_to_int_loop
    sub $s1, $s0, $s7
    mul $t8, $t8, $s4
    add $t8, $t8, $s1
    j   str_to_int_loop

end_str_to_int_loop:
    
    add $t9, $t9, $t8        #add to running total
    addi $t2,1                #incrememnt the number of pixels added together

    bne $t2, 3, reset_small_buffer_address   #branch when 3 values have been summed, know it has RGB
    j calculate_average

reset_small_buffer_address:

    la $t3, small_buffer        # reset small buffer pointer
    j main_loop

calculate_average:
    move $t2, $zero             # calculating the average

    div $s3, $t9, 3
    move $t9, $zero
    mflo $t8

    la $a0, result_string   # Load the address of the result string
    li $a2, 10              # Load 10
    sb $zero, ($a0)         # Null terminate the string
    addi $a0,10             # Move to the end of the string

int_to_str_loop:
    div $t8, $a2            # Divide $t8 by 10
    mflo $s4                # Set s4 to the quotient
    mfhi $s5                # Set s5 to the remainder

    addi $s5,48             # Convert to ASCII string
    sb $s5, -1($a0)         # Store the digit in the string

    addi $a0,-1                 # Move to the next position in the string

    beqz $s4, end_int_to_str    # Check if the quotient is zero

    move $t8, $s4               # If not 0, continue
    j int_to_str_loop

end_int_to_str:

    move $s7, $a0

add_to_big_buffer:

    lb $t8, 0($s7)                          #load byte from small buffer
    beq $t8, $zero, end_add_to_big_buffer   #branch if end of small buffer 
    sb $t8, 0($t1)                          #store the byte in big buffer
    addi $s7,1                              #increase the pointer for address containing the string to write
    addi $t1,1                              #increase pointer to the big buffer by 1
    addi $t7,1                              #increase the byte counter per byte
    j add_to_big_buffer


end_add_to_big_buffer:
    lb $t8, newline                         #load a newline character into register t8
    sb $t8, 0($t1)                          #make end have newline character
    addi $t1,1                              #increase pointer by 1
    addi $t7,1                              #increase the byte counter per byte
    la $t3, small_buffer                    #reset the pointer to the small buffer
    j main_loop 

final_write_big_buffer:

    li $v0, 13                               # open file in write mode
    la $a0, outputfile
    li $a1, 1
    syscall
    move $s1, $v0

    li $v0, 15                               # write  big buffer to the file
    move $a0, $s1
    la $a1, big_buffer
    addi $t7,1
    move $a2, $t7                              # specify how many bytes to write to the file
    syscall

    li $v0, 16                               # close the file 
    move $a0, $s1
    syscall

exit:

    li $v0, 10
    syscall
