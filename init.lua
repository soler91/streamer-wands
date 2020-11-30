function is_valid_entity(entity_id)
    return entity_id ~= nil and entity_id ~= 0
end

function OnWorldPostUpdate()
    local world_state = GameGetWorldStateEntity()
    if (_ws_main and is_valid_entity(world_state)) then
        _ws_main()
    end
end

function OnPlayerSpawned(player_entity)
    dofile("mods/streamer_wands/files/ws/ws.lua")
end

function OnPausePreUpdate()
    if (_ws_main) then
        _ws_main()
    end
end