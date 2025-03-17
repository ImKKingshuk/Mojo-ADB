# MojoADB: App Management Module

from core.client import ADBClient

# App installation and management functions
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