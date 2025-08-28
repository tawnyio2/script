--[[
    🎮 ROBLOX HUB SCRIPT - SCRIPT D'APPRENTISSAGE COMPLET
    
    Ce script combine toutes les fonctionnalités en un seul fichier :
    - Mouvement amélioré (vitesse/saut)
    - Interface GUI moderne avec contrôles
    - HUD avec barres de progression
    - Effets visuels et particules
    - Utilitaires et fonctions helper
    
    📋 INSTRUCTIONS D'UTILISATION :
    1. Placez ce script dans StarterPlayerScripts
    2. Lancez le jeu pour voir l'interface
    3. Utilisez les boutons pour activer/désactiver les fonctionnalités
    
    ⚠️  AVERTISSEMENT : À des fins éducatives uniquement
--]]

-- ========================================
-- 🔧 SERVICES ET VARIABLES GLOBALES
-- ========================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Variables de configuration
local CONFIG = {
    -- Paramètres de mouvement
    NORMAL_WALKSPEED = 16,
    ENHANCED_WALKSPEED = 50,
    NORMAL_JUMPPOWER = 50,
    ENHANCED_JUMPPOWER = 120,
    
    -- Paramètres GUI
    GUI_SCALE = 1,
    ANIMATION_SPEED = 0.3,
    
    -- Couleurs du thème
    COLORS = {
        PRIMARY = Color3.fromRGB(64, 128, 255),
        SECONDARY = Color3.fromRGB(45, 45, 45),
        SUCCESS = Color3.fromRGB(76, 175, 80),
        DANGER = Color3.fromRGB(244, 67, 54),
        WARNING = Color3.fromRGB(255, 193, 7),
        BACKGROUND = Color3.fromRGB(30, 30, 30)
    }
}

-- Variables d'état
local gameState = {
    speedEnabled = false,
    jumpEnabled = false,
    flyEnabled = false,
    noClipEnabled = false,
    health = 100,
    energy = 100,
    xp = 0,
    level = 1
}

-- ========================================
-- 🛠️ FONCTIONS UTILITAIRES
-- ========================================

-- Fonction pour créer des animations fluides
local function createTween(object, properties, duration, easingStyle)
    duration = duration or CONFIG.ANIMATION_SPEED
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    
    local tweenInfo = TweenInfo.new(
        duration,
        easingStyle,
        Enum.EasingDirection.Out
    )
    
    return TweenService:Create(object, tweenInfo, properties)
end

-- Fonction pour créer des éléments GUI stylisés
local function createStyledFrame(parent, properties)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = properties.BackgroundColor3 or CONFIG.COLORS.SECONDARY
    frame.BorderSizePixel = 0
    frame.Size = properties.Size or UDim2.new(0, 200, 0, 50)
    frame.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    
    -- Coins arrondis
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Ombre
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = frame
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 2, 0.5, 2)
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(12, 12, 256-12, 256-12)
    shadow.ZIndex = frame.ZIndex - 1
    
    return frame
end

-- Fonction pour créer des boutons interactifs
local function createButton(parent, text, position, size, callback)
    local button = createStyledFrame(parent, {
        Size = size or UDim2.new(0, 150, 0, 40),
        Position = position,
        BackgroundColor3 = CONFIG.COLORS.PRIMARY
    })
    
    local label = Instance.new("TextLabel")
    label.Parent = button
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    
    local clickDetector = Instance.new("TextButton")
    clickDetector.Parent = button
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    
    -- Effets de survol
    clickDetector.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = CONFIG.COLORS.PRIMARY:lerp(Color3.new(1, 1, 1), 0.1)}):Play()
        createTween(button, {Size = (size or UDim2.new(0, 150, 0, 40)) + UDim2.new(0, 4, 0, 2)}):Play()
    end)
    
    clickDetector.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = CONFIG.COLORS.PRIMARY}):Play()
        createTween(button, {Size = size or UDim2.new(0, 150, 0, 40)}):Play()
    end)
    
    -- Effet de clic
    clickDetector.MouseButton1Click:Connect(function()
        createTween(button, {Size = (size or UDim2.new(0, 150, 0, 40)) - UDim2.new(0, 2, 0, 1)}):Play()
        wait(0.1)
        createTween(button, {Size = size or UDim2.new(0, 150, 0, 40)}):Play()
        
        if callback then
            callback()
        end
    end)
    
    return button, clickDetector
end

-- Fonction pour créer des barres de progression
local function createProgressBar(parent, position, size, color, initialValue)
    local background = createStyledFrame(parent, {
        Size = size or UDim2.new(0, 200, 0, 20),
        Position = position,
        BackgroundColor3 = CONFIG.COLORS.BACKGROUND
    })
    
    local fill = createStyledFrame(background, {
        Size = UDim2.new(initialValue or 1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = color or CONFIG.COLORS.SUCCESS
    })
    
    local function updateProgress(value)
        value = math.clamp(value, 0, 1)
        createTween(fill, {Size = UDim2.new(value, 0, 1, 0)}):Play()
    end
    
    return background, updateProgress
end

-- ========================================
-- 🏃 SYSTÈME DE MOUVEMENT AMÉLIORÉ
-- ========================================

local MovementSystem = {}

function MovementSystem.toggleSpeed()
    gameState.speedEnabled = not gameState.speedEnabled
    
    if gameState.speedEnabled then
        humanoid.WalkSpeed = CONFIG.ENHANCED_WALKSPEED
        print("🏃 Vitesse améliorée activée !")
    else
        humanoid.WalkSpeed = CONFIG.NORMAL_WALKSPEED
        print("🚶 Vitesse normale restaurée")
    end
end

function MovementSystem.toggleJump()
    gameState.jumpEnabled = not gameState.jumpEnabled
    
    if gameState.jumpEnabled then
        humanoid.JumpPower = CONFIG.ENHANCED_JUMPPOWER
        print("🦘 Saut amélioré activé !")
    else
        humanoid.JumpPower = CONFIG.NORMAL_JUMPPOWER
        print("👟 Saut normal restauré")
    end
end

function MovementSystem.toggleFly()
    gameState.flyEnabled = not gameState.flyEnabled
    
    if gameState.flyEnabled then
        -- Création du système de vol
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
        bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
        bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
        bodyAngularVelocity.Parent = rootPart
        
        -- Contrôles de vol
        local flyConnection
        flyConnection = RunService.Heartbeat:Connect(function()
            if not gameState.flyEnabled then
                flyConnection:Disconnect()
                if bodyVelocity then bodyVelocity:Destroy() end
                if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
                return
            end
            
            local camera = workspace.CurrentCamera
            local moveVector = humanoid.MoveDirection
            local lookVector = camera.CFrame.LookVector
            local rightVector = camera.CFrame.RightVector
            
            local velocity = Vector3.new(0, 0, 0)
            
            -- Mouvement horizontal
            if moveVector.Magnitude > 0 then
                velocity = velocity + (lookVector * moveVector.Z + rightVector * moveVector.X) * 50
            end
            
            -- Mouvement vertical
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, 50, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity + Vector3.new(0, -50, 0)
            end
            
            bodyVelocity.Velocity = velocity
        end)
        
        print("✈️ Mode vol activé ! Utilisez ESPACE/SHIFT pour monter/descendre")
    else
        print("🚶 Mode vol désactivé")
    end
end

function MovementSystem.toggleNoClip()
    gameState.noClipEnabled = not gameState.noClipEnabled
    
    if gameState.noClipEnabled then
        -- Désactiver les collisions
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        print("👻 NoClip activé !")
    else
        -- Réactiver les collisions
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        print("🧱 NoClip désactivé")
    end
end

-- ========================================
-- 🎨 SYSTÈME D'INTERFACE GRAPHIQUE
-- ========================================

local GUISystem = {}

function GUISystem.createMainGUI()
    -- Création de l'interface principale
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RobloxHubGUI"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    -- Frame principale
    local mainFrame = createStyledFrame(screenGui, {
        Size = UDim2.new(0, 350, 0, 500),
        Position = UDim2.new(0, 20, 0.5, -250),
        BackgroundColor3 = CONFIG.COLORS.BACKGROUND
    })
    
    -- Titre
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = mainFrame
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🎮 ROBLOX HUB"
    titleLabel.TextColor3 = CONFIG.COLORS.PRIMARY
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    
    -- Boutons de fonctionnalités
    local buttonY = 70
    local buttonSpacing = 60
    
    -- Bouton vitesse
    local speedButton = createButton(mainFrame, "🏃 Vitesse Améliorée", 
        UDim2.new(0, 20, 0, buttonY), UDim2.new(0, 310, 0, 45), 
        MovementSystem.toggleSpeed)
    
    -- Bouton saut
    buttonY = buttonY + buttonSpacing
    local jumpButton = createButton(mainFrame, "🦘 Saut Amélioré", 
        UDim2.new(0, 20, 0, buttonY), UDim2.new(0, 310, 0, 45), 
        MovementSystem.toggleJump)
    
    -- Bouton vol
    buttonY = buttonY + buttonSpacing
    local flyButton = createButton(mainFrame, "✈️ Mode Vol", 
        UDim2.new(0, 20, 0, buttonY), UDim2.new(0, 310, 0, 45), 
        MovementSystem.toggleFly)
    
    -- Bouton NoClip
    buttonY = buttonY + buttonSpacing
    local noClipButton = createButton(mainFrame, "👻 NoClip", 
        UDim2.new(0, 20, 0, buttonY), UDim2.new(0, 310, 0, 45), 
        MovementSystem.toggleNoClip)
    
    -- Section des sliders
    buttonY = buttonY + buttonSpacing + 20
    
    -- Slider de vitesse
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Parent = mainFrame
    speedLabel.Size = UDim2.new(1, -40, 0, 25)
    speedLabel.Position = UDim2.new(0, 20, 0, buttonY)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Vitesse: " .. CONFIG.ENHANCED_WALKSPEED
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.TextScaled = true
    speedLabel.Font = Enum.Font.Gotham
    
    -- Bouton pour basculer la visibilité
    local toggleButton = createButton(mainFrame, "➖", 
        UDim2.new(1, -40, 0, 10), UDim2.new(0, 30, 0, 30), 
        function()
            local isVisible = mainFrame.Size.Y.Offset > 100
            if isVisible then
                createTween(mainFrame, {Size = UDim2.new(0, 350, 0, 60)}):Play()
                toggleButton:FindFirstChild("TextLabel").Text = "➕"
            else
                createTween(mainFrame, {Size = UDim2.new(0, 350, 0, 500)}):Play()
                toggleButton:FindFirstChild("TextLabel").Text = "➖"
            end
        end)
    
    return screenGui
end

function GUISystem.createHUD()
    -- Création du HUD
    local hudGui = Instance.new("ScreenGui")
    hudGui.Name = "RobloxHubHUD"
    hudGui.Parent = playerGui
    hudGui.ResetOnSpawn = false
    
    -- Frame du HUD
    local hudFrame = createStyledFrame(hudGui, {
        Size = UDim2.new(0, 300, 0, 120),
        Position = UDim2.new(1, -320, 0, 20),
        BackgroundColor3 = CONFIG.COLORS.BACKGROUND
    })
    
    -- Barre de santé
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Parent = hudFrame
    healthLabel.Size = UDim2.new(1, -20, 0, 20)
    healthLabel.Position = UDim2.new(0, 10, 0, 10)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "❤️ Santé"
    healthLabel.TextColor3 = Color3.new(1, 1, 1)
    healthLabel.TextScaled = true
    healthLabel.Font = Enum.Font.Gotham
    
    local healthBar, updateHealth = createProgressBar(hudFrame, 
        UDim2.new(0, 10, 0, 35), UDim2.new(1, -20, 0, 15), 
        CONFIG.COLORS.DANGER, gameState.health / 100)
    
    -- Barre d'énergie
    local energyLabel = Instance.new("TextLabel")
    energyLabel.Parent = hudFrame
    energyLabel.Size = UDim2.new(1, -20, 0, 20)
    energyLabel.Position = UDim2.new(0, 10, 0, 60)
    energyLabel.BackgroundTransparency = 1
    energyLabel.Text = "⚡ Énergie"
    energyLabel.TextColor3 = Color3.new(1, 1, 1)
    energyLabel.TextScaled = true
    energyLabel.Font = Enum.Font.Gotham
    
    local energyBar, updateEnergy = createProgressBar(hudFrame, 
        UDim2.new(0, 10, 0, 85), UDim2.new(1, -20, 0, 15), 
        CONFIG.COLORS.WARNING, gameState.energy / 100)
    
    -- Mise à jour du HUD
    local function updateHUD()
        updateHealth(gameState.health / 100)
        updateEnergy(gameState.energy / 100)
    end
    
    -- Simulation des changements de stats
    spawn(function()
        while hudGui.Parent do
            wait(2)
            gameState.energy = math.max(0, gameState.energy - math.random(1, 5))
            if gameState.energy <= 0 then
                gameState.energy = 100
            end
            updateHUD()
        end
    end)
    
    return hudGui
end

-- ========================================
-- ✨ SYSTÈME D'EFFETS VISUELS
-- ========================================

local EffectsSystem = {}

function EffectsSystem.createSpeedTrail()
    if not gameState.speedEnabled then return end
    
    local trail = Instance.new("Trail")
    trail.Parent = rootPart
    trail.Color = ColorSequence.new(CONFIG.COLORS.PRIMARY)
    trail.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)}
    trail.Lifetime = 0.5
    trail.MinLength = 0
    trail.FaceCamera = true
    
    -- Attachments pour le trail
    local attachment0 = Instance.new("Attachment")
    attachment0.Parent = rootPart
    attachment0.Position = Vector3.new(-1, -2, 0)
    
    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = rootPart
    attachment1.Position = Vector3.new(1, -2, 0)
    
    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    
    -- Nettoyer après 5 secondes
    game:GetService("Debris"):AddItem(trail, 5)
    game:GetService("Debris"):AddItem(attachment0, 5)
    game:GetService("Debris"):AddItem(attachment1, 5)
end

function EffectsSystem.createJumpEffect()
    if not gameState.jumpEnabled then return end
    
    -- Effet de particules au saut
    local effect = Instance.new("Explosion")
    effect.Parent = workspace
    effect.Position = rootPart.Position - Vector3.new(0, 3, 0)
    effect.BlastRadius = 10
    effect.BlastPressure = 0
    effect.Visible = false
    
    -- Particules personnalisées
    local particles = Instance.new("ParticleEmitter")
    particles.Parent = rootPart
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new(CONFIG.COLORS.SUCCESS)
    particles.Size = NumberSequence.new(0.5)
    particles.Lifetime = NumberRange.new(0.5, 1.0)
    particles.Rate = 50
    particles.SpreadAngle = Vector2.new(45, 45)
    particles.Speed = NumberRange.new(10, 20)
    
    particles:Emit(20)
    
    -- Nettoyer après 2 secondes
    game:GetService("Debris"):AddItem(particles, 2)
end

-- ========================================
-- 🎵 SYSTÈME AUDIO
-- ========================================

local AudioSystem = {}

function AudioSystem.playSound(soundId, volume, pitch)
    local sound = Instance.new("Sound")
    sound.Parent = rootPart
    sound.SoundId = "rbxasset://sounds/" .. soundId
    sound.Volume = volume or 0.5
    sound.Pitch = pitch or 1
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- ========================================
-- 🚀 INITIALISATION PRINCIPALE
-- ========================================

local function initializeHub()
    print("🎮 Initialisation du Roblox Hub...")
    
    -- Attendre que le personnage soit complètement chargé
    if not character or not humanoid or not rootPart then
        player.CharacterAdded:Wait()
        character = player.Character
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
    end
    
    -- Créer les interfaces
    local mainGUI = GUISystem.createMainGUI()
    local hudGUI = GUISystem.createHUD()
    
    -- Connexions d'événements
    humanoid.Jumping:Connect(function()
        EffectsSystem.createJumpEffect()
    end)
    
    -- Connexion pour les effets de vitesse
    local lastPosition = rootPart.Position
    RunService.Heartbeat:Connect(function()
        local currentPosition = rootPart.Position
        local speed = (currentPosition - lastPosition).Magnitude
        
        if speed > 1 and gameState.speedEnabled then
            EffectsSystem.createSpeedTrail()
        end
        
        lastPosition = currentPosition
    end)
    
    -- Raccourcis clavier
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F1 then
            MovementSystem.toggleSpeed()
        elseif input.KeyCode == Enum.KeyCode.F2 then
            MovementSystem.toggleJump()
        elseif input.KeyCode == Enum.KeyCode.F3 then
            MovementSystem.toggleFly()
        elseif input.KeyCode == Enum.KeyCode.F4 then
            MovementSystem.toggleNoClip()
        end
    end)
    
    print("✅ Roblox Hub initialisé avec succès !")
    print("🎯 Raccourcis: F1=Vitesse, F2=Saut, F3=Vol, F4=NoClip")
    
    -- Notification de bienvenue
    local function showWelcomeNotification()
        local notification = createStyledFrame(playerGui, {
            Size = UDim2.new(0, 400, 0, 100),
            Position = UDim2.new(0.5, -200, 0, -100),
            BackgroundColor3 = CONFIG.COLORS.SUCCESS
        })
        
        local welcomeText = Instance.new("TextLabel")
        welcomeText.Parent = notification
        welcomeText.Size = UDim2.new(1, 0, 1, 0)
        welcomeText.BackgroundTransparency = 1
        welcomeText.Text = "🎮 Roblox Hub Chargé !\n🎯 Utilisez F1-F4 ou les boutons GUI"
        welcomeText.TextColor3 = Color3.new(1, 1, 1)
        welcomeText.TextScaled = true
        welcomeText.Font = Enum.Font.GothamBold
        
        -- Animation d'entrée
        createTween(notification, {Position = UDim2.new(0.5, -200, 0, 20)}):Play()
        
        -- Disparition automatique
        wait(3)
        createTween(notification, {
            Position = UDim2.new(0.5, -200, 0, -100),
            BackgroundTransparency = 1
        }):Play()
        
        wait(0.5)
        notification:Destroy()
    end
    
    spawn(showWelcomeNotification)
end

-- ========================================
-- 🎯 GESTION DES ÉVÉNEMENTS
-- ========================================

-- Réinitialiser quand le personnage respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Réinitialiser l'état
    gameState.speedEnabled = false
    gameState.jumpEnabled = false
    gameState.flyEnabled = false
    gameState.noClipEnabled = false
    
    -- Réinitialiser après un court délai
    wait(1)
    initializeHub()
end)

-- ========================================
-- 🚀 LANCEMENT DU SCRIPT
-- ========================================

-- Démarrage du hub
initializeHub()

