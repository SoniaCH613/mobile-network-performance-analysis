-- =========================================
-- CREATION D'UNE VUE DETAILLEE DES MESURES
-- =========================================

CREATE OR REPLACE VIEW vue_mesures_detaillees AS

SELECT
    m.id_mesure,

    o.nom_operateur,

    z.nom_zone,

    p.code_protocole,
    p.libelle,

    m.date_mesure,
    m.code_commune_insee,

    m.debit_descendant_mbps,
    m.debit_montant_mbps,

    m.duree_acces_web_secondes,

    m.web_charge_5s,
    m.web_charge_10s,

    m.video_qualite_correcte,
    m.video_qualite_parfaite,

    m.envoi_fichier_reussi

FROM mesures AS m

JOIN operateurs AS o
    ON o.id_operateur = m.id_operateur

JOIN zones AS z
    ON z.id_zone = m.id_zone

JOIN protocoles AS p
    ON p.id_protocole = m.id_protocole;
