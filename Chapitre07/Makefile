ARMGNU ?=  C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin

AOPS = --warn --fatal-warnings -mcpu=cortex-m33

all : chap7.uf2


chap7.uf2: chap7.bin
	C:\PrincipalA\Outils\picotool uf2 convert chap7.elf chap7.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap7.o : chap7.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  chap7.s -o chap7.o
chap7.bin :   memmap.ld chap7.o routinesARMGit.o routinespicoUSBGit.o
	$(ARMGNU)\ld  -T memmap.ld  chap7.o ./routinesARMGit.o ./routinespicoUSBGit.o -o chap7.elf -M >chap7_map.txt
	$(ARMGNU)\objdump -D chap7.elf > chap7.list 
	$(ARMGNU)\objcopy -O binary chap7.elf chap7.bin


routinesARMGit.o : ./routinesARMGit.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinesARMGit.s -o ./routinesARMGit.o

routinespicoUSBGit.o : ./routinespicoUSBGit.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinespicoUSBGit.s -o ./routinespicoUSBGit.o