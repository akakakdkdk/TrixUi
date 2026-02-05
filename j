-- services
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- estado do script
local enabled = false
local running = false

-- Knit
local Knit = RS:WaitForChild("Knit"):WaitForChild("Knit")
local PebbleRE = Knit.Services.PebbleThrowService.RE.Activated
local TodoRE = Knit.Services.TodoService.RE.RightActivated
local BruteRE = Knit.Services.BruteForceService.RE.Activated

-- ==============================
-- FUNÇÃO DO COMBO
-- ==============================
local function startCombo()
	if not enabled then return end
	if running then return end
	running = true

	local char = player.Character
	if not char then running = false return end

	local moveset = char:WaitForChild("Moveset")

	PebbleRE:FireServer(moveset:WaitForChild("Pebble Throw"))
	task.wait(0.72)

	TodoRE:FireServer()
	task.wait(0.35)

	BruteRE:FireServer(moveset:WaitForChild("Brute Force"))
	task.wait(0.67)

	BruteRE:FireServer(moveset:WaitForChild("Brute Force"))

	running = false
end

-- ==============================
-- GUI
-- ==============================
local gui = Instance.new("ScreenGui")
gui.Name = "ComboGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local container = Instance.new("Frame", gui)
container.Size = UDim2.fromOffset(80, 80)
container.Position = UDim2.new(0.85, 0, 0.2, 0)
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.BackgroundTransparency = 1

local button = Instance.new("ImageButton", container)
button.Size = UDim2.fromScale(1, 1)
button.BackgroundTransparency = 1
button.Image = "rbxassetid://121522237638267"
button.ImageTransparency = 0.16
button.AutoButtonColor = false

local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.fromOffset(28, 28)
toggle.Position = UDim2.new(1, -34, 0, 6)
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

-- ==============================
-- TOGGLE ON / OFF
-- ==============================
local function updateToggle()
	if enabled then
		toggle.Text = "🔓"
		toggle.BackgroundColor3 = Color3.fromRGB(30, 70, 30)
	else
		toggle.Text = "🔒"
		toggle.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
	end
end

updateToggle()

toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	updateToggle()
end)

-- ==============================
-- BOTÃO EXECUTA O COMBO
-- ==============================
button.MouseButton1Click:Connect(function()
	if not enabled then return end
	task.spawn(startCombo)
end)
