param(
    [Parameter(Position = 0)]
    [string]$Message,

    [string]$Tag
)

if (-not $Message) {
    $Message = "save $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

git add -A

$changes = git diff --cached --name-only
if (-not $changes) {
    Write-Host "No changes to save."
    exit 0
}

git commit -m $Message
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

if ($Tag) {
    git tag -a $Tag -m $Message
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    Write-Host "Saved and tagged as $Tag."
} else {
    Write-Host "Saved."
}
