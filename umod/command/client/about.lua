
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    et.trap_SendServerCommand(params.clientNum, "cpm \"This server is running the new KMOD-ng version " .. version .. " " .. releaseStatus .. "\n\"")
    et.trap_SendServerCommand(params.clientNum, "cpm \"Created by Clutch152, enhanced by Yellux.\n\"")

    return 1
end