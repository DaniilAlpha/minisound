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

    s.platform = :ios, '13.0'

    s.source     = { :path => '.' }
    s.dependency 'Flutter'
    s.framework = 'AVFoundation'

    s.vendored_frameworks = '${PODS_BUILD_DIR}/libminisound_ffi.framework'
    s.pod_target_xcconfig = { 
        'DEFINES_MODULE' => 'YES',
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
        'CMAKE_BUILD_TYPE' => 'Release'
    }
    s.script_phase = {
        :name => 'CMake Build',
        :execution_position => :before_compile,
        :output_files => ['${PODS_BUILD_DIR}/libminisound_ffi.framework'],
        :script => <<-SCRIPT
            set -e

            echo === Building minisound_ffi for iOS via CMake ===
            echo - Archs: $(echo ${ARCHS} | tr ' ' ';') 
            echo - SDK Root: ${SDKROOT}

            cd ${PODS_BUILD_DIR} 
            cmake ${PODS_TARGET_SRCROOT}/../src/                        \
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}                  \
                -DCMAKE_OSX_ARCHITECTURES=$(echo ${ARCHS} | tr ' ' ';') \
                -DCMAKE_OSX_SYSROOT=${SDKROOT}                          \
                -DCMAKE_SYSTEM_NAME=iOS                                 \
                -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0
            cmake --build .
        SCRIPT
    }
    s.xcconfig = { 'OTHER_LDFLAGS' => '$(inherited) -framework libminisound_ffi' }
end
