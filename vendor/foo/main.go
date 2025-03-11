package main

// #cgo LDFLAGS: -shared
// #include <stdlib.h>
import "C"

import (
	"fmt"
	"runtime"
	"sync"
)

var initOnce sync.Once

//export InitializeFoo
func InitializeFoo() {
	initOnce.Do(func() {
		fmt.Println("👉 foo: Go runtime initialization starting")
		defer fmt.Println("✅ foo: Go runtime initialization complete")

		// Force a garbage collection to initialize GC state.
		runtime.GC()

		// Spawn a dummy goroutine and wait for it to finish.
		done := make(chan struct{})
		go func() {
			// Minimal work just to kick off the scheduler.
			close(done)
		}()
		<-done
	})
}

func main() {}
