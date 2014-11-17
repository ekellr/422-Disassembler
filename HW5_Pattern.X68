*-----------------------------------------------------------
* Title      : Pattern Matching
* Written by : Robert Anderson
* Date       : 11/12/2014
* Description: A program that can search through memory and
*              find a pattern match using defined constants.
*-----------------------------------------------------------

begin       EQU         $3000          	* Org beginning address
exit        EQU         $2700         	* Simulator stop code address
bit         EQU         1               * Advance by one bit

    ORG    begin
    
START:                  

        MOVEA.L start_addr,A0    		* Load starting search address
        MOVEA.L end_range,A1   		    * Range of addresses to search through 
        MOVEA.L not_fnd,A2   		    * Search Result Address
        MOVE.B  srch_ptrn,D0   		    * Binary pattern to search
   
loop    CMP.B        (A0),D0       		* Search for test pattern    
        BEQ          match         		* Search pattern found in A0, save and exit
        ADDQ.L       #bit,A0      		* Increment address pointer
        CMPA.L       A1,A0         		* Are we done yet?
        BGT          no_match      		* Past range? Exit (A0 > A1)
        BRA          loop   			* Search incremented memory at A0

match   MOVE.L       A0,(A2)            * Save contents of data at A0 into A2
no_match   STOP      #exit           	* Break out of the simulator

    SIMHALT             ; halt simulator
    
**********************************************************************
*                           Data Section
**********************************************************************    
    
*=====================================================================
*                        Variables and Constants 
*=====================================================================    

start_addr DC.L         $00007000     
end_range  DC.L         $00008000 
not_fnd    DC.L         $FFFFFFFF
srch_ptrn  DC.B         253   

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
