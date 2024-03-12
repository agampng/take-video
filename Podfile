# Uncomment the next line to define a global platform for your project
 platform :ios, '12.2'

target 'take_video' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for take_video
  pod "SwiftyCam"
  pod "SnapKit"

  target 'take_videoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'take_videoUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.2'
    end
  end
end
