import 'dart:io';

Future<void> run(String command, List<String> args) async {
  final process = await Process.start(command, args, runInShell: true);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception('❌ Command failed: $command ${args.join(" ")}');
  }
}

Future<void> main() async {
  stdout.write("👉 Enter build type (release/debug): ");
  final input = stdin.readLineSync()?.trim().toLowerCase();

  // Default to release if input is empty/invalid
  final buildType = (input == "debug") ? "debug" : "release";

  print("🔨 Selected build type: $buildType");

  print("🧹 Cleaning previous builds...");
  await run("flutter", ["clean"]);

  print("📦 Getting dependencies...");
  await run("flutter", ["pub", "get"]);

  print("⚙️ Building APK...");
  await run("flutter", ["build", "apk", "--$buildType"]);

  print("📦 Building App Bundle...");
  await run("flutter", ["build", "appbundle", "--$buildType"]);

  // macOS only: build iOS
  if (Platform.isMacOS) {
    print("🍎 Building iOS app...");
    await run("flutter", ["build", "ios", "--$buildType"]);
  }

  print("✅ Build completed successfully!");
}
