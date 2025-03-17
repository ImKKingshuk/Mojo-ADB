# MojoADB: Network Connections Module

from core.client import ADBClient

# Network connection functions
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