//go:build !grocksdb_no_link && !grocksdb_clean_link && windows

// Windows-specific default link options
package grocksdb

// #cgo LDFLAGS: -lrocksdb -lstdc++ -lzstd -llz4 -lz -lsnappy
import "C"
