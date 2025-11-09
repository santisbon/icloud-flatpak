# Self-Hosted Flatpak Repository

This guide covers how to set up and maintain your own Flatpak repository for distributing multiple applications, enabling automatic updates for users.

## Overview

**Advantages**:
- Automatic updates for users
- Standard Flatpak workflow (same as Flathub)
- Full control over release timing
- Can host multiple applications
- Users add repo once, get updates forever
- Smaller downloads (only delta updates)

**Disadvantages**:
- Requires web hosting with static file serving
- Initial setup more complex
- Need to manage GPG keys
- Bandwidth costs (though usually minimal)
- Must maintain repository structure

## Prerequisites

1. **Web hosting** with static file serving (any of these):
   - GitHub Pages (free, static)
   - GitLab Pages (free, static)
   - Netlify (free tier available)
   - Your own domain/server (e.g., https://santisbon.me)
   - Cloud storage (S3, Google Cloud Storage, etc.)

2. **HTTPS required** - Flatpak repositories must be served over HTTPS

3. **GPG key** for signing the repository

## Part 1: Repository Setup

### Step 1: Generate GPG Key (First Time Only)

```bash
# Generate new GPG key specifically for Flatpak signing
gpg --full-generate-key

# Follow prompts:
# - Kind: (1) RSA and RSA
# - Key size: 4096
# - Expiration: 0 (does not expire) or set your preference
# - Real name: "Your Name Flatpak Repository"
# - Email: your-email@example.com
# - Comment: "Repository signing key"

# List keys to get the key ID
gpg --list-secret-keys --keyid-format=long

# Example output:
# sec   rsa4096/ABCD1234EFGH5678 2025-11-09
#       ABCD1234EFGH5678ABCD1234EFGH5678ABCD1234
# uid   Your Name Flatpak Repository <your-email@example.com>

# Export public key (users will need this)
gpg --export ABCD1234EFGH5678 > flatpak-repo.gpg

# Export private key for backup (KEEP SECURE!)
gpg --export-secret-keys ABCD1234EFGH5678 > flatpak-repo-private.gpg
# Store this in a safe location (password manager, encrypted backup)
```

### Step 2: Initialize Repository

```bash
# Create repository directory
mkdir -p flatpak-repo
cd flatpak-repo

# Initialize OSTree repository
ostree --repo=repo init --mode=archive-z2

# Repository config is created automatically by ostree init
# Verify it exists
cat repo/config

# Should show:
# [core]
# repo_version=1
# mode=archive-z2
```

### Step 3: Build and Add Application to Repository

```bash
# Navigate to your project
cd /home/armando/code/icloud-flatpak

# Build for x86_64
flatpak-builder \
  --arch=x86_64 \
  --repo=/path/to/flatpak-repo/repo \
  --force-clean \
  --gpg-sign=ABCD1234EFGH5678 \
  build-x86_64 \
  me.santisbon.iCloudServices.yaml

# Build for aarch64
flatpak-builder \
  --arch=aarch64 \
  --repo=/path/to/flatpak-repo/repo \
  --force-clean \
  --gpg-sign=ABCD1234EFGH5678 \
  build-aarch64 \
  me.santisbon.iCloudServices.yaml

# Update repository summary
flatpak build-update-repo \
  --generate-static-deltas \
  --gpg-sign=ABCD1234EFGH5678 \
  /path/to/flatpak-repo/repo
```

### Step 4: Create Repository Configuration File

Create a `.flatpakrepo` file for your repository:

```bash
cat > /path/to/flatpak-repo/santisbon-apps.flatpakrepo << 'EOF'
[Flatpak Repo]
Title=Santisbon Applications
Url=https://santisbon.me/flatpak/repo
Homepage=https://santisbon.me/flatpak/
Comment=Custom applications by Santisbon
Description=A collection of custom Flatpak applications including iCloud Services and other utilities
Icon=https://santisbon.me/flatpak/icon.png
GPGKey=mQINBGcwMXYBEAC... (paste base64 encoded GPG key here)
EOF
```

To get the base64 encoded GPG key:
```bash
gpg --export ABCD1234EFGH5678 | base64 -w0
```

Paste the output (single line) after `GPGKey=`

## Part 2: Hosting Options

### Option A: GitHub Pages (Free, Recommended)

**Advantages**: Free, HTTPS included, good bandwidth, easy setup

```bash
# Create separate repository for hosting
cd ~
git clone https://github.com/santisbon/flatpak-repo.git
cd flatpak-repo

# Copy repository files
cp -r /path/to/flatpak-repo/* .

# Create index.html for repository homepage
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Santisbon Flatpak Repository</title>
    <style>
        body { font-family: sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
        pre { background: #f4f4f4; padding: 15px; border-radius: 5px; overflow-x: auto; }
        .app { border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Santisbon Flatpak Repository</h1>

    <p>Custom Flatpak applications with automatic updates.</p>

    <h2>Setup</h2>
    <pre><code># Add the repository
flatpak remote-add --user --if-not-exists santisbon-apps https://santisbon.github.io/flatpak-repo/santisbon-apps.flatpakrepo

# Update app list
flatpak update</code></pre>

    <h2>Available Applications</h2>

    <div class="app">
        <h3>iCloud Services</h3>
        <p>Access all your iCloud web services on Linux with native desktop integration.</p>
        <pre><code># Install prerequisites
flatpak install --user flathub org.chromium.Chromium

# Install
flatpak install --user santisbon-apps me.santisbon.iCloudServices

# Launch
flatpak run me.santisbon.iCloudServices mail</code></pre>
        <p><a href="https://github.com/santisbon/icloud-flatpak">Source Code</a></p>
    </div>

    <!-- Add more applications here as you publish them -->

    <h2>Updates</h2>
    <pre><code>flatpak update</code></pre>

    <h2>Support</h2>
    <ul>
        <li><a href="https://github.com/santisbon">GitHub Profile</a></li>
        <li><a href="https://santisbon.me">Website</a></li>
    </ul>
</body>
</html>
EOF

# Commit and push
git add .
git commit -m "Initial flatpak repository"
git push origin main

# Enable GitHub Pages
# Go to: https://github.com/santisbon/flatpak-repo/settings/pages
# Source: Deploy from a branch
# Branch: main / (root)
# Save
```

Your repository will be available at: `https://santisbon.github.io/flatpak-repo/`

Update the `.flatpakrepo` file URLs to match GitHub Pages:
```ini
Url=https://santisbon.github.io/flatpak-repo/repo
Homepage=https://santisbon.github.io/flatpak-repo/
```

### Option B: Custom Domain

If you own `santisbon.me`:

```bash
# Upload repository to your web server
rsync -avz /path/to/flatpak-repo/ user@santisbon.me:/var/www/flatpak/

# Or use your hosting provider's upload method
# Ensure files are served at: https://santisbon.me/flatpak/
```

Update `.flatpakrepo` file:
```ini
Url=https://santisbon.me/flatpak/repo
Homepage=https://santisbon.me/flatpak/
```

### Option C: GitLab Pages

Similar to GitHub Pages, but using GitLab:

```yaml
# .gitlab-ci.yml
pages:
  stage: deploy
  script:
    - mkdir public
    - cp -r repo public/
    - cp icloud-services.flatpakrepo public/
  artifacts:
    paths:
      - public
  only:
    - main
```

Repository available at: `https://santisbon.gitlab.io/flatpak-repo/`

### Option D: Netlify

1. Create account at https://netlify.com
2. Drag and drop your `flatpak-repo` folder
3. Get URL: `https://santisbon-apps.netlify.app`
4. (Optional) Configure custom domain

## Part 3: User Installation

### Create Installation Instructions

Create `INSTALL-FROM-REPO.md`:

```markdown
# Install from Flatpak Repository

## One-Time Setup

### 1. Install Flatpak
```bash
sudo apt install flatpak  # Debian/Ubuntu
sudo dnf install flatpak  # Fedora
```

### 2. Add Flathub (for dependencies)
```bash
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

### 3. Add Santisbon Apps Repository

**Method 1: Using .flatpakrepo file (Recommended)**
```bash
flatpak remote-add --user --if-not-exists santisbon-apps https://santisbon.me/flatpak/santisbon-apps.flatpakrepo
```

**Method 2: Manual setup**
```bash
# Download GPG key
wget https://santisbon.me/flatpak/flatpak-repo.gpg

# Import GPG key
flatpak remote-add --user --gpg-import=flatpak-repo.gpg santisbon-apps https://santisbon.me/flatpak/repo
```

## Browse Available Applications

```bash
flatpak remote-ls santisbon-apps
```

## Install Applications

**Example: iCloud Services**
```bash
# Install any required dependencies first
flatpak install --user flathub org.chromium.Chromium

# Install the application
flatpak install --user santisbon-apps me.santisbon.iCloudServices
```

## Updates

Updates are automatic! Just run:
```bash
flatpak update
```

## Uninstall

```bash
# Remove a specific application
flatpak uninstall me.santisbon.iCloudServices

# Remove the repository
flatpak remote-delete santisbon-apps
```
```

## Part 4: Updating Your Repository

### Publishing a New Version

```bash
cd /home/armando/code/icloud-flatpak

# Make your changes and commit
git add .
git commit -m "Version 1.1.0: New features"
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin main v1.1.0

# Update metainfo.xml with new release entry

# Rebuild and publish to repository
flatpak-builder \
  --arch=x86_64 \
  --repo=/path/to/flatpak-repo/repo \
  --force-clean \
  --gpg-sign=ABCD1234EFGH5678 \
  build-x86_64 \
  me.santisbon.iCloudServices.yaml

flatpak-builder \
  --arch=aarch64 \
  --repo=/path/to/flatpak-repo/repo \
  --force-clean \
  --gpg-sign=ABCD1234EFGH5678 \
  build-aarch64 \
  me.santisbon.iCloudServices.yaml

# Update repository summary
flatpak build-update-repo \
  --generate-static-deltas \
  --gpg-sign=ABCD1234EFGH5678 \
  /path/to/flatpak-repo/repo

# Sync to hosting
cd /path/to/flatpak-repo
git add repo/
git commit -m "Publish v1.1.0"
git push origin main
```

Users will automatically get the update next time they run `flatpak update`!

### Automated Publishing with GitHub Actions

Create `.github/workflows/publish-to-repo.yml`:

```yaml
name: Publish to Flatpak Repository

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y flatpak flatpak-builder
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        flatpak install -y flathub org.freedesktop.Platform//x86_64/25.08
        flatpak install -y flathub org.freedesktop.Sdk//x86_64/25.08
        flatpak install -y flathub org.freedesktop.Platform//aarch64/25.08
        flatpak install -y flathub org.freedesktop.Sdk//aarch64/25.08

    - name: Import GPG key
      run: |
        echo "${{ secrets.GPG_PRIVATE_KEY }}" | gpg --import
      env:
        GPG_PRIVATE_KEY: ${{ secrets.GPG_PRIVATE_KEY }}

    - name: Clone repository
      run: |
        git clone https://github.com/santisbon/flatpak-repo.git repo-checkout
        cd repo-checkout
        ostree --repo=repo init --mode=archive-z2 || true

    - name: Build and publish x86_64
      run: |
        flatpak-builder \
          --arch=x86_64 \
          --repo=repo-checkout/repo \
          --gpg-sign=${{ secrets.GPG_KEY_ID }} \
          --force-clean \
          build-x86_64 \
          me.santisbon.iCloudServices.yaml

    - name: Build and publish aarch64
      run: |
        flatpak-builder \
          --arch=aarch64 \
          --repo=repo-checkout/repo \
          --gpg-sign=${{ secrets.GPG_KEY_ID }} \
          --force-clean \
          build-aarch64 \
          me.santisbon.iCloudServices.yaml

    - name: Update repository
      run: |
        cd repo-checkout
        flatpak build-update-repo \
          --generate-static-deltas \
          --gpg-sign=${{ secrets.GPG_KEY_ID }} \
          repo

    - name: Deploy to repository
      run: |
        cd repo-checkout
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"
        git add repo/
        git commit -m "Publish ${{ github.ref_name }}"
        git push
```

**Setup secrets** in GitHub repository settings:
- `GPG_PRIVATE_KEY`: Your private GPG key (from `gpg --export-secret-keys --armor KEYID`)
- `GPG_KEY_ID`: Your GPG key ID (e.g., `ABCD1234EFGH5678`)

## Part 5: Repository Management

### Monitor Repository Size

```bash
# Check repository size
du -sh /path/to/flatpak-repo/repo

# OSTree repositories grow over time
# Clean old objects (keeps last 30 days)
ostree --repo=/path/to/flatpak-repo/repo prune --refs-only --keep-younger-than="30 days ago"
```

### Repository Statistics

Create a simple stats page:

```bash
# Count commits in repository
ostree --repo=/path/to/flatpak-repo/repo log me.santisbon.iCloudServices | grep "^commit" | wc -l

# List all refs
ostree --repo=/path/to/flatpak-repo/repo refs

# Get repository size
du -sh /path/to/flatpak-repo/repo
```

### Backup Repository

```bash
# Backup GPG keys (CRITICAL!)
gpg --export-secret-keys ABCD1234EFGH5678 > backup-gpg-private-key.asc

# Backup entire repository
tar czf flatpak-repo-backup-$(date +%Y%m%d).tar.gz /path/to/flatpak-repo/

# Upload to secure location
# e.g., encrypted cloud storage, external drive, etc.
```

### Handle Key Expiration

If your GPG key expires:

```bash
# Extend expiration
gpg --edit-key ABCD1234EFGH5678
# gpg> expire
# (select new expiration)
# gpg> save

# Re-export public key
gpg --export ABCD1234EFGH5678 > flatpak-repo.gpg

# Update .flatpakrepo file with new GPG key
gpg --export ABCD1234EFGH5678 | base64 -w0

# Users will need to re-add the repository or:
flatpak remote-modify --gpg-import=flatpak-repo.gpg santisbon-apps
```

## Part 6: Multi-Application Repository

You can host multiple applications in the same repository. Users add your repository once and get access to all your apps.

### Adding a Second Application

```bash
# Navigate to your second app project
cd /path/to/your-second-app

# Build for x86_64 and add to the SAME repository
flatpak-builder \
  --arch=x86_64 \
  --repo=/path/to/flatpak-repo/repo \
  --gpg-sign=ABCD1234EFGH5678 \
  --force-clean \
  build-x86_64 \
  me.santisbon.AnotherApp.yaml

# Build for aarch64
flatpak-builder \
  --arch=aarch64 \
  --repo=/path/to/flatpak-repo/repo \
  --gpg-sign=ABCD1234EFGH5678 \
  --force-clean \
  build-aarch64 \
  me.santisbon.AnotherApp.yaml

# Update repository
flatpak build-update-repo \
  --generate-static-deltas \
  --gpg-sign=ABCD1234EFGH5678 \
  /path/to/flatpak-repo/repo
```

### Update the Website

Add the new app to your index.html:

```html
<div class="app">
    <h3>Another App</h3>
    <p>Description of your second application.</p>
    <pre><code># Install
flatpak install --user santisbon-apps me.santisbon.AnotherApp

# Launch
flatpak run me.santisbon.AnotherApp</code></pre>
    <p><a href="https://github.com/santisbon/another-app">Source Code</a></p>
</div>
```

### Deploy Updates

```bash
cd /path/to/flatpak-repo
git add repo/
git commit -m "Add AnotherApp to repository"
git push origin main
```

Users automatically see the new app:
```bash
flatpak remote-ls santisbon-apps
# Shows both me.santisbon.iCloudServices and me.santisbon.AnotherApp
```

## Part 7: Troubleshooting

### Users Can't Add Repository

**Error**: "error: GPG verification failed"

**Solution**:
```bash
# Re-download GPG key
wget https://santisbon.me/flatpak/flatpak-repo.gpg

# Re-add repository
flatpak remote-add --user --gpg-import=flatpak-repo.gpg --if-not-exists santisbon-apps https://santisbon.me/flatpak/repo
```

### Repository Won't Build

**Error**: "GPG signing failed"

**Solution**:
```bash
# Check GPG key is available
gpg --list-secret-keys

# Test signing
echo "test" | gpg --sign --default-key ABCD1234EFGH5678

# If passphrase prompt, either:
# - Enter passphrase each time
# - Use gpg-agent to cache passphrase
# - Create key without passphrase (less secure)
```

### Static Deltas Failing

**Error**: "error: Summary delta generation failed"

**Solution**:
```bash
# Generate static deltas manually
flatpak build-update-repo \
  --generate-static-deltas \
  --static-delta-ignore-ref=*.Debug \
  --gpg-sign=ABCD1234EFGH5678 \
  /path/to/flatpak-repo/repo
```

## Comparison: GitHub Releases vs Self-Hosted Repository

| Feature | GitHub Releases | Self-Hosted Repo |
|---------|----------------|------------------|
| **Updates** | Manual | Automatic |
| **Setup Time** | 10 minutes | 1-2 hours |
| **Maintenance** | Low | Medium |
| **User Experience** | Download + install | Add repo once |
| **Hosting Cost** | Free | Free (GitHub Pages) or $5-10/month |
| **Bandwidth** | GitHub's generous limits | Varies by host |
| **Update Size** | Full bundle (~5-10 MB) | Delta updates (~1-2 MB) |
| **Best For** | Quick releases, testing | Production, multiple apps |

## Security Best Practices

1. **Protect GPG private key**:
   - Never commit to git
   - Store encrypted backups
   - Use GitHub secrets for CI/CD

2. **Use HTTPS**:
   - Required for Flatpak repositories
   - Free with GitHub Pages, Let's Encrypt, etc.

3. **Sign all commits**:
   - Ensures repository integrity
   - Required for distribution

4. **Regular backups**:
   - GPG keys (most critical!)
   - Repository contents
   - Configuration files

## Resources

- [Flatpak Repository Hosting](https://docs.flatpak.org/en/latest/hosting-a-repository.html)
- [OSTree Documentation](https://ostreedev.github.io/ostree/)
- [GPG Guide](https://www.gnupg.org/documentation/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)

## Next Steps

1. Set up repository using GitHub Pages
2. Build and publish initial version
3. Create user installation instructions
4. Set up automated publishing (optional)
5. Monitor and maintain repository

For GitHub Releases distribution instead, see [GITHUB-RELEASES.md](GITHUB-RELEASES.md).
