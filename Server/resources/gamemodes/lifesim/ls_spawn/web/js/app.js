/**
 * LIFESIM RP - Kiroshi Holographic Spawn Selector Controller
 * Path: ls_spawn/web/js/app.js
 * 
 * Gerenciador reativo da interface de seleção de spawn points:
 * 1. Renderização dinâmica da lista de locais públicos e última posição.
 * 2. Visualização topográfica holográfica animada em Canvas (Radar Grid).
 * 3. Síntese diegética de áudio Web Audio API (Cyberpunk SFX).
 * 4. Navegação ágil por teclado (Setas + Enter) ou mouse.
 * 5. Ponte bidirecional CEF com OPEN//77 (Open77.on / Open77.emit).
 */

(() => {
  "use strict";

  // ===========================================================================
  // ESTADO DA APLICAÇÃO
  // ===========================================================================
  let spawnsList = [];
  let filteredSpawns = [];
  let selectedSpawn = null;
  let activeFilter = "all";
  let timeoutTimer = null;
  let remainingSeconds = 120;
  let radarAnimId = null;

  // ===========================================================================
  // ELEMENTOS DOM
  // ===========================================================================
  const containerEl = document.getElementById("spawn-container");
  const spawnListEl = document.getElementById("spawn-list");
  const filterBtns = document.querySelectorAll(".filter-btn");
  const timeoutDisplayEl = document.getElementById("timeout-display");

  // Painel de Detalhes
  const detailBadgeEl = document.getElementById("detail-badge");
  const detailThreatEl = document.getElementById("detail-threat");
  const detailNameEl = document.getElementById("detail-name");
  const detailDistrictEl = document.getElementById("detail-district");
  const detailDescEl = document.getElementById("detail-description");
  const detailTransitTextEl = document.getElementById("detail-transit-text");
  const radarCoordsTextEl = document.getElementById("radar-coords-text");
  const btnConfirmSpawn = document.getElementById("btn-confirm-spawn");

  // Canvas
  const radarCanvas = document.getElementById("radar-canvas");
  const radarCtx = radarCanvas ? radarCanvas.getContext("2d") : null;

  // ===========================================================================
  // ÁUDIO DIEGÉTICO KIROSHI (Síntese Web Audio API)
  // ===========================================================================
  let audioCtx = null;
  function getAudioContext() {
    if (!audioCtx) {
      const AudioContextClass = window.AudioContext || window.webkitAudioContext;
      if (AudioContextClass) {
        audioCtx = new AudioContextClass();
      }
    }
    if (audioCtx && audioCtx.state === "suspended") {
      audioCtx.resume();
    }
    return audioCtx;
  }

  function playUiSound(type = "tick") {
    try {
      const ctx = getAudioContext();
      if (!ctx) return;

      const now = ctx.currentTime;
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);

      if (type === "tick") {
        osc.type = "sine";
        osc.frequency.setValueAtTime(800, now);
        osc.frequency.exponentialRampToValueAtTime(1400, now + 0.04);
        gain.gain.setValueAtTime(0.04, now);
        gain.gain.linearRampToValueAtTime(0.001, now + 0.04);
        osc.start(now);
        osc.stop(now + 0.04);
      } else if (type === "select") {
        osc.type = "triangle";
        osc.frequency.setValueAtTime(600, now);
        osc.frequency.linearRampToValueAtTime(1200, now + 0.08);
        gain.gain.setValueAtTime(0.06, now);
        gain.gain.linearRampToValueAtTime(0.001, now + 0.08);
        osc.start(now);
        osc.stop(now + 0.08);
      } else if (type === "confirm") {
        // Pulso energético potente de spawn
        const subOsc = ctx.createOscillator();
        const subGain = ctx.createGain();
        subOsc.type = "sawtooth";
        subOsc.frequency.setValueAtTime(180, now);
        subOsc.frequency.exponentialRampToValueAtTime(60, now + 0.35);
        subGain.gain.setValueAtTime(0.12, now);
        subGain.gain.linearRampToValueAtTime(0.001, now + 0.35);
        subOsc.connect(subGain);
        subGain.connect(ctx.destination);
        subOsc.start(now);
        subOsc.stop(now + 0.35);

        osc.type = "sine";
        osc.frequency.setValueAtTime(520, now);
        osc.frequency.exponentialRampToValueAtTime(1600, now + 0.25);
        gain.gain.setValueAtTime(0.08, now);
        gain.gain.linearRampToValueAtTime(0.001, now + 0.25);
        osc.start(now);
        osc.stop(now + 0.25);
      }
    } catch (_) {}
  }

  // ===========================================================================
  // RADAR HOLOGRÁFICO ANIMADO (CANVAS)
  // ===========================================================================
  let sweepAngle = 0;
  let pulseRadius = 10;

  function renderRadarFrame() {
    if (!radarCtx || !radarCanvas) return;
    const w = radarCanvas.width;
    const h = radarCanvas.height;
    const cx = w / 2;
    const cy = h / 2;

    radarCtx.clearRect(0, 0, w, h);

    // 1. Grid de fundo
    radarCtx.strokeStyle = "rgba(34, 216, 226, 0.08)";
    radarCtx.lineWidth = 1;
    const step = 28;
    for (let x = 0; x < w; x += step) {
      radarCtx.beginPath();
      radarCtx.moveTo(x, 0);
      radarCtx.lineTo(x, h);
      radarCtx.stroke();
    }
    for (let y = 0; y < h; y += step) {
      radarCtx.beginPath();
      radarCtx.moveTo(0, y);
      radarCtx.lineTo(w, y);
      radarCtx.stroke();
    }

    // 2. Círculos concêntricos de telemetria
    radarCtx.strokeStyle = "rgba(34, 216, 226, 0.2)";
    radarCtx.lineWidth = 1;
    [30, 60, 90, 120].forEach(r => {
      radarCtx.beginPath();
      radarCtx.arc(cx, cy, r, 0, Math.PI * 2);
      radarCtx.stroke();
    });

    // 3. Eixos de mira central
    radarCtx.strokeStyle = "rgba(34, 216, 226, 0.35)";
    radarCtx.beginPath();
    radarCtx.moveTo(cx - 15, cy);
    radarCtx.lineTo(cx + 15, cy);
    radarCtx.moveTo(cx, cy - 15);
    radarCtx.lineTo(cx, cy + 15);
    radarCtx.stroke();

    // 4. Varredura angular (Radar Sweep)
    sweepAngle = (sweepAngle + 0.035) % (Math.PI * 2);
    radarCtx.save();
    radarCtx.translate(cx, cy);
    radarCtx.rotate(sweepAngle);
    const grad = radarCtx.createLinearGradient(0, 0, 140, 0);
    grad.addColorStop(0, "rgba(34, 216, 226, 0.35)");
    grad.addColorStop(1, "rgba(34, 216, 226, 0)");
    radarCtx.fillStyle = grad;
    radarCtx.beginPath();
    radarCtx.moveTo(0, 0);
    radarCtx.arc(0, 0, 140, 0, 0.45);
    radarCtx.closePath();
    radarCtx.fill();
    radarCtx.restore();

    // 5. Pulso no alvo central
    pulseRadius = (pulseRadius + 0.6) % 36;
    radarCtx.strokeStyle = `rgba(34, 216, 226, ${1 - pulseRadius / 36})`;
    radarCtx.lineWidth = 1.5;
    radarCtx.beginPath();
    radarCtx.arc(cx, cy, pulseRadius, 0, Math.PI * 2);
    radarCtx.stroke();

    // 6. Ponto fixo do marcador
    radarCtx.fillStyle = "#22d8e2";
    radarCtx.beginPath();
    radarCtx.arc(cx, cy, 3.5, 0, Math.PI * 2);
    radarCtx.fill();

    radarAnimId = requestAnimationFrame(renderRadarFrame);
  }

  function startRadar() {
    if (radarAnimId) cancelAnimationFrame(radarAnimId);
    radarAnimId = requestAnimationFrame(renderRadarFrame);
  }

  function stopRadar() {
    if (radarAnimId) {
      cancelAnimationFrame(radarAnimId);
      radarAnimId = null;
    }
  }

  // ===========================================================================
  // ATUALIZAÇÃO DA INTERFACE E DETALHES
  // ===========================================================================

  function selectSpawnLocation(spawn) {
    if (!spawn) return;
    selectedSpawn = spawn;

    // Atualiza classes ativas na lista
    const allCards = spawnListEl.querySelectorAll(".spawn-card");
    allCards.forEach(card => {
      if (card.dataset.id === spawn.id) {
        card.classList.add("selected");
        card.scrollIntoView({ behavior: "smooth", block: "nearest" });
      } else {
        card.classList.remove("selected");
      }
    });

    // Atualiza Painel de Detalhes
    detailNameEl.textContent = spawn.name;
    detailDistrictEl.textContent = `${spawn.district || "Night City"} // ${spawn.subdistrict || "Setor Urbano"}`;
    detailBadgeEl.textContent = spawn.badge || "LOCAL PÚBLICO";
    detailDescEl.textContent = spawn.description || "Setor público monitorado pela rede civil de Night City.";
    detailTransitTextEl.textContent = spawn.transitInfo || "Linhas integradas de transporte público e vias de acesso rápido.";

    // Classificação de perigo
    detailThreatEl.className = "threat-badge";
    const rating = spawn.threatRating || 1;
    if (rating === 1) {
      detailThreatEl.classList.add("safe");
      detailThreatEl.textContent = `AMEAÇA: ${spawn.threatLevel || "BAIXA"}`;
    } else if (rating === 2 || rating === 3) {
      detailThreatEl.classList.add("medium");
      detailThreatEl.textContent = `AMEAÇA: ${spawn.threatLevel || "MODERADA"}`;
    } else {
      detailThreatEl.classList.add("danger");
      detailThreatEl.textContent = `AMEAÇA: ${spawn.threatLevel || "ELEVADA"}`;
    }

    // Coordenadas geodésicas
    if (spawn.coords && spawn.coords.x !== undefined) {
      const x = Number(spawn.coords.x).toFixed(2);
      const y = Number(spawn.coords.y).toFixed(2);
      const z = Number(spawn.coords.z).toFixed(2);
      radarCoordsTextEl.textContent = `LOC: X ${x} | Y ${y} | Z ${z}`;
    } else {
      radarCoordsTextEl.textContent = "LOC: SENSOR ATIVO // NCE-SAT";
    }

    playUiSound("select");
  }

  function renderSpawnCards() {
    spawnListEl.innerHTML = "";

    filteredSpawns.forEach((spawn, index) => {
      const card = document.createElement("div");
      card.className = "spawn-card";
      card.dataset.id = spawn.id;
      if (selectedSpawn && selectedSpawn.id === spawn.id) {
        card.classList.add("selected");
      }

      const threatRating = spawn.threatRating || 1;
      const threatClass = `threat-${threatRating}`;

      card.innerHTML = `
        <div class="card-top-row">
          <span class="card-badge">${spawn.badge || "PÚBLICO"}</span>
          <span class="card-threat-dot ${threatClass}" title="Nível de Ameaça: ${spawn.threatLevel}"></span>
        </div>
        <div class="card-name">${spawn.name}</div>
        <div class="card-district">${spawn.district} // ${spawn.subdistrict}</div>
      `;

      card.addEventListener("mouseenter", () => playUiSound("tick"));
      card.addEventListener("click", () => selectSpawnLocation(spawn));

      spawnListEl.appendChild(card);
    });

    // Se nenhum estiver selecionado ou o atual não estiver na lista filtrada, seleciona o primeiro
    if (filteredSpawns.length > 0) {
      const exists = filteredSpawns.some(s => selectedSpawn && s.id === selectedSpawn.id);
      if (!exists) {
        selectSpawnLocation(filteredSpawns[0]);
      }
    }
  }

  function applyFilter(category) {
    activeFilter = category;
    filterBtns.forEach(btn => {
      btn.classList.toggle("active", btn.dataset.filter === category);
    });

    if (category === "all") {
      filteredSpawns = [...spawnsList];
    } else {
      filteredSpawns = spawnsList.filter(s => s.category === category);
    }

    renderSpawnCards();
    playUiSound("tick");
  }

  // ===========================================================================
  // CONTROLE DO TIMER DE TIMEOUT
  // ===========================================================================

  function startTimeoutCountdown(seconds = 120) {
    remainingSeconds = seconds;
    if (timeoutTimer) clearInterval(timeoutTimer);

    timeoutDisplayEl.textContent = `TIMEOUT: ${remainingSeconds}s`;
    timeoutTimer = setInterval(() => {
      remainingSeconds--;
      if (remainingSeconds <= 0) {
        clearInterval(timeoutTimer);
        timeoutDisplayEl.textContent = "TIMEOUT // AUTO-SPAWN";
        confirmSpawnSelection();
      } else {
        timeoutDisplayEl.textContent = `TIMEOUT: ${remainingSeconds}s`;
      }
    }, 1000);
  }

  function stopTimeoutCountdown() {
    if (timeoutTimer) {
      clearInterval(timeoutTimer);
      timeoutTimer = null;
    }
  }

  // ===========================================================================
  // CONFIRMAÇÃO DE SPAWN
  // ===========================================================================

  function confirmSpawnSelection() {
    if (!selectedSpawn) {
      if (filteredSpawns.length > 0) {
        selectedSpawn = filteredSpawns[0];
      } else if (spawnsList.length > 0) {
        selectedSpawn = spawnsList[0];
      }
    }

    if (!selectedSpawn) return;

    playUiSound("confirm");
    btnConfirmSpawn.disabled = true;
    btnConfirmSpawn.classList.add("loading");
    btnConfirmSpawn.querySelector(".btn-text").textContent = "MATERIALIZANDO // SINAPSE ATIVA...";

    if (window.Open77) {
      window.Open77.emit("spawn:select", {
        spawnId: selectedSpawn.id
      });

      // Timeout de segurança: fecha o modal automaticamente caso a confirmação de rede atrase ou caia
      setTimeout(() => {
        closeSpawnModal();
      }, 1500);
    } else {
      console.log("[ls_spawn] Mock spawn confirmado para:", selectedSpawn.id);
      setTimeout(() => {
        closeSpawnModal();
      }, 1000);
    }
  }

  // ===========================================================================
  // CICLO DE VIDA DO MODAL
  // ===========================================================================

  function openSpawnModal(payload) {
    btnConfirmSpawn.disabled = false;
    btnConfirmSpawn.classList.remove("loading");
    btnConfirmSpawn.querySelector(".btn-text").textContent = "ESTABELECER SINAPSE // SPAWN";

    if (payload && Array.isArray(payload.spawns)) {
      spawnsList = payload.spawns;
    }

    activeFilter = "all";
    filterBtns.forEach(btn => btn.classList.toggle("active", btn.dataset.filter === "all"));
    filteredSpawns = [...spawnsList];

    renderSpawnCards();

    // Seleciona o primeiro da lista por padrão
    if (filteredSpawns.length > 0) {
      selectSpawnLocation(filteredSpawns[0]);
    }

    containerEl.classList.remove("hidden");
    startRadar();
    startTimeoutCountdown(payload && payload.timeoutSec ? payload.timeoutSec : 120);

    playUiSound("select");
  }

  function closeSpawnModal() {
    containerEl.classList.add("hidden");
    btnConfirmSpawn.disabled = false;
    btnConfirmSpawn.classList.remove("loading");
    btnConfirmSpawn.querySelector(".btn-text").textContent = "ESTABELECER SINAPSE // SPAWN";
    stopRadar();
    stopTimeoutCountdown();
  }

  // ===========================================================================
  // NAVEGAÇÃO POR TECLADO
  // ===========================================================================

  window.addEventListener("keydown", (e) => {
    if (containerEl.classList.contains("hidden")) return;

    if (e.key === "ArrowDown") {
      e.preventDefault();
      if (filteredSpawns.length === 0) return;
      let currentIndex = filteredSpawns.findIndex(s => selectedSpawn && s.id === selectedSpawn.id);
      let nextIndex = (currentIndex + 1) % filteredSpawns.length;
      selectSpawnLocation(filteredSpawns[nextIndex]);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      if (filteredSpawns.length === 0) return;
      let currentIndex = filteredSpawns.findIndex(s => selectedSpawn && s.id === selectedSpawn.id);
      let prevIndex = (currentIndex - 1 + filteredSpawns.length) % filteredSpawns.length;
      selectSpawnLocation(filteredSpawns[prevIndex]);
    } else if (e.key === "Enter") {
      e.preventDefault();
      confirmSpawnSelection();
    }
  });

  // Filtros
  filterBtns.forEach(btn => {
    btn.addEventListener("click", () => {
      applyFilter(btn.dataset.filter);
    });
  });

  // Botão de Confirmação
  btnConfirmSpawn.addEventListener("click", confirmSpawnSelection);

  // ===========================================================================
  // INTEGRAÇÃO COM A PONTE OPEN//77 (CEF)
  // ===========================================================================

  if (window.Open77) {
    window.Open77.on("spawn:open", (payload) => {
      openSpawnModal(payload);
    });
    window.Open77.on("spawn:close", () => {
      closeSpawnModal();
    });

    window.Open77.ready();
    window.Open77.emit("ls:spawn:ready", { version: "0.1.0" });
  }

  // ===========================================================================
  // MOCK PARA TESTE E VALIDAÇÃO LOCAL INDEPENDENTE
  // ===========================================================================
  if (!window.Open77) {
    console.log("[ls_spawn] Executando em ambiente de teste autônomo local.");
    const mockSpawns = [
      {
        id: "h10_atrium",
        name: "Megabuilding H10 - Pátio Central",
        district: "Watson",
        subdistrict: "Little China",
        badge: "MEGABUILDING",
        threatLevel: "Baixo (Área Civil)",
        threatRating: 1,
        category: "megabuilding",
        description: "O monumental atrium central do Megabuilding H10. Ponto nevrálgico de Watson com lojas de conveniência, ripperdocs credenciados e terminais financeiros da Night City Net.",
        transitInfo: "Acesso direto a elevadores residenciais e linhas do NCART.",
        coords: { x: -1355.2, y: 1275.5, z: 110.5 }
      },
      {
        id: "h8_japantown",
        name: "Megabuilding H8 - Clouds Terrace",
        district: "Westbrook",
        subdistrict: "Japantown",
        badge: "MEGABUILDING",
        threatLevel: "Médio (Tyger Claws / Entretenimento)",
        threatRating: 2,
        category: "megabuilding",
        description: "Megaestrutura icônica de entretenimento e habitação de Japantown. Lar do famoso clube Clouds, cercado por pontes aéreas e letreiros em néon.",
        transitInfo: "Conexão rápida com os viadutos suspensos de Westbrook.",
        coords: { x: -1120.0, y: 350.0, z: 32.0 }
      },
      {
        id: "corpo_plaza",
        name: "Arasaka Corpo Plaza",
        district: "City Center",
        subdistrict: "Corpo Plaza",
        badge: "METRÓPOLE",
        threatLevel: "Controlado (Segurança Máxima Arasaka)",
        threatRating: 2,
        category: "metropolis",
        description: "O coração financeiro e geopolítico de Night City. Arranha-céus colossais da Arasaka, Militech e Kang Tao circundam uma praça monumental vigiada por drones de combate.",
        transitInfo: "Terminais de transporte corporativo de alta velocidade.",
        coords: { x: -200.5, y: -120.3, z: 15.0 }
      },
      {
        id: "kabuki_roundabout",
        name: "Mercado Noturno de Kabuki",
        district: "Watson",
        subdistrict: "Kabuki",
        badge: "PRAÇA PÚBLICA",
        threatLevel: "Médio (Submundo / Mercado Clandestino)",
        threatRating: 2,
        category: "plaza",
        description: "Labirinto pulsante em vários andares com barracas de ramen sintético, modders de garagem e comércio informal sob néon denso.",
        transitInfo: "Acesso imediato às vias secundárias e becos de Watson.",
        coords: { x: -1180.0, y: 1450.0, z: 120.0 }
      },
      {
        id: "japantown_cherry",
        name: "Cherry Blossom Market",
        district: "Westbrook",
        subdistrict: "Japantown",
        badge: "PRAÇA CULTURAL",
        threatLevel: "Baixo / Moderado (Ponto Turístico)",
        threatRating: 1,
        category: "plaza",
        description: "A praça mais deslumbrante de Westbrook. Árvores holográficas de cerejeira em flor iluminam fontes cibernéticas e pavilhões gastronômicos.",
        transitInfo: "Praça de pedestres com paradas de táxi Delamain nas proximidades.",
        coords: { x: -1442.2, y: 127.4, z: 18.0 }
      },
      {
        id: "glen_city_hall",
        name: "City Hall Plaza - The Glen",
        district: "Heywood",
        subdistrict: "The Glen",
        badge: "CENTRO CÍVICO",
        threatLevel: "Baixo (Distrito Governamental)",
        threatRating: 1,
        category: "plaza",
        description: "Grande praça cívica diante da prefeitura de Night City. Ampla área aberta com palmeiras cibernéticas e arquitetura neo-brutalista de Heywood.",
        transitInfo: "Hub central de transporte rodoviário e linhas metropolitanas.",
        coords: { x: -800.0, y: -850.0, z: 14.5 }
      },
      {
        id: "pacifica_mall",
        name: "Grand Imperial Mall Plaza",
        district: "Pacifica",
        subdistrict: "Coastview",
        badge: "ZONA LIVRE",
        threatLevel: "Elevado (Área Sem Lei / Voodoo Boys)",
        threatRating: 4,
        category: "metropolis",
        description: "Esqueleto de shopping center monumental abandonado na costa sul. Território autônomo dominado pelos netrunners dos Voodoo Boys.",
        transitInfo: "Zona não atendida por transporte público oficial.",
        coords: { x: -1716.4, y: -2421.3, z: 62.6 }
      },
      {
        id: "last_position",
        name: "Última Conexão do Biochip",
        district: "Watson",
        subdistrict: "Memória Biomonitor",
        badge: "PERSISTENTE",
        threatLevel: "Seguro",
        threatRating: 1,
        category: "all",
        description: "Retomar sua consciência e atividade exatamente nas coordenadas onde seu biomonitor transmitiu o último pulso antes de desconectar.",
        transitInfo: "Restauração de coordenadas geodésicas gravadas em nuvem.",
        coords: { x: -1355.2, y: 1275.5, z: 110.5 }
      }
    ];

    openSpawnModal({ spawns: mockSpawns, timeoutSec: 120 });
  }
})();
