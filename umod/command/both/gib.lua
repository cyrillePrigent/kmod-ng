-- Gib a player.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: gib \[partname/id#\]\n")
    else
        local clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if client[clientNum]['team'] ~= 1 and client[clientNum]['team'] ~= 2 then
                printCmdMsg(params, "Client is not actively playing\n")
            else
                if et.gentity_get(clientNum, "health") <= 0 then
                    printCmdMsg(params, "Client is currently dead\n")
                else
                    et.G_Damage(clientNum, clientNum, 1022, 400, 24, 0)
                    et.G_ClientSound(clientNum, "sound/misc/goat.wav")
                    et.trap_SendServerCommand(-1, "b 16 \"^7" .. et.gentity_get(clientNum, "pers.netname") .. " ^7was Gibbed^7")
                end
            end
        end
    end

    return 1
end
