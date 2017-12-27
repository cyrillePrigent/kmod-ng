-- Display "about" message of umod.
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    for i = 1, 49, 1 do
        debug(
            "ps.ammo " .. i,
            et.gentity_get(params.clientNum, "ps.ammo", i)
        )

        debug(
            "ps.ammoclip " .. i,
            et.gentity_get(params.clientNum, "ps.ammoclip", i)
        )
    end
    
--     et.trap_SendConsoleCommand(
--         et.EXEC_APPEND,
--         "qsay sess.latchPlayerType = " ..
--             et.gentity_get(params.clientNum, "sess.latchPlayerType")
--          .. "\n"
--     )
-- 
--     et.trap_SendConsoleCommand(
--         et.EXEC_APPEND,
--         "qsay sess.latchPlayerWeapon = " ..
--             et.gentity_get(params.clientNum, "sess.latchPlayerWeapon")
--         .. "\n"
--     )

    return 1
end
