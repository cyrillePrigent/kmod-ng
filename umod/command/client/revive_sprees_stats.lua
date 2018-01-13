-- Display revive spree, multi revive & monster revive player stats.
-- From rspree script.
-- Require : revive spree & multi revive module
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"

    local guid = string.lower(client[params.clientNum]["guid"])
    local statsMsg

    if type(reviveSpree["serverRecords"][guid]) ~= "table" then
        statsMsg = "no reviving stats for " .. client[params.clientNum]["name"]
    else
        local monsterRevive = ""
        local multiRevive   = ""
        local revive        = ""
        local msg           = client[params.clientNum]["name"] .. color1 .. " has "

        if reviveSpree["serverRecords"][guid][2] ~= 0 then
            monsterRevive = reviveSpree["serverRecords"][guid][2] .. " monster revives"
        end

        if reviveSpree["serverRecords"][guid][1] ~= 0 then
            multiRevive = reviveSpree["serverRecords"][guid][1] .. " multi revives"
        end

        revive = "revived a total of " .. reviveSpree["serverRecords"][guid][3] .. " players"

        if reviveSpree["serverRecords"][guid][2] == 0
          and reviveSpree["serverRecords"][guid][1] == 0 then
            msg = msg .. revive
        elseif reviveSpree["serverRecords"][guid][2] ~= 0
          and reviveSpree["serverRecords"][guid][1] ~= 0 then
            msg = msg .. "made " .. monsterRevive .. ", " .. multiRevive .. " and " .. revive
        else
            if reviveSpree["serverRecords"][guid][2] ~= 0 then
                msg = msg .. "made " .. monsterRevive .. " and " .. revive
            end

            if reviveSpree["serverRecords"][guid][1] ~= 0
                msg = msg .. "made " .. multiRevive .. " and " .. revive
            end
        end
        
        statsMsg = msg .. " since " .. os.date(dateFormat, reviveSpree["serverRecords"][guid][5])
    end

    printCmdMsg(params, statsMsg)

    return 0
end
