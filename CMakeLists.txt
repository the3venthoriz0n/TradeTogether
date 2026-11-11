cmake_minimum_required(VERSION 3.24)

# Link spdlog/fmt statically: the plugin DLL must not depend on spdlog.dll/fmt.dll,
# which do not exist in a Skyrim install. Must be set before project().
set(VCPKG_TARGET_TRIPLET "x64-windows-static-md" CACHE STRING "")

project(TradeTogether VERSION 0.12.0 LANGUAGES CXX)
set(TRADETOGETHER_RELEASE_VERSION "${PROJECT_VERSION}-strpm")

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# CommonLibSSE-NG (alandtse fork) is vendored as a submodule: only this fork supports
# Skyrim 1.7.99+ (Address Library format 5).
set(BUILD_TESTS OFF CACHE BOOL "Disable CommonLibSSE-NG tests" FORCE)
add_subdirectory(lib/commonlibsse-ng CommonLibSSE EXCLUDE_FROM_ALL)
include(lib/commonlibsse-ng/cmake/CommonLibSSE.cmake)

set(PROJECT_SOURCES
    src/PCH.h
    src/main.cpp
    src/AutoTransfer.h
    src/AutoTransfer.cpp
    src/Config.h
    src/Config.cpp
    src/Input.h
    src/Input.cpp
    src/Localization.h
    src/Localization.cpp
    src/MCMBridge.h
    src/MCMBridge.cpp
    src/Offer.h
    src/Offer.cpp
    src/Protocol.h
    src/Protocol.cpp
    src/SafeMessageBox.h
    src/SafeMessageBox.cpp
    src/STRPluginMessagingAPI/STRPluginMessagingAPI.h
    src/STRPluginMessagingAPI.cpp
    src/StrMessagingTransport.h
    src/StrMessagingTransport.cpp
    src/Trade.h
    src/Trade.cpp
    src/UdpTransport.h
    src/UdpTransport.cpp
)

add_commonlibsse_plugin(${PROJECT_NAME}
    SOURCES ${PROJECT_SOURCES}
)

target_precompile_headers(${PROJECT_NAME} PRIVATE src/PCH.h)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    WIN32_LEAN_AND_MEAN
    NOMINMAX
)

if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /utf-8 /permissive-)
endif()

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${PROJECT_SOURCES})

set(PACKAGE_PLUGIN_DIR "${CMAKE_CURRENT_SOURCE_DIR}/package/Data/SKSE/Plugins")
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PACKAGE_PLUGIN_DIR}"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:${PROJECT_NAME}>"
            "${PACKAGE_PLUGIN_DIR}/$<TARGET_FILE_NAME:${PROJECT_NAME}>"
    COMMENT "Copying TradeTogether.dll to package/Data/SKSE/Plugins (${TRADETOGETHER_RELEASE_VERSION})"
)
