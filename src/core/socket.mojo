# MojoADB: Socket Module for ADB Protocol

from python import Python
from core.errors import ADBError

# ADB Socket for direct communication with ADB server
struct ADBSocket:
    var host: String
    var port: Int
    
    fn __init__(inout self, host: String, port: Int):
        self.host = host
        self.port = port
    
    fn send_and_receive(self, command: String) -> String:
        """
        Sends a command to the ADB server using socket communication and returns the response.
        This implements the ADB protocol directly for more robust communication.
        """
        try:
            # Import Python modules
            socket = Python.import_module("socket")
            struct = Python.import_module("struct")
            
            # Create socket
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((self.host, self.port))
            
            # Format command according to ADB protocol
            # Format: <length><command>
            cmd_length = len(command)
            hex_cmd_length = "{:04x}".format(cmd_length)
            
            # Send command length and command
            s.sendall(hex_cmd_length.encode() + command.encode())
            
            # Read response
            # First 4 bytes are OKAY or FAIL
            response_status = s.recv(4).decode()
            
            if response_status == "OKAY":
                # If the command expects data, read the data length and then the data
                if command.startswith("host:transport") or command.startswith("shell:"):
                    # Read response length (4 bytes hex string)
                    response_length_hex = s.recv(4).decode()
                    if response_length_hex:
                        response_length = int(response_length_hex, 16)
                        # Read response data
                        response_data = ""
                        while len(response_data) < response_length:
                            chunk = s.recv(response_length - len(response_data)).decode()
                            if not chunk:
                                break
                            response_data += chunk
                        return response_data
                    return "Command executed successfully"
                return "Command executed successfully"
            elif response_status == "FAIL":
                # Read error message length (4 bytes hex string)
                error_length_hex = s.recv(4).decode()
                error_length = int(error_length_hex, 16)
                # Read error message
                error_message = s.recv(error_length).decode()
                raise ADBError("ADB server error: " + error_message, -1, command)
            else:
                raise ADBError("Invalid response from ADB server", -1, command)
        except e:
            raise ADBError("Socket communication error: " + str(e), -1, command)
        finally:
            try:
                s.close()
            except:
                pass
    
    fn check_server_connection(self) -> Bool:
        """
        Checks if the ADB server is running and accessible.
        Returns True if connection successful, False otherwise.
        """
        try:
            socket = Python.import_module("socket")
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(1.0)  # 1 second timeout
            s.connect((self.host, self.port))
            s.close()
            return True
        except:
            return False