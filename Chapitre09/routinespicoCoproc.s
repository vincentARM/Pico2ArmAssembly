/* Programme assembleur ARM Raspberry pico */
/*  routines calcul double coprocessor   */
/* voir 3.6.2. Double-precision Coprocessor (DCP) */
/* lancer avec putty picopuceserieCom4  */
.syntax unified
.cpu cortex-m33
.thumb
.global autoriserCoproc,convIntToDoubleS,convIntToDoubleNS,convDoubleToIntS,diviserDouble
.global convDoubleToIntNS,multiplierDouble,ajouterDouble,soustraireDouble
.global multiplierFloat, comparerDouble,convertirDouble,division32R2023
.global testConversion1,conversion64,arretCoproc,convDoubleToLong,convLongToDoubleNS
.global conversion64SP
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico2Git.inc"
.equ CPACR,     0x0ed88
.equ NSACR,     0x0ed8c
.equ PPB_BASE,  0xe0000000

/*********************************************/
/*           MACROS                      */
/********************************************/
.include "./ficmacros.inc"

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data               @ INFO: .data
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text

/************************************/
/*       autorisation coprocessor             */
/***********************************/
/* pas de parametre   */
.thumb_func
autoriserCoproc:             @ INFO: autoriserCoproc
    push {r1,r2,lr}
    ldr r0,iadrPpbbase       @ autorisation coprocessor
    ldr r1,iadrCPACR
    ldr r2,[r0,r1]
    ldr r2,iParctrl          @ bit 8 et 9 coproc 4
    str r2,[r0,r1]           @ utile
    ldr r1,iAdrNSACR
    ldr r2,[r0,r1]
    mov r2,0b10100000        @ bit 5 coproc 5 
    str r2,[r0,r1]           @ inutile
    ldr r2,[r0,r1]
    pop {r1,r2,pc}
.align 2
iParctrl:               .int 0b00000001100001100000000
/************************************/
/*       autorisation coprocessor             */
/***********************************/
/* pas de parametre   */
.thumb_func
arretCoproc:                 @ INFO: arretCoproc
    push {r1,r2,lr}
    ldr r0,iadrPpbbase       @ arret du coprocessor
    ldr r1,iadrCPACR
    ldr r2,iParctrl1
    str r2,[r0,r1]
    mov r0,200
    bl attendre
    pop {r1,r2,pc}
.align 2
iadrPpbbase:            .int PPB_BASE 
iadrCPACR:              .int CPACR
iAdrNSACR:              .int NSACR
iParctrl1:               .int 0b01100000000000000000000
/************************************/
/*      conversion entier en double     signé         */
/***********************************/
/* r0 contient la valeur entier   */
/* resultat dans r0,r1         */

.thumb_func
convIntToDoubleS:                 @ INFO: convIntToDouble
    push {r4,lr}
    mcrr p4,#7,r0,r0,c0           @  WXIC \rx,\rx
    cdp p4,#0,c0,c0,c1,#0         @  ADD0
    cdp p4,#1,c0,c0,c1,#1         @ SUB1 
    cdp p4,#8,c0,c0,c0,#1         @ NRDD
    mrrc p4,#3,r0,r1,c0           @ RDDS \rzl,\rzh
    pop {r4,pc}
.align 2  
/************************************/
/*      conversion entier en double  non signé            */
/***********************************/
/* r0 contient la valeur entier   */
/* resultat dans r0,r1         */

.thumb_func
convIntToDoubleNS:                @ INFO: convIntToDoubleNS
    push {r4,lr}
    mcrr p4,#6,r0,r0,c0           @  WXUC \rx,\rx
    cdp p4,#0,c0,c0,c1,#0         @  ADD0
    cdp p4,#1,c0,c0,c1,#1         @ SUB1 
    cdp p4,#8,c0,c0,c0,#1         @ NRDD
    mrrc p4,#3,r0,r1,c0           @ RDDS \rzl,\rzh
    pop {r4,pc}
.align 2  

/************************************/
/*      conversion double  en entier signe            */
/***********************************/
/* r0 r1 contient la valeur double  */
/* resultat dans r0         */
.thumb_func
convDoubleToIntS:                 @ INFO: convDoubleToIntS
    push {r4,lr}
    mcrr p4,#8,r0,r1,c0           @ WXDC \rxl,\rxh
    cdp p4,#0,c0,c0,c1,#0         @  ADD0
    cdp p4,#1,c0,c0,c1,#0         @ ADD1
    cdp p4,#8,c0,c0,c0,#2         @ NTDC
    mrc p4,#0,r0,c0,c3,#0         @ RDIC \rz
    pop {r4,pc}
.align 2 

/************************************/
/*      conversion entier en double  non signé            */
/***********************************/
/* r0 r1 contient la valeur Long   */
/* resultat dans r0,r1         */

.thumb_func
convLongToDoubleNS:                      @ INFO: convLongToDoubleNS
    push {r4-r10,lr}
    mov r4,r1
    mcrr p4,#6,r0,r0,c0           @  WXUC \rx,\rx  charge r0 dans X
    cdp p4,#0,c0,c0,c1,#0         @  ADD0
    cdp p4,#1,c0,c0,c1,#1         @ SUB1 
    cdp p4,#8,c0,c0,c0,#1         @ NRDD        conversion en double
    mrrc p4,#3,r0,r1,c0           @ RDDS \rzl,\rzh save
     
    mcrr p4,#6,r4,r4,c0           @  WXUC \rx,\rx   charge r4 dans X
    cdp p4,#0,c0,c0,c1,#0         @  ADD0
    cdp p4,#1,c0,c0,c1,#1         @ SUB1 
    cdp p4,#8,c0,c0,c0,#1         @ NRDD  conversion en double
    mrrc p4,#3,r2,r3,c0           @ RDDS \rzl,\rzh save
    mcrr p4,#1,r2,r3,c0           @ write R2 and R3 unpacked double-precision into X
    
    adr r6,ratio1
    ldrd r6,r7,[r6]
    
    mcrr p4,#1,r6,r7,c1           @WYUP r6,r7  charge ratio dans Y

                          @ multiplication
    mrrc p4,#0,r4,r5,c4   @   RXMS \ra,\rb,0 save x dans r4 r5
    mrrc p4,#0,r6,r7,c5   @   RYMS \rc,\rd,0
    umull r8,r9,r4,r6     @  umull \re,\rf,\ra,\rc
    movs r10,#0
    umlal r9,r10,r4,r7    @ umlal \rf,\rg,\ra,\rd
    umlal r9,r10,r5,r6    @ umlal \rf,\rg,\rb,\rc
    mcrr p4,#2,r8,r9,c0   @   WXMS \re,\rf
    movs r8,#0
    umlal r10,r8,r5,r7    @  umlal \rg,\re,\rb,\rd
    mcrr p4,#3,r10,r8,c0  @  WXMO \rg,\re
    cdp p4,#8,c0,c0,c0,#1 @ normalise and round double-precision result
    mrrc p4,#5,r2,r3,c0   @  RDDM \rzl,\rzh  Obligatoire
    mcrr p4,#1,r2,r3,c0   @ recharge X
                          @ et addition
    mcrr p4,#1,r0,r1,c1     @WYUP r0,r1  charge partie basse dans Y
                          @ addition
    cdp p4,#0,c0,c0,c1,#0 @compare X and Y; set status and alignment shift
    cdp p4,#1,c0,c0,c1,#0 @add/subtract (depending on status and signs) xm and ym
                          @aligned, write result to xm
    cdp p4,#8,c0,c0,c0,#1 @ normalise and round double-precision result
    mrrc p4,#1,r0,r1,c0   @RDDA read R0 and R1 packed double-precision from X, including
                          @special-value processing for addition
    
    pop {r4-r10,pc}
.align 2  

/************************************/
/*      conversion double  en entier non signe            */
/***********************************/
/* r0 r1 contient la valeur double  */
/* resultat dans r0         */
.thumb_func
convDoubleToIntNS:             @ INFO: convDoubleToIntNS
    push {r4,lr}
    mcrr p4,#8,r0,r1,c0        @ WXDC \rxl,\rxh
    cdp p4,#0,c0,c0,c1,#0      @ ADD0
    cdp p4,#1,c0,c0,c1,#0      @ ADD1
    cdp p4,#8,c0,c0,c0,#2      @ NTDC
    mrc p4,#0,r0,c0,c3,#1      @ RDUC \rz
    
    pop {r4,pc}
.align 2 

/************************************/
/*      conversion double  en entier non signe            */
/***********************************/
/* r0 r1 contient la valeur double1  */
/* r2 r3 contient la valeur double2  */
/* resultat dans r0         */
.thumb_func
comparerDouble:            @ INFO: comparerDouble
    push {r4,lr}
    mcrr p4,#1,r0,r1,c0    @ write R0 and R1 unpacked double-precision into X
    mcrr p4,#1,r2,r3,c1    @ write R2 and R3 unpacked double-precision into Y
    cdp p4,#0,c0,c0,c1,#0  @ ADD0
    mrc p4,#0,r0,c0,c0,#1  @ RCMP \rz
    ubfx r0,r0,#29, #2     @ r0=3 si egalité 1 si > 0 si <  (à verifier)
    cmp r0,#3
    bne 1f
    movs r0,0              @ égal
    b 100f
1:
    cmp r0,#1
    bne 2f
    movs r0,1              @ plus grand
    b 100f
2:                         @ plus petit
    movs r0,-1
100:
    pop {r4,pc}
.align 2 

/************************************/
/*       multiplication coprocessor              */
/***********************************/
/* r0,r1 contient la valeur du 1er double   */
/* r2,r3 contient la valeur du 2ieme double */
/* resultat dans r0,r1         */
.thumb_func
multiplierDouble:         @ INFO: multiplierDouble
    push {r2-r10,lr}
    mcrr p4,#1,r0,r1,c0   @write R0 and R1 unpacked double-precision into X
    mcrr p4,#1,r2,r3,c1   @write R2 and R3 unpacked double-precision into Y
    mrrc p4,#0,r4,r5,c4   @   RXMS \ra,\rb,0  met X dans r4 r5
    mrrc p4,#0,r6,r7,c5   @   RYMS \rc,\rd,0
    umull r8,r9,r4,r6     @  umull \re,\rf,\ra,\rc
    movs r10,#0
    umlal r9,r10,r4,r7    @ umlal \rf,\rg,\ra,\rd
    umlal r9,r10,r5,r6    @ umlal \rf,\rg,\rb,\rc
    mcrr p4,#2,r8,r9,c0   @   WXMS \re,\rf
    movs r8,#0
    umlal r10,r8,r5,r7    @  umlal \rg,\re,\rb,\rd
    mcrr p4,#3,r10,r8,c0  @  WXMO \rg,\re
    
    cdp p4,#8,c0,c0,c0,#1 @ normalise and round double-precision result
    mrrc p4,#5,r0,r1,c0   @  RDDM \rzl,\rzh
    
    pop {r2-r10,pc}
.align 2
/************************************/
/*       division coprocessor              */
/***********************************/
/* r0,r1 contient valeur du 1er double   */
/* r2,r3 contient valeur du 2ieme double */
/* resultat dans r0,r1         */
diviserDouble:             @ INFO: diviserDouble
    push {r2-r8,lr}
    mcrr p4,#1,r0,r1,c0    @write R0 and R1 unpacked double-precision into X
    mcrr p4,#1,r2,r3,c1    @write R2 and R3 unpacked double-precision into Y
    mrrc p4,#2,r4,r5,c1    @   RYMR \ra,\rb
    umull r5,r6,r4,r5      @ umull \rb,\rc,\ra,\rb
    mvn r6,r6,lsl #2       @ mvn \rc,\rc,lsl #2
    smmlar r4,r6,r4,r4     @ smmlar \ra,\rc,\ra,\ra
    smmulr r6,r6,r6        @ smmulr \rc,\rc,\rc
    smmlar r4,r6,r4,r4     @  smmlar \ra,\rc,\ra,\ra
    sub  r7,r4,r4,lsr #31  @  sub \re,\ra,\ra,lsr #31
    mrrc p4,#0,r6,r8,c4    @     RXMS \rc,\rd,0
    smmulr r5,r7,r8        @  smmulr \rb,\re,\rd
    mrrc p4,#1,r6,r8,c5    @ RYMS \rc,\rd,1
    umull r6,r4,r5,r6      @ umull \rc,\ra,\rb,\rc
    mla r4,r5,r8,r4        @ mla \ra,\rb,\rd,\ra
    mrrc p4,#4,r6,r8,c4    @RXMS \rc,\rd,4
    sub r4,r6,r4           @sub \ra,\rc,\ra
    smmulr r6,r4,r7        @  smmulr \rc,\ra,\re
    mov r8,r5,lsr #4       @  mov \rd,\rb,lsr #4
    adds r4,r6,r5,lsl #28  @ adds \ra,\rc,\rb,lsl #28
    adc  r5,r8,r6,asr #31  @ adc \rb,\rd,\rc,asr #31
    mcrr p4,#4,r4,r5,c0    @ WXDD \ra,\rb
    cdp p4,#8,c0,c0,c0,#1  @ NRDD  normalise
    mrrc p4,#7,r0,r1,c0  @ RDDD \rzl,\rzh
    
    pop {r2-r8,pc}
.align 2
/************************************/
/*       addition double             */
/***********************************/
/* r0,r1 contient valeur 1er double   */
/* r2,r3 contient valeur du 2ieme double */
.thumb_func
ajouterDouble:                      @ INFO: ajouterDouble
    push {r2-r4,lr}
    mcrr p4,#1,r0,r1,c0   @ write R0 and R1 unpacked double-precision into X
    mcrr p4,#1,r2,r3,c1   @ write R2 and R3 unpacked double-precision into Y
    cdp p4,#0,c0,c0,c1,#0 @ compare X and Y; set status and alignment shift
    cdp p4,#1,c0,c0,c1,#0 @ add/subtract (depending on status and signs) xm and ym
                          @ aligned, write result to xm
    cdp p4,#8,c0,c0,c0,#1 @ normalise and round double-precision result
    mrrc p4,#1,r0,r1,c0   @ read R0 and R1 packed double-precision from X, including
                          @ special-value processing for addition
    pop {r2-r4,pc}
.align 2
/************************************/
/*       addition double             */
/***********************************/
/* r0,r1 contient valeur 1er double   */
/* r2,r3 contient valeur du 2ieme double */
.thumb_func
soustraireDouble:                      @ INFO: soustraireDouble
    push {r2-r4,lr}
    mcrr p4,#1,r0,r1,c0   @ write R0 and R1 unpacked double-precision into X
    mcrr p4,#1,r2,r3,c1   @ write R2 and R3 unpacked double-precision into Y
    cdp p4,#0,c0,c0,c1,#0 @ compare X and Y; set status and alignment shift
                          @ aligned, write result to xm
    cdp p4,#1,c0,c0,c1,#1 @ soustraction
    cdp p4,#8,c0,c0,c0,#1 @ normalise and round double-precision result
    mrrc p4,#3,r0,r1,c0   @read R0 and R1 packed double-precision from X, including
                          @ special-value processing for addition
    pop {r2-r4,pc}
.align 2
/************************************/
/*       multiplication FLOAT               */
/***********************************/
/* r0 contient valeur du 1er float   */
/* r1 contient valeur du 2ieme float */
/* r0 retourne la valeur */
.thumb_func
multiplierFloat:           @ INFO: multiplierFloat
    push {r2-r3,lr}
    mcrr p4,#1,r0,r1,c2    @ WXYU                  
    mrrc p4,#1,r2,r3,c1    @ RXYH
    umull r2,r3,r2,r3
    mcrr p4,#10,r2,r3,c0  @ WXFM
    cdp p4,#8,c0,c0,c2,#1 @ NRDF
    mrc p4,#0,r0,c0,c2,#2
    pop {r2-r3,pc}
.align 2

/************************************/
/*       conversion double partie entiere  */
/*    et partie décimale en 2 registres partie haute et basse */
/***********************************/
/* r0,r1 contient valeur du 1er double   */
/* r0,r1 retourne valeur double decimale*/
/* r2,r3 retourne valeur double partie entiere */
.thumb_func
conversionDoubleDecimal:      @ INFO: conversionDoubleDecimal
    push {r4-r11,lr}
    mov r5,r0
    mov r6,r1
    adr r2,ratio
    ldrd r2,r3,[r2]
    bl diviserDouble      @ division par 10 puis 32
    bl convDoubleToIntNS  @ conversion partie haute en entier
    mov r10,r0            @ save partie haute 
    bl convIntToDoubleNS
    adr r2,ratio
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r7,r0
    mov r8,r1
    mov r0,r5
    mov r1,r6
    mov r2,r7
    mov r3,r8
    bl soustraireDouble    @ calcul partie basse
    bl convDoubleToIntNS   @ conversion partie basse en entier
    mov r9,r0              @ save partie basse
    bl convIntToDoubleNS
    mov r2,r7
    mov r3,r8
    bl ajouterDouble         @ partie entiere complete  
    mov r2,r0
    mov r3,r1
    mov r0,r5                @ nombre de départ
    mov r1,r6
    bl soustraireDouble      @ calcul partie decimale
    
    adr r2,divE15A           @ pourquoi cette valeur ?
                             @ pour avoir une valeur entière maximum
    ldrd r2,r3,[r2]          @ de la partie décimale
    bl multiplierDouble
    mov r5,r0
    mov r6,r1                 @ save partie decimale totale
    adr r2,ratio
    ldrd r2,r3,[r2]
    bl diviserDouble          @ division par 1E10
    affregtit divisionfrac
    bl convDoubleToIntNS      @ conversion partie haute decimale en entier
    mov r11,r0                @ save partie haute décimale
    bl convIntToDoubleNS      @ reconverti en double
    adr r2,ratio
    ldrd r2,r3,[r2]
    bl multiplierDouble       @ et recalcul pour alignement
    mov r7,r0                 @ et save
    mov r8,r1
    mov r0,r5
    mov r1,r6
    mov r2,r7                @ pour la déduire du total décimal
    mov r3,r8
    bl soustraireDouble      @ calcul partie basse de la partie decimale
    bl convDoubleToIntNS     @  et conversion en entier retour dans r0
    mov r1,r11               @ partie décimale haute
    mov r2,r9                @ partie entière basse
    mov r3,r10               @ partie entière haute
    

    pop {r4-r11,pc}
.align 2

ratio:               .double  1E9
                             @  4294967296
divE15A:             .double 1E15

/************************************/
/*       conversion double partie entiere  */
/*    et partie décimale en 2 registres partie haute et basse */
/* conversion en long

/***********************************/
/* r0,r1 contient valeur du 1er double   */
/* r0,r1 retourne valeur double decimale*/
/* r2,r3 retourne valeur double partie entiere */
.thumb_func
conversionDoubleDecimalA:      @ INFO: conversionDoubleDecimalA
    push {r4-r9,lr}
    mov r4,r0
    mov r5,r1
    bl convDoubleToLong
    mov r6,r0             @ save partie entière basse
    mov r7,r1             @ save partie entière haute
    bl convLongToDoubleNS
    mov r8,r0
    mov r9,r1
    mov r0,r4             @ valeur de départ
    mov r1,r5
    mov r2,r8             @ valeur entiere
    mov r3,r9
    bl soustraireDouble   @ calcul partie décimale
    adr r2,divE19A        @ alignement partie décimale
    ldrd r2,r3,[r2]
    bl multiplierDouble
    bl convDoubleToLong  @ et conversion en long
    mov r2,r0            @ partie decimale basse
    mov r3,r1            @ partie decimale haute
    mov r0,r6            @ partie entière basse
    mov r1,r7            @ partie entière haute
    pop {r4-r9,pc}
.align 2
divE19A:             .double 1E19    @ TODO: verifier la validité
/************************************/
/*       exemple               */
/***********************************/
/* r0,r1 contient valeur du 1er double   */
/* r0,r1 retourne valeur double entiere*/
.thumb_func
testConversion:                      @ INFO: testConversion
    push {r2-r4,lr}
    mcrr p4,#1,r0,r1,c0    @ charge X à partir de r0 et r1
    adr r2,ratio
    ldrd r2,r3,[r2]
    mcrr p4,#1,r2,r3,c1    @ write R2 and R3 unpacked double-precision into Y
    cdp p4,#8,c0,c0,c0,#1  @ normalise 
    mrrc p4,#1,r0,r1,c0    @ retourne X,Y 
    pop {r2-r4,pc}
.align 2

/************************************/
/*    conversion double vers long               */
/***********************************/
/* r0 contient adresse du 1er double   */
/* r1 contient adresse du 2ieme double */
.thumb_func
convDoubleToLong:                      @ INFO: convDoubleToLong
    push {r2-r8,lr}
    mov r5,r0
    mov r6,r1
    adr r2,ratio1
    ldrd r2,r3,[r2]
    bl diviserDouble      @ division par 10 puis 32
    bl convDoubleToIntNS  @ conversion partie haute en entier
    mov r4,r0             @ save partie haute 
    bl convIntToDoubleNS
    adr r2,ratio1
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r7,r0
    mov r8,r1
    mov r0,r5
    mov r1,r6
    mov r2,r7
    mov r3,r8
    bl soustraireDouble    @ calcul partie basse
    bl convDoubleToIntNS   @ conversion partie basse en entier
    mov r1,r4
    pop {r2-r8,pc}
.align 2
ratio1:               .int 0x00000000
                      .int 0x41F00000
/******************************************************************/
/*     Conversion double                                           */ 
/******************************************************************/
/* r0  contient la valeur du double */
/* r1  contient la valeur du double */
/* r0 contient l'adresse de la zone de conversion  mini 20 caractères*/
/* r0 retourne la longueur utile de la zone */
convertirDouble:               // INFO: convertirDouble
    push {r2-r10,lr}
    mov r6,r2                 // save adresse de la zone
    mov r8,#0                 // nombre de caractères écrits
    mov r3,#'+'
    strb r3,[r6]              // forçage du signe +
    mov r2,r1             
    cmp r2,#0
    bge 1f            // positif ?
    mov r4,1
    lsl r4,r4,31
    bic r1,r1,r4        // raz signe
    mov r3,#'-'               // et signe -
    strb r3,[r6]
1:
    adds r8,r8,#1              // position suivante
    cmp r0,#0                  // cas du 0 positif ou negatif
    bne 2f
    cmp r1,#0                  // cas du 0 positif ou negatif
    bne 2f
    mov r3,#'0'
    strb r3,[r6,r8]           // stocke le caractère 0
    adds r8,r8,#1
    mov r3,#0
    strb r3,[r6,r8]           // stocke le 0 final
    mov r0,r8                 // retourne la longueur
    b 100f
2: 
    ldr r2,iMaskExposant
    mov r3,r1
    and r3,r3,r2              // exposant à  ?
    cmp r3,r2
    bne 4f
    movs r4,1
    lsl r4,r4,#20             // revoir ce bit 51  si r0 ou r1
    and r4,r0,r4
    cmp r0,r4
    beq 3f
    mov r2,#'N'               // cas du Nan. stk byte car pas possible de stocker un int 
    strb r2,[r6]              // car zone non alignée
    mov r2,#'a'
    strb r2,[r6,#1] 
    mov r2,#'n'
    strb r2,[r6,#2] 
    mov r2,#0                  // 0 final
    strb r2,[r6,#3] 
    mov r0,#3
    b 100f
3:                             // cas infini positif ou négatif
    mov r2,#'I'
    strb r2,[r6,r8] 
    adds r8,r8,#1
    mov r2,#'n'
    strb r2,[r6,r8] 
    adds r8,r8,#1
    mov r2,#'f'
    strb r2,[r6,r8] 
    adds r8,r8,#1
    mov r2,#0
    strb r2,[r6,r8]
    mov r0,r8
    b 100f
4:
    bl normaliserFloat
    mov r5,r2                // save exposant
   // bl conversionDoubleDecimal
    bl conversionDoubleDecimalA
    mov r7,r0
    mov r9,r2
    mov r10,r3
    mov r4,r6                // save adresse début zone 
    adds r6,r6,r8
    mov r2,r6
    bl conversion64
    add r6,r6,r0
    mov r3,#','
    strb r3,[r6]
    adds r6,r6,#1
    mov r0,r9
    mov r1,r10
    mov r2,r6
    bl conversion64SP
    adds r6,r6,r0
    b 41f
                             // conversion partie entière dans r0
    mov r2,r6                // save adresse début zone 
    adds r6,r6,r8
    mov r0,r3
    mov r1,r6
    bl conversion10SP
    add r6,r6,r0
    mov r0,r10
    mov r1,r6
    bl conversion10
    add r6,r6,r0
    
    mov r3,#','
    strb r3,[r6]
    adds r6,r6,#1
 
    mov r0,r9                // conversion partie haute décimale
    mov r1,r6
    bl conversion10          // TODO: routine à revoir car non suppression des 0 en tête
    add r6,r6,r0
    mov r0,r7                // conversion partie basse décimale
    mov r1,r6
    bl conversion10          // TODO: routine à revoir car non suppression des 0 en tête
    add r6,r6,r0
41:
    sub r6,r6,#1
                             // il faut supprimer les zéros finaux
5:
    ldrb r0,[r6]
    cmp r0,#'0'
    bne 6f
    sub r6,r6,#1
    b 5b
6:
    cmp r0,#','
    bne 7f
    sub r6,r6,#1
7:
    add r6,r6,#1
    cmp r5,0
    beq 5f              // si exposant à zero pas d affichage
    mov r3,#'E'
    strb r3,[r6]
    add r6,r6,#1
    mov r0,r5                // conversion exposant
    mov r3,r0
    cmp r3,0
    bge 4f
    neg r0,r0               // exposant negatif
    mov r3,#'-'
    strb r3,[r6]
    adds r6,r6,#1
4:
    mov r1,r6
    bl conversion10
    add r6,r6,r0
5:
    mov r3,#0
    strb r3,[r6]
    adds r6,r6,#1
    mov r0,r6
    subs r0,r0,r2                 // retour de la longueur de la zone
    subs r0,r0,#1                  // sans le 0 final

100:
    pop {r2-r10,pc}
 
    
iMaskExposant:            .int 0x7FF00000     @ cache exposant
dConst1:                  .double 0f1E17

/***************************************************/
/*   normaliser float                              */
/***************************************************/
/* r0,r1 contient la valeur du double (valeur toujours positive et <> Nan) */
/* r0,r1 retourne la nouvelle valeur à la place de d0*/
/* r2 retourne l'exposant */
normaliserFloat:            // INFO: normaliserFloat
    push {r3-r8,lr}
    mov r8,#0              // exposant
    mov r4,r0
    mov r5,r1
    adr r2,dConstE7        // pas de normalisation pour les valeurs < 1E7
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    blt 10f                 // si double est < dConstE7
    
    mov r0,r4
    mov r1,r5
    adr r2,dConstE256        //
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    blt 1f   
    mov r0,r4
    mov r1,r5
    bl diviserDouble
    mov r4,r0
    mov r5,r1
    adds r8,r8,#256
    
1:
    mov r0,r4
    mov r1,r5
    adr r2,dConstE128        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    blt 1f      
    mov r0,r4
    mov r1,r5
    bl diviserDouble
    mov r4,r0
    mov r5,r1
    adds r8,r8,#128
1:
    mov r0,r4
    mov r1,r5
    adr r2,dConstE64        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    blt 1f      
    mov r0,r4
    mov r1,r5
    bl diviserDouble
    mov r4,r0
    mov r5,r1
    adds r8,r8,#64
    
 
1:
    mov r0,r4
    mov r1,r5
    adr r2,dConstE32        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    blt 1f     
    mov r0,r4
    mov r1,r5
    bl diviserDouble
    mov r4,r0
    mov r5,r1
    adds r8,r8,#32
1:
    mov r0,r4
    mov r1,r5
    adr r2,dConstE16        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    blt 1f      
    mov r0,r4
    mov r1,r5
    bl diviserDouble
    mov r4,r0
    mov r5,r1
    adds r8,r8,#16
1:
    mov r0,r4
    mov r1,r5
    adr r2,dConstE8        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    blt 1f      
    mov r0,r4
    mov r1,r5
    bl diviserDouble
    mov r4,r0
    mov r5,r1
    adds r8,r8,#8

1:
    mov r0,r4
    mov r1,r5
    adr r2,dConstE4       // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    blt 1f      
    mov r0,r4
    mov r1,r5
    bl diviserDouble
    mov r4,r0
    mov r5,r1
    adds r8,r8,#4
1:
    mov r0,r4
    mov r1,r5
    adr r2,dConstE2        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    blt 1f      
    mov r0,r4
    mov r1,r5
    bl diviserDouble
    mov r4,r0
    mov r5,r1
    adds r8,r8,#2
1:
    mov r0,r4
    mov r1,r5
    adr r2,dConstE1        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    blt 10f      
    mov r0,r4
    mov r1,r5
    bl diviserDouble
    mov r4,r0
    mov r5,r1
    adds r8,r8,#1


10:
    mov r0,r4
    mov r1,r5
    adr r2,dConstME5        //   pas de normalisation pour les valeurs > 1E-5
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    bgt 90f      
    mov r0,r4
    mov r1,r5
    adr r2,dConstME255        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    bgt 11f      
    mov r0,r4
    mov r1,r5
    adr r2,dConstE256        // 
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r4,r0
    mov r5,r1
    subs r8,r8,#256

11:   
    mov r0,r4
    mov r1,r5
    adr r2,dConstME127        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    bgt 11f      
    mov r0,r4
    mov r1,r5
    adr r2,dConstE128        // 
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r4,r0
    mov r5,r1
    subs r8,r8,#128
11:
    mov r0,r4
    mov r1,r5
    adr r2,dConstME63        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    bgt 11f      
    mov r0,r4
    mov r1,r5
    adr r2,dConstE64        // 
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r4,r0
    mov r5,r1
    subs r8,r8,#64

11:
    mov r0,r4
    mov r1,r5
    adr r2,dConstME31        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    bgt 11f      
    mov r0,r4
    mov r1,r5
    adr r2,dConstE32        // 
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r4,r0
    mov r5,r1
    subs r8,r8,#32

11:
    mov r0,r4
    mov r1,r5
    adr r2,dConstME15        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    bgt 11f      
    mov r0,r4
    mov r1,r5
    adr r2,dConstE16        // 
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r4,r0
    mov r5,r1
    subs r8,r8,#16
 
11:
    mov r0,r4
    mov r1,r5
    adr r2,dConstME7        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    bgt 11f      
    mov r0,r4
    mov r1,r5
    adr r2,dConstE8        // 
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r4,r0
    mov r5,r1
    subs r8,r8,#8
11:
    mov r0,r4
    mov r1,r5
    adr r2,dConstME3        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    bgt 11f      
    mov r0,r4
    mov r1,r5
    adr r2,dConstE4        // 
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r4,r0
    mov r5,r1
    subs r8,r8,#4
11:
    mov r0,r4
    mov r1,r5
    adr r2,dConstME1        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    bgt 11f      
    mov r0,r4
    mov r1,r5
    adr r2,dConstE2        // 
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r4,r0
    mov r5,r1
    subs r8,r8,#2
11:
    mov r0,r4
    mov r1,r5
    adr r2,dConstE0        // 
    ldrd r2,r3,[r2]
    bl comparerDouble
    cmp r0,#0
    bgt 90f      
    mov r0,r4
    mov r1,r5
    adr r2,dConstE1        // 
    ldrd r2,r3,[r2]
    bl multiplierDouble
    mov r4,r0
    mov r5,r1
    subs r8,r8,#1
    
90:
    mov r0,r4
    mov r1,r5
    mov r2,r8

100:                       // fin standard de la fonction
    pop {r3-r8,pc}

.align 2
dConstE7:             .double 0f1E9   @ 0f1E7  à suivre
dConstE256:           .double 0f1E256
dConstE128:           .double 0f1E128
dConstE64:            .double 0f1E64
dConstE32:            .double 0f1E32
dConstE16:            .double 0f1E16
dConstE8:             .double 0f1E8
dConstE4:             .double 0f1E4
dConstE2:             .double 0f1E2
dConstE1:             .double 0f1E1
dConstME5:            .double 0f1E-5
dConstME255:          .double 0f1E-255
dConstME127:          .double 0f1E-127
dConstME63:           .double 0f1E-63
dConstME31:           .double 0f1E-31
dConstME15:           .double 0f1E-15
dConstME7:            .double 0f1E-7
dConstME3:            .double 0f1E-3
dConstME1:            .double 0f1E-1
dConstE0:             .double 0f1E0

/******************************************************************/
/*     Conversion d'un registre en décimal                                 */ 
/******************************************************************/
/* r0 contient la valeur et r1 l' adresse de la zone de stockage   */
/* modif 05/11/2021 pour garder les zéros de tête  */
/* et recadrage en début de zone */ 
conversion10SP:                // INFO: conversion10SP

    push {r1-r5,lr}
    mov r5,r1
    mov r4,#16
    mov r2,r0
    mov r1,#10                  // conversion decimale
1:                              // debut de boucle de conversion
    mov r0,r2                   // copie nombre départ ou quotients successifs
    udiv r2,r0,r1               // division par le facteur de conversion
    mls r3,r1,r2,r0
    add r3,r3,#48               // car c'est un chiffre    
    strb r3,[r5,r4]             // stockage du byte au debut zone (r5) + la position (r4)
    subs r4,r4,#1               // position précedente
    bge 1b
    movs r4,0
    strb r4,[r5,16]            // 0 final
100:    
    pop {r1-r5,pc}
/******************************************************************/
/*     Conversion d'un nombre 64 bits en décimal                                 */ 
/******************************************************************/
/* r0 partie basse et r1 partie haute     !/
/* r2 l' adresse de la zone de stockage   */
/* et sans recadrage en début de zone */ 
.equ TAILLEZONE64SP,   18
.thumb_func
conversion64SP:                // INFO: conversion64SP
    push {r1-r7,lr}
    mov r5,r2
    mov r6,r0
    mov r7,r1
    mov r4,#TAILLEZONE64SP
1:                              // debut de boucle de conversion
    mov r2,#10                  // conversion decimale
    mov r0,r6
    mov r1,r7
    bl division32R2023              // division par le facteur de conversion
    add r2,r2,#48               // car c'est un chiffre    
    strb r2,[r5,r4]             // stockage du byte au debut zone (r5) + la position (r4)
    mov r6,r0
    mov r7,r1
    subs r4,r4,#1               // position précedente
    
    
    bge 1b
    movs r4,0
    strb r4,[r5,#TAILLEZONE64SP + 1]            // 0 final
    mov r0,TAILLEZONE64SP
100:    
    pop {r1-r7,pc}  
/******************************************************************/
/*     Conversion d'un nombre 64 bits en décimal                                 */ 
/******************************************************************/
/* r0 partie basse et r1 partie haute     !/
/* r2 l' adresse de la zone de stockage   */
/* et avec recadrage en début de zone */ 
.equ TAILLEZONE64,   25
.thumb_func
conversion64:                // INFO: conversion64
    push {r1-r7,lr}
    mov r5,r2
    mov r6,r0
    mov r7,r1
    mov r4,#TAILLEZONE64
1:                              // debut de boucle de conversion
    mov r2,#10                  // conversion decimale
    mov r0,r6
    mov r1,r7
    bl division32R2023              // division par le facteur de conversion
    add r2,r2,#48               // car c'est un chiffre    
    strb r2,[r5,r4]             // stockage du byte au debut zone (r5) + la position (r4)
    mov r6,r0
    mov r7,r1
    subs r4,r4,#1               // position précedente
    cbz r0,2f
    b 1b
2:
    cbz r1,3f
    b 1b
3:
    mov r0,0                   // début de zone  
    
    add r4,r4,1                // ne peut pas être égal à 0 (car lg zone = 25)
4:
    ldrb r2,[r5,r4]
    strb r2,[r5,r0]
    add r0,r0,1
    add r4,r4,1
    cmp r4,TAILLEZONE64
    ble 4b
    
    movs r4,0
    strb r4,[r5,r0]            // 0 final
100:    
    pop {r1-r7,pc} 
/***************************************************/
/*   division number 64 bits in 2 registers by number 32 bits */
/*   unsigned */
/***************************************************/
/* r0 contains lower part dividende   */
/* r1 contains upper part dividende   */
/* r2 contains divisor   */
/* r0 return lower part quotient    */
/* r1 return upper part quotient    */
/* r2 return remainder               */
division32R2023:        @ INFO: division32R2023
    push {r3-r6,lr}    @ save registers
    mov r4,r2          @ save divisor
    mov r5,#0          @ init upper part divisor   
    mov r2,r0          @ save dividende
    mov r3,r1
    mov r0,#0          @ init result
    mov r1,#0
    mov r6,#0          @ init shift counter
1:                     @ loop shift divisor
    cmp r5,#0          @ upper divisor <0
    blt 2f
    cmp r5,r3
    it eq
    cmpeq r4,r2
11:
    bhs 2f             @ new divisor > dividende
    lsl r5,#1          @ shift left one bit upper divisor
    lsls r4,#1         @ shift left one bit lower divisor
    it cs
    orrcs r5,r5,#1     @ move bit 31 lower on upper
12:
    add r6,r6,#1       @ increment shift counter
    b 1b
2:                     @ loop 2
    lsl r1,#1          @ shift left one bit upper quotient
    lsls r0,#1         @ shift left one bit lower quotient
    it cs
    orrcs r1,#1        @ move bit 31 lower on upper
21:
    cmp r5,r3          @ compare divisor and dividende
    it eq
    cmpeq r4,r2
22:
    bhi 3f
    subs r2,r2,r4      @ <  sub divisor from dividende lower
    sbc r3,r3,r5       @ and upper
    orr r0,r0,#1       @ move 1 on quotient
3:
    lsr r4,r4,#1       @ shift right one bit upper divisor
    lsrs r5,#1         @ and lower
    it cs
    orrcs r4,#0x80000000 @ move bit 0 upper to  31 bit lower
    subs r6,#1         @ decrement shift counter
    bge 2b             @ if > 0 loop 2
    
100:
    pop {r3-r6,pc}

