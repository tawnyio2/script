--[[
    📱 ROBLOX HUB SCRIPT - VERSION MOBILE OPTIMISÉE
    
    Version spécialement conçue pour les appareils mobiles avec :
    - Interface tactile optimisée
    - Boutons plus grands (minimum 60px)
    - Disposition responsive
    - Menu hamburger mobile-friendly
    - Boutons flottants pour accès rapide
    - Support orientation portrait/paysage
    
    📋 INSTRUCTIONS D'UTILISATION :
    1. Copiez ce script dans votre exploit mobile
    2. Exécutez le script dans le jeu
    3. Utilisez les contrôles tactiles pour naviguer
    
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
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variables pour le personnage
local character
local humanoid
local rootPart

-- Détection mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = workspace.CurrentCamera.ViewportSize

-- Fonction pour obtenir le personnage de manière sécurisée
local function getCharacter()
    if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
        return player.Character, player.Character.Humanoid, player.Character.HumanoidRootPart
    end
    return nil, nil, nil
end

-- Fonction pour attendre le personnage
local function waitForCharacter()
    local attempts = 0
    local maxAttempts = 100
    
    while attempts < maxAttempts do
        local char, hum, root = getCharacter()
        if char and hum and root then
            print("✅ Personnage trouvé après", attempts, "tentatives")
            return char, hum, root
        end
        
        attempts = attempts + 1
        wait(0.1)
    end
    
    warn("❌ Impossible de trouver le personnage après", maxAttempts, "tentatives")
    return nil, nil, nil
end

-- Initialisation du personnage
print("🔍 Recherche du personnage...")
character, humanoid, rootPart = waitForCharacter()

if not character then
    warn("❌ ERREUR: Personnage non trouvé. Le script ne peut pas continuer.")
    return
end

print("✅ Personnage initialisé avec succès!")
print("📱 Mode mobile détecté:", isMobile)

-- Configuration mobile-optimisée
local CONFIG = {
    -- Paramètres de mouvement
    NORMAL_WALKSPEED = 16,
    ENHANCED_WALKSPEED = 50,
    NORMAL_JUMPPOWER = 50,
    ENHANCED_JUMPPOWER = 120,
    
    -- Paramètres GUI mobile
    MOBILE_BUTTON_SIZE = isMobile and 70 or 50,
    MOBILE_SPACING = isMobile and 15 or 10,
    MOBILE_FONT_SIZE = isMobile and 18 or 14,
    ANIMATION_SPEED = 0.3,
    
    -- Tailles responsives
    GUI_WIDTH = math.min(screenSize.X * 0.9, isMobile and 350 or 400),
    GUI_HEIGHT = math.min(screenSize.Y * 0.8, isMobile and 500 or 600),
    
    -- Couleurs du thème mobile
    COLORS = {
        PRIMARY = Color3.fromRGB(64, 128, 255),
        SECONDARY = Color3.fromRGB(45, 45, 45),
        SUCCESS = Color3.fromRGB(76, 175, 80),
        DANGER = Color3.fromRGB(244, 67, 54),
        WARNING = Color3.fromRGB(255, 193, 7),
        BACKGROUND = Color3.fromRGB(25, 25, 25),
        ACCENT = Color3.fromRGB(255, 255, 255)
    }
}

-- Variables d'état
local gameState = {
    speedEnabled = false,
    jumpEnabled = false,
    flyEnabled = false,
    noClipEnabled = false,
    menuOpen = false,
    health = 100,
    energy = 100
}

-- ========================================
-- 🛠️ FONCTIONS UTILITAIRES MOBILES
-- ========================================

-- Fonction pour créer des animations fluides
local function createTween(object, properties, duration, easingStyle)
    if not object then return end
    
    duration = duration or CONFIG.ANIMATION_SPEED
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    
    local tweenInfo = TweenInfo.new(
        duration,
        easingStyle,
        Enum.EasingDirection.Out
    )
    
    return TweenService:Create(object, tweenInfo, properties)
end

-- Fonction pour créer des éléments GUI mobile-optimisés
local function createMobileFrame(parent, properties)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = properties.BackgroundColor3 or CONFIG.COLORS.SECONDARY
    frame.BorderSizePixel = 0
    frame.Size = properties.Size or UDim2.new(0, 200, 0, CONFIG.MOBILE_BUTTON_SIZE)
    frame.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    
    -- Coins arrondis plus prononcés pour mobile
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, isMobile and 12 or 8)
    corner.Parent = frame
    
    -- Ombre pour meilleure visibilité
    local shadow = Instance.new("ImageLabel")
    shadow.Parent = frame
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 2, 0.5, 2)
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ZIndex = frame.ZIndex - 1
    
    return frame
end

-- Fonction pour créer des boutons tactiles optimisés
local function createMobileButton(parent, text, position, size, callback, buttonType)
    buttonType = buttonType or "primary"
    
    local buttonSize = size or UDim2.new(0, 200, 0, CONFIG.MOBILE_BUTTON_SIZE)
    local backgroundColor = CONFIG.COLORS.PRIMARY
    
    if buttonType == "success" then
        backgroundColor = CONFIG.COLORS.SUCCESS
    elseif buttonType == "danger" then
        backgroundColor = CONFIG.COLORS.DANGER
    elseif buttonType == "warning" then
        backgroundColor = CONFIG.COLORS.WARNING
    end
    
    local button = createMobileFrame(parent, {
        Size = buttonSize,
        Position = position,
        BackgroundColor3 = backgroundColor
    })
    
    local label = Instance.new("TextLabel")
    label.Parent = button
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = CONFIG.COLORS.ACCENT
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.8
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    local clickDetector = Instance.new("TextButton")
    clickDetector.Parent = button
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    
    -- Effets tactiles améliorés
    local originalSize = buttonSize
    local pressedSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale, originalSize.Y.Offset - 4)
    
    clickDetector.MouseButton1Down:Connect(function()
        local tween = createTween(button, {
            Size = pressedSize,
            BackgroundColor3 = backgroundColor:lerp(Color3.new(0, 0, 0), 0.2)
        }, 0.1)
        if tween then tween:Play() end
    end)
    
    clickDetector.MouseButton1Up:Connect(function()
        local tween = createTween(button, {
            Size = originalSize,
            BackgroundColor3 = backgroundColor
        }, 0.1)
        if tween then tween:Play() end
    end)
    
    clickDetector.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
        
        -- Effet de vibration pour mobile
        if isMobile then
            -- Simulation d'effet tactile
            local vibrationTween = createTween(button, {Rotation = 2}, 0.05)
            if vibrationTween then 
                vibrationTween:Play()
                vibrationTween.Completed:Connect(function()
                    local backTween = createTween(button, {Rotation = 0}, 0.05)
                    if backTween then backTween:Play() end
                end)
            end
        end
    end)
    
    return button, clickDetector, label
end

-- ========================================
-- 🏃 SYSTÈME DE MOUVEMENT AMÉLIORÉ
-- ========================================

local MovementSystem = {}

function MovementSystem.toggleSpeed()
    local char, hum, root = getCharacter()
    if not hum then
        warn("❌ Impossible de modifier la vitesse: Humanoid non trouvé")
        return
    end
    
    gameState.speedEnabled = not gameState.speedEnabled
    
    if gameState.speedEnabled then
        hum.WalkSpeed = CONFIG.ENHANCED_WALKSPEED
        print("🏃 Vitesse améliorée activée !")
    else
        hum.WalkSpeed = CONFIG.NORMAL_WALKSPEED
        print("🚶 Vitesse normale restaurée")
    end
end

function MovementSystem.toggleJump()
    local char, hum, root = getCharacter()
    if not hum then
        warn("❌ Impossible de modifier le saut: Humanoid non trouvé")
        return
    end
    
    gameState.jumpEnabled = not gameState.jumpEnabled
    
    if gameState.jumpEnabled then
        hum.JumpPower = CONFIG.ENHANCED_JUMPPOWER
        print("🦘 Saut amélioré activé !")
    else
        hum.JumpPower = CONFIG.NORMAL_JUMPPOWER
        print("👟 Saut normal restauré")
    end
end

local flyConnection
function MovementSystem.toggleFly()
    local char, hum, root = getCharacter()
    if not root then
        warn("❌ Impossible d'activer le vol: RootPart non trouvé")
        return
    end
    
    gameState.flyEnabled = not gameState.flyEnabled
    
    if gameState.flyEnabled then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = root
        
        flyConnection = RunService.Heartbeat:Connect(function()
            local char, hum, root = getCharacter()
            if not root or not bodyVelocity.Parent then return end
            
            local camera = workspace.CurrentCamera
            local moveVector = hum.MoveDirection
            local lookDirection = camera.CFrame.LookVector
            
            local velocity = Vector3.new(0, 0, 0)
            
            if moveVector.Magnitude > 0 then
                velocity = velocity + (camera.CFrame.RightVector * moveVector.X + lookDirection * moveVector.Z).Unit * 50
            end
            
            -- Contrôles tactiles pour monter/descendre
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or gameState.flyUp then
                velocity = velocity + Vector3.new(0, 50, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or gameState.flyDown then
                velocity = velocity + Vector3.new(0, -50, 0)
            end
            
            bodyVelocity.Velocity = velocity
        end)
        
        print("✈️ Vol activé !")
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        if root:FindFirstChild("BodyVelocity") then
            root.BodyVelocity:Destroy()
        end
        
        gameState.flyUp = false
        gameState.flyDown = false
        print("🚶 Vol désactivé")
    end
end

local noClipConnection
function MovementSystem.toggleNoClip()
    local char, hum, root = getCharacter()
    if not char then
        warn("❌ Impossible d'activer NoClip: Personnage non trouvé")
        return
    end
    
    gameState.noClipEnabled = not gameState.noClipEnabled
    
    if gameState.noClipEnabled then
        noClipConnection = RunService.Stepped:Connect(function()
            local char = getCharacter()
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        print("👻 NoClip activé !")
    else
        if noClipConnection then
            noClipConnection:Disconnect()
            noClipConnection = nil
        end
        
        local char = getCharacter()
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
        print("🚶 NoClip désactivé")
    end
end

-- ========================================
-- 📱 INTERFACE MOBILE PRINCIPALE
-- ========================================

local function createMobileGUI()
    -- Vérifier si une GUI existe déjà
    if playerGui:FindFirstChild("RobloxHubMobileGUI") then
        playerGui.RobloxHubMobileGUI:Destroy()
    end
    
    -- Créer la GUI principale
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RobloxHubMobileGUI"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    -- Frame principal mobile-optimisé
    local mainFrame = createMobileFrame(screenGui, {
        Size = UDim2.new(0, CONFIG.GUI_WIDTH, 0, CONFIG.GUI_HEIGHT),
        Position = UDim2.new(0.5, -CONFIG.GUI_WIDTH/2, 0.5, -CONFIG.GUI_HEIGHT/2),
        BackgroundColor3 = CONFIG.COLORS.BACKGROUND
    })
    
    -- En-tête mobile avec bouton hamburger
    local header = createMobileFrame(mainFrame, {
        Size = UDim2.new(1, 0, 0, isMobile and 80 or 60),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = CONFIG.COLORS.PRIMARY
    })
    
    -- Bouton hamburger
    local hamburgerButton = createMobileButton(header, "☰", 
        UDim2.new(0, 10, 0.5, -25), 
        UDim2.new(0, 50, 0, 50), 
        function()
            gameState.menuOpen = not gameState.menuOpen
            -- Animation du menu (implémentée plus bas)
        end
    )
    
    -- Titre
    local title = Instance.new("TextLabel")
    title.Parent = header
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 70, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "📱 ROBLOX HUB MOBILE"
    title.TextColor3 = CONFIG.COLORS.ACCENT
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Bouton de fermeture
    local closeButton = createMobileButton(header, "✕", 
        UDim2.new(1, -60, 0.5, -25), 
        UDim2.new(0, 50, 0, 50), 
        function()
            screenGui:Destroy()
        end, "danger"
    )
    
    -- Zone de contenu avec scroll
    local contentFrame = createMobileFrame(mainFrame, {
        Size = UDim2.new(1, -20, 1, -(isMobile and 100 or 80)),
        Position = UDim2.new(0, 10, 0, isMobile and 90 or 70),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    })
    
    -- ScrollingFrame pour contenu mobile
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = contentFrame
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = isMobile and 8 or 6
    scrollFrame.ScrollBarImageColor3 = CONFIG.COLORS.PRIMARY
    
    -- Layout pour organiser les boutons
    local layout = Instance.new("UIListLayout")
    layout.Parent = scrollFrame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, CONFIG.MOBILE_SPACING)
    
    -- Padding pour le contenu
    local padding = Instance.new("UIPadding")
    padding.Parent = scrollFrame
    padding.PaddingAll = UDim.new(0, CONFIG.MOBILE_SPACING)
    
    -- Boutons de fonctionnalités mobile-optimisés
    local buttonWidth = UDim2.new(1, 0, 0, CONFIG.MOBILE_BUTTON_SIZE)
    
    -- Bouton Vitesse
    local speedButton, _, speedLabel = createMobileButton(scrollFrame, "🏃 Vitesse: OFF", 
        UDim2.new(0, 0, 0, 0), buttonWidth, 
        function()
            MovementSystem.toggleSpeed()
            speedLabel.Text = gameState.speedEnabled and "🏃 Vitesse: ON" or "🏃 Vitesse: OFF"
            speedButton.BackgroundColor3 = gameState.speedEnabled and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.PRIMARY
        end
    )
    speedButton.LayoutOrder = 1
    
    -- Bouton Saut
    local jumpButton, _, jumpLabel = createMobileButton(scrollFrame, "🦘 Saut: OFF", 
        UDim2.new(0, 0, 0, 0), buttonWidth, 
        function()
            MovementSystem.toggleJump()
            jumpLabel.Text = gameState.jumpEnabled and "🦘 Saut: ON" or "🦘 Saut: OFF"
            jumpButton.BackgroundColor3 = gameState.jumpEnabled and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.PRIMARY
        end
    )
    jumpButton.LayoutOrder = 2
    
    -- Bouton Vol
    local flyButton, _, flyLabel = createMobileButton(scrollFrame, "✈️ Vol: OFF", 
        UDim2.new(0, 0, 0, 0), buttonWidth, 
        function()
            MovementSystem.toggleFly()
            flyLabel.Text = gameState.flyEnabled and "✈️ Vol: ON" or "✈️ Vol: OFF"
            flyButton.BackgroundColor3 = gameState.flyEnabled and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.PRIMARY
        end
    )
    flyButton.LayoutOrder = 3
    
    -- Bouton NoClip
    local noClipButton, _, noClipLabel = createMobileButton(scrollFrame, "👻 NoClip: OFF", 
        UDim2.new(0, 0, 0, 0), buttonWidth, 
        function()
            MovementSystem.toggleNoClip()
            noClipLabel.Text = gameState.noClipEnabled and "👻 NoClip: ON" or "👻 NoClip: OFF"
            noClipButton.BackgroundColor3 = gameState.noClipEnabled and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.PRIMARY
        end
    )
    noClipButton.LayoutOrder = 4
    
    -- Contrôles de vol pour mobile
    if isMobile then
        local flyControlsFrame = createMobileFrame(scrollFrame, {
            Size = UDim2.new(1, 0, 0, CONFIG.MOBILE_BUTTON_SIZE + 20),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        })
        flyControlsFrame.LayoutOrder = 5
        
        local flyUpButton = createMobileButton(flyControlsFrame, "⬆️ MONTER", 
            UDim2.new(0, 5, 0, 10), 
            UDim2.new(0.48, 0, 0, CONFIG.MOBILE_BUTTON_SIZE), 
            nil, "warning"
        )
        
        local flyDownButton = createMobileButton(flyControlsFrame, "⬇️ DESCENDRE", 
            UDim2.new(0.52, 0, 0, 10), 
            UDim2.new(0.48, 0, 0, CONFIG.MOBILE_BUTTON_SIZE), 
            nil, "warning"
        )
        
        -- Gestion des contrôles tactiles pour le vol
        flyUpButton[2].MouseButton1Down:Connect(function()
            gameState.flyUp = true
        end)
        
        flyUpButton[2].MouseButton1Up:Connect(function()
            gameState.flyUp = false
        end)
        
        flyDownButton[2].MouseButton1Down:Connect(function()
            gameState.flyDown = true
        end)
        
        flyDownButton[2].MouseButton1Up:Connect(function()
            gameState.flyDown = false
        end)
    end
    
    -- Informations mobile-optimisées
    local infoFrame = createMobileFrame(scrollFrame, {
        Size = UDim2.new(1, 0, 0, isMobile and 120 : 100),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    })
    infoFrame.LayoutOrder = 6
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Parent = infoFrame
    infoLabel.Size = UDim2.new(1, -20, 1, -20)
    infoLabel.Position = UDim2.new(0, 10, 0, 10)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = isMobile and "📱 CONTRÔLES TACTILES:\n• Touchez les boutons pour activer\n• Maintenez MONTER/DESCENDRE pour voler\n• Interface optimisée mobile" or "📋 CONTRÔLES:\n• Cliquez sur les boutons\n• Espace/Shift pour vol\n• Interface responsive"
    infoLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Ajuster la taille du contenu scrollable
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 40)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 40)
    end)
    
    -- Rendre la fenêtre déplaçable (optimisé pour mobile)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function startDrag(input)
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
    
    local function updateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    
    local function endDrag()
        dragging = false
    end
    
    -- Support tactile et souris
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateDrag(input)
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)
    
    print("✅ Interface mobile créée avec succès!")
    return screenGui
end

-- ========================================
-- 🎯 BOUTONS FLOTTANTS MOBILES
-- ========================================

local function createFloatingButtons()
    if not isMobile then return end
    
    local floatingGui = Instance.new("ScreenGui")
    floatingGui.Name = "FloatingButtons"
    floatingGui.Parent = playerGui
    floatingGui.ResetOnSpawn = false
    floatingGui.IgnoreGuiInset = true
    
    -- Bouton flottant principal (toggle menu)
    local mainFloatingButton = createMobileButton(floatingGui, "🎮", 
        UDim2.new(1, -80, 0, 100), 
        UDim2.new(0, 60, 0, 60), 
        function()
            if playerGui:FindFirstChild("RobloxHubMobileGUI") then
                playerGui.RobloxHubMobileGUI:Destroy()
            else
                createMobileGUI()
            end
        end
    )
    
    -- Boutons flottants secondaires
    local speedFloatingButton = createMobileButton(floatingGui, "🏃", 
        UDim2.new(1, -80, 0, 180), 
        UDim2.new(0, 50, 0, 50), 
        function()
            MovementSystem.toggleSpeed()
            speedFloatingButton[3].Text = gameState.speedEnabled and "🏃" or "🚶"
            speedFloatingButton[1].BackgroundColor3 = gameState.speedEnabled and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.PRIMARY
        end
    )
    
    local jumpFloatingButton = createMobileButton(floatingGui, "🦘", 
        UDim2.new(1, -80, 0, 240), 
        UDim2.new(0, 50, 0, 50), 
        function()
            MovementSystem.toggleJump()
            jumpFloatingButton[3].Text = gameState.jumpEnabled and "🦘" or "👟"
            jumpFloatingButton[1].BackgroundColor3 = gameState.jumpEnabled and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.PRIMARY
        end
    )
    
    print("✅ Boutons flottants créés!")
end

-- ========================================
-- 🚀 GESTION DES RESPAWNS
-- ========================================

local function onCharacterAdded(newCharacter)
    print("🔄 Nouveau personnage détecté, mise à jour...")
    
    if newCharacter:WaitForChild("Humanoid", 5) and newCharacter:WaitForChild("HumanoidRootPart", 5) then
        character = newCharacter
        humanoid = character.Humanoid
        rootPart = character.HumanoidRootPart
        
        -- Réinitialiser l'état
        gameState.speedEnabled = false
        gameState.jumpEnabled = false
        gameState.flyEnabled = false
        gameState.noClipEnabled = false
        gameState.flyUp = false
        gameState.flyDown = false
        
        -- Nettoyer les connexions existantes
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if noClipConnection then
            noClipConnection:Disconnect()
            noClipConnection = nil
        end
        
        print("✅ Personnage mis à jour avec succès!")
    else
        warn("❌ Échec du chargement du nouveau personnage")
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

-- ========================================
-- 🎯 CONTRÔLES ET RACCOURCIS
-- ========================================

-- Raccourcis clavier (pour les appareils avec clavier)
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F1 then
            if playerGui:FindFirstChild("RobloxHubMobileGUI") then
                playerGui.RobloxHubMobileGUI:Destroy()
            else
                createMobileGUI()
            end
        elseif input.KeyCode == Enum.KeyCode.F2 then
            MovementSystem.toggleSpeed()
        elseif input.KeyCode == Enum.KeyCode.F3 then
            MovementSystem.toggleJump()
        elseif input.KeyCode == Enum.KeyCode.F4 then
            MovementSystem.toggleFly()
        elseif input.KeyCode == Enum.KeyCode.F5 then
            MovementSystem.toggleNoClip()
        end
    end)
end

-- Gestion de l'orientation mobile
if isMobile then
    local function updateOrientation()
        local newScreenSize = workspace.CurrentCamera.ViewportSize
        local isLandscape = newScreenSize.X > newScreenSize.Y
        
        -- Ajuster la configuration selon l'orientation
        CONFIG.GUI_WIDTH = math.min(newScreenSize.X * 0.9, isLandscape and 450 or 350)
        CONFIG.GUI_HEIGHT = math.min(newScreenSize.Y * 0.8, isLandscape and 400 or 500)
        
        -- Recréer l'interface si elle existe
        if playerGui:FindFirstChild("RobloxHubMobileGUI") then
            playerGui.RobloxHubMobileGUI:Destroy()
            wait(0.1)
            createMobileGUI()
        end
    end
    
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateOrientation)
end

-- ========================================
-- 🚀 INITIALISATION FINALE
-- ========================================

-- Créer l'interface au démarrage
wait(1)
if isMobile then
    createFloatingButtons()
    print("📱 Interface mobile avec boutons flottants créée!")
else
    createMobileGUI()
    print("💻 Interface desktop responsive créée!")
end

print("🎮 ROBLOX HUB MOBILE SCRIPT CHARGÉ AVEC SUCCÈS!")
print("📱 Mode mobile:", isMobile)
print("📋 CONTRÔLES:")
if isMobile then
    print("• Touchez le bouton 🎮 pour ouvrir le menu")
    print("• Utilisez les boutons flottants pour un accès rapide")
    print("• Interface tactile optimisée")
else
    print("• F1: Ouvrir/Fermer l'interface")
    print("• F2-F5: Raccourcis fonctions")
    print("• Interface responsive")
end
print("✅ Script mobile prêt à l'utilisation!")
