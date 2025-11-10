# iCloud Services for Linux

Provides individual desktop launchers for iCloud web services on Linux. Each iCloud service (Mail, Photos, Drive, etc.) appears as a separate application in your desktop environment.

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

- Uses Chrome or Chromium browser in app mode for a clean, native-like interface.
- Each service runs as a separate application with its own dock/task manager icon.
- Log in once per service (authentication persists across sessions). Supports passkeys for Face ID login.
- Native desktop integration with proper icons and categories.

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

4. **Freedesktop Runtime and SDK**
   ```bash
   flatpak install --user flathub org.freedesktop.Platform//25.08
   flatpak install --user flathub org.freedesktop.Sdk//25.08
   ```

5. **Chrome or Chromium Browser** (required dependency)
   ```bash
   flatpak install --user flathub org.chromium.Chromium
   # OR
   flatpak install --user flathub com.google.Chrome
   ```

   **Note:** You must install Chrome or Chromium manually. The app will detect which one is installed and use it automatically.

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
Now you can send the .flatpak file to someone and if they have the Flathub repository set up and a working network connection to install the runtime/sdk, they can install iCloud with:
```bash
flatpak install flathub org.freedesktop.Platform//25.08
flatpak install flathub org.freedesktop.Sdk//25.08

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
   - Verify it opens in app mode (no address bar)
   - Log in to iCloud and test functionality

### Testing Checklist

- [x] All desktop launchers appear in application menu
- [x] Icons display correctly
- [x] Each service launches in app mode (no address bar)
- [x] Each service has its own dock icon (not grouped together)
- [x] iCloud services load properly
- [x] Login persists across sessions for each service
- [x] Network connectivity works
- [x] File uploads/downloads work (Drive, Photos)

### Known Limitations

**Separate Logins Required:** Each iCloud service runs as a separate Chrome/Chromium app with its own profile to ensure separate dock icons. This means you'll need to log in to iCloud once for each service you use. However:
- Logins persist across sessions (you only log in once per service)
- You can log in with Face ID by using a passkey
- Each service maintains its own separate dock icon
- Services can run simultaneously without interference

## Troubleshooting

### Icons Not Showing

If icons don't appear:
```bash
gtk-update-icon-cache ~/.local/share/flatpak/exports/share/icons/hicolor
```

### Chrome/Chromium Not Found

Ensure the browser is installed e.g.
```bash
flatpak install --user flathub org.chromium.Chromium
```

### Logout / Clear Data

Each service has its own Chromium profile. To logout of a specific service:
```bash
# Logout of Mail only
rm -rf ~/.var/app/org.chromium.Chromium/config/icloud-mail

# Logout of Drive only
rm -rf ~/.var/app/org.chromium.Chromium/config/icloud-drive
```

To logout of all iCloud services at once:
```bash
rm -rf ~/.var/app/org.chromium.Chromium/config/icloud-*
```

Alternatively, clear cookies from within each service:
1. Open the iCloud service
2. Click the menu (three dots) in Chromium
3. Go to Settings → Privacy and security → Clear browsing data
4. Select "Cookies and other site data" for icloud.com

### Desktop Files Not Appearing

Update desktop database:
```bash
update-desktop-database ~/.local/share/flatpak/exports/share/applications
```

### Permission Issues

The app requires these minimal permissions:
- `--share=ipc` - Inter-process communication for X11 compatibility
- `--socket=wayland` / `--socket=fallback-x11` - Desktop environment integration
- `--talk-name=org.freedesktop.Flatpak` - Permission to spawn Chromium as a separate Flatpak

Note: Network access, GPU, and other browser permissions are handled by Chromium running in its own sandbox.

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

iCloud is a trademark of Apple Inc. This is an unofficial third-party application not affiliated with Apple Inc. Icons by The Cross-Platform Organization (https://github.com/cross-platform) under GNU GPL v3.

## Support

For issues and contributions, please refer to the project repository.

## Distribution

Choose how to distribute your application:

### Option 1: GitHub Releases (Recommended)
Distribute `.flatpak` bundles directly through GitHub Releases. Simple setup, no infrastructure needed.
- [GITHUB-RELEASES.md](GITHUB-RELEASES.md) - Complete guide to GitHub Releases distribution

### Option 2: Self-Hosted Flatpak Repository
Host your own Flatpak repository for automatic updates. Can use GitHub Pages (free) or your own domain.
- [SELF-HOSTED-REPO.md](SELF-HOSTED-REPO.md) - Complete guide to self-hosted repositories

### Option 3: Flathub (Not Recommended)
**Note**: Flathub may reject this application due to their [web wrapper policy](https://docs.flathub.org/docs/for-app-authors/requirements). See FLATHUB.md for details and requirements if attempting submission.
- [FLATHUB.md](FLATHUB.md) - Flathub submission guide (may be rejected)

### Preparation
Before distributing, ensure your application meets all requirements:
- [DISTRIBUTION-PREP.md](DISTRIBUTION-PREP.md) - Fix common issues and prepare for release

## See Also

- [QUICKSTART.md](QUICKSTART.md) - Quick build and install guide
- [MULTI-ARCH.md](MULTI-ARCH.md) - Multi-architecture build instructions
- [Chromium](https://flathub.org/en/apps/org.chromium.Chromium) - Browser backend
- [Freedesktop Runtime](https://docs.flatpak.org/en/latest/available-runtimes.html) - [Releases](https://gitlab.com/freedesktop-sdk/freedesktop-sdk/-/wikis/Releases)
