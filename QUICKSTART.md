# Quick Start Guide

Get up and running with iCloud Services on Linux in just a few steps!

## Prerequisites (One-time Setup)

```bash
# Install Flatpak and tools
sudo apt install flatpak flatpak-builder  # Debian/Ubuntu
# OR
sudo dnf install flatpak flatpak-builder  # Fedora

# Add Flathub
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install required runtimes
flatpak install --user flathub org.gnome.Platform//47 org.gnome.Sdk//47

# Install Epiphany (required dependency)
flatpak install --user flathub org.gnome.Epiphany
```

## Step 1: Download Icons

Before building, download 8 icons from Icons8:

1. Visit https://icons8.com/
2. Search for each service name (mail, drive, calendar, contacts, photos, notes, reminders, location)
3. Download as 100x100 PNG
4. Save to `icons/` directory with these names:
   - `icloud-mail.png`
   - `icloud-drive.png`
   - `icloud-calendar.png`
   - `icloud-contacts.png`
   - `icloud-photos.png`
   - `icloud-notes.png`
   - `icloud-reminders.png`
   - `icloud-find.png`

## Step 2: Build and Install

```bash
cd icloud-flatpak

# Build and install in one command
flatpak-builder --user --install --force-clean build-dir me.santisbon.iCloudServices.json
```

Wait 2-5 minutes for the build to complete.

## Step 3: Launch!

**From the command line:**
```bash
flatpak run me.santisbon.iCloudServices mail
```

**From your desktop:**
- Open your application menu
- Search for "iCloud"
- Click any service (Mail, Drive, Calendar, etc.)

## That's It!

You now have 8 iCloud service launchers on your Linux desktop. Each one opens in Epiphany with full WebKit compatibility.

## Troubleshooting

**Icons not showing?**
```bash
gtk-update-icon-cache ~/.local/share/flatpak/exports/share/icons/hicolor
```

**Apps not in menu?**
```bash
update-desktop-database ~/.local/share/flatpak/exports/share/applications
```

**Can't find Epiphany?**
```bash
flatpak install --user flathub org.gnome.Epiphany
```

## Next Steps

- Read [README.md](README.md) for detailed documentation
- See [FLATHUB.md](FLATHUB.md) to publish to Flathub
- Check [MULTI-ARCH.md](MULTI-ARCH.md) for ARM builds

Enjoy iCloud on Linux! 🎉
