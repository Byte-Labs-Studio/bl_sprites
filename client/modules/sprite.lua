local sprites = require "client.modules.sprites"
local config = require "client.modules.config"
local lib_points = lib.points

local Sprite = {}
Sprite.__index = Sprite

local GetWorldPositionOfEntityBone, vec3, GetEntityCoords = GetWorldPositionOfEntityBone, vec3, GetEntityCoords

local function baseConstructor(data)
    if not data then
        return
    end

    local default = config.default
    local shapes = config.shapes
    local keySprites = config.keySprites

    local contains = lib.table.contains

    local type = data.type or 'default'
    local key = data.key or default.key
    local keySprite = contains(keySprites, data.key)
    local colour = data.colour or default.colour
    local keyColour = data.keyColour or default.keyColour
    local shape = contains(shapes, data.shape) and data.shape or default.shape
    local scale = data.scale or default.scale
    local distance = data.distance or default.distance
    local spriteIndicator = data.spriteIndicator or config.spriteIndicatorDefault

    local coords, entity, boneId, onEnter, onExit, nearby, canInteract, offset in data
    local selectedSprite = contains(shapes, data.shape) and shape or false

    coords = type == 'entity' and GetEntityCoords(entity) or type == 'bone' and GetWorldPositionOfEntityBone(entity, boneId) or vec3(coords.x, coords.y, coords.z)
    offset = offset or vec3(0,0,0)


    local spriteData = lib_points.new({
        type = type,
        key = key,
        canInteract = canInteract,
        keySprite = keySprite,
        sprite = selectedSprite,
        scale = scale,
        colour = colour,
        keyColour = keyColour,
        distance = distance,
        spriteIndicator = spriteIndicator,
        coords = coords,

        entity = entity,
        boneId = boneId,

        offset = offset,

        onEnter = function(self)
            local id = self.id
            sprites.active[id] = self

            if sprites.entities[id] then
                sprites.entities[id] = nil
            end

            if onEnter then
                onEnter(self)
            end
        end,

        onExit = function(self)
            local id = self.id
            sprites.active[id] = nil
            sprites.entities[id] = (type == 'entity' or type == 'bone') and self or nil
            if onExit then
                onExit(self)
            end
        end,

        nearby = function(self)
            if type ~= 'default' then
                coords = type == 'entity' and GetEntityCoords(entity) or type == 'bone' and GetWorldPositionOfEntityBone(entity, boneId) + offset or coords
                self.coords = coords
            end

            self.currentDistance = #(sprites.playerCoords - coords)
            if nearby then
                nearby(self)
            end
        end,

        updateTargetData = function(self, key, value)
            local sprite = sprites.active[self.id]
            if not sprite then return end
            if key == 'key' then
                sprite.keySprite = contains(keySprites, value)
            end
            sprite[key] = value
        end,

        removeSprite = function(self)
            local id = self.id
            if not id then return end

            self:remove()
            sprites.active[id] = nil
        end
    })

    if #(GetEntityCoords(cache.ped) - coords) > distance then
        sprites.entities[spriteData.id] = (type == 'entity' or type == 'bone') and spriteData or nil
    end

    spriteData.resource = GetInvokingResource()

    spriteData.eventHandler = AddEventHandler('onResourceStop', function(resourceName)
        if resourceName ~= spriteData.resource then return end
        spriteData:removeSprite()
        RemoveEventHandler(spriteData.eventHandler)
        Wait(1000)
        spriteData = nil
    end)

    spriteData = setmetatable(spriteData, Sprite)

    return spriteData
end

function Sprite:getClosestSprite()
    local closest = math.huge
    local closestData = nil
    for k, v in pairs(sprites.active) do
        if closest > v.currentDistance then
            closest = v.currentDistance
            closestData = v
        end
    end

    return closestData
end

---@param data DefinedSpriteParam
function Sprite:defineSprite(data)
    data.type = "default"
    return baseConstructor(data)
end

---@param data EntitySpriteParam
function Sprite:defineSpriteOnEntity(data)
    data.type = "entity"
    return baseConstructor(data)
end

---@param data BoneSpriteParam
function Sprite:defineSpriteOnBone(data)
    data.type = "bone"
    return baseConstructor(data)
end

return Sprite