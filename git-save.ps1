param(
    [Parameter(Position = 0)]
    [string]$Message,

    [string]$Tag,

    [string]$Branch = "main",

    [switch]$NoPush
)

if (-not $Message) {
    $Message = "save $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

function Push-ToRemote {
    param(
        [string]$BranchName,
        [string]$TagName
    )

    $origin = git remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $origin) {
        Write-Host "Saved locally. No origin remote is configured."
        return
    }

    git push -u origin $BranchName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Saved locally, but push failed. Check network/authentication, then run: git push -u origin $BranchName"
        exit $LASTEXITCODE
    }

    if ($TagName) {
        git push origin $TagName
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Code pushed, but tag push failed. Run: git push origin $TagName"
            exit $LASTEXITCODE
        }
    }
}

git add -A

$changes = git diff --cached --name-only
if (-not $changes) {
    Write-Host "No changes to save."
    if (-not $NoPush) {
        Push-ToRemote -BranchName $Branch -TagName $Tag
    }
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

if (-not $NoPush) {
    Push-ToRemote -BranchName $Branch -TagName $Tag
    Write-Host "Pushed to origin/$Branch."
}
