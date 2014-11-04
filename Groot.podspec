Pod::Spec.new do |s|
  s.name         = "Groot"
  s.version      = "0.2"
  s.summary      = "From JSON to Core Data and back."

  s.description  = <<-DESC
                   With Groot you can convert JSON dictionaries and arrays into Core Data object graphs.
                   DESC

  s.homepage     = "https://github.com/gonzalezreal/Groot"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  
  s.author             = { "Guillermo Gonzalez" => "gonzalezreal@icloud.com" }
  s.social_media_url   = "https://twitter.com/gonzalezreal"

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'

  s.source       = { :git => "https://github.com/gonzalezreal/Groot.git", :tag => s.version.to_s }

  s.source_files  = "Groot/**/*.{h,m}"
  s.private_header_files = "Groot/Private/*.h"

  s.frameworks = 'Foundation', 'CoreData'

  s.requires_arc = true
end
