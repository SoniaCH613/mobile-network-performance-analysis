let
    Source = Csv.Document(File.Contents(pCheminCSV), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    EnTetes = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Types = Table.TransformColumnTypes(EnTetes, {
        {"id_mesure", Int64.Type}, {"nom_operateur", type text}, {"nom_zone", type text},
        {"code_protocole", type text}, {"libelle", type text}, {"date_mesure", type date},
        {"code_commune_insee", type text}, {"debit_descendant_mbps", type number},
        {"debit_montant_mbps", type number}, {"duree_acces_web_secondes", type number},
        {"web_charge_5s", type text}, {"web_charge_10s", type text},
        {"video_qualite_correcte", type text}, {"video_qualite_parfaite", type text},
        {"envoi_fichier_reussi", type text}
    }, "en-US"),
    IndicateursBooleens = Table.TransformColumns(Types, {
        {"web_charge_5s", each if _ = null or Text.Trim(Text.From(_)) = "" then null else Text.Lower(Text.Trim(Text.From(_))) = "t", type nullable logical},
        {"web_charge_10s", each if _ = null or Text.Trim(Text.From(_)) = "" then null else Text.Lower(Text.Trim(Text.From(_))) = "t", type nullable logical},
        {"video_qualite_correcte", each if _ = null or Text.Trim(Text.From(_)) = "" then null else Text.Lower(Text.Trim(Text.From(_))) = "t", type nullable logical},
        {"video_qualite_parfaite", each if _ = null or Text.Trim(Text.From(_)) = "" then null else Text.Lower(Text.Trim(Text.From(_))) = "t", type nullable logical},
        {"envoi_fichier_reussi", each if _ = null or Text.Trim(Text.From(_)) = "" then null else Text.Lower(Text.Trim(Text.From(_))) = "t", type nullable logical}
    })
in
    IndicateursBooleens