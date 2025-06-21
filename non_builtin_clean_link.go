//go:build !grocksdb_no_link && grocksdb_clean_link && !windows

// Unix-specific clean link options
package grocksdb

// #cgo LDFLAGS: -lrocksdb -pthread -lstdc++ -ldl
import "C"
