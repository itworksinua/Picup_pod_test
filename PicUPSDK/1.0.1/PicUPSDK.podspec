Pod::Spec.new do |s|
    # 1
    s.platform = :ios
    s.ios.deployment_target = '12.0'
    s.name = "PicUPSDK"
    s.summary = "RWPickFlavor lets a user select an ice cream flavor."
    s.requires_arc = true
    
    # 2
    s.version = "1.0.1"
    
    # 3
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    
    # 4 - Replace with your name and e-mail address
    s.author = { 'test' => 'test@gmail.com' }
    
    # 5 - Replace this URL with your own GitHub page's URL (from the address bar)
    s.homepage = 'https://github.com/itworksinua/Picup_pod_test'
    
    # 6 - Replace this URL with your own Git URL from "Quick Setup"
    s.source = { :git => 'https://github.com/itworksinua/Picup_pod_test.git',
        :tag => s.version.to_s }
    
    # 7
    s.framework = 'UIKit'
    s.framework = 'Foundation'
    s.dependency 'Alamofire', '~> 4.9'
    
    # 8
    s.source_files  = 'Sources/**/*.{swift}'
    
    # 9
    #s.resources = "Picup_pod_test/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
    
    # 10
    s.swift_version = "5.0"
end

