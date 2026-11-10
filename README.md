# Mobile Network Performance Analysis – France

## 1. Présentation du projet

Ce projet consiste à analyser et comparer les performances
des réseaux mobiles des quatre principaux opérateurs français :

- Orange
- SFR
- Bouygues Telecom
- Free Mobile

L'étude repose principalement sur des données publiques
provenant de l'ARCEP et de l'ANFR.

L'objectif est de transformer des données brutes en
informations exploitables pour comprendre les performances
des réseaux mobiles en France.

## 2. Problématique

Comment évaluer et comparer la qualité des réseaux mobiles
des opérateurs français selon les territoires, afin
d'identifier les disparités de performance et les zones
où la qualité de service est la plus faible ?

## 3. Objectifs de l'étude

Le projet cherchera notamment à :

- Comparer les débits descendants et montants des opérateurs.
- Étudier les différences de performances entre les territoires.
- Identifier les départements présentant les performances
  les plus faibles.
- Étudier la répartition géographique des antennes mobiles.
- Examiner l'évolution du déploiement de la 5G.
- Étudier les zones concernées par le dispositif
  de couverture ciblée.

## 4. Sources de données

Les données utilisées dans cette version proviennent principalement de l'ARCEP.

### ARCEP – Qualité de service 2025

Mesures de qualité des réseaux mobiles réalisées
en France métropolitaine.
Source :
https://data.arcep.fr/mobile/mesures_qualite_arcep/2025/Metropole/

### ARCEP – Sites mobiles 2026

Données concernant les sites mobiles et le déploiement
des technologies 4G et 5G.

Source :
https://data.arcep.fr/mobile/sites/last/

### ARCEP – Dispositif de couverture ciblée 2026

Données concernant les zones et les sites associés
au dispositif de couverture ciblée.

Source :
https://data.arcep.fr/mobile/dispositif_couverture_ciblee/last/index.html

## 5. Technologies utilisées

### Analyse et traitement des données
- Python
- Pandas
- NumPy
- Jupyter Notebook

### Visualisation
- Matplotlib
- Seaborn
- Power BI (prévu)

### Base de données
- PostgreSQL
- SQL
- SQLAlchemy
- Psycopg

### Environnement de développement
- VS Code
- Git
- GitHub

## 6. Organisation du projet

```text
mobile-network-performance-analysis/
│
├── analyses_jupyter/
│   └── 01_data_exploration.ipynb
│
├── documentation/
│
├── donnees/
│   ├── donnees_originales/
│   └── donnees_preparees/
│
├── rapports/
│   └── graphiques/
│
├── sql/
│
├── src/
│
├── .gitignore
└── requirements.txt
```
