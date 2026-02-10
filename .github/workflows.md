# GitHub Actions Workflows

This repository includes several automated workflows to ensure the Flutter SDK Homebrew formula is always up-to-date and working correctly.

## Workflows

### 1. Test Formula (`test-formula.yml`)

**Triggers:** Push to main/master, pull requests, manual dispatch

**What it does:**
- Runs on both Ubuntu and macOS
- Validates formula with `brew audit` and `brew style`
- Installs the formula from source
- Tests Flutter installation and basic functionality
- Tests project creation with `flutter create`
- Cleans up by uninstalling

**Purpose:** Ensures formula changes don't break installation or basic Flutter functionality.

### 2. Update Flutter Version (`update-flutter.yml`)

**Triggers:** Daily at 9 AM UTC, manual dispatch

**What it does:**
- Checks official Flutter release feeds for new stable versions
- Compares with current formula version
- If new version found:
  - Downloads SHA256 checksums for all platforms (macOS Intel, macOS ARM64, Linux)
  - Updates formula with new version and checksums
  - Creates a pull request with the changes

**Purpose:** Automatically keeps the formula updated with latest Flutter stable releases.

### 3. Verify Checksums (`verify-checksums.yml`)

**Triggers:** Changes to Formula file, pull requests, manual dispatch

**What it does:**
- Extracts URLs and SHA256 values from formula
- Downloads actual binaries from Flutter's storage
- Verifies checksums match both formula and official releases
- Tests installation on both Ubuntu and macOS

**Purpose:** Ensures all binary downloads are secure and match official Flutter releases.

### 4. Release (`release.yml`)

**Triggers:** Git tags starting with 'v'

**What it does:**
- Runs comprehensive tests before releasing
- Creates GitHub release with installation instructions
- Ensures tagged releases are properly tested

**Purpose:** Manages official releases of the tap.

## Automation Benefits

1. **Always Up-to-Date:** Automatically detects new Flutter stable releases
2. **Security:** Verifies all binary checksums against official releases
3. **Cross-Platform:** Tests on both Ubuntu and macOS environments
4. **Quality Gates:** Prevents broken formulas from being merged
5. **Easy Updates:** Pull requests are created automatically for version updates

## Scripts

The workflows use Ruby scripts in `.github/scripts/`:

- `check_flutter_release.rb`: Checks for new Flutter releases
- `update_formula.rb`: Updates formula with new version/checksums
- `verify_checksums.rb`: Downloads and verifies binary checksums

These scripts are designed to run on GitHub Actions runners with Ruby pre-installed.

## Manual Triggers

All workflows can be triggered manually from the GitHub Actions tab, allowing you to:
- Re-run tests if needed
- Force check for updates
- Verify checksums manually
- Create releases on demand