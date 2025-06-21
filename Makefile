GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
GOOS_GOARCH := $(GOOS)_$(GOARCH)
GOOS_GOARCH_NATIVE := $(shell go env GOHOSTOS)_$(shell go env GOHOSTARCH)

ROOT_DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DEST=$(ROOT_DIR)/dist/$(GOOS_GOARCH)
DEST_LIB=$(DEST)/lib
DEST_INCLUDE=$(DEST)/include

default: prepare libs

.PHONY: prepare
prepare:
ifeq ($(GOOS),windows)
	powershell -Command "if (Test-Path '$(DEST)') { Remove-Item '$(DEST)' -Recurse -Force }"
	powershell -Command "New-Item -ItemType Directory -Path '$(DEST_LIB)' -Force | Out-Null"
	powershell -Command "New-Item -ItemType Directory -Path '$(DEST_INCLUDE)' -Force | Out-Null"
else
	rm -rf $(DEST)
	mkdir -p $(DEST_LIB) $(DEST_INCLUDE)
endif

.PHONY: libs
libs:
ifeq ($(GOOS),windows)
	powershell -ExecutionPolicy Bypass -File build_windows.ps1 -InstallPrefix "$(DEST)"
else
	./build.sh $(DEST)
endif

.PHONY: libs-windows
libs-windows:
	powershell -ExecutionPolicy Bypass -File build_windows.ps1 -InstallPrefix "$(DEST)"

.PHONY: test
test:
	go test -race -v -count=1 -tags testing,grocksdb_no_link
