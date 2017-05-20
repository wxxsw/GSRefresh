Pod::Spec.new do |s|
  s.name         = "GSRefresh"
  s.version      = "0.0.1"
  s.summary      = "Fully customizable drop-down refresh and load more. (WIP)"

  s.homepage     = "https://github.com/wxxsw/GSRefresh"
  s.license      = "MIT"

  s.author       = { "GeSen" => "i@gesen.me" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/wxxsw/GSRefresh.git", :commit => s.version.to_s }
  s.source_files  = "Sources/*.swift"
  # s.exclude_files = "Classes/Exclude

  s.dependency "GSSwift", "~> 0.0.1"

  s.requires_arc = true
end
