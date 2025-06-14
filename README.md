<div align="center">

# 🚀 lsx

**A beautiful, fast, and modern alternative to `ls`**

_Written in Zig for blazing performance_

[![CI](https://github.com/rohit746/lsx/workflows/CI/badge.svg)](https://github.com/rohit746/lsx/actions)
[![Release](https://github.com/rohit746/lsx/workflows/Release/badge.svg)](https://github.com/rohit746/lsx/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

---

## ✨ Features

- 🎨 **Color-coded output** - Different colors for files, directories, symlinks, and executables
- 📁 **File type icons** - Beautiful Unicode icons for instant file recognition
- 📊 **Smart sorting** - Sort by name, size, or modification time
- 👁️ **Hidden files** - Toggle visibility with `-a` flag
- 📏 **Human-readable sizes** - Display sizes in KB, MB, GB format
- 🔐 **Permissions display** - Clear permission formatting in long mode
- ⚡ **Fast performance** - Built with Zig for maximum speed
- 🌐 **Cross-platform** - Works on Linux, macOS, and Windows

## 📸 Preview

```
📁 Documents/     📄 README.md      🖼️ image.png      ⚙️ config.json
📂 src/           📜 script.sh      🎵 music.mp3      🔗 symlink.txt
```

**Long format:**

```
drwxr-xr-x  user  staff   128B  Jun 14 10:30  📁 Documents/
-rw-r--r--  user  staff  1.2KB  Jun 14 09:15  📄 README.md
-rwxr-xr-x  user  staff   456B  Jun 14 08:45  📜 script.sh
```

## 🚀 Quick Start

### Installation

#### Option 1: Download Release Binary

```bash
# Download from GitHub releases
curl -L https://github.com/rohit746/lsx/releases/latest/download/lsx-linux-x86_64 -o lsx
chmod +x lsx
sudo mv lsx /usr/local/bin/
```

#### Option 2: Build from Source

```bash
git clone https://github.com/rohit746/lsx.git
cd lsx
zig build -Doptimize=ReleaseFast
sudo cp zig-out/bin/lsx /usr/local/bin/
```

### Basic Usage

```bash
# List current directory
lsx

# List with hidden files
lsx -a

# Long format with details
lsx -l

# Combine options
lsx -la
```

## 📖 Usage Guide

### Command Syntax

```bash
lsx [OPTIONS] [PATH...]
```

### 🔧 Options

| Option | Long Form       | Description                              |
| ------ | --------------- | ---------------------------------------- |
| `-a`   | `--all`         | Show hidden files and directories        |
| `-l`   | `--long`        | Use long listing format with details     |
| `-S`   | `--size`        | Sort by file size (largest first)        |
| `-t`   | `--time`        | Sort by modification time (newest first) |
| `-r`   | `--reverse`     | Reverse the sort order                   |
| `-p`   | `--permissions` | Show detailed permissions                |
|        | `--no-colors`   | Disable colored output                   |
|        | `--no-icons`    | Disable file type icons                  |
|        | `--bytes`       | Show exact file sizes in bytes           |
| `-h`   | `--help`        | Display help information                 |

### 💡 Examples

```bash
# List all files in long format with permissions
lsx -lap

# Sort by size, largest files first
lsx -lS

# Sort by time, newest files first
lsx -lt

# Reverse time sort (oldest first)
lsx -ltr

# Multiple directories
lsx /usr/bin /etc /tmp

# Clean output for scripts
lsx --no-colors --no-icons /path/to/dir
```

## 🛠️ Development

### Prerequisites

- [Zig](https://ziglang.org/) 0.14.0 or later

### Building

```bash
# Debug build
zig build

# Release build
zig build -Doptimize=ReleaseFast

# Run tests
zig build test

# Format code
zig fmt src/
```

### Project Structure

```
lsx/
├── src/
│   ├── main.zig          # Main application logic
│   ├── root.zig          # Core utilities and types
│   ├── test_main.zig     # Unit tests
│   └── test_cli.zig      # Integration tests
├── build.zig             # Build configuration
└── build.zig.zon         # Package manifest
```

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. 🐛 Report bugs
2. 💡 Suggest new features
3. 🔧 Submit pull requests
4. 📖 Improve documentation

Please ensure your code is formatted (`zig fmt`) and tests pass (`zig build test`) before submitting.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by modern tools like `exa` and `lsd`
- Built with the amazing [Zig](https://ziglang.org/) programming language
- Icons use Unicode emojis for universal compatibility

---

<div align="center">

**Made with ❤️ and Zig**

[Report Bug](https://github.com/rohit746/lsx/issues) · [Request Feature](https://github.com/rohit746/lsx/issues) · [Releases](https://github.com/rohit746/lsx/releases)

</div>
