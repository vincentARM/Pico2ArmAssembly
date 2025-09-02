### Utilsation de macros, affichage registres et mémoire

Nous allons voir maintenant  l’implantation de macros qui vont nous permettre d’afficher facilement à tout endroit du code, le contenu de tous les registres et le contenu de la memore.

Pour cela nous ajoutons un fichier ficmacros.inc qui contient les macros :
afficherLib :  affiche un libellé quelconque
affregtit   :  affiche le contenu des registres
affmemtit   :  affiche le contenu de x tranches de mémoire de 16 octets

Dans le fichier  routinesARMGit.s, nous ajoutons les routines qui permettent ces affichages avec les sous-routines nécessaires.

Dans le programme principal nous insérons le fichier des macros avec la pseudo instructions include et nous ajoutons 2 commandes supplémentaires bit et test.

Pour la commande aff, nous ajoutons l’appel à la macro d’affichage d’un libellé en tapant seulement 
afficherLib commandeAff
Si nous voulons des espaces il faut mettre le libellé entre quotes :
afficherLib « commande Aff »

Puis nous chargeons une adresse mémoire quelconque dans le registre r0 et nous appelons la macro d’affichage de la mémoire :
affmemtit buffer r0 3

avec buffer comme libellé, r0 pour indiquer que l’adresse de début est dans ce registre et 3 pour avoir 3 lignes de 16 octets.
Remarque : la macro actuelle n’accepte que les registres r0 ou r1.
Voici le résultat :
```
Mémoire  adresse : 20000C00  buffer
20000C00 *61 66 66 00 00 00 00 00 00 00 00 00 00 00 00 00  aff.............
20000C10  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
20000C20  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  .............…
```

Puis nous testons la commande movt qui permet d’ajouter dans la partie haute une valeur de 16 bits. Cela permet en 2 instructions d’alimenter les 32 bits d’un registe et nous appelons l’affiche du contenu de tous les registres avec la macro :
affregtit testmacro

avec le résultat suivant :
```
Vidage registres : testmacro
r0  : 56781234  r1  : 2000003C  r2  : 20000280  r3  : 2000064C
r4  : 6850A201  r5  : 88526891  r6  : 04F54710  r7  : 400E0014
r8  : 43280035  r9  : 00000000  r10 : 10000000  fp  : 62707361
r12 : 2332BF00  sp  : 20040800  lr  : inconnu   pc  : 100000C3
```

Ces 3 macros ne détruisent aucun registre et peuvent donc être placé n’importe où pour le  débogage.

Dans la commande bin, nous testons les nouvelles instructions du M33 de manipulation des bits et dans la commande test nous testons les instructions cbz  et it qui évitent d’avoir pour des cas simples des instructions supplémentaires et des sauts à des étiquettes.

Pour le test sur les manipulation des bits, nous appelons une routine d’affichage du contenu du registre r0 en base 2 : bl affRegBin
J’aurais pu créer une macro mais cette routine ne sera pas utilisée très souvent par rapport aux autres.

Voici un résultat d’exécution :
```
Entrez une commande (ou aide) : bit
affichage bits
Affichage binaire :
00000000 00000000 00000000 00001100
instruction sbfx cas negatif
Affichage binaire :
11111111 11111111 11111111 11111110
instruction sbfx cas positif
Affichage binaire :
00000000 00000000 00000000 00000001
instruction ubfx
Affichage binaire :
00000000 00000000 00000000 00000101
instruction bfc
Affichage binaire :
00000000 00000000 00000000 00000001
instruction bfi
Affichage binaire :
00000000 00000000 00000001 10000001
Entrez une commande (ou aide) : test
Comparaison et saut
Registre nul

test instruction IT
Vidage registres : testIT
r0  : 00000005  r1  : 0000000B  r2  : 0001F000  r3  : 00000003
r4  : 00000004  r5  : 88526891  r6  : 04F54710  r7  : 400E0014
r8  : 43280035  r9  : 00000000  r10 : 10000000  fp  : 62707361
r12 : 2332BF00  sp  : 20040800  lr  : inconnu   pc  : 100003A3
Vidage registres : testIT2
r0  : 00000005  r1  : 0000000B  r2  : 0001F000  r3  : 00000003
r4  : 0000000F  r5  : 88526891  r6  : 04F54710  r7  : 400E0014
r8  : 43280035  r9  : 00000000  r10 : 10000000  fp  : 62707361
r12 : 2332BF00  sp  : 20040800  lr  : inconnu   pc  : 100003D3
Entrez une commande (ou aide) :

```
