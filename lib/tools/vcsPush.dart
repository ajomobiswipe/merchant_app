import 'dart:io';

Future<String> runGit(List<String> args) async {
  final result = await Process.run("git", args, runInShell: true);
  if (result.exitCode != 0) {
    throw Exception("❌ Git failed: git ${args.join(' ')}\n${result.stderr}");
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

Future<void> checkUncommittedChanges() async {
  final status = await runGit(["status", "--porcelain"]);
  if (status.isNotEmpty) {
    print("⚠️  You have uncommitted changes.");
    stdout.write("👉 Enter commit message: ");
    final message = stdin.readLineSync()?.trim();
    if (message == null || message.isEmpty) {
      print("❌ Commit aborted: empty message.");
      exit(1);
    }
    await runGit(["add", "."]);
    await runGit(["commit", "-m", message]);
    print("✅ Changes committed.");
  } else {
    print("✅ No uncommitted changes.");
  }
}

Future<void> checkRemoteUpdates(String remote, String branch) async {
  await runGit(["fetch", remote]);
  final diff = await runGit(["log", "$branch..$remote/$branch", "--oneline"]);
  if (diff.isNotEmpty) {
    print("⚠️  Remote '$remote' has updates not pulled:");
    print(diff);
    stdout.write("👉 Do you want to pull them now? (y/n): ");
    final ans = stdin.readLineSync()?.trim().toLowerCase();
    if (ans == "y") {
      await runCommand("git", ["pull", remote, branch]);
      print("✅ Pulled latest from $remote/$branch.");
    } else {
      print("⚠️ Skipping pull for $remote/$branch.");
    }
  } else {
    print("✅ $remote is up-to-date on $branch.");
  }
}

Future<void> pushToRemote(
    String remote, bool allBranches, String branch) async {
  print("⬆️  Pushing to $remote...");
  if (allBranches) {
    await runCommand("git", ["push", remote, "--all"]);
  } else {
    await runCommand("git", ["push", remote, branch]);
  }
  await runCommand("git", ["push", remote, "--tags"]);
  print("✅ Push to $remote completed.");
}

Future<void> main() async {
  try {
    final branch = await runGit(["rev-parse", "--abbrev-ref", "HEAD"]);

    print("👉 Choose option:");
    print("1) Commit & push current branch ($branch)");
    print("2) Commit & push all branches");
    stdout.write("Enter choice (1/2): ");
    final choice = stdin.readLineSync()?.trim();
    final allBranches = (choice == "2");

    // Step 1: Commit if needed
    await checkUncommittedChanges();

    // Step 2: Check remote updates before pushing
    if (allBranches) {
      final branches = await runGit(["branch", "--format=%(refname:short)"]);
      for (final b in branches.split("\n")) {
        if (b.trim().isNotEmpty) {
          await checkRemoteUpdates("origin", b.trim());
          await checkRemoteUpdates("github", b.trim());
        }
      }
    } else {
      await checkRemoteUpdates("origin", branch);
      await checkRemoteUpdates("github", branch);
    }

    // Step 3: Push
    await pushToRemote("origin", allBranches, branch);
    await pushToRemote("github", allBranches, branch);

    print("🎉 Sync completed successfully!");
  } catch (e) {
    print("❌ Sync failed: $e");
    exit(1);
  }
}
