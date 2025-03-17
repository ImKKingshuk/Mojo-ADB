# MojoADB: Device Management Module

from core.client import ADBClient

# Device listing and information functions
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

fn get_state(client: ADBClient):
    let result = client.send_command("get-state")
    print("Device state:", result)

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