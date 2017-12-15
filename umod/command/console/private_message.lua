-- Send a private message (advanced private message).
-- NOTE : In ETpro, m / pm / msg don't work in server console. Use m2 command instead.
-- From kmod lua script.
--  params is parameters passed from et_ConsoleCommand function.
--   * params["arg1"] => client
--   * params["arg2"] => private message content
function execute_command(params)
    if params.nbArg < 3 then 
        et.G_Print("Useage: /m2 \[pname/ID\] \[message\]\n")
    else
        params.displayInConsole = true
        local message   = et.ConcatArgs(2)
        local targetNum = client2id(params["arg1"], params)

        if targetNum ~= nil then
            et.G_Print(
                "Private message sent to " .. client[targetNum]["name"]
                .. "^d --> ^3" .. message .. "^7\n"
            )

            et.trap_SendServerCommand(
                targetNum,
                msgCmd["chatArea"] .. "\"^dPrivate message from ^1SERVER ^d--> ^3"
                .. message .. "^7"
            )

            et.G_ClientSound(targetNum, pmSound)

            if logChatModule == 1 then
                logPrivateMessage(
                    1022, message, targetNum, client[targetNum]["name"]
                )
            end
        end
    end

    return 1
end
