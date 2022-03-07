# Author: Liam Dempsey - 10754465
# Sources: None - I am already familiar with the prime number sieve

.data
	prompt_input:	.asciiz	"Enter a prime number (0 to quit): "
	prompt_primes:	.asciiz	"List of prime numbers:"
	space:		.asciiz	" "
	endl:		.asciiz	"\n"

.text

.globl main

	### MAIN FUNCTION ###
main:	# Get the list of numbers
	jal	input
	addi	$s0,	$v0,	0	# $s0 --> Count of user-inputted values

	# Loop through each of the inputs and determine if they are prime
	# Every input that is prime will remain and every that is not will become 0
	sll	$s1,	$s0,	2	# $t0 --> Total byte offset of input list
	li	$s2,	0		# $t1 --> Loop counter (incremented by four)
	
loop1:	beq	$s1,	$s2,	done1

	sub	$s3,	$sp,	$s2
	lw	$a0,	-4($s3)		# $a0 --> User input
	
	sub	$a1,	$sp,	$s1
	addi	$a1,	$a1,	-4	# $a1 --> Base address of "primes" list
	
	srl	$a2,	$a0,	1
	addi	$a2,	$a2,	2
	sll	$a2,	$a2,	2
	sub	$a2,	$a1,	$a2	# $a2 -- Base address of working values list

	jal	prime
	
	sw	$v0,	-4($s3)
	
	# Loop management
	addi	$s2,	$s2,	4
	j	loop1

	# Print primes prompt
done1:	li	$v0,	4
	la	$a0,	prompt_primes
	syscall

	# Prepare the loop
	sll	$t0,	$s0,	2	# $t0 --> Total byte offset of input list
	li	$t1,	0		# $t1 --> Loop counter (incremented by four)
	
loop2:	beq	$t0,	$t1,	done2

	sub	$t2,	$sp,	$t1
	lw	$t3,	-4($t2)		# $a0 --> User input

	beq	$t3,	$zero,	skp21

	# Print space
	li	$v0,	4
	la	$a0,	space
	syscall
	
	# Print the value
	li	$v0,	1
	addi	$a0,	$t3,	0
	syscall

	# Loop management
skp21:	addi	$t1,	$t1,	4
	j	loop2

	# Exit
done2:	li	$v0,	4
	la	$a0,	endl
	syscall

	li	$v0,	10
	syscall


	### INPUT FUNCTION - A ###
	# Inputs:   None
	# Outputs:  $v0 --> Count of user-inputted values
input:	# Gets user input and saves it to the stack until the user enters 0
	li	$t0,	0	# Initialize $t0 to 0; $t0 --> Count (saved here until $v0 is open)

	# Obtain input
loopA1:	# Print input prompt
	li	$v0,	4
	la	$a0,	prompt_input
	syscall
	
	# Obtain user input
	li	$v0,	5
	syscall
	
	bne	$v0,	$zero,	skpA11
	addi	$v0,	$t0,	0
	jr	$ra
	
skpA11:	addi	$t0,	$t0,	1
	sll	$t1,	$t0,	2	# $t1 --> Offset of $sp to store input
	sub	$t1,	$sp,	$t1	# $t1 --> Offset address of $sp to store input
	sw	$v0,	0($t1)
	
	j	loopA1
	
	
	### PRIME FUNCTION - B ###
	# Inputs:   $a0 --> Value to check; $a1 --> Base address of "primes" list; $a2 --> Base address of working values list
	# Outputs:  $v0 --> $a0 if prime, 0 if composite
prime:	# Takes a number and determines if it is prime or not
	addi	$v0,	$a0,	0	# $v0 --> Initialized to the checked value (in preparation for the value to be prime

	li	$t0,	1		# $t0 --> Initialize to 1 (first odd prime minus 2)
	li	$t1,	-4		# $t1 --> Primes array iterator
	li	$t2,	2
	sw	$t2,	0($a1)

	# Prepare the primes array
loopB1:	sltu	$t2,	$t0,	$a0
	beq	$t2,	$zero,	doneB1

	addi	$t0,	$t0,	2
			
	add	$t2,	$a1,	$t1	# $t2 --> Address of array entry
	sw	$t0,	0($t2)

	addi	$t1,	$t1,	-4
	j	loopB1

	# Append a zero as the stopping parameter
doneB1:	li	$t0,	0
	add	$t2,	$a1,	$t1	# $t2 --> Address of array entry
	sw	$t0,	0($t2)

	# Prepare the next loops
loopB2:	lw	$t0,	0($a1)		# $t0 --> First value of the "primes" list
	srl	$t1,	$a0,	1	# $t1 --> Checked value / 2
			
	# Continue to check values until the "multiple array" starts with a value greater than half of the checked value
	sltu	$t2,	$t1,	$t0
	bne	$t2,	$zero,	doneB2
	
	li	$t2,	0		# $t2 --> Initialize to 0
	li	$t3,	0		# $t3 --> Multiples array iterator
	
	# Create the multiples array for the given value of $t0
loopB3:	sltu	$t4,	$t2,	$a0
	beq	$t4,	$zero,	doneB3
	
	add	$t2,	$t2,	$t0	# $t2 --> Increment by first value of multiples array
	
	add	$t4,	$t3,	$a2	# $t4 --> Address of array entry
	sw	$t2,	0($t4)
	
	addi	$t3,	$t3,	-4
	
	j	loopB3
	
	# Append a zero as the stopping parameter
doneB3:	li	$t2,	0
	add	$t4,	$t3,	$a2	# $t4 --> Address of array entry
	sw	$t2,	0($t4)
	
	# For every value in $a1 (stops when value = 0) check if present in $a2 array
	# If not present, place it at the beginning of $a1 for the new array
	# If present and equal to $a0, set $v0 to zero and exit the loop
	# Finish by appending a zero
	li	$t1,	0		# $t1 --> Primes array iterator
	li	$t2,	0		# $t2 --> New primes array iterator
	lw	$t3,	0($a2)		# $t3 --> First value of multiples array
	
loopB4:	beq	$t0,	$zero,	doneB4

	li	$t4,	0		# $t4 --> Multiples array iterator
loopB5:	beq	$t3,	$zero,	donB51

	# Check if $t3 matches $a0
	bne	$t3,	$a0,	skpB51

	li	$v0,	0
	jr	$ra

	# Check if $t0 matches $t3 (jump to donB52 if it does; i.e. break)
skpB51:	beq	$t0,	$t3,	donB52
	
	add	$t5,	$a2,	$t4
	lw	$t3,	0($t5)
	addi	$t4,	$t4,	-4
	
	j	loopB5
	
	# Add value to new primes array
donB51:	add	$t3,	$a1,	$t2
	sw	$t0,	0($t3)
	addi	$t2,	$t2,	-4
	
	# Load the next value of the primes array to $t1
donB52:	add	$t3,	$a1,	$t1
	lw	$t0,	0($t3)
	addi	$t1,	$t1,	-4
	
	j	loopB4
	
	# Append a zero as the stopping parameter
doneB4:	li	$t0,	0
	add	$t1,	$a1,	$t2
	sw	$t0,	0($t1)

	j	loopB2
	
doneB2:	jr	$ra



