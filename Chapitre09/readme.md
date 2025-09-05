### Coprocesseur doubles CDC

Nous allons voir l’utilisation du coprocesseur pour effectuer des opérations en virgule flottante avec des doubles. Voir la documentation 3.6.2. Double-precision coprocessor (DCP)
Pour cela nous ajoutons le fichier routinesPicoCoproc.s qui contient les routines de conversion et les routines de calcul en double précisions .

Je ne vous cache pas que la programmation du coprocesseur est assez complexe.
Quelques exemples sont donnés dans la datasheet lais il faudra chercher sur internet les traductions des différentes opérations envisagées.

Dans le programme principal, nous nous contentons de tester une addition, une multiplication et une division.
Je vous déconseille d’utiliser ces programmes pour des applications réelles car ils doivent comporter quelques erreurs.

voici un exemple d’exécution :
```
Demarrage normal ARM.
Coprocesseur Ok
Entrez une commande (ou aide) : aff
Addition doubles
+10554
Multiplication doubles
+26543,039999999997235136
Entrez une commande (ou aide) : test
Division
+57,421395348837208422
Entrez une commande (ou aide) :
```
Bon, maintenant, nous avons fait un tour de quelques possibilités de la programmation en assembleur ARM du pico 2. Il reste encore beaucoup à voir et donc je vous laisse le soin de continuer cette exploration :  GPIO, dma, systick, uart etc.
