Pod::Spec.new do |s|
  s.name             = 'MultiColorBlock'
  s.version          = '0.1.0'
  s.summary          = 'MultiColorBlock library is used to recognize the priority of daily task with simple color code.'
  #s.description      = <<-DESC
  s.homepage         = 'https://github.com/nfasate/MultiColorBlock'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nfasate' => 'nfasate@github.com' }
  s.source           = { :git => 'https://github.com/nfasate/MultiColorBlock.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MultiColorBlock/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MultiColorBlock' => ['MultiColorBlock/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
