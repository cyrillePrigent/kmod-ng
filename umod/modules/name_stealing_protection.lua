-- Name stealing protection

-- Function

function checkNameStealingProtectionClientUserinfoChanged(vars)
    local name = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "name")
    local guid = client[vars["clientNum"]]["guid"]

    --if name ~= client[vars["clientNum"]]["name"] and name ~= "ETPlayer" and name ~= "UnnamedPlayer" then
    if name ~= client[vars["clientNum"]]["name"] then
        local testName = et.Q_CleanStr(string.gsub(name, "^%s*(.-)%s*$", "%1"))

        if testName ~= "" then
            for i = 0, clientsLimit, 1 do
                if i ~= vars["clientNum"] and client[i]["name"] ~= "" then
                    if guid ~= client[i]["guid"] and testName == et.Q_CleanStr(string.gsub(client[i]["name"], "^%s*(.-)%s*$", "%1")) then
                        -- $GUID is a name faker
                        if logChatModule == 1 then
                            writeLog(string.format(
                                "%s (%s) is a name faker. Stole name of %s (%s)",
                                guid,
                                name,
                                client[i]["name"],
                                client[i]["guid"]
                            ))
                        end

                        kick(i, "Name stealing / faking")
                        break
                    end
                end
            end
        end
    end
end

-- Add callback name stealing protection function.
addCallbackFunction({
    ["ClientUserinfoChanged"] = "checkNameStealingProtectionClientUserinfoChanged"
})
