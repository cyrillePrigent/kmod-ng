-- Send a private message (advanced private message).
-- From kmod script.
-- Require : advanced private message module
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
--   * params["arg2"] => private message content
function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendServerCommand(
            params.clientNum,
            "print \"Useage: /" .. params.bangCmd .. " [pname/ID] [message]\n"
        )
    else
        params.displayInConsole = true
        local pmContent = et.ConcatArgs(2)
        local targetNum = client2id(params["arg1"], params)

        if targetNum ~= nil then
            et.trap_SendServerCommand(
                params.clientNum,
                "chat \"^dPrivate message sent to "
                .. client[targetNum]["name"] .. "^d --> " .. color2 .. pmContent
            )

            et.G_ClientSound(params.clientNum, pmSound)

            et.trap_SendServerCommand(
                targetNum,
                "chat \"^dPrivate message from "
                .. client[params.clientNum]["name"] .. "^d --> " .. color2 .. pmContent
            )

            et.G_ClientSound(targetNum, pmSound)

            if logChatModule == 1 and logPrivateMsg == 1 then
                logPrivateMessage(
                    params.clientNum,
                    pmContent,
                    targetNum,
                    client[targetNum]["name"]
                )
            end
        end
    end

    return 1
end
