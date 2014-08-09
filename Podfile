platform :ios, '7.0'
pod 'AFNetworking', '~> 2.0'

post_install do | installer |
	require 'fileutils'
	FileUtils.cp_r('Pods/Pods-Acknowledgements.plist', 'Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end