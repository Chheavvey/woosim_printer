$ErrorActionPreference = "Stop"

Write-Host "Woosim Flutter build fix started..." -ForegroundColor Cyan

$ProjectRoot = Get-Location
$AndroidDir = Join-Path $ProjectRoot "android"
$AppGradleKts = Join-Path $ProjectRoot "android\app\build.gradle.kts"
$GradleProps = Join-Path $ProjectRoot "android\gradle.properties"

if (!(Test-Path $AndroidDir)) {
    throw "This script must be run from Flutter project root folder. Missing android folder."
}

if (!(Test-Path $AppGradleKts)) {
    throw "Missing android/app/build.gradle.kts. This script is for Kotlin DSL Flutter projects."
}

# 1) Opt out from AGP 9 new DSL path that can break older Flutter/plugin Gradle scripts.
if (!(Test-Path $GradleProps)) {
    New-Item -ItemType File -Force -Path $GradleProps | Out-Null
}
$props = Get-Content $GradleProps -Raw
if ($props -notmatch "(?m)^android\.newDsl\s*=") {
    Add-Content $GradleProps "`nandroid.newDsl=false"
} else {
    $props = $props -replace "(?m)^android\.newDsl\s*=.*$", "android.newDsl=false"
    Set-Content $GradleProps $props
}

# 2) Rewrite app build.gradle.kts using Flutter standard plugin order and minSdk 28.
$buildGradle = @'
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.devlabs.woosim_printer_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.devlabs.woosim_printer_flutter"
        minSdk = 28
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
'@
Set-Content $AppGradleKts $buildGradle

# 3) Remove corrupted Gradle transform cache and project build cache.
$GradleTransforms = Join-Path $env:USERPROFILE ".gradle\caches\9.1.0\transforms"
if (Test-Path $GradleTransforms) {
    Write-Host "Removing Gradle 9.1.0 transform cache..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $GradleTransforms
}

$ProjectGradle = Join-Path $ProjectRoot "android\.gradle"
$ProjectBuild = Join-Path $ProjectRoot "build"
$DartTool = Join-Path $ProjectRoot ".dart_tool"
foreach ($p in @($ProjectGradle, $ProjectBuild, $DartTool)) {
    if (Test-Path $p) {
        Write-Host "Removing $p" -ForegroundColor Yellow
        Remove-Item -Recurse -Force $p
    }
}

Write-Host "Running flutter clean..." -ForegroundColor Cyan
flutter clean

Write-Host "Running flutter pub get..." -ForegroundColor Cyan
flutter pub get

Write-Host "Done. Now run: flutter run" -ForegroundColor Green
