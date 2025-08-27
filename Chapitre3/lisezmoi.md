### Modification du délai de clignotement par le core1

Pour nous amuser encore avec la led, nous allons maintenant modifier le délai d’extinction et d’allumage de la led un utilisant le coeur 1.

Pour cela nous devons écrire des fonctions de lecture et d’écriture des files FIFO de communication entre les 2 coeurs. C’est le rôle des fonctions :
```
multicore_fifo_write
multicore_fifo_read
multicore_fifo_drain
```
Nous écrivons la fonction qui sera exécutée par le core 1 : execCore1 dont nous allons passer l’adresse à la fonction de démarrage du core 1 : multicore_init_core1.

Dans cette dernière fonction, nous commençons par positionner dans la sequence d’initialisation, l’adresse de la VTOR, de la fin de pile et l’adresse de la fonction  execCore1 (qui doit toujours se terminer par 1 contrainte thumb!). Puis nous envoyons chaque donnée de la sequence au coeur1 pour le réveiller et nous vérifions sa réponse à chaque envoi.

Dans le programme principal, nous appelons comme au chapitre précédent, la routine initdebut puis la routine  multicore_init_core1, et nous appelons le clignotement de la led.
