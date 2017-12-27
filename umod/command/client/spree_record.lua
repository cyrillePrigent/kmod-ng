-- Display current spree record.
-- Require : killing spree module
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    debug("spree", spree)
    debug("mapSpree", mapSpree)
    
    
    et.trap_SendServerCommand(
        params.clientNum,
        msgCmd["chatArea"] .. " \"" .. spree["msg"]["oldLong"] .. "\""
    )

    et.trap_SendServerCommand(
        params.clientNum,
        msgCmd["chatArea"] .. " \"" .. mapSpree["msg"]["oldLong"] .. "\""
    )

    return 1
end
