platform :ios, '7.0'
pod 'RestKit', '~> 0.20.0'
pod 'PLCrashReporter', '1.2-rc5'
pod 'ARChromeActivity', '~> 1.0'
pod 'TUSafariActivity', '~> 1.0.1'


post_install do | installer |
	require 'fileutils'
	FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
