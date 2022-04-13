#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'kommunicate_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Kommunicate live chat.'
  s.description      = <<-DESC
Flutter plugin for Kommunicate live chat.
                       DESC
  s.homepage         = 'https://kommunicate.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Kommunicate' => 'ashish@kommunicate.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  s.dependency 'Flutter'
  s.swift_version = '5.1'
  s.dependency 'Kommunicate', '~> 6.6.0'

  s.ios.deployment_target = '12.0'
end

