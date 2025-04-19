--Thanks for downloading! if you have any issues post it in the issues of github
--add and delete locations below it was setup for my server leave it or keep it

local policeDepartments = {
    { name = 'MRPD', coords = vec4(442.81, -998.66, 34.97, 182.12) }, --gabz
    { name = 'Roxwood PD', coords = vec4(-441.12, 7106.54, 22.38, 293.14) }, --ambitioneers ofc
    { name = 'Sandy PD', coords = vec4(1860.34, 3688.21, 38.22, 220.11) }, --gabz
    { name = 'Paleto PD', coords = vec4(-447.02, 5995.64, 37.01, 205.17) }, --gabz
    -- Add more departments with their respective coordinates as needed
}

---Do Not Touch Below This

local interactionZone = nil

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
                        { type = 'input', label = 'Reason for Call', description = 'e.g. Officer in need of assistance', required = true }
                    })

                    if not input then return end

                    local locationLabel = input[1]
                    local reason = input[2]
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
                        code = '99',
                        icon = 'fa-solid fa-bullhorn',
                        priority = 2,
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
        interactionZone = lib.points.new({
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
                if IsControlJustReleased(0, 38) then -- E
                    lib.hideTextUI()
                    lib.showContext('dispatcher_menu_' .. dept.name)
                end
            end
        })
    end)
end
