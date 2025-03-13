function LoadObjectFromJSONFile(filename)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), filename)
    return json.decode(loadFile)
end