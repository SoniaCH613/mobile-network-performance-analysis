$ErrorActionPreference = "Stop"

# Ce script configure automatiquement le chemin du CSV pour Power BI.
# À exécuter depuis Windows après avoir extrait le ZIP dans le dossier du projet.

$powerbiDir = $PSScriptRoot
$csvPath = Join-Path $powerbiDir "exports\vue_mesures_detaillees.csv"
$modelPath = Join-Path $powerbiDir "rapport\MobileNetworkPerformance.SemanticModel\model.bim"

if (-not (Test-Path -LiteralPath $csvPath)) {
    throw "CSV introuvable : $csvPath. Vérifie que le dossier powerbi/exports contient vue_mesures_detaillees.csv."
}
if (-not (Test-Path -LiteralPath $modelPath)) {
    throw "Fichier model.bim introuvable : $modelPath."
}

$model = Get-Content -LiteralPath $modelPath -Raw -Encoding UTF8 | ConvertFrom-Json
$parameter = $model.model.expressions | Where-Object { $_.name -eq "pCheminCSV" }

if ($null -eq $parameter) {
    throw "Le paramètre pCheminCSV n'a pas été trouvé dans model.bim."
}

$parameter.expression = '"' + $csvPath + '" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]'

$json = $model | ConvertTo-Json -Depth 100
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($modelPath, $json, $utf8NoBom)

Write-Host ""
Write-Host "Source Power BI configurée :" -ForegroundColor Green
Write-Host $csvPath -ForegroundColor Cyan
Write-Host ""
Write-Host "Tu peux maintenant ouvrir powerbi\rapport\MobileNetworkPerformance.pbip dans Power BI Desktop."
