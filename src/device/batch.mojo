# MojoADB: Batch Operations Module

from core.client import ADBClient
from core.errors import ADBError
from device.tracker import DeviceTracker
from python import Python

# Batch operations for multiple devices
struct BatchOperations:
    var client: ADBClient
    var tracker: DeviceTracker
    
    fn __init__(inout self, client: ADBClient):
        self.client = client
        self.tracker = DeviceTracker(client)
    
    fn execute_on_all(self, command: String) -> Dict[String, String]:
        """
        Execute a command on all connected devices.
        Returns a dictionary mapping device serials to command results.
        """
        # Refresh device list
        let devices = self.tracker.refresh_devices()
        var results = Dict[String, String]()
        
        # Execute command on each device
        for serial in devices.keys():
            try:
                # Create a client for this specific device
                let device_client = ADBClient(serial, self.client.verbose)
                let result = device_client.send_command(command)
                results[serial] = result
            except e:
                results[serial] = "Error: " + str(e)
        
        return results
    
    fn execute_on_filtered(self, command: String, filter_func: fn(Dict[String, String]) -> Bool) -> Dict[String, String]:
        """
        Execute a command on devices that match a filter function.
        The filter_func should take a device info dictionary and return True if the device should be included.
        Returns a dictionary mapping device serials to command results.
        """
        # Refresh device list
        let devices = self.tracker.refresh_devices()
        var results = Dict[String, String]()
        
        # Execute command on filtered devices
        for serial, info in devices.items():
            if filter_func(info):
                try:
                    # Create a client for this specific device
                    let device_client = ADBClient(serial, self.client.verbose)
                    let result = device_client.send_command(command)
                    results[serial] = result
                except e:
                    results[serial] = "Error: " + str(e)
        
        return results
    
    fn install_on_all(self, apk_path: String, flags: String = "") -> Dict[String, String]:
        """
        Install an APK on all connected devices.
        Returns a dictionary mapping device serials to installation results.
        """
        let cmd = "install " + flags + " \"" + apk_path + "\""
        return self.execute_on_all(cmd)
    
    fn uninstall_from_all(self, package: String, keep_data: Bool = False) -> Dict[String, String]:
        """
        Uninstall a package from all connected devices.
        Returns a dictionary mapping device serials to uninstallation results.
        """
        let cmd = "uninstall " + ("-k " if keep_data else "") + package
        return self.execute_on_all(cmd)
    
    fn push_to_all(self, local_path: String, remote_path: String) -> Dict[String, String]:
        """
        Push a file to all connected devices.
        Returns a dictionary mapping device serials to push results.
        """
        let cmd = "push \"" + local_path + "\" \"" + remote_path + "\""
        return self.execute_on_all(cmd)
    
    fn pull_from_all(self, remote_path: String, local_dir: String) -> Dict[String, String]:
        """
        Pull a file from all connected devices.
        The files will be saved with the device serial as a prefix.
        Returns a dictionary mapping device serials to pull results.
        """
        var results = Dict[String, String]()
        let devices = self.tracker.refresh_devices()
        
        for serial in devices.keys():
            try:
                # Create a client for this specific device
                let device_client = ADBClient(serial, self.client.verbose)
                let local_path = local_dir + "/" + serial + "_" + remote_path.split("/")[-1]
                let cmd = "pull \"" + remote_path + "\" \"" + local_path + "\""
                let result = device_client.send_command(cmd)
                results[serial] = result
            except e:
                results[serial] = "Error: " + str(e)
        
        return results
    
    fn reboot_all(self, mode: String = "") -> Dict[String, String]:
        """
        Reboot all connected devices.
        Returns a dictionary mapping device serials to reboot results.
        """
        let cmd = "reboot " + mode
        return self.execute_on_all(cmd)
    
    fn shell_on_all(self, shell_command: String) -> Dict[String, String]:
        """
        Run a shell command on all connected devices.
        Returns a dictionary mapping device serials to command results.
        """
        let cmd = "shell " + shell_command
        return self.execute_on_all(cmd)
    
    fn get_properties_from_all(self, property_name: String) -> Dict[String, String]:
        """
        Get a specific property from all connected devices.
        Returns a dictionary mapping device serials to property values.
        """
        let cmd = "shell getprop " + property_name
        return self.execute_on_all(cmd)