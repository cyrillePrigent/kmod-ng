-- Display "about" message of umod.
--  params is parameters passed from et_ClientCommand  function.
function execute_command(params)
    et.trap_SendServerCommand(
        params.clientNum,
        string.format(
            "cpm \"This server is running the Uber Mod version %s %s\n\"",
            version, releaseStatus
        )
    )

    et.trap_SendServerCommand(
        params.clientNum,
        "cpm \"Based on kmod by Clutch152, enhanced by Yellux.\n\""
    )

    return 1
end
