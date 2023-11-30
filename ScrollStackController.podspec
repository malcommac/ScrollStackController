Pod::Spec.new do |s|
  s.name         = "ScrollStackController"
  s.version      = "1.6.0"
  s.summary      = "Create complex scrollable layout using UIViewController and simplify your code"
  s.homepage     = "https://github.com/malcommac/ScrollStackController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniele Margutti" => "hello@danielemargutti.com" }
  s.social_media_url   = "http://www.twitter.com/danielemargutti"
  s.ios.deployment_target = "11.0"
  s.source       = { :git => "https://github.com/malcommac/ScrollStackController.git", :tag => s.version.to_s }
  s.frameworks  = "Foundation", "UIKit"
  s.source_files = 'Sources/**/*.swift'
  s.swift_versions = ['5.0', '5.1', '5.3', '5.4', '5.5', '5.7', '5.8', '5.9']
end
