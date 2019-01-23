Pod::Spec.new do |s|
  s.name         = "GSRefresh"
  s.version      = "0.5.2"
  s.summary      = "Fully customizable drop-down refresh and load more."

  s.homepage     = "https://github.com/wxxsw/GSRefresh"
  s.license      = "MIT"

  s.author       = { "Gesen" => "i@gesen.me" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/wxxsw/GSRefresh.git", :tag => s.version.to_s }
  s.source_files  = "Sources/*.swift"
  # s.exclude_files = "Classes/Exclude

  s.requires_arc = true

  s.swift_version = "4.2"
end
