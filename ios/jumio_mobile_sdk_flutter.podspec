require "yaml"

pubspec = YAML.load_file('../pubspec.yaml')

Pod::Spec.new do |s|
  s.name         = pubspec["name"]
  s.version      = pubspec["version"]
  s.summary      = pubspec["description"]
  s.description  = "Jumio Mobile SDK for Flutter"
  s.homepage     = pubspec["homepage"]
  s.license      = pubspec["license"]
  s.authors      = { "Jumio Corporation" => "support@jumio.com" }
  s.platforms    = { :ios => "11.0" }
  s.source       = { :git => "https://github.com/Jumio/mobile-flutter.git", :tag => "#{s.version}" }

  s.source_files = "Classes/**/*.{h,c,m,swift}"
  s.resource = "Localizations/**/*.strings"
  s.requires_arc = true

  s.dependency 'Flutter'
  s.dependency "Jumio", "4.0.0"

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end

