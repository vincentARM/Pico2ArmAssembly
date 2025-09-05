/* routine de conversion de float */
/* algorithme   */
.syntax unified
.cpu cortex-m33
.thumb
.text
.global convertirFloat
/******************************************************************/
/*     Conversion Float                                            */ 
/******************************************************************/
/* s0  contient la valeur du Float */
/* r0 contient l'adresse de la zone de conversion  mini 20 caractères*/
/* r0 retourne la longueur utile de la zone */
convertirFloat:               @ INFO: convertirFloat
    push {r1-r7,lr}
    vpush {s1-s2}
    mov r6,r0                 @ save adresse de la zone
    vmov r0,s0
    movs r7,#0                @ nombre de caractères écrits
    movs r3,#'+'
    strb r3,[r6]              @ forçage du signe +
    mov r2,r0
    lsls r2,#1                 @ extraction 31 bit
    bcc 1f                    @ positif ?
    lsrs r0,r2,#1              @ suppression du signe si negatif
    movs r3,#'-'               @ et signe -
    strb r3,[r6]
1:
    adds r7,#1                 @ position suivante
    cmp r0,#0                  @ cas du 0 positif ou negatif
    bne 2f
    movs r3,#'0'
    strb r3,[r6,r7]           @ stocke le caractère 0
    adds r7,#1
    movs r3,#0
    strb r3,[r6,r7]           @ stocke le 0 final
    mov r0,r7                 @ retourne la longueur
    b 100f
2: 
    ldr r2,iMaskExposant
    mov r1,r0
    ands r1,r2                @ exposant à 255 ?
    cmp r1,r2
    bne 4f
    lsls r0,#10                @ bit 22 à 0 ?
    bcc 3f                    @ oui 
    movs r2,#'N'               @ cas du Nan. stk byte car pas possible de stocker un int 
    strb r2,[r6]              @ car zone non alignée
    movs r2,#'a'
    strb r2,[r6,#1] 
    movs r2,#'n'
    strb r2,[r6,#2] 
    movs r2,#0                  @ 0 final
    strb r2,[r6,#3] 
    movs r0,#3
    b 100f
3:                             @ cas infini positif ou négatif
    movs r2,#'I'
    strb r2,[r6,r7] 
    adds r7,#1
    movs r2,#'n'
    strb r2,[r6,r7] 
    adds r7,#1
    movs r2,#'f'
    strb r2,[r6,r7] 
    adds r7,#1
    movs r2,#0
    strb r2,[r6,r7]
    mov r0,r7
    b 100f
4:
    bl normaliserFloat
    mov r5,r0                @ save exposant
    VCVT.U32.f32  s2,s0      @ valeur entière de la partie entière
    vmov r0,s2               @ partie entière
    VCVT.F32.U32  s1,s2      @ remise en float
    vsub.f32 s1,s0,s1        @ pour extraire partie fractionnaire
    vldr s2,iConst1
    vmul.f32 s1,s2,s1        @ pour la recadrer en partie entière

    VCVT.U32.f32  s1,s1      @ convertir en entier
    vmov r4,s1               @ valeur fractionnaire
                             @ conversion partie entière dans r0
    mov r2,r6                @ save adresse début zone 
    adds r6,r7
    mov r1,r6
    bl conversion10
    add r6,r0
    movs r3,#','
    strb r3,[r6]
    adds r6,#1
 
    mov r0,r4                @ conversion partie fractionnaire
    mov r1,r6
    bl conversion10SP        @ routine spéciale car conservatopn des 0 en tête
    add r6,r0
    subs r6,#1
                             @ il faut supprimer les zéros finaux
5:
    ldrb r0,[r6]
    cmp r0,#'0'
    bne 6f
    subs r6,#1
    b 5b
6:
    cmp r0,#','
    bne 7f
    subs r6,#1
7:
    adds r6,#1
    movs r3,#'E'
    strb r3,[r6]
    adds r6,#1
    mov r0,r5                  @ conversion exposant
    mov r3,r0
    lsls r3,#1
    bcc 4f
    rsbs r0,r0,#0
    movs r3,#'-'
    strb r3,[r6]
    adds r6,#1
4:
    mov r1,r6
    bl conversion10
    add r6,r0
    
    movs r3,#0
    strb r3,[r6]
    adds r6,#1
    mov r0,r6
    subs r0,r2                 @ retour de la longueur de la zone
    subs r0,#1                  @ sans le 0 final

100:
    vpop {s1-s2}
    pop {r1-r7,pc}
iMaskExposant:            .int 0xFF<<23
iConst1:                  .float 0f1E9

/***************************************************/
/*   normaliser float                              */
/***************************************************/
/* r0 contient la valeur du float (valeur toujours positive et <> Nan) */
/* s0 retourne la nouvelle valeur */
/* r0 retourne l'exposant */
normaliserFloat:            @ INFO: normaliserFloat
    push {lr}               @ save  registre
    vmov s0,r0              @ valeur de départ
    movs r0,#0              @ exposant
    vldr s1,iConstE7        @ pas de normalisation pour les valeurs < 1E7
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    blo 10f                 @ si s0 est < iConstE7
    
    vldr s1,iConstE32
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    blo 1f
    vldr s1,iConstE32
    vdiv.f32 s0,s0,s1
    adds r0,#32
1:
    vldr s1,iConstE16
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    blo 2f
    vldr s1,iConstE16
    vdiv.f32 s0,s0,s1
    adds r0,#16
2:
    vldr s1,iConstE8
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    blo 3f
    vldr s1,iConstE8
    vdiv.f32 s0,s0,s1
    adds r0,#8
3:
    vldr s1,iConstE4
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    blo 4f
    vldr s1,iConstE4
    vdiv.f32 s0,s0,s1
    adds r0,#4
4:
    vldr s1,iConstE2
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    blo 5f
    vldr s1,iConstE2
    vdiv.f32 s0,s0,s1
    adds r0,#2
5:
    vldr s1,iConstE1
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    blo 10f
    vldr s1,iConstE1
    vdiv.f32 s0,s0,s1
    adds r0,#1

10:
    vldr s1,iConstME5        @ pas de normalisation pour les valeurs > 1E-5
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    bhi 100f
    vldr s1,iConstME31
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    bhi 11f
    vldr s1,iConstE32

    vmul.f32 s0,s0,s1
    subs r0,#32
11:
    vldr s1,iConstME15
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    bhi 12f
    vldr s1,iConstE16
    vmul.f32 s0,s0,s1
    subs r0,#16
12:
    vldr s1,iConstME7
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    bhi 13f
    vldr s1,iConstE8
    vmul.f32 s0,s0,s1
    subs r0,#8
13:
    vldr s1,iConstME3
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    bhi 14f
    vldr s1,iConstE4
    vmul.f32 s0,s0,s1
    subs r0,#4
14:
    vldr s1,iConstME1
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    bhi 15f
    vldr s1,iConstE2
    vmul.f32 s0,s0,s1
    subs r0,#2
15:
    vldr s1,iConstE0
    vcmp.f32 s0,s1
    vmrs APSR_nzcv,FPSCR
    bhi 100f
    vldr s1,iConstE1
    vmul.f32 s0,s0,s1
    subs r0,#1

100:                       @ fin standard de la fonction
    pop {pc}               @ restaur des registres
.align 2
iConstE7:             .float 0f1E7
iConstE32:            .float 0f1E32
iConstE16:            .float 0f1E16
iConstE8:             .float 0f1E8
iConstE4:             .float 0f1E4
iConstE2:             .float 0f1E2
iConstE1:             .float 0f1E1
iConstME5:            .float 0f1E-5
iConstME31:           .float 0f1E-31
iConstME15:           .float 0f1E-15
iConstME7:            .float 0f1E-7
iConstME3:            .float 0f1E-3
iConstME1:            .float 0f1E-1
iConstE0:             .float 0f1E0
/******************************************************************/
/*     Conversion d'un registre en décimal                                 */ 
/******************************************************************/
/* r0 contient la valeur et r1 l' adresse de la zone de stockage   */
/* modif 05/11/2021 pour garder les zéros de tête  */
/* et recadrage en début de zone */ 
conversion10SP:            @ INFO: conversion10SP
    push {r1-r5,lr}        @  save des registres 
    mov r5,r1
    mov r4,#8
    mov r2,r0
    mov r1,#10             @ conversion decimale
1:                         @ debut de boucle de conversion
    mov r0,r2              @ copie nombre départ ou quotients successifs
	udiv r2,r0,r1
	mls r3,r2,r1,r0        @ calcul du reste
    add r3,#48             @ car c'est un chiffre   
    strb r3,[r5,r4]        @ stockage du byte au debut zone (r5) + la position (r4)
    subs r4,r4,#1          @ position précedente
    bge 1b
    mov r0,#8
    mov r3,#0
    strb r3,[r5,r0]
100:    
    pop {r1-r5,lr}
    bx lr    



/********************************************************************/
/*********************************************/
/*constantes */
/********************************************/
//.include "../constantesARM.inc"
