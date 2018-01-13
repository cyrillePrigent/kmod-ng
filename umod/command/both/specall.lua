-- Put all player in allies and axis team to spectator.
-- From kmod script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    params.say = "chat"
    local matches = 0

    for p = 0, clientsLimit, 1 do
        if client[p]['team'] == 1 or client[p]['team'] == 2 then
            matches = matches + 1
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref remove " .. p .. "\n")
        end
    end

    if matches > 0 then
        params.broadcast2allClients = true
        printCmdMsg(
            params,
            "Moving " .. color4 .. matches .. color1 .. " players to spectator\n"
        )
    else
        printCmdMsg(params, "No players moved to spectator\n")
    end

    return 1
end
