# MojoADB: File Operations Module

from core.client import ADBClient

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