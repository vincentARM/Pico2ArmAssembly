ARMGNU ?=  C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin

AOPS = --warn --fatal-warnings -mcpu=cortex-m33

all : chap9.uf2


chap9.uf2: chap9.bin
	C:\PrincipalA\Outils\picotool uf2 convert chap9.elf chap9.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap9.o : chap9.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  chap9.s -o chap9.o
chap9.bin :   memmap.ld chap9.o routinesARMGit.o routinespicoUSBGit.o routinespicoCoproc.o
	$(ARMGNU)\ld  -T memmap.ld  chap9.o ./routinesARMGit.o ./routinespicoUSBGit.o ./routinespicoCoproc.o -o chap9.elf -M >chap9_map.txt
	$(ARMGNU)\objdump -D chap9.elf > chap9.list 
	$(ARMGNU)\objcopy -O binary chap9.elf chap9.bin


routinesARMGit.o : ./routinesARMGit.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinesARMGit.s -o ./routinesARMGit.o

routinespicoUSBGit.o : ./routinespicoUSBGit.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinespicoUSBGit.s -o ./routinespicoUSBGit.o
routinespicoCoproc.o : ./routinespicoCoproc.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinespicoCoproc.s -o ./routinespicoCoproc.o	