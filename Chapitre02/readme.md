### Eclats de la Led

Dans ce chapitre, nous allons faire clignoter la led un certain nombre de fois. Cette fonction peut nous servir à tester un programme tant que nous n’avons pas des fonctions d’écriture et de communication par le port USB.

Pour compliquer un petit peu, nous allons stocker le nombre d’éclats dans une zone de la .data. Pour un bon fonctionnement,  cela nous oblige à prévoir une routine qui copie le contenu de la daya se trouvant en mémoire flash dans la ram : c’est le rôle de la fonction initDebut. Les adresses des données _debutFlashData, _debutRamData et _debutRamBss sont données par les instructions du linker contenues dans le fichier memmap.ld.

Nous en profitons aussi pour initialiser à zéro les données de la BBS car cela n’est fait nulle part quand on écrit un programme assembleur hors SDK.

La fonction main se contente d’appeler la fonction initDebut, puis récupère le contenu de la variable iNbEclats pour la passer à la routine ledEclats.

Après un délai d’attente, le programme appelle de nouveau cette routine mais en passant le nombre d’éclats directement dans le registre r0.

A l‘execution *, la Led effectue 4 éclairs puis après un temps d’attente 2 éclairs.

Vous pouvez recompiler le programme en mettant en commentaire l’appel à la fonction initDebut et vous constaterez que la led n’effectue plus les éclats.

Remarque importante : si vous modifiez dans le fichier memmap.ld les adresses des débuts de la data ou de la bss, il faut vous assurer que ces adresses soient bien alignées sur 4 octets pour éviter un problème lors de la copie dans initDebut.

