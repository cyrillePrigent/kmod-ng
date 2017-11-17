-- Self kill limit

-- Global var

selfkillLimit = {
    ["limit"]       = tonumber(et.trap_Cvar_Get("u_selfkill_limit")),
    ["msgPosition"] = et.trap_Cvar_Get("u_selfkill_msg_position")
}

-- Set default client data.
clientDefaultData["selfkills"] = 0

addSlashCommand("client", "kill", {"function", "selfkillLimitSlashCommand"})

-- Function

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function selfkillLimitSlashCommand(params)
    if client[params.clientNum]["team"] ~= 3 and et.gentity_get(params.clientNum, "health") > 0 then
        if client[params.clientNum]["selfkills"] < selfkillLimit["limit"] then
            client[params.clientNum]["selfkills"] = client[params.clientNum]["selfkills"] + 1

            if client[params.clientNum]["selfkills"] == selfkillLimit["limit"] then
                et.trap_SendServerCommand(
                    params.clientNum,
                    string.format(
                        "%s ^7You have reached your /kill limit!\nYou can no longer /kill for the rest of this map.\n",
                        selfkillLimit["msgPosition"]
                    )
                )
            elseif client[params.clientNum]["selfkills"] == (selfkillLimit["limit"] - 1) then
                et.trap_SendServerCommand(
                    params.clientNum,
                    string.format(
                        "%s ^7You have ^11^7 /kill left for this map.\n",
                        selfkillLimit["msgPosition"]
                    )
                )
            end
        else
            et.trap_SendServerCommand(
                params.clientNum,
                string.format(
                    "%s ^7You may no longer /kill for the rest of this map!\n",
                    selfkillLimit["msgPosition"]
                )
            )

            return 1
        end
    end

    return 0
end
