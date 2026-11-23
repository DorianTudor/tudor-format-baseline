param([Parameter(Mandatory=$true)][string]$ExpectedHead)

$ErrorActionPreference = 'Stop'
$suite = 'npm ci --no-audit --no-fund && npm run check'

function Invoke-VerificationStep {
    param([string]$Name, [string]$Command)
    Write-Host "LOCAL VERIFY: $Name" -ForegroundColor Cyan
    & cmd.exe /d /s /c $Command
    if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE." }
}

if ($ExpectedHead -notmatch '^[0-9a-fA-F]{40}$') { throw 'ExpectedHead must be a full Git commit SHA.' }
$root = (& git rev-parse --show-toplevel).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Could not resolve the repository root.' }
Push-Location $root
try {
    $headBefore = (& git rev-parse HEAD).Trim()
    if ($headBefore -ne $ExpectedHead) { throw "Push SHA $ExpectedHead is not the checked-out HEAD $headBefore." }
    if (& git status --porcelain=v1 -uall) { throw 'The worktree must be clean before local verification.' }
    $gitDirectory = (& git rev-parse --git-common-dir).Trim()
    if (-not [System.IO.Path]::IsPathRooted($gitDirectory)) { $gitDirectory = Join-Path $root $gitDirectory }
    $receiptPath = Join-Path $gitDirectory 'tudor-local-verification.json'
    if (Test-Path -LiteralPath $receiptPath -PathType Leaf) {
        try {
            $receipt = Get-Content -LiteralPath $receiptPath -Raw | ConvertFrom-Json
            if ($receipt.Result -eq 'success' -and $receipt.Sha -eq $ExpectedHead -and $receipt.Suite -eq $suite) {
                Write-Host 'Reusing successful exact-SHA local verification receipt.' -ForegroundColor Green
                return
            }
        } catch { }
    }

    # Build PC routing (ssh-testing-verifying-connection): the same check runs on the
    # build PC. TUDOR_REMOTE_VERIFY_ACTIVE marks the build PC itself; TUDOR_VERIFY_LOCAL=1
    # is the user's choice to verify here, at low priority, when the build PC is down.
    $remoteHelper = Join-Path $HOME 'Documents\Tudor Tools\ssh-testing-verifying-connection\Invoke-RemoteVerify.ps1'
    $runner = 'this PC'
    if ($env:TUDOR_REMOTE_VERIFY_ACTIVE -ne '1' -and $env:TUDOR_VERIFY_LOCAL -ne '1' -and (Test-Path -LiteralPath $remoteHelper -PathType Leaf)) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $remoteHelper -RepoRoot $root -Sha $ExpectedHead
        if ($LASTEXITCODE -eq 75) { throw 'Build PC unavailable, so nothing was verified. Retry, or set TUDOR_VERIFY_LOCAL=1 to verify on this PC.' }
        if ($LASTEXITCODE -ne 0) { throw "Build PC verification failed with exit code $LASTEXITCODE." }
        $runner = 'build PC'
    }
    else {
        if ($env:TUDOR_VERIFY_LOCAL -eq '1') { [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = 'BelowNormal' }
        Invoke-VerificationStep 'Baseline check' $suite
    }

    $headAfter = (& git rev-parse HEAD).Trim()
    if ($headAfter -ne $ExpectedHead) { throw 'HEAD changed during local verification.' }
    if (& git status --porcelain=v1 -uall) { throw 'Local verification changed tracked or untracked files.' }
    [pscustomobject]@{ Sha=$ExpectedHead.ToLowerInvariant(); CheckedAt=[datetime]::UtcNow.ToString('o'); Suite=$suite; Runner=$runner; Result='success' } |
        ConvertTo-Json | Set-Content -LiteralPath $receiptPath -Encoding UTF8
}
finally { Pop-Location }
