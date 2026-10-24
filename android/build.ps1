# Builds a signed StitchTally.apk with the plain Android SDK tools (no Gradle).
# Usage:  powershell -ExecutionPolicy Bypass -File build.ps1 [-VersionCode 2 -VersionName 1.1]
param([int]$VersionCode = 1, [string]$VersionName = "1.0")
$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "$env:LOCALAPPDATA\Android\Sdk" }
$bt = "$sdk\build-tools\34.0.0"
$androidJar = "$sdk\platforms\android-34\android.jar"
if (-not $env:JAVA_HOME -or -not (Test-Path "$env:JAVA_HOME\bin\javac.exe")) {
    $jdk = Get-ChildItem "C:\Program Files\Microsoft" -Directory -Filter "jdk-17*" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $jdk) { throw "JDK 17 not found. Install it with: winget install Microsoft.OpenJDK.17" }
    $env:JAVA_HOME = $jdk.FullName
}
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
foreach ($p in @($bt, $androidJar)) { if (-not (Test-Path $p)) { throw "Missing $p. Install with sdkmanager 'build-tools;34.0.0' 'platforms;android-34'" } }

function Run($exe, [string[]]$argv) {
    & $exe @argv
    if ($LASTEXITCODE -ne 0) { throw "$(Split-Path $exe -Leaf) failed with exit code $LASTEXITCODE" }
}

$out = "$root\build"
Remove-Item -Recurse -Force $out -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$out\gen", "$out\classes", "$out\dex" | Out-Null

Write-Host "1/6 Compiling resources"
Run "$bt\aapt2.exe" @("compile", "--dir", "$root\res", "-o", "$out\res.zip")

Write-Host "2/6 Linking resources, manifest and assets"
Run "$bt\aapt2.exe" @("link", "-o", "$out\unsigned.apk", "-I", $androidJar,
    "--manifest", "$root\AndroidManifest.xml", "-A", "$(Split-Path $root -Parent)\app", "-R", "$out\res.zip",
    "--java", "$out\gen", "--min-sdk-version", "26", "--target-sdk-version", "34",
    "--version-code", "$VersionCode", "--version-name", $VersionName, "--auto-add-overlay")

Write-Host "3/6 Compiling Java"
$sources = Get-ChildItem "$root\src", "$out\gen" -Recurse -Filter *.java | ForEach-Object FullName
Run "javac" (@("-encoding", "UTF-8", "-source", "11", "-target", "11", "-nowarn", "-Xlint:-options",
    "-classpath", $androidJar, "-d", "$out\classes") + $sources)

Write-Host "4/6 Converting to Android bytecode"
$classes = Get-ChildItem "$out\classes" -Recurse -Filter *.class | ForEach-Object FullName
Run "$bt\d8.bat" (@("--release", "--lib", $androidJar, "--min-api", "26", "--output", "$out\dex") + $classes)

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::Open("$out\unsigned.apk", "Update")
[IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$out\dex\classes.dex", "classes.dex") | Out-Null
$zip.Dispose()

Write-Host "5/6 Aligning"
Run "$bt\zipalign.exe" @("-p", "-f", "4", "$out\unsigned.apk", "$out\aligned.apk")

Write-Host "6/6 Signing"
# Your personal signing key. Keep stitchtally.keystore and keystore.properties safe:
# updates to the installed app must be signed with the same key.
$ks = "$root\stitchtally.keystore"
$props = "$root\keystore.properties"
if (-not (Test-Path $ks)) {
    $pw = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ })
    Set-Content -Path $props -Value "password=$pw" -Encoding ascii
    Run "keytool" @("-genkeypair", "-keystore", $ks, "-alias", "stitchtally", "-keyalg", "RSA", "-keysize", "2048",
        "-validity", "10000", "-storepass", $pw, "-keypass", $pw, "-dname", "CN=Stitch Tally")
}
$pw = (@(Get-Content $props) -match "^password=")[0].Substring(9)
$apk = Join-Path (Split-Path $root -Parent) "StitchTally.apk"
Run "$bt\apksigner.bat" @("sign", "--ks", $ks, "--ks-key-alias", "stitchtally", "--ks-pass", "pass:$pw", "--key-pass", "pass:$pw", "--out", $apk, "$out\aligned.apk")
Run "$bt\apksigner.bat" @("verify", $apk)
Write-Host "Built $apk ($([math]::Round((Get-Item $apk).Length / 1KB)) KB)"
