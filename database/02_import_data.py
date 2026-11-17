import os
from pathlib import Path

import pandas as pd
import psycopg2

from dotenv import load_dotenv
from psycopg2.extras import execute_values


# ==================================================
# 1. CONFIGURATION DU PROJET
# ==================================================

DOSSIER_PROJET = Path(__file__).resolve().parents[1]

load_dotenv(DOSSIER_PROJET / ".env")


# Chemin du CSV
chemin_csv = Path(os.getenv("CSV_PATH"))

if not chemin_csv.is_absolute():
    chemin_csv = DOSSIER_PROJET / chemin_csv


if not chemin_csv.is_file():
    raise FileNotFoundError(
        f"Fichier CSV introuvable : {chemin_csv}"
    )


# Configuration PostgreSQL
configuration_bd = {
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT"),
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD")
}


# ==================================================
# 2. COLONNES ET PROTOCOLES RETENUS
# ==================================================

COLONNES_SOURCE = [
    "operator",
    "protocole",
    "zone",
    "date_start",
    "insee_com",
    "bitrate_dl",
    "bitrate_ul",
    "acess_duration",
    "loaded_in_less_5_secondes",
    "loaded_in_less_10_secondes",
    "quality_correct",
    "quality_perfect",
    "upload_ok"
]

PROTOCOLES_RETENUS = [
    "DOWNLOAD",
    "UPLOAD",
    "WEB",
    "STREAM",
    "ULH"
]


# ==================================================
# 3. REQUETE D'INSERTION DANS LA TABLE STAGING
# ==================================================

REQUETE_INSERTION = """
    INSERT INTO staging_mesures (
        nom_operateur,
        code_protocole,
        nom_zone,
        date_mesure,
        code_commune_insee,
        debit_descendant_mbps,
        debit_montant_mbps,
        duree_acces_web_secondes,
        web_charge_5s,
        web_charge_10s,
        video_qualite_correcte,
        video_qualite_parfaite,
        envoi_fichier_reussi
    )
    VALUES %s
"""


# ==================================================
# 4. FONCTIONS DE CONVERSION
# ==================================================

def convertir_texte(valeur):

    if pd.isna(valeur):
        return None

    return str(valeur).strip()


def convertir_nombre(valeur):

    if pd.isna(valeur):
        return None

    return float(valeur)


def convertir_booleen(valeur):

    if pd.isna(valeur):
        return None

    nombre = float(valeur)

    if nombre not in (0, 1):
        raise ValueError(
            f"Valeur binaire inattendue : {valeur}"
        )

    return bool(int(nombre))


def convertir_date(valeur):

    if pd.isna(valeur):
        return None

    date = pd.to_datetime(
        valeur,
        dayfirst=True,
        errors="coerce"
    )

    if pd.isna(date):
        return None

    return date.date()


# ==================================================
# 5. PREPARER UNE LIGNE POUR POSTGRESQL
# ==================================================

def preparer_ligne(ligne):

    return (
        convertir_texte(ligne["operator"]),
        convertir_texte(ligne["protocole"]),
        convertir_texte(ligne["zone"]),
        convertir_date(ligne["date_start"]),
        convertir_texte(ligne["insee_com"]),
        convertir_nombre(ligne["bitrate_dl"]),
        convertir_nombre(ligne["bitrate_ul"]),
        convertir_nombre(ligne["acess_duration"]),
        convertir_booleen(ligne["loaded_in_less_5_secondes"]),
        convertir_booleen(ligne["loaded_in_less_10_secondes"]),
        convertir_booleen(ligne["quality_correct"]),
        convertir_booleen(ligne["quality_perfect"]),
        convertir_booleen(ligne["upload_ok"])
    )


# ==================================================
# 6. FONCTION PRINCIPALE
# ==================================================

def main():

    encodage = os.getenv("CSV_ENCODING", "cp1252")
    separateur = os.getenv("CSV_SEPARATOR", ";")
    decimal = os.getenv("CSV_DECIMAL", ",")

    taille_bloc = 10000
    total_importe = 0

    print("Fichier CSV :", chemin_csv)
    print("Connexion à PostgreSQL...")

    connexion = psycopg2.connect(**configuration_bd)

    try:

        with connexion:

            with connexion.cursor() as curseur:

                # On repart d'un import propre.
                # Cette opération remplace les mesures précédentes.

                curseur.execute("""
                    TRUNCATE TABLE
                        mesures,
                        staging_mesures
                    RESTART IDENTITY;
                """)

                # Lecture du CSV par blocs

                blocs = pd.read_csv(
                    chemin_csv,
                    sep=separateur,
                    encoding=encodage,
                    decimal=decimal,
                    dtype={
                        "insee_com": "string"
                    },
                    usecols=COLONNES_SOURCE,
                    chunksize=taille_bloc
                )

                for numero_bloc, bloc in enumerate(blocs, start=1):

                    # Uniformiser les textes
                    for colonne in [
                        "operator",
                        "protocole",
                        "zone"
                    ]:
                        bloc[colonne] = (
                            bloc[colonne]
                            .astype("string")
                            .str.strip()
                        )

                    # Conserver les protocoles du projet
                    bloc = bloc[
                        bloc["protocole"].isin(
                            PROTOCOLES_RETENUS
                        )
                    ].copy()

                    if bloc.empty:
                        continue

                    # Vérifier les colonnes d'identification
                    colonnes_identification = [
                        "operator",
                        "protocole",
                        "zone"
                    ]

                    if bloc[colonnes_identification].isna().any().any():
                        raise ValueError(
                            "Une colonne d'identification contient "
                            "des valeurs manquantes."
                        )

                    lignes = [
                        preparer_ligne(ligne)
                        for ligne in bloc.to_dict(orient="records")
                    ]

                    # Insertion dans staging_mesures
                    execute_values(
                        curseur,
                        REQUETE_INSERTION,
                        lignes,
                        page_size=1000
                    )

                    total_importe += len(lignes)

                    print(
                        f"Bloc {numero_bloc} terminé : "
                        f"{total_importe:,} lignes importées"
                    )


                # ==================================================
                # 7. REMPLIR LES TABLES DE REFERENCE
                # ==================================================

                curseur.execute("""
                    INSERT INTO operateurs (nom_operateur)
                    SELECT DISTINCT nom_operateur
                    FROM staging_mesures
                    ON CONFLICT (nom_operateur) DO NOTHING;
                """)

                curseur.execute("""
                    INSERT INTO zones (nom_zone)
                    SELECT DISTINCT nom_zone
                    FROM staging_mesures
                    ON CONFLICT (nom_zone) DO NOTHING;
                """)

                curseur.execute("""
                    INSERT INTO protocoles (
                        code_protocole,
                        libelle
                    )
                    VALUES
                        ('DOWNLOAD', 'Débit descendant'),
                        ('UPLOAD', 'Débit montant'),
                        ('WEB', 'Navigation Web'),
                        ('STREAM', 'Qualité du streaming vidéo'),
                        ('ULH', 'Réussite de l envoi d un fichier')
                    ON CONFLICT (code_protocole)
                    DO UPDATE SET libelle = EXCLUDED.libelle;
                """)


                # ==================================================
                # 8. REMPLIR LA TABLE CENTRALE AVEC DES JOINTURES
                # ==================================================

                curseur.execute("""
                    INSERT INTO mesures (
                        id_staging,
                        id_operateur,
                        id_zone,
                        id_protocole,
                        date_mesure,
                        code_commune_insee,
                        debit_descendant_mbps,
                        debit_montant_mbps,
                        duree_acces_web_secondes,
                        web_charge_5s,
                        web_charge_10s,
                        video_qualite_correcte,
                        video_qualite_parfaite,
                        envoi_fichier_reussi
                    )

                    SELECT
                        s.id_staging,
                        o.id_operateur,
                        z.id_zone,
                        p.id_protocole,
                        s.date_mesure,
                        s.code_commune_insee,
                        s.debit_descendant_mbps,
                        s.debit_montant_mbps,
                        CASE
                            WHEN s.code_protocole = 'WEB'
                            THEN s.duree_acces_web_secondes
                            ELSE NULL
                        END,
                        s.web_charge_5s,
                        s.web_charge_10s,
                        s.video_qualite_correcte,
                        s.video_qualite_parfaite,
                        s.envoi_fichier_reussi

                    FROM staging_mesures AS s

                    JOIN operateurs AS o
                        ON o.nom_operateur = s.nom_operateur

                    JOIN zones AS z
                        ON z.nom_zone = s.nom_zone

                    JOIN protocoles AS p
                        ON p.code_protocole = s.code_protocole;
                """)


                # Vérifier le nombre de lignes finales

                curseur.execute("""
                    SELECT COUNT(*) FROM staging_mesures;
                """)
                total_staging = curseur.fetchone()[0]

                curseur.execute("""
                    SELECT COUNT(*) FROM mesures;
                """)
                total_mesures = curseur.fetchone()[0]


        print("\nIMPORTATION TERMINEE")
        print("Lignes sélectionnées :", total_importe)
        print("Lignes dans staging :", total_staging)
        print("Lignes dans mesures :", total_mesures)

    finally:
        connexion.close()


if __name__ == "__main__":
    main()
