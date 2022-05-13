--[[
    Sonoran CAD Plugins

    Plugin Name: radiolink
    Creator: Sonoran Software Systems
    Description: Sonoran Radio Link plugin for Sonoran CAD

    Put all server-side logic in this file.
]]

CreateThread(function() Config.LoadPlugin("radiolink", function(pluginConfig)

    if pluginConfig.enabled then

        local CallCache = {}
        local UnitCache = {}

        CreateThread(function()
            while true do
                Wait(5000)
                CallCache = GetCallCache()
                UnitCache = GetUnitCache()
                for k, v in pairs(CallCache) do
                    v.dispatch.units = {}
                    if v.dispatch.idents then
                        for ka, va in pairs(v.dispatch.idents) do
                            local unit
                            local unitId = GetUnitById(va)
                            table.insert(v.dispatch.units, UnitCache[unitId])
                        end
                    end
                end
            end
        end)

        RegisterNetEvent("SonoranCAD::sonrad:GetCurrentCall")
        AddEventHandler("SonoranCAD::sonrad:GetCurrentCall", function()
            local playerid = source
            local unit = GetUnitByPlayerId(source)
            -- print("unit: " .. json.encode(unit))
            for k, v in pairs(CallCache) do
                if v.dispatch.idents then
                    -- print(json.encode(v))
                    for ka, va in pairs(v.dispatch.idents) do
                        -- print("Comparing " .. unit.id .. " to " .. va)
                        if unit then
                            if unit.id == va then
                                TriggerClientEvent("SonoranCAD::sonrad:UpdateCurrentCall", source, v)
                                -- print("SonoranCAD::sonrad:UpdateCurrentCall " .. source .. " " .. json.encode(v))
                            end
                        end
                    end
                end
            end
        end)

        RegisterNetEvent("SonoranCAD::sonrad:RadioPanic")
        AddEventHandler("SonoranCAD::sonrad:RadioPanic", function()
            if not isPluginLoaded("callcommands") then
                errorLog("Cannot process radio panic as the required callcommands plugin is not present.")
                return
            end
            sendPanic(source, true)
        end)

        RegisterNetEvent("SonoranCAD::sonrad:GetUnitInfo")
        AddEventHandler("SonoranCAD::sonrad:GetUnitInfo", function()
            local unit = GetUnitByPlayerId(source)
            if unit then
                TriggerClientEvent("SonoranCAD::sonrad:GetUnitInfo:Return", source, unit)
            end
        end)
    end

end) end)
