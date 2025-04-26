# Demande à l'utilisateur de spécifier les chemins
$inputRoot = Read-Host "✨ Entrez le chemin du dossier source"
$outputRoot = Read-Host "✨ Entrez le chemin du dossier de sortie"
$cwebpPath = Read-Host "🔍 Entrez le chemin complet de cwebp.exe (ex: C:\Users\jonat\Downloads\libwebp-1.4.0-windows-x64\bin\cwebp.exe)"

# Demande à l'utilisateur le niveau de compression souhaité
$quality = Read-Host "🔢 Entrez le niveau de qualité de compression (0 = très compressé, 100 = qualité maximale). Recommandé : 75"

# Assure que le dossier de sortie existe
if (-Not (Test-Path $outputRoot)) {
    New-Item -ItemType Directory -Path $outputRoot
    Write-Host "`n🔳 Dossier de sortie créé : $outputRoot`n"
}

# Fonction pour convertir une image en WebP avec cwebp
function Convert-ImageToWebP($inputPath, $outputPath, $cwebpPath, $quality) {
    try {
        Write-Host "💚 Traitement du fichier :"
        Write-Host "    ➔ Source : $inputPath"
        Write-Host "    ➔ Destination : $outputPath`n"
        & "$cwebpPath" -q $quality "$inputPath" -o "$outputPath" *> $null
        Write-Host "✅ Conversion réussie !`n"
    } catch {
        Write-Host "❌ Erreur lors de la conversion de $inputPath : $_`n"
    }
}

# Débute le chronomètre
$startTime = Get-Date

# Parcourt tous les fichiers png/jpg
$files = Get-ChildItem -Path $inputRoot -Recurse -Include *.png, *.jpg, *.jpeg
$total = $files.Count
$count = 0

Write-Host "`n🚀 Début de la conversion de $total fichiers...`n"

foreach ($file in $files) {
    $relativePath = $file.DirectoryName.Substring($inputRoot.Length)

    # Remplacer les espaces par des tirets
    $relativePath = $relativePath -replace " ", "-"

    # Créer le nouveau chemin de dossier si pas existant
    $newDir = Join-Path $outputRoot $relativePath.TrimStart("\\")
    if (-Not (Test-Path $newDir)) {
        New-Item -ItemType Directory -Path $newDir -Force | Out-Null
        Write-Host "📁 Nouveau dossier créé : $newDir`n"
    }

    # Définir le chemin de sortie avec extension .webp
    $filenameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $outputFile = Join-Path $newDir ($filenameWithoutExt + ".webp")

    # Convertir l'image
    Convert-ImageToWebP -inputPath $file.FullName -outputPath $outputFile -cwebpPath $cwebpPath -quality $quality

    $count++
    Write-Host "📈 Progression : $count / $total fichiers traités.`n"
}

# Fin du chronomètre
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n🎯 Conversion terminée ! $count fichiers convertis avec succès.`n"
Write-Host "⏱️ Temps total de conversion : $($duration.ToString("hh\:mm\:ss"))"
