GO_C_FLAGS := CGO_ENABLED=1 GOOS=darwin GOARCH=amd64
GO_MAKE_PARAMS += GOBIN_SHARED_LIB_CFLAGS="${GO_C_FLAGS}"
GO_MAKE_PARAMS += CGO_CFLAGS="-O3"

FOO := build/libfoo.dylib
BAR := build/libbar.dylib
STATUS_GO_LIBRARY := vendor/status-go/build/bin/libstatus.dylib
STATUS_KEYCARD_GO_LIBRARY := vendor/status-keycard-go/build/libkeycard/libkeycard.dylib

$(FOO):
	mkdir -p vendor/foo/build
	cd vendor/foo && \
	$(GO_C_FLAGS) go build -buildmode=c-shared -o build/libfoo.dylib main.go

$(BAR):
	mkdir -p vendor/bar/build
	cd vendor/bar && \
	$(GO_C_FLAGS) go build -buildmode=c-shared -o build/libbar.dylib main.go

$(STATUS_GO_LIBRARY):
	$(MAKE) -C vendor/status-go statusgo-shared-library SHELL=/bin/sh $(GO_MAKE_PARAMS)

$(STATUS_KEYCARD_GO_LIBRARY):
	$(MAKE) -C vendor/status-keycard-go build-lib

statusgo: $(STATUS_GO_LIBRARY)
statuskeycardgo: $(STATUS_KEYCARD_GO_LIBRARY)
foo: $(FOO)
bar: $(BAR)

clean:
	rm build/app
	rm -rf vendorf/foo/build
	rm -rf vendorf/bar/build
	$(MAKE) -C vendor/status-go clean SHELL=/bin/sh
	rm -rf vendor/status-keycard-go/build/libkeycard

app: foo bar statusgo statuskeycardgo
	clang -arch x86_64 -o build/app main.cpp \
		-Lvendor/status-go/build/bin -lstatus \
		-Lvendor/status-keycard-go/build/libkeycard -lkeycard \
		-Lvendor/foo/build -lfoo \
		-Lvendor/bar/build -lbar \
		-std=c++11
	
run: app
	DYLD_LIBRARY_PATH=vendor/status-go/build/bin:vendor/status-keycard-go/build/libkeycard:vendor/foo/build:vendor/bar/build \
	./build/app
