param(
    [switch]$Version
)

function GetVertion {
    $ProductJsonPath = "$PSScriptRoot\product.json"

    if (!(Test-Path -Path "$ProductJsonPath" -PathType Leaf)) {
        Write-Warning -Message ("$ProductJsonPath 不存在")
        [System.Environment]::Exit(0)
    }

    $ProductInfo = $null
    try {
        $ProductInfo = Get-Content -Path "$ProductJsonPath" | ConvertFrom-Json
    }
    catch {
        Write-Warning -Message ("$ProductJsonPath 解析失败")
        [System.Environment]::Exit(0)
    }
    if (!$ProductInfo -or $ProductInfo -isNot [PSCustomObject]) {
        Write-Warning -Message ("$ProductJsonPath 解析失败")
        [System.Environment]::Exit(0)
    }

    $Version = $ProductInfo.'version'
    if (!$Version) {
        Write-Warning -Message ("$ProductJsonPath 不存在 version 信息")
        [System.Environment]::Exit(0)
    }

    return $Version
}

function SaveReg {
    param($Path)

    Write-Host -Object ''
    Write-Host -Object '正在保存设置修改前的注册表数据' -ForegroundColor Yellow

    if (!(Test-Path -Path "$Path\old" -PathType Container)) {
        New-Item -Path "$Path\old" -ItemType Directory -Force | Out-Null
    }
    if (!(Test-Path -Path "$Path\new" -PathType Container)) {
        New-Item -Path "$Path\new" -ItemType Directory -Force | Out-Null
    }

    reg export HKLM "$Path\old\hklm.txt" /y
    reg export HKCU "$Path\old\hkcu.txt" /y
    reg export HKCR "$Path\old\hkcr.txt" /y
    reg export HKU "$Path\old\hku.txt" /y
    reg export HKCC "$Path\old\hkcc.txt" /y

    Write-Host -Object ''
    Write-Host -Object "设置修改前的注册表数据保存成功: $Path\old" -ForegroundColor Green

    Write-Host -Object ''
    Read-Host -Prompt '设置修改后请按回车键'

    Write-Host -Object ''
    Write-Host -Object '正在保存设置修改后的注册表数据' -ForegroundColor Yellow

    reg export HKLM "$Path\new\hklm.txt" /y
    reg export HKCU "$Path\new\hkcu.txt" /y
    reg export HKCR "$Path\new\hkcr.txt" /y
    reg export HKU "$Path\new\hku.txt" /y
    reg export HKCC "$Path\new\hkcc.txt" /y

    Write-Host -Object ''
    Write-Host -Object "设置修改后的注册表数据保存成功: $Path\new" -ForegroundColor Green
}

$VersionInfo = GetVertion

if ($Version) {
    return $VersionInfo
}

Clear-Host
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$ProgressPreference = 'SilentlyContinue'
$Host.UI.RawUI.WindowTitle = "RegDiff v$VersionInfo"
Set-Location -Path "$PSScriptRoot"
Write-Host -Object ''
Write-Host -Object "=====> RegDiff v$VersionInfo https://github.com/dsx42/RegDiff <====="

while ($true) {
    Write-Host -Object ''
    $Desc = Read-Host -Prompt '请输入要修改的设置的描述'
    if (!$Desc) {
        continue
    }

    SaveReg -Path "$PSScriptRoot\RegData\$Desc"
}
