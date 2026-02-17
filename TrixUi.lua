local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ============ AUTO BUILDER DEPENDENCIES ============
local _ReplicatedStorage = game:GetService('ReplicatedStorage')
local _RunService = game:GetService('RunService')
local _CoreGui = game:GetService('CoreGui')
local _HttpService = game:GetService('HttpService')

local Library = {
    Icons = {},
    Themes = {
        ["Dark"]     = {Main = Color3.fromRGB(18, 18, 18), Accent = Color3.fromRGB(255, 255, 255), Outline = Color3.fromRGB(40, 40, 40), Text = Color3.fromRGB(230, 230, 230), Secondary = Color3.fromRGB(30, 30, 30)},
        ["Light"]    = {Main = Color3.fromRGB(240, 240, 240), Accent = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(200, 200, 200), Text = Color3.fromRGB(40, 40, 40), Secondary = Color3.fromRGB(220, 220, 220)},
        ["Nebula"]   = {Main = Color3.fromRGB(15, 10, 25), Accent = Color3.fromRGB(150, 50, 255), Outline = Color3.fromRGB(45, 30, 70), Text = Color3.fromRGB(240, 240, 240), Secondary = Color3.fromRGB(25, 20, 45)},
        ["Obsidian"] = {Main = Color3.fromRGB(10, 10, 10), Accent = Color3.fromRGB(120, 120, 120), Outline = Color3.fromRGB(30, 30, 30), Text = Color3.fromRGB(200, 200, 200), Secondary = Color3.fromRGB(20, 20, 20)},
        ["Aurora"]   = {Main = Color3.fromRGB(10, 25, 20), Accent = Color3.fromRGB(0, 255, 150), Outline = Color3.fromRGB(30, 60, 50), Text = Color3.fromRGB(230, 255, 240), Secondary = Color3.fromRGB(15, 40, 35)},
        ["Eclipse"]  = {Main = Color3.fromRGB(15, 15, 20), Accent = Color3.fromRGB(255, 100, 0), Outline = Color3.fromRGB(40, 30, 30), Text = Color3.fromRGB(255, 230, 230), Secondary = Color3.fromRGB(25, 20, 20)},
        ["Carbon"]   = {Main = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(200, 0, 0), Outline = Color3.fromRGB(50, 50, 50), Text = Color3.fromRGB(220, 220, 220), Secondary = Color3.fromRGB(35, 35, 35)},
        ["Ember"]    = {Main = Color3.fromRGB(25, 15, 10), Accent = Color3.fromRGB(255, 120, 0), Outline = Color3.fromRGB(60, 30, 10), Text = Color3.fromRGB(255, 240, 230), Secondary = Color3.fromRGB(40, 25, 15)},
        ["Glacier"]  = {Main = Color3.fromRGB(15, 20, 30), Accent = Color3.fromRGB(0, 200, 255), Outline = Color3.fromRGB(40, 60, 80), Text = Color3.fromRGB(230, 245, 255), Secondary = Color3.fromRGB(25, 35, 50)},
        ["Volt"]     = {Main = Color3.fromRGB(15, 15, 10), Accent = Color3.fromRGB(220, 255, 0), Outline = Color3.fromRGB(50, 50, 20), Text = Color3.fromRGB(245, 255, 220), Secondary = Color3.fromRGB(25, 25, 15)},
        ["Nova"]     = {Main = Color3.fromRGB(20, 10, 30), Accent = Color3.fromRGB(255, 0, 200), Outline = Color3.fromRGB(60, 20, 80), Text = Color3.fromRGB(255, 230, 250), Secondary = Color3.fromRGB(35, 15, 50)},
        ["Aether"]   = {Main = Color3.fromRGB(10, 10, 25), Accent = Color3.fromRGB(0, 255, 255), Outline = Color3.fromRGB(30, 30, 70), Text = Color3.fromRGB(220, 255, 255), Secondary = Color3.fromRGB(20, 20, 45)}
    },
    CurrentTheme = nil,
    -- ============ AUTO BUILDER DATA ============
    AutoBuilder = {
        Settings = {
            BuildDelay = 0.02,
            BuildRotation = 0,
            BuildOffset = Vector3.new(0, 0, -25),
            BuildMode = 'Player',
            StealMode = 'All',
        },
        State = {
            isBuilding = false,
            isPaused = false,
            stopRequested = false,
            currentSourceModel = nil,
            builtParts = {},
        },
        Remotes = {
            BuildEvent = nil,
            Buildable = nil,
            Logic = nil,
        }
    }
}

Library.CurrentTheme = Library.Themes["Dark"]

-- ============ ICONS (OPCIONAL) ============
local iconSuccess, iconData = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/deedlemcdoodledeedlemcdoodle-creator/SpectravaxHub/main/everylucideassetin.lua"))()
end)
if iconSuccess and type(iconData) == "table" then Library.Icons = iconData end

function Library:SetTheme(name)
    if Library.Themes[name] then
        Library.CurrentTheme = Library.Themes[name]
    end
end

-- ============ AUTO BUILDER CORE FUNCTIONS ============

-- Inicializa os remotes do jogo
function Library:InitRemotes()
    local function SafeWaitForChild(parent, childName, timeout)
        timeout = timeout or 3
        local startTime = tick()
        while tick() - startTime < timeout do
            local child = parent:FindFirstChild(childName)
            if child then return child end
            task.wait(0.1)
        end
        return nil
    end

    pcall(function()
        local remotesFolder = _ReplicatedStorage:FindFirstChild('Remotes')
        if remotesFolder then
            Library.AutoBuilder.Remotes.BuildEvent = SafeWaitForChild(remotesFolder, 'BuildEvent', 2)
        end

        local mapFolder = workspace:FindFirstChild('Map')
        if mapFolder then
            local destructible = mapFolder:FindFirstChild('Destructible')
            if destructible then
                Library.AutoBuilder.Remotes.Buildable = SafeWaitForChild(destructible, 'Buildable', 2)
            end
        end

        Library.AutoBuilder.Remotes.Logic = workspace:FindFirstChild('Logic')
    end)
end

-- Wait functions
function Library:waitForNewPart(timeout)
    timeout = timeout or 4
    local newPart = nil
    local u12 = Library.AutoBuilder.Remotes.Buildable
    if not u12 then return nil end

    for _, part in ipairs(u12:GetDescendants()) do
        if part:IsA('BasePart') and not table.find(Library.AutoBuilder.State.builtParts, part) then
            if (tick() - (part:GetAttribute('CreationTime') or 0)) < 2 then
                return part
            end
        end
    end

    local conn = u12.DescendantAdded:Connect(function(p)
        if p:IsA('BasePart') and not table.find(Library.AutoBuilder.State.builtParts, p) then
            newPart = p
            p:SetAttribute('CreationTime', tick())
        end
    end)

    local start = tick()
    while not newPart and tick() - start < timeout do
        task.wait(0.1)
    end
    conn:Disconnect()
    return newPart
end

function Library:waitForNewLogicPart(timeout)
    timeout = timeout or 4
    local newPart = nil
    local u13 = Library.AutoBuilder.Remotes.Logic
    if not u13 then return nil end

    for _, part in ipairs(u13:GetDescendants()) do
        if part:IsA('BasePart') and not table.find(Library.AutoBuilder.State.builtParts, part) then
            if (tick() - (part:GetAttribute('CreationTime') or 0)) < 2 then
                return part
            end
        end
    end

    local conn = u13.DescendantAdded:Connect(function(p)
        if p:IsA('BasePart') and not table.find(Library.AutoBuilder.State.builtParts, p) then
            newPart = p
            p:SetAttribute('CreationTime', tick())
        end
    end)

    local start = tick()
    while not newPart and tick() - start < timeout do
        task.wait(0.1)
    end
    conn:Disconnect()
    return newPart
end

-- Steal Build
function Library:StealBuild()
    if not writefile then return "writefile is not supported" end
    self:InitRemotes()

    local todasParts = {}
    local dadosSalvos = { Parts = {}, LogicParts = {} }

    local logicTypes = {
        Moveset=true, Relay=true, Touch=true, Sound=true, Jeep=true, Team=true, Move=true,
        Dummy=true, NPC=true, Damage=true, Boost=true, MovesetClear=true, Item=true,
        Awakening=true, Accessory=true, Special=true, And=true, Light=true, Not=true,
        Timer=true, XOR=true, Prompt=true, Connect=true, Image=true, Texture=true,
        Camera=true, Character=true, Gate=true, Trigger=true, Switch=true, Teleport=true
    }

    local buildable = workspace.Map and workspace.Map:FindFirstChild('Destructible')
    if buildable then
        buildable = buildable:FindFirstChild('Buildable')
        if buildable then
            for _, obj in ipairs(buildable:GetDescendants()) do
                if obj:IsA('BasePart') then table.insert(todasParts, obj) end
            end
        end
    end

    if Library.AutoBuilder.Settings.StealMode == 'All' then
        local logic = workspace:FindFirstChild('Logic')
        if logic then
            for _, obj in ipairs(logic:GetDescendants()) do
                if obj:IsA('BasePart') then table.insert(todasParts, obj) end
            end
        end
    end

    for i, part in ipairs(todasParts) do
        local isLogic = logicTypes[part.Name] or (Library.AutoBuilder.Settings.StealMode == 'All' and workspace:FindFirstChild('Logic') and part:IsDescendantOf(workspace.Logic))

        local dados = {
            ClassName = part.ClassName,
            CFrame = {part.CFrame:GetComponents()},
            Size = {part.Size.X, part.Size.Y, part.Size.Z},
            Color = {part.Color.R, part.Color.G, part.Color.B},
            Material = part.Material.Name,
            Transparency = part.Transparency,
            Name = part.Name,
        }

        if isLogic then
            local inputsArg3 = part:GetAttribute('Inputs_Arg3')
            if inputsArg3 then dados.Inputs_Arg3 = inputsArg3 end

            local inputsArg4 = part:GetAttribute('Inputs_Arg4')
            if inputsArg4 then dados.Inputs_Arg4 = inputsArg4 end

            local accessoryId = part:GetAttribute('AccessoryId')
            if accessoryId then dados.AccessoryId = accessoryId end

            local moveName = part:GetAttribute('MoveName')
            if moveName then dados.MoveName = moveName end

            local moveNameFt = part:GetAttribute('MoveNameFt')
            if moveNameFt then dados.MoveNameFt = moveNameFt end

            local dict = part:GetAttribute('Dict')
            if dict then dados.Dict = dict end

            local imageAttr = part:GetAttribute('Image')
            if imageAttr then
                dados.Image = (type(imageAttr) == 'string' and imageAttr:match("%d+")) and tonumber(imageAttr:match("%d+")) or imageAttr
            end

            local damage = part:GetAttribute('Damage')
            if damage then dados.Damage = tonumber(damage) or damage end

            local destAttr = part:GetAttribute('Destination')
            if destAttr then dados.Destination = {destAttr:GetComponents()} end

            local filhos = {}
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA('StringValue') or child:IsA('NumberValue') or child:IsA('BoolValue') or child:IsA('ObjectValue') then
                    filhos[child.Name] = child.Value
                end
            end
            if next(filhos) then dados.Filhos = filhos end

            table.insert(dadosSalvos.LogicParts, dados)
        else
            table.insert(dadosSalvos.Parts, dados)
        end
    end

    local success, jsonData = pcall(_HttpService.JSONEncode, _HttpService, dadosSalvos)
    if success then
        local modo = Library.AutoBuilder.Settings.StealMode == 'All' and 'Completo' or 'Apenas_Mapa'
        local fileName = ('Build_%s_%s.txt'):format(modo .. '_' .. os.date('%Y_%m_%d_%H%M%S'), (_HttpService:GenerateGUID(true):gsub('-', ''):sub(1, 8)))
        local writeSuccess, err = pcall(writefile, fileName, jsonData)
        if writeSuccess then
            return "✅ Build salvo: " .. fileName
        else
            return "❌ Erro ao salvar arquivo: " .. tostring(err)
        end
    else
        return "❌ Erro ao codificar dados"
    end
end

-- Load From File
function Library:LoadFromFile(filename)
    if not readfile then return "readfile não suportado" end
    self:InitRemotes()

    local filePath = filename
    if not filePath:match('%.json$') and not filePath:match('%.txt$') then
        filePath = filename .. '.txt'
    end

    local readSuccess, fileContent = pcall(readfile, filePath)
    if readSuccess and fileContent and fileContent ~= '' then
        local decodeSuccess, data = pcall(_HttpService.JSONDecode, _HttpService, fileContent)
        if decodeSuccess and typeof(data) == 'table' then
            if Library.AutoBuilder.State.currentSourceModel then
                Library.AutoBuilder.State.currentSourceModel:Destroy()
            end

            local model = Instance.new('Model')
            model.Name = filename:gsub('%.txt$', ''):gsub('%.json$', '')

            if data.Parts then
                for _, partData in ipairs(data.Parts) do
                    local part = Instance.new(partData.ClassName or 'Part')
                    part.Size = Vector3.new(unpack(partData.Size))
                    part.Color = Color3.new(unpack(partData.Color))
                    part.Material = Enum.Material[partData.Material]
                    part.Transparency = partData.Transparency or 0
                    part.CFrame = CFrame.new(unpack(partData.CFrame))
                    part.Anchored = true
                    part.Parent = model
                end
            end

            if data.LogicParts then
                for _, partData in ipairs(data.LogicParts) do
                    local part = Instance.new(partData.ClassName or 'Part')
                    part.Name = partData.Name or 'Logic'
                    part.Size = Vector3.new(unpack(partData.Size))
                    part.Color = Color3.new(unpack(partData.Color))
                    part.Material = Enum.Material[partData.Material]
                    part.Transparency = partData.Transparency or 0
                    part.CFrame = CFrame.new(unpack(partData.CFrame))
                    part.Anchored = true
                    part.Parent = model

                    if partData.MoveName then part:SetAttribute('MoveName', partData.MoveName) end
                    if partData.MoveNameFt then part:SetAttribute('MoveNameFt', partData.MoveNameFt) end
                    if partData.Dict then part:SetAttribute('Dict', partData.Dict) end
                    if partData.Image then part:SetAttribute('Image', partData.Image) end
                    if partData.Damage then part:SetAttribute('Damage', partData.Damage) end
                    if partData.Destination then
                        local cf = CFrame.new(unpack(partData.Destination))
                        part:SetAttribute('Destination', cf)
                    end
                    if partData.Inputs_Arg3 then part:SetAttribute('Inputs_Arg3', partData.Inputs_Arg3) end
                    if partData.Inputs_Arg4 then part:SetAttribute('Inputs_Arg4', partData.Inputs_Arg4) end
                    if partData.AccessoryId then part:SetAttribute('AccessoryId', partData.AccessoryId) end

                    if partData.Filhos then
                        for nome, valor in pairs(partData.Filhos) do
                            local child = Instance.new('StringValue')
                            child.Name = nome
                            child.Value = tostring(valor)
                            child.Parent = part
                        end
                    end
                end
            end

            model.PrimaryPart = model:FindFirstChildOfClass('BasePart')
            model.Parent = _CoreGui
            Library.AutoBuilder.State.currentSourceModel = model
            return "✅ Modelo carregado: " .. model.Name
        else
            return "❌ Formato de arquivo inválido"
        end
    else
        return "❌ Não foi possível ler o arquivo"
    end
end

-- Build Model
function Library:BuildModel()
    local state = Library.AutoBuilder.State
    local settings = Library.AutoBuilder.Settings
    local remotes = Library.AutoBuilder.Remotes

    if state.isBuilding or not (state.currentSourceModel and remotes.BuildEvent) then
        return "Nenhum modelo carregado ou já construindo"
    end

    self:InitRemotes()
    state.isBuilding = true
    state.stopRequested = false

    local playerRoot = Library:GetPlayerRoot()
    local sourceModel = state.currentSourceModel

    if settings.BuildMode == 'Player' and not playerRoot then
        state.isBuilding = false
        return "Raiz do jogador não encontrada"
    end

    local logicTypes = {
        Moveset=true, Relay=true, Touch=true, Sound=true, Jeep=true, Team=true, Move=true,
        Dummy=true, NPC=true, Damage=true, Boost=true, MovesetClear=true, Item=true,
        Awakening=true, Accessory=true, Special=true, And=true, Light=true, Not=true,
        Timer=true, XOR=true, Prompt=true, Connect=true, Image=true, Texture=true,
        Camera=true, Character=true, Gate=true, Trigger=true, Switch=true, Teleport=true
    }

    local normalParts = {}
    local logicParts = {}

    for _, obj in ipairs(sourceModel:GetDescendants()) do
        if obj:IsA('BasePart') then
            if logicTypes[obj.Name] then
                table.insert(logicParts, {part = obj, tipo = obj.Name})
            else
                table.insert(normalParts, obj)
            end
        end
    end

    local total = #normalParts + #logicParts
    if total == 0 then
        state.isBuilding = false
        return "Nenhuma parte para construir"
    end

    local origin, pivot
    if settings.BuildMode == 'Player' then
        if not sourceModel.PrimaryPart then
            sourceModel.PrimaryPart = sourceModel:FindFirstChildOfClass('BasePart')
        end
        pivot = sourceModel:GetPivot()
        if not pivot then
            state.isBuilding = false
            return "Pivô do modelo inválido"
        end
        local rot = CFrame.Angles(0, math.rad(settings.BuildRotation), 0)
        local offset = CFrame.new(settings.BuildOffset)
        origin = playerRoot.CFrame * rot * offset
    else
        origin = CFrame.new(0, 0, 0)
    end

    table.clear(state.builtParts)
    local index = 0
    local failedParts = {}

    for i, part in ipairs(normalParts) do
        if state.stopRequested then break end
        while state.isPaused do task.wait() end
        index = index + 1

        local cf = settings.BuildMode == 'Player' and origin * pivot:ToObjectSpace(part.CFrame) or part.CFrame
        local partType = 'Part'
        if part:IsA('WedgePart') then partType = 'Wedge'
        elseif part:IsA('TrussPart') then partType = 'Truss' end

        local newPart = nil
        local attempts = 0
        while not newPart and attempts < 3 and not state.stopRequested do
            attempts = attempts + 1
            remotes.BuildEvent:FireServer('Create', partType, cf.Position)

            local waitTime = attempts == 1 and 2.5 or (attempts == 2 and 3.0 or 4.0)
            newPart = self:waitForNewPart(waitTime)

            if newPart then
                remotes.BuildEvent:FireServer('Move', {{newPart, cf, part.Size}})
                remotes.BuildEvent:FireServer('Color', {newPart}, part.Color)
                remotes.BuildEvent:FireServer('Material', {newPart}, part.Material.Name)
                remotes.BuildEvent:FireServer('Transparency', {newPart}, tostring(part.Transparency))
                table.insert(state.builtParts, newPart)
            elseif attempts < 3 then
                task.wait(0.3)
            end
        end

        if not newPart then
            table.insert(failedParts, {
                tipo = partType, cframe = cf, tamanho = part.Size,
                cor = part.Color, material = part.Material.Name, transparencia = part.Transparency
            })
        end

        if settings.BuildDelay > 0 then task.wait(settings.BuildDelay) end
    end

    for i, partData in ipairs(logicParts) do
        if state.stopRequested then break end
        while state.isPaused do task.wait() end
        index = index + 1

        local part = partData.part
        local logicType = partData.tipo
        local cf = settings.BuildMode == 'Player' and origin * pivot:ToObjectSpace(part.CFrame) or part.CFrame

        local newPart = nil
        local attempts = 0
        while not newPart and attempts < 3 and not state.stopRequested do
            attempts = attempts + 1
            remotes.BuildEvent:FireServer('Create', logicType, cf.Position)

            local waitTime = attempts == 1 and 2.5 or (attempts == 2 and 3.0 or 4.0)
            newPart = self:waitForNewLogicPart(waitTime)

            if newPart then
                remotes.BuildEvent:FireServer('Move', {{newPart, cf, part.Size}})
                remotes.BuildEvent:FireServer('Color', {newPart}, part.Color)
                remotes.BuildEvent:FireServer('Material', {newPart}, part.Material.Name)
                remotes.BuildEvent:FireServer('Transparency', {newPart}, tostring(part.Transparency))
                table.insert(state.builtParts, newPart)
            elseif attempts < 3 then
                task.wait(0.3)
            end
        end

        if newPart then
            task.wait(0.05)

            if logicType == "Moveset" or logicType == "Special" or logicType == "Awakening" or logicType == "MovesetClear" then
                local id = part:GetAttribute('Inputs_Arg3') or (part:FindFirstChild('Inputs_Arg3') and part.Inputs_Arg3.Value)
                remotes.BuildEvent:FireServer('Inputs', {newPart}, id or '1', '')
            end

            if logicType == "Not" then
                local id = part:GetAttribute('Inputs_Arg4') or (part:FindFirstChild('Inputs_Arg4') and part.Inputs_Arg4.Value)
                remotes.BuildEvent:FireServer('Inputs', {newPart}, '', id or '1')
            end

            if logicType == "Accessory" then
                local id = part:GetAttribute('AccessoryId') or part:GetAttribute('Image') or
                          (part:FindFirstChild('AccessoryId') and part.AccessoryId.Value) or
                          (part:FindFirstChild('Image') and part.Image.Value)
                if id then remotes.BuildEvent:FireServer('LogicProp', {newPart}, 'Acc', id) end
            end

            if logicType == "Moveset" then
                local moveName = part:GetAttribute('MoveName') or (part:FindFirstChild('MoveName') and part.MoveName.Value)
                if moveName then remotes.BuildEvent:FireServer('LogicProp', {newPart}, 'MoveName', moveName) end
                local dict = part:GetAttribute('Dict') or (part:FindFirstChild('Dict') and part.Dict.Value)
                if dict then remotes.BuildEvent:FireServer('LogicProp', {newPart}, 'Dict', dict) end
            end

            if logicType == "Image" or logicType == "Texture" then
                local imageId = part:GetAttribute('Image') or (part:FindFirstChild('Image') and part.Image.Value)
                if imageId then remotes.BuildEvent:FireServer('LogicProp', {newPart}, 'Image', imageId) end
            end

            if logicType == "Damage" then
                local damageVal = part:GetAttribute('Damage') or (part:FindFirstChild('Damage') and part.Damage.Value)
                if damageVal then remotes.BuildEvent:FireServer('LogicProp', {newPart}, 'Damage', tostring(damageVal)) end
            end

            if logicType == "Team" then
                local teamName = part:GetAttribute('MoveNameFt') or (part:FindFirstChild('MoveNameFt') and part.MoveNameFt.Value)
                if teamName then remotes.BuildEvent:FireServer('LogicProp', {newPart}, 'MoveNameFt', teamName) end
            end

            if logicType == "Camera" or logicType == "Teleport" then
                local dest = part:GetAttribute('Destination') or (part:FindFirstChild('Destination') and part.Destination.Value)
                if dest then
                    local destCF = type(dest) == 'CFrame' and dest or CFrame.new(dest)
                    remotes.BuildEvent:FireServer('LogicProp', {newPart}, 'Destination', destCF)
                end
            end
        end

        if settings.BuildDelay > 0 then task.wait(settings.BuildDelay) end
    end

    if #failedParts > 0 and not state.stopRequested then
        task.wait(1.0)
        for _, partInfo in ipairs(failedParts) do
            if state.stopRequested then break end
            remotes.BuildEvent:FireServer('Create', partInfo.tipo, partInfo.cframe.Position)
            local newPart = self:waitForNewPart(3.0)
            if newPart then
                remotes.BuildEvent:FireServer('Move', {{newPart, partInfo.cframe, partInfo.tamanho}})
                remotes.BuildEvent:FireServer('Color', {newPart}, partInfo.cor)
                remotes.BuildEvent:FireServer('Material', {newPart}, partInfo.material)
                remotes.BuildEvent:FireServer('Transparency', {newPart}, tostring(partInfo.transparencia))
                table.insert(state.builtParts, newPart)
            end
            task.wait(0.2)
        end
    end

    state.isBuilding = false
    return "Construção concluída com " .. #failedParts .. " falhas"
end

function Library:PauseBuild()
    Library.AutoBuilder.State.isPaused = not Library.AutoBuilder.State.isPaused
    return Library.AutoBuilder.State.isPaused and "Pausado" or "Continuando"
end

function Library:StopBuild()
    Library.AutoBuilder.State.stopRequested = true
    return "Parada solicitada"
end

function Library:DestroyLastBuild()
    if #Library.AutoBuilder.State.builtParts > 0 and Library.AutoBuilder.Remotes.BuildEvent then
        Library.AutoBuilder.Remotes.BuildEvent:FireServer('Delete', Library.AutoBuilder.State.builtParts)
        table.clear(Library.AutoBuilder.State.builtParts)
        return "Última construção destruída"
    else
        return "Nada para destruir"
    end
end

function Library:GetPlayerRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char and char:FindFirstChild('HumanoidRootPart')
end

-- ============ WINDOW CREATION FUNCTION ============
function Library:CreateWindow(title, iconName)
    local theme = Library.CurrentTheme
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TrixUi_" .. tostring(math.random(1000, 9999))
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = gethui and gethui() or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

    -- Frame principal com bordas mais arredondadas
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 240, 0, 500)
    Main.Position = UDim2.new(0.5, -120, 0.5, -250)
    Main.BackgroundColor3 = theme.Main
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true

    -- Cantos mais arredondados
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = Main

    -- Sombra/Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = theme.Accent
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.5
    Stroke.Parent = Main

    -- Header com gradiente
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = theme.Secondary
    Header.BorderSizePixel = 0

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.Parent = Header

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, iconName and 45 or 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Window"
    Title.TextColor3 = theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15

    if iconName and Library.Icons[iconName] then
        local TitleIcon = Instance.new("ImageLabel", Header)
        TitleIcon.Size = UDim2.new(0, 22, 0, 22)
        TitleIcon.Position = UDim2.new(0, 12, 0.5, -11)
        TitleIcon.BackgroundTransparency = 1
        TitleIcon.Image = Library.Icons[iconName]
        TitleIcon.ImageColor3 = theme.Text
    end

    -- Botão fechar
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
    CloseBtn.BackgroundColor3 = theme.Secondary
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = theme.Text
    CloseBtn.TextSize = 22
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.AutoButtonColor = false

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn

    CloseBtn.Activated:Connect(function() ScreenGui:Destroy() end)

    -- Container principal com padding
    local Container = Instance.new("ScrollingFrame", Main)
    Container.Size = UDim2.new(1, -20, 1, -60)
    Container.Position = UDim2.new(0, 10, 0, 50)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 4
    Container.ScrollBarImageColor3 = theme.Accent
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)

    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0, 10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local Padding = Instance.new("UIPadding", Container)
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.PaddingBottom = UDim.new(0, 5)

    local Elements = {}

    -- Label (seção)
    function Elements:Label(text)
        local Label = Instance.new("TextLabel", Container)
        Label.Size = UDim2.new(1, 0, 0, 24)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = theme.Text
        Label.TextTransparency = 0.3
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
    end

    -- CopyLabel
    function Elements:CopyLabel(text, content)
        local Frame = Instance.new("Frame", Container)
        Frame.Size = UDim2.new(1, 0, 0, 32)
        Frame.BackgroundTransparency = 1

        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(0.65, -5, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Btn = Instance.new("TextButton", Frame)
        Btn.Size = UDim2.new(0.35, -5, 0.8, 0)
        Btn.Position = UDim2.new(0.65, 0, 0.1, 0)
        Btn.BackgroundColor3 = theme.Accent
        Btn.Text = "Copy"
        Btn.TextColor3 = theme.Main
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        Btn.AutoButtonColor = false

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = Btn

        Btn.Activated:Connect(function()
            if setclipboard then
                setclipboard(content or text)
                Btn.Text = "✓"
                task.wait(0.5)
                Btn.Text = "Copy"
            end
        end)
    end

    -- Button
    function Elements:Button(text, iconName, callback)
        local Button = Instance.new("TextButton", Container)
        Button.Size = UDim2.new(1, 0, 0, 38)
        Button.BackgroundColor3 = theme.Secondary
        Button.Text = (iconName and "    " or "") .. text
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.AutoButtonColor = false

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 10)
        BtnCorner.Parent = Button

        if iconName and Library.Icons[iconName] then
            local Icon = Instance.new("ImageLabel", Button)
            Icon.Size = UDim2.new(0, 18, 0, 18)
            Icon.Position = UDim2.new(0, 12, 0.5, -9)
            Icon.BackgroundTransparency = 1
            Icon.Image = Library.Icons[iconName]
            Icon.ImageColor3 = theme.Text
        end

        Button.Activated:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = theme.Accent}):Play()
            TweenService:Create(Button, TweenInfo.new(0.1), {TextColor3 = theme.Main}):Play()
            task.wait(0.1)
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = theme.Secondary}):Play()
            TweenService:Create(Button, TweenInfo.new(0.1), {TextColor3 = theme.Text}):Play()
            if callback then pcall(callback) end
        end)
    end

    -- Slider
    function Elements:Slider(text, min, max, default, callback)
        local defaultVal = math.clamp(default, min, max)
        local SliderFrame = Instance.new("Frame", Container)
        SliderFrame.Size = UDim2.new(1, 0, 0, 45)
        SliderFrame.BackgroundTransparency = 1

        local Label = Instance.new("TextLabel", SliderFrame)
        Label.Text = text
        Label.Size = UDim2.new(1, -50, 0, 20)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local ValLabel = Instance.new("TextLabel", SliderFrame)
        ValLabel.Text = tostring(defaultVal)
        ValLabel.Size = UDim2.new(0, 50, 0, 20)
        ValLabel.Position = UDim2.new(1, -50, 0, 0)
        ValLabel.BackgroundTransparency = 1
        ValLabel.TextColor3 = theme.Accent
        ValLabel.Font = Enum.Font.GothamBold
        ValLabel.TextSize = 12
        ValLabel.TextXAlignment = Enum.TextXAlignment.Right

        local Bar = Instance.new("Frame", SliderFrame)
        Bar.Size = UDim2.new(1, -6, 0, 6)
        Bar.Position = UDim2.new(0, 3, 0, 25)
        Bar.BackgroundColor3 = theme.Secondary

        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = Bar

        local Fill = Instance.new("Frame", Bar)
        Fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = theme.Accent

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill

        local Circle = Instance.new("Frame", Fill)
        Circle.Size = UDim2.new(0, 14, 0, 14)
        Circle.AnchorPoint = Vector2.new(0.5, 0.5)
        Circle.Position = UDim2.new(1, 0, 0.5, 0)
        Circle.BackgroundColor3 = theme.Accent

        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = Circle

        local dragging = false
        local function Update(input)
            local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            local val = min + (max - min) * pos
            if math.abs(val - math.floor(val)) < 0.01 then val = math.floor(val) else val = tonumber(string.format("%.2f", val)) end
            ValLabel.Text = tostring(val)
            if callback then pcall(callback, val) end
        end

        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                Update(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- Dropdown
    function Elements:Dropdown(text, list, callback)
        local DropdownFrame = Instance.new("Frame", Container)
        DropdownFrame.Size = UDim2.new(1, 0, 0, 38)
        DropdownFrame.BackgroundColor3 = theme.Secondary
        DropdownFrame.ClipsDescendants = true

        local DropCorner = Instance.new("UICorner")
        DropCorner.CornerRadius = UDim.new(0, 10)
        DropCorner.Parent = DropdownFrame

        local DropBtn = Instance.new("TextButton", DropdownFrame)
        DropBtn.Size = UDim2.new(1, -16, 1, 0)
        DropBtn.Position = UDim2.new(0, 8, 0, 0)
        DropBtn.BackgroundTransparency = 1
        DropBtn.Text = text .. "  ▼"
        DropBtn.TextColor3 = theme.Text
        DropBtn.Font = Enum.Font.Gotham
        DropBtn.TextSize = 13
        DropBtn.TextXAlignment = Enum.TextXAlignment.Left

        local OptionScroll = Instance.new("ScrollingFrame", DropdownFrame)
        OptionScroll.Size = UDim2.new(1, -10, 0, 140)
        OptionScroll.Position = UDim2.new(0, 5, 0, 38)
        OptionScroll.BackgroundTransparency = 1
        OptionScroll.BorderSizePixel = 0
        OptionScroll.ScrollBarThickness = 4
        OptionScroll.ScrollBarImageColor3 = theme.Accent
        OptionScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        OptionScroll.Visible = false

        local OptionLayout = Instance.new("UIListLayout", OptionScroll)
        OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        OptionLayout.Padding = UDim.new(0, 4)

        local toggled = false
        DropBtn.Activated:Connect(function()
            toggled = not toggled
            OptionScroll.Visible = toggled
            local contentHeight = math.min(#list * 34, 140)
            local goalSize = toggled and UDim2.new(1, 0, 0, 38 + contentHeight) or UDim2.new(1, 0, 0, 38)
            TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = goalSize}):Play()
            DropBtn.Text = toggled and text .. "  ▲" or text .. "  ▼"
        end)

        for i, v in ipairs(list) do
            local Option = Instance.new("TextButton", OptionScroll)
            Option.Size = UDim2.new(1, -4, 0, 30)
            Option.BackgroundColor3 = theme.Main
            Option.BackgroundTransparency = 0.3
            Option.Text = "  " .. v
            Option.TextColor3 = theme.Text
            Option.TextXAlignment = Enum.TextXAlignment.Left
            Option.Font = Enum.Font.Gotham
            Option.TextSize = 12

            local OptionCorner = Instance.new("UICorner")
            OptionCorner.CornerRadius = UDim.new(0, 8)
            OptionCorner.Parent = Option

            Option.Activated:Connect(function()
                toggled = false
                OptionScroll.Visible = false
                TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 38)}):Play()
                DropBtn.Text = text .. "  ▼"
                if callback then pcall(callback, v) end
            end)
        end
    end

    -- StatusLabel
    function Elements:StatusLabel(initialText)
        local Frame = Instance.new("Frame", Container)
        Frame.Size = UDim2.new(1, 0, 0, 38)
        Frame.BackgroundColor3 = theme.Secondary
        Frame.BackgroundTransparency = 0.2

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 10)
        FrameCorner.Parent = Frame

        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(1, -12, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = initialText or "Pronto"
        Label.TextColor3 = theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextWrapped = true

        return Label
    end

    -- TextBox
    function Elements:TextBox(placeholder, callback)
        local Box = Instance.new("TextBox", Container)
        Box.Size = UDim2.new(1, 0, 0, 38)
        Box.BackgroundColor3 = theme.Secondary
        Box.PlaceholderText = placeholder
        Box.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
        Box.Text = ""
        Box.TextColor3 = theme.Text
        Box.Font = Enum.Font.Gotham
        Box.TextSize = 13
        Box.ClearTextOnFocus = false

        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 10)
        BoxCorner.Parent = Box

        Box.FocusLost:Connect(function()
            if callback then pcall(callback, Box.Text) end
        end)

        return Box
    end

    -- ProgressBar
    function Elements:ProgressBar()
        local Frame = Instance.new("Frame", Container)
        Frame.Size = UDim2.new(1, 0, 0, 26)
        Frame.BackgroundColor3 = theme.Secondary

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 8)
        FrameCorner.Parent = Frame

        local Fill = Instance.new("Frame", Frame)
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = theme.Accent

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 8)
        FillCorner.Parent = Fill

        return Fill
    end

    -- ModeSelector
    function Elements:ModeSelector(text, options, defaultOption, callback)
        local Frame = Instance.new("Frame", Container)
        Frame.Size = UDim2.new(1, 0, 0, 38)
        Frame.BackgroundTransparency = 1

        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(0.5, -5, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Button = Instance.new("TextButton", Frame)
        Button.Size = UDim2.new(0.5, -5, 0.8, 0)
        Button.Position = UDim2.new(0.5, 0, 0.1, 0)
        Button.BackgroundColor3 = theme.Secondary
        Button.Text = defaultOption or options[1]
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 12
        Button.AutoButtonColor = false

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 8)
        ButtonCorner.Parent = Button

        Button.Activated:Connect(function()
            local currentIdx = 1
            for i, opt in ipairs(options) do
                if opt == Button.Text then currentIdx = i break end
            end
            local nextIdx = (currentIdx % #options) + 1
            Button.Text = options[nextIdx]
            if callback then pcall(callback, Button.Text) end
        end)

        return Button
    end

    return Elements
end

-- Inicializa os remotes
Library:InitRemotes()

return Library
