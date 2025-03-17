# MojoADB

A powerful ADB client written in Mojo, providing enhanced functionality for Android device management.

## Features

### Core Features

- Device management (list, reboot, root, etc.)
- File operations (push, pull, sync)
- App management (install, uninstall)
- Shell command execution
- Logging (logcat, bugreport, dumpsys)

### Enhanced Features

#### Wireless Debugging

- Easy wireless connection setup with `mojoadb wireless`
- Automatic reconnection to wireless devices
- TCP/IP mode management

#### Device Diagnostics

- Comprehensive system information
- Battery health monitoring
- Memory usage analysis
- Network statistics
- Quick device health checks

#### Batch Operations

- Execute commands on all connected devices
- Install/uninstall apps on multiple devices
- Push/pull files to/from multiple devices
- Run shell commands across all devices

#### Real-time Device Monitoring

- Track device connections and disconnections
- Monitor device state changes
- Callback support for device events

## Usage

```
mojoadb [-s <serial>] [-v] <command> [options] [args]
```

### Basic Commands

- `devices` - List connected devices
- `shell [command]` - Run shell command or interactive shell
- `push <src> <dest>` - Push file to device
- `pull <src> <dest>` - Pull file from device
- `install <apk> [flags]` - Install APK
- `uninstall [-k] <package>` - Uninstall package

### Wireless Commands

- `wireless [port]` - Set up wireless debugging
- `tcpip <port>` - Switch to TCP/IP mode
- `connect <host:port>` - Connect to device
- `disconnect [host:port]` - Disconnect from device
- `list-forwards` - List port forwards
- `list-reverses` - List reverse port forwards

### Diagnostics Commands

- `diagnostics health` - Check device health
- `diagnostics system` - Show system information
- `diagnostics battery` - Show battery information
- `diagnostics network` - Show network information
- `diagnostics performance [duration] [interval]` - Monitor device performance

### Batch Commands

- `batch shell <command>` - Run shell command on all devices
- `batch install <apk> [flags]` - Install APK on all devices
- `batch uninstall [-k] <package>` - Uninstall package from all devices
- `batch push <local> <remote>` - Push file to all devices
- `batch pull <remote> <local_dir>` - Pull file from all devices
- `batch reboot [mode]` - Reboot all devices

## Examples

```bash
# Set up wireless debugging
mojoadb -s <serial> wireless

# Check device health
mojoadb -s <serial> diagnostics health

# Install app on all connected devices
mojoadb batch install path/to/app.apk

# Run a shell command on all devices
mojoadb batch shell "ls /sdcard"
```

## License

GNU General Public License v3.0
