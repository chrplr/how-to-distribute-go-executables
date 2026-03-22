Hello Go
--------

[Go](https://go.dev) makes cross-compiling very easy, if one sticks to pure-go and command-line (cli) applications. 


Thus, given a source file `main.go` such as:

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, 世界")
}
```

You can compile it for Windows, Linux and Mac (amd64 achitecture):

```bash
GOARCH=amd64
for GOOS in windows darwin linux
do
    go build -o main-$OS main.go
done
```

---

Yes packaging Go binaries to distribute to end-users on various platforms is not completely trivial. The currents document describes a possible approach.

It contains two simple "Hello World"" applicatons, one cli and one gui (relying on [gio](https://gioui.org/))

## Building with Make

A `Makefile` is provided to build the project. All outputs go into `bin/`.

| Target | Description |
|---|---|
| `make` or `make all` | Build CLI and GUI for the current platform → `bin/` |
| `make cli` | Build the CLI only → `bin/hello-world-cli` |
| `make gui` | Build the GUI only → `bin/hello-world-gui` |
| `make web` | Compile the GUI to WebAssembly and assemble the web bundle → `bin/web/` |
| `make serve` | Build the web bundle and start a local HTTP server on port 8080 |
| `make build-multiplatform` | Cross-compile both apps for all supported OS/arch combinations → `bin/multiplatform/` |
| `make clean` | Remove the entire `bin/` directory |

### Cross-compilation notes

The CLI is pure Go (`CGO_ENABLED=0`) and cross-compiles to all targets without
any extra tooling. The GUI uses [Gio](https://gioui.org/), whose rendering
backend varies by OS:

| Target | Supported | Notes |
|---|---|---|
| `linux/amd64` | yes | native build |
| `linux/arm64` | if available | requires `gcc-aarch64-linux-gnu` (`apt install gcc-aarch64-linux-gnu`) |
| `windows/amd64`, `windows/arm64` | yes | D3D11 backend is pure Go |
| `darwin/amd64`, `darwin/arm64` | skipped | Metal backend requires [osxcross](https://github.com/tpoechtrager/osxcross) |
| `js/wasm` | yes | WebGL backend, no CGO needed |


## Creating the binaries with Github Actions

If your project is linked to remote repository on github, you can compile and package your software on Github's machine. It appear in the *Releases* section of yourselves github project's page.

Check out the [release.yml](.github/worflows/release.yml) file for this very project.

It follows my [] (Releases-Naming-Conventions.md)



## Installing and running the binaries

### Linux

Should just work.

### Windows

On first use, Microsoft Defender may warn you to the program is dangerous, by you can just click on more info and start it anyway.

### MacOS

At first start, your application will  block with a more or less scary message from you Mac.
This is because macOS includes a security system called Gatekeeper that checks whether an application has been reviewed and digitally signed by Apple. 
It is not the case of my applications as I am am not an Apple Developer.

Send your users to  https://chrplr.github.io/note-about-macos-unsigned-apps to address the issue.







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

