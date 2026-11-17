# Rapport Power BI — Mobile Network Performance

Ce dossier contient un projet Power BI (`.pbip`) construit à partir de `vue_mesures_detaillees.csv`.

## Contenu du rapport

- **Comparaison des opérateurs** : six KPI et quatre graphiques comparant Orange, Bouygues, SFR et Free.
- **Analyse par zone** : comparaison des zones denses, intermédiaires, rurales et touristiques, avec filtres opérateur et zone.
- **Évolution temporelle** : évolution quotidienne des indicateurs par opérateur, avec filtre de zone.

## Données source

Le rapport s'appuie sur les 336 954 lignes et 15 colonnes du CSV fourni.
Période couverte : du 26 mai 2025 au 2 septembre 2025.
La colonne `code_commune_insee` est importée en texte afin de préserver le format des codes commune.

Les colonnes de mesures propres à un protocole restent vides pour les autres protocoles : c'est attendu.
Les indicateurs `t`/`f` sont convertis en valeurs logiques lors de l'importation.

## Connexion du CSV (une seule fois)

Le chemin absolu du fichier varie selon l'ordinateur. Après avoir extrait ce dossier dans ton projet :

1. Dans Windows, ouvre PowerShell à la racine du projet.
2. Exécute :

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\powerbi\configurer_source_powerbi.ps1
   ```

   Le script place automatiquement le chemin local du CSV dans le paramètre Power BI `pCheminCSV`.
3. Ouvre `powerbi\rapport\MobileNetworkPerformance.pbip` avec Power BI Desktop.
4. Si Power BI te propose d'appliquer des modifications ou d'actualiser les données, accepte.

Si tu ne peux pas exécuter le script, ouvre Power BI Desktop > Transformer les données > Gérer les paramètres, puis remplace la valeur de `pCheminCSV` par le chemin complet du CSV.

## GitHub

Le CSV est un fichier de données local. Il est préférable de ne pas le pousser dans GitHub si ton `.gitignore` contient déjà :

```gitignore
powerbi/exports/*.csv
```

À pousser :
- `powerbi/rapport/MobileNetworkPerformance.pbip`
- `powerbi/rapport/MobileNetworkPerformance.Report/`
- `powerbi/rapport/MobileNetworkPerformance.SemanticModel/`
- `powerbi/configurer_source_powerbi.ps1`
- `powerbi/README_POWERBI.md`

Le fichier CSV reste local et permet l'actualisation des données sur ton ordinateur.

## Indicateurs inclus

- Nombre de mesures et nombre de communes
- Débit descendant médian (DOWNLOAD)
- Débit montant médian (UPLOAD)
- Temps médian de navigation Web (WEB)
- Taux de chargement Web inférieur à 5 secondes et à 10 secondes
- Taux de streaming en qualité parfaite et qualité correcte (STREAM)
- Taux de réussite des envois de fichiers (ULH)

Les médianes et les taux sont recalculés dans le contexte des filtres du rapport. Les colonnes propres à un protocole sont donc traitées avec leur filtre de protocole correspondant.

## Résultats de contrôle sur le CSV fourni

| Indicateur | Orange | Bouygues | SFR | Free |
|---|---:|---:|---:|---:|
| Débit descendant médian (Mbps) | 232,243 | 154,674 | 131,007 | 100,812 |
| Débit montant médian (Mbps) | 14,180 | 9,203 | 9,169 | 5,018 |
| Temps médian Web (s) | 2,34 | 2,48 | 2,48 | 2,67 |
| Web chargé < 5 s | 89,34 % | 85,19 % | 85,10 % | 82,30 % |
| Streaming parfait | 92,89 % | 91,50 % | 90,90 % | 89,45 % |
| Envoi ULH réussi | 92,69 % | 90,84 % | 89,44 % | 86,25 % |

Ces valeurs sont des contrôles calculés sur le fichier source fourni, sans filtre de zone ni de date.

## Note sur le format

Le `.pbip` est le format de projet Power BI, adapté au suivi des fichiers dans Git. Il contient la définition du rapport PBIR et le modèle sémantique TMSL. Le fichier `.pbip` doit être ouvert avec Power BI Desktop.

**Contrôle technique effectué ici :** le CSV a été lu, les 15 colonnes/types ont été profilés, tous les fichiers JSON du projet ont été relus, les références de champs et de mesures des 24 visuels ont été contrôlées et l'archive ZIP a été testée. L'ouverture et le rendu final doivent néanmoins être confirmés dans Power BI Desktop sur ton ordinateur.
