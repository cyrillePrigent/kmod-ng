-- Self kill limit
-- From kmod script.

-- Global var

selfkillLimit = {
    -- Limit of allowed selkill.
    ["limit"] = tonumber(et.trap_Cvar_Get("u_selfkill_limit")),
    -- Selfkill limit message position.
    ["msgPosition"] = et.trap_Cvar_Get("u_selfkill_msg_position")
}

-- Set default client data.
clientDefaultData["selfkills"] = 0

-- Override kill slash command.
addSlashCommand("client", "kill", {"function", "selfkillLimitSlashCommand"})

-- Function

-- Function executed when slash command is called in et_ClientCommand function.
-- Limit selfkill when kill slash command is used.
-- If player make selfkill before last selfkill allowed, a notification is display.
-- All selfkill following is disabled and a notification is display.
--  params is parameters passed to the function executed in command file.
function selfkillLimitSlashCommand(params)
    if client[params.clientNum]["team"] ~= 3
      and et.gentity_get(params.clientNum, "health") > 0 then
        params.say          = selfkillLimit["msgPosition"]
        params.noDisplayCmd = true

        if client[params.clientNum]["selfkills"] < selfkillLimit["limit"] then
            client[params.clientNum]["selfkills"] = client[params.clientNum]["selfkills"] + 1

            if client[params.clientNum]["selfkills"] == selfkillLimit["limit"] then
                printCmdMsg(
                    params,
                    "You have reached your /kill limit !\n " ..
                    "You can no longer /kill for the rest of this map."
                )
            elseif client[params.clientNum]["selfkills"] == selfkillLimit["limit"] - 1 then
                printCmdMsg(
                    params,
                    "You have " .. color4 .. "1" .. color1 .. " /kill left for this map."
                )
            end
        else
            printCmdMsg(
                params,
                "You may no longer /kill for the rest of this map!"
            )

            return 1
        end
    end

    return 0
end
