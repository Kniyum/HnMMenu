local SET_COMPONENTS_CLIENT_SIDE = true

function CreateHnMMenu()
    local HnMMenu = {
        dataSource= GetDataSource(),
        menus= {},
        configuration= nil
    }

    setmetatable(HnMMenu, {__index = function(t,k) return search(k, arg) end})
    HnMMenu.__index = HnMMenu

    -- Constructor
    function HnMMenu:new(o) 
        o = o or {}
        setmetable(o, HnMMenu)
        return o
    end

    function HnMMenu:GetConfiguration()
        return self.configuration
    end

    function HnMMenu:SetConfiguration(c)
        self.configuration = c
    end


    function HnMMenu:GetDrawableName(componentId, drawableId) 
        return 'string_res_' .. tostring(componentId) .. '_' .. tostring(drawableId)
    end

    -- Apply changes (client & server)
    function HnMMenu:SetPedComponentVariation(target, componentId, drawableId, textureId, paletteId)
        if SET_COMPONENTS_CLIENT_SIDE then
            -- Client side
            SetPedComponentVariation(target.ped, componentId, drawableId, textureId, paletteId)
        else
            -- Server side
            TriggerServerEvent('PedComponentSet', target.net, {componentId= componentId, drawableId= drawableId, textureId= textureId, paletteId= paletteId})
        end
    end

    function HnMMenu:resetPedComponents(model)
        -- Haut
        self:SetPedComponentVariation(model, 11, 15, 0, 0)
        -- Maillot
        self:SetPedComponentVariation(model, 8, 15, 0, 0)
        -- Torse
        self:SetPedComponentVariation(model, 3, 13, 0, 0)
        -- Pantalon
        self:SetPedComponentVariation(model, 4, 11, 0, 0)
        -- Chaussures
        self:SetPedComponentVariation(model, 6, 13, 0, 0)
    end

    function HnMMenu:Open()
        MenuV:CloseAll()

        self:resetPedComponents(self.configuration.model)
        self:resetPedComponents(self.configuration.target)

        HnMMenu:GetRootMenu():Open()
    end



    function HnMMenu:GetRootMenu()
        if self.menus.root == nil then
            self.menus.root = MenuV:CreateMenu('Centre de tri', '', "default", "menuv", "hnm_root")
        end
        self.menus.root:ClearItems()

        self.menus.root:AddButton({ label= 'Création vêtement', select= function() 
            self:GetGenericListMenu({
                title= 'Création',
                namespace= 'clothes_creation',
                data= { { name= 'Haut', value=11 }, { name='Pantalon', value=4 }, { name='Chaussures', value=6 } },
                select= function(componentId) 
                    self:GetComponentListMenu({
                        title= tostring('Création vêtement'),
                        subtitle= tostring(componentId),
                        componentId= componentId
                    }):Open()
                end
            }):Open() 
        end })
        self.menus.root:AddButton({ label= 'Categorisation vêtement', select= function() 

            self:GetGenericListMenu({
                title= 'Categorisation',
                namespace= 'clothes_categorization',
                data= { { name= 'Maillot', value=8 }, { name='Torse', value=3 } },
                select= function(componentId)

                    local m = self:GetGenericListMenu({
                        title= 'Categorisation',
                        namespace= 'clothes_categories',
                        data= self.dataSource:GetCategories(componentId),
                        enter= function (categoryId)
                            self:resetPedComponents(self.configuration.model)
                            self:resetPedComponents(self.configuration.target)
                            self:SetPedComponentVariation(self.configuration.model, componentId, categoryId, 0, 0) 
                            self:SetPedComponentVariation(self.configuration.target, componentId, categoryId, 0, 0) 
                        end,
                        select= function(categoryId)

                            local data = {}

                            local m2 = self:GetSwitchableSelectionMenu({
                                title= 'res_cat_' .. componentId .. '_' .. categoryId,
                                dataCount= GetNumberOfPedDrawableVariations(self.configuration.model.ped, componentId),
                                currentState= 2,
                                navigationMode= 2,
                                GetName= function (index) 
                                    local drawableId = index - 1
                                    return 'res_' .. componentId .. '_' .. drawableId 
                                end,
                                IsChecked= function (index) 
                                    local drawableId = index - 1
                                    return arrayContains(data, drawableId)
                                end,
                                enter= function (index)
                                    local drawableId = index - 1
                                    self:SetPedComponentVariation(self.configuration.target, componentId, drawableId, 0, 0)
                                end,
                                change= function (index, checked) 
                                    local drawableId = index - 1
                                    if checked then
                                        if not arrayContains(data, drawableId) then
                                            table.insert(data, drawableId)
                                        end
                                    else
                                        if arrayContains(data, drawableId) then
                                            removeTableItem(data, drawableId)
                                        end
                                    end
                                end
                            })

                            m2:AddButton({
                                label= 'Enregistrer',
                                select= function()
                                    -- TODO: Save
                                end
                            })

                            m2:On('Open', function ()
                                self:SetPedComponentVariation(self.configuration.target, componentId, 0, 0, 0)
                            end)
                            
                            m2:Open()

                        end
                    })
                    
                    m:On('Close', function()
                        self:resetPedComponents(self.configuration.model)
                        self:resetPedComponents(self.configuration.target)
                    end)

                    m:Open() 
                end
            }):Open()
        end })

        return self.menus.root
    end

    function HnMMenu:GetGenericListMenu(parameters)
        parameters = parameters or {}
        parameters.title = parameters.title or ''
        parameters.subtitle = parameters.subtitle or ''
        parameters.namespace = parameters.namespace or 'hnm_generic'
        parameters.data = parameters.data or {}
        parameters.enter = parameters.enter or function() end
        parameters.select = parameters.select or function() end

        if self.menus[parameters.namespace] == nil then
            self.menus[parameters.namespace] = MenuV:CreateMenu(parameters.title, parameters.subtitle, 'default', 'menuv', parameters.namespace)
        else
            self.menus[parameters.namespace]:SetTitle(parameters.title)
            self.menus[parameters.namespace]:SetSubtitle(parameters.subtitle)
        end
        self.menus[parameters.namespace]:ClearItems()

        for i=1,#parameters.data,1 do
            self.menus[parameters.namespace]:AddButton({
                label= parameters.data[i].name,
                enter= function() parameters.enter(parameters.data[i].value) end,
                select= function() parameters.select(parameters.data[i].value) end
            })
        end
        
        return self.menus[parameters.namespace]
    end

    function HnMMenu:GetComponentListMenu(parameters)
        parameters = parameters or {}
        parameters.title = parameters.title or ''
        parameters.subtitle = parameters.subtitle or ''
        parameters.namespace = parameters.namespace or 'hnm_component_list'

        if self.menus.componentListMenu == nil then
            self.menus.componentListMenu = MenuV:CreateMenu(parameters.title, parameters.subtitle, 'default', 'menuv', parameters.namespace)
        else
            self.menus.componentListMenu:SetTitle(parameters.title)
            self.menus.componentListMenu:SetSubtitle(parameters.subtitle)
        end
        self.menus.componentListMenu:ClearItems()

        for i=1,GetNumberOfPedDrawableVariations(self.configuration.model.ped, parameters.componentId),1 do
            local drawableId= i - 1
            self.menus.componentListMenu:AddButton({
                label= self:GetDrawableName(parameters.componentId, drawableId),
                enter= function() 
                    self:SetPedComponentVariation(self.configuration.model, parameters.componentId, drawableId, 0, 0)
                    self:SetPedComponentVariation(self.configuration.target, parameters.componentId, drawableId, 0, 0)
                end,
                select= function ()
                    self:GetMainComponentMenu({
                        title= 'res_comp_' .. parameters.componentId .. '_' .. drawableId,
                        componentId= parameters.componentId,
                        drawableId= drawableId
                    }):Open()
                end
            })
        end

        self.menus.componentListMenu:On('Open', function ()
            self:SetPedComponentVariation(self.configuration.model, parameters.componentId, 0, 0, 0)
            self:SetPedComponentVariation(self.configuration.target, parameters.componentId, 0, 0, 0)
        end)

        self.menus.componentListMenu:On('Close', function ()
            self:resetPedComponents(self.configuration.model)
            self:resetPedComponents(self.configuration.target)
        end)

        return self.menus.componentListMenu
    end

    function HnMMenu:GetMainComponentMenu(parameters)
        parameters = parameters or {}
        parameters.title = parameters.title or ''
        parameters.subtitle = parameters.subtitle or ''
        parameters.namespace = parameters.namespace or 'hnm_component_details'

        if self.menus.componentDetailsMenu == nil then
            self.menus.componentDetailsMenu = MenuV:CreateMenu(parameters.title, parameters.subtitle, 'default', 'menuv', parameters.namespace)
        else
            self.menus.componentDetailsMenu:SetTitle(parameters.title)
            self.menus.componentDetailsMenu:SetSubtitle(parameters.subtitle)
        end
        self.menus.componentDetailsMenu:ClearItems()

        local data = {
            componentId= parameters.componentId,
            drawableId= parameters.drawableId,
            textureIds= {},
            sub= {},
            shop=1,
            category=1
        }

        local collection = GetPedCollectionNameFromDrawable(self.configuration.target.ped, parameters.componentId, parameters.drawableId)
        local textureCount = GetNumberOfPedCollectionTextureVariations(self.configuration.target.ped, parameters.componentId, collection, parameters.drawableId)
        if textureCount == 0 then textureCount = 1 end
        for i=1,textureCount,1 do
            local textureId = i - 1
            table.insert(data.textureIds, textureId)
        end

        local undershirtCategories = self.dataSource:GetCategories(8)
        local torsoCategories = self.dataSource:GetCategories(3)
        for i=1,#undershirtCategories,1 do
            data.sub[tostring(i)] = {}

            for j=1,#torsoCategories,1 do
                table.insert(data.sub[tostring(i)], j)
            end
        end

        -- Magasin
        self.menus.componentDetailsMenu:AddSlider({
            label= 'Magasin',
            values= self.dataSource:GetShops(),
            value= data.shop,
            change= function (element, value) 
                data.shop = value
            end
        })

        -- Catégorie magasin
        self.menus.componentDetailsMenu:AddSlider({
            label= 'Catégorie en magasin',
            values= self.dataSource:GetShopCategories(parameters.componentId),
            value= data.category,
            change= function (element, value) 
                data.category = value
            end
        })

        -- Variantes
        self.menus.componentDetailsMenu:AddButton({
            label= 'Variantes',
            select= function() 
                local m = self:GetSwitchableSelectionMenu({
                    title= 'Variantes',
                    componentId= parameters.componentId,
                    drawableId= parameters.drawableId,
                    dataCount= textureCount,
                    currentState= 2,
                    navigationMode= 2,
                    GetName= function (index) 
                        local textureId = index - 1
                        return 'res_' .. parameters.componentId .. '_' .. parameters.drawableId .. '_' .. textureId 
                    end,
                    IsChecked= function (index) 
                        local textureId = index - 1
                        return arrayContains(data.textureIds, textureId) 
                    end,
                    enter= function (index)
                        local textureId = index - 1
                        self:SetPedComponentVariation(self.configuration.target, parameters.componentId, parameters.drawableId, textureId, 0)
                    end,
                    change= function (index, checked) 
                        local textureId = index - 1
                        if checked then
                            if not arrayContains(data.textureIds, textureId) then
                                table.insert(data.textureIds, textureId)
                            end
                        else
                            if arrayContains(data.textureIds, textureId) then
                                removeTableItem(data.textureIds, textureId)
                            end
                        end
                    end
                })

                m:On('Close', function() 
                    -- Reset to initial textureId
                    self:SetPedComponentVariation(self.configuration.target, parameters.componentId, parameters.drawableId, 0, 0)
                end)

                m:Open()
            end
        })

        if parameters.componentId == 11 then
            -- Catégorie maillots
            self.menus.componentDetailsMenu:AddButton({
                label= 'Catégories maillots',
                select= function() 
                    self:GetSwitchableSelectionMenu({
                        title= 'Maillots',
                        dataCount= #self.dataSource:GetCategories(8),
                        namespace='hnm_subcomponent_selection_8',
                        currentState= 2,
                        navigationMode= 3,
                        GetName= function (index) return 'string_cat_8_' .. index end,
                        IsChecked= function (index) return data.sub[tostring(index)] ~= nil end,
                        enter= function (index) self:SetPedComponentVariation(self.configuration.target, 8, index, 0, 0) end,
                        change= function (index, checked)
                            if checked then
                                data.sub[tostring(index)] = {}
                            else 
                                data.sub[tostring(index)] = nil
                            end
                        end,
                        select= function(selection)
                            local m = self:GetSwitchableSelectionMenu({
                                title= 'Torses & gants',
                                dataCount= #self.dataSource:GetCategories(3),
                                namespace='hnm_subcomponent_selection_3',
                                currentState= 2,
                                navigationMode= 2,
                                GetName= function (index) return 'string_cat_3_' .. index end,
                                IsChecked= function (index) return arrayContains(data.sub[tostring(selection)], index) end,
                                enter= function (index) self:SetPedComponentVariation(self.configuration.target, 3, index, 0, 0) end,
                                change= function (index, checked)
                                    if checked then
                                        if not arrayContains(data.sub[tostring(selection)], index) then
                                            table.insert(data.sub[tostring(selection)], index)
                                        end
                                    else
                                        if arrayContains(data.sub[tostring(selection)], index) then
                                            removeTableItem(data.sub[tostring(selection)], index)
                                        end
                                    end
                                end,
                            })
                            
                            m:On('Close', function () 
                                self:SetPedComponentVariation(self.configuration.target, 3, 13, 0, 0)
                            end)

                            m:Open()
                        end
                    }):Open()
                end
            })
        end


        self.menus.componentDetailsMenu:AddButton({
            label= 'Enregistrer',
            select= function() 
                if self.dataSource:Update(data) then
                    notifyStatus('Tenue ' .. self:GetDrawableName(parameters.componentId, parameters.drawableId) .. ' enregistrée')
                else
                    notifyStatus('Erreur lors de l\'enregistrement')
                end
            end
        })

        self.menus.componentDetailsMenu:On('Open', function () 
            self:SetPedComponentVariation(self.configuration.model, 8, 15, 0, 0)
            self:SetPedComponentVariation(self.configuration.model, 3, 13, 0, 0)
            
            self:SetPedComponentVariation(self.configuration.target, 8, 15, 0, 0)
            self:SetPedComponentVariation(self.configuration.target, 3, 13, 0, 0)
        end)

        return self.menus.componentDetailsMenu
    end

    function HnMMenu:GetSwitchableSelectionMenu(parameters)
        parameters = parameters or {}
        parameters.title = parameters.title or ''
        parameters.subtitle = parameters.subtitle or ''
        parameters.namespace = parameters.namespace or 'hnm_subcomponent_selection'

        parameters.GetName = parameters.GetName or function(index) return 'res_' end
        parameters.enter = parameters.enter or function(element) end
        parameters.select = parameters.select or function(element, value) end
        parameters.change = parameters.change or function(index, value) end
        parameters.IsChecked = parameters.IsChecked or function(index) return false end
        parameters.dataCount = parameters.dataCount or 0

        parameters.navigationMode = parameters.navigationMode or 1
        parameters.currentState = parameters.currentState or 2


        if self.menus['subcomponentDynamicMenu' .. parameters.namespace] == nil then
            self.menus['subcomponentDynamicMenu' .. parameters.namespace] = MenuV:CreateMenu(parameters.title, parameters.subtitle, 'default', 'menuv', parameters.namespace)
        else
            self.menus['subcomponentDynamicMenu' .. parameters.namespace]:SetTitle(parameters.title)
            self.menus['subcomponentDynamicMenu' .. parameters.namespace]:SetSubtitle(parameters.subtitle)
        end
        self.menus['subcomponentDynamicMenu' .. parameters.namespace]:ClearItems()

        if parameters.navigationMode == 3 then
            self.menus['subcomponentDynamicMenu' .. parameters.namespace]:AddSlider({
                label= 'mode',
                value = parameters.currentState,
                values= { { label= 'navigation', value=  1 }, { label= 'sélection', value= 2 } },
                change = function (element, mode)
                    parameters.currentState = mode
                    self.menus['subcomponentDynamicMenu' .. parameters.namespace]:Close()
                    self:GetSwitchableSelectionMenu(parameters):Open()
                end
            })
        end

        for j=1,parameters.dataCount,1 do
            if parameters.currentState == 1 then
                self.menus['subcomponentDynamicMenu' .. parameters.namespace]:AddButton({
                    label= parameters.GetName(j),
                    disabled= not parameters.IsChecked(j),
                    enter = function () parameters.enter(j) end,
                    select = function () parameters.select(j) end
                })
            else 
                self.menus['subcomponentDynamicMenu' .. parameters.namespace]:AddCheckbox({
                    label= parameters.GetName(j),
                    value = parameters.IsChecked(j),
                    enter = function () parameters.enter(j) end,
                    change = function (elem, checked) parameters.change(j, checked) end
                })
            end
        end

        return self.menus['subcomponentDynamicMenu' .. parameters.namespace]
    end

    return HnMMenu
end