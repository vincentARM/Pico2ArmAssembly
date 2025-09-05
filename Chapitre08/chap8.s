/* Programme assembleur ARM Raspberry pico 2 */
/* mesure température par capteur ADC */
.syntax unified
.cpu cortex-m33
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico2Git.inc"

/*********************************************/
/*           MACROS                      */
/********************************************/
.include "./ficmacros.inc"

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data                       @ INFO: .data
szMessDemStd:       .asciz "Demarrage normal ARM.\r\n"
szRetourLigne:      .asciz "\r\n"

szMessCmd:         .asciz "Entrez une commande (ou aide) : "
szLibCmdAff:       .asciz "aff"	
szLibCmdTemp:       .asciz "temp"
szLibCmdTest:      .asciz "test"
szLibCmdFin:       .asciz "fin"
szLibCmdAide:      .asciz "aide"

szLibListCom:      .asciz "aff : \r\ntemp : mesure temperature\r\ntest : \r\nfin : reboot BOOTSEL\r\n"
szMessTemp:       .ascii "Température = "
sZoneTempDec:     .asciz "             "


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
    afficherLib "Non implanté"
	

	b 20f
5:
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdTemp     @ INFO: commande temp
    bl comparerChaines
    cmp r0, 0
    bne 6f
	afficherLib "Température"
	bl autoriserFPU           @ autorisation fpu
 
	bl init_clk_adc           @ init horloge ADC
	mov r0,0x0c
	bl calculerFrequenceReg   @ vérification fréquence
	affregtit "Frequence ADC en hexa dans r0"
	bl initADC                @ init ADC
	bl testTemp               @ mesure température
	
	b 20f
6:
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdTest     @ INFO: commande test
    bl comparerChaines
    cmp r0, 0
    bne 7f
	afficherLib "Non implanté"

	
    b 20f
7:	
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
iAdrszLibCmdTemp:       .int szLibCmdTemp
iAdrszLibCmdTest:       .int szLibCmdTest
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
/*     autorisation calculs FPU                                */ 
/******************************************************************/
.equ CPACR, 0x0ed88
.equ FPCCR, 0x0ef34
.thumb_func
autoriserFPU:                @ INFO: autoriserFPU
    push {r1-r2,lr}
	ldr r0,iadrPpbbase           @ autorisation fpu
    ldr r1,iadrCPACR
    ldr r2,iParctrl
    str r2,[r0,r1]

    pop {r1-r2,pc} 
.align 2
iadrPpbbase:            .int PPB_BASE
iadrCPACR:              .int CPACR
iadrFPCCR:              .int FPCCR
iParctrl:               .int 0b01100001100000000000000

/******************************************************************/
/*     exemple fonction                                 */ 
/******************************************************************/
/* r0 parametre     */
.thumb_func
exempleFonction:                @ INFO: exempleFonction
    push {r1-r7,lr}


    pop {r1-r7,pc} 
.align 2

/******************************************************************/
/*     Température                                           */ 
/******************************************************************/
/* 12.4. ADC and Temperature Sensor */
.equ ADC_CS,          0
.equ ADC_RESULT,      4
.equ ADC_FCS,         8
.equ ADC_FIFO,        0xC
.equ ADC_DIV,         0x10
.equ ADC_INTR,        0x14
.equ ADC_INTE,        0x18
.equ ADC_INTF,        0x1C
.equ ADC_INTS,        0x20
.equ ADC_CS_START_ONCE_BITS,   0x4
.thumb_func
testTemp:                   @ INFO: testTemp
    push {lr}
    afficherLib debutADC 
    ldr r2,iAdrAdcBase      @ lancement mesure 
    ldr r1,[r2,ADC_CS]
	//affregtit suite1
    ldr r3,iParam           
    orrs r3,r3,r1           @ pour éviter arret autres canaux
	ldr r2,iAdrAdcBase      @ lancement mesure 
    str r3,[r2,ADC_CS]
    movs r0,10
    bl attendre
	mov r1,0b100000000      @ pour bit 8 à 1
1:                          @ boucle attente ok
    ldr r0,[r2,ADC_CS]
    tst r0,r1
    beq 1b
	//affregtit suite3
    mov r3,ADC_CS_START_ONCE_BITS
	ldr r2,iAdrAdcBaseSet
    str r3,[r2,ADC_CS]       @ lancement mesure

	ldr r2,iAdrAdcBase
	mov r1,0b100000000       @ pour bit 8 à 1
 2:                          @ boucle attente ok   ldr r4,[r2,ADC_RESULT]
     ldr r0,[r2,ADC_CS]   
     tst r0,r1
     beq 2b 
	 
	 ldr r4,[r2,ADC_RESULT]
 
	vmov  s0, r4
    vcvt.f32.u32 s0, s0      @ conversion en float
	adr r1,iCst4
	vldr s1,[r1]
	vmul.f32 s2,s0,s1        @ multiplication par 0.000805664
	adr r1,iCst1
	vldr s1,[r1]
	vsub.f32 s2,s2,s1        @ soustraction 0.706
	adr r1,iCst3
	vldr s1,[r1]
	vdiv.f32 s2,s2,s1        @ division par 0.001721
	adr r1,iCst2
	vldr s1,[r1]
	vsub.f32 s2,s1,s2        @ soustraction
	
	vmov r4,s2
	vmov s0,s2
	ldr r0,iAdrsZoneTempDec
    bl convertirFloat

    ldr r0,iAdrszMessTemp
    bl envoyerMessage
	
	ldr r0,iAdrszRetourLigne
	bl envoyerMessage
    
    pop {pc}
.align 2
iParam:           .int 0x100007
iCst1:            .float 0.706
iCst2:            .float 20.0           @ à adapter suivant votre environement
iCst3:            .float 0.001721
iCst4:            .float 0.000805664
iCst5:            .float 10.0
iAdrBasePllUsb:   .int PLL_USB_BASE
iAdrszMessTemp:   .int szMessTemp
iAdrsZoneTempDec: .int sZoneTempDec
iAdrAdcBaseSet:   .int ADC_BASE + ATOMIC_SET
/******************************************************************/
/*     initialisation ADC                                         */ 
/******************************************************************/
.equ ADC_BASE,   0x400a0000
.thumb_func
initADC:                            @ INFO: initADC
    ldr r0,iAdrResetBaseMskSet      @ reset 
    movs r1,1
    str r1,[r0]                     @ reset des zones
    ldr r0,iAdrResetBaseMskClear
    str r1,[r0]
    ldr r2,iAdrResetBase
    movs r0,r1
1:                                  @ boucle d'attente du reset
    movs r0,r1
    ldr r3,[r2,RESETS_DONE]
    bics r0,r3
    bne 1b
	
    ldr r2,iAdrAdcBase
    str r1,[r2]
    lsls r1,8
2:                                 @ boucle attente init 
    ldr r3,[r2]
    tst r3,r1
    beq 2b
	
    bx lr
.align 2
iAdrResetBase:            .int RESETS_BASE
iAdrResetBaseMskSet:      .int RESETS_BASE + ATOMIC_SET
iAdrResetBaseMskClear:    .int RESETS_BASE + ATOMIC_CLEAR
iAdrAdcBase:              .int ADC_BASE
/***********************************/
/*       Init horloge ADC           */
/***********************************/
.equ CLOCKS_CLK_ADC_CTRL_ENABLED_BITS,   0x10000000
.equ CLK_ADC_CTRL,      0x6C
.equ CLK_ADC_DIV,       0x70
.equ CLK_ADC_SELECTED,  0x74
.thumb_func
init_clk_adc:                     @ INFO: init_clk_adc
    push {r4,lr}
    movs   r2,0x1
    lsls   r2, r2, #16            @  bit 16 à 1
    ldr    r3, iAdrClkAdcDivSet   @ adresse diviseur horloge système
    str    r2, [r3]               @ met 1 dans le bit 16 du diviseur
1:
    movs    r1, #1
    ldr    r2,iAdrClkAdcClr       @ adresse horloge système bitmask clear
    ldr    r3,iAdrClkAdc          @ adresse controle horloge système
    lsls r1,r1,11
    str    r1, [r2]               @ clear le bit 11 
    ldr r0,iParCtrlAdc
2:
    ldr    r2, [r3]
    tst    r2,r0                  @ teste le bit 28
    bne  2b                       @ boucle attente de prise en compte du clear

    ldr    r0,iParAdcClr          @ bits 0,1 et 5;6,7
    ldr    r3,iAdrClkAdc          @ adresse controle horloge système
    ldr    r2, [r3]               @ charge le registre controle 
    ldr    r4,iAdrClkAdcClr
    str r0,[r4]                   @ efface les bits 0,1 et 5,6,7
    movs r0,10
    bl attendre
    movs r1,0b00000000            @ valeur 3 dans bits 5,6,7 et 0 dans bit 0 et 1
    ldr    r4,iAdrClkAdcSet
    str    r1, [r4]               @ stocke nouvelle valeur dans les bits 0,1 5,6,7
    movs   r2,0x1
    lsls   r2, r2, #11            @  bit 11 à 1
    ldr    r3, iAdrClkAdcSet      @ 
    str    r2, [r3]               @ met 1 dans le bit 11 


    ldr    r1,iAdrClkAdc          @ 
    ldr    r3,iParCtrlAdc
3:
    ldr    r2, [r1]
    tst    r2,r3                  @ test bit 28 
    beq   3b                      @ boucle attente
    
   pop {r4,pc}
    

.align 2
iAdrClkAdc:              .int  CLOCKS_BASE + CLK_ADC_CTRL
iAdrClkAdcXor:           .int  CLOCKS_BASE + CLK_ADC_CTRL + ATOMIC_XOR
iAdrClkAdcSet:           .int  CLOCKS_BASE + CLK_ADC_CTRL + ATOMIC_SET
iAdrClkAdcClr:           .int  CLOCKS_BASE + CLK_ADC_CTRL + ATOMIC_CLEAR
iAdrClkAdcDiv:           .int  CLOCKS_BASE + CLK_ADC_DIV
iAdrClkAdcDivSet:        .int  CLOCKS_BASE + CLK_ADC_DIV + ATOMIC_SET
iAdrClkAdcSel:           .int  CLOCKS_BASE + CLK_ADC_SELECTED
iParAdcClr:              .int  0b000000011100011
iParCtrlAdc:             .int CLOCKS_CLK_ADC_CTRL_ENABLED_BITS
 /******************************************************************/
/*     Calcul frequence                                             */ 
/******************************************************************/
/* r0  N° horloge */
/*    pour rp2040
CLOCKS_FC0_SRC_VALUE_PLL_SYS_CLKSRC_PRIMARY 0x01
CLOCKS_FC0_SRC_VALUE_PLL_USB_CLKSRC_PRIMARY 0x02
CLOCKS_FC0_SRC_VALUE_ROSC_CLKSRC            0x03
CLOCKS_FC0_SRC_VALUE_ROSC_CLKSRC_PH         0x04
CLOCKS_FC0_SRC_VALUE_XOSC_CLKSRC            0x05
CLOCKS_FC0_SRC_VALUE_CLKSRC_GPIN0           0x06
CLOCKS_FC0_SRC_VALUE_CLKSRC_GPIN1           0x07
CLOCKS_FC0_SRC_VALUE_CLK_REF                0x08
CLOCKS_FC0_SRC_VALUE_CLK_SYS                0x09
CLOCKS_FC0_SRC_VALUE_CLK_PERI               0x0a
CLOCKS_FC0_SRC_VALUE_CLK_USB                0x0b
CLOCKS_FC0_SRC_VALUE_CLK_ADC                0x0c
CLOCKS_FC0_SRC_VALUE_CLK_RTC                0x0d

pour rp2350 


0x01 → pll_sys_clksrc_primary
0x02 → pll_usb_clksrc_primary
0x03 → rosc_clksrc
0x04 → rosc_clksrc_ph
0x05 → xosc_clksrc
0x06 → clksrc_gpin0
0x07 → clksrc_gpin1
0x08 → clk_ref
0x09 → clk_sys
0x0a → clk_peri
0x0b → clk_usb
0x0c → clk_adc
0x0d → clk_hstx
0x0e → lposc_clksrc
0x0f → otp_clk2fc
0x10 → pll_usb_clksrc_primary_dft

*/
.equ FC0_REF_KHZ,    0x8C
.equ FC0_MIN_KHZ,    0x90
.equ FC0_MAX_KHZ,    0x94
.equ FC0_DELAY,      0x98
.equ FC0_INTERVAL,   0x9C
.equ FC0_SRC,        0xa0
.equ FC0_STATUS,     0xa4
.equ FC0_RESULT,     0xa8
.equ CLOCKS_FC0_STATUS_RUNNING_BITS,   0x00000100
.equ CLOCKS_FC0_STATUS_DONE_BITS,      0x00000010
.equ CLOCKS_FC0_RESULT_KHZ_LSB, 5
.thumb_func
calculerFrequenceReg:          @ INFO: calculerFrequenceReg
    push {r1-r4,lr}
    ldr r1,iAdrClockStatus
    ldr r3,iBitsRun
    
1:                             @ boucle attente mesure
    ldr r2,[r1]
    ands r2,r3
    bne 1b

    ldr r1,iAdrClockRefKLZ
    ldr r2,iFresRef            @ frequence du XOSC 12000 KHz
    str r2,[r1]
    ldr r1,iAdrClockInter
    movs r2,10                 @ intervalle
    str r2,[r1]
    ldr r1,iAdrClockMin
    movs r2,0                  @ minimum
    str r2,[r1]
    ldr r1,iAdrClockMax
    movs r2,0
    subs r2,1                  @ maximun 0xFFFFFFFF
    str r2,[r1]
    ldr r1,iAdrClockSrc
    str r0,[r1]                @ N° horloge demandée demarre la mesure

    ldr r1,iAdrClockStatus
    movs r3,CLOCKS_FC0_STATUS_DONE_BITS
2:                             @ boucle attente résultat
    ldr r2,[r1]
    ands r2,r3
    beq 2b
    
    ldr r1,iAdrClockResult     @ récupération resultat
    ldr r2,[r1]
    lsrs r2,CLOCKS_FC0_RESULT_KHZ_LSB
 
    mov r0,r2                  @ retourne la valeur
    
100:
    pop {r1-r4,pc}
.align 2
iAdrClockStatus:       .int CLOCKS_BASE + FC0_STATUS
iAdrClockRefKLZ:       .int CLOCKS_BASE + FC0_REF_KHZ
iAdrClockInter:        .int CLOCKS_BASE + FC0_INTERVAL
iAdrClockMin:          .int CLOCKS_BASE + FC0_MIN_KHZ
iAdrClockMax:          .int CLOCKS_BASE + FC0_MAX_KHZ
iAdrClockSrc:          .int CLOCKS_BASE + FC0_SRC
iAdrClockResult:       .int CLOCKS_BASE + FC0_RESULT
iBitsRun:              .int CLOCKS_FC0_STATUS_RUNNING_BITS
iFresRef:              .int 12000

