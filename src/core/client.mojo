# MojoADB: Core Client Module

from core.utils import system_call
from core.errors import ADBError

# ADB Client for communicating with the ADB server
struct ADBClient:
    var host: String
    var port: Int
    var serial: String
    var verbose: Bool

    fn __init__(inout self, serial: String = "", verbose: Bool = False):
        self.host = "localhost"
        self.port = 5037
        self.serial = serial
        self.verbose = verbose

    fn send_command(self, command: String) -> String:
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