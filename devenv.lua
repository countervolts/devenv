local DevEnv = {}
local Arguments = {...}

-- utilities

DevEnv.Players = game:GetService('Players')
DevEnv.Workspace = game:GetService('Workspace')
DevEnv.ReplicatedStorage = game:GetService('ReplicatedStorage')
DevEnv.Http = game:GetService('HttpService')
DevEnv.Tween = game:GetService("TweenService")
DevEnv.CoreGui = game:GetService('CoreGui')
DevEnv.Pathfinding = game:GetService('PathfindingService')
DevEnv.RunService = game:GetService('RunService')

-- variables

DevEnv.LocalPlayer = DevEnv.Players.LocalPlayer

-- functions

DevEnv.F = {}
DevEnv.__cache = {}

DevEnv.F.Print = function(self, var)
	print(var)
end

DevEnv.ClearCache = function(self)
	table.clear(DevEnv.__cache)
end

DevEnv.F.Character = function(self)
	return DevEnv.LocalPlayer.Character or DevEnv.LocalPlayer.CharacterAdded:Wait()
end

DevEnv.F.Humanoid = function(self, timeout)
	return DevEnv.F.Character():WaitForChild('Humanoid', (timeout or 2))
end

DevEnv.F.Root = function(self, timeout)
	return DevEnv.F.Character():WaitForChild('HumanoidRootPart', (timeout or 2))
end

DevEnv.F.TweenTo = function(self, cframe, speed)
	local hrp = DevEnv.F:Root()
    
    local goal = {CFrame = cframe}
    local tweeninfo = TweenInfo.new(
    	(cframe.Position - hrp.Position).magnitude/speed,
    	Enum.EasingStyle.Linear,
    	Enum.EasingDirection.In,
    	0,
    	false
    )
    
    local tween = DevEnv.Tween:Create(hrp, tweeninfo, goal)
    tween:Play()
    tween.Completed:Wait()
    
    table.insert(DevEnv.__cache, tweeninfo)
    return tween
end

DevEnv.F.ChangeWalkSpeed = function(self, int)
	DevEnv.F:Humanoid().WalkSpeed = int
end

DevEnv.F.ChangeJumpPower = function(self, int)
	DevEnv.F:Humanoid().JumpPower = int
end

DevEnv.F.GetClosest = function(self, teamcheck, friendcheck)
	local closest, lowest = nil, math.huge
	
	for i,v in pairs(DevEnv.Players:GetPlayers()) do
        if v ~= DevEnv.LocalPlayer then
            local cancontinue = true

            if teamcheck then
                if v.Team == DevEnv.LocalPlayer.Team then
                    cancontinue = false
                end
            end

            if cancontinue then
                local cancontinue = true

                if friendcheck then
                    if v:IsFriendsWith(DevEnv.LocalPlayer.UserId) then
                        cancontinue = false
                    end
                end

                if cancontinue then
                    pcall(function()
                        local character = v.Character
                        local root = character:FindFirstChild('HumanoidRootPart')
                        local humanoid = character:FindFirstChild('Humanoid')
                        if humanoid.Health ~= 0 and humanoid.Health ~= math.huge and not character:FindFirstChildOfClass("ForceField") then
                            local mag = (DevEnv.F:Root().Position - root.Position).magnitude
                            
                            if mag < lowest then
                                lowest = mag
                                closest = v
                            end
                        end
                    end)
                end
            end
        end
	end
	
	return closest
end

DevEnv.F.JsonDecode = function(self, json)
	local json = (json or {})
	local t = DevEnv.Http:JSONDecode(json)
	
	table.insert(DevEnv.__cache, t)
	return t
end

DevEnv.F.JsonEncode = function(self, t)
	local t = (t or {})
	local json = DevEnv.Http:JSONEncode(t)
	
	table.insert(DevEnv.__cache, json)
	return json
end

DevEnv.F.Descendants = function(self, t)
	local descendants = {}
	
	for _, v in pairs(t) do
		local parent = v
		if type(parent) == 'table' then
			table.insert(descendants, tostring(_))
			for iterator, child in pairs(DevEnv.F:Descendants(parent)) do
				table.insert(descendants, child)
			end
		else
			table.insert(descendants, parent)
		end
	end
	
	return descendants
end

DevEnv.F.RandomString = function(self, length, lowercase, uppercase, numbers, specialchars)
	local length = (length and length or 10)
	local lowercase = (lowercase and lowercase or true)
	local uppercase = (uppercase and uppercase or true)
	local numbers = (numbers and numbers or true)
	local specialchars = (specialchars and specialchars or true)
	
	local possiblechars = ''
	local letters = 'abcdefghijklmnopqrstuvwxyz'
	
	if lowercase then
		possiblechars = possiblechars .. letters
	end
	
	if uppercase then
		possiblechars = possiblechars .. letters:upper()
	end
	
	if numbers then
		possiblechars = possiblechars .. '1234567890'
	end
	
	if specialchars then
		possiblechars = possiblechars .. '~`!@#$%^&*()-_=+|{[}]:;"\'<,>.?/'
	end
	
	local finalstring = ''
	for i = 1, length do
		local random = math.random(1,#possiblechars)
		local randomchar = string.sub(possiblechars,random,random)
		finalstring = finalstring .. randomchar
	end
	
	table.insert(DevEnv.__cache, finalstring)
	return finalstring
end

DevEnv.F.GuardedCall = function(self, func, ...)
	if not clonefunction then
		error('Developer Enviroment error: clonefunction not supported')
	end
	
	local cloned = clonefunction(func)
	
	local oldcloned
	oldcloned = hookfunction(cloned,function(...)
		return oldcloned(...)
	end)
	
	local oldcloned
	oldcloned = hookfunction(cloned,newcclosure(function(...)
		return oldcloned(...)
	end))
	
	table.insert(DevEnv.__cache, cloned)
	return cloned(...)
end

DevEnv.F.Compare = function(self, str1, str2)
	local devider = 100/#str1
	local difference = 0
	local iterator = 0
	local shared = {}
	
	for v in str1:gmatch('.') do
		iterator = iterator + 1
		if str2:sub(iterator,iterator) == v then
			difference = difference + devider
			shared[iterator] = {[v] = true}
		else
			shared[iterator] = {[v] = false}
		end
	end
	
	table.insert(DevEnv.__cache, {[1] = difference, [2] = shared})
	return difference, shared
end

DevEnv.F.God = function(self)
	local humanoid, character = DevEnv.F:Humanoid(), DevEnv.F:Character()
	local name = DevEnv.F.RandomString()
	humanoid.Name = name
	
	local cloned = humanoid:Clone()
	cloned.Parent = character
	cloned.Name = 'Humanoid'
	wait()
	character[name]:Destroy()
	DevEnv.Workspace.CurrentCamera.CameraSubject = character:WaitForChild('Humanoid')
	character.Animate.Disabled = true
	wait()
	character.Animate.Disabled = false
end

DevEnv.F.AddFunction = function(self, func, name)
	DevEnv.F[name] = func
end

DevEnv.F.RemoveFunction = function(self, name)
	DevEnv.F[name] = nil
end

-- events

DevEnv.E = {}

function DevEnv.E:CreateEvent()
	local event = {}
	event.connections = {}
	
	function event:Connect(func)
		local connection = coroutine.wrap(func)
		table.insert(event.connections, connection)
		return connection
	end
	
	function event:Fire(...)
		for i = 1, #event.connections do
			event.connections[i](...)
		end
	end
	
	table.insert(DevEnv.__cache, event)
	return event
end

local CacheEvent = DevEnv.E:CreateEvent()
CacheEvent:Connect(function()
	print('There\'s currently ' .. tostring(#DevEnv.F:Descendants(DevEnv.__cache)) .. ' objects in the cache.')
end)

CacheEvent:Connect(function()
	table.foreach(DevEnv.F:Descendants(DevEnv.__cache), function(i, v)
		if type(v) == 'function' then
			print(i, getinfo(v).name, type(v))
		else
			print(i, tostring(v), type(v))
		end
	end)
end)

CacheEvent:Connect(function()
	print('Clearing cache..')
end)

CacheEvent:Connect(DevEnv.ClearCache)

CacheEvent:Connect(function()
	print('Now there\'s currently ' .. tostring(#DevEnv.__cache) .. ' objects in the cache.')
end)

if Arguments[1]['cache-event'] then
	CacheEvent:Fire()
end

return DevEnv
