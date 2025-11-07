# iCloud Services for Linux

A Flatpak application that provides individual desktop launchers for iCloud web services on Linux. Each iCloud service (Mail, Calendar, Drive, etc.) appears as a separate application in your desktop environment, launching in a built-in WebKit browser for the best compatibility with Apple services.

## Features

- Individual iCloud service launchers:
  - iCloud Mail
  - iCloud Contacts
  - iCloud Calendar
  - iCloud Photos
  - iCloud Drive
  - iCloud Notes
  - iCloud Reminders
  - iCloud Pages
  - iCloud Numbers
  - iCloud Keynote
  - iCloud Find My

- Uses Epiphany (GNOME Web) browser with WebKit engine for full iCloud compatibility
- Each service runs in application mode with a shared profile (log in once, access all services)
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
   flatpak install --user flathub org.gnome.Platform//49
   flatpak install --user flathub org.gnome.Sdk//49
   ```

5. **Epiphany Browser** (required dependency)
   ```bash
   flatpak install --user flathub org.gnome.Epiphany
   ```

## Building

### Local Build (Single Architecture)

1. **Clone or navigate to the project directory:**
   ```bash
   cd icloud-flatpak
   ```

2. **Build and install the Flatpak:**
      ```bash
      flatpak-builder --force-clean --user --repo=repo --install build-dir me.santisbon.iCloudServices.yaml
      ```

### Share the app with a single-file bundle

```bash
flatpak build-bundle repo icloud-services.flatpak me.santisbon.iCloudServices --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
```
Now you can send the .flatpak file to someone and if they have the Flathub repository set up and a working network connection to install the runtime, they can install it with:
```bash
flatpak install --user icloud-services.flatpak
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

- [ ] All desktop launchers appear in application menu
- [ ] Icons display correctly
- [ ] Each service launches Epiphany in application mode
- [ ] iCloud services load properly (WebKit compatibility)
- [ ] Login persists across sessions (shared profile for all services)
- [ ] Can access multiple services without re-authentication
- [ ] Network connectivity works
- [ ] File uploads/downloads work (Drive, Photos)

### Known Limitations

**Window Grouping:** Each service uses a unique `StartupWMClass` (e.g., `icloud-mail`, `icloud-drive`) to help desktop environments treat them as separate applications. However, since all services ultimately launch Epiphany, window management behavior may vary depending on:

- Your desktop environment (GNOME, KDE, etc.)
- Whether Epiphany's `--application-mode` creates distinct window classes
- Desktop compositor settings

In some cases, all iCloud windows may still group together in the taskbar. This is a fundamental limitation of using a browser as the backend for multiple "apps."

## Troubleshooting

### Icons Not Showing

If icons don't appear:
```bash
gtk-update-icon-cache ~/.local/share/flatpak/exports/share/icons/hicolor
```

### Epiphany Not Found

Ensure Epiphany is installed:
```bash
flatpak install --user flathub org.gnome.Epiphany
```

### Logout / Clear Data

All services share one profile. To logout of all iCloud services:
```bash
rm -rf ~/.var/app/me.santisbon.iCloudServices/data/icloud
```

### Desktop Files Not Appearing

Update desktop database:
```bash
update-desktop-database ~/.local/share/flatpak/exports/share/applications
```

### Permission Issues

The app requires these minimal permissions:
- `--share=ipc` - Inter-process communication for X11 compatibility
- `--socket=wayland` / `--socket=fallback-x11` - Desktop environment integration
- `--talk-name=org.freedesktop.Flatpak` - Permission to spawn Epiphany as a separate Flatpak

Note: Network access, GPU, and other browser permissions are handled by Epiphany running in its own sandbox.

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

This project is provided as-is.

iCloud is a trademark of Apple Inc. This is an unofficial third-party application not affiliated with Apple.

## Support

For issues and contributions, please refer to the project repository.

## See Also

- [FLATHUB.md](FLATHUB.md) - Guide for publishing to Flathub
- [MULTI-ARCH.md](MULTI-ARCH.md) - Multi-architecture build instructions
- [Epiphany](https://flathub.org/en/apps/org.gnome.Epiphany) ([manifest](https://github.com/flathub/org.gnome.Epiphany/blob/master/org.gnome.Epiphany.json)) - Base app
- [GNOME Runtime](https://release.gnome.org/calendar/) releases

## Next Steps:

1. Build and test:
   ```sh
   cd icloud-flatpak
   flatpak-builder --user --install --force-clean build-dir me.santisbon.iCloudServices.yaml
   flatpak run me.santisbon.iCloudServices mail
   ```
2. Create GitHub repo at https://github.com/santisbon/icloud-flatpak
3. Submit to Flathub (follow FLATHUB.md)
