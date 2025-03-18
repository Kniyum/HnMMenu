function CreateSortMenu()

    local SortMenu = {
        MENU_MODE = {
            NAVIGATION_MODE = 1,
            SELECTION_MODE = 2,
            BOTH_MODES = 3
        },
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

        menu:AddButton({ label = 'Gestion des catégories', select = function() self:GenerateMainComponentMenu():Open() end })
        menu:AddButton({ label = 'Associations des tenues', select = function() end })

        return menu
    end

    function SortMenu:GenerateMainComponentMenu() 
        local menu = MenuV:CreateMenu('Centre de tri', '', "default", "menuv", "unknown")
        for k,part in pairs(self.categories) do
            local componentId = tonumber(k)
            if self.categories[k].root then
                menu:AddButton({ label = self:GetSubMenuTitle(componentId), select = function() 
                    self:SetVoidPed(self.configuration.base)
                    self:SetVoidPed(self.configuration.model)
                    self:GenerateSelectionMenu({
                        navigationState= SortMenu.MENU_MODE.NAVIGATION_MODE,
                        componentId= componentId,
                    }):Open()
                end })
            end
        end
        return menu
    end

    function SortMenu:GenerateSelectionMenu(parameters)
        parameters.navigationState = parameters.navigationState or SortMenu.MENU_MODE.NAVIGATION_MODE
        parameters.currentMode = parameters.currentMode or SortMenu.MENU_MODE.NAVIGATION_MODE

        local menu = MenuV:CreateMenu(nil, nil, "default", "menuv", "unknown")
        local data = self:LoadObjectFromJSONFileCached(self:GetComponentNameResourceFilename(self.configuration.type, parameters.componentId))

        menu:SetTitle(self:GetSubMenuTitle(parameters.componentId))
        if parameters.parent then
            menu:SetSubtitle(self:GetSubMenuTitle(parameters.parent.componentId) .. ' > '.. parameters.parent.drawableId ..'.' .. self:GetCategoryName(parameters.parent.componentId, parameters.parent.drawableId))
        end

        if parameters.navigationState == SortMenu.MENU_MODE.BOTH_MODES then
            menu:AddSlider({
                label= 'mode',
                value = parameters.currentMode,
                values= { { label= 'navigation', value=  SortMenu.MENU_MODE.NAVIGATION_MODE }, { label= 'sélection', value= SortMenu.MENU_MODE.SELECTION_MODE } },
                change = function (element, mode)
                    parameters.currentMode = mode

                    menu:Close()
                    self:GenerateSelectionMenu(parameters):Open()
                end
            })
        end

        local obj = nil
        print('parent: ' .. dump(parameters.parent))
        if parameters.parent then
            if parameters.parent.parent then
                obj = self.categories[tostring(parameters.parent.componentId)][tostring(parameters.parent.drawableId)].parents[tostring(parameters.parent.parent.drawableId)]
            else
                obj = self.categories[tostring(parameters.parent.componentId)][tostring(parameters.parent.drawableId)].parents
            end
        end

        for j = 0,15,1 do
            if parameters.currentMode == SortMenu.MENU_MODE.NAVIGATION_MODE then
                menu:AddButton({
                    label= j .. '. ' ..  self:GetCategoryName(parameters.componentId, j),
                    disabled= obj ~= nil and not arrayContains(obj, j),
                    enter = function () self:SetPedComponentVariation(self.configuration.model, parameters.componentId, j, 0, 0) end,
                    select = function () 
                        local subCategory = self:GetSubCategory(parameters.componentId)
                        if subCategory then
                            local subsub = self:GetSubCategory(subCategory)


                            local data = {
                                navigationState= nextMode,
                                componentId= subCategory,
                                parent= {
                                    componentId= parameters.componentId, 
                                    drawableId= j
                                }
                            }

                            
                            if subsub == nil then
                                data.navigationState = SortMenu.MENU_MODE.SELECTION_MODE
                                data.currentMode = SortMenu.MENU_MODE.SELECTION_MODE
                            else
                                data.navigationState = SortMenu.MENU_MODE.BOTH_MODES
                                data.currentMode = SortMenu.MENU_MODE.NAVIGATION_MODE
                            end

                            if parameters.parent then
                                data.parent.parent= {
                                    componentId= parameters.parent.componentId, 
                                    drawableId= parameters.parent.drawableId
                                }
                            end
                            
                            print('data.parent: ' .. dump(data.parent))

                            self:GenerateSelectionMenu(data):Open()
                        end
                    end
                })
            else 
                menu:AddCheckbox({
                    label = j .. '. ' ..  self:GetCategoryName(parameters.componentId, j),
                    value = arrayContains(obj, j),
                    enter = function () self:SetPedComponentVariation(self.configuration.model, parameters.componentId, j, 0, 0) end,
                    change = function (item, checked) 
                        addOrRemoveInArray(obj, j, checked)
                        TriggerServerEvent('SaveFileContentLocaly', 'config/categories.backup.json', self.categories)
                    end
                })
            end
        end

        return menu
    end


    function SortMenu:GetSubCategory(category)
        local category = tostring(category)

        local subCategory = self.categories[category].sub or nil
        return tonumber(subCategory)
    end

    function SortMenu:SetVoidPed(model)
        self:SetPedComponentVariation(model, 11, 15, 0, 0) 
        self:SetPedComponentVariation(model, 8, 15, 0, 0) 
        self:SetPedComponentVariation(model, 3, 13, 0, 0)
        self:SetPedComponentVariation(model, 4, 11, 0, 0)
        self:SetPedComponentVariation(model, 6, 13, 0, 0)
    end

    function SortMenu:IsCategoryParentValid(parent, category, current)
        local parent = tonumber(parent)
        local category = tostring(category)

        local catObj = self.categories[category]
        if catObj == nil then
            return false
        end

        local currentObj = catObj[tostring(parent)]
        if currentObj == nil then
            return false
        end

        local parents = currentObj.parents
        if parents == nil then
            return false
        end

        return arrayContains(parents, current)
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
        return self.strings[componentId].filenames[type] or nil
    end

    -- Apply changes (client & server)
    function SortMenu:SetPedComponentVariation(target, componentId, drawableId, textureId, paletteId)
        -- Client side
        --SetPedComponentVariation(target.netPed, componentId, drawableId, textureId, paletteId)        

        -- Server side
        TriggerServerEvent('PedComponentSet', target.ped, {componentId= componentId, drawableId= drawableId, textureId= textureId, paletteId= paletteId})
        --print('event.PedComponentSet target=(ped:' .. target.ped .. '|net:' .. target.netPed .. ') componentId=' .. componentId .. ' drawableId=' .. drawableId .. ' textureId=' .. textureId .. ' paletteId=' .. paletteId)
    end

    function addOrRemoveInArray(obj, data, add) 
        local found = false
        for i=1,#obj,1 do
            local v = obj[i]
            if v == data then
                found = true
                if not add then
                    table.remove(obj, i)
                end
            end
        end
        if not found then
            table.insert(obj, data)
        end
    end


    return SortMenu
end