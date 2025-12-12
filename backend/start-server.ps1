# Start Laravel Backend Server

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STARTING LARAVEL BACKEND SERVER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "c:\Users\Rakha\Downloads\ALP Vispro\ALP_VOW_KLP4\backend"

Write-Host "Server will be available at:" -ForegroundColor Yellow
Write-Host "  - http://localhost:8000" -ForegroundColor White
Write-Host "  - http://127.0.0.1:8000" -ForegroundColor White
Write-Host ""
Write-Host "API Endpoints:" -ForegroundColor Yellow
Write-Host "  - POST /api/login      (Login)" -ForegroundColor White
Write-Host "  - POST /api/users      (Register)" -ForegroundColor White
Write-Host "  - GET  /api/test       (Test API)" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

php artisan serve
