import 'dart:io';

Future<String> runGit(List<String> args, {bool allowFail = false}) async {
  final result = await Process.run("git", args, runInShell: true);
  if (result.exitCode != 0 && !allowFail) {
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

Future<void> ensureNotDetachedHead() async {
  final branch = await runGit(["rev-parse", "--abbrev-ref", "HEAD"]);
  if (branch == "HEAD") {
    print(
        "❌ You are in a detached HEAD state. Please checkout a branch first.");
    exit(1);
  }
}

Future<void> checkUncommittedChanges() async {
  final status = await runGit(["status", "--porcelain"]);
  if (status.isNotEmpty) {
    print("⚠️  You have uncommitted changes.");
    while (true) {
      stdout.write("👉 Enter commit message (or 'q' to quit): ");
      final message = stdin.readLineSync()?.trim();
      if (message == null || message.isEmpty) {
        print("❌ Commit message cannot be empty.");
      } else if (message.toLowerCase() == "q") {
        print("❌ Commit aborted by user.");
        exit(1);
      } else {
        await runGit(["add", "."]);
        final commitResult =
            await runGit(["commit", "-m", message], allowFail: true);
        if (commitResult.contains("nothing to commit")) {
          print("✅ Nothing new to commit.");
        } else {
          print("✅ Changes committed.");
        }
        break;
      }
    }
  } else {
    print("✅ No uncommitted changes.");
  }

  // Double-check if repo still dirty
  final left = await runGit(["status", "--porcelain"]);
  if (left.isNotEmpty) {
    print("❌ Some files are still untracked/ignored. Please handle manually.");
    exit(1);
  }
}

Future<bool> checkRemoteUpdates(String remote, String branch) async {
  await runGit(["fetch", remote], allowFail: true);
  final diff = await runGit(["log", "$branch..$remote/$branch", "--oneline"],
      allowFail: true);
  if (diff.isNotEmpty) {
    print("⚠️  Remote '$remote' has new commits not pulled:");
    print(diff);
    stdout.write("👉 Do you want to pull them now? (y/n): ");
    final ans = stdin.readLineSync()?.trim().toLowerCase();
    if (ans == "y") {
      try {
        await runCommand("git", ["pull", remote, branch]);
        print("✅ Pulled latest from $remote/$branch.");
        return true;
      } catch (_) {
        print("❌ Merge conflict detected. Resolve manually before syncing.");
        exit(1);
      }
    } else {
      print("❌ Cannot safely push while remote has new commits. Aborting.");
      exit(1);
    }
  }
  return false;
}

Future<void> pushToRemote(
    String remote, bool allBranches, String branch) async {
  print("⬆️  Pushing to $remote...");
  try {
    if (allBranches) {
      await runCommand("git", ["push", remote, "--all"]);
    } else {
      await runCommand("git", ["push", remote, branch]);
    }
    await runCommand("git", ["push", remote, "--tags"]);
    print("✅ Push to $remote completed.");
  } catch (_) {
    print("⚠️ Push to $remote was rejected (non-fast-forward).");
    stdout.write("👉 Do you want to force push? (y/n): ");
    final ans = stdin.readLineSync()?.trim().toLowerCase();
    if (ans == "y") {
      if (allBranches) {
        await runCommand("git", ["push", remote, "--all", "--force"]);
      } else {
        await runCommand("git", ["push", remote, branch, "--force"]);
      }
      print("✅ Force push to $remote completed.");
    } else {
      print("❌ Push aborted.");
      exit(1);
    }
  }
}

Future<void> main() async {
  try {
    await ensureNotDetachedHead();
    final branch = await runGit(["rev-parse", "--abbrev-ref", "HEAD"]);

    print("👉 Choose option:");
    print("1) Commit & push current branch ($branch)");
    print("2) Commit & push all branches");

    String? choice;
    while (choice != "1" && choice != "2") {
      stdout.write("Enter choice (1/2): ");
      choice = stdin.readLineSync()?.trim();
      if (choice != "1" && choice != "2") {
        print("❌ Invalid choice. Please enter 1 or 2.");
      }
    }
    final allBranches = (choice == "2");
    // Step 1: Commit changes
    await checkUncommittedChanges();

    // Step 2: Check and pull updates
    if (allBranches) {
      final branches = await runGit(["branch", "--format=%(refname:short)"]);
      for (final b in branches.split("\n")) {
        final br = b.trim();
        if (br.isEmpty) continue;
        await checkRemoteUpdates("origin", br);
        await checkRemoteUpdates("github", br);
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


//  dart run lib\tools\vcsPush.dart -run in cmd to push