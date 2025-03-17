# MojoADB: Main Module

# Import core modules
from core.client import ADBClient
from core.errors import ADBError

# Import feature modules
from device.management import (
    list_devices, get_serialno, reboot, emu_kill, kill_server, start_server,
    get_state, wait_for_device, root, unroot, remount, sideload
)
from file.operations import push_file, pull_file, sync, rm_file
from shell.commands import run_shell, interactive_shell
from app.management import install_app, install_multi, uninstall_app, pm_command
from logging.logs import logcat, bugreport, dumpsys
from network.connections import switch_to_tcpip, connect_device, disconnect_device, forward, reverse

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