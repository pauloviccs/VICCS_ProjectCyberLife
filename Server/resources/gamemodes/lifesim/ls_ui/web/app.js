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
            (ripperdocModalEl && !ripperdocModalEl.classList.contains("hidden"))
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

    // ESCAPE UNIVERSAL
    window.addEventListener("keydown", (e) => {
        if (e.key === "Escape") {
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
        console.log("[ls_ui] Executando em ambiente de teste local independente.");
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
    }
})();


