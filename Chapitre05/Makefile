ARMGNU ?=  C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin

AOPS = --warn --fatal-warnings -mcpu=cortex-m33

all : chap5.uf2


chap5.uf2: chap5.bin
	C:\PrincipalA\Outils\picotool uf2 convert chap5.elf chap5.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap5.o : chap5.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  chap5.s -o chap5.o
chap5.bin :   memmap.ld chap5.o routinesARMGit.o
	$(ARMGNU)\ld  -T memmap.ld  chap5.o ./routinesARMGit.o -o chap5.elf -M >chap5_map.txt
	$(ARMGNU)\objdump -D chap5.elf > chap5.list
	$(ARMGNU)\objcopy -O binary chap5.elf chap5.bin


routinesARMGit.o : ./routinesARMGit.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinesARMGit.s -o ./routinesARMGit.o

