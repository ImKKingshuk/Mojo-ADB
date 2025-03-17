# MojoADB: Core Utilities Module

# System call implementation using Python's subprocess module
fn system_call(cmd: String) -> String:
    from python import Python
    try:
        subprocess = Python.import_module("subprocess")
        result = subprocess.run(cmd, shell=True, text=True, capture_output=True)
        if result.returncode != 0 and result.stderr:
            return "error: " + result.stderr
        return result.stdout
    except e:
        return "error: Failed to execute command: " + cmd