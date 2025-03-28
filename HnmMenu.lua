function CreateHnMMenu()
    local HnMMenu = {
        dataSource= nil,
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

    function HnMMenu:SetDataSource(d)
        self.dataSource = d
    end


    function HnMMenu:GetDrawableName(componentId, drawableId, textureId)
        local textureId = textureId or 0
        return self.dataSource:GetClothesName(self.configuration.type, componentId, drawableId, textureId)
    end

    -- Apply changes (client & server)
    function HnMMenu:SetPedComponentVariation(target, componentId, drawableId, textureId, paletteId)
        SetPedComponentVariation(target.ped, componentId, drawableId, textureId, paletteId)
    end

    function HnMMenu:resetPedComponents(model)
        -- Top
        self:SetPedComponentVariation(model, 11, 15, 0, 0)
        -- Undershirt
        self:SetPedComponentVariation(model, 8, 15, 0, 0)
        -- Torso
        self:SetPedComponentVariation(model, 3, 13, 0, 0)
        -- Legs
        self:SetPedComponentVariation(model, 4, 11, 0, 0)
        -- Shoes
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
            self.menus.root = MenuV:CreateMenu("Centre de tri", "", "default", "menuv", "hnm_root")
        end
        self.menus.root:ClearItems()

        self.menus.root:AddButton({ label= "Création vêtement", select= function() 
            self:GetGenericListMenu({
                title= "Création",
                namespace= "clothes_creation",
                data=  self.dataSource:GetMainComponents(),
                select= function(componentId) 
                    self:GetComponentListMenu({
                        title= "Création vêtement",
                        subtitle= self.dataSource:GetComponent(componentId).label,
                        componentId= componentId
                    }):Open()
                end
            }):Open() 
        end })
        self.menus.root:AddButton({ label= "Categorisation vêtement", select= function() 

            self:GetGenericListMenu({
                title= "Categorisation",
                namespace= "clothes_categorization",
                data= self.dataSource:GetSubComponents(),
                select= function(componentId)

                    local m = self:GetGenericListMenu({
                        title= "Categorisation",
                        namespace= "clothes_categories",
                        data= self.dataSource:GetCategories(self.configuration.type, componentId),
                        enter= function (categoryId)
                            self:resetPedComponents(self.configuration.model)
                            self:resetPedComponents(self.configuration.target)
                            self:SetPedComponentVariation(self.configuration.model, componentId, categoryId, 0, 0) 
                            self:SetPedComponentVariation(self.configuration.target, componentId, categoryId, 0, 0) 
                        end,
                        select= function(categoryId, index)
                            local data = self.dataSource:GetCategoryDrawables(self.configuration.type, componentId, categoryId)

                            local alreadyCategorized = {}
                            for n=1,#self.dataSource:GetCategories(self.configuration.type, componentId),1 do
                                table.insert(alreadyCategorized, self.dataSource:GetCategories(self.configuration.type, componentId)[n].value)
                            end

                            local m2 = self:GetSwitchableSelectionMenu({
                                namespace= "category_product_selection",
                                title= self.dataSource:GetCategories(self.configuration.type, componentId)[index].label,
                                dataCount= GetNumberOfPedDrawableVariations(self.configuration.model.ped, componentId),
                                currentState= 2,
                                navigationMode= 2,
                                GetName= function (index) 
                                    local drawableId = index - 1
                                    return self:GetDrawableName(componentId, drawableId)
                                end,
                                filter= function(index) 
                                    local drawableId = index - 1
                                    return not self.dataSource:IsDrawableInOtherCategory(self.configuration.type, componentId, categoryId, drawableId) and not ArrayContains(alreadyCategorized, drawableId)
                                end,
                                IsChecked= function (index) 
                                    local drawableId = index - 1
                                    return ArrayContains(data, drawableId)
                                end,
                                enter= function (index)
                                    local drawableId = index - 1
                                    self:SetPedComponentVariation(self.configuration.target, componentId, drawableId, 0, 0)
                                end,
                                change= function (index, checked) 
                                    local drawableId = index - 1
                                    if checked then
                                        if not ArrayContains(data, drawableId) then
                                            table.insert(data, drawableId)
                                        end
                                    else
                                        if ArrayContains(data, drawableId) then
                                            RemoveTableItem(data, drawableId)
                                        end
                                    end
                                end,
                                save= function() 
                                    if self.dataSource:UpdateCategory(self.configuration.type, componentId, categoryId, data) then
                                        notifyStatus("Catégorie " .. self.dataSource:GetCategories(self.configuration.type, componentId)[index].label .. " complétée")
                                    else
                                        notifyStatus("Erreur lors de l\'enregistrement")
                                    end

                                    return true
                                end
                            })

                            m2:On("Open", function ()
                                self:SetPedComponentVariation(self.configuration.target, componentId, categoryId, 0, 0, 0)
                            end)
                            
                            m2:Open()

                        end
                    })
                    
                    m:On("Close", function()
                        self:resetPedComponents(self.configuration.model)
                        self:resetPedComponents(self.configuration.target)
                    end)

                    m:Open() 
                end
            }):Open()
        end })

        self.menus.root:AddButton({
            label= "Collections",
            select= function() 
                self:GetGenericListMenu({
                    title= "Création",
                    namespace= "collection_components",
                    data=  self.dataSource:GetCollectionableComponents(),
                    select= function(componentId) 

                        local drawables = {}
                        for l=1,GetNumberOfPedDrawableVariations(self.configuration.target.ped, tonumber(componentId)),1 do
                            local drawableId = l - 1
                            table.insert(drawables, drawableId)
                        end

                        self:GetSwitchableSelectionMenu({
                            title= self.dataSource:GetComponents()[componentId].label,
                            dataCount= #drawables,
                            currentState= 1,
                            navigationMode= 1,
                            IsChecked= function() return true end,
                            GetName= function (index) 
                                local drawableId = index - 1
                                return self:GetDrawableName(componentId, drawableId, 0)
                            end,
                            enter= function (index)
                                local drawableId = index - 1
                                self:SetPedComponentVariation(self.configuration.model, componentId, drawableId, 0, 0)
                                self:SetPedComponentVariation(self.configuration.target, componentId, drawableId, 0, 0)
                            end,
                            select= function (index)
                                local drawableId = index - 1
                                self:SetPedComponentVariation(self.configuration.model, componentId, drawableId, 0, 0)

                                local collection = {}

                                local ids = {}
                                local count = 20
                                local starting = drawableId - count
                                local max = GetNumberOfPedDrawableVariations(self.configuration.model.ped, componentId)
                                for k = starting, starting + (count*2), 1 do
                                    if k >= 0 and k < max then
                                        table.insert(ids, k)
                                    end
                                end

                                self:GetSwitchableSelectionMenu({
                                    namespace= "glove_collection_selection",
                                    title= self:GetDrawableName(componentId, drawableId),
                                    dataCount= #ids,
                                    currentState= 2,
                                    navigationMode= 2,
                                    IsDisabled= function (index) return drawableId == ids[index] end,
                                    GetName= function (index) 
                                        local drawableId = ids[index]
                                        return self:GetDrawableName(componentId, drawableId)
                                    end,
                                    IsChecked= function (index) 
                                        return drawableId == ids[index] or false -- TODO
                                    end,
                                    enter= function (index)
                                        self:SetPedComponentVariation(self.configuration.target, componentId, ids[index], 0, 0)
                                    end,
                                    change= function (index, checked)
                                        local drawableId = ids[index]
                                        if checked then
                                            if not ArrayContains(collection, drawableId) then
                                                table.insert(collection, drawableId)
                                            end
                                        else
                                            if ArrayContains(collection, drawableId) then
                                                RemoveTableItem(collection, drawableId)
                                            end
                                        end
                                    end,
                                    save= function ()
                                        if self.dataSource:UpdateCollection(self.configuration.type, componentId, collection) then
                                            local name = "sans-titre"
                                            if #collection > 0 then name = self:GetDrawableName(componentId, collection[0]) end
                                            notifyStatus("Collection  " .. name .. " complétée")
                                        else
                                            notifyStatus("Erreur lors de l\'enregistrement")
                                        end
                                        return true
                                    end
                                }):Open()

                            end,
                        }):Open()
                    end
                }):Open()
            end
        })

        return self.menus.root
    end

    function HnMMenu:GetGenericListMenu(parameters)
        parameters = parameters or {}
        parameters.title = parameters.title or ""
        parameters.subtitle = parameters.subtitle or ""
        parameters.namespace = parameters.namespace or "hnm_generic"
        parameters.data = parameters.data or {}
        parameters.enter = parameters.enter or function(value, index) end
        parameters.select = parameters.select or function(value, index) end

        if self.menus[parameters.namespace] == nil then
            self.menus[parameters.namespace] = MenuV:CreateMenu(parameters.title, parameters.subtitle, "default", "menuv", parameters.namespace)
        else
            self.menus[parameters.namespace]:SetTitle(parameters.title)
            self.menus[parameters.namespace]:SetSubtitle(parameters.subtitle)
        end
        self.menus[parameters.namespace]:ClearItems()

        for i=1,#parameters.data,1 do
            self.menus[parameters.namespace]:AddButton({
                label= parameters.data[i].label,
                enter= function() parameters.enter(parameters.data[i].value, i) end,
                select= function() parameters.select(parameters.data[i].value, i) end
            })
        end
        
        return self.menus[parameters.namespace]
    end

    function HnMMenu:GetComponentListMenu(parameters)
        parameters = parameters or {}
        parameters.title = parameters.title or ""
        parameters.subtitle = parameters.subtitle or ""
        parameters.namespace = parameters.namespace or "hnm_component_list"

        if self.menus.componentListMenu == nil then
            self.menus.componentListMenu = MenuV:CreateMenu(parameters.title, parameters.subtitle, "default", "menuv", parameters.namespace)
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
                        title= self:GetDrawableName(parameters.componentId, drawableId),
                        componentId= parameters.componentId,
                        drawableId= drawableId
                    }):Open()
                end
            })
        end

        self.menus.componentListMenu:On("Close", function ()
            self:resetPedComponents(self.configuration.model)
            self:resetPedComponents(self.configuration.target)
        end)

        return self.menus.componentListMenu
    end

    function HnMMenu:GetMainComponentMenu(parameters)
        parameters = parameters or {}
        parameters.title = parameters.title or ""
        parameters.subtitle = parameters.subtitle or ""
        parameters.namespace = parameters.namespace or "hnm_component_details"

        if self.menus.componentDetailsMenu == nil then
            self.menus.componentDetailsMenu = MenuV:CreateMenu(parameters.title, parameters.subtitle, "default", "menuv", parameters.namespace)
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

        if parameters.componentId == 11 then
            local undershirtCategories = self.dataSource:GetCategories(self.configuration.type, 8)
            local torsoCategories = self.dataSource:GetCategories(self.configuration.type, 3)
            for i=1,#undershirtCategories,1 do
                data.sub[tostring(i)] = {}

                for j=1,#torsoCategories,1 do
                    table.insert(data.sub[tostring(i)], j)
                end
            end
        end

        -- Shop
        self.menus.componentDetailsMenu:AddSlider({
            label= "Magasin",
            values= self.dataSource:GetShops(),
            value= data.shop,
            change= function (element, value) 
                data.shop = value
            end
        })

        -- Shop category
        self.menus.componentDetailsMenu:AddSlider({
            label= "Catégorie en magasin",
            values= self.dataSource:GetShopCategories(parameters.componentId),
            value= data.category,
            change= function (element, value) 
                data.category = value
            end
        })

        -- Variations
        self.menus.componentDetailsMenu:AddButton({
            label= "Variantes",
            select= function() 
                local m = self:GetSwitchableSelectionMenu({
                    title= "Variantes",
                    componentId= parameters.componentId,
                    drawableId= parameters.drawableId,
                    dataCount= textureCount,
                    currentState= 2,
                    navigationMode= 2,
                    GetName= function (index) 
                        local textureId = index - 1
                        return self:GetDrawableName(parameters.componentId, parameters.drawableId, textureId)
                    end,
                    IsChecked= function (index) 
                        local textureId = index - 1
                        return ArrayContains(data.textureIds, textureId) 
                    end,
                    enter= function (index)
                        local textureId = index - 1
                        self:SetPedComponentVariation(self.configuration.target, parameters.componentId, parameters.drawableId, textureId, 0)
                    end,
                    change= function (index, checked) 
                        local textureId = index - 1
                        if checked then
                            if not ArrayContains(data.textureIds, textureId) then
                                table.insert(data.textureIds, textureId)
                            end
                        else
                            if ArrayContains(data.textureIds, textureId) then
                                RemoveTableItem(data.textureIds, textureId)
                            end
                        end
                    end
                })

                m:On("Close", function() 
                    -- Reset to initial textureId
                    self:SetPedComponentVariation(self.configuration.target, parameters.componentId, parameters.drawableId, 0, 0)
                end)

                m:Open()
            end
        })

        if parameters.componentId == 11 then
            -- Undershirt categories
            self.menus.componentDetailsMenu:AddButton({
                label= "Catégories maillots",
                select= function() 
                    self:GetSwitchableSelectionMenu({
                        title= self.dataSource:GetComponents()[8].label,
                        dataCount= #self.dataSource:GetCategories(self.configuration.type, 8),
                        namespace="hnm_subcomponent_selection_8",
                        currentState= 2,
                        navigationMode= 3,
                        GetName= function (index) return self.dataSource:GetCategories(self.configuration.type, 8)[index].label end,
                        IsChecked= function (index) return data.sub[tostring(index)] ~= nil end,
                        enter= function (index) 
                            local drawableId = self.dataSource:GetCategories(self.configuration.type, 8)[index].value
                            self:SetPedComponentVariation(self.configuration.target, 8, drawableId, 0, 0) 
                        end,
                        change= function (index, checked)
                            if checked then
                                data.sub[tostring(index)] = {}
                            else 
                                data.sub[tostring(index)] = nil
                            end
                        end,
                        select= function(selection)
                            local m = self:GetSwitchableSelectionMenu({
                                title= self.dataSource:GetComponents()[3].label,
                                dataCount= #self.dataSource:GetCategories(self.configuration.type, 3),
                                namespace="hnm_subcomponent_selection_3",
                                currentState= 2,
                                navigationMode= 2,
                                GetName= function (index) return self.dataSource:GetCategories(self.configuration.type, 3)[index].label end,
                                IsChecked= function (index) return ArrayContains(data.sub[tostring(selection)], index) end,
                                enter= function (index) 
                                    local drawableId = self.dataSource:GetCategories(self.configuration.type, 3)[index].value
                                    self:SetPedComponentVariation(self.configuration.target, 3, drawableId, 0, 0) 
                                end,
                                change= function (index, checked)
                                    if checked then
                                        if not ArrayContains(data.sub[tostring(selection)], index) then
                                            table.insert(data.sub[tostring(selection)], index)
                                        end
                                    else
                                        if ArrayContains(data.sub[tostring(selection)], index) then
                                            RemoveTableItem(data.sub[tostring(selection)], index)
                                        end
                                    end
                                end,
                            })
                            
                            m:On("Close", function () 
                                self:SetPedComponentVariation(self.configuration.target, 3, 13, 0, 0)
                            end)

                            m:Open()
                        end
                    }):Open()
                end
            })
        end


        self.menus.componentDetailsMenu:AddButton({
            label= "Enregistrer",
            select= function() 
                if self.dataSource:UpdateProduct(data) then
                    notifyStatus("Tenue " .. self:GetDrawableName(parameters.componentId, parameters.drawableId) .. " enregistrée")
                else
                    notifyStatus("Erreur lors de l\'enregistrement")
                end
            end
        })

        self.menus.componentDetailsMenu:On("Open", function () 
            self:SetPedComponentVariation(self.configuration.model, 8, 15, 0, 0)
            self:SetPedComponentVariation(self.configuration.model, 3, 13, 0, 0)
            
            self:SetPedComponentVariation(self.configuration.target, 8, 15, 0, 0)
            self:SetPedComponentVariation(self.configuration.target, 3, 13, 0, 0)
        end)

        return self.menus.componentDetailsMenu
    end

    function HnMMenu:GetSwitchableSelectionMenu(parameters)
        parameters = parameters or {}
        parameters.title = parameters.title or ""
        parameters.subtitle = parameters.subtitle or ""
        parameters.namespace = parameters.namespace or "hnm_subcomponent_selection"

        parameters.GetName = parameters.GetName or function(index) return "res_" end
        parameters.enter = parameters.enter or function(element) end
        parameters.select = parameters.select or function(element, value) end
        parameters.change = parameters.change or function(index, value) end
        parameters.IsChecked = parameters.IsChecked or function(index) return false end
        parameters.IsDisabled = parameters.IsDisabled or function (index) return not parameters.IsChecked end
        parameters.dataCount = parameters.dataCount or 0
        parameters.filter = parameters.filter or function (index) return true end

        parameters.navigationMode = parameters.navigationMode or 1
        parameters.currentState = parameters.currentState or 2


        if self.menus["subcomponentDynamicMenu" .. parameters.namespace] == nil then
            self.menus["subcomponentDynamicMenu" .. parameters.namespace] = MenuV:CreateMenu(parameters.title, parameters.subtitle, "default", "menuv", parameters.namespace)
        else
            self.menus["subcomponentDynamicMenu" .. parameters.namespace]:SetTitle(parameters.title)
            self.menus["subcomponentDynamicMenu" .. parameters.namespace]:SetSubtitle(parameters.subtitle)
        end
        self.menus["subcomponentDynamicMenu" .. parameters.namespace]:ClearItems()

        if parameters.navigationMode == 3 then
            self.menus["subcomponentDynamicMenu" .. parameters.namespace]:AddSlider({
                label= "mode",
                value = parameters.currentState,
                values= { { label= "navigation", value=  1 }, { label= "sélection", value= 2 } },
                change = function (element, mode)
                    parameters.currentState = mode
                    self.menus["subcomponentDynamicMenu" .. parameters.namespace]:Close()
                    self:GetSwitchableSelectionMenu(parameters):Open()
                end
            })
        end

        for j=1,parameters.dataCount,1 do
            if parameters.filter(j) then
                if parameters.currentState == 1 then
                    self.menus["subcomponentDynamicMenu" .. parameters.namespace]:AddButton({
                        label= parameters.GetName(j),
                        disabled= not parameters.IsChecked(j),
                        enter = function () parameters.enter(j) end,
                        select = function () parameters.select(j) end
                    })
                else 
                    self.menus["subcomponentDynamicMenu" .. parameters.namespace]:AddCheckbox({
                        label= parameters.GetName(j),
                        value = parameters.IsChecked(j),
                        disabled= parameters.IsDisabled(j),
                        enter = function () parameters.enter(j) end,
                        change = function (elem, checked) parameters.change(j, checked) end
                    })
                end
            end
        end

        if parameters.save ~= nil then
            self.menus["subcomponentDynamicMenu" .. parameters.namespace]:AddButton({
                label= "Enregistrer",
                select= function() 
                    if parameters.save() then
                        self.menus["subcomponentDynamicMenu" .. parameters.namespace]:Close()
                    end
                end
            })
        end

        return self.menus["subcomponentDynamicMenu" .. parameters.namespace]
    end

    return HnMMenu
end