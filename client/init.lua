local sprites = require "client.modules.sprites"
local config = require "client.modules.config"
local CreateSprite = require "client.modules.sprite"

local keySpriteScaleModifier, txtDict in config
local GetAspectRatio, SetDrawOrigin, DrawSprite, BeginTextCommandDisplayText, AddTextComponentSubstringPlayerName, SetTextScale, SetTextCentre, SetTextFont, SetTextColour, EndTextCommandDisplayText, ClearDrawOrigin, GetEntityCoords = GetAspectRatio, SetDrawOrigin, DrawSprite, BeginTextCommandDisplayText, AddTextComponentSubstringPlayerName, SetTextScale, SetTextCentre, SetTextFont, SetTextColour, EndTextCommandDisplayText, ClearDrawOrigin, GetEntityCoords
local table_unpack = table.unpack
local math_exp = math.exp

local function drawSprite(sprite, scaleModifier)
    if sprite.canInteract and not sprite.canInteract() then return end

    local ratio = GetAspectRatio(true)

    local scale = scaleModifier and sprite.scale * scaleModifier or sprite.scale
    scale = math.floor(scale * 10000) / 10000

    local coords = sprite.renderCoords or sprite.coords
    SetDrawOrigin(coords.x, coords.y, coords.z)

    if sprite.sprite then
        scale = scale * math_exp(-0.15 * sprite.currentDistance)
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

        if next(activeSprites) then
            sprites.playerCoords = GetEntityCoords(cache.ped)
        end

        oldSprites = deep_clone(activeSprites)
    end
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


local CreateSprite = exports.bl_sprites

local test = CreateSprite:sprite({
    coords = GetEntityCoords(PlayerPedId()),
    key = "E",
    scale = 0.1,
    -- colour = { 255, 0, 255 },
    -- keyColour = { 0, 255, 255 },
    -- shape = "hex",
    shape = "hex",
    distance = 10.0,
    onEnter = function(self)
        print("onEnter")
    end,
    onExit = function(self)
        print("onExit")
    end,
})
