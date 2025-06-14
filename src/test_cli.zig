const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;
const process = std.process;

// CLI Integration Tests
// These tests run the actual lsx binary and verify its behavior

const TestBinary = struct {
    allocator: std.mem.Allocator,
    binary_path: []const u8,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, binary_path: []const u8) Self {
        return Self{
            .allocator = allocator,
            .binary_path = binary_path,
        };
    }

    pub fn run(self: Self, args: []const []const u8) !std.process.Child.RunResult {
        var child_args = ArrayList([]const u8).init(self.allocator);
        defer child_args.deinit();

        try child_args.append(self.binary_path);
        for (args) |arg| {
            try child_args.append(arg);
        }

        return std.process.Child.run(.{
            .allocator = self.allocator,
            .argv = child_args.items,
            .max_output_bytes = 1024 * 1024, // 1MB
        });
    }

    pub fn runExpectSuccess(self: Self, args: []const []const u8) !std.process.Child.RunResult {
        const result = try self.run(args);
        if (result.term != .Exited or result.term.Exited != 0) {
            std.debug.print("Command failed with term: {any}\n", .{result.term});
            std.debug.print("Stderr: {s}\n", .{result.stderr});
            return error.CommandFailed;
        }
        return result;
    }
};

// Helper function to check if binary exists
fn binaryExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}

test "CLI help command" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test --help
    const help_result = try test_binary.runExpectSuccess(&[_][]const u8{"--help"});
    defer allocator.free(help_result.stdout);
    defer allocator.free(help_result.stderr);

    try testing.expect(std.mem.indexOf(u8, help_result.stdout, "lsx - A modern alternative to ls") != null);
    try testing.expect(std.mem.indexOf(u8, help_result.stdout, "USAGE:") != null);
    try testing.expect(std.mem.indexOf(u8, help_result.stdout, "OPTIONS:") != null);

    // Test -h
    const h_result = try test_binary.runExpectSuccess(&[_][]const u8{"-h"});
    defer allocator.free(h_result.stdout);
    defer allocator.free(h_result.stderr);

    try testing.expectEqualStrings(help_result.stdout, h_result.stdout);
}

test "CLI basic directory listing" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test listing current directory
    const result = try test_binary.runExpectSuccess(&[_][]const u8{"."});
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Should contain some basic files we know exist
    try testing.expect(std.mem.indexOf(u8, result.stdout, "src") != null);
    try testing.expect(std.mem.indexOf(u8, result.stdout, "build.zig") != null);
}

test "CLI long format" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test long format
    const result = try test_binary.runExpectSuccess(&[_][]const u8{ "-l", "." });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Long format should include file sizes
    try testing.expect(std.mem.indexOf(u8, result.stdout, "K") != null or
        std.mem.indexOf(u8, result.stdout, "B") != null);
}

test "CLI with permissions" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test long format with permissions
    const result = try test_binary.runExpectSuccess(&[_][]const u8{ "-l", "-p", "." });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Should contain permission strings
    try testing.expect(std.mem.indexOf(u8, result.stdout, "rw") != null);
}

test "CLI show all files" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test showing all files (including hidden)
    const result = try test_binary.runExpectSuccess(&[_][]const u8{ "-a", "." });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Should include hidden files like .gitignore
    try testing.expect(std.mem.indexOf(u8, result.stdout, ".gitignore") != null);
}

test "CLI sort by size" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test sort by size
    const result = try test_binary.runExpectSuccess(&[_][]const u8{ "-S", "." });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Should run successfully (detailed verification would be complex)
    try testing.expect(result.stdout.len > 0);
}

test "CLI reverse sort" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test reverse sort
    const result = try test_binary.runExpectSuccess(&[_][]const u8{ "-r", "." });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Should run successfully
    try testing.expect(result.stdout.len > 0);
}

test "CLI disable colors and icons" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test without colors and icons
    const result = try test_binary.runExpectSuccess(&[_][]const u8{ "--no-colors", "--no-icons", "." });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Should not contain ANSI escape sequences
    try testing.expect(std.mem.indexOf(u8, result.stdout, "\x1b[") == null);

    // Should not contain emoji icons
    try testing.expect(std.mem.indexOf(u8, result.stdout, "📁") == null);
    try testing.expect(std.mem.indexOf(u8, result.stdout, "📄") == null);
}

test "CLI bytes format" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test exact byte sizes
    const result = try test_binary.runExpectSuccess(&[_][]const u8{ "-l", "--bytes", "." });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Should contain exact byte numbers (no K, M, G suffixes)
    const lines = std.mem.split(u8, result.stdout, "\n");
    var found_numeric = false;
    while (lines.next()) |line| {
        if (line.len > 0) {
            // Look for pure numeric file sizes
            var i: usize = 0;
            while (i < line.len) : (i += 1) {
                if (std.ascii.isDigit(line[i])) {
                    // Check if this is a standalone number (file size)
                    var j = i;
                    while (j < line.len and std.ascii.isDigit(line[j])) {
                        j += 1;
                    }
                    if (j > i + 1) { // More than one digit
                        found_numeric = true;
                        break;
                    }
                    i = j;
                }
            }
            if (found_numeric) break;
        }
    }
    try testing.expect(found_numeric);
}

test "CLI invalid option handling" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test invalid option
    const result = try test_binary.run(&[_][]const u8{"--invalid-option"});
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Should exit with error
    try testing.expect(result.term == .Exited and result.term.Exited != 0);

    // Should suggest help
    try testing.expect(std.mem.indexOf(u8, result.stdout, "Try 'lsx --help'") != null);
}

test "CLI non-existent directory" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Test non-existent directory
    const result = try test_binary.run(&[_][]const u8{"/non/existent/directory"});
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Should handle gracefully and show error message
    try testing.expect(std.mem.indexOf(u8, result.stdout, "cannot access") != null or
        std.mem.indexOf(u8, result.stdout, "No such file") != null);
}

// Benchmark test
test "CLI performance benchmark" {
    const allocator = testing.allocator;

    // Skip if binary doesn't exist
    if (!binaryExists("zig-out/bin/lsx")) {
        return error.SkipZigTest;
    }

    const test_binary = TestBinary.init(allocator, "zig-out/bin/lsx");

    // Benchmark basic listing
    const start_time = std.time.nanoTimestamp();
    const result = try test_binary.runExpectSuccess(&[_][]const u8{"."});
    const end_time = std.time.nanoTimestamp();

    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    const duration_ms = @divTrunc(end_time - start_time, 1_000_000);

    // Should complete in reasonable time (less than 1 second for small directory)
    try testing.expect(duration_ms < 1000);

    std.debug.print("Basic listing took {d}ms\n", .{duration_ms});
}
