/**
 * KIROSHI OPTICS // SPATIAL POSITIONING SCANNER CONTROLLER
 * Path: open77_coords/web/js/app.js
 */

(() => {
  "use strict";

  let spatialData = {
    position: { x: 0, y: 0, z: 0 },
    head: { forwardX: 0, forwardY: 0, forwardZ: 0, boneX: 0, boneY: 0, boneZ: 0, pitch: 0 },
    yaw: 0,
    heading: 0
  };

  let activeFormat = "lua-table";
  let activeDecimals = 2;

  // Elementos do DOM
  const valX = document.getElementById("val-x");
  const valY = document.getElementById("val-y");
  const valZ = document.getElementById("val-z");
  const valHeading = document.getElementById("val-heading");
  const valHeadForward = document.getElementById("val-head-forward");
  const valHeadBone = document.getElementById("val-head-bone");
  const outputCode = document.getElementById("output-code");
  const formatDisplayTag = document.getElementById("format-display-tag");
  const toastEl = document.getElementById("copy-toast");

  const btnClose = document.getElementById("btn-close");
  const btnRefresh = document.getElementById("btn-refresh");
  const btnCopy = document.getElementById("btn-copy");

  const precBtns = document.querySelectorAll(".prec-btn");
  const formatChips = document.querySelectorAll(".chip-btn");

  // ===========================================================================
  // ÁUDIO SINTETIZADO KIROSHI (Web Audio API)
  // ===========================================================================
  let audioCtx = null;
  function playCyberBeep(freq = 880, duration = 0.05, type = "sine") {
    try {
      if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      if (audioCtx.state === "suspended") audioCtx.resume();
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.type = type;
      osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
      gain.gain.setValueAtTime(0.04, audioCtx.currentTime);
      gain.gain.linearRampToValueAtTime(0.001, audioCtx.currentTime + duration);
      osc.connect(gain);
      gain.connect(audioCtx.destination);
      osc.start();
      osc.stop(audioCtx.currentTime + duration);
    } catch (_) {}
  }

  // ===========================================================================
  // FORMATAÇÃO DE STRINGS
  // ===========================================================================
  function n(val) {
    const num = Number(val) || 0;
    return num.toFixed(activeDecimals);
  }

  function generateFormattedCode() {
    const p = spatialData.position;
    const h = spatialData.head;
    const head = spatialData.heading;

    switch (activeFormat) {
      case "lua-table":
        formatDisplayTag.textContent = "FORMATO SELECIONADO: LUA CONFIG TABLE (ls_housing/shop)";
        return `doorCoords = {\n    x = ${n(p.x)},\n    y = ${n(p.y)},\n    z = ${n(p.z)},\n    heading = ${n(head)},\n    radius = 2.5\n}`;

      case "vec4":
        formatDisplayTag.textContent = "FORMATO SELECIONADO: LUA VECTOR4 (x, y, z, heading)";
        return `vec4(${n(p.x)}, ${n(p.y)}, ${n(p.z)}, ${n(head)})`;

      case "vec3":
        formatDisplayTag.textContent = "FORMATO SELECIONADO: LUA VECTOR3 (x, y, z)";
        return `vec3(${n(p.x)}, ${n(p.y)}, ${n(p.z)})`;

      case "polyzone":
        formatDisplayTag.textContent = "FORMATO SELECIONADO: POLYZONE POINT 2D ({ x = ..., y = ... })";
        return `{ x = ${n(p.x)}, y = ${n(p.y)} }, -- Z: ${n(p.z)}`;

      case "open77-marker":
        formatDisplayTag.textContent = "FORMATO SELECIONADO: OPEN77 GROUND MARKER SPEC";
        return `{\n    position = { x = ${n(p.x)}, y = ${n(p.y)}, z = ${n(p.z)} },\n    heading = ${n(head)},\n    radius = 1.6,\n    shape = "ring",\n    style = "objective",\n    color = { 0, 255, 157, 210 }\n}`;

      case "spawner-npc":
        formatDisplayTag.textContent = "FORMATO SELECIONADO: NPC / PED SPAWNER + HEAD LOOK";
        return `{\n    coords = { x = ${n(p.x)}, y = ${n(p.y)}, z = ${n(p.z)} },\n    heading = ${n(head)},\n    headForward = { x = ${n(h.forwardX)}, y = ${n(h.forwardY)}, z = ${n(h.forwardZ)} },\n    pitch = ${n(h.pitch)}\n}`;

      case "json":
        formatDisplayTag.textContent = "FORMATO SELECIONADO: JSON DATA OBJECT";
        return JSON.stringify({
          position: { x: Number(n(p.x)), y: Number(n(p.y)), z: Number(n(p.z)) },
          heading: Number(n(head)),
          yaw: Number(n(spatialData.yaw)),
          headForward: { x: Number(n(h.forwardX)), y: Number(n(h.forwardY)), z: Number(n(h.forwardZ)) },
          headBone: { x: Number(n(h.boneX)), y: Number(n(h.boneY)), z: Number(n(h.boneZ)) }
        }, null, 2);

      case "raw-csv":
        formatDisplayTag.textContent = "FORMATO SELECIONADO: RAW CSV (X, Y, Z, HEADING)";
        return `${n(p.x)}, ${n(p.y)}, ${n(p.z)}, ${n(head)}`;

      default:
        return `${n(p.x)}, ${n(p.y)}, ${n(p.z)}`;
    }
  }

  function updateUI() {
    const p = spatialData.position;
    const h = spatialData.head;
    const head = spatialData.heading;

    valX.textContent = n(p.x);
    valY.textContent = n(p.y);
    valZ.textContent = n(p.z);
    valHeading.textContent = `${n(head)}°`;

    valHeadForward.textContent = `fx: ${n(h.forwardX)}, fy: ${n(h.forwardY)}, fz: ${n(h.forwardZ)} (Pitch: ${n(h.pitch)}°)`;
    valHeadBone.textContent = `hx: ${n(h.boneX)}, hy: ${n(h.boneY)}, hz: ${n(h.boneZ)}`;

    outputCode.value = generateFormattedCode();
  }

  // ===========================================================================
  // INTERAÇÕES E CLIPBOARD
  // ===========================================================================
  function showToast(msg) {
    if (!toastEl) return;
    toastEl.querySelector(".toast-text").textContent = msg;
    toastEl.classList.remove("hidden");
    setTimeout(() => {
      toastEl.classList.add("hidden");
    }, 2800);
  }

  async function copyToClipboard() {
    const text = outputCode.value;
    if (!text) return;

    let copied = false;

    // 1. Tenta API do navegador (Clipboard API)
    if (navigator.clipboard && navigator.clipboard.writeText) {
      try {
        await navigator.clipboard.writeText(text);
        copied = true;
      } catch (_) {}
    }

    // 2. Fallback de textarea select + execCommand
    if (!copied) {
      try {
        outputCode.select();
        outputCode.setSelectionRange(0, 99999);
        document.execCommand("copy");
        copied = true;
      } catch (_) {}
    }

    // 3. Ponte nativa Open77 Clipboard
    if (window.Open77) {
      window.Open77.emit("coords:copyNative", { text: text });
    }

    playCyberBeep(1200, 0.08, "triangle");
    showToast("✓ COORDENADA COPIADA PARA A ÁREA DE TRANSFERÊNCIA!");
  }

  function closeModal() {
    playCyberBeep(600, 0.04);
    if (window.Open77) {
      window.Open77.emit("coords:close");
    }
  }

  function refreshCoords() {
    playCyberBeep(950, 0.05);
    if (window.Open77) {
      window.Open77.emit("coords:refresh");
    }
  }

  // ===========================================================================
  // EVENT LISTENERS
  // ===========================================================================
  btnCopy.addEventListener("click", copyToClipboard);
  btnClose.addEventListener("click", closeModal);
  btnRefresh.addEventListener("click", refreshCoords);

  // Seleção de Chips de Formato
  formatChips.forEach(chip => {
    chip.addEventListener("click", () => {
      formatChips.forEach(c => c.classList.remove("active"));
      chip.classList.add("active");
      activeFormat = chip.dataset.format;
      playCyberBeep(800, 0.03);
      updateUI();
    });
  });

  // Alternador de Precisão Decimal
  precBtns.forEach(btn => {
    btn.addEventListener("click", () => {
      precBtns.forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      activeDecimals = parseInt(btn.dataset.decimals, 10) || 2;
      playCyberBeep(850, 0.03);
      updateUI();
    });
  });

  // Tecla ESC para fechar
  window.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      closeModal();
    }
  });

  // ===========================================================================
  // INTEGRAÇÃO COM OPEN//77
  // ===========================================================================
  if (window.Open77) {
    window.Open77.on("coords:setData", (data) => {
      if (!data) return;
      spatialData = data;
      updateUI();
      playCyberBeep(1000, 0.06);
    });

    // Notifica que a interface terminou de carregar no CEF
    window.Open77.emit("coords:ready");
  } else {
    // Modo de visualização de desenvolvimento (Mock local)
    spatialData = {
      position: { x: -1402.94, y: 1272.19, z: 111.075 },
      head: { forwardX: 0.951, forwardY: 0.309, forwardZ: 0.0, boneX: -1402.94, boneY: 1272.19, boneZ: 112.78, pitch: 0.0 },
      yaw: 18.0005,
      heading: 18.0
    };
    updateUI();
  }
})();
