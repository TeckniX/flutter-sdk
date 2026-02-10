#!/usr/bin/env ruby

require 'fileutils'

def update_formula(new_version, macos_x64_sha, macos_arm64_sha, linux_sha)
  formula_path = 'Formula/flutter-sdk.rb'
  
  # Read current formula
  content = File.read(formula_path)
  
  # Update version
  content.gsub!(/version\s+"[^"]+"/, "version \"#{new_version}\"")
  
  # Update macOS Intel URL and SHA
  macos_intel_url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_#{new_version}-stable.zip"
  content.gsub!(/url\s+"https:\/\/storage\.googleapis\.com\/flutter_infra_release\/releases\/stable\/macos\/flutter_macos_[^"]*"/, "url \"#{macos_intel_url}\"")
  
  # Update macOS Intel SHA
  content.gsub!(/sha256\s+"[^"]*"/.match(/sha256\s+"[^"]*"/)[0].split("\n")[0], "sha256 \"#{macos_x64_sha}\"")
  
  # Update Apple Silicon section
  if content.include?('Hardware::CPU.arm?')
    # Update ARM64 URL
    macos_arm_url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_#{new_version}-stable.zip"
    content.gsub!(/url\s+"https:\/\/storage\.googleapis\.com\/flutter_infra_release\/releases\/stable\/macos\/flutter_macos_arm64_[^"]*"/, "url \"#{macos_arm_url}\"")
    
    # Update ARM64 SHA
    content.gsub!(/sha256\s+"[^"]*"/.match(/sha256\s+"[^"]*"/)[0].split("\n")[1], "sha256 \"#{macos_arm64_sha}\"")
  end
  
  # Update Linux URL and SHA
  linux_url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_#{new_version}-stable.tar.xz"
  content.gsub!(/url\s+"https:\/\/storage.googleapis\.com\/flutter_infra_release\/releases\/stable\/linux\/flutter_linux_[^"]*"/, "url \"#{linux_url}\"")
  content.gsub!(/sha256\s+"[^"]*"/.match(/sha256\s+"[^"]*"/)[0].split("\n")[-1], "sha256 \"#{linux_sha}\"")
  
  # Write updated formula
  File.write(formula_path, content)
  
  puts "✅ Updated formula to Flutter #{new_version}"
  puts "  macOS Intel SHA256: #{macos_x64_sha}"
  puts "  macOS ARM64 SHA256: #{macos_arm64_sha}" if macos_arm64_sha
  puts "  Linux SHA256: #{linux_sha}"
end

def main
  if ARGV.length != 4
    puts "Usage: #{$0} <version> <macos-x64-sha> <macos-arm64-sha> <linux-sha>"
    exit 1
  end
  
  new_version = ARGV[0]
  macos_x64_sha = ARGV[1]
  macos_arm64_sha = ARGV[2]
  linux_sha = ARGV[3]
  
  update_formula(new_version, macos_x64_sha, macos_arm64_sha, linux_sha)
end

main