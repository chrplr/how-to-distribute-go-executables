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

Yet, packaging Go binaries to distribute to end-users on various platforms is not always easy. In particular, Graphical applications often require assets (graphic or sound files, fonts,...) and are more tricky to distribute.


This document describes a possible approach.

The current project features two simple "Hello World" applications:

```
cmd/
├── hello-world-cli/   # command-line application
└── hello-world-gui/   # graphical application (Gio)
```


The CLI prints "Hello, 世界" to the terminal and exits. The GUI opens a window displaying "Hello, 世界".

If you just want to try the apps, grab an installer from the [GitHub releases](#building-executables-and-installers-with-github-actions) below. If you want to build from source, see [Building with Make](#building-with-make).

## Building executables and installers with GitHub Actions

If your project is linked to a remote repository on GitHub, **you can compile and package your
software on GitHub's machines.** The result appears in the *Releases* section of your project page.

Check out the [release.yml](.github/workflows/release.yml) file for this very project.
It follows the [Releases Naming Conventions](Releases-Naming-Conventions.md) described in this repo.


### Using the installers released by GitHub

Installers use **stable filenames** (no version number), so these links always point to the
latest release and never need updating.

#### Linux (x86_64)

Download the AppImage — a self-contained executable that runs on any modern Linux distribution
without installation:

```bash
curl -LO https://github.com/chrplr/how-to-distribute-go-executables/releases/latest/download/hello-world-gui-linux-x86_64.AppImage
chmod +x hello-world-gui-linux-x86_64.AppImage
./hello-world-gui-linux-x86_64.AppImage
```

Or install the Debian/Ubuntu package:

```bash
curl -LO https://github.com/chrplr/how-to-distribute-go-executables/releases/latest/download/hello-world-gui-linux-x86_64.deb
sudo dpkg -i hello-world-gui-linux-x86_64.deb
hello-world-gui
```

#### Windows (x86_64)

Download and run
[hello-world-gui-windows-x86_64-setup.exe](https://github.com/chrplr/how-to-distribute-go-executables/releases/latest/download/hello-world-gui-windows-x86_64-setup.exe).
The installer places the app in `Program Files`, creates a desktop shortcut, and registers an
uninstaller in "Add or Remove Programs".

On first use, Microsoft Defender may show a "Windows protected your PC" warning.
Click **More info** → **Run anyway** to proceed.

#### macOS (M1, M2, M3, M4 — Apple Silicon)

Download
[hello-world-gui-macos-arm64-app.zip](https://github.com/chrplr/how-to-distribute-go-executables/releases/latest/download/hello-world-gui-macos-arm64-app.zip),
unzip it, and drag **Hello World GUI.app** to your Applications folder.

> [!WARNING]
> macOS Gatekeeper will block the app on first launch because it is not signed with an Apple
> Developer certificate. See
> [macOS installation and security](https://chrplr.github.io/note-about-macos-unsigned-apps)
> to bypass this.

---

### Installing the raw binaries released by GitHub

The releases are at <https://github.com/chrplr/how-to-distribute-go-executables/releases>.
Raw archives include the version number in their filename.

#### Linux (x86_64)

**GUI**: Download [hello-world-gui-v0.1.2-linux-x86_64.tar.gz](https://github.com/chrplr/how-to-distribute-go-executables/releases/download/v0.1.2/hello-world-gui-v0.1.2-linux-x86_64.tar.gz),
untar it, and run the binary.

**CLI**: Download [hello-world-cli-v0.1.2-linux-x86_64.tar.gz](https://github.com/chrplr/how-to-distribute-go-executables/releases/download/v0.1.2/hello-world-cli-v0.1.2-linux-x86_64.tar.gz),
open a terminal in the folder, and run `./hello-world-cli`.

#### Windows (x86_64)

**GUI**: [hello-world-gui-v0.1.2-windows-x86_64.zip](https://github.com/chrplr/how-to-distribute-go-executables/releases/download/v0.1.2/hello-world-gui-v0.1.2-windows-x86_64.zip)

**CLI**: [hello-world-cli-v0.1.2-windows-x86_64.zip](https://github.com/chrplr/how-to-distribute-go-executables/releases/download/v0.1.2/hello-world-cli-v0.1.2-windows-x86_64.zip)

On first use, Microsoft Defender may show a "Windows protected your PC" warning.
Click **More info** → **Run anyway** to proceed.

#### macOS (M1, M2, ...)

**GUI**: [hello-world-gui-v0.1.2-macos-arm64.tar.gz](https://github.com/chrplr/how-to-distribute-go-executables/releases/download/v0.1.2/hello-world-gui-v0.1.2-macos-arm64.tar.gz)

**CLI**: [hello-world-cli-v0.1.2-macos-arm64.tar.gz](https://github.com/chrplr/how-to-distribute-go-executables/releases/download/v0.1.2/hello-world-cli-v0.1.2-macos-arm64.tar.gz)

At first start your application will be blocked by macOS Gatekeeper, because it is not signed
with an Apple Developer certificate. See
[macOS installation and security](https://chrplr.github.io/note-about-macos-unsigned-apps)
to address this.

---

### Running the GUI in a browser (WebAssembly)

The GitHub release also includes a WebAssembly bundle (`hello-world-gui-*-web.zip`) that runs
the GUI directly in any modern browser via WebGL — no installation needed.

To build and run it locally:

**1. Build the bundle**

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


## Building with Make

*Prerequisites*:

* [Go](https://go.dev/dl/) 1.25 or later
* `make`
* `curl` (used by `make fonts` to download the embedded CJK font)

To compile the apps on your computer, a [Makefile](Makefile) is provided to build the project. All outputs go into `bin/`.

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



### Command-line application

```bash
make cli
./bin/hello-world-cli
```

### Graphical application

Compiling the GUI app requires to download the [Noto Sans SC](https://fonts.google.com/noto/specimen/Noto+Sans+SC) font (OFL license)
This font will be embedded in the binary to ensure correct rendering of Chinese characters on all platforms.

```bash
make gui
./bin/hello-world-gui
```

(Note: On Linux, building the GUI natively also requires X11/Wayland/Vulkan development headers:

```bash
sudo apt install libwayland-dev libxkbcommon-dev libxkbcommon-x11-dev \
                 libx11-xcb-dev libxcursor-dev libxfixes-dev libegl-dev libvulkan-dev
```
)



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


