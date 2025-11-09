# Distribution via GitHub Releases

This guide covers how to distribute your iCloud Services Flatpak application through GitHub Releases, making it easy for users to download and install.

## Overview

**Advantages**:
- Simple setup - no server infrastructure needed
- Direct download links for users
- Automatic download statistics
- Release notes and version history
- Works with any GitHub repository
- Free hosting with generous bandwidth

**Disadvantages**:
- Users must manually download and install updates
- No automatic update notifications
- Larger file size (bundles include all dependencies)

## Prerequisites

1. **GitHub repository** at https://github.com/santisbon/icloud-flatpak
2. **Local builds** working correctly
3. **Screenshots** prepared and hosted (see [DISTRIBUTION-PREP.md](DISTRIBUTION-PREP.md))
4. **Release tag** created (e.g., v1.0.0)

## Step 1: Prepare Your Release

### 1.1 Create Release Tag

```bash
cd /home/armando/code/icloud-flatpak

# Ensure all changes are committed
git status

# Commit any pending changes
git add .
git commit -m "Prepare for v1.0.0 release"

# Create annotated tag
git tag -a v1.0.0 -m "iCloud Services v1.0.0

Initial stable release featuring:
- Support for all 11 iCloud web services
- Multi-architecture support (x86_64 and aarch64)
- Wayland and X11 compatibility
- Proper desktop integration with window grouping
- Individual persistent logins per service"

# Push commits and tags
git push origin main
git push origin v1.0.0
```

### 1.2 Update Metainfo Release Information

Ensure your `me.santisbon.iCloudServices.metainfo.xml` has current release info:

```xml
<releases>
  <release version="1.0.0" date="2025-11-09">
    <description>
      <p>Initial stable release</p>
      <ul>
        <li>Support for all 11 iCloud services (Mail, Drive, Calendar, Contacts, Photos, Notes, Reminders, Pages, Numbers, Keynote, Find My)</li>
        <li>Multi-architecture support: x86_64 (amd64) and aarch64 (arm64)</li>
        <li>Wayland compatibility with proper window grouping</li>
        <li>Individual persistent logins per service with passkey support</li>
        <li>Native desktop integration with proper icons and categories</li>
      </ul>
    </description>
  </release>
</releases>
```

## Step 2: Build Release Bundles

### 2.1 Build for x86_64 (amd64)

```bash
# Clean build for x86_64
flatpak-builder --arch=x86_64 --repo=repo --force-clean build-x86_64 me.santisbon.iCloudServices.yaml

# Create bundle
flatpak build-bundle repo icloud-services-x86_64.flatpak me.santisbon.iCloudServices \
  --arch=x86_64 \
  --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo

# Check bundle size
ls -lh icloud-services-x86_64.flatpak
```

### 2.2 Build for aarch64 (arm64)

```bash
# Install aarch64 runtime if not already installed
flatpak install --user flathub org.freedesktop.Platform/aarch64/25.08
flatpak install --user flathub org.freedesktop.Sdk/aarch64/25.08

# Build for aarch64
flatpak-builder --arch=aarch64 --repo=repo --force-clean build-aarch64 me.santisbon.iCloudServices.yaml

# Create bundle
flatpak build-bundle repo icloud-services-aarch64.flatpak me.santisbon.iCloudServices \
  --arch=aarch64 \
  --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo

# Check bundle size
ls -lh icloud-services-aarch64.flatpak
```

### 2.3 Verify Bundles

```bash
# List contents of x86_64 bundle
flatpak info --show-metadata icloud-services-x86_64.flatpak

# List contents of aarch64 bundle
flatpak info --show-metadata icloud-services-aarch64.flatpak

# Test installation (optional - use --user to avoid system-wide install)
flatpak install --user icloud-services-x86_64.flatpak
flatpak run me.santisbon.iCloudServices mail
flatpak uninstall --user me.santisbon.iCloudServices
```

## Step 3: Create GitHub Release

### 3.1 Via GitHub Web Interface (Recommended)

1. **Navigate to releases**:
   - Go to https://github.com/santisbon/icloud-flatpak/releases
   - Click "Draft a new release"

2. **Configure release**:
   - **Tag**: Select `v1.0.0` (or create new tag)
   - **Release title**: `iCloud Services v1.0.0`
   - **Description**: Use this template:

   ```markdown
   # iCloud Services v1.0.0

   Access all your iCloud web services natively on Linux with proper desktop integration.

   ## What's New

   - Support for all 11 iCloud services (Mail, Drive, Calendar, Contacts, Photos, Notes, Reminders, Pages, Numbers, Keynote, Find My)
   - Multi-architecture support: x86_64 (Intel/AMD) and aarch64 (ARM64/Apple Silicon via Asahi Linux)
   - Wayland compatibility with proper window grouping and icons
   - Individual persistent logins per service with passkey/Face ID support
   - Native desktop integration with proper application categories and icons

   ## Installation

   ### Prerequisites

   1. **Flatpak** must be installed:
      ```bash
      sudo apt install flatpak           # Debian/Ubuntu
      sudo dnf install flatpak           # Fedora
      ```

   2. **Flathub repository** (for dependencies):
      ```bash
      flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      ```

   3. **Chrome or Chromium** (required):
      ```bash
      flatpak install --user flathub org.chromium.Chromium
      # OR
      flatpak install --user flathub com.google.Chrome
      ```

   ### Install iCloud Services

   **For Intel/AMD (x86_64):**
   ```bash
   # Download the file below, then:
   flatpak install --user icloud-services-x86_64.flatpak
   ```

   **For ARM64/Apple Silicon (aarch64):**
   ```bash
   # Download the file below, then:
   flatpak install --user icloud-services-aarch64.flatpak
   ```

   ## Usage

   Launch from your application menu or command line:
   ```bash
   flatpak run me.santisbon.iCloudServices mail
   flatpak run me.santisbon.iCloudServices drive
   flatpak run me.santisbon.iCloudServices calendar
   # ... and 8 more services
   ```

   All services will appear in your application menu under "Internet" or "Office" categories.

   ## Notes

   - **First Launch**: You'll need to log in to iCloud for each service (authentication persists)
   - **Passkeys**: Face ID login works via passkey authentication
   - **Updates**: Check this page for new releases (no automatic updates)

   ## Supported Platforms

   - Debian/Ubuntu (x86_64, aarch64)
   - Fedora (x86_64, aarch64)
   - Arch Linux (x86_64, aarch64)
   - Asahi Linux (Apple Silicon - aarch64)
   - Any Linux distribution with Flatpak support

   ## Troubleshooting

   See the [README](https://github.com/santisbon/icloud-flatpak#troubleshooting) for common issues and solutions.

   ---

   **Disclaimer**: This is an unofficial third-party application not affiliated with Apple Inc. iCloud is a trademark of Apple Inc.
   ```

3. **Upload bundles**:
   - Drag and drop both `.flatpak` files:
     - `icloud-services-x86_64.flatpak`
     - `icloud-services-aarch64.flatpak`
   - Optionally add checksums file (see below)

4. **Publish**:
   - Check "Set as the latest release"
   - Click "Publish release"

### 3.2 Via GitHub CLI (Alternative)

```bash
# Install GitHub CLI if not already installed
# See: https://cli.github.com/

# Authenticate
gh auth login

# Create release with bundles
gh release create v1.0.0 \
  icloud-services-x86_64.flatpak \
  icloud-services-aarch64.flatpak \
  --title "iCloud Services v1.0.0" \
  --notes-file release-notes.md

# Or use inline notes
gh release create v1.0.0 \
  icloud-services-x86_64.flatpak \
  icloud-services-aarch64.flatpak \
  --title "iCloud Services v1.0.0" \
  --notes "Initial stable release with support for all 11 iCloud services..."
```

## Step 4: Add Checksums (Recommended)

Provide SHA256 checksums for security verification:

```bash
# Generate checksums
sha256sum icloud-services-x86_64.flatpak > SHA256SUMS
sha256sum icloud-services-aarch64.flatpak >> SHA256SUMS

# Display checksums
cat SHA256SUMS
```

Add checksums to release notes or upload `SHA256SUMS` file:

```bash
# Upload checksums file to existing release
gh release upload v1.0.0 SHA256SUMS
```

Users can verify downloads:
```bash
sha256sum -c SHA256SUMS
```

## Step 5: Update README

Add installation instructions to your README:

```markdown
## Installation

Download the latest release from [GitHub Releases](https://github.com/santisbon/icloud-flatpak/releases).

### Prerequisites

1. Install Flatpak:
   ```bash
   sudo apt install flatpak  # Debian/Ubuntu
   ```

2. Add Flathub repository:
   ```bash
   flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   ```

3. Install Chromium:
   ```bash
   flatpak install --user flathub org.chromium.Chromium
   ```

### Install iCloud Services

**For x86_64 (Intel/AMD):**
1. Download [icloud-services-x86_64.flatpak](https://github.com/santisbon/icloud-flatpak/releases/latest)
2. Install:
   ```bash
   flatpak install --user icloud-services-x86_64.flatpak
   ```

**For aarch64 (ARM64/Apple Silicon):**
1. Download [icloud-services-aarch64.flatpak](https://github.com/santisbon/icloud-flatpak/releases/latest)
2. Install:
   ```bash
   flatpak install --user icloud-services-aarch64.flatpak
   ```
```

## Step 6: Promote Your Release

### Social Media Announcement

Share your release on relevant platforms:

**Reddit**:
- r/linux
- r/flatpak
- r/linux_gaming (if relevant)
- r/AsahiLinux (for ARM support)

**Twitter/Mastodon**:
```
iCloud Services v1.0.0 is now available for Linux!

Access all your iCloud web services with native desktop integration:
Mail, Calendar, Drive, Photos, and more

Works on x86_64 and ARM64 (Asahi Linux)
Wayland + X11 support

Download: https://github.com/santisbon/icloud-flatpak/releases

#Linux #Flatpak #iCloud #OpenSource
```

### Update Project Links

Ensure your project links to the releases page:
- Update GitHub repository description
- Add "Latest Release" badge to README
- Link from personal website/portfolio

## Maintaining Releases

### Creating Updates

For version 1.1.0:

```bash
# Make your changes
git add .
git commit -m "Add new features for v1.1.0"

# Update metainfo.xml with new release entry
# Add <release version="1.1.0" date="YYYY-MM-DD"> above the 1.0.0 entry

# Create new tag
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin main
git push origin v1.1.0

# Rebuild bundles
flatpak-builder --arch=x86_64 --repo=repo --force-clean build-x86_64 me.santisbon.iCloudServices.yaml
flatpak build-bundle repo icloud-services-x86_64.flatpak me.santisbon.iCloudServices --arch=x86_64

flatpak-builder --arch=aarch64 --repo=repo --force-clean build-aarch64 me.santisbon.iCloudServices.yaml
flatpak build-bundle repo icloud-services-aarch64.flatpak me.santisbon.iCloudServices --arch=aarch64

# Create GitHub release
gh release create v1.1.0 \
  icloud-services-x86_64.flatpak \
  icloud-services-aarch64.flatpak \
  --title "iCloud Services v1.1.0" \
  --notes "What's new in v1.1.0..."
```

### Handling Bug Reports

When users report issues:

1. **Label GitHub issues** with version number
2. **Reproduce** with the specific release bundle
3. **Create patch release** if critical (v1.0.1)
4. **Update release notes** if workaround exists

## Advanced: Automatic Builds with GitHub Actions

Automate bundle creation on each release tag:

Create `.github/workflows/release.yml`:

```yaml
name: Create Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        arch: [x86_64, aarch64]

    steps:
    - uses: actions/checkout@v4

    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y flatpak flatpak-builder
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        flatpak install -y flathub org.freedesktop.Platform//${{ matrix.arch }}/25.08
        flatpak install -y flathub org.freedesktop.Sdk//${{ matrix.arch }}/25.08

    - name: Build Flatpak
      run: |
        flatpak-builder --arch=${{ matrix.arch }} --repo=repo --force-clean build-dir me.santisbon.iCloudServices.yaml
        flatpak build-bundle repo icloud-services-${{ matrix.arch }}.flatpak me.santisbon.iCloudServices --arch=${{ matrix.arch }}

    - name: Generate checksums
      run: sha256sum icloud-services-${{ matrix.arch }}.flatpak > icloud-services-${{ matrix.arch }}.flatpak.sha256

    - name: Upload artifacts
      uses: actions/upload-artifact@v4
      with:
        name: icloud-services-${{ matrix.arch }}
        path: |
          icloud-services-${{ matrix.arch }}.flatpak
          icloud-services-${{ matrix.arch }}.flatpak.sha256

  release:
    needs: build
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
    - uses: actions/checkout@v4

    - name: Download all artifacts
      uses: actions/download-artifact@v4

    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        files: |
          icloud-services-*/icloud-services-*.flatpak
          icloud-services-*/icloud-services-*.flatpak.sha256
        generate_release_notes: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Now releases are automatic:
```bash
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
# GitHub Actions automatically builds and creates release
```

## User Installation Guide

Create a simple guide for end users:

**INSTALL.md**:
```markdown
# How to Install iCloud Services

## Step 1: Install Prerequisites

### Install Flatpak
- **Ubuntu/Debian**: `sudo apt install flatpak`
- **Fedora**: `sudo dnf install flatpak`
- **Arch**: `sudo pacman -S flatpak`

### Add Flathub
```bash
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

### Install Chrome or Chromium
```bash
flatpak install --user flathub org.chromium.Chromium
```

## Step 2: Download iCloud Services

Visit: https://github.com/santisbon/icloud-flatpak/releases/latest

Download the file for your system:
- **Most PCs**: `icloud-services-x86_64.flatpak`
- **Apple Silicon (Asahi)**: `icloud-services-aarch64.flatpak`

## Step 3: Install

```bash
flatpak install --user ~/Downloads/icloud-services-*.flatpak
```

## Step 4: Launch

Find "iCloud" in your application menu, or run:
```bash
flatpak run me.santisbon.iCloudServices mail
```

## Uninstall

```bash
flatpak uninstall me.santisbon.iCloudServices
```
```

## Comparison with Other Distribution Methods

| Feature | GitHub Releases | Self-Hosted Repo | Flathub |
|---------|----------------|------------------|---------|
| Setup Complexity | Low | Medium | High |
| User Updates | Manual | Automatic | Automatic |
| Hosting Cost | Free | $5-10/month | Free |
| Approval Process | None | None | Required |
| Download Stats | Yes | No (unless custom) | Yes |
| Bandwidth | Generous | Limited by plan | Unlimited |
| Update Speed | Instant | Instant | Review required |

## Next Steps

- Create your first release following this guide
- Write clear installation instructions
- Set up issue templates for bug reports
- Monitor download statistics
- Plan update schedule

For self-hosted repository distribution, see [SELF-HOSTED-REPO.md](SELF-HOSTED-REPO.md).
