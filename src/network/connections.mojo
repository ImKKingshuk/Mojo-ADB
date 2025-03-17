# MojoADB: Network Connections Module

from core.client import ADBClient
from core.errors import ADBError
from device.tracker import DeviceTracker
from python import Python

# Network connection functions
fn switch_to_tcpip(client: ADBClient, port: Int) -> Bool:
    """
    Switch a device to TCP/IP mode on the specified port.
    Returns True if successful, False otherwise.
    """
    try:
        let cmd = "tcpip " + str(port)
        let result = client.send_command(cmd)
        let success = "restarting in TCP mode" in result.lower() or "error" not in result.lower()
        print("Switched to TCP/IP on port", port, ":", result)
        return success
    except e:
        print("Error switching to TCP/IP mode:", str(e))
        return False

fn connect_device(client: ADBClient, host_port: String) -> Bool:
    """
    Connect to a device over TCP/IP.
    Returns True if successful, False otherwise.
    """
    try:
        let result = client.send_command("connect " + host_port)
        let success = "connected to" in result.lower() or "already connected" in result.lower()
        print("Connected to", host_port, ":", result)
        
        # If successful, register the device for auto-reconnection
        if success and client.serial:
            try:
                let tracker = DeviceTracker(client)
                let parts = host_port.split(":")
                let ip = parts[0]
                let port = int(parts[1]) if len(parts) > 1 else 5555
                tracker.register_wireless_device(client.serial, ip, port)
            except:
                pass
        
        return success
    except e:
        print("Error connecting to device:", str(e))
        return False

fn disconnect_device(client: ADBClient, host_port: String = "") -> Bool:
    """
    Disconnect from a device over TCP/IP.
    Returns True if successful, False otherwise.
    """
    try:
        let cmd = "disconnect " + host_port if host_port else "disconnect"
        let result = client.send_command(cmd)
        print("Disconnected:", result)
        return True
    except e:
        print("Error disconnecting from device:", str(e))
        return False

fn forward(client: ADBClient, local: String, remote: String) -> Bool:
    """
    Forward a local port to a remote port on the device.
    Returns True if successful, False otherwise.
    """
    try:
        let cmd = "forward " + local + " " + remote
        let result = client.send_command(cmd)
        print("Forwarded", local, "to", remote, ":", result)
        return "error" not in result.lower()
    except e:
        print("Error setting up port forwarding:", str(e))
        return False

fn reverse(client: ADBClient, remote: String, local: String) -> Bool:
    """
    Reverse a remote port to a local port.
    Returns True if successful, False otherwise.
    """
    try:
        let cmd = "reverse " + remote + " " + local
        let result = client.send_command(cmd)
        print("Reversed", remote, "to", local, ":", result)
        return "error" not in result.lower()
    except e:
        print("Error setting up reverse port forwarding:", str(e))
        return False

fn list_forwards(client: ADBClient) -> String:
    """
    List all forward port mappings.
    """
    try:
        return client.send_command("forward --list")
    except e:
        return "Error listing forwards: " + str(e)

fn list_reverses(client: ADBClient) -> String:
    """
    List all reverse port mappings.
    """
    try:
        return client.send_command("reverse --list")
    except e:
        return "Error listing reverses: " + str(e)

fn setup_wireless_debugging(client: ADBClient, port: Int = 5555) -> Bool:
    """
    Set up wireless debugging for a connected device.
    This function will:
    1. Get the device's IP address
    2. Switch to TCP/IP mode
    3. Connect to the device wirelessly
    4. Register the device for auto-reconnection
    
    Returns True if successful, False otherwise.
    """
    try:
        # Create a device tracker
        let tracker = DeviceTracker(client)
        
        # Get the device's IP address
        let ip = tracker.get_device_ip(client.serial)
        if not ip:
            print("Error: Could not determine device IP address")
            return False
            
        print("Device IP address:", ip)
        
        # Switch to TCP/IP mode
        if not switch_to_tcpip(client, port):
            print("Error: Failed to switch to TCP/IP mode")
            return False
            
        # Wait for the device to switch modes
        time = Python.import_module("time")
        time.sleep(2)
        
        # Connect to the device wirelessly
        let host_port = ip + ":" + str(port)
        if not connect_device(client, host_port):
            print("Error: Failed to connect to device wirelessly")
            return False
            
        # Register the device for auto-reconnection
        tracker.register_wireless_device(client.serial, ip, port)
        
        print("Successfully set up wireless debugging for device", client.serial)
        print("You can now disconnect the USB cable")
        return True
    except e:
        print("Error setting up wireless debugging:", str(e))
        return False