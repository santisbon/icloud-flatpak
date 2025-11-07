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
flatpak install --user flathub org.gnome.Platform//49 org.gnome.Sdk//49

# Install Epiphany (required)
flatpak install --user flathub org.gnome.Epiphany
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

You now have iCloud service launchers on your Linux desktop. Each one opens in Epiphany with full WebKit compatibility.

## Troubleshooting

**Icons not showing?**
```bash
gtk-update-icon-cache ~/.local/share/flatpak/exports/share/icons/hicolor
```

**Apps not in menu?**
```bash
update-desktop-database ~/.local/share/flatpak/exports/share/applications
```

**Epiphany not found?**
```bash
flatpak install --user flathub org.gnome.Epiphany
```

**Need to logout?**
```bash
rm -rf ~/.var/app/me.santisbon.iCloudServices/data/icloud
```

## Next Steps

- Read [README.md](README.md) for detailed documentation
- See [FLATHUB.md](FLATHUB.md) to publish to Flathub
- Check [MULTI-ARCH.md](MULTI-ARCH.md) for ARM builds

Enjoy iCloud on Linux!
