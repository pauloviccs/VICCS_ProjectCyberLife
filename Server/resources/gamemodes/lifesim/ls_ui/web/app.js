/**
 * LIFESIM RP - Native Cyberpunk 2077 HUD Controller (Kiroshi Biomonitor)
 * Path: ls_ui/web/app.js
 * Gerenciador reativo de telemetria biológica, posicionamento livre (draggable),
 * persistência em localStorage e menu de configurações diegético (/biomonitor).
 */

(() => {
    "use strict";

    // =========================================================================
    // ELEMENTOS DOM
    // =========================================================================
    const biomonitorEl = document.getElementById("biomonitor");
    const statusBadgeEl = document.getElementById("status-badge");
    const statusTextEl = document.getElementById("status-text");
    const telemetryStatusEl = document.getElementById("telemetry-status");
    const settingsModalEl = document.getElementById("settings-modal");
    const repositionToolbarEl = document.getElementById("reposition-toolbar");
    const damageVignetteEl = document.getElementById("damage-vignette");
    const economyCashEl = document.getElementById("economy-cash");
    const economyBankEl = document.getElementById("economy-bank");

    const btnCloseModal = document.getElementById("btn-close-modal");
    const btnCloseModalX = document.getElementById("btn-close-modal-x");
    const btnReposition = document.getElementById("btn-reposition");
    const btnResetPos = document.getElementById("btn-reset-pos");
    const btnSavePos = document.getElementById("btn-save-pos");
    const btnCancelPos = document.getElementById("btn-cancel-pos");

    // ATM TERMINAL ELEMENTOS
    const atmModalEl = document.getElementById("atm-modal");
    const atmCashValEl = document.getElementById("atm-cash-val");
    const atmBankValEl = document.getElementById("atm-bank-val");
    const atmFeedbackEl = document.getElementById("atm-feedback");
    const btnCloseAtm = document.getElementById("btn-close-atm");
    const btnCloseAtmX = document.getElementById("btn-close-atm-x");
    const btnAtmCustomWithdraw = document.getElementById("btn-atm-custom-withdraw");
    const btnAtmCustomDeposit = document.getElementById("btn-atm-custom-deposit");
    const btnAtmTransfer = document.getElementById("btn-atm-transfer");
    const atmCustomAmountEl = document.getElementById("atm-custom-amount");
    const atmTransferTargetEl = document.getElementById("atm-transfer-target");
    const atmTransferAmountEl = document.getElementById("atm-transfer-amount");

    // VENDING MACHINE ELEMENTOS
    const vendingModalEl = document.getElementById("vending-modal");
    const vendingCashValEl = document.getElementById("vending-cash-val");
    const vendingBankValEl = document.getElementById("vending-bank-val");
    const vendingFeedbackEl = document.getElementById("vending-feedback");
    const vendingGridEl = document.getElementById("vending-grid");
    const btnCloseVending = document.getElementById("btn-close-vending");
    const btnCloseVendingX = document.getElementById("btn-close-vending-x");

    // RIPPERDOC CLINIC ELEMENTOS
    const ripperdocModalEl = document.getElementById("ripperdoc-modal");
    const ripperFeedbackEl = document.getElementById("ripper-feedback");
    const ripperImplantsGridEl = document.getElementById("ripper-implants-grid");
    const ripperPharmaGridEl = document.getElementById("ripper-pharma-grid");
    const btnCloseRipperdoc = document.getElementById("btn-close-ripperdoc");
    const btnCloseRipperdocX = document.getElementById("btn-close-ripperdoc-x");
    const tabBtnCyberware = document.getElementById("tab-btn-cyberware");
    const tabBtnPharma = document.getElementById("tab-btn-pharma");
    const ripperPanelCyberware = document.getElementById("ripper-panel-cyberware");
    const ripperPanelPharma = document.getElementById("ripper-panel-pharma");

    // RIPPER DIAGNOSTIC LABELS
    const ripperDiagStabilityFill = document.getElementById("ripper-diag-stability-fill");
    const ripperDiagStabilityVal = document.getElementById("ripper-diag-stability-val");
    const ripperDiagHeatFill = document.getElementById("ripper-diag-heat-fill");
    const ripperDiagHeatVal = document.getElementById("ripper-diag-heat-val");
    const ripperDiagBlocker = document.getElementById("ripper-diag-blocker");
    const ripperDiagPsychosis = document.getElementById("ripper-diag-psychosis");
    const ripperDiagCount = document.getElementById("ripper-diag-count");
    const ripperDiagBank = document.getElementById("ripper-diag-bank");

    // =========================================================================
    // SINCRONIZAÇÃO DE VISIBILIDADE DO BIOMONITOR (Elimina overlap com modais)
    // =========================================================================
    function syncBiomonitorVisibilityWithModals() {
        if (!biomonitorEl) return;
        const isExternalTerminalActive = (
            (atmModalEl && !atmModalEl.classList.contains("hidden")) ||
            (vendingModalEl && !vendingModalEl.classList.contains("hidden")) ||
            (ripperdocModalEl && !ripperdocModalEl.classList.contains("hidden")) ||
            (inventoryModalEl && !inventoryModalEl.classList.contains("hidden"))
        );
        if (isExternalTerminalActive) {
            biomonitorEl.classList.add("modal-active-hidden");
        } else {
            biomonitorEl.classList.remove("modal-active-hidden");
        }
    }



    const vitalsMap = {
        hunger: {
            fill: document.querySelector('.vital-row[data-vital="hunger"] .vital-fill'),
            val: document.querySelector('.vital-row[data-vital="hunger"] .vital-val'),
            row: document.querySelector('.vital-row[data-vital="hunger"]'),
            critLower: 15
        },
        thirst: {
            fill: document.querySelector('.vital-row[data-vital="thirst"] .vital-fill'),
            val: document.querySelector('.vital-row[data-vital="thirst"] .vital-val'),
            row: document.querySelector('.vital-row[data-vital="thirst"]'),
            critLower: 15
        },
        energy: {
            fill: document.querySelector('.vital-row[data-vital="energy"] .vital-fill'),
            val: document.querySelector('.vital-row[data-vital="energy"] .vital-val'),
            row: document.querySelector('.vital-row[data-vital="energy"]'),
            critLower: 15
        },
        hygiene: {
            fill: document.querySelector('.vital-row[data-vital="hygiene"] .vital-fill'),
            val: document.querySelector('.vital-row[data-vital="hygiene"] .vital-val'),
            row: document.querySelector('.vital-row[data-vital="hygiene"]'),
            critLower: 15
        },
        stress: {
            fill: document.querySelector('.vital-row[data-vital="stress"] .vital-fill'),
            val: document.querySelector('.vital-row[data-vital="stress"] .vital-val'),
            row: document.querySelector('.vital-row[data-vital="stress"]'),
            critUpper: 80
        }
    };

    // =========================================================================
    // ÁUDIO DIEGÉTICO KIROSHI (Síntese Web Audio API)
    // =========================================================================
    let audioCtx = null;
    function playBeep(freq = 880, duration = 0.08, type = "sine") {
        try {
            if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            if (audioCtx.state === "suspended") audioCtx.resume();

            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.type = type;
            osc.frequency.setValueAtTime(freq, audioCtx.currentTime);

            gain.gain.setValueAtTime(0.04, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.0001, audioCtx.currentTime + duration);

            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.start();
            osc.stop(audioCtx.currentTime + duration);
        } catch (_) {}
    }

    let isAlertPlaying = false;
    function triggerAlertBeep() {
        if (isAlertPlaying) return;
        isAlertPlaying = true;
        playBeep(440, 0.12, "sawtooth");
        setTimeout(() => {
            playBeep(330, 0.15, "sawtooth");
            isAlertPlaying = false;
        }, 180);
    }

    // =========================================================================
    // PERSISTÊNCIA & POSICIONAMENTO ESPACIAL DO BIOMONITOR
    // =========================================================================
    const STORAGE_KEY = "kiroshi_biomonitor_pos";

    function applyPosition(left, top) {
        if (!biomonitorEl) return;
        const width = biomonitorEl.offsetWidth || 320;
        const height = biomonitorEl.offsetHeight || 280;

        const maxLeft = Math.max(0, window.innerWidth - width);
        const maxTop = Math.max(0, window.innerHeight - height);

        const clampedX = Math.max(0, Math.min(maxLeft, Math.round(left)));
        const clampedY = Math.max(0, Math.min(maxTop, Math.round(top)));

        biomonitorEl.style.left = `${clampedX}px`;
        biomonitorEl.style.top = `${clampedY}px`;
        biomonitorEl.style.bottom = "auto";
        biomonitorEl.style.right = "auto";
    }

    function applyDefaultPosition() {
        if (!biomonitorEl) return;
        biomonitorEl.style.left = "40px";
        biomonitorEl.style.bottom = "40px";
        biomonitorEl.style.top = "auto";
        biomonitorEl.style.right = "auto";
    }

    function loadSavedPosition() {
        try {
            const raw = localStorage.getItem(STORAGE_KEY);
            if (raw) {
                const pos = JSON.parse(raw);
                if (pos && typeof pos.left === "number" && typeof pos.top === "number") {
                    applyPosition(pos.left, pos.top);
                    return;
                }
            }
        } catch (e) {
            console.warn("[ls_ui] Falha ao carregar posição de localStorage:", e);
        }
        applyDefaultPosition();
    }

    // Carrega a posição salva imediatamente no boot
    loadSavedPosition();

    // =========================================================================
    // DRAGGABLE LOGIC & MODAL DE CONFIGURAÇÃO (/biomonitor)
    // =========================================================================
    let isRepositioning = false;
    let isDragging = false;
    let startMouseX = 0;
    let startMouseY = 0;
    let startElemLeft = 0;
    let startElemTop = 0;
    let backupPos = null;

    function openSettingsModal() {
        if (settingsModalEl) {
            settingsModalEl.classList.remove("hidden");
            playBeep(750, 0.09, "sine");
        }
    }

    function closeSettingsModal() {
        if (settingsModalEl) {
            const card = settingsModalEl.querySelector(".modal-card");
            if (card) card.style.transform = "";
            settingsModalEl.classList.add("hidden");
        }
        if (window.Open77) {
            Open77.emit("biomonitor:closeSettings");
        }
        playBeep(520, 0.07, "sine");
    }

    function startRepositionMode() {
        isRepositioning = true;
        backupPos = {
            left: biomonitorEl.offsetLeft,
            top: biomonitorEl.offsetTop
        };

        // Assegura estilo absoluto top/left
        applyPosition(biomonitorEl.offsetLeft, biomonitorEl.offsetTop);

        biomonitorEl.classList.add("repositioning");
        if (repositionToolbarEl) repositionToolbarEl.classList.remove("hidden");
        playBeep(880, 0.1, "triangle");
    }

    function stopRepositionMode(save = false) {
        isRepositioning = false;
        isDragging = false;
        biomonitorEl.classList.remove("repositioning");
        if (repositionToolbarEl) repositionToolbarEl.classList.add("hidden");

        if (save) {
            const currentPos = {
                left: biomonitorEl.offsetLeft,
                top: biomonitorEl.offsetTop
            };
            try {
                localStorage.setItem(STORAGE_KEY, JSON.stringify(currentPos));
            } catch (e) {
                console.warn("[ls_ui] Erro ao gravar posição:", e);
            }
            if (window.Open77) {
                Open77.emit("biomonitor:savePosition", currentPos);
            }
            playBeep(1040, 0.12, "sine");
        } else {
            if (backupPos) {
                applyPosition(backupPos.left, backupPos.top);
            }
            if (window.Open77) {
                Open77.emit("biomonitor:closeSettings");
            }
            playBeep(440, 0.08, "sine");
        }
    }

    // Drag listeners no Biomonitor
    biomonitorEl.addEventListener("mousedown", (e) => {
        if (!isRepositioning) return;
        isDragging = true;
        startMouseX = e.clientX;
        startMouseY = e.clientY;
        startElemLeft = biomonitorEl.offsetLeft;
        startElemTop = biomonitorEl.offsetTop;
        e.preventDefault();
    });

    window.addEventListener("mousemove", (e) => {
        if (!isDragging || !isRepositioning) return;
        const deltaX = e.clientX - startMouseX;
        const deltaY = e.clientY - startMouseY;
        applyPosition(startElemLeft + deltaX, startElemTop + deltaY);
    });

    window.addEventListener("mouseup", () => {
        if (isDragging) {
            isDragging = false;
        }
    });

    // Eventos dos botões do Modal
    if (btnReposition) {
        btnReposition.addEventListener("click", () => {
            if (settingsModalEl) settingsModalEl.classList.add("hidden");
            startRepositionMode();
        });
    }

    if (btnResetPos) {
        btnResetPos.addEventListener("click", () => {
            try {
                localStorage.removeItem(STORAGE_KEY);
            } catch (_) {}
            applyDefaultPosition();
            if (window.Open77) {
                Open77.emit("biomonitor:resetPosition");
            }
            playBeep(660, 0.1, "sawtooth");
        });
    }

    if (btnCloseModal) {
        btnCloseModal.addEventListener("click", closeSettingsModal);
    }
    if (btnCloseModalX) {
        btnCloseModalX.addEventListener("click", closeSettingsModal);
    }

    // Eventos da Toolbar de Reposicionamento
    if (btnSavePos) {
        btnSavePos.addEventListener("click", () => stopRepositionMode(true));
    }
    if (btnCancelPos) {
        btnCancelPos.addEventListener("click", () => stopRepositionMode(false));
    }

    // =========================================================================
    // ATUALIZAÇÃO REATIVA DE VITAIS & TELEMETRIA
    // =========================================================================
    function updateVitals(data = {}) {
        if (!data || typeof data !== "object") return;

        let hasCriticalCondition = false;

        for (const [key, vMeta] of Object.entries(vitalsMap)) {
            const rawVal = data[key];
            if (rawVal === undefined || rawVal === null) continue;

            const val = Math.max(0, Math.min(100, Number(rawVal) || 0));
            
            let pctText = "";
            if (val >= 99.95) {
                pctText = "100%";
            } else if (val <= 0.05) {
                pctText = "0%";
            } else {
                pctText = `${val.toFixed(1)}%`;
            }

            if (vMeta.val) vMeta.val.textContent = pctText;

            const scale = (val / 100).toFixed(3);
            if (vMeta.fill) {
                vMeta.fill.style.transform = `scaleX(${scale})`;
                vMeta.fill.style.setProperty("--scale", scale);
            }

            let isCrit = false;
            if (vMeta.critLower !== undefined && val <= vMeta.critLower) {
                isCrit = true;
            } else if (vMeta.critUpper !== undefined && val >= vMeta.critUpper) {
                isCrit = true;
            }

            if (vMeta.row) {
                vMeta.row.classList.toggle("critical", isCrit);
            }

            if (isCrit) hasCriticalCondition = true;
        }

        // Telemetria de esforço/atividade física
        if (telemetryStatusEl && data.activity) {
            const actStr = String(data.activity).toUpperCase();
            const multStr = Number(data.activityMult || 1.0).toFixed(1);
            telemetryStatusEl.textContent = `TELEMETRY: ${actStr} (x${multStr})`;
        }

        // Status geral Kiroshi
        if (statusBadgeEl && statusTextEl) {
            if (hasCriticalCondition) {
                statusBadgeEl.classList.add("alert");
                statusTextEl.textContent = "SYS: DEGRADED";
                triggerAlertBeep();
            } else if (data.activity === "sprinting" || data.activity === "combat") {
                statusBadgeEl.classList.remove("alert");
                statusTextEl.textContent = `SYS: HIGH LOAD (${data.activity.toUpperCase()})`;
            } else {
                statusBadgeEl.classList.remove("alert");
                statusTextEl.textContent = "SYS: NOMINAL";
            }
        }

        // Atualizar barras de vitais do personagem dentro do modal do inventário
        const charHpBar = document.getElementById("char-hp-bar");
        const charHpVal = document.getElementById("char-hp-val");
        const charStamBar = document.getElementById("char-stam-bar");
        const charStamVal = document.getElementById("char-stam-val");
        const charCyberBar = document.getElementById("char-cyber-bar");
        const charCyberVal = document.getElementById("char-cyber-val");

        if (charHpBar && charHpVal && (data.hunger !== undefined || data.thirst !== undefined)) {
            const hungerVal = Number(data.hunger !== undefined ? data.hunger : 100);
            const thirstVal = Number(data.thirst !== undefined ? data.thirst : 100);
            const avgVital = Math.max(0, Math.min(100, Math.round((hungerVal + thirstVal) / 2)));
            charHpBar.style.width = `${avgVital}%`;
            charHpVal.textContent = `${avgVital}%`;
        }
        if (charStamBar && charStamVal && data.energy !== undefined) {
            const energyVal = Math.max(0, Math.min(100, Math.round(Number(data.energy))));
            charStamBar.style.width = `${energyVal}%`;
            charStamVal.textContent = `${energyVal}%`;
        }
        if (charCyberBar && charCyberVal && data.stress !== undefined) {
            const stressVal = Number(data.stress);
            const cyberRes = Math.max(0, Math.min(100, Math.round(100 - stressVal)));
            charCyberBar.style.width = `${cyberRes}%`;
            charCyberVal.textContent = `${cyberRes}%`;
        }
    }

    // =========================================================================
    // ALERTA DE DANO BIOLÓGICO (DESIDRATAÇÃO / INANIÇÃO A 0%)
    // =========================================================================
    let damageVignetteTimeout = null;
    function triggerDamageAlert(alertData) {
        if (!damageVignetteEl) return;

        damageVignetteEl.classList.add("active");
        triggerAlertBeep();

        if (statusBadgeEl && statusTextEl) {
            statusBadgeEl.classList.add("alert");
            statusTextEl.textContent = "SYS: VITAL FAILURE";
        }

        if (damageVignetteTimeout) clearTimeout(damageVignetteTimeout);
        damageVignetteTimeout = setTimeout(() => {
            damageVignetteEl.classList.remove("active");
        }, 2200);
    }

    function setVisibility(visible) {
        if (!biomonitorEl) return;
        biomonitorEl.classList.toggle("hidden", !visible);
    }

    // =========================================================================
    // TELEMETRIA FINANCEIRA (EURODÓLARES E$) & ATM KIOSK
    // =========================================================================
    let currentCash = 0;
    let currentBank = 0;
    let atmFeedbackTimer = null;

    function formatMoney(num) {
        const val = Math.floor(Number(num) || 0);
        return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    }

    function updateEconomy(data = {}) {
        if (!data || typeof data !== "object") return;
        if (data.cash !== undefined) {
            currentCash = Math.floor(Number(data.cash) || 0);
            if (economyCashEl) economyCashEl.textContent = formatMoney(currentCash);
            if (atmCashValEl) atmCashValEl.textContent = formatMoney(currentCash);
            if (vendingCashValEl) vendingCashValEl.textContent = formatMoney(currentCash);
        }
        if (data.bank !== undefined) {
            currentBank = Math.floor(Number(data.bank) || 0);
            if (economyBankEl) economyBankEl.textContent = formatMoney(currentBank);
            if (atmBankValEl) atmBankValEl.textContent = formatMoney(currentBank);
            if (vendingBankValEl) vendingBankValEl.textContent = formatMoney(currentBank);
            if (ripperDiagBank) ripperDiagBank.textContent = "E$ " + formatMoney(currentBank);
        }
    }


    function showAtmFeedback(msg, isSuccess = true) {
        if (!atmFeedbackEl) return;
        if (atmFeedbackTimer) clearTimeout(atmFeedbackTimer);

        atmFeedbackEl.textContent = msg;
        atmFeedbackEl.className = "atm-feedback " + (isSuccess ? "success" : "error");
        atmFeedbackEl.classList.remove("hidden");

        if (isSuccess) {
            playBeep(880, 0.08, "sine");
        } else {
            playBeep(300, 0.15, "sawtooth");
        }

        atmFeedbackTimer = setTimeout(() => {
            atmFeedbackEl.classList.add("hidden");
            atmFeedbackEl.textContent = "";
        }, 3500);
    }

    function openAtmModal(data = {}) {
        if (!atmModalEl) return;
        updateEconomy(data);
        atmModalEl.classList.remove("hidden");
        syncBiomonitorVisibilityWithModals();
        playBeep(660, 0.1, "sine");
        setTimeout(() => playBeep(880, 0.1, "sine"), 100);

        if (atmCustomAmountEl) atmCustomAmountEl.value = "";
        if (atmTransferTargetEl) atmTransferTargetEl.value = "";
        if (atmTransferAmountEl) atmTransferAmountEl.value = "";
        if (atmFeedbackEl) atmFeedbackEl.classList.add("hidden");
    }

    function closeAtmModal() {
        if (!atmModalEl) return;
        atmModalEl.classList.add("hidden");
        syncBiomonitorVisibilityWithModals();
        playBeep(440, 0.08, "sine");

        if (window.Open77) {
            Open77.emit("atm:close");
        }
    }

    function sendAtmAction(action, amount, target = null) {
        amount = Math.floor(Number(amount) || 0);
        if (amount <= 0) {
            showAtmFeedback("Valor informado inválido.", false);
            return;
        }

        playBeep(750, 0.06, "sine");

        if (window.Open77) {
            Open77.emit("atm:action", { action, amount, target });
        } else {
            // Mock local no navegador
            if (action === "withdraw") {
                if (currentBank < amount) {
                    showAtmFeedback("Saldo bancário insuficiente!", false);
                } else {
                    currentBank -= amount;
                    currentCash += amount;
                    updateEconomy({ cash: currentCash, bank: currentBank });
                    showAtmFeedback(`Saque de E$ ${formatMoney(amount)} efetuado!`, true);
                }
            } else if (action === "deposit") {
                if (currentCash < amount) {
                    showAtmFeedback("Dinheiro vivo insuficiente!", false);
                } else {
                    currentCash -= amount;
                    currentBank += amount;
                    updateEconomy({ cash: currentCash, bank: currentBank });
                    showAtmFeedback(`Depósito de E$ ${formatMoney(amount)} concluído!`, true);
                }
            } else if (action === "transfer") {
                if (currentBank < amount) {
                    showAtmFeedback("Saldo bancário insuficiente para transferência!", false);
                } else {
                    currentBank -= amount;
                    updateEconomy({ cash: currentCash, bank: currentBank });
                    showAtmFeedback(`Transferência de E$ ${formatMoney(amount)} enviada ao cidadão [${target}]!`, true);
                }
            }
        }
    }

    // BOTÕES QUICK WITHDRAW
    document.querySelectorAll(".atm-btn.quick-withdraw").forEach((btn) => {
        btn.addEventListener("click", () => {
            const amt = btn.getAttribute("data-amount");
            sendAtmAction("withdraw", amt);
        });
    });

    // BOTÕES QUICK DEPOSIT
    document.querySelectorAll(".atm-btn.quick-deposit").forEach((btn) => {
        btn.addEventListener("click", () => {
            const raw = btn.getAttribute("data-amount");
            const amt = raw === "all" ? currentCash : Number(raw);
            if (amt <= 0) {
                showAtmFeedback("Você não possui dinheiro em mãos para depositar.", false);
                return;
            }
            sendAtmAction("deposit", amt);
        });
    });

    // CUSTOM WITHDRAW / DEPOSIT
    if (btnAtmCustomWithdraw && atmCustomAmountEl) {
        btnAtmCustomWithdraw.addEventListener("click", () => {
            const val = atmCustomAmountEl.value;
            sendAtmAction("withdraw", val);
        });
    }

    if (btnAtmCustomDeposit && atmCustomAmountEl) {
        btnAtmCustomDeposit.addEventListener("click", () => {
            const val = atmCustomAmountEl.value;
            sendAtmAction("deposit", val);
        });
    }

    // TRANSFERÊNCIA
    if (btnAtmTransfer && atmTransferTargetEl && atmTransferAmountEl) {
        btnAtmTransfer.addEventListener("click", () => {
            const tgt = atmTransferTargetEl.value;
            const amt = atmTransferAmountEl.value;
            if (!tgt || Number(tgt) <= 0) {
                showAtmFeedback("Informe o ID válido do cidadão destinatário.", false);
                return;
            }
            sendAtmAction("transfer", amt, Number(tgt));
        });
    }

    // BOTÕES DE FECHAR ATM
    if (btnCloseAtm) btnCloseAtm.addEventListener("click", closeAtmModal);
    if (btnCloseAtmX) btnCloseAtmX.addEventListener("click", closeAtmModal);

    // =========================================================================
    // MÁQUINA DE VENDAS & CONVENIÊNCIA 24/7 (ALL-FOODS)
    // =========================================================================
    const VENDING_CATALOG = [
        { id: "burrito_xxl", name: "XXL All-Foods Burrito", cat: "food", price: 25, hunger: 35, thirst: -5, energy: 10 },
        { id: "spicy_ramen", name: "Kabuki Spicy Ramen", cat: "food", price: 45, hunger: 45, thirst: -10, energy: 15 },
        { id: "synth_burger", name: "Captain Caliente Burger", cat: "food", price: 30, hunger: 30, thirst: -4, energy: 8 },
        { id: "nicola_blue", name: "NiCola Blue", cat: "drink", price: 15, hunger: 2, thirst: 35, energy: 8 },
        { id: "spunky_monkey", name: "Spunky Monkey Energy", cat: "drink", price: 20, hunger: 0, thirst: 40, energy: 25 },
        { id: "real_water", name: "Night City Purified Water", cat: "drink", price: 10, hunger: 0, thirst: 50, energy: 5 },
        { id: "chromanticore", name: "Chromanticore Soda", cat: "drink", price: 12, hunger: 1, thirst: 30, energy: 10 },
        { id: "bounce_back_mk1", name: "Bounce-Back Mk.1 (Stim)", cat: "medical", price: 150, hunger: 0, thirst: 0, energy: 30 },
        { id: "wet_wipes", name: "Biotechnica Sanitizing Wipes", cat: "medical", price: 18, hunger: 0, thirst: 0, hygiene: 40 }
    ];

    let currentVendingCat = "all";
    let vendingFeedbackTimer = null;

    function renderVendingItems(filterCat = "all") {
        if (!vendingGridEl) return;
        currentVendingCat = filterCat;
        vendingGridEl.innerHTML = "";

        const filtered = VENDING_CATALOG.filter(it => filterCat === "all" || it.cat === filterCat);
        filtered.forEach(it => {
            const card = document.createElement("div");
            card.className = "vending-item-card";

            let statPills = "";
            if (it.hunger) statPills += `<span class="vending-stat-tag hunger">CAL ${it.hunger > 0 ? "+" : ""}${it.hunger}%</span>`;
            if (it.thirst) statPills += `<span class="vending-stat-tag thirst">H2O ${it.thirst > 0 ? "+" : ""}${it.thirst}%</span>`;
            if (it.energy) statPills += `<span class="vending-stat-tag energy">BAT ${it.energy > 0 ? "+" : ""}${it.energy}%</span>`;
            if (it.hygiene) statPills += `<span class="vending-stat-tag energy">BIO +${it.hygiene}%</span>`;

            card.innerHTML = `
                <div class="vending-item-header">
                    <span class="vending-item-name">${it.name}</span>
                    <span class="vending-item-price">E$ ${it.price}</span>
                </div>
                <div class="vending-item-badges">
                    ${statPills}
                </div>
                <div class="vending-item-actions">
                    <button class="vending-buy-btn cash" data-item="${it.id}" data-type="cash" type="button">PAGAR CASH</button>
                    <button class="vending-buy-btn bank" data-item="${it.id}" data-type="bank" type="button">PAGAR BANCO</button>
                </div>
            `;
            vendingGridEl.appendChild(card);
        });

        vendingGridEl.querySelectorAll(".vending-buy-btn").forEach(btn => {
            btn.addEventListener("click", () => {
                const itemKey = btn.getAttribute("data-item");
                const pType = btn.getAttribute("data-type");
                buyVendingItem(itemKey, pType);
            });
        });
    }

    function showVendingFeedback(msg, isSuccess = true) {
        if (!vendingFeedbackEl) return;
        if (vendingFeedbackTimer) clearTimeout(vendingFeedbackTimer);

        vendingFeedbackEl.textContent = msg;
        vendingFeedbackEl.className = "vending-feedback " + (isSuccess ? "success" : "error");
        vendingFeedbackEl.classList.remove("hidden");

        if (isSuccess) playBeep(880, 0.08, "sine");
        else playBeep(300, 0.15, "sawtooth");

        vendingFeedbackTimer = setTimeout(() => {
            vendingFeedbackEl.classList.add("hidden");
            vendingFeedbackEl.textContent = "";
        }, 3200);
    }

    function buyVendingItem(itemKey, pType = "cash") {
        const item = VENDING_CATALOG.find(i => i.id === itemKey);
        if (!item) return;

        playBeep(720, 0.08, "sine");
        if (window.Open77) {
            Open77.emit("vending:buy", { itemKey, paymentType: pType, price: item.price, label: item.name });
        } else {
            showVendingFeedback(`Dispensando '${item.name}' via ${pType.toUpperCase()}...`, true);
        }
    }

    function openVendingModal(data = {}) {
        if (!vendingModalEl) return;
        updateEconomy(data);
        renderVendingItems("all");
        vendingModalEl.classList.remove("hidden");
        syncBiomonitorVisibilityWithModals();
        playBeep(520, 0.1, "sine");
        setTimeout(() => playBeep(780, 0.1, "sine"), 100);
    }

    function closeVendingModal() {
        if (!vendingModalEl) return;
        vendingModalEl.classList.add("hidden");
        syncBiomonitorVisibilityWithModals();
        playBeep(440, 0.08, "sine");
        if (window.Open77) Open77.emit("vending:close");
    }

    document.querySelectorAll(".vending-cat-btn").forEach(btn => {
        btn.addEventListener("click", () => {
            document.querySelectorAll(".vending-cat-btn").forEach(b => b.classList.remove("active"));
            btn.classList.add("active");
            renderVendingItems(btn.getAttribute("data-cat"));
        });
    });

    if (btnCloseVending) btnCloseVending.addEventListener("click", closeVendingModal);
    if (btnCloseVendingX) btnCloseVendingX.addEventListener("click", closeVendingModal);

    // =========================================================================
    // CLÍNICA RIPPERDOC & CIBERWARE LAB (VIKTOR VECTOR)
    // =========================================================================
    const RIPPER_IMPLANTS = [
        { id: "kiroshi_optics_mk1", name: "Kiroshi Optics Mk.1", slot: "ocular", quality: "common", price: 1200, neuralCost: 6.0, heatBonus: 0.4, desc: "Visão tática digital com scanner biomonitor." },
        { id: "kiroshi_optics_mk2", name: "Kiroshi Optics Mk.2", slot: "ocular", quality: "rare", price: 3500, neuralCost: 10.0, heatBonus: 0.8, desc: "Zoom óptico aprimorado e análise de trajetórias." },
        { id: "kiroshi_optics_stalker", name: "Kiroshi 'Stalker' Mk.3", slot: "ocular", quality: "legendary", price: 12500, neuralCost: 18.0, heatBonus: 1.6, desc: "Penetração sensorial em espectro termográfico." },
        { id: "bioconductor_mk1", name: "Biocondutor Zetatech Mk.1", slot: "frontal_cortex", quality: "rare", price: 4200, neuralCost: 10.0, heatBonus: 0.6, desc: "Acelera resfriamento cibernético em 15%." },
        { id: "memory_boost_mk2", name: "Amplificador Dynalar", slot: "frontal_cortex", quality: "epic", price: 8500, neuralCost: 14.0, heatBonus: 0.9, desc: "Otimiza taxa de recuperação analítica." },
        { id: "second_heart_mk1", name: "Segundo Coração Moore", slot: "circulatory", quality: "legendary", price: 28000, neuralCost: 22.0, heatBonus: 1.5, desc: "Ressuscita usuário de parada cardíaca letal." },
        { id: "subdermal_armor_mk1", name: "Armadura Militech", slot: "integumentary", quality: "common", price: 2500, neuralCost: 7.0, heatBonus: 0.2, desc: "Malha de aramida tecida sob a epiderme." },
        { id: "optical_camo_mk1", name: "Camuflagem Arasaka", slot: "integumentary", quality: "legendary", price: 22000, neuralCost: 20.0, heatBonus: 2.0, desc: "Nanofibras de desvio de fótons (invisibilidade)." },
        { id: "militech_sandevistan_mk4", name: "Militech Sandevistan Mk.4", slot: "operating_sys", quality: "iconic", price: 35000, neuralCost: 28.0, heatBonus: 3.2, desc: "Desacelera 75% do mundo por 12s." },
        { id: "arasaka_cyberdeck_mk3", name: "Cyberdeck Arasaka Mk.3", slot: "operating_sys", quality: "epic", price: 16000, neuralCost: 18.0, heatBonus: 2.0, desc: "Processador de invasão de redes e daemons." },
        { id: "smart_link", name: "Smart Link Arasaka", slot: "hands", quality: "rare", price: 4500, neuralCost: 8.0, heatBonus: 0.4, desc: "Interface palmar para guiar armas inteligentes." },
        { id: "mantis_blades", name: "Lâminas Mantis Carbono", slot: "arms", quality: "epic", price: 15000, neuralCost: 18.0, heatBonus: 1.4, desc: "Lâminas retráteis ultra-afiadas nos antebraços." },
        { id: "gorilla_arms", name: "Braços de Gorila", slot: "arms", quality: "epic", price: 15000, neuralCost: 18.0, heatBonus: 1.2, desc: "Pistões de alta pressão para socos brutais." },
        { id: "reinforced_tendons", name: "Tendões Reforçados", slot: "legs", quality: "rare", price: 9000, neuralCost: 12.0, heatBonus: 0.5, desc: "Atuadores de nitrogênio para salto duplo." }
    ];

    const RIPPER_PHARMA = [
        { id: "neuroblocker_booster", name: "Injetor de Neurobloqueador", price: 250, desc: "30 min de supressão neural e contenção de psicose.", stab: "+15.0%", heat: "-1.5°C" },
        { id: "cryo_spray", name: "Spray Criogênico Craniano", price: 180, desc: "Arrefecimento imediato de -6.0°C em ciberópticos.", stab: "+5.0%", heat: "-6.0°C" },
        { id: "immuno_shot", name: "Ampola Imunossupressora", price: 190, desc: "Acalma o sistema biológico pós-cirúrgico por 15 min.", stab: "+10.0%", heat: "-0.8°C" }
    ];

    let currentRipperSlot = "all";
    let currentInstalledIds = new Set(["kiroshi_optics_mk1", "subdermal_armor_mk1"]);
    let ripperFeedbackTimer = null;

    function renderRipperImplants(slot = "all") {
        if (!ripperImplantsGridEl) return;
        currentRipperSlot = slot;
        ripperImplantsGridEl.innerHTML = "";

        const filtered = RIPPER_IMPLANTS.filter(i => slot === "all" || i.slot === slot);
        filtered.forEach(imp => {
            const isInstalled = currentInstalledIds.has(imp.id);
            const card = document.createElement("div");
            card.className = `implant-card ${imp.quality}`;

            card.innerHTML = `
                <div class="implant-header">
                    <span class="implant-title">${imp.name}</span>
                    <span class="implant-price">E$ ${formatMoney(imp.price)}</span>
                </div>
                <p class="implant-desc">${imp.desc}</p>
                <div class="implant-specs">
                    <span class="spec-pill neural">Custo Neural: -${imp.neuralCost}%</span>
                    <span class="spec-pill heat">Calor: +${imp.heatBonus}°C</span>
                </div>
                <button class="implant-btn ${isInstalled ? "installed" : ""}" data-id="${imp.id}" type="button">
                    ${isInstalled ? "INSTALADO NO CORPO" : "PROCEDIMENTO CIRÚRGICO"}
                </button>
            `;
            ripperImplantsGridEl.appendChild(card);
        });

        ripperImplantsGridEl.querySelectorAll(".implant-btn:not(.installed)").forEach(btn => {
            btn.addEventListener("click", () => {
                const id = btn.getAttribute("data-id");
                buyRipperImplant(id);
            });
        });
    }

    function renderRipperPharma() {
        if (!ripperPharmaGridEl) return;
        ripperPharmaGridEl.innerHTML = "";

        RIPPER_PHARMA.forEach(ph => {
            const card = document.createElement("div");
            card.className = "implant-card rare";
            card.innerHTML = `
                <div class="implant-header">
                    <span class="implant-title">${ph.name}</span>
                    <span class="implant-price">E$ ${formatMoney(ph.price)}</span>
                </div>
                <p class="implant-desc">${ph.desc}</p>
                <div class="implant-specs">
                    <span class="spec-pill neural">Estabilidade: ${ph.stab}</span>
                    <span class="spec-pill heat">Calor: ${ph.heat}</span>
                </div>
                <button class="implant-btn" data-pharma="${ph.id}" type="button">
                    ADQUIRIR & APLICAR DOSAGEM
                </button>
            `;
            ripperPharmaGridEl.appendChild(card);
        });

        ripperPharmaGridEl.querySelectorAll(".implant-btn").forEach(btn => {
            btn.addEventListener("click", () => {
                const pid = btn.getAttribute("data-pharma");
                buyRipperPharma(pid);
            });
        });
    }

    function showRipperFeedback(msg, isSuccess = true) {
        if (!ripperFeedbackEl) return;
        if (ripperFeedbackTimer) clearTimeout(ripperFeedbackTimer);

        ripperFeedbackEl.textContent = msg;
        ripperFeedbackEl.className = "ripper-feedback " + (isSuccess ? "success" : "error");
        ripperFeedbackEl.classList.remove("hidden");

        if (isSuccess) playBeep(880, 0.08, "sine");
        else playBeep(300, 0.15, "sawtooth");

        ripperFeedbackTimer = setTimeout(() => {
            ripperFeedbackEl.classList.add("hidden");
            ripperFeedbackEl.textContent = "";
        }, 3500);
    }

    function buyRipperImplant(implantId) {
        playBeep(640, 0.1, "sine");
        if (window.Open77) {
            Open77.emit("ripperdoc:buyImplant", { implantId });
        } else {
            showRipperFeedback(`Cirurgia de implante iniciada: ${implantId}`, true);
        }
    }

    function buyRipperPharma(pharmaId) {
        playBeep(640, 0.1, "sine");
        if (window.Open77) {
            Open77.emit("ripperdoc:buyPharma", { pharmaId });
        } else {
            showRipperFeedback(`Farmacêutico ${pharmaId} aplicado com sucesso!`, true);
        }
    }

    function updateRipperdocPatientDiag(data = {}) {
        if (data.stability !== undefined) {
            const st = Math.max(0, Math.min(100, Number(data.stability)));
            if (ripperDiagStabilityFill) ripperDiagStabilityFill.style.width = st + "%";
            if (ripperDiagStabilityVal) ripperDiagStabilityVal.textContent = st.toFixed(1) + "%";
        }
        if (data.heat !== undefined) {
            const ht = Number(data.heat);
            const pct = Math.max(0, Math.min(100, (ht - 35.0) * 10.0));
            if (ripperDiagHeatFill) ripperDiagHeatFill.style.width = pct + "%";
            if (ripperDiagHeatVal) ripperDiagHeatVal.textContent = ht.toFixed(1) + "°C";
        }
        if (data.blockerActive !== undefined && ripperDiagBlocker) {
            ripperDiagBlocker.textContent = data.blockerActive ? "ATIVO" : "EM FALTA";
            ripperDiagBlocker.style.color = data.blockerActive ? "#4FE3A9" : "#FF003C";
        }
        if (data.psychosis !== undefined && ripperDiagPsychosis) {
            ripperDiagPsychosis.textContent = data.psychosis ? "CRÍTICO" : "NOMINAL";
            ripperDiagPsychosis.style.color = data.psychosis ? "#FF003C" : "#4FE3A9";
        }
        if (data.implants && Array.isArray(data.implants)) {
            currentInstalledIds = new Set(data.implants.map(i => typeof i === "string" ? i : i.id));
            if (ripperDiagCount) ripperDiagCount.textContent = currentInstalledIds.size + " PEÇAS";
            renderRipperImplants(currentRipperSlot);
        }
    }

    function openRipperdocModal(data = {}) {
        if (!ripperdocModalEl) return;
        updateEconomy(data);
        updateRipperdocPatientDiag(data);
        renderRipperImplants("all");
        renderRipperPharma();

        ripperdocModalEl.classList.remove("hidden");
        syncBiomonitorVisibilityWithModals();
        playBeep(440, 0.12, "sine");
        setTimeout(() => playBeep(660, 0.12, "sine"), 120);
    }

    function closeRipperdocModal() {
        if (!ripperdocModalEl) return;
        ripperdocModalEl.classList.add("hidden");
        syncBiomonitorVisibilityWithModals();
        playBeep(330, 0.08, "sine");
        if (window.Open77) Open77.emit("ripperdoc:close");
    }

    if (tabBtnCyberware && tabBtnPharma) {
        tabBtnCyberware.addEventListener("click", () => {
            tabBtnCyberware.classList.add("active");
            tabBtnPharma.classList.remove("active");
            ripperPanelCyberware.classList.remove("hidden");
            ripperPanelPharma.classList.add("hidden");
        });
        tabBtnPharma.addEventListener("click", () => {
            tabBtnPharma.classList.add("active");
            tabBtnCyberware.classList.remove("active");
            ripperPanelPharma.classList.remove("hidden");
            ripperPanelCyberware.classList.add("hidden");
        });
    }

    document.querySelectorAll(".slot-filter-btn").forEach(btn => {
        btn.addEventListener("click", () => {
            document.querySelectorAll(".slot-filter-btn").forEach(b => b.classList.remove("active"));
            btn.classList.add("active");
            renderRipperImplants(btn.getAttribute("data-slot"));
        });
    });

    if (btnCloseRipperdoc) btnCloseRipperdoc.addEventListener("click", closeRipperdocModal);
    if (btnCloseRipperdocX) btnCloseRipperdocX.addEventListener("click", closeRipperdocModal);

    // =========================================================================
    // INVENTÁRIO & BANCADA DE CRAFTING KIROSHI
    // =========================================================================
    const inventoryModalEl = document.getElementById("inventory-modal");
    const btnCloseInv = document.getElementById("btn-close-inv");
    const btnCloseInvX = document.getElementById("btn-close-inv-x");
    const playerInventoryGrid = document.getElementById("player-inventory-grid");
    const bagWeightFill = document.getElementById("bag-weight-fill");
    const bagWeightText = document.getElementById("bag-weight-text");
    const bagSlotCount = document.getElementById("bag-slot-count");
    const invSearchInput = document.getElementById("inv-search-input");
    const btnClearSearch = document.getElementById("btn-clear-search");
    const invSortBtns = document.querySelectorAll(".inv-sort-btn");
    const radialLoadoutSlotsEl = document.getElementById("radial-loadout-slots");
    const tabBtnLoadout = document.getElementById("tab-btn-loadout");
    const tabBtnCrafting = document.getElementById("tab-btn-crafting");
    const tabBtnSecondary = document.getElementById("tab-btn-secondary");
    const sidePanelLoadout = document.getElementById("side-panel-loadout");
    const sidePanelCrafting = document.getElementById("side-panel-crafting");
    const sidePanelSecondary = document.getElementById("side-panel-secondary");
    const craftingRecipesList = document.getElementById("crafting-recipes-list");
    const recipeDetailImg = document.getElementById("recipe-detail-img");
    const recipeDetailTitle = document.getElementById("recipe-detail-title");
    const recipeDetailMeta = document.getElementById("recipe-detail-meta");
    const recipeDetailDesc = document.getElementById("recipe-detail-desc");
    const recipeReqsList = document.getElementById("recipe-reqs-list");
    const craftProgressBox = document.getElementById("craft-progress-box");
    const craftProgTimer = document.getElementById("craft-prog-timer");
    const craftProgFill = document.getElementById("craft-prog-fill");
    const btnCraftItem = document.getElementById("btn-craft-item");

    // WEAPON LOADOUT SLOTS
    const weaponSlotsEls = [
        document.getElementById("weapon-slot-1"),
        document.getElementById("weapon-slot-2"),
        document.getElementById("weapon-slot-3")
    ];

    // RADIAL MENU ELEMENTOS
    const radialOverlayEl = document.getElementById("radial-overlay");
    const radialSlicesGroup = document.getElementById("radial-slices-group");
    const radialSlotsLayer = document.getElementById("radial-slots-layer");
    const radialCoreIcon = document.getElementById("radial-core-icon");
    const radialCoreName = document.getElementById("radial-core-name");
    const radialCoreMeta = document.getElementById("radial-core-meta");

    // TOOLTIP ELEMENTOS
    const itemTooltipEl = document.getElementById("kiroshi-item-tooltip");
    const tooltipHeroBox = document.getElementById("tooltip-hero-box");
    const tooltipHeroImg = document.getElementById("tooltip-hero-img");
    const tooltipName = document.getElementById("tooltip-item-name");
    const tooltipRarity = document.getElementById("tooltip-item-rarity");
    const tooltipItemType = document.getElementById("tooltip-item-type");
    const tooltipDesc = document.getElementById("tooltip-item-desc");
    const tooltipWeight = document.getElementById("tooltip-item-weight");
    const tooltipCount = document.getElementById("tooltip-item-count");
    const tooltipEffects = document.getElementById("tooltip-item-effects");
    const tooltipDpsRow = document.getElementById("tooltip-dps-row");
    const tooltipDpsStat = document.getElementById("tooltip-dps-stat");

    // ESTADO DO INVENTÁRIO
    let currentBagState = {
        invId: 1,
        maxWeight: 35000,
        maxSlots: 40,
        currentWeight: 0,
        items: {}
    };

    let activeInvFilter = "all";
    let invSearchQuery = "";
    let currentSortMode = "slot";
    let activeCraftCat = "all";
    let selectedRecipe = null;
    let craftAnimationTimer = null;
    let draggedSlot = null;
    let equippedWeapons = [null, null, null];

    // CATÁLOGO LOCAL DE RECEITAS
    const LOCAL_RECIPES = [
        {
            id: "craft_unity",
            label: "Constitutional Arms Unity (9mm)",
            category: "weapons",
            output: { item: "weapon_unity", count: 1 },
            timeSec: 6,
            description: "Montagem de pistola tática semiautomática utilizando polímero reforçado e câmara de 9mm.",
            inputs: [
                { item: "component_common", count: 15 },
                { item: "component_uncommon", count: 8 },
                { item: "metal_scrap", count: 10 }
            ]
        },
        {
            id: "craft_lexington",
            label: "Militech M-10AF Lexington",
            category: "weapons",
            output: { item: "weapon_lexington", count: 1 },
            timeSec: 8,
            description: "Usinagem de pistola automática de alta dispersão com controle eletrônico de cadência.",
            inputs: [
                { item: "component_uncommon", count: 20 },
                { item: "metal_scrap", count: 15 },
                { item: "microchip", count: 1 }
            ]
        },
        {
            id: "craft_nue",
            label: "Tsunami Nue (Armação de Precisão)",
            category: "weapons",
            output: { item: "weapon_nue", count: 1 },
            timeSec: 10,
            description: "Pistola japonesa forjada sob tolerâncias microscópicas. Alto recuo, impacto letal.",
            inputs: [
                { item: "component_rare", count: 15 },
                { item: "component_uncommon", count: 12 },
                { item: "upgrade_part", count: 2 }
            ]
        },
        {
            id: "craft_copperhead",
            label: "Nokota Copperhead (Assault Rifle)",
            category: "weapons",
            output: { item: "weapon_copperhead", count: 1 },
            timeSec: 12,
            description: "Fuzil de assalto de combate urbano com receptor de aço estampado e coronha dobrável.",
            inputs: [
                { item: "component_uncommon", count: 25 },
                { item: "component_rare", count: 15 },
                { item: "upgrade_part", count: 3 },
                { item: "metal_scrap", count: 20 }
            ]
        },
        {
            id: "craft_crusher",
            label: "Rostović Crusher (Auto-Shotgun)",
            category: "weapons",
            output: { item: "weapon_crusher", count: 1 },
            timeSec: 12,
            description: "Escopeta de tambor automática de cal. 12 para varredura de corredores em Megabuildings.",
            inputs: [
                { item: "component_rare", count: 20 },
                { item: "metal_scrap", count: 25 },
                { item: "upgrade_part", count: 3 }
            ]
        },
        {
            id: "craft_katana",
            label: "Katana Tática Arasaka",
            category: "weapons",
            output: { item: "weapon_katana", count: 1 },
            timeSec: 8,
            description: "Forja de lâmina monomolecular com balanceamento ergonômico anti-inércia.",
            inputs: [
                { item: "component_rare", count: 15 },
                { item: "metal_scrap", count: 20 },
                { item: "component_epic", count: 1 }
            ]
        },
        {
            id: "craft_ammo_handgun",
            label: "Lote de Munição 9mm (x50)",
            category: "ammo",
            output: { item: "ammo_handgun", count: 50 },
            timeSec: 3,
            description: "Prensagem de 50 cápsulas de latão com ogiva ogival e propelente padrão.",
            inputs: [
                { item: "component_common", count: 6 },
                { item: "gunpowder", count: 10 },
                { item: "metal_scrap", count: 6 }
            ]
        },
        {
            id: "craft_ammo_rifle",
            label: "Lote de Munição 5.56mm (x50)",
            category: "ammo",
            output: { item: "ammo_rifle", count: 50 },
            timeSec: 4,
            description: "50 cartuchos de fuzil com ponta de aço endurecido para penetração de coletes leves.",
            inputs: [
                { item: "component_uncommon", count: 8 },
                { item: "gunpowder", count: 15 },
                { item: "metal_scrap", count: 8 }
            ]
        },
        {
            id: "craft_ammo_shotgun",
            label: "Lote de Cartuchos Cal. 12 (x30)",
            category: "ammo",
            output: { item: "ammo_shotgun", count: 30 },
            timeSec: 4,
            description: "30 cartuchos de plástico reforçado com bagos múltiplos de chumbo e alta expansão.",
            inputs: [
                { item: "component_uncommon", count: 8 },
                { item: "gunpowder", count: 12 },
                { item: "metal_scrap", count: 10 }
            ]
        },
        {
            id: "craft_maxdoc",
            label: "Inalador MaxDoc Mk.1",
            category: "medical",
            output: { item: "maxdoc_mk1", count: 1 },
            timeSec: 4,
            description: "Síntese em nebulizador portátil com biogel de coagulação imediata.",
            inputs: [
                { item: "component_common", count: 6 },
                { item: "biogel", count: 2 }
            ]
        },
        {
            id: "craft_bounce_back",
            label: "Estimulante Bounce Back",
            category: "medical",
            output: { item: "bounce_back", count: 1 },
            timeSec: 5,
            description: "Ampola estéril de nano-reparadores teciduais para suporte metabólico prolongado.",
            inputs: [
                { item: "component_uncommon", count: 8 },
                { item: "biogel", count: 3 }
            ]
        },
        {
            id: "craft_neuroblocker",
            label: "Neurobloqueador Imunológico",
            category: "medical",
            output: { item: "neuroblocker", count: 1 },
            timeSec: 7,
            description: "Fórmula imunossupressora neural para resfriar sobrecargas sinápticas de ciberware.",
            inputs: [
                { item: "component_rare", count: 10 },
                { item: "biogel", count: 4 },
                { item: "microchip", count: 1 }
            ]
        },
        {
            id: "craft_comp_uncommon",
            label: "Componente Incomum (Tier 2)",
            category: "components",
            output: { item: "component_uncommon", count: 1 },
            timeSec: 2,
            description: "Refinamento e fusão de 3 componentes comuns em uma liga mais pura.",
            inputs: [
                { item: "component_common", count: 3 }
            ]
        },
        {
            id: "craft_comp_rare",
            label: "Componente Raro (Tier 3)",
            category: "components",
            output: { item: "component_rare", count: 1 },
            timeSec: 3,
            description: "Tratamento térmico de 3 componentes incomuns com revestimento semicondutor.",
            inputs: [
                { item: "component_uncommon", count: 3 }
            ]
        },
        {
            id: "craft_upgrade_part",
            label: "Módulo de Aprimoramento",
            category: "components",
            output: { item: "upgrade_part", count: 1 },
            timeSec: 5,
            description: "Montagem de servomecanismo de calibração a partir de sucatas e ligas estruturais.",
            inputs: [
                { item: "metal_scrap", count: 8 },
                { item: "component_uncommon", count: 4 }
            ]
        }
    ];

    // CATÁLOGO DE ITENS LOCAL COM DADOS VISUAIS E ESPECIFICAÇÕES DIEGÉTICAS
    const LOCAL_CATALOG = Object.assign({}, window.ItemsCatalog || {}, {
        // Fallbacks adicionais de vitais
        burrito_xxl: { name: "Burrito XXL Sintético", type: "consumable", rarity: "common", weight: 400, image: "burrito.png", desc: "Massa proteica apimentada de Night City.", effects: { fome: 35, energia: 10 } },
        spicy_ramen: { name: "Lamen Apimentado All-Foods", type: "consumable", rarity: "common", weight: 450, image: "burrito.png", desc: "Tigela quente de lamen com brotos de soja sintéticos.", effects: { fome: 40, energia: 15 } },
        synth_burger: { name: "Hambúrguer Sintético", type: "consumable", rarity: "common", weight: 350, image: "burrito.png", desc: "Hambúrguer suculento de soja com molho tártaro sintético.", effects: { fome: 30, energia: 8 } },
        clean_water: { name: "Água Purificada NC", type: "consumable", rarity: "common", weight: 500, image: "water.png", desc: "Água potável sem resíduos químicos pesados.", effects: { sede: 40 } },
        real_water: { name: "Água Mineral Real", type: "consumable", rarity: "rare", weight: 500, image: "water.png", desc: "Água pura 100% natural, sem filtros químicos.", effects: { sede: 60, estresse: -15 } },
        nicola_blue: { name: "Refrigerante NiCola Blue", type: "consumable", rarity: "common", weight: 330, image: "water.png", desc: "O clássico 'Taste the Love!' com gás e taurina.", effects: { sede: 25, energia: 12 } },
        chromanticore: { name: "Bebida Chromanticore", type: "consumable", rarity: "uncommon", weight: 350, image: "water.png", desc: "Explosão de sabores cromados e taurina sintética.", effects: { sede: 30, energia: 20 } },
        spunky_monkey: { name: "Spunky Monkey Energy", type: "consumable", rarity: "uncommon", weight: 350, image: "water.png", desc: "Bebida energética hiper-cafeinada.", effects: { sede: 25, energia: 25 } },
        synth_coffee: { name: "Café Sintético Hot-Cup", type: "consumable", rarity: "common", weight: 250, image: "coffee.png", desc: "Café pressurizado autocalecente.", effects: { sede: 15, energia: 20 } },
        combat_ration: { name: "Ração Tática Militech", type: "consumable", rarity: "rare", weight: 600, image: "burrito.png", desc: "Ração concentrada militar de longa duração.", effects: { fome: 50, energia: 30 } },
        wet_wipes: { name: "Lenços Umedecidos", type: "consumable", rarity: "common", weight: 80, image: "biogel.svg", desc: "Lenços com álcool isopropílico para higienização rápida.", effects: { higiene: 35 } },

        // Farmacêuticos e Médicos
        maxdoc_mk1: { name: "Inalador MaxDoc Mk.1", type: "medical", rarity: "common", weight: 150, image: "maxdoc.png", desc: "Biogel inalatório cicatrizante rápido.", effects: { saude: 30 } },
        bounce_back: { name: "Estimulante Bounce Back", type: "medical", rarity: "uncommon", weight: 150, image: "bounce_back.png", desc: "Injeção celular de nano-reparadores contínuos.", effects: { saude: 45, estresse: -10 } },
        bounce_back_mk1: { name: "Injeção Bounce Back Mk.1", type: "medical", rarity: "uncommon", weight: 150, image: "bounce_back.png", desc: "Estimulante celular de regeneração de tecido.", effects: { saude: 40 } },
        neuroblocker: { name: "Neurobloqueador Imunológico", type: "medical", rarity: "rare", weight: 100, image: "neuroblocker.svg", desc: "Estabiliza o cérebro contra surtos de ciberpsicose.", effects: { estresse: -40 } },
        biogel: { name: "Biogel Reparador Dermal", type: "medical", rarity: "common", weight: 200, image: "biogel.svg", desc: "Gel antimicrobiano para suturas de emergência.", effects: { saude: 20, higiene: 20 } },
        cryo_spray: { name: "Spray Criogênico Dermal", type: "medical", rarity: "uncommon", weight: 120, image: "biogel.svg", desc: "Resfriamento imediato para queimaduras e ferimentos térmicos.", effects: { saude: 25 } },

        // Munições
        ammo_handgun: { name: "Munição Pistola 9mm", type: "ammo", rarity: "common", weight: 15, image: "ammo_handgun.png", desc: "Balas 9mm para pistolas e submetralhadoras." },
        ammo_rifle: { name: "Munição Fuzil 5.56mm", type: "ammo", rarity: "uncommon", weight: 25, image: "ammo_rifle.png", desc: "Projéteis de rifle de alta penetração balística." },
        ammo_shotgun: { name: "Cartuchos Cal. 12", type: "ammo", rarity: "uncommon", weight: 45, image: "ammo_shotgun.png", desc: "Cartuchos de chumbo denso para dispersão letal." },
        ammo_sniper: { name: "Munição .50 BMG", type: "ammo", rarity: "rare", weight: 80, image: "ammo_sniper.png", desc: "Munição pesada perfurante anti-material." }
    });

    /**
     * Normaliza a estrutura de itens recebida do servidor (seja array ou dicionário associativo)
     * para um dicionário seguro slotMap[slotNumber] = itemData com metadados do catálogo.
     */
    function normalizeBagItems(rawItems) {
        const slotMap = {};
        if (!rawItems) return slotMap;

        if (Array.isArray(rawItems)) {
            rawItems.forEach((it, idx) => {
                if (it && it.itemId) {
                    const slotNum = Number(it.slot) || (idx + 1);
                    slotMap[slotNum] = {
                        slot: slotNum,
                        itemId: String(it.itemId),
                        count: Number(it.count) || 1,
                        metadata: it.metadata || {},
                        name: it.name,
                        desc: it.description || it.desc,
                        type: it.type,
                        rarity: it.rarity,
                        weight: it.weight,
                        image: it.image,
                        ammoType: it.ammoType,
                        slotType: it.slot,
                        effects: it.effects
                    };
                }
            });
        } else if (typeof rawItems === "object") {
            for (const key of Object.keys(rawItems)) {
                const it = rawItems[key];
                if (it && it.itemId) {
                    const slotNum = Number(it.slot) || Number(key);
                    slotMap[slotNum] = {
                        slot: slotNum,
                        itemId: String(it.itemId),
                        count: Number(it.count) || 1,
                        metadata: it.metadata || {},
                        name: it.name,
                        desc: it.description || it.desc,
                        type: it.type,
                        rarity: it.rarity,
                        weight: it.weight,
                        image: it.image,
                        ammoType: it.ammoType,
                        slotType: it.slot,
                        effects: it.effects
                    };
                }
            }
        }
        return slotMap;
    }

    function getItemDef(itemId, itemObj) {
        if (!itemId) return { name: "Desconhecido", type: "misc", rarity: "common", weight: 100, image: "default_item.svg", desc: "" };
        const key = String(itemId).trim();
        if (LOCAL_CATALOG[key]) return LOCAL_CATALOG[key];

        // Se o item recebido do servidor/cliente já veio enriquecido com o catálogo oficial
        if (itemObj && itemObj.name) {
            return {
                name: itemObj.name,
                type: itemObj.type || "misc",
                rarity: itemObj.rarity || "common",
                weight: itemObj.weight !== undefined ? itemObj.weight : 100,
                image: itemObj.image || "default_item.svg",
                desc: itemObj.desc || itemObj.description || "",
                ammoType: itemObj.ammoType,
                slot: itemObj.slotType || itemObj.slot,
                effects: itemObj.effects
            };
        }

        // Dedução inteligente de atributos para itens dinâmicos do banco
        let inferredType = "misc";
        let inferredRarity = "common";
        let inferredImage = "default_item.svg";
        let inferredWeight = 200;
        let inferredDps = null;

        if (key.startsWith("weapon_") || key.includes("gun") || key.includes("rifle") || key.includes("blade")) {
            inferredType = "weapon";
            inferredRarity = "rare";
            inferredImage = "weapon_unity.png";
            inferredWeight = 1500;
            inferredDps = 180;
        } else if (key.startsWith("ammo_")) {
            inferredType = "ammo";
            inferredRarity = "common";
            inferredImage = "ammo_handgun.png";
            inferredWeight = 20;
        } else if (key.startsWith("food_") || key.includes("water") || key.includes("burger") || key.includes("ramen") || key.includes("cola")) {
            inferredType = "consumable";
            inferredRarity = "common";
            inferredImage = key.includes("water") || key.includes("cola") ? "water.png" : "burrito.png";
            inferredWeight = 400;
        } else if (key.startsWith("med_") || key.includes("doc") || key.includes("back") || key.includes("spray") || key.includes("gel")) {
            inferredType = "medical";
            inferredRarity = "uncommon";
            inferredImage = key.includes("doc") ? "maxdoc.png" : "bounce_back.png";
            inferredWeight = 150;
        } else if (key.startsWith("component_") || key.includes("scrap") || key.includes("chip")) {
            inferredType = "crafting_material";
            inferredRarity = key.includes("rare") ? "rare" : (key.includes("epic") ? "epic" : "common");
            inferredImage = "component_common.svg";
            inferredWeight = 25;
        }

        const formattedName = key.replace(/_/g, " ").replace(/\b\w/g, l => l.toUpperCase());

        return {
            name: formattedName,
            type: inferredType,
            rarity: inferredRarity,
            weight: inferredWeight,
            image: inferredImage,
            dps: inferredDps,
            desc: "Item carregado do registro neural do cidadão."
        };
    }

    // STORAGE & CARREGAMENTO DO LOADOUT DE ARMAS
    const WEAPONS_STORAGE_KEY = "ls_weapon_loadout_slots";
    try {
        const savedWeapons = localStorage.getItem(WEAPONS_STORAGE_KEY);
        if (savedWeapons) {
            const parsedW = JSON.parse(savedWeapons);
            if (Array.isArray(parsedW) && parsedW.length === 3) {
                equippedWeapons = parsedW;
            }
        }
    } catch (_) {}

    function saveWeaponLoadout() {
        try {
            localStorage.setItem(WEAPONS_STORAGE_KEY, JSON.stringify(equippedWeapons));
        } catch (_) {}
    }

    function toggleEquipWeapon(itemId) {
        if (!itemId) return;
        const existingIdx = equippedWeapons.indexOf(itemId);
        if (existingIdx !== -1) {
            equippedWeapons[existingIdx] = null;
            saveWeaponLoadout();
            renderCombatLoadout();
            renderInventory();
            playBeep(340, 0.08, "sine");
            return;
        }

        const emptyIdx = equippedWeapons.findIndex(w => w === null);
        if (emptyIdx !== -1) {
            equippedWeapons[emptyIdx] = itemId;
            saveWeaponLoadout();
            renderCombatLoadout();
            renderInventory();
            playBeep(640, 0.1, "sine");
        } else {
            // Se os 3 slots estiverem ocupados, substitui o slot 1
            equippedWeapons[0] = itemId;
            saveWeaponLoadout();
            renderCombatLoadout();
            renderInventory();
            playBeep(580, 0.1, "triangle");
        }
    }

    function renderCombatLoadout() {
        if (!weaponSlotsEls || weaponSlotsEls.length < 3) return;

        weaponSlotsEls.forEach((slotEl, idx) => {
            if (!slotEl) return;
            const weaponId = equippedWeapons[idx];
            slotEl.innerHTML = "";

            if (weaponId) {
                const def = getItemDef(weaponId);
                slotEl.classList.remove("empty");
                slotEl.classList.add(`rarity-${def.rarity || "rare"}`);

                const header = document.createElement("div");
                header.className = "weapon-slot-header";
                header.innerHTML = `
                    <span class="weapon-slot-idx">SLOT 0${idx + 1}</span>
                    <span class="weapon-slot-type">${(def.type || "WEAPON").toUpperCase()}</span>
                `;
                slotEl.appendChild(header);

                const body = document.createElement("div");
                body.className = "weapon-slot-body";
                body.innerHTML = `
                    <img class="weapon-img" src="./images/${def.image || "weapon_unity.png"}" alt="${def.name}" />
                    <div class="weapon-info">
                        <div class="weapon-name">${def.name}</div>
                        <div class="weapon-meta">
                            <span class="weapon-dps">${def.dps || 180} DPS</span>
                            <span class="weapon-ammo">BALÍSTICA</span>
                        </div>
                    </div>
                `;
                slotEl.appendChild(body);

                const unequipBtn = document.createElement("button");
                unequipBtn.className = "weapon-unequip-btn";
                unequipBtn.title = "Desequipar arma";
                unequipBtn.textContent = "✕";
                unequipBtn.addEventListener("click", (e) => {
                    e.stopPropagation();
                    equippedWeapons[idx] = null;
                    saveWeaponLoadout();
                    renderCombatLoadout();
                    renderInventory();
                    playBeep(300, 0.08, "sine");
                });
                slotEl.appendChild(unequipBtn);

                // Tooltip
                slotEl.addEventListener("mouseenter", (e) => showItemTooltip({ itemId: weaponId, count: 1 }, def, e));
                slotEl.addEventListener("mouseleave", hideItemTooltip);
                slotEl.addEventListener("mousemove", updateTooltipPosition);
            } else {
                slotEl.classList.add("empty");
                slotEl.classList.remove("rarity-common", "rarity-uncommon", "rarity-rare", "rarity-epic");
                slotEl.innerHTML = `
                    <div class="weapon-slot-empty">
                        <span class="empty-plus">+</span>
                        <span class="empty-title">SLOT 0${idx + 1} VAZIO</span>
                        <span class="empty-sub">ARRASTE OU DUPLO-CLIQUE EM UMA ARMA</span>
                    </div>
                `;
            }

            // Drag & Drop no slot de arma
            slotEl.addEventListener("dragover", (e) => e.preventDefault());
            slotEl.addEventListener("drop", (e) => {
                e.preventDefault();
                if (draggedSlot !== null) {
                    const normalized = normalizeBagItems(currentBagState.items);
                    const draggedItem = normalized[draggedSlot];
                    if (draggedItem) {
                        const def = getItemDef(draggedItem.itemId);
                        if (def.type === "weapon") {
                            equippedWeapons[idx] = draggedItem.itemId;
                            saveWeaponLoadout();
                            renderCombatLoadout();
                            renderInventory();
                            playBeep(640, 0.1, "sine");
                        }
                    }
                    draggedSlot = null;
                }
            });
        });
    }

    function renderInventory() {
        if (!playerInventoryGrid) return;
        playerInventoryGrid.innerHTML = "";

        const items = normalizeBagItems(currentBagState.items);
        let filledCount = 0;
        let totalWeight = 0;

        let displayOrder = [];
        for (let s = 1; s <= currentBagState.maxSlots; s++) {
            displayOrder.push({ slot: s, item: items[s] });
        }

        if (currentSortMode !== "slot") {
            const rarityRank = { epic: 4, rare: 3, uncommon: 2, common: 1, misc: 0 };
            displayOrder.sort((a, b) => {
                if (!a.item && !b.item) return a.slot - b.slot;
                if (!a.item) return 1;
                if (!b.item) return -1;
                const defA = getItemDef(a.item.itemId, a.item);
                const defB = getItemDef(b.item.itemId, b.item);

                if (currentSortMode === "rarity") {
                    const diff = (rarityRank[defB.rarity] || 0) - (rarityRank[defA.rarity] || 0);
                    if (diff !== 0) return diff;
                    return defA.name.localeCompare(defB.name);
                } else if (currentSortMode === "weight") {
                    const diff = ((defB.weight || 0) * (b.item.count || 1)) - ((defA.weight || 0) * (a.item.count || 1));
                    if (diff !== 0) return diff;
                    return defA.name.localeCompare(defB.name);
                } else if (currentSortMode === "name") {
                    return defA.name.localeCompare(defB.name);
                }
                return a.slot - b.slot;
            });
        }

        displayOrder.forEach(({ slot: s, item }) => {
            const slotEl = document.createElement("div");
            slotEl.className = "inv-slot";
            slotEl.setAttribute("data-slot", s);

            if (item && item.itemId) {
                filledCount++;
                const def = getItemDef(item.itemId, item);
                const itemTotalWeight = (def.weight || 100) * (item.count || 1);
                totalWeight += itemTotalWeight;

                // Aplicar classe de raridade
                slotEl.classList.add(`rarity-${def.rarity || "common"}`);

                // Verificação de Filtros e Busca
                let isFilteredOut = false;
                if (activeInvFilter !== "all" && def.type !== activeInvFilter) {
                    isFilteredOut = true;
                }
                if (invSearchQuery && invSearchQuery.length > 0) {
                    const matchName = def.name.toLowerCase().includes(invSearchQuery);
                    const matchKey = item.itemId.toLowerCase().includes(invSearchQuery);
                    if (!matchName && !matchKey) {
                        isFilteredOut = true;
                    }
                }
                if (isFilteredOut) {
                    slotEl.style.opacity = "0.15";
                }

                // Tag de índice
                const idxTag = document.createElement("span");
                idxTag.className = "slot-idx-tag";
                idxTag.textContent = String(s).padStart(2, "0");
                slotEl.appendChild(idxTag);

                // Tag de tipo
                const typeTag = document.createElement("span");
                typeTag.className = "slot-type-tag";
                typeTag.textContent = (def.type || "ITEM").replace("_", " ").toUpperCase();
                slotEl.appendChild(typeTag);

                // Dot de raridade
                const rarityDot = document.createElement("span");
                rarityDot.className = "slot-rarity-dot";
                slotEl.appendChild(rarityDot);

                // Badge de equipado (Armas ou Radial)
                const isEquippedInWeapon = equippedWeapons.includes(item.itemId);
                const isEquippedInRadial = equippedRadialSlots.includes(item.itemId);
                if (isEquippedInWeapon || isEquippedInRadial) {
                    const eqBadge = document.createElement("span");
                    eqBadge.className = "equipped-badge";
                    eqBadge.textContent = isEquippedInWeapon ? "ARMADO" : "RADIAL";
                    slotEl.appendChild(eqBadge);
                }

                // Imagem do Item em alta resolução
                const imgEl = document.createElement("img");
                imgEl.className = "slot-img";
                imgEl.src = `./images/${def.image || "default_item.svg"}`;
                imgEl.alt = def.name;
                slotEl.appendChild(imgEl);

                // Nome do Item
                const nameEl = document.createElement("span");
                nameEl.className = "slot-name";
                nameEl.textContent = def.name;
                slotEl.appendChild(nameEl);

                // Contador de quantidade
                const countEl = document.createElement("span");
                countEl.className = "slot-count";
                countEl.textContent = `x${item.count || 1}`;
                slotEl.appendChild(countEl);

                // Barra inferior de raridade
                const barEl = document.createElement("div");
                barEl.className = "slot-rarity-bar";
                slotEl.appendChild(barEl);

                // Tooltip events diegéticos Kiroshi
                slotEl.addEventListener("mouseenter", (e) => showItemTooltip(item, def, e));
                slotEl.addEventListener("mouseleave", hideItemTooltip);
                slotEl.addEventListener("mousemove", updateTooltipPosition);

                // Duplo clique: se for arma equipa no loadout, se for consumível consome
                slotEl.addEventListener("dblclick", () => {
                    playBeep(520, 0.08, "sine");
                    if (def.type === "weapon") {
                        toggleEquipWeapon(item.itemId);
                    } else {
                        if (window.Open77) Open77.emit("inventory:useItem", { slot: s });
                    }
                });

                // Clique direito: se arma equipa/desequipa no loadout de armas, caso contrário no radial
                slotEl.addEventListener("contextmenu", (e) => {
                    e.preventDefault();
                    if (def.type === "weapon") {
                        toggleEquipWeapon(item.itemId);
                    } else {
                        toggleEquipItemInRadial(item.itemId);
                    }
                });

                // Drag & Drop
                slotEl.draggable = true;
                slotEl.addEventListener("dragstart", (e) => {
                    draggedSlot = s;
                    e.dataTransfer.setData("text/plain", s);
                });
            } else {
                slotEl.classList.add("empty");
                slotEl.innerHTML = `
                    <span class="slot-empty-num">${String(s).padStart(2, "0")}</span>
                    <span class="slot-empty-wm">EMPTY</span>
                `;
            }

            slotEl.addEventListener("dragover", (e) => e.preventDefault());
            slotEl.addEventListener("drop", (e) => {
                e.preventDefault();
                if (draggedSlot && draggedSlot !== s) {
                    playBeep(440, 0.06, "sine");
                    if (window.Open77) Open77.emit("inventory:moveItem", { fromSlot: draggedSlot, toSlot: s });
                    draggedSlot = null;
                }
            });

            playerInventoryGrid.appendChild(slotEl);
        });

        // Atualizar telemetria de peso
        const currentKg = (totalWeight / 1000).toFixed(1);
        const maxKg = (currentBagState.maxWeight / 1000).toFixed(1);
        if (bagWeightText) bagWeightText.textContent = `${currentKg} / ${maxKg} kg`;

        const pct = Math.min(100, Math.round((totalWeight / currentBagState.maxWeight) * 100));
        if (bagWeightFill) {
            bagWeightFill.style.width = `${pct}%`;
            if (pct >= 90) bagWeightFill.classList.add("danger");
            else bagWeightFill.classList.remove("danger");
        }

        if (bagSlotCount) {
            bagSlotCount.textContent = `${filledCount} / ${currentBagState.maxSlots} SLOTS`;
        }

        renderCombatLoadout();
        renderRadialLoadout();
    }

    // =========================================================================
    // LOADOUT TÁTICO DO MENU RADIAL (8 SLOTS DIRECIONAIS)
    // =========================================================================
    const RADIAL_STORAGE_KEY = "ls_radial_loadout_slots";
    const RADIAL_COMPASS = [
        { key: "1", dir: "↑", label: "NORTE" },
        { key: "2", dir: "↗", label: "NORDESTE" },
        { key: "3", dir: "→", label: "LESTE" },
        { key: "4", dir: "↘", label: "SUDESTE" },
        { key: "5", dir: "↓", label: "SUL" },
        { key: "6", dir: "↙", label: "SUDOESTE" },
        { key: "7", dir: "←", label: "OESTE" },
        { key: "8", dir: "↖", label: "NOROESTE" }
    ];

    let equippedRadialSlots = ["weapon_unity", "ammo_handgun", "maxdoc_mk1", "burrito_xxl", "clean_water", null, null, null];
    try {
        const saved = localStorage.getItem(RADIAL_STORAGE_KEY);
        if (saved) {
            const parsed = JSON.parse(saved);
            if (Array.isArray(parsed) && parsed.length === 8) {
                equippedRadialSlots = parsed;
            }
        }
    } catch (_) {}

    function saveRadialLoadout() {
        try {
            localStorage.setItem(RADIAL_STORAGE_KEY, JSON.stringify(equippedRadialSlots));
        } catch (_) {}
    }

    function toggleEquipItemInRadial(itemId) {
        const existingIndex = equippedRadialSlots.indexOf(itemId);
        if (existingIndex !== -1) {
            equippedRadialSlots[existingIndex] = null;
            saveRadialLoadout();
            renderRadialLoadout();
            playBeep(320, 0.08, "sine");
            return;
        }

        const emptyIndex = equippedRadialSlots.findIndex(s => s === null);
        if (emptyIndex !== -1) {
            equippedRadialSlots[emptyIndex] = itemId;
            saveRadialLoadout();
            renderRadialLoadout();
            playBeep(620, 0.1, "sine");
        } else {
            playBeep(220, 0.1, "sawtooth");
        }
    }

    function renderRadialLoadout() {
        if (!radialLoadoutSlotsEl) return;
        radialLoadoutSlotsEl.innerHTML = "";
        const invItems = currentBagState.items || {};

        // Contar estoque de cada item na mochila
        const stockMap = {};
        for (const s in invItems) {
            const it = invItems[s];
            stockMap[it.itemId] = (stockMap[it.itemId] || 0) + (it.count || 1);
        }

        for (let i = 0; i < 8; i++) {
            const cardEl = document.createElement("div");
            cardEl.className = "radial-slot-card";
            cardEl.setAttribute("data-radial-index", i);

            const compassTag = document.createElement("span");
            compassTag.className = "compass-tag";
            compassTag.textContent = `[${RADIAL_COMPASS[i].key}]`;
            cardEl.appendChild(compassTag);

            const compassArrow = document.createElement("span");
            compassArrow.className = "compass-arrow";
            compassArrow.textContent = RADIAL_COMPASS[i].dir;
            cardEl.appendChild(compassArrow);

            const itemId = equippedRadialSlots[i];
            if (itemId) {
                const def = getItemDef(itemId);
                const count = stockMap[itemId] || 0;

                cardEl.classList.add(`rarity-${def.rarity || "common"}`);

                const imgEl = document.createElement("img");
                imgEl.src = `./images/${def.image || "default_item.svg"}`;
                imgEl.alt = def.name;
                cardEl.appendChild(imgEl);

                const countBadge = document.createElement("span");
                countBadge.className = "slot-count-badge";
                if (count > 0) {
                    countBadge.textContent = `x${count}`;
                } else {
                    cardEl.classList.add("out-of-stock");
                    countBadge.textContent = "0";
                }
                cardEl.appendChild(countBadge);

                cardEl.title = `[${RADIAL_COMPASS[i].key}] ${def.name} (${RADIAL_COMPASS[i].label}) - Botão direito para desequipar`;

                // Clique direito no card do radial para desequipar
                cardEl.addEventListener("contextmenu", (e) => {
                    e.preventDefault();
                    equippedRadialSlots[i] = null;
                    saveRadialLoadout();
                    renderRadialLoadout();
                    playBeep(320, 0.08, "sine");
                });
            } else {
                cardEl.classList.add("empty");
                cardEl.title = `Slot Radial [${RADIAL_COMPASS[i].key}] ${RADIAL_COMPASS[i].label} (Vazio - Arraste um item aqui)`;
            }

            // Drag & Drop para equipar itens no slot do radial
            cardEl.addEventListener("dragover", (e) => {
                e.preventDefault();
                cardEl.classList.add("drag-over");
            });

            cardEl.addEventListener("dragleave", () => {
                cardEl.classList.remove("drag-over");
            });

            cardEl.addEventListener("drop", (e) => {
                e.preventDefault();
                cardEl.classList.remove("drag-over");
                if (draggedSlot && currentBagState.items[draggedSlot]) {
                    const item = currentBagState.items[draggedSlot];
                    equippedRadialSlots[i] = item.itemId;
                    saveRadialLoadout();
                    renderRadialLoadout();
                    playBeep(640, 0.1, "sine");
                    draggedSlot = null;
                }
            });

            radialLoadoutSlotsEl.appendChild(cardEl);
        }
    }

    // =========================================================================
    // CRAFTING CONTROLLER
    // =========================================================================
    function renderCraftingRecipes() {
        if (!craftingRecipesList) return;
        craftingRecipesList.innerHTML = "";

        const filtered = LOCAL_RECIPES.filter(r => activeCraftCat === "all" || r.category === activeCraftCat);

        filtered.forEach((recipe, idx) => {
            const def = getItemDef(recipe.output.item);
            const cardEl = document.createElement("div");
            cardEl.className = "recipe-card";
            if (selectedRecipe && selectedRecipe.id === recipe.id) cardEl.classList.add("active");

            const imgEl = document.createElement("img");
            imgEl.className = "recipe-card-img";
            imgEl.src = `./images/${def.image || "default_item.svg"}`;
            cardEl.appendChild(imgEl);

            const infoEl = document.createElement("div");
            infoEl.className = "recipe-card-info";

            const titleEl = document.createElement("span");
            titleEl.className = "recipe-card-title";
            titleEl.textContent = recipe.label;
            infoEl.appendChild(titleEl);

            const subEl = document.createElement("span");
            subEl.className = "recipe-card-sub";
            subEl.textContent = `Tempo: ${recipe.timeSec}s | Qtd: x${recipe.output.count}`;
            infoEl.appendChild(subEl);

            cardEl.appendChild(infoEl);

            cardEl.addEventListener("click", () => {
                selectedRecipe = recipe;
                document.querySelectorAll(".recipe-card").forEach(c => c.classList.remove("active"));
                cardEl.classList.add("active");
                renderRecipeDetails(recipe);
                playBeep(480, 0.05, "sine");
            });

            craftingRecipesList.appendChild(cardEl);
        });

        if (!selectedRecipe && filtered.length > 0) {
            selectedRecipe = filtered[0];
            renderRecipeDetails(filtered[0]);
        }
    }

    function renderRecipeDetails(recipe) {
        if (!recipe) return;
        const def = getItemDef(recipe.output.item);

        if (recipeDetailImg) recipeDetailImg.src = `./images/${def.image || "default_item.svg"}`;
        if (recipeDetailTitle) recipeDetailTitle.textContent = recipe.label;
        if (recipeDetailMeta) recipeDetailMeta.textContent = `Tempo de Produção: ${recipe.timeSec}s | Rendimento: x${recipe.output.count}`;
        if (recipeDetailDesc) recipeDetailDesc.textContent = recipe.description;

        if (recipeReqsList) {
            recipeReqsList.innerHTML = "";
            let canCraft = true;

            // Contar insumos no inventário
            const invItems = currentBagState.items || {};
            const availableCounts = {};
            for (let slot in invItems) {
                const it = invItems[slot];
                availableCounts[it.itemId] = (availableCounts[it.itemId] || 0) + it.count;
            }

            recipe.inputs.forEach(req => {
                const reqDef = getItemDef(req.item);
                const has = availableCounts[req.item] || 0;
                const isSufficient = has >= req.count;
                if (!isSufficient) canCraft = false;

                const reqRow = document.createElement("div");
                reqRow.className = `req-item ${isSufficient ? "has-enough" : "missing"}`;

                const leftSpan = document.createElement("span");
                leftSpan.textContent = reqDef.name;

                const rightSpan = document.createElement("span");
                rightSpan.textContent = `[ ${has} / ${req.count} ]`;

                reqRow.appendChild(leftSpan);
                reqRow.appendChild(rightSpan);
                recipeReqsList.appendChild(reqRow);
            });

            if (btnCraftItem) {
                btnCraftItem.disabled = !canCraft;
            }
        }
    }

    if (btnCraftItem) {
        btnCraftItem.addEventListener("click", () => {
            if (!selectedRecipe) return;
            playBeep(600, 0.1, "sine");
            btnCraftItem.disabled = true;

            if (window.Open77) {
                Open77.emit("inventory:startCraft", { recipeId: selectedRecipe.id });
            }

            // Animação de progresso no cliente
            if (craftProgressBox && craftProgFill && craftProgTimer) {
                craftProgressBox.classList.remove("hidden");
                craftProgFill.style.width = "0%";
                let elapsed = 0;
                const total = selectedRecipe.timeSec * 10;

                clearInterval(craftAnimationTimer);
                craftAnimationTimer = setInterval(() => {
                    elapsed++;
                    const progress = Math.min(100, (elapsed / total) * 100);
                    craftProgFill.style.width = `${progress}%`;
                    const remaining = Math.max(0, (selectedRecipe.timeSec - (elapsed / 10))).toFixed(1);
                    craftProgTimer.textContent = `${remaining}s`;

                    if (elapsed >= total) {
                        clearInterval(craftAnimationTimer);
                        craftProgressBox.classList.add("hidden");
                        playBeep(880, 0.15, "triangle");
                    }
                }, 100);
            }
        });
    }

    // Filtros de Crafting
    document.querySelectorAll(".craft-cat-btn").forEach(btn => {
        btn.addEventListener("click", () => {
            document.querySelectorAll(".craft-cat-btn").forEach(b => b.classList.remove("active"));
            btn.classList.add("active");
            activeCraftCat = btn.getAttribute("data-cat");
            renderCraftingRecipes();
        });
    });

    // Barra de Busca de Itens
    if (invSearchInput) {
        invSearchInput.addEventListener("input", (e) => {
            invSearchQuery = (e.target.value || "").trim().toLowerCase();
            renderInventory();
        });
    }
    if (btnClearSearch) {
        btnClearSearch.addEventListener("click", () => {
            if (invSearchInput) invSearchInput.value = "";
            invSearchQuery = "";
            renderInventory();
        });
    }

    // Botões de Ordenação
    if (invSortBtns && invSortBtns.length > 0) {
        invSortBtns.forEach(btn => {
            btn.addEventListener("click", () => {
                invSortBtns.forEach(b => b.classList.remove("active"));
                btn.classList.add("active");
                currentSortMode = btn.getAttribute("data-sort") || "slot";
                renderInventory();
            });
        });
    }

    // Filtros por Categoria do Inventário
    document.querySelectorAll(".inv-filter-btn").forEach(btn => {
        btn.addEventListener("click", () => {
            document.querySelectorAll(".inv-filter-btn").forEach(b => b.classList.remove("active"));
            btn.classList.add("active");
            activeInvFilter = btn.getAttribute("data-filter");
            renderInventory();
        });
    });

    // Abas do Painel Direito (Loadout & Equipamento, Crafting, Container)
    function switchRightPanelTab(tabName) {
        if (tabBtnLoadout) tabBtnLoadout.classList.toggle("active", tabName === "loadout");
        if (tabBtnCrafting) tabBtnCrafting.classList.toggle("active", tabName === "crafting");
        if (tabBtnSecondary) tabBtnSecondary.classList.toggle("active", tabName === "secondary");

        if (sidePanelLoadout) sidePanelLoadout.classList.toggle("hidden", tabName !== "loadout");
        if (sidePanelCrafting) sidePanelCrafting.classList.toggle("hidden", tabName !== "crafting");
        if (sidePanelSecondary) sidePanelSecondary.classList.toggle("hidden", tabName !== "secondary");
        playBeep(420, 0.05, "sine");
    }

    if (tabBtnLoadout) tabBtnLoadout.addEventListener("click", () => switchRightPanelTab("loadout"));
    if (tabBtnCrafting) tabBtnCrafting.addEventListener("click", () => switchRightPanelTab("crafting"));
    if (tabBtnSecondary) tabBtnSecondary.addEventListener("click", () => switchRightPanelTab("secondary"));

    function openInventoryModal() {
        if (!inventoryModalEl) return;
        inventoryModalEl.classList.remove("hidden");
        syncBiomonitorVisibilityWithModals();
        renderInventory();
        renderCombatLoadout();
        renderCraftingRecipes();
        playBeep(480, 0.1, "sine");
    }

    function closeInventoryModal() {
        if (!inventoryModalEl) return;
        inventoryModalEl.classList.add("hidden");
        hideItemTooltip();
        syncBiomonitorVisibilityWithModals();
        playBeep(320, 0.08, "sine");
        if (window.Open77) Open77.emit("inventory:close");
    }

    if (btnCloseInv) btnCloseInv.addEventListener("click", closeInventoryModal);
    if (btnCloseInvX) btnCloseInvX.addEventListener("click", closeInventoryModal);

    window.addEventListener("keydown", (e) => {
        if (!inventoryModalEl || inventoryModalEl.classList.contains("hidden")) return;
        const tag = (e.target && e.target.tagName) ? e.target.tagName.toUpperCase() : "";
        if (tag === "INPUT" || tag === "TEXTAREA") return;
        if (e.key === "Escape" || e.code === "Escape" || e.key === "i" || e.key === "I") {
            closeInventoryModal();
        }
    });

    // =========================================================================
    // QUICK RADIAL MENU (8 SETORES ANGULARES CONECTADOS AO LOADOUT DO JOGADOR)
    // =========================================================================
    let radialSelectedSlot = -1;
    let radialItemsMap = [];

    function openRadialMenu() {
        if (!radialOverlayEl || !radialSlicesGroup || !radialSlotsLayer) return;
        radialOverlayEl.classList.remove("hidden");
        radialSelectedSlot = -1;
        playBeep(580, 0.08, "sine");

        // Mapear os 8 setores angulares (0 a 7) para o array de equippedRadialSlots
        const invItems = currentBagState.items || {};
        radialItemsMap = [];

        for (let i = 0; i < 8; i++) {
            const equippedId = equippedRadialSlots[i];
            const compass = RADIAL_COMPASS[i] || { key: String(i + 1), dir: "", label: `SETOR ${i + 1}` };

            if (!equippedId) {
                radialItemsMap.push(null);
                continue;
            }

            // Localizar primeiro slot que contenha esse item e calcular estoque total na mochila
            let foundItem = null;
            let totalAvailable = 0;
            for (const s in invItems) {
                const it = invItems[s];
                if (it.itemId === equippedId) {
                    totalAvailable += (it.count || 1);
                    if (!foundItem) foundItem = it;
                }
            }

            if (foundItem) {
                radialItemsMap.push({
                    slot: foundItem.slot,
                    itemId: equippedId,
                    count: totalAvailable,
                    outOfStock: false,
                    compass: compass
                });
            } else {
                radialItemsMap.push({
                    slot: null,
                    itemId: equippedId,
                    count: 0,
                    outOfStock: true,
                    compass: compass
                });
            }
        }

        renderRadialSlices();
    }

    function closeRadialMenu() {
        if (!radialOverlayEl) return;
        radialOverlayEl.classList.add("hidden");

        if (radialSelectedSlot >= 0 && radialItemsMap[radialSelectedSlot]) {
            const item = radialItemsMap[radialSelectedSlot];
            if (item.slot && !item.outOfStock) {
                playBeep(720, 0.12, "triangle");
                if (window.Open77) {
                    Open77.emit("radial:triggerAction", { slot: item.slot, itemId: item.itemId });
                }
            } else if (item.outOfStock) {
                playBeep(240, 0.1, "sawtooth");
            }
        } else {
            playBeep(280, 0.05, "sine");
        }
    }

    function renderRadialSlices() {
        radialSlicesGroup.innerHTML = "";
        radialSlotsLayer.innerHTML = "";

        const numSlices = 8;
        const cx = 200, cy = 200;
        const rInner = 70, rOuter = 185;
        const angleStep = (2 * Math.PI) / numSlices;

        for (let i = 0; i < numSlices; i++) {
            const startAngle = i * angleStep - Math.PI / 2 - angleStep / 2;
            const endAngle = startAngle + angleStep;

            const x1 = cx + rOuter * Math.cos(startAngle);
            const y1 = cy + rOuter * Math.sin(startAngle);
            const x2 = cx + rOuter * Math.cos(endAngle);
            const y2 = cy + rOuter * Math.sin(endAngle);
            const x3 = cx + rInner * Math.cos(endAngle);
            const y3 = cy + rInner * Math.sin(endAngle);
            const x4 = cx + rInner * Math.cos(startAngle);
            const y4 = cy + rInner * Math.sin(startAngle);

            const pathD = `M ${x4} ${y4} L ${x1} ${y1} A ${rOuter} ${rOuter} 0 0 1 ${x2} ${y2} L ${x3} ${y3} A ${rInner} ${rInner} 0 0 0 ${x4} ${y4} Z`;

            const pathEl = document.createElementNS("http://www.w3.org/2000/svg", "path");
            pathEl.setAttribute("d", pathD);
            pathEl.setAttribute("class", "radial-slice");
            pathEl.setAttribute("data-index", i);

            const it = radialItemsMap[i];
            if (it && it.outOfStock) {
                pathEl.classList.add("out-of-stock-slice");
            }

            pathEl.addEventListener("mouseenter", () => highlightRadialSlice(i));
            radialSlicesGroup.appendChild(pathEl);

            // Adicionar nó visual com ícone
            const midAngle = startAngle + angleStep / 2;
            const nodeR = 125;
            const nodeX = cx + nodeR * Math.cos(midAngle);
            const nodeY = cy + nodeR * Math.sin(midAngle);

            const nodeEl = document.createElement("div");
            nodeEl.className = "radial-slot-node";
            nodeEl.style.left = `${nodeX}px`;
            nodeEl.style.top = `${nodeY}px`;

            if (it) {
                const def = getItemDef(it.itemId);
                const img = document.createElement("img");
                img.src = `./images/${def.image || "default_item.svg"}`;
                img.alt = def.name;
                nodeEl.appendChild(img);

                if (it.outOfStock) {
                    nodeEl.style.opacity = "0.35";
                    nodeEl.style.filter = "grayscale(1)";
                } else if (it.count > 1) {
                    const cntBadge = document.createElement("span");
                    cntBadge.className = "radial-node-badge";
                    cntBadge.textContent = `${it.count}`;
                    cntBadge.style.position = "absolute";
                    cntBadge.style.bottom = "-2px";
                    cntBadge.style.right = "-2px";
                    cntBadge.style.fontSize = "9px";
                    cntBadge.style.fontWeight = "bold";
                    cntBadge.style.color = "#22D8E2";
                    cntBadge.style.background = "rgba(0,0,0,0.8)";
                    cntBadge.style.padding = "1px 3px";
                    cntBadge.style.borderRadius = "2px";
                    nodeEl.appendChild(cntBadge);
                }
            } else {
                nodeEl.style.opacity = "0.2";
            }

            radialSlotsLayer.appendChild(nodeEl);
        }

        updateRadialCore(null);
    }

    function highlightRadialSlice(index) {
        radialSelectedSlot = index;
        document.querySelectorAll(".radial-slice").forEach(sl => sl.classList.remove("hovered"));
        const activeSlice = document.querySelector(`.radial-slice[data-index="${index}"]`);
        if (activeSlice) activeSlice.classList.add("hovered");

        const it = radialItemsMap[index];
        updateRadialCore(it);
        playBeep(400 + (index * 40), 0.03, "sine");
    }

    function updateRadialCore(item) {
        if (!radialCoreName || !radialCoreIcon || !radialCoreMeta) return;

        if (item) {
            const def = getItemDef(item.itemId);
            radialCoreName.textContent = `[${item.compass.key}] ${def.name}`;
            if (item.outOfStock) {
                radialCoreMeta.textContent = `[ ${item.compass.label} // ESGOTADO NA MOCHILA ]`;
                radialCoreMeta.style.color = "#FF5964";
            } else {
                radialCoreMeta.textContent = `[ ${item.compass.label} ${item.compass.dir} // x${item.count} ]`;
                radialCoreMeta.style.color = "#22D8E2";
            }
            radialCoreIcon.innerHTML = `<img src="./images/${def.image || "default_item.svg"}" alt="Icon">`;
        } else {
            radialCoreName.textContent = "SELECIONE UM ITEM";
            radialCoreMeta.textContent = "[ MOVA O CURSOR // 1 A 8 ]";
            radialCoreMeta.style.color = "";
            radialCoreIcon.innerHTML = "";
        }
    }

    if (radialOverlayEl) {
        radialOverlayEl.addEventListener("mousemove", (e) => {
            if (radialOverlayEl.classList.contains("hidden")) return;
            const svg = document.getElementById("radial-svg");
            if (!svg) return;
            const rect = svg.getBoundingClientRect();
            const cx = rect.left + rect.width / 2;
            const cy = rect.top + rect.height / 2;
            const dx = e.clientX - cx;
            const dy = e.clientY - cy;
            const dist = Math.hypot(dx, dy);

            if (dist < 45) {
                if (radialSelectedSlot !== -1) {
                    radialSelectedSlot = -1;
                    document.querySelectorAll(".radial-slice").forEach(sl => sl.classList.remove("hovered"));
                    updateRadialCore(null);
                }
                return;
            }

            const angle = Math.atan2(dy, dx);
            const angleStep = (2 * Math.PI) / 8;
            let normAngle = angle + Math.PI / 2 + angleStep / 2;
            if (normAngle < 0) normAngle += 2 * Math.PI;
            if (normAngle >= 2 * Math.PI) normAngle -= 2 * Math.PI;
            const sliceIndex = Math.floor(normAngle / angleStep) % 8;

            if (sliceIndex !== radialSelectedSlot) {
                highlightRadialSlice(sliceIndex);
            }
        });
    }

    // =========================================================================
    // TOOLTIP DIEGÉTICO KIROSHI
    // =========================================================================
    function showItemTooltip(item, def, e) {
        if (!itemTooltipEl) return;
        if (tooltipName) tooltipName.textContent = def.name;
        if (tooltipRarity) {
            tooltipRarity.textContent = (def.rarity || "comum").toUpperCase();
            tooltipRarity.className = `tooltip-rarity rarity-${def.rarity || "common"}`;
        }
        if (tooltipItemType) {
            tooltipItemType.textContent = (def.type || "ITEM").replace("_", " ").toUpperCase();
        }
        if (tooltipDesc) tooltipDesc.textContent = def.desc || def.description || "";
        if (tooltipWeight) tooltipWeight.textContent = `${((def.weight || 100) / 1000).toFixed(2)} kg`;
        if (tooltipCount) tooltipCount.textContent = `x${item.count || 1}`;

        // Hero image preview
        if (tooltipHeroImg) {
            tooltipHeroImg.src = `./images/${def.image || "default_item.svg"}`;
            tooltipHeroImg.alt = def.name;
        }

        // Se for arma com DPS definido
        if (tooltipDpsRow && tooltipDpsStat) {
            if (def.type === "weapon" && def.dps) {
                tooltipDpsStat.textContent = def.dps;
                tooltipDpsRow.classList.remove("hidden");
            } else {
                tooltipDpsRow.classList.add("hidden");
            }
        }

        if (tooltipEffects) {
            if (def.effects) {
                const effectsStr = Object.entries(def.effects).map(([k, v]) => `+${v} ${k.toUpperCase()}`).join(" | ");
                tooltipEffects.textContent = effectsStr;
                tooltipEffects.classList.remove("hidden");
            } else {
                tooltipEffects.classList.add("hidden");
            }
        }

        itemTooltipEl.classList.remove("hidden");
        updateTooltipPosition(e);
    }

    function updateTooltipPosition(e) {
        if (!itemTooltipEl || itemTooltipEl.classList.contains("hidden")) return;
        const offset = 18;
        let x = e.clientX + offset;
        let y = e.clientY + offset;

        // Limitar dentro da janela de visualização do navegador para não cortar
        const tooltipWidth = 360;
        const tooltipHeight = itemTooltipEl.offsetHeight || 320;
        if (x + tooltipWidth > window.innerWidth) {
            x = Math.max(10, e.clientX - tooltipWidth - offset);
        }
        if (y + tooltipHeight > window.innerHeight) {
            y = Math.max(10, window.innerHeight - tooltipHeight - 10);
        }

        itemTooltipEl.style.left = `${x}px`;
        itemTooltipEl.style.top = `${y}px`;
    }

    function hideItemTooltip() {
        if (!itemTooltipEl) return;
        itemTooltipEl.classList.add("hidden");
    }

    // =========================================================================
    // ESCAPE UNIVERSAL
    // =========================================================================
    window.addEventListener("keydown", (e) => {
        if (e.key === "Escape") {
            if (inventoryModalEl && !inventoryModalEl.classList.contains("hidden")) closeInventoryModal();
            if (atmModalEl && !atmModalEl.classList.contains("hidden")) closeAtmModal();
            if (vendingModalEl && !vendingModalEl.classList.contains("hidden")) closeVendingModal();
            if (ripperdocModalEl && !ripperdocModalEl.classList.contains("hidden")) closeRipperdocModal();
            if (settingsModalEl && !settingsModalEl.classList.contains("hidden")) closeSettingsModal();
            syncBiomonitorVisibilityWithModals();
        }
    });

    // =========================================================================
    // OPEN//77 NATIVE BRIDGE BINDINGS
    // =========================================================================
    if (window.Open77) {
        Open77.on("vitals:update", updateVitals);
        Open77.on("hud:vitals", updateVitals);
        Open77.on("hud:visibility", (p) => setVisibility(Boolean(p && p.visible !== false)));
        Open77.on("biomonitor:openSettings", openSettingsModal);
        Open77.on("vitals:damageAlert", triggerDamageAlert);
        Open77.on("economy:update", updateEconomy);
        Open77.on("atm:open", openAtmModal);
        Open77.on("atm:close", closeAtmModal);
        Open77.on("atm:feedback", (data) => {
            if (data && data.message) showAtmFeedback(data.message, data.success !== false);
        });
        Open77.on("vending:open", openVendingModal);
        Open77.on("vending:close", closeVendingModal);
        Open77.on("vending:feedback", (data) => {
            if (data && data.message) showVendingFeedback(data.message, data.success !== false);
        });
        Open77.on("ripperdoc:open", openRipperdocModal);
        Open77.on("ripperdoc:close", closeRipperdocModal);
        Open77.on("ripperdoc:updateData", updateRipperdocPatientDiag);
        Open77.on("ripperdoc:feedback", (data) => {
            if (data && data.message) showRipperFeedback(data.message, data.success !== false);
        });

        // NOVOS BINDINGS: INVENTÁRIO & CRAFTING
        Open77.on("inventory:toggle", (payload) => {
            const isOpen = (typeof payload === "object" && payload !== null) ? Boolean(payload.open) : Boolean(payload);
            if (isOpen) openInventoryModal(); else closeInventoryModal();
        });
        Open77.on("inventory:updateBag", (bagData) => {
            if (bagData) {
                currentBagState = {
                    invId: bagData.invId || currentBagState.invId || 1,
                    maxWeight: bagData.maxWeight || currentBagState.maxWeight || 35000,
                    maxSlots: bagData.maxSlots || currentBagState.maxSlots || 40,
                    currentWeight: bagData.currentWeight || 0,
                    items: normalizeBagItems(bagData.items)
                };
                renderInventory();
                renderCombatLoadout();
                renderCraftingRecipes();
            }
        });

        // NOVO BINDING: QUICK RADIAL MENU
        Open77.on("radial:toggle", (payload) => {
            const isActive = (typeof payload === "object" && payload !== null) ? Boolean(payload.active) : Boolean(payload);
            if (isActive) openRadialMenu(); else closeRadialMenu();
        });

        Open77.on("biomonitor:setPosition", (pos) => {
            if (pos && typeof pos.left === "number" && typeof pos.top === "number") {
                try {
                    localStorage.setItem(STORAGE_KEY, JSON.stringify(pos));
                } catch (_) {}
                applyPosition(pos.left, pos.top);
            }
        });

        // Sinalizar prontidão ao runtime do servidor
        Open77.ready();
        Open77.emit("ls:ui:ready", { version: "0.1.0" });
    }

    // Mock local para validação autônoma
    if (!window.Open77) {
        console.log("[ls_ui] Executando em ambiente de teste local independente com Kiroshi HUD v2.");
        updateVitals({
            hunger: 78,
            thirst: 65,
            energy: 92,
            hygiene: 80,
            stress: 15
        });
        updateEconomy({
            cash: 500,
            bank: 2500
        });
        currentBagState.items = normalizeBagItems({
            1: { itemId: "weapon_unity", slot: 1, count: 1 },
            2: { itemId: "weapon_tamayura", slot: 2, count: 1 },
            3: { itemId: "burrito_xxl", slot: 3, count: 3 },
            4: { itemId: "clean_water", slot: 4, count: 2 },
            5: { itemId: "spicy_ramen", slot: 5, count: 2 },
            6: { itemId: "nicola_blue", slot: 6, count: 4 },
            7: { itemId: "maxdoc_mk1", slot: 7, count: 2 },
            8: { itemId: "bounce_back_mk1", slot: 8, count: 1 },
            9: { itemId: "ammo_handgun", slot: 9, count: 60 },
            10: { itemId: "component_common", slot: 10, count: 25 },
            11: { itemId: "metal_scrap", slot: 11, count: 18 }
        });
        renderInventory();
        renderCombatLoadout();
        renderCraftingRecipes();
    }
})();



