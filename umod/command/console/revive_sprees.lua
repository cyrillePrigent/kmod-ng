-- Display all admins name and level in server console.
--  params is parameters passed from et_ConsoleCommand function.
function execute_command(params)
    et.G_Printf("rsprees: --------------------\n")

    for i = 0, sv_maxclients do
        if client[i]["reviveSpree"] ~= nil and client[i]["reviveSpree"] ~= 0 then
            et.G_Printf("^7rsprees: %d %s^7 (%s)^7\n", 
                        client[i]["reviveSpree"],
                        playerName(i),
                        teamName(tonumber(et.gentity_get(i, "sess.sessionTeam"))))
        end
    end

    et.G_Printf("^7rsprees: --------------------\n")

    if reviveSpree["maxId"] ~= nil then
        et.G_Printf("^7Max: %s^7 with %d\n", playerName(reviveSpree["maxId"]), reviveSpree["maxSpree"])
    end

    return 1
end