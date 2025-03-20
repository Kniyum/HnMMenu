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

    function DataSource:GetCategories(componentId)
        if componentId == 8 then
            return {
                [1] = { name= '0', value=0 },
                [2] = { name= '1', value=1 },
                [3] = { name= '2', value=2 },
                [4] = { name= '3', value=3 },
                [5] = { name= '4', value=4 },
                [6] = { name= '5', value=5 },
                [7] = { name= '6', value=6 },
                [8] = { name= '7', value=7 },
                [9] = { name= '8', value=8 },
                [10] = { name= '9', value=9 },
                [11] = { name= '10', value=10 },
                [12] = { name= '11', value=11 },
                [13] = { name= '12', value=12 },
                [14] = { name= '13', value=13 },
                [15] = { name= '14', value=14 },
                [16] = { name= '15', value=15 }
            }
        elseif componentId == 3 then
            return {
                [1] = { name= 'Col ouvert + manche courte', value=0 },
                [2] = { name= 'Col ouvert + main', value=1 },
                [3] = { name= 'Col v + Sans manche', value=2 },
                [4] = { name= 'Rieng', value=3 },
                [5] = { name= 'Col serré + main', value=4 },
                [6] = { name= 'Bras + torse', value=5 },
                [7] = { name= 'Col V + mains', value=6 },
                [8] = { name= 'Rieng', value=7 },
                [9] = { name= 'Col serré - avant bras', value=8 },
                [10] = { name= 'Rieng', value=9 },
                [11] = { name= 'Rieng', value=10 },
                [12] = { name= 'Col V + manche courte', value=11 },
                [13] = { name= 'Col ouvert + mains', value=12 },
                [14] = { name= 'Col normal - sans main', value=13 },
                [15] = { name= 'Chemise ouverte + mains', value=14 },
                [16] = { name= 'Tout nu', value=15 }
            }
        else
            return {}
        end
    end

    function DataSource:Update(data)
        for i=1,#data.textureIds,1 do
            print('{ componentId= '..data.componentId..', \ndrawableId= '..data.drawableId..', \ntextureId= '..data.textureIds[i]..', \nshop= '..data.shop..', \ncategory= '..data.category..', \ndata='..dump(data.sub)..' }')
        end
        --TODO
        return true
    end

    return DataSource
end