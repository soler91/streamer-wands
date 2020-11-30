local server = ModSettingGet("streamer_wands.server")
local token = dofile("mods/streamer_wands/token.lua")
HOST_URL = "ws://" .. server .. "/" .. token