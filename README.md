# iCloud Services for Linux

A Flatpak application that provides individual desktop launchers for iCloud web services on Linux. Each iCloud service (Mail, Drive, Calendar, etc.) appears as a separate application in your desktop environment, launching in Epiphany browser for WebKit compatibility.

## Features

- 8 individual iCloud service launchers:
  - iCloud Mail
  - iCloud Drive
  - iCloud Calendar
  - iCloud Contacts
  - iCloud Photos
  - iCloud Notes
  - iCloud Reminders
  - iCloud Find My

- Uses Epiphany (GNOME Web) browser with WebKit engine for full iCloud compatibility
- Each service runs in application mode with isolated profiles
- Native desktop integration with proper icons and categories

## Prerequisites

### Required Software

1. **Flatpak** (1.12.0 or later)
   ```bash
   sudo apt install flatpak  # Debian/Ubuntu
   sudo dnf install flatpak  # Fedora
   ```

2. **Flatpak Builder**
   ```bash
   sudo apt install flatpak-builder  # Debian/Ubuntu
   sudo dnf install flatpak-builder  # Fedora
   ```

3. **Flathub Repository**
   ```bash
   flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   ```

4. **GNOME Runtime and SDK**
   ```bash
   flatpak install --user flathub org.gnome.Platform//47
   flatpak install --user flathub org.gnome.Sdk//47
   ```

5. **Epiphany Browser** (dependency)
   ```bash
   flatpak install --user flathub org.gnome.Epiphany
   ```

### Icons

Before building, you need to download icons from Icons8. See [README-ICONS.md](README-ICONS.md) for detailed instructions.

Quick summary:
1. Visit https://icons8.com/
2. Download 100x100 PNG icons for each service
3. Save them in the `icons/` directory with the names specified in README-ICONS.md

## Building

### Local Build (Single Architecture)

1. **Clone or navigate to the project directory:**
   ```bash
   cd icloud-flatpak
   ```

2. **Ensure all icons are downloaded** (see README-ICONS.md)

3. **Build the Flatpak:**
   ```bash
   flatpak-builder --force-clean build-dir me.santisbon.iCloudServices.yaml
   ```

4. **Install locally for testing:**
   ```bash
   flatpak-builder --user --install --force-clean build-dir me.santisbon.iCloudServices.yaml
   ```

### Build with Custom Build Directory

```bash
flatpak-builder --repo=repo --force-clean build-dir me.santisbon.iCloudServices.yaml
flatpak build-bundle repo icloud-services.flatpak me.santisbon.iCloudServices
```

## Testing

### Test the Installation

1. **Verify the app is installed:**
   ```bash
   flatpak list | grep icloud
   ```

2. **Check desktop files are exported:**
   ```bash
   ls ~/.local/share/flatpak/exports/share/applications/ | grep icloud
   ```

3. **Test individual services:**
   ```bash
   flatpak run me.santisbon.iCloudServices mail
   flatpak run me.santisbon.iCloudServices drive
   flatpak run me.santisbon.iCloudServices calendar
   # etc.
   ```

4. **Launch from desktop environment:**
   - Open your application menu
   - Search for "iCloud"
   - Launch any service (Mail, Drive, etc.)
   - Verify it opens in Epiphany
   - Log in to iCloud and test functionality

### Testing Checklist

- [ ] All 8 desktop launchers appear in application menu
- [ ] Icons display correctly
- [ ] Each service launches Epiphany in application mode
- [ ] iCloud services load properly (WebKit compatibility)
- [ ] Login persists across sessions (separate profiles per service)
- [ ] Network connectivity works
- [ ] File uploads/downloads work (Drive, Photos)

## Troubleshooting

### Icons Not Showing

If icons don't appear:
```bash
gtk-update-icon-cache ~/.local/share/flatpak/exports/share/icons/hicolor
```

### Epiphany Not Found

Ensure Epiphany is installed:
```bash
flatpak install flathub org.gnome.Epiphany
flatpak run org.gnome.Epiphany --version
```

### Desktop Files Not Appearing

Update desktop database:
```bash
update-desktop-database ~/.local/share/flatpak/exports/share/applications
```

### Permission Issues

The app requires these minimal permissions:
- `--talk-name=org.freedesktop.Flatpak` - Launch Epiphany browser from the launcher
- `--share=ipc` - Inter-process communication for X11 compatibility
- `--socket=wayland` / `--socket=fallback-x11` - Desktop environment integration

Note: Network access and other permissions are handled by Epiphany itself, not this launcher.

## Uninstalling

```bash
flatpak uninstall me.santisbon.iCloudServices
flatpak uninstall --unused  # Remove unused runtimes
```

## Development

### Modifying Desktop Files

Edit files in `desktop-files/` then rebuild:
```bash
flatpak-builder --user --install --force-clean build-dir me.santisbon.iCloudServices.yaml
```

### Adding New Services

1. Add URL to `scripts/launch-icloud.sh`
2. Create corresponding .desktop file
3. Download icon for new service
4. Update manifest to install new desktop file and icon

## License and Attribution

This project is provided as-is. Icons must be downloaded from Icons8 (https://icons8.com/) and require attribution per their free license terms.

iCloud is a trademark of Apple Inc. This is an unofficial third-party application not affiliated with Apple.

## Support

For issues and contributions, please refer to the project repository.

## See Also

- [FLATHUB.md](FLATHUB.md) - Guide for publishing to Flathub
- [MULTI-ARCH.md](MULTI-ARCH.md) - Multi-architecture build instructions
- [README-ICONS.md](README-ICONS.md) - Icon download instructions


## Next Steps:

1. Download icons (see README-ICONS.md)
2. Build and test:
   ```sh
   cd icloud-flatpak
   flatpak-builder --user --install --force-clean build-dir me.santisbon.iCloudServices.yaml
   flatpak run me.santisbon.iCloudServices mail
   ```
3. Create GitHub repo at https://github.com/santisbon/icloud-flatpak
4. Submit to Flathub (follow FLATHUB.md)
