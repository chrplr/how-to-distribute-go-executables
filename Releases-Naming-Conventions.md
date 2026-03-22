# Release Asset Naming Conventions

These conventions apply to GitHub Actions workflows and README installation instructions for multi-platform Go projects.

---

## Principles

1. **Installer filenames are stable** (no version embedded) — enables permanent `/latest/download/` links in README files that never need updating.
2. **Raw binary archive filenames include the version** — users downloading from the Releases page can tell at a glance what they have.
3. **Architecture names are consistent**: always `x86_64` (not `amd64`), `arm64`, `aarch64` (Linux ARM 64-bit).
4. **OS names are consistent**: `linux`, `windows`, `macos`.
5. **Separators are always hyphens** (never underscores).
6. **macOS app bundles** use the `-app.zip` suffix to distinguish them from raw binary archives.

---

## Installer filenames (stable, no version)

| Platform | Filename pattern | Notes |
|---|---|---|
| Windows x86_64 | `{app}-windows-x86_64-setup.exe` | NSIS installer |
| Windows ARM64 | `{app}-windows-arm64-setup.exe` | NSIS installer |
| macOS ARM64 | `{app}-macos-arm64-app.zip` | `.app` bundle in zip |
| macOS x86_64 | `{app}-macos-x86_64-app.zip` | `.app` bundle in zip |
| Linux x86_64 | `{app}-linux-x86_64.AppImage` | |
| Linux aarch64 | `{app}-linux-aarch64.AppImage` | |
| Linux x86_64 | `{app}-linux-x86_64.deb` | Debian/Ubuntu package |

---

## Raw binary archive filenames (versioned)

| Platform | Filename pattern |
|---|---|
| Linux x86_64 | `{app}-v{VERSION}-linux-x86_64.tar.gz` |
| Linux arm64 | `{app}-v{VERSION}-linux-arm64.tar.gz` |
| macOS ARM64 | `{app}-v{VERSION}-macos-arm64.tar.gz` |
| macOS x86_64 | `{app}-v{VERSION}-macos-x86_64.tar.gz` |
| Windows x86_64 | `{app}-v{VERSION}-windows-x86_64.zip` |
| Windows ARM64 | `{app}-v{VERSION}-windows-arm64.zip` |

---

## GitHub Actions: arch mapping snippet

When a CI loop iterates over `amd64`/`arm64` (Go convention), map to the artifact arch before constructing filenames:

```bash
if [ "$ARCH" = "amd64" ]; then ARTIFACT_ARCH="x86_64"; else ARTIFACT_ARCH="arm64"; fi
```

For Linux AppImages where `aarch64` is needed:

```bash
if [ "$ARCH" = "amd64" ]; then APP_ARCH="x86_64"; else APP_ARCH="aarch64"; fi
```

---

## README direct-download links

Use GitHub's `/latest/download/` URL so links stay valid across releases:

```
https://github.com/{owner}/{repo}/releases/latest/download/{stable-installer-filename}
```

For raw binary archives (versioned filenames), link to the Releases page instead:

```
https://github.com/{owner}/{repo}/releases
```

---

## Example README installation section

```markdown
### Windows
Download [app-windows-x86_64-setup.exe](https://github.com/OWNER/REPO/releases/latest/download/app-windows-x86_64-setup.exe)
and run it.

### macOS
Download [app-macos-arm64-app.zip](https://github.com/OWNER/REPO/releases/latest/download/app-macos-arm64-app.zip)
(M1/M2/M3/M4) or [app-macos-x86_64-app.zip](https://github.com/OWNER/REPO/releases/latest/download/app-macos-x86_64-app.zip)
(Intel). Extract and drag the `.app` to your Applications folder.

> [!WARNING]
> macOS may show a security warning the first time you open the app.
> See [macOS installation and security](https://chrplr.github.io/note-about-macos-unsigned-apps).

### Linux
Download [app-linux-x86_64.AppImage](https://github.com/OWNER/REPO/releases/latest/download/app-linux-x86_64.AppImage).
Right-click → **Properties > Permissions** → check **"Allow executing file as program"**, then double-click to run.

### Raw binaries
Download a `.zip` or `.tar.gz` archive for your platform from the
[Releases page](https://github.com/OWNER/REPO/releases).
```
