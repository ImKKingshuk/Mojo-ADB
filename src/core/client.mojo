# MojoADB: Core Client Module

from core.utils import system_call
from core.errors import ADBError
from core.socket import ADBSocket

# ADB Client for communicating with the ADB server
struct ADBClient:
    var host: String
    var port: Int
    var serial: String
    var verbose: Bool
    var use_socket: Bool
    var socket: ADBSocket

    fn __init__(inout self, serial: String = "", verbose: Bool = False, use_socket: Bool = True):
        self.host = "localhost"
        self.port = 5037
        self.serial = serial
        self.verbose = verbose
        self.use_socket = use_socket
        self.socket = ADBSocket(self.host, self.port)
    
    fn send_command(self, command: String) -> String:
        if self.use_socket:
            return self._send_socket_command(command)
        else:
            return self._send_shell_command(command)
    
    fn _send_socket_command(self, command: String) -> String:
        try:
            var full_cmd = command
            if self.serial != "":
                full_cmd = "host:transport:" + self.serial + ":" + command
            else:
                full_cmd = "host:" + command
                
            if self.verbose:
                print("[VERBOSE] Socket command:", full_cmd)
                
            var result = self.socket.send_and_receive(full_cmd)
            return result
        except e:
            if self.verbose:
                print("[VERBOSE] Socket error, falling back to shell command")
            return self._send_shell_command(command)
    
    fn _send_shell_command(self, command: String) -> String:
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
        
    fn get_device_info(self) -> Dict[String, String]:
        let result = self.send_command("devices -l")
        var device_info = Dict[String, String]()
        
        # Parse device info from output
        if self.serial != "":
            for line in result.split("\n"):
                if self.serial in line:
                    let parts = line.split()
                    if len(parts) > 1:
                        device_info["serial"] = self.serial
                        device_info["state"] = parts[1]
                        
                        # Extract additional properties
                        for i in range(2, len(parts)):
                            if ":" in parts[i]:
                                let kv = parts[i].split(":")
                                if len(kv) == 2:
                                    device_info[kv[0]] = kv[1]
        
        return device_info