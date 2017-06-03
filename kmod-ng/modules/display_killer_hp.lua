-- Display killer HP

-- Global var

-- Set default client data.
clientDefaultData["killerHp"] = 0

-- Function

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function displayKillerHpObituaryEnemyKill(vars)
    client[vars["killer"]]["killerHp"] = (time["frame"] + 5000)
    local killerHp = et.gentity_get(vars["killer"], "health")

    if client[vars["victim"]]["killerHp"] < time["frame"] then
        if killerHp >= 75 then
            et.trap_SendServerCommand(vars["victim"], ("b 8 \"^7" .. vars["killerName"] .. "^" .. k_color .. "'s hp (^o" .. killerHp .. "^" .. k_color .. ")"))

            if client[vars["killer"]]["useAdrenaline"] == 1 then
                et.trap_SendServerCommand(vars["victim"], ("b 8 \"^7" .. vars["killerName"] .. "^" .. k_color .. " is an adrenaline junkie!\""))
            end
        elseif killerHp >= 50 and killerHp <= 74 then
            et.trap_SendServerCommand(vars["victim"], string.format("b 8 \"^7" .. vars["killerName"] .. "^" .. k_color .. "'s hp (^o" .. killerHp .. "^" .. k_color .. ")"))

            if client[vars["killer"]]["useAdrenaline"] == 1 then
                et.trap_SendServerCommand(vars["victim"], ("b 8 \"^7" .. vars["killerName"] .. "^" .. k_color .. " is an adrenaline junkie!\""))
            end
        elseif killerHp >= 25 and killerHp <= 49 then
            et.trap_SendServerCommand(vars["victim"], string.format("b 8 \"^7" .. vars["killerName"] .. "^" .. k_color .. "'s hp (^o" .. killerHp .. "^" .. k_color .. ")"))

            if client[vars["killer"]]["useAdrenaline"] == 1 then
                et.trap_SendServerCommand(vars["victim"], ("b 8 \"^7" .. vars["killerName"] .. "^" .. k_color .. " is an adrenaline junkie!\""))
            end
        elseif killerHp > 0 and killerHp <= 24 then
            et.trap_SendServerCommand(vars["victim"], string.format("b 8 \"^7" .. vars["killerName"] .. "^" .. k_color .. "'s hp (^o" .. killerHp .. "^" .. k_color .. ")"))

            if client[vars["killer"]]["useAdrenaline"] == 1 then
                et.trap_SendServerCommand(vars["victim"], ("b 8 \"^7" .. vars["killerName"] .. "^" .. k_color .. " is an adrenaline junkie!\""))
            end
        end
    end

    if killerHp <= 0 then
        if vars["meansOfDeath"] == 4 or vars["meansOfDeath"] == 18 or vars["meansOfDeath"] == 18 or vars["meansOfDeath"] == 26 or vars["meansOfDeath"] == 27 or vars["meansOfDeath"] == 30 or vars["meansOfDeath"] == 44 or vars["meansOfDeath"] == 43 then
            et.trap_SendServerCommand(vars["victim"], string.format("b 8 \"^" .. k_color .. "You were owned by ^7" .. vars["killerName"] .. "^" .. k_color .. "'s explosive inheritance"))
        end
    end
end

-- Add callback display killer HP function.
addCallbackFunction({
    ["ObituaryEnemyKill"] = "displayKillerHpObituaryEnemyKill"
})