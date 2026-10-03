// =============================================================================
// LIFESIM RP - NATIVE CYBERPUNK 2077 LOADING SCREEN ENGINE
// Path: ls_loadscreen/web/js/app.js
// Suporte a: Cenas Vanilla (Crossfade), Vídeo Local MP4, YouTube IFrame,
//            Audio Player com Web Audio Fallback, e Telemetria Open77 CEF
// =============================================================================

(function () {
    "use strict";

    // Elementos DOM
    const $ = id => document.getElementById(id);

    // Estado Geral
    let config = {
        mode: "vanilla",
        localVideoUrl: "./media/intro.mp4",
        youtube: { enabled: false, videoId: "kPvG0j3zFjA", startSeconds: 0 },
        vanillaScenes: [],
        playlist: [],
        defaultVolume: 0.5,
        sceneIntervalMs: 7000,
        crossfadeDurationMs: 1200
    };

    let currentSceneIndex = 0;
    let sceneTimer = null;
    let activeBackdrop = "a"; // 'a' ou 'b'
    let currentTrackIndex = 0;
    let isPlaying = true;
    let isMuted = false;
    let currentVolume = 0.5;
    let audioContext = null;
    let synthGain = null;
    let synthOscillator = null;

    // =========================================================================
    // 1. CARREGAMENTO DE CONFIGURAÇÃO (FAIL-SAFE)
    // =========================================================================

    const defaultConfig = {
        mode: "vanilla",
        localVideoUrl: "./media/intro.mp4",
        youtube: { enabled: false, videoId: "kPvG0j3zFjA", startSeconds: 0 },
        vanillaScenes: [
            {
                district: "WATSON // KABUKI",
                title: "WATSON DISTRICT // KABUKI ROUNDABOUT",
                subtitle: "ZONA INDUSTRIAL & MERCADOS NOTURNOS // SUB-DISTRITO D9",
                threat: "ELEVADA // MAELSTROM & TYGER CLAWS",
                gradient: "radial-gradient(ellipse at 50% 40%, rgba(34, 216, 226, 0.18) 0%, rgba(8, 18, 30, 0.92) 50%, rgba(3, 7, 14, 0.98) 100%)",
                accent: "#22D8E2",
                coords: "X: -1420.44 | Y: 1289.12 | Z: 18.5"
            },
            {
                district: "CITY CENTER // CORPO PLAZA",
                title: "CORPO PLAZA // ARASAKA TOWER",
                subtitle: "ZONA CORPORATIVA RESTRITA // CORREDOR DE AERODINOS",
                threat: "SEGURANÇA MÁXIMA ARASAKA SEC",
                gradient: "radial-gradient(ellipse at 50% 40%, rgba(255, 0, 60, 0.18) 0%, rgba(24, 8, 16, 0.92) 50%, rgba(6, 2, 8, 0.98) 100%)",
                accent: "#FF003C",
                coords: "X: -188.75 | Y: -240.50 | Z: 124.0"
            },
            {
                district: "WESTBROOK // JAPANTOWN",
                title: "JAPANTOWN // CHERRY BLOSSOM MARKET",
                subtitle: "CORREDOR HOLOGRÁFICO DE NEON & CASINOS ILUMINADOS",
                threat: "MODERADA // POLICIAMENTO PRIVADO NCPD",
                gradient: "radial-gradient(ellipse at 50% 40%, rgba(252, 238, 10, 0.16) 0%, rgba(24, 20, 6, 0.92) 50%, rgba(7, 5, 2, 0.98) 100%)",
                accent: "#FCEE0A",
                coords: "X: 342.11 | Y: 720.89 | Z: 45.2"
            },
            {
                district: "PACIFICA // COASTVIEW",
                title: "PACIFICA // GRAND IMPERIAL COASTVIEW",
                subtitle: "TERRITÓRIO DESREGULAMENTADO // REDE NEURAL DESCENTRALIZADA",
                threat: "EXTREMA // VOODOO BOYS & ANIMAIS",
                gradient: "radial-gradient(ellipse at 50% 40%, rgba(0, 255, 157, 0.16) 0%, rgba(6, 24, 18, 0.92) 50%, rgba(2, 8, 6, 0.98) 100%)",
                accent: "#00FF9D",
                coords: "X: -1100.80 | Y: -1850.32 | Z: 12.0"
            },
            {
                district: "BADLANDS // HIGHWAY 101",
                title: "BADLANDS // DUST HIGHWAY 101",
                subtitle: "PLANÍCIE NÔMADE // ROTAS DOS ALDECALDOS & WRAITHS",
                threat: "ALTA // EMBOSCADAS NÔMADES",
                gradient: "radial-gradient(ellipse at 50% 40%, rgba(255, 122, 0, 0.18) 0%, rgba(28, 14, 6, 0.92) 50%, rgba(10, 4, 2, 0.98) 100%)",
                accent: "#FF7A00",
                coords: "X: 2450.60 | Y: -890.15 | Z: 32.7"
            }
        ],
        playlist: [
            {
                title: "Night City Wire // Sub-bass Pulse",
                artist: "V.I.C.C.S Neural Synth",
                duration: "03:45",
                freq: 55
            },
            {
                title: "Kiroshi Optics // Calibration Stream",
                artist: "Optics Systems Cyber-Audio",
                duration: "04:12",
                freq: 65
            },
            {
                title: "Trauma Team Platinum // Priority Uplink",
                artist: "Emergency Dispatch Lo-Fi",
                duration: "02:58",
                freq: 48
            }
        ],
        defaultVolume: 0.5,
        sceneIntervalMs: 7000,
        crossfadeDurationMs: 1200
    };

    async function loadConfiguration() {
        try {
            const res = await fetch("./config.json");
            if (res.ok) {
                const data = await res.json();
                config = Object.assign({}, defaultConfig, data);
            } else {
                config = defaultConfig;
            }
        } catch (_) {
            config = defaultConfig;
        }

        currentVolume = config.defaultVolume || 0.5;
        if ($("volume-slider")) $("volume-slider").value = currentVolume;

        initMediaEngine();
        initAudioEngine();
        initCanvasParticles();
        setupEventListeners();
    }

    // =========================================================================
    // 2. MEDIA ENGINE (VANILLA CROSSFADE / LOCAL MP4 / YOUTUBE)
    // =========================================================================

    function initMediaEngine() {
        const mode = config.mode || "vanilla";
        document.body.dataset.mode = mode;

        if (mode === "local" && config.localVideoUrl) {
            setupLocalVideo();
        } else if (mode === "youtube" && config.youtube && config.youtube.enabled) {
            setupYouTube();
        } else {
            setupVanillaScenes();
        }
    }

    function setupVanillaScenes() {
        const layer = $("vanilla-layer");
        if (layer) layer.classList.add("active");

        applyScene(0);

        if (sceneTimer) clearInterval(sceneTimer);
        sceneTimer = setInterval(() => {
            currentSceneIndex = (currentSceneIndex + 1) % config.vanillaScenes.length;
            applyScene(currentSceneIndex);
        }, config.sceneIntervalMs || 7000);
    }

    function applyScene(index) {
        const scene = config.vanillaScenes[index];
        if (!scene) return;

        const targetBg = activeBackdrop === "a" ? $("scene-bg-b") : $("scene-bg-a");
        const currentBg = activeBackdrop === "a" ? $("scene-bg-a") : $("scene-bg-b");

        if (targetBg && currentBg) {
            targetBg.style.background = scene.gradient;
            targetBg.classList.add("active");
            currentBg.classList.remove("active");
            activeBackdrop = activeBackdrop === "a" ? "b" : "a";
        }

        if ($("scene-district")) $("scene-district").textContent = scene.district || "";
        if ($("scene-title")) $("scene-title").textContent = scene.title || "";
        if ($("scene-desc")) $("scene-desc").textContent = scene.subtitle || "";
        if ($("scene-threat")) $("scene-threat").textContent = "// TAXA DE AMEAÇA: " + (scene.threat || "NOMINAL");
        if ($("scene-coords")) $("scene-coords").textContent = scene.coords || "";

        // Altera cor de destaque se especificado
        if (scene.accent && $("scene-title")) {
            $("scene-title").style.textShadow = `0 4px 20px rgba(0, 0, 0, 0.9), 0 0 25px ${scene.accent}4D`;
        }
    }

    function setupLocalVideo() {
        const layer = $("local-video-layer");
        const video = $("local-video-player");
        if (!layer || !video) {
            setupVanillaScenes();
            return;
        }

        layer.classList.add("active");
        video.src = config.localVideoUrl;
        video.play().catch(() => {
            // Em caso de falha de codec ou arquivo ausente, fallback suave para vanilla
            layer.classList.remove("active");
            setupVanillaScenes();
        });

        video.onerror = () => {
            layer.classList.remove("active");
            setupVanillaScenes();
        };
    }

    function setupYouTube() {
        const layer = $("youtube-layer");
        if (!layer || !config.youtube.videoId) {
            setupVanillaScenes();
            return;
        }

        layer.classList.add("active");
        const tag = document.createElement("script");
        tag.src = "https://www.youtube.com/iframe_api";
        const firstScriptTag = document.getElementsByTagName("script")[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

        window.onYouTubeIframeAPIReady = function () {
            try {
                new window.YT.Player("yt-player-container", {
                    videoId: config.youtube.videoId,
                    playerVars: {
                        autoplay: 1,
                        controls: 0,
                        showinfo: 0,
                        modestbranding: 1,
                        loop: 1,
                        fs: 0,
                        cc_load_policy: 0,
                        iv_load_policy: 3,
                        autohide: 1,
                        start: config.youtube.startSeconds || 0
                    },
                    events: {
                        onReady: function (e) {
                            e.target.mute();
                            e.target.playVideo();
                        },
                        onError: function () {
                            layer.classList.remove("active");
                            setupVanillaScenes();
                        }
                    }
                });
            } catch (_) {
                layer.classList.remove("active");
                setupVanillaScenes();
            }
        };

        // Fallback de segurança se a API do YT demorar mais de 3 segundos
        setTimeout(() => {
            if (!layer.querySelector("iframe")) {
                layer.classList.remove("active");
                setupVanillaScenes();
            }
        }, 3000);
    }

    // =========================================================================
    // 3. CANVAS DE PARTÍCULAS E GRID HOLOGRÁFICO
    // =========================================================================

    function initCanvasParticles() {
        const canvas = $("ambient-canvas");
        if (!canvas) return;

        const ctx = canvas.getContext("2d");
        let width = canvas.width = window.innerWidth;
        let height = canvas.height = window.innerHeight;

        window.addEventListener("resize", () => {
            width = canvas.width = window.innerWidth;
            height = canvas.height = window.innerHeight;
        }, { passive: true });

        const particleCount = 45;
        const particles = [];
        for (let i = 0; i < particleCount; i++) {
            particles.push({
                x: Math.random() * width,
                y: Math.random() * height,
                vx: (Math.random() - 0.5) * 0.4,
                vy: -Math.random() * 0.6 - 0.2,
                size: Math.random() * 2 + 0.8,
                alpha: Math.random() * 0.6 + 0.2
            });
        }

        function render() {
            ctx.clearRect(0, 0, width, height);

            // Grid holográfico sutil de fundo
            ctx.strokeStyle = "rgba(34, 216, 226, 0.025)";
            ctx.lineWidth = 1;
            const gridSize = 80;
            for (let x = 0; x < width; x += gridSize) {
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x, height);
                ctx.stroke();
            }
            for (let y = 0; y < height; y += gridSize) {
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
                ctx.stroke();
            }

            // Partículas cibernéticas
            for (let i = 0; i < particles.length; i++) {
                const p = particles[i];
                p.x += p.vx;
                p.y += p.vy;

                if (p.y < 0) p.y = height;
                if (p.x < 0) p.x = width;
                if (p.x > width) p.x = 0;

                ctx.fillStyle = `rgba(34, 216, 226, ${p.alpha})`;
                ctx.fillRect(p.x, p.y, p.size, p.size);
            }

            requestAnimationFrame(render);
        }

        requestAnimationFrame(render);
    }

    // =========================================================================
    // 4. AUDIO ENGINE (PLAYLIST + WEB AUDIO SYNTH AMBIENT FALLBACK)
    // =========================================================================

    function initAudioEngine() {
        updateTrackDisplay();
        startSynthAmbient();
    }

    function updateTrackDisplay() {
        const track = config.playlist[currentTrackIndex];
        if (!track) return;

        if ($("track-title")) $("track-title").textContent = track.title;
        if ($("track-artist")) $("track-artist").textContent = track.artist;
    }

    function startSynthAmbient() {
        try {
            const AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!AudioCtx) return;

            if (!audioContext) {
                audioContext = new AudioCtx();
            }

            if (audioContext.state === "suspended") {
                const resumeOnInteract = () => {
                    audioContext.resume();
                    document.removeEventListener("click", resumeOnInteract);
                    document.removeEventListener("keydown", resumeOnInteract);
                };
                document.addEventListener("click", resumeOnInteract, { once: true });
                document.addEventListener("keydown", resumeOnInteract, { once: true });
            }

            const track = config.playlist[currentTrackIndex] || { freq: 55 };

            synthGain = audioContext.createGain();
            synthGain.gain.setValueAtTime(isMuted ? 0 : currentVolume * 0.08, audioContext.currentTime);

            // Filtro passa-baixa analógico para sensação de subwoofer futurista
            const filter = audioContext.createBiquadFilter();
            filter.type = "lowpass";
            filter.frequency.setValueAtTime(140, audioContext.currentTime);

            synthOscillator = audioContext.createOscillator();
            synthOscillator.type = "triangle";
            synthOscillator.frequency.setValueAtTime(track.freq || 55, audioContext.currentTime);

            synthOscillator.connect(filter);
            filter.connect(synthGain);
            synthGain.connect(audioContext.destination);

            synthOscillator.start();
        } catch (_) {}
    }

    function togglePlayPause() {
        isPlaying = !isPlaying;
        const icon = $("play-icon");
        const eq = $("eq-visualizer");

        if (isPlaying) {
            if (icon) icon.textContent = "❚❚";
            if (eq) eq.style.opacity = "1";
            if (synthGain && audioContext) {
                synthGain.gain.linearRampToValueAtTime(isMuted ? 0 : currentVolume * 0.08, audioContext.currentTime + 0.1);
            }
        } else {
            if (icon) icon.textContent = "▶";
            if (eq) eq.style.opacity = "0.2";
            if (synthGain && audioContext) {
                synthGain.gain.linearRampToValueAtTime(0, audioContext.currentTime + 0.1);
            }
        }
    }

    function nextTrack() {
        currentTrackIndex = (currentTrackIndex + 1) % config.playlist.length;
        updateTrackDisplay();

        if (synthOscillator && audioContext) {
            const track = config.playlist[currentTrackIndex];
            synthOscillator.frequency.linearRampToValueAtTime(track.freq || 55, audioContext.currentTime + 0.2);
        }
    }

    function toggleMute() {
        isMuted = !isMuted;
        const muteIcon = $("mute-icon");

        if (isMuted) {
            if (muteIcon) muteIcon.textContent = "🔇";
            if (synthGain && audioContext) synthGain.gain.setValueAtTime(0, audioContext.currentTime);
        } else {
            if (muteIcon) muteIcon.textContent = "🔊";
            if (synthGain && audioContext && isPlaying) {
                synthGain.gain.setValueAtTime(currentVolume * 0.08, audioContext.currentTime);
            }
        }
    }

    function setVolume(val) {
        currentVolume = parseFloat(val) || 0;
        if (!isMuted && synthGain && audioContext && isPlaying) {
            synthGain.gain.setValueAtTime(currentVolume * 0.08, audioContext.currentTime);
        }
    }

    // =========================================================================
    // 5. TELEMETRIA CEF & PROGRESSO REAL (OPEN77 SHELL EVENT INTEGRATION)
    // =========================================================================

    function setupProgressTelemetry() {
        // Receptor nativo CEF Open77
        if (window.Open77 && typeof window.Open77.on === "function") {
            window.Open77.on("progress", payload => {
                handleProgressEvent(payload);
            });

            window.Open77.on("server", payload => {
                if (payload && payload.name && $("server-title")) {
                    $("server-title").textContent = payload.name.toUpperCase();
                }
            });
        }

        // Listener secundário via postMessage para compatibilidade ampla
        window.addEventListener("message", event => {
            const data = event.data;
            if (!data) return;

            if (data.type === "progress" || data.phase) {
                handleProgressEvent(data);
            } else if (data.type === "server" && data.name && $("server-title")) {
                $("server-title").textContent = data.name.toUpperCase();
            }
        });

        // Simulação gradual suave enquanto o engine prepara a arena
        let simulatedFraction = 0.05;
        const simInterval = setInterval(() => {
            if (simulatedFraction < 0.90) {
                simulatedFraction += 0.015;
                updateProgressUI("CARREGANDO NIGHT CITY // ARENA", simulatedFraction);
            } else {
                clearInterval(simInterval);
            }
        }, 300);
    }

    function handleProgressEvent(payload) {
        if (!payload) return;
        const label = payload.label || payload.phase || "CARREGANDO ARENA";
        const fraction = typeof payload.fraction === "number" ? payload.fraction : (payload.progress || 0);
        updateProgressUI(label, fraction);
    }

    function updateProgressUI(label, fraction) {
        const clampedFraction = Math.max(0, Math.min(1, fraction));
        const percent = Math.round(clampedFraction * 100);

        if ($("load-phase-label")) {
            $("load-phase-label").textContent = String(label).toUpperCase();
        }

        if ($("load-percent")) {
            $("load-percent").textContent = percent + "%";
        }

        if ($("progress-fill")) {
            $("progress-fill").style.width = percent + "%";
        }

        const track = document.querySelector(".progress-track");
        if (track) {
            track.setAttribute("aria-valuenow", String(percent));
        }

        if ($("load-status-sub")) {
            if (percent < 30) {
                $("load-status-sub").textContent = "CARREGANDO RECURSOS & MANIFESTO";
            } else if (percent < 70) {
                $("load-status-sub").textContent = "ESTRUTURANDO MALHA DE NIGHT CITY & DADOS";
            } else if (percent < 98) {
                $("load-status-sub").textContent = "SINCRONIZANDO BIOMONITOR & SISTEMAS VITAIS";
            } else {
                $("load-status-sub").textContent = "PRONTO // ENTRANDO EM NIGHT CITY...";
            }
        }
    }

    // =========================================================================
    // 6. RETORNAR AO HUB (CANCELAR / DESCONECTAR)
    // =========================================================================

    function returnToHub() {
        const btn = $("btn-return-hub");
        if (btn) {
            btn.querySelector(".hub-label").textContent = "DESCONECTANDO...";
            btn.disabled = true;
        }

        // 1. Emite para Open77 Shell CEF se presente
        if (window.Open77 && typeof window.Open77.emit === "function") {
            try {
                window.Open77.emit("connection:cancel");
                window.Open77.emit("shell:launcher");
            } catch (_) {}
        }

        // 2. Fetch padrão NUI callback
        try {
            const resourceName = typeof GetParentResourceName === "function" ? GetParentResourceName() : "ls_loadscreen";
            fetch(`https://${resourceName}/cancel`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ action: "cancel" })
            }).catch(() => {});
        } catch (_) {}

        // 3. Fallback de postMessage para o frame pai
        window.parent.postMessage({ action: "cancel" }, "*");
    }

    // =========================================================================
    // 7. EVENT LISTENERS
    // =========================================================================

    function setupEventListeners() {
        // Botão Retornar ao Hub
        const btnHub = $("btn-return-hub");
        if (btnHub) {
            btnHub.addEventListener("click", returnToHub);
        }

        // Tecla ESC para Retornar ao Hub
        window.addEventListener("keydown", event => {
            if (event.key === "Escape") {
                returnToHub();
            }
        });

        // Controles de Áudio
        const btnPlay = $("btn-play-pause");
        if (btnPlay) btnPlay.addEventListener("click", togglePlayPause);

        const btnNext = $("btn-next-track");
        if (btnNext) btnNext.addEventListener("click", nextTrack);

        const btnMute = $("btn-mute-toggle");
        if (btnMute) btnMute.addEventListener("click", toggleMute);

        const volSlider = $("volume-slider");
        if (volSlider) {
            volSlider.addEventListener("input", e => setVolume(e.target.value));
        }

        setupProgressTelemetry();
    }

    // Inicialização
    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", loadConfiguration);
    } else {
        loadConfiguration();
    }
})();
