-- Know guids

--  PURPOSE:
--  This script prevents clients with a pbguid never before seen by the server from joining a team until they have served
--  a wait-time (defined by "k_wait_time" below).  It is intended to prevent clients who have been kicked/banned from
--  the server from being able to reconnect and play again immediately if they have simply obtained a new pbguid.  

--  DESCRIPTION:
--  This script captures the pbguids (from Userinfo: cl_guid) of clients as they connect to the server and checks them
--  against a serverside list (knownguids.txt).  If the pbguid is present on the list the client is allowed to play
--  immediately.  If the pbguid is not present then the client is forced to wait in spectator mode for the designated
--  time, and their pbguid is added to the list.  In addition, this script performs a basic length and hex char test on
--  the pbguid that will immediately kick obviously spoofed examples.

-- More explication : https://www.pbbans.com/forums/is-et-is-a-lost-cause-t38603.html?p=107761

--  GhosT:McSteve
--  www.ghostworks.co.uk
--  Version 2, 4/2/08

-- Yellux
--  Version 3, 7/5/17
--  * Fix pb guid hex check
--  * Reduce I/O filesystem access
--  * Fix force_wait set to 0 (no writting in known_guids.cfg file & optimization)

-- Global var

knownGuids = {
    ["list"]      = {},
    ["waitTime"]  = {
        ["mins"]    = tonumber(et.trap_Cvar_Get("k_wait_time")),
        ["ms"]      = 0
    },
    ["forceWait"] = tonumber(et.trap_Cvar_Get("k_force_wait"))
}

knownGuids["waitTime"]["ms"] = knownGuids["waitTime"]["mins"] * 60 * 1000

-- Set default client data.
if knownGuids["forceWait"] == 1 then
    clientDefaultData["enterTime"] = 0
    addSlashCommand("client", "team", {"function", "checkKnownGuidsTeamEntrance"})
end


-- Function

-- Initializes know guids data.
-- Load know guids entry of known_guids.cfg file.
function loadKnownGuids()
	if knownGuids["forceWait"] == 1 then
        local fd, len = et.trap_FS_FOpenFile("known_guids.cfg", et.FS_READ)

        if len == -1 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay \"^3WARNING: known_guids.cfg file does not exist!\"\n")
        else
            local fileStr = et.trap_FS_Read(fd, len)

            for knownGuid in string.gfind(fileStr, "^(%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x)\n$") do
                knownGuids["list"][knownGuid] = true
            end
        end

        et.trap_FS_FCloseFile(fd)
    end
end

-- Callback function when  a client begins (becomes active, and enters the gameworld).
--  vars is the local vars passed from et_ClientBegin function.
function checkKnownGuidsClientBegin(vars)
	local guid = string.upper(et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "cl_guid"))

	-- check the guid is 32 chars and hex	
	if guidValidityCheck(guid) then
        if knownGuids["forceWait"] == 0 then
            writeKnownGuid(guid)
        else
            if not knownGuids["list"][guid] then
                -- if guid is not found, flag up the client as new (set enter_time to non-zero) and then add the guid
                client[vars["clientNum"]]["enterTime"] = et.trap_Milliseconds()
            end
            
        end
	else
        et.trap_DropClient(vars["clientNum"], "The instruction at 0x00000000 referenced memory at 0x00000000. The memory could not be read.")
	end
end

-- Write a new guid entry in known_guids.cfg file.
--  guid is the player guid to add in known_guids.cfg file.
function writeKnownGuid(guid)
    local fd, len = et.trap_FS_FOpenFile("known_guids.cfg", et.FS_APPEND)
    local info = guid .. "\n"
    et.trap_FS_Write(info, string.len(info), fd)
    et.trap_FS_FCloseFile(fd)
end

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function checkKnownGuidsTeamEntrance(params)
	if client[params.clientNum]["enterTime"] ~= 0 and client[params.clientNum]["team"] == 3 then
        --if connect_time < wait_time then deny team join
        local timeConnected = et.trap_Milliseconds() - client[params.clientNum]["enterTime"]

        if timeConnected < knownGuids["waitTime"]["ms"] then
            et.trap_SendServerCommand(params.clientNum, "cp \"^3Sorry, you must wait^5 " .. knownGuids["waitTime"]["mins"] ..  " ^3minutes before joining a team.  This is an anti-cheat measure.  Thanks for your patience.\n\"")
            return 1
        else
            -- if timeConnected is NOT < wait_time, AND client[params.clientNum]["enterTime"] is non-zero, then a client
            --  with a new guid has served his wait time, so we can add the guid to file
            local guid = string.upper(et.Info_ValueForKey(et.trap_GetUserinfo(params.clientNum), "cl_guid"))
            writeKnownGuid(guid)

            -- set enter_time for this client to 0 so the client is not subjected to testing again
            client[params.clientNum]["enterTime"] = 0
            knownGuids["list"][guid] = true
        end
	end

	return 0
end

-- Check guid validity (length & content).
--  guid is the player guid to check.
function guidValidityCheck(guid)
    if string.len(guid) ~= 32 then
		return false
	end

    if string.find(guid, "^%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x$") == nil then
        return false
    end

	return true
end

-- Add callback known guids function.
addCallbackFunction({
    ["ReadConfig"]  = "loadKnownGuids",
    ["ClientBegin"] = "checkKnownGuidsClientBegin"
})
