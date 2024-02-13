fx_version 'cerulean'

game "gta5"

author "Byte Labs"
version '1.0.0'
description 'Byte Labs Sprites'
repository 'https://github.com/Byte-Labs-Project/bl_sprites'

lua54 'yes'

shared_script {
    '@ox_lib/init.lua',
}

client_script {
    'client/init.lua',
}

files {
    'client/modules/*.lua',
    'assets/*.png'
}