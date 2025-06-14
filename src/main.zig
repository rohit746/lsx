const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

// ANSI color codes
const Colors = struct {
    const reset = "\x1b[0m";
    const bold = "\x1b[1m";
    const dim = "\x1b[2m";
    const red = "\x1b[31m";
    const green = "\x1b[32m";
    const yellow = "\x1b[33m";
    const blue = "\x1b[34m";
    const magenta = "\x1b[35m";
    const cyan = "\x1b[36m";
    const white = "\x1b[37m";
    const bright_blue = "\x1b[94m";
    const bright_green = "\x1b[92m";
    const bright_yellow = "\x1b[93m";
    const bright_red = "\x1b[91m";
};

// File type icons
const Icons = struct {
    const folder = "📁";
    const file = "📄";
    const executable = "⚡";
    const link = "🔗";
    const image = "🖼️";
    const video = "🎥";
    const audio = "🎵";
    const archive = "📦";
    const code = "💻";
    const config = "⚙️";
    const doc = "📝";
    const hidden = "👻";
};

const FileInfo = struct {
    name: []const u8,
    path: []const u8,
    size: u64,
    is_dir: bool,
    is_executable: bool,
    is_hidden: bool,
    is_symlink: bool,
    mtime: i128,
    permissions: u32,

    fn getIcon(self: FileInfo) []const u8 {
        if (self.is_hidden) return Icons.hidden;
        if (self.is_dir) return Icons.folder;
        if (self.is_symlink) return Icons.link;
        if (self.is_executable) return Icons.executable;

        // Check file extension
        if (std.mem.lastIndexOf(u8, self.name, ".")) |dot_idx| {
            const ext = self.name[dot_idx + 1 ..];
            if (std.mem.eql(u8, ext, "png") or std.mem.eql(u8, ext, "jpg") or
                std.mem.eql(u8, ext, "jpeg") or std.mem.eql(u8, ext, "gif") or
                std.mem.eql(u8, ext, "bmp") or std.mem.eql(u8, ext, "svg"))
            {
                return Icons.image;
            } else if (std.mem.eql(u8, ext, "mp4") or std.mem.eql(u8, ext, "avi") or
                std.mem.eql(u8, ext, "mkv") or std.mem.eql(u8, ext, "mov"))
            {
                return Icons.video;
            } else if (std.mem.eql(u8, ext, "mp3") or std.mem.eql(u8, ext, "wav") or
                std.mem.eql(u8, ext, "flac") or std.mem.eql(u8, ext, "ogg"))
            {
                return Icons.audio;
            } else if (std.mem.eql(u8, ext, "zip") or std.mem.eql(u8, ext, "tar") or
                std.mem.eql(u8, ext, "gz") or std.mem.eql(u8, ext, "rar") or
                std.mem.eql(u8, ext, "7z"))
            {
                return Icons.archive;
            } else if (std.mem.eql(u8, ext, "zig") or std.mem.eql(u8, ext, "c") or
                std.mem.eql(u8, ext, "cpp") or std.mem.eql(u8, ext, "rs") or
                std.mem.eql(u8, ext, "py") or std.mem.eql(u8, ext, "js") or
                std.mem.eql(u8, ext, "ts") or std.mem.eql(u8, ext, "go"))
            {
                return Icons.code;
            } else if (std.mem.eql(u8, ext, "json") or std.mem.eql(u8, ext, "yml") or
                std.mem.eql(u8, ext, "yaml") or std.mem.eql(u8, ext, "toml") or
                std.mem.eql(u8, ext, "xml") or std.mem.eql(u8, ext, "ini"))
            {
                return Icons.config;
            } else if (std.mem.eql(u8, ext, "txt") or std.mem.eql(u8, ext, "md") or
                std.mem.eql(u8, ext, "rst") or std.mem.eql(u8, ext, "pdf"))
            {
                return Icons.doc;
            }
        }

        return Icons.file;
    }

    fn getColor(self: FileInfo) []const u8 {
        if (self.is_hidden) return Colors.dim;
        if (self.is_dir) return Colors.bright_blue;
        if (self.is_symlink) return Colors.cyan;
        if (self.is_executable) return Colors.bright_green;

        // Check file extension for color coding
        if (std.mem.lastIndexOf(u8, self.name, ".")) |dot_idx| {
            const ext = self.name[dot_idx + 1 ..];
            if (std.mem.eql(u8, ext, "png") or std.mem.eql(u8, ext, "jpg") or
                std.mem.eql(u8, ext, "jpeg") or std.mem.eql(u8, ext, "gif") or
                std.mem.eql(u8, ext, "bmp") or std.mem.eql(u8, ext, "svg"))
            {
                return Colors.magenta;
            } else if (std.mem.eql(u8, ext, "mp4") or std.mem.eql(u8, ext, "avi") or
                std.mem.eql(u8, ext, "mkv") or std.mem.eql(u8, ext, "mov"))
            {
                return Colors.bright_red;
            } else if (std.mem.eql(u8, ext, "mp3") or std.mem.eql(u8, ext, "wav") or
                std.mem.eql(u8, ext, "flac") or std.mem.eql(u8, ext, "ogg"))
            {
                return Colors.yellow;
            } else if (std.mem.eql(u8, ext, "zip") or std.mem.eql(u8, ext, "tar") or
                std.mem.eql(u8, ext, "gz") or std.mem.eql(u8, ext, "rar") or
                std.mem.eql(u8, ext, "7z"))
            {
                return Colors.red;
            } else if (std.mem.eql(u8, ext, "zig") or std.mem.eql(u8, ext, "c") or
                std.mem.eql(u8, ext, "cpp") or std.mem.eql(u8, ext, "rs") or
                std.mem.eql(u8, ext, "py") or std.mem.eql(u8, ext, "js") or
                std.mem.eql(u8, ext, "ts") or std.mem.eql(u8, ext, "go"))
            {
                return Colors.green;
            }
        }

        return Colors.white;
    }
};

const Config = struct {
    show_hidden: bool = false,
    long_format: bool = false,
    show_icons: bool = true,
    show_colors: bool = true,
    sort_by_size: bool = false,
    sort_by_time: bool = false,
    reverse_sort: bool = false,
    human_readable: bool = true,
    show_permissions: bool = false,
};

fn formatSize(size: u64, human_readable: bool, allocator: Allocator) ![]u8 {
    if (!human_readable) {
        return std.fmt.allocPrint(allocator, "{d}", .{size});
    }

    const units = [_][]const u8{ "B", "K", "M", "G", "T", "P" };
    var size_f: f64 = @floatFromInt(size);
    var unit_idx: usize = 0;

    while (size_f >= 1024.0 and unit_idx < units.len - 1) {
        size_f /= 1024.0;
        unit_idx += 1;
    }

    if (unit_idx == 0) {
        return std.fmt.allocPrint(allocator, "{d}B", .{size});
    } else {
        return std.fmt.allocPrint(allocator, "{d:.1}{s}", .{ size_f, units[unit_idx] });
    }
}

fn formatPermissions(mode: u32, allocator: Allocator) ![]u8 {
    var perms = try allocator.alloc(u8, 10);

    // File type
    perms[0] = if (std.os.linux.S.ISDIR(mode)) 'd' else if (std.os.linux.S.ISLNK(mode)) 'l' else '-';

    // Owner permissions
    perms[1] = if (mode & std.os.linux.S.IRUSR != 0) 'r' else '-';
    perms[2] = if (mode & std.os.linux.S.IWUSR != 0) 'w' else '-';
    perms[3] = if (mode & std.os.linux.S.IXUSR != 0) 'x' else '-';

    // Group permissions
    perms[4] = if (mode & std.os.linux.S.IRGRP != 0) 'r' else '-';
    perms[5] = if (mode & std.os.linux.S.IWGRP != 0) 'w' else '-';
    perms[6] = if (mode & std.os.linux.S.IXGRP != 0) 'x' else '-';

    // Other permissions
    perms[7] = if (mode & std.os.linux.S.IROTH != 0) 'r' else '-';
    perms[8] = if (mode & std.os.linux.S.IWOTH != 0) 'w' else '-';
    perms[9] = if (mode & std.os.linux.S.IXOTH != 0) 'x' else '-';

    return perms;
}

fn collectFiles(allocator: Allocator, dir_path: []const u8, config: Config) !ArrayList(FileInfo) {
    var files = ArrayList(FileInfo).init(allocator);

    var dir = std.fs.cwd().openDir(dir_path, .{ .iterate = true }) catch |err| switch (err) {
        error.FileNotFound => {
            print("lsx: cannot access '{s}': No such file or directory\n", .{dir_path});
            return files;
        },
        error.AccessDenied => {
            print("lsx: cannot access '{s}': Permission denied\n", .{dir_path});
            return files;
        },
        else => return err,
    };
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |entry| {
        const is_hidden = entry.name[0] == '.';
        if (!config.show_hidden and is_hidden) continue;

        const full_path = try std.fs.path.join(allocator, &[_][]const u8{ dir_path, entry.name });
        defer allocator.free(full_path);

        const stat = dir.statFile(entry.name) catch |err| switch (err) {
            error.FileNotFound => continue,
            else => return err,
        };

        const is_executable = stat.mode & std.os.linux.S.IXUSR != 0;
        const is_symlink = entry.kind == .sym_link;

        const file_info = FileInfo{
            .name = try allocator.dupe(u8, entry.name),
            .path = try allocator.dupe(u8, full_path),
            .size = stat.size,
            .is_dir = entry.kind == .directory,
            .is_executable = is_executable and entry.kind != .directory,
            .is_hidden = is_hidden,
            .is_symlink = is_symlink,
            .mtime = stat.mtime,
            .permissions = @intCast(stat.mode),
        };

        try files.append(file_info);
    }

    return files;
}

fn sortFiles(files: []FileInfo, config: Config) void {
    const Context = struct {
        config: Config,

        fn lessThan(context: @This(), a: FileInfo, b: FileInfo) bool {
            // Directories always come first
            if (a.is_dir != b.is_dir) {
                return a.is_dir and !b.is_dir;
            }

            var result: bool = undefined;

            if (context.config.sort_by_size) {
                result = a.size < b.size;
            } else if (context.config.sort_by_time) {
                result = a.mtime < b.mtime;
            } else {
                // Sort by name (case-insensitive)
                const a_lower = std.ascii.allocLowerString(std.heap.page_allocator, a.name) catch a.name;
                const b_lower = std.ascii.allocLowerString(std.heap.page_allocator, b.name) catch b.name;
                defer if (a_lower.ptr != a.name.ptr) std.heap.page_allocator.free(a_lower);
                defer if (b_lower.ptr != b.name.ptr) std.heap.page_allocator.free(b_lower);

                result = std.mem.order(u8, a_lower, b_lower) == .lt;
            }

            return if (context.config.reverse_sort) !result else result;
        }
    };

    std.mem.sort(FileInfo, files, Context{ .config = config }, Context.lessThan);
}

fn displayFiles(files: []FileInfo, config: Config, allocator: Allocator) !void {
    if (config.long_format) {
        // Long format display
        for (files) |file| {
            // Permissions
            if (config.show_permissions) {
                const perms = try formatPermissions(file.permissions, allocator);
                defer allocator.free(perms);
                print("{s} ", .{perms});
            }

            // Size
            const size_str = try formatSize(file.size, config.human_readable, allocator);
            defer allocator.free(size_str);
            print("{s:>8} ", .{size_str});

            // Icon and name with color
            if (config.show_icons) {
                print("{s} ", .{file.getIcon()});
            }

            if (config.show_colors) {
                print("{s}{s}{s}", .{ file.getColor(), file.name, Colors.reset });
            } else {
                print("{s}", .{file.name});
            }

            if (file.is_symlink) {
                // Try to read the symlink target
                var target_buf: [std.fs.max_path_bytes]u8 = undefined;
                if (std.fs.cwd().readLink(file.path, &target_buf)) |target| {
                    print(" -> {s}", .{target});
                } else |_| {
                    print(" -> (broken link)", .{});
                }
            }

            print("\n", .{});
        }
    } else {
        // Grid format display
        var max_name_len: usize = 0;
        for (files) |file| {
            const display_len = if (config.show_icons) file.name.len + 3 else file.name.len;
            if (display_len > max_name_len) {
                max_name_len = display_len;
            }
        }

        const terminal_width = 80; // Could be dynamic
        const cols = @max(1, terminal_width / (max_name_len + 2));

        for (files, 0..) |file, i| {
            if (config.show_icons) {
                print("{s} ", .{file.getIcon()});
            }

            if (config.show_colors) {
                print("{s}{s}{s}", .{ file.getColor(), file.name, Colors.reset });
            } else {
                print("{s}", .{file.name});
            }

            if ((i + 1) % cols == 0 or i == files.len - 1) {
                print("\n", .{});
            } else {
                const padding = max_name_len - file.name.len;
                var j: usize = 0;
                while (j < padding + 2) : (j += 1) {
                    print(" ", .{});
                }
            }
        }
    }
}

fn printUsage() void {
    print("lsx - A modern alternative to ls\n\n", .{});
    print("USAGE:\n", .{});
    print("    lsx [OPTIONS] [PATH...]\n\n", .{});
    print("OPTIONS:\n", .{});
    print("    -a, --all          Show hidden files\n", .{});
    print("    -l, --long         Use long format\n", .{});
    print("    -S, --size         Sort by file size\n", .{});
    print("    -t, --time         Sort by modification time\n", .{});
    print("    -r, --reverse      Reverse sort order\n", .{});
    print("    -h, --help         Show this help message\n", .{});
    print("    --no-icons         Disable icons\n", .{});
    print("    --no-colors        Disable colors\n", .{});
    print("    --bytes            Show exact byte sizes\n", .{});
    print("    -p, --permissions  Show permissions (in long format)\n\n", .{});
    print("EXAMPLES:\n", .{});
    print("    lsx                List current directory\n", .{});
    print("    lsx -la            List all files in long format\n", .{});
    print("    lsx -S /usr/bin    List /usr/bin sorted by size\n", .{});
    print("    lsx -t --reverse   List sorted by time (newest first)\n", .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var config = Config{};
    var paths = ArrayList([]const u8).init(allocator);
    defer paths.deinit();

    // Parse command line arguments
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];

        if (std.mem.eql(u8, arg, "-a") or std.mem.eql(u8, arg, "--all")) {
            config.show_hidden = true;
        } else if (std.mem.eql(u8, arg, "-l") or std.mem.eql(u8, arg, "--long")) {
            config.long_format = true;
        } else if (std.mem.eql(u8, arg, "-S") or std.mem.eql(u8, arg, "--size")) {
            config.sort_by_size = true;
        } else if (std.mem.eql(u8, arg, "-t") or std.mem.eql(u8, arg, "--time")) {
            config.sort_by_time = true;
        } else if (std.mem.eql(u8, arg, "-r") or std.mem.eql(u8, arg, "--reverse")) {
            config.reverse_sort = true;
        } else if (std.mem.eql(u8, arg, "-p") or std.mem.eql(u8, arg, "--permissions")) {
            config.show_permissions = true;
        } else if (std.mem.eql(u8, arg, "--no-icons")) {
            config.show_icons = false;
        } else if (std.mem.eql(u8, arg, "--no-colors")) {
            config.show_colors = false;
        } else if (std.mem.eql(u8, arg, "--bytes")) {
            config.human_readable = false;
        } else if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            printUsage();
            return;
        } else if (arg[0] == '-' and arg.len > 1 and arg[1] != '-') {
            // Handle combined short flags (e.g., -la, -ltr, etc.)
            for (arg[1..]) |flag_char| {
                switch (flag_char) {
                    'a' => config.show_hidden = true,
                    'l' => config.long_format = true,
                    'S' => config.sort_by_size = true,
                    't' => config.sort_by_time = true,
                    'r' => config.reverse_sort = true,
                    'p' => config.show_permissions = true,
                    'h' => {
                        printUsage();
                        return;
                    },
                    else => {
                        print("lsx: unknown option '-{c}'\n", .{flag_char});
                        print("Try 'lsx --help' for more information.\n", .{});
                        return;
                    },
                }
            }
        } else if (arg[0] != '-') {
            try paths.append(arg);
        } else {
            print("lsx: unknown option '{s}'\n", .{arg});
            print("Try 'lsx --help' for more information.\n", .{});
            return;
        }
    }

    // If no paths specified, use current directory
    if (paths.items.len == 0) {
        try paths.append(".");
    }

    // Process each path
    for (paths.items, 0..) |path, path_idx| {
        if (paths.items.len > 1) {
            if (path_idx > 0) print("\n", .{});
            print("{s}:\n", .{path});
        }

        var files = try collectFiles(allocator, path, config);
        defer {
            for (files.items) |file| {
                allocator.free(file.name);
                allocator.free(file.path);
            }
            files.deinit();
        }

        sortFiles(files.items, config);
        try displayFiles(files.items, config, allocator);
    }
}
