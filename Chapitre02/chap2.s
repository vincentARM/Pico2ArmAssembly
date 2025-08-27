/* Programme assembleur ARM Raspberry pico 2 */

.syntax unified
.cpu cortex-m33
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.equ LED_PIN,      25
.equ ADRSTACK,     0x20040800           @ adresse de la pile

.equ ATOMIC_XOR,   0x1000
.equ ATOMIC_SET,   0x2000
.equ ATOMIC_CLEAR, 0x3000

//.equ SIO_BASE,        0xD0000000

.equ IO_BANK0_BASE,   0x40028000        @ avant 0x40014000
.equ PADS_BANK0_BASE, 0x40038000        @ avant  0x4001C000

.equ GPIO0_CTRL,      4

.equ GPIO_IN        , 0x004 @ Input value for GPIO pins
.equ GPIO_HI_IN     , 0x008 @ Input value for QSPI pins
.equ GPIO_OUT       , 0x010 @ GPIO output value
.equ GPIO_HI_OUT    , 0x014 @ QSPI output value

.equ GPIO_OUT_SET   , 0x018 @ GPIO output value set
.equ GPIO_HI_OUT_SET, 0x01C @ QSPI output value set

.equ GPIO_OUT_CLR   , 0x020 @ GPIO output value clear
.equ GPIO_HI_OUT_CLR, 0x024 @ QSPI output value clear

.equ GPIO_OUT_XOR   , 0x028 @ GPIO output value XOR
.equ GPIO_HI_OUT_XOR, 0x02c @ QSPI output value XOR
.equ GPIO_OE        , 0x030 @ GPIO output enable
.equ GPIO_HI_OE     , 0x034 @ QSPI output enable
.equ GPIO_OE_SET    , 0x038 @ GPIO output enable set
.equ GPIO_HI_OE_SET , 0x03C @ QSPI output enable set
.equ GPIO_OE_CLR    , 0x040 @ GPIO output enable clear
.equ GPIO_HI_OE_CLR , 0x044 @ QSPI output enable clear
.equ GPIO_OE_XOR    , 0x048 @ GPIO output enable XOR
.equ GPIO_HI_OE_XOR , 0x04c @ QSPI output enable XOR

.equ GPIO_FUNC_SIO,   5     @ fonction gpio 

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data                       @ INFO: .data

.align 2
iNbEclats:        .int 4

/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 2

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global main
.thumb_func
main:                           @ INFO: main
    
	bl initDebut                @ recopie data et init bss
	
	ldr r0,iAdriNbEclats
	ldr r0,[r0]
	bl ledEclats    

	mov r0,5000
    bl attendre
	
	mov r0,2
	bl ledEclats 
    
100:                            @ boucle pour fin de programme standard  
loop:
    b 100b
iAdriNbEclats: .int iNbEclats
/************************************/
/*       bloc de controle voir 5.9.5.1. Minimum Arm IMAGE_DEF             */
/***********************************/
.align 2
blocembd:       .int 0xffffded3       @ image arm
                .int 0x10210142       @ voir doc section 5.9.5
                .int 0x00000344
                .int 0x10000001       @ initial pointer address
                .int ADRSTACK         @ initial stack address
                .int 0x000004FF       @ dernier item avec taille du suivant
                .int 0x00000000       @ fib de la boucle
                .int 0xab123579       @ image end 
/******************************************************************/
/*     initialisation                                             */ 
/******************************************************************/
.thumb_func
initDebut:                       @ INFO: initDebut
    push {r1-r4,lr}
    ldr r1,iAdrDebFlashData
    ldr r2,iAdrDebRamData 
    ldr r3,iAdrDebRamBss
1:                              @ boucle de copie de la data en rom
    ldm r1!, {r0}               @ vers la data en ram
    stm r2!, {r0}
    cmp r2, r3
    blo 1b
                                @ initialisation de la .bss
    ldr r2,iAdrFinRamBss
    movs r0,0
2:  
    stm r3!, {r0}
    cmp r3, r2
    blo 2b
100:
    pop {r1-r4,pc}
   
.align 2
iAdrDebFlashData:         .int _debutFlashData
iAdrDebRamData:           .int _debutRamData
iAdrDebRamBss:            .int _debutRamBss
iAdrFinRamBss:            .int _finRamBss               
/************************************/
/*        Led eclats            */
/***********************************/
/* r0 contient le nombre d'éclats */
.thumb_func
ledEclats:                       @ INFO: ledEclats
    push {r1-r4,lr}
    mov r4,r0                    @ nombre eclats
    ldr r0,iAdrPad
    mov r1,0b1000000             @ PADS_BANK0: GPIO0 Register IE: Input enable
    str r1,[r0,4 * LED_PIN]
    
    ldr r0,iAdrPadClr
    mov r1,0b100000000           @ PADS_BANK0: GPIO0 Register ISO: Pad isolation control
    str r1,[r0,4 * LED_PIN]
    
    mov r1,GPIO_FUNC_SIO
    ldr r0,iAdriGpioCtrl0
    str r1,[r0,8 * LED_PIN]
    
    mov r2,0
    movt r2,0xD000               @ adresse SIO_BASE
    mov r1,1
    lsl r1,r1,LED_PIN            @ déplacement bit à gauche
    str r1,[r2,GPIO_OE_SET]
1:
    str r1,[r2,GPIO_OUT_SET]     @ allumage led
    mov r0,500
    bl attendre
    str r1,[r2,GPIO_OUT_CLR]     @ extinction led
    mov r0,500
    bl attendre 
	subs r4,r4,1                 @ decrement le nombre d eclats
	bgt 1b                       @ et boucle
	
    pop {r1-r4,pc}
.align 2
iAdriGpioCtrl0:     .int IO_BANK0_BASE + GPIO0_CTRL
iAdrPad:            .int PADS_BANK0_BASE + 4 + ATOMIC_SET
iAdrPadClr:         .int PADS_BANK0_BASE + 4 + ATOMIC_CLEAR  
.align 2
/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur attente   */
.thumb_func
attendre:                     @ INFO: attendre
    push {lr}
    lsls r0,r0,11             @ approximatif 
1:
    subs r0,r0, 1
    bne 1b
    pop {pc}
.align 2	
/******************************************************************/
/*     exemple fonction                                 */ 
/******************************************************************/
/* r0 parametre     */
.thumb_func
exempleFonction:                // INFO: exempleFonction
    push {r1-r7,lr}

100:    
    pop {r1-r7,pc} 
.align 2
