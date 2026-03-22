Hello Go
--------

[Go](https://go.dev) makes cross-compiling very easy, if one sticks to pure-go and command-line (cli) applications. Here is an example :

```bash
export CGO_ENABLED=0  # enforce pure-go

for PLATFORM in "windows/amd64" "windows/arm64" "linux/amd64" "linux/arm64" "darwin/amd64" "darwin/arm64"; do

    # Split the platform string into OS and ARCH
    IFS="/" read -r -a ARRAY <<< "$PLATFORM"
    GOOS=${ARRAY[0]}
    GOARCH=${ARRAY[1]}
    
    # Set the output filename (adding .exe for windows)
    OUTPUT_NAME="${APP_NAME}-${GOOS}-${GOARCH}"
    if [ "$GOOS" = "windows" ]; then
        OUTPUT_NAME+='.exe'
    fi

    export GOOS=$GOOS
    export GOARCH=$GOARCH

    go build -o "bin/$OUTPUT_NAME" main.go

done

```

But packaging Go binaries for end-users on various platforms is not trivial.

This repository outlines a possible approach.

It contains a cli and a gui application in `cmd/'

# command-line application

# graphical application


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

