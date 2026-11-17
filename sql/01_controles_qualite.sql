-- =========================================
-- 1. NOMBRE DE LIGNES
-- =========================================

SELECT COUNT(*) AS nombre_staging
FROM staging_mesures;

SELECT COUNT(*) AS nombre_mesures
FROM mesures;


-- =========================================
-- 2. NOMBRE D'ELEMENTS DANS LES TABLES DE REFERENCE
-- =========================================

SELECT COUNT(*) AS nombre_operateurs
FROM operateurs;

SELECT COUNT(*) AS nombre_zones
FROM zones;

SELECT COUNT(*) AS nombre_protocoles
FROM protocoles;


-- =========================================
-- 3. REPARTITION DES MESURES PAR PROTOCOLE
-- =========================================

SELECT
    p.code_protocole,
    p.libelle,
    COUNT(m.id_mesure) AS nombre_mesures

FROM mesures AS m

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

GROUP BY
    p.code_protocole,
    p.libelle

ORDER BY nombre_mesures DESC;


-- =========================================
-- 4. REPARTITION PAR OPERATEUR
-- =========================================

SELECT
    o.nom_operateur,
    COUNT(m.id_mesure) AS nombre_mesures

FROM mesures AS m

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

GROUP BY o.nom_operateur

ORDER BY nombre_mesures DESC;


-- =========================================
-- 5. DISPONIBILITE DES INDICATEURS
-- =========================================

SELECT
    p.code_protocole,

    COUNT(m.id_mesure) AS total_mesures,

    COUNT(m.debit_descendant_mbps) AS debit_descendant,

    COUNT(m.debit_montant_mbps) AS debit_montant,

    COUNT(m.duree_acces_web_secondes) AS duree_web,

    COUNT(m.web_charge_5s) AS web_5s,

    COUNT(m.web_charge_10s) AS web_10s,

    COUNT(m.video_qualite_correcte) AS qualite_correcte,

    COUNT(m.video_qualite_parfaite) AS qualite_parfaite,

    COUNT(m.envoi_fichier_reussi) AS envoi_reussi

FROM mesures AS m

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

GROUP BY p.code_protocole

ORDER BY p.code_protocole;


-- =========================================
-- 6. VERIFIER LES RELATIONS
-- =========================================

SELECT COUNT(*) AS mesures_sans_reference
FROM mesures AS m

LEFT JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

LEFT JOIN zones AS z
    ON z.id_zone = m.id_zone

LEFT JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE
    o.id_operateur IS NULL
    OR z.id_zone IS NULL
    OR p.id_protocole IS NULL;


-- =========================================
-- 7. PERIODE DES MESURES
-- =========================================

SELECT
    MIN(date_mesure) AS premiere_date,
    MAX(date_mesure) AS derniere_date
FROM mesures;
