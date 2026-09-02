// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "connectivity_plus", path: "../.packages/connectivity_plus-7.2.0"),
        .package(name: "device_info_plus", path: "../.packages/device_info_plus-12.4.0"),
        .package(name: "file_picker", path: "../.packages/file_picker-10.3.10"),
        .package(name: "fluttertoast", path: "../.packages/fluttertoast-9.1.0"),
        .package(name: "local_auth_darwin", path: "../.packages/local_auth_darwin-1.6.1"),
        .package(name: "open_file_ios", path: "../.packages/open_file_ios-1.1.0"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-9.0.1"),
        .package(name: "permission_handler_apple", path: "../.packages/permission_handler_apple-9.4.10"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.6"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.4.1"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "connectivity-plus", package: "connectivity_plus"),
                .product(name: "device-info-plus", package: "device_info_plus"),
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "fluttertoast", package: "fluttertoast"),
                .product(name: "local-auth-darwin", package: "local_auth_darwin"),
                .product(name: "open-file-ios", package: "open_file_ios"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "permission-handler-apple", package: "permission_handler_apple"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
