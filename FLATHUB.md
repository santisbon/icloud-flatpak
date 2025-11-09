# Publishing to Flathub

> **WARNING**: This application will likely be **REJECTED** by Flathub due to their [web wrapper policy](https://docs.flathub.org/docs/for-app-authors/requirements).
>
> Flathub explicitly states: _"Submissions that are merely documentation, media-only content, fonts, firmware, **web wrappers**, shell extensions, or CLI utilities are rejected."_
>
> This application is fundamentally a web wrapper - it launches Chrome/Chromium with specific URLs in app mode.
>
> **Recommended alternatives**:
> - [GitHub Releases](GITHUB-RELEASES.md) - Simple, direct distribution
> - [Self-Hosted Repository](SELF-HOSTED-REPO.md) - Automatic updates for users
>
> This guide is provided for reference only.

---

This guide covers the complete workflow for submitting the iCloud Services Flatpak to Flathub, the primary repository for Flatpak applications.

## Prerequisites

1. **GitHub Account** - Flathub uses GitHub for submissions
2. **Tested Flatpak** - Your app should be thoroughly tested locally
3. **AppStream Metadata** - Required for Flathub (see below)
4. **Screenshots** - At least 2 screenshots of your app in action
5. **Valid App ID** - Must be a reverse-DNS name you control

## App ID

This project uses the app ID `me.santisbon.iCloudServices` which follows the reverse-DNS format using the santisbon.me domain. This is appropriate for Flathub submission as:
- It uses a controlled domain (santisbon.me)
- It clearly indicates this is an unofficial third-party application
- It follows Flatpak/Flathub naming conventions

## Step 1: Add Required Metadata

Flathub requires AppStream metadata. Create this file:

**File: `me.santisbon.iCloudServices.metainfo.xml`** (already created)

## Step 2: Update Manifest

Add the metainfo file to your manifest build commands:

```yaml
build-commands:
  - install -Dm755 scripts/launch-icloud.sh /app/bin/launch-icloud.sh
  - install -Dm644 me.santisbon.iCloudServices.metainfo.xml /app/share/metainfo/me.santisbon.iCloudServices.metainfo.xml
  # ...existing commands...
```

## Step 3: Validate Metadata

Install validation tools:
```bash
sudo apt install appstream  # Debian/Ubuntu
sudo dnf install appstream  # Fedora
```

Validate your metadata:
```bash
appstreamcli validate me.santisbon.iCloudServices.metainfo.xml
```

Validate the built Flatpak:
```bash
flatpak run org.freedesktop.appstream-glib validate /path/to/me.santisbon.iCloudServices.metainfo.xml
```

## Step 4: Prepare Your Repository

1. **Create a GitHub repository** for your Flatpak:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: iCloud Services Flatpak"
   git remote add origin https://github.com/santisbon/icloud-flatpak.git
   git push -u origin main
   ```

2. **Tag a release:**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

3. **Host screenshots** (GitHub releases, separate hosting, etc.)

4. **Update manifest to use archive source:**

   Instead of `type: dir`, use Git source:
   ```yaml
   sources:
     - type: archive
       url: https://github.com/santisbon/icloud-flatpak/archive/refs/tags/v1.0.0.tar.gz
       sha256: YOUR_SHA256_HASH
   ```

   Get the SHA256:
   ```bash
   wget https://github.com/santisbon/icloud-flatpak/archive/refs/tags/v1.0.0.tar.gz
   sha256sum v1.0.0.tar.gz
   ```

## Step 5: Submit to Flathub

1. **Fork the Flathub repository:**

   Go to https://github.com/flathub/flathub and click "Fork"

2. **Create a new branch in your fork:**
   ```bash
   git clone https://github.com/santisbon/flathub.git
   cd flathub
   git checkout -b add-icloud-services
   ```

3. **Add your app:**
   ```bash
   mkdir me.santisbon.iCloudServices
   cd me.santisbon.iCloudServices
   # Copy your manifest file here
   cp /path/to/icloud-flatpak/me.santisbon.iCloudServices.yaml .
   # Copy metainfo
   cp /path/to/icloud-flatpak/me.santisbon.iCloudServices.metainfo.xml .
   ```

4. **Commit and push:**
   ```bash
   git add .
   git commit -m "Add iCloud Services application"
   git push origin add-icloud-services
   ```

5. **Create a Pull Request:**
   - Go to your fork on GitHub
   - Click "Pull Request"
   - Target: `flathub/flathub:master`
   - Source: `santisbon/flathub:add-icloud-services`
   - Fill in the PR template with all required information

## Step 6: Flathub Review Process

The Flathub team will review your submission. They'll check:

- **Manifest quality** - Proper structure, correct dependencies
- **Metadata validity** - AppStream compliance
- **Build success** - Must build on Flathub infrastructure
- **Multi-arch support** - Should support x86_64 and aarch64
- **Security** - Minimal required permissions
- **Legal** - No trademark issues, proper licensing

Common review feedback:
- "Use more specific finish-args"
- "Add content rating"
- "Provide better screenshots"
- "Fix desktop file categories"

## Step 7: Buildbot Process

Once approved:
1. Flathub's buildbot will automatically build for all architectures
2. It will publish to the Flathub repository
3. Your app becomes available via: `flatpak install flathub me.santisbon.iCloudServices`

## Step 8: Maintaining Your App

### Updating Your App

1. **Make changes to your source repository**
2. **Tag a new release:**
   ```bash
   git tag -a v1.1.0 -m "Release version 1.1.0"
   git push origin v1.1.0
   ```

3. **Update the Flathub manifest:**
   - Fork the app repository: https://github.com/flathub/me.santisbon.iCloudServices
   - Update the manifest with new version URL and SHA256
   - Update metainfo.xml with new release entry
   - Submit PR

4. **Buildbot will automatically build and publish**

## Permissions Explanation

This app uses minimal permissions following Flatpak best practices:
- `--share=ipc` - Standard for desktop apps (X11 shared memory)
- `--socket=wayland` / `--socket=fallback-x11` - Desktop environment integration
- `--talk-name=org.freedesktop.Flatpak` - Permission to spawn Chromium as a separate Flatpak

**External Dependency:** This app requires Chromium to be installed separately:
- Chromium runs in its own sandbox with its own permissions
- The launcher just spawns Chromium windows in app mode with specific URLs
- Network, GPU, and browser permissions are handled by Chromium itself

## Flathub Guidelines

Review the official guidelines before submitting:
- https://docs.flathub.org/docs/for-app-authors/submission
- https://docs.flathub.org/docs/for-app-authors/requirements

## Important Considerations

### Trademark Issues

Since "iCloud" is an Apple trademark, you may need to:
- Use a different name (e.g., "Web Services for iCloud")
- Add clear disclaimers that this is unofficial
- Be prepared for potential rejection or rename request

### Chromium Dependency

This app requires Chrome or Chromium to be installed. The `<requires>` tag in metainfo.xml informs the user of this requirement.

**Manual installation (command line):**
- Users must install: `flatpak install flathub org.chromium.Chromium`
- The launcher provides helpful error messages if Chromium is missing

**How it works:**
- The launcher spawns Chromium as a separate Flatpak process
- Each iCloud service opens in Chromium's app mode (no address bar)
- Provides a clean, native-like application experience

### Icons Attribution

Your metainfo.xml should include attribution:
```xml
<description>
  <p>Icons by The Cross-Platform Organization (https://github.com/cross-platform) under GNU GPL v3</p>
</description>
```

## Alternative: Publish Outside Flathub

If Flathub rejects due to trademark concerns, you can:

1. **Host on your own repository:**
   ```bash
   # Set up a flat-repo
   flatpak-builder --repo=repo --force-clean build-dir me.santisbon.iCloudServices.yaml

   # Users can install via:
   flatpak remote-add --user icloud-services https://yoursite.com/repo
   flatpak install icloud-services me.santisbon.iCloudServices
   ```

2. **Distribute as .flatpak bundle:**
   ```bash
   flatpak build-bundle repo icloud-services.flatpak me.santisbon.iCloudServices
   # Users double-click to install
   ```

## Getting Help

- Flathub Matrix channel: #flathub:matrix.org
- Flathub Discourse: https://discourse.flathub.org/
- Flatpak documentation: https://docs.flatpak.org/

## Checklist Before Submission

- [ ] App ID follows reverse-DNS format you control
- [ ] AppStream metadata validates with no errors
- [ ] App builds successfully locally
- [ ] All services launch and work correctly
- [ ] Icons display properly
- [ ] Screenshots are high-quality and representative
- [ ] Source code is in a public Git repository
- [ ] Release is tagged
- [ ] Manifest uses archive source (not dir)
- [ ] SHA256 hash is correct
- [ ] finish-args are minimal and justified
- [ ] Icons attribution is included
- [ ] Trademark concerns are addressed
