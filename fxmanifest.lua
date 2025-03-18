fx_version 'cerulean'
game 'gta5'

files {
    'strings/*.json',
    'config/*.json'
}

client_scripts {
    'utils/base.utils.lua',
    'utils/io.utils.lua',
    'utils/ui.utils.lua',

    '@menuv/menuv.lua',

    'SortMenu.lua',
    'HnmMenu.lua',
    'client.lua'
}

server_scripts {
    'utils/io.utils.lua',
    'server.lua'
}