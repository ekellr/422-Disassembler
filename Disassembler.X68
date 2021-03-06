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
word    EQU   2
long    EQU   4

    ORG $00000FFE
FarLabel:
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
        
        MOVE.L  #snippetEnd,A4
        
mainLoop:
        CMPA.L A3,A4 ;check end of prog
        BEQ fin
        
        MOVE.W (A3),D1 ;copy word from other prog to analyze as instruction
        
        MOVEQ.L #0,D3
        
        ***things to save A3,A4,D1(?)***
        MOVEM.L A3-A4,-(SP)
        BSR checkOPcode
        MOVEM.L (SP)+,A3-A4
        ADDA.L  D7,A3 ;look past data that was part of the instruction
        
        ADDQ.L  #word,A3
        BRA     mainLoop 
        
checkOPcode:


        LEA     instOPList,A0 ;get instruction signitrue list in A0
        ADDA.L  D3,A0 ;get correct sig         
        
        LEA     instMaskList,A1 ;get instruction mask in A1
        ADDA.L  D3,A1  ;get correct mast
        
        MOVE.W  D1,D2 ;move instruction into D2 for manipulaiton
        
        AND.W   (A1),D2 ;mask instruction
        CMP.W   (A0),D2 ;compare to sig
        BEQ     found ;if sig matches branch
        
        ADDQ.L  #word,D3 ;if not found, add to D3 and check for next instruction
        BRA checkOPcode

found:
        
        LEA     instLabelList,A1 ;get instruction code label
        ADDA.L  D3,A1 ;get correct label
        ADDA.L  D3,A1
        MOVEA.L (A1),A1
        JSR     (A1)
        RTS
        

instOPList DC.W negInstruction,NoOpInstruction,moveInstruction,bccInstruction,dataInstruction         
instMaskList DC.W negMAsk,NoOpMask,moveMask,bccMask,dataMask          
instLabelList DC.L NEG,NOP, MOVE,Bcc,unknownOpCode

snippet:
         NOP
         BRA snippet
         BRA FarLabel
         BEQ snippet
         BGT NEG
         BSR snippet
         NEG D1
         
snippetEnd:
         SIMHALT
        

NEG:
        
        LEA     negMessage,A1  ;move string for NEG info
        MOVE.B  #14,D0        ;set for task to display null terminated 
                              ;string without CR, LF
        TRAP    #15
        
        LEA     clearLine,A1  ;move string for a CR and LF
        MOVE.B  #14,D0        ;set for task to display null terminated 
                              ;string without CR, LF
        TRAP    #15
        
        RTS


        
NOP:

        LEA     nopMessage,A1  ;move string for NOP info
        MOVE.B  #13,D0        ;set for task to display null terminated 
                              ;string with CR, LF
        TRAP    #15

        RTS
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

        MOVEQ.L #0,D7
        RTS
        
MOVEA:
        LEA     moveAMessage,A1  ;move string for MOVE
        MOVE.B  #13,D0        ;set for task to display null terminated 
                              ;string with CR, LF
        TRAP    #15

        RTS

           
Bcc:

        LEA     bccMessage,A1  ;move string for BRA info
        MOVE.B  #14,D0        ;set for task to display null terminated 
                              ;string without CR, LF
        TRAP    #15
        
        MOVEQ.L #0,D0 ;clear D0
        MOVE.W  D1,D2 ;move instruction into D2 for manipulaiton
        LSR.W   #8,D2
        AND.W   #$0F,D2 ;mask instruction
        
checkCC:        
        LEA     bccList,A0 ;get condition code signature list in A0
        ADDA.L  D0,A0 ;get correct sig         
        CMP.B   (A0),D2 ;compare to sig
        BEQ     foundCC ;if sig matches branch
        ADDQ.B  #byte,D0
        BRA     checkCC
foundCC:
        LEA     conditionCodeMessage,A1 ;get condition code message in A1
        MULU.W  #long,D0 ;adjust size of D0 for a long
        ADDA.L  D0,A1 ;get correct message location
        MOVEA.L (A1),A1 ;get correct message
        
        MOVE.B  #14,D0        ;set for task to display null terminated 
                              ;string without CR, LF
        TRAP    #15

        
        
        ADDQ.L  #word,A3 ;move past instruction in case long displacement
        AND.W   #$00FF,D1   ;check for word sized displacement
        
        CMP.B   #$0,D1
        BEQ     BccWord
        
        CMP.B   #$FF,D1 check for long sized displacement
        BEQ     BccLong
        
BccByte:
        
        MOVEQ.L #0,D7 ;pass back no extra data followed
        BRA     BccDone
BccWord:
        MOVE.W  (A3),D1
        
        MOVEQ.L #word,D7 ;pass back an extra word followed
        BRA     BccDone
BccLong:
        MOVE.L  (A3),D1
        
        MOVEQ.L #long,D7 ;pass back an extra long followed
        BRA     BccDone
BccDone:

        MOVE.W  #16,D2 ;put base in D2
        MOVE.W  #15,D0  ;put task #15 in D0
        TRAP    #15
        
        LEA     clearLine,A1  ;move string for a CR and LF
        MOVE.B  #14,D0        ;set for task to display null terminated 
                              ;string without CR, LF
        TRAP    #15

        
        RTS
        
        
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
        
        MOVEQ.L #0,D7
        RTS
        
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






* Put variables and constants here

***list of OP codes

NoOpInstruction  EQU %0100111001110001
moveInstruction  EQU 0
bccInstruction   EQU %0110000000000000
negInstruction   EQU %0100010000000000
dataInstruction  EQU 0

***

***list of OP masks

NoOpMask  EQU $FFFF
moveMask  EQU $C000
bccMask   EQU $F000
negMask   EQU $FF00
dataMask  EQU 0
***

***Bcc Codes***
CC EQU $04
CS EQU $05
EQ EQU $07
GE EQU $0C
GT EQU $0E
HI EQU $02
LE EQU $0F
LS EQU $03
LT EQU $0D
MI EQU $0B
NE EQU $06
PL EQU $0A
VC EQU $08
VS EQU $09
RA EQU $00 ;not really a Condition Code
SR EQU $01 ;not really a Condition Code

CCm DC.B 'CC ',0
CSm DC.B 'CS ',0
EQm DC.B 'EQ ',0
GEm DC.B 'GE ',0
GTm DC.B 'GT ',0
HIm DC.B 'HI ',0
LEm DC.B 'LE ',0
LSm DC.B 'LS ',0
LTm DC.B 'LT ',0
MIm DC.B 'MI ',0
NEm DC.B 'NE ',0
PLm DC.B 'PL ',0
VCm DC.B 'VC ',0
VSm DC.B 'VS ',0
RAm DC.B 'RA ',0
SRm DC.B 'SR ',0

BccList DC.B SR,CC,CS,EQ,GE,GT,HI,LE,LS,LT,MI,NE,PL,VC,VS,RA
conditionCodeMessage DC.L SRm,CCm,CSm,EQm,GEm,GTm,HIm,LEm,LSm,LTm,MIm,NEm,PLm,VCm,VSm,RAm
***

startLocationPrompt DC.B    'Enter start location',0
endLocationPrompt   DC.B    'Enter end location',0

clearLine  DC.B $0D,$0A,0

invalidHexStringMessage DC.B 'Invalid Hex. Please try again',0


nopMessage  DC.B 'NOP',0 
moveMessage DC.B 'MOVE',0
bccMessage  DC.B 'B',0
negMessage  DC.B 'NEG',0
dataMessage DC.B 'DATA: ',0


moveaMessage DC.B 'MOVEA',0


startLocation       DC.L    0
endLocation         DC.L    0


   
    END    START        ; last line of source
    








*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
