-- Based on RoadKillPuppy's PlaySound / etpro lua module
-- ex. 'rcon rconpass playsound sound/etpro/hit.wav'
--     'rcon rconpass playsound_env sound/etpro/hit.wav'
--
-- copypasted 99% of the code from ReyalP's wolfwiki page
-- thx r0f`deej for testing...  May your sprees be remembered!
--
-- 0.1 rkp
-- 0.2 rkp: dirty implementation of -1 parameter used by etadminmod [REMOVED]
-- 0.3 rkp: workaround for etpro beta racecondition
-- 0.4 rkp: cleaned-up version for etpro 3.2.3
-- 0.5 rkp: added playsound_env command

-- Require : playsound module

-- Playsound plays a sound that everybody on the server can hear
--  params is parameters passed from et_ConsoleCommand function.
--   * params["arg1"] => path to wav sound file
function execute_command(params)
    if params.nbArg < 2 then
        et.G_Print("Useage: playsound [path_to_sound.wav]\n")
    else
        et.G_globalSound(params["arg1"])
    end

    return 1
end
