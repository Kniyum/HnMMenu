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
        -- Server side
        TriggerServerEvent('PedComponentSet', target, {componentId= componentId, drawableId= drawableId, textureId= textureId, paletteId= paletteId})
    end

    function HnMMenu:Open()
        MenuV:CloseAll()

        self:SetPedComponentVariation(self.configuration.model.net, 11, 15, 0, 0)
        self:SetPedComponentVariation(self.configuration.target.net, 11, 15, 0, 0)

        self:SetPedComponentVariation(self.configuration.model.net, 8, 15, 0, 0)
        self:SetPedComponentVariation(self.configuration.target.net, 8, 15, 0, 0)

        self:SetPedComponentVariation(self.configuration.model.net, 3, 13, 0, 0)
        self:SetPedComponentVariation(self.configuration.target.net, 3, 13, 0, 0)

        self:SetPedComponentVariation(self.configuration.model.net, 4, 11, 0, 0)
        self:SetPedComponentVariation(self.configuration.target.net, 4, 11, 0, 0)

        self:SetPedComponentVariation(self.configuration.model.net, 6, 13, 0, 0)
        self:SetPedComponentVariation(self.configuration.target.net, 6, 13, 0, 0)

        HnMMenu:GetRootMenu():Open()
    end



    function HnMMenu:GetRootMenu()
        if self.menus.root == nil then
            self.menus.root = MenuV:CreateMenu('Centre de tri', '', "default", "menuv", "hnm_root")
        end
        self.menus.root:ClearItems()

        self.menus.root:AddButton({ label= 'Création vêtement', select= function() 
            self:GetGenericListMenu({
                title= 'Création vêtement',
                namespace= 'clothes_creation',
                data= { { name= 'Haut', value=11 }, { name='Pantalon', value=4 }, { name='Chaussures', value=6 } },
                enter= function(componentId) 
                    self:GetComponentListMenu({
                        title= tostring('Création vêtement'),
                        subtitle= tostring(componentId),
                        componentId= componentId
                    }):Open()
                end
            }):Open() 
        end })
        self.menus.root:AddButton({ label= 'Categorisation vêtement', select= function()  end })

        return self.menus.root
    end

    function HnMMenu:GetGenericListMenu(parameters)
        parameters = parameters or {}
        parameters.title = parameters.title or ''
        parameters.subtitle = parameters.subtitle or ''
        parameters.namespace = parameters.namespace or 'hnm_generic'
        parameters.data = parameters.data or {}
        parameters.enter = parameters.enter or function() end

        if self.menus.genericListMenu == nil then
            self.menus.genericListMenu = MenuV:CreateMenu(parameters.title, parameters.subtitle, 'default', 'menuv', parameters.namespace)
        else
            self.menus.genericListMenu:SetTitle(parameters.title)
            self.menus.genericListMenu:SetSubtitle(parameters.subtitle)
        end
        self.menus.genericListMenu:ClearItems()

        for i=1,#parameters.data,1 do
            local item = parameters.data[i]
            self.menus.genericListMenu:AddButton({
                label= item.name,
                select= function() parameters.enter(item.value) end
            })
        end
        
        return self.menus.genericListMenu
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

        for i=0,GetNumberOfPedDrawableVariations(self.configuration.model.ped, parameters.componentId)-1,1 do
            self.menus.componentListMenu:AddButton({
                label= self:GetDrawableName(parameters.componentId, i),
                enter= function() 
                    self:SetPedComponentVariation(self.configuration.model.net, parameters.componentId, i, 0, 0)
                    self:SetPedComponentVariation(self.configuration.target.net, parameters.componentId, i, 0, 0)
                end,
                select= function ()
                    self:GetMainComponentMenu({
                        title= '',
                        subtitle= '',
                        componentId= parameters.componentId,
                        drawableId= i
                    }):Open()
                end
            })
        end

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
        for i=0,GetNumberOfPedCollectionTextureVariations(self.configuration.target.ped, parameters.componentId, collection, parameters.drawableId),1 do
            table.insert(data.textureIds, i)
        end

        local undershirtCategories = self.dataSource:GetCategories(8)
        local torsoCategories = self.dataSource:GetCategories(3)
        for i=0,#undershirtCategories-1,1 do
            data.sub[tostring(i)] = {}

            for j=0,#torsoCategories-1,1 do
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
                self:GetSwitchableSelectionMenu({
                    title= 'Variantes',
                    subtitle= '',
                    componentId= parameters.componentId,
                    drawableId= parameters.drawableId,
                    currentState= 2,
                    navigationMode= 2,
                    GetName= function (index) return 'res_' .. parameters.componentId .. '_' .. parameters.drawableId .. '_' .. index end,
                    IsChecked= function (index) return arrayContains(data.textureIds, index) end,
                    enter= function (textureId)
                        self:SetPedComponentVariation(self.configuration.target.net, parameters.componentId, parameters.drawableId, textureId, 0)
                    end,
                    change= function (index, checked) 
                        if checked then
                            if not arrayContains(data.textureIds, index) then
                                table.insert(data.textureIds, index)
                            end
                        else
                            if arrayContains(data.textureIds, index) then
                                removeTableItem(data.textureIds, index)
                            end
                        end
                    end
                }):Open()
            end
        })

        if parameters.componentId == 11 then
            -- Catégorie maillots
            self.menus.componentDetailsMenu:AddButton({
                label= 'Catégories maillots',
                select= function() 
                    self:GetSwitchableSelectionMenu({
                        title= 'Maillots',
                        subtitle= '',
                        namespace='hnm_subcomponent_selection_8',
                        currentState= 2,
                        navigationMode= 3,
                        GetName= function (index) return 'string_cat_8_' .. index end,
                        IsChecked= function (index) return data.sub[tostring(index)] ~= nil end,
                        enter= function (index) self:SetPedComponentVariation(self.configuration.target.net, 8, index, 0, 0) end,
                        change= function (index, checked)
                            if checked then
                                data.sub[tostring(index)] = {}
                            else 
                                data.sub[tostring(index)] = nil
                            end
                        end,
                        select= function(selection)
                            self:GetSwitchableSelectionMenu({
                                title= 'Torses & gants',
                                subtitle= '',
                                namespace='hnm_subcomponent_selection_3',
                                currentState= 2,
                                navigationMode= 2,
                                GetName= function (index) return 'string_cat_3_' .. index end,
                                IsChecked= function (index) return arrayContains(data.sub[tostring(selection)], index) end,
                                enter= function (index) self:SetPedComponentVariation(self.configuration.target.net, 3, index, 0, 0) end,
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
                            }):Open()
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

        for j = 0,15,1 do
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