# SqlSugar 实体类生成脚本
# 
# 使用方法:
#   .\scripts\generate-entities.ps1              # 交互式生成
#   .\scripts\generate-entities.ps1 -All         # 生成所有表
#   .\scripts\generate-entities.ps1 -Table "TableName"  # 生成指定表
#   .\scripts\generate-entities.ps1 -Table "TableName" -WithBase  # 生成指定表（继承 BaseEntity）
#
# 前置要求:
#   1. 在 appsettings.json 中配置数据库连接字符串
#   2. 确保 SQL Server 服务正在运行
#   3. 确保数据库存在且可访问

param(
    [switch]$All,
    [string]$Table = "",
    [switch]$WithBase,
    [switch]$Test
)

Write-Host "=== SqlSugar 实体类生成工具 ===" -ForegroundColor Cyan
Write-Host ""

# 检查是否有 .NET SDK
$dotnetVersion = dotnet --version 2>$null
if (-not $dotnetVersion) {
    Write-Host "错误: 未找到 .NET SDK" -ForegroundColor Red
    Write-Host "请先安装 .NET 8 SDK: https://dotnet.microsoft.com/download" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ .NET SDK 版本: $dotnetVersion" -ForegroundColor Green

# 检查配置文件
if (-not (Test-Path "appsettings.json")) {
    Write-Host "错误: 未找到 appsettings.json 配置文件" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 配置文件已找到" -ForegroundColor Green
Write-Host ""

# 测试模式 - 运行交互式测试程序
if ($Test) {
    Write-Host "启动测试程序..." -ForegroundColor Yellow
    Write-Host ""
    
    # 创建临时测试程序
    $testCode = @"
using LogisticsProduction.Net8.Tools;

TestEntityGenerator.TestGeneration();
"@
    
    # 使用 dotnet-script 或直接编译运行
    # 这里简化为提示用户在代码中调用
    Write-Host "请在代码中调用以下方法进行测试:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "using LogisticsProduction.Net8.Tools;" -ForegroundColor Cyan
    Write-Host "TestEntityGenerator.TestGeneration();" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "或者使用以下命令行参数:" -ForegroundColor Yellow
    Write-Host "  .\scripts\generate-entities.ps1              # 交互式" -ForegroundColor Cyan
    Write-Host "  .\scripts\generate-entities.ps1 -All         # 生成所有表" -ForegroundColor Cyan
    Write-Host "  .\scripts\generate-entities.ps1 -Table 'Product'  # 生成指定表" -ForegroundColor Cyan
    exit 0
}

# 创建临时 C# 脚本
$scriptContent = @"
using LogisticsProduction.Net8.Tools;
using Microsoft.Extensions.Configuration;
using System;

var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false)
    .AddJsonFile("appsettings.Development.json", optional: true)
    .Build();

var connectionString = configuration.GetConnectionString("MainDb");

if (string.IsNullOrEmpty(connectionString))
{
    Console.WriteLine("错误: 未找到数据库连接字符串 'MainDb'");
    Console.WriteLine("请在 appsettings.json 中配置 ConnectionStrings:MainDb");
    Environment.Exit(1);
}

var generator = new EntityGenerator(connectionString, "Domain/Entities");

"@

if ($All) {
    Write-Host "生成所有表的实体类..." -ForegroundColor Yellow
    $scriptContent += @"
try
{
    generator.GenerateAllEntities();
    Console.WriteLine("完成!");
}
catch (Exception ex)
{
    Console.WriteLine(`$"错误: {ex.Message}`);
    Environment.Exit(1);
}
"@
}
elseif ($Table) {
    if ($WithBase) {
        Write-Host "生成表 '$Table' 的实体类（继承 BaseEntity）..." -ForegroundColor Yellow
        $scriptContent += @"
try
{
    generator.GenerateEntityWithBase("$Table");
    Console.WriteLine("完成!");
}
catch (Exception ex)
{
    Console.WriteLine(`$"错误: {ex.Message}`);
    Environment.Exit(1);
}
"@
    }
    else {
        Write-Host "生成表 '$Table' 的实体类..." -ForegroundColor Yellow
        $scriptContent += @"
try
{
    generator.GenerateEntity("$Table");
    Console.WriteLine("完成!");
}
catch (Exception ex)
{
    Console.WriteLine(`$"错误: {ex.Message}`);
    Environment.Exit(1);
}
"@
    }
}
else {
    # 交互式模式
    Write-Host "请选择操作:" -ForegroundColor Yellow
    Write-Host "1. 生成所有表的实体类"
    Write-Host "2. 生成指定表的实体类"
    Write-Host "3. 生成指定表的实体类（继承 BaseEntity）"
    Write-Host ""
    
    $choice = Read-Host "请输入选项 (1-3)"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "生成所有表的实体类..." -ForegroundColor Yellow
            $scriptContent += @"
try
{
    generator.GenerateAllEntities();
    Console.WriteLine("完成!");
}
catch (Exception ex)
{
    Console.WriteLine(`$"错误: {ex.Message}`);
    Environment.Exit(1);
}
"@
        }
        "2" {
            $tableName = Read-Host "请输入表名"
            Write-Host ""
            Write-Host "生成表 '$tableName' 的实体类..." -ForegroundColor Yellow
            $scriptContent += @"
try
{
    generator.GenerateEntity("$tableName");
    Console.WriteLine("完成!");
}
catch (Exception ex)
{
    Console.WriteLine(`$"错误: {ex.Message}`);
    Environment.Exit(1);
}
"@
        }
        "3" {
            $tableName = Read-Host "请输入表名"
            Write-Host ""
            Write-Host "生成表 '$tableName' 的实体类（继承 BaseEntity）..." -ForegroundColor Yellow
            $scriptContent += @"
try
{
    generator.GenerateEntityWithBase("$tableName");
    Console.WriteLine("完成!");
}
catch (Exception ex)
{
    Console.WriteLine(`$"错误: {ex.Message}`);
    Environment.Exit(1);
}
"@
        }
        default {
            Write-Host "无效的选项" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host ""

# 保存临时脚本
$tempScript = "Tools\TempGenerateScript.cs"
$scriptContent | Out-File -FilePath $tempScript -Encoding UTF8

# 使用 dotnet-script 运行（如果安装了）或提示用户
Write-Host "提示: 请在代码中调用 EntityGenerator 类来生成实体" -ForegroundColor Yellow
Write-Host ""
Write-Host "示例代码:" -ForegroundColor Cyan
Write-Host "  using LogisticsProduction.Net8.Tools;" -ForegroundColor Gray
Write-Host "  var generator = new EntityGenerator(connectionString, ""Domain/Entities"");" -ForegroundColor Gray

if ($All) {
    Write-Host "  generator.GenerateAllEntities();" -ForegroundColor Gray
}
elseif ($Table -and $WithBase) {
    Write-Host "  generator.GenerateEntityWithBase(""$Table"");" -ForegroundColor Gray
}
elseif ($Table) {
    Write-Host "  generator.GenerateEntity(""$Table"");" -ForegroundColor Gray
}

Write-Host ""
Write-Host "或者在 Program.cs 中添加以下代码（开发环境）:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  if (app.Environment.IsDevelopment())" -ForegroundColor Gray
Write-Host "  {" -ForegroundColor Gray
Write-Host "      var connectionString = builder.Configuration.GetConnectionString(""MainDb"");" -ForegroundColor Gray
Write-Host "      var generator = new EntityGenerator(connectionString!, ""Domain/Entities"");" -ForegroundColor Gray
Write-Host "      // generator.GenerateAllEntities();" -ForegroundColor Gray
Write-Host "  }" -ForegroundColor Gray
Write-Host ""

# 清理临时文件
if (Test-Path $tempScript) {
    Remove-Item $tempScript -Force
}

Write-Host "完成!" -ForegroundColor Green

