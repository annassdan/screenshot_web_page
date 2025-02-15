require 'rake'

namespace :download do

  desc "Download chromium binary"
  task :chromium do
    ScreenshotWebPage.download_chromium
  end

end

task :default => "download:chromium"