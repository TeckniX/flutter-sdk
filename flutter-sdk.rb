class FlutterSdk < Formula
  desc "UI toolkit for building applications for mobile, web, and desktop"
  homepage "https://flutter.dev"
  url "https://github.com/flutter/flutter.git",
      branch: "stable",
      revision: "c519ee916eaeb88923e67befb89c0f1dab83a6a1"
  version "3.27.0"
  license "BSD-3-Clause"

  depends_on "git" => :build
  depends_on "dart" => :optional

  def install
    # Clone the repository to the Cellar path
    system "git", "clone", "https://github.com/flutter/flutter.git", 
           "-b", "stable", "--depth", "1", prefix

    # Remove .git directory to save space
    rm_rf prefix/".git"

    # Make flutter executable
    chmod 0755, prefix/"bin/flutter"

    # Create bin directory and symlink flutter executable
    bin.install_symlink prefix/"bin/flutter"

    # Add flutter to PATH in shell configuration if needed
    ohai "Flutter SDK installed to: #{opt_prefix}"
  end

  def post_install
    # Run flutter doctor to verify installation
    system "#{bin}/flutter", "doctor", "-v"
  end

  def caveats
    <<~EOS
      Flutter SDK has been installed to:
        #{opt_prefix}

      To use Flutter, add the following to your shell configuration file (~/.zshrc or ~/.bash_profile):
        export PATH="#{opt_prefix}/bin:$PATH"

      For Android development, ensure you have:
        - Android Studio installed
        - Android SDK configured
        - Accept Android licenses: flutter doctor --android-licenses

      For iOS development on macOS, ensure you have:
        - Xcode installed
        - CocoaPods installed: brew install cocoapods

      Run 'flutter doctor' to check for any additional dependencies.
    EOS
  end

  test do
    system "#{bin}/flutter", "--version"
    assert_match "Flutter", shell_output("#{bin}/flutter --version")
  end
end
