Hello Go
--------

[Go](https://go.dev) makes cross-compiling very easy (provided one sticks to pure-go and avoids CGO).

To compile for Windows, Linux and Mac (x86_64 architecture) the following `main.go` file:


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

## Contents

**The distribution problem.** Compiling a Go binary is easy; getting it onto other people's
machines in a form they can double-click is not — GUI apps need icons, fonts, and OS-specific
installers, and unsigned apps trip security warnings. This repo shows one end-to-end approach,
driven entirely by a tagged Git push.

- [Using the installers released by GitHub](#using-the-installers-released-by-github) — AppImage / `.deb`, Windows setup, macOS `.app`
- [Installing the raw binaries released by GitHub](#installing-the-raw-binaries-released-by-github)
- [Running the GUI in a browser (WebAssembly)](#running-the-gui-in-a-browser-webassembly)
- [Building with Make](#building-with-make) — targets, GUI prerequisites, build support matrix

The three files that do the real work: the [Makefile](Makefile) (local builds),
[.github/workflows/release.yml](.github/workflows/release.yml) (CI build + packaging + publish),
and [Releases-Naming-Conventions.md](Releases-Naming-Conventions.md) (artifact-naming rules).

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

Only Apple Silicon (arm64) builds are published. To support Intel Macs you would add a
`darwin/amd64` target to the release workflow.

> [!WARNING]
> macOS Gatekeeper will block the app on first launch because it is not signed with an Apple
> Developer certificate. See
> [macOS installation and security](https://chrplr.github.io/note-about-macos-unsigned-apps)
> to bypass this.

---

### Installing the raw binaries released by GitHub

Raw binary archives embed the version number in their filename (e.g.
`hello-world-gui-vX.Y.Z-linux-x86_64.tar.gz`), so — unlike the stable-name installers above —
their download URLs change with every release. Rather than hard-code a version here, browse the
[**Releases page**](https://github.com/chrplr/how-to-distribute-go-executables/releases) and pick
the archive for your platform:

| Platform | GUI archive | CLI archive |
|---|---|---|
| Linux x86_64 | `hello-world-gui-vX.Y.Z-linux-x86_64.tar.gz` | `hello-world-cli-vX.Y.Z-linux-x86_64.tar.gz` |
| Windows x86_64 | `hello-world-gui-vX.Y.Z-windows-x86_64.zip` | `hello-world-cli-vX.Y.Z-windows-x86_64.zip` |
| macOS arm64 | `hello-world-gui-vX.Y.Z-macos-arm64.tar.gz` | `hello-world-cli-vX.Y.Z-macos-arm64.tar.gz` |

- **Linux**: untar the archive and run the binary (`./hello-world-cli`, or `./hello-world-gui`).
- **Windows**: unzip and run the `.exe`. Microsoft Defender may show a "Windows protected your
  PC" warning — click **More info** → **Run anyway**.
- **macOS**: untar and run. Gatekeeper will block the unsigned app on first launch; see
  [macOS installation and security](https://chrplr.github.io/note-about-macos-unsigned-apps).

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
* `python3` (only for `make serve`, which starts a local web server for the WebAssembly build)

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



### Build support matrix

The CLI is pure Go (`CGO_ENABLED=0`) and cross-compiles to all targets without
any extra tooling. The GUI uses [Gio](https://gioui.org/), whose rendering
backend varies by OS (some rows below are native builds rather than cross-compiles):

| Target | Supported | Notes |
|---|---|---|
| `linux/amd64` | yes | native build |
| `linux/arm64` | if available | requires `gcc-aarch64-linux-gnu` (`apt install gcc-aarch64-linux-gnu`) |
| `windows/amd64`, `windows/arm64` | yes | D3D11 backend is pure Go |
| `darwin/arm64` | yes | Metal backend, native build on Apple Silicon |
| `js/wasm` | yes | WebGL backend, no CGO needed |

---

Author: Christophe Pallier

Date: 2026/03/22

## License

This project is dual-licensed so the build recipes are free to reuse:

- **Documentation and prose** (this README and the naming-conventions guide):
  CC BY-SA — see [LICENSE.txt](LICENSE.txt).
- **Build recipes and code** (the `Makefile`, `.github/workflows/`, `packaging/`, and the Go
  sources under `cmd/`): MIT — see [LICENSE-CODE.txt](LICENSE-CODE.txt) — so you can copy them
  into your own projects without the ShareAlike obligation.
