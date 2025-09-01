/* Programme assembleur ARM Raspberry pico 2 */
/* connexion USB */
.syntax unified
.cpu cortex-m33
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico2Git.inc"


/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data                       @ INFO: .data
szMessDemStd:       .asciz "Demarrage normal ARM.\r\n"
szRetourLigne:      .asciz "\r\n"

szMessCmd:         .asciz "Entrez une commande (ou aide) : "
szLibCmdAff:       .asciz "aff"	
szLibCmdFin:       .asciz "fin"
szLibCmdAide:      .asciz "aide"

szLibListCom:      .asciz "aff test \r\nfin reboot BOOTSEL\r\n"
.align 2
iNbEclats:        .int 1
  
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
sBuffer:            .skip 100
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
	//bl ledEclats    
	

	bl initUsbDevice
    
    movs r0,1                    @ pour verifier si OK 
    bl ledEclats
    
     ldr r0,iAdriHostOK
1:                               @ boucle attente connexion
    ldr r1,[r0]
    cmp r1,TRUE
    bne 1b
 
    ldr r0,iAdrszMessDemStd     @ connexion ok, message acceuil
    bl envoyerMessage 
    
2:
    ldr r0,iAdrszMessCmd
    bl envoyerMessage           @ message commande
    ldr r0,iAdrsBuffer
    bl recevoirMessage
	
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFin      @ INFO: commande fin  
    bl comparerChaines
    cmp r0, 0
    bne 3f
    bl resetPicoBoot
    b 20f
3:
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdAide     @ INFO: commande aide
    bl comparerChaines
    cmp r0, 0
    bne 4f
    ldr r0,iAdrszLibListCom
    bl envoyerMessage
    
    b 20f
4:
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdAff     @ INFO: commande aff
    bl comparerChaines
    cmp r0, 0
    bne 5f	
	mov r0,sp
	push {r0}                 @ stocke la valeur de r0 sur la pile
	bl affRegHexa             @ affiche la valeur en hexa
	add sp,sp,4               @ realigne la pile car le push l a déphasé de 4 octets
	
	ldr r0,iAdrsBuffer        @ ici on passe l adresse dans le registre r0
	bl affRegHexaReg          @ et elle est affichée
		
	b 20f
5:
    @ place pour ajout de nouvelles commandes

15:
    ldr r0,iAdrsBuffer         @ si saisie non reconnue
    bl envoyerMessage          @ affichage du code saisi
    ldr r0,iAdrszRetourLigne
    bl envoyerMessage	
20:	
	b 2b

	
    
100:                            @ boucle pour fin de programme standard  
    b 100b
iAdriNbEclats:          .int iNbEclats
iAdrszMessDemStd:       .int szMessDemStd
iAdrszRetourLigne:      .int szRetourLigne
iAdrszMessCmd:          .int szMessCmd
iAdrszLibCmdAide:       .int szLibCmdAide
iAdrszLibCmdAff:        .int szLibCmdAff
iAdrszLibCmdFin:        .int szLibCmdFin
iAdriHostOK:            .int iHostOK
iAdrsBuffer:            .int sBuffer
iAdrszLibListCom:       .int szLibListCom
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
/*     exemple fonction                                 */ 
/******************************************************************/
/* r0 parametre     */
.thumb_func
exempleFonction:                @ INFO: exempleFonction
    push {r1-r7,lr}

100:    
    pop {r1-r7,pc} 
.align 2
