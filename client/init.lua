require "client.modules.textures"
local sprites = require "client.modules.sprites"
local config = require "client.modules.config"
local CreateSprite = require "client.modules.sprite"
local myPed = nil
local keySpriteScaleModifier, txtDict in config
local GetAspectRatio, SetDrawOrigin, DrawSprite, BeginTextCommandDisplayText, AddTextComponentSubstringPlayerName, SetTextScale, SetTextCentre, SetTextFont, SetTextColour, EndTextCommandDisplayText, ClearDrawOrigin, GetEntityCoords, GetScreenCoordFromWorldCoord = GetAspectRatio, SetDrawOrigin, DrawSprite, BeginTextCommandDisplayText, AddTextComponentSubstringPlayerName, SetTextScale, SetTextCentre, SetTextFont, SetTextColour, EndTextCommandDisplayText, ClearDrawOrigin, GetEntityCoords, GetScreenCoordFromWorldCoord
local table_unpack = table.unpack
local math_exp = math.exp

local inViews = {}
local spriteIndicators = {}

local function drawSprite(sprite, scaleModifier)
    if sprite.canInteract then
        local success, resp = pcall(sprite.canInteract)
        if not success or not resp then return end
    end

    local id = sprite.id

    local ratio = GetAspectRatio(true)
    local coords = sprite.coords
    SetDrawOrigin(coords.x, coords.y, coords.z)

    local scale = scaleModifier and sprite.scale * scaleModifier or sprite.scale
    scale = math.floor(scale * 10000) / 10000

    if sprite.spriteIndicator then
        local _, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

        local inScreen = x > 0.3 and y > 0.25 and x < 0.7 and y < 0.75

        if inScreen then
            if not inViews[id] then
                inViews[id] = 0.1
            end

            if inViews[id] < 1.0 then
                inViews[id] = inViews[id] + 0.1 > 1.0 and 1.0 or inViews[id] + 0.1
            end

            if spriteIndicators[id] then
                spriteIndicators[id] = spriteIndicators[id] - 0.1 < 0.0 and 0.0 or spriteIndicators[id] - 0.1
                if spriteIndicators[id] <= 0.0 then
                    spriteIndicators[id] = nil
                end
            end
        else
            if inViews[id] then
                inViews[id] = inViews[id] - 0.1 < 0.0 and 0.0 or inViews[id] - 0.1
                if inViews[id] <= 0.0 then
                    inViews[id] = nil
                end
            end

            if not spriteIndicators[id] then
                spriteIndicators[id] = 0.1
            end

            if spriteIndicators[id] < 1.0 then
                spriteIndicators[id] = spriteIndicators[id] + 0.1 > 1.0 and 1.0 or spriteIndicators[id] + 0.1
            end
        end
    else
        inViews[id] = 1.0
    end

    if inViews[id] and sprite.sprite or not sprite.spriteIndicator and sprite.sprite then
        scale = scale * math_exp(-0.15 * sprite.currentDistance)
        local r, g, b, a = table_unpack(sprite.colour)

        local spriteScale = scale * inViews[id]
        DrawSprite(txtDict, sprite.sprite, 0, 0, spriteScale, spriteScale * ratio, 0.0, r, g, b, a or 255)
    end
    
    if sprite.sprite and spriteIndicators[id] then
        local indicatorScaleModifier = spriteIndicators[id]
        local indicatorConfig = config.spriteIndicator

        local indicatorScale = indicatorConfig.scale * math_exp(-0.15 * sprite.currentDistance) * indicatorScaleModifier * (scaleModifier or 1.0)
        local r, g, b, a = table_unpack(sprite.colour)

        DrawSprite(txtDict, indicatorConfig.shape, 0, 0, indicatorScale, indicatorScale * ratio, 0.0, r, g, b, a or 255)
    end

    if (inViews[id] and sprite.key and not spriteIndicators[id]) or (not sprite.spriteIndicator and sprite.key) then
        if sprite.keySprite then
            local r, g, b, a = table_unpack(sprite.keyColour)
            scale = scale * keySpriteScaleModifier
            DrawSprite(txtDict, sprite.key, 0, 0, scale, scale * ratio, 0.0, r, g, b, a or 255)
        else
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName(sprite.key)

            SetTextScale(1.0, scale * 14)
            SetTextCentre(true)
            SetTextFont(2)

            local r, g, b = table_unpack(sprite.keyColour)
            SetTextColour(r, g, b, 255)
            EndTextCommandDisplayText(0, -(scale * 0.5))
        end
    end

    ClearDrawOrigin()
end

CreateThread(function()
    local Wait, GetWorldPositionOfEntityBone, GetEntityCoords, pairs = Wait, GetWorldPositionOfEntityBone, GetEntityCoords, pairs
    while true do
        Wait(250)
        for _,v in pairs(sprites.entities) do
            local entity, boneId in v
            v.coords = boneId and GetWorldPositionOfEntityBone(entity, boneId) or GetEntityCoords(entity)
        end
    end
end)

CreateThread(function()
    local deep_clone = lib.table.deepclone

    local activeSprites = sprites.active
    lib.requestStreamedTextureDict(txtDict)

    ---@type table<number, ActiveSprite>
    local oldSprites = {}

    ---@type table<number, number> Number is the scale, so it can scale in
    local newSprites = {}

    ---@type table<number, ActiveSprite> Store here because it wont be in the activeSprites table anymore
    local removeActiveSprites = {}

    ---@type table<number, number> Number is the scale, so it can scale out
    local removeSprites = {}

    local _wait = 0

    myPed = cache.ped
    local Wait, pairs, next = Wait, pairs, next
    while true do
        Wait(_wait)

        for k, v in pairs(oldSprites) do
            if not activeSprites[k] then
                removeActiveSprites[k] = deep_clone(v)
                oldSprites[k] = nil
            end
        end

        for k, v in pairs(activeSprites) do
            if not oldSprites[k] then
                newSprites[k] = 0.1
                oldSprites[k] = v
            end
    
            local newSprite = newSprites[k]
            if newSprite and newSprite < 1.0 then
                newSprites[k] += 0.1
                if newSprites[k] > 1.0 then
                    newSprites[k] = nil
                end
            end
    
            drawSprite(v, newSprites[k])
        end

        for k, v in pairs(removeActiveSprites) do
            removeSprites[k] = removeSprites[k] or 1.0

            if removeSprites[k] > 0.0 then
                removeSprites[k] -= 0.1
                if removeSprites[k] <= 0.0 then
                    removeSprites[k] = nil
                    removeActiveSprites[k] = nil
                else
                    drawSprite(v, removeSprites[k] or 0)
                end
            end
        end

        local refreshCoords = (next(activeSprites) or next(removeSprites) or next(newSprites)) and true or false
        if refreshCoords then
            sprites.playerCoords = GetEntityCoords(myPed)
            _wait = 0
        else
            _wait = 250
        end

        oldSprites = deep_clone(activeSprites)
    end
end)

lib.onCache('ped', function(value)
    myPed = value
end)

exports('spriteOnEntity', function(data)
    return CreateSprite:defineSpriteOnEntity(data)
end)

exports('spriteOnBone', function(data)
    return CreateSprite:defineSpriteOnBone(data)
end)

exports('sprite', function(data)
    return CreateSprite:defineSprite(data)
end)


exports('updateTargetData', function(id, key, value)
    if type(id) == 'table' then
        id = id.id
    end

    local sprite = sprites.active[id]
    if not sprite then return end

    sprite:updateTargetData(key, value)
end)
