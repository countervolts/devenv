local DevEnv = {}
local Arguments = {...}

DevEnv.Players = game:GetService('Players')
DevEnv.Workspace = game:GetService('Workspace')
DevEnv.ReplicatedStorage = game:GetService('ReplicatedStorage')
DevEnv.Http = game:GetService('HttpService')
DevEnv.Tween = game:GetService("TweenService")
DevEnv.Pathfinding = game:GetService('PathfindingService')
DevEnv.RunService = game:GetService('RunService')

DevEnv.LocalPlayer = DevEnv.Players.LocalPlayer

DevEnv.F = {}

DevEnv.F.Character = function(self)
    return DevEnv.LocalPlayer.Character or DevEnv.LocalPlayer.CharacterAdded:Wait()
end

DevEnv.F.Humanoid = function(self, timeout)
    return DevEnv.F.Character():WaitForChild('Humanoid', (timeout or 2))
end

DevEnv.F.Root = function(self, timeout)
    return DevEnv.F.Character():WaitForChild('HumanoidRootPart', (timeout or 2))
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

return DevEnv
