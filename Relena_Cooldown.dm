<module>

    <!-- Information sur le module -->
    <header>
        <!-- Nom affiché dans la liste des modules -->
        <name>Cooldown</name>        
        <!-- Version du module -->
        <version>1.0</version>
        <!-- Dernière version de dofus pour laquelle ce module fonctionne -->
        <dofusVersion>2.11</dofusVersion>
        <!-- Auteur du module -->
        <author>Relena</author>
        <!-- Courte description -->
        <shortDescription>Quand votre ennemi pourra t'il relancer ce sort?</shortDescription>
        <!-- Description détaillée -->
        <description>Ce module écoute les sorts lancé au cour d'un combat, et enregistre leur cooldown.</description>
	</header>

    <!-- Liste des interfaces du module, avec nom de l'interface, nom du fichier squelette .xml et nom de la classe script d'interface -->
    <uis>
		<ui name="config" file="xml/config.xml" class="ui::ConfigUI"/>
        <ui name="cooldown" file="xml/cooldown.xml" class="ui::CooldownUI" />
    </uis>
    
    <script>Cooldown.swf</script>
    
</module>
