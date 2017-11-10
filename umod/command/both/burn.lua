-- Burn a player.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: burn \[partname/id#\]\n")
    else
        local clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if client[clientNum]['team'] >= 3 or client[clientNum]['team'] < 1 then
                printCmdMsg(params, "Client is not actively playing\n")
            else
                if et.gentity_get(clientNum, "health") <= 0 then
                    printCmdMsg(params, "Client is currently dead\n")
                else
                    et.G_Damage(params.clientNum, params.clientNum, 1022, 5, 24, 19)
                    et.G_Sound(clientNum,et.G_SoundIndex("sound/player/hurt_barbwire.wav"))
                    et.trap_SendServerCommand(-1, "b 16 \"^7" .. client[clientNum]["name"] .. " ^7was Burned^7")
                end
            end
        end
    end

    return 1
end
