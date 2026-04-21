# Flutter and Android Development Setup Script
Write-Host "=== Flutter and Android Development Setup ===" -ForegroundColor Green

# Install Flutter using Chocolatey
Write-Host "`nInstalling Flutter SDK..." -ForegroundColor Yellow
choco install flutter -y

# Install Android Studio
Write-Host "`nInstalling Android Studio..." -ForegroundColor Yellow
winget install Google.AndroidStudio --accept-package-agreements --accept-source-agreements

# Install Java JDK (required for Android development)
Write-Host "`nInstalling Java JDK..." -ForegroundColor Yellow
choco install openjdk17 -y

Write-Host "`n=== Installation Complete ===" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Close and reopen your terminal to refresh PATH"
Write-Host "2. Run: flutter doctor"
Write-Host "3. Open Android Studio and complete the setup wizard"
Write-Host "4. In Android Studio, go to Tools > Device Manager to create an emulator"
Write-Host "5. Accept Android licenses: flutter doctor --android-licenses"
