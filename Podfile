source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

def shared_pods
    pod 'RxSwift', '~> 3.0.0-rc.1'
    pod 'RxCocoa', '~> 3.0.0-rc.1'
    pod 'Realm', '~> 2.0'
    pod 'RealmSwift', '~> 2.0'
end

def shared_app_pods
    pod 'XCGLogger', '~> 4.0'
    pod 'Locksmith', '~> 3.0'
    pod 'RxRealm', '~> 0.2'
end

target 'EmonCMSiOS' do
    platform :ios, '10.0'
    shared_pods
    shared_app_pods

    pod 'RxDataSources', '~> 1.0.0-rc.2'
    pod 'Action', '~> 2.0.0-beta.1'
    pod 'Charts', '~> 3.0'
    pod 'Former', '~> 1.5'
end

target 'EmonCMSiOSTests' do
    platform :ios, '10.0'
    shared_pods

    pod 'Quick', '~> 0.10'
    pod 'Nimble', '~> 5.0'
    pod 'RxTest', '~> 3.0.0-rc.1'
end

target 'EmonCMSToday' do
    platform :ios, '10.0'
    shared_pods
    shared_app_pods
end
