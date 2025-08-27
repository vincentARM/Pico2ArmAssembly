### Clignotement de la Led.

Dans le source du programme assembleur nous trouvons la directive .cpu cortex-m33 pour préciser le type de processeur puis toutes les constantes nécessaires au programme. Pour les codes GPIO il y a plus de constantes qu’utile dans ce programme ?

Vous remarquerez que les adresses des registres mémoire de base (comme IO_BANK0_BASE) sont différents de celles du rp2040 et aussi celles des déplacements des registres GPIO (comme GPIO_OUT_SET). Donc si vous reprenez des programmes assembleur du rp2040, il faudra veiller à bien utiliser les valeurs correctes.

Ensuite nous trouvons les sections .data et .bss qui seront inutiles ici, puis la section .text qui contient le code.

Dans la fonction principale nous trouvons un appel à la fonction de clignotement de la led puis un bloc très particulier absolument nécessaire pour le démarrage du programme. Ce bloc doit être situé dans les premiers 4096 caractères de la section .text et fourni au chargeur les indications nécessaires : exécutable ARM ou riscv, adresse de la pile, adresse de démarrage du programme. Pour plus de précision, consultez la section 5.9.5. Minimum viable image metadata de la datasheet du rp2350.

Puis le source contient la fonction de clignotement de la led et c’est tout. Voici les messages de compilation :

C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin\as --warn --fatal-warnings -mcpu=cortex-m33  chap1.s -o chap1.o
C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin\ld  -T memmap.ld  chap1.o  -o chap1.elf -M >chap1_map.txt
C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin\objdump -D chap1.elf > chap1.list
C:\PrincipalA\Outils\tools\arm-gnu-toolchain-13.3.rel1-mingw-w64-i686-arm-none-eabi\arm-none-eabi\bin\objcopy -O binary chap1.elf chap1.bin
C:\PrincipalA\Outils\picotool uf2 convert chap1.elf chap1.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
RP2350-E9: Adding absolute block to UF2 targeting 0x10010000

Vous remarquerez que le makefile contient une directive particulièrement importante : --offset 0x10000000 qui indique où le code doit être chargé dans la mémoire. Et par contre le bloc de contrôle donne l’adresse de la 1er instruction à exécuter :

.int 0x10000001       @ initial pointer address

A noter que l’adresse doit se terminer par 1 car il s’agit d’instructions thumb.

Après compilation et chargement du fichier uf2 sur le pico2, la led clignote et c’est tout !!!
