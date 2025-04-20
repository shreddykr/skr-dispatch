fx_version 'cerulean'
game 'gta5'

author 'shreddykr'
description 'Dispatcher Menu using ox_lib & ps-dispatch'
version '1.0.1'

lua54 'yes'

shared_script '@ox_lib/init.lua'

dependencies {
    'ps-mdt',
    'ps-dispatch',
    'ox_lib',
    'qb-core'
}

client_scripts {
    'client.lua'
}
