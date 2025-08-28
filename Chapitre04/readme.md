###  Mise en place de l'horloge systeme

Cette fois çi, nous allons mettre en place l’horloge système qui va faire fonctionner les coeurs à 150 mhz car ces premiers programmes fonctionnaient avec l’horloge par défaut (oscillateur rosc) qui tourne à 11mhz.
Pour vérifier si l’horloge bascule bien, nous allumerons la led une première fois puis nous la referons clignoter avec la nouvelle horloge.

Donc nous commençons par lancer l’oscillateur cristal dans la fonction initOscCristal et avant de démarrer l’horloge système, nous devons initialiser le PLL système qui va préparer la fréquence de 150 Mhz. Si vous voulez changer la fréquence, je vous conseille de lire le chapitre  8.6 de la datasheet pour voir le calcul des paramètres à modifier dans la fonction pll_init.

L’horloge système est démarrée dans la fonction init_clk_sys .

Comme il commence à être pénible de déconnecté le pico du port usb pour le relancer en mode bootsel, j’ai ajouté en fin de fonction principale une fonction qui remet le pico en mode bootsel et donc il est facile de copier un nouveau fichier uf2 sans débrancher rebrancher le pico.

J’ai modifié aussi la fonction d’attente pour avoir un délai d’une milliseconde par unité contenu dans le registre r0. Ainsi une valeur 1000 doit donner un délai 1 seconde.

L’exécution montre la led clignoter 5 fois avec un délai de 1s entre chaque eclair puis clignoter beaucoup plus rapidement 10 fois et le pico bascule en mode bootsel.

Si vous voulez relancer l’execution, il suddit de débrancher, rebrancher le pico.
