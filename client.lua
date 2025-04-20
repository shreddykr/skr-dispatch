-- Add and delete locations below. It was setup for my server, leave it or keep it.

local policeDepartments = {
    { name = 'MRPD', coords = vec4(442.81, -998.66, 34.97, 182.12) }, --gabz
    { name = 'Roxwood PD', coords = vec4(-441.12, 7106.54, 22.38, 293.14) }, --ambitioneers
    { name = 'Sandy PD', coords = vec4(1860.34, 3688.21, 38.22, 220.11) }, --gabz
    { name = 'Paleto PD', coords = vec4(-447.02, 5995.64, 37.01, 205.17) }, --gabz
    { name = 'Military Dispatch', coords = vec4(-2361.85, 3243.44, 92.9, 141.87) },
    { name = 'Park Ranger', coords = vec4(383.31, 794.82, 190.49, 96.33) }, --gabz
}

local bankLocations = {
    { name = 'Pacific Bank', coords = vec4(256.9, 228.17, 106.29, 328.56) },
    { name = 'Diamond Casino', coords = vec4(928.39, 55.03, 59.87, 167.44) }, --unclejust
    { name = 'Paleto Bank', coords = vec4(-114.22, 6474.03, 31.63, 37.98) },
    { name = 'Vangelico Jewelry', coords = vec4(-630.5, -237.13, 38.05, 204.69) },
    { name = 'Roxwood Bank', coords = vec4(-2831.72, 6232.25, 9.77, 111.34) }, --ambitioneers
}

--- Do Not Touch Below This

-- Police Dispatcher Menu Setup
for _, dept in ipairs(policeDepartments) do
    lib.registerContext({
        id = 'dispatcher_menu_' .. dept.name,
        title = dept.name .. ' Dispatcher Alerts',
        options = {
            {
                title = 'Manual Dispatch',
                icon = 'bullhorn',
                onSelect = function()
                    local input = lib.inputDialog(dept.name .. ' Dispatch Alert', {
                        { type = 'input', label = 'Location Name', description = 'e.g. Legion Square', required = true },
                        { type = 'input', label = 'Reason for Call', description = 'e.g. Officer in need of assistance', required = true },
                        { type = 'input', label = 'Code', description = '10-80', required = true },
                        { type = 'select', label = 'Priority', options = {
                            { label = 'Priority 1 (Urgent)', value = 1 },
                            { label = 'Priority 2 (Medium)', value = 2 },
                            { label = 'Priority 3 (Low)', value = 3 },
                        }, required = true }
                    })

                    if not input then return end

                    local locationLabel = input[1]
                    local reason = input[2]
                    local code = input[3]
                    local priority = tonumber(input[3])
                    local waypoint = GetFirstBlipInfoId(8)

                    if not DoesBlipExist(waypoint) then
                        lib.notify({
                            type = 'error',
                            title = 'No Waypoint Set',
                            description = 'Please place a waypoint on the map first.'
                        })
                        return
                    end

                    local coords = GetBlipInfoIdCoord(waypoint)

                    exports['ps-dispatch']:CustomAlert({
                        message = dept.name .. ' Manual Dispatch: ' .. locationLabel .. '\nReason: ' .. reason,
                        code = code,
                        icon = 'fa-solid fa-bullhorn',
                        priority = priority,
                        coords = coords
                    })

                    lib.notify({
                        title = 'Dispatch Sent',
                        description = 'Your manual dispatch has been sent.',
                        type = 'success'
                    })

                    lib.hideContext()
                end
            },
        }
    })

    CreateThread(function()
        lib.points.new({
            coords = vec3(dept.coords.x, dept.coords.y, dept.coords.z),
            distance = 2.5,
            onEnter = function()
                lib.showTextUI('[E] Open ' .. dept.name .. ' Dispatcher Menu', {
                    position = 'right-center',
                    icon = 'siren-on'
                })
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            nearby = function()
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    lib.showContext('dispatcher_menu_' .. dept.name)
                end
            end
        })
    end)
end

-- Bank Alarm Interaction Setup (with Cancel option)
for _, bank in ipairs(bankLocations) do
    CreateThread(function()
        lib.points.new({
            coords = vec3(bank.coords.x, bank.coords.y, bank.coords.z),
            distance = 2.0,
            onEnter = function()
                lib.showTextUI('[E] Press Hidden Alarm', {
                    position = 'right-center',
                    icon = 'fa-solid fa-building-shield'
                })
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            nearby = function()
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()

                    -- Show the Hidden Alarm Confirmation Menu
                    lib.registerContext({
                        id = 'confirm_alarm_' .. bank.name,
                        title = 'Confirm Silent Alarm',
                        options = {
                            {
                                title = 'Send Alarm',
                                icon = 'check',
                                onSelect = function()
                                    local ped = cache.ped
                                    local coords = GetEntityCoords(ped)

                                    exports['ps-dispatch']:CustomAlert({
                                        message = 'Silent Alarm: ' .. bank.name,
                                        code = '10-90',
                                        icon = 'fa-solid fa-building-shield',
                                        priority = 2,
                                        coords = coords
                                    })

                                    lib.notify({
                                        title = 'Alarm Triggered',
                                        description = 'Silent alarm sent to police.',
                                        type = 'alert'
                                    })
                                    lib.hideContext()
                                end
                            },
                            {
                                title = 'Cancel',
                                icon = 'times',
                                onSelect = function()
                                    lib.notify({
                                        title = 'Operation Cancelled',
                                        description = 'You cancelled the silent alarm.',
                                        type = 'error'
                                    })
                                    lib.hideContext()
                                end
                            },
                        }
                    })

                    -- Show the confirmation menu when pressing E
                    lib.showContext('confirm_alarm_' .. bank.name)
                end
            end
        })
    end)
end
