# MojoADB: A feature-rich, robust ADB implementation in Mojo


# System call implementation using Python's subprocess module
fn system_call(cmd: String) -> String:
    from python import Python
    try:
        subprocess = Python.import_module("subprocess")
        result = subprocess.run(cmd, shell=True, text=True, capture_output=True)
        if result.returncode != 0 and result.stderr:
            return "error: " + result.stderr
        return result.stdout
    except e:
        return "error: Failed to execute command: " + cmd

# Error handling struct
struct ADBError:
    var message: String
    var code: Int
    var command: String
    
    fn __init__(inout self, message: String, code: Int = -1, command: String = ""):
        self.message = message
        self.code = code
        self.command = command
        
    fn __str__(self) -> String:
        var error_str = self.message
        if self.command:
            error_str += " (Command: " + self.command + ")"
        if self.code != -1:
            error_str += " (Code: " + str(self.code) + ")"
        return error_str

# ADB Client
struct ADBClient:
    var host: String
    var port: Int
    var serial: String
    var verbose: Bool

    fn __init__(inout self, serial: String = "", verbose: Bool = False):
        self.host = "localhost"
        self.port = 5037
        self.serial = serial
        self.verbose = verbose

    fn send_command(self, command: String) -> String:
        var full_cmd = "adb"
        if self.serial != "":
            full_cmd += " -s " + self.serial
        full_cmd += " " + command
        if self.verbose:
            print("[VERBOSE] Executing:", full_cmd)
        let result = system_call(full_cmd)
        if "error" in result.lower():
            # Extract error code if available
            var error_code = -1
            if "error code" in result.lower():
                try:
                    # Try to extract error code from string like "error code: 1"
                    let code_str = result.split("error code:")[1].strip().split()[0]
                    error_code = int(code_str)
                except e:
                    pass
            raise ADBError("Command failed: " + result, error_code, full_cmd)
        return result

# Device Management
fn list_devices(client: ADBClient):
    let output = client.send_command("devices -l")
    if output.strip() == "":
        print("No devices found.")
    else:
        print("List of devices attached:")
        print(output)

fn get_serialno(client: ADBClient):
    let output = client.send_command("get-serialno")
    print("Serial number:", output)

fn reboot(client: ADBClient, mode: String = ""):
    let cmd = "reboot " + mode if mode else "reboot"
    let result = client.send_command(cmd)
    print(result)

fn emu_kill(client: ADBClient):
    let result = client.send_command("emu kill")
    print("Emulator killed:", result)

fn kill_server(client: ADBClient):
    let result = client.send_command("kill-server")
    print("ADB server killed.")

fn start_server(client: ADBClient):
    let result = client.send_command("start-server")
    print("ADB server started.")

# File Operations
fn push_file(client: ADBClient, src: String, dest: String):
    let cmd = "push " + src + " " + dest
    let result = client.send_command(cmd)
    print("Pushed", src, "to", dest, ":", result)

fn pull_file(client: ADBClient, src: String, dest: String):
    let cmd = "pull " + src + " " + dest
    let result = client.send_command(cmd)
    print("Pulled", src, "to", dest, ":", result)

fn sync(client: ADBClient, local_dir: String, remote_dir: String):
    let cmd = "sync " + local_dir + " " + remote_dir
    let result = client.send_command(cmd)
    print("Synced", local_dir, "to", remote_dir, ":", result)

fn rm_file(client: ADBClient, path: String):
    let result = client.send_command("shell rm " + path)
    print("Removed", path, ":", result)

# Shell Access
fn run_shell(client: ADBClient, command: String):
    let result = client.send_command("shell " + command)
    print(result)

fn interactive_shell(client: ADBClient):
    print("Interactive shell (type 'exit' to quit)")
    while True:
        let cmd = input("shell> ")
        if cmd == "exit":
            break
        elif cmd.strip() == "":
            continue
        run_shell(client, cmd)

# App Management
fn install_app(client: ADBClient, apk_path: String, flags: String = ""):
    let cmd = "install " + flags + " " + apk_path
    let result = client.send_command(cmd)
    print("Installed", apk_path, ":", result)

fn install_multi(client: ADBClient, apks: List[String]):
    let apk_list = " ".join(apks)
    let result = client.send_command("install-multi " + apk_list)
    print("Installed multiple APKs:", result)

fn uninstall_app(client: ADBClient, package: String, keep_data: Bool = False):
    let cmd = "uninstall " + ("-k " if keep_data else "") + package
    let result = client.send_command(cmd)
    print("Uninstalled", package, ":", result)

fn pm_command(client: ADBClient, pm_args: String):
    let result = client.send_command("shell pm " + pm_args)
    print("Package manager output:", result)


fn logcat(client: ADBClient, filter: String = ""):
    let cmd = "logcat " + filter
    let result = client.send_command(cmd)
    print(result)  

fn bugreport(client: ADBClient, output_path: String = ""):
    let cmd = "bugreport " + output_path if output_path else "bugreport"
    let result = client.send_command(cmd)
    print("Bug report:", result)

fn dumpsys(client: ADBClient, service: String = ""):
    let cmd = "shell dumpsys " + service if service else "shell dumpsys"
    let result = client.send_command(cmd)
    print("Dumpsys output:", result)

# Networking
fn switch_to_tcpip(client: ADBClient, port: Int):
    let cmd = "tcpip " + str(port)
    let result = client.send_command(cmd)
    print("Switched to TCP/IP on port", port, ":", result)

fn connect_device(client: ADBClient, host_port: String):
    let result = client.send_command("connect " + host_port)
    print("Connected to", host_port, ":", result)

fn disconnect_device(client: ADBClient, host_port: String = ""):
    let cmd = "disconnect " + host_port if host_port else "disconnect"
    let result = client.send_command(cmd)
    print("Disconnected:", result)

fn forward(client: ADBClient, local: String, remote: String):
    let cmd = "forward " + local + " " + remote
    let result = client.send_command(cmd)
    print("Forwarded", local, "to", remote, ":", result)

fn reverse(client: ADBClient, remote: String, local: String):
    let cmd = "reverse " + remote + " " + local
    let result = client.send_command(cmd)
    print("Reversed", remote, "to", local, ":", result)

# Miscellaneous
fn wait_for_device(client: ADBClient, state: String = "device"):
    let cmd = "wait-for-" + state
    let result = client.send_command(cmd)
    print("Waited for", state, ":", result)

fn root(client: ADBClient):
    let result = client.send_command("root")
    print("Rooted:", result)

fn unroot(client: ADBClient):
    let result = client.send_command("unroot")
    print("Unrooted:", result)

fn remount(client: ADBClient):
    let result = client.send_command("remount")
    print("Remounted:", result)

fn sideload(client: ADBClient, zip_path: String):
    let result = client.send_command("sideload " + zip_path)
    print("Sideloaded", zip_path, ":", result)

fn get_state(client: ADBClient):
    let result = client.send_command("get-state")
    print("Device state:", result)

# Main CLI
fn main():
    var args = sys.argv()
    if len(args) < 2:
        print("Usage: mojoadb [-s <serial>] [-v] <command> [options] [args]")
        print("Commands: devices, push, pull, shell, install, logcat, reboot, dumpsys, etc.")
        return

    var serial = ""
    var verbose = False
    var i = 1

    # Parse flags
    while i < len(args) and args[i].startswith("-"):
        if args[i] == "-s" and i + 1 < len(args):
            serial = args[i + 1]
            i += 2
        elif args[i] == "-v":
            verbose = True
            i += 1
        else:
            print("Unknown flag:", args[i])
            return

    let client = ADBClient(serial, verbose)
    let command = args[i]
    i += 1

  
    try:
        if command == "devices":
            list_devices(client)
        elif command == "get-serialno":
            get_serialno(client)
        elif command == "reboot":
            let mode = args[i] if i < len(args) else ""
            reboot(client, mode)
        elif command == "emu-kill":
            emu_kill(client)
        elif command == "kill-server":
            kill_server(client)
        elif command == "start-server":
            start_server(client)
        elif command == "push":
            if i + 1 >= len(args):
                print("Usage: mojoadb push <src> <dest>")
                return
            push_file(client, args[i], args[i + 1])
        elif command == "pull":
            if i + 1 >= len(args):
                print("Usage: mojoadb pull <src> <dest>")
                return
            pull_file(client, args[i], args[i + 1])
        elif command == "sync":
            if i + 1 >= len(args):
                print("Usage: mojoadb sync <local_dir> <remote_dir>")
                return
            sync(client, args[i], args[i + 1])
        elif command == "rm":
            if i >= len(args):
                print("Usage: mojoadb rm <path>")
                return
            rm_file(client, args[i])
        elif command == "shell":
            if i >= len(args):
                interactive_shell(client)
            else:
                run_shell(client, " ".join(args[i:]))
        elif command == "install":
            if i >= len(args):
                print("Usage: mojoadb install <apk> [flags]")
                return
            let flags = " ".join(args[i + 1:]) if i + 1 < len(args) else ""
            install_app(client, args[i], flags)
        elif command == "install-multi":
            if i >= len(args):
                print("Usage: mojoadb install-multi <apk1> <apk2> ...")
                return
            install_multi(client, args[i:])
        elif command == "uninstall":
            if i >= len(args):
                print("Usage: mojoadb uninstall [-k] <package>")
                return
            let keep_data = "-k" in args[i:]
            let pkg_idx = i + 1 if "-k" in args[i:] else i
            uninstall_app(client, args[pkg_idx], keep_data)
        elif command == "pm":
            if i >= len(args):
                print("Usage: mojoadb pm <args>")
                return
            pm_command(client, " ".join(args[i:]))
        elif command == "logcat":
            let filter = " ".join(args[i:]) if i < len(args) else ""
            logcat(client, filter)
        elif command == "bugreport":
            let path = args[i] if i < len(args) else ""
            bugreport(client, path)
        elif command == "dumpsys":
            let service = args[i] if i < len(args) else ""
            dumpsys(client, service)
        elif command == "tcpip":
            if i >= len(args):
                print("Usage: mojoadb tcpip <port>")
                return
            switch_to_tcpip(client, int(args[i]))
        elif command == "connect":
            if i >= len(args):
                print("Usage: mojoadb connect <host:port>")
                return
            connect_device(client, args[i])
        elif command == "disconnect":
            let host_port = args[i] if i < len(args) else ""
            disconnect_device(client, host_port)
        elif command == "forward":
            if i + 1 >= len(args):
                print("Usage: mojoadb forward <local> <remote>")
                return
            forward(client, args[i], args[i + 1])
        elif command == "reverse":
            if i + 1 >= len(args):
                print("Usage: mojoadb reverse <remote> <local>")
                return
            reverse(client, args[i], args[i + 1])
        elif command == "wait-for":
            let state = args[i] if i < len(args) else "device"
            wait_for_device(client, state)
        elif command == "root":
            root(client)
        elif command == "unroot":
            unroot(client)
        elif command == "remount":
            remount(client)
        elif command == "sideload":
            if i >= len(args):
                print("Usage: mojoadb sideload <zip>")
                return
            sideload(client, args[i])
        elif command == "get-state":
            get_state(client)
        else:
            print("Unknown command:", command)
    except e: ADBError:
        print("Error:", e.__str__())

if __name__ == "__main__":
    main()