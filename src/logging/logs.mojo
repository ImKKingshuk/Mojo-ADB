# MojoADB: Logging Module

from client.adb_client import ADBClient

# Logging and debugging functions
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