#include "vendor/status-go/build/bin/libstatus.h"
#include "vendor/status-keycard-go/build/libkeycard/libkeycard.h"
#include "vendor/foo/build/libfoo.h"
#include "vendor/bar/build/libbar.h"

#include <unistd.h>
#include <string>
#include <cstdlib>
#include <iostream>

void printArch();
void delay();

int main() {
    printArch();

    InitializeStatusGo();
    // InitializeFoo();
    
    delay();
    
    InitializeStatusKeycardGo();
    // InitializeBar();

    return 0;
}

void printArch() {
    const char* archEnv = std::getenv("ARCH");
    if (archEnv == nullptr) {
        std::cout << "😕 ARCH not set" << std::endl;
    } else {
        std::cout << "🚀 ARCH: " << archEnv << std::endl;
    }
}

void delay() {
    const char* delayEnv = std::getenv("DELAY");
    if (delayEnv == nullptr) {
        return;
    }
    const auto delay = std::stoi(delayEnv);
    if (delay <= 0) {
        return;
    }
    std::cout << "Delaying for " << delay << "ms" << std::endl;
    usleep(delay * 1000);
}
