import os
from pathlib import Path

import pandas as pd
import matplotlib.pyplot as plt
import psycopg2

from dotenv import load_dotenv


# =========================================
# 1. CONFIGURATION
# =========================================

DOSSIER_PROJET = Path(__file__).resolve().parents[1]

load_dotenv(DOSSIER_PROJET / ".env")

configuration_bd = {
    "host": os.getenv("DB_HOST"),
    "port": int(os.getenv("DB_PORT", "5432")),
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD")
}

DOSSIER_FIGURES = DOSSIER_PROJET / "figures"
DOSSIER_FIGURES.mkdir(parents=True, exist_ok=True)


# =========================================
# 2. RECUPERER LES RESULTATS SQL
# =========================================

def lire_requete(connexion, requete):

    with connexion.cursor() as curseur:

        curseur.execute(requete)

        colonnes = [
            description[0]
            for description in curseur.description
        ]

        lignes = curseur.fetchall()

    return pd.DataFrame(lignes, columns=colonnes)


# =========================================
# 3. CREER UN GRAPHIQUE
# =========================================

def creer_graphique(donnees, titre, nom_indicateur,
                    nom_fichier, ordre_inverse=False):

    if donnees.empty:
        print("Aucune donnée :", titre)
        return

    valeurs = donnees["valeur"].astype(float)

    fig, ax = plt.subplots(figsize=(9, 5))

    ax.bar(
        donnees["nom_operateur"],
        valeurs
    )

    ax.set_title(titre)
    ax.set_xlabel("Opérateur")
    ax.set_ylabel(nom_indicateur)

    ax.grid(axis="y", alpha=0.3)

    fig.tight_layout()

    chemin = DOSSIER_FIGURES / nom_fichier

    fig.savefig(chemin, dpi=150)

    plt.close(fig)

    print("Graphique créé :", chemin.name)


# =========================================
# 4. REQUETES SQL
# =========================================

requetes = [

    (
        """
        SELECT
            o.nom_operateur,
            ROUND((
                PERCENTILE_CONT(0.5)
                WITHIN GROUP (
                    ORDER BY m.debit_descendant_mbps
                )
            )::numeric, 2) AS valeur

        FROM mesures AS m

        JOIN operateurs AS o
            ON o.id_operateur = m.id_operateur

        JOIN protocoles AS p
            ON p.id_protocole = m.id_protocole

        WHERE p.code_protocole = 'DOWNLOAD'

        GROUP BY o.nom_operateur

        ORDER BY valeur DESC;
        """,

        "Débit descendant médian par opérateur",
        "Débit descendant (Mbps)",
        "01_debit_descendant.png"
    ),

    (
        """
        SELECT
            o.nom_operateur,
            ROUND((
                PERCENTILE_CONT(0.5)
                WITHIN GROUP (
                    ORDER BY m.debit_montant_mbps
                )
            )::numeric, 2) AS valeur

        FROM mesures AS m

        JOIN operateurs AS o
            ON o.id_operateur = m.id_operateur

        JOIN protocoles AS p
            ON p.id_protocole = m.id_protocole

        WHERE p.code_protocole = 'UPLOAD'

        GROUP BY o.nom_operateur

        ORDER BY valeur DESC;
        """,

        "Débit montant médian par opérateur",
        "Débit montant (Mbps)",
        "02_debit_montant.png"
    ),

    (
        """
        SELECT
            o.nom_operateur,
            ROUND((
                PERCENTILE_CONT(0.5)
                WITHIN GROUP (
                    ORDER BY m.duree_acces_web_secondes
                )
            )::numeric, 2) AS valeur

        FROM mesures AS m

        JOIN operateurs AS o
            ON o.id_operateur = m.id_operateur

        JOIN protocoles AS p
            ON p.id_protocole = m.id_protocole

        WHERE p.code_protocole = 'WEB'

        GROUP BY o.nom_operateur

        ORDER BY valeur ASC;
        """,

        "Durée médiane d'accès aux pages Web",
        "Durée (secondes)",
        "03_navigation_web.png"
    ),

    (
        """
        SELECT
            o.nom_operateur,

            ROUND(
                100.0 * AVG(
                    m.video_qualite_parfaite::int
                ),
                2
            ) AS valeur

        FROM mesures AS m

        JOIN operateurs AS o
            ON o.id_operateur = m.id_operateur

        JOIN protocoles AS p
            ON p.id_protocole = m.id_protocole

        WHERE p.code_protocole = 'STREAM'

        GROUP BY o.nom_operateur

        ORDER BY valeur DESC;
        """,

        "Qualité parfaite du streaming par opérateur",
        "Qualité parfaite (%)",
        "04_streaming.png"
    ),

    (
        """
        SELECT
            o.nom_operateur,

            ROUND(
                100.0 * AVG(
                    m.envoi_fichier_reussi::int
                ),
                2
            ) AS valeur

        FROM mesures AS m

        JOIN operateurs AS o
            ON o.id_operateur = m.id_operateur

        JOIN protocoles AS p
            ON p.id_protocole = m.id_protocole

        WHERE p.code_protocole = 'ULH'

        GROUP BY o.nom_operateur

        ORDER BY valeur DESC;
        """,

        "Réussite de l'envoi de fichiers",
        "Taux de réussite (%)",
        "05_envoi_fichier.png"
    )

]


# =========================================
# 5. EXECUTION ET CREATION DES GRAPHIQUES
# =========================================

def main():

    print("Connexion à PostgreSQL...")

    connexion = psycopg2.connect(**configuration_bd)

    try:

        for requete, titre, indicateur, fichier in requetes:

            resultats = lire_requete(
                connexion,
                requete
            )

            creer_graphique(
                resultats,
                titre,
                indicateur,
                fichier
            )

        print("\nLes 5 graphiques ont été créés avec succès.")

    finally:

        connexion.close()


if __name__ == "__main__":
    main()
