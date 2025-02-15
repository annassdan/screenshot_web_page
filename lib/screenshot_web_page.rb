require "rbconfig"
class ScreenshotWebPage
  VENDOR_DIR = "vendor"

  def self.of(url)
    begin
      download_path = File.join(gem_root, VENDOR_DIR)
      puts gem_root
      where_chrome = File.join(download_path, "chrome-#{os_type}")

      puts where_chrome
      unless Dir.exist?(where_chrome)
        ScreenshotWebPage.download_chromium
      end

      require "puppeteer-ruby"
      require 'securerandom'
      screenshot_path = "tmp/#{SecureRandom.hex(15)}.png"

      Puppeteer.launch(
        headless: false,
        executable_path: chromium_binary,
        args: ["--start-maximized"]
      ) do |browser|
        page = browser.new_page
        page.goto(url)

        sleep 3
        page.screenshot(path: screenshot_path)
      end

      screenshot_path
    rescue Exception => e
      nil
    end
  end


  def self.download_chromium
    download_path = File.join(gem_root, VENDOR_DIR)

    if Dir.exist?(File.join(download_path, "chrome-#{os_type}"))
      puts "Chrome already downloaded!"
      return
    end

    chrome_download_url, zip_name = chromium_url_path
    zip_path = File.join(download_path, zip_name)

    total_size = nil
    downloaded = 0
    # Open the URL with progress callbacks
    URI.open(
      chrome_download_url,
      content_length_proc: lambda { |t| total_size = t },
      progress_proc: lambda { |s|
        downloaded = s
        if total_size && total_size > 0
          percent = (downloaded.to_f / total_size * 100).round
          downloaded_mb = (downloaded.to_f / (1024 * 1024)).round(2)
          total_size_mb  = (total_size.to_f / (1024 * 1024)).round(2)
          print "\rDownloading Chromium #{downloaded_mb} MB of #{total_size_mb} MB (#{percent}%)..."
        else
          print "\rDownloaded #{downloaded} bytes"
        end
      }
    ) do |remote_file|
      File.open(zip_path, "wb") do |file|
        # Read in 1024-byte chunks to allow progress updates
        while chunk = remote_file.read(1024)
          file.write(chunk)
        end
      end
    end
    #
    puts "\nExtracting..."

    system("unzip -o #{zip_path} -d #{download_path}")
    File.delete(zip_path)
    puts "Chrome has been downloaded and extracted to #{download_path}"
  end

  private

  def self.gem_root
    File.expand_path('..', __dir__)
  end

  def self.os_type
    host_os = RbConfig::CONFIG["host_os"]

    if host_os =~ /darwin/
      "mac"
    elsif host_os =~ /linux/
      "linux"
    else
      raise "Unsupported OS: #{host_os.inspect}"
    end
  end

  def self.chromium_binary
    host_os = RbConfig::CONFIG["host_os"]
    if host_os =~ /darwin/
      File.join(gem_root, VENDOR_DIR, "chrome-mac", "Chromium.app", "Contents", "MacOS", "Chromium")
    elsif host_os =~ /linux/
      File.join(gem_root, VENDOR_DIR, "chrome-linux", "chrome")
    else
      nil
    end
  end

  def self.chromium_url_path
    host_os = RbConfig::CONFIG["host_os"]
    host_cpu = RbConfig::CONFIG["host_cpu"]

    if host_os =~ /darwin/
      if host_cpu =~ /arm/
        %w[https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Mac_Arm%2F1361663%2Fchrome-mac.zip?generation=1727674802927137&alt=media Mac_Arm_1361663_chrome-mac.zip]
      elsif host_cpu =~ /x86/
        %w[https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Mac%2F1361662%2Fchrome-mac.zip?generation=1727674461536805&alt=media Mac_1361662_chrome-mac.zip]
      else
        raise "Unsupported OS: #{host_cpu.inspect}"
      end
    elsif host_os =~ /linux/
      # if host_cpu =~ /x86_64/
      # elsif host_cpu =~ /arm/ || host_cpu =~ /aarch64/
      # else
      #   raise "Unsupported OS: #{host_cpu.inspect}"
      # end
      %w[https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1361662%2Fchrome-linux.zip?generation=1727674543920044&alt=media Linux_1361662_chrome-linux.zip]
    else
      nil
    end
  end


end