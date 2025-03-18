function CreateHnMMenu()
    local HnMMenu = {
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

    function HnMMenu:GetShops()
        return { 
            { label= 'Binco', value= 1 }, 
            { label= 'Suburban', value= 2 }, 
            { label= 'Ponsonbys', value= 3 }, 
            { label= 'Masques', value= 4 }, 
            { label= 'Sac', value= 5 }, 
            { label= 'Casino', value= 6 } }
    end

    function HnMMenu:GetShopCategories(mainCategory) 
        print('mainCategory: ' .. tostring(mainCategory))
        if mainCategory == 11 then
            return { 
                { label='T-Shirts', value=1 },
                { label='Polos', value=2 },
                { label='Manteaux', value=3 },
                { label='Sweats & Hoodies', value=4 },
                { label='Costumes', value=5 },
                { label='Chemises', value=6 },
                { label='Robes', value=7 },
                { label='Pulls', value=8 },
                { label='Déguisements', value=9 },
                { label='Gilets', value=10 },
                { label='Vestes', value=11 },
                { label='Eté', value=12 },
                { label='Marcels', value=13 }
            }
        elseif mainCategory == 4 then
            return { 
                { label='Pantalons', value=1 },
                { label='Shorts', value=1 },
                { label='Jupes', value=1 },
                { label='Jeans', value=1 },
                { label='Déguisements', value=1 },
                { label='Intérieur', value=1 },
                { label='Survêtement', value=1 },
                { label='Maillots de bain', value=1 }
            }
        elseif mainCategory == 6 then
            return { 
                { label='Sandales', value=1 },
                { label='Talons', value=1 },
                { label='Bottes/Bottines', value=1 },
                { label='Baskets', value=1 },
                { label='Chaussures plates', value=1 },
                { label='Déguisements', value=1 },
                { label='Hiver', value=1 }
            }
        end
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
                        drawableid= i
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

        -- Magasin
        self.menus.componentDetailsMenu:AddSlider({
            label= 'Magasin',
            values= HnMMenu:GetShops(),
            change= function (element, value) 
                -- TODO: SetShop()
            end
        })

        -- Catégorie magasin
        self.menus.componentDetailsMenu:AddSlider({
            label= 'Catégorie en magasin',
            values= HnMMenu:GetShopCategories(parameters.componentId),
            change= function (element, value) 
                -- TODO: SetShopCategory()
            end
        })

        -- Variantes
        self.menus.componentDetailsMenu:AddButton({
            label= 'Variantes',
            select= function() 
                self:GetSwitchableSelectionMenu({
                    title= 'Variantes',
                    subtitle= 'TODO',
                    componentId= 8,
                    drawableId= parameters.drawableId,
                    currentState= 2,
                    navigationMode= 2
                }):Open()
            end
        })

        -- Catégorie maillots
        self.menus.componentDetailsMenu:AddButton({
            label= 'Catégories maillots',
            select= function() 
                self:GetSwitchableSelectionMenu({
                    title= 'Catégories de maillots',
                    subtitle= 'TODO',
                    componentId= 8,
                    drawableId= parameters.drawableId,
                    currentState= 2,
                    navigationMode= 3
                }):Open()
            end
        })


        self.menus.componentDetailsMenu:AddButton({
            label= 'Enregistrer',
            select= function() 
                -- TODO: enregistrer en DB

                notifyStatus('Tenue ' .. self:GetDrawableName(parameters.componentId, parameters.drawableId) .. ' enregistrée')
            end
        })

        return self.menus.componentDetailsMenu
    end

    function HnMMenu:GetSwitchableSelectionMenu(parameters)
        parameters = parameters or {}
        parameters.title = parameters.title or ''
        parameters.subtitle = parameters.subtitle or ''
        parameters.namespace = parameters.namespace or 'hnm_subcomponent_selection' 

        parameters.navigationMode = parameters.navigationMode or 1
        parameters.currentState = parameters.currentState or 2

        if self.menus.subcomponentDynamicMenu == nil then
            self.menus.subcomponentDynamicMenu = MenuV:CreateMenu(parameters.title, parameters.subtitle, 'default', 'menuv', parameters.namespace)
        else
            self.menus.subcomponentDynamicMenu:SetTitle(parameters.title)
            self.menus.subcomponentDynamicMenu:SetSubtitle(parameters.subtitle)
        end
        self.menus.subcomponentDynamicMenu:ClearItems()

        if parameters.navigationMode == 3 then
            self.menus.subcomponentDynamicMenu:AddSlider({
                label= 'mode',
                value = parameters.currentState,
                values= { { label= 'navigation', value=  1 }, { label= 'sélection', value= 2 } },
                change = function (element, mode)
                    parameters.currentState = mode

                    self.menus.subcomponentDynamicMenu:Close()
                    self:GetSwitchableSelectionMenu(parameters):Open()
                end
            })
        end

        --[[local obj = nil
        if parameters.parent then
            if parameters.parent.parent then
                obj = self.categories[tostring(parameters.parent.componentId)][tostring(parameters.parent.drawableId)].parents[tostring(parameters.parent.parent.drawableId)]
            else
                obj = self.categories[tostring(parameters.parent.componentId)][tostring(parameters.parent.drawableId)].parents
            end
        end]]

        for j = 0,15,1 do
            if parameters.currentState == 1 then
                self.menus.subcomponentDynamicMenu:AddButton({
                    label= 'category_' .. parameters.componentId .. '_' .. j,
                    --disabled= obj ~= nil and not arrayContains(obj, j),
                    enter = function () self:SetPedComponentVariation(self.configuration.model.net, parameters.componentId, j, 0, 0) end,
                    select = function () 
                        local data = {
                            navigationMode= 2,
                            currentState= 2,
                            componentId= 3,
                            parent= {
                                componentId= 8, 
                                drawableId= j,
                                parent= {
                                    componentId= 11, 
                                    drawableId= parameters.drawableId
                                }
                            }
                        }
                        
                        self:GetSwitchableSelectionMenu(data):Open()
                    end
                })
            else 
                self.menus.subcomponentDynamicMenu:AddCheckbox({
                    label= 'category_' .. parameters.componentId .. '_' .. j,
                    value = false, --arrayContains(obj, j),
                    enter = function () self:SetPedComponentVariation(self.configuration.model.net, parameters.componentId, j, 0, 0) end,
                    change = function (item, checked) 
                        --addOrRemoveInArray(obj, j, checked)
                        --TriggerServerEvent('SaveFileContentLocaly', 'config/categories.json', self.categories)
                    end
                })
            end
        end

        return self.menus.subcomponentDynamicMenu

    end

    return HnMMenu
end