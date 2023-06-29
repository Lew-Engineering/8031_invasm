"IAL"

* ****************************************************************************
* I8031.S - Inverse assembler for the Intel MCS-51 8031/8051 microcontroller
*           and variants
*
*           This file is to be compiled by the HP 10391B Inverse Assembler
*           Development Package V2.0 for HP/Agilent Logic Analyzers.
*
*           Tested with the Agilent 1671G, but should be compaitble with other
*           models (165X, 166X, 167X, 165XX, etc.).
*
* Written by Eddie Lew
*
* Edit History:
*
* 06-29-23 - First released version.
* 03-09-23 - Started file.
* ****************************************************************************

* ****************************************************************************
* How to build the inverse assembler
*
* 1. Run the following, using asm.exe from the HP 10391B package on a MS-DOS PC
*
*      asm I8031.S
*	
*    This generates a file named "I8031.R".
*
*    Note, the DOSBox application can be used on modern computers and operating
*    systems to emulate the MS-DOS environment that asm.exe requires.
*
* 2. Send "I8031.R" to the logic analyzer via its RS-232 port from COM1 on
*    your MS-DOS PC using ialdown.exe from the HP 10391B package:
*
*      ialdown I8031 "8031 Inverse Assembler" I8031.R 1 B
*
*    This will create a file named "I8031" in the logic analyzer.
*
*    Alternatively, send "I8031.R" to the logic analyzer via GPIB using the
*    following GPIB command:
*	
*      :mmemory:download 'I8031',internal0,'8031 Inverse Assembler',
*        -15614,#8XXXXXXXXZ...\n
*	
*    where
*      XXXXXXXX is the size of "I8031.R" plus 1, in ASCII decimal with leading
*        zeros
*      Z is the null charcter (it represents the 'B' used in ialdown command)
*      ... is the contents of the "I8031.R" file
*      \n is the newline character 0xA - this is required!    
*
*    The GPIB command above works for the 167XG, and might be different for
*    other logic analyzer models.  Refer to the documentation for your specific
*    model.
*
*    Note that you cannot just copy the raw "I8031.R" file via floppy disk or
*      FTP to the logic analyzer.  It needs to be transformed to an inverse
*      assembler format by the download process above, which creates the
*      file "I8031".
*
* 3. Load the I8031 inverse assembler into memory via the logic analyzer's
*    front panel controls.  Choose the file named "I8031".
*
*    It can also be loaded via the following GPIB command on the 167XG:
*
*      :mmemory:load:iassembler 'I8031',internal0,1,1
*
* ****************************************************************************

* ****************************************************************************
* Logic analyzer setup
*
* This is expected to be used with a CPU with external EPROM for code
* and external SRAM for data.  The EA- input (DIP pin 31) must be tied low.
*        
* The logic analyzer should be configured as follows (167X assumed below):
*
* 1. DATA label (8 bits) assigned to  
*      bit  0 = P0.0/AD0    DIP pin 39     POD 1, ch 0
*      bit  1 = P0.1/AD1    DIP pin 38     POD 1, ch 1
*      bit  2 = P0.2/AD2    DIP pin 37     POD 1, ch 2
*      bit  3 = P0.3/AD3    DIP pin 36     POD 1, ch 3
*      bit  4 = P0.4/AD4    DIP pin 35     POD 1, ch 4
*      bit  5 = P0.5/AD5    DIP pin 34     POD 1, ch 5
*      bit  6 = P0.6/AD6    DIP pin 33     POD 1, ch 6
*      bit  7 = P0.7/AD7    DIP pin 32     POD 1, ch 7
*
* 2. ADDR label (16 bits) assigned to
*      bit  0 = P0.0/AD0    DIP pin 39     POD 1, ch 0
*      bit  1 = P0.1/AD1    DIP pin 38     POD 1, ch 1
*      bit  2 = P0.2/AD2    DIP pin 37     POD 1, ch 2
*      bit  3 = P0.3/AD3    DIP pin 36     POD 1, ch 3
*      bit  4 = P0.4/AD4    DIP pin 35     POD 1, ch 4
*      bit  5 = P0.5/AD5    DIP pin 34     POD 1, ch 5
*      bit  6 = P0.6/AD6    DIP pin 33     POD 1, ch 6
*      bit  7 = P0.7/AD7    DIP pin 32     POD 1, ch 7
*      bit  8 = P2.0/A8     DIP pin 21     POD 1, ch 8
*      bit  9 = P2.1/A9     DIP pin 22     POD 1, ch 9
*      bit 10 = P2.2/A10    DIP pin 23     POD 1, ch 10
*      bit 11 = P2.3/A11    DIP pin 24     POD 1, ch 11
*      bit 12 = P2.4/A12    DIP pin 25     POD 1, ch 12
*      bit 13 = P2.5/A13    DIP pin 26     POD 1, ch 13
*      bit 14 = P2.6/A14    DIP pin 27     POD 1, ch 14
*      bit 15 = P2.7/A15    DIP pin 28     POD 1, ch 15
*
* 3. STAT label (5 bits) assigned to
*      bit  0 = RST         DIP pin 8      POD 2, ch 0
*      bit  1 = ALE         DIP pin 30     POD 1, J CLK, fall
*      bit  2 = PSEN-       DIP pin 29     POD 2, K CLK, rise
*      bit  3 = WR-         DIP pin 16     POD 3, L CLK, fall
*      bit  4 = RD-         DIP pin 17     POD 4, M CLK, rise
*
*    Note the PSEN- and RD- bits will always be latched high due to the timing
*    of the clocks.  The inverse assembler does not consider the states of
*    those bits, but they are required for the proper clocking of the other
*    data, address, and state bits.
* 
* 4. Use "state" acquisition mode
*
* 5. Set clocking to J-fall  = ALE
*                    K-rise  = PSEN-
*                    L-fall  = WR-
*                    M-rise  = RD-
*
*    That is, clock when
*        ALE fall OR PSEN- rise OR WR- fall OR RD- rise
*
*    Setup time should be 0.0 ns, hold time 4.0 ns.
*    Improper setup/hold time will cause the incorrect state of the 4 clock
*    signls to appear in the STAT label.
*
* 6. After loading the I8031 inverse assembler file, select "Invasm" in place
*    of "Hex" for the "DATA" column in the listing display.
*
* 7. After capturing data from the target system, if the DATA column shows
*    "undecoded data" or if the opcodes do not make sense (due to misalignment
*    with the start of an opcode, scroll the listing display so that the
*    data cycle for the start of a valid opcode is at the top line of the
*    display and select the "Invasm" field at the top of the screen.  This will
*    resychronize the inverse assembler with captured data.
*    Note this "Invasm" field is NOT the same one used for the DATA column.
*
* 8. Note that since the 8031 uses a multiplexed address/data bus, the 
*    lower 8 bits of the ADDR label will contain the opcode data on the
*    lines that display the instruction mnemonics.  The ADDR label of the
*    previous display line in the listing has the correct address for that
*    instruction.
*
* 9. Decoded instructions will show the absolute 16-bit address as an operand
*    in place of the 8-bit relative address or 11-bit 2K window address.
*    Otherwise the symbol name will be displayed if ADDR symbols are defined,
*    either as user symbols or loaded via the Symbol Utillity.  Symbols are
*    only used for the program address space, not the data address space.
*
* 10. When setting a trigger based on the address, this must be done when
*     ALE is low, since data is multiplexed with the address bus.  However
*     note that dummy cycles often have the address of the next instruction
*     in memory, so you may end up triggering on a dummy cycle rather then
*     than a real instruction cycle.
* ****************************************************************************

* ****************************************************************************
* Select CPU type
* ****************************************************************************

* Standard 8031, 8051, 80C31, 80C51, 8032, 8052, 80C32, 80C52 and others 
CPU_8031        CONSTANT        0

* Dallas / Maxim / Analog Devices DS80C310, DS80C320, DS80C323 and other
* high speed microcontroller variants
* This type has much fewer dummy bus cycles than the standard 8031
CPU_DS80C310    CONSTANT        1

* Set this to one of the CPU types above
CPU_TYPE        CONSTANT        CPU_8031

* ****************************************************************************
* Initilization	
* ****************************************************************************	

* Set list title row strings for the DATA label column
                DEFAULT_WIDTH   40               ; Display field width
                                                 
                LABEL_TITLE     "8031 mnemonic"  ; Replaces "DATA" label
                BASE_TITLE      "Hex"            ; User chooses "Invasm"

* ****************************************************************************
* Variables
* ****************************************************************************	

CAPT_REL        VARIABLE        0       ; Relative capture location
ADDR_HIGH       VARIABLE        0       ; High byte of 16-bit address
CNT_DUMMY       VARIABLE        0       ; Number of dummy bytes to add
OPCODE_L        VARIABLE        0       ; Lower 4 bits of opcode for dummy cyc
OPCODE_H        VARIABLE        0       ; Upper 4 bits of opcode for dummy cyc
ADDR_ABS        VARIABLE        0       ; 16-bit absolute code address
LEN_INSTR       VARIABLE        0       ; Length of current instruction to
                                        ; compute abs addr from relative addr

* ****************************************************************************
* Constants
* ****************************************************************************

* Display formats
DEC1_FMT        FORMAT          1,DEC,1          ; 1 bit,   in 1 decimal digit
DEC3_FMT        FORMAT          3,DEC,1          ; 3 bits,  in 1 decimal digit
HEX8_FMT        FORMAT          8,HEX,2          ; 8 bits,  in 2 hex digits
HEX11_FMT       FORMAT          11,HEX,4         ; 16 bits, in 4 hex digits
HEX16_FMT       FORMAT          16,HEX,4         ; 16 bits, in 4 hex digits

* Current state for this cycle
* There is no state for reading from the data SRAM, but is instead implied from
* MOVX opcode
STAT_ADDR       CONSTANT        11100B  ; ADDR has 16-bit address from 8031
STAT_OPCODE     CONSTANT        11110B  ; DATA has 8-bit read from code EPROM
STAT_WR         CONSTANT        10100B  ; DATA has 8-bit write to data SRAM

* Tags for captured logic analyzer locations
TAG_NONE        CONSTANT        0       ; Location not tagged
TAG_OPERAND     CONSTANT        1       ; Operand already processed
TAG_DUMMY       CONSTANT        2       ; Dummy/filler byte already processed
TAG_MOVX_WR     CONSTANT        4       ; External memory write due to MOVX
TAG_MOVX_RD_ADR CONSTANT        5       ; External memory read addr due to MOVX
TAG_MOVX_RD_DAT CONSTANT        6       ; External memory read data due to MOVX
TAG_MOVC_RD     CONSTANT        7       ; External code read due to MOVC

* Number of characters for the address field, before the mnemonic string
LEN_ADDR        CONSTANT        15

* Dummy bus cycle count for all 8031 opcodes
*
* A dummy bus cycle is defined as an ALE & PSEN- pair
* X-axis is lower 4 bits of opcode
* Y-axis is upper 4 bits of opcode
*
* Value is 0-3 dummy bus cycles for that opcode, in binary
* Special case 0x84 "DIV AB" has 7 dummy bus cycles (marked as 3 in table)
*              0xA4 "MUL AB" has 7 dummy bus cycles (marked as 3 in table)
*
*                                F E D C B A 9 8 7 6 5 4 3 2 1 0
DUMMY_0A        CONSTANT        01010101010101010101000101011001B ; 0x0*
DUMMY_1A        CONSTANT        01010101010101010101000101011001B ; 0x1*
DUMMY_2A        CONSTANT        01010101010101010101000001111001B ; 0x2*
DUMMY_3A        CONSTANT        01010101010101010101000001111001B ; 0x3*
DUMMY_4A        CONSTANT        01010101010101010101000001001010B ; 0x4*
DUMMY_5A        CONSTANT        01010101010101010101000001001010B ; 0x5*
DUMMY_6A        CONSTANT        01010101010101010101000001001010B ; 0x6*
DUMMY_7A        CONSTANT        00000000000000000000010011101010B ; 0x7*
DUMMY_8A        CONSTANT        10101010101010101010011110101010B ; 0x8*
DUMMY_9A        CONSTANT        01010101010101010101000010101001B ; 0x9*
DUMMY_AA        CONSTANT        10101010101010101010011111001010B ; 0xA*
DUMMY_BA        CONSTANT        01010101010101010101010101001010B ; 0xB*
DUMMY_CA        CONSTANT        01010101010101010101000101001010B ; 0xC*
DUMMY_DA        CONSTANT        10101010101010100000010101001010B ; 0xD*
DUMMY_EA        CONSTANT        01010101010101010101000101011001B ; 0xE*
DUMMY_FA        CONSTANT        01010101010101010101000101011001B ; 0xF*

* Dummy bus cycle count for all DS80C310 opcodes
*
* A dummy bus cycle is defined as an ALE & PSEN- pair
* X-axis is lower 4 bits of opcode
* Y-axis is upper 4 bits of opcode
* Value is 0-3 dummy bus cycles for that opcode, in binary
* Special case 0x84 "DIV AB" has 4 dummy bus cycles (marked as 3 in table)
*              0xA4 "MUL AB" has 4 dummy bus cycles (marked as 3 in table)
*
*                                F E D C B A 9 8 7 6 5 4 3 2 1 0
DUMMY_0B        CONSTANT        00000000000000000000000000010100B ; 0x0*
DUMMY_1B        CONSTANT        00000000000000000000000000010101B ; 0x1*
DUMMY_2B        CONSTANT        00000000000000000000000000110101B ; 0x2*
DUMMY_3B        CONSTANT        00000000000000000000000000110101B ; 0x3*
DUMMY_4B        CONSTANT        00000000000000000000000000000101B ; 0x4*
DUMMY_5B        CONSTANT        00000000000000000000000000000101B ; 0x5*
DUMMY_6B        CONSTANT        00000000000000000000000000000101B ; 0x6*
DUMMY_7B        CONSTANT        00000000000000000000000010000101B ; 0x7*
DUMMY_8B        CONSTANT        00000000000000000000001101000101B ; 0x8*
DUMMY_9B        CONSTANT        00000000000000000000000001000100B ; 0x9*
DUMMY_AB        CONSTANT        00000000000000000000001110000100B ; 0xA*
DUMMY_BB        CONSTANT        01010101010101010101010100000100B ; 0xB*
DUMMY_CB        CONSTANT        00000000000000000000000000000100B ; 0xC*
DUMMY_DB        CONSTANT        01010101010101010000010000000100B ; 0xD*
DUMMY_EB        CONSTANT        00000000000000000000000000000100B ; 0xE*
DUMMY_FB        CONSTANT        00000000000000000000000000000100B ; 0xF*

* ****************************************************************************
* Entry point
* ****************************************************************************

        SET     RETURN_FLAGS,0          ; Not the start of an opcode yet  
        SET     CAPT_REL,0              ; Capture memory relative load position

* Don't process operands or dummy filler if they are tagged from previous
* processing, since they are already handled
        LOAD    INPUT_TAG
        IF      17,16 = 0         THEN GOTO NOT_INSTR       ; Do not decode
        IF      2,0 = TAG_NONE    THEN GOTO CHECK_STAT      ; Untagged
        IF      2,0 = TAG_OPERAND THEN GOTO PROCESS_OPERAND ; Operand data
        IF      2,0 = TAG_DUMMY   THEN GOTO PROCESS_DUMMY   ; Dummy addr/data
        IF      2,0 = TAG_MOVX_WR THEN GOTO PROCESS_MOVX_WR ; MOVX data write
        IF      2,0 = TAG_MOVX_RD_ADR THEN GOTO PROCESS_MOVX_RA ; MOVX rd
        IF      2,0 = TAG_MOVX_RD_DAT THEN GOTO PROCESS_MOVX_RD ; MOVX rd
        IF      2,0 = TAG_MOVC_RD THEN GOTO PROCESS_MOVC_RD ; MOVC code read

        GOTO    UNKNOWN

* Do not decode instructions since user has not selected first valid opcode
* location with the "Invasm" button on the logic analyzer
NOT_INSTR
        LOAD    INPUT_DATA
        OUTPUT  "  undecoded data "
        OUTPUT  ACCUMULATOR,HEX8_FMT
        RETURN
        
* Operand from previously processed opcode
PROCESS_OPERAND
        OUTPUT  "  operand"             ; Label as generic operand
        RETURN
        
* Dummy cycles from previously processed opcode
PROCESS_DUMMY
        OUTPUT  "  dummy"               ; Label as dummy filler
        LOAD    INPUT_STATUS            ; Get current STAT pin states
        IF      4,0 = STAT_ADDR   THEN OUTPUT " addr"
        IF      4,0 = STAT_OPCODE THEN OUTPUT " data"
        RETURN

* External data memory write due to MOVX
PROCESS_MOVX_WR
        OUTPUT  "  ext data wr"         ; Label as external SRAM write
        LOAD    INPUT_STATUS            ; Get current STAT pin states
        IF      4,0 = STAT_ADDR THEN OUTPUT " addr"
        IF      4,0 = STAT_WR   THEN OUTPUT " data"
        RETURN

* External data memory read address due to MOVX
PROCESS_MOVX_RA
        OUTPUT  "  ext data rd addr"    ; Label as external SRAM read
        RETURN

* External data memory read data due to MOVX
PROCESS_MOVX_RD
        OUTPUT  "  ext data rd data"    ; Label as external SRAM read
        RETURN

* External code memory read due to MOVC
PROCESS_MOVC_RD
        OUTPUT  "  ext code rd"         ; Label as external EPROM access
        LOAD    INPUT_STATUS            ; Get current STAT pin states
        IF      4,0 = STAT_ADDR   THEN OUTPUT " addr"
        IF      4,0 = STAT_OPCODE THEN OUTPUT " data"
        RETURN

* Check if this is address, opcode, or data write
CHECK_STAT
        LOAD    INPUT_STATUS            ; Get current STAT pin states

        IF      4,0 = STAT_ADDR     THEN GOTO PROCESS_ADDR
        IF      4,0 = STAT_OPCODE   THEN GOTO PROCESS_OPCODE

        * The following should not normally occur, since it is handled by the
        * MOVX opcode handling above
        IF      3,0 = STAT_WR THEN GOTO PROCESS_WR

* ****************************************************************************
* Error - state is unknown, it might be in reset
* ****************************************************************************
UNKNOWN
        OUTPUT  "  unknown"
        RETURN

* ****************************************************************************
* ALE occured to latch 16-bit address
* ****************************************************************************
PROCESS_ADDR
        OUTPUT  "  addr "
        RETURN

* ****************************************************************************
* Write 8-bit data to external SRAM, this should not occur since it it is
* handled previously with the MOVX processing
* ****************************************************************************
PROCESS_WR
        LOAD    INITIAL_DATA
        OUTPUT  "  ext data wr"
        OUTPUT  ACCUMULATOR,HEX8_FMT
        RETURN
        
* ****************************************************************************
* 8-bit opcode from external code EPROM
* ****************************************************************************
PROCESS_OPCODE

        * Output address of this opcode or symbol if defined for ADDR label
        * Need to look one cycle back since ADDR for this cycle actually has
        * DATA in the lower 8 bits
        INPUT   REL,-1                  ; Get 16-bit address of this opcode
        IF      INPUT_ERROR = 0 THEN GOTO OUTPUT_ADDR
        OUTPUT  "XXXX "
        GOTO    OUTPUT_OPCODE
OUTPUT_ADDR
        LOAD    INPUT_ADDRESS
        STORE   ADDR_ABS                                ; Save for operand use
        IF_NOT_MAPPED THEN OUTPUT ACCUMULATOR,HEX16_FMT ; Symbol or 16-bit hex
        
        FETCH_POSITION                  ; Set position for printing the opcode
        IF      31,0 <= LEN_ADDR THEN POSITION ABS,LEN_ADDR+1
        OUTPUT  " "

OUTPUT_OPCODE
        SET     RETURN_FLAGS,1          ; This is the start of an opcode
        LOAD    INITIAL_DATA

        CASE_OF 7,4                     ; x0   x1    x2    x3    x4   x5-xF
          CALL  GROUP_0Y                ; NOP  AJMP  LJMP  RR    INC  INC
          CALL  GROUP_1Y                ; JBC  ACALL LCALL RRC   DEC  DEC
          CALL  GROUP_2Y                ; JB   AJMP  RET   RL    ADD  ADD
          CALL  GROUP_3Y                ; JNB  ACALL RETI  RLC   ADDC ADDC
          CALL  GROUP_4Y                ; JC   AJMP  ORL   ORL   ORL  ORL
          CALL  GROUP_5Y                ; JNC  ACALL ANL   ANL   ANL  ANL
          CALL  GROUP_6Y                ; JZ   AJMP  XRL   XRL   XRL  XRL
          CALL  GROUP_7Y                ; JNZ  ACALL ORL   JMP   MOV  MOV
          CALL  GROUP_8Y                ; SJMP AJMP  ANL   MOVC  DIV  MOV
          CALL  GROUP_9Y                ; MOV  ACALL MOV   MOVC  SUBB SUBB
          CALL  GROUP_AY                ; ORL  AJMP  MOV   INC   MUL  MOV
          CALL  GROUP_BY                ; ANL  ACALL CPL   CPL   CJNE CJNE
          CALL  GROUP_CY                ; PUSH AJMP  CLR   CLR   SWAP XCH
          CALL  GROUP_DY                ; POP  ACALL SETB  SETB  DA   XCHDD/DJNZ
          CALL  GROUP_EY                ; MOVX AJMP  MOVX  MOVX  CLR  MOV
          CALL  GROUP_FY                ; MOVX ACALL MOVX  MOVX  CPL  MOV
        CASE_END

* ****************************************************************************
* Add dummy cycles if necessary
*
* On the 8031 these dummy cycles occur when the number of cycles to execute
* the opcode is greater then the number of bytes in the opcode and operand
* divided by 2.  A cycle count of N will result in 2*N address/data
* transactions.
*
* On the DS80C310 they occur when the number of cycles to execute the opcode
* is greater than the number of bytes in the opcode and operand.
* ****************************************************************************

        * Need to get upper and lower 4 bits of the opcode to do the lookup
        * of the number of dummy cycles
        LOAD    INITIAL_DATA
        AND     0FH
        STORE   OPCODE_L                ; Store lower 4 bits of the opcode
	
        LOAD    INITIAL_DATA
        ROTATE  RIGHT,4
        AND     0FH
        STORE   OPCODE_H                ; Store upper 4 bits of the opcode

	* Choose correct table based on the CPU type
        IF      CPU_TYPE = CPU_8031     THEN GOTO DUMMY_8031
        IF      CPU_TYPE = CPU_DS80C310 THEN GOTO DUMMY_DS80C310

* Dummy cycles for original 8031 CPU
DUMMY_8031
        * Special case for 0x84 DIV AB and 0xA4 MUL AB
        * These have 7 dummy cycles, which don't fit in to the lookup table
        LOAD    INITIAL_DATA
        IF      7,0 = 084H THEN GOTO MULDIV_8031
        IF      7,0 = 0A4H THEN GOTO MULDIV_8031
        GOTO    DUMMY_H_8031
MULDIV_8031
        SET     CNT_DUMMY,7
        GOTO    LOOP_DUMMY

        * Get the correct table row based on the upper 4 bits of the opcode
DUMMY_H_8031
        CASE_OF OPCODE_H
          LOAD  DUMMY_0A
          LOAD  DUMMY_1A
          LOAD  DUMMY_2A
          LOAD  DUMMY_3A
          LOAD  DUMMY_4A
          LOAD  DUMMY_5A
          LOAD  DUMMY_6A
          LOAD  DUMMY_7A
          LOAD  DUMMY_8A
          LOAD  DUMMY_9A
          LOAD  DUMMY_AA
          LOAD  DUMMY_BA
          LOAD  DUMMY_CA
          LOAD  DUMMY_DA
          LOAD  DUMMY_EA
          LOAD  DUMMY_FA
        CASE_END

        GOTO    DUMMY_L                 ; Process based on opcode lower 4 bits
                
* Dummy cycles for DS80C310 CPU
DUMMY_DS80C310
        * Special case for 0x84 DIV AB and 0xA4 MUL AB
        * These have 4 dummy cycles, which don't fit in to the lookup table
        LOAD    INITIAL_DATA
        IF      7,0 = 084H THEN GOTO MULDIV_DS80C310
        IF      7,0 = 0A4H THEN GOTO MULDIV_DS80C310
        GOTO    DUMMY_H_DS80C310
MULDIV_DS80C310
        SET     CNT_DUMMY,4
        GOTO    LOOP_DUMMY

        * Get the correct table row based on the upper 4 bits of the opcode
DUMMY_H_DS80C310
        CASE_OF OPCODE_H
          LOAD  DUMMY_0B
          LOAD  DUMMY_1B
          LOAD  DUMMY_2B
          LOAD  DUMMY_3B
          LOAD  DUMMY_4B
          LOAD  DUMMY_5B
          LOAD  DUMMY_6B
          LOAD  DUMMY_7B
          LOAD  DUMMY_8B
          LOAD  DUMMY_9B
          LOAD  DUMMY_AB
          LOAD  DUMMY_BB
          LOAD  DUMMY_CB
          LOAD  DUMMY_DB
          LOAD  DUMMY_EB
          LOAD  DUMMY_FB
        CASE_END

        * Process based on the lower 4-bit of the opcode
DUMMY_L
        CASE_OF OPCODE_L
          NOP                          ; IAL does not support rotate by 0 bits
          ROTATE  RIGHT,2
          ROTATE  RIGHT,4
          ROTATE  RIGHT,6
          ROTATE  RIGHT,8
          ROTATE  RIGHT,10
          ROTATE  RIGHT,12
          ROTATE  RIGHT,14
          ROTATE  RIGHT,16
          ROTATE  RIGHT,18
          ROTATE  RIGHT,20
          ROTATE  RIGHT,22
          ROTATE  RIGHT,24
          ROTATE  RIGHT,26
          ROTATE  RIGHT,28
          ROTATE  RIGHT,30
        CASE_END

DUMMY_MASK
        AND     3                       ; Get value of 0 to 3
        STORE   CNT_DUMMY

        * Add the number of dummy cycles specified above
LOOP_DUMMY
        IF      CNT_DUMMY=0 THEN RETURN ; Done
        CALL    GET_NEXT_DUMMY          ; Mark as dummy cycle
        DECREMENT CNT_DUMMY
        GOTO    LOOP_DUMMY              ; Loop for next dummy cycle
        
* ****************************************************************************
* Opcodes with regular addressing modes
*
* x4 - Immeadiate, next byte has 8-bit constant (some exceptions)
* x5 - Memory direct, next byte has internal memory location 
* x6 - Register indirect @R0
* x7 - Register indirect @R1
* x8 - Register direct R0
* x9 - Register direct R1
* xA - Register direct R2
* xB - Register direct R3
* xC - Register direct R4
* xD - Register direct R5
* xE - Register direct R6
* xF - Register direct R7
* ****************************************************************************
GROUP_REGULAR
        ; Decode the opcode name
        CASE_OF 7,4
          OUTPUT "INC "                 ; 0x0y  INC  operand         y=4 -> A
          OUTPUT "DEC "                 ; 0x1y  DEC  operand         y=4 -> A
          OUTPUT "ADD A, "              ; 0x2y  ADD  A, operand
          OUTPUT "ADDC A, "             ; 0x3y  ADDC A, operand
          OUTPUT "ORL A, "              ; 0x4y  ORL  A, operand
          OUTPUT "ANL A, "              ; 0x5y  ANL  A, operand
          OUTPUT "XRL A, "              ; 0x6y  XRL  A, operand
          OUTPUT "MOV "                 ; 0x7y  MOV  operand, #data  y=4 -> A
          OUTPUT "MOV "                 ; 0x8y  MOV  direct, operand no y=4
          OUTPUT "SUBB A, "             ; 0x9y  SUBB A, operand
          OUTPUT "MOV "                 ; 0xAy  MOV  operand, direct no y=4,5
          OUTPUT "CJNE "                ; 0xBy  CJNE opr,#data,rel or A,opr,rel
          OUTPUT "XCH A, "              ; 0xCy  XCH  A, operand      no y=4
          OUTPUT "DJNZ "                ; 0xDy  DJNZ operand, rel    no y=4,6,7
          OUTPUT "MOV A, "              ; 0xEy  MOV  A, operand      no y=4
          OUTPUT "MOV "                 ; 0xFy  MOV  operand, A      no y=4
        CASE_END

* Special case for before processing operand
        IF      7,0 = 004H THEN GOTO INC_DEC_A ; 0x04 INC A
        IF      7,0 = 014H THEN GOTO INC_DEC_A ; 0x14 DEC A
        IF      7,0 = 074H THEN GOTO MOV_A     ; 0x74 MOV A,#data
        IF      7,0 = 085H THEN GOTO MOV_DIR   ; 0x85 MOV direct,direct 
        IF      7,4 = 008H THEN GOTO MOV_ADDR  ; 0x86-0x8f MOV direct,other
        IF      7,0 = 0B4H THEN GOTO CJNE_A    ; 0xB4 CJNE A,#data,rel
        IF      7,0 = 0B5H THEN GOTO CJNE_A    ; 0xB5 CJNE A,direct,rel
        GOTO    OPERAND_DECODE                 ; No special case

* Opcode 0x04 INC A and 0x14 DEC A, no other operand to process
INC_DEC_A
        OUTPUT  "A"
        RETURN

* Opcode 0x74 MOV A, #data
MOV_A   
	OUTPUT  "A"
        GOTO    GROUP_REGULAR_END

* Opcode 0x85 MOV direct, direct
* Need to read one more data byte to get past the normal operand
MOV_DIR
        CALL    GET_NEXT_BYTE           ; Direct source
        CALL    GET_NEXT_BYTE           ; Direct destination
        OUTPUT  ACCUMULATOR,HEX8_FMT
        OUTPUT  ", "
        DECREMENT CAPT_REL              ; Get back to first operand
        DECREMENT CAPT_REL
        DECREMENT CAPT_REL
        DECREMENT CAPT_REL
        LOAD    INITIAL_DATA
        GOTO    OPERAND_DECODE

* Opcode 0x86 to 0x8F MOV direct, R0-7 or @R0-1
MOV_ADDR
        CALL    GET_NEXT_BYTE           ; Data
        OUTPUT  ACCUMULATOR,HEX8_FMT
        OUTPUT  ", "
        LOAD    INITIAL_DATA
        GOTO    OPERAND_DECODE
	
* Opcode 0xB4 and 0xB5 CJNE A,...        
CJNE_A
        OUTPUT  "A"
        GOTO    GROUP_REGULAR_END
        
* Decode the operand
OPERAND_DECODE
        IF      3,0 <= 3 THEN GOTO ERROR
        IF      3,0 = 4  THEN GOTO OPERAND_DATA
        IF      3,0 = 5  THEN GOTO OPERAND_DIRECT
        IF      3,0 <= 7 THEN GOTO OPERAND_REG_INDIRECT
        IF      3,0 >= 8 THEN GOTO OPERAND_REG
	
* Unknown opcode, not handled here
ERROR
        OUTPUT  "ERROR"
        RETURN
        
* Operand is #data 8-bit constant
OPERAND_DATA
        CALL    GET_NEXT_BYTE           ; #data
        OUTPUT  "#"
        OUTPUT  ACCUMULATOR,HEX8_FMT
        GOTO    GROUP_REGULAR_END
        
* Operand is direct 8-bit internal memory address
OPERAND_DIRECT
        CALL    GET_NEXT_BYTE           ; direct
        OUTPUT  ACCUMULATOR,HEX8_FMT
        GOTO    GROUP_REGULAR_END
        
* Operand is indirect register @R0 or @R1
OPERAND_REG_INDIRECT
        OUTPUT  "@R"
        OUTPUT  ACCUMULATOR,DEC1_FMT
        GOTO    GROUP_REGULAR_END
	
* Operand is register R0 to R7
OPERAND_REG
        OUTPUT  "R"
        OUTPUT  ACCUMULATOR,DEC3_FMT

* Additional post-processing for select opcodes
GROUP_REGULAR_END
	LOAD    INITIAL_DATA
        IF      7,4=07H THEN GOTO MOV_DATA_POST ; MOV operand, #data
        IF      7,4=0AH THEN GOTO MOV_ADDR_POST ; MOV operand, direct
        IF      7,4=0BH THEN GOTO CJNE_POST     ; CJNE operand, #data, rel
        IF      7,4=0DH THEN GOTO DJNZ_POST     ; DJNZ operand, rel
        IF      7,4=0FH THEN OUTPUT ", A"       ; MOV operand, A
        IF      7,0=085H THEN GOTO MOV_DD_POST  ; MOV direct, direct
        RETURN

* Opcode 0x74 to 0x7f MOV operand, #data
MOV_DATA_POST
        CALL    GET_NEXT_BYTE           ; #data
        OUTPUT  ", #"
        OUTPUT  ACCUMULATOR,HEX8_FMT
        RETURN
                
* Opcode 0xA4 to 0xAF MOV operand, direct
MOV_ADDR_POST
        CALL    GET_NEXT_BYTE           ; direct
        OUTPUT  ", "
        OUTPUT  ACCUMULATOR,HEX8_FMT
        RETURN

* Opcode 0xB4 CJNE A, #data, rel
* Opcode 0xB5 CJNE A, direct, rel
* Opcode 0xB6 to 0xBF CJNE operand, #data, rel
CJNE_POST
        OUTPUT  ", "
        IF      7,0 <> 0B5H THEN OUTPUT  "#"
        CALL    GET_NEXT_BYTE           ; #data or direct
        OUTPUT  ACCUMULATOR,HEX8_FMT

        OUTPUT  ", "
        SET     LEN_INSTR,3             ; Relative to start of next opcode
        CALL    OUTPUT_ABS_FROM_REL     ; Output addr as symbol or 16-bit abs
        RETURN
	
* Opcode 0xD5, 0xD8 to 0xDf DJNZ operand, rel
DJNZ_POST
        OUTPUT  ", "
        IF      7,0=0D5H THEN SET LEN_INSTR,3 ;Relative to start of next opcode
        IF      7,0<>0D5H THEN SET LEN_INSTR,2;Relative to start of next opcode
        CALL    OUTPUT_ABS_FROM_REL     ; Output addr as symbol or 16-bit abs
        RETURN

* Opcode 0x85 MOV direct, direct
MOV_DD_POST
        INCREMENT CAPT_REL              ; Skip last opcode so that dummy cycles
        INCREMENT CAPT_REL              ; can be added afterwards
        RETURN
        
* ****************************************************************************
* Group 0x0y opcodes
* ****************************************************************************
GROUP_0Y
        * 0x04 to 0x0f INC opcode with regular operands
        IF      3,0 >= 4 THEN GOTO GROUP_REGULAR

        * Special case opcodes
        CASE_OF  1,0
          OUTPUT "NOP"                  ; 0x00 NOP
          GOTO   OPCODE_AJMP            ; 0x01 AJMP addr11
          GOTO   OPCODE_LJMP            ; 0x02 LJMP addr16
          OUTPUT "RR A"                 ; 0x03 RR A
        CASE_END
	
        RETURN

        * 0x02 LJMP addr16
OPCODE_LJMP
        OUTPUT  "LJMP "
        CALL    OUTPUT_OPER_ADDR16
        RETURN

* ****************************************************************************
* Group 0x1y opcodes
* ****************************************************************************
GROUP_1Y
        * 0x14 to 0x1F DEC opcode with regular operands
        IF      3,0 >= 4 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 1,0
          GOTO   OPCODE_JBC             ; 0x10 JBC bit, rel
          GOTO   OPCODE_ACALL           ; 0x11 ACALL addr11
          GOTO   OPCODE_LCALL           ; 0x12 LCALL addr16
          OUTPUT "RRC A"                ; 0x13 RRC A
        CASE_END
	
        RETURN

        * 0x10 JBC, bit, rel
OPCODE_JBC
        OUTPUT  "JBC "
        CALL    OUTPUT_OPER_VAL         ; bit
        OUTPUT  ", "
        SET     LEN_INSTR,3             ; Relative to start of next opcode
        CALL    OUTPUT_ABS_FROM_REL     ; Output addr as symbol or 16-bit abs
	RETURN
        
        * 0x12 LCALL addr16
OPCODE_LCALL
        OUTPUT  "LCALL "
        CALL    OUTPUT_OPER_ADDR16
        RETURN
	
* ****************************************************************************
* Group 0x2y opcodes
* ****************************************************************************
GROUP_2Y
        * ADD opcode with regular operands
        IF      3,0 >= 4 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 1,0
          GOTO   OPCODE_JB              ; 0x20 JB bit, rel
          GOTO   OPCODE_AJMP            ; 0x21 AJMP addr11
          OUTPUT "RET"                  ; 0x21 RET
          OUTPUT "RL A"                 ; 0x23 RL A
        CASE_END
	
        RETURN
	
        * 0x20 JB, bit, rel
OPCODE_JB
        OUTPUT  "JB "
        CALL    OUTPUT_OPER_VAL         ; bit
        OUTPUT  ", "
        SET     LEN_INSTR,3             ; Relative to start of next opcode
        CALL    OUTPUT_ABS_FROM_REL     ; Output addr as symbol or 16-bit abs
	RETURN
	
* ****************************************************************************
* Group 0x3y opcodes
* ****************************************************************************
GROUP_3Y
        * ADDC opcode with regular operands
        IF      3,0 >= 4 THEN GOTO GROUP_REGULAR

        * Special case opcodes
        CASE_OF 1,0
          GOTO   OPCODE_JNB             ; 0x30 JNB bit, rel
          GOTO   OPCODE_ACALL           ; 0x31 ACALL addr11
          OUTPUT "RETI"                 ; 0x32 RETI
          OUTPUT "RLC A"                ; 0x33 RLC A
        CASE_END
	
        RETURN
	
        * 0x30 JNB bit, rel
OPCODE_JNB
        OUTPUT  "JNB "
        CALL    OUTPUT_OPER_VAL         ; bit
        OUTPUT  ", "
        SET     LEN_INSTR,3             ; Relative to start of next opcode
        CALL    OUTPUT_ABS_FROM_REL     ; Output addr as symbol or 16-bit abs
	RETURN
	
* ****************************************************************************
* Group 0x4y opcodes
* ****************************************************************************
GROUP_4Y
        * ORL opcode with regular operands
        IF      3,0 >= 4 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 1,0
          GOTO   OPCODE_JC              ; 0x40 JC rel
          GOTO   OPCODE_AJMP            ; 0x41 AJMP addr11
          GOTO   OPCODE_ORL_A           ; 0x42 ORL direct, A
          GOTO   OPCODE_ORL_DATA        ; 0x43 ORL direct, #data
        CASE_END
	
        RETURN
	
        * 0x40 JC rel
OPCODE_JC
        OUTPUT  "JC "
        SET     LEN_INSTR,2             ; Relative to start of next opcode
        CALL    OUTPUT_ABS_FROM_REL     ; Output addr as symbol or 16-bit abs
	RETURN

        * 0x42 ORL direct, A
OPCODE_ORL_A
        OUTPUT  "ORL "
        CALL    OUTPUT_OPER_VAL
        OUTPUT  ", A"
	RETURN
	
        * 0x43 ORL direct, #data
OPCODE_ORL_DATA
        OUTPUT  "ORL "
        CALL    OUTPUT_OPER_VAL
        OUTPUT  ", #"
        CALL    OUTPUT_OPER_VAL        
	RETURN
        
* ****************************************************************************
* Group 0x5y opcodes
* ****************************************************************************
GROUP_5Y
        * ANL opcode with regular operands
        IF      3,0 >= 4 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 1,0
          GOTO   OPCODE_JNC             ; 0x50 JNC rel
          GOTO   OPCODE_ACALL           ; 0x51 ACALL addr11
          GOTO   OPCODE_ANL_A           ; 0x52 ANL direct, A
          GOTO   OPCODE_ANL_DATA        ; 0x53 ANL direct, #data
        CASE_END
	
        RETURN
	
        * 0x50 JNC rel
OPCODE_JNC
        OUTPUT  "JNC "
        SET     LEN_INSTR,2             ; Relative to start of next opcode
        CALL    OUTPUT_ABS_FROM_REL     ; Output addr as symbol or 16-bit abs
	RETURN

        * 0x52 ANL direct, A
OPCODE_ANL_A
        OUTPUT  "ANL "
        CALL    OUTPUT_OPER_VAL
        OUTPUT  ", A"
	RETURN
	
        * 0x53 ANL direct, #data
OPCODE_ANL_DATA
        OUTPUT  "ANL "
        CALL    OUTPUT_OPER_VAL
        OUTPUT  ", #"
        CALL    OUTPUT_OPER_VAL        
	RETURN
	
* ****************************************************************************
* Group 0x6y opcodes
* ****************************************************************************
GROUP_6Y
        * XRL opcode with regular operands
        IF      3,0 >= 4 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 1,0
          GOTO   OPCODE_JZ              ; 0x60 JZ rel
          GOTO   OPCODE_AJMP            ; 0x61 AJMP addr11
          GOTO   OPCODE_XRL_A           ; 0x62 XRL direct, A
          GOTO   OPCODE_XRL_DATA        ; 0x63 XRL direct, #data
        CASE_END
	
        RETURN
	
        * 0x60 JZ rel
OPCODE_JZ
        OUTPUT  "JZ "
        SET     LEN_INSTR,2             ; Relative to start of next opcode
        CALL    OUTPUT_ABS_FROM_REL     ; Output addr as symbol or 16-bit abs
	RETURN

        * 0x62 XRL direct, A
OPCODE_XRL_A
        OUTPUT  "XRL "
        CALL    OUTPUT_OPER_VAL
        OUTPUT  ", A"
	RETURN
	
        * 0x63 XRL direct, #data
OPCODE_XRL_DATA
        OUTPUT  "XRL "
        CALL    OUTPUT_OPER_VAL
        OUTPUT  ", #"
        CALL    OUTPUT_OPER_VAL        
        RETURN
	
* ****************************************************************************
* Group 0x7y opcodes
* ****************************************************************************
GROUP_7Y
        * MOV opcode with regular operands
        IF      3,0 >= 4 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 1,0
          GOTO   OPCODE_JNZ             ; 0x70 JNZ rel
          GOTO   OPCODE_ACALL           ; 0x71 ACALL addr11
          GOTO   OPCODE_ORL_C           ; 0x72 ORL C, bit
          OUTPUT "JMP @A+DPTR"          ; 0x73 JMP @A+DPTR
        CASE_END
	
        RETURN
	
        * 0x70 JNZ rel
OPCODE_JNZ
        OUTPUT  "JNZ "
        SET     LEN_INSTR,2             ; Relative to start of next opcode
        CALL    OUTPUT_ABS_FROM_REL     ; Output addr as symbol or 16-bit abs
	RETURN

        * 0x72 ORL C, bit
OPCODE_ORL_C
        OUTPUT  "ORL C,  "
        CALL    OUTPUT_OPER_VAL
	RETURN
	
* ****************************************************************************
* Group 0x8y opcodes
* ****************************************************************************
GROUP_8Y
        * MOV opcode with regular operands (no 0x84)
        IF      3,0 >= 5 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 1,0
          GOTO   OPCODE_SJMP            ; 0x80 SJMP rel
          GOTO   OPCODE_AJMP            ; 0x81 AJMP addr11
          GOTO   OPCODE_ANL_C           ; 0x82 ANL C, bit
          OUTPUT "MOVC A,@A+PC"         ; 0x83 MOVC A,@A+PC
        CASE_END
	
        * On 8031 skip the dummy cycle that occurs after MOVC
        * On DS80C310 skip the next instruction that occurs right after MOVC
	INCREMENT CAPT_REL              ; ALE
        INCREMENT CAPT_REL              ; Data

        * Skip dummy cycle
        INCREMENT CAPT_REL              ; ALE
        INCREMENT CAPT_REL              ; Data
	
        * Tag cycles as external memory read from MOVC
MARK_MOVCP_RD
        INCREMENT CAPT_REL              ; Address of memory read due to MOVC
        INPUT     REL,CAPT_REL
        IF        INPUT_ERROR <> 0 THEN RETURN
        TAG_WITH  TAG_MOVC_RD           ; Mark as a memory read
        
        INCREMENT CAPT_REL              ; Data of memory read due to MOVC
        INPUT     REL,CAPT_REL
        IF        INPUT_ERROR <> 0 THEN RETURN
        TAG_WITH  TAG_MOVC_RD           ; Mark as a memory read
	
        * Back up so that dummy cycles can be marked on return
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL

        IF        CPU_TYPE=CPU_DS80C310 THEN RETURN

        * On 8031 back up 2 more since it has 2 dummy cycles
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	
        RETURN
	
        * 0x80 SJMP rel
OPCODE_SJMP
        OUTPUT  "SJMP "
        SET     LEN_INSTR,2             ; Relative to start of next opcode
        CALL    OUTPUT_ABS_FROM_REL     ; Output addr as symbol or 16-bit abs
	RETURN

        * 0x82 ANL C, bit
OPCODE_ANL_C
        OUTPUT  "ANL C,  "
        CALL    OUTPUT_OPER_VAL
        RETURN

* ****************************************************************************
* Group 0x9y opcodes
* ****************************************************************************
GROUP_9Y
        * SUBB opcode with regular operands
        IF      3,0 >= 4 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 1,0
          GOTO   OPCODE_MOV_DPTR        ; 0x90 MOV DPTR, #data16
          GOTO   OPCODE_ACALL           ; 0x91 ACALL addr11
          GOTO   OPCODE_MOV_BITC        ; 0x92 MOV bit, C
          OUTPUT "MOVC A,@A+DPTR"       ; 0x93 MOVC A, @A+DPTR
        CASE_END
	
        * On 8031 skip the dummy cycle that occurs after MOVC
        * On DS80C310 skip the next instruction that occurs right after MOVC
	INCREMENT CAPT_REL              ; ALE
        INCREMENT CAPT_REL              ; Data

        * Skip dummy cycle
        INCREMENT CAPT_REL              ; ALE
        INCREMENT CAPT_REL              ; Data
	
        * Tag cycles as external memory read from MOVC
MARK_MOVCD_RD	
        INCREMENT CAPT_REL              ; Address of memory read due to MOVC
        INPUT     REL,CAPT_REL
        IF        INPUT_ERROR <> 0 THEN RETURN
        TAG_WITH  TAG_MOVC_RD           ; Mark as a memory read
        
        INCREMENT CAPT_REL              ; Data of memory read due to MOVC
        INPUT     REL,CAPT_REL
        IF        INPUT_ERROR <> 0 THEN RETURN
        TAG_WITH  TAG_MOVC_RD           ; Mark as a memory read
	
        * Back up so that dummy cycles can be marked on return
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	
        IF        CPU_TYPE=CPU_DS80C310 THEN RETURN

        * On 8031 back up 2 more since it has 2 dummy cycles
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	
        RETURN

        * 0x90 MOV DPTR, #data16
OPCODE_MOV_DPTR
        OUTPUT  "MOV DPTR, "
        CALL    OUTPUT_OPER_DATA16
	RETURN
        
        * 0x92 MOV bit, C
OPCODE_MOV_BITC
        OUTPUT  "MOV "
        CALL    OUTPUT_OPER_VAL
        OUTPUT  ", C"
        RETURN
        
* ****************************************************************************
* Group 0xAy opcodes
* ****************************************************************************
GROUP_AY
        * MOV opcode with regular operands (no 0xA4 or 0xA5)
        IF      3,0 >= 6 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 2,0
          GOTO   OPCODE_ORL_CIBIT       ; 0xA0 ORL C, /bit
          GOTO   OPCODE_AJMP            ; 0xA1 AJMP addr11
          GOTO   OPCODE_MOV_CBIT        ; 0xA2 MOV C, bit
          OUTPUT "INC DPTR"             ; 0xA3 INC DPTR
          OUTPUT "MUL AB"               ; 0xA4 MUL AB
        CASE_END
	
        RETURN

        * 0xA0 ORL C, /bit
OPCODE_ORL_CIBIT
        OUTPUT  "ORL C, /"
        CALL    OUTPUT_OPER_VAL
        RETURN
        
        * 0xA2 MOV C, bit
OPCODE_MOV_CBIT
        OUTPUT  "MOV C, "
        CALL    OUTPUT_OPER_VAL
        RETURN
	
* ****************************************************************************
* Group 0xBy opcodes
* ****************************************************************************
GROUP_BY
        * CJNE opcode with regular operands
        IF      3,0 >= 4 THEN GOTO GROUP_REGULAR
	
        * Special case opcodes
        CASE_OF 1,0
          GOTO   OPCODE_ANL_CIBIT       ; 0xB0 ANL C, /bit
          GOTO   OPCODE_ACALL           ; 0xB1 ACALL addr11
          GOTO   OPCODE_CPL_BIT         ; 0xB2 CPL bit
          OUTPUT "CPL C"                ; 0xB3 CPL C
        CASE_END
	
        RETURN

        * 0xB0 ANL C, /bit
OPCODE_ANL_CIBIT
        OUTPUT  "ANL C, /"
        CALL    OUTPUT_OPER_VAL
        RETURN
        
        * 0xB2 CPL bit
OPCODE_CPL_BIT
        OUTPUT  "CPL "
        CALL    OUTPUT_OPER_VAL
        RETURN
	
* ****************************************************************************
* Group 0xCy opcodes
* ****************************************************************************
GROUP_CY
        * XCH opcode with regular operands (no 0xC4)
        IF      3,0 >= 5 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 2,0
          GOTO   OPCODE_PUSH            ; 0xC0 PUSH direct
          GOTO   OPCODE_AJMP            ; 0xC1 AJMP addr11
          GOTO   OPCODE_CLR_BIT         ; 0xC2 CLR bit
          OUTPUT "CLR C"                ; 0xC3 CLR C
          OUTPUT "SWAP A"               ; 0xC4 SWAP A
        CASE_END
	
        RETURN

        * 0xC0 PUSH direct
OPCODE_PUSH
        OUTPUT  "PUSH "
        CALL    OUTPUT_OPER_VAL
        RETURN

        * 0xC2 CLR bit
OPCODE_CLR_BIT
        OUTPUT  "CLR "
        CALL    OUTPUT_OPER_VAL
        RETURN
	
* ****************************************************************************
* Group 0xDy opcodes
* ****************************************************************************
GROUP_DY
        * DJNZ opcode with regular operands (no 0xD4, 0xD6, or 0xD7)
        IF      3,0 = 5 THEN GOTO GROUP_REGULAR
        IF      3,0 >=8 THEN GOTO GROUP_REGULAR
        
        * Special case opcodes
        CASE_OF 2,0
          GOTO   OPCODE_POP             ; 0xD0 POP direct
          GOTO   OPCODE_ACALL           ; 0xD1 ACALL addr11
          GOTO   OPCODE_SETB            ; 0xD2 SETB bit
          OUTPUT "SETB C"               ; 0xD3 SETB C
          OUTPUT "DA A"                 ; 0xD4 DA A
        CASE_END
	
        RETURN

        * 0xD0 POP direct
OPCODE_POP
        OUTPUT  "POP "
        CALL    OUTPUT_OPER_VAL
        RETURN

        * 0xD2 SETB bit
OPCODE_SETB
        OUTPUT  "SETB "
        CALL    OUTPUT_OPER_VAL
        RETURN

* ****************************************************************************
* Group 0xEy opcodes
* ****************************************************************************
GROUP_EY
        * MOV opcode with regular operands (no 0xE4)
        IF      3,0 >= 5 THEN GOTO GROUP_REGULAR
	
        * Special case opcodes
        CASE_OF 2,0
          OUTPUT "MOVX A, @DPTR"        ; 0xE0 MOVX A, @DPTR
          GOTO   OPCODE_AJMP            ; 0xE1 AJMP addr11
          OUTPUT "MOVX A, @R0"          ; 0xE2 MOVX A, @R0
          OUTPUT "MOVX A, @R1"          ; 0xE3 MOVX A, @R1
          OUTPUT "CLR A"                ; 0xE4 CLR A
        CASE_END

        IF      7,0=0E4H THEN RETURN    ; Exit early for CLR
        
        * On 8031 skip the dummy cycle that occurs after MOVX
        * On DS80C310 skip the next instruction that occurs right after MOVX
	INCREMENT CAPT_REL              ; ALE
        INCREMENT CAPT_REL              ; Data

        * Tag cycles as external memory read from MOVX
        INCREMENT CAPT_REL              ; Address of memory read due to MOVX
        INPUT     REL,CAPT_REL
        IF        INPUT_ERROR <> 0 THEN RETURN
        TAG_WITH  TAG_MOVX_RD_ADR       ; Mark as a memory read
        
        INCREMENT CAPT_REL              ; Data of memory read due to MOVX
        INPUT     REL,CAPT_REL
        IF        INPUT_ERROR <> 0 THEN RETURN
        TAG_WITH  TAG_MOVX_RD_DAT       ; Mark as a memory read

        * Back up so that additional 8031 dummy cycles can be marked on return
        IF        CPU_TYPE=CPU_DS80C310 THEN RETURN ; None for DS80C310
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	
        RETURN
	
* ****************************************************************************
* Group 0xFy opcodes
* ****************************************************************************
GROUP_FY
        * MOV opcode with regular operands (no 0xF4)
        IF      3,0 >= 5 THEN GOTO GROUP_REGULAR
	
        * Special case opcodes
        CASE_OF 2,0
          OUTPUT "MOVX @DPTR, A"        ; 0xF0 MOVX @DPTR, A
          GOTO   OPCODE_ACALL           ; 0xF1 ACALL addr11
          OUTPUT "MOVX @R0, A"          ; 0xF2 MOVX @R0, A
          OUTPUT "MOVX @R1, A"          ; 0xF3 MOVX @R1, A
          OUTPUT "CPL A"                ; 0xF4 CPL A
        CASE_END

        IF      7,0=0F4H THEN RETURN    ; Exit early for CPL
        
        * On 8031 skip the dummy cycle that occurs after MOVX
        * On DS80C310 skip the next instruction that occurs right after MOVX
	INCREMENT CAPT_REL              ; ALE
        INCREMENT CAPT_REL              ; Data
	
        * Tag cycles as external memory write from MOVX
        INCREMENT CAPT_REL              ; Address of memory write due to MOVX
        INPUT     REL,CAPT_REL
        IF        INPUT_ERROR <> 0 THEN RETURN
        TAG_WITH  TAG_MOVX_WR           ; Mark as a memory write
        
        INCREMENT CAPT_REL              ; Data of memory write due to MOVX
        INPUT     REL,CAPT_REL
        IF        INPUT_ERROR <> 0 THEN RETURN
        TAG_WITH  TAG_MOVX_WR           ; Mark as a memory write
	
        * Back up so that additional 8031 dummy cycles can be marked on return
        IF        CPU_TYPE=CPU_DS80C310 THEN RETURN ; None for DS80C310
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	DECREMENT CAPT_REL
	
        RETURN
	
* ****************************************************************************
* AJMP addr11
*
* addr11 operand is displayed as absolute 16-bit address or symbol if defined
* for ADDR label
* ****************************************************************************
OPCODE_AJMP
        OUTPUT  "AJMP "

        * Get address bits 0 to 10 from opcode and operand
        ROTATE  LEFT,3                  ; Get address bits 8 to 10
        AND     0700H
        STORE   ADDR_HIGH
        CALL    GET_NEXT_BYTE           ; Get address bits 0 to 7
        INCLUSIVE_OR ADDR_HIGH          ; Create a 11-bit value
        STORE   ADDR_HIGH

        * Convert to absolute 16-bit address for display
        LOAD    ADDR_ABS                ; Address of this opcode
        ADD     2                       ; Add 2 to get 2K block that addr11
        AND     0F800H                  ; indexes into
        INCLUSIVE_OR ADDR_HIGH          ; Get absolute 16-bit addr

        * Display as absolute 16-bit address or symbol if defined for ADDR
        IF_NOT_MAPPED THEN OUTPUT  ACCUMULATOR,HEX16_FMT
        RETURN
        
* ****************************************************************************
* ACALL addr11
*
* addr11 operand is displayed as absolute 16-bit address or symbol if defined
* for ADDR label
* ****************************************************************************
OPCODE_ACALL
        OUTPUT  "ACALL "
	
        * Get address bits 0 to 10 from opcode and operand
        ROTATE  LEFT,3                  ; Get address bits 8 to 10
        AND     0700H
        STORE   ADDR_HIGH
        CALL    GET_NEXT_BYTE           ; Get address bits 0 to 7
        INCLUSIVE_OR ADDR_HIGH          ; Create 11-bit value
        STORE   ADDR_HIGH

        * Convert to absolute 16-bit address for display
        LOAD    ADDR_ABS                ; Address of this opcode
        ADD     2                       ; Add 2 to get 2K block that addr11
        AND     0F800H                  ; indexes into
        INCLUSIVE_OR ADDR_HIGH          ; Get absolute 16-bit addr

        * Display as absolute 16-bit address or symbol if defined for ADDR
        IF_NOT_MAPPED THEN OUTPUT  ACCUMULATOR,HEX16_FMT
        RETURN

* ****************************************************************************
* Output operand as one 16-bit immeadiate data "#data16"
* ****************************************************************************
OUTPUT_OPER_DATA16
        OUTPUT  "#"                     ; Immeadiate identified with leading #
        CALL    GET_NEXT_BYTE           ; Get MSB byte, bits 8 to 15
        ROTATE  LEFT,8                  ; Move it into the upper 8-bits
        AND     0FF00H
        STORE   ADDR_HIGH
        
        CALL    GET_NEXT_BYTE           ; Get LSB byte, bits 0 to 7
        INCLUSIVE_OR ADDR_HIGH          ; Create a 16-bit value
        OUTPUT  ACCUMULATOR,HEX16_FMT   ; Display as 4 hex digits
        RETURN
        
* ****************************************************************************
* Output operand as one 16-bit address "addr16" or symbol if defined for ADDR
* label
* ****************************************************************************
OUTPUT_OPER_ADDR16
        CALL    GET_NEXT_BYTE           ; Get MSB byte, bits 8 to 15
        ROTATE  LEFT,8                  ; Move it into the upper 8-bits
        AND     0FF00H
        STORE   ADDR_HIGH
        
        CALL    GET_NEXT_BYTE           ; Get LSB byte, bits 0 to 7
        INCLUSIVE_OR ADDR_HIGH          ; Create a 16-bit value
        IF_NOT_MAPPED THEN OUTPUT ACCUMULATOR,HEX16_FMT ; Symbol or 4-digit hex
        RETURN
	
* ****************************************************************************
* Output operand as one 8-bit value - "val"
* ****************************************************************************
OUTPUT_OPER_VAL
        CALL    GET_NEXT_BYTE           ; Get value
        OUTPUT  ACCUMULATOR,HEX8_FMT    ; Display as 2 hex digits
	RETURN

* ****************************************************************************
* Output operand as two 8-bit values - "val, val"
* ****************************************************************************
OUTPUT_OPER_2VAL
        CALL    GET_NEXT_BYTE           ; Get 1st value
        OUTPUT  ACCUMULATOR,HEX8_FMT    ; Display as 2 hex digits
        OUTPUT  ", "
        CALL    GET_NEXT_BYTE           ; Get 2nd value
        OUTPUT  ACCUMULATOR,HEX8_FMT    ; Display as 2 hex digits
	RETURN

* ****************************************************************************
* Output absolute 16-bit code address from 8-bit relative address
* or output symbol name instead if defined for ADDR label
* ****************************************************************************
OUTPUT_ABS_FROM_REL
        CALL    GET_NEXT_BYTE           ; Get 'rel' operand
        IF      7,0 < 07FH THEN GOTO ADD_REL
        
SUB_REL INCLUSIVE_OR 0FFFFFF00H         ; rel is negative, make it a 32-bit
                                        ; negative number
        
ADD_REL ADD     ADDR_ABS                ; Add relative value to current addr
        ADD     LEN_INSTR               ; Add the length of the instruction
        AND     0FFFFH                  ; Make it 16 bits
	
                                        ; Symbol or 16-bit abs addr
        IF_NOT_MAPPED THEN OUTPUT ACCUMULATOR,HEX16_FMT
        RETURN

* ****************************************************************************
* Get next operand byte
* ****************************************************************************
GET_NEXT_BYTE
        * Skip existing dummy or external memory access cycles
        INCREMENT CAPT_REL
        INPUT     REL,CAPT_REL           ; Load captured state for this location
        IF        INPUT_ERROR <> 0 THEN RETURN
        LOAD      INPUT_TAG
        IF        3,0=TAG_DUMMY THEN GOTO GET_NEXT_BYTE
        IF        2,2=1 THEN GOTO GET_NEXT_BYTE
	
                                         ; Skip ALE state
        INCREMENT CAPT_REL               ; Point to operand data
        INPUT     REL,CAPT_REL           ; Load captured data for this location
        IF        INPUT_ERROR <> 0 THEN RETURN
        LOAD      INPUT_DATA             ; Get operand data
        TAG_WITH  TAG_OPERAND            ; Tag it so this data will output
                                         ; "operand" on subsequent iterations
        RETURN
        
* ****************************************************************************
* Get next dummy filler byte
* ****************************************************************************
GET_NEXT_DUMMY
        * Skip existing dummy or external memory access cycles
        INCREMENT CAPT_REL
        INPUT     REL,CAPT_REL           ; Load captured state for this location
        IF        INPUT_ERROR <> 0 THEN RETURN
        LOAD      INPUT_TAG
        IF        2,0=TAG_DUMMY THEN GOTO GET_NEXT_DUMMY
        IF        2,2=1 THEN GOTO GET_NEXT_DUMMY

                                         ; Dummy ALE state
        INPUT     REL,CAPT_REL           ; Load captured addr for this location
        IF        INPUT_ERROR <> 0 THEN RETURN
        TAG_WITH  TAG_DUMMY              ; Tag it as dummy, will output
                                         ; "dummy addr" on subsequent iteration
	
        INCREMENT CAPT_REL               ; Dummy data
        INPUT     REL,CAPT_REL           ; Load captured data for this location
        IF        INPUT_ERROR <> 0 THEN RETURN
        TAG_WITH  TAG_DUMMY              ; Tag it as dummy, will output
                                         ; "dummy data" on subsequent iteration
        RETURN
