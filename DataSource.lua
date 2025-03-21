function GetDataSource()

    local DataSource = {
        strings = {},
        categories = {
            male= {},
            female= {}
        }
    }

    setmetatable(DataSource, {__index = function(t,k) return search(k, arg) end})
    DataSource.__index = DataSource

    function DataSource:new(o)
        o = o or {}
        setmetable(o, DataSource)
        return o
    end

    function DataSource:GetShops()
        return { 
            { label= 'Binco', value= 1 }, 
            { label= 'Suburban', value= 2 }, 
            { label= 'Ponsonbys', value= 3 }, 
            { label= 'Masques', value= 4 }, 
            { label= 'Sac', value= 5 }, 
            { label= 'Casino', value= 6 } }
    end

    function DataSource:GetComponents()
        return {
            [11]= { label= 'Haut', value=11 },
            [8]= { label= 'Maillot', value=8 },
            [3]= { label= 'Torse', value=3 },
            [4]= { label= 'Pantalon', value=4 },
            [6]= { label= 'Chaussures', value=6 }
        }
    end

    function DataSource:GetComponent(componentId)
        return self:GetComponents()[componentId]
    end

    function DataSource:GetMainComponents()
        local array = {}
        local main = { 11, 4, 6 }
        for _,key in ipairs(main) do
            table.insert(array, self:GetComponents()[key])
        end
        return array
    end

    function DataSource:GetSubComponents()
        local array = {}
        local main = { 8, 3 }
        for _,key in ipairs(main) do
            table.insert(array, self:GetComponents()[key])
        end
        return array
    end

    function DataSource:GetCollectionableComponents()
        local array = {}
        local main = { 3 }
        for _,key in ipairs(main) do
            table.insert(array, self:GetComponents()[key])
        end
        return array
    end


    function DataSource:GetStringsFilename(type) 
        return 'strings/' .. type .. '.json'
    end

    function DataSource:GetConfiguration(type)
        if self.strings[type] == nil then
            self.strings[type] = LoadObjectFromJSONFile(self:GetStringsFilename(type))
        end

        return self.strings[type]
    end

    function DataSource:GetClothesName(type, componentId, drawableId, textureId)
        local textureId = textureId or 0
        return self:GetConfiguration(type)[componentId .. '_' .. drawableId .. '_' .. textureId]
    end

    function DataSource:GetShopCategories(mainCategory) 
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
                { label='Shorts', value=2 },
                { label='Jupes', value=3 },
                { label='Jeans', value=4 },
                { label='Déguisements', value=5 },
                { label='Intérieur', value=6 },
                { label='Survêtement', value=7 },
                { label='Maillots de bain', value=8 }
            }
        elseif mainCategory == 6 then
            return { 
                { label='Sandales', value=1 },
                { label='Talons', value=2 },
                { label='Bottes/Bottines', value=3 },
                { label='Baskets', value=4 },
                { label='Chaussures plates', value=5 },
                { label='Déguisements', value=6 },
                { label='Hiver', value=7 }
            }
        end
    end

    function DataSource:GetCategories(type, componentId)
        if componentId == 8 then
            if type == 'female' then
                return {
                    [1] = { label= 'ouverte - décolleté', value=0 },
                    [2] = { label= 'semi - décolleté', value=1 },
                    [3] = { label= 'ouverte - grand décolleté', value=4 },
                    [4] = { label= 'semi - grand décolleté', value=5 },
                    [5] = { label= 'ouverte - petit décolleté', value=11 },
                    [6] = { label= 'ouverte - décolleté plongeant', value=12 },
                    [7] = { label= 'ouverte - bustier', value=13 },
                    [8] = { label= 'torse nu', value=15 },
                    [9] = { label= 'fermé - sans manche', value=32 }
                    --[10] = { label= '', value=10 },
                    --[11] = { label= '', value=11 },
                    --[12] = { label= '', value=12 },
                    --[13] = { label= '', value=14 },
                    --[14] = { label= '', value=15 },
                    --[15] = { label= '', value=31 },
                    --[16] = { label= '', value=32 }
                }
            else
                return {
                    [1] = { label= 'ouverte - col fermé', value=0 },
                    [2] = { label= 'ouverte - col v', value=1 },
                    [3] = { label= 'semi - col simple', value=2 },
                    [4] = { label= 'ouverte - col ouvert', value=3 },
                    [5] = { label= 'ouverte - col fermé', value=4 },
                    [6] = { label= 'ouverte - col large', value=5 },
                    [7] = { label= 'veston - col fermé', value=6 },
                    [8] = { label= 'veston - col ouvert', value=7 },
                    [9] = { label= 'ouvert - court - col v', value=9 },
                    [10] = { label= 'ouvert - rentré - col fermé', value=10 },
                    [11] = { label= 'ouvert - rentré - col ouvert', value=11 },
                    [12] = { label= 'ouvert - sorti - col ouvert', value=12 },
                    [13] = { label= 'semi - col v', value=14 },
                    [14] = { label= 'torse nu', value=15 },
                    [15] = { label= 'ouvert - rentré - fermé - manchettes', value=31 },
                    [16] = { label= 'ouvert - rentré - ouvert - manchettes', value=32 }
                }
            end
        elseif componentId == 3 then
            if type == 'female' then
                return {
                    [1] = { label= 'manche courte - col simple', value=0 },
                    [2] = { label= 'manche longue - col simple', value=1 },
                    [3] = { label= 'sans manche - col ouvert', value=2 },
                    [4] = { label= 'manche longue - col serré', value=4 },
                    [5] = { label= 'bras nu - haut torse', value=5 },
                    [6] = { label= 'manche longue - col v', value=6 },
                    [7] = { label= 'manche longue - col serré', value=8 },
                    [8] = { label= 'manche retroussée - col ouvert', value=11 },
                    [9] = { label= 'manche longue - col v', value=12 },
                    [10] = { label= 'manche longue - ouvert', value=14 },
                    [11] = { label= 'torse nu', value=15 }
                }
            else
                return {
                    [1] = { label= 'manche courte - col simple', value=0 },
                    [2] = { label= 'manche longue - col simple', value=1 },
                    [3] = { label= 'sans manche - col ouvert', value=2 },
                    [4] = { label= 'manche longue - col serré', value=4 },
                    [5] = { label= 'bras nu - haut torse', value=5 },
                    [6] = { label= 'manche longue - col v', value=6 },
                    [7] = { label= 'manche longue - col serré', value=8 },
                    [8] = { label= 'manche retroussée - col ouvert', value=11 },
                    [9] = { label= 'manche longue - col v', value=12 },
                    [10] = { label= 'manche longue - ouvert', value=14 },
                    [11] = { label= 'torse nu', value=15 }
                }
            end
        else
            return {}
        end
    end

    function DataSource:UpdateProduct(data)
        for i=1,#data.textureIds,1 do
            print('{ \n    componentId= '..data.componentId..', \n    drawableId= '..data.drawableId..', \n    textureId= '..data.textureIds[i]..', \n    shop= '..data.shop..', \n    category= '..data.category..', \n    data='..dump(data.sub)..' \n}')
        end
        --TODO
        return true
    end

    function DataSource:GetComponentCategories(type, componentId)
        if self.categories[type][tostring(componentId)] == nil then
            self.categories[type][tostring(componentId)] = {}
        end

        return self.categories[type][tostring(componentId)]
    end

    function DataSource:GetCategoryDrawables(type, componentId, categoryId)
        local componentCategories = self:GetComponentCategories(type, componentId)
        if not keyExist(componentCategories, categoryId) then
            self.categories[type][tostring(componentId)][tostring(categoryId)] = {}
        end

        return self.categories[type][tostring(componentId)][tostring(categoryId)]
    end

    function DataSource:UpdateCategory(type, componentId, categoryId, data)
        if not keyExist(self.categories[type], tostring(componentId)) then
            self.categories[type][tostring(componentId)] = {}
        end

        self.categories[type][tostring(componentId)][tostring(categoryId)] = data
        return true
    end

    function DataSource:IsDrawableInOtherCategory(type, componentId, categoryId, drawableId)
        local componentCategories = self:GetComponentCategories(type, componentId)
        for catId, data in pairs(componentCategories) do
            if tostring(catId) ~= tostring(categoryId) then
                if arrayContains(data, drawableId) then
                    return true
                end
            end
        end
        return false
    end

    return DataSource
end