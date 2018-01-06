-- Display reviving spree of current players in server console.
-- From rspree lua.
--  params is parameters passed from et_ConsoleCommand function.
function execute_command(params)
    local teamList = { "Axis" , "Allies" , "Spectator" }

    et.G_Print("--------------------------\n")
    et.G_Print("- Current reviving spree -\n")
    et.G_Print("--------------------------\n")

    for p = 0, clientsLimit, 1 do
        if client[p]["reviveSpree"] ~= 0 then
            et.G_Printf(
                "%s (%s) with %d revive\n", 
                et.Q_CleanStr(client[p]["name"]),
                teamList[client[p]["team"]],
                client[p]["reviveSpree"]
            )
        end
    end

    et.G_Print("--------------------------\n")

    if reviveSpree["maxId"] ~= nil then
        et.G_Printf(
            "Max: %s with %d revive\n",
            et.Q_CleanStr(client[reviveSpree["maxId"]]["name"]),
            reviveSpree["maxSpree"]
        )
    end

    return 1
end
