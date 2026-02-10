#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'

def fetch_releases(platform)
  url = case platform
         when 'macos'
           'https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json'
         when 'linux'
           'https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json'
         else
           raise "Unknown platform: #{platform}"
         end

  uri = URI(url)
  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

def get_latest_stable_release(platform)
  releases = fetch_releases(platform)
  stable_releases = releases['releases'].select { |r| r['channel'] == 'stable' }
  stable_releases.max_by { |r| Gem::Version.new(r['version']) }
end

def get_current_version
  formula_content = File.read('Formula/flutter-sdk.rb')
  match = formula_content.match(/version\s+"([^"]+)"/)
  match ? match[1] : nil
end

def main
  puts "Checking for Flutter updates..."

  # Get current version from formula
  current_version = get_current_version
  puts "Current version: #{current_version}"

  # Get latest stable releases
  macos_release = get_latest_stable_release('macos')
  linux_release = get_latest_stable_release('linux')

  # They should have the same version
  latest_version = macos_release['version']
  puts "Latest version: #{latest_version}"

  # Compare versions
  needs_update = Gem::Version.new(latest_version) > Gem::Version.new(current_version)

  if needs_update
    puts "⚡ New version available: #{latest_version}"

    # Get the latest stable releases with proper architecture info
    macos_releases = fetch_releases('macos')['releases']
    linux_releases = fetch_releases('linux')['releases']

    # Find specific releases for current version
    macos_x64 = macos_releases.find { |r| r['version'] == latest_version && r['dart_sdk_arch'] == 'x64' && r['channel'] == 'stable' }
    macos_arm64 = macos_releases.find { |r| r['version'] == latest_version && r['dart_sdk_arch'] == 'arm64' && r['channel'] == 'stable' }
    linux_x64 = linux_releases.find { |r| r['version'] == latest_version && r['dart_sdk_arch'] == 'x64' && r['channel'] == 'stable' }

    if macos_x64 && macos_arm64 && linux_x64
      # Set GitHub Actions outputs
      File.open(File::ENV['GITHUB_OUTPUT'], 'a') do |f|
        f.puts "needs-update=true"
        f.puts "new-version=#{latest_version}"
        f.puts "macos-x64-sha=#{macos_x64['sha256']}"
        f.puts "macos-arm64-sha=#{macos_arm64['sha256']}"
        f.puts "linux-sha=#{linux_x64['sha256']}"
      end
      puts "✅ Found release data for all platforms"
    else
      puts "❌ Could not find complete release data for version #{latest_version}"
      File.open(File::ENV['GITHUB_OUTPUT'], 'a') do |f|
        f.puts "needs-update=false"
      end
    end
  else
    puts "✅ Up to date"
    File.open(File::ENV['GITHUB_OUTPUT'], 'a') do |f|
      f.puts "needs-update=false"
    end
  end
rescue => e
  puts "❌ Error: #{e.message}"
  File.open(File::ENV['GITHUB_OUTPUT'], 'a') do |f|
    f.puts "needs-update=false"
  end
  exit 1
end

main