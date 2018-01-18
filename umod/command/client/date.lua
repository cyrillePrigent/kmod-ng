-- Display current date.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.noDisplayCmd = true
    params.say          = "chat"

    printCmdMsg(
        params,
        "The server date is " .. getFormatedDate(os.time(), true) .. "\n"
    )

    return 1
end
