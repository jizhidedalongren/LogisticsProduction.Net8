# Interactive Feature Scaffold Generator (.NET 8)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Feature Scaffold Generator (Interactive)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get user input
$FeatureName = Read-Host "Enter feature name (e.g., WareHouse, ProductRecord)"
$EntityName = Read-Host "Enter entity name (e.g., WareHouseTask, ProductRecord)"
$Description = Read-Host "Enter description (optional)"
$includeCommand = Read-Host "Include write operations (Command)? (y/n)"

Write-Host ""
Write-Host "About to generate the following feature:" -ForegroundColor Yellow
Write-Host "  Feature Name: $FeatureName" -ForegroundColor White
Write-Host "  Entity Name: $EntityName" -ForegroundColor White
Write-Host "  Description: $Description" -ForegroundColor White
Write-Host "  Include Commands: $includeCommand" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Confirm generation? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Cancelled" -ForegroundColor Red
    exit
}

# Call main script
$scriptPath = Join-Path $PSScriptRoot "scaffold-feature.ps1"

$params = @{
    FeatureName = $FeatureName
    EntityName = $EntityName
    Description = $Description
}

if ($includeCommand -eq "y") {
    $params.IncludeCommand = $true
}

& $scriptPath @params
