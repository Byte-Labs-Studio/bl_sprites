# bl_sprites
## Description
Interactive World Sprites that provide players extra info.

## [PREVIEW[(

## [DOCUMENTATION](https://docs.byte-labs.net/bl_sprites)

### Example
```lua
local CreateSprite = exports.bl_sprites

local test = CreateSprite:sprite({
    coords = GetEntityCoords(PlayerPedId()),
    key = "R",
    shape = "circle",
    spriteIndicator = true,
    colour = {255, 0, 0, 255},
    distance = 5.0,
    scale = 0.05,
    canInteract = function()
        return true
    end,
    nearby = function()
        print('nearby')
    end,
    onEnter = function()
        print('onEnter')
    end,
    onExit = function()
        print('onExit')
    end,
})

-- test is an object you can call functions on such as removeSprite() or updateTargetData()

Wait(2000)
test:updateTargetData('scale', 0.08)

Wait(2000)
test:removeSprite()
```
