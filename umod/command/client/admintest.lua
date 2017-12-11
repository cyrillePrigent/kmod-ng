-- Test your admin level and display result.
-- Require : admins module
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.say = msgCmd["chatArea"]

    local level = getAdminLevel(params.clientNum)

    if level > 0 then
        printCmdMsg(
            params,
            "You are an admin \[lvl " .. level .. "\]\n"
        )
    else
        printCmdMsg(
            params,
            "You are a guest \[lvl 0\]\n"
        )
    end

    return 1
end
