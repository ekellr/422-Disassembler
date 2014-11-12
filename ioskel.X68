*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

stack   EQU   $00005000
begin   EQU   $00005001
end     EQU   $00FFFFFE
byte    EQU   1

    ORG    $1000
start:
        LEA stack, SP
        
        LEA startLocationPrompt,A1 ;prompt for start loaction
        MOVE.L  #13,D0
        TRAP    #15
        
        LEA     startLocation,A1 ;get start location
        BSR     parseHexString
        LEA     startLocation,A3 ;store start location in A3
        MOVE.L  D0,(A3)

        LEA endLocationPrompt,A1 ;prompt for end location
        MOVE.L  #13,D0
        TRAP    #15 
        MOVE.B  #4,D0   ;get end location
        TRAP    #15
        LEA endLocation,A4 ;store end location in A4
        MOVE.L  D0,(A4)
        simhalt

***Pre:     Hex String is at (A1) and null terminated
***         A2 is free to be used to store initial value of A1
***Post:    Value in hex is in D0  
parseHexString:
        
        MOVEA.L A1,A2
        MOVE.B  #2,D0 ;ask user for string  
        TRAP    #15
        
        CMP.W   #9,D1
        BGT     badHexString
        
        CMP.B   #'$',(A1)
        BNE     badHexString
        ADDQ.L  #byte,A1
        MOVEQ.L #0,D0 ;clear D0
        MOVEQ.L #8,D2 ;prevent trying to read more than 4 bytes
HexStringBody:
        
        CMP.B   #0,(A1) ;if reach zero, end of string
        BEQ     HexStringDone
        CMP.B   #0,D2 ;check how many nybbles have been read
        BLT     HexStringDone
              
        CMP.B   #'0',(A1)
        BLT     badHexString
        CMP.B   #'9',(A1)
        BLE     hexNumber
        
        CMP.B   #'A',(A1)
        BLT     badHexString
        CMP.B   #'F',(A1)
        BLE     hexAlpha
        BRA     badHexString
        
        
HexStringDone:
        
        RTS
HexNumber:
        LSL.L   #4,D0
        MOVE.B (A1),D1
        SUB.B  #'0',D1
        ADD.L  D1,D0
        ADDQ.L #byte,A1
        BRA HexStringbody
HexAlpha:
        LSL.L   #4,D0
        MOVE.B (A1),D1
        SUB.B  #'A',D1
        ADD.B  #10,D1
        ADD.L  D1,D0
        ADDQ.L #byte,A1

        BRA HexStringbody
badHexString:
        
        LEA     invalidHexStringMessage,A1
        MOVE.L  #13,D0
        TRAP    #15
        MOVEA.L A2,A1
        BRA parseHexString

    SIMHALT             ; halt simulator

* Put variables and constants here
startLocationPrompt DC.B    'Enter start location',0
endLocationPrompt   DC.B    'Enter end location',0
invalidHexStringMessage DC.B 'Invalid Hex. Please try again',0

startLocation       DC.L    0
endLocation         DC.L    0



    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
