ARMGNU ?=  C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin

AOPS = --warn --fatal-warnings -mcpu=cortex-m33

all : chap4.uf2


chap4.uf2: chap4.bin
	C:\PrincipalA\Outils\picotool uf2 convert chap4.elf chap4.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap4.o : chap4.s
	$(ARMGNU)\as $(AOPS)  chap4.s -o chap4.o
chap4.bin :   memmap.ld chap4.o 
	$(ARMGNU)\ld  -T memmap.ld  chap4.o  -o chap4.elf -M >chap4_map.txt
	$(ARMGNU)\objdump -D chap4.elf > chap4.list
	$(ARMGNU)\objcopy -O binary chap4.elf chap4.bin
#
#routinespicoUSBARM.o : ./routinespicoUSBARM.s
#	$(ARMGNU)\as $(AOPS)  ./routinespicoUSBARM.s -o ./routinespicoUSBARM.o
#routinesPicoARM.o : ../routinesARM/routinesPicoARM.s
#	$(ARMGNU)\as $(AOPS)  ../routinesARM/routinesPicoARM.s -o ../routinesARM/routinesPicoARM.o
#routinesMulticore.o : ./routinesMulticore.s
#	$(ARMGNU)\as $(AOPS)  ./routinesMulticore.s -o ./routinesMulticore.o
#xmodemArm.o : ./xmodemArm.s
#	$(ARMGNU)\as $(AOPS)  ./xmodemArm.s -o ./xmodemArm.o
#routinesLisp.o : ./routinesLisp.s
#	$(ARMGNU)\as $(AOPS)  ./routinesLisp.s -o ./routinesLisp.o
