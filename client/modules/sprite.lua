local sprites = require "client.modules.sprites"
local config = require "client.modules.config"
local lib_points = lib.points

local Sprite = {}
Sprite.__index = Sprite

local function baseConstructor(self, data)
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
    local spriteIndicator = config.spriteIndicatorDefault

    if data.spriteIndicator ~= nil then
        spriteIndicator = data.spriteIndicator
    end

    local coords, entity, boneId, onEnter, onExit, nearby, canInteract in data

    coords = type == 'entity' and GetEntityCoords(entity) or type == 'bone' and GetWorldPositionOfEntityBone(entity, boneId) or vec3(coords.x, coords.y, coords.z)

    local selectedSprite = contains(shapes, data.shape)  and shape or false

    local GetEntityCoords, GetWorldPositionOfEntityBone = GetEntityCoords, GetWorldPositionOfEntityBone

    self = lib_points.new({
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
            sprites.entities[id] = (type == 'entity' or type == 'bone') and self
            if onExit then
                onExit(self)
            end
        end,

        nearby = function(self)
            if type ~= 'default' then
                coords = type == 'entity' and GetEntityCoords(entity) or type == 'bone' and GetWorldPositionOfEntityBone(entity, boneId) or coords
                self.coords = coords
            end

            self.currentDistance = #(sprites.playerCoords - coords)
            if nearby then
                nearby(self)
            end
        end,

        updateTargetData = function(self, key, value)
            sprites.active[self.id][key] = value
        end,

        removeSprite = function(self)
            local id = self.id
            if not id then return end

            self:remove()
            sprites.active[id] = nil
        end
    })

    self = setmetatable(self, Sprite)

    return self
end

---@param data DefinedSpriteParam
function Sprite:defineSprite(data)
    data.type = "default"
    return baseConstructor(self, data)
end

---@param data EntitySpriteParam
function Sprite:defineSpriteOnEntity(data)
    data.type = "entity"
    return baseConstructor(self, data)
end

---@param data BoneSpriteParam
function Sprite:defineSpriteOnBone(data)
    data.type = "bone"
    return baseConstructor(self, data)
end

return Sprite