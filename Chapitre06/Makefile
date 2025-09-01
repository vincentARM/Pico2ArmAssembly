ARMGNU ?=  C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin

AOPS = --warn --fatal-warnings -mcpu=cortex-m33

all : chap6.uf2


chap6.uf2: chap6.bin
	C:\PrincipalA\Outils\picotool uf2 convert chap6.elf chap6.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap6.o : chap6.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  chap6.s -o chap6.o
chap6.bin :   memmap.ld chap6.o routinesARMGit.o routinespicoUSBGit.o
	$(ARMGNU)\ld  -T memmap.ld  chap6.o ./routinesARMGit.o ./routinespicoUSBGit.o -o chap6.elf -M >chap6_map.txt
	$(ARMGNU)\objdump -D chap6.elf > chap6.list 
	$(ARMGNU)\objcopy -O binary chap6.elf chap6.bin


routinesARMGit.o : ./routinesARMGit.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinesARMGit.s -o ./routinesARMGit.o

routinespicoUSBGit.o : ./routinespicoUSBGit.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinespicoUSBGit.s -o ./routinespicoUSBGit.o