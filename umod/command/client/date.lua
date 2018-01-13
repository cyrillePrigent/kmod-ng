-- Display current date.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.noDisplayCmd = true
    params.say          = "chat"

    printCmdMsg(params, os.date("The server date is %x %I:%M:%S%p\n"))

    return 1
end
