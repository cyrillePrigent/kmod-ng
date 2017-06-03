--[[

    ██╗  ██╗███╗   ███╗ ██████╗ ██████╗       ███╗   ██╗ ██████╗
    ██║ ██╔╝████╗ ████║██╔═══██╗██╔══██╗      ████╗  ██║██╔════╝
    █████╔╝ ██╔████╔██║██║   ██║██║  ██║█████╗██╔██╗ ██║██║  ███╗
    ██╔═██╗ ██║╚██╔╝██║██║   ██║██║  ██║╚════╝██║╚██╗██║██║   ██║
    ██║  ██╗██║ ╚═╝ ██║╚██████╔╝██████╔╝      ██║ ╚████║╚██████╔╝
    ╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═════╝       ╚═╝  ╚═══╝ ╚═════╝

This program is free software. you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License.

Source : https://github.com/cyrillePrigent/kmod-ng
Author : Yellux

--]]

kmod_ng_path = et.trap_Cvar_Get("fs_basepath") .. "/" .. et.trap_Cvar_Get("gamename") .. "/kmod-ng/"

dofile(kmod_ng_path .. "core.lua")
