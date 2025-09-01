### Connexion USB
Les programmes précédents ont amené  la constructions de briques qui vont nous permettre de construire des programmes plus intéressants et en particulier d’établir la communication par le port USB à un ordinateur hôte pour afficher des messages.

Cette fois ci, nous allons donc ajouter un fichier de routines pour gérer le protocole USB routinesPicoUsbGit.s : attention j’ai repris mon programme du RP2040 et je l’ai adapté au pico2 avec quelques petites améliorations, et donc il peut comporter encore des erreurs.

Dans le fichier des routines, nous ajoutons le lancement du PLL usb et de l’horloge spécifique à l’USB car la fréquence requise pour ce protocole est de 48 Mhz.

Dans le fichier  routinesPicoUsbGit.s, nous avons toutes les routines de gestion du protocole et les routines envoyerMessages et recevoirMessage qui vont permettre au programme maître de dialoguer avec l’hôte. 
Nous ajoutons dans le fichier makefile les lignes pour compiler et lier ces routines.

Dans le programme principal, après l’initialisation et le lancement des horloges, nous appelons la routine initUsbDevice qui va initialiser les fonctions necessaires à la connexion USB en utilisant l’interruption 14  USBCTRL_IRQ.

Puis le programme attend que l’utilisateur établisse une connexion serie USB. En ce qui me concerne j’utilise windows11 et le logiciel putty pour me connecter sur le port série com4.

Dès la connexion établie, le programme attend la saisie d’une commande, puis analyse cette commende et l’exécute. Ici nous avons de commande aff et fin qui termine le programme et remet le pico en mode bootsel.
La commande aff (pour affichage) montre l’exemple d’affiche du contenu d’un registre soit en utilisant la pile soit par le registre r0.

Vous remarquerez que dans le cas de la pile il faut réaligner la pile de 4 octets car elle a été déphasée par l’utilisation du push avant l’appel.

Voici le résultat de la connexion : 
```
Demarrage normal ARM.
Entrez une commande (ou aide) : aff
Valeur du registre : 20040800
Valeur du registre : 200009C0
Entrez une commande (ou aide) : aide
aff test
fin reboot BOOTSEL
Entrez une commande (ou aide) : fin
Entrez une commande (ou aide) :
```

