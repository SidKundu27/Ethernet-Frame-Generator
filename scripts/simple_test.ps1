param(
    [string]$TestCase = "default"
)

Write-Host "=== Simple Test Script ===" -ForegroundColor Green
Write-Host "Test Case: $TestCase" -ForegroundColor Yellow

if ($TestCase -eq "help") {
    Write-Host "This is help output" -ForegroundColor Cyan
} else {
    Write-Host "Running test case: $TestCase" -ForegroundColor Green
}

Write-Host "Script completed." -ForegroundColor Green
