*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

stack   EQU   $00005000
begin   EQU   $00005001
end     EQU   $00FFFFFE

    ORG    $1000
start:
        LEA stack, SP
        
        LEA startLocationPrompt,A1 ;prompt for start loaction
        MOVE.L  #13,D0
        TRAP    #15
        MOVE.B  #4,D0   ;get start location
        TRAP    #15
        MOVEA.L D1,A3   ;store location in A3

        LEA endLocationPrompt,A1 ;prompt for end location
        MOVE.L  #13,D0
        TRAP    #15 
        MOVE.B  #4,D0   ;get end location
        TRAP    #15
        MOVEA.L D1,A4   ;store location in A4

    
badfileopen:
    SIMHALT             ; halt simulator

* Put variables and constants here
startLocationPrompt DC.B    'Enter start location',0
endLocationPrompt   DC.B    'Enter end location',0



    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
