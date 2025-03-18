function notifyAction(message) 
    BeginTextCommandDisplayHelp("STRING");
    AddTextComponentSubstringPlayerName(message);
    EndTextCommandDisplayHelp(0, false, false, 6000);
end

function notifyStatus(message) 
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(true, false)
end