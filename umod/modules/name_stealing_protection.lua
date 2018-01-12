-- Name stealing protection
-- From etadmin script.
        
-- Function

-- Callback function when a client’s Userinfo string has changed.
-- When client’s Userinfo string has change, check his name is
-- already used and kick him if needed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function checkNameStealingProtectionClientUserinfo(vars)
    local name = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "name")

    -- Check if name is modified (Exclude default name)
    -- TODO : Check default player name of ET-Legacy
    if name ~= client[vars["clientNum"]]["name"] and name ~= "ETPlayer" then
        local testName  = et.Q_CleanStr(trim(name))

        if testName ~= "" then
            local guid = client[vars["clientNum"]]["guid"]

            for p = 0, clientsLimit, 1 do
                if p ~= vars["clientNum"] and client[p]["name"] ~= "" then
                    if guid ~= client[p]["guid"]
                      and testName == et.Q_CleanStr(trim(client[p]["name"])) then
                        -- Name faker detected
                        if logChatModule == 1 then
                            writeLog(string.format(
                                "%s (%s) is a name faker. Stole name of %s (%s)",
                                name,
                                guid,
                                client[p]["name"],
                                client[p]["guid"]
                            ))
                        end

                        kick(vars["clientNum"], "Name stealing / faking")
                        break
                    end
                end
            end
        end
    end
end

-- Add callback name stealing protection function.
addCallbackFunction({
    ["ClientUserinfoChanged"] = "checkNameStealingProtectionClientUserinfo"
})
