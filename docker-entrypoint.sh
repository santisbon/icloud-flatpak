#!/bin/bash
set -e

ARCH=${FLATPAK_ARCH:-x86_64}

echo "Building for architecture: $ARCH"

# Build the Flatpak
flatpak-builder --arch=$ARCH --repo=/output/repo --force-clean /build/build-dir /build/me.santisbon.iCloudServices.json

# Create bundle if requested
if [ "$CREATE_BUNDLE" = "true" ]; then
    flatpak build-bundle /output/repo /output/icloud-services-${ARCH}.flatpak me.santisbon.iCloudServices --arch=$ARCH
    echo "Bundle created: /output/icloud-services-${ARCH}.flatpak"
fi

echo "Build completed for $ARCH"
