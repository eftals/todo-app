# PowerShell script to check LocalStack /_localstack/health endpoint for any valid JSON response

Write-Host "Checking LocalStack health (any valid JSON response)..."

$maxAttempts = 30
$attempt = 0
$success = $false

while ($attempt -lt $maxAttempts -and -not $success) {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:4566/_localstack/health"
        if ($response) {
            Write-Host "LocalStack /_localstack/health endpoint returned valid JSON!"
            $success = $true
            exit 0
        }
    } catch {
        # Ignore errors and retry
    }
    $attempt++
    Write-Host "Waiting for valid JSON from /_localstack/health... ($attempt of $maxAttempts)"
    Start-Sleep -Seconds 1
}

if (-not $success) {
    Write-Host "LocalStack /_localstack/health did not return valid JSON in time."
    exit 1
} 