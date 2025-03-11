#include "vendor/status-go/build/bin/libstatus.h"
#include "vendor/status-keycard-go/build/libkeycard/libkeycard.h"
#include "vendor/foo/build/libfoo.h"
#include "vendor/bar/build/libbar.h"

int main() {
    // InitializeStatusGo();
    // InitializeStatusKeycardGo();
    InitializeFoo();
    InitializeBar();
    return 0;
}
