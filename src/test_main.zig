const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;
const main = @import("main.zig");

const TestUtils = @import("root.zig").TestUtils;

// Test the FileInfo struct and its methods
test "FileInfo.getIcon returns correct icons" {
    const file_txt = main.FileInfo{
        .name = "test.txt",
        .path = "/tmp/test.txt",
        .size = 100,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    };

    try testing.expectEqualStrings(main.Icons.doc, file_txt.getIcon());

    const file_zig = main.FileInfo{
        .name = "test.zig",
        .path = "/tmp/test.zig",
        .size = 100,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    };

    try testing.expectEqualStrings(main.Icons.code, file_zig.getIcon());

    const dir = main.FileInfo{
        .name = "testdir",
        .path = "/tmp/testdir",
        .size = 4096,
        .is_dir = true,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o755,
    };

    try testing.expectEqualStrings(main.Icons.folder, dir.getIcon());

    const hidden_file = main.FileInfo{
        .name = ".hidden",
        .path = "/tmp/.hidden",
        .size = 100,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = true,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    };

    try testing.expectEqualStrings(main.Icons.hidden, hidden_file.getIcon());

    const executable = main.FileInfo{
        .name = "test",
        .path = "/tmp/test",
        .size = 100,
        .is_dir = false,
        .is_executable = true,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o755,
    };

    try testing.expectEqualStrings(main.Icons.executable, executable.getIcon());

    const symlink = main.FileInfo{
        .name = "link",
        .path = "/tmp/link",
        .size = 100,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = true,
        .mtime = 0,
        .permissions = 0o644,
    };

    try testing.expectEqualStrings(main.Icons.link, symlink.getIcon());
}

test "FileInfo.getColor returns correct colors" {
    const file_txt = main.FileInfo{
        .name = "test.txt",
        .path = "/tmp/test.txt",
        .size = 100,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    };

    try testing.expectEqualStrings(main.Colors.white, file_txt.getColor());

    const dir = main.FileInfo{
        .name = "testdir",
        .path = "/tmp/testdir",
        .size = 4096,
        .is_dir = true,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o755,
    };

    try testing.expectEqualStrings(main.Colors.bright_blue, dir.getColor());

    const hidden_file = main.FileInfo{
        .name = ".hidden",
        .path = "/tmp/.hidden",
        .size = 100,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = true,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    };

    try testing.expectEqualStrings(main.Colors.dim, hidden_file.getColor());

    const executable = main.FileInfo{
        .name = "test",
        .path = "/tmp/test",
        .size = 100,
        .is_dir = false,
        .is_executable = true,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o755,
    };

    try testing.expectEqualStrings(main.Colors.bright_green, executable.getColor());

    const symlink = main.FileInfo{
        .name = "link",
        .path = "/tmp/link",
        .size = 100,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = true,
        .mtime = 0,
        .permissions = 0o644,
    };

    try testing.expectEqualStrings(main.Colors.cyan, symlink.getColor());
}

test "formatSize human readable" {
    const allocator = testing.allocator;

    // Test bytes
    const size_bytes = try main.formatSize(512, true, allocator);
    defer allocator.free(size_bytes);
    try testing.expectEqualStrings("512B", size_bytes);

    // Test kilobytes
    const size_kb = try main.formatSize(2048, true, allocator);
    defer allocator.free(size_kb);
    try testing.expectEqualStrings("2.0K", size_kb);

    // Test megabytes
    const size_mb = try main.formatSize(2 * 1024 * 1024, true, allocator);
    defer allocator.free(size_mb);
    try testing.expectEqualStrings("2.0M", size_mb);

    // Test gigabytes
    const size_gb = try main.formatSize(3 * 1024 * 1024 * 1024, true, allocator);
    defer allocator.free(size_gb);
    try testing.expectEqualStrings("3.0G", size_gb);
}

test "formatSize exact bytes" {
    const allocator = testing.allocator;

    const size_exact = try main.formatSize(1048576, false, allocator);
    defer allocator.free(size_exact);
    try testing.expectEqualStrings("1048576", size_exact);
}

test "formatPermissions" {
    const allocator = testing.allocator;

    // Test regular file permissions (644)
    const perms_644 = try main.formatPermissions(0o100644, allocator);
    defer allocator.free(perms_644);
    try testing.expectEqualStrings("-rw-r--r--", perms_644);

    // Test directory permissions (755)
    const perms_755 = try main.formatPermissions(0o040755, allocator);
    defer allocator.free(perms_755);
    try testing.expectEqualStrings("drwxr-xr-x", perms_755);

    // Test executable permissions (755)
    const perms_exec = try main.formatPermissions(0o100755, allocator);
    defer allocator.free(perms_exec);
    try testing.expectEqualStrings("-rwxr-xr-x", perms_exec);
}

test "Config default values" {
    const config = main.Config{};

    try testing.expect(!config.show_hidden);
    try testing.expect(!config.long_format);
    try testing.expect(config.show_icons);
    try testing.expect(config.show_colors);
    try testing.expect(!config.sort_by_size);
    try testing.expect(!config.sort_by_time);
    try testing.expect(!config.reverse_sort);
    try testing.expect(config.human_readable);
    try testing.expect(!config.show_permissions);
}

test "sortFiles by name" {
    const allocator = testing.allocator;

    var files = ArrayList(main.FileInfo).init(allocator);
    defer files.deinit();

    // Add files in random order
    try files.append(main.FileInfo{
        .name = try allocator.dupe(u8, "zebra.txt"),
        .path = try allocator.dupe(u8, "/tmp/zebra.txt"),
        .size = 100,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    });

    try files.append(main.FileInfo{
        .name = try allocator.dupe(u8, "alpha.txt"),
        .path = try allocator.dupe(u8, "/tmp/alpha.txt"),
        .size = 200,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    });

    try files.append(main.FileInfo{
        .name = try allocator.dupe(u8, "beta"),
        .path = try allocator.dupe(u8, "/tmp/beta"),
        .size = 4096,
        .is_dir = true,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o755,
    });

    defer {
        for (files.items) |file| {
            allocator.free(file.name);
            allocator.free(file.path);
        }
    }

    const config = main.Config{};
    main.sortFiles(files.items, config);

    // Directories should come first, then files alphabetically
    try testing.expectEqualStrings("beta", files.items[0].name);
    try testing.expectEqualStrings("alpha.txt", files.items[1].name);
    try testing.expectEqualStrings("zebra.txt", files.items[2].name);
}

test "sortFiles by size" {
    const allocator = testing.allocator;

    var files = ArrayList(main.FileInfo).init(allocator);
    defer files.deinit();

    try files.append(main.FileInfo{
        .name = try allocator.dupe(u8, "large.txt"),
        .path = try allocator.dupe(u8, "/tmp/large.txt"),
        .size = 1000,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    });

    try files.append(main.FileInfo{
        .name = try allocator.dupe(u8, "small.txt"),
        .path = try allocator.dupe(u8, "/tmp/small.txt"),
        .size = 100,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    });

    defer {
        for (files.items) |file| {
            allocator.free(file.name);
            allocator.free(file.path);
        }
    }

    const config = main.Config{ .sort_by_size = true };
    main.sortFiles(files.items, config);

    // Should be sorted by size (smallest first)
    try testing.expectEqualStrings("small.txt", files.items[0].name);
    try testing.expectEqualStrings("large.txt", files.items[1].name);
}

test "sortFiles reverse order" {
    const allocator = testing.allocator;

    var files = ArrayList(main.FileInfo).init(allocator);
    defer files.deinit();

    try files.append(main.FileInfo{
        .name = try allocator.dupe(u8, "alpha.txt"),
        .path = try allocator.dupe(u8, "/tmp/alpha.txt"),
        .size = 100,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    });

    try files.append(main.FileInfo{
        .name = try allocator.dupe(u8, "beta.txt"),
        .path = try allocator.dupe(u8, "/tmp/beta.txt"),
        .size = 200,
        .is_dir = false,
        .is_executable = false,
        .is_hidden = false,
        .is_symlink = false,
        .mtime = 0,
        .permissions = 0o644,
    });

    defer {
        for (files.items) |file| {
            allocator.free(file.name);
            allocator.free(file.path);
        }
    }

    const config = main.Config{ .reverse_sort = true };
    main.sortFiles(files.items, config);

    // Should be reverse alphabetical
    try testing.expectEqualStrings("beta.txt", files.items[0].name);
    try testing.expectEqualStrings("alpha.txt", files.items[1].name);
}

// Integration test with actual file system
test "collectFiles basic functionality" {
    const allocator = testing.allocator;

    // Create a temporary directory
    var tmp_dir = try TestUtils.createTempDir();
    defer tmp_dir.cleanup();

    // Create test files
    try TestUtils.createTestFile(tmp_dir.dir, "test.txt", "Hello, world!");
    try TestUtils.createTestFile(tmp_dir.dir, "test.zig", "const std = @import(\"std\");");
    try TestUtils.createTestDir(tmp_dir.dir, "subdir");
    try TestUtils.createTestFile(tmp_dir.dir, ".hidden", "hidden content");

    // Test without hidden files
    const config_no_hidden = main.Config{};
    var files_no_hidden = try main.collectFiles(allocator, tmp_dir.sub_path, config_no_hidden);
    defer {
        for (files_no_hidden.items) |file| {
            allocator.free(file.name);
            allocator.free(file.path);
        }
        files_no_hidden.deinit();
    }

    // Should find 3 files (not including hidden)
    try testing.expect(files_no_hidden.items.len == 3);

    // Test with hidden files
    const config_with_hidden = main.Config{ .show_hidden = true };
    var files_with_hidden = try main.collectFiles(allocator, tmp_dir.sub_path, config_with_hidden);
    defer {
        for (files_with_hidden.items) |file| {
            allocator.free(file.name);
            allocator.free(file.path);
        }
        files_with_hidden.deinit();
    }

    // Should find 4 files (including hidden)
    try testing.expect(files_with_hidden.items.len == 4);
}

// Test file extension recognition
test "file extension recognition" {
    const test_cases = [_]struct {
        filename: []const u8,
        expected_icon: []const u8,
    }{
        .{ .filename = "test.png", .expected_icon = main.Icons.image },
        .{ .filename = "test.jpg", .expected_icon = main.Icons.image },
        .{ .filename = "test.mp4", .expected_icon = main.Icons.video },
        .{ .filename = "test.mp3", .expected_icon = main.Icons.audio },
        .{ .filename = "test.zip", .expected_icon = main.Icons.archive },
        .{ .filename = "test.c", .expected_icon = main.Icons.code },
        .{ .filename = "test.json", .expected_icon = main.Icons.config },
        .{ .filename = "test.md", .expected_icon = main.Icons.doc },
        .{ .filename = "unknown.xyz", .expected_icon = main.Icons.file },
    };

    for (test_cases) |case| {
        const file_info = main.FileInfo{
            .name = case.filename,
            .path = case.filename,
            .size = 100,
            .is_dir = false,
            .is_executable = false,
            .is_hidden = false,
            .is_symlink = false,
            .mtime = 0,
            .permissions = 0o644,
        };

        try testing.expectEqualStrings(case.expected_icon, file_info.getIcon());
    }
}

// Test error handling
test "collectFiles handles non-existent directory" {
    const allocator = testing.allocator;
    const config = main.Config{};

    var files = try main.collectFiles(allocator, "/non/existent/path", config);
    defer files.deinit();

    // Should return empty list for non-existent directory
    try testing.expect(files.items.len == 0);
}

// Test memory management
test "memory management in formatSize" {
    const allocator = testing.allocator;

    // Test that all allocated memory is properly freed
    const sizes = [_]u64{ 0, 512, 1024, 1048576, 1073741824 };

    for (sizes) |size| {
        const result = try main.formatSize(size, true, allocator);
        defer allocator.free(result);

        // Just ensure the result is valid
        try testing.expect(result.len > 0);
    }
}

// Performance test for large file lists
test "sortFiles performance with many files" {
    const allocator = testing.allocator;

    var files = ArrayList(main.FileInfo).init(allocator);
    defer files.deinit();

    // Create 1000 test files
    var i: u32 = 0;
    while (i < 1000) : (i += 1) {
        const name = try std.fmt.allocPrint(allocator, "file_{d}.txt", .{i});
        const path = try std.fmt.allocPrint(allocator, "/tmp/file_{d}.txt", .{i});

        try files.append(main.FileInfo{
            .name = name,
            .path = path,
            .size = i * 100,
            .is_dir = false,
            .is_executable = false,
            .is_hidden = false,
            .is_symlink = false,
            .mtime = @as(i128, i),
            .permissions = 0o644,
        });
    }

    defer {
        for (files.items) |file| {
            allocator.free(file.name);
            allocator.free(file.path);
        }
    }

    const config = main.Config{};

    // Time the sorting operation
    const start_time = std.time.nanoTimestamp();
    main.sortFiles(files.items, config);
    const end_time = std.time.nanoTimestamp();
    const duration_ns = end_time - start_time;

    // Should complete in reasonable time (less than 100ms)
    try testing.expect(duration_ns < 100_000_000);

    // Verify first file is sorted correctly
    try testing.expectEqualStrings("file_0.txt", files.items[0].name);
}
