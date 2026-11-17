-- =========================================
-- 1. DEBIT DESCENDANT (DOWNLOAD)
-- =========================================

SELECT
    o.nom_operateur,

    COUNT(m.debit_descendant_mbps) AS nombre_mesures,

    ROUND(
        AVG(m.debit_descendant_mbps),
        2
    ) AS debit_moyen,

    ROUND(
        (
            PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY m.debit_descendant_mbps
            )
        )::numeric,
        2
    ) AS debit_median

FROM mesures AS m

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE p.code_protocole = 'DOWNLOAD'

GROUP BY o.nom_operateur

ORDER BY debit_median DESC;


-- =========================================
-- 2. DEBIT MONTANT (UPLOAD)
-- =========================================

SELECT
    o.nom_operateur,

    COUNT(m.debit_montant_mbps) AS nombre_mesures,

    ROUND(
        AVG(m.debit_montant_mbps),
        2
    ) AS debit_moyen,

    ROUND(
        (
            PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY m.debit_montant_mbps
            )
        )::numeric,
        2
    ) AS debit_median

FROM mesures AS m

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE p.code_protocole = 'UPLOAD'

GROUP BY o.nom_operateur

ORDER BY debit_median DESC;


-- =========================================
-- 3. NAVIGATION WEB
-- =========================================

SELECT
    o.nom_operateur,

    COUNT(m.duree_acces_web_secondes) AS nombre_mesures,

    ROUND(
        AVG(m.duree_acces_web_secondes),
        2
    ) AS duree_moyenne,

    ROUND(
        (
            PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY m.duree_acces_web_secondes
            )
        )::numeric,
        2
    ) AS duree_mediane,

    ROUND(
        100.0 * AVG(m.web_charge_5s::int),
        2
    ) AS chargement_5s_pct,

    ROUND(
        100.0 * AVG(m.web_charge_10s::int),
        2
    ) AS chargement_10s_pct

FROM mesures AS m

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE p.code_protocole = 'WEB'

GROUP BY o.nom_operateur

ORDER BY duree_mediane ASC;


-- =========================================
-- 4. QUALITE DU STREAMING VIDEO
-- =========================================

SELECT
    o.nom_operateur,

    COUNT(m.video_qualite_correcte) AS nombre_mesures,

    ROUND(
        100.0 * AVG(m.video_qualite_correcte::int),
        2
    ) AS qualite_correcte_pct,

    ROUND(
        100.0 * AVG(m.video_qualite_parfaite::int),
        2
    ) AS qualite_parfaite_pct

FROM mesures AS m

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE p.code_protocole = 'STREAM'

GROUP BY o.nom_operateur

ORDER BY qualite_parfaite_pct DESC;


-- =========================================
-- 5. REUSSITE DE L'ENVOI DE FICHIER (ULH)
-- =========================================

SELECT
    o.nom_operateur,

    COUNT(m.envoi_fichier_reussi) AS nombre_mesures,

    ROUND(
        100.0 * AVG(m.envoi_fichier_reussi::int),
        2
    ) AS taux_reussite_pct

FROM mesures AS m

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE p.code_protocole = 'ULH'

GROUP BY o.nom_operateur

ORDER BY taux_reussite_pct DESC;
