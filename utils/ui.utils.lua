function notifyAction(message) 
    BeginTextCommandDisplayHelp("STRING");
    AddTextComponentSubstringPlayerName(message);
    EndTextCommandDisplayHelp(0, false, false, 6000);
end