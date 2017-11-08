-- Put all afk player in allies and axis team to spectator.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    local matches = 0

    for i = 0, clientsLimit, 1 do
        if client[i]['team'] == 1 or client[i]['team'] == 2 then
            matches = matches + 1
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref remove " .. i .. "\n")
        end
    end

    printCmdMsg(params, "Moving ^1" .. matches .. " ^7players to spectator\n")

    return 1
end
