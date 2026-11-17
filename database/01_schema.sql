-- ==================================================
-- 1. TABLE DES OPERATEURS
-- ==================================================

CREATE TABLE operateurs (
    id_operateur SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom_operateur VARCHAR(50) NOT NULL UNIQUE
);


-- ==================================================
-- 2. TABLE DES ZONES
-- ==================================================

CREATE TABLE zones (
    id_zone SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom_zone VARCHAR(60) NOT NULL UNIQUE
);


-- ==================================================
-- 3. TABLE DES PROTOCOLES
-- ==================================================

CREATE TABLE protocoles (
    id_protocole SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code_protocole VARCHAR(20) NOT NULL UNIQUE,
    libelle VARCHAR(100) NOT NULL
);


-- ==================================================
-- 4. TABLE TEMPORAIRE DE PREPARATION
-- ==================================================

CREATE TABLE staging_mesures (
    id_staging BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nom_operateur VARCHAR(50) NOT NULL,
    code_protocole VARCHAR(20) NOT NULL,
    nom_zone VARCHAR(60) NOT NULL,

    date_mesure DATE,
    code_commune_insee VARCHAR(5),

    debit_descendant_mbps NUMERIC(12, 3),
    debit_montant_mbps NUMERIC(12, 3),

    duree_acces_web_secondes NUMERIC(12, 3),

    web_charge_5s BOOLEAN,
    web_charge_10s BOOLEAN,

    video_qualite_correcte BOOLEAN,
    video_qualite_parfaite BOOLEAN,

    envoi_fichier_reussi BOOLEAN
);


-- ==================================================
-- 5. TABLE CENTRALE DES MESURES
-- ==================================================

CREATE TABLE mesures (
    id_mesure BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_staging BIGINT NOT NULL UNIQUE
        REFERENCES staging_mesures(id_staging),

    id_operateur SMALLINT NOT NULL
        REFERENCES operateurs(id_operateur),

    id_zone SMALLINT NOT NULL
        REFERENCES zones(id_zone),

    id_protocole SMALLINT NOT NULL
        REFERENCES protocoles(id_protocole),

    date_mesure DATE,
    code_commune_insee VARCHAR(5),

    debit_descendant_mbps NUMERIC(12, 3),
    debit_montant_mbps NUMERIC(12, 3),

    duree_acces_web_secondes NUMERIC(12, 3),

    web_charge_5s BOOLEAN,
    web_charge_10s BOOLEAN,

    video_qualite_correcte BOOLEAN,
    video_qualite_parfaite BOOLEAN,

    envoi_fichier_reussi BOOLEAN,

    CONSTRAINT chk_debit_descendant
        CHECK (
            debit_descendant_mbps IS NULL
            OR debit_descendant_mbps >= 0
        ),

    CONSTRAINT chk_debit_montant
        CHECK (
            debit_montant_mbps IS NULL
            OR debit_montant_mbps >= 0
        ),

    CONSTRAINT chk_duree_web
        CHECK (
            duree_acces_web_secondes IS NULL
            OR duree_acces_web_secondes >= 0
        )
);


-- ==================================================
-- 6. INDEX POUR FACILITER LES RECHERCHES
-- ==================================================

CREATE INDEX idx_mesures_analyse
ON mesures (id_protocole, id_operateur, id_zone);

CREATE INDEX idx_mesures_date
ON mesures (date_mesure);
