# 8031_invasm

8031/8051 inverse assembler for Hewlett-Packard and Agilent logic analyzers

Eddie Lew, Lew Engineering, 6/29/2023


# INTRODUCTION

This project includes inverse assemblers for the Intel 8031 and 8051 
microcontrollers and high-speed variants to be used with older Hewlett-Packard
and Agilent logic analyzers.

The inverse assembler allows the assembly language mnemonics being executed
on the target system to be shown on the logic analyzer display when the logic
analyzer is probing the microcontroller's data/address bus and control signals.

![intro](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/97f948a8-5f0e-4636-ade7-1ddcb41b13f8)

# SUPPORTED LOGIC ANALYZERS

These inverse assemblers have been tested specifically on the Agilent 1671G
logic analyzer, but they should be compatible with other similar models
including

- HP 1650 / 1651 series
- HP 1660 series
- HP 1670A, 1671A, 1672A
- HP 1670D, 1671D, 1672D
- HP 1670E, 1671E, 1672E
- HP/Agilent 1670G, 1671G, 1672G
- HP 16500 series

Newer HP/Agilent/Keysight logic analyzers that internally use the Windows
operating system are not supported.


# SUPPORTED TARGET DEVICES

The I8031.S inverse assembler source supports the following devices:
- 8031
- 8051 (when using external ROM for code)
- 80C31
- 80C51 (when using external ROM for code)
- 8032
- 8052 (when using external ROM for code)
- 80C32
- 80C52 (when using external ROM for code)
- and other similar devices with the same bus timing as the 8031

The I80C310.S inverse assembler source supports the following devices from
Dallas, Maxim, and Analog Devices:
- DS80C310
- DS80C320
- DS80C323
- and other similar devices with the same bus timing as the DS80C310

The DS80C3XX family uses the same opcodes as the 8031, but with fewer dummy
cycles in the bus timing.  This reduces the execution time for several opcodes.


# INVERSE ASSEMBLER DEVELOPMENT SOFTWARE

The inverse assembler source files are designed to be compiled by the 
Hewlett-Packard / Agilent / Keysight "10391B Inverse Assembler Development
Package (Version 2.00)", available at

  https://www.keysight.com/us/en/lib/software-detail/instrument-firmware-software/10391b-inverse-assembler-development-package-version-0200-sw575.html

A direct download link is

  https://www.keysight.com/us/en/assets/ndx/9018-31995/miscellaneous/10391B-Inverse-Assembler-Development-Package-v2-0.zip

The above development package must be installed on a PC-DOS / MS-DOS system in
order to compile the inverse assemblers from source.  The DOSBox application
can be used to run the assembler in a virutal machine on a modern Windows or
MacOS computer.

Documentation for the development package is at

  https://www.keysight.com/us/en/assets/9018-01037/reference-guides/9018-01037.pdf

It is only necessary to use the development package if you intend to modify the 8031 inverse assembler.
If you want to use the inverse assembler as is, precompiled files that can be directly copied to
the logic analyzer are in the bin directory.

# DIRECTORIES

The "src" directory contains the inverse assembler source files.
- I8031.S - inverse assembler source file for standard 8031 microcontrollers
- I80C310.S - inverse assembler source file for high-speed 8031 compatible microcontrollers
- 8031.BAT - DOS batch file that compiles I8031.S and send the created I8031.R file to the logic analyzer via the COM1 serial port
- 80C310.BAT - DOS batch file that compiles I80C310.S and send the created I80C310.R file to the logic analyzer via the COM1 serial port
- 8031.CMD - Used by the 8031.BAT file to send I8031.R to the logic analyzer
- 80C310.CMD - Used by the 80C310.BAT file to send I80C310.R to the logic analyzer

The "bin" directory contains the inverse assembler binary files that are output
from the HP 10391B inverse assembler package.  These are included here as a
convenience if the user does not want to compile the .S files.
- I8031 - final inverse assembler binary for standard 8031 microcontrollers, to be loaded on the logic analzyer via ftp or floppy
- I80C310 - final inverse assembler binary for high-speed 8031 compatible microcontrollers, to be loaded on the logic analyzer via ftp or floppy
- I8031.R - intermediate compiled inverse assembler for standard 8031 microcontrollers, output from the development package
- I80C310.R - intermediate compiled inverse assembler for high-speed 8031 compatible microcontrollers, output from the development package

# LOADING THE INVERSE ASSEMBLER ON THE LOGIC ANALYZER

1. Get the I8031 and I80C310 files from the bin directory of this repository.

2. If the logic analyzer is connected to an Ethernet network, the I8031 and I80C310 files can be transfered
   to the logic analyzer with the ftp command.
   Below is the sequence for the 167XG; other models might be different.
   Replace "ana" with the host name of your logic analyzer.
```
% ftp ana
Connected to ana.
220    167XG V03.02 FUSION FTP server (Version 3.3) ready.
Name (ana:user): data
230 User DATA logged in.
ftp> cd system/disk/hard
200 Remote Directory changed to "/system/disk/hard".
ftp> binary
200 Type set to Image.
ftp> put I8031
200 PORT command ok.
150 Opening data connection for I8031 (192.168.0.39,54117).
226 Transfer complete.
8192 bytes sent in 0.000166 seconds (47.1 Mbytes/s)
ftp> put I80C310
200 PORT command ok.
150 Opening data connection for I80C310 (192.168.0.39,54117).
226 Transfer complete.
8192 bytes sent in 0.000166 seconds (47.1 Mbytes/s)
ftp> 
```

3. If the logic analyzer is not connected to an Ethernet network, you can transfer the I8031 and I80C31 files via floppy disk.

4. Activate the inverse assembler file I8031 or I80C310 using the logic analyzer's front panel controls.

![file_load](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/0ca3e452-1bc0-41e5-acc0-a64c33b78511)

   It can also be activated via the following GPIB command on the 167XG:
*      :mmemory:load:iassembler 'I8031',internal0,1,1
   or
*      :mmemory:load:iassembler 'I80C310',internal0,1,1

# LOGIC ANALYZER CONFIGURATION

This is expected to be used with a CPU with external EPROM for code
and external SRAM for data.  The EA- input (DIP pin 31) must be tied low.
       
The logic analyzer should be configured as follows (167X assumed below):

1. DATA label (8 bits) assigned to
```
     bit  0 = P0.0/AD0    DIP pin 39     POD 1, ch 0
     bit  1 = P0.1/AD1    DIP pin 38     POD 1, ch 1
     bit  2 = P0.2/AD2    DIP pin 37     POD 1, ch 2
     bit  3 = P0.3/AD3    DIP pin 36     POD 1, ch 3
     bit  4 = P0.4/AD4    DIP pin 35     POD 1, ch 4
     bit  5 = P0.5/AD5    DIP pin 34     POD 1, ch 5
     bit  6 = P0.6/AD6    DIP pin 33     POD 1, ch 6
     bit  7 = P0.7/AD7    DIP pin 32     POD 1, ch 7
```
2. ADDR label (16 bits) assigned to
```
     bit  0 = P0.0/AD0    DIP pin 39     POD 1, ch 0
     bit  1 = P0.1/AD1    DIP pin 38     POD 1, ch 1
     bit  2 = P0.2/AD2    DIP pin 37     POD 1, ch 2
     bit  3 = P0.3/AD3    DIP pin 36     POD 1, ch 3
     bit  4 = P0.4/AD4    DIP pin 35     POD 1, ch 4
     bit  5 = P0.5/AD5    DIP pin 34     POD 1, ch 5
     bit  6 = P0.6/AD6    DIP pin 33     POD 1, ch 6
     bit  7 = P0.7/AD7    DIP pin 32     POD 1, ch 7
     bit  8 = P2.0/A8     DIP pin 21     POD 1, ch 8
     bit  9 = P2.1/A9     DIP pin 22     POD 1, ch 9
     bit 10 = P2.2/A10    DIP pin 23     POD 1, ch 10
     bit 11 = P2.3/A11    DIP pin 24     POD 1, ch 11
     bit 12 = P2.4/A12    DIP pin 25     POD 1, ch 12
     bit 13 = P2.5/A13    DIP pin 26     POD 1, ch 13
     bit 14 = P2.6/A14    DIP pin 27     POD 1, ch 14
     bit 15 = P2.7/A15    DIP pin 28     POD 1, ch 15
```
3. STAT label (5 bits) assigned to
```
     bit  0 = RST         DIP pin 8      POD 2, ch 0
     bit  1 = ALE         DIP pin 30     POD 1, J CLK, fall
     bit  2 = PSEN-       DIP pin 29     POD 2, K CLK, rise
     bit  3 = WR-         DIP pin 16     POD 3, L CLK, fall
     bit  4 = RD-         DIP pin 17     POD 4, M CLK, rise
```
   Note the PSEN- and RD- bits will always be latched high due to the timing
   of the clocks.  The inverse assembler does not consider the states of
   those bits, but they are required for the proper clocking of the other
   data, address, and state bits.

4. Use "state" acquisition mode

5. Set clocking to
```
     J-fall  = ALE
     K-rise  = PSEN-
     L-fall  = WR-
     M-rise  = RD-
```
   That is, clock when
   
       ALE fall OR PSEN- rise OR WR- fall OR RD- rise

   Setup time should be -0.5 ns, hold time 4.5 ns.
   
   Improper setup/hold time will cause the incorrect state of the 4 clock signals to appear in the STAT label.

6. After loading the inverse assembler file, select "Invasm" in place of "Hex" for the "DATA" column in the listing display.

The screenshots below are an example of how to set up the Agilent 1671G to be used with the 8031 inverse assembler.
The setup for other logic analyzer models is similar, but may not be exactly the same.

Configuration screen

![config](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/0c6c632d-5f0a-4529-9e9f-e567629411c8)

Format screen

![format_1](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/8b2933a6-dc8e-4277-8e52-bc92720aa1fe)

![format_2](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/e4d2f25a-e735-45f2-ab77-d5dffec16688)

Master clock screen

![master_clock](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/022279a4-d7a2-4c1b-918d-7e11bc6cebd5)

Setup and hold screen

![setup_hold](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/7e59d506-4db0-47fa-b896-1b678c9991d5)

Trigger screen

![trigger_1](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/25abc2df-8cc8-4217-aecb-5ee27533d0ee)

![trigger_2](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/a74df448-fafc-4311-b7c3-a77226e5583a)

The following GPIB commands result in a similar configuration on the Agilent 1671G.
Text including and after "//" are comments and are not part of the GPIB command.

```
:select 1                              // Allow ":machine*" commands to work

:machine1:name '8031'                  // Set machine name to match CPU type

:machine1:assign 1,2,3,4               // Pods 1,2,3,4 used
:machine2:assign none                  // Machine2 not used

:machine1:type state                   // Need state mode for inverse assembler
:machine2:type off 
                                       // Master clock definition
:machine1:sformat:master J, fall       // ALE falling
:machine1:sformat:master K, ris        // PSEN- rising
:machine1:sformat:master L, fall       // WR- falling
:machine1:sformat:master M, ris        // RD- rising

:machine1:sformat:sethold 1,9          // Setup/hold -0.5 ns / 4.5 ns on all 
:machine1:sformat:sethold 2,9          // 4 pods
:machine1:sformat:sethold 3,9 
:machine1:sformat:sethold 4,9 

:machine1:sformat:remove all           // Remove all pod channel labels
                                       // Assign channels to labels
:machine1:sformat:label 'ADDR', pos, #H0, #H0000, #H0000, #H0000, #HFFFF 
:machine1:sformat:label 'DATA', pos, #H0, #H0000, #H0000, #H0000, #H00FF 
:machine1:sformat:label 'STAT', pos, #HF, #H0000, #H0000, #H0001, #H0000 

                                       // Load inverse assembler from hard disk
:mmemory:load:iassembler 'I8031',internal0,1,1 

:machine1:strigger:clear all           // Clear state triggers

:machine1:slist:remove                 // Clear state list columns
:machine1:slist:column 1, 'ADDR', hex  // Address lines
:machine1:slist:column 2, 'DATA', iass // Inverse assembler output
:machine1:slist:column 3, 'STAT', bin  // RST/ALE/PSEN-/WR-/RD-

:machine1:swaveform:remove             // Clear state waveforms
:machine1:swaveform:insert 'ADDR', overlay  // Address lines
:machine1:swaveform:insert 'DATA', overlay  // Data lines shared w/ ADDR
:machine1:swaveform:insert 'STAT', overlay  // RST/ALE/PSEN-/WR-/RD-

:menu 1,7                              // Show list display
```

# USING THE LISTING DISPLAY

1. After capturing data from the target system, if the DATA column shows
   "undecoded data" or if the opcodes do not make sense (due to misalignment
   with the start of an opcode), scroll the listing display so that the
   adderess cycle for the start of a valid opcode is at the top line of the
   display and select the "Invasm" button at the top of the screen.  This will
   resynchronize the inverse assembler with captured data.
   Note this "Invasm" button is NOT the same one used for the DATA column.

2. Note that since the 8031 uses a multiplexed address/data bus, the 
   lower 8 bits of the ADDR label will contain the opcode data on the
   lines that display the instruction mnemonics.  The ADDR label of the
   previous display line in the listing has the correct address for that
   instruction.

3. Decoded instructions will show the absolute 16-bit address as an operand
   in place of the 8-bit relative address or 11-bit 2K window address.
   Otherwise the symbol name will be displayed if ADDR symbols are defined,
   either as user symbols or loaded via the Symbol Utility.  Symbols are
   only used for the program address space, not the data address space.

4. When setting a trigger based on the address, this must be done when
   ALE is low, since data is multiplexed with the address bus.  However
   note that dummy cycles often have the address of the next instruction
   in memory, so you may end up triggering on a dummy cycle rather than
   a real instruction cycle.
