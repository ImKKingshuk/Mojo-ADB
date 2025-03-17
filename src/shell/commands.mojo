# MojoADB: Shell Commands Module

from core.client import ADBClient

# Shell command execution functions
fn run_shell(client: ADBClient, command: String):
    let result = client.send_command("shell " + command)
    print(result)

fn interactive_shell(client: ADBClient):
    print("Interactive shell (type 'exit' to quit)")
    while True:
        let cmd = input("shell> ")
        if cmd == "exit":
            break
        elif cmd.strip() == "":
            continue
        run_shell(client, cmd)