function CreateHnmMenu() 

    -- Class
    local HnmMenu = {
        -- Current entity targeted by the menu
        target = entity,
        -- Stored resource file content
        resourceFileCache = {},
        -- Components configuration
        configuration = {
            [11] = {
                name = 'Hauts',
                root = true,
                filenames= {
                    male = 'strings/male_tops.json',
                    female = 'strings/female_tops.json'
                }
            },
            [8] = {
                name = 'Maillot',
                root = false,
                filenames= {
                    male = 'strings/male_undershirts.json',
                    female = 'strings/female_undershirts.json'
                }
            },
            [4] = {
                name = 'Pantalons',
                root = true,
                filenames= {
                    male = 'strings/male_legs.json',
                    female = 'strings/female_legs.json'
                }
            },
            [6] = {
                name = 'Chaussures',
                root = true,
                filenames= {
                    male = 'strings/male_shoes.json',
                    female = 'strings/female_shoes.json'
                }
            },
            [3] = {
                name = 'Gants',
                desc = 'Allez gin-gant !',
                root = false,
                filenames= {
                    male = 'strings/male_torsos.json',
                    female = 'strings/female_torsos.json'
                }
            }
        }
    }
    
    setmetatable(HnmMenu, {__index = function(t,k) return search(k, arg) end})
    HnmMenu.__index = HnmMenu

    -- Constructor
    function HnmMenu:new(o) 
        o = o or {}
        setmetable(o, HnmMenu)
        return o
    end




    -- Set Ped target
    function HnmMenu:SetTarget(t)
        self.target = t
    end

    -- Load file from cache if exists or store in cache before returning
    function HnmMenu:LoadObjectFromJSONFileCached(filename) 
        if self.resourceFileCache[filename] ~= nil then
            return self.resourceFileCache[filename]
        else 
            local data = LoadObjectFromJSONFile(filename)
            self.resourceFileCache[filename] = data
            return data
        end
    end

    -- Apply changes (client & server)
    function HnmMenu:SetPedComponentVariation(target, componentId, drawableId, textureId, paletteId)
        -- Client side
        SetPedComponentVariation(NetToEnt(target.ped), componentId, drawableId, textureId, paletteId)        
        -- Server side
        TriggerServerEvent('PedComponentSet', target.type, {componentId= componentId, drawableId= drawableId, textureId= textureId, paletteId= paletteId})
        --print('event.PedComponentSet target=' .. target.type .. ' componentId=' .. componentId .. ' drawableId=' .. drawableId .. ' textureId=' .. textureId .. ' paletteId=' .. paletteId)
    end

    -- Get componentId name
    function HnmMenu:GetSubMenuTitle(componentId) 
        return self.configuration[componentId].name
    end

    function HnmMenu:GetComponentNameResourceFilename(type, componentId)
        return self.configuration[componentId].filenames[type] or nil
    end

    -- Get display name
    function HnmMenu:GetDisplayName(ped, data, componentId, drawableId, textureId) 
        if data[tostring(drawableId)] == nil or data[tostring(drawableId)][tostring(textureId)] == nil then
            return '#MISSING_RESOURCE_' .. componentId .. '_' .. drawableId .. '_' .. textureId
        end
        return data[tostring(drawableId)][tostring(textureId)].Localized
    end

    -- Glove string with format
    function HnmMenu:GetAccurateGloveStringWithMargin(amount)
        local str = amount .. ' gant'
        if amount > 1 then
            str = str .. 's'
        end
        -- Add non-breaking space to avoid text sticking to checkbox
        str = str .. '&#160&#160'
        return str
    end

    -- Get number of variations for a drawable
    function HnmMenu:GetVariationsCount(ped, componentId, drawableId) 
        local collection = GetPedCollectionNameFromDrawable(ped, componentId, drawableId) or ''
        collection = string.lower(collection)
        return GetNumberOfPedCollectionTextureVariations(ped, componentId, collection, drawableId)
    end

    -- Generate a selection menu
    function HnmMenu:GenerateSelectionMenu(title, subtitle, items, enterCallback, updateCallback)
        local ped = NetToEnt(self.target.ped)
        local menu = MenuV:CreateMenu(nil, nil, "default", "menuv", "unknown")

        menu:SetTitle(title)
        menu:SetSubtitle(subtitle)

        for j = 1, #items, 1 do
            menu:AddCheckbox({ 
                label = items[j],
                enter = function (v) enterCallback(j-1) end,
                update = function (v, val) updateCallback(j-1, val) end
            })
        end

        return menu -- MenuV:OpenMenu(menu, nil, false)
    end

    -- Generate 
    function HnmMenu:GenerateSubComponentMenu() 
        local ped = NetToEnt(self.target.ped)
        local menu = MenuV:CreateMenu(nil, nil, "default", "menuv", "unknown")
        local data = self:LoadObjectFromJSONFileCached(self:GetComponentNameResourceFilename(self.target.type, 8))
        
        menu:SetTitle(self.configuration[8].name)

        for k = 0, GetNumberOfPedDrawableVariations(ped, 8, ''), 1 do
            menu:AddCheckbox({ 
                label = self:GetDisplayName(ped, data, 8, k, 0),
                rightLabel = self:GetAccurateGloveStringWithMargin(math.random(5)),
                enter = function (v) self:SetPedComponentVariation(self.target, 8, k, 0, 0) end,
                change = function (v, newVal, oldVal) 
                    if newVal then 
                        local gloveData = self:LoadObjectFromJSONFileCached(self:GetComponentNameResourceFilename(self.target.type, 3))
                        local items = {}

                        for m = 0, GetNumberOfPedDrawableVariations(ped, 3, ''), 1 do
                            table.insert(items, self:GetDisplayName(ped, gloveData, 3, m, 0))
                        end

                        local selectionMenu = self:GenerateSelectionMenu(self.configuration[3].name, self.configuration[3].desc, items, function(d)
                            self:SetPedComponentVariation(self.target, 3, d, 0, 0)
                        end, function (d, checked)
                            -- TODO: componentId= 3, drawableId= d, selected= checked
                        end)
                        selectionMenu:Open()
                    end
                end,
            })
        end

        return menu
    end

    -- Generate clothes menu
    function HnmMenu:GenerateComponentDetailMenu(componentId, drawableId)
        local variations = {}
        local ped = NetToEnt(self.target.ped)
        local menu = MenuV:CreateMenu(nil, nil, "default", "menuv", "unknown")
        local data = self:LoadObjectFromJSONFileCached(self:GetComponentNameResourceFilename(self.target.type, componentId))

        for l = 1, self:GetVariationsCount(ped, componentId, drawableId), 1 do
            table.insert(variations,'Variante ' .. l)
        end

        menu:SetTitle(self:GetDisplayName(ped, data, cmponentId, drawableId, 0))

        -- Check variations (if none, don't display)
        if #variations > 0 then
            menu:AddButton({ label = 'Variantes', rightLabel = '>', select = function(v) 
                local selectionMenu = self:GenerateSelectionMenu('Variantes', self:GetDisplayName(ped, data, cmponentId, drawableId, 0), variations, function(t)
                    self:SetPedComponentVariation(self.target, componentId, drawableId, t, 0)
                end, function (t, checked)
                    -- TODO: componentId= componentId, drawableId= drawableId, textureid= t, selected= checked
                end)
                selectionMenu:Open()
            end}) 
        else 
            menu:AddButton({ label = 'Variantes', rightLabel = 'Aucune'})
        end

        menu:AddSlider({ label = 'Magasin', value = 1, values = { { label = 'Aucun', value = 0, description = "" }, { label = 'Binco', value = 1, description = "Si t'es pauvre" }, { label = 'Suburban', value = 2, description = "Si t'es un peu moins pauvre" }, { label = 'Ponsonbys', value = 3, description = "Si t'es BG" } }, rightLabel = nil, select = function (v) end })
        menu:AddButton({ label = self.configuration[3].name, value = self:GenerateSubComponentMenu(), rightLabel = '12 elem.' })
        menu:AddButton({ label = 'Valider', value = nil, select = function (v) 
            menu:Close() 

            -- TODO: Export

        end })
        return menu
    end

    -- Generate component's clothes menu list
    function HnmMenu:GenerateComponent(componentId)
        local ped = NetToEnt(self.target.ped)
        local menu = MenuV:CreateMenu(nil, nil, "default", "menuv", "unknown")
        local data = self:LoadObjectFromJSONFileCached(self:GetComponentNameResourceFilename(self.target.type, componentId))

        menu:SetTitle(self:GetSubMenuTitle(componentId))
        
        for i = 0, GetNumberOfPedDrawableVariations(ped, componentId, ''), 1 do
            menu:AddButton({ 
                label = self:GetDisplayName(ped, data, cmponentId, i, 0),
                enter = function () self:SetPedComponentVariation(self.target, componentId, i, 0, 0) end,
                select = function () self:GenerateComponentDetailMenu(componentId, i):Open() end
            })
        end

        return menu
    end

    -- Generate root menu
    function HnmMenu:GenerateRootMenu()
        local menu = MenuV:CreateMenu('H&M', 'Mode et qualité au meilleur prix', "default", "menuv", "unknown")

        for k,part in pairs(self.configuration) do
            if part.root then
                menu:AddButton({ label = self:GetSubMenuTitle(k), select = function() self:GenerateComponent(k):Open() end })
            end
        end

        return menu
    end

    -- Generate root menu & open
    function HnmMenu:Open()
        local rootMenu = self:GenerateRootMenu()
        rootMenu:Open()
    end

    return HnmMenu
end
