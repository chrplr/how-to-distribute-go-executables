MODULE := github.com/chrplr/hello-go
CLI    := hello-world-cli
GUI    := hello-world-gui

# Build tags for the GUI on Linux hosts missing Vulkan/X11 dev headers.
# Remove these if your system has libvulkan-dev and libxkbcommon-x11-dev.
GUI_TAGS_LINUX := nox11 novulkan

# Noto Sans SC — OFL-licensed variable font with full CJK coverage (~17 MB).
NOTO_URL  := https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf
NOTO_FONT := cmd/$(GUI)/fonts/NotoSansSC.ttf

.PHONY: all cli gui fonts clean web serve build-multiplatform build-multiplatform-cli build-multiplatform-gui help

help:
	@echo "Targets:"
	@echo "  all                    Build CLI and GUI for the current platform (default)"
	@echo "  cli                    Build the CLI  -> bin/hello-world-cli"
	@echo "  gui                    Build the GUI  -> bin/hello-world-gui (requires fonts)"
	@echo "  fonts                  Download embedded fonts (Noto Sans SC, ~17 MB)"
	@echo "  web                    Compile GUI to WebAssembly -> bin/web/"
	@echo "  serve                  Build web bundle and serve it on http://localhost:8080"
	@echo "  build-multiplatform    Cross-compile both apps for all supported targets -> bin/multiplatform/"
	@echo "  clean                  Remove bin/"
	@echo "  help                   Show this message"

all: cli gui

cli:
	go build -o bin/$(CLI) ./cmd/$(CLI)

# Download the Noto Sans SC font if not already present.
fonts: $(NOTO_FONT)
$(NOTO_FONT):
	@mkdir -p cmd/$(GUI)/fonts
	curl -L -o $(NOTO_FONT) "$(NOTO_URL)"

gui: $(NOTO_FONT)
	go build -tags "$(GUI_TAGS_LINUX)" -o bin/$(GUI) ./cmd/$(GUI)

clean:
	rm -rf bin/

# Build the wasm bundle and copy all assets into bin/web/, ready to serve.
# wasm_exec.js is taken from the active Go toolchain (go env GOROOT).
web:
	@mkdir -p bin/web
	GOOS=js GOARCH=wasm CGO_ENABLED=0 \
		go build -o bin/web/hello-world-gui.wasm ./cmd/$(GUI)
	cp "$(shell go env GOROOT)/lib/wasm/wasm_exec.js" bin/web/
	cp web/index.html bin/web/
	@echo "Web bundle ready in bin/web/ — run 'make serve' to preview."

# Serve bin/web/ on http://localhost:8080
# WebAssembly requires HTTP (not file://) due to browser security restrictions.
serve: web
	cd bin/web && python3 -m http.server 8080

# ---------------------------------------------------------------------------
# Multi-platform cross-compilation
#
# CLI  (pure Go, CGO_ENABLED=0): all OS/arch combinations work out of the box.
#
# GUI  (Gio rendering backends differ by OS):
#   linux   – OpenGL via CGO  → native amd64 build; arm64 needs aarch64-linux-gnu-gcc
#   windows – D3D11 pure-Go   → CGO_ENABLED=0 works for both amd64 and arm64
#   darwin  – Metal via CGO+ObjC → requires osxcross; skipped here
#   js/wasm – WebGL via syscall/js → CGO_ENABLED=0 works
#   wasip1  – no GL support in Gio → GUI not available
# ---------------------------------------------------------------------------

build-multiplatform: build-multiplatform-cli build-multiplatform-gui

build-multiplatform-cli:
	@mkdir -p bin/multiplatform
	@for platform in \
		linux/amd64 linux/arm64 \
		darwin/amd64 darwin/arm64 \
		windows/amd64 windows/arm64 \
		wasip1/wasm; do \
		os=$$(echo $$platform | cut -d/ -f1); \
		arch=$$(echo $$platform | cut -d/ -f2); \
		ext=""; \
		[ "$$os" = "windows" ] && ext=".exe"; \
		[ "$$os" = "wasip1" ] && ext=".wasm"; \
		echo "  CLI  $$os/$$arch..."; \
		GOOS=$$os GOARCH=$$arch CGO_ENABLED=0 \
			go build -o bin/multiplatform/$(CLI)-$$os-$$arch$$ext ./cmd/$(CLI) || exit 1; \
	done

build-multiplatform-gui:
	@mkdir -p bin/multiplatform

	@# linux/amd64 — native CGO build
	@echo "  GUI  linux/amd64..."
	@GOOS=linux GOARCH=amd64 \
		go build -tags "$(GUI_TAGS_LINUX)" \
		-o bin/multiplatform/$(GUI)-linux-amd64 ./cmd/$(GUI)

	@# linux/arm64 — CGO cross-compiler required
	@if command -v aarch64-linux-gnu-gcc >/dev/null 2>&1; then \
		echo "  GUI  linux/arm64..."; \
		CC=aarch64-linux-gnu-gcc GOOS=linux GOARCH=arm64 CGO_ENABLED=1 \
			go build -tags "$(GUI_TAGS_LINUX)" \
			-o bin/multiplatform/$(GUI)-linux-arm64 ./cmd/$(GUI); \
	else \
		echo "  GUI  linux/arm64... SKIPPED (install gcc-aarch64-linux-gnu)"; \
	fi

	@# windows — D3D11 backend is pure Go, no CGO needed
	@echo "  GUI  windows/amd64..."
	@GOOS=windows GOARCH=amd64 CGO_ENABLED=0 \
		go build -o bin/multiplatform/$(GUI)-windows-amd64.exe ./cmd/$(GUI)

	@echo "  GUI  windows/arm64..."
	@GOOS=windows GOARCH=arm64 CGO_ENABLED=0 \
		go build -o bin/multiplatform/$(GUI)-windows-arm64.exe ./cmd/$(GUI)

	@# darwin — Metal backend requires CGO + osxcross; skipped
	@echo "  GUI  darwin/amd64... SKIPPED (Metal backend requires osxcross)"
	@echo "  GUI  darwin/arm64... SKIPPED (Metal backend requires osxcross)"

	@# js/wasm — WebGL backend, no CGO needed
	@echo "  GUI  js/wasm..."
	@GOOS=js GOARCH=wasm CGO_ENABLED=0 \
		go build -o bin/multiplatform/$(GUI)-js.wasm ./cmd/$(GUI)
