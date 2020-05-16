function GetDirectoryFromPath(path)
	return path:match("(.*[/\\])")
end

function ModuleRequire(path,file)
	return require(GetDirectoryFromPath(path) .. file)
end

function math.round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function math.symbolsCount(num)
	return #(string.gsub(tostring(num),"%p+",''))
end

function GetMultipleBountyBonus(hUnit)
	local bonus = 0

	for _,modifier in pairs(hUnit:FindAllModifiers()) do
		if modifier.GetBountyMultiplyBonus then 
			bonus = bonus + modifier:GetBountyMultiplyBonus()
		end 
	end
	return bonus
end 

function table.length(tbl)
	local count = 0 

	for k,v in pairs(tbl) do
		count = count + 1
	end 

	return count
end 

function CDOTA_BaseNPC:FilterModifiers(callback)
	local list = {}
	if not callback then print('[FilterModifiers] Error! Callback not found') return list end
	for k,v in pairs(self:FindAllModifiers()) do
		if callback(v) then 
			table.insert(list,v)
		end 
	end 

	return list
end 

--[[
	ability
	modifier
	duration
	count
	updateStack
	caster
	data
]]
function CDOTA_BaseNPC:AddStackModifier(data)
	data.data = data.data or {}
	data.data.duration = (data.duration or -1)
	if self:HasModifier(data.modifier) then
		local current_stack = self:GetModifierStackCount( data.modifier, data.ability )
		if data.updateStack then
			self:AddNewModifier(data.caster or self, data.ability,data.modifier,data.data)
		end
		self:SetModifierStackCount( data.modifier, data.ability, current_stack + (data.count or 1) )
		if self:GetModifierStackCount( data.modifier, data.ability ) < 1 then
			self:RemoveModifierByName(data.modifier)
		end
	else
		self:AddNewModifier(data.caster or self, data.ability,data.modifier,data.data)
		self:SetModifierStackCount( data.modifier, data.ability, (data.count or 1) )
	end
	return self:GetModifierStackCount( data.modifier, data.ability )
end

function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then return end
  
	done = done or {}
	done[t] = true
	indent = indent or 0
  
	local l = {}
	for k, v in pairs(t) do
	  table.insert(l, k)
	end
  
	table.sort(l)
	for k, v in ipairs(l) do
	  -- Ignore FDesc
	  if v ~= 'FDesc' then
		local value = t[v]
  
		if type(value) == "table" and not done[value] then
		  done [value] = true
		  print(string.rep ("\t", indent)..tostring(v)..":")
		  PrintTable (value, indent + 2, done)
		elseif type(value) == "userdata" and not done[value] then
		  done [value] = true
		  print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
		  PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
		else
		  if t.FDesc and t.FDesc[v] then
			print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
		  else
			print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
		  end
		end
	  end
	end
  end