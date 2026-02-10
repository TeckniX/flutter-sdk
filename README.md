# Flutter SDK Homebrew Formula

This repository contains a Homebrew formula for installing the Flutter SDK on macOS and Linux systems.

## What is Flutter?

Flutter is Google's UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.

## Installation

### Option 1: Install from this repository

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/flutter-sdk.git
   cd flutter-sdk
   ```

2. Install the formula:
   ```bash
   brew install --build-from-source ./flutter-sdk.rb
   ```

### Option 2: Install from a tap (if published)

```bash
brew tap TeckniX/flutter-sdk
brew install flutter-sdk
```

## Post-Installation Setup

After installation, you need to add Flutter to your PATH. Add the following line to your shell configuration file:

- For bash (`~/.bash_profile` or `~/.bashrc`):
  ```bash
  export PATH="$(brew --prefix flutter-sdk)/bin:$PATH"
  ```

- For zsh (`~/.zshrc`):
  ```bash
  export PATH="$(brew --prefix flutter-sdk)/bin:$PATH"
  ```

Reload your shell configuration:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Verify Installation

Check that Flutter is properly installed:

```bash
flutter --version
flutter doctor
```

## Development Dependencies

### For Android Development
- Android Studio
- Android SDK
- Accept Android licenses:
  ```bash
  flutter doctor --android-licenses
  ```

### For iOS Development (macOS only)
- Xcode
- CocoaPods:
  ```bash
  brew install cocoapods
  ```

## Usage Examples

### Create a new Flutter project
```bash
flutter create my_app
cd my_app
flutter run
```

### Run on different platforms
```bash
# Run on connected device/emulator
flutter run

# Run on web
flutter run -d chrome

# Run on desktop (if configured)
flutter run -d macos  # macOS
flutter run -d windows  # Windows
flutter run -d linux  # Linux
```

### Build for production
```bash
# Build APK for Android
flutter build apk

# Build IPA for iOS
flutter build ios

# Build web application
flutter build web
```

## Troubleshooting

### Common Issues

1. **Flutter command not found**
   - Ensure Flutter is in your PATH
   - Restart your terminal after updating shell configuration

2. **Doctor reports missing dependencies**
   - Run `flutter doctor` to see what's missing
   - Install the missing components as suggested

3. **Android licenses not accepted**
   - Run `flutter doctor --android-licenses` and accept all licenses

4. **iOS development setup issues**
   - Ensure Xcode is installed from the App Store
   - Run `sudo xcode-select --install` if command line tools are missing
   - Install CocoaPods: `brew install cocoapods`

### Getting Help

- Run `flutter doctor` for a comprehensive health check
- Check the [official Flutter documentation](https://flutter.dev/docs)
- Visit [Flutter GitHub issues](https://github.com/flutter/flutter/issues) for known problems

## Formula Details

This Homebrew formula:
- Downloads Flutter from the official GitHub repository (stable branch)
- Installs to the Homebrew prefix
- Symlinks the Flutter executable to your PATH
- Runs `flutter doctor` during post-installation to verify setup
- Includes a basic test to ensure installation works

## Contributing

If you find issues with this formula or want to improve it:

1. Fork this repository
2. Make your changes
3. Test the formula: `brew install --build-from-source ./flutter-sdk.rb`
4. Submit a pull request

## License

This formula follows the same BSD-3-Clause license as Flutter itself.

## Uninstall

To remove Flutter installed via this formula:

```bash
brew uninstall flutter-sdk
```

If you installed from a tap, you can also remove the tap:

```bash
brew untap your-username/flutter-sdk
```
