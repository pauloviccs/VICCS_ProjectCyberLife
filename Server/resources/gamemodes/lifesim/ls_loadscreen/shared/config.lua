-- =============================================================================
-- LIFESIM RP - LOADING SCREEN CONFIGURATION
-- Path: ls_loadscreen/shared/config.lua
-- Suporta: Transições Vanilla suave, vídeo local MP4, ou streaming YouTube
-- =============================================================================

Config = {}

-- Modo Padrão da Loading Screen:
-- "vanilla" = Cenas dinâmicas e cinemáticas de Night City com transição suave (Default)
-- "local"   = Vídeo MP4 localizado na pasta do recurso (ex: web/media/intro.mp4)
-- "youtube" = Transmissão direta de vídeo/stream do YouTube via IFrame API
Config.DefaultMode = "vanilla"

-- Configurações de Mídia
Config.Media = {
    -- Transições Vanilla de Night City (Cut-scenes estéticas)
    vanillaScenes = {
        {
            id = "scene_watson",
            title = "WATSON DISTRICT // KABUKI ROUNDABOUT",
            subtitle = "ZONA INDUSTRIAL & SUBTERRÂNEA - TAXA DE CRIME: ELEVADA",
            accent = "#22D8E2"
        },
        {
            id = "scene_corpo",
            title = "CITY CENTER // CORPO PLAZA & ARASAKA TOWER",
            subtitle = "ZONA CORPORATIVA RESTRITA - SEGURANÇA MÁXIMA ARASAKA SEC",
            accent = "#FF003C"
        },
        {
            id = "scene_westbrook",
            title = "WESTBROOK // JAPANTOWN ENTERTAINMENT HUB",
            subtitle = "CORREDOR HOLOGRÁFICO DE NEON - MERCADOS NOTURNOS & CASINOS",
            accent = "#FCEE0A"
        },
        {
            id = "scene_pacifica",
            title = "PACIFICA // GRAND IMPERIAL COASTVIEW",
            subtitle = "TERRITÓRIO DOS VOODOO BOYS - REDE NEURAL DESCENTRALIZADA",
            accent = "#00FF9D"
        },
        {
            id = "scene_badlands",
            title = "BADLANDS // DUST HIGHWAY 101",
            subtitle = "ROTAS NÔMADES DOS ALDECALDOS & WRAITHS",
            accent = "#FF7A00"
        }
    },

    -- Mídia Local MP4 (coloque seu arquivo em web/media/intro.mp4 se ativado)
    localVideo = "media/intro.mp4",

    -- Integração YouTube
    youtube = {
        enabled = false,
        videoId = "kPvG0j3zFjA", -- ID do vídeo do YouTube (ex: Cyberpunk 2077 Night City ambience)
        startSeconds = 0,
        suggestedQuality = "hd1080"
    },

    -- Intervalo de troca de cena Vanilla (em milissegundos)
    sceneIntervalMs = 7000,
    -- Duração da transição suave crossfade (em milissegundos)
    crossfadeDurationMs = 1200
}

-- Configurações do Player de Áudio / Telemetria
Config.Player = {
    defaultVolume = 0.5,
    autoPlay = true,
    showEqualizer = true,
    playlist = {
        {
            title = "Night City Wire // Sub-bass Pulse",
            artist = "V.I.C.C.S Neural Synth Engine",
            duration = "03:45",
            bpm = 85
        },
        {
            title = "Kiroshi Optics // Calibration Ambience",
            artist = "Optics Systems Cyber-Audio",
            duration = "04:12",
            bpm = 92
        },
        {
            title = "Trauma Team Platinum // Priority Uplink",
            artist = "Emergency Dispatch Lo-Fi",
            duration = "03:10",
            bpm = 78
        }
    }
}
