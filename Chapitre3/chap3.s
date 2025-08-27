/* Programme assembleur ARM Raspberry pico 2 */
/* routines multi coeur */
/* changement delai de clignotement par le core1 */
.syntax unified
.cpu cortex-m33
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.equ LED_PIN,      25
.equ TAILLESTACK,  0x800                     @ taille à revoir si necessaire
.equ ADRSTACK,     0x20040800                @ adresse de la pile

.equ ATOMIC_XOR,   0x1000
.equ ATOMIC_SET,   0x2000
.equ ATOMIC_CLEAR, 0x3000

.equ SIO_BASE,     0xD0000000
.equ PPB_CPUID,    0xed00
.equ PPB_VTOR,     0xed08
.equ IO_BANK0_BASE,   0x40028000        @ avant 0x40014000
.equ PADS_BANK0_BASE, 0x40038000      @ avant  0x4001C000
.equ GPIO0_CTRL,   4

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

.equ GPIO_FUNC_SIO,   5

.equ SIO_FIFO_ST_RDY_BITS,   0x00000002
.equ SIO_FIFO_ST_VLD_BITS,   0x00000001

.equ SIOBASE_FIF0_ST,     0x50
.equ SIOBASE_FIF0_WR,     0x54
.equ SIOBASE_FIF0_RD,     0x58

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data               @ INFO: .data

.align 2
cmd_sequence:      .int 0,0,1,0,0,0,0          @ séquence initialisation
iDelaiLed:           .int 500

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

    bl initDebut
	
    adr r0,execCore1           @ fonction executée par le core1
    bl multicore_init_core1    @ mettre en commentaire pour voir la difference
	
   // movs r0,25
   // bl attendre
	
	bl clignoterLed
    
100:                            @ boucle pour fin de programme standard  
loop:
    b 100b
/************************************/
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

   pop {r1-r4,pc}
   
.align 2
iAdrDebFlashData:         .int _debutFlashData
iAdrDebRamData:           .int _debutRamData
iAdrDebRamBss:            .int _debutRamBss
iAdrFinRamBss:            .int _finRamBss

/************************************/
/*     changement délai par le core 1     */
/***********************************/
.thumb_func
execCore1:                   @ INFO: execCore1
    push {r1,lr}

    movs r0,4000
    bl attendre
	
	ldr r1,iAdriDelaiLed
    mov r0,150
	str r0,[r1] 
1:                          @ loop core 1
    b 1b
100:
    pop {r1,pc}
.align 2    
//iAdrSioBase:        .int SIO_BASE

/******************************************************************/
/*     ecriture FIFO                                              */ 
/******************************************************************/
/*  r0  contient la valeur à écrire           */
.thumb_func
multicore_fifo_write:               @ INFO: multicore_fifo_write
    push {lr}
	mov r1,0
    movt r1,0xD000                    @ adresse SIO_BASE
    movs r2,SIO_FIFO_ST_RDY_BITS      @ soit 2
1:  
    ldr r3,[r1,SIOBASE_FIF0_ST]       @ etat de la pile fifo
    tst r3,r2                         @ bit 1 à 1 ?
    beq 1b                            @ non boucle
    str r0,[r1,SIOBASE_FIF0_WR]       @ écriture dans la file FIFO 
    sev                               @ evenement vers l autre coeur
    pop {pc}
.align 2
/******************************************************************/
/*     lecture FIFO                                         */ 
/******************************************************************/
/*  r0  retoune la valeur lue                 */
.thumb_func
multicore_fifo_read:          @ INFO: multicore_fifo_pop_blocking
    push {lr}
    movs r2,SIO_FIFO_ST_VLD_BITS
    mov r1,0
    movt r1,0xD000                    @ adresse SIO_BASE
1:  
    ldr r3,[r1,SIOBASE_FIF0_ST]       @ registre status de la file fifo
    tst r3,r2
    bne 3f
2:
    wfe
    ldr r3,[r1,SIOBASE_FIF0_ST]       @ registre status de la file fifo
    tst r3,r2
    beq 2b
3:
	mov r1,0
    movt r1,0xD000                    @ adresse SIO_BASE
    ldr r0,[r1,SIOBASE_FIF0_RD]       @ lecture fifo
    
    pop {pc}
.align 2
/******************************************************************/
/*     vidage de la file d'attente lecture FIFO                   */ 
/******************************************************************/
.thumb_func
multicore_fifo_drain:                 @ INFO:  multicore_fifo_drain
    push {lr}
	mov r1,0
    movt r1,0xD000                    @ adresse SIO_BASE
    movs r2,SIO_FIFO_ST_VLD_BITS      @   soit 1
1:  
    ldr r3,[r1,SIOBASE_FIF0_ST]        @ état de la pile FIFO
    tst r3,r2                          @ bits 0  à 1 ?
    beq 2f
    ldr r3,[r1,SIOBASE_FIF0_RD]        @ vide le registre de lecture
    b 1b
2:
    pop {pc}
.align 2 
/******************************************************************/
/*     initialisation lancement core 1                            */ 
/******************************************************************/
/*  r0 = adresse procédure devant être executée par le core 1     */
.thumb_func
multicore_init_core1:              @ INFO: multicore_launch_core1
    push {r4,r5,r6,lr}
    movs r1,1
    orrs r0,r1                     @ adresse doit se finir par 1 voir info thumb
    ldr r1,iAdrStack1
	mov r2,TAILLESTACK
    adds r3,r1,r2                  @ adresse de fin de pile
    
    mov r2,0
    movt r2,0xE000                 @ adresse PPB_BASE
    ldr r1,iAdrVtor1
    add r2,r2,r1                   @ calcul de l'adresse où se trouve l'adresse vtor
    ldr r2,[r2]                    @ charge l'adresse vtor
    ldr r1,iAdrcmd_sequence
    str r2,[r1,12]                 @ stocke adresse vtor dans la sequence de commande
    str r3,[r1,16]                 @ stocke adresse fin de pile dans la sequence de commande
    str r0,[r1,20]                 @ stocke l'adresse de la procedure à executer par le core 1
    
    movs r4,0                      @ indice élement séquence
    ldr r5,iAdrcmd_sequence        @ adresse de la sequence d initialisation
1:
    lsls r0,r4,2                   @ déplacement
    ldr r6,[r5,r0]                 @ charge un élement de la sequence 
    cmp r6,0
    bne 2f
    bl multicore_fifo_drain        @ vide la file d attente lecture fifo
    sev
2:
    mov r0,r6
    bl multicore_fifo_write        @ envoi élément séquence
    bl multicore_fifo_read         @ réponse
    cmp r0,r6
    beq 3f                         @ compare envoi et réponse
    movs r4,0                      @ si écart recommence l envoi
    b 4f
3:
    adds r4,1
4:
    cmp r4,5
    ble 1b
    movs r0,5
    bl attendre    
    pop {r4,r5,r6,pc}
.align 2
iAdrcmd_sequence:   .int cmd_sequence
iAdrStack1:         .int ADRSTACK
iAdrVtor1:          .int PPB_VTOR
/************************************/
/*       clignotement Led             */
/***********************************/
.thumb_func
clignoterLed:                  @ INFO: clignoterLed
    push {r1-r5,lr}
    mov r4,r0
	ldr r5,iAdriDelaiLed
    ldr r0,iAdrPad
    mov r1,0b1000000         @ PADS_BANK0: GPIO0 Register IE: Input enable
    str r1,[r0,4 * LED_PIN]
    
    ldr r0,iAdrPadClr
    mov r1,0b100000000         @ PADS_BANK0: GPIO0 Register ISO: Pad isolation control
    str r1,[r0,4 * LED_PIN]
    
    mov r1,GPIO_FUNC_SIO
    ldr r0,iAdriGpioCtrl0
    str r1,[r0,8 * LED_PIN]
    
    mov r2,0
    movt r2,0xD000
    mov r1,1
    lsl r1,r1,LED_PIN
    str r1,[r2,GPIO_OE_SET]
1:
    str r1,[r2,GPIO_OUT_SET]     @ allumage led
    ldr r0,[r5]
    bl attendre
    str r1,[r2,GPIO_OUT_CLR]     @ extinction led
    ldr r0,[r5]
    bl attendre 
	b 1b                         @ loop

    pop {r1-r5,pc}
.align 2
iAdriGpioCtrl0:     .int IO_BANK0_BASE + GPIO0_CTRL
iAdriGpioCtrl0CLR:  .int IO_BANK0_BASE + GPIO0_CTRL + ATOMIC_CLEAR
iAdriSioOeset:      .int SIO_BASE + GPIO_OE_SET + ATOMIC_SET
iAdriSioHIOeset:    .int SIO_BASE + GPIO_HI_OE_SET + ATOMIC_SET
iAdriSioOutset:     .int SIO_BASE + GPIO_OUT_SET + ATOMIC_SET
iAdrPad:            .int PADS_BANK0_BASE + 4 + ATOMIC_SET
iAdrPadClr:         .int PADS_BANK0_BASE + 4 + ATOMIC_CLEAR  
iAdriDelaiLed:      .int iDelaiLed
/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur en milliseconde   */
/* r1 non sauvegardé */
.thumb_func
attendre:                     @ INFO: attendre
    push {r1,lr}
    lsls r0,r0,11             @ approximatif 
1:
    subs r0,r0, 1
    bne 1b
    pop {r1,pc}
.align 2	
