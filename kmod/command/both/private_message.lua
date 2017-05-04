
-- TODO Use printCmdMsg function

-- params["arg1"] = client
-- params["arg2"] = PlayerID
-- params["arg3"] = message
function execute_command(params)
    local clientnum = tonumber(params["arg1"])

    if clientnum then
        if clientnum >= 0 and clientnum < 64 then
            if et.gentity_get(clientnum, "pers.connected") ~= 2 then
                if params.commandSaid then
                    et.trap_SendServerCommand(params["arg2"], string.format("print \"There is no client associated with this slot number\n"))
                else
                    et.G_Print("There is no client associated with this slot number\n")
                end

                return
            end
        else
            if params.commandSaid then
                et.trap_SendServerCommand(params["arg2"], string.format("print \"Please enter a slot number between 0 and 63\n"))
            else
                et.G_Print("Please enter a slot number between 0 and 63\n")
            end

            return
        end
    else
        if params["arg1"] then
            s, e = string.find(params["arg1"], params["arg1"])

            if e <= 2 then
                if params.commandSaid then
                    et.trap_SendServerCommand(params["arg2"], string.format("print \"Player name requires more than 2 characters\n"))
                else
                    et.G_Print("Player name requires more than 2 characters\n")
                end

                return
            else
                clientnum = name2IDPM(params["arg1"])
            end
        end

        if not clientnum then
            if params.commandSaid then
                et.trap_SendServerCommand(params["arg2"], string.format("print \"Try name again or use slot number\n"))
            else
                et.G_Print("Try name again or use slot number\n")
            end

            return
        end
    end

    local name = et.gentity_get(params["arg2"], "pers.netname")
    local rname = et.gentity_get(clientnum, "pers.netname")

    if params["arg2"] == 1022 then
        name = "^1SERVER"
    end

    if params.commandSaid then
        if params["arg2"] ~= 1022 then
            et.trap_SendServerCommand(params["arg2"], ("b 8 \"^dPrivate message sent to " .. rname .. "^d --> ^3" .. params["arg3"] .. "^7"))
            et.G_ClientSound(params["arg2"], pmsound)
        end
    else
        et.G_Print("Private message sent to " .. rname .. "^d --> ^3" .. params["arg3"] .. "^7\n")
    end

    et.trap_SendServerCommand(clientnum, ("b 8 \"^dPrivate message from " .. name .. "^d --> ^3" .. params["arg3"] .. "^7"))
    et.G_ClientSound(clientnum, pmsound)
end
