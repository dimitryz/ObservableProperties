Pod::Spec.new do |s|
  s.name         = "ObservableProperties"
  s.version      = "1.0.2"
  s.source       = { :git => "https://github.com/dimitryz/ObservableProperties.git", :tag => "#{s.version}" }
  s.summary      = "A library for defining observable objects with a single value."
  s.description  = "A library for defining observable objects with a single value."
  s.homepage     = "https://github.com/dimitryz/ObservableProperties"
  s.license      = {:type => "MIT", :file => "LICENSE"}
  s.authors      = {'Dimitry zolotaryov' => 'dimitry@webit.ca'}
  s.ios.deployment_target = "10.0"
  s.source_files  = "Sources/ObservableProperties/**/*.swift"
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end
