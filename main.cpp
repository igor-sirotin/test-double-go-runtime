#include "vendor/status-go/build/bin/libstatus.h"
#include "vendor/status-keycard-go/build/libkeycard/libkeycard.h"

int main() {
    InitializeStatusGo();
    InitializeStatusKeycardGo();
    return 0;
}
