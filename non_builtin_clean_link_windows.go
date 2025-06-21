//go:build !grocksdb_no_link && grocksdb_clean_link && windows

// Windows-specific clean link options - minimal set of flags
package grocksdb

// #cgo LDFLAGS: -lrocksdb -lstdc++
import "C"
