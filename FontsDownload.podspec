Pod::Spec.new do |s|

  s.name         = "FontsDownload"
  s.version      = "1.0"
  s.summary      = "远程下载字体"
  s.description  = <<-DESC
        远程下载字体并显示效果
                   DESC

  s.homepage     = "https://github.com/Lang-FZ/FontsDownload"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT (FontsDownload)"
  # s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "LangFZ" => "446003664@qq.com" }
  # Or just: s.author    = "LangFZ"
  # s.authors            = { "LangFZ" => "446003664@qq.com" }
  # s.social_media_url   = "http://twitter.com/LangFZ"

  # s.platform     = :ios
  s.platform     = :ios, "5.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/Lang-FZ/FontsDownload.git", :tag => "#{s.version}" }

  s.source_files  = "FontsDownload", "FontsDownload/FontsDownloadController/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  #s.public_header_files = "FontsDownload/Header.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "MBProgressHUD"

end
