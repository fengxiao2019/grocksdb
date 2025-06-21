param(
    [Parameter(Mandatory=$true)]
    [string]$InstallPrefix
)

# Exit on any error
$ErrorActionPreference = "Stop"

Write-Host "Building RocksDB and dependencies for Windows..." -ForegroundColor Green
Write-Host "Install prefix: $InstallPrefix" -ForegroundColor Yellow

# Create build directory
$BUILD_PATH = "$env:TEMP\rocksdb_build"
if (Test-Path $BUILD_PATH) {
    Write-Host "Cleaning existing build directory..." -ForegroundColor Yellow
    Remove-Item $BUILD_PATH -Recurse -Force
}
New-Item -ItemType Directory -Path $BUILD_PATH | Out-Null

# Ensure install directories exist
New-Item -ItemType Directory -Path "$InstallPrefix\lib" -Force | Out-Null
New-Item -ItemType Directory -Path "$InstallPrefix\include" -Force | Out-Null

$CMAKE_REQUIRED_PARAMS = @(
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DCMAKE_INSTALL_PREFIX=$InstallPrefix"
    "-DCMAKE_BUILD_TYPE=Release"
    "-G", "Visual Studio 16 2019"
    "-A", "x64"
)

# Function to build a dependency
function Build-Dependency {
    param(
        [string]$Name,
        [string]$Version,
        [string]$Url,
        [string]$ArchiveName,
        [string]$SourceDir,
        [array]$ExtraOptions = @(),
        [string]$Subdir = ""
    )
    
    Write-Host "Building $Name $Version..." -ForegroundColor Cyan
    
    Set-Location $BUILD_PATH
    
    # Download
    if (-not (Test-Path $ArchiveName)) {
        Write-Host "  Downloading $Name..." -ForegroundColor White
        Invoke-WebRequest -Uri $Url -OutFile $ArchiveName
    }
    
    # Extract
    Write-Host "  Extracting $Name..." -ForegroundColor White
    if ($ArchiveName.EndsWith(".tar.gz")) {
        tar -xzf $ArchiveName
    } elseif ($ArchiveName.EndsWith(".zip")) {
        Expand-Archive -Path $ArchiveName -DestinationPath . -Force
    }
    
    # Build
    $buildDir = "$SourceDir$Subdir"
    Set-Location $buildDir
    
    New-Item -ItemType Directory -Path "build_place" -Force | Out-Null
    Set-Location "build_place"
    
    Write-Host "  Configuring $Name..." -ForegroundColor White
    $cmakeArgs = $CMAKE_REQUIRED_PARAMS + $ExtraOptions + @("..")
    & cmake @cmakeArgs
    if ($LASTEXITCODE -ne 0) { throw "CMake configuration failed for $Name" }
    
    Write-Host "  Building $Name..." -ForegroundColor White
    cmake --build . --config Release
    if ($LASTEXITCODE -ne 0) { throw "Build failed for $Name" }
    
    Write-Host "  Installing $Name..." -ForegroundColor White
    cmake --build . --config Release --target install
    if ($LASTEXITCODE -ne 0) { throw "Install failed for $Name" }
    
    # Clean up
    Set-Location $BUILD_PATH
    Remove-Item $SourceDir -Recurse -Force -ErrorAction SilentlyContinue
}

try {
    # Build Snappy
    Build-Dependency -Name "Snappy" -Version "1.2.2" `
        -Url "https://github.com/google/snappy/archive/1.2.2.tar.gz" `
        -ArchiveName "snappy-1.2.2.tar.gz" `
        -SourceDir "snappy-1.2.2" `
        -ExtraOptions @("-DSNAPPY_BUILD_TESTS=OFF", "-DSNAPPY_BUILD_BENCHMARKS=OFF")

    # Build zlib
    Build-Dependency -Name "zlib" -Version "1.3.1" `
        -Url "https://github.com/madler/zlib/archive/v1.3.1.tar.gz" `
        -ArchiveName "zlib-1.3.1.tar.gz" `
        -SourceDir "zlib-1.3.1" `
        -ExtraOptions @()

    # Build LZ4
    Build-Dependency -Name "LZ4" -Version "1.10.0" `
        -Url "https://github.com/lz4/lz4/archive/v1.10.0.tar.gz" `
        -ArchiveName "lz4-1.10.0.tar.gz" `
        -SourceDir "lz4-1.10.0" `
        -Subdir "\build\cmake" `
        -ExtraOptions @("-DLZ4_BUILD_LEGACY_LZ4C=OFF", "-DBUILD_SHARED_LIBS=OFF", "-DLZ4_POSITION_INDEPENDENT_LIB=ON")

    # Build Zstd
    Build-Dependency -Name "Zstd" -Version "1.5.7" `
        -Url "https://github.com/facebook/zstd/archive/v1.5.7.tar.gz" `
        -ArchiveName "zstd-1.5.7.tar.gz" `
        -SourceDir "zstd-1.5.7" `
        -Subdir "\build\cmake" `
        -ExtraOptions @(
            "-DZSTD_BUILD_PROGRAMS=OFF",
            "-DZSTD_BUILD_CONTRIB=OFF", 
            "-DZSTD_BUILD_STATIC=ON",
            "-DZSTD_BUILD_SHARED=OFF",
            "-DZSTD_BUILD_TESTS=OFF",
            "-DZSTD_ZLIB_SUPPORT=ON",
            "-DZSTD_LZMA_SUPPORT=OFF"
        )

    # Build RocksDB
    Build-Dependency -Name "RocksDB" -Version "10.2.1" `
        -Url "https://github.com/facebook/rocksdb/archive/v10.2.1.tar.gz" `
        -ArchiveName "rocksdb-10.2.1.tar.gz" `
        -SourceDir "rocksdb-10.2.1" `
        -ExtraOptions @(
            "-DCMAKE_PREFIX_PATH=$InstallPrefix",
            "-DWITH_TESTS=OFF",
            "-DWITH_GFLAGS=OFF",
            "-DWITH_BENCHMARK_TOOLS=OFF",
            "-DWITH_TOOLS=OFF",
            "-DWITH_MD_LIBRARY=OFF",
            "-DWITH_RUNTIME_DEBUG=OFF",
            "-DROCKSDB_BUILD_SHARED=OFF",
            "-DWITH_SNAPPY=ON",
            "-DWITH_LZ4=ON",
            "-DWITH_ZLIB=ON",
            "-DWITH_LIBURING=OFF",
            "-DWITH_ZSTD=ON",
            "-DWITH_BZ2=OFF",
            "-DPORTABLE=1"
        )

    # Clean up build directory
    Remove-Item $BUILD_PATH -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "" -ForegroundColor Green
    Write-Host "✅ Build completed successfully!" -ForegroundColor Green
    Write-Host "📁 Libraries installed to: $InstallPrefix" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor Green
    Write-Host "To use with grocksdb, set these environment variables:" -ForegroundColor Cyan
    Write-Host "  set CGO_CFLAGS=-I$InstallPrefix\include" -ForegroundColor White
    Write-Host "  set CGO_LDFLAGS=-L$InstallPrefix\lib -lrocksdb -lstdc++ -lzstd -llz4 -lz -lsnappy" -ForegroundColor White
    Write-Host "  go build" -ForegroundColor White
    Write-Host "" -ForegroundColor Green

} catch {
    Write-Host "❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 