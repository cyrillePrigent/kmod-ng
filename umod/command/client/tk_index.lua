-- Display your teamkill index.
-- From kmod script.
-- Require : teamkill restriction module
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.say = "chat"
    local status

    if client[params.clientNum]['tkIndex'] < 0 then
        status = "^1NOT OK"
    else
        status = "^2OK"
    end

    printCmdMsg(
        params,
        color1 .. client[params.clientNum]["name"] .. color1 .. " has a tk index of " ..
        color2 .. client[params.clientNum]['tkIndex'] .. color1 .. " [" .. status ..
        color1 .. "]\n"
    )

    return 1
end
