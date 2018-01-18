-- Display current time.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.noDisplayCmd = true
    params.say          = "chat"

    printCmdMsg(params, os.date("The server time is %X\n"))

    return 1
end
