# Distribution Preparation Guide

This guide covers how to prepare your iCloud Services Flatpak for distribution, addressing common requirements for publishing platforms.

## Issues to Fix Before Distribution

### 1. Domain Verification

**Issue**: The application ID `me.santisbon.iCloudServices` uses the domain `santisbon.me`, which requires proof of ownership.

**How to Fix**:

#### Option A: Prove Domain Ownership (Recommended for Flathub)

1. **Ensure domain is accessible via HTTPS**:
   ```bash
   curl -I https://santisbon.me
   # Should return 200 OK
   ```

2. **Prepare for verification** (if required by Flathub):
   - Flathub may ask you to place a verification token at a specific URL
   - Example: `https://santisbon.me/.well-known/flathub-verification.txt`
   - You'll receive the token content during the submission process

3. **Alternative verification methods**:
   - Host your project page at `https://santisbon.me/icloud-services`
   - Add a clear link between your domain and GitHub repository
   - Add a TXT DNS record if requested

#### Option B: Use Code Hosting Domain (Alternative)

If you don't control `santisbon.me` or prefer not to verify it, switch to a code hosting domain:

1. **Change Application ID** to use GitHub:
   ```
   Old: me.santisbon.iCloudServices
   New: io.github.santisbon.iCloudServices
   ```

2. **Update all files**:
   - `me.santisbon.iCloudServices.yaml` → `io.github.santisbon.iCloudServices.yaml`
   - `me.santisbon.iCloudServices.metainfo.xml` → `io.github.santisbon.iCloudServices.metainfo.xml`
   - All desktop files: Update `Icon=` fields
   - All icon files: Rename to match new ID
   - Update launcher script if it references the app ID

3. **GitHub requirements**:
   - Repository must be at `https://github.com/santisbon/icloud-flatpak`
   - Repository must be public
   - No additional verification needed

### 2. Screenshot Hosting

**Issue**: Metainfo contains placeholder screenshot URLs.

**How to Fix**:

#### Option A: GitHub Releases (Recommended)

1. **Take high-quality screenshots**:
   ```bash
   # Launch the app and take screenshots
   flatpak run me.santisbon.iCloudServices mail
   # Use screenshot tool to capture the window
   ```

   **Requirements**:
   - Minimum 1600×900 resolution (preferably 1920×1080)
   - PNG format
   - Show the app in use (not just empty windows)
   - At least 2 screenshots, maximum 5

   **Suggested screenshots**:
   - Screenshot 1: Application menu showing all iCloud service icons
   - Screenshot 2: iCloud Drive in app mode (no browser chrome)
   - Screenshot 3: Multiple services open (Mail, Calendar, etc.) in taskbar
   - Screenshot 4: One of the productivity apps (Pages, Numbers, or Keynote)

2. **Host screenshots on GitHub**:
   ```bash
   # Create screenshots directory
   mkdir -p screenshots

   # Move your screenshots here
   mv ~/Pictures/icloud-*.png screenshots/

   # Commit to repository
   git add screenshots/
   git commit -m "Add application screenshots"
   git push
   ```

3. **Get raw GitHub URLs**:
   ```
   https://raw.githubusercontent.com/santisbon/icloud-flatpak/main/screenshots/desktop-menu.png
   https://raw.githubusercontent.com/santisbon/icloud-flatpak/main/screenshots/drive-app-mode.png
   ```

4. **Update metainfo.xml**:
   ```xml
   <screenshots>
     <screenshot type="default">
       <image>https://raw.githubusercontent.com/santisbon/icloud-flatpak/main/screenshots/desktop-menu.png</image>
       <caption>All iCloud services appear as individual apps in your desktop menu</caption>
     </screenshot>
     <screenshot>
       <image>https://raw.githubusercontent.com/santisbon/icloud-flatpak/main/screenshots/drive-app-mode.png</image>
       <caption>iCloud Drive running in clean app mode without browser UI</caption>
     </screenshot>
     <screenshot>
       <image>https://raw.githubusercontent.com/santisbon/icloud-flatpak/main/screenshots/taskbar-integration.png</image>
       <caption>Multiple iCloud services with proper icons in the taskbar</caption>
     </screenshot>
   </screenshots>
   ```

#### Option B: Dedicated Hosting

Host screenshots on your domain:
```xml
<screenshots>
  <screenshot type="default">
    <image>https://santisbon.me/icloud-services/screenshots/screenshot1.png</image>
    <caption>Desktop integration with proper categories and icons</caption>
  </screenshot>
</screenshots>
```

### 3. Stable Release Tags

**Issue**: No stable release tags in git repository.

**How to Fix**:

1. **Ensure code is ready for release**:
   ```bash
   # Test the build
   flatpak-builder --force-clean --user --install build-dir me.santisbon.iCloudServices.yaml

   # Test all services
   flatpak run me.santisbon.iCloudServices mail
   flatpak run me.santisbon.iCloudServices drive
   # ... test others
   ```

2. **Update version in metainfo.xml**:
   ```xml
   <releases>
     <release version="1.0.0" date="2025-11-09">
       <description>
         <p>Initial stable release</p>
         <ul>
           <li>Support for all 11 iCloud services</li>
           <li>Chrome/Chromium integration with app mode</li>
           <li>Separate persistent logins per service</li>
           <li>Support for x86_64 and aarch64 architectures</li>
           <li>Wayland and X11 support</li>
         </ul>
       </description>
     </release>
   </releases>
   ```

3. **Create git tag**:
   ```bash
   # Commit any final changes
   git add .
   git commit -m "Prepare for v1.0.0 release"
   git push

   # Create annotated tag
   git tag -a v1.0.0 -m "Release version 1.0.0

   Initial stable release with:
   - Support for all 11 iCloud services
   - Multi-architecture support (x86_64 and aarch64)
   - Wayland compatibility improvements
   - Desktop integration with proper icons and window grouping"

   # Push tag to GitHub
   git push origin v1.0.0
   ```

4. **Create GitHub Release**:
   - Go to https://github.com/santisbon/icloud-flatpak/releases
   - Click "Draft a new release"
   - Select tag `v1.0.0`
   - Title: "iCloud Services v1.0.0"
   - Description: Copy from metainfo.xml release notes
   - Upload pre-built `.flatpak` bundles (see GITHUB-RELEASES.md)
   - Click "Publish release"

### 4. Update Manifest Source Type

**Issue**: Currently uses `type: dir` which only works for local builds.

**How to Fix**:

For distribution (GitHub Releases, Flathub, etc.), change to archive source:

```yaml
# In me.santisbon.iCloudServices.yaml
modules:
  - name: icloud-services
    buildsystem: simple
    build-commands:
      - install -Dm755 scripts/launch-icloud.sh /app/bin/launch-icloud.sh
      # ... rest of build commands ...
    sources:
      - type: archive
        url: https://github.com/santisbon/icloud-flatpak/archive/refs/tags/v1.0.0.tar.gz
        sha256: REPLACE_WITH_ACTUAL_SHA256
```

**Get the SHA256 hash**:
```bash
# Download the archive
wget https://github.com/santisbon/icloud-flatpak/archive/refs/tags/v1.0.0.tar.gz

# Calculate SHA256
sha256sum v1.0.0.tar.gz

# Copy the hash and update manifest
```

**Important**: Keep the local version with `type: dir` for development, and only use the archive version for distribution manifests.

## Validation Checklist

Before distributing, validate everything:

### Validate Metainfo
```bash
# Install validation tools
flatpak install flathub org.freedesktop.appstream-glib

# Validate the metainfo file
appstreamcli validate me.santisbon.iCloudServices.metainfo.xml

# Should output: "Validation was successful"
```

### Validate Desktop Files
```bash
# Install desktop-file-utils
sudo apt install desktop-file-utils  # Debian/Ubuntu
sudo dnf install desktop-file-utils  # Fedora

# Validate each desktop file
for file in desktop-files/*.desktop; do
    echo "Validating $file"
    desktop-file-validate "$file"
done
```

### Test Complete Build
```bash
# Clean build
flatpak-builder --force-clean --user --install build-dir me.santisbon.iCloudServices.yaml

# Test launch
flatpak run me.santisbon.iCloudServices mail

# Check icons appear correctly
ls ~/.local/share/flatpak/exports/share/icons/hicolor/256x256/apps/ | grep icloud

# Check desktop files
ls ~/.local/share/flatpak/exports/share/applications/ | grep icloud
```

### Test Multi-Architecture Builds
```bash
# Build for x86_64
flatpak-builder --arch=x86_64 --repo=repo --force-clean build-x86_64 me.santisbon.iCloudServices.yaml

# Build for aarch64 (requires aarch64 SDK installed)
flatpak-builder --arch=aarch64 --repo=repo --force-clean build-aarch64 me.santisbon.iCloudServices.yaml

# Create bundles
flatpak build-bundle repo icloud-services-x86_64.flatpak me.santisbon.iCloudServices --arch=x86_64
flatpak build-bundle repo icloud-services-aarch64.flatpak me.santisbon.iCloudServices --arch=aarch64
```

## Quick Reference: Distribution Readiness

- [x] SPDX license format (GPL-3.0-or-later)
- [ ] Domain verification OR switch to io.github ID
- [ ] Real screenshots (minimum 2, hosted on GitHub or domain)
- [ ] Git release tag (v1.0.0)
- [ ] Manifest uses archive source type (for distribution)
- [ ] AppStream metainfo validates successfully
- [ ] Desktop files validate successfully
- [ ] Multi-architecture builds tested
- [ ] All services tested and working

## Next Steps

Once all issues are fixed, choose your distribution method:

1. **GitHub Releases** - See [GITHUB-RELEASES.md](GITHUB-RELEASES.md)
2. **Self-Hosted Repository** - See [SELF-HOSTED-REPO.md](SELF-HOSTED-REPO.md)
3. **Flathub** - See [FLATHUB.md](FLATHUB.md) (Note: May be rejected due to web wrapper policy)

## Resources

- [AppStream Documentation](https://www.freedesktop.org/software/appstream/docs/)
- [Desktop Entry Specification](https://specifications.freedesktop.org/desktop-entry-spec/latest/)
- [Flatpak Manifest Documentation](https://docs.flatpak.org/en/latest/manifests.html)
- [SPDX License List](https://spdx.org/licenses/)
