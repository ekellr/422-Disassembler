*##########################################################################
* Title      : 
* Written by : Andrew Watson
*            : Elaine Keller
*            : Robert Anderson
* Date       : 11/14/2014
* Description: 
*##########################################################################

***************************************************************************
*                   Variable/Data Definitions
***************************************************************************

stack   EQU   $00005000
begin   EQU   $00005001
end     EQU   $00FFFFFE
byte    EQU   1
prgorg  EQU   $1000

    ORG    prgorg

***************************************************************************
*                   Begin processing active code
***************************************************************************
    
start:

        LEA         stack, SP           ;Initialize stack
        BRA         begin_address
        
*==========================================================================
*                   Enter / Validate beginning address 
*==========================================================================
 
begin_address:

       
        LEA         slPrompt,A1         ;Load address for starting loaction prompt
        MOVE.L      slPrompt,D1         ;Load display length to D1
        MOVE.L      #14,D0              ;14 = Display the NULL terminated string at (A1) without CR, LF.
        TRAP        #15                 ;Perform task 14 (display)
        
        LEA         startLocation,A1    ;Load address to store user input
        MOVE.B      #2,D0               ;2=Read string from keyboard and store at (A1), NULL (0) terminated, length returned in D1.W (max 80
        TRAP        #15                 ;Perform task 2 (input)
        
        BSR         enter_addr_edit_all
        CMP.W       #-1,D3              ;Did the edit pass?
        BEQ         begin_address       ;No, loop and ask for correct input
        
        MOVEA.L     D3,A3               ;Beginning address gets stored in A3
        
        LEA         spc,A1              ;Load address for starting loaction prompt
        MOVE.B      spc_len,D1          ;Load empty line length
        MOVE.L      #0,D0               ;0 = Display the NULL terminated string at (A1) with CR, LF.
        TRAP        #15                 ;Perform task 14 (display)

        
        BRA         end_address

*===========================================================================
*                   Enter / Validate ending address 
*===========================================================================

end_address:
        
        LEA         elPrompt,A1         ;Load address for ending loaction prompt
        ;MOVE.L     elPrompt,D1         ;Load display length to D1
        MOVE.L      #80,D1       ;did not like previous command, do not know why, it should have worked
        MOVE.L      #14,D0              ;14 = Display the NULL terminated string at (A1) without CR, LF.
        TRAP        #15                 ;Perform task 14 (display)
        
        MOVE.B      #2,D0               ;2=Read string from keyboard and store at (A1), NULL (0) terminated, length returned in D1.W (max 80
        TRAP        #15                 ;Perform task 2 (input)
        
        BSR         enter_addr_edit_all
        CMP.W       #-1,D3              ;Did the edit pass?
        BEQ         end_address         ;No, loop and ask for correct input

        MOVEA.L     D3,A4               ;Ending address gets stored in A4
        BRA         mainLoop

******************************************************************************
*                   Begin processing OP Codes
******************************************************************************
      
                
mainLoop:
        
        BRA         Exit_Program
        
loopend:

  
Exit_Program:
        
        simhalt
        
*==============================================================================
*                            variables and constants
*==============================================================================
        
slPrompt        DC.B    'Enter a starting address from $0 to $00FFFFFE: $',0
elPrompt        DC.B    'Enter a ending address from $0 to $00FFFFFE: $',0

clearLine       DC.B    $0D,$0A,0

invalidMsg      DC.B    ' Address entered is not within the specified range! Please try again',0
invCharMsg      DC.B    ' A Character entered is not a valid address character! Please try again',0


even_msg        DC.B    ' You must enter an even address!'

dataMessage     DC.B    'DATA: ',0
moveMessage     DC.B    'MOVE',0
moveaMessage    DC.B    'MOVEA',0
nopMessage      DC.B    'NOP',0 

startLocation   DC.L    0
endLocation     DC.L    0

spc             DC.B    ' '
spc_len         DC.B    spc_len-spc






*******************************************************************************
*                            SUB ROUTINES
*******************************************************************************
*==============================================================================
* enter_addr_edit_all - Enter address edit check to edit all errors  
*                       using multiple different error checking routines.
*
* Parameters -
*   Input   A1      The data that needs checked.
*   Input   D1      The number of characters input     
*   Output  D3      Returns '-1' when there is an error.
*==============================================================================

enter_addr_edit_all

*------------------------------------------------------------------------------
* Test for odd number of characters entered, not allowed
*------------------------------------------------------------------------------
       
        BSR         ck_boundry          ;check if the input is on a odd / even boundry
        CMP.W       #-1,D3              ;Is the address odd?
        BEQ         enter_addr_edit_all_exit     ;No, return

*------------------------------------------------------------------------------
* Ttest for character entered all being valid address characters
* Note: lower case a-f, gets converted to upper case A-F in D3
*------------------------------------------------------------------------------
        
        BSR         parseHexString      ;check if the input contains valid Hex characters
        CMP.W       #-1,D3              ;Does the address contain valid Hex characters?
        BEQ         enter_addr_edit_all_exit     ;No, return

*------------------------------------------------------------------------------
* Verify that the address entered is witin the range defined in the Equate
*------------------------------------------------------------------------------        
        
        BSR         ck_addr_range       ;is address entered witin the range 
                                        ;   as defined in the Equate? 
        CMP.W       #-1,D3              ;is the address  valid?
        BEQ         enter_addr_edit_all_exit     ;No, return

enter_addr_edit_all_exit:

        RTS                             ;return

*==============================================================================
* ck_boundry - Check the size of the data characters input and determine
*              if an odd number of characters was entered
*
* Parameters -
*   Input   A1      The data that needs checked for odd length.
*   Input   D1      The number of characters input     
*   Output  D3      Returns '-1' when there is an odd length.
*==============================================================================

ck_boundry:

        CLR.W       D3                  ;Clear the return

        CMP.B       #0,D1               ;Check for nothing entered
        BEQ         ck_size_error       ;Number of characters entered must be 
                                        ;greater than 0  
        
        
        * The program will branch to ck_size_error if D1 is greater than #8        
        CMP.B       #8,D1               ;Check for more than 8 characters entered
        BGT         ck_size_error       ;Number of characters entered must be less
                                        ;than 9
        
        MOVE.L      #$00000002,D2       ;Load a long 2 into D1
        DIVU        D2,D1               ;Divide address by 2
        SWAP        D1                  ;get remainder
        CMP.B       #$01,D1             ;Check for remainder of 1
        BEQ         ck_boundry_error    ;Number of characters entered must be an 
                                        ;even number   
  
        RTS                             ;return

*------------------------------------------------------------------------------
* ck_boundry_error - An odd number of characters was entered
*                  - Load error message and display it
*                  - Return error condition
*------------------------------------------------------------------------------
        
ck_boundry_error:

        LEA         even_msg,A1         ;Load odd error message into A1
        MOVE.L      even_msg,D1         ;Load error length to D1
        
        MOVE.L      #0,D0               ;Display n characters of string at (A1), 
                                        ; n is D1.W with CR, LF. 
        TRAP #15                        ;Display the error message
        MOVE.L #-1,D3                   ;Load -1 into return parameter
        RTS                             ;Return
        
*------------------------------------------------------------------------------
* ck_size_error -   The number of characters entered must be more than zero
*                  - Load error message and display it
*                  - Return error condition
*------------------------------------------------------------------------------
        
ck_size_error:

        LEA         invalidMsg,A1       ;Load invalid range message into A1
        MOVE.L      invalidMsg,D1       ;Load error length to D1
        
        MOVE.L      #0,D0               ;Display n characters of string at (A1), 
                                        ; n is D1.W with CR, LF. 
        TRAP        #15                 ;Display the error message
        MOVE.L      #-1,D3              ;Load -1 into return parameter
        RTS                             ;Return        


*==============================================================================
* parseHexString - Converts user input string into a valid memory address
*                - Stores parsed address data into D3
*                - Stores good/bad (1/0) data in D4 
*
* Hex values are stored as bytes in D2, the ASCII chart shows their value
*   The ASCII chart values we care about are in the ranges of: 
*                            Hex            Decimal
*       No Value           NULL = 0         0
*       Numeric Values:     0-9 = 30-39     48-57
*       Upper Case letters: A-F = 41-46     65-70
*       Lower Case letterc: a-f = 61-66     97-102

* Parameters -
*   Input   A1      The data that needs checked for valid input.
*   Output  D3      The return value, '-1' for error
*==============================================================================

parseHexString:

* setup any initializing item that do not get looped through
        CLR.W       D3                  ;Clear the return

        
*------------------------------------------------------------------------------
* NextHex - Loop through all bytes and vaildate the input
* Parameters -
*   Input   A1      The data that needs checked for valid input.
*   Output  D3      The return value, '-1' for error
*------------------------------------------------------------------------------
        
NextHex:

        MOVE.B      (A1)+,D2            ;Examine next character and decode it
        CMP.B       #0,D2               ;Check character for null 
        BEQ         NextHexReturn       ;Character is null (end of input)
        
*................................................................................
*  Check decimal values 0-9 by testing hexadecimal values 30-39
*................................................................................
                
        * The program will branch to hex_range_error if D2 is less than #30
        CMP.B       #48,D2              ;Hex value 30 = Ascii numeric value 0
        BLT         hex_range_error     ;Branch to handle range error hexidecimal
                                        ;processing
        
        * The program will branch to UcaseHex if D2 is greater than #39
        CMP.B       #57,D2              ;Hex value 30 = Ascii numeric value 0
        BGT         UcaseHex            ;Branch to upper case hexidecimal processing
        
        *a valid number was found within this range
        SUBI.B      #48,D2              ;Change ascii decimal code to actual value
        BRA         NextHexDone         ;Done parsing this byte


*..............................................................................
*  Check upper case values A-F by testing hexadecimal values 41-46
*..............................................................................

UcaseHex:

        * The program will branch to hex_range_error if D2 is less than #41
        CMP.B       #65,D2              ;Hex value 41 = Ascii character value 'A'
        BLT         hex_range_error     ;Branch to handle range error hexidecimal
                                        ;processing
        
        CMP.B       #70,D2              ;Hex value 46 = Ascii character value 'F'
        BGT         LcaseHex            ;Branch to handle lower case hexidecimal 
                                        ;processing
        
        *a valid number was found within this range
        SUBI.B      #55,D2              ;Change uppercase character to actual value
        BRA         NextHexDone         ;Done parsing this byte


*..............................................................................
*  Check lower case values a-f by testing hexadecimal values 61-66
*..............................................................................

LcaseHex
        
        * The program will branch to hex_range_error if D2 is less than #61
        CMP.B       #97,D2              ;Hex value 61 = Ascii character value 'a'
        BLT         hex_range_error     ;Branch to handle range error hexidecimal 
                                        ;processing

        CMP.B       #102,D2              ;Hex value 66 = Ascii character value 'f'
        BGT         hex_range_error     ;Branch to handle range error hexidecimal 
                                        ;processing

        *a valid number was found within this range
        SUBI.B      #87,D2              ;Change lowercase character to actual value
        BRA         NextHexDone         ;Done parsing this byte

NextHexDone:

        ASL.L       #4,D3               ; Make rooom for new byte in the return register
        ADD.B       D2,D3               ; Move the new byte into the return register
        BRA         NextHex             ; We're ready to parse the next byte
        
*-------------------------------------------------------------------------------------
* hex_range_error -  A character entered was within the valid range for a hex address
*                 -  Load error message and display it
*                 -  Return error condition
*-------------------------------------------------------------------------------------
        
hex_range_error:

        LEA         invCharMsg,A1       ;Load invalid range message into A1
        MOVE.L      invCharMsg,D1       ;Load error length to D1
        
        MOVE.L      #0,D0               ;Display n characters of string at (A1), 
                                        ; n is D1.W with CR, LF. 
        TRAP        #15                 ;Display the error message
        MOVE.L      #-1,D3              ;Load -1 into return parameter
        BRA         NextHexReturn
        
NextHexReturn:
        
        RTS                             ;Return      


*===============================================================================
* ck_addr_range - check the address input is within a valid memory address range
*                - Parsed address data into D3
*
* Parameters -
*   Input   A1      The data that needs checked for valid address.
*   Output  D3      The return value, '-1' for error
*===============================================================================


ck_addr_range:   

*------------------------------------------------------------------------------
* Verify that the address entered is witin the 
* beginning range ('begin') as defined in the Equate
*------------------------------------------------------------------------------   
            
        MOVE.L      #begin,D6           * Load minimum starting address
        CMP.L       D6,D3               * Is input at or above minimum?
        BLT         ck_addr_range_error 
        
*------------------------------------------------------------------------------
* Verify that the address entered is witin the 
* ending range ('end') as defined in the Equate
*------------------------------------------------------------------------------
        
        MOVE.L      #end,D6             * Load maximum starting address
        CMP.L       D6,D3               * Is input at or below maximum?
        BGT         ck_addr_range_error 
        BRA         ck_addr_done        ;done checking
        
*..............................................................................
* ck_addr_range_error -  A address entered is not within the 
*                        valid range for a hex address
*..............................................................................
        
ck_addr_range_error

        LEA         invCharMsg,A1       ;Load invalid range message into A1
        MOVE.L      invCharMsg,D1       ;Load error length to D1
        
        MOVE.L      #0,D0               ;Display n characters of string at (A1), 
                                        ; n is D1.W with CR, LF. 
        TRAP        #15                 ;Display the error message
        MOVE.L      #-1,D3              ;Load -1 into return parameter
        BRA         ck_addr_done 

ck_addr_done:

        RTS                             ;Return
        
        
*******************************************************************************
*                   Begin processing Effective Addresses
*******************************************************************************

Effective_label
*Need to JSR(Jump) or BSR(Branch) to Subroutine to get here

*IMPORTANT!!!!!!!!

*Not sure what i need to look through(A1, D1) through and where to return my 
*findings Maybe i am appending my findings to a data register for output dispaly

Effective_label_done

        RTS                             ;Return
        

end_of_program_START:
  
        END         START               ; last line of source








