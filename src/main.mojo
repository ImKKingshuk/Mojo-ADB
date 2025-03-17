# MojoADB: Main Module

from core.client import ADBClient
from core.errors import ADBError
from device.management import (
    list_devices, get_serialno, reboot, emu_kill, kill_server, start_server,
    get_state, wait_for_device, root, unroot, remount, sideload
)
from file.operations import push_file, pull_file, sync, rm_file
from shell.commands import run_shell, interactive_shell
from app.management import install_app, install_multi, uninstall_app, pm_command
from logging.logs import logcat, bugreport, dumpsys
from network.connections import (
    switch_to_tcpip, connect_device, disconnect_device, forward, reverse,
    list_forwards, list_reverses, setup_wireless_debugging
)
from device.diagnostics import DeviceDiagnostics
from device.batch import BatchOperations
from device.tracker import DeviceTracker
from device.performance import PerformanceMonitor


fn main():
    var args = sys.argv()
    if len(args) < 2:
        print("Usage: mojoadb [-s <serial>] [-v] <command> [options] [args]")
        print("Commands: devices, push, pull, shell, install, logcat, reboot, dumpsys, etc.")
        return

    var serial = ""
    var verbose = False
    var i = 1

  
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
        elif command == "wireless":
            let port = int(args[i]) if i < len(args) else 5555
            setup_wireless_debugging(client, port)
        elif command == "list-forwards":
            print(list_forwards(client))
        elif command == "list-reverses":
            print(list_reverses(client))
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
        elif command == "diagnostics":
            let diagnostics = DeviceDiagnostics(client)
            if i < len(args):
                if args[i] == "health":
                    let health = diagnostics.check_device_health(client.serial)
                    print("Device Health Check:")
                    for key, value in health.items():
                        print("  " + key + ": " + value)
                elif args[i] == "system":
                    let system_info = diagnostics.get_system_info(client.serial)
                    print("System Information:")
                    for key, value in system_info.items():
                        if key not in ["cpu_info", "mem_info", "storage_info"]:
                            print("  " + key + ": " + value)
                elif args[i] == "battery":
                    let battery = diagnostics.get_battery_health(client.serial)
                    print("Battery Information:")
                    for key, value in battery.items():
                        if key != "stats":
                            print("  " + key + ": " + value)
                elif args[i] == "network":
                    let network = diagnostics.get_network_stats(client.serial)
                    print("Network Information:")
                    for key, value in network.items():
                        if key not in ["interfaces", "statistics", "wifi"]:
                            print("  " + key + ": " + value)
                elif args[i] == "performance":
                    let duration = int(args[i+1]) if i+1 < len(args) else 60
                    let interval = int(args[i+2]) if i+2 < len(args) else 5
                    print("Monitoring device performance for", duration, "seconds with", interval, "second intervals...")
                    diagnostics.monitor_performance(client.serial, duration, interval)
                else:
                    print("Unknown diagnostics command. Available: health, system, battery, network, performance")
            else:
                print("Usage: mojoadb diagnostics <health|system|battery|network|performance> [duration] [interval]>")
        elif command == "batch":
            if i >= len(args):
                print("Usage: mojoadb batch <command>")
                return
                
            let batch = BatchOperations(client)
            let batch_command = args[i]
            i += 1
            
            if batch_command == "shell":
                if i >= len(args):
                    print("Usage: mojoadb batch shell <shell_command>")
                    return
                let results = batch.shell_on_all(" ".join(args[i:]))
                print("Shell command results:")
                for serial, result in results.items():
                    print("\nDevice:", serial)
                    print(result)
            elif batch_command == "install":
                if i >= len(args):
                    print("Usage: mojoadb batch install <apk_path> [flags]")
                    return
                let apk_path = args[i]
                i += 1
                let flags = " ".join(args[i:]) if i < len(args) else ""
                let results = batch.install_on_all(apk_path, flags)
                print("Installation results:")
                for serial, result in results.items():
                    print("Device:", serial, "-", result)
            elif batch_command == "uninstall":
                if i >= len(args):
                    print("Usage: mojoadb batch uninstall [-k] <package>")
                    return
                let keep_data = "-k" in args[i:]
                let pkg_idx = i + 1 if "-k" in args[i:i+1] else i
                if pkg_idx >= len(args):
                    print("Package name required")
                    return
                let results = batch.uninstall_from_all(args[pkg_idx], keep_data)
                print("Uninstallation results:")
                for serial, result in results.items():
                    print("Device:", serial, "-", result)
            elif batch_command == "push":
                if i + 1 >= len(args):
                    print("Usage: mojoadb batch push <local_path> <remote_path>")
                    return
                let results = batch.push_to_all(args[i], args[i+1])
                print("Push results:")
                for serial, result in results.items():
                    print("Device:", serial, "-", result)
            elif batch_command == "pull":
                if i + 1 >= len(args):
                    print("Usage: mojoadb batch pull <remote_path> <local_dir>")
                    return
                let results = batch.pull_from_all(args[i], args[i+1])
                print("Pull results:")
                for serial, result in results.items():
                    print("Device:", serial, "-", result)
            elif batch_command == "reboot":
                let mode = args[i] if i < len(args) else ""
                let results = batch.reboot_all(mode)
                print("Reboot results:")
                for serial, result in results.items():
                    print("Device:", serial, "-", result)
            else:
                print("Unknown batch command:", batch_command)
        else:
            print("Unknown command:", command)
    except e: ADBError:
        print("Error:", e.__str__())

if __name__ == "__main__":
    main()