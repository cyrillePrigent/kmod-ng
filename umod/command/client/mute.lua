-- Mute a player.
-- If mute module is enabled, you can add a duration to player mute.
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
--   * params["arg2"] => mute duration (in minutes)
function execute_command(params)
    params.say = msgCmd["chatArea"]
   
    if params.nbArg < 2 then
        if muteModule == 1 then
            printCmdMsg(
                params,
                "Useage: mute \[partname/id#\] \[duration\]\nDuration is optional.\n"
            )
        else
            printCmdMsg(params, "Useage: mute \[partname/id#\]\n")
        end
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "ref mute " .. clientNum .. "\n"
                )

                params.broadcast2allClients = true
                params.noDisplayCmd         = true

                if muteModule == 1 then
                    local duration = tonumber(params["arg2"])

                    if duration then
                        client[clientNum]['muteEnd'] = time["frame"] + (duration * 60000)
                        setMute(clientNum, duration * 60)

                        printCmdMsg(
                            params,
                            string.format(
                                "%s ^7has been muted for %d minutes\n",
                                client[clientNum]["name"], duration
                            )
                        )
                    else
                        printCmdMsg(
                            params,
                            client[clientNum]["name"] .. " ^7has been muted\n"
                        )
                    end
                else
                    printCmdMsg(
                        params,
                        client[clientNum]["name"] .. " ^7has been muted\n"
                    )
                end
            else
                printCmdMsg(params, "Cannot mute a higher admin\n")
            end
        end
    end

    return 1
end
