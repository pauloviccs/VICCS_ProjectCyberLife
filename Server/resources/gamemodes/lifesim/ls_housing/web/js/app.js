/**
 * LIFESIM RP - Housing Holographic Controller
 * Path: ls_housing/web/js/app.js
 */

(() => {
  "use strict";

  let currentApt = null;
  let activeTab = "tab-overview";
  let activeCatalogCategory = "all";

  // Elementos DOM
  const modalEl = document.getElementById("housing-modal");
  const btnCloseModal = document.getElementById("btn-close-modal");
  const navTabs = document.querySelectorAll(".nav-tab");
  const tabPanes = document.querySelectorAll(".tab-pane");
  const feedbackEl = document.getElementById("housing-feedback");

  // Campos de Informações
  const aptTitleEl = document.getElementById("apt-name-title");
  const aptBuildingSubEl = document.getElementById("apt-building-sub");
  const aptStatusBadgeEl = document.getElementById("apt-status-badge");
  const aptDistrictValEl = document.getElementById("apt-district-val");
  const aptBuildingValEl = document.getElementById("apt-building-val");
  const aptCapacityValEl = document.getElementById("apt-capacity-val");
  const aptLockValEl = document.getElementById("apt-lock-val");
  const aptRentDueValEl = document.getElementById("apt-rent-due-val");

  // Botões de Ação
  const btnEnter = document.getElementById("btn-enter-apartment");
  const btnRent = document.getElementById("btn-rent-apartment");
  const btnBuy = document.getElementById("btn-buy-apartment");
  const btnStartBuild = document.getElementById("btn-start-build");
  const aptRentPriceEl = document.getElementById("apt-rent-price");
  const aptBuyPriceEl = document.getElementById("apt-buy-price");

  // Catálogo
  const catalogListEl = document.getElementById("catalog-list");
  const catFilterBtns = document.querySelectorAll(".cat-filter-btn");

  // ===========================================================================
  // ÁUDIO DIEGÉTICO KIROSHI (Web Audio API)
  // ===========================================================================
  let audioCtx = null;
  function playBeep(freq = 880, duration = 0.05, type = "sine") {
    try {
      if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      if (audioCtx.state === "suspended") audioCtx.resume();
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.type = type;
      osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
      gain.gain.setValueAtTime(0.05, audioCtx.currentTime);
      gain.gain.linearRampToValueAtTime(0.001, audioCtx.currentTime + duration);
      osc.connect(gain);
      gain.connect(audioCtx.destination);
      osc.start();
      osc.stop(audioCtx.currentTime + duration);
    } catch (_) {}
  }

  // ===========================================================================
  // CATÁLOGO DE MOBÍLIAS PADRÃO (CLIENT CACHE)
  // ===========================================================================
  const defaultCatalog = [
    {
      id: "bed_futon_cyber",
      name: "Futon Night City Básico",
      category: "beds",
      price: 600,
      dimensions: { width: 1.3, length: 2.0, height: 0.55 }
    },
    {
      id: "bed_arasaka_ortho",
      name: "Cama Ortopédica Arasaka",
      category: "beds",
      price: 3200,
      dimensions: { width: 1.9, length: 2.2, height: 0.8 }
    },
    {
      id: "sofa_leather_cyber",
      name: "Sofá de Couro Sintético Neon",
      category: "seating",
      price: 1100,
      dimensions: { width: 2.2, length: 0.95, height: 0.85 }
    },
    {
      id: "chair_netrunner_ergonomic",
      name: "Cadeira Ergonômica Netrunner",
      category: "seating",
      price: 850,
      dimensions: { width: 0.75, length: 0.75, height: 1.25 }
    },
    {
      id: "desk_workstation_cyber",
      name: "Bancada Cyber-Desk",
      category: "tables",
      price: 1400,
      dimensions: { width: 1.7, length: 0.85, height: 0.78 }
    },
    {
      id: "table_coffee_glass",
      name: "Mesa de Centro Holográfica",
      category: "tables",
      price: 650,
      dimensions: { width: 1.1, length: 0.65, height: 0.45 }
    },
    {
      id: "shower_sonic_booth",
      name: "Cabine de Banho Sônica",
      category: "sanitary",
      price: 2400,
      dimensions: { width: 1.15, length: 1.15, height: 2.25 }
    },
    {
      id: "kitchen_synth_cooker",
      name: "Sintetizador Culinário Chef",
      category: "sanitary",
      price: 1900,
      dimensions: { width: 1.5, length: 0.75, height: 0.9 }
    },
    {
      id: "stash_heavy_safe",
      name: "Cofre Balístico Residencial",
      category: "storage",
      price: 1750,
      dimensions: { width: 1.0, length: 0.6, height: 0.7 }
    },
    {
      id: "lamp_cyber_ambient",
      name: "Luminária de Mesa Neon",
      category: "decor",
      price: 250,
      dimensions: { width: 0.35, length: 0.35, height: 0.45 }
    },
    {
      id: "holo_projector_koi",
      name: "Projetor Peixe Koi",
      category: "decor",
      price: 900,
      dimensions: { width: 0.4, length: 0.4, height: 0.3 }
    }
  ];

  // ===========================================================================
  // RENDERIZAÇÃO DO CATÁLOGO
  // ===========================================================================
  function renderCatalog() {
    if (!catalogListEl) return;
    catalogListEl.innerHTML = "";

    const filtered = activeCatalogCategory === "all"
      ? defaultCatalog
      : defaultCatalog.filter(i => i.category === activeCatalogCategory);

    filtered.forEach(item => {
      const card = document.createElement("div");
      card.className = "furniture-card";
      card.innerHTML = `
        <div class="furniture-card-top">
          <span class="furniture-category-badge">${item.category.toUpperCase()}</span>
          <span class="furniture-price-tag">E$ ${item.price.toLocaleString("pt-BR")}</span>
        </div>
        <div class="furniture-title">${item.name}</div>
        <div class="furniture-dims-pill">
          DIM: ${item.dimensions.width}m × ${item.dimensions.length}m × ${item.dimensions.height}m (OBB)
        </div>
        <button class="btn-place-furniture" data-id="${item.id}">
          [ POSICIONAR NOVO ]
        </button>
      `;

      card.querySelector(".btn-place-furniture").addEventListener("click", () => {
        playBeep(980, 0.08);
        if (window.Open77) {
          window.Open77.emit("housing:openBuildMode", { templateId: item.id });
        } else {
          console.log("[ls_housing] Mock selecionou para posicionar:", item.id);
        }
      });

      catalogListEl.appendChild(card);
    });
  }

  // ===========================================================================
  // ATUALIZAÇÃO DE DADOS DO APARTAMENTO
  // ===========================================================================
  function showApartmentInfo(data) {
    if (!data || !data.apartment) return;
    currentApt = data.apartment;

    aptTitleEl.textContent = currentApt.name;
    aptBuildingSubEl.textContent = `${currentApt.building} // ${currentApt.tier.toUpperCase()}`;
    aptDistrictValEl.textContent = `${currentApt.district} // ${currentApt.subdistrict}`;
    aptBuildingValEl.textContent = currentApt.building;
    aptCapacityValEl.textContent = `0 / ${currentApt.maxFurniture} peças`;

    aptRentPriceEl.textContent = (currentApt.rentPrice || 0).toLocaleString("pt-BR");
    aptBuyPriceEl.textContent = (currentApt.buyPrice || 0).toLocaleString("pt-BR");

    const badgeParent = aptStatusBadgeEl ? aptStatusBadgeEl.parentElement : null;

    if (data.hasLease) {
      if (data.leaseType === "owned") {
        aptStatusBadgeEl.textContent = "● PROPRIETÁRIO // QUITADO";
        if (badgeParent) badgeParent.className = "sync-badge owned";

        btnRent.style.display = "none";
        btnBuy.style.display = "none";
        btnEnter.style.display = "block";
        btnStartBuild.style.display = "block";

        aptLockValEl.textContent = data.isLocked ? "TRANCADO (CHAVE ATIVA)" : "DESTRANCADO";
        aptLockValEl.className = data.isLocked ? "info-val secure" : "info-val";
        aptRentDueValEl.textContent = "ESCRITURA DEFINITIVA (VITALÍCIO)";
        aptRentDueValEl.className = "info-val text-success";
      } else {
        // Aluguel
        const nowSec = (data.serverTime || Math.floor(Date.now() / 1000));
        const isExpired = data.rentDueUnix > 0 && data.rentDueUnix < nowSec;
        const d = data.rentDueUnix > 0 ? new Date(data.rentDueUnix * 1000) : null;
        const dateStr = d ? `${d.toLocaleDateString("pt-BR")} ${d.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" })}` : "Não definido";

        if (data.inGracePeriod) {
          aptStatusBadgeEl.textContent = `▲ CARÊNCIA (${data.graceHoursLeft || 24}H)`;
          if (badgeParent) badgeParent.className = "sync-badge grace";

          aptRentDueValEl.textContent = `VENCIDO (Carência: ${data.graceHoursLeft || 24}h restantes)`;
          aptRentDueValEl.className = "info-val text-warning";
          aptLockValEl.textContent = "ACESSO EM CARÊNCIA (REGULARIZE)";
          aptLockValEl.className = "info-val text-warning";

          btnEnter.style.display = "block";
          btnStartBuild.style.display = "block";
          btnRent.style.display = "block";
          btnRent.textContent = `REGULARIZAR ALUGUEL (E$ ${(currentApt.rentPrice || 0).toLocaleString("pt-BR")})`;
          btnBuy.style.display = "block";
        } else if (isExpired) {
          aptStatusBadgeEl.textContent = "▲ ALUGUEL VENCIDO";
          if (badgeParent) badgeParent.className = "sync-badge expired";

          aptRentDueValEl.textContent = `VENCIDO EM: ${dateStr}`;
          aptRentDueValEl.className = "info-val text-danger";
          aptLockValEl.textContent = "BLOQUEADO POR INADIMPLÊNCIA";
          aptLockValEl.className = "info-val text-danger";

          btnEnter.style.display = "none";
          btnStartBuild.style.display = "none";
          btnRent.style.display = "block";
          btnRent.textContent = `REGULARIZAR ALUGUEL (E$ ${(currentApt.rentPrice || 0).toLocaleString("pt-BR")})`;
          btnBuy.style.display = "block";
        } else {
          aptStatusBadgeEl.textContent = "● LOCAÇÃO EM DIA";
          if (badgeParent) badgeParent.className = "sync-badge active";

          aptRentDueValEl.textContent = `EM DIA (Vence: ${dateStr})`;
          aptRentDueValEl.className = "info-val text-success";
          aptLockValEl.textContent = data.isLocked ? "TRANCADO (CHAVE ATIVA)" : "DESTRANCADO";
          aptLockValEl.className = data.isLocked ? "info-val secure" : "info-val";

          btnEnter.style.display = "block";
          btnStartBuild.style.display = "block";
          btnRent.style.display = "block";
          btnRent.textContent = `RENOVAR ALUGUEL (+3 DIAS - E$ ${(currentApt.rentPrice || 0).toLocaleString("pt-BR")})`;
          btnBuy.style.display = "block";
        }
      }
    } else {
      aptStatusBadgeEl.textContent = "DISPONÍVEL PARA CONTRATO";
      if (badgeParent) badgeParent.className = "sync-badge";

      btnEnter.style.display = "none";
      btnStartBuild.style.display = "none";
      btnRent.style.display = "block";
      btnRent.textContent = `ALUGAR IMÓVEL (E$ ${(currentApt.rentPrice || 0).toLocaleString("pt-BR")} / 3 DIAS)`;
      btnBuy.style.display = "block";
      btnBuy.textContent = `COMPRA DEFINITIVA (E$ ${(currentApt.buyPrice || 0).toLocaleString("pt-BR")})`;
      aptLockValEl.textContent = "TRANCADO (SEM CONTRATO)";
      aptLockValEl.className = "info-val";
      aptRentDueValEl.textContent = "Disponível para ocupação imediata";
      aptRentDueValEl.className = "info-val";
    }

    renderCatalog();
    modalEl.classList.remove("hidden");
    playBeep(700, 0.08);
  }

  function showFeedback(data) {
    if (!feedbackEl || !data || !data.message) return;
    feedbackEl.textContent = data.message;
    feedbackEl.className = "feedback-banner " + (data.success ? "success" : "error");
    feedbackEl.classList.remove("hidden");
    setTimeout(() => {
      feedbackEl.classList.add("hidden");
    }, 4500);
  }

  // ===========================================================================
  // LISTENERS DE AÇÕES
  // ===========================================================================
  btnEnter.addEventListener("click", () => {
    if (currentApt && window.Open77) {
      playBeep(1100, 0.08);
      window.Open77.emit("housing:enter", { aptId: currentApt.id });
    }
  });

  btnRent.addEventListener("click", () => {
    if (currentApt && window.Open77) {
      playBeep(880, 0.08);
      window.Open77.emit("housing:rent", { aptId: currentApt.id });
    }
  });

  btnBuy.addEventListener("click", () => {
    if (currentApt && window.Open77) {
      playBeep(880, 0.08);
      window.Open77.emit("housing:buy", { aptId: currentApt.id });
    }
  });

  btnStartBuild.addEventListener("click", () => {
    if (window.Open77) {
      playBeep(980, 0.08);
      window.Open77.emit("housing:openBuildMode", { templateId: defaultCatalog[0].id });
    }
  });

  btnCloseModal.addEventListener("click", () => {
    modalEl.classList.add("hidden");
    if (window.Open77) {
      window.Open77.emit("housing:close");
    }
  });

  window.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && !modalEl.classList.contains("hidden")) {
      modalEl.classList.add("hidden");
      if (window.Open77) {
        window.Open77.emit("housing:close");
      }
    } else if (e.key === "Enter" && !modalEl.classList.contains("hidden")) {
      if (btnEnter && btnEnter.style.display !== "none") {
        playBeep(1100, 0.08);
        btnEnter.click();
      }
    }
  });

  // Troca de Abas
  navTabs.forEach(tab => {
    tab.addEventListener("click", () => {
      const target = tab.dataset.tab;
      activeTab = target;
      navTabs.forEach(t => t.classList.toggle("active", t === tab));
      tabPanes.forEach(p => p.classList.toggle("active", p.id === target));
      playBeep(800, 0.04);
    });
  });

  // Filtros de Catálogo
  catFilterBtns.forEach(btn => {
    btn.addEventListener("click", () => {
      activeCatalogCategory = btn.dataset.cat;
      catFilterBtns.forEach(b => b.classList.toggle("active", b === btn));
      renderCatalog();
      playBeep(850, 0.04);
    });
  });

  // ===========================================================================
  // INTEGRAÇÃO COM A PONTE OPEN//77
  // ===========================================================================
  if (window.Open77) {
    window.Open77.on("housing:showInfo", showApartmentInfo);
    window.Open77.on("housing:feedback", showFeedback);
    window.Open77.on("housing:close", () => {
      modalEl.classList.add("hidden");
    });

    window.Open77.ready();
    window.Open77.emit("ls:housing:ready", { version: "0.1.0" });
  }

  // Mock local para validação autônoma
  if (!window.Open77) {
    console.log("[ls_housing] Rodando em modo de validação autônoma local.");
    showApartmentInfo({
      apartment: {
        id: "h10_apt_v",
        name: "Megabuilding H10 - Apto 0705",
        district: "Watson",
        subdistrict: "Little China",
        building: "Megabuilding H10",
        tier: "Starter",
        rentPrice: 350,
        buyPrice: 18000,
        maxFurniture: 60
      },
      hasLease: true,
      leaseType: "rent",
      isLocked: true,
      rentDueUnix: Math.floor(Date.now() / 1000) + 86400 * 3
    });
  }
})();
