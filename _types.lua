

---@class SpriteParamBase
---@field public id? integer @ The handle id of the sprite. Assigned on creation
---@field public spriteType? 'default' | 'entity' | 'bone' @ The type of the sprites. Assigned on creation
---@field public key string @ The displayed in the middle of the sprite
---@field public colour number[] @ The colour of the sprite. RGB array
---@field public keyColour? number[] @ The colour of the key. RGB array
---@field public shape string  @ The shape of the sprite
---@field public scale number @ Multiplier for the sprite size
---@field public distance number @ The distance from the sprite to the player
---@field public onEnter? function @ The function to call when the player enters the sprite
---@field public onExit? function @ The function to call when the player exits the sprite
---@field public nearby? function @ The function to call when the player is nearby the sprite
---@field public sprite? string @ The sprite name
---@field public keySprite? string @ The key sprite name
---@field public spriteIndicator? boolean @ Whether to display the sprite indicator

---@class DefinedSpriteParam : SpriteParamBase
---@field public coords vector3 @ The coordinates of the sprite
---@field public distance number @ The distance from the sprite to the player

---@class EntitySpriteParam : SpriteParamBase
---@field public entity number @ The entity to track the bone of

---@class BoneSpriteParam : SpriteParamBase
---@field public boneId number @ Bone id
---@field public entity number @ The entity to track the bone of

---@class ActiveSprite : SpriteParamBase

