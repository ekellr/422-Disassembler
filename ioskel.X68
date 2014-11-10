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
        
        MOVE.B  #50,D0 ;close all files
        TRAP    #15
        
        LEA fileNamePrompt,A1 ;prompt for name of file
        MOVE.L  #13,D0
        TRAP    #15
        
        MOVE.B  #2,D0 ;get file name from user and store at A1
        TRAP    #15 ***A1 currently fileNamePrompt
        
        MOVE.B  #51,D0 ;set for task to open existing file
                       ;with the file name
        TRAP    #15
        CMP.W   #2,D0 ;check if file succesfully opened (2 represents error)
        BRA     badfileopen ***todo:loop back if file not found
        
        LEA     fileOneID,A2
        MOVE.L  D1,(A2) ;store file id
        
        *****READ IN PROGRAM******
        MOVE.B  
        
        
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
fileNamePrompt      DC.B    'Enter file name',0
fileOneID           DC.L    0


    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
