-- Display current time.
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand  function.
function execute_command(params)
    params.noDisplayCmd = true
    params.say          = msgCmd["chatArea"]

    printCmdMsg(params, os.date("The server time is %I:%M:%S%p\n"))

    return 1
end
