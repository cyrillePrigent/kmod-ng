-- Enable cheats (for etpro).
-- You can use god, noclip & nofatigue.
-- Enable / disable Punkbuster automatically if needed (Cheat-protected).
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => cheats value
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: cheats \[0-1\]\n")
    else
        local cheat = tonumber(params["arg1"])

        if cheat == 1 then
            pbState=false

            if tonumber(et.trap_Cvar_Get("sv_punkbuster")) == 1 then
                pbState=true
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "pb_sv_disable\n")
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "forcecvar sv_cheats 1\n")

            params.broadcast2allClients = true
            params.noDisplayCmd         = true

            printCmdMsg(params, "Cheats have been Enabled\n")
        elseif cheat == 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "forcecvar sv_cheats 0\n")

            if pbState then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "pb_sv_enable\n")
            end

            params.broadcast2allClients = true
            params.noDisplayCmd         = true

            printCmdMsg(params, "Cheats have been Disabled\n")
        else
            printCmdMsg(params, "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
