import 'dart:io';

Future<String> runGit(List<String> args) async {
  final result = await Process.run("git", args, runInShell: true);
  if (result.exitCode != 0) {
    throw Exception(
        "❌ Git command failed: git ${args.join(' ')}\n${result.stderr}");
  }
  return (result.stdout as String).trim();
}

Future<void> runCommand(String command, List<String> args) async {
  final process = await Process.start(command, args, runInShell: true);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception("❌ Command failed: $command ${args.join(' ')}");
  }
}

Future<void> commitIfNeeded() async {
  final status = await runGit(["status", "--porcelain"]);
  if (status.isNotEmpty) {
    print("⚠️  You have uncommitted changes.");
    stdout.write("👉 Enter commit message: ");
    final message = stdin.readLineSync()?.trim();
    if (message == null || message.isEmpty) {
      print("❌ Commit aborted: message cannot be empty.");
      exit(1);
    }

    print("📌 Adding changes...");
    await runGit(["add", "."]);

    print("💾 Committing changes...");
    await runGit(["commit", "-m", message]);

    print("✅ Changes committed.");
  } else {
    print("✅ No uncommitted changes.");
  }
}

Future<void> pushToRemote(String remoteName) async {
  print("⬆️  Pushing to $remoteName...");
  await runCommand("git", ["push", remoteName, "--all"]);
  await runCommand("git", ["push", remoteName, "--tags"]);
  print("✅ Push to $remoteName completed!");
}

Future<void> main() async {
  try {
    await commitIfNeeded();

    await pushToRemote("origin"); // TFS
    await pushToRemote("github"); // GitHub

    print("🎉 Sync completed successfully!");
  } catch (e) {
    print("❌ Sync failed: $e");
    exit(1);
  }
}
