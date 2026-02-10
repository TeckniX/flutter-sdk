class FlutterSdk < Formula
  desc "UI toolkit for building applications for mobile, web, and desktop"
  homepage "https://flutter.dev"
  license "BSD-3-Clause"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.38.9-stable.zip"
      sha256 "5a9f29d40d5b932ff495d568125b1b22814920003e6c4be7f89ee7e652936098"
    else
      url "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.38.9-stable.zip"
      sha256 "ab8b66c8a95ffb7c52cd21bb7fd79dfeba6904c1353cff0a2637782fd970c1d4"
    end
  else
    url "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.38.9-stable.tar.xz"
    sha256 "cb39eeb717c7d7dce95736b862cada2fdedeebcbb0107c44a346659c77031003"
  end

  version "3.38.9"

  depends_on "dart" => :optional

  def install
    # Extract the archive to prefix
    if OS.mac?
      system "unzip", "-q", cached_download, "-d", prefix
      # Move contents up one level if nested
      if (prefix/"flutter").exist?
        (prefix/"flutter").children.each { |child| child.rename(prefix/child.basename) }
        rmdir prefix/"flutter"
      end
    else
      system "tar", "-xf", cached_download, "-C", prefix, "--strip-components=1"
    end

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
