/* Programme assembleur ARM Raspberry pico 2 */
/* vtor et exceptions */
.syntax unified
.cpu cortex-m33
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico2Git.inc"

.equ IRQ_ALARME0, 0
.equ TIMER0_BASE, 0x400b0000
.equ TIMER_INTR,  0x3C        @ raz interruption
.equ TIMER_INTE,  0x40        @ autorisation 
.equ TIMER_INTF,  0x44        @ forçage

.equ NVIC_ISER_OFFSET, 0x0000e100
.equ NVIC_ICPR_OFFSET, 0x0000e280

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data                       @ INFO: .data
.align 5
 vtorData:
    .word _stack
    .word main
    .word gestionExceptions10    @ isr_nmi 
    .word gestionExceptions12    @ isr_hardfault
    .word gestionExceptions14    @ isr_svcall

    .word loop                   @ 5   isr_pendsv
    .word loop                   @ isr_systick
    .word loop                   @ 
    .word loop
    .word loop

    .word loop
    .word loop
    .word loop
    .word loop
    .word loop

    .word loop        @ 15
    .word testInter 
    //.word loop    @ remplace la precedente
    .word loop
    .word loop
    .word loop
    
    .word loop        @ 20
    .word loop
    .word loop
    .word loop
    .word loop
    
    .word loop    @ 25
    .word loop
    .word loop
    .word loop
    .word loop
    .word loop       @ remplace la precedente
    .fill 200,1,0     @ normalement la vtor fait 272 caractères
.align 2
iNbEclats:        .int 1
  
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
main:                            @ INFO: main
    
	bl initDebut                 @ recopie data et init bss
	
	bl initHorloges
	
	ldr r0,iAdriNbEclats
	ldr r0,[r0]
	bl ledEclats    
	
	ldr r1,iAdrVtor              @ init table des vecteurs VTOR
    ldr r0,iAdrVtorData
    str r0,[r1]
	
	
    
    movs r0,1                    @ pour verifier si OK 
    bl ledEclats
    
    movs r0,IRQ_ALARME0 +16      @ N° du poste IRQ USB dans la table des vecteurs
    lsls r0,2                    @ 4 octets par poste 
    adr r1,testInter             @ adresse de la fonction à appeler
    ldr r2,iAdrVtor              @ adresse du registre contenant adresse table des vecteurs
    ldr r2,[r2]                  @ charge adresse de la table
   // str r1,[r2,r0]             @ stocke adresse de la fonction dans le bon poste 
	
	movs r1,1                    @  autoriser IRQ 
    lsls r1,IRQ_ALARME0
    ldr r0,iAdrNvicIcpr          @ Clears or reads the pending state of each group of 32 interrupts
   // str r1,[r0]                @ non obligatoire ici
    ldr r0,iAdrNvicIser          @ Clears or reads the enabled state of each group of 32 interrupts
    str r1,[r0]
	
	movs r1,1                    @  autoriser IRQ Alarme 0
    lsls r1,IRQ_ALARME0
    ldr r0,iAdrTimer0
    str r1,[r0,TIMER_INTE]
	mov r0,1000
	bl attendre
	
	mov r0,-1                    @ pour tester une exception  12 éclats
	//ldr r0,[r0]                @ enlever le commentaire
	
	ldr r0,iAdrTimer0            @ force interruption pour tester si OK
	str r1,[r0,TIMER_INTF]
	
	
	
	//bl resetPicoBoot           @ remet le pico en mode bootrom
	
    
100:                             @ boucle pour fin de programme standard  
loop:
    b 100b
iAdriNbEclats:        .int iNbEclats
iAdrVtor:             .int PPB_BASE + PPB_VTOR
iAdrVtorData:         .int vtorData
iAdrNvicIser:         .int PPB_BASE  + NVIC_ISER_OFFSET
iAdrNvicIcpr:         .int PPB_BASE  + NVIC_ICPR_OFFSET
iAdrTimer0:          .int TIMER0_BASE
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
initDebut:                      @ INFO: initDebut
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

/******************************************************************/
/*     fonction gestion des exceptions                                */ 
/******************************************************************/
.thumb_func
gestionExceptions10:          @ INFO: gestionExceptions10
    push {r0,lr}
	mov r0,10
	bl ledEclats
	
	bkpt   10                 @ arret

100:    
    pop {r0,pc} 
.align 2
/******************************************************************/
/*     fonction gestion des exceptions                                */ 
/******************************************************************/
.thumb_func
gestionExceptions12:          @ INFO: gestionExceptions12
    push {r0,lr}
	mov r0,12
	bl ledEclats
	
	bkpt   12

100:    
    pop {r0,pc} 
.align 2
/******************************************************************/
/*     fonction gestion des exceptions                                */ 
/******************************************************************/
.thumb_func
gestionExceptions14:           @ INFO: gestionExceptions14
    push {r0,lr}
	mov r0,14
	bl ledEclats
	
	bkpt   14

100:    
    pop {r0,pc} 
.align 2
/******************************************************************/
/*     fonction gestion des exceptions                            */ 
/******************************************************************/
.thumb_func
testInter:                @ INFO: testInter
    push {r0,r1,lr}
	movs r1,1             @  invalider IRQ 
    lsls r1,IRQ_ALARME0
    ldr r0,iAdrTimer0Clear
    str r1,[r0,TIMER_INTR]
	
	mov r0,8
	bl ledEclats
	
	mov r0,1000
	bl attendre

    bl resetPicoBoot         @ remet le pico en mode bootrom

100:    
    pop {r0,r1,pc} 
.align 2
iAdrTimer0Clear:    .int TIMER0_BASE + ATOMIC_CLEAR
/******************************************************************/
/*     exemple fonction                                 */ 
/******************************************************************/
/* r0 parametre     */
.thumb_func
exempleFonction:                @ INFO: exempleFonction
    push {r1-r7,lr}

100:    
    pop {r1-r7,pc} 
.align 2
