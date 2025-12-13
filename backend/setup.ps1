# Setup Backend Laravel

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP BACKEND LARAVEL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Pindah ke direktori backend
Set-Location "c:\Users\Rakha\Downloads\ALP Vispro\ALP_VOW_KLP4\backend"

# 1. Install dependencies
Write-Host "[1/5] Installing Composer dependencies..." -ForegroundColor Yellow
if (!(Test-Path "vendor")) {
    composer install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Composer install failed!" -ForegroundColor Red
        exit 1
    }
}
Write-Host "✓ Composer dependencies installed" -ForegroundColor Green

# 2. Copy .env file jika belum ada
Write-Host "`n[2/5] Checking .env file..." -ForegroundColor Yellow
if (!(Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✓ .env file created from .env.example" -ForegroundColor Green
    } else {
        Write-Host "Warning: .env.example not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "✓ .env file exists" -ForegroundColor Green
}

# 3. Generate app key
Write-Host "`n[3/5] Generating application key..." -ForegroundColor Yellow
php artisan key:generate --force
Write-Host "✓ Application key generated" -ForegroundColor Green

# 4. Run migrations
Write-Host "`n[4/5] Running database migrations..." -ForegroundColor Yellow
php artisan migrate --force
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Database migrations completed" -ForegroundColor Green
} else {
    Write-Host "Warning: Migration failed. Make sure database is configured in .env" -ForegroundColor Yellow
}

# 5. Clear cache
Write-Host "`n[5/5] Clearing cache..." -ForegroundColor Yellow
php artisan config:clear
php artisan cache:clear
Write-Host "✓ Cache cleared" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start the server, run:" -ForegroundColor Yellow
Write-Host "  php artisan serve" -ForegroundColor White
Write-Host ""
Write-Host "Your API will be available at:" -ForegroundColor Yellow
Write-Host "  http://localhost:8000/api" -ForegroundColor White
Write-Host "  http://127.0.0.1:8000/api" -ForegroundColor White
Write-Host ""
