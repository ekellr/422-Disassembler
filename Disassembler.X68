    
*****Symbols*****
prog_st     EQU $00001000 ;start of program to be disassembled
prog_end    EQU $000010F0 ;end of program to be disassembled
start       EQU $1000      ;this program's instructions begin here in memory
exit        EQU $2700     ;
word        EQU 2         ;makes it clear when adding to a memory address,
                          ;2 is a word

NoOpInstruction  EQU %0100111001110001
    ORG    start
        
        MOVE.B  #50,D0 ;close all files
        TRAP    #15
        
        LEA     fileName,A1 ;load address of file name to A1
        MOVE.B  #51,D0 ;set for task to open existing file
                       ;with the file name
        TRAP    #15
        
        CMP.W   #2,D0 ;check if file succesfully opened
        BEQ     endOfProg
        LEA     fileOneID,A2 ;save file ID
        MOVE.L  D1,(A2)
        
*        LEA     prog_st,A2  ;load start of prog into address reg A0
*        LEA     prog_end,A3 ;load end of prog into address reg A1
        NOP
loopStart:
        
        LEA     fileReadBuffer,A1
        MOVE.L  (A2),D1 ;make sure file ID in D1
        MOVE.B  #2,D2
        MOVE.B  #53,D0 ;read in a word
        TRAP    #15
        
        CMP.B   #2,D2 ;anything less two indicates EOF
        BLT     eof
        
        MOVE.W  (A1),D1 ;move data into register
        BRA     checkOpCode
loopBody:
*        ADDQ.L  #word,A2
*        CMPA.L  A2,A3
*        BLT     endOfProg
        BRA     loopStart
        
checkOPcode:
        
        CMPI.W  #NoOpInstruction,D1
        BEQ     NOP
        BRA     unknownOpCode
        
NOP:

        LEA     nopString,A1  ;move string for NOP info
        MOVE.B  #13,D0        ;set for task to display null terminated 
                              ;string with CR, LF
        TRAP    #15

        BRA     loopBody
        
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
        
eof:
    BRA endOfProg    
        
endOfProg:

    SIMHALT
*****Constants*****
dataString DC.B 'DATA: ',0
clearLine  DC.B $0D,$0A,0
nopString  DC.B 'NOP',0 
fileName   DC.B 'Disassembler.bin',0
fileReadBuffer DC.L 0
fileOneID  DC.L   0 
    END  start





*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
