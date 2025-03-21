function isEmpty(str) 
    return str == nil or str == ''
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s ..k..' = ' .. dump(v) .. ', '
       end
       s = string.sub(s, 1, -3)
       return string.sub(s .. '} \n', 1, -3)
    else
       return tostring(o)
    end
end

function keyExist(o, key) 
   for k,v in pairs(o) do
      if tostring(k) == tostring(key) then
         return true
      end
   end
   return false
end

 function removeTableItem(array, item)
   local cursor = -1
   for i=1,#array,1 do 
      if array[i] == item then
         cursor = i
         break
      end
   end

   if cursor > -1 then
      table.remove(array, cursor)
   end
 end

 function arrayContains(tab, val)
   for index, value in ipairs(tab) do
       if value == val then
           return true
       end
   end

   return false
end