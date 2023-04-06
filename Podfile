use_modular_headers!

source 'https://github.com/CocoaPods/Specs.git'

target 'String' do
  platform :ios, '11.0'
  pod 'BMProtocols', :path => '../../Beem/ios-beemworkspace.git/protocols/'
  pod 'BMMagazine', :path => '../../Beem/ios-beemworkspace.git/ios-magazine/'
  pod 'BMIMLib', :path => '../../Beem/ios-beemworkspace.git/bmimlib/'
  pod 'BMCommonLib', :path => '../../Beem/ios-beemworkspace.git/ios-commonlib/'

  target 'StringTests' do
    platform :ios, '11.0'
    pod 'OCMock', '3.9.1'
    pod 'Quick', '5.0.1'
    pod 'Nimble', '10.0.0'
  end
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        config.build_settings['CODE_SIGN_IDENTITY'] = ''
      end
    end
  end
end
