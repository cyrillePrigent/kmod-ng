

function execute_command(params)
    local status
    local name = et.Info_ValueForKey(et.trap_GetUserinfo(params.clientNum), "name")

    if tkIndex[params.clientNum] < -1 then
        status = "^1NOT OK"
    else
        status = "^2OK"
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Tk_index: ^7" .. name .. "^7 has a tk index of ^3" .. tkIndex[params.clientNum] .. "^7 \[" .. status .. "^7\] \n")

    return 1
end
