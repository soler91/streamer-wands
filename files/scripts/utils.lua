dofile("mods/streamer_wands/files/scripts/json.lua")

function get_player()
    local player = EntityGetWithTag("player_unit") or nil
    if player ~= nil then
        return player[1]
    end
end

function get_player_pos()
    local x, y = EntityGetTransform(get_player())
    if (x ~= nil) then
        return x, y
    end
end

function str_to_table(data)
    local ret = {}
    for value in string.gmatch(data, "([^,]+)") do
        table.insert(ret, value)
    end
    return ret
end

function get_wands()
    local childs = EntityGetAllChildren(get_player())
    local inven = nil
    if childs ~= nil then
        for _, child in ipairs(childs) do
            if EntityGetName(child) == "inventory_quick" then
                inven = child
            end
        end
    end
    local wands = {}
    if inven ~= nil then
        local items = EntityGetAllChildren(inven)
        for _, child_item in ipairs(items) do
            if EntityHasTag(child_item, "wand") then
                wands[_] = child_item
            end
        end
    end

    return wands or nil
end

function get_wand_stats(id)
    local serialized = {}

    local ability_comp = EntityGetFirstComponentIncludingDisabled(id, "AbilityComponent")
    serialized.sprite = ComponentGetValue2(ability_comp, "sprite_file")
    serialized.mana = ComponentGetValue2(ability_comp, "mana")
    serialized.ui_name = ComponentGetValue2(ability_comp, "ui_name")
    serialized.mana_max = ComponentGetValue2(ability_comp, "mana_max")
    serialized.mana_charge_speed = ComponentGetValue2(ability_comp, "mana_charge_speed")

    serialized.reload_time = ComponentObjectGetValue2(ability_comp, "gun_config", "reload_time")
    serialized.actions_per_round = ComponentObjectGetValue2(ability_comp, "gun_config", "actions_per_round")
    serialized.deck_capacity = ComponentObjectGetValue2(ability_comp, "gun_config", "deck_capacity")
    serialized.shuffle_deck_when_empty = ComponentObjectGetValue2(ability_comp, "gun_config", "shuffle_deck_when_empty")

    serialized.spread_degrees = ComponentObjectGetValue2(ability_comp, "gunaction_config", "spread_degrees")
    serialized.speed_multiplier = ComponentObjectGetValue2(ability_comp, "gunaction_config", "speed_multiplier")
    serialized.fire_rate_wait = ComponentObjectGetValue2(ability_comp, "gunaction_config", "fire_rate_wait")
    return serialized
end

function get_wand_spells(id)
    local childs = EntityGetAllChildren(id)
    local always_cast = {}
    local deck = {}
    if childs ~= nil then
        for _, child in ipairs(childs) do
            local item_comp = EntityGetFirstComponentIncludingDisabled(child, "ItemComponent")
            local item_component = EntityGetFirstComponentIncludingDisabled(child, "ItemActionComponent")
            local is_always_cast = ComponentGetValue2(item_comp, "permanently_attached")
            local action_id = ComponentGetValue2(item_component, "action_id")
            if (is_always_cast) then
                table.insert(always_cast, action_id)
            else
                table.insert(deck, action_id)
            end
        end
    end
    return always_cast, deck
end

function serialize_wands()
    local player = get_player()
    if (player == nil) then
        return "";
    end
    local serialized = {}
    local wands_ids = get_wands()

    for _, wand in ipairs(wands_ids) do
        local stats = get_wand_stats(wand)
        local always_cast, deck = get_wand_spells(wand)
        table.insert( serialized, {stats, always_cast, deck} )
    end
    return json.encode(serialized)
end