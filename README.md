# pickdev-scripts

Ce Repo contient les différents scripts bash/js/.. qui nous seront utiles durant le développement

## pickdev (bash)

##### Contexte

Pour visualiser un site sur un serveur apache, on déplace ses fichiers dans /var/www/html.

Petit problème: si on veut travailler sur un autre site web ? Il faut manuellement déplacer les fichiers dans un autre dossier et puis
redéplacer les nouveaux fichiers dans le dossier html.

Ceci est un peu relou donc j'ai décidé d'écrire ce petit script qui va utiliser des project.id et noms de dossiers pour faire la gestion des projets,
vérification des versions git (pour voir s'il faut créer un dossier backup) ...

##### Utilisation

Pour l'utiliser, simplement créer un fichier project.id dans chaque dossier de projet, avec le nom du dossier (=nom de projet).

```
$ cd ReactTest
$ cat project.id
ReactTest
$
```

Ensuite, dès que vous voulez mettre en place un projet sur le serveur apache, tapez "pickdev 'nom_projet'" et hops tout est pris en charge :D

Il faut configurer dans le script dans les premières lignes, le dossier home de tes projets (ex: /home/user/rendu) et aussi le dossier où le serveur apache tourne
(normalement c'est /var/www/html)

##### Conclusion

Ah oui et aussi, je viens de me rendre compte que ce script sert à rien car au final c'est node qui fera le serveur dans chaque dossier de projet
