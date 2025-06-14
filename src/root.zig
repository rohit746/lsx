//! lsx library module
//! This module contains the core functionality for the lsx directory listing tool.

const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

// Re-export main module functionality for testing
pub const main_module = @import("main.zig");

// Test utilities
pub const TestUtils = struct {
    /// Creates a temporary directory for testing
    pub fn createTempDir() !std.testing.TmpDir {
        return std.testing.tmpDir(.{});
    }

    /// Creates a test file with specified content
    pub fn createTestFile(dir: std.fs.Dir, name: []const u8, content: []const u8) !void {
        const file = try dir.createFile(name, .{});
        defer file.close();
        try file.writeAll(content);
    }

    /// Creates a test directory
    pub fn createTestDir(dir: std.fs.Dir, name: []const u8) !void {
        try dir.makeDir(name);
    }

    /// Creates a test executable file
    pub fn createTestExecutable(dir: std.fs.Dir, name: []const u8) !void {
        const file = try dir.createFile(name, .{ .mode = 0o755 });
        defer file.close();
        try file.writeAll("#!/bin/bash\necho 'test'\n");
    }
};
