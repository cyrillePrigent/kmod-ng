-- Put all player in allies and axis team to spectator.
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    params.say = msgCmd["chatArea"]
    local matches = 0

    for i = 0, clientsLimit, 1 do
        if client[i]['team'] == 1 or client[i]['team'] == 2 then
            matches = matches + 1
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref remove " .. i .. "\n")
        end
    end

    if matches > 0 then
        params.broadcast2allClients = true
        printCmdMsg(params, "Moving ^1" .. matches .. " ^7players to spectator\n")
    else
        printCmdMsg(params, "No players moved to spectator\n")
    end

    return 1
end
