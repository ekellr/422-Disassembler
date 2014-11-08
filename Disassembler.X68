*-----------------------------------------------------------
*
* This is a program to read a byte from $7000 to $8000
* and look for the pattern in memory. If the pattern is found
* then the address of the word is stored in the location at Address2. If no pattern match
* is found the program stores $00000000 in the A2 location.
* The ____DESCRIPTION_____ algorithm assumes that the _____x____ is located on a word
* boundary.
*
*-----------------------------------------------------------
    OPT CRE
    
*****Symbols*****
prog_st     EQU $00001000 ;start of program to be disassembled
prog_end    EQU $00003000 ;end of program to be disassembled
start       EQU $1000      ;this program's instructions begin here in memory
exit        EQU $2700     ;
byte        EQU 1         ;makes it clear when adding to a memory address,
                          ;1 is a byte

    ORG    start

        LEA     prog_st,A2  ;load start of prog into address reg A0
        LEA     prog_end,A3 ;load end of prog into address reg A1
loopStart:
        MOVE.B  (A2),D1
        BRA     checkOpCode
loopBody:
        ADDQ.L  #byte,A2
        CMPA.L  A2,A3
        BLT     endOfProg
        BRA     loopStart
        
checkOPcode:
        BRA     unknownOpCode
        
unknownOpCode:
        LEA     dataString,A1 ;move string for data info
        MOVE.B  #14,D0        ;set for task to display null terminated 
                              ;string without CR, LF
        TRAP    #15
        
        MOVE.B  #16,D2        ;set for displaying a base16(hex) number
        MOVE.B  #15,D0
        TRAP    #15
        LEA     clearLine,A1  ;move string for a CR and LF
        MOVE.B  #14,D0        ;set for task to display null terminated 
                              ;string without CR, LF
        TRAP    #15
        BRA     loopBody
        
endOfProg:


*****Constants*****
dataString DC.B 'DATA: ',0
clearLine  DC.B $0D,$0A,0
    END  start





*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
