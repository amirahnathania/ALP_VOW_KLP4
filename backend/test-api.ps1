# Test API Connection

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TESTING API CONNECTION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8000/api"

# Test 1: Test endpoint
Write-Host "[1] Testing /api/test endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/test" -Method Get
    Write-Host "✓ API is working!" -ForegroundColor Green
    Write-Host "  Response: $($response.message)" -ForegroundColor Gray
} catch {
    Write-Host "✗ API test failed!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host ""

# Test 2: Login endpoint structure
Write-Host "[2] Testing /api/login endpoint (POST)..." -ForegroundColor Yellow
try {
    $body = @{
        email = "test@ketua.ac.id"
        password = "Test1234"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "✓ Login endpoint is accessible" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "✓ Login endpoint is working (401 Unauthorized expected for invalid credentials)" -ForegroundColor Green
    } else {
        Write-Host "✗ Login endpoint error!" -ForegroundColor Red
        Write-Host "  Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST COMPLETED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
