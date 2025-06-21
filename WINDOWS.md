# Windows Support for grocksdb

This document provides comprehensive instructions for building and using grocksdb on Windows.

## Prerequisites

Before building grocksdb on Windows, ensure you have:

- **Visual Studio 2019 or later** with C++ support (Community Edition is sufficient)
- **CMake 3.10 or later** (download from https://cmake.org/)
- **Git for Windows** (download from https://git-scm.com/)
- **PowerShell 5.0 or later** (included with Windows 10+)
- **Go 1.17 or later** (download from https://golang.org/)

## Quick Start

### 1. Build RocksDB Dependencies

Option A - Using the batch file (recommended):
```cmd
build_windows.bat C:\rocksdb
```

Option B - Using PowerShell directly:
```powershell
.\build_windows.ps1 -InstallPrefix "C:\rocksdb"
```

### 2. Build Your Go Application

After the dependencies are built, set environment variables and build:

**Command Prompt:**
```cmd
set CGO_CFLAGS=-IC:\rocksdb\include
set CGO_LDFLAGS=-LC:\rocksdb\lib -lrocksdb -lstdc++ -lzstd -llz4 -lz -lsnappy
go build
```

**PowerShell:**
```powershell
$env:CGO_CFLAGS="-IC:\rocksdb\include"
$env:CGO_LDFLAGS="-LC:\rocksdb\lib -lrocksdb -lstdc++ -lzstd -llz4 -lz -lsnappy"
go build
```

## Example Application

Create a simple test program to verify your installation:

```go
// main.go
package main

import (
    "fmt"
    "log"
    
    "github.com/linxGnu/grocksdb"
)

func main() {
    // Open database
    opts := grocksdb.NewDefaultOptions()
    opts.SetCreateIfMissing(true)
    
    db, err := grocksdb.OpenDb(opts, "test.db")
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()
    defer opts.Destroy()
    
    // Write
    wo := grocksdb.NewDefaultWriteOptions()
    defer wo.Destroy()
    
    err = db.Put(wo, []byte("key"), []byte("value"))
    if err != nil {
        log.Fatal(err)
    }
    
    // Read
    ro := grocksdb.NewDefaultReadOptions()
    defer ro.Destroy()
    
    value, err := db.Get(ro, []byte("key"))
    if err != nil {
        log.Fatal(err)
    }
    defer value.Free()
    
    fmt.Printf("Value: %s\n", value.Data())
}
```

## Build Customization

### Using Build Tags

grocksdb supports several build tags for customization:

1. **Default build** (includes all dependencies):
```cmd
go build
```

2. **Clean link** (minimal dependencies):
```cmd
go build -tags grocksdb_clean_link
```

3. **No link** (full control via environment variables):
```cmd
set CGO_LDFLAGS=-LC:\rocksdb\lib -lrocksdb -lstdc++ -lzstd
go build -tags grocksdb_no_link
```

### Custom Installation Path

If you installed RocksDB to a different location:

```cmd
set ROCKSDB_PATH=D:\my\rocksdb\path
set CGO_CFLAGS=-I%ROCKSDB_PATH%\include
set CGO_LDFLAGS=-L%ROCKSDB_PATH%\lib -lrocksdb -lstdc++ -lzstd -llz4 -lz -lsnappy
go build
```

## Troubleshooting

### Common Issues

1. **"gcc not found"**
   - Install MinGW-w64 or use Visual Studio's Developer Command Prompt
   - Alternative: Use TDM-GCC (https://jmeubank.github.io/tdm-gcc/)

2. **"cannot find -lrocksdb"**
   - Verify RocksDB was built successfully
   - Check that CGO_LDFLAGS points to the correct lib directory
   - Ensure library files exist in the specified path

3. **PowerShell execution policy error**
   - Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
   - Or use: `powershell -ExecutionPolicy Bypass -File build_windows.ps1`

4. **CMake not found**
   - Add CMake to your PATH environment variable
   - Or specify full path in the build script

### Debugging Build Issues

Enable verbose output:
```cmd
set CGO_CFLAGS=-IC:\rocksdb\include -v
set CGO_LDFLAGS=-LC:\rocksdb\lib -lrocksdb -lstdc++ -lzstd -llz4 -lz -lsnappy -v
go build -x -v
```

### Using with Different Compilers

**MinGW-w64:**
```cmd
set CC=gcc
set CXX=g++
go build
```

**Clang:**
```cmd
set CC=clang
set CXX=clang++
go build
```

## Advanced Configuration

### Static vs Dynamic Linking

The build script creates static libraries by default. For dynamic linking:

1. Modify `build_windows.ps1` and change `-DROCKSDB_BUILD_SHARED=OFF` to `ON`
2. Ensure DLLs are in your PATH when running applications

### Cross-compilation

Build for different architectures:

```cmd
# For ARM64 (if supported)
set GOARCH=arm64
go build

# For 32-bit (if needed)
set GOARCH=386
go build
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Build on Windows
on: [push, pull_request]
jobs:
  build:
    runs-on: windows-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-go@v2
      with:
        go-version: 1.19
    - name: Build RocksDB
      run: .\build_windows.bat C:\rocksdb
    - name: Build Application
      run: |
        $env:CGO_CFLAGS="-IC:\rocksdb\include"
        $env:CGO_LDFLAGS="-LC:\rocksdb\lib -lrocksdb -lstdc++ -lzstd -llz4 -lz -lsnappy"
        go build
```

## Performance Considerations

- Use Release builds for production (this is default in our scripts)
- Consider enabling specific CPU optimizations if targeting specific hardware
- Profile your application with Windows Performance Analyzer if needed

## Support

If you encounter issues with Windows support:

1. Check this documentation first
2. Verify all prerequisites are installed
3. Try building a simple example application
4. Create an issue on GitHub with:
   - Windows version
   - Visual Studio version
   - Go version
   - Complete error messages
   - Build command used

## Contributing

When contributing Windows-specific changes:

1. Test on multiple Windows versions (10, 11, Server)
2. Test with different Visual Studio versions
3. Update this documentation
4. Add Windows-specific test cases 