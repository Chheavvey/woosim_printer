Write-Host "Applying AGP 9 new DSL fix for Woosim Flutter project..." -ForegroundColor Cyan

$ProjectRoot = Get-Location
$GradleFile = Join-Path $ProjectRoot "android\app\build.gradle.kts"
$GradleProperties = Join-Path $ProjectRoot "android\gradle.properties"

if (!(Test-Path $GradleFile)) {
    Write-Host "ERROR: android\app\build.gradle.kts not found. Please run this script inside the Flutter project root." -ForegroundColor Red
    exit 1
}

$NewContent = @'
import com.android.build.api.dsl.ApplicationExtension
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

configure<ApplicationExtension> {
    namespace = "com.devlabs.woosim_printer_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
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

configure<KotlinAndroidProjectExtension> {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
'@

Set-Content -Path $GradleFile -Value $NewContent -Encoding UTF8
Write-Host "Updated android\app\build.gradle.kts" -ForegroundColor Green

if (Test-Path $GradleProperties) {
    $props = Get-Content $GradleProperties | Where-Object { $_ -notmatch '^\s*android\.newDsl\s*=' }
    Set-Content -Path $GradleProperties -Value $props -Encoding UTF8
    Write-Host "Removed android.newDsl override from android\gradle.properties" -ForegroundColor Green
}

$pathsToClean = @(
    "android\.gradle",
    "android\app\build",
    "build",
    ".dart_tool"
)

foreach ($p in $pathsToClean) {
    $full = Join-Path $ProjectRoot $p
    if (Test-Path $full) {
        try {
            Remove-Item -Recurse -Force $full -ErrorAction Stop
            Write-Host "Removed $p" -ForegroundColor Green
        } catch {
            Write-Host "Could not remove $p. Close Android Studio/Emulator and delete it manually if build still fails." -ForegroundColor Yellow
        }
    }
}

Write-Host "Done. Now run:" -ForegroundColor Cyan
Write-Host "flutter pub get" -ForegroundColor White
Write-Host "flutter run" -ForegroundColor White
