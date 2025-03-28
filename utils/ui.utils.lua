function NotifyAction(message) 
    BeginTextCommandDisplayHelp("STRING");
    AddTextComponentSubstringPlayerName(message);
    EndTextCommandDisplayHelp(0, false, false, 6000);
end

function NotifyStatus(message) 
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(true, false)
end