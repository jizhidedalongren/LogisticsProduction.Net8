# 交互式功能脚手架生成器 (.NET 8)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "功能脚手架生成器（交互式）" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 获取用户输入
$FeatureName = Read-Host "请输入功能名称（如：WareHouse, ProductRecord）"
$EntityName = Read-Host "请输入实体名称（如：WareHouseTask, ProductRecord）"
$Description = Read-Host "请输入功能描述（可选）"
$includeCommand = Read-Host "是否包含写操作（Command）？(y/n)"

Write-Host ""
Write-Host "即将生成以下功能：" -ForegroundColor Yellow
Write-Host "  功能名称: $FeatureName" -ForegroundColor White
Write-Host "  实体名称: $EntityName" -ForegroundColor White
Write-Host "  功能描述: $Description" -ForegroundColor White
Write-Host "  包含写操作: $includeCommand" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "确认生成？(y/n)"
if ($confirm -ne "y") {
    Write-Host "已取消" -ForegroundColor Red
    exit
}

# 调用主脚本
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