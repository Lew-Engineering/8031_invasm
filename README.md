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
- 80C51
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
- I8031.R - compiled inverse assembler for standard 8031 microcontrollers
- I80C310.R - compiled inverse assembler for high-speed 8031 compatible microcontrollers

Note there is a special procedure for sending the .R files to the logic
analyzer; they cannot be copied to the logic analyzer via floppy disk or FTP.
Use the .BAT files described above, or see the instructions at the top of the
I8031.S or I80C310.S files for more details.


# USAGE

Detailed instructions for compiling, uploading, and using the inverse assemblers
are included at the top of the I8031.S and I80C310.S files.

The instructions also describe how to configure the logic analyzer and the
connections to the microcontroller signal pins.

# LOGIC ANALYZER CONFIGURATION

The screenshots below are an example of how to set up the Agilent 1671G to be used with the 8031 inverse assembler.
The setup for other logic analyzer models is similar, but may not be exactly the same.

Loading the inverse assembler screen
![file_load](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/0ca3e452-1bc0-41e5-acc0-a64c33b78511)

Configuration screen
![config](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/0c6c632d-5f0a-4529-9e9f-e567629411c8)

Format screen
![format_1](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/8b2933a6-dc8e-4277-8e52-bc92720aa1fe)
![format_2](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/e4d2f25a-e735-45f2-ab77-d5dffec16688)

Trigger screen
![trigger_1](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/25abc2df-8cc8-4217-aecb-5ee27533d0ee)
![trigger_2](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/a74df448-fafc-4311-b7c3-a77226e5583a)

Master clock screen
![master_clock](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/022279a4-d7a2-4c1b-918d-7e11bc6cebd5)

Setup and hold screen
![setup_hold](https://github.com/Lew-Engineering/8031_invasm/assets/108096699/20e48fb2-7e50-47c1-b15d-a026ea04a1bc)
