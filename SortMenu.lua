function CreateSortMenu()

    local SortMenu = {
        target = nil,
        resourceFileCache= {},
        configuration= nil,
        categories= nil,
        strings = {
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
        },
    }

    setmetatable(SortMenu, {__index = function(t,k) return search(k, arg) end})
    SortMenu.__index = SortMenu

    -- Constructor
    function SortMenu:new(o) 
        o = o or {}
        setmetable(o, SortMenu)
        return o
    end


    function SortMenu:Init()
        self.categories = self:LoadObjectFromJSONFileCached('config/categories.json')
    end
    
    function SortMenu:Open()
        local rootMenu = self:GenerateRootMenu()
        rootMenu:Open()
    end

    function SortMenu:SetTarget(t)
        self.target = t
    end

    function SortMenu:SetConfiguration(c)
        self.configuration = c
    end

    -- Generate root menu
    function SortMenu:GenerateRootMenu()
        local menu = MenuV:CreateMenu('Centre de tri', '', "default", "menuv", "unknown")
        for k,part in pairs(self.categories) do
            print('k: ' .. type(k) .. ' ' .. k)
            menu:AddButton({ label = self:GetSubMenuTitle(k), select = function() self:GenerateCategoryList(k):Open() end })
        end
        return menu
    end

    -- Generate category list menu
    function SortMenu:GenerateCategoryList(componentId)
        self:SetPedComponentVariation(self.configuration.base, 11, 15, 0, 0) 
        self:SetPedComponentVariation(self.configuration.base, 8, 15, 0, 0) 
        self:SetPedComponentVariation(self.configuration.base, 3, 15, 0, 0) 
        self:SetPedComponentVariation(self.configuration.base, 6, 15, 0, 0) 
        self:SetPedComponentVariation(self.configuration.base, 4, 15, 0, 0) 
        self:SetPedComponentVariation(self.configuration.model, 11, 15, 0, 0) 
        self:SetPedComponentVariation(self.configuration.model, 8, 15, 0, 0) 
        self:SetPedComponentVariation(self.configuration.model, 3, 15, 0, 0) 
        self:SetPedComponentVariation(self.configuration.model, 6, 15, 0, 0) 
        self:SetPedComponentVariation(self.configuration.model, 4, 15, 0, 0) 

        local data = self:LoadObjectFromJSONFileCached(self:GetComponentNameResourceFilename(self.configuration.type, componentId))

        local menu = MenuV:CreateMenu(nil, nil, "default", "menuv", "unknown")

        menu:SetTitle(self:GetSubMenuTitle(componentId))
        
        for i = 0,15,1 do --GetNumberOfPedDrawableVariations(ped, componentId, ''), 1 do
            menu:AddButton({ 
                label = self:GetCategoryName(componentId, i),
                enter = function () 
                    print('enter')
                    self:SetPedComponentVariation(self.configuration.base, componentId, i, 0, 0) 
                    self:SetPedComponentVariation(self.configuration.model, componentId, i, 0, 0)
                end,
                --select = function () self:GenerateComponentDetailMenu(componentId, i):Open() end
            })
        end

        return menu
    end




    -- Load file from cache if exists or store in cache before returning
    function SortMenu:LoadObjectFromJSONFileCached(filename) 
        if self.resourceFileCache[filename] ~= nil then
            return self.resourceFileCache[filename]
        else 
            local data = LoadObjectFromJSONFile(filename)
            self.resourceFileCache[filename] = data
            return data
        end
    end

    -- Get componentId display name
    function SortMenu:GetSubMenuTitle(componentId)
        local componentId = tonumber(componentId)

        if self.strings[componentId] == nil then
            return '#MISSING_VALUE STR_RES_' .. componentId
        else
            return self.strings[componentId].name
        end
    end

    -- Get display name of category
    function SortMenu:GetCategoryName(componentId, drawableId)
        local componentId = tostring(componentId)
        local drawableId = tostring(drawableId)
        
        if self.categories[componentId] == nil or self.categories[componentId][drawableId] == nil then
            return '#MISSING_CATEGORY_' .. componentId .. '_' .. drawableId
        end

        return self.categories[componentId][drawableId].name
    end

    -- Get display name
    function SortMenu:GetDisplayName(data, componentId, drawableId, textureId) 
        local componentId = tostring(componentId)
        local drawableId = tostring(drawableId)
        local textureId = tostring(textureId)
        
        if data[drawableId] == nil or data[drawableId][textureId] == nil then
            return '#MISSING_RESOURCE_' .. componentId .. '_' .. drawableId .. '_' .. textureId
        else
            return data[drawableId][textureId].Localized
        end
    end

    function SortMenu:GetComponentNameResourceFilename(type, componentId)
        local componentId = tonumber(componentId)
        return self.strings[componentId].filenames[type] or nil
    end

    -- Apply changes (client & server)
    function SortMenu:SetPedComponentVariation(target, componentId, drawableId, textureId, paletteId)
        local componentId = tonumber(componentId)
        local drawableId = tonumber(drawableId)
        local textureId = tonumber(textureId)
        local paletteId = tonumber(paletteId)

        -- Client side
        --SetPedComponentVariation(target.netPed, componentId, drawableId, textureId, paletteId)        

        -- Server side
        TriggerServerEvent('PedComponentSet', target.ped, {componentId= componentId, drawableId= drawableId, textureId= textureId, paletteId= paletteId})
        --print('event.PedComponentSet target=(ped:' .. target.ped .. '|net:' .. target.netPed .. ') componentId=' .. componentId .. ' drawableId=' .. drawableId .. ' textureId=' .. textureId .. ' paletteId=' .. paletteId)
    end


    return SortMenu
end