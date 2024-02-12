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

    local coords, entity, boneId, onEnter, onExit, nearby in data

    coords = type == 'entity' and GetEntityCoords(entity) or type == 'bone' and GetWorldPositionOfEntityBone(entity, boneId) or vec3(coords.x, coords.y, coords.z)

    local selectedSprite = contains(shapes, data.shape)  and 'white_' .. shape or false

    local GetEntityCoords, GetWorldPositionOfEntityBone, GetScreenCoordFromWorldCoord = GetEntityCoords, GetWorldPositionOfEntityBone, GetScreenCoordFromWorldCoord

    self = lib_points.new({
        type = type,
        key = key,
        canInteract = function()
            return true
        end,
        keySprite = keySprite,
        sprite = selectedSprite,
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
            if not type == 'default' then
                coords = type == 'entity' and GetEntityCoords(entity) or type == 'bone' and GetWorldPositionOfEntityBone(entity, boneId) or coords
                self.coords = coords
            end

            local _, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

            local inScreen = x > 0.3 and y > 0.25 and x < 0.6 and y < 0.75
            if inScreen then
                -- self.key = key
                -- self.keySprite = keySprite
                self.scale = scale
            else
                -- self.key = 'eye'
                -- self.keySprite = true
                self.scale = 0.03
            end

            self.currentDistance = #(sprites.playerCoords - coords)
            if nearby then
                nearby(self)
            end
        end,

        updateTargetData = function(self, key, value)
            self[key] = value
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