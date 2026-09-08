--[[
    Script: Futebol de Rua Clássico - Zekay
    Sistema completo de futebol estilo street soccer
]]

-- Carrega o script principal via loadstring
local sucesso, erro = pcall(function()
    local scriptURL = "https://raw.githubusercontent.com/SeuUsuario/SeuRepositorio/main/futebol.lua" -- Troque pelo seu link
    local script = game:HttpGet(scriptURL)
    local func = loadstring(script)
    if func then
        func()
    else
        error("Falha ao compilar o script")
    end
end)

if not sucesso then
    warn("Erro ao carregar o script: " .. tostring(erro))
    -- Script de fallback caso o loadstring falhe
    print("Carregando versão local...")
    
    -- ===== SCRIPT PRINCIPAL (FALLBACK) =====
    local Zekay = {
        Nome = "Futebol de Rua Clássico",
        Versao = "1.0",
        Time1 = {},
        Time2 = {},
        Pontos1 = 0,
        Pontos2 = 0,
        Tempo = 0,
        EmJogo = false
    }

    -- Serviços
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")

    -- Função para criar a bola
    function Zekay.CriarBola()
        local bola = Instance.new("Part")
        bola.Name = "Bola"
        bola.Size = Vector3.new(1.5, 1.5, 1.5)
        bola.Shape = Enum.PartType.Ball
        bola.BrickColor = BrickColor.new("White")
        bola.Material = Enum.Material.SmoothPlastic
        bola.Anchored = false
        bola.CanCollide = true
        bola.Mass = 5
        bola.Elasticity = 0.8
        bola.Friction = 0.3
        
        -- Adiciona efeito visual
        local decal = Instance.new("Decal")
        decal.Texture = "rbxassetid://1234567890" -- Textura da bola (opcional)
        decal.Face = Enum.NormalId.Front
        decal.Parent = bola
        
        -- Coloca no centro do campo
        bola.Position = Vector3.new(0, 2, 0)
        bola.Parent = workspace
        
        return bola
    end

    -- Função para criar o campo
    function Zekay.CriarCampo()
        local campo = Instance.new("Part")
        campo.Name = "Campo"
        campo.Size = Vector3.new(50, 0.5, 30)
        campo.BrickColor = BrickColor.new("Bright green")
        campo.Material = Enum.Material.Grass
        campo.Anchored = true
        campo.CanCollide = true
        campo.Position = Vector3.new(0, -0.25, 0)
        campo.Parent = workspace
        
        -- Linhas do campo
        Zekay.CriarLinha(Vector3.new(0, 0.1, -15), Vector3.new(50, 0.1, 0.5), "White")
        Zekay.CriarLinha(Vector3.new(0, 0.1, 15), Vector3.new(50, 0.1, 0.5), "White")
        Zekay.CriarLinha(Vector3.new(-25, 0.1, 0), Vector3.new(0.5, 0.1, 30), "White")
        Zekay.CriarLinha(Vector3.new(25, 0.1, 0), Vector3.new(0.5, 0.1, 30), "White")
        Zekay.CriarLinha(Vector3.new(0, 0.1, 0), Vector3.new(0.5, 0.1, 30), "White")
        
        -- Círculo central
        Zekay.CriarCirculo(Vector3.new(0, 0.1, 0), 5, "White")
        
        -- Gols
        Zekay.CriarGol(Vector3.new(-25, 1, 0), "Time1")
        Zekay.CriarGol(Vector3.new(25, 1, 0), "Time2")
        
        -- Paredes (para a bola não sair)
        Zekay.CriarParede(Vector3.new(-25.5, 1, 0), Vector3.new(0.5, 2, 16), "Gray")
        Zekay.CriarParede(Vector3.new(25.5, 1, 0), Vector3.new(0.5, 2, 16), "Gray")
        Zekay.CriarParede(Vector3.new(0, 1, -15.5), Vector3.new(26, 2, 0.5), "Gray")
        Zekay.CriarParede(Vector3.new(0, 1, 15.5), Vector3.new(26, 2, 0.5), "Gray")
        
        print("Campo criado!")
    end

    -- Funções auxiliares para criar elementos do campo
    function Zekay.CriarLinha(posicao, tamanho, cor)
        local linha = Instance.new("Part")
        linha.Size = tamanho
        linha.BrickColor = BrickColor.new(cor)
        linha.Material = Enum.Material.SmoothPlastic
        linha.Anchored = true
        linha.CanCollide = false
        linha.Transparency = 0.5
        linha.Position = posicao
        linha.Parent = workspace
    end

    function Zekay.CriarCirculo(posicao, raio, cor)
        for i = 0, 360, 10 do
            local angulo = math.rad(i)
            local x = posicao.X + math.cos(angulo) * raio
            local z = posicao.Z + math.sin(angulo) * raio
            local ponto = Instance.new("Part")
            ponto.Size = Vector3.new(0.3, 0.1, 0.3)
            ponto.BrickColor = BrickColor.new(cor)
            ponto.Material = Enum.Material.SmoothPlastic
            ponto.Anchored = true
            ponto.CanCollide = false
            ponto.Transparency = 0.5
            ponto.Position = Vector3.new(x, posicao.Y, z)
            ponto.Parent = workspace
        end
    end

    function Zekay.CriarGol(posicao, dono)
        local cor = (dono == "Time1") and "Bright blue" or "Bright red"
        
        -- Trave
        local trave1 = Instance.new("Part")
        trave1.Size = Vector3.new(0.3, 3, 0.3)
        trave1.BrickColor = BrickColor.new(cor)
        trave1.Material = Enum.Material.Metal
        trave1.Anchored = true
        trave1.CanCollide = true
        trave1.Position = posicao + Vector3.new(0, 1.5, -3)
        trave1.Parent = workspace
        
        local trave2 = Instance.new("Part")
        trave2.Size = Vector3.new(0.3, 3, 0.3)
        trave2.BrickColor = BrickColor.new(cor)
        trave2.Material = Enum.Material.Metal
        trave2.Anchored = true
        trave2.CanCollide = true
        trave2.Position = posicao + Vector3.new(0, 1.5, 3)
        trave2.Parent = workspace
        
        -- Trave superior
        local traveSuperior = Instance.new("Part")
        traveSuperior.Size = Vector3.new(0.3, 0.3, 6)
        traveSuperior.BrickColor = BrickColor.new(cor)
        traveSuperior.Material = Enum.Material.Metal
        traveSuperior.Anchored = true
        traveSuperior.CanCollide = true
        traveSuperior.Position = posicao + Vector3.new(0, 3, 0)
        traveSuperior.Parent = workspace
        
        -- Rede (apenas visual)
        for i = -2.5, 2.5, 0.5 do
            for j = 0.5, 2.5, 0.5 do
                local rede = Instance.new("Part")
                rede.Size = Vector3.new(0.1, 0.1, 0.1)
                rede.BrickColor = BrickColor.new("White")
                rede.Material = Enum.Material.SmoothPlastic
                rede.Anchored = true
                rede.CanCollide = false
                rede.Transparency = 0.5
                rede.Position = posicao + Vector3.new((dono == "Time1" and -0.5 or 0.5), j, i)
                rede.Parent = workspace
            end
        end
    end

    function Zekay.CriarParede(posicao, tamanho, cor)
        local parede = Instance.new("Part")
        parede.Size = tamanho
        parede.BrickColor = BrickColor.new(cor)
        parede.Material = Enum.Material.SmoothPlastic
        parede.Anchored = true
        parede.CanCollide = true
        parede.Transparency = 0.3
        parede.Position = posicao
        parede.Parent = workspace
    end

    -- Função para chutar a bola
    function Zekay.ChutarBola(jogador, forca, direcao)
        local bola = workspace:FindFirstChild("Bola")
        if not bola then return end
        
        local character = jogador.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Aplica força na bola
        local forcaTotal = forca or 50
        local direcaoFinal = direcao or rootPart.CFrame.LookVector
        
        local velocity = bola.Velocity
        bola.Velocity = velocity + (direcaoFinal * forcaTotal)
        
        -- Efeito de chute
        local debounce = Instance.new("BoolValue")
        debounce.Name = "Chutando"
        debounce.Parent = bola
        task.wait(0.5)
        debounce:Destroy()
    end

    -- Função para iniciar a partida
    function Zekay.IniciarPartida()
        if Zekay.EmJogo then return end
        
        Zekay.EmJogo = true
        Zekay.Pontos1 = 0
        Zekay.Pontos2 = 0
        Zekay.Tempo = 0
        
        -- Limpa jogadores antigos
        Zekay.Time1 = {}
        Zekay.Time2 = {}
        
        -- Pega jogadores atuais
        local todosJogadores = Players:GetPlayers()
        local metade = math.floor(#todosJogadores / 2)
        
        for i, player in ipairs(todosJogadores) do
            if i <= metade then
                table.insert(Zekay.Time1, player)
                player.TeamColor = BrickColor.new("Bright blue")
            else
                table.insert(Zekay.Time2, player)
                player.TeamColor = BrickColor.new("Bright red")
            end
        end
        
        -- Coloca a bola no centro
        local bola = workspace:FindFirstChild("Bola")
        if bola then
            bola.Position = Vector3.new(0, 2, 0)
            bola.Velocity = Vector3.new(0, 0, 0)
        end
        
        print("Partida iniciada!")
        print("Time 1:", #Zekay.Time1, "jogadores")
        print("Time 2:", #Zekay.Time2, "jogadores")
        
        -- Start do cronômetro
        Zekay.IniciarCronometro()
    end

    -- Função do cronômetro
    function Zekay.IniciarCronometro()
        spawn(function()
            while Zekay.EmJogo do
                task.wait(1)
                Zekay.Tempo = Zekay.Tempo + 1
                
                -- Tempo limite de 10 minutos
                if Zekay.Tempo >= 600 then
                    Zekay.FinalizarPartida()
                    break
                end
            end
        end)
    end

    -- Função para finalizar partida
    function Zekay.FinalizarPartida()
        Zekay.EmJogo = false
        print("Partida finalizada!")
        print("Placar final - Time 1:", Zekay.Pontos1, "x", Zekay.Pontos2, "Time 2")
        
        if Zekay.Pontos1 > Zekay.Pontos2 then
            print("Time 1 venceu!")
        elseif Zekay.Pontos2 > Zekay.Pontos1 then
            print("Time 2 venceu!")
        else
            print("Empate!")
        end
    end

    -- Função para detectar gol
    function Zekay.DetectarGol()
        local bola = workspace:FindFirstChild("Bola")
        if not bola then return end
        
        -- Detecta gol do Time 1 (lado esquerdo)
        if bola.Position.X < -24 and bola.Position.Z > -3 and bola.Position.Z < 3 then
            Zekay.Pontos1 = Zekay.Pontos1 + 1
            print("GOL do Time 1! Placar:", Zekay.Pontos1, "x", Zekay.Pontos2)
            task.wait(1)
            bola.Position = Vector3.new(0, 2, 0)
            bola.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Detecta gol do Time 2 (lado direito)
        if bola.Position.X > 24 and bola.Position.Z > -3 and bola.Position.Z < 3 then
            Zekay.Pontos2 = Zekay.Pontos2 + 1
            print("GOL do Time 2! Placar:", Zekay.Pontos1, "x", Zekay.Pontos2)
            task.wait(1)
            bola.Position = Vector3.new(0, 2, 0)
            bola.Velocity = Vector3.new(0, 0, 0)
        end
    end

    -- Função para criar placar
    function Zekay.CriarPlacar()
        local placar = Instance.new("BillboardGui")
        placar.Name = "Placar"
        placar.Size = UDim2.new(0, 200, 0, 100)
        placar.Adornee = workspace:FindFirstChild("Campo")
        placar.Parent = workspace
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.5
        frame.Parent = placar
        
        local time1 = Instance.new("TextLabel")
        time1.Size = UDim2.new(0.4, 0, 1, 0)
        time1.Position = UDim2.new(0, 0, 0, 0)
        time1.Text = "Time 1: 0"
        time1.TextColor3 = Color3.fromRGB(0, 0, 255)
        time1.BackgroundTransparency = 1
        time1.Parent = frame
        
        local time2 = Instance.new("TextLabel")
        time2.Size = UDim2.new(0.4, 0, 1, 0)
        time2.Position = UDim2.new(0.6, 0, 0, 0)
        time2.Text = "Time 2: 0"
        time2.TextColor3 = Color3.fromRGB(255, 0, 0)
        time2.BackgroundTransparency = 1
        time2.Parent = frame
        
        return placar
    end

    -- Função para controlar chute com clique
    function Zekay.ConfigurarControles()
        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local player = Players.LocalPlayer
                if player and player.Character then
                    local bola = workspace:FindFirstChild("Bola")
                    if bola then
                        local character = player.Character
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            -- Distância até a bola
                            local distancia = (bola.Position - rootPart.Position).Magnitude
                            if distancia < 5 then
                                -- Chuta na direção da câmera
                                local camera = workspace.CurrentCamera
                                local direction = camera.CFrame.LookVector
                                Zekay.ChutarBola(player, 60, direction)
                            end
                        end
                    end
                end
            end
        end)
    end

    -- Função principal para iniciar o jogo
    function Zekay.Iniciar()
        print("Iniciando", Zekay.Nome, "Versão", Zekay.Versao)
        
        -- Limpa o workspace de elementos antigos
        local bola = workspace:FindFirstChild("Bola")
        if bola then bola:Destroy() end
        
        -- Cria o campo e a bola
        Zekay.CriarCampo()
        Zekay.CriarBola()
        Zekay.CriarPlacar()
        
        -- Detecta gols a cada frame
        RunService.Heartbeat:Connect(function()
            Zekay.DetectarGol()
        end)
        
        -- Inicia partida automaticamente
        task.wait(2)
        Zekay.IniciarPartida()
        
        -- Configura controles (apenas para o jogador local)
        if Players.LocalPlayer then
            Zekay.ConfigurarControles()
        end
        
        print("Jogo de futebol de rua pronto!")
    end

    -- Executa o script
    Zekay.Iniciar()

    return Zekay
end
