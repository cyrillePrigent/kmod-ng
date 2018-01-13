-- Display "about" message of umod.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    et.trap_SendServerCommand(
        params.clientNum,
        "cpm \"" .. color1 .. "This server is running the Uber Mod version " ..
        version .. " " .. releaseStatus .. "\n\""
    )

    et.trap_SendServerCommand(
        params.clientNum,
        "cpm \"Based on kmod by Clutch152, enhanced by Yellux.\n\""
    )

    return 1
end
