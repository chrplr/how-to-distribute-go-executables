Hello Go
--------

[Go](https://go.dev) makes cross-compiling very easy (provided one sticks to pure-go and avoids CGO).

To compile for Windows, Linux and Mac (amd64 architecture), the following `main.go` file:


```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, 世界")
}
```

One only has to run the bash commands:

```bash
for GOOS in windows darwin linux
do
    go build -o main-$GOOS main.go
done
```

---

Packaging Go binaries to distribute to end-users on various platforms is not completely trivial is not trivial however. 


This document describes a possible approach.

The current project contains two simple "Hello World" applications:

```
cmd/
├── hello-world-cli/   # command-line application
└── hello-world-gui/   # graphical application (Gio)
```

Graphical applications often require assets (graphic or sound files, fonts,...) and are more tricky to distribute.


## Prerequisites to build

- [Go](https://go.dev/dl/) 1.25 or later
- `make`
- `curl` (used by `make fonts` to download the embedded CJK font)

On Linux, building the GUI natively also requires X11/Wayland/Vulkan development headers:

```bash
sudo apt install libwayland-dev libxkbcommon-dev libxkbcommon-x11-dev \
                 libx11-xcb-dev libxcursor-dev libxfixes-dev libegl-dev libvulkan-dev
```

## Command-line application

The CLI prints "Hello, 世界" to the terminal and exits.

```bash
make cli
./bin/hello-world-cli
```

## Graphical application


The GUI opens a window displaying "Hello, 世界" using the [Gio](https://gioui.org/) toolkit.
The [Noto Sans SC](https://fonts.google.com/noto/specimen/Noto+Sans+SC) font (OFL license)
is embedded in the binary to ensure correct rendering of Chinese characters on all platforms.

```bash
make gui
./bin/hello-world-gui
```

## Building with Make

A `Makefile` is provided to build the project. All outputs go into `bin/`.

| Target | Description |
|---|---|
| `make` or `make all` | Build CLI and GUI for the current platform → `bin/` |
| `make cli` | Build the CLI only → `bin/hello-world-cli` |
| `make gui` | Build the GUI only → `bin/hello-world-gui` |
| `make fonts` | Download the embedded Noto Sans SC font (~17 MB, OFL license) |
| `make web` | Compile the GUI to WebAssembly and assemble the web bundle → `bin/web/` |
| `make serve` | Build the web bundle and start a local HTTP server on port 8080 |
| `make build-multiplatform` | Cross-compile both apps for all supported OS/arch combinations → `bin/multiplatform/` |
| `make clean` | Remove the entire `bin/` directory |
| `make help` | List all available targets |

### Cross-compilation notes

The CLI is pure Go (`CGO_ENABLED=0`) and cross-compiles to all targets without
any extra tooling. The GUI uses [Gio](https://gioui.org/), whose rendering
backend varies by OS:

| Target | Supported | Notes |
|---|---|---|
| `linux/amd64` | yes | native build |
| `linux/arm64` | if available | requires `gcc-aarch64-linux-gnu` (`apt install gcc-aarch64-linux-gnu`) |
| `windows/amd64`, `windows/arm64` | yes | D3D11 backend is pure Go |
| `darwin/arm64` | yes | Metal backend, native build on Apple Silicon |
| `js/wasm` | yes | WebGL backend, no CGO needed |


## Creating the binaries with GitHub Actions

If your project is linked to a remote repository on GitHub, you can compile and package your
software on GitHub's machines. The result appears in the *Releases* section of your project page.

Check out the [release.yml](.github/workflows/release.yml) file for this very project.
It follows the [Releases Naming Conventions](Releases-Naming-Conventions.md) described in this repo.


## Installing and running the binaries

### Linux

Should just work.

### Windows

On first use, Microsoft Defender may warn you that the program is dangerous, but you can
click on "More info" and start it anyway.

### macOS

At first start, your application will be blocked with a more or less scary message from your Mac.
This is because macOS includes a security system called Gatekeeper that checks whether an
application has been reviewed and digitally signed by Apple.
It is not the case for applications distributed here, as signing requires an Apple Developer account.

See [macOS installation and security](https://chrplr.github.io/note-about-macos-unsigned-apps) to address the issue.


## Running the GUI in a browser (WebAssembly)

The graphical version (`cmd/hello-world-gui`) is built with [Gio](https://gioui.org/)
which supports WebAssembly via WebGL. You can run it in any modern browser with
two commands.

**1. Build the WebAssembly bundle**

```bash
make web
```

This compiles the GUI to WebAssembly and assembles everything into `bin/web/`:

```
bin/web/
├── hello-world-gui.wasm   # compiled application
├── wasm_exec.js           # Go runtime glue (copied from your Go toolchain)
└── index.html             # loader page
```

**2. Start a local HTTP server**

```bash
make serve
```

This runs `python3 -m http.server 8080` inside `bin/web/`.

> **Why HTTP?** Browsers block `fetch()` on `file://` URLs, so WebAssembly
> cannot be loaded by opening `index.html` directly from disk.

**3. Open the page**

Navigate to <http://localhost:8080> in your browser. The Gio window will render
inside the page and display "Hello, 世界".

Press `Ctrl+C` in the terminal to stop the server.
