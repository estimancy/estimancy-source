# Application d'un motif unitex sur des spécifications
Le(s) motif(s) à utiliser sont dans le répertoire `pattern`.
Pour appliquer un motif unitex sur un texte en utilisant python, suivre les étapes suivantes : 
1. Vérifier que le fichier `.yaml` correspondant à la langue souhaité existe, pour la langue français `unitex-fr.yaml` existe déjà dans ce répertoire. 

S'il n'existe pas, utiliser la commande suivante pour le créer selon la langue souhaitée: 
```bash
python build-config-file.py -l fr -d /path/to/Unitex-GramLab-3.1/French -o unitex-fr.yaml unitex.yaml
```
2. Lancer l'extraction des données à partir des spécifications en utilisant le motif `motif_data_global.fst2` et le fichier YAML configuré, utiliser la commande :
```bash
python do-concord.py -c unitex-fr.yaml -g patterns/motif_data_global.fst2 spec-presage.txt
```
