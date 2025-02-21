fx_version 'cerulean'
game 'gta5'

author 'DriftV'
description 'Vehicle Dashboard - KM Count'
version '1.0.0'

lua54 'yes'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

client_scripts {
    'client.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependency 'baseevents'
