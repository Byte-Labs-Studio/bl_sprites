local sprites = require "client.modules.sprites"
local config = require "client.modules.config"
local spriteClass = require "client.modules.sprite"


local keySpriteScaleModifier, txtDict in config
local GetAspectRatio, SetDrawOrigin, DrawSprite, BeginTextCommandDisplayText, AddTextComponentSubstringPlayerName, SetTextScale, SetTextCentre, SetTextFont, SetTextColour, EndTextCommandDisplayText, ClearDrawOrigin, GetEntityCoords = GetAspectRatio, SetDrawOrigin, DrawSprite, BeginTextCommandDisplayText, AddTextComponentSubstringPlayerName, SetTextScale, SetTextCentre, SetTextFont, SetTextColour, EndTextCommandDisplayText, ClearDrawOrigin, GetEntityCoords
local table_unpack = table.unpack

local function drawSprite(sprite, scaleModifier)
    local ratio = GetAspectRatio(true)

    local scale = scaleModifier and sprite.scale * scaleModifier or sprite.scale
    scale = math.floor(scale * 10000) / 10000

    local coords = sprite.renderCoords or sprite.coords
    SetDrawOrigin(coords.x, coords.y, coords.z)

    if sprite.sprite then
        scale = scale * math.exp(-0.15 * sprite.currentDistance)
        local r, g, b, a = table_unpack(sprite.colour)
        DrawSprite(txtDict, sprite.sprite, 0, 0, scale, scale * ratio, 0.0, r, g, b, a or 255)
    end

    if sprite.key then
        if sprite.keySprite then
            local r, g, b, a = table_unpack(sprite.keyColour)
            scale = scale * keySpriteScaleModifier
            DrawSprite(txtDict, 'white_' .. sprite.key, 0, 0, scale, scale * ratio, 0.0, r, g, b, a or 255)
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

    while true do
        Wait(0)
        -- find the removed sprites
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

            if newSprites[k] and newSprites[k] < 1.0 then
                newSprites[k] = newSprites[k] + 0.1
                if newSprites[k] > 1.0 then
                    newSprites[k] = nil
                end
            end

            drawSprite(v, newSprites[k])
        end

        for k, v in pairs(removeActiveSprites) do
            if removeSprites[k] == nil then
                removeSprites[k] = 1.0
            end

            if removeSprites[k] and removeSprites[k] > 0.0 then
                removeSprites[k] = removeSprites[k] - 0.1
                if removeSprites[k] <= 0.0 then
                    removeSprites[k] = nil
                    removeActiveSprites[k] = nil
                else
                    drawSprite(v, removeSprites[k] or 0)
                end
            end
        end

        oldSprites = deep_clone(activeSprites)
    end
end)


local sprite

RegisterCommand('create', function(source, args)
    local coords = GetEntityCoords(PlayerPedId())

    sprite = spriteClass:defineSprite({
        coords = vec3(coords.x, coords.y, coords.z),
        key = args[1],
        scale = 0.1,
        -- colour = { 255, 0, 255 },
        -- keyColour = { 0, 255, 255 },
        shape = "hex",
        distance = 10.0,
        onEnter = function(self)
            print("onEnter")
        end,
        onExit = function(self)
            print("onExit")
        end,
        nearby = function(self)
            -- print("nearby")
        end,
    })

    -- print('creation', json.encode(sprite, {indent = true}))
end, false)

RegisterCommand('createveh', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    sprite = spriteClass:defineSpriteOnEntity({
        -- coords = vec3(coords.x, coords.y, coords.z),
        entity = vehicle,
        key = "E",
        colour = { 255, 0, 255 },
        keyColour = { 0, 255, 255 },
        -- shape = "hex",
        distance = 5.0,
        onEnter = function(self)
            print("onEnter")
        end,
        onExit = function(self)
            print("onExit")
        end,
        nearby = function(self)
            -- print("nearby")
        end,
    })

    -- print('creation', json.encode(sprite, {indent = true}))
end, false)

RegisterCommand('createbone', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    local boneId = GetEntityBoneIndexByName(vehicle, "wheel_lr")

    sprite = spriteClass:defineSpriteOnBone({
        -- coords = vec3(coords.x, coords.y, coords.z),
        entity = vehicle,
        boneId = boneId,
        key = "E",
        colour = { 255, 0, 255 },
        keyColour = { 0, 255, 255 },
        shape = "hex",
        distance = 5.0,
        onEnter = function(self)
            print("onEnter")
        end,
        onExit = function(self)
            print("onExit")
        end,
        nearby = function(self)
            -- print("nearby")
        end,
    })

    -- print('creation', json.encode(sprite, {indent = true}))
end, false)

RegisterCommand('remove', function()
    sprite:remove()
end, false)