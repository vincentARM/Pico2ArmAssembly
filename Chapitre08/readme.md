### Mesure de la température 

Cette fois ci, nous allons utiliser le capteur de température intégré au pico 2 pour effectuer quelques opérations en virgule flottante avec des nombres en 32 bits de type float.

Voir le paragraphe : 12.4. ADC and Temperature Sensor

Pour cela il nous faut ajouter une option lors de la compilation pour indiquer au compilateur que nous allons utiliser des instructions en virgule flottante (fpu) :
```
AOPS = --warn --fatal-warnings -mcpu=cortex-m33 -mfpu=vfp -mfloat-abi=hard
```
Dans le programme principale il faut ajouter une routine pour autoriser le processeur fpu comme ceci :
```
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
```
Puis dans la commande temp, il nous faut lancer l’horloge spécifique ADC à une fréquence de 48 Mhz. Pour le vérifier, j’ai ajouté la routine de calcul de la fréquence d’une horloge :
calculerFrequenceReg

Bon, j’ai fait simple et je n’adffiche que les registres pour avoir la frequence en hexa dans le registre r0.

Nous avons la valeur 0x0000C1A3 ce qui correspons à 49 571 milliers de hertz soit à peu prés 48Mhz.

Ensuite nous appelons la routine d’initialisation du capteur ADC : initADC puis la routine de mesure de la température : testTemp

Dans cette dernière, nous effectuons les calculs proposés dans la datasheet 12.4.6. Temperature sensor en virgule flottante simple précision.

Il faut adapter la valeur proposée 27 en fonction de votre environnement.

Pour terminer, il faut convertir le résultat de float en string pour l’afficher. Pour cela j’ai ajouté un fichier qui contient une routine de conversion un peu particulière mais peut être plus simple qu’une conversion standard.
Il faut donc ajouter une étape de compilation dans le fichier makefile pour le fichier routineConvFloat32.s

Le résultat est un peu brut avec toutes les décimales. Si vous vous en sentez le courage, vous pouvez essayer de tronquer le résultat à une ou deux décimales simplement.

Voici un exemple d’exécution :
```
Demarrage normal ARM.
Entrez une commande (ou aide) : temp
Température
Vidage registres : Frequence ADC en hexa dans r0
r0  : 0000C1A3  r1  : 4001006C  r2  : 10000800  r3  : 10000000
r4  : 6850A201  r5  : 88526891  r6  : 04F54710  r7  : 400E0014
r8  : 43280035  r9  : 00000000  r10 : 10000000  fp  : 62707361
r12 : BD687000  sp  : 20040800  lr  : inconnu   pc  : 100000CF
debutADC
Température = +24,81983756E0
Entrez une commande (ou aide) : aff
Non implanté
Entrez une commande (ou aide) : test
Non implanté
Entrez une commande (ou aide) :
```
