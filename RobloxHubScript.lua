--[[
    📱 ROBLOX HUB SCRIPT - VERSION GUI SEULEMENT
    
    Version GUI uniquement pour compatibilité maximale :
    - Interface tactile mobile-optimisée
    - Boutons visuels sans fonctionnalités actives
    - Compatible avec tous les exploits
    - Aucun service problématique utilisé
    - Sécurisé et stable
    
    📋 INSTRUCTIONS D'UTILISATION :
    1. Copiez ce script dans votre exploit
    2. Exécutez le script dans le jeu
    3. L'interface s'affiche sans affecter le gameplay
    
    ⚠️  AVERTISSEMENT : À des fins éducatives uniquement
--]]

-- ========================================
-- 🔧 SERVICES ET VARIABLES BASIQUES
-- ========================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Détection mobile sécurisée
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = workspace.CurrentCamera.ViewportSize

print("📱 Mode mobile détecté:", isMobile)
print("📺 Taille d'écran:", screenSize.X .. "x" .. screenSize.Y)

-- Configuration GUI mobile-optimisée
local CONFIG = {
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

-- Variables d'état GUI uniquement (pas de fonctionnalités réelles)
local guiState = {
    speedEnabled = false,
    jumpEnabled = false,
    flyEnabled = false,
    noClipEnabled = false,
    menuOpen = false
}

-- ========================================
-- 🛠️ FONCTIONS UTILITAIRES GUI
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

-- Fonction pour créer des boutons tactiles optimisés (GUI seulement)
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
    
    -- Effets tactiles améliorés (visuels seulement)
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
        
        -- Effet de vibration visuel pour mobile
        if isMobile then
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
-- 🎭 FONCTIONS GUI SIMULÉES (SANS EFFET RÉEL)
-- ========================================

local function toggleSpeedGUI()
    guiState.speedEnabled = not guiState.speedEnabled
    print("🎭 [GUI SEULEMENT] Vitesse:", guiState.speedEnabled and "ON" or "OFF")
end

local function toggleJumpGUI()
    guiState.jumpEnabled = not guiState.jumpEnabled
    print("🎭 [GUI SEULEMENT] Saut:", guiState.jumpEnabled and "ON" or "OFF")
end

local function toggleFlyGUI()
    guiState.flyEnabled = not guiState.flyEnabled
    print("🎭 [GUI SEULEMENT] Vol:", guiState.flyEnabled and "ON" or "OFF")
end

local function toggleNoClipGUI()
    guiState.noClipEnabled = not guiState.noClipEnabled
    print("🎭 [GUI SEULEMENT] NoClip:", guiState.noClipEnabled and "ON" or "OFF")
end

-- ========================================
-- 📱 INTERFACE MOBILE GUI SEULEMENT
-- ========================================

local function createGUIOnlyInterface()
    -- Vérifier si une GUI existe déjà
    if playerGui:FindFirstChild("RobloxHubGUIOnly") then
        playerGui.RobloxHubGUIOnly:Destroy()
    end
    
    -- Créer la GUI principale
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RobloxHubGUIOnly"
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
    
    -- Bouton hamburger (GUI seulement)
    local hamburgerButton = createMobileButton(header, "☰", 
        UDim2.new(0, 10, 0.5, -25), 
        UDim2.new(0, 50, 0, 50), 
        function()
            guiState.menuOpen = not guiState.menuOpen
            print("🎭 [GUI SEULEMENT] Menu:", guiState.menuOpen and "OUVERT" or "FERMÉ")
        end
    )
    
    -- Titre
    local title = Instance.new("TextLabel")
    title.Parent = header
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 70, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "📱 ROBLOX HUB (GUI ONLY)"
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
            print("👋 Interface fermée")
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
    
    -- Boutons de fonctionnalités GUI seulement
    local buttonWidth = UDim2.new(1, 0, 0, CONFIG.MOBILE_BUTTON_SIZE)
    
    -- Bouton Vitesse (GUI seulement)
    local speedButton, _, speedLabel = createMobileButton(scrollFrame, "🏃 Vitesse: OFF", 
        UDim2.new(0, 0, 0, 0), buttonWidth, 
        function()
            toggleSpeedGUI()
            speedLabel.Text = guiState.speedEnabled and "🏃 Vitesse: ON" or "🏃 Vitesse: OFF"
            speedButton.BackgroundColor3 = guiState.speedEnabled and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.PRIMARY
        end
    )
    speedButton.LayoutOrder = 1
    
    -- Bouton Saut (GUI seulement)
    local jumpButton, _, jumpLabel = createMobileButton(scrollFrame, "🦘 Saut: OFF", 
        UDim2.new(0, 0, 0, 0), buttonWidth, 
        function()
            toggleJumpGUI()
            jumpLabel.Text = guiState.jumpEnabled and "🦘 Saut: ON" or "🦘 Saut: OFF"
            jumpButton.BackgroundColor3 = guiState.jumpEnabled and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.PRIMARY
        end
    )
    jumpButton.LayoutOrder = 2
    
    -- Bouton Vol (GUI seulement)
    local flyButton, _, flyLabel = createMobileButton(scrollFrame, "✈️ Vol: OFF", 
        UDim2.new(0, 0, 0, 0), buttonWidth, 
        function()
            toggleFlyGUI()
            flyLabel.Text = guiState.flyEnabled and "✈️ Vol: ON" or "✈️ Vol: OFF"
            flyButton.BackgroundColor3 = guiState.flyEnabled and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.PRIMARY
        end
    )
    flyButton.LayoutOrder = 3
    
    -- Bouton NoClip (GUI seulement)
    local noClipButton, _, noClipLabel = createMobileButton(scrollFrame, "👻 NoClip: OFF", 
        UDim2.new(0, 0, 0, 0), buttonWidth, 
        function()
            toggleNoClipGUI()
            noClipLabel.Text = guiState.noClipEnabled and "👻 NoClip: ON" or "👻 NoClip: OFF"
            noClipButton.BackgroundColor3 = guiState.noClipEnabled and CONFIG.COLORS.SUCCESS or CONFIG.COLORS.PRIMARY
        end
    )
    noClipButton.LayoutOrder = 4
    
    -- Contrôles de vol simulés pour mobile
    if isMobile then
        local flyControlsFrame = createMobileFrame(scrollFrame, {
            Size = UDim2.new(1, 0, 0, CONFIG.MOBILE_BUTTON_SIZE + 20),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        })
        flyControlsFrame.LayoutOrder = 5
        
        local flyUpButton = createMobileButton(flyControlsFrame, "⬆️ MONTER", 
            UDim2.new(0, 5, 0, 10), 
            UDim2.new(0.48, 0, 0, CONFIG.MOBILE_BUTTON_SIZE), 
            function()
                print("🎭 [GUI SEULEMENT] Commande vol: MONTER")
            end, "warning"
        )
        
        local flyDownButton = createMobileButton(flyControlsFrame, "⬇️ DESCENDRE", 
            UDim2.new(0.52, 0, 0, 10), 
            UDim2.new(0.48, 0, 0, CONFIG.MOBILE_BUTTON_SIZE), 
            function()
                print("🎭 [GUI SEULEMENT] Commande vol: DESCENDRE")
            end, "warning"
        )
    end
    
    -- Informations GUI seulement
    local infoFrame = createMobileFrame(scrollFrame, {
        Size = UDim2.new(1, 0, 0, isMobile and 140 or 120),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    })
    infoFrame.LayoutOrder = 6
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Parent = infoFrame
    infoLabel.Size = UDim2.new(1, -20, 1, -20)
    infoLabel.Position = UDim2.new(0, 10, 0, 10)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "🎭 VERSION GUI SEULEMENT\n\n• Interface tactile fonctionnelle\n• Boutons visuels sans effet réel\n• Compatible avec tous exploits\n• Aucun risque de détection\n• Parfait pour tester l'interface"
    infoLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Statut en temps réel
    local statusFrame = createMobileFrame(scrollFrame, {
        Size = UDim2.new(1, 0, 0, CONFIG.MOBILE_BUTTON_SIZE),
        BackgroundColor3 = Color3.fromRGB(30, 60, 30)
    })
    statusFrame.LayoutOrder = 7
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = statusFrame
    statusLabel.Size = UDim2.new(1, -20, 1, -10)
    statusLabel.Position = UDim2.new(0, 10, 0, 5)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "✅ INTERFACE ACTIVE - AUCUNE FONCTIONNALITÉ RÉELLE"
    statusLabel.TextColor3 = CONFIG.COLORS.SUCCESS
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Ajuster la taille du contenu scrollable
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 40)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 40)
    end)
    
    -- Animation d'entrée
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    local entranceTween = createTween(mainFrame, {
        Size = UDim2.new(0, CONFIG.GUI_WIDTH, 0, CONFIG.GUI_HEIGHT)
    }, 0.5, Enum.EasingStyle.Back)
    
    if entranceTween then
        entranceTween:Play()
    end
    
    print("✅ Interface GUI-Only créée avec succès!")
    print("🎭 Toutes les fonctionnalités sont purement visuelles")
    print("🔒 Aucun risque de détection ou de problème de compatibilité")
end

-- ========================================
-- 🚀 INITIALISATION PRINCIPALE
-- ========================================

print("🎭 ========================================")
print("🎭 ROBLOX HUB SCRIPT - VERSION GUI SEULEMENT")
print("🎭 ========================================")
print("📱 Détection mobile:", isMobile and "OUI" or "NON")
print("📺 Résolution:", screenSize.X .. "x" .. screenSize.Y)
print("🎭 Mode: Interface seulement (aucune fonctionnalité réelle)")
print("🔒 Sécurité: Maximale (aucun service problématique)")
print("")

-- Créer l'interface GUI seulement
createGUIOnlyInterface()

print("✅ Script GUI-Only prêt à l'utilisation!")
print("🎭 Toutes les interactions sont purement cosmétiques")
print("📱 Interface optimisée pour mobile et desktop")
print("🔒 Compatible avec tous les exploits")

-- Message de rappel
wait(2)
print("")
print("⚠️  RAPPEL: Cette version n'affecte pas le gameplay")
print("🎭 Les boutons changent visuellement mais n'ont aucun effet réel")
print("✅ Parfait pour tester l'interface sans risque")
