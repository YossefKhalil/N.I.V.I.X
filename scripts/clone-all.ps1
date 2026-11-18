$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$target = Join-Path $root "repos"
New-Item -ItemType Directory -Force -Path $target | Out-Null

$repos = [ordered]@{
    "Ni-Agent"  = "https://github.com/YossefKhalil/Ni-Agent.git"
    "Ni-Zep"    = "https://github.com/YossefKhalil/Ni-Zep.git"
    "Ni-Strata" = "https://github.com/YossefKhalil/Ni-Strata.git"
}

foreach ($name in $repos.Keys) {
    $dest = Join-Path $target $name
    if (Test-Path $dest) {
        Write-Host "skip  $name (already exists)"
    } else {
        Write-Host "clone $name"
        git clone --depth 1 $repos[$name] $dest
    }
}

Write-Host "done. repos in $target"