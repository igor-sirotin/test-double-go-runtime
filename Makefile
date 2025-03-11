GO_MAKE_PARAMS += GOBIN_SHARED_LIB_CFLAGS="CGO_ENABLED=1 GOOS=darwin GOARCH=amd64"
GO_MAKE_PARAMS += CGO_CFLAGS="-O3"

STATUS_GO_LIBRARY := vendor/status-go/build/bin/libstatus.dylib
STATUS_KEYCARD_GO_LIBRARY := vendor/status-keycard-go/build/libkeycard/libkeycard.dylib

$(STATUS_GO_LIBRARY):
	$(MAKE) -C vendor/status-go statusgo-shared-library SHELL=/bin/sh $(GO_MAKE_PARAMS)

$(STATUS_KEYCARD_GO_LIBRARY):
	$(MAKE) -C vendor/status-keycard-go build-lib

statusgo: $(STATUS_GO_LIBRARY)
statuskeycardgo: $(STATUS_KEYCARD_GO_LIBRARY)

clean:
	rm build/app
	rm -rf library-1/build
	rm -rf library-2/build
	$(MAKE) -C vendor/status-go clean SHELL=/bin/sh
	rm -rf status-keycard-go/build/libkeycard

app: statusgo statuskeycardgo
	clang -arch x86_64 -o build/app main.cpp \
		-Lvendor/status-go/build/bin -lstatus \
		-Lvendor/status-keycard-go/build/libkeycard -lkeycard \
		-std=c++11
	
run: app
	DYLD_LIBRARY_PATH=vendor/status-go/build/bin:vendor/status-keycard-go/build/libkeycard ./build/app
