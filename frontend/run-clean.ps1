# Flutter Clean & Run Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FLUTTER CLEAN & RUN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "c:\Users\Rakha\Downloads\ALP Vispro\ALP_VOW_KLP4\frontend"

Write-Host "[1/3] Cleaning build cache..." -ForegroundColor Yellow
flutter clean
Write-Host "✓ Clean completed" -ForegroundColor Green

Write-Host "`n[2/3] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "✓ Dependencies downloaded" -ForegroundColor Green

Write-Host "`n[3/3] Running Flutter app..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TIPS:" -ForegroundColor Yellow
Write-Host "- Jika perubahan tidak muncul, tekan 'R' untuk hot reload" -ForegroundColor White
Write-Host "- Atau tekan 'Shift+R' untuk hot restart" -ForegroundColor White
Write-Host "- Backend harus running di http://localhost:8000" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

flutter run
