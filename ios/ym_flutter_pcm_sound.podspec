#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_pcm_sound.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ym_flutter_pcm_sound'
  s.version          = '2.0.0'
  s.summary          = 'Flutter plugin for PCM sound'
  s.description      = 'Flutter plugin for PCM sound'
  s.homepage         = 'https://github.com/yashmanghnani/ym_flutter_pcm_sound'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Chip Weinberger' => 'weinbergerc@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.frameworks = 'AudioToolbox', 'AVFoundation'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', }
end
