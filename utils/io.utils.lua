function LoadObjectFromJSONFile(filename)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), filename)
    return json.decode(loadFile)
end

function SaveJSONFileFromData(filename, data) 
    local json = json.encode(data)
    return SaveResourceFile(GetCurrentResourceName(), filename, json, -1)
end