# MojoADB: Error Handling Module

# Error handling struct for ADB operations
struct ADBError:
    var message: String
    var code: Int
    var command: String
    
    fn __init__(inout self, message: String, code: Int = -1, command: String = ""):
        self.message = message
        self.code = code
        self.command = command
        
    fn __str__(self) -> String:
        var error_str = self.message
        if self.command:
            error_str += " (Command: " + self.command + ")"
        if self.code != -1:
            error_str += " (Code: " + str(self.code) + ")"
        return error_str