Pod::Spec.new do |spec|
  spec.name         = "RPLPagedView"
  spec.version      = "0.1"
  spec.summary      = "RPLPagedView is a simple gallery"
  spec.homepage     = "https://github.com/mikk22/RPLPagedView"
  spec.license      = 'none'
  spec.author       = { "Mihail Koltsov" => "mikk.22@gmail.com" }
  spec.platform     = :ios, '6.0'
  spec.source       = { :git => "https://github.com/mikk22/RPLPagedView.git", :tag => spec.version.to_s }
  spec.source_files  = 'RPLPagedView/*.{h,m}'
  spec.public_header_files = 'RPLPagedView/*.h'
  spec.frameworks    = 'UIKit'
  spec.requires_arc = true
end
