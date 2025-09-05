## Introduction

Dans cette partie, nous allons nous intéresser à la programmation assembleur ARM sans l’utilisation du sdk C++ sur le pico 2.
Le pico2 dispose d’un processeur RP2350 avec 2 cœurs ARM cortex M33 ce qui autorise de nouvelles instructions par rapport aux cœurs M0+ du rp2040.
Il dispose aussi d ‘un processeur Hazard3 avec 2 coeurs riscv, et nous verrons dans une autre partie la programmation en assembleur riscv.

Mon intention n'est pas de vous proposer un cours sur les instructions assembleur ARM mais plutôt de vous donner un aperçu des possibilités de l'assembleur sur le pico2 et de vous proposer des petits programmes qui peuvent vous éviter de nombreuses dificultés.

Je vous conseille de téléchargez la datasheet rp2350 sur le site de raspberry et la documentation sur les instructions assembleur ARM sur le site : https://developer.arm.com/documentation/den0013/0400/Introduction-to-Assembly-Language/The-ARM-instruction-sets

### Les outils :

En ce qui me concerne, je programme avec notepad++, mais vous pouvez utiliser n’importe quel éditeur.

Pour compiler en assembleur arm, il faut installer le compilateur et le linker à partir du site :
https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

Téléchargez et installer dans votre propre répertoire outil la version que vous souhaitez.

Pour convertir le fichier .elf en fichier .uf2 il faut utiliser l’utilitaire picotool.exe. Pour cela il faut récupérer l’exécutable dans un projet développé avec le sdk dans le répertoire  \build\_deps\picotool du projet.

Il faut créer un fichier makefile dont voici un exemple pour le 1er programme de cette série :
```
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
```

Et il faut un fichier memmap.ld utilisé par le linker dont voici un exemple :

```
MEMORY
{
  flash      (rx)  : ORIGIN = 0x10000000, LENGTH = 2048k
  ram      (rwx) : ORIGIN = 0x20000000, LENGTH =   0x00080000
}

/* heap is just after bss section */
__HEAP_SIZE  = 64K;

STACK_SIZE = 0x4000;

/* this is to eliminate RWX permission error for text segment */
PHDRS
{
  text PT_LOAD FLAGS(5);
  data PT_LOAD FLAGS(6);
  bss PT_LOAD FLAGS(6);
}

/* Section Definitions */
SECTIONS
{

    .text :
    {
       /*  KEEP(*(.vectors .vectors.*))  pour simplifier */
        *(.text*)
        *(.rodata*)
    } > flash   :text

    . = ALIGN(4);
    _debutFlashData = . ;
    .data :
    {
      _debutRamData = . ;
     . = ALIGN(2);
        *(.data*);
    } > ram AT >flash  :data
    
    
     /* .bss section which is used for uninitialized data */
      . = ALIGN(4);
     _debutRamBss = . ;
    .bss (NOLOAD) :
    {
        *(.bss*)
        *(COMMON)
    } > ram  :bss
     _finRamBss = . ;
     /* heap starts after bss and grows bottom up */
     .heap (COPY) :
    {
    . = ALIGN(4);
     _debutHeap = . ;

    . = . + __HEAP_SIZE;
    . = ALIGN(4);
    __HeapLimit = .;    /* used for checking stack/heap overflow */
    end = .;            /* used by NEWLIB */

  } > ram


    /* stack section */
    .stack (NOLOAD):
    {
        . = ALIGN(8);
        . = . + STACK_SIZE;
        _stack = .;
        . = ALIGN(8);
    } > ram

    _end = . ;
}
```

Dans le répertoire chapitre1 vous trouverez le programme habituel pour faire clignoter la led. Vous y trouverez aussi le makefile et le fichier  memmap.ld.

  [ Chapitre1](https://github.com/vincentARM/Pico2ArmAssembly/tree/main/Chapitre01)  Clignotement Led.

  [ Chapitre2](https://github.com/vincentARM/Pico2ArmAssembly/tree/main/Chapitre02)  Allumage et extinction de la Led.
  
  [ Chapitre3](https://github.com/vincentARM/Pico2ArmAssembly/tree/main/Chapitre03)  Utilisation du core1

  [ Chapitre4](https://github.com/vincentARM/Pico2ArmAssembly/tree/main/Chapitre04)  Utilisation horloge systeme

  [ Chapitre5](https://github.com/vincentARM/Pico2ArmAssembly/tree/main/Chapitre05) Mise en place VTOR et traitement des exceptions
  
  [ Chapitre6](https://github.com/vincentARM/Pico2ArmAssembly/tree/main/Chapitre06) Connexion série USB

  [ Chapitre7](https://github.com/vincentARM/Pico2ArmAssembly/tree/main/Chapitre07) Utilsation des macros, affichage registres et mémoire

  [ Chapitre8](https://github.com/vincentARM/Pico2ArmAssembly/tree/main/Chapitre08) Mesure de la température capteur ADC


 [ Chapitre9](https://github.com/vincentARM/Pico2ArmAssembly/tree/main/Chapitre09) Coprocessur double CDC
