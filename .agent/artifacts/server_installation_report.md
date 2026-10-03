# Relatório de Instalação e Ativação: Servidor OPEN//77

> **Projeto:** VICCS Night City Life-Sim RP  
> **Servidor Host:** OPEN//77 Dedicated Server (.NET 8 Runtime - win-x64)  
> **Build:** `2.31.21+op77.121`  
> **Status:** 100% Operacional e Matriculado no Master Server

---

## 1. Topologia da Pasta do Servidor (`Server/`)

```text
Server/
├── .open77/                      # Chaves criptográficas geradas pela plataforma (ignorado no git)
│   ├── master-identity.json      # Identidade do servidor assinada pelo Master
│   └── resource-signing-key.json # Par de chaves Ed25519 para assinatura dos pacotes de recursos
├── acl.jsonc                     # Controle de acesso com perfis: helper, moderator e operator
├── check_config.bat              # Utilitário de validação rápida (--check-config)
├── config/
│   └── server.schema.json        # Esquema JSON Schema oficial (Draft 2020-12)
├── open77-client.d.lua           # Tipagens completas do cliente REDengine (558 KB)
├── open77-server.d.lua           # Tipagens completas do servidor REDengine (722 KB)
├── package-manifest.json         # Manifesto e hashes de integridade SHA-256 do pacote
├── resources/                    # Catálogo de recursos
│   ├── gamemodes/
│   │   ├── freeroam/             # Gamemode freeroam nativo
│   │   ├── lifesim/              # [NOVO] Gamemode customizado VICCS Life-Sim RP
│   │   ├── open77_cyberware_lab/ # Laboratório de teste de implantes
│   │   └── open77_freeroam/      # Complementos de freeroam
│   ├── open77_equipment/         # Equipamentos e slots
│   ├── open77_wardrobe/          # Guarda-roupa persistente
│   ├── polyzone/                 # Zonas tridimensionais
│   └── system/                   # 32 recursos oficiais do sistema OPEN//77
├── server.jsonc                  # Configuração autoritativa principal e licença Master
└── start_server.bat              # Script executável de inicialização do servidor dedicado
```

---

## 2. Configuração Autoritativa (`server.jsonc`)

O arquivo foi estruturado e validado contra o esquema oficial:

```jsonc
{
  "$schema": "./config/server.schema.json",
  "schemaVersion": 1,
  "identity": {
    "name": "VICCS Night City Life-Sim RP",
    "description": "Simulação social e biológica profunda inspirada em The Sims no universo de Cyberpunk 2077.",
    "locale": "pt-BR",
    "tags": ["lifesim", "roleplay", "brazil", "portugues", "cyberpunk"],
    "visibility": "public"
  },
  "network": {
    "port": 11778,
    "publicEndpoint": "127.0.0.1:11778",
    "maximumPlayers": 32
  },
  "simulation": {
    "tickRate": 30,
    "snapshotRate": 20,
    "expectedGameBuild": 231,
    "helloTimeoutSeconds": 30
  },
  "masterServer": {
    "enabled": true,
    "licenseKey": "op77_live_svWGISMFenupfaZhE31mGddAGzuTQHE-hP-YnxUZbh0",
    "publishPlayerList": true
  },
  "accessControl": {
    "file": "acl.jsonc"
  },
  "voice": {
    "enabled": true,
    "quality": "standard",
    "proximityDistance": 15.0
  },
  "resources": {
    "enabled": true,
    "root": "resources",
    "load": [
      "polyzone",
      "open77_equipment",
      "open77_wardrobe",
      "system/*",
      "gamemodes/lifesim/*"
    ]
  }
}
```

---

## 3. Evidências do Teste de Ativação ao Vivo

Executamos o binário do servidor para teste de aceitação real. O log de execução registrou:

1. **37 Recursos Carregados:** Todos os subsistemas (voz 3D `open-voice`, elevadores, portas, clima, inventário, veículos, armas) inicializados com sucesso em geração 1.
2. **Sockets de Rede:**
   - Jogo (UDP): `0.0.0.0:11778`
   - Download de Recursos HTTP (TCP): `0.0.0.0:11779`
3. **Comunicação com o Master Server:**
   - `[INF] Automatic Master enrollment completed.`
   - `[INF] Run lease granted by the master (expires 2026-10-01T15:28:20).`
   - `[INF] Registered server 38d7c275-be7a-4ece-b0d2-7c8ac12ac265 with the Open77 Master.`
