function GetDataSource()

    local DataSource = {}

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

    function DataSource:GetCategories(componentId)
        if componentId == 8 then
            return {
                [0] = { name= '0' },
                [1] = { name= '1' },
                [2] = { name= '2' },
                [3] = { name= '3' },
                [4] = { name= '4' },
                [5] = { name= '5' },
                [6] = { name= '6' },
                [7] = { name= '7' },
                [8] = { name= '8' },
                [9] = { name= '9' },
                [10] = { name= '10' },
                [11] = { name= '11' },
                [12] = { name= '12' },
                [13] = { name= '13' },
                [14] = { name= '14' },
                [15] = { name= '15' }
            }
        elseif componentId == 3 then
            return {
                [0] = { name= '0' },
                [1] = { name= '1' },
                [2] = { name= '2' },
                [3] = { name= '3' },
                [4] = { name= '4' },
                [5] = { name= '5' },
                [6] = { name= '6' },
                [7] = { name= '7' },
                [8] = { name= '8' },
                [9] = { name= '9' },
                [10] = { name= '10' },
                [11] = { name= '11' },
                [12] = { name= '12' },
                [13] = { name= '13' },
                [14] = { name= '14' },
                [15] = { name= '15' }
            }
        else
            return {}
        end
    end

    function DataSource:Update(data)
        for i=1,#data.textureIds-1,1 do
            print('{ componentId= '..data.componentId..', \ndrawableId= '..data.drawableId..', \ntextureId= '..data.textureIds[i]..', \nshop= '..data.shop..', \ncategory= '..data.category..', \ndata='..dump(data.sub)..' }')
        end
        --TODO
        return true
    end

    return DataSource
end