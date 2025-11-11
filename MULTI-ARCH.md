# Multi-Architecture Builds

This guide covers building the iCloud Services Flatpak for multiple architectures (amd64/x86_64 and arm64/aarch64) using Docker and QEMU emulation.

## Overview

Flatpak supports multiple architectures, and Flathub requires apps to be available for:
- **x86_64** (amd64) - Standard desktop/laptop processors
- **aarch64** (arm64) - ARM processors (Raspberry Pi, Apple Silicon via Asahi Linux, etc.)

## Prerequisites

### Install Required Tools

1. **Docker:**
   ```bash
   # Debian/Ubuntu
   sudo apt install docker.io
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -aG docker $USER
   # Log out and back in for group changes
   ```

2. **QEMU for cross-architecture emulation:**
   ```bash
   # Debian/Ubuntu
   sudo apt install qemu-user-static binfmt-support

   # Fedora
   sudo dnf install qemu-user-static
   ```

3. **Enable multi-architecture Docker builds:**
   ```bash
   docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
   ```

## Method 1: Local Cross-Architecture Build (Recommended for Testing)

### Build for x86_64 (Native on amd64)

```bash
cd icloud-flatpak
flatpak-builder --force-clean --user --repo=repo build-dir --arch=x86_64 me.santisbon.iCloudServices.yaml
```

### Build for aarch64 (Cross-compile on amd64)

This requires the arm64 SDK and runtime:

```bash
# Install aarch64 platform
flatpak install --user flathub org.freedesktop.Platform/aarch64/25.08
flatpak install --user flathub org.freedesktop.Sdk/aarch64/25.08

# Build for aarch64
flatpak-builder --force-clean --user --repo=repo build-dir --arch=aarch64 me.santisbon.iCloudServices.yaml
```

**Note:** Cross-compilation can be slow due to QEMU emulation.

### Create Multi-Arch Bundle

```bash
# Build for both architectures
flatpak-builder --arch=x86_64 --repo=repo --force-clean build-x86_64 me.santisbon.iCloudServices.yaml
flatpak-builder --arch=aarch64 --repo=repo --force-clean build-aarch64 me.santisbon.iCloudServices.yaml

# Create bundles
flatpak build-bundle repo icloud-services-x86_64.flatpak me.santisbon.iCloudServices --arch=x86_64
flatpak build-bundle repo icloud-services-aarch64.flatpak me.santisbon.iCloudServices --arch=aarch64
```

## Method 2: Docker-Based Builds (Recommended for CI/CD)

This method uses Docker containers for isolated, reproducible builds.

### Create Dockerfile

Create a file named `Dockerfile.flatpak-builder`:

```dockerfile
ARG ARCH=amd64
FROM --platform=linux/${ARCH} fedora:39

# Install Flatpak build tools
RUN dnf install -y \
    flatpak \
    flatpak-builder \
    git \
    && dnf clean all

# Add Flathub repository
RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Freedesktop Platform and SDK
ARG FLATPAK_ARCH=x86_64
RUN flatpak install -y --system flathub org.freedesktop.Platform/${FLATPAK_ARCH}/25.08 \
    && flatpak install -y --system flathub org.freedesktop.Sdk/${FLATPAK_ARCH}/25.08

WORKDIR /build

# Set up entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
```

### Create Docker Entrypoint Script

Create `docker-entrypoint.sh`:

```bash
#!/bin/bash
set -e

ARCH=${FLATPAK_ARCH:-x86_64}

echo "Building for architecture: $ARCH"

# Build the Flatpak
flatpak-builder --arch=$ARCH --repo=/output/repo --force-clean /build/build-dir /build/me.santisbon.iCloudServices.yaml

# Create bundle if requested
if [ "$CREATE_BUNDLE" = "true" ]; then
    flatpak build-bundle /output/repo /output/icloud-services-${ARCH}.flatpak me.santisbon.iCloudServices --arch=$ARCH
    echo "Bundle created: /output/icloud-services-${ARCH}.flatpak"
fi

echo "Build completed for $ARCH"
```

### Build Docker Images

```bash
# Build for amd64
docker build \
  --build-arg ARCH=amd64 \
  --build-arg FLATPAK_ARCH=x86_64 \
  -t icloud-flatpak-builder:amd64 \
  -f Dockerfile.flatpak-builder \
  .

# Build for arm64
docker build \
  --build-arg ARCH=arm64 \
  --build-arg FLATPAK_ARCH=aarch64 \
  -t icloud-flatpak-builder:arm64 \
  -f Dockerfile.flatpak-builder \
  .
```

### Run Docker Builds

```bash
# Create output directory
mkdir -p output-{amd64,arm64}

# Build for amd64
docker run --rm \
  -v $(pwd):/build:ro \
  -v $(pwd)/output-amd64:/output \
  -e FLATPAK_ARCH=x86_64 \
  -e CREATE_BUNDLE=true \
  icloud-flatpak-builder:amd64

# Build for arm64
docker run --rm \
  -v $(pwd):/build:ro \
  -v $(pwd)/output-arm64:/output \
  -e FLATPAK_ARCH=aarch64 \
  -e CREATE_BUNDLE=true \
  icloud-flatpak-builder:arm64
```

The built Flatpak bundles will be in:
- `output-amd64/icloud-services-x86_64.flatpak`
- `output-arm64/icloud-services-aarch64.flatpak`

## Method 3: Docker Buildx (Multi-Platform Builds)

Docker Buildx allows building for multiple platforms simultaneously:

```bash
# Create a new builder instance
docker buildx create --name multiarch-builder --use
docker buildx inspect --bootstrap

# Build for both platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t icloud-flatpak-builder:latest \
  -f Dockerfile.flatpak-builder \
  --push \
  .
```

## Method 4: GitHub Actions CI/CD (Automated)

For automated builds on every commit/release, create `.github/workflows/build.yml`:

```yaml
name: Build Multi-Arch Flatpak

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  release:
    types: [ created ]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        arch: [x86_64, aarch64]
        include:
          - arch: x86_64
            docker_arch: amd64
          - arch: aarch64
            docker_arch: arm64

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up QEMU
      uses: docker/setup-qemu-action@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Install Flatpak
      run: |
        sudo apt-get update
        sudo apt-get install -y flatpak flatpak-builder
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        flatpak install -y flathub org.freedesktop.Platform//${{ matrix.arch }}/25.08
        flatpak install -y flathub org.freedesktop.Sdk//${{ matrix.arch }}/25.08

    - name: Build Flatpak
      run: |
        flatpak-builder --arch=${{ matrix.arch }} --repo=repo --force-clean build-dir me.santisbon.iCloudServices.yaml

    - name: Create Bundle
      run: |
        flatpak build-bundle repo icloud-services-${{ matrix.arch }}.flatpak me.santisbon.iCloudServices --arch=${{ matrix.arch }}

    - name: Upload Artifact
      uses: actions/upload-artifact@v4
      with:
        name: icloud-services-${{ matrix.arch }}
        path: icloud-services-${{ matrix.arch }}.flatpak

    - name: Upload Release Asset
      if: github.event_name == 'release'
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: ${{ github.event.release.upload_url }}
        asset_path: ./icloud-services-${{ matrix.arch }}.flatpak
        asset_name: icloud-services-${{ matrix.arch }}.flatpak
        asset_content_type: application/octet-stream
```

## Testing Multi-Arch Builds

### Test on Native Hardware

**x86_64:**
```bash
flatpak install icloud-services-x86_64.flatpak
flatpak run me.santisbon.iCloudServices mail
```

**aarch64:**
- Test on Raspberry Pi, ARM server, or Apple Silicon with Asahi Linux
```bash
flatpak install icloud-services-aarch64.flatpak
flatpak run me.santisbon.iCloudServices mail
```

### Test with QEMU Emulation

You can test ARM builds on x86_64 using QEMU (slow but functional):

```bash
# Register QEMU
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Install and test
flatpak install icloud-services-aarch64.flatpak
flatpak run --arch=aarch64 me.santisbon.iCloudServices mail
```

## Flathub Multi-Arch Builds

When you submit to Flathub, their buildbot automatically builds for all supported architectures:

1. **Submit your manifest** (as per FLATHUB.md)
2. **Buildbot builds for x86_64 and aarch64** automatically
3. **No extra configuration needed** - Flathub handles it

Your manifest doesn't need architecture-specific configurations unless you have architecture-specific dependencies.

## Troubleshooting

### QEMU Emulation is Slow

This is expected. Cross-architecture builds using QEMU can be 10-50x slower. Options:
- Use native hardware for testing (Raspberry Pi, etc.)
- Use cloud CI/CD with native ARM runners (GitHub Actions, GitLab CI)
- Be patient - it will complete eventually

### Architecture-Specific Dependencies

If you need different dependencies per architecture:

```json
{
  "modules": [
    {
      "name": "arch-specific-module",
      "only-arches": ["x86_64"],
      "sources": [...]
    },
    {
      "name": "arm-specific-module",
      "only-arches": ["aarch64"],
      "sources": [...]
    }
  ]
}
```

### Build Failures on ARM

Common issues:
- Missing ARM-compatible dependencies
- Timeout due to slow emulation - increase timeouts
- Platform-specific bugs - test on real hardware

## Performance Comparison

Typical build times (approximate):

| Method | x86_64 on amd64 | aarch64 on amd64 (QEMU) | aarch64 on native ARM |
|--------|-----------------|--------------------------|------------------------|
| Local | 2-5 min | 20-60 min | 2-5 min |
| Docker | 3-6 min | 25-70 min | 3-6 min |
| GitHub Actions | 3-7 min | 15-45 min | 3-7 min |

## Best Practices

1. **Develop and test on x86_64 first** - faster iteration
2. **Test ARM builds before releasing** - on real hardware if possible
3. **Use CI/CD for releases** - automated multi-arch builds
4. **Monitor build times** - optimize if builds take too long
5. **Document architecture requirements** - if any platform-specific features

## Additional Resources

- Flatpak Multi-Arch: https://docs.flatpak.org/en/latest/flatpak-builder-command-reference.html#flatpak-builder
- Docker Multi-Platform: https://docs.docker.com/build/building/multi-platform/
- QEMU User Emulation: https://wiki.debian.org/QemuUserEmulation
- GitHub Actions: https://docs.github.com/en/actions

## Summary

For most use cases:
- **Development**: Build locally for your native architecture
- **Testing**: Use Docker with QEMU for multi-arch testing
- **Production**: Use GitHub Actions or submit to Flathub (handles multi-arch automatically)

This simple shell script app doesn't have architecture-specific code, so multi-arch builds should work seamlessly!
