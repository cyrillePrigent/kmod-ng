-- Display your teamkill index.
--  From kmod lua script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    params.say = msgCmd["chatArea"]
    local status

    if client[params.clientNum]['tkIndex'] < 0 then
        status = "^1NOT OK"
    else
        status = "^2OK"
    end

    printCmdMsg(
        params,
        "^7" .. client[params.clientNum]["name"] .. "^7 has a tk index of ^3"
        .. client[params.clientNum]['tkIndex'] .. "^7 [" .. status .. "^7]\n"
    )

    return 1
end
