function isEmpty(str) 
    return str == nil or str == ''
end

function dump(o, ind)
   ind = ind or 0
   local indent = ''
   for i=1,ind do indent = indent .. " " end

   if type(o) == 'table' then
      local s = indent .. '{ '

      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end

         s = s .. '\n' .. indent .. '[' .. k .. ']' ..' = ' .. dump(v, ind + 4) .. ','
      end
      if #o > 0 then
         s = string.sub(s, 1, -1) .. '\n'
      end

      return s .. indent .. '}'
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