# bl_sprites
## Description
Interactive World Sprites that provide players extra info.

### Dependencies:
- [ox_lib](https://github.com/overextended/ox_lib)

### [PREVIEW](https://youtu.be/vmtox_rdTOE)

### [DOCUMENTATION](https://docs.byte-labs.net/bl_sprites)

### [Create own/edit sprites](https://www.figma.com/file/lCa8qRBuXazc4jXBpaHAuC/Byte-Labs-Sprites?type=design&node-id=0%3A1&mode=design&t=PI6EaFRVr89TyzA4-1)

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
