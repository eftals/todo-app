# PowerShell script to verify all required LocalStack services are running

Write-Host "Checking LocalStack services (dynamodb, sqs, sns, s3, lambda)..."

$requiredServices = @('dynamodb', 'sqs', 'sns', 's3', 'lambda')
$maxAttempts = 30
$attempt = 0
$success = $false

while ($attempt -lt $maxAttempts -and -not $success) {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:4566/_localstack/health"
        $allRunning = $true
        foreach ($service in $requiredServices) {
            if ($response.services.$service -ne 'running') {
                $allRunning = $false
                break
            }
        }
        if ($allRunning) {
            Write-Host "All required LocalStack services are running!"
            $success = $true
            exit 0
        }
    } catch {
        # Ignore errors and retry
    }
    $attempt++
    Write-Host "Waiting for all services to be running... ($attempt of $maxAttempts)"
    Start-Sleep -Seconds 1
}

if (-not $success) {
    Write-Host "Not all required LocalStack services became running in time."
    exit 1
} 