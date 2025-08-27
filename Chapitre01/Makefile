ARMGNU ?=  C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin

AOPS = --warn --fatal-warnings -mcpu=cortex-m33

all : chap1.uf2


chap1.uf2: chap1.bin
	C:\PrincipalA\Outils\picotool uf2 convert chap1.elf chap1.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap1.o : chap1.s
	$(ARMGNU)\as $(AOPS)  chap1.s -o chap1.o
chap1.bin :   memmap.ld chap1.o 
	$(ARMGNU)\ld  -T memmap.ld  chap1.o  -o chap1.elf -M >chap1_map.txt
	$(ARMGNU)\objdump -D chap1.elf > chap1.list
	$(ARMGNU)\objcopy -O binary chap1.elf chap1.bin
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
