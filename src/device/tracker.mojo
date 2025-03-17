# MojoADB: Device Tracker Module

from core.client import ADBClient
from core.errors import ADBError
from python import Python

# Device tracking and monitoring
struct DeviceTracker:
    var client: ADBClient
    var devices: Dict[String, Dict[String, String]]
    var monitoring: Bool
    var monitor_thread: PythonObject
    var callback: PythonObject
    var monitor_interval: Int
    var wireless_devices: Dict[String, Dict[String, String]]
    
    fn __init__(inout self, client: ADBClient, monitor_interval: Int = 5):
        self.client = client
        self.devices = Dict[String, Dict[String, String]]()
        self.monitoring = False
        self.monitor_thread = None
        self.callback = None
        self.monitor_interval = monitor_interval
        self.wireless_devices = Dict[String, Dict[String, String]]()
    
    fn refresh_devices(inout self) -> Dict[String, Dict[String, String]]:
        """
        Refresh the list of connected devices and their properties.
        Returns a dictionary of device serials to device properties.
        """
        let result = self.client.send_command("devices -l")
        var new_devices = Dict[String, Dict[String, String]]()
        
        for line in result.split("\n"):
            if not line.strip() or "List of devices" in line:
                continue
                
            let parts = line.split()
            if len(parts) > 1:
                let serial = parts[0]
                let state = parts[1]
                
                var device_info = Dict[String, String]()
                device_info["serial"] = serial
                device_info["state"] = state
                
                # Extract additional properties
                for i in range(2, len(parts)):
                    if ":" in parts[i]:
                        let kv = parts[i].split(":")
                        if len(kv) == 2:
                            device_info[kv[0]] = kv[1]
                
                new_devices[serial] = device_info
        
        self.devices = new_devices
        return self.devices
    
    fn get_device_state(self, serial: String) -> String:
        """
        Get the current state of a specific device.
        Returns the state string or "unknown" if the device is not found.
        """
        if serial in self.devices:
            return self.devices[serial]["state"]
        else:
            # Try to refresh and check again
            self.refresh_devices()
            if serial in self.devices:
                return self.devices[serial]["state"]
            return "unknown"
    
    fn wait_for_device_state(self, serial: String, target_state: String, timeout: Int = 60) -> Bool:
        """
        Wait for a device to reach a specific state.
        Returns True if the device reached the state within the timeout, False otherwise.
        """
        time = Python.import_module("time")
        start_time = time.time()
        
        while time.time() - start_time < timeout:
            let state = self.get_device_state(serial)
            if state == target_state:
                return True
            time.sleep(1)
        
        return False
    
    fn get_device_property(self, serial: String, property: String) -> String:
        """
        Get a specific property of a device.
        Returns the property value or empty string if not found.
        """
        if serial in self.devices and property in self.devices[serial]:
            return self.devices[serial][property]
        else:
            # Try to refresh and check again
            self.refresh_devices()
            if serial in self.devices and property in self.devices[serial]:
                return self.devices[serial][property]
            return ""
    
    fn get_device_ip(self, serial: String) -> String:
        """
        Get the IP address of a connected device.
        Returns the IP address or empty string if not found.
        """
        try:
            let result = self.client.send_command("shell ip addr show wlan0")
            for line in result.split("\n"):
                if "inet " in line:
                    # Extract IP address using regex-like approach
                    let parts = line.split("inet ")[1].split("/")[0].strip()
                    return parts
            return ""
        except:
            return ""
    
    fn connect_wireless(self, serial: String, port: Int = 5555) -> Bool:
        """
        Connect to a device wirelessly.
        First enables TCP/IP mode on the device, then connects to it.
        Returns True if successful, False otherwise.
        """
        try:
            # Get device IP address
            let ip = self.get_device_ip(serial)
            if not ip:
                return False
            
            # Enable TCP/IP mode
            self.client.send_command("tcpip " + str(port))
            
            # Wait a moment for the device to switch modes
            time = Python.import_module("time")
            time.sleep(2)
            
            # Connect to the device
            let connect_result = self.client.send_command("connect " + ip + ":" + str(port))
            return "connected" in connect_result.lower()
        except:
            return False
    
    fn get_battery_info(self, serial: String) -> Dict[String, String]:
        """
        Get battery information for a device.
        Returns a dictionary with battery properties.
        """
        var battery_info = Dict[String, String]()
        
        try:
            let result = self.client.send_command("shell dumpsys battery")
            for line in result.split("\n"):
                line = line.strip()
                if ": " in line:
                    let parts = line.split(": ")
                    if len(parts) == 2:
                        battery_info[parts[0]] = parts[1]
        except:
            pass
        
        return battery_info
    
    fn get_screen_resolution(self, serial: String) -> Tuple[Int, Int]:
        """
        Get the screen resolution of a device.
        Returns a tuple of (width, height) or (-1, -1) on error.
        """
        try:
            let result = self.client.send_command("shell wm size")
            if "Physical size:" in result:
                let size_str = result.split("Physical size:")[1].strip()
                let dimensions = size_str.split("x")
                if len(dimensions) == 2:
                    return (int(dimensions[0]), int(dimensions[1]))
            return (-1, -1)
        except:
            return (-1, -1)
            
    fn start_monitoring(inout self, callback: PythonObject = None):
        """
        Start monitoring for device connections and disconnections.
        If a callback function is provided, it will be called when device states change.
        The callback should accept two parameters: device_serial and state.
        """
        if self.monitoring:
            return
            
        self.callback = callback
        self.monitoring = True
        
        # Create a monitoring thread using Python's threading
        threading = Python.import_module("threading")
        time = Python.import_module("time")
        
        def monitor_devices():
            prev_devices = Dict[String, Dict[String, String]]()
            while self.monitoring:
                try:
                    # Refresh device list
                    current_devices = self.refresh_devices()
                    
                    # Check for new devices or state changes
                    for serial, info in current_devices.items():
                        if serial not in prev_devices:
                            # New device connected
                            if self.callback:
                                self.callback(serial, "connected")
                            print("Device connected:", serial)
                        elif prev_devices[serial]["state"] != info["state"]:
                            # Device state changed
                            if self.callback:
                                self.callback(serial, info["state"])
                            print("Device", serial, "state changed to", info["state"])
                    
                    # Check for disconnected devices
                    for serial in prev_devices.keys():
                        if serial not in current_devices:
                            # Device disconnected
                            if self.callback:
                                self.callback(serial, "disconnected")
                            print("Device disconnected:", serial)
                    
                    # Update previous devices
                    prev_devices = current_devices
                    
                    # Check wireless devices and attempt reconnection if needed
                    self.check_wireless_devices()
                    
                    # Sleep for the monitoring interval
                    time.sleep(self.monitor_interval)
                except e:
                    print("Error in device monitoring:", str(e))
                    time.sleep(self.monitor_interval)
        
        # Start the monitoring thread
        self.monitor_thread = threading.Thread(target=monitor_devices)
        self.monitor_thread.daemon = True
        self.monitor_thread.start()
        
    fn stop_monitoring(inout self):
        """
        Stop the device monitoring thread.
        """
        if not self.monitoring:
            return
            
        self.monitoring = False
        if self.monitor_thread:
            # Wait for the thread to terminate
            time = Python.import_module("time")
            time.sleep(self.monitor_interval + 1)
            self.monitor_thread = None
            
    fn check_wireless_devices(inout self):
        """
        Check wireless devices and attempt to reconnect if they're disconnected.
        """
        for serial, info in self.wireless_devices.items():
            if serial not in self.devices:
                # Try to reconnect
                try:
                    if "ip" in info and "port" in info:
                        ip = info["ip"]
                        port = int(info["port"])
                        print("Attempting to reconnect to wireless device:", ip + ":" + str(port))
                        self.client.send_command("connect " + ip + ":" + str(port))
                except e:
                    print("Failed to reconnect to wireless device:", serial, str(e))
                    
    fn register_wireless_device(inout self, serial: String, ip: String, port: Int = 5555):
        """
        Register a device for wireless connection monitoring and auto-reconnection.
        """
        var device_info = Dict[String, String]()
        device_info["ip"] = ip
        device_info["port"] = str(port)
        self.wireless_devices[serial] = device_info