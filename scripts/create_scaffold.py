#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
脚手架生成器启动脚本（中文版）
生成交互式 PowerShell 脚本用于创建功能脚手架

使用方法：
  python .\\scripts\\create_scaffold.py  # 生成 scripts\\scaffold-cn.ps1
  
注意：生成的 PowerShell 脚本使用 UTF-8 BOM 编码，确保中文正确显示
"""

content = '''# 交互式功能脚手架生成器 (.NET 8)

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
'''

# 写入文件，使用 UTF-8 BOM 编码（PowerShell 兼容）
from pathlib import Path

output_path = Path(__file__).with_name('scaffold-cn.ps1')

with open(output_path, 'w', encoding='utf-8-sig', newline='\r\n') as f:
    f.write(content)

print(f"✓ 已生成 {output_path.name}（中文交互版）")
print("\n使用方法：")
print("  .\\scripts\\scaffold-cn.ps1    # 中文交互式生成")
print("  .\\scripts\\scaffold.ps1       # 英文交互式生成")
print("  .\\scripts\\scaffold-feature.ps1 -FeatureName WareHouse -EntityName WareHouseTask  # 命令行直接生成")
