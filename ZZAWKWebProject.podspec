Pod::Spec.new do |s|
  s.name             = 'ZZAWKWebProject'
  s.version          = '0.1.3'
  s.summary          = 'A short description of ZZAWKWebProject.'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/linkking/ZZAWKWeb'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'linkking' => 'zhulei@oradt.com' }
  s.source           = { :git => 'https://github.com/linkking/ZZAWKWeb.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZZAWKWebProject/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZZAWKWebProject' => ['ZZAWKWebProject/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
