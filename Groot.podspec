Pod::Spec.new do |s|
  s.name         = "Groot"
  s.version      = "3.0.1"
  s.summary      = "From JSON to Core Data and back."

  s.description  = <<-DESC
                   With Groot you can convert JSON dictionaries and arrays into Core Data object graphs.
                   DESC

  s.homepage     = "https://github.com/gonzalezreal/Groot"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  
  s.author             = { "Guillermo Gonzalez" => "gonzalezreal@icloud.com" }
  s.social_media_url   = "https://twitter.com/gonzalezreal"
  
  s.source       = { :git => "https://github.com/gonzalezreal/Groot.git", :tag => s.version.to_s }
  
  s.default_subspec = "Swift"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  
  s.subspec "Swift" do |ss|
    ss.ios.deployment_target = "8.0"
    ss.osx.deployment_target = "10.9"
    
    ss.source_files  = "Groot/**/*.{swift,h,m}"
    ss.private_header_files = "Groot/Private/*.h"
  end
  
  s.subspec "ObjC" do |ss|
    ss.ios.deployment_target = "6.0"
    ss.osx.deployment_target = "10.8"
    
    ss.source_files  = "Groot/**/*.{h,m}"
    ss.private_header_files = "Groot/Private/*.h"
  end
  
  s.frameworks = "Foundation", "CoreData"
  s.requires_arc = true
end
