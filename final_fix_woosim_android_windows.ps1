$ErrorActionPreference = "Stop"

Write-Host "Woosim final Android fix started..." -ForegroundColor Cyan

if (-not (Test-Path "pubspec.yaml")) {
    throw "Please run this script inside your Flutter project root folder. I cannot find pubspec.yaml."
}

# 1) Force AGP 9 to use old DSL because Flutter can detect applicationId better with standard android {} block.
$GradleProperties = "android\gradle.properties"
if (-not (Test-Path $GradleProperties)) {
    New-Item -ItemType File -Force -Path $GradleProperties | Out-Null
}
$gpText = Get-Content $GradleProperties -Raw
$gpLines = $gpText -split "`r?`n" | Where-Object { $_ -notmatch "^\s*android\.newDsl\s*=" }
$gpNew = (($gpLines -join "`r`n").TrimEnd()) + "`r`nandroid.newDsl=false`r`n"
Set-Content -Path $GradleProperties -Value $gpNew -Encoding UTF8
Write-Host "Updated android\gradle.properties with android.newDsl=false" -ForegroundColor Green

# 2) Use standard Flutter Android build.gradle.kts. Do NOT use configure<ApplicationExtension>; Flutter may not detect package id.
$BuildGradleKts = "android\app\build.gradle.kts"
$BuildGradleContent = @'
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
Set-Content -Path $BuildGradleKts -Value $BuildGradleContent -Encoding UTF8
Write-Host "Rewrote android\app\build.gradle.kts with standard Flutter DSL" -ForegroundColor Green

# 3) Ensure AndroidManifest has Flutter launch activity and required permissions.
$Manifest = "android\app\src\main\AndroidManifest.xml"
$ManifestContent = @'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-feature android:name="android.hardware.bluetooth" android:required="false" />
    <uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />

    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />

    <application
        android:label="Woosim Printer"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:requestLegacyExternalStorage="true"
        android:usesCleartextTraffic="true">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />

    </application>

</manifest>
'@
New-Item -ItemType Directory -Force -Path (Split-Path $Manifest) | Out-Null
Set-Content -Path $Manifest -Value $ManifestContent -Encoding UTF8
Write-Host "Rewrote AndroidManifest.xml" -ForegroundColor Green

# 4) Ensure MainActivity exists in the expected package.
$MainDir = "android\app\src\main\kotlin\com\devlabs\woosim_printer_flutter"
New-Item -ItemType Directory -Force -Path $MainDir | Out-Null
$MainActivity = Join-Path $MainDir "MainActivity.kt"

$HasPrinterHandler = Test-Path (Join-Path $MainDir "printer\PrinterChannelHandler.kt")

if ($HasPrinterHandler) {
$MainContent = @'
package com.devlabs.woosim_printer_flutter

import com.devlabs.woosim_printer_flutter.printer.PrinterChannelHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "woosim_printer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler(PrinterChannelHandler(this))
    }
}
'@
} else {
$MainContent = @'
package com.devlabs.woosim_printer_flutter

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
'@
}
Set-Content -Path $MainActivity -Value $MainContent -Encoding UTF8
Write-Host "Rewrote MainActivity.kt" -ForegroundColor Green

# 5) Clean generated files.
Write-Host "Cleaning Flutter/Gradle generated files..." -ForegroundColor Cyan
flutter clean
if (Test-Path ".dart_tool") { Remove-Item -Recurse -Force ".dart_tool" }
if (Test-Path "android\.gradle") { Remove-Item -Recurse -Force "android\.gradle" }

flutter pub get

Write-Host ""
Write-Host "Fix finished. Now run:" -ForegroundColor Green
Write-Host "flutter run" -ForegroundColor Yellow
