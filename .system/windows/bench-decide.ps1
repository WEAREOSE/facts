# bench-decide.ps1
# Runs llama-bench on GPU and CPU, compares t/s, outputs one line:
#   GPU|<gpu_ts>|<cpu_ts>   if GPU wins (10% margin)
#   CPU|<cpu_ts>|<gpu_ts>   if CPU wins
#   FAIL||                  if benchmark failed

param(
    [string]$BenchPath,
    [string]$ModelPath
)

$ErrorActionPreference = "SilentlyContinue"

function Get-TokensPerSec($lines) {
    foreach ($line in $lines) {
        # Match a "tg<digits> |" pattern (the token-generation row)
        if ($line -match 'tg\d+\s*\|') {
            $parts = $line -split '\|'
            # The t/s is the last non-empty field, format: "<num> +/- <stddev>"
            # Just grab the leading number, regardless of separator (avoids Unicode issues)
            for ($i = $parts.Length - 1; $i -ge 0; $i--) {
                $f = $parts[$i].Trim()
                if ($f -match '^([0-9]+\.?[0-9]*)') {
                    return $matches[1]
                }
            }
        }
    }
    return $null
}

# Run GPU benchmark
$gpuOut = & $BenchPath -m $ModelPath -ngl 99 -p 0 -n 32 --no-warmup 2>$null
$gpuTG = Get-TokensPerSec $gpuOut

# Run CPU benchmark
$cpuOut = & $BenchPath -m $ModelPath -ngl 0 -p 0 -n 32 --no-warmup 2>$null
$cpuTG = Get-TokensPerSec $cpuOut

if (-not $gpuTG -or -not $cpuTG) {
    Write-Output "FAIL||"
    exit
}

$gpu = [float]$gpuTG
$cpu = [float]$cpuTG

if ($gpu -gt $cpu * 1.1) {
    Write-Output "GPU|$gpuTG|$cpuTG"
} else {
    Write-Output "CPU|$cpuTG|$gpuTG"
}
