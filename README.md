Cooldown
=========

By *Relena* 

Ce module enregistre les sorts lancé en combat et qui on un cooldown > 1. Il les affiche enssuite dans une petite interface.

* L'interface se redimentionne automatiquement.
* L'interface peut s'ouvrir automatiquement au début d'un combat. Ou pas.
* L'interface est deplacable.
* L'interface permet de selectioner avec précision les personnages que l'on souhaite suivre.
* La position de l'interface est automatiquement enregistré.

![Interface avec le thème sombre](http://imageshack.us/a/img856/3005/srr0.png "Interface avec le thème sombre")
![Interface avec le thème beige](http://imageshack.us/a/img163/8457/rhb5.png "Interface avec le thème beige")

Download + Compile:
-------------------

1. Install Git
2. git clone https://github.com/Dofus/Cooldown.git
3. mxmlc -output Cooldown.swf -compiler.library-path+=./modules-library.swc -source-path src -keep-as3-metadata Api Module DevMode -- src/Cooldown.as

Installation:
-------------

1. Create a new *Cooldown* folder in the *ui* folder present in your Dofus instalation folder. (i.e. *ui/Cooldown*)
2. Copy the following files in this new folder:
    * xml/
    * Cooldown.swf
    * Relena_Cooldown.dm
3. Launch Dofus
4. Enable the module in your config menu.
5. ...
6. Profit!
