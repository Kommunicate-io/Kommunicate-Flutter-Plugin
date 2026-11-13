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
  s.source_files = 'kommunicate_flutter/Sources/kommunicate_flutter/**/*.swift'

  s.dependency 'Flutter'
  s.swift_version = '5.1'
  # CocoaPods trunk stops at 7.3.6; 7.3.8+ is available only via Swift Package Manager.
  s.dependency 'Kommunicate', '~> 7.3.6'


  s.ios.deployment_target = '13.0'
end

