      .data
filename:
.string "input.txt"
mode:
.string "r"
input:
.space 20000
resultstring:
.space 10
string1:
.string "puzzle 1: "
string2:
.string "puzzle 2: "


        .text

        .global main
        .global itoa
        .global puts
        .global fopen
        .global fgets
        .global fread

readnumber: # convert ascii to integer and set pointer to next integer after that
            # pretty much c function 'atoa'
            # RSI: Pointer to ascii integer
            # RBX: Temporary register for reading ascii character
            # RAX: Return value, integer
    MOVQ $0, %RAX
    MOV $0, %RBX
readloop:
    MOV (%RSI), %BL # EBX <- Value at RSI
    CMP $'0', %BL # If ascii code less than '0'
    JL readend
    CMP $'9', %BL # If ascii code more than '9'
    JG readend
    MOV $10, %EDX
    MUL %EDX # multiply current integer by 10
    SUBQ $'0', %RBX # ASCII to integer
    ADDQ %RBX, %RAX 
    INCQ %RSI
    JMP readloop

readend:
    INCQ %RSI # To skip non-number symbol

    RET




puzzle1:
    MOVABSQ $input, %RAX # Set pointer to input
    MOVQ %RAX, %RSI
    MOVQ $0, %RAX # RAX = number of pairs that fully contain each other
    
puzzle1loop:
    MOV (%RSI), %BL # BL <- Value at RSI
    CMP $0, %BL
    JE puzzle1end  # exit if reached end of input
    CMP $10, %BL
    JE puzzle1end  # exit if reached end of input

# Assume A1-A2,B1-B2

    PUSH %RAX
    CALL readnumber # A1, offset 24
    PUSH %RAX
    CALL readnumber # A2, offset 16
    PUSH %RAX
    CALL readnumber # B1, offset 8
    PUSH %RAX
    CALL readnumber # B2, offset 0
    PUSH %RAX
    MOV 32(%RSP), %RAX

#firstcontainssecond
    MOVQ 24(%RSP), %RDX
    CMPQ 8(%RSP), %RDX
    JG secondcontainsfirst # A1 <= B1
    MOVQ 16(%RSP), %RDX
    CMPQ (%RSP),%RDX
    JL secondcontainsfirst # A2 >= B2
    JMP puzzle1gainreward

secondcontainsfirst:
    MOVQ 24(%RSP), %RDX
    CMPQ 8(%RSP), %RDX
    JL puzzle1noreward # A1 >= B1
    MOVQ 16(%RSP), %RDX
    CMPQ (%RSP),%RDX
    JG puzzle1noreward # A2 <= B2
puzzle1gainreward:
    INC %RAX
puzzle1noreward:
    ADDQ $40, %RSP
    JMP puzzle1loop

puzzle1end:
    PUSH %RAX
    

    # puts(*string1)
    MOVABSQ $string1, %RAX
    MOVQ %RAX, %RCX

    subq	$32, %rsp #shadow space
    CALL puts
    addq	$32, %rsp

    # itoa (RAX, *resultstring, 10)
    MOVABSQ $resultstring, %RAX
    MOVQ %RAX, %RDX
    MOVQ $10, %R8
    POP %RAX
    MOVQ %RAX, %RCX

    subq	$32, %rsp #shadow space
    CALL itoa
    addq	$32, %rsp

    # puts(*resultstring)
    MOVABSQ $resultstring, %RAX
    MOVQ %RAX, %RCX

    subq	$32, %rsp #shadow space
    CALL puts
    addq	$32, %rsp

    RET

puzzle2:
    MOVABSQ $input, %RAX # Set pointer to input
    MOVQ %RAX, %RSI
    MOVQ $0, %RAX # RAX = number of pairs that overlap
    
puzzle2loop:
    MOV (%RSI), %BL # EBX <- Value at RSI
    CMP $0, %BL
    JE puzzle2end  # exit if reached end of input
    CMP $10, %BL
    JE puzzle2end  # exit if reached end of input

    # Assume A1-A2,B1-B2
    PUSH %RAX
    CALL readnumber # A1, offset 24
    PUSH %RAX
    CALL readnumber # A2, offset 16
    PUSH %RAX
    CALL readnumber # B1, offset 8
    PUSH %RAX
    CALL readnumber # B2, offset 0
    PUSH %RAX
    MOV 32(%RSP), %RAX

    MOVQ 16(%RSP), %RDX
    CMPQ 8(%RSP), %RDX
    JL puzzle2nooverlap # A2 >= B1
    MOVQ (%RSP), %RDX
    CMPQ 24(%RSP),%RDX
    JL puzzle2nooverlap # B2 >= A1
    # Reward
    INC %RAX    # Wohoo add to counter
puzzle2nooverlap:
    ADDQ $40, %RSP
    JMP puzzle2loop

puzzle2end:
    PUSH %RAX
    
        # puts(*string2)
    MOVABSQ $string2, %RAX
    MOVQ %RAX, %RCX

    subq	$32, %rsp #shadow space
    CALL puts
    addq	$32, %rsp

        # itoa (RAX, *resultstring, 10)
    MOVABSQ $resultstring, %RAX
    MOVQ %RAX, %RDX
    MOVQ $10, %R8
    POP %RAX
    MOVQ %RAX, %RCX

    subq	$32, %rsp #shadow space
    CALL itoa
    addq	$32, %rsp

        # puts(*resultstring)
    MOVABSQ $resultstring, %RAX
    MOVQ %RAX, %RCX

    subq	$32, %rsp #shadow space
    CALL puts
    addq	$32, %rsp

    RET

main:
    SUBQ $40, %RSP # Safety stack :)

        # fopen(*filename, *mode)
    MOVABSQ $filename, %RAX
    MOVQ %RAX, %RCX
    MOVABSQ $mode, %RAX
    MOVQ %RAX, %RDX

    subq	$32, %rsp #shadow space
    CALL fopen
    addq	$32, %rsp

    PUSH %RAX

        # fgets(*input, 20000, *filepointer)
    MOVABSQ $input, %RAX
    MOVQ %RAX, %RCX
    MOVQ $1, %RDX
    MOVQ $20000, %R8
    POP %RAX
    MOVQ %RAX, %R9


    subq	$32, %rsp #shadow space
    CALL fread
    addq	$32, %rsp

    CALL puzzle1
    CALL puzzle2

    # exit process
    XORQ %RAX, %RAX
    ADDQ $40, %RSP
    ret
