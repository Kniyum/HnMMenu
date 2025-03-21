fx_version 'cerulean'
game 'gta5'

files {
    'strings/*.json'
}

client_scripts {
    'utils/base.utils.lua',
    'utils/io.utils.lua',
    'utils/ui.utils.lua',

    '@menuv/menuv.lua',
    'DataSource.lua',
    'HnMMenu.lua',
    'client.lua'
}

server_scripts {
    'utils/base.utils.lua',
    'utils/io.utils.lua',
    'server.lua'
}