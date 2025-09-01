### Mise en place vtor et traitement des exceptions
Nous allons voir la mise en place de la table vectorielle des traitement ses exceptions et des interruptions (VTOR). En effet cette table sera necessaire dans la suite des programmes de cette série.
Mais notre programme assembleur commence à devenir important et nous allons le dissocier en plusieurs autres fichiers. 

Tout d’abord, nous retirons toutes les constantes pour les regrouper dans le fichier constantesPico2Git.inc que nous intégrons dans notre source avec la pseudo instruction :
```
.include "./constantesPico2Git.inc". 
```

Ensuite, nous transferrons toutes le routines qui ont un intérêt général dans le fichier routinesARMGit.s et nous modifions le fichier makefile pour compiler ces routines les rattacher au programme principal avec :

```
chap5.bin :   memmap.ld chap5.o routinesARMGit.o
	$(ARMGNU)\ld  -T memmap.ld  chap5.o ./routinesARMGit.o -o chap5.elf -M >chap5_map.txt
	$(ARMGNU)\objdump -D chap5.elf > chap5.list
	$(ARMGNU)\objcopy -O binary chap5.elf chap5.bin

routinesARMGit.o : ./routinesARMGit.s ./constantesPico2Git.inc
	$(ARMGNU)\as $(AOPS)  ./routinesARMGit.s -o ./routinesARMGit.o
```

Dans le programme source chap5.s, nous créons dans la .data la table VTOR composées d’adresses vers des sous routines et dont le plus grand nombres pointent vers une boucle.
Vous remarquerez que la VTOR a un alignement particulier sur une frontière de 64 octets (2 puissance 5).

Dans les premières adresses, nous trouvons l’adresse de la pile, l’adresse du début du programe (ou une adresse de réinitialisation du programme)  puis les routines pour gerer les principales exceptions. Ici nous nous contentons dans les sous-routines d’allumer la led avec un nombre d’éclairs différent pour chaque type.

Pour tester une interruption, nous allons utiliser l’interruption de l alarme timer code 0 et nous positionnons l’adresse de la routine à appeler testInter dans le poste 16 de la VTOR. Les 15 premiers postes de la VTOR sont réservés pour le traitement des exceptions par les coeurs ARM et l’interruption que nous voulons gerer est l’interruption 0 soit le premier poste libre après ces 15 postes pour stocker l’adresse de la routine.

Dans la fonction principale, nous stockons l’adresse de notre VTOR dans l’adresse prévue pour que le firmware se servent bien de notre table pour gérer les exceptions et les interruptions. Il s’agit de l’adresse  PPB_BASE + PPB_VTOR soit 0xE000ED08  (voir le chapitre 3.7.5 de la datasheet).

Ensuite j’ai laissé dans le code un exemple de modification du poste 16 de la table avec l’adresse de la routine testinter. Vous pouvez enlever le commentaire de l’instruction de stockage et mettre en commentaire l’adresse 16 dans la VTOR pour vérifier le bon fonctionnement.

Puis nous trouvons les instructions d’autorisation de l’interruption (mise en jour du bit 0 des différents registres) puis le forçage de l’interruption pour tester le bon enchainement.

J’ai ajouté avant le forçage, un exemple d’une erreur (tentative de lecture d’une adresse memoire invalide) qui va déclencher 12 éclats de la led. L’instruction fautive est en commentaire et vous pouvez le supprimer pour voir si cela fonctionne.

Dans la routine testInter, nous commençons par invalider l’interruption, puis nous allumons la led 8 fois et au bout d’un certain temps, nous faisons basculer le pico en mode bootsel pour recharger un nouveau fichier .uf2

Cette exemple fonctionne très bien mais quoi faire s’il ne fonctionne pas avec votre matériel ? Et bien il faut réussir à le déboguer avec l’utilisation de la seule Led ( ou avec une sonde de débogage voir la documentation raspberry pico).
Donc déjà la led doit clignoter 2 fois dès le branchement pour indiquer que les premières routines sont ok (recopie de la data ok, lancement des horloges ok, maj de l’adresse VTOR ok).
Donc ensuite il faut exeminer le code et ajouter des appels à la ledEclats avec un nombre d’éclats diddérent. Bon courage.
