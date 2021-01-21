Pod::Spec.new do |spec|

  spec.name         = "CharacterKit"
  spec.version      = "0.1"
  spec.license      = "MIT"
  spec.summary      = "Swift package used to easily integrate elements of classic RPGs into you project."
  spec.homepage     = "https://github.com/appoly/IdentifyKit"
  spec.authors = "James Wolfe"
  spec.source = { :git => 'https://github.com/appoly/IdentifyKit.git', :tag => spec.version }

  spec.ios.deployment_target = "11.4"
  spec.swift_versions = ["5.0", "5.1"]
  
  spec.source_files = "Sources/*.swift"
  

end
