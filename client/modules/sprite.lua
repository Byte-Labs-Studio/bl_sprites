local sprites = require "client.modules.sprites"
local config = require "client.modules.config"
local lib_points = lib.points

local Sprite = {}
Sprite.__index = Sprite

function Sprite:baseConstructor(data)
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
    local coords = data.coords
    local entity = data.entity
    local boneId = data.boneId
    local onEnter = data.onEnter
    local onExit = data.onExit
    local nearby = data.nearby

    if type == 'entity' then
        coords = GetEntityCoords(entity)
    elseif type == 'bone' then
        coords = GetWorldPositionOfEntityBone(entity, boneId)
    end

    local sprite = contains(shapes, data.shape)  and 'white_' .. shape or false

    local GetEntityCoords, GetWorldPositionOfEntityBone = GetEntityCoords, GetWorldPositionOfEntityBone

    local self = setmetatable({}, Sprite)

    self = lib_points.new({
        type = type,
        key = key,
        keySprite = keySprite,
        sprite = sprite,
        scale = scale,
        colour = colour,
        keyColour = keyColour,
        distance = distance,

        coords = coords,
        entity = entity,
        boneId = boneId,

        onEnter = function(self)
            local id = self.id
            sprites.active[id] = self

            if onEnter then
                onEnter(self)
            end
        end,

        onExit = function(self)
            local id = self.id
            sprites.active[id] = nil

            if onExit then
                onExit(self)
            end
        end,

        nearby = function(self)

            if type == 'entity' then
                local entity = entity
                local coords = GetEntityCoords(entity)
                self.coords = vec3(coords.x, coords.y, coords.z)
            elseif type == 'bone' then
                local entity = entity
                local boneId = boneId
                local coords = GetWorldPositionOfEntityBone(entity, boneId)
                self.coords = vec3(coords.x, coords.y, coords.z)
            end

            if nearby then
                nearby(self)
            end
        end,
    })

    return self
end

---@param data DefinedSpriteParam
function Sprite:defineSprite(data)
    data.type = "default"
    self:baseConstructor(data)
end

function Sprite:removeSprite()
    local id = self.id

    if not id then
        return
    end

    self:remove()
    sprites.defined[id] = nil
end

---@param data EntitySpriteParam
function Sprite:defineSpriteOnEntity(data)
    data.type = "entity"
    self:baseConstructor(data)
end

---@param data BoneSpriteParam
function Sprite:defineSpriteOnBone(data)
    data.type = "bone"
    self:baseConstructor(data)
end

return Sprite
