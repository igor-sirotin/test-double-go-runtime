ARCH ?= x86_64

ifeq ($(ARCH), arm64)
	GO_ARCH=arm64
	CLANG_ARCH=arm64
else
	GO_ARCH=amd64
	CLANG_ARCH=x86_64
endif

GO_FLAGS := CGO_ENABLED=1 GOOS=darwin GOARCH=${GO_ARCH}

FOO := vendor/foo/build/libfoo.dylib
BAR := vendor/bar/build/libbar.dylib
STATUS_GO_LIBRARY := vendor/status-go/build/bin/libstatus.dylib
STATUS_KEYCARD_GO_LIBRARY := vendor/status-keycard-go/build/libkeycard/libkeycard.dylib

$(FOO): 
	mkdir -p vendor/foo/build
	cd vendor/foo && \
		$(GO_FLAGS) go build -buildmode=c-shared -o build/libfoo.dylib main.go

$(BAR):
	mkdir -p vendor/bar/build
	cd vendor/bar && \
		$(GO_FLAGS) go build -buildmode=c-shared -o build/libbar.dylib main.go

$(STATUS_GO_LIBRARY):
	$(MAKE) -C vendor/status-go statusgo-shared-library \
		SHELL=/bin/sh \
		GOBIN_SHARED_LIB_CFLAGS="${GO_FLAGS}" \
		CGO_CFLAGS="-O3"

$(STATUS_KEYCARD_GO_LIBRARY):
	$(MAKE) -C vendor/status-keycard-go build-lib \
		CGOFLAGS="${GO_FLAGS}" \
		CGO_CFLAGS="-O3"

statusgo: $(STATUS_GO_LIBRARY)
statuskeycardgo: $(STATUS_KEYCARD_GO_LIBRARY)
foo: $(FOO)
bar: $(BAR)

clean:
	rm -f build/app
	rm -rf vendorf/foo/build
	rm -rf vendorf/bar/build
	rm -rf vendor/status-go/build/bin
	rm -rf vendor/status-keycard-go/build/libkeycard

app: foo bar statusgo statuskeycardgo
	clang -arch ${CLANG_ARCH} -o build/app main.cpp \
		-Lvendor/status-go/build/bin -lstatus \
		-Lvendor/status-keycard-go/build/libkeycard -lkeycard \
		-Lvendor/foo/build -lfoo \
		-Lvendor/bar/build -lbar \
		-std=c++11 -lstdc++
	
run: app
	DYLD_LIBRARY_PATH=vendor/status-go/build/bin:vendor/status-keycard-go/build/libkeycard:vendor/foo/build:vendor/bar/build \
	./build/app
