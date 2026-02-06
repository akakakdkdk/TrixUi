-- 1. Controle de Instância (Evita bugs ao atualizar o script)
getgenv().FocusMonitorAtivo = false
task.wait(0.1)

-- 2. Configuração da Toggle (Pode ser alterada pela sua GUI)
getgenv().FocusEnabled = getgenv().FocusEnabled or true 
getgenv().FocusMonitorAtivo = true

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local LocalPlayer = game:GetService('Players').LocalPlayer

-- Função que executa a segunda parte do golpe
local function ExecutarFocusAutomatico(habilidadeObj)
    -- Só continua se a toggle estiver ligada
    if not getgenv().FocusEnabled then return end

    -- O script original espera 0.33 segundos antes do segundo hit
    task.wait(0.33)

    -- Verifica novamente se ainda está ligado após o wait
    if not getgenv().FocusEnabled then return end

    local focusService = ReplicatedStorage:WaitForChild('Knit'):WaitForChild('Knit'):WaitForChild('Services'):WaitForChild('FocusStrikeService'):WaitForChild('RE'):WaitForChild('Activated')
    
    focusService:FireServer(habilidadeObj)
    print("Auto: Segundo Focus Strike disparado!")
end

-- 3. O GATILHO (Hookmetamethod para detectar seu uso manual)
local focusRemote = ReplicatedStorage:WaitForChild('Knit'):WaitForChild('Knit'):WaitForChild('Services'):WaitForChild('FocusStrikeService'):WaitForChild('RE'):WaitForChild('Activated')

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Verifica se o monitor e a toggle estão ativos
    if not getgenv().FocusMonitorAtivo or not getgenv().FocusEnabled then
        return oldNamecall(self, ...)
    end

    -- Se você disparou o Focus Strike manualmente
    if self == focusRemote and method == "FireServer" then
        -- args[1] costuma ser o objeto da habilidade passado no FireServer
        task.spawn(function()
            ExecutarFocusAutomatico(args[1])
        end)
    end

    return oldNamecall(self, ...)
end)

print("Monitor Focus Strike: Ativado e aguardando uso manual.")
