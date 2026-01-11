#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint minisound_ffi.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
    s.name        = 'minisound_ffi'
    s.version     = '0.0.1'
    s.summary     = 'A new Flutter FFI plugin project.'
    s.description = <<-DESC
A new Flutter FFI plugin project.
    DESC
    s.homepage    = 'http://example.com'
    s.license     = { :file => '../LICENSE' }
    s.author      = { 'Your Company' => 'email@example.com' }

    s.osx.deployment_target   = '10.11'
    s.ios.deployment_target   = '13.0'
    s.swift_version           = '5.0'

    # This will ensure the source files in Classes/ are included in the native
    # builds of apps using this FFI plugin. Podspec does not support relative
    # paths, so Classes contains a forwarder C file that relatively imports
    # `../src/*` so that the C sources can be shared among all target platforms.
    s.source          = { :path => '.' }
    s.osx.dependency 'FlutterMacOS'
    s.ios.dependency 'Flutter'

    s.osx.pod_target_xcconfig = { 
        'DEFINES_MODULE' => 'YES',
        'CMAKE_BUILD_TYPE' => 'Release'
    }
    s.ios.pod_target_xcconfig = { 
        'DEFINES_MODULE' => 'YES',
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
        'CMAKE_BUILD_TYPE' => 'Release'
        'CMAKE_SYSTEM_NAME' => 'iOS'
    }
    s.script_phase = {
        :name => 'CMake Build',
        :execution_position => :before_compile,
        :output_files => ['${PODS_BUILD_DIR}/libminisound_ffi.dylib'],
        :script => <<-SCRIPT
            cmake -B ${PODS_BUILD_DIR} -S ${PODS_TARGET_SRCROOT}/../src/ \
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}                   \
                -DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}                 \
                -DCMAKE_OSX_ARCHITECTURES="${ARCHS}"
            cmake --build ${PODS_BUILD_DIR}
        SCRIPT
    }
    s.vendored_libraries = '${PODS_BUILD_DIR}/libminisound_ffi.dylib'
    # s.xcconfig = { 'OTHER_LDFLAGS' => '-force_load "${PODS_BUILD_DIR}/libminisound_ffi.dylib"' }
end
