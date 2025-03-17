# MojoADB

A feature-rich, robust ADB (Android Debug Bridge) implementation in Mojo language.

## Features

- **Device Management**: List devices, get serial numbers, reboot devices, etc.
- **File Operations**: Push, pull, sync, and remove files on Android devices
- **Shell Access**: Run shell commands or start an interactive shell
- **App Management**: Install, uninstall, and manage Android applications
- **Logging**: Access device logs with logcat, bugreport, and dumpsys
- **Networking**: TCP/IP mode, connect/disconnect devices, port forwarding
- **System Operations**: Root access, remount filesystems, sideload packages

## Requirements

- Mojo SDK
- ADB command-line tools installed and available in PATH
- Android device or emulator

## Installation

```bash
# Clone the repository
git clone https://github.com/ImKKingshuk/Mojo-ADB.git
cd Mojo-ADB

# Build with Mojo
mojo build MojoADB.mojo -o mojoadb
```

## Usage

```bash
# Basic usage
./mojoadb [-s <serial>] [-v] <command> [options] [args]

# List connected devices
./mojoadb devices

# Push a file to device
./mojoadb push local_file.txt /sdcard/remote_file.txt

# Pull a file from device
./mojoadb pull /sdcard/remote_file.txt local_file.txt

# Run a shell command
./mojoadb shell ls -la /sdcard

# Start an interactive shell
./mojoadb shell

# Install an APK
./mojoadb install app.apk

# View device logs
./mojoadb logcat
```

## Available Commands

### Device Management

- `devices`: List connected devices
- `get-serialno`: Get device serial number
- `reboot [bootloader|recovery|sideload|sideload-auto-reboot]`: Reboot device
- `emu-kill`: Kill emulator
- `kill-server`: Kill ADB server
- `start-server`: Start ADB server

### File Operations

- `push <local> <remote>`: Copy file/dir to device
- `pull <remote> <local>`: Copy file/dir from device
- `sync <local> <remote>`: Sync directory
- `rm <path>`: Remove file from device

### Shell Access

- `shell [command]`: Run remote shell command or interactive shell

### App Management

- `install [options] <apk>`: Install app
- `install-multi <apk1> <apk2> ...`: Install multiple APKs
- `uninstall [-k] <package>`: Uninstall app (keep data with -k)
- `pm <args>`: Package manager commands

### Logging

- `logcat [filter]`: View device logs
- `bugreport [path]`: Generate bug report
- `dumpsys [service]`: Dump system service info

### Networking

- `tcpip <port>`: Switch to TCP/IP mode
- `connect <host:port>`: Connect to device
- `disconnect [host:port]`: Disconnect from device
- `forward <local> <remote>`: Forward socket connections
- `reverse <remote> <local>`: Reverse socket connections

### System Operations

- `wait-for [state]`: Wait for device state
- `root`: Restart ADB with root permissions
- `unroot`: Restart ADB without root permissions
- `remount`: Remount partitions read-write
- `sideload <zip>`: Sideload package
- `get-state`: Get device state

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

## Author

[ImKKingshuk](https://github.com/ImKKingshuk)
