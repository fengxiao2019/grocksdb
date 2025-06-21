# grocksdb, RocksDB wrapper for Go

[![](https://github.com/linxGnu/grocksdb/workflows/CI/badge.svg)]()
[![Go Report Card](https://goreportcard.com/badge/github.com/linxGnu/grocksdb)](https://goreportcard.com/report/github.com/linxGnu/grocksdb)
[![Coverage Status](https://coveralls.io/repos/github/linxGnu/grocksdb/badge.svg?branch=master)](https://coveralls.io/github/linxGnu/grocksdb?branch=master)
[![godoc](https://img.shields.io/badge/docs-GoDoc-green.svg)](https://godoc.org/github.com/linxGnu/grocksdb)

This is a `Fork` from [tecbot/gorocksdb](https://github.com/tecbot/gorocksdb). I respect the author work and community contribution.
The `LICENSE` still remains as upstream.

Why I made a patched clone instead of PR:
- Supports almost C API (unlike upstream). Catching up with latest version of Rocksdb as promise.
- This fork contains `no defer` in codebase (my side project requires as less overhead as possible). This introduces loose
convention of how/when to free c-mem, thus break the rule of [tecbot/gorocksdb](https://github.com/tecbot/gorocksdb).

## Install

### Prerequisites

#### Linux/macOS:
- librocksdb
- libsnappy  
- libz
- liblz4
- libzstd
- libbz2 (optional)

Please follow this guide: https://github.com/facebook/rocksdb/blob/master/INSTALL.md to build above libs.

#### Windows:
- **Visual Studio 2019 or later** with C++ support
- **CMake 3.10 or later**
- **Git for Windows** (or equivalent for tar command)
- **PowerShell 5.0 or later**

**Automated Installation:**
```cmd
# Using batch file (recommended)
build_windows.bat C:\rocksdb

# Or using PowerShell directly
powershell -ExecutionPolicy Bypass -File build_windows.ps1 -InstallPrefix "C:\rocksdb"
```

**Manual Installation:**
You can also manually install RocksDB following: https://github.com/facebook/rocksdb/blob/master/INSTALL.md#windows

### Build 

After installing both `rocksdb` and `grocksdb`, you can build your app using the following commands:

#### Linux/macOS:
```bash
CGO_CFLAGS="-I/path/to/rocksdb/include" \
CGO_LDFLAGS="-L/path/to/rocksdb -lrocksdb -lstdc++ -lm -lz -lsnappy -llz4 -lzstd" \
  go build
```

Or just:
```bash
go build # if prerequisites are in linker paths
```

If your rocksdb was linked with bz2:
```bash
CGO_LDFLAGS="-L/path/to/rocksdb -lrocksdb -lstdc++ -lm -lz -lsnappy -llz4 -lzstd -lbz2" \
  go build
```

#### Windows:
After running the build script, set environment variables and build:

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

**Or use Make (if you have Make for Windows):**
```cmd
# Set GOOS and build
set GOOS=windows
make libs
go build
```

#### Customize the build flags

**Linux/macOS:**
Currently, the default build flags without specifying `CGO_LDFLAGS` or the corresponding environment variables are `-lrocksdb -pthread -lstdc++ -ldl -lm -lzstd -llz4 -lz -lsnappy`

**Windows:**
The default build flags are `-lrocksdb -lstdc++ -lzstd -llz4 -lz -lsnappy` (Unix-specific libraries like `-pthread` and `-ldl` are automatically excluded)

If you want to customize the build flags:

1. Use `-tags grocksdb_clean_link` to create a cleaner set of flags and build it based on the cleaner flag. The base build flags after using the tag are `-lrocksdb -pthread -lstdc++ -ldl` (Linux/macOS) or `-lrocksdb -lstdc++` (Windows).
```bash
# Linux/macOS
CGO_LDFLAGS="-L/path/to/rocksdb -lzstd" go build -tags grocksdb_clean_link

# Windows
set CGO_LDFLAGS=-LC:\rocksdb\lib -lzstd
go build -tags grocksdb_clean_link
```

2. Use `-tags grocksdb_no_link` to ignore the build flags provided by the library and build it fully based on the custom flags.
```bash
# Linux/macOS
CGO_LDFLAGS="-L/path/to/rocksdb -lrocksdb -lstdc++ -lzstd -llz4" go build -tags grocksdb_no_link

# Windows  
set CGO_LDFLAGS=-LC:\rocksdb\lib -lrocksdb -lstdc++ -lzstd -llz4
go build -tags grocksdb_no_link
```

## Usage

See also: [doc](https://godoc.org/github.com/linxGnu/grocksdb)

## API Support

Almost C API, excepts:
- [ ] get_db_identity
- [ ] putv/mergev/deletev/delete_rangev
- [ ] compaction_filter/compaction_filter_factory/compaction_filter_context
- [ ] transactiondb_property_value/transactiondb_property_int
- [ ] optimistictransactiondb_property_value/optimistictransactiondb_property_int
- [ ] writebatch_update_timestamps/writebatch_wi_update_timestamps/writebatch_iterate_cf
- [ ] approximate_sizes_cf_with_flags
- [ ] logger_create_callback_logger

