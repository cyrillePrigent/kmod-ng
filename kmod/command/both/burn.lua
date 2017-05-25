

function execute_command(params)
    if params.nbArg < 2 then
        if params.command == 'console' then
            et.G_Print("Burn is used to burn a player\n")
            et.G_Print("useage: burn \[name/PID\]\n")
        elseif params.command == 'client' then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Burn:^7 \[partname/id#\]\n")
        end

        return 1
    end

    local clientNum = client2id(tonumber(params["arg1"]), 'Burn', params.command, params.say)

    if clientNum ~= nil
        if client[clientNum]['team'] >= 3 or client[clientNum]['team'] < 1 then
            if params.command == 'client' then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Burn: ^7Client is not actively playing\n")
            elseif params.command == 'console' then
                et.G_Print("Client is not actively playing\n")
            end

            return 1
        end

        if et.gentity_get(clientNum, "health") <= 0 then
            if params.command == 'client' then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Burn: ^7Client is currently dead\n")
            elseif params.command == 'console' then
                et.G_Print("Client is currently dead\n")
            end

            return 1
        end

        et.gentity_set(clientNum, "health", (et.gentity_get(clientNum, "health") - 5))
        -- TODO Put sound file value in config file
        soundIndex = et.G_SoundIndex("sound/player/hurt_barbwire.wav")
        et.G_Sound(clientNum, soundIndex)

        et.trap_SendServerCommand(-1, ("b 16 \"^7" .. et.gentity_get(clientNum, "pers.netname") .. " ^7was Burned^7"))
    end

    return 1
end
