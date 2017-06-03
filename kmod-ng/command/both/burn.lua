

function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Burn", "Useage: burn \[partname/id#\]\n")
        return 1
    end

    local clientNum = client2id(tonumber(params["arg1"]), 'Burn', params)

    if clientNum ~= nil
        if client[clientNum]['team'] >= 3 or client[clientNum]['team'] < 1 then
            printCmdMsg(params, "Burn", "Client is not actively playing\n")

            return 1
        end

        if et.gentity_get(clientNum, "health") <= 0 then
            printCmdMsg(params, "Burn", "Client is currently dead\n")

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
