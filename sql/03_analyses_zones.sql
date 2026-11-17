-- =========================================
-- 1. DEBIT DESCENDANT PAR ZONE
-- =========================================

SELECT
    z.nom_zone,
    o.nom_operateur,

    COUNT(m.debit_descendant_mbps) AS nombre_mesures,

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

JOIN zones AS z
    ON z.id_zone = m.id_zone

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE p.code_protocole = 'DOWNLOAD'

GROUP BY z.nom_zone, o.nom_operateur

ORDER BY z.nom_zone, debit_median DESC;


-- =========================================
-- 2. DEBIT MONTANT PAR ZONE
-- =========================================

SELECT
    z.nom_zone,
    o.nom_operateur,

    COUNT(m.debit_montant_mbps) AS nombre_mesures,

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

JOIN zones AS z
    ON z.id_zone = m.id_zone

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE p.code_protocole = 'UPLOAD'

GROUP BY z.nom_zone, o.nom_operateur

ORDER BY z.nom_zone, debit_median DESC;


-- =========================================
-- 3. NAVIGATION WEB PAR ZONE
-- =========================================

SELECT
    z.nom_zone,
    o.nom_operateur,

    COUNT(m.duree_acces_web_secondes) AS nombre_mesures,

    ROUND(
        (
            PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY m.duree_acces_web_secondes
            )
        )::numeric,
        2
    ) AS duree_mediane

FROM mesures AS m

JOIN zones AS z
    ON z.id_zone = m.id_zone

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE p.code_protocole = 'WEB'

GROUP BY z.nom_zone, o.nom_operateur

ORDER BY z.nom_zone, duree_mediane ASC;


-- =========================================
-- 4. QUALITE VIDEO PAR ZONE
-- =========================================

SELECT
    z.nom_zone,
    o.nom_operateur,

    COUNT(m.video_qualite_parfaite) AS nombre_mesures,

    ROUND(
        100.0 * AVG(m.video_qualite_parfaite::int),
        2
    ) AS qualite_parfaite_pct

FROM mesures AS m

JOIN zones AS z
    ON z.id_zone = m.id_zone

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE p.code_protocole = 'STREAM'

GROUP BY z.nom_zone, o.nom_operateur

ORDER BY z.nom_zone, qualite_parfaite_pct DESC;


-- =========================================
-- 5. REUSSITE ULH PAR ZONE
-- =========================================

SELECT
    z.nom_zone,
    o.nom_operateur,

    COUNT(m.envoi_fichier_reussi) AS nombre_mesures,

    ROUND(
        100.0 * AVG(m.envoi_fichier_reussi::int),
        2
    ) AS taux_reussite_pct

FROM mesures AS m

JOIN zones AS z
    ON z.id_zone = m.id_zone

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole

WHERE p.code_protocole = 'ULH'

GROUP BY z.nom_zone, o.nom_operateur

ORDER BY z.nom_zone, taux_reussite_pct DESC;
