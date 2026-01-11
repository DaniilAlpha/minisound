#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint minisound_ffi.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
    s.name             = 'minisound_ffi'
    s.version          = '0.0.1'
    s.summary          = 'A new Flutter FFI plugin project.'
    s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
    s.homepage         = 'http://example.com'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'Your Company' => 'email@example.com' }

    s.platform = :osx, '10.11'
    s.swift_version = '5.0'

    # This will ensure the source files in Classes/ are included in the native
    # builds of apps using this FFI plugin. Podspec does not support relative
    # paths, so Classes contains a forwarder C file that relatively imports
    # `../src/*` so that the C sources can be shared among all target platforms.
    s.source           = { :path => '.' }
    s.source_files     = 'Classes/**/*'
    s.dependency 'FlutterMacOS'

    s.pod_target_xcconfig = { 
        'CMAKE_BUILD_TYPE' => 'Release',
        'CMAKE_BUILD_TYPE_Debug' => 'Debug',

        'DEFINES_MODULE' => 'YES' # was here before, don't remove
    }
    s.prepare_command = <<-CMD
        echo Building minisound_ffi via CMake...
        cmake -B ./build/ -S ../src/ -DCMAKE_BUILD_TYPE=#{s.pod_target_xcconfig.CMAKE_BUILD_TYPE}
        cmake --build ./build/ 
    CMD
    s.vendored_libraries = 'build/libminisound_ffi.dylib'
    s.xcconfig = { 'OTHER_LDFLAGS' => '-force_load "${PODS_ROOT}/../packages/minisound_ffi/macos/build/libminisound_ffi.dylib' }
end
