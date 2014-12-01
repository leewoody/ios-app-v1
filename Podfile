platform :ios, '7.0'
pod 'AFNetworking', '~> 2.0'
pod 'TBXML', '~> 1.5'
pod 'PLCrashReporter', '1.2-rc5'
pod 'ARChromeActivity', '~> 1.0'
pod 'TUSafariActivity', '~> 1.0.1'

post_install do | installer |
	require 'fileutils'
	FileUtils.cp_r('Pods/Pods-Acknowledgements.plist', 'Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end