-- Know guids

--  PURPOSE:
--  This script prevents clients with a pbguid never before
--  seen by the server from joining a team until they have served
--  a wait-time (defined by "u_wait_time" below). It is intended
--  to prevent clients who have been kicked/banned from the server
--  from being able to reconnect and play again immediately if they
--  have simply obtained a new pbguid.  

--  DESCRIPTION:
--  This script captures the pbguids (from Userinfo: cl_guid) of clients
--  as they connect to the server and checks them against a serverside
--  list (knownguids.txt).  If the pbguid is present on the list the client
--  is allowed to play immediately. If the pbguid is not present then the
--  client is forced to wait in spectator mode for the designated time,
--  and their pbguid is added to the list.  In addition, this script performs
--  a basic length and hex char test on the pbguid that will immediately
--  kick obviously spoofed examples.

-- More explication :
-- https://www.pbbans.com/forums/is-et-is-a-lost-cause-t38603.html?p=107761

--  GhosT:McSteve
--  www.ghostworks.co.uk
--  Version 2, 4/2/08

-- Yellux
--  Version 3, 7/5/17
--  * Fix pb guid hex check
--  * Fix force_wait set to 0 (no writting in known_guids.cfg file & optimization)
--  * Keep player connected time between warmup / round & between map

-- Global var

knownGuids = {
    -- Time to wait before join a team on server.
    ["waitTime"]  = {
        ["mins"]    = tonumber(et.trap_Cvar_Get("u_kg_wait_time")),
        ["secs"]    = 0,
        ["ms"]      = 0
    },
    -- Switch the wait-time off to collect guids.
    ["forceWait"] = tonumber(et.trap_Cvar_Get("u_kg_force_wait"))
}

knownGuids["waitTime"]["secs"] = knownGuids["waitTime"]["mins"] * 60
knownGuids["waitTime"]["ms"]   = knownGuids["waitTime"]["secs"] * 1000

-- Set default client data.
clientDefaultData["enterTime"] = 0

-- Override team slash command.
addSlashCommand("client", "team", {"function", "checkKnownGuidsTeamEntrance"})


-- Function

if knownGuids["forceWait"] == 1 then
    -- Called when qagame initializes.
    -- Load pending player guid and set remaining time before join a team on server.
    --  vars is the local vars of et_InitGame function.
    function knownGuidsInitGame(vars)
        local fd, len = et.trap_FS_FOpenFile(
            "know_guids/pending_guids.cfg", et.FS_READ
        )

        if len == -1 then
            et.G_LogPrint(
                "uMod WARNING: know_guids/pending_guids.cfg file no found / not readable!\n"
            )
        elseif len ~= 0 then
            local fileStr = et.trap_FS_Read(fd, len)
            local backup = {}

            for clientGuid, clientEnterTime
            in string.gfind(fileStr, "(%x+)%s%-%s(%d+)\n") do
                backup[clientGuid] = clientEnterTime
            end

            for p = 0, clientsLimit, 1 do
                local guid = et.Info_ValueForKey(et.trap_GetUserinfo(p), "cl_guid")

                if guid ~= "" and backup[guid] ~= nil then
                    client[p]["enterTime"] = backup[guid]
                end
            end
        end

        et.trap_FS_FCloseFile(fd)
    end

    -- Callback function when qagame shuts down.
    -- Save pending player guid and remaining time before join a team on server.
    --  vars is the local vars passed from et_ShutdownGame function.
    function knownGuidsShutdownGame(vars)
        local fd, len = et.trap_FS_FOpenFile(
            "know_guids/pending_guids.cfg", et.FS_WRITE
        )

        if len == -1 then
            et.G_LogPrint(
                "uMod WARNING: know_guids/pending_guids.cfg file no found / not writable!\n"
            )
        else
            for p = 0, clientsLimit, 1 do
                if client[p]["guid"] ~= "" and client[p]["enterTime"] ~= 0 then
                    local fileLine = client[p]["guid"] .. " - "
                        .. client[p]["enterTime"] .. "\n"

                    et.trap_FS_Write(fileLine, string.len(fileLine), fd)
                end
            end
        end

        et.trap_FS_FCloseFile(fd)
    end
end

-- Callback function when a client begins (becomes active, and enters the gameworld).
-- Check player guid before join server.
--  vars is the local vars passed from et_ClientBegin function.
function checkKnownGuidsClientBegin(vars)
    -- If client data is set at Init Game, don't check client.
    if client[vars["clientNum"]]["enterTime"] ~= 0 then
        return
    end

    -- Check the guid is 32 chars and hex.
    if guidValidityCheck(client[vars["clientNum"]]["guid"]) then
        -- If guid is know, flag up the client as new (set enterTime to current server time)
        if not knownGuidCheck(vars["clientNum"]) then
            client[vars["clientNum"]]["enterTime"] = et.trap_Milliseconds()
        end
    else
        -- Drop client with bad / missing guid.
        et.trap_DropClient(
            vars["clientNum"],
            "The instruction at 0x00000000 referenced memory at 0x00000000. The memory could not be read."
        )
    end
end

-- Check if player guid is known or not.
--  clientNum is the client slot id.
function knownGuidCheck(clientNum)
    local fd, len = et.trap_FS_FOpenFile("know_guids/validated_guids.cfg", et.FS_READ)

    if len == -1 then
        et.trap_FS_FCloseFile(fd)

        -- Write validated_guids.cfg file if don't exist
        local fd, len = et.trap_FS_FOpenFile("know_guids/validated_guids.cfg", et.FS_WRITE)

        if len == -1 then
            et.G_LogPrint(
                "uMod WARNING: know_guids/validated_guids.cfg file no found / not writable!\n"
            )
        else
            et.trap_FS_Write("", 0, fd)
        end
    else
        local fileStr = et.trap_FS_Read(fd, len)

        if string.find(fileStr, client[clientNum]["guid"]) ~= nil then
            return true
        end
    end

    et.trap_FS_FCloseFile(fd)

    return false
end

-- If a player wait time before join a server, and
-- client enterTime is non-zero, then a client with a new guid
-- has served his wait time, so we can add the guid to file.
--  params is parameters passed to the function executed in command file.
function addKnownGuid(clientNum)
    local fd, len = et.trap_FS_FOpenFile("know_guids/validated_guids.cfg", et.FS_APPEND)
    
    if len == -1 then
        et.G_LogPrint("uMod WARNING: validated_guids.cfg file no found / not writable!\n")
    else
        local fileLine = client[clientNum]["guid"] .. "\n"

        et.trap_FS_Write(fileLine, string.len(fileLine), fd)

        -- Set enterTime for this client to 0 so
        -- the client is not subjected to testing again.
        client[clientNum]["enterTime"] = 0
    end

    et.trap_FS_FCloseFile(fd)
end

-- Function executed when slash command is called in et_ClientCommand function.
-- Check player team entrance.
--  params is parameters passed to the function executed in command file.
function checkKnownGuidsTeamEntrance(params)
    -- Don't check player guid already know.
    if client[params.clientNum]["enterTime"] == 0 then
        return 0
    end

    -- Switch the wait-time off to collect guids only.
    if knownGuids["forceWait"] == 0 then
        addKnownGuid(params.clientNum)
        return 0
    end

    -- Check player team entrance.
    if client[params.clientNum]["team"] == 3 then      
        local connectedTime = et.trap_Milliseconds() - client[params.clientNum]["enterTime"]

        -- If a player don't wait time before join a server
        -- then deny team join.
        if connectedTime < knownGuids["waitTime"]["ms"] then
            et.trap_SendServerCommand(
                params.clientNum,
                "cp \"" .. color2 .. "Sorry, you must wait " .. color4 ..
                second2readeableTime(knownGuids["waitTime"]["secs"] - (connectedTime / 1000))
                .. color2 .. " before joining a team.  This is an anti-cheat measure.  Thanks for your patience.\n\""
            )

            return 1
        end

        addKnownGuid(params.clientNum)
    end

    return 0
end

-- Check guid validity (length & content).
--  guid is the player guid to check.
function guidValidityCheck(guid)
    if string.find(
        guid,
        "^%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x$"
      ) == nil then
        return false
    end

    return true
end

-- Add callback known guids function.
if knownGuids["forceWait"] == 1 then
    addCallbackFunction({
        ["InitGame"]     = "knownGuidsInitGame",
        ["ShutdownGame"] = "knownGuidsShutdownGame"
    })
end
        
addCallbackFunction({
    ["ClientBegin"] = "checkKnownGuidsClientBegin"
})
