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
        LEA stack, SP ;initialize stack
        
        ;LEA startLocationPrompt,A1 ;prompt for start loaction
        ;MOVE.L  #13,D0
        ;TRAP    #15
        
        ;LEA     startLocation,A1 ;get start location
        ;BSR     parseHexString 
        ;LEA     startLocation,A3 ;store start location in A3
        ;MOVE.L  D0,(A3)
        
      ;  MOVE.L #$3000,A3
       
        MOVE.L #snippet,A3
        
        ;LEA endLocationPrompt,A1 ;prompt for end location
        ;MOVE.L  #13,D0
        ;TRAP    #15 
        ;MOVE.B  #4,D0   ;get end location
        ;TRAP    #15
        ;LEA endLocation,A4 ;store end location in A4
        ;MOVE.L  D0,(A4)
        
        MOVE.L  #$303E,A4
        
mainLoop:
        
        MOVE.W (A3),D1 ;copy word from other prog to analyze as instruction
        CMPA.L A3,A4
        BEQ fin
        
checkOPcode:
        
        CMPI.W  #NoOpInstruction,D1 ;
        BEQ     NOP
        
        MOVE.W  D1,D2 ;move instruction into D2 for manipulaiton
        MOVE.B  #14,D0
        LSR.W   D0,D2
        CMPI.W  #moveInstruction,D2
        BEQ     MOVE
        
        BRA     unknownOpCode

loopend:
        ADDQ   #2,A3
        BRA mainLoop
    


instOPList DC.L NoOpInstruction,moveInstruction,0 ; dataInstruction,0          
        
;instMaskList DC.L NoOpMask,moveMask,0 ; dataInstruction,0          
;instTextList DC.L NoOpText, moveText,0

        
        
NOP:

        LEA     nopMessage,A1  ;move string for NOP info
        MOVE.B  #13,D0        ;set for task to display null terminated 
                              ;string with CR, LF
        TRAP    #15

        BRA     loopend
        ; bra -> rts
MOVE:
        
        

        MOVE.W  D1,D2
        LSR     #6,D2
        AND.B   #%00000111,D2
        
        CMPI.B  #1,D2
        BEQ     MOVEA
        
        MOVE.W  D1,D2 ;check source mode
        LSR     #3,D2   
        AND.W   #$0007,D2
        
        MOVE.W  D1,D2 ;check source reg
        AND.W   #$0007,D2
        
        
        
        LEA     moveMessage,A1  ;move string for MOVE
        MOVE.B  #13,D0        ;set for task to display null terminated 
                              ;string with CR, LF
        TRAP    #15

        BRA     loopend
        
MOVEA:
        LEA     moveAMessage,A1  ;move string for MOVE
        MOVE.B  #13,D0        ;set for task to display null terminated 
                              ;string with CR, LF
        TRAP    #15

        BRA     loopend

           
        
        
unknownOpCode:
        LEA     dataMessage,A1 ;move string for data info
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
        BRA     mainLoop
        
fin

        
        
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


snippet: NOP
         NEG D3
         SIMHALT



* Put variables and constants here

***list of OP codes

NoOpInstruction  EQU %0100111001110001
moveInstruction  EQU 0

***

startLocationPrompt DC.B    'Enter start location',0
endLocationPrompt   DC.B    'Enter end location',0

clearLine  DC.B $0D,$0A,0

invalidHexStringMessage DC.B 'Invalid Hex. Please try again',0

dataMessage DC.B 'DATA: ',0
moveMessage DC.B 'MOVE',0
moveaMessage DC.B 'MOVEA',0
nopMessage  DC.B 'NOP',0 

startLocation       DC.L    0
endLocation         DC.L    0



    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
