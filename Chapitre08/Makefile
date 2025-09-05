ARMGNU ?=  C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin

AOPS = --warn --fatal-warnings -mcpu=cortex-m33 -mfpu=vfp -mfloat-abi=hard

all : chap8.uf2


chap8.uf2: chap8.bin
	C:\PrincipalA\Outils\picotool uf2 convert chap8.elf chap8.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap8.o : chap8.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  chap8.s -o chap8.o
chap8.bin :   memmap.ld chap8.o routinesARMGit.o routinespicoUSBGit.o routineConvFloat32.o
	$(ARMGNU)\ld  -T memmap.ld  chap8.o ./routinesARMGit.o ./routinespicoUSBGit.o ./routineConvFloat32.o -o chap8.elf -M >chap8_map.txt
	$(ARMGNU)\objdump -D chap8.elf > chap8.list 
	$(ARMGNU)\objcopy -O binary chap8.elf chap8.bin


routinesARMGit.o : ./routinesARMGit.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinesARMGit.s -o ./routinesARMGit.o

routinespicoUSBGit.o : ./routinespicoUSBGit.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinespicoUSBGit.s -o ./routinespicoUSBGit.o
	
routineConvFloat32.o :  ./routineConvFloat32.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routineConvFloat32.s -o ./routineConvFloat32.o