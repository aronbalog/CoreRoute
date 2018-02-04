Pod::Spec.new do |spec|
	spec.name = 'CoreRoute'
	spec.ios.deployment_target = '8.0'
	spec.version = '0.2.1'
  	spec.license = 'MIT'
	spec.summary = 'A Swift routing framework'
	spec.author = 'Aron Balog'
	spec.homepage = 'https://github.com/aronbalog/CoreRoute'
	spec.source = { :git => 'https://github.com/aronbalog/CoreRoute.git', :tag => '0.2.1'  }
	spec.source_files = 'CoreRoute/**/*.{swift}'
	spec.requires_arc = true
	spec.xcconfig = { 'SWIFT_VERSION' => '4.0' }
end