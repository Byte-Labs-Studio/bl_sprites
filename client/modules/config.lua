return {

    txtDict = 'byte_sprites',

    ---@comment multiplier on top of the scale
    keySpriteScaleModifier = 0.4,

    shapes = {
        'circle',
        'square',
        'hex'
    },

    keySprites = {
        'eye',
        'lock',
        'unlock',
        'radial'
    },

    ---@type SpriteParamBase
    default = {
        key = '',
        colour = {134, 133, 239, 255},
        keyColour = {255, 0, 0, 255},
        shape = '',
        scale = 0.05,
        distance = 10,
    }
}