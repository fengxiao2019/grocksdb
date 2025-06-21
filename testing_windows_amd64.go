//go:build testing

package grocksdb

// #cgo CFLAGS: -I${SRCDIR}/dist/windows_amd64/include
// #cgo CXXFLAGS: -I${SRCDIR}/dist/windows_amd64/include
// #cgo LDFLAGS: -L${SRCDIR}/dist/windows_amd64/lib -lrocksdb -lstdc++ -lzstd -llz4 -lz -lsnappy
import "C"
