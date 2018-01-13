-- Gib a player.
-- From kmod script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: gib [partname/id#]\n")
    else
        local clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if client[clientNum]['team'] ~= 1 and client[clientNum]['team'] ~= 2 then
                printCmdMsg(params, "Client is not actively playing\n")
            else
                if et.gentity_get(clientNum, "health") <= 0 then
                    printCmdMsg(params, "Client is currently dead\n")
                else
                    if et.gentity_get(clientNum, "ps.powerups", 1) > 0 then
                        et.gentity_set(clientNum, "ps.powerups", 1, 0)
                    end

                    et.G_Damage(clientNum, clientNum, 1022, 400, 16, 0)
                    et.G_ClientSound(clientNum, "sound/misc/goat.wav")

                    params.broadcast2allClients = true
                    params.noDisplayCmd         = true
                    params.say                  = "cpm"

                    printCmdMsg(
                        params,
                        client[clientNum]["name"] .. color1 .. " was Gibbed\n"
                    )
                end
            end
        end
    end

    return 1
end
