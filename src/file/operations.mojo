# MojoADB: File Operations Module

from core.client import ADBClient
from core.errors import ADBError
from python import Python

# File transfer and management functions
fn push_file(client: ADBClient, src: String, dest: String):
    let cmd = "push " + src + " " + dest
    let result = client.send_command(cmd)
    print("Pushed", src, "to", dest, ":", result)

fn pull_file(client: ADBClient, src: String, dest: String):
    let cmd = "pull " + src + " " + dest
    let result = client.send_command(cmd)
    print("Pulled", src, "to", dest, ":", result)

fn sync(client: ADBClient, local_dir: String, remote_dir: String):
    let cmd = "sync " + local_dir + " " + remote_dir
    let result = client.send_command(cmd)
    print("Synced", local_dir, "to", remote_dir, ":", result)

fn rm_file(client: ADBClient, path: String):
    let result = client.send_command("shell rm " + path)
    print("Removed", path, ":", result)

# Enhanced file operations
fn list_files(client: ADBClient, path: String, show_hidden: Bool = False) -> String:
    """
    List files in the specified directory on the device.
    Returns the listing as a string.
    """
    var cmd = "shell ls -l " + path
    if show_hidden:
        cmd += " -a"
    return client.send_command(cmd)

fn file_exists(client: ADBClient, path: String) -> Bool:
    """
    Check if a file exists on the device.
    Returns True if the file exists, False otherwise.
    """
    let result = client.send_command("shell [ -e " + path + " ] && echo 'exists' || echo 'not exists'")
    return "exists" in result

fn is_directory(client: ADBClient, path: String) -> Bool:
    """
    Check if a path is a directory on the device.
    Returns True if the path is a directory, False otherwise.
    """
    let result = client.send_command("shell [ -d " + path + " ] && echo 'dir' || echo 'not dir'")
    return "dir" in result

fn get_file_size(client: ADBClient, path: String) -> Int:
    """
    Get the size of a file on the device in bytes.
    Returns -1 if the file doesn't exist or there's an error.
    """
    try:
        let result = client.send_command("shell stat -c %s " + path)
        return int(result.strip())
    except:
        return -1

fn mkdir(client: ADBClient, path: String, parents: Bool = False) -> Bool:
    """
    Create a directory on the device.
    If parents is True, create parent directories as needed.
    Returns True if successful, False otherwise.
    """
    var cmd = "shell mkdir "
    if parents:
        cmd += "-p "
    cmd += path
    
    try:
        client.send_command(cmd)
        return True
    except:
        return False

fn batch_push(client: ADBClient, file_mappings: List[Tuple[String, String]]) -> Dict[String, String]:
    """
    Push multiple files to the device in a batch operation.
    file_mappings is a list of (source, destination) tuples.
    Returns a dictionary with source paths as keys and results as values.
    """
    var results = Dict[String, String]()
    
    for mapping in file_mappings:
        let src = mapping[0]
        let dest = mapping[1]
        try:
            let result = client.send_command("push " + src + " " + dest)
            results[src] = "Success: " + result
        except e:
            results[src] = "Failed: " + e.__str__()
    
    return results

fn batch_pull(client: ADBClient, file_mappings: List[Tuple[String, String]]) -> Dict[String, String]:
    """
    Pull multiple files from the device in a batch operation.
    file_mappings is a list of (source, destination) tuples.
    Returns a dictionary with source paths as keys and results as values.
    """
    var results = Dict[String, String]()
    
    for mapping in file_mappings:
        let src = mapping[0]
        let dest = mapping[1]
        try:
            let result = client.send_command("pull " + src + " " + dest)
            results[src] = "Success: " + result
        except e:
            results[src] = "Failed: " + e.__str__()
    
    return results

fn copy_file(client: ADBClient, src: String, dest: String) -> Bool:
    """
    Copy a file on the device from src to dest.
    Returns True if successful, False otherwise.
    """
    try:
        client.send_command("shell cp " + src + " " + dest)
        return True
    except:
        return False

fn move_file(client: ADBClient, src: String, dest: String) -> Bool:
    """
    Move a file on the device from src to dest.
    Returns True if successful, False otherwise.
    """
    try:
        client.send_command("shell mv " + src + " " + dest)
        return True
    except:
        return False

fn get_file_permissions(client: ADBClient, path: String) -> String:
    """
    Get the permissions of a file on the device.
    Returns the permission string (e.g., "rwxr-xr-x") or empty string on error.
    """
    try:
        let result = client.send_command("shell stat -c %a " + path)
        return result.strip()
    except:
        return ""

fn set_file_permissions(client: ADBClient, path: String, mode: String) -> Bool:
    """
    Set the permissions of a file on the device.
    mode should be in octal format (e.g., "755").
    Returns True if successful, False otherwise.
    """
    try:
        client.send_command("shell chmod " + mode + " " + path)
        return True
    except:
        return False