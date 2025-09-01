/* Programme assembleur ARM Raspberry pico 2*/
/* routines assembleur PICO 2*/
/* avril 2025 */ 
.syntax unified
.cpu cortex-m33
.thumb
.global ledEclats,attendre,resetPicoBoot,initHorloges

/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico2Git.inc"

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data

/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
//sBuffer:        .skip 80

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.thumb_func

/************************************/
/*        Led eclats            */
/***********************************/
/* r0 contient le nombre d'éclats */
.thumb_func
ledEclats:                       @ INFO: ledEclats
    push {r1-r4,lr}
    mov r4,r0                    @ nombre eclats
    ldr r0,iAdrPadSet            @ 
    mov r1,0b1000000             @ PADS_BANK0: GPIO0 Register IE: Input enable
    str r1,[r0,4 * LED_PIN]
    
    ldr r0,iAdrPadClr
    mov r1,0b100000000           @ PADS_BANK0: GPIO0 Register ISO: Pad isolation control
    str r1,[r0,4 * LED_PIN]
    
    mov r1,GPIO_FUNC_SIO         @ init code fonction 
    ldr r0,iAdriGpioCtrl0
    str r1,[r0,8 * LED_PIN]
    
    mov r2,0
    movt r2,0xD000               @ adresse SIO_BASE
    mov r1,1
    lsl r1,r1,LED_PIN            @ déplacement bit à gauche
    str r1,[r2,GPIO_OE_SET]
1:
    str r1,[r2,GPIO_OUT_SET]     @ allumage led
    mov r0,250
    bl attendre
    str r1,[r2,GPIO_OUT_CLR]     @ extinction led
    mov r0,250
    bl attendre 
	subs r4,r4,1                 @ decrement le nombre d eclats
	bgt 1b                       @ et boucle
	
    pop {r1-r4,pc}
.align 2
iAdriGpioCtrl0:     .int IO_BANK0_BASE + GPIO0_CTRL
iAdrPadSet:         .int PADS_BANK0_BASE + GPIO0_CTRL + ATOMIC_SET
iAdrPadClr:         .int PADS_BANK0_BASE + GPIO0_CTRL + ATOMIC_CLEAR  
.align 2

/******************************************************************/
/*     initialisation   horloges                                          */ 
/******************************************************************/
initHorloges:                             @ INFO: initHorloge
    push {lr}
    
    bl initOscCristal
    
    bl pll_init
    bl init_clk_sys
 
    
    pop {pc}
.align 2
iAdrSioBase:            .int SIO_BASE
iAdrClocks:             .int CLOCKS_BASE
iAdrClocksSet:          .int CLOCKS_BASE + 0x2000


/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur attente   */
.thumb_func
attendre:                     @ INFO: attendre
    push {r1,lr}
	mov r1,0x6E36             @ 150mhz  2 instructions soit 16 picosecondes  
	movt r1,1                 @ pour 0x16E36 soit 93750
	mul r0,r0,r1              @ 16 * 93750 * r0= 1000  = 150000000  soit 1 s
1:
    subs r0,r0, 1
    bne 1b
    pop {r1,pc}
.align 2	
/******************************************************************/
/*     initialisation  cristal oscillateur                                          */ 
/******************************************************************/
/* voir paragraphe 8.2. Crystal oscillator (XOSC)  */
.equ XOSC_BASE,         0x40048000
.equ XOSC_CTRL,         0x00 
.equ XOSC_STARTUP,      0xC
.equ XOSC_STATUS,       4
.equ XOSC_ENABLE_12MHZ, 0xfabaa0
.equ CLK_SYS_RESUS_CTRL, 0x84
.thumb_func
initOscCristal:                     @ INFO: initOscCristal
    push {r1-r6,lr}
    movs r1,0
    ldr r4,iAdrCLOCKS_BASE
    ldr r6,iAdrResusctrl
    str  r1, [r6]
    
    ldr r6,iAdrOscBase
	mov r5,0x2f
    str  r5, [r6, #XOSC_STARTUP]     @ 
                                    
    ldr r3,iParamOsc
    str  r3, [r6, #XOSC_CTRL]        @ Activate XOSC. r3 = XOSC_ENABLE_12MHZ 

1:  ldr  r0, [r6, #XOSC_STATUS]      @ Wait for stable flag (in MSB)
    cmp r0,0
    bge  1b

  pop {r1-r6,pc}
.align 2    
iAdrCLOCKS_BASE:        .int CLOCKS_BASE 
iParamClk:              .int 0x860
iAdrOscBase:            .int XOSC_BASE
iAdrOscBaseSet:         .int XOSC_BASE + ATOMIC_SET
iParamOsc:              .int XOSC_ENABLE_12MHZ            @
iAdrResusctrl:          .int CLOCKS_BASE + CLK_SYS_RESUS_CTRL
/***********************************/
/*       Init Pll SYS              */
/***********************************/
.equ PLL_CS,            0
.equ PLL_PWR,           4
.equ PLL_FBDIV_INT,     8
.equ PLL_PRIM,           0xC
.equ PLL_PWR_PD_BITS,   1
.equ PLL_PWR_VCOPD_BITS,  0x00000020
.equ PLL_PWR_POSTDIVPD_BITS, 8
.equ PLL_CS_LOCK_N_BITS,   0x40000000
/* cf datasheet     8.6 PLL  */
/*  PLL SYS: 12 / 1 = 12MHz * 125 = 1500MHZ / 5 / 2 = 150MHz  */
.thumb_func
pll_init:                   @ INFO: pll_init voir chapitre 8.6
    push    {r4,lr}
    
    bl pll_reset
    
    ldr  r4,iAdrPllSysSet
    movs r1,1               @ valeur refdiv (diviseur)
    str  r1,[r4,PLL_CS]     @ dans registre controle
    
    ldr  r0,ipllLock
    ldr  r4,iAdrPllSys
1:
    ldr  r2, [r4,PLL_CS]    @ boucle attente lock
    tst  r2,r0
    bne  1b                 @ attente lock 

    movs r0,125             @ pour pll_sys @ 125 avant
    movs r3,PLL_PWR_PD_BITS ||  PLL_PWR_VCOPD_BITS      @ 21
    str  r0, [r4,PLL_FBDIV_INT]   @ stocke la frequence 
    ldr  r1,iAdrPllSyspwrclear
    str  r3, [r1]           @ stocke 0x21 base + pwr + 0x3000
    ldr  r3,ipllLock
2:
    ldr  r2,[r4,PLL_CS]      @ charge registre CS 
    ands r2,r3
    bne  2b                  @ attente lock 
    
    movs r3,PLL_PWR_POSTDIVPD_BITS
    movs r0,2                @ postdiv2
    lsls r0,r0, 12
    movs r2,5                @ postdiv1  pour pll sys
    lsls r2,r2, 16
    orrs r2,r0
    str  r2,[r4,PLL_PRIM]     @ stocke les valeurs des 2 diviseurs (soit 2 *5 =10)
    
    str  r3, [r1]             @ stocke 8 dans base + pwr + 0x3000 clear
    pop  {r4, pc}
.align 2
iAdrPllSys:              .int PLL_SYS_BASE 
iAdrPllSysSet:           .int PLL_SYS_BASE + ATOMIC_SET
iAdrPllSyspwrset:        .int PLL_SYS_BASE + ATOMIC_SET + PLL_PWR
iAdrPllSyspwrclear:      .int PLL_SYS_BASE + ATOMIC_CLEAR + PLL_PWR
ipllLock:                .int PLL_CS_LOCK_N_BITS
/***********************************/
/*       reset Pll SYS   */              
/***********************************/
/* cf datasheet     7.5 subsystem reset  */
.equ RESETS_RESET,                  0
.equ RESETS_DONE,                   8
.equ RESETS_RESET_PLL_SYS_BITS,     0x00004000
.equ RESETS_RESET_PLL_USB_BITS,     0x00008000
.thumb_func
pll_reset:                        @ INFO: pll_reset
    push    {lr}
    ldr r1,iPllReset  
    ldr r0,iAdrResetBaseClr       @ reset général sauf 4 sous systèmes  
    ldr r2,iAdrResetBaseSet
    str r1,[r2,RESETS_RESET]
    str r1,[r0,RESETS_RESET]
    ldr r2,iAdrResetBase
1:
    ldr r3,[r2,#RESETS_DONE]      @ boucle attente reset ok
    tst r3,r1
    beq 1b
    
    pop {pc}
.align 2 
iAdrResetBase:        .int RESETS_BASE
iAdrResetBaseSet:     .int RESETS_BASE + ATOMIC_SET
iAdrResetBaseClr:     .int RESETS_BASE + ATOMIC_CLEAR
iPllReset:            .int RESETS_RESET_PLL_SYS_BITS | RESETS_RESET_PLL_USB_BITS
/***********************************/
/*       Init hologe systeme    */
/***********************************/
.equ CLK_SYS_CTRL,        0x3C
.equ CLK_SYS_DIV,         0x40
.equ CLK_SYS_SELECTED,    0x44
init_clk_sys:                     @ INFO: init_clk_sys
    push {r4,lr}
    movs   r2,0x1
    lsls   r2, r2, #16            @  bit 16 à 1
    ldr    r3, iAdrClkSysDiv      @ adresse diviseur horloge système
    str    r2, [r3]               @ met 1 dans le bit 16 du diviseur


    ldr    r0,iParSysClr          @ bits 0 et 5 et 6 7
    ldr    r3,iAdrClkSys          @ adresse controle horloge système
    ldr    r2, [r3]               @ charge le registre controle 
    ldr    r4,iAdrClkSysClr
    str r0,[r4]                   @ efface les bits 0 et 5,6 7
    movs r0,10
    bl attendre
    movs r1,0b0000001             @ valeur 0 dans bits 5,6 et 1 dans bit 0 et 1
    ldr    r4,iAdrClkSysSet
    str    r1, [r4]               @ stocke nouvelle valeur dans les bits 0,1 6,7,8

    ldr    r1,iAdrClkSysSel       @ adresse CLK_SYS_SELECTED
    movs   r3,#0b11               @ pour tester le bit 0
3:
    ldr    r2, [r1]
    tst    r2,r3                  @ test bit 0 et 1 
    beq   3b                      @ boucle attente

    pop {r4,pc}
.align 2
iAdrClkSys:              .int  CLOCKS_BASE + CLK_SYS_CTRL
iAdrClkSysXor:           .int  CLOCKS_BASE + CLK_SYS_CTRL + ATOMIC_XOR
iAdrClkSysSet:           .int  CLOCKS_BASE + CLK_SYS_CTRL + ATOMIC_SET
iAdrClkSysClr:           .int  CLOCKS_BASE + CLK_SYS_CTRL + ATOMIC_CLEAR
iAdrClkSysDiv:           .int  CLOCKS_BASE + CLK_SYS_DIV
iAdrClkSysSel:           .int  CLOCKS_BASE + CLK_SYS_SELECTED
iParSysClr:              .int  0b0000000011100001


/************************************/
/*       relance demarrage pico2 bootrom             */
/***********************************/
/* voir paragraphe 5.4.8.24. reboot */
resetPicoBoot:                 # INFO: resetPicoBoot
    push {r1-r4,lr}
    mov r0,'R'           @ code reboot
    mov r1,'B' 
    mov r2,2
    mov r3,100
    mov r4,0
    bl appelFctRom

100:
    pop {r1-r4,pc}
.align 2

/************************************/
/*       appel des fonctions de la Rom   */
/***********************************/
/* voir la datasheet  paragraphe 5.4. Bootrom APIs */
/* r0 Code 1  */
/* r1 code 2  */
/* r2 parametre fonction 1 */
/* r3 parametre fonction 2 */
/* r4 parametre fonction 3 */
.thumb_func
appelFctRom:                   @ INFO: appelFctRom
    push {r2-r5,lr}            @ save  registers 
    lsls r1,#8                 @ conversion des codes
    orrs r0,r1
    ldr r1,ptRom_table_lookup
    movs r2,#0
    ldrh r2,[r1]               @ sur 2 octets seulement
    ldr r1,ptFunctionTable
    movs r3,#0
    ldrh r3,[r1]               @ sur 2 octets seulement
    movs r1,0x4                @ ou 0x10 nonsecure ou 0x4
    blx r2                     @ recherche adresse fonction
 
    ldrh r5,[r0]               @ charge adresse de la fonction sur 2 octets
    ldr r0,[sp]                @ Comme r2 et r3 peuvent être écrasés par l appel précedent
    ldr r1,[sp,4]              @ récupération des paramétres 1 et  2 pour la fonction
    movs r2,r4                 @ parametre 3 fonction
    movs r3,0                  @ init parametre 4
    blx r5                     @ et appel de la fonction trouvée 

    pop {r2-r5,pc}             @ restaur registers
.align 2
ptRom_table_lookup:     .int 0x18
ptFunctionTable:        .int 0x14
