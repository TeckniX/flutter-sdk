#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'
require 'digest'

def fetch_url(url)
  uri = URI(url)
  Net::HTTP.get(uri)
end

def get_expected_checksum(url)
  case url
  when /flutter_macos_.*\.zip/
    platform = 'macos'
  when /flutter_linux_.*\.tar\.xz/
    platform = 'linux'
  else
    raise "Unknown URL pattern: #{url}"
  end

  releases_url = "https://storage.googleapis.com/flutter_infra_release/releases/releases_#{platform}.json"
  releases_json = JSON.parse(fetch_url(releases_url))
  
  # Extract filename from URL
  filename = File.basename(url)
  
  # Find matching release
  release = releases_json['releases'].find { |r| r['archive']&.include?(filename) }
  release ? release['sha256'] : nil
end

def download_and_verify(url, expected_sha)
  puts "Downloading: #{url}"
  
  # Download file
  content = fetch_url(url)
  actual_sha = Digest::SHA256.hexdigest(content)
  
  puts "Expected SHA256: #{expected_sha}"
  puts "Actual SHA256:   #{actual_sha}"
  
  if actual_sha == expected_sha
    puts "✅ Checksum verified"
    return true
  else
    puts "❌ Checksum mismatch!"
    return false
  end
rescue => e
  puts "❌ Error downloading/verifying: #{e.message}"
  return false
end

def main
  puts "Verifying checksums in flutter-sdk.rb..."
  
  formula_content = File.read('Formula/flutter-sdk.rb')
  
  # Extract all URLs and their associated SHA256 values
  url_pattern = /url\s+"([^"]+)"/
  sha_pattern = /sha256\s+"([^"]+)"/
  
  urls = formula_content.scan(url_pattern).flatten
  shas = formula_content.scan(sha_pattern).flatten
  
  if urls.size != shas.size
    puts "❌ Mismatch between number of URLs (#{urls.size}) and SHA256 values (#{shas.size})"
    exit 1
  end
  
  all_valid = true
  
  urls.each_with_index do |url, index|
    puts "\n--- Checking #{url} ---"
    
    # Get expected checksum from Flutter releases
    expected_sha = get_expected_checksum(url)
    formula_sha = shas[index]
    
    if expected_sha != formula_sha
      puts "❌ Formula SHA256 doesn't match expected from Flutter releases"
      puts "   Formula: #{formula_sha}"
      puts "   Expected: #{expected_sha}"
      all_valid = false
      next
    end
    
    # Verify actual download matches checksum
    unless download_and_verify(url, formula_sha)
      all_valid = false
    end
  end
  
  puts "\n=== Summary ==="
  if all_valid
    puts "✅ All checksums verified successfully"
    exit 0
  else
    puts "❌ Some checksums failed verification"
    exit 1
  end
  
rescue => e
  puts "❌ Verification failed: #{e.message}"
  exit 1
end

main