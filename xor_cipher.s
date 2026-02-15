# Data Segment
.data
plain_text: .asciiz "ken_SU is a junior CompE. student at UMASS, Amherst.00000000"
password: .asciiz "SU00"
cipher_text: .space 128     # allocate space for cipher_text
deciphered_text: .space 128  # allocate space for deciphered_text

plain: .asciiz "Plain Text: "
cipher: .asciiz "Cipher Text: "
deciphered: .asciiz "Generated Plain Text: "


# Text Segment
.text
.globl main
main:
    # initialization of variables
    la  s0, plain_text
    la  s1, password
    la  s2, cipher_text
    la  s3, deciphered_text 
    
    # encrypt
    la  a2, plain_text  # starting address of plain_text
    la  a3, password    # starting address of password
    la  a4, cipher_text # starting address of cipher_text
    addi    a5, zero, 0 # password index counter
    jal ra, ENCRYPT

    # print encrypted text
    # li  a0, 4
    # la  a1, cipher_text
    # ecall

    # decrypt
    la  a3, password        # starting address of password
    la  a4, cipher_text     # starting address of cipher_text
    la  a6, deciphered_text  # starting address of deciphered_text
    addi    a5, zero, 0     # password index counter
    jal ra, DECRYPT

    # print decrypted text
    # li  a0, 4
    # la  a1, deciphered_text
    # ecall

    # compare
    la  a2, plain_text      # starting address of plain_text
    la  a6, deciphered_text  # starting address of deciphered_text
    jal ra, COMPARE


RESET_KEY_ENCRYPTED:
    addi    a5, zero, 0 # set password index counter to 0
    beqz    a5, ENCRYPT

SWITCH_ENCRYPT:
    # get current character of password[a3], 8-bits
    lbu t0, 0(a3)
    srli    t4, t0, 4       # get upper bits of the password, 4-bits
    slli    t5, t0, 4       # get lower bits of the password, 4-bits
    or      t4, t4, t5      # temp4 = new generated password, 8-bits
    andi    t4, t4, 0xEE    # bits 0 and 4 of all four generated password characters are cleared to 0.

    # get current character of plain[a2], 8-bits
    lbu t0, 0(a2)

    # xor with generated password
    xor t0, t4, t0

    # store character to cipher[a4]
    sb  t0, 0(a4)

    # move to the next character:
    addi    a2, a2, 1   # plain[+1]
    addi    a3, a3, 1   # password[+1]
    addi    a4, a4, 1   # cipher[+1]
    addi    a5, a5, 1   # counter[+1]
  
ENCRYPT:
    # get current character of plain[a2], 8-bits
    lbu t0, 0(a2)

    # If (plain[a2] == NULL=0) END
    beqz    t0, END
    # If password counter == '4' RESET
    addi    t0, zero, 4
    beq     a5, t0, RESET_KEY_ENCRYPTED
    
    # check plain[a2] for even or odd
    andi	t1, t0, 0x0f		# copy lower 4-bits of plain_text to temp1, 4-bits
	andi	t2, t0, 0xf0		# copy upper 4-bits of plain_text to temp2, 4-bits
    # get the lsb to see if it's odd or even
	andi	t4, t2, 1
	andi	t5, t3, 1
    # If both are even or odd swap
    beq t4, t5, SWITCH_ENCRYPT

    # move to the next character: (if not switched)
    addi    a2, a2, 1   # plain[+1]
    addi    a3, a3, 1   # password[+1]
    addi    a4, a4, 1   # cipher[+1]
    addi    a5, a5, 1   # counter[+1]
    bnez    a2, ENCRYPT

END:
    jr ra


 # decrypt
    # la  a3, password    # starting address of password
    # la  a4, cipher_text # starting address of cipher_text
    # la  a6, deciphered_text  # starting address of deciphered_text
    # addi    a5, zero, 0 # password index counter
    # jal ra, DECRYPT

RESET_KEY_DECRYPTED:
    addi    a5, zero, 0 # set password index counter to 0
    beqz    a5, DECRYPT

SWITCH_DECRYPT:
    # get current character of password[a3], 8-bits
    lbu t0, 0(a3)
    srli    t4, t0, 4       # get upper bits of the password, 4-bits
    slli    t5, t0, 4       # get lower bits of the password, 4-bits
    or      t4, t4, t5      # temp4 = new generated password, 8-bits
    andi    t4, t4, 0xEE    # bits 0 and 4 of all four generated password characters are cleared to 0.

    # get current character of cipher[a4], 8-bits
    lbu t0, 0(a4)

    # xor with generated password
    xor t0, t4, t0

    # store character to decrypted[a6]
    sb  t0, 0(a6)

    # move to the next character:
    addi    a6, a6, 1   # decrypted[+1]
    addi    a3, a3, 1   # password[+1]
    addi    a4, a4, 1   # cipher[+1]
    addi    a5, a5, 1   # counter[+1]

DECRYPT:
    # get current character of cipher[a4], 8-bits
    lbu t0, 0(a4)

    # If (cipher_text[a4] == NULL=0) END
    beqz    t0, END
    # If password counter == '4' RESET
    addi    t0, zero, 4
    beq     a5, t0, RESET_KEY_DECRYPTED
    
    # check cipher_text[a2] for even or odd
    andi	t1, t0, 0x0f		# copy lower 4-bits of plain_text to temp1, 4-bits
	andi	t2, t0, 0xf0		# copy upper 4-bits of plain_text to temp2, 4-bits
    # get the lsb to see if it's odd or even
	andi	t4, t2, 1
	andi	t5, t3, 1
    # If both are even or odd switch
    beq t4, t5, SWITCH_DECRYPT

    # move to the next character: (if not switched)
    addi    a6, a6, 1   # decrypted[+1]
    addi    a3, a3, 1   # password[+1]
    addi    a4, a4, 1   # cipher[+1]
    addi    a5, a5, 1   # counter[+1]
    bnez    a2, DECRYPT

# compare
# la  a2, plain_text      # starting address of plain_text
# la  a6, deciphered_text  # starting address of deciphered_text
# jal ra, COMPARE

NEXT:
    addi    a2, a2, 1   # plain[+1]
    addi    a6, a6, 1   # decrypted[+1]


COMPARE:
    # get current character of plain[a2] >> t0, 8-bits
    lbu t0, 0(a2)
    # get current character of decrypted[a4] >> t1, 8-bits
    lbu t1, 0(a2)
    
    # If (plain_text[a4] == NULL=0) SAME
    beqz    t0, EQUAL

    # If not at end compare
    beq t0, t1, NEXT

    # If not the same return 0
    bne t0, t1, NOT_EQUAL



# plain_text: .asciiz "name_HI is a junior CompE. student at UMASS, Amherst.00000000"
# password: .asciiz "HI00"
# cipher_text: .space 128     # allocate space for cipher_text
# deciphered_text: .space 128  # allocate space for deciphered_text

# plain: .asciiz "Plain Text: "
# cipher: .asciiz "Cipher Text: "
# deciphered: .asciiz "Generated Plain Text: "

EQUAL:
    # return 1
    li a0, 1
    addi, a1, zero, 1
    ecall

    # print complete output
    li  a0, 4
    la  a1, plain
    ecall
    la  a1, plain_text
    ecall

    la  a1, cipher
    ecall
    la  a1, cipher_text
    ecall

    la  a1, deciphered
    ecall
    la  a1, deciphered_text
    ecall

    jr ra

NOT_EQUAL:
    li a0, 1
    addi, a1, zero, 0
    ecall
    jr ra