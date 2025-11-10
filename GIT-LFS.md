# Git Large File Storage (LFS) for Flatpak Repositories

This document provides comprehensive documentation on using Git Large File Storage (Git LFS) with Flatpak repositories hosted on GitHub.

## Table of Contents

1. [The Problem](#the-problem)
2. [What is Git LFS?](#what-is-git-lfs)
3. [Why Flatpak Repositories Need LFS](#why-flatpak-repositories-need-lfs)
4. [Installation](#installation)
5. [Setting Up LFS for a New Repository](#setting-up-lfs-for-a-new-repository)
6. [Converting an Existing Repository to LFS](#converting-an-existing-repository-to-lfs)
7. [Working with LFS Repositories](#working-with-lfs-repositories)
8. [Technical Details](#technical-details)
9. [Troubleshooting](#troubleshooting)
10. [Best Practices](#best-practices)

## The Problem

When hosting a Flatpak repository on GitHub, you'll encounter GitHub's file size limits:

- **Maximum file size**: 100 MB
- **Warning threshold**: 50 MB
- **Repository size warning**: 1 GB
- **Repository size limit**: 5 GB (soft limit)

### The Specific Error

When attempting to push a Flatpak repository to GitHub without LFS, you'll see:

```
remote: error: File repo/objects/77/ef3fc1eaff8a452cc66c9b5cb06271fb97fca4fa0c48365e90fd8aab8523fb.filez is 104.22 MB; this exceeds GitHub's file size limit of 100.00 MB
remote: error: GH001: Large files detected. You may want to try Git Large File Storage - https://git-lfs.github.com.
```

### Why OSTree Objects Are Large

Flatpak uses OSTree (libostree) for its repository format. OSTree stores application data as objects:

- **`.filez` files**: Compressed content objects (application files)
- **`.file` files**: Uncompressed content objects
- **`.commit` files**: Commit metadata
- **`.dirtree` files**: Directory tree metadata

For applications with large assets (libraries, frameworks, images), individual `.filez` files can easily exceed 100 MB. In our case, the iCloud Services app had object files reaching 104.22 MB due to:
- Chromium dependency libraries
- Freedesktop runtime components
- Multi-architecture support (x86_64 and aarch64)

## What is Git LFS?

**Git Large File Storage (LFS)** is an open-source Git extension that replaces large files with text pointers inside Git, while storing the actual file contents on a remote server.

### How It Works

1. **Without LFS**:
   ```
   Git Repository
   └── large-file.bin (100 MB actual file stored in Git)
   ```

2. **With LFS**:
   ```
   Git Repository                    LFS Server
   └── large-file.bin (pointer)  →  └── actual-file.bin (100 MB)
   ```

The pointer file is tiny (~130 bytes) and looks like this:
```
version https://git-lfs.github.com/spec/v1
oid sha256:abc123...
size 104857600
```

### Benefits for Flatpak Repositories

- **Push succeeds**: Large OSTree objects bypass Git's file size limits
- **Faster clones**: Initial clone only downloads pointers
- **Efficient updates**: Only download changed LFS objects
- **GitHub compatibility**: Works seamlessly with GitHub Pages
- **No bandwidth waste**: Don't re-download unchanged large files

## Why Flatpak Repositories Need LFS

Flatpak repositories hosted on GitHub typically need LFS because:

1. **OSTree object files grow large**: Individual application objects can be 50-200 MB
2. **Multi-architecture support**: Each architecture (x86_64, aarch64) has its own objects
3. **Static deltas**: Pre-computed update deltas can be very large
4. **Accumulated history**: Repository grows with each version published
5. **GitHub's limits**: Free GitHub accounts have strict file size limits

### Which Files Need LFS?

In a Flatpak repository, these files commonly exceed 100 MB:

- `repo/objects/**/*.filez` - Compressed content objects (MOST COMMON)
- `repo/objects/**/*.file` - Uncompressed content objects (RARE)
- `repo/deltas/**/*` - Static delta files (OCCASIONAL)

Other files are typically small and don't need LFS:
- `repo/objects/**/*.commit` (< 1 KB)
- `repo/objects/**/*.dirtree` (< 10 KB)
- `repo/objects/**/*.dirmeta` (< 1 KB)
- `repo/refs/**/*` (< 1 KB)
- `repo/summary` (< 100 KB)

## Installation

### Debian/Ubuntu

```bash
sudo apt update
sudo apt install git-lfs
```

### Fedora

```bash
sudo dnf install git-lfs
```

### Arch Linux

```bash
sudo pacman -S git-lfs
```

### macOS

```bash
brew install git-lfs
```

### Verify Installation

```bash
git lfs version
# Output: git-lfs/3.6.1 (GitHub; linux amd64; go 1.23.2)
```

## Setting Up LFS for a New Repository

If you're creating a new Flatpak hosting repository from scratch:

### Step 1: Initialize Repository

```bash
# Create and clone your GitHub repository
cd ~/code
git clone git@github.com:username/flatpak-repo.git
cd flatpak-repo

# Initialize Git LFS in this repository
git lfs install
```

Output:
```
Updated Git hooks.
Git LFS initialized.
```

This command:
- Installs Git LFS hooks in `.git/hooks/`
- Updates `.git/config` with LFS settings
- Only needs to be run once per repository

### Step 2: Configure LFS Tracking

```bash
# Track large OSTree object files
git lfs track "repo/objects/**/*.filez"
git lfs track "repo/objects/**/*.file"

# Optional: Track delta files if you generate static deltas
git lfs track "repo/deltas/**/*"
```

Output:
```
Tracking "repo/objects/**/*.filez"
Tracking "repo/objects/**/*.file"
```

This creates/updates `.gitattributes`:
```
repo/objects/**/*.filez filter=lfs diff=lfs merge=lfs -text
repo/objects/**/*.file filter=lfs diff=lfs merge=lfs -text
```

### Step 3: Commit LFS Configuration

```bash
# Add the .gitattributes file
git add .gitattributes

# Create .gitignore for temporary files
cat > .gitignore << 'EOF'
repo/.lock
EOF

git add .gitignore
git commit -m "Configure Git LFS for OSTree objects"
git push origin main
```

### Step 4: Build and Add Your Application

```bash
# Build your application to this repository
cd ~/code/your-flatpak-app

flatpak-builder \
  --arch=x86_64 \
  --repo=~/code/flatpak-repo/repo \
  --gpg-sign=YOUR_GPG_KEY_ID \
  --force-clean \
  build-x86_64 \
  your.app.manifest.yaml

# Update repository
flatpak build-update-repo \
  --generate-static-deltas \
  --gpg-sign=YOUR_GPG_KEY_ID \
  ~/code/flatpak-repo/repo
```

### Step 5: Commit and Push with LFS

```bash
cd ~/code/flatpak-repo

# Stage all files (LFS will handle large files automatically)
git add repo/

# Commit
git commit -m "Add application to repository"

# Push (this will upload LFS objects)
git push origin main
```

Output will show LFS upload progress:
```
Uploading LFS objects: 100% (399/399), 147 MB | 5.8 MB/s, done.
Enumerating objects: 1028, done.
Counting objects: 100% (1028/1028), done.
Delta compression using up to 8 threads
Compressing objects: 100% (863/863), done.
Writing objects: 100% (1027/1027), 120.45 KiB | 8.03 MiB/s, done.
Total 1027 (delta 158), reused 0 (delta 0), pack-reused 0
```

Notice:
- **LFS objects uploaded first**: 399 files, 147 MB total
- **Git objects uploaded second**: Pointers and metadata only

## Converting an Existing Repository to LFS

If you already have a Flatpak repository pushed to GitHub and hit the file size error:

### The Situation We Encountered

```
# Initial attempt to push
git push origin main

# Error received:
remote: error: File repo/objects/77/ef3fc1eaff8a452cc66c9b5cb06271fb97fca4fa0c48365e90fd8aab8523fb.filez is 104.22 MB; this exceeds GitHub's file size limit of 100.00 MB
```

### Solution: Convert to LFS

#### Step 1: Check Repository State

```bash
cd ~/code/flatpak-repo

# Check what's staged or committed
git status
```

Output:
```
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```

This means we have a local commit that can't be pushed.

#### Step 2: Install and Initialize LFS

```bash
# Install Git LFS (if not already installed)
sudo apt install git-lfs

# Initialize LFS in this repository
git lfs install
```

#### Step 3: Undo the Problematic Commit (Soft Reset)

```bash
# Soft reset: undo commit but keep changes staged
git reset --soft HEAD~1

# Verify files are still staged
git status | head -20
```

Output shows files are still staged, just not committed:
```
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   .gitignore
	modified:   repo/config
	new file:   repo/objects/00/8ad5334843974d78a27e7bdd3b7b552be3d0c42a389f556f6a67f17ffee95c.filez
	new file:   repo/objects/01/f99c9cfc4e8511b177f0867dac4b27f13ee6d915306939e7c6d41e68ee4e4a.filez
	...
```

#### Step 4: Configure LFS Tracking

```bash
# Tell Git LFS which files to track
git lfs track "repo/objects/**/*.filez"
git lfs track "repo/objects/**/*.file"
```

This creates `.gitattributes`:
```
repo/objects/**/*.filez filter=lfs diff=lfs merge=lfs -text
repo/objects/**/*.file filter=lfs diff=lfs merge=lfs -text
```

#### Step 5: Unstage and Re-stage Files

This is the critical step that makes Git LFS take over:

```bash
# Unstage repo files
git reset HEAD repo/

# Stage .gitattributes first
git add .gitattributes

# Now re-stage repo files (LFS will handle them now)
git add repo/
```

When you run `git add repo/` after configuring `.gitattributes`, Git LFS:
1. Reads the `.gitattributes` patterns
2. Identifies matching large files
3. Uploads them to LFS storage
4. Creates pointer files in Git

#### Step 6: Commit with LFS

```bash
git commit -m "Add iCloud Services to repository with Git LFS"
```

Output shows LFS in action:
```
[main a4735e8] Add iCloud Services to repository with Git LFS
 863 files changed, 1209 insertions(+)
 create mode 100644 .gitattributes
 create mode 100644 .gitignore
 create mode 100644 repo/objects/00/8ad5334843974d78a27e7bdd3b7b552be3d0c42a389f556f6a67f17ffee95c.filez
 ...
```

#### Step 7: Push with LFS

```bash
git push origin main
```

Success! Output shows LFS upload:
```
Uploading LFS objects: 100% (399/399), 147 MB | 5.8 MB/s, done.
To github.com:santisbon/flatpak-repo.git
   ac5e935..a4735e8  main -> main
```

### Summary of What Happened

1. **Problem**: 104.22 MB file exceeded GitHub's 100 MB limit
2. **Solution**: Use Git LFS to store large files separately
3. **Process**:
   - Undo the failing commit (soft reset)
   - Configure LFS tracking patterns
   - Re-stage files so LFS processes them
   - Commit (creates pointers)
   - Push (uploads to LFS server)
4. **Result**: 399 LFS objects (147 MB) uploaded successfully

## Working with LFS Repositories

### Cloning an LFS Repository

```bash
# Standard clone (automatically fetches LFS objects)
git clone git@github.com:username/flatpak-repo.git

# The clone will:
# 1. Download Git repository (pointers)
# 2. Download LFS objects (actual files)
# 3. Replace pointers with actual files
```

### Cloning Without LFS Objects (Faster)

```bash
# Clone only pointers (much faster)
GIT_LFS_SKIP_SMUDGE=1 git clone git@github.com:username/flatpak-repo.git

# Later, fetch LFS objects when needed
cd flatpak-repo
git lfs pull
```

### Checking LFS Status

```bash
# See which files are tracked by LFS
git lfs ls-files

# Example output:
# 008ad533 * repo/objects/00/8ad5334843974d78a27e7bdd3b7b552be3d0c42a389f556f6a67f17ffee95c.filez
# 01f99c9c * repo/objects/01/f99c9cfc4e8511b177f0867dac4b27f13ee6d915306939e7c6d41e68ee4e4a.filez
```

```bash
# Check LFS storage usage
git lfs ls-files --size | sort -h -k 2

# Example output:
# 008ad533 * repo/objects/00/8ad533...filez (2.3 MB)
# ...
# 77ef3fc1 * repo/objects/77/ef3fc1...filez (104.2 MB)
```

### Updating LFS Files

When you add or modify large files:

```bash
# Modify/add files
flatpak-builder --repo=repo ...

# Stage changes (LFS handles automatically)
git add repo/

# Commit
git commit -m "Update application"

# Push (uploads new/changed LFS objects)
git push origin main
```

Git LFS only uploads:
- New LFS objects
- Changed LFS objects
- Doesn't re-upload unchanged files

### Fetching LFS Objects

```bash
# Fetch LFS objects for current commit
git lfs fetch

# Fetch and check out LFS objects
git lfs pull

# Fetch LFS objects for all refs
git lfs fetch --all
```

## Technical Details

### How Git LFS Stores Files

#### Without LFS

```bash
# Git stores the actual file content
$ ls -lh repo/objects/77/ef3fc1...filez
-rw-r--r-- 1 user user 104M Nov 9 10:00 repo/objects/77/ef3fc1...filez

# Git history contains full file
$ git show HEAD:repo/objects/77/ef3fc1...filez | wc -c
109252608  # 104 MB
```

#### With LFS

```bash
# Git stores a pointer file
$ cat repo/objects/77/ef3fc1...filez
version https://git-lfs.github.com/spec/v1
oid sha256:77ef3fc1eaff8a452cc66c9b5cb06271fb97fca4fa0c48365e90fd8aab8523fb
size 109252608

# Pointer is tiny
$ git show HEAD:repo/objects/77/ef3fc1...filez | wc -c
132  # 132 bytes

# Actual file stored in .git/lfs
$ ls -lh .git/lfs/objects/77/ef/77ef3fc1eaff8a452cc66c9b5cb06271fb97fca4fa0c48365e90fd8aab8523fb
-rw-r--r-- 1 user user 104M Nov 9 10:00 .git/lfs/objects/77/ef/77ef3fc1...
```

### Git LFS Storage Locations

#### Local Storage

```
your-repo/
├── .git/
│   ├── lfs/
│   │   └── objects/
│   │       └── 77/ef/
│   │           └── 77ef3fc1eaff8a452cc66c9b5cb06271fb97fca4fa0c48365e90fd8aab8523fb
│   └── hooks/
│       ├── pre-push (LFS hook)
│       └── post-checkout (LFS hook)
└── repo/
    └── objects/
        └── 77/
            └── ef3fc1...filez (pointer file in working directory)
```

#### Remote Storage (GitHub)

GitHub stores LFS objects separately from the Git repository:
- **Git repository**: `https://github.com/user/repo.git` (pointers)
- **LFS storage**: `https://github.com/user/repo.git/info/lfs` (actual files)

### The .gitattributes File

```gitattributes
repo/objects/**/*.filez filter=lfs diff=lfs merge=lfs -text
repo/objects/**/*.file filter=lfs diff=lfs merge=lfs -text
```

Breaking down each attribute:

- **`filter=lfs`**: Apply LFS clean/smudge filters
  - **Clean**: When staging files (`git add`), upload to LFS and create pointer
  - **Smudge**: When checking out files, replace pointer with actual content
- **`diff=lfs`**: Use LFS-aware diff (shows pointer changes, not full file diff)
- **`merge=lfs`**: Use LFS-aware merge (merges pointers, not file contents)
- **`-text`**: Treat as binary (don't perform text transformations)

### Git LFS Commands Used Behind the Scenes

When you run `git add repo/`:

```bash
# Git LFS clean filter (runs automatically)
git lfs clean repo/objects/77/ef3fc1...filez

# Outputs pointer to Git
# Uploads actual file to .git/lfs/objects/
```

When you run `git push origin main`:

```bash
# Git LFS pre-push hook (runs automatically)
git lfs pre-push origin refs/heads/main

# Uploads LFS objects to remote
# Then pushes Git objects (pointers)
```

When you run `git checkout` or `git clone`:

```bash
# Git LFS smudge filter (runs automatically)
git lfs smudge repo/objects/77/ef3fc1...filez

# Downloads actual file from LFS
# Replaces pointer with actual content
```

### Bandwidth and Storage Quotas

#### GitHub Free Accounts

- **Storage**: 1 GB LFS storage included
- **Bandwidth**: 1 GB/month bandwidth included
- **Additional**: $5/month for 50 GB storage + 50 GB bandwidth

#### Our Repository Usage

```bash
# Check total LFS storage used
git lfs ls-files --size | awk '{sum+=$2} END {print sum/1024/1024 " MB"}'

# Output: 147 MB (well within free tier)
```

For the iCloud Services repository:
- **399 LFS objects**: 147 MB total
- **Monthly bandwidth estimate**: ~2-5 GB (depends on download frequency)
- **Free tier**: Sufficient for small-to-medium user base

## Troubleshooting

### Error: "This exceeds GitHub's file size limit"

**Problem**: Pushing fails with file size error

**Solution**: Follow the "Converting an Existing Repository to LFS" section above

### Error: "git-lfs: command not found"

**Problem**: Git LFS not installed

**Solution**:
```bash
sudo apt install git-lfs  # Debian/Ubuntu
sudo dnf install git-lfs  # Fedora
```

### Files Not Tracked by LFS

**Problem**: Large files committed to Git instead of LFS

**Symptoms**:
```bash
git lfs ls-files  # Shows fewer files than expected
du -sh .git       # Git directory is huge
```

**Cause**: Files added before LFS was configured, or `.gitattributes` incorrect

**Solution**:
```bash
# Remove files from Git history and re-add with LFS
git rm --cached repo/objects/**/*.filez
git add repo/objects/**/*.filez
git commit -m "Migrate large files to LFS"
```

### LFS Pointer Files in Working Directory

**Problem**: After `git clone`, files show pointer content instead of actual files

**Example**:
```bash
$ cat repo/objects/77/ef3fc1...filez
version https://git-lfs.github.com/spec/v1
oid sha256:77ef3fc1...
size 109252608
```

**Cause**: LFS objects weren't downloaded

**Solution**:
```bash
# Download LFS objects
git lfs pull

# Verify
file repo/objects/77/ef3fc1...filez
# Output: repo/objects/77/ef3fc1...filez: data (should be binary, not text)
```

### Push is Slow

**Problem**: `git push` takes a very long time

**Cause**: Uploading large LFS objects

**Solution**: This is expected. LFS uploads can be slow (5-10 MB/s typical). Monitor progress:
```bash
git push origin main
# Uploading LFS objects: 45% (180/399), 67 MB | 5.2 MB/s
```

### Clone is Slow

**Problem**: `git clone` takes a long time

**Cause**: Downloading all LFS objects

**Solution**: Clone without LFS objects initially:
```bash
# Fast clone (pointers only)
GIT_LFS_SKIP_SMUDGE=1 git clone git@github.com:user/repo.git

# Download LFS objects later when needed
cd repo
git lfs pull
```

### "Exceeded LFS storage quota"

**Problem**: Push fails with quota error

**Cause**: Free tier 1 GB LFS storage exceeded

**Solutions**:
1. **Upgrade to paid plan**: $5/month for 50 GB
2. **Clean old objects**:
   ```bash
   # Remove old versions from LFS
   git lfs prune
   ```
3. **Use alternative hosting**: GitLab offers 10 GB LFS storage free

### Migrating Repository to LFS

**Problem**: Need to convert entire repository history to use LFS

**Solution**: Use `git lfs migrate`

```bash
# Migrate all .filez files in history to LFS
git lfs migrate import --include="*.filez" --everything

# Push migrated history
git push origin main --force  # WARNING: Rewrites history!
```

**Warning**: This rewrites Git history. Only do this if:
- Repository is new/private
- No one else has cloned it
- You understand the implications

## Best Practices

### 1. Track LFS Patterns Early

Configure `.gitattributes` BEFORE building your Flatpak repository:

```bash
# First: Set up LFS
git lfs install
git lfs track "repo/objects/**/*.filez"
git add .gitattributes
git commit -m "Configure LFS"

# Then: Build your Flatpak
flatpak-builder --repo=repo ...
```

### 2. Use Specific Patterns

Be specific about what files to track with LFS:

**Good**:
```gitattributes
repo/objects/**/*.filez filter=lfs diff=lfs merge=lfs -text
repo/objects/**/*.file filter=lfs diff=lfs merge=lfs -text
```

**Bad**:
```gitattributes
repo/** filter=lfs diff=lfs merge=lfs -text  # Too broad!
```

Tracking everything with LFS:
- Wastes LFS storage on small files
- Slows down operations
- Costs more bandwidth

### 3. Check File Sizes Before Committing

```bash
# Find files over 50 MB
find repo/objects -type f -size +50M

# Check specific file size
ls -lh repo/objects/77/ef3fc1...filez
```

If files over 50 MB aren't tracked by LFS, add them to `.gitattributes`.

### 4. Don't Commit `.git/lfs`

Your `.gitignore` should NOT exclude `.git/lfs` because:
- `.git/` is already excluded by Git automatically
- You never commit `.git/` contents

### 5. Document LFS in README

Include LFS setup in your repository README:

```markdown
## For Developers

This repository uses Git LFS. To clone:

\`\`\`bash
git clone git@github.com:user/repo.git
cd repo
git lfs install
git lfs pull
\`\`\`
```

### 6. Monitor LFS Usage

Regularly check your LFS usage:

```bash
# Local LFS size
du -sh .git/lfs

# Number of LFS objects
git lfs ls-files | wc -l

# Total LFS storage
git lfs ls-files --size | awk '{sum+=$2} END {print sum/1024/1024 " MB"}'
```

### 7. Prune Old LFS Objects

After major updates, clean up:

```bash
# Remove LFS objects not referenced by current branches
git lfs prune

# Show what would be pruned (dry run)
git lfs prune --dry-run
```

### 8. Use LFS for OSTree Only

Don't track your entire repository with LFS. Only track:
- `repo/objects/**/*.filez`
- `repo/objects/**/*.file`
- `repo/deltas/**/*` (optional)

Don't track:
- Source code
- Build scripts
- Documentation
- Small config files

## Summary

### Quick Reference

**Install**:
```bash
sudo apt install git-lfs
```

**Initialize**:
```bash
git lfs install
```

**Track files**:
```bash
git lfs track "repo/objects/**/*.filez"
git lfs track "repo/objects/**/*.file"
```

**Commit .gitattributes**:
```bash
git add .gitattributes
git commit -m "Configure Git LFS"
```

**Work normally**:
```bash
git add repo/
git commit -m "Add application"
git push origin main  # LFS uploads automatically
```

**Clone**:
```bash
git clone git@github.com:user/repo.git  # LFS downloads automatically
```

### What We Accomplished

1. **Problem**: 104.22 MB file exceeded GitHub's 100 MB limit
2. **Solution**: Implemented Git LFS
3. **Process**:
   - Installed Git LFS
   - Configured `.gitattributes` to track `.filez` and `.file` patterns
   - Reset problematic commit
   - Re-staged files with LFS handling
   - Successfully pushed 399 LFS objects (147 MB total)
4. **Result**: Flatpak repository successfully hosted on GitHub Pages with automatic updates

### Resources

- [Git LFS Official Site](https://git-lfs.github.com/)
- [Git LFS Tutorial](https://github.com/git-lfs/git-lfs/wiki/Tutorial)
- [GitHub LFS Documentation](https://docs.github.com/en/repositories/working-with-files/managing-large-files)
- [Git LFS Specification](https://github.com/git-lfs/git-lfs/blob/main/docs/spec.md)
- [OSTree Documentation](https://ostreedev.github.io/ostree/)
