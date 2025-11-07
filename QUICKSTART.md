# Quick Start Guide

Get up and running with iCloud Services on Linux in just a few steps!

## Prerequisites (One-time Setup)

```bash
# Install Flatpak and tools
sudo apt install flatpak flatpak-builder  # Debian/Ubuntu
# OR
sudo dnf install flatpak flatpak-builder  # Fedora

# Add Flathub
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install required runtimes
flatpak install --user flathub org.freedesktop.Platform//25.08 org.freedesktop.Sdk//25.08

# Install Chromium (required for command-line builds)
# Note: App centers install this automatically
flatpak install --user flathub org.chromium.Chromium
```

## Step 1: Build and Install

```bash
cd icloud-flatpak

# Build and install in one command
flatpak-builder --user --install --force-clean build-dir me.santisbon.iCloudServices.yaml
```

Wait 2-5 minutes for the build to complete.

## Step 2: Launch!

**From the command line:**
```bash
flatpak run me.santisbon.iCloudServices mail
```

**From your desktop:**
- Open your application menu
- Search for "iCloud"
- Click any service (Mail, Drive, Calendar, etc.)

## That's It!

You now have iCloud service launchers on your Linux desktop. Each one opens in Chromium's app mode for a clean, native-like experience.

## Troubleshooting

**Icons not showing?**
```bash
gtk-update-icon-cache ~/.local/share/flatpak/exports/share/icons/hicolor
```

**Apps not in menu?**
```bash
update-desktop-database ~/.local/share/flatpak/exports/share/applications
```

**Chromium not found?**
```bash
flatpak install --user flathub org.chromium.Chromium
```

**Need to logout?**
Clear Chromium's browser data for icloud.com from Chromium's settings, or completely reset:
```bash
rm -rf ~/.var/app/org.chromium.Chromium/
```

## Next Steps

- Read [README.md](README.md) for detailed documentation
- See [FLATHUB.md](FLATHUB.md) to publish to Flathub
- Check [MULTI-ARCH.md](MULTI-ARCH.md) for ARM builds

Enjoy iCloud on Linux!
