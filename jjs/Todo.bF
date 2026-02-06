-- 1. Limpeza de scripts antigos (Evita que o combo rode duplicado ao atualizar)
getgenv().ComboMonitorAtivo = false -- Desliga qualquer versão anterior rodando na memória
task.wait(0.1) 

-- 2. Configuração da Toggle Principal
-- Mude para 'false' para desativar ou 'true' para ativar
getgenv().ComboEnabled = true 

-- 3. Variável de controle interna para o monitor
getgenv().ComboMonitorAtivo = true

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local LocalPlayer = game:GetService('Players').LocalPlayer

local function ExecutarComboSequencial()
    -- Checa se a toggle está ligada antes de começar
    if not getgenv().ComboEnabled then return end

    local character = LocalPlayer.Character
    if not character then return end
    local moveset = character:WaitForChild('Moveset', 5)
    if not moveset then return end

    print("--- Combo Iniciado ---")

    -- PASSO 1: Espera o Pebble (O gatilho já aconteceu, então esperamos o tempo dele)
    task.wait(0.72)
    if not getgenv().ComboEnabled then return end -- Check de segurança

    -- PASSO 2: Todo Right
    local todoRemote = ReplicatedStorage:WaitForChild('Knit'):WaitForChild('Knit'):WaitForChild('Services'):WaitForChild('TodoService'):WaitForChild('RE'):WaitForChild('RightActivated')
    todoRemote:FireServer()
    print("Executado: Todo Right")

    task.wait(0.35)
    if not getgenv().ComboEnabled then return end -- Check de segurança

    -- PASSO 3: Brute Force 1
    local bruteRemote = ReplicatedStorage:WaitForChild('Knit'):WaitForChild('Knit'):WaitForChild('Services'):WaitForChild('BruteForceService'):WaitForChild('RE'):WaitForChild('Activated')
    bruteRemote:FireServer(moveset:WaitForChild('Brute Force'))
    print("Executado: Brute Force 1")

    task.wait(0.67)
    if not getgenv().ComboEnabled then return end -- Check de segurança

    -- PASSO 4: Brute Force 2
    bruteRemote:FireServer(moveset:WaitForChild('Brute Force'))
    print("Executado: Brute Force 2")

    print("--- Combo Finalizado ---")
end

-- 4. O GATILHO (Monitorando o Pebble Throw)
local pebbleRemote = ReplicatedStorage:WaitForChild('Knit'):WaitForChild('Knit'):WaitForChild('Services'):WaitForChild('PebbleThrowService'):WaitForChild('RE'):WaitForChild('Activated')

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    -- Se o script foi "descarregado" ou a toggle desligada, não faz nada
    if not getgenv().ComboMonitorAtivo or not getgenv().ComboEnabled then
        return oldNamecall(self, ...)
    end

    if self == pebbleRemote and method == "FireServer" then
        task.spawn(ExecutarComboSequencial)
    end

    return oldNamecall(self, ...)
end)

print("Monitor de Combo carregado com sucesso!")
